import type { ReactNode } from "react";
import { Section, SectionHeading } from "#components/SectionHeading";
import { AddMarks } from "#models/AddMarks";
import { ForeignWords } from "#models/ForeignWords";
import { PartOfMacOS } from "#models/PartOfMacOS";
import { PerApp } from "#models/PerApp";
import type { SectionProps } from "#sections/Context";

function Card({ model, title, text }: { model: ReactNode; title: string; text: string }) {
  return (
    <article className="row-span-3 box-border grid min-w-0 grid-rows-subgrid gap-y-[18px] rounded-[28px] border border-ink/8 bg-white p-7">
      <div className="box-border flex min-h-[120px] flex-col justify-center gap-3.5 rounded-[18px] bg-linen p-5">
        {model}
      </div>
      <h3 className="m-0 text-[22px] font-bold text-charcoal">{title}</h3>
      <p className="m-0 text-base leading-[1.55] text-slate">{text}</p>
    </article>
  );
}

/** 4. Features: four cards, each with the animated part of its model. */
export function Features({ locale, messages }: SectionProps) {
  const t = messages.features;
  return (
    <Section id="features">
      <SectionHeading eyebrow={t.eyebrow} title={t.title} />
      <div className="grid grid-cols-[repeat(auto-fit,minmax(min(100%,440px),1fr))] gap-5">
        <Card model={<ForeignWords />} title={t.foreignTitle} text={t.foreignText} />
        <Card
          model={<AddMarks messages={messages} />}
          title={t.addMarksTitle}
          text={t.addMarksText}
        />
        <Card
          model={<PerApp locale={locale} messages={messages} />}
          title={t.perAppTitle}
          text={t.perAppText}
        />
        <Card model={<PartOfMacOS messages={messages} />} title={t.macOSTitle} text={t.macOSText} />
      </div>
    </Section>
  );
}
