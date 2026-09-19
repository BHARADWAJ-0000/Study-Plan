import crypto from 'node:crypto';

const port = Number(process.env.PORT || 8787);
const apiKey = process.env.GEMINI_API_KEY;
const model = process.env.GEMINI_MODEL || 'gemini-2.0-flash';
const now = () => new Date();
const id = (prefix) => `${prefix}_${crypto.randomUUID()}`;

const db = {
  materials: new Map(),
  jobs: new Map(),
  plans: new Map(),
  quizzes: new Map(),
};

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Content-Type': 'application/json; charset=utf-8',
};

function respond(response, status, body) {
  response.writeHead(status, corsHeaders);
  response.end(JSON.stringify(body));
}

function errorResponse(response, error) {
  const status = error.status || 400;
  return respond(response, status, { error: { code: error.code || 'REQUEST_ERROR', message: error.message } });
}

function assert(condition, message, code = 'INVALID_REQUEST') {
  if (!condition) {
    const error = new Error(message);
    error.status = 400;
    error.code = code;
    throw error;
  }
}

async function readBody(request) {
  const chunks = [];
  let size = 0;
  for await (const chunk of request) {
    size += chunk.length;
    assert(size <= 15 * 1024 * 1024, 'Request exceeds the 15 MB limit', 'PAYLOAD_TOO_LARGE');
    chunks.push(chunk);
  }
  return Buffer.concat(chunks);
}

function jsonBody(buffer) {
  if (!buffer.length) return {};
  try {
    return JSON.parse(buffer.toString('utf8'));
  } catch {
    const error = new Error('Request body must be valid JSON');
    error.status = 400;
    throw error;
  }
}

function parseMultipart(buffer, contentType) {
  const boundary = contentType.match(/boundary=(?:"([^"]+)"|([^;]+))/i)?.[1] || contentType.match(/boundary=(?:"([^"]+)"|([^;]+))/i)?.[2];
  assert(boundary, 'Multipart boundary is missing');
  const marker = Buffer.from(`--${boundary}`);
  const fields = {};
  let file = null;
  let offset = 0;

  while (offset < buffer.length) {
    const start = buffer.indexOf(marker, offset);
    if (start < 0) break;
    const headerStart = start + marker.length + 2;
    const headerEnd = buffer.indexOf(Buffer.from('\r\n\r\n'), headerStart);
    if (headerEnd < 0) break;
    const headers = buffer.subarray(headerStart, headerEnd).toString('utf8');
    const dataStart = headerEnd + 4;
    const next = buffer.indexOf(marker, dataStart);
    if (next < 0) break;
    const data = buffer.subarray(dataStart, Math.max(dataStart, next - 2));
    const name = headers.match(/name="([^"]+)"/)?.[1];
    const filename = headers.match(/filename="([^"]*)"/)?.[1];
    if (name && filename) file = { name: filename, bytes: data, contentType: headers.match(/Content-Type:\s*([^\r\n]+)/i)?.[1] || 'application/octet-stream' };
    else if (name) fields[name] = data.toString('utf8');
    offset = next;
  }
  return { fields, file };
}

function extractText(file, fields) {
  if (fields.text) return String(fields.text).slice(0, 200_000);
  if (!file) return '';
  const extension = file.name.toLowerCase().split('.').pop();
  if (extension === 'txt' || extension === 'md' || file.contentType.startsWith('text/')) return file.bytes.toString('utf8').slice(0, 200_000);
  return `Imported ${extension || 'document'}: ${file.name}. Extracted content will be indexed by the document worker.`;
}

function topicGraph(text, filename = 'notes') {
  const stopWords = new Set(['this', 'that', 'with', 'from', 'have', 'will', 'your', 'about', 'there', 'which', 'their', 'into', 'what', 'when']);
  const words = text.toLowerCase().replace(/[^a-z0-9\s]/g, ' ').split(/\s+/).filter((word) => word.length > 4 && !stopWords.has(word));
  const counts = new Map();
  for (const word of words) counts.set(word, (counts.get(word) || 0) + 1);
  const topics = [...counts.entries()].sort((a, b) => b[1] - a[1]).slice(0, 8);
  if (!topics.length) topics.push([filename.replace(/\.[^.]+$/, '') || 'Core concepts', 1]);
  return topics.map(([title, frequency], index) => ({
    topic_id: `top_${String(index + 1).padStart(2, '0')}`,
    title: title[0].toUpperCase() + title.slice(1),
    estimated_reading_minutes: Math.min(120, 25 + frequency * 5),
    difficulty: index < 2 ? 'medium' : 'easy',
    parent_chapter: 'Imported material',
    chunk_count: Math.max(1, Math.ceil(frequency / 3)),
  }));
}

function dateString(date) {
  return date.toISOString().slice(0, 10);
}

