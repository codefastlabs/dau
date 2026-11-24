// Typed examples shown by the illustration models. Each comes from TypingExamples.json, which
// DauEngine's WebsiteExamplesTests replays through the engine, so the page cannot show text
// the engine does not produce.

import file from "#data/TypingExamples.json" with { type: "json" };

export interface TypingExample {
  id: string;
  method: "telex" | "vni";
  keys: string;
  expected: string;
  typedWord?: string;
  /** Field text after each key; the last equals `expected`. */
  frames?: string[];
}

const examples = new Map(file.examples.map((entry) => [entry.id, entry as TypingExample]));

/** The example `id`. A missing id throws while the page prerenders, so the build fails. */
export function typingExample(id: string): TypingExample {
  const found = examples.get(id);
  if (!found) throw new Error(`TypingExamples.json has no example "${id}"`);
  return found;
}

/** The keys of `example` as key caps: one per key, a typed space shown as "Space". */
export function keyCaps(example: TypingExample): string[] {
  return [...example.keys].map((key) => (key === " " ? "Space" : key));
}

/**
 * The field before the first key, then its text after each key: animations start from an
 * empty field, or from the word already in the document (D20). The engine test checks the
 * frames after each key; missing or malformed frames throw while the page prerenders.
 */
export function typingFrames(example: TypingExample): string[] {
  const { frames } = example;
  if (!frames || frames.length !== [...example.keys].length || frames.at(-1) !== example.expected) {
    throw new Error(
      `TypingExamples.json: "${example.id}" needs one frame per key, ending on expected`,
    );
  }
  return [example.typedWord ?? "", ...frames];
}
