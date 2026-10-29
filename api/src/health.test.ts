import { describe, expect, it, vi } from 'vitest';
import request from 'supertest';
import { HealthResponse } from '@starter/shared';

vi.mock('./db', () => ({
  pool: { query: vi.fn(async () => ({ rows: [{ now: new Date('2026-10-31T00:00:00Z'), user_count: 0 }] })) },
}));
const { app } = await import('./app');

describe('GET /health', () => {
  it('returns a body matching the shared schema', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(HealthResponse.parse(res.body).db.userCount).toBe(0);
  });
});
