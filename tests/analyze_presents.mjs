// PresentMon 2.5.1's default CSV. Summarizes ETW events, not optical scanout.
// Display timing is ambiguous on mixed-refresh desktops; see PresentMon #108.
import { readFile, writeFile } from 'node:fs/promises';
const [input, output] = process.argv.slice(2);
const lines = (await readFile(input, 'utf8')).trim().split(/\r?\n/);
const headers = lines.shift().split(',');
const rows = lines.map(line => Object.fromEntries(line.split(',').map((v, i) => [headers[i], v])));
if (!rows.length) throw new Error('No present samples');
const distribution = name => {
  const values = rows.map(row => row[name]).filter(v => v !== 'NA' && v !== undefined && Number(v) > 0).map(Number).sort((a,b) => a-b);
  if (!values.length) return null;
  const q = p => values[Math.ceil(values.length * p) - 1];
  return { count: values.length, mean_ms: values.reduce((a,b) => a+b,0)/values.length, p50_ms:q(.5), p95_ms:q(.95), p99_ms:q(.99), max_ms:values.at(-1), over_20: values.filter(v => v>20).length };
};
const count = name => rows.reduce((result,row) => { result[row[name]] = (result[row[name]] ?? 0)+1; return result; },{});
const summary = { source: input, rows: rows.length, modes: count('PresentMode'), tearing: count('AllowsTearing'), sync_intervals: count('SyncInterval'), presents: distribution('MsBetweenPresents'), displayed: distribution('MsBetweenDisplayChange'), gpu_busy: distribution('MsGPUBusy'), cpu_busy: distribution('MsCPUBusy'), present_api: distribution('MsInPresentAPI') };
if (output) await writeFile(output, JSON.stringify(summary, null, 2)+'\n');
console.log(JSON.stringify(summary, null, 2));
