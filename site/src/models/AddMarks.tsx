import { keyCaps, typingExample, typingFrames } from "#data/Examples";
import type { Messages } from "#i18n/vi";
import { TypingDemo } from "#models/Frames";

const viet = typingExample("add-marks-viet");

/** Mark keys typed right after a word already in the document (D20). */
export function AddMarks({ messages }: { messages: Messages }) {
  const context = messages.features.addMarksContext;
  // The word already in the document, then the field after each mark key.
  const frames = typingFrames(viet).map((word) => context + word);
  return <TypingDemo small keys={keyCaps(viet)} frames={frames} />;
}
