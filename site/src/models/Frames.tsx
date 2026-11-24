import type { CSSProperties, ReactNode } from "react";

export interface FrameTiming {
  /** How long each frame but the last stays on screen. */
  stepSeconds: number;
  /** How long the last frame stays before the animation starts over. */
  holdSeconds: number;
}

/**
 * The pace of the key-by-key models: 0.6 s a key is slow enough to follow each key and its
 * text, and the result stays 3 s (the last key lit for one step, then 2.4 s unlit).
 */
export const modelTiming: FrameTiming = { stepSeconds: 0.6, holdSeconds: 3 };

const ms = (seconds: number) => Math.round(seconds * 1000);

/** A short stable name for a block of CSS, so React writes each distinct block once. */
const cssName = (css: string) =>
  [...css].reduce((hash, char) => (hash * 33 + char.charCodeAt(0)) >>> 0, 5381).toString(36);

/**
 * Keyframes for `count` frames: each frame is a copy of the same element, shown during its
 * own slice of the cycle by `animation-delay`, so the whole animation is CSS (docs/Website.md).
 * A key cap lights up the same way, for the frames its key produces.
 */
function frameAnimation(count: number, timing: FrameTiming) {
  const cycle = timing.stepSeconds * (count - 1) + timing.holdSeconds;
  const name = `frames-${ms(timing.stepSeconds)}-${ms(timing.holdSeconds)}-${count}`;
  const percent = (seconds: number) => ((seconds / cycle) * 100).toFixed(3);
  const showFor = (keyframesName: string, seconds: number) =>
    `@keyframes ${keyframesName}{0%{opacity:1}${percent(seconds)}%{opacity:0}100%{opacity:0}}`;
  const delay = (index: number) => `${(index * timing.stepSeconds).toFixed(2)}s`;
  const duration = `${cycle.toFixed(2)}s step-end infinite`;
  return {
    name,
    css: showFor(name, timing.stepSeconds) + showFor(`${name}-last`, timing.holdSeconds),
    frameStyle: (index: number): CSSProperties => ({
      animation: `${index === count - 1 ? `${name}-last` : name} ${duration}`,
      animationDelay: delay(index),
    }),
    /** A key lit from frame `first` for `steps` steps; its keyframes come with it. */
    litKey: (first: number, steps: number) => ({
      css: showFor(`${name}-key${steps}`, steps * timing.stepSeconds),
      style: { animation: `${name}-key${steps} ${duration}`, animationDelay: delay(first) },
    }),
  };
}

interface FramesProps {
  frames: readonly ReactNode[];
  timing: FrameTiming;
  /** Class of each frame element, next to `frame`. */
  className?: string;
  style?: CSSProperties;
}

/** Frames of one animation, stacked in place; reduced motion shows only the last. */
export function Frames({ frames, timing, className = "", style }: FramesProps) {
  const { name, css, frameStyle } = frameAnimation(frames.length, timing);
  return (
    <>
      <style href={name} precedence="default">
        {css}
      </style>
      {frames.map((content, index) => {
        const last = index === frames.length - 1;
        return (
          <span
            // Frames never reorder; the index is the frame's identity.
            // oxlint-disable-next-line react/no-array-index-key
            key={index}
            className={`frame ${last ? "last" : ""} ${className}`}
            style={{ ...style, ...frameStyle(index) }}
          >
            {content}
          </span>
        );
      })}
    </>
  );
}

/** One frame of a typing field: the text, then the caret, then an optional note after it. */
export type FieldFrame = ReactNode | { text: ReactNode; afterCaret: ReactNode };

function isNoted(frame: FieldFrame): frame is { text: ReactNode; afterCaret: ReactNode } {
  return typeof frame === "object" && frame !== null && "afterCaret" in frame;
}

/** A text field that replays typed frames, each with a caret after the text. */
export function TypingField({
  frames,
  timing = modelTiming,
  small = false,
}: {
  frames: readonly FieldFrame[];
  timing?: FrameTiming;
  small?: boolean;
}) {
  return (
    <div className={`typing-field ${small ? "small" : ""}`} aria-hidden="true">
      <Frames
        timing={timing}
        frames={frames.map((frame) => (
          <>
            {isNoted(frame) ? frame.text : frame}
            <span className="caret" />
            {isNoted(frame) ? frame.afterCaret : null}
          </>
        ))}
      />
    </div>
  );
}

/**
 * A row of key caps above a typing field. The field starts on `frames[0]` (empty, or the word
 * already in the document), then shows the text after each key while that key lights up, then
 * holds the result with no key lit. `keyForFrame[i]` is the key whose press shows frame `i`
 * (-1 for the starting frame); by default frame `i` comes from key `i - 1`. A key that produces
 * several frames stays lit for all of them. Reduced motion shows the result, no key lit.
 */
export function TypingDemo({
  keys,
  frames,
  keyForFrame = frames.map((_, index) => index - 1),
  small = false,
  timing = modelTiming,
}: {
  keys: readonly string[];
  frames: readonly FieldFrame[];
  keyForFrame?: readonly number[];
  small?: boolean;
  timing?: FrameTiming;
}) {
  if (keyForFrame.length !== frames.length) throw new Error("TypingDemo: one key index per frame");
  const animation = frameAnimation(frames.length, timing);
  const lit = keys.map((_, key) => {
    const first = keyForFrame.indexOf(key);
    const steps = keyForFrame.filter((index) => index === key).length;
    return first < 0 ? undefined : animation.litKey(first, steps);
  });
  const css = [...new Set(lit.map((entry) => entry?.css).filter(Boolean))].join("");
  return (
    <>
      <style href={`keys-${cssName(css)}`} precedence="default">
        {css}
      </style>
      <div className="flex flex-wrap items-center gap-1.5" aria-hidden="true">
        {keys.map((key, index) => (
          // Keys never reorder; the index is the key's identity.
          // oxlint-disable-next-line react/no-array-index-key
          <span key={index} className="key-cap relative">
            {key}
            <span className="key-lit" style={lit[index]?.style}>
              {key}
            </span>
          </span>
        ))}
      </div>
      <TypingField frames={frames} timing={timing} small={small} />
    </>
  );
}
