import { en } from "#i18n/en";
import { localizedPath, type Locale } from "#i18n/Locale";
import { vi } from "#i18n/vi";
import { AppIcon } from "#components/AppIcon";

const blocks: { locale: Locale; messages: typeof vi }[] = [
  { locale: "vi", messages: vi },
  { locale: "en", messages: en },
];

/**
 * The 404 page in both languages at once: an unknown path does not say which one the reader
 * wants (docs/Website.md). Each block carries its own `lang`.
 */
export function NotFound() {
  return (
    <main className="mx-auto box-content flex min-h-svh max-w-[1120px] flex-col justify-center gap-12 px-6 py-24">
      <AppIcon size={72} />
      {blocks.map(({ locale, messages }) => (
        <section key={locale} lang={locale} className="flex flex-col gap-3.5">
          <h1 className="m-0 text-[clamp(30px,4.2vw,48px)] leading-[1.08] font-extrabold tracking-[-1px] text-charcoal">
            {messages.notFound.title}
          </h1>
          <p className="m-0 text-lg leading-relaxed text-slate">
            {messages.notFound.text}{" "}
            <a href={localizedPath("/", locale)} hrefLang={locale} className="font-bold text-ink">
              {messages.notFound.home}
            </a>
          </p>
        </section>
      ))}
    </main>
  );
}
