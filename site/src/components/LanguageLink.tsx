import { track } from "#analytics/Tracking";
import { localizedPath, type Locale } from "#i18n/Locale";

/** Link to the same page in the other language, read in that language's voice (D45). */
export function LanguageLink({
  path,
  from,
  label,
  className,
}: {
  path: string;
  from: Locale;
  label: string;
  className?: string;
}) {
  const to: Locale = from === "vi" ? "en" : "vi";
  return (
    <a
      href={localizedPath(path, to)}
      hrefLang={to}
      lang={to}
      className={className}
      onClick={() => track("language_switch", { from, to })}
    >
      {label}
    </a>
  );
}
