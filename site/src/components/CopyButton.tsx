import { useState, type ReactNode } from "react";

interface CopyButtonProps {
  text: string;
  /** Announced to screen readers once the text is on the clipboard. */
  copiedMessage: string;
  className?: string;
  ariaLabel?: string;
  onCopied?: () => void;
  children: ReactNode;
}

/** Copies `text` and announces it in a polite live region. */
export function CopyButton({
  text,
  copiedMessage,
  className,
  ariaLabel,
  onCopied,
  children,
}: CopyButtonProps) {
  const [announcement, setAnnouncement] = useState("");

  async function copy() {
    try {
      await navigator.clipboard.writeText(text);
    } catch (error) {
      // The browser refused (no user activation, permission policy): the button stays usable.
      if (error instanceof DOMException && error.name === "NotAllowedError") return;
      throw error;
    }
    // Clearing first makes a second copy announce again.
    setAnnouncement("");
    requestAnimationFrame(() => setAnnouncement(copiedMessage));
    onCopied?.();
  }

  return (
    <>
      <button
        type="button"
        className={className}
        aria-label={ariaLabel}
        onClick={() => void copy()}
      >
        {children}
      </button>
      <span aria-live="polite" className="sr-only">
        {announcement}
      </span>
    </>
  );
}
