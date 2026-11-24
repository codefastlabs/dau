import { siteOrigin } from "#Links";
import { localizedPath, type Locale } from "#i18n/Locale";
import type { Messages } from "#i18n/vi";

type Meta =
  | { title: string }
  | { name: string; content: string }
  | { property: string; content: string };
type Link = { rel: string; href: string; hrefLang?: string };

/**
 * Head tags that depend on the page path: canonical, hreflang alternates (each version lists
 * itself and the other; `x-default` is English, D45) and Open Graph.
 */
export function localizedHead(
  path: string,
  locale: Locale,
  messages: Messages,
): { meta: Meta[]; links: Link[] } {
  const url = (target: Locale) => siteOrigin + localizedPath(path, target);
  const other: Locale = locale === "vi" ? "en" : "vi";
  const otherLocale = other === "en" ? "en_US" : "vi_VN";
  const image = siteOrigin + messages.head.ogImage;
  return {
    meta: [
      { title: messages.head.title },
      { name: "description", content: messages.head.description },
      { property: "og:site_name", content: "Dấu" },
      { property: "og:type", content: "website" },
      { property: "og:locale", content: messages.head.ogLocale },
      { property: "og:locale:alternate", content: otherLocale },
      { property: "og:url", content: url(locale) },
      { property: "og:title", content: messages.head.title },
      { property: "og:description", content: messages.head.description },
      { property: "og:image", content: image },
      { property: "og:image:width", content: "1200" },
      { property: "og:image:height", content: "630" },
      { property: "og:image:alt", content: messages.head.ogImageAlt },
      { name: "twitter:card", content: "summary_large_image" },
    ],
    links: [
      { rel: "canonical", href: url(locale) },
      { rel: "alternate", hrefLang: "vi", href: url("vi") },
      { rel: "alternate", hrefLang: "en", href: url("en") },
      { rel: "alternate", hrefLang: "x-default", href: url("en") },
    ],
  };
}
