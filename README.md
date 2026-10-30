## Layout

| Path            | What                                                                                                               |
| --------------- | ------------------------------------------------------------------------------------------------------------------ |
| `client/`          | React Native + Expo Router, TypeScript                                                                             |
| `api/`          | Express, TypeScript. `app.ts` is the app, `server.ts` runs it locally (a Lambda adapter wraps `app.ts` in block 2) |
| `shared/`       | zod schemas used by both the API and the app                                                                       |
| `sql/changelog/` | Liquibase changesets. One file per change; never edit one that has run                                             |
| `terraform/`        | Terraform (block 2)                                                                                                |

## Local dev

Prereqs: Node 22+, Docker, Expo Go on your phone.

```sh
npm install
cp .env.example .env     # local-only credentials
npm run db:up            # Postgres in Docker
npm run db:migrate       # Liquibase update
npm run dev:api          # http://localhost:3000/health
npm run dev:app          # scan the QR code with your phone
```

iPhone and Mac need to be on the same Wi-Fi. The app finds the API at the same IP Metro is served from; set `EXPO_PUBLIC_API_URL` to override.

## Checks

```sh
npm run typecheck
npm run lint
npm test
```
