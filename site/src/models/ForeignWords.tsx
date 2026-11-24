import { keyCaps, typingExample, typingFrames } from "#data/Examples";
import { TypingDemo } from "#models/Frames";

const windows = typingExample("foreign-windows");
const car = typingExample("foreign-car-double-r");

/** Foreign words stay as typed (D4); a doubled mark key keeps the letters (D26). */
export function ForeignWords() {
  return (
    <>
      <div className="flex flex-col gap-2">
        {/* Telex reads the leading w as ư until Space restores the word. */}
        <TypingDemo small keys={keyCaps(windows)} frames={typingFrames(windows)} />
      </div>
      <div className="flex flex-col gap-2">
        <TypingDemo small keys={keyCaps(car)} frames={typingFrames(car)} />
      </div>
    </>
  );
}
