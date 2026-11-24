import type { ReactNode } from "react";
import { Section, SectionHeading } from "#components/SectionHeading";
import { typingExample } from "#data/Examples";
import { verifiedApps, verifiedMacOS } from "#data/SiteData";
import { format, joinList } from "#i18n/Locale";
import type { SectionProps } from "#sections/Context";

const markExample = typingExample("faq-vni-lan");
const digitExample = typingExample("faq-vni-double-digit");
const standaloneExample = typingExample("vni-standalone-digits");

const answer = "m-0 mb-[22px] max-w-[760px] text-base leading-relaxed text-slate";

function Question({
  id,
  question,
  open = false,
  children,
}: {
  id?: string;
  question: string;
  open?: boolean;
  children: ReactNode;
}) {
  return (
    <details id={id} open={open} className="rounded-[20px] border border-ink/8 bg-white px-6">
      <summary className="flex min-h-16 items-center gap-4 text-lg font-bold text-charcoal">
        <span className="flex-1">{question}</span>
        <span
          aria-hidden="true"
          className="faq-toggle text-[26px] font-normal text-ink transition-transform duration-200"
        >
          +
        </span>
      </summary>
      {children}
    </details>
  );
}

/** 8. FAQ: nine questions, each a <details>. */
export function Faq({ locale, messages }: SectionProps) {
  const t = messages.faq;
  const verified = format(t.builtIn.verified, {
    apps: joinList(verifiedApps(locale), locale),
    macOS: verifiedMacOS,
  });
  return (
    <Section id="faq" className="bg-mist">
      <SectionHeading eyebrow={t.eyebrow} title={t.title} />
      <div className="faq flex flex-col gap-3">
        <Question question={t.free.q} open>
          <p className={answer}>{t.free.a}</p>
        </Question>
        <Question question={t.data.q}>
          <p className={answer}>{t.data.a}</p>
        </Question>
        <Question question={t.permissions.q}>
          <p className={answer}>{t.permissions.a}</p>
        </Question>
        <Question question={t.builtIn.q}>
          <p className={answer}>
            {t.builtIn.aBefore}
            <a href="#why" className="font-bold text-ink">
              {t.builtIn.aLink}
            </a>
            {t.builtIn.aAfter} {verified}
          </p>
        </Question>
        <Question question={t.switching.q}>
          <p className={answer}>{t.switching.a}</p>
        </Question>
        <Question question={t.skipped.q}>
          <p className={answer}>{t.skipped.intro}</p>
          <ul className="m-0 mb-[22px] max-w-[760px] pl-5 text-base leading-relaxed text-slate">
            {t.skipped.items.map((item) => (
              <li key={item.term} className="my-1">
                <b>{item.term}</b> {item.text}
              </li>
            ))}
          </ul>
        </Question>
        <Question question={t.vni.q}>
          <p className={answer}>
            {format(t.vni.a, {
              markKeys: markExample.keys,
              mark: markExample.expected,
              digitKeys: digitExample.keys,
              digit: digitExample.expected,
              standalone: standaloneExample.expected,
            })}
          </p>
        </Question>
        <Question question={t.cannotChoose.q}>
          <p className={answer}>{t.cannotChoose.a}</p>
        </Question>
        <Question id="uninstall" question={t.uninstall.q}>
          <p className={answer}>{t.uninstall.a}</p>
        </Question>
      </div>
    </Section>
  );
}
