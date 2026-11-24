import type { Messages } from "#i18n/vi";

function Part({ title, subtitle, lines }: { title: string; subtitle: string; lines: string[] }) {
  return (
    <div className="flex min-w-0 flex-col gap-3.5 rounded-[18px] border border-paper/30 p-7">
      <h3 className="m-0 text-[22px] font-extrabold text-paper">{title}</h3>
      <p className="m-0 text-sm text-paper/75">{subtitle}</p>
      {lines.map((line) => (
        <p key={line} className="m-0 text-base leading-[1.55] text-paper">
          {line}
        </p>
      ))}
    </div>
  );
}

/** The two parts of Dấu: the one that gets keys has no network (N2, D8). */
export function Privacy({ messages }: { messages: Messages }) {
  const t = messages.privacy;
  return (
    <div className="grid grid-cols-1 items-stretch gap-6 min-[901px]:grid-cols-[minmax(0,1fr)_160px_minmax(0,1fr)]">
      <Part
        title={t.inputMethodTitle}
        subtitle={t.inputMethodSubtitle}
        lines={[t.inputMethodNetwork, t.inputMethodSandbox, t.inputMethodLog]}
      />
      <div className="flex flex-col items-center justify-center gap-2.5 text-center">
        <div className="h-0.5 w-full bg-paper/50" />
        <p className="m-0 text-sm leading-normal text-paper/85">{t.link}</p>
      </div>
      <Part
        title={t.appTitle}
        subtitle={t.appSubtitle}
        lines={[t.appNetwork, t.appReports, t.appTelemetry]}
      />
    </div>
  );
}
