// Last step of `pnpm build`: checks dist/client and fails the build when it is wrong, so Vercel
// keeps the deployment it has (docs/research/WebsiteStack.md, section 3, "Cách bảo vệ").
// Along the way it inserts the CSP <meta> with the hash of every inline script, drops the
// build-date <lastmod> from the sitemap and the plugin's pages.json, and lists every slot
// still waiting for data.

import { createHash } from "node:crypto";
import { existsSync, readFileSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { charsetFile, siteDir } from "#tools/TextSources";

const outDir = join(siteDir, "dist/client");
const failures: string[] = [];
const fail = (message: string) => failures.push(message);

const requiredFiles = [
  "index.html",
  "en.html",
  "404.html",
  "sitemap.xml",
  "robots.txt",
  "appcast.xml",
];
for (const file of requiredFiles) {
  if (!existsSync(join(outDir, file))) fail(`Thiếu ${file} trong dist/client.`);
}

function checkAppcastBytes() {
  const source = readFileSync(join(siteDir, "appcast.xml"));
  const output = join(outDir, "appcast.xml");
  if (existsSync(output) && !source.equals(readFileSync(output))) {
    fail("dist/client/appcast.xml khác từng byte với site/appcast.xml.");
  }
}

function cleanSitemap() {
  const path = join(outDir, "sitemap.xml");
  if (!existsSync(path)) return;
  // Start writes the build day as lastmod of every page; a wrong date is worse than none.
  // crawlLinks also follows links to built files (the VietQR image download) and lists them
  // as pages; only pages belong in a sitemap.
  const sitemap = readFileSync(path, "utf8")
    .replace(/\s*<lastmod>[^<]*<\/lastmod>/g, "")
    .replace(/\s*<url>\s*<loc>[^<]*\/assets\/[^<]*<\/loc>[\s\S]*?<\/url>/g, "");
  writeFileSync(path, sitemap);
  const locs = [...sitemap.matchAll(/<loc>([^<]*)<\/loc>/g)].map((match) => match[1]);
  const expected = ["https://dau.codefastlabs.com/", "https://dau.codefastlabs.com/en"];
  if (locs.join(" ") !== expected.join(" "))
    fail(`sitemap.xml có ${locs.join(", ")}, cần ${expected.join(", ")}.`);
  rmSync(join(outDir, "pages.json"), { force: true });
}

const inlineScript = /<script(?![^>]*\ssrc=)[^>]*>([\s\S]*?)<\/script>/g;

function sha256(text: string) {
  return `'sha256-${createHash("sha256").update(text, "utf8").digest("base64")}'`;
}

/**
 * The part of the policy that depends on the build (docs/research/WebsiteStack.md, section 3):
 * vercel.json cannot hold per-build hashes, so they go in a <meta> at the top of <head>.
 */
function insertCsp(html: string): string {
  const hashes = [...html.matchAll(inlineScript)].map((match) => sha256(match[1] ?? ""));
  const policy = [
    "default-src 'self'",
    `script-src 'self' ${hashes.join(" ")}`,
    // React writes style attributes, and hoisted <style> holds the models' keyframes.
    "style-src 'self' 'unsafe-inline'",
    "img-src 'self' data:",
    "font-src 'self'",
    "connect-src 'self'",
    "manifest-src 'self'",
  ].join("; ");
  return html.replace(
    "<head>",
    `<head><meta http-equiv="Content-Security-Policy" content="${policy}"/>`,
  );
}

function checkCsp(file: string, html: string) {
  const policy =
    /<meta http-equiv="Content-Security-Policy" content="([^"]*)"/.exec(html)?.[1] ?? "";
  for (const match of html.matchAll(inlineScript)) {
    if (!policy.includes(sha256(match[1] ?? "")))
      fail(`${file}: một script nội tuyến không có mã băm trong CSP.`);
  }
}

const entities: Record<string, string> = {
  amp: "&",
  lt: "<",
  gt: ">",
  quot: '"',
  apos: "'",
  nbsp: " ",
};

/** The text a reader sees: the body without scripts, styles and tags, entities decoded. */
function visibleText(html: string): string {
  const body = html.slice(html.indexOf("<body"));
  return body
    .replace(/<(script|style)[^>]*>[\s\S]*?<\/\1>/g, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/&(#x[0-9a-f]+|#\d+|\w+);/gi, (entity, name: string) => {
      if (name.startsWith("#x") || name.startsWith("#X"))
        return String.fromCodePoint(parseInt(name.slice(2), 16));
      if (name.startsWith("#")) return String.fromCodePoint(Number(name.slice(1)));
      return entities[name] ?? entity;
    });
}

function checkCharacters(file: string, text: string, charset: Set<string>) {
  const missing = new Set([...text].filter((char) => char > " " && !charset.has(char)));
  if (missing.size > 0) fail(`${file}: ký tự ngoài phông đã cắt: ${[...missing].join(" ")}`);
}

