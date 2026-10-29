import express from 'express';
import cors from 'cors';
import type { HealthResponse } from '@starter/shared';
import { pool } from './db';

// The Express app, kept separate from server.ts so the Lambda adapter can wrap it in block 2.
export const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', async (_req, res) => {
  const { rows } = await pool.query<{ now: Date; user_count: number }>(
    'select now(), (select count(*)::int from users) as user_count',
  );
  const body: HealthResponse = {
    status: 'ok',
    db: { connected: true, serverTime: rows[0].now.toISOString(), userCount: rows[0].user_count },
  };
  res.json(body);
});

app.use((err: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error(err);
  res.status(500).json({ error: 'internal_error' });
});
