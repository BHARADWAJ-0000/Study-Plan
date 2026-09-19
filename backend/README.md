# Monkeymax API

The service exposes the study-plan workflow and runs locally without external services.
When `DATABASE_URL` and `REDIS_URL` are absent, it uses in-memory state and inline jobs.

## Start locally

```bash
cd /home/o/study_revision_app/backend
GEMINI_API_KEY="your-new-server-side-key" node server.js
```

The server binds to `0.0.0.0:8787`, so an Android device can reach it over the local network.
Never put `GEMINI_API_KEY` in the Flutter build.

## API

- `GET /api/v1/health`
- `POST /api/v1/materials/upload`
- `GET /api/v1/jobs/:job_id`
- `POST /api/v1/plans/generate`
- `GET /api/v1/plans/:plan_id`
- `POST /api/v1/quizzes/generate`
- `POST /api/v1/quizzes/evaluate`
- `POST /api/v1/plans/:plan_id/recalibrate`

`materials/upload` accepts JSON for local testing (`filename`, `text`) and multipart uploads with a `file` field.
The local parser indexes TXT/Markdown directly and records PDF/DOCX metadata for the document worker boundary.

## Production services

`docker-compose.yml` provides PostgreSQL with pgvector and Redis. `schema.sql` contains the persistence model for users, materials, chunks, topic graphs, plans, tasks, quizzes, and mastery events.
The current service intentionally reports `database: memory` and `queue: inline` until those environment variables and adapters are wired into deployment.
