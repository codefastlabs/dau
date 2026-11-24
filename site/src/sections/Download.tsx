import { track } from "#analytics/Tracking";
import { AppIcon } from "#components/AppIcon";
import { CopyButton } from "#components/CopyButton";
import { DownloadIcon, LinkIcon } from "#components/Icons";
import { checksum, downloadUrl, homebrewCask, offeredBuild } from "#data/SiteData";
import { format } from "#i18n/Locale";
import { homebrewCommand, releasesUrl } from "#Links";
import type { SectionProps } from "#sections/Context";
import { formatDate, formatMegabytes } from "#sections/Formatting";

/**
 * 9. Download: the offered build from the appcast, its checksum, Homebrew once the cask exists
 * (D6). Off a Mac the copy-link box leads and the .dmg button steps back (docs/Website.md).
 */
export function Download({ locale, messages, pageUrl }: SectionProps) {
  const t = messages.download;
  const version = offeredBuild?.shortVersion ?? t.versionPlaceholder;
  const date = offeredBuild?.pubDate ? formatDate(offeredBuild.pubDate, locale) : t.datePlaceholder;
  const size = offeredBuild?.lengthBytes
    ? format(t.sizeValue, { size: formatMegabytes(offeredBuild.lengthBytes, locale) })
    : t.sizePlaceholder;
  return (
    <section id="download">
      <div className="mx-auto box-content flex max-w-[1120px] flex-col gap-10 px-6 py-24">
        <div className="grid grid-cols-[repeat(auto-fit,minmax(min(100%,320px),1fr))] items-center gap-10 rounded-[32px] border border-ink/10 bg-white p-[clamp(28px,5vw,56px)]">
          <div className="col-[1/-1] hidden flex-col items-start gap-3 rounded-2xl bg-mist p-4 non-mac:flex">
            <span className="text-[15px] leading-normal font-semibold text-charcoal">
              {messages.copyLink.macOnly}
            </span>
            <CopyButton
              text={pageUrl}
              copiedMessage={messages.copyLink.copied}
              className="box-border inline-flex cursor-pointer items-center gap-2.5 rounded-full border-0 bg-ink px-6 py-[13px] text-base font-bold text-paper"
            >
              <LinkIcon />
              {messages.copyLink.label}
            </CopyButton>
          </div>
          <div className="flex min-w-0 flex-col gap-[18px]">
            <div className="flex items-center gap-4">
              <AppIcon size={72} />
              <div className="flex flex-col gap-0.5">
                <span className="text-3xl font-extrabold text-charcoal">
                  {format(t.name, { version })}
                </span>
                <span className="text-sm text-muted">
                  {date} · {size}
                </span>
              </div>
            </div>
            <span className="text-[15px] leading-relaxed text-slate">{t.requirements}</span>
            <div className="flex flex-wrap gap-3">
              <a
                href={downloadUrl}
                onClick={() => track("download_click", { locale })}
                className="inline-flex items-center gap-2.5 rounded-full bg-ink px-7 py-[15px] text-base font-bold text-paper no-underline non-mac:bg-ink/8 non-mac:px-6 non-mac:font-semibold non-mac:text-ink"
              >
                <DownloadIcon />
                {t.dmg}
              </a>
              <a
                href={releasesUrl}
                className="inline-flex items-center rounded-full bg-ink/8 px-6 py-[15px] text-base font-semibold text-ink no-underline"
              >
                {t.history}
              </a>
            </div>
          </div>
          <div className="flex min-w-0 flex-col gap-3.5">
            {homebrewCask ? (
              <>
                <span className="text-sm font-bold text-charcoal">{t.homebrewTitle}</span>
                <div className="flex flex-wrap items-start gap-x-3 gap-y-2.5 rounded-2xl bg-charcoal py-3.5 pr-3.5 pl-5">
                  <code className="min-w-0 flex-[1_1_220px] py-[5px] font-mono text-[15px] leading-normal wrap-anywhere whitespace-pre-wrap text-paper">
                    {homebrewCommand}
                  </code>
                  <CopyButton
                    text={homebrewCommand}
                    copiedMessage={t.homebrewCopied}
                    ariaLabel={t.homebrewCopyLabel}
                    onCopied={() => track("homebrew_copy", { locale })}
                    className="box-border inline-flex h-[34px] flex-none cursor-pointer items-center rounded-full border-0 bg-paper/14 px-3.5 text-sm font-semibold text-paper"
                  >
                    {t.homebrewCopy}
                  </CopyButton>
                </div>
              </>
            ) : null}
            <span className="text-[13px] wrap-anywhere text-muted">
              {format(t.checksum, { checksum: checksum ?? t.checksumPlaceholder })}
            </span>
            <div className="flex flex-col gap-1 border-t border-ink/10 pt-3.5">
              <span className="text-sm font-bold text-charcoal">{t.verifiableTitle}</span>
              <span className="text-sm leading-normal text-slate">{t.verifiableText}</span>
            </div>
            <div className="rounded-2xl bg-mist px-4 py-3.5 text-sm leading-normal text-slate non-mac:hidden">
              {t.otherDeviceBefore}
              <CopyButton
                text={pageUrl}
                copiedMessage={messages.copyLink.copied}
                className="cursor-pointer border-0 bg-transparent p-0 text-sm font-bold text-ink underline"
              >
                {t.otherDeviceLink}
              </CopyButton>
              {t.otherDeviceAfter}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