/** Internal links point at a file of the output; in-page links at an id of the page. */
function checkLinks(file: string, html: string) {
  const ids = new Set([...html.matchAll(/\sid="([^"]+)"/g)].map((match) => match[1]));
  for (const [, attribute, value = ""] of html.matchAll(/\s(href|src)="([^"]*)"/g)) {
    if (value.startsWith("#")) {
      if (value !== "#" && !ids.has(value.slice(1)))
        fail(`${file}: ${attribute}="${value}" không trỏ tới id nào.`);
      continue;
    }
    if (!value.startsWith("/") || value.startsWith("//")) continue;
    const path = value.replace(/[?#].*$/, "");
    const target = path === "/" ? "index.html" : path.slice(1);
    const candidates = [target, `${target}.html`];
    if (!candidates.some((candidate) => existsSync(join(outDir, candidate)))) {
      fail(`${file}: ${attribute}="${value}" không trỏ tới tệp nào trong dist/client.`);
    }
  }
}

function listPlaceholders(file: string, text: string) {
  const slots = [...new Set(text.match(/\[[^\]\n]+\]/g) ?? [])];
  for (const slot of slots) console.log(`  ${file}: ô chờ dữ liệu ${slot}`);
}

/**
 * Vercel serves 404.html at every unknown path. The router matches no route there, so React
 * would rebuild the page it hydrates (error #418 in the console); the page has nothing
 * interactive, so it ships as plain HTML.
 */
function stripScriptsFrom404() {
  const path = join(outDir, "404.html");
  if (!existsSync(path)) return;
  const html = readFileSync(path, "utf8")
    .replace(/<script[^>]*>[\s\S]*?<\/script>/g, "")
    .replace(/<link rel="modulepreload"[^>]*>/g, "");
  writeFileSync(path, html);
}

/** Built images keep their format: a prerender pass that fetches a file overwrites it with the response. */
function checkImages() {
  const signatures: Record<string, number[]> = {
    ".png": [0x89, 0x50, 0x4e, 0x47],
    ".ico": [0x00, 0x00, 0x01, 0x00],
  };
  for (const dir of [outDir, join(outDir, "assets")]) {
    for (const name of readdirSync(dir)) {
      const signature = signatures[name.slice(name.lastIndexOf("."))];
      if (!signature) continue;
      const head = readFileSync(join(dir, name)).subarray(0, signature.length);
      if (!signature.every((byte, index) => head[index] === byte))
        fail(`${name} không còn là ảnh hợp lệ.`);
    }
  }
}

/**
 * Every example id the models ask for exists in TypingExamples.json. A missing id throws
 * while the page prerenders, but Start can still exit 0 (TanStack/router#8120), so the ids
 * are also checked here from the sources.
 */
function checkExampleIds() {
  const file = JSON.parse(readFileSync(join(siteDir, "src/data/TypingExamples.json"), "utf8")) as {
    examples: { id: string }[];
  };
  const known = new Set(file.examples.map((example) => example.id));
  const sources = ["src/models", "src/sections"].flatMap((dir) =>
    readdirSync(join(siteDir, dir)).map((name) => join(siteDir, dir, name)),
  );
  // Models call typingExample("id"); the key chart lists its ids as "table-…" literals.
  const idLiteral = /typingExample\("([^"]+)"\)|"(table-[a-z0-9-]+)"/g;
  for (const source of sources) {
    for (const [, called, listed] of readFileSync(source, "utf8").matchAll(idLiteral)) {
      const id = called ?? listed ?? "";
      if (!known.has(id))
        fail(`${source.slice(siteDir.length)}: TypingExamples.json không có ví dụ "${id}".`);
    }
  }
}

/** Each download page holds every section of docs/Website.md, so a render error cannot pass. */
function checkSections(file: string, html: string) {
  if (file === "404.html") return;
  for (const id of [
    "top",
    "why",
    "features",
    "typing-table",
    "privacy",
    "faq",
    "download",
    "contribute",
  ]) {
    if (!html.includes(`id="${id}"`)) fail(`${file}: thiếu mục #${id}.`);
  }
}

checkExampleIds();
checkAppcastBytes();
checkImages();
cleanSitemap();
stripScriptsFrom404();

const charset = new Set(existsSync(charsetFile) ? [...readFileSync(charsetFile, "utf8")] : []);
if (charset.size === 0) fail("Không có src/fonts/Charset.txt; chạy tools/SubsetFonts.ts trước.");

console.log("Ô còn chờ dữ liệu (N5):");
for (const file of readdirSync(outDir).filter((name) => name.endsWith(".html"))) {
  const path = join(outDir, file);
  const html = insertCsp(readFileSync(path, "utf8"));
  writeFileSync(path, html);
  checkCsp(file, html);
  checkSections(file, html);
  checkLinks(file, html);
  const text = visibleText(html);
  checkCharacters(file, text, charset);
  listPlaceholders(file, text);
}

if (failures.length > 0) {
  console.error("Đầu ra của trang sai:");
  for (const failure of failures) console.error(`  ${failure}`);
  process.exit(1);
}
console.log("Đã kiểm đầu ra: appcast giống từng byte, đủ tệp, liên kết, ảnh, phông, CSP.");
