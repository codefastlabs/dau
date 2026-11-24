// Exports the page's identity files into public/ (docs/Brand.md, "File cần xuất"): favicon.svg,
// favicon.ico (16 and 32 px), apple-touch-icon.png (180 px) from Resources/Brand/AppIcon.svg,
// and og-image.png, og-image-en.png (1200 × 630) from the artboards OgImage.dc.html and
// OgImageEn.dc.html. Run by hand when the icon or the artboards change:
//
//   node tools/ExportImages.ts
//
// Pictures are taken by headless Chrome, which shows no window, on a profile of its own in a
// temporary folder. The artboards are set in the Fontsource copy of Be Vietnam Pro, so the
// export needs no network.

import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { siteDir } from "#tools/TextSources";

const chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const repoDir = join(siteDir, "..");
const publicDir = join(siteDir, "public");
const work = mkdtempSync(join(tmpdir(), "dau-site-images-"));
const fontsource = dirname(
  createRequire(import.meta.url).resolve("@fontsource/be-vietnam-pro/package.json"),
);

function screenshot(html: string, width: number, height: number, output: string) {
  const page = join(work, "page.html");
  writeFileSync(page, html);
  execFileSync(
    chrome,
    [
      "--headless=new",
      "--disable-gpu",
      "--hide-scrollbars",
      "--default-background-color=00000000",
      "--force-device-scale-factor=1",
      `--user-data-dir=${join(work, "profile")}`,
      `--window-size=${width},${height}`,
      "--virtual-time-budget=5000",
      `--screenshot=${output}`,
      `file://${page}`,
    ],
    { stdio: "ignore" },
  );
}

/** The flat icon without the Icon Composer margin and shadow: the plate fills the square. */
function croppedIcon(): string {
  return readFileSync(join(repoDir, "Resources/Brand/AppIcon.svg"), "utf8")
    .replace(/<!--[\s\S]*?-->\s*/g, "")
    .replace(/<defs>[\s\S]*?<\/defs>\s*/, "")
    .replace(' filter="url(#shadow)"', "")
    .replace(
      /width="1024" height="1024" viewBox="0 0 1024 1024"/,
      'width="824" height="824" viewBox="100 100 824 824"',
    );
}

function iconPng(size: number, background: string, output: string) {
  const svg = croppedIcon().replace(/width="824" height="824"/, `width="${size}" height="${size}"`);
  screenshot(
    `<!doctype html><html><body style="margin:0;background:${background}">${svg}</body></html>`,
    size,
    size,
    output,
  );
}

/** An ICO whose entries are PNG images, which every current browser reads. */
function ico(pngs: { size: number; data: Buffer }[]): Buffer {
  const header = Buffer.alloc(6 + 16 * pngs.length);
  header.writeUInt16LE(0, 0);
  header.writeUInt16LE(1, 2);
  header.writeUInt16LE(pngs.length, 4);
  let offset = header.length;
  pngs.forEach(({ size, data }, index) => {
    const entry = 6 + 16 * index;
    header.writeUInt8(size, entry);
    header.writeUInt8(size, entry + 1);
    header.writeUInt16LE(1, entry + 4);
    header.writeUInt16LE(32, entry + 6);
    header.writeUInt32LE(data.length, entry + 8);
    header.writeUInt32LE(offset, entry + 12);
    offset += data.length;
  });
  return Buffer.concat([header, ...pngs.map(({ data }) => data)]);
}

function ogImage(artboard: string, output: string) {
  const source = readFileSync(join(repoDir, "docs/canvas/src", artboard), "utf8");
  const markup =
    /<x-dc>([\s\S]*?)<\/x-dc>/
      .exec(source)?.[1]
      ?.replace(/<helmet>[\s\S]*?<\/helmet>/, "")
      .replaceAll("{{accent}}", "#0A64D8") ?? "";
  const faces = [500, 700, 800]
    .flatMap((weight) =>
      ["latin", "latin-ext", "vietnamese"].map(
        (subset) =>
          `@font-face{font-family:"Be Vietnam Pro";font-weight:${weight};` +
          `src:url("file://${join(fontsource, "files", `be-vietnam-pro-${subset}-${weight}-normal.woff2`)}")}`,
      ),
    )
    .join("");
  screenshot(
    `<!doctype html><html><head><meta charset="utf-8"><style>${faces}html,body{margin:0}</style></head><body>${markup}</body></html>`,
    1200,
    630,
    output,
  );
}

try {
  writeFileSync(join(publicDir, "favicon.svg"), croppedIcon());
  const sizes = [16, 32];
  for (const size of sizes) iconPng(size, "transparent", join(work, `icon-${size}.png`));
  writeFileSync(
    join(publicDir, "favicon.ico"),
    ico(sizes.map((size) => ({ size, data: readFileSync(join(work, `icon-${size}.png`)) }))),
  );
  // iOS rounds the corners itself and shows transparency as black, so the square is filled with Ink.
  iconPng(180, "#10285A", join(publicDir, "apple-touch-icon.png"));
  ogImage("OgImage.dc.html", join(publicDir, "og-image.png"));
  ogImage("OgImageEn.dc.html", join(publicDir, "og-image-en.png"));
  console.log("Đã xuất favicon, apple-touch-icon và hai ảnh Open Graph vào public/.");
} finally {
  rmSync(work, { recursive: true, force: true });
}
