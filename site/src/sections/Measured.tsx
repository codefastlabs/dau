import { Section, SectionHeading } from "#components/SectionHeading";
import { engineTests, heavyLoad, measuredAppCount, type HeavyLoad } from "#data/SiteData";
import { compatibilityListUrl } from "#Links";
import { format, type Locale } from "#i18n/Locale";
import type { Messages } from "#i18n/vi";
import type { SectionProps } from "#sections/Context";
import { formatDate, machineLabel } from "#sections/Formatting";

interface Metric {
  value: string;
  text: string;
  notes: string[];
}

function metrics(load: HeavyLoad, locale: Locale, messages: Messages): Metric[] {
  const t = messages.measured;
  const conditions = { machine: machineLabel(load, messages), date: formatDate(load.date, locale) };
  return [
    {
      value: engineTests ? engineTests.cases.toLocaleString(locale) : t.casesPlaceholder,
      text: t.casesText,
      notes: [t.casesNote],
    },
    {
      value: `${load.p99Ms.toLocaleString(locale)} ms`,
      text: format(t.p99Text, { limit: load.p99LimitMs }),
      notes: [format(t.p99Note, { build: load.p99Build, ...conditions }), t.gate],
    },
    {
      value: `${load.rssMB.toLocaleString(locale)} MB`,
      text: format(t.rssText, { limit: load.rssLimitMB }),
      notes: [format(t.rssNote, { build: load.rssBuild, ...conditions })],
    },
  ];
}

/**
 * 7. Measured: shown only once the offered build has heavy-load numbers (docs/Website.md,
 * section 7), so the page never opens on a row of empty slots.
 */
export function Measured({ locale, messages }: SectionProps) {
  if (!heavyLoad) return null;
  const t = messages.measured;
  const items = metrics(heavyLoad, locale, messages);
  return (
    <Section id="measured">
      <SectionHeading eyebrow={t.eyebrow} title={t.title} lead={t.lead} leadWidth="max-w-[680px]" />
      <div className="flex flex-col gap-4">
        <div className="flex flex-wrap items-center gap-x-8 gap-y-3 rounded-[28px] border border-ink/8 bg-white p-[clamp(28px,4vw,48px)]">
          <span className="text-[clamp(48px,7vw,88px)] leading-none font-extrabold tracking-[-2px] text-ink">
            {measuredAppCount}
          </span>
          <div className="flex min-w-0 flex-[1_1_280px] flex-col gap-2.5">
            <span className="text-xl leading-[1.45] font-semibold text-charcoal">
              {t.appCountText}
            </span>
            <a href={compatibilityListUrl} className="text-[15px] font-semibold text-ink">
              {t.appCountLink}
            </a>
          </div>
        </div>
        <div className="hidden grid-cols-[repeat(auto-fit,minmax(min(100%,240px),1fr))] gap-px overflow-hidden rounded-[20px] border border-ink/8 bg-ink/8 min-[641px]:grid">
          {items.map((item) => (
            <div key={item.text} className="flex min-w-0 flex-col gap-1.5 bg-white px-[22px] py-5">
              <span className="text-[22px] font-extrabold text-ink">{item.value}</span>
              <span className="text-sm leading-normal text-slate">{item.text}</span>
              {item.notes.map((note) => (
                <span key={note} className="text-[13px] leading-normal text-muted">
                  {note}
                </span>
              ))}
            </div>
          ))}
        </div>
        <ul
          aria-label={t.otherLabel}
          className="m-0 list-none rounded-[20px] border border-ink/8 bg-white px-5 py-0 min-[641px]:hidden"
        >
          {items.map((item, index) => (
            <li
              key={item.text}
              className={`flex flex-col gap-1 py-4 ${index > 0 ? "border-t border-ink/8" : ""}`}
            >
              <span className="text-[15px] leading-normal text-slate">
                <b className="text-lg font-extrabold text-ink">{item.value}</b> {item.text}
              </span>
              {item.notes.map((note) => (
                <span key={note} className="text-[13px] leading-normal text-muted">
                  {note}
                </span>
              ))}
            </li>
          ))}
        </ul>
      </div>
    </Section>
  );
}
