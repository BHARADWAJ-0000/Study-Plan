import http from 'node:http';

const port = Number(process.env.PORT || 8787);
const apiKey = process.env.GEMINI_API_KEY;
const model = process.env.GEMINI_MODEL || 'gemini-2.0-flash';

const headers = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Content-Type': 'application/json; charset=utf-8',
};

function send(response, status, body) {
  response.writeHead(status, headers);
  response.end(JSON.stringify(body));
}

function readBody(request) {
  return new Promise((resolve, reject) => {
    let raw = '';
    request.on('data', (chunk) => {
      raw += chunk;
      if (raw.length > 1_000_000) reject(new Error('Request is too large'));
    });
    request.on('end', () => resolve(raw ? JSON.parse(raw) : {}));
    request.on('error', reject);
  });
}

function fallbackPlan(topic, days = 7) {
  return Array.from({ length: Math.max(3, Math.min(days, 14)) }, (_, index) => ({
    day: index + 1,
    title: `${topic} focus`,
    tasks: [
      `Review the key ideas in ${topic}.`,
      'Complete 10 active-recall questions.',
      'Record one mistake and one takeaway.',
    ],
  }));
}

async function generatePlan(input) {
  const topic = String(input.topic || 'exam preparation').slice(0, 120);
  const days = Number(input.days || 7);
  if (!apiKey) return { source: 'offline', plan: fallbackPlan(topic, days) };

  const prompt = `Create a practical ${days}-day study plan for ${topic}. Return JSON only with this shape: {"plan":[{"day":1,"title":"...","tasks":["...","...","..."]}]}. Keep each task short and actionable.`;
  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
  const geminiResponse = await fetch(endpoint, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }),
  });
  if (!geminiResponse.ok) throw new Error(`Gemini returned ${geminiResponse.status}`);

  const data = await geminiResponse.json();
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text || '';
  const jsonText = text.replace(/^```json\s*/i, '').replace(/\s*```$/i, '').trim();
  const parsed = JSON.parse(jsonText);
  if (!Array.isArray(parsed.plan)) throw new Error('Gemini returned an invalid plan');
  return { source: 'gemini', plan: parsed.plan };
}

import { requestHandler } from './app.js';

const server = http.createServer(async (request, response) => {
  try {
    await requestHandler(request, response);
  } catch (error) {
    response.writeHead(500, { 'Content-Type': 'application/json; charset=utf-8' });
    response.end(JSON.stringify({ error: { code: 'INTERNAL_ERROR', message: error.message } }));
  }
});

server.listen(port, '0.0.0.0', () => {
  console.log(`Monkeymax API listening on http://0.0.0.0:${port}`);
});
