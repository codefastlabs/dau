import { AppIcon } from "#components/AppIcon";
import { issuesUrl, releasesUrl, repositoryUrl } from "#Links";
import type { SectionProps } from "#sections/Context";

const link = "text-paper no-underline";

/** 11. Footer on Charcoal: outlined logo and links (D39 asks for "Ủng hộ dự án" here). */
export function Footer({ messages }: SectionProps) {
  const t = messages.footer;
  return (
    <footer className="bg-charcoal text-paper/75">
      <div className="mx-auto box-content flex max-w-[1120px] flex-wrap items-start gap-x-12 gap-y-6 px-6 py-12 text-sm">
        <div className="flex flex-[1_1_260px] flex-col gap-3">
          <span className="flex items-center gap-2.5 text-xl font-extrabold text-paper">
            <AppIcon size={32} outlined />
            Dấu
          </span>
          <span>{t.tagline}</span>
        </div>
        <nav aria-label={t.label} className="flex flex-wrap gap-x-7 gap-y-3">
          <a href={repositoryUrl} className={link}>
            {t.source}
          </a>
          <a href={issuesUrl} className={link}>
            {t.issues}
          </a>
          <a href={releasesUrl} className={link}>
            {t.history}
          </a>
          <a href="#uninstall" className={link}>
            {t.uninstall}
          </a>
          <a href="#contribute" className={link}>
            {t.donate}
          </a>
        </nav>
      </div>
    </footer>
  );
}
