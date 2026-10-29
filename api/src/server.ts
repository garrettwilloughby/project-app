import { app } from './app';

const port = Number(process.env.PORT ?? 3000);
// 0.0.0.0 so your phone on the same Wi-Fi can reach it.
app.listen(port, '0.0.0.0', () => console.log(`API listening on http://localhost:${port}`));
