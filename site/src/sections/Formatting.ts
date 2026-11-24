import type { HeavyLoad } from "#data/SiteData";
import { format, type Locale } from "#i18n/Locale";
import type { Messages } from "#i18n/vi";

// Dates are calendar days written in the data files; formatting in UTC keeps the prerendered
// text and the hydrated text the same wherever the reader is.
const dateFormats: Record<Locale, Intl.DateTimeFormatOptions> = {
  vi: { day: "2-digit", month: "2-digit", year: "numeric", timeZone: "UTC" },
  en: { day: "numeric", month: "long", year: "numeric", timeZone: "UTC" },
};

/** A `YYYY-MM-DD` day or a `Date`, as the language writes dates. */
export function formatDate(day: string | Date, locale: Locale): string {
  const date = typeof day === "string" ? new Date(`${day}T00:00:00Z`) : day;
  return new Intl.DateTimeFormat(locale === "vi" ? "vi-VN" : "en-US", dateFormats[locale]).format(
    date,
  );
}

export function machineLabel(load: HeavyLoad, messages: Messages): string {
  return format(messages.measured.machine, { chip: load.machine, macOS: load.macOS });
}

/** Size in MB as Finder counts it (a million bytes), one decimal. */
export function formatMegabytes(bytes: number, locale: Locale): string {
  return (bytes / 1_000_000).toLocaleString(locale, { maximumFractionDigits: 1 });
}
