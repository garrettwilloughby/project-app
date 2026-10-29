import { z } from 'zod';

export const HealthResponse = z.object({
  status: z.literal('ok'),
  db: z.object({
    connected: z.boolean(),
    serverTime: z.string(),
    userCount: z.number().int(),
  }),
});
export type HealthResponse = z.infer<typeof HealthResponse>;
