// Serves dist/client on localhost the way Vercel serves it (vercel.json): clean URLs (/en is
// en.html), 404.html for unknown paths, the configured headers (CSP included) and brotli or
// gzip like a CDN. Lighthouse CI measures through it (lighthouserc.json): its own static server
// serves /en only as /en.html, a path the router does not know, so the English page would be
// measured as the 404 page.
//
//   node tools/ServeDist.ts [port]      default port 4173

import { existsSync, readFileSync, statSync } from "node:fs";
import { createServer } from "node:http";
import { extname, join } from "node:path";
import { brotliCompressSync, gzipSync } from "node:zlib";
import { siteDir } from "#tools/TextSources";

const root = join(siteDir, "dist/client");
const port = Number(process.argv[2] ?? 4173);
const vercel = JSON.parse(readFileSync(join(siteDir, "vercel.json"), "utf8")) as {
  headers: { source: string; headers: { key: string; value: string }[] }[];
};

const contentTypes: Record<string, string> = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".woff2": "font/woff2",
  ".png": "image/png",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".xml": "application/xml",
  ".txt": "text/plain; charset=utf-8",
};

function configuredHeaders(path: string): Record<string, string> {
  const headers: Record<string, string> = {};
  for (const rule of vercel.headers) {
    const pattern = new RegExp(`^${rule.source.replace("(.*)", ".*")}$`);
    if (pattern.test(path)) for (const { key, value } of rule.headers) headers[key] = value;
  }
  return headers;
}

function resolve(path: string): { file: string; status: number } {
  const file = path === "/" ? "index.html" : path.slice(1);
  const isFile = (name: string) =>
    existsSync(join(root, name)) && statSync(join(root, name)).isFile();
  if (isFile(file)) return { file, status: 200 };
  if (isFile(`${file}.html`)) return { file: `${file}.html`, status: 200 };
  return { file: "404.html", status: 404 };
}

createServer((request, response) => {
  const path = decodeURIComponent(new URL(request.url ?? "/", "http://localhost").pathname);
  const { file, status } = resolve(path);
  let body: Buffer = readFileSync(join(root, file));
  const headers: Record<string, string> = {
    "Content-Type": contentTypes[extname(file)] ?? "application/octet-stream",
    Vary: "Accept-Encoding",
    ...configuredHeaders(path),
  };
  const accepted = String(request.headers["accept-encoding"] ?? "");
  if (/\.(html|js|css|xml|svg|txt)$/.test(file)) {
    if (accepted.includes("br")) {
      body = brotliCompressSync(body);
      headers["Content-Encoding"] = "br";
    } else if (accepted.includes("gzip")) {
      body = gzipSync(body);
      headers["Content-Encoding"] = "gzip";
    }
  }
  response.writeHead(status, headers);
  response.end(body);
}).listen(port, "127.0.0.1", () =>
  console.log(`Đang phục vụ dist/client ở http://127.0.0.1:${port}`),
);
