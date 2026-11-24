// The text the page can show, for cutting the font (SubsetFonts.ts) and checking the output
// against it (VerifyOutput.ts). docs/research/WebsiteStack.md, section 4.

import { readdirSync, readFileSync, statSync } from "node:fs";
import { join, relative } from "node:path";

export const siteDir = new URL("..", import.meta.url).pathname;
export const fontsDir = join(siteDir, "src/fonts");
export const charsetFile = join(fontsDir, "Charset.txt");

const repoDir = join(siteDir, "..");

/**
 * Data files outside site/ that the page reads (D45). The page shows only the names in them;
 * the maintainers' notes never reach it.
 */
const sharedData = [
  "Apps/Dau/Resources/CompatibilityList.json",
  "Apps/Dau/Resources/Supporters.json",
].map((path) => join(repoDir, path));

function namesIn(value: unknown): string[] {
  if (Array.isArray(value)) return value.flatMap(namesIn);
  if (typeof value !== "object" || value === null) return [];
  return Object.entries(value).flatMap(([key, inner]) => {
    if (key !== "name") return namesIn(inner);
    return typeof inner === "string" ? [inner] : Object.values(inner as object).map(String);
  });
}

function filesUnder(dir: string): string[] {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) return path === fontsDir ? [] : filesUnder(path);
    return /\.(ts|tsx|json)$/.test(name) && name !== "routeTree.gen.ts" ? [path] : [];
  });
}

/**
 * Characters the browser's Intl formatting adds to dates, numbers and money on the page
 * (no-break spaces, the đồng sign); they appear in no source file.
 */
const formattedChars = "  ₫";

/** Every character of the page's sources, plus printable ASCII. */
export function pageCharacters(): Set<string> {
  const chars = new Set<string>();
  for (let code = 0x20; code <= 0x7e; code++) chars.add(String.fromCharCode(code));
  for (const char of formattedChars) chars.add(char);
  const texts = [
    ...[...filesUnder(join(siteDir, "src")), join(siteDir, "appcast.xml")].map((file) =>
      readFileSync(file, "utf8"),
    ),
    ...sharedData.flatMap((file) => namesIn(JSON.parse(readFileSync(file, "utf8")))),
  ];
  for (const text of texts) {
    for (const char of text) {
      if (char >= " ") chars.add(char);
    }
  }
  return chars;
}

export function describe(path: string): string {
  return relative(repoDir, path);
}
