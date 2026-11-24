import { Section, SectionHeading } from "#components/SectionHeading";
import { Privacy as PrivacyModel } from "#models/Privacy";
import type { SectionProps } from "#sections/Context";

/** 6. Privacy, on Ink: the two parts of Dấu, open source, and how the page counts (D8, N2, D45). */
export function Privacy({ messages }: SectionProps) {
  const t = messages.privacy;
  return (
    <Section id="privacy" className="bg-ink">
      <SectionHeading eyebrow={t.eyebrow} title={t.title} lead={t.lead} onInk />
      <PrivacyModel messages={messages} />
      <p className="m-0 text-[15px] leading-relaxed text-paper/80">
        <b className="text-paper">{t.sourceLead}</b>
        {t.sourceText}
        <br />
        <b className="text-paper">{t.countsLead}</b>
        {t.countsText}
      </p>
    </Section>
  );
}
