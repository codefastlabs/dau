// Cuts Be Vietnam Pro down to the characters of the page before `vite build`
// (docs/research/WebsiteStack.md, section 4). Writes src/fonts/: one woff2 per weight and
// Fontsource subset, Fonts.css and Charset.txt, the characters the cut font draws.

import { mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { dirname, join } from "node:path";
import subsetFont from "subset-font";
import { charsetFile, fontsDir, pageCharacters } from "#tools/TextSources";

/** The five weights the artboards use. */
const weights = [400, 500, 600, 700, 800];
const subsets = ["vietnamese", "latin-ext", "latin"];

/**
 * Symbols the page shows in the system font, not in Be Vietnam Pro: key caps in the
 * monospace face (␣ ↩ ⌫), the menu check mark and the contribute icons (β ♥).
 */
export const systemFontChars = new Set(["␣", "↩", "⌫", "✓", "♥", "β"]);

const fontsource = dirname(
  createRequire(import.meta.url).resolve("@fontsource/be-vietnam-pro/package.json"),
);

function parseRange(range: string): (code: number) => boolean {
  const spans = range.split(",").map((part) => {
    const [start = "0", end] = part.trim().replace(/^U\+/i, "").split("-");
    return [parseInt(start, 16), parseInt(end ?? start, 16)] as const;
  });
  return (code) => spans.some(([start, end]) => code >= start && code <= end);
}

const unicodeRanges: Record<string, string> = JSON.parse(
  readFileSync(join(fontsource, "unicode.json"), "utf8"),
);

function unicodeRange(subset: string): string {
  const range = unicodeRanges[subset];
  if (!range) throw new Error(`Fontsource has no unicode-range for ${subset}`);
  return range;
}

const chars = pageCharacters();
rmSync(fontsDir, { recursive: true, force: true });
mkdirSync(fontsDir, { recursive: true });

const covered = new Set<string>();
const faces: string[] = [];
let bytes = 0;
for (const subset of subsets) {
  const range = unicodeRange(subset);
  const inRange = parseRange(range);
  const text = [...chars].filter((char) => inRange(char.codePointAt(0) ?? 0)).join("");
  if (text === "") continue;
  for (const char of text) covered.add(char);
  for (const weight of weights) {
    const source = readFileSync(
      join(fontsource, "files", `be-vietnam-pro-${subset}-${weight}-normal.woff2`),
    );
    const cut = await subsetFont(source, text, { targetFormat: "woff2" });
    const file = `be-vietnam-pro-${subset}-${weight}.woff2`;
    writeFileSync(join(fontsDir, file), cut);
    bytes += cut.byteLength;
    faces.push(
      `@font-face{font-family:"Be Vietnam Pro";font-style:normal;font-display:swap;font-weight:${weight};` +
        `src:url("./${file}") format("woff2");unicode-range:${range}}`,
    );
  }
}

const uncovered = [...chars].filter((char) => !covered.has(char) && !systemFontChars.has(char));
if (uncovered.length > 0) {
  console.error(
    `Ký tự không có trong phông và không nằm trong danh sách phông hệ thống: ${uncovered.join(" ")}`,
  );
  process.exit(1);
}

writeFileSync(join(fontsDir, "Fonts.css"), `${faces.join("\n")}\n`);
writeFileSync(charsetFile, [...covered, ...systemFontChars].sort().join(""));
console.log(
  `Đã cắt phông: ${covered.size} ký tự, ${faces.length} tệp, ${(bytes / 1024).toFixed(1)} KB.`,
);
