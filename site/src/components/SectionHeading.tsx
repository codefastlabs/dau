import type { ReactNode } from "react";

/** Eyebrow, title and lead that open every section of the page. */
export function SectionHeading({
  eyebrow,
  title,
  lead,
  leadWidth = "max-w-[760px]",
  onInk = false,
}: {
  eyebrow: string;
  title: string;
  lead?: ReactNode;
  leadWidth?: string;
  onInk?: boolean;
}) {
  return (
    <div className="flex flex-col gap-3.5">
      <span
        className={`text-[13px] font-bold tracking-[1px] uppercase ${onInk ? "text-ink-pale" : "text-ink-soft"}`}
      >
        {eyebrow}
      </span>
      <h2
        className={`m-0 max-w-[820px] text-[clamp(30px,4.2vw,48px)] leading-[1.08] font-extrabold tracking-[-1px] ${onInk ? "text-paper" : "text-charcoal"}`}
      >
        {title}
      </h2>
      {lead ? (
        <p
          className={`m-0 text-lg leading-relaxed ${leadWidth} ${onInk ? "text-paper/85" : "text-slate"}`}
        >
          {lead}
        </p>
      ) : null}
    </div>
  );
}

/** A full-width band holding one section in the page column. */
export function Section({
  id,
  className = "",
  children,
}: {
  id: string;
  className?: string;
  children: ReactNode;
}) {
  return (
    <section id={id} className={className}>
      <div className="mx-auto box-content flex max-w-[1120px] flex-col gap-10 px-6 py-24">
        {children}
      </div>
    </section>
  );
}
