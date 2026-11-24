import { en } from "#i18n/en";
import { vi, type Messages } from "#i18n/vi";

export type Locale = "vi" | "en";

/** The `{-$locale}` path parameter: absent is Vietnamese, `en` is English (D45). */
export function localeFromParam(param: string | undefined): Locale {
  return param === "en" ? "en" : "vi";
}

export function messagesFor(locale: Locale): Messages {
  return locale === "en" ? en : vi;
}

/** Path of `path` in `locale`: Vietnamese keeps it, English prefixes `/en`. */
export function localizedPath(path: string, locale: Locale): string {
  if (locale === "vi") return path;
  return path === "/" ? "/en" : `/en${path}`;
}

/** Fills `{name}` slots of a dictionary string. A slot without a value stays visible. */
export function format(template: string, values: Record<string, string | number>): string {
  return template.replace(/\{(\w+)\}/g, (slot, name: string) =>
    name in values ? String(values[name]) : slot,
  );
}

/** "A, B và C" / "A, B, and C", as each language writes a list. */
export function joinList(items: readonly string[], locale: Locale): string {
  return new Intl.ListFormat(locale, { type: "conjunction" }).format(items);
}
