// Reads the Sparkle feed (site/appcast.xml) at build time and picks the build the page offers.

export interface AppcastItem {
  /** `sparkle:version`, the build number. */
  version: string;
  /** `sparkle:shortVersionString`, the version people see ("0.1.0"). */
  shortVersion: string;
  channel: string | undefined;
  pubDate: Date | undefined;
  url: string | undefined;
  lengthBytes: number | undefined;
}

function element(block: string, name: string): string | undefined {
  const match = new RegExp(`<${name}>([^<]*)</${name}>`).exec(block);
  return match?.[1]?.trim();
}

function attribute(tag: string, name: string): string | undefined {
  return new RegExp(`\\s${name}="([^"]*)"`).exec(tag)?.[1];
}

/** Sparkle accepts the version either as an element of the item or on its enclosure. */
export function parseAppcast(xml: string): AppcastItem[] {
  const items: AppcastItem[] = [];
  for (const [, block = ""] of xml.matchAll(/<item>([\s\S]*?)<\/item>/g)) {
    const enclosure = /<enclosure\s[^>]*>/.exec(block)?.[0] ?? "";
    const version = element(block, "sparkle:version") ?? attribute(enclosure, "sparkle:version");
    if (!version) continue;
    const date = element(block, "pubDate");
    const length = attribute(enclosure, "length");
    items.push({
      version,
      shortVersion:
        element(block, "sparkle:shortVersionString") ??
        attribute(enclosure, "sparkle:shortVersionString") ??
        element(block, "title") ??
        version,
      channel: element(block, "sparkle:channel"),
      pubDate: date ? new Date(date) : undefined,
      url: attribute(enclosure, "url"),
      lengthBytes: length ? Number(length) : undefined,
    });
  }
  return items;
}

/**
 * The build the page offers (D6, D7): the stable build with the highest `sparkle:version` once
 * one exists, else the newest beta. An item without a channel tag is stable.
 */
export function selectItem(items: readonly AppcastItem[]): AppcastItem | undefined {
  const newest = (list: readonly AppcastItem[]) =>
    list.reduce<AppcastItem | undefined>(
      (best, item) => (!best || Number(item.version) > Number(best.version) ? item : best),
      undefined,
    );
  const stable = items.filter((item) => item.channel === undefined);
  return stable.length > 0
    ? newest(stable)
    : newest(items.filter((item) => item.channel === "beta"));
}
