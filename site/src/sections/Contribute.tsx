import { Section, SectionHeading } from "#components/SectionHeading";
import vietQRUrl from "#assets/VietQR.png";
import { expenses, githubSponsors, supporters, vietQR } from "#data/SiteData";
import { sponsorsUrl } from "#Links";
import type { SectionProps } from "#sections/Context";
import { formatDate } from "#sections/Formatting";

const symbol =
  "flex size-9 flex-none items-center justify-center rounded-[10px] bg-ink/8 text-lg text-ink";

function Way({ mark, title, text }: { mark: string; title: string; text: string }) {
  return (
    <div className="flex items-start gap-3.5 border-t border-ink/10 py-4">
      <span aria-hidden="true" className={symbol}>
        {mark}
      </span>
      <div className="flex min-w-0 flex-col gap-1">
        <h3 className="m-0 text-lg font-bold text-charcoal">{title}</h3>
        <p className="m-0 text-[15px] leading-[1.55] text-slate">{text}</p>
      </div>
    </div>
  );
}

/**
 * 10. Contribute: ways to help, donations (D39), thanks with the supporters who agreed to be
 * named, and only money actually spent.
 */
export function Contribute({ locale, messages }: SectionProps) {
  const t = messages.contribute;
  const vietQRCard = (
    <div className="flex flex-wrap items-start gap-[18px] rounded-2xl bg-paper/8 p-4">
      <div className="flex w-40 flex-none flex-col items-center gap-2.5">
        <img
          src={vietQRUrl}
          alt={t.vietQRAlt}
          width={160}
          height={160}
          className="box-border size-40 flex-none rounded-xl bg-white p-2"
        />
        <a
          href={vietQRUrl}
          download="Dau-VietQR.png"
          className="text-sm font-bold text-paper underline underline-offset-3"
        >
          {t.vietQRDownload}
        </a>
      </div>
      <div className="flex min-w-0 flex-[1_1_200px] flex-col gap-2.5">
        <span className="text-[15px] font-bold text-paper">{t.vietQRTitle}</span>
        <dl className="m-0 flex flex-col gap-2">
          {(
            [
              [t.vietQRRecipient, vietQR.recipient],
              [t.vietQRBank, vietQR.bank],
            ] as const
          ).map(([label, value]) => (
            <div key={label} className="flex flex-col gap-px">
              <dt className="text-xs text-paper/65">{label}</dt>
              <dd className="m-0 text-[15px] font-semibold text-paper">{value}</dd>
            </div>
          ))}
        </dl>
        <p className="m-0 text-[13px] leading-normal text-paper/80">{t.vietQRNote}</p>
      </div>
    </div>
  );
  const sponsors = githubSponsors ? (
    <>
      <a
        href={sponsorsUrl}
        className="inline-flex items-center self-start rounded-full bg-paper px-5 py-3 text-[15px] font-bold text-ink no-underline"
      >
        {t.sponsorsButton}
      </a>
      <span className="text-[13px] text-paper/65">{t.sponsorsNote}</span>
    </>
  ) : null;
  const money = new Intl.NumberFormat(locale === "vi" ? "vi-VN" : "en-US", {
    style: "currency",
    currency: "VND",
  });
  return (
    <Section id="contribute">
      <SectionHeading eyebrow={t.eyebrow} title={t.title} lead={t.lead} />
      <div className="grid grid-cols-[repeat(auto-fit,minmax(min(100%,340px),1fr))] items-start gap-8">
        <div className="flex min-w-0 flex-col">
          <span className="pb-1.5 text-[13px] font-bold text-ink-soft">{t.handTitle}</span>
          <Way mark="!" title={t.reportTitle} text={t.reportText} />
          <Way mark="β" title={t.betaTitle} text={t.betaText} />
          <Way mark="{ }" title={t.codeTitle} text={t.codeText} />
          <Way mark="♥" title={t.shareTitle} text={t.shareText} />
        </div>
        <div className="flex min-w-0 flex-col gap-4 rounded-3xl bg-ink p-7">
          <span className="text-[13px] font-bold text-ink-pale">{t.donateEyebrow}</span>
          <h3 className="m-0 text-2xl leading-[1.2] font-extrabold text-paper">{t.donateTitle}</h3>
          <p className="m-0 text-[15px] leading-[1.55] text-paper/85">{t.donateText}</p>
          {/* The English artboard puts GitHub Sponsors first, the Vietnamese one VietQR. */}
          {locale === "en" ? (
            <>
              {sponsors}
              {vietQRCard}
            </>
          ) : (
            <>
              {vietQRCard}
              {sponsors}
            </>
          )}
        </div>
      </div>
      <div className="flex flex-col gap-3.5 border-t border-ink/12 pt-[18px]">
        <h3 className="m-0 text-xl font-bold text-charcoal">{t.thanksTitle}</h3>
        <p className="m-0 text-base leading-relaxed text-slate">{t.thanksText}</p>
        {supporters.length > 0 ? (
          <ul aria-label={t.supportersLabel} className="m-0 flex list-none flex-wrap gap-2 p-0">
            {supporters.map((supporter) => (
              <li
                key={supporter.name}
                className="inline-flex h-[34px] items-center rounded-full border border-ink/14 bg-white px-3.5 text-[15px] font-semibold text-ink"
              >
                {supporter.name}
              </li>
            ))}
          </ul>
        ) : null}
        <p className="m-0 text-sm leading-[1.55] text-graphite">{t.consent}</p>
      </div>
      <div className="flex flex-col gap-3.5 border-t border-ink/12 pt-[18px]">
        <h3 className="m-0 text-xl font-bold text-charcoal">{t.expensesTitle}</h3>
        <p className="m-0 text-base leading-relaxed text-slate">{t.expensesText}</p>
        {expenses.length > 0 ? (
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-[15px] text-charcoal">
              <thead>
                <tr>
                  <th
                    scope="col"
                    className="pr-4 pb-2 text-left text-[13px] font-semibold text-graphite"
                  >
                    {t.expensesDate}
                  </th>
                  <th
                    scope="col"
                    className="pr-4 pb-2 text-left text-[13px] font-semibold text-graphite"
                  >
                    {t.expensesItem}
                  </th>
                  <th
                    scope="col"
                    className="pb-2 text-right text-[13px] font-semibold text-graphite"
                  >
                    {t.expensesAmount}
                  </th>
                </tr>
              </thead>
              <tbody>
                {expenses.map((expense) => (
                  <tr key={`${expense.date}-${expense.item.en}`}>
                    <td className="border-t border-ink/10 py-3 pr-4">
                      {formatDate(expense.date, locale)}
                    </td>
                    <td className="border-t border-ink/10 py-3 pr-4">{expense.item[locale]}</td>
                    <td className="border-t border-ink/10 py-3 text-right whitespace-nowrap">
                      {expense.currency === "VND"
                        ? money.format(expense.amount)
                        : `${expense.amount.toLocaleString(locale)} ${expense.currency}`}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : null}
      </div>
    </Section>
  );
}
