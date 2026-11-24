import { typingExample, typingFrames } from "#data/Examples";
import { format } from "#i18n/Locale";
import type { Messages } from "#i18n/vi";
import { Frames, type FrameTiming } from "#models/Frames";

const sentence = typingExample("hero-sentence");
const markMidWord = typingExample("hero-hoa-binh");

// The hero starts on the empty field, types the sentence, Return, then a phrase whose first word
// has its mark key before its last vowel (D28): "hofa" passes through "hò". The phrase's own
// empty start is the Return frame, so it is skipped.
const textFrames = [
  ...typingFrames(sentence),
  `${sentence.expected}\n`,
  ...typingFrames(markMidWord)
    .slice(1)
    .map((text) => `${sentence.expected}\n${text}`),
];
const keyFrames = [
  "",
  ...sentence.keys.replaceAll(" ", "␣"),
  "↩",
  ...markMidWord.keys.replaceAll(" ", "␣"),
];

if (textFrames.length !== keyFrames.length) {
  throw new Error("Hero animation: one text frame per key is required");
}

const timing: FrameTiming = { stepSeconds: 0.24, holdSeconds: 2.64 };

/** Hero animation: keys become marked text, showing only the key just typed (D28, D15). */
export function TonePlacement({ messages }: { messages: Messages }) {
  const label = format(messages.hero.illustration, {
    keys1: sentence.keys,
    text1: sentence.expected,
    keys2: markMidWord.keys,
    text2: markMidWord.expected,
  });
  return (
    <div
      // The animation is markup, not a picture file, so it takes the image role with a label.
      // oxlint-disable-next-line jsx-a11y/prefer-tag-over-role
      role="img"
      aria-label={label}
      className="box-border w-full overflow-hidden rounded-[22px] border border-ink/12 bg-white shadow-[0_30px_60px_-20px] shadow-ink/35"
    >
      <div className="flex h-10 items-center gap-2 border-b border-black/6 bg-mist px-4">
        <div aria-hidden="true" className="flex gap-2">
          <span className="size-3 rounded-full bg-window-close" />
          <span className="size-3 rounded-full bg-window-minimize" />
          <span className="size-3 rounded-full bg-window-zoom" />
        </div>
        <span aria-hidden="true" className="mr-[52px] flex-1 text-center text-xs text-muted">
          {messages.hero.windowTitle}
        </span>
        <svg
          width="22"
          height="16"
          viewBox="0 0 22 16"
          aria-hidden="true"
          className="block flex-none"
        >
          <path
            fillRule="evenodd"
            className="fill-charcoal"
            d="M4.5 0.5 H17.5 A4 4 0 0 1 21.5 4.5 V11.5 A4 4 0 0 1 17.5 15.5 H4.5 A4 4 0 0 1 0.5 11.5 V4.5 A4 4 0 0 1 4.5 0.5 Z M6.5 3.75 H8.3 L11 10.125 L13.7 3.75 H15.5 L11.9 12.25 H10.1 Z"
          />
        </svg>
      </div>
      <div
        aria-hidden="true"
        className="[container-type:inline-size] flex flex-col gap-7 px-8 pt-9 pb-7"
      >
        {/* Each typed line stays on one line: 11cqi fits "tôi yêu tiếng Việt" and the caret in
            the narrowest card (Be Vietnam Pro 600 is 8.45 em wide for that line). */}
        <div className="relative h-[2.6em] text-[min(44px,11cqi)] leading-[1.3] font-semibold text-charcoal">
          <Frames
            timing={timing}
            className="absolute inset-0 whitespace-pre"
            frames={textFrames.map((text) => (
              <>
                {text}
                <span className="hero-caret" />
              </>
            ))}
          />
        </div>
        <div className="flex items-center gap-3.5">
          <span className="text-[13px] text-muted">{messages.hero.lastKey}</span>
          <span className="relative inline-block size-14 rounded-xl border border-black/16 bg-white font-mono text-2xl font-semibold text-charcoal shadow-[0_3px_0] shadow-black/14">
            <Frames
              timing={timing}
              className="absolute inset-0 flex items-center justify-center"
              frames={keyFrames}
            />
          </span>
        </div>
      </div>
    </div>
  );
}
