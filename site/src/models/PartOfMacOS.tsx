import type { Messages } from "#i18n/vi";

/** The input source menu macOS draws: Dấu has no menu bar icon of its own (D2, N1). */
export function PartOfMacOS({ messages }: { messages: Messages }) {
  const t = messages.features;
  return (
    <div aria-hidden="true" className="flex flex-col items-end gap-2">
      <div className="flex h-8 items-center justify-end gap-3.5 rounded-[10px] bg-white/70 px-4 text-[13px] font-semibold">
        <span className="inline-flex h-4 w-[22px] items-center justify-center rounded bg-charcoal text-[10px] font-extrabold text-paper">
          V
        </span>
        <span>{t.menuClock}</span>
      </div>
      <div className="box-border w-full max-w-80 rounded-xl bg-white/96 p-1.5 text-sm text-charcoal shadow-[0_10px_30px] ring-1 shadow-black/18 ring-black/8">
        <div className="flex h-[30px] items-center gap-2.5 rounded-[7px] bg-ink px-2.5 text-white">
          <span className="w-3.5">✓</span>
          <span className="flex-1">{t.menuDau}</span>
        </div>
        <div className="flex h-[30px] items-center gap-2.5 px-2.5">
          <span className="w-3.5" />
          <span className="flex-1">{t.menuUS}</span>
        </div>
        <div className="mx-2.5 my-1 h-px bg-black/10" />
        <div className="flex h-[30px] items-center gap-2.5 px-2.5 text-graphite">
          <span className="w-3.5" />
          <span>{t.menuSettings}</span>
        </div>
      </div>
    </div>
  );
}
