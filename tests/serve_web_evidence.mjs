// Local-only receiver for the opt-in game's own screenshots and metrics.
// No browser debugging, profile access, external network calls or dependencies.
// node tests/serve_web_evidence.mjs 8147 build/web build/evidence/p2b/web-1080
import http from 'node:http';
import path from 'node:path';
import { mkdir, readFile, writeFile } from 'node:fs/promises';

const [port = '8147', root = 'build/web', output = 'build/evidence/p2b/web-1080'] = process.argv.slice(2);
const webRoot = path.resolve(root);
await mkdir(output, { recursive: true });
const allowedLabels = new Set(['ready', 'alpha', 'visited_return', 'error', 'result', 'debug']);
const types = { '.html': 'text/html', '.js': 'text/javascript', '.wasm': 'application/wasm', '.pck': 'application/octet-stream', '.png': 'image/png' };
let firstFrame;
let screenshots = 0;
const server = http.createServer(async (request, response) => {
  try {
    if (request.url === '/__evidence' && request.method === 'POST') {
      if (request.headers['content-type'] !== 'application/json') throw new Error('JSON required');
      const chunks = [];
      let bytes = 0;
      for await (const chunk of request) {
        bytes += chunk.length;
        if (bytes > 24 * 1024 * 1024) throw new Error('Payload exceeds evidence limit');
        chunks.push(chunk);
      }
      const report = JSON.parse(Buffer.concat(chunks).toString('utf8'));
      if (report.kind === 'screenshot' && allowedLabels.has(report.label)) {
        const png = Buffer.from(report.png, 'base64');
        if (png.toString('hex', 0, 8) !== '89504e470d0a1a0a') throw new Error('PNG required');
        await writeFile(path.join(output, `${report.label}.png`), png);
        screenshots++;
        console.log(`Screenshot ${report.label}: ${png.readUInt32BE(16)}x${png.readUInt32BE(20)}`);
      } else if (report.kind === 'first_frame') {
        firstFrame = report;
        console.log(JSON.stringify(report));
      } else if (report.kind === 'complete') {
        await writeFile(path.join(output, 'metrics.json'), JSON.stringify({ ...report, first_frame: firstFrame, screenshots }, null, 2));
        console.log(JSON.stringify({ viewport: report.viewport, mean_fps: report.mean_fps, p95_ms: report.p95_ms, p99_ms: report.p99_ms, runs: report.runs.length, screenshots }));
        if (screenshots !== 6 || report.runs.some(run => !run.finished || run.errors)) process.exitCode = 1;
        response.end('ok');
        server.close();
        return;
      }
      response.end('ok');
      return;
    }
    if (request.method !== 'GET') { response.writeHead(405).end(); return; }
    const relative = decodeURIComponent(new URL(request.url, 'http://127.0.0.1').pathname);
    const file = path.resolve(webRoot, relative === '/' ? 'index.html' : `.${relative}`);
    if (!file.startsWith(webRoot + path.sep)) { response.writeHead(403).end(); return; }
    const body = await readFile(file);
    response.writeHead(200, { 'Content-Type': types[path.extname(file)] ?? 'application/octet-stream', 'Cache-Control': 'no-store' });
    response.end(body);
  } catch (error) {
    response.writeHead(400).end(String(error));
    console.error(error.message);
  }
});
server.listen(Number(port), '127.0.0.1', () => console.log(`Evidence server http://127.0.0.1:${port}/?evidence=1&capture=1`));
server.headersTimeout = 10000;
server.requestTimeout = 15000;
