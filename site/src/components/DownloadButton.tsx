import type { ReactNode } from "react";
import { CopyButton } from "#components/CopyButton";
import { LinkIcon } from "#components/Icons";

interface DownloadButtonProps {
  href: string;
  /** Classes shared by both states, so the button keeps its look when it swaps. */
  className: string;
  children: ReactNode;
  copyLabel: string;
  copiedMessage: string;
  /** The page URL the copy-link state puts on the clipboard. */
  pageUrl: string;
  withIcon?: boolean;
  onClick?: () => void;
}

/**
 * The download button on a Mac; elsewhere the "copy link" button in its place
 * (docs/Website.md, section 9). Both are in the HTML; Styles.css shows one by platform.
 */
export function DownloadButton({
  href,
  className,
  children,
  copyLabel,
  copiedMessage,
  pageUrl,
  withIcon = false,
  onClick,
}: DownloadButtonProps) {
  return (
    <>
      <a href={href} className={`${className} non-mac:hidden`} onClick={onClick}>
        {children}
      </a>
      <span className="hidden non-mac:contents">
        <CopyButton
          text={pageUrl}
          copiedMessage={copiedMessage}
          className={`${className} cursor-pointer`}
        >
          {withIcon ? <LinkIcon /> : null}
          {copyLabel}
        </CopyButton>
      </span>
    </>
  );
}
