import express from 'express';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();
const PORT = process.env.PORT || 3000;

app.use(
  express.static(path.join(__dirname, 'public'), {
    // A design prototype is edited constantly; a cached stylesheet wastes more time than the
    // bytes save.
    etag: false,
    setHeaders: (res) => res.setHeader('Cache-Control', 'no-store'),
  })
);

app.get('/health', (_req, res) => res.json({ ok: true }));

// The full clickable prototype (Direction A). /app/<screen-id> deep-links.
app.get(['/app', '/app/:id'], (_req, res) =>
  res.sendFile(path.join(__dirname, 'public', 'app', 'index.html'))
);

// v2: the three direction studies rebuilt from the client's references.
app.get('/v2', (_req, res) => res.sendFile(path.join(__dirname, 'public', 'v2', 'index.html')));

// Deep links: /screen/tracking opens straight into that screen.
app.get('/screen/:id', (_req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`\n  Vinkol prototype  →  http://localhost:${PORT}\n`);
});