function buildSchedule({ examDate, dailyHours, pacing = 1, topics }) {
  const end = new Date(`${examDate}T23:59:59Z`);
  const start = now();
  const totalDays = Math.max(1, Math.min(60, Math.ceil((end - start) / 86_400_000)));
  const schedule = [];
  const topicList = topics.length ? topics : [{ topic_id: 'top_01', title: 'Core concepts', estimated_reading_minutes: 60 }];
  const minutesPerDay = Math.max(30, Math.round(Number(dailyHours || 2) * 60 * Number(pacing || 1)));

  for (let day = 0; day < totalDays; day += 1) {
    const date = new Date(start.getTime() + day * 86_400_000);
    const topic = topicList[day % topicList.length];
    const phase = day >= totalDays - 2 ? 'Mock quiz and final revision' : day % 3 === 2 ? 'Active recall and error review' : 'Concept learning';
    schedule.push({
      day: day + 1,
      date: dateString(date),
      available_hours: Number(dailyHours || 2),
      topics: [{
        topic_id: topic.topic_id,
        title: topic.title,
        estimated_minutes: Math.min(minutesPerDay, topic.estimated_reading_minutes || minutesPerDay),
        learning_objectives: [`Understand ${topic.title}`, `Apply ${topic.title} in practice`, phase],
        status: 'pending',
      }],
    });
  }
  return { total_days: totalDays, schedule };
}

function validatePlan(plan) {
  assert(typeof plan.plan_id === 'string' && plan.plan_id.length > 0, 'plan_id is required');
  assert(/^\d{4}-\d{2}-\d{2}$/.test(plan.exam_date), 'exam_date must use YYYY-MM-DD');
  assert(Array.isArray(plan.schedule), 'schedule must be an array');
  return plan;
}

async function geminiJson(prompt, fallback) {
  if (!apiKey) return { source: 'offline', value: fallback };
  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
  const result = await fetch(endpoint, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ contents: [{ parts: [{ text: `${prompt}\nReturn JSON only. Do not use markdown fences.` }] }] }),
  });
  if (!result.ok) throw new Error(`Gemini returned ${result.status}`);
  const body = await result.json();
  const text = body.candidates?.[0]?.content?.parts?.[0]?.text || '';
  return { source: 'gemini', value: JSON.parse(text.replace(/^```json\s*/i, '').replace(/\s*```$/i, '').trim()) };
}

async function processMaterial(jobId, materialId) {
  const material = db.materials.get(materialId);
  const job = db.jobs.get(jobId);
  try {
    material.text = material.text || '';
    material.topics = topicGraph(material.text, material.filename);
    material.status = 'ready';
    job.status = 'completed';
    job.result = { material_id: materialId, topic_graph: material.topics };
  } catch (error) {
    material.status = 'failed';
    job.status = 'failed';
    job.error = error.message;
  }
}

async function createQuiz(plan, topicId) {
  const topic = plan.material_topics.find((item) => item.topic_id === topicId) || plan.material_topics[0];
  const fallback = {
    questions: [{
      question: `Which approach best improves mastery of ${topic.title}?`,
      options: [
        { key: 'A', text: 'Passive rereading', explanation: 'Rereading can build familiarity but gives limited evidence of recall.' },
        { key: 'B', text: 'Active recall followed by error review', explanation: 'Correct. Retrieval and error review strengthen durable understanding.' },
        { key: 'C', text: 'Skipping difficult examples', explanation: 'Avoiding difficulty removes the practice needed to improve mastery.' },
        { key: 'D', text: 'Studying only the night before', explanation: 'Cramming reduces spacing and makes recall less reliable.' },
      ],
      correct_answer: 'B',
      source_page: 1,
    }],
  };
  const generated = await geminiJson(`Create one four-option quiz question about ${topic.title}. Explain why every option is correct or incorrect. Schema: ${JSON.stringify(fallback)}`, fallback);
    return { source: generated.source, ...generated.value };
}

