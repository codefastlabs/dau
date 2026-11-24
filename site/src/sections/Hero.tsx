import { DownloadButton } from "#components/DownloadButton";
import { DownloadIcon } from "#components/Icons";
import { repositoryUrl } from "#Links";
import { TonePlacement } from "#models/TonePlacement";
import type { SectionProps } from "#sections/Context";

/** 2. Hero: the one idea of the page, the main buttons and the typing animation. */
export function Hero({ messages, pageUrl }: SectionProps) {
  const t = messages.hero;
  return (
    <section id="top">
      <div className="mx-auto box-content grid max-w-[1120px] grid-cols-1 items-center gap-14 px-6 pt-12 pb-24 min-[901px]:grid-cols-[minmax(0,1.5fr)_minmax(0,1fr)]">
        <div className="flex min-w-0 flex-col gap-6">
          <span className="text-[13px] font-bold tracking-[1px] text-ink-soft uppercase">
            {t.eyebrow}
            <span className="max-[640px]:hidden">{t.eyebrowSuffix}</span>
          </span>
          <h1 className="m-0 text-[clamp(42px,4.7vw,60px)] leading-[1.04] font-extrabold tracking-[-2px] text-balance text-charcoal">
            {t.title}
          </h1>
          <p className="m-0 max-w-[560px] text-[19px] leading-[1.55] text-slate">{t.subtitle}</p>
          <div className="flex flex-col gap-3">
            <div className="flex flex-wrap gap-3">
              <DownloadButton
                href="#download"
                withIcon
                className="box-border inline-flex items-center gap-2.5 rounded-full border-0 bg-ink px-7 py-[15px] text-base font-bold text-paper no-underline"
                copyLabel={messages.copyLink.label}
                copiedMessage={messages.copyLink.copied}
                pageUrl={pageUrl}
              >
                <DownloadIcon />
                {t.download}
              </DownloadButton>
              <a
                href={repositoryUrl}
                className="inline-flex items-center rounded-full bg-ink/8 px-6 py-[15px] text-base font-semibold text-ink no-underline"
              >
                {t.source}
              </a>
            </div>
            <span className="hidden text-[15px] leading-normal text-slate non-mac:block">
              {messages.copyLink.macOnly}
            </span>
          </div>
          <span className="text-sm text-muted">{t.requirements}</span>
        </div>
        <div className="flex min-w-0 justify-center">
          <TonePlacement messages={messages} />
        </div>
      </div>
    </section>
  );
}
