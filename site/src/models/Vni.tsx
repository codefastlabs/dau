import type { ReactNode } from "react";
import { keyCaps, typingExample, typingFrames } from "#data/Examples";
import type { Messages } from "#i18n/vi";
import { TypingDemo } from "#models/Frames";

const viet = typingExample("vni-viet");
const doubleDigit = typingExample("vni-double-digit");
const standalone = typingExample("vni-standalone-digits");

function Card({
  title,
  caption,
  children,
}: {
  title: string;
  caption: string;
  children: ReactNode;
}) {
  return (
    <div className="flex min-w-0 flex-col gap-3 rounded-[20px] border border-ink/8 bg-white p-5">
      <h3 className="m-0 text-sm font-bold text-ink">{title}</h3>
      {children}
      <p className="m-0 text-[15px] leading-[1.55] text-iron">{caption}</p>
    </div>
  );
}

/** VNI: a digit after a syllable is a mark (D36); typed twice it stays a digit (D26). */
export function Vni({ messages }: { messages: Messages }) {
  const t = messages.typingTable;
  return (
    <div className="flex min-w-0 flex-col gap-3.5">
      <Card title={t.vniTitle} caption={t.vniCaption}>
        <TypingDemo small keys={keyCaps(viet)} frames={typingFrames(viet)} />
      </Card>
      <Card title={t.doubleTitle} caption={t.doubleCaption}>
        <TypingDemo small keys={keyCaps(doubleDigit)} frames={typingFrames(doubleDigit)} />
      </Card>
      <Card title={t.standaloneTitle} caption={t.standaloneCaption}>
        <TypingDemo small keys={keyCaps(standalone)} frames={typingFrames(standalone)} />
      </Card>
    </div>
  );
}
