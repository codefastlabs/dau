import { AppIcon } from "#components/AppIcon";
import { DownloadButton } from "#components/DownloadButton";
import { LanguageLink } from "#components/LanguageLink";
import { repositoryUrl } from "#Links";
import type { SectionProps } from "#sections/Context";

const link = "text-slate no-underline";

/** 1. Navigation: logo, section links (GitHub hidden on phones) and the main button. */
export function Nav({ locale, messages, pageUrl }: SectionProps) {
  const t = messages.nav;
  return (
    <header className="relative z-2">
      <nav
        aria-label={t.label}
        className="mx-auto box-content flex max-w-[1120px] flex-wrap items-center gap-x-3 gap-y-3 px-6 py-[18px] text-[15px] min-[641px]:gap-x-7"
      >
        <a
          href="#top"
          className="flex items-center gap-2.5 text-xl font-extrabold text-charcoal no-underline"
        >
          <AppIcon size={32} />
          Dấu
        </a>
        <span className="flex-1" />
        <span className="hidden gap-7 min-[641px]:flex">
          <a href="#features" className={link}>
            {t.features}
          </a>
          <a href="#typing-table" className={link}>
            {t.typingTable}
          </a>
          <a href="#faq" className={link}>
            {t.faq}
          </a>
          <a href={repositoryUrl} className={link}>
            {t.github}
          </a>
        </span>
        <LanguageLink path="/" from={locale} label={t.otherLanguage} className={link} />
        <DownloadButton
          href="#download"
          className="box-border rounded-full border-0 bg-ink px-[18px] py-[9px] text-[15px] font-bold text-paper no-underline"
          copyLabel={messages.copyLink.label}
          copiedMessage={messages.copyLink.copied}
          pageUrl={pageUrl}
        >
          {t.download}
        </DownloadButton>
      </nav>
    </header>
  );
}