async function handleApi(request, response, url, body) {
  if (request.method === 'GET' && url.pathname === '/api/v1/health') return respond(response, 200, { ok: true, ai_configured: Boolean(apiKey), database: process.env.DATABASE_URL ? 'configured' : 'memory', queue: process.env.REDIS_URL ? 'configured' : 'inline' });

  if (request.method === 'POST' && url.pathname === '/api/v1/materials/upload') {
    const contentType = request.headers['content-type'] || '';
    const parsed = contentType.includes('multipart/form-data') ? parseMultipart(body, contentType) : { fields: jsonBody(body), file: null };
    const filename = parsed.file?.name || parsed.fields.filename || 'syllabus.txt';
    const materialId = id('mat');
    const jobId = id('job');
    const material = { material_id: materialId, filename, status: 'processing', text: extractText(parsed.file, parsed.fields), created_at: now().toISOString() };
    db.materials.set(materialId, material);
    db.jobs.set(jobId, { job_id: jobId, status: 'queued', material_id: materialId, created_at: now().toISOString() });
    setImmediate(() => processMaterial(jobId, materialId));
    return respond(response, 202, { job_id: jobId, material_id: materialId, status: 'queued' });
  }

  const jobMatch = url.pathname.match(/^\/api\/v1\/jobs\/([^/]+)$/);
  if (request.method === 'GET' && jobMatch) {
    const job = db.jobs.get(jobMatch[1]);
    if (!job) return respond(response, 404, { error: { code: 'NOT_FOUND', message: 'Job not found' } });
    return respond(response, 200, job);
  }

  if (request.method === 'POST' && url.pathname === '/api/v1/plans/generate') {
    const input = jsonBody(body);
    assert(input.job_id, 'job_id is required');
    assert(input.exam_date, 'exam_date is required');
    const job = db.jobs.get(input.job_id);
    const material = job && db.materials.get(job.material_id);
    assert(material?.status === 'ready', 'Material is not ready yet', 'MATERIAL_NOT_READY');
    const schedule = buildSchedule({ examDate: input.exam_date, dailyHours: input.daily_hours || 2, pacing: input.student_pacing_factor || 1, topics: material.topics });
    const planId = id('plan');
    const plan = validatePlan({ plan_id: planId, exam_date: input.exam_date, total_days: schedule.total_days, schedule: schedule.schedule, material_topics: material.topics, progress: { completed_tasks: 0, mastery: 0, pacing_alert: null }, created_at: now().toISOString() });
    db.plans.set(planId, plan);
    return respond(response, 201, plan);
  }

  const planMatch = url.pathname.match(/^\/api\/v1\/plans\/([^/]+)$/);
  if (request.method === 'GET' && planMatch) {
    const plan = db.plans.get(planMatch[1]);
    if (!plan) return respond(response, 404, { error: { code: 'NOT_FOUND', message: 'Plan not found' } });
    return respond(response, 200, plan);
  }

  if (request.method === 'POST' && url.pathname === '/api/v1/quizzes/generate') {
    const input = jsonBody(body);
    const plan = db.plans.get(input.plan_id);
    assert(plan, 'plan_id was not found', 'NOT_FOUND');
    const quiz = await createQuiz(plan, input.topic_id);
    const quizId = id('quiz');
    const stored = { quiz_id: quizId, plan_id: input.plan_id, topic_id: input.topic_id || plan.material_topics[0].topic_id, ...quiz, created_at: now().toISOString() };
    db.quizzes.set(quizId, stored);
    return respond(response, 201, stored);
  }

  if (request.method === 'POST' && url.pathname === '/api/v1/quizzes/evaluate') {
    const input = jsonBody(body);
    const quiz = db.quizzes.get(input.quiz_id);
    assert(quiz, 'quiz_id was not found', 'NOT_FOUND');
    const answers = input.answers || {};
    let correct = 0;
    for (const [index, question] of quiz.questions.entries()) if (answers[index] === question.correct_answer) correct += 1;
    const score = Math.round((correct / quiz.questions.length) * 100);
    const plan = db.plans.get(quiz.plan_id);
    plan.progress.mastery = score;
    plan.progress.pacing_alert = score < 70 ? 'Review this topic and add a short recovery session.' : null;
    return respond(response, 200, { score, correct, total: quiz.questions.length, explanations: quiz.questions.map((question) => ({ question: question.question, options: question.options })), progress: plan.progress });
  }

  const recalibrateMatch = url.pathname.match(/^\/api\/v1\/plans\/([^/]+)\/recalibrate$/);
  if (request.method === 'POST' && recalibrateMatch) {
    const plan = db.plans.get(recalibrateMatch[1]);
    assert(plan, 'plan_id was not found', 'NOT_FOUND');
    const input = jsonBody(body);
    const remaining = plan.schedule.filter((day) => day.topics.some((topic) => topic.status !== 'completed'));
    const extraHours = Number(input.additional_daily_hours || 0);
    plan.progress.pacing_alert = remaining.length < 3 && extraHours <= 0 ? 'Pacing alert: increase daily study time to finish on schedule.' : null;
    return respond(response, 200, { plan_id: plan.plan_id, remaining_days: remaining.length, pacing_alert: plan.progress.pacing_alert, recommended_daily_hours: Math.max(1, (remaining[0]?.available_hours || 2) + (plan.progress.pacing_alert ? 1 : 0)) });
  }

  return respond(response, 404, { error: { code: 'NOT_FOUND', message: 'Endpoint not found' } });
}

export async function requestHandler(request, response) {
  if (request.method === 'OPTIONS') return respond(response, 204, {});
  const url = new URL(request.url, `http://${request.headers.host || 'localhost'}`);
  const body = await readBody(request);
  try {
    if (request.method === 'GET' && url.pathname === '/health') return respond(response, 200, { ok: true, aiConfigured: Boolean(apiKey) });
    if (request.method === 'POST' && url.pathname === '/generate-plan') {
      const input = jsonBody(body);
      const topic = String(input.topic || 'exam preparation').slice(0, 120);
      const plan = buildSchedule({ examDate: dateString(new Date(Date.now() + Number(input.days || 7) * 86_400_000)), dailyHours: 2, topics: [{ topic_id: 'top_01', title: topic, estimated_reading_minutes: 60 }] });
      return respond(response, 200, { source: 'offline', plan: plan.schedule.map((day) => ({ day: day.day, title: day.topics[0].title, tasks: day.topics[0].learning_objectives })) });
    }
    return await handleApi(request, response, url, body);
  } catch (error) {
    return errorResponse(response, error);
  }
}
