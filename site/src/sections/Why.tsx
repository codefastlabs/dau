import { Section, SectionHeading } from "#components/SectionHeading";
import { latestHeavyLoad, verifiedApps, verifiedMacOS, type HeavyLoad } from "#data/SiteData";
import { format, joinList, type Locale } from "#i18n/Locale";
import type { Messages } from "#i18n/vi";
import { ThreeWays } from "#models/ThreeWays";
import type { SectionProps } from "#sections/Context";
import { formatDate, machineLabel } from "#sections/Formatting";

/** Dấu on a busy Mac: the p99 of the latest heavy-load run, rounded up to a whole ms (D42). */
function BusyCard({
  load,
  locale,
  messages,
}: {
  load: HeavyLoad | undefined;
  locale: Locale;
  messages: Messages;
}) {
  const t = messages.why;
  return (
    <div className="flex flex-col gap-1.5 rounded-2xl border border-ink/12 bg-white px-5 py-[18px]">
      <span className="text-xs font-bold tracking-[1px] text-ink-soft uppercase">
        {t.busyEyebrow}
      </span>
      <span className="text-[34px] leading-[1.1] font-extrabold tracking-[-0.5px] text-ink">
        {load ? format(t.busyValue, { ms: Math.floor(load.p99Ms) + 1 }) : t.busyPlaceholder}
      </span>
      {load ? (
        <>
          <p className="m-0 text-sm leading-[1.55] text-iron">
            {format(t.busyText, { apps: joinList(load.apps, locale) })}
          </p>
          <p className="m-0 mt-1 text-xs leading-normal text-muted">
            {format(t.busyConditions, {
              date: formatDate(load.date, locale),
              machine: machineLabel(load, messages),
              build: load.p99Build,
              limit: load.p99LimitMs,
            })}
          </p>
        </>
      ) : null}
    </div>
  );
}

/** 3. Why Dấu: three kinds of input methods on the same four keys (N3, D13). */
export function Why({ locale, messages }: SectionProps) {
  const t = messages.why;
  const apps = verifiedApps(locale);
  return (
    <Section id="why" className="bg-mist">
      <SectionHeading eyebrow={t.eyebrow} title={t.title} lead={t.lead} />
      <div className="grid grid-cols-[repeat(auto-fit,minmax(min(100%,300px),1fr))] items-stretch gap-5">
        <ThreeWays messages={messages} />
        <div className="col-[1/-1] grid min-w-0 grid-cols-[repeat(auto-fit,minmax(min(100%,340px),1fr))] items-start gap-x-8 gap-y-5">
          <BusyCard load={latestHeavyLoad} locale={locale} messages={messages} />
          <div className="flex flex-col gap-2.5">
            <span className="text-sm font-semibold text-charcoal">
              {format(t.verifiedTitle, { count: apps.length, macOS: verifiedMacOS })}
            </span>
            <ul className="m-0 flex list-none flex-wrap gap-1.5 p-0">
              {apps.map((app) => (
                <li
                  key={app}
                  className="inline-flex h-[26px] items-center rounded-full border border-ink/12 bg-white px-2.5 text-[13px] whitespace-nowrap text-iron"
                >
                  {app}
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </Section>
  );
}
