import type { ReactNode } from "react";
import { keyCaps, typingExample, typingFrames } from "#data/Examples";
import type { Messages } from "#i18n/vi";
import { TypingDemo } from "#models/Frames";

const hoa = typingExample("three-ways-hoa");
const keys = keyCaps(hoa);
const frames = typingFrames(hoa);
const beforeLastKey = frames.slice(0, -1);
// The simulated input method erases back to the text before the replaced letter.
const erasedTo = frames.at(-3) ?? "";

function Card({
  title,
  caption,
  emphasized = false,
  children,
}: {
  title: string;
  caption: string;
  emphasized?: boolean;
  children: ReactNode;
}) {
  return (
    <div
      className={`flex min-w-0 flex-col gap-4 rounded-3xl bg-white p-6 ${emphasized ? "border-2 border-ink" : "border border-ink/8"}`}
    >
      <h3 className="m-0 text-[15px] font-bold text-ink">{title}</h3>
      {children}
      <p className="m-0 text-[15px] leading-[1.55] text-iron">{caption}</p>
    </div>
  );
}

const underlined = (text: string) => (
  <span className="underline decoration-2 underline-offset-[5px]">{text}</span>
);

const fakeKey = (label: string) => <span className="key-cap ml-3 text-[13px]">{label}</span>;

/** Three ways the same keys reach the app (N3, D13): underline, fake keys, in place. */
export function ThreeWays({ messages }: { messages: Messages }) {
  const t = messages.why;
  return (
    <>
      <Card title={t.builtInTitle} caption={t.builtInCaption}>
        <TypingDemo
          keys={[...keys, "Space"]}
          // Space commits the underlined word.
          frames={[...frames.map(underlined), `${hoa.expected} `]}
        />
      </Card>
      <Card title={t.simulatedTitle} caption={t.simulatedCaption}>
        <TypingDemo
          keys={keys}
          frames={[
            ...beforeLastKey,
            { text: erasedTo, afterCaret: fakeKey(t.simulatedFakeDelete) },
            { text: hoa.expected, afterCaret: fakeKey(t.simulatedRetype) },
          ]}
          // The last key shows two frames: the fake ⌫, then the retyped letters.
          keyForFrame={[
            ...beforeLastKey.map((_, index) => index - 1),
            keys.length - 1,
            keys.length - 1,
          ]}
        />
      </Card>
      <Card title={t.dauTitle} caption={t.dauCaption} emphasized>
        <TypingDemo keys={keys} frames={frames} />
      </Card>
    </>
  );
}
