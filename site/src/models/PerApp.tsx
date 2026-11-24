import { suggestedApps } from "#data/SiteData";
import { format, type Locale } from "#i18n/Locale";
import type { Messages } from "#i18n/vi";

// Two apps that type correctly in place, then every app labelled "Đề xuất" in the
// compatibility list (D13, docs/Compatibility.md).
const inPlaceApps = ["Safari", "Chrome"];

const tileColor: Record<string, string> = {
  Safari: "bg-accent-blue",
  Chrome: "bg-accent-green",
  Terminal: "bg-charcoal",
  Ghostty: "bg-accent-purple",
};

/** Per-app rules: in place by default, underline where the list suggests it (D5, D13, D43). */
export function PerApp({ locale, messages }: { locale: Locale; messages: Messages }) {
  const t = messages.features;
  const rows = [
    ...inPlaceApps.map((name) => ({ name, underline: false })),
    ...[...suggestedApps]
      .sort((a, b) => a.localeCompare(b, locale))
      .map((name) => ({ name, underline: true })),
  ];
  return (
    <div className="overflow-hidden rounded-[14px] border border-ink/10 bg-white">
      {rows.map(({ name, underline }, index) => (
        <div
          key={name}
          className={`box-border flex min-h-[52px] items-center gap-3 px-3.5 py-2 ${index > 0 ? "border-t border-ink/8" : ""}`}
        >
          <span
            aria-hidden="true"
            className={`flex size-[30px] flex-none items-center justify-center rounded-lg text-[13px] font-bold text-white ${tileColor[name] ?? "bg-ink"}`}
          >
            {name[0]}
          </span>
          <span className="flex min-w-0 flex-1 flex-col gap-0.5">
            <span className="text-[15px] font-semibold text-charcoal">{name}</span>
            <span className="flex flex-wrap items-center gap-1.5 text-[13px] text-iron">
              {underline ? t.perAppUnderline : t.perAppInPlace}
              {underline ? (
                <span className="inline-flex h-[22px] items-center rounded-full bg-ink/8 px-[9px] text-xs font-semibold whitespace-nowrap text-ink">
                  {t.perAppSuggested}
                </span>
              ) : null}
            </span>
          </span>
          <input
            type="checkbox"
            className="switch"
            aria-label={format(t.perAppSwitch, { app: name })}
            defaultChecked={underline}
            disabled
          />
        </div>
      ))}
    </div>
  );
}
