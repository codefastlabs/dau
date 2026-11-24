import assert from "node:assert/strict";
import { test } from "vitest";
import { parseAppcast, selectItem } from "#data/Appcast";

function item(version: string, channel?: string) {
  return `<item><title>0.1.0</title><pubDate>Tue, 17 Nov 2026 10:00:00 +0700</pubDate>${
    channel ? `<sparkle:channel>${channel}</sparkle:channel>` : ""
  }<sparkle:version>${version}</sparkle:version><sparkle:shortVersionString>0.1.0</sparkle:shortVersionString><enclosure url="https://example.com/${version}.dmg" length="12345678" type="application/octet-stream" sparkle:edSignature="x"/></item>`;
}

const feed = (...items: string[]) => `<rss><channel>${items.join("")}</channel></rss>`;

test("an empty feed offers nothing", () => {
  assert.equal(selectItem(parseAppcast(feed())), undefined);
});

test("before any stable build, the newest beta is offered", () => {
  const offered = selectItem(
    parseAppcast(feed(item("90", "beta"), item("120", "beta"), item("100", "beta"))),
  );
  assert.equal(offered?.version, "120");
  assert.equal(offered?.url, "https://example.com/120.dmg");
  assert.equal(offered?.lengthBytes, 12345678);
});

test("once a stable build exists, only stable builds are offered (D6, D7)", () => {
  const offered = selectItem(parseAppcast(feed(item("130", "beta"), item("110"), item("100"))));
  assert.equal(offered?.version, "110");
});

test("the version may sit on the enclosure", () => {
  const xml = feed(
    '<item><enclosure url="https://example.com/a.dmg" length="1" sparkle:version="7" sparkle:shortVersionString="0.2.0"/></item>',
  );
  assert.deepEqual(
    parseAppcast(xml).map((entry) => [entry.version, entry.shortVersion]),
    [["7", "0.2.0"]],
  );
});
