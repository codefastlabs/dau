import { createFileRoute, notFound } from "@tanstack/react-router";
import { localizedHead } from "#i18n/Head";
import { localeFromParam, localizedPath, messagesFor } from "#i18n/Locale";
import { siteOrigin } from "#Links";
import { Contribute } from "#sections/Contribute";
import { Download } from "#sections/Download";
import { Faq } from "#sections/Faq";
import { Features } from "#sections/Features";
import { Footer } from "#sections/Footer";
import { Hero } from "#sections/Hero";
import { Measured } from "#sections/Measured";
import { Nav } from "#sections/Nav";
import { Privacy } from "#sections/Privacy";
import { TypingTable } from "#sections/TypingTable";
import { Why } from "#sections/Why";

/** The download page: Vietnamese at /, English at /en (D45). */
export const Route = createFileRoute("/{-$locale}/")({
  beforeLoad: ({ params }) => {
    if (params.locale !== undefined && params.locale !== "en") throw notFound();
  },
  head: ({ params }) => {
    const locale = localeFromParam(params.locale);
    return localizedHead("/", locale, messagesFor(locale));
  },
  component: DownloadPage,
});

function DownloadPage() {
  const { locale: param } = Route.useParams();
  const locale = localeFromParam(param);
  const props = {
    locale,
    messages: messagesFor(locale),
    pageUrl: siteOrigin + localizedPath("/", locale),
  };
  return (
    <div className="bg-paper text-charcoal">
      <Nav {...props} />
      <main>
        <Hero {...props} />
        <Why {...props} />
        <Features {...props} />
        <TypingTable {...props} />
        <Privacy {...props} />
        <Measured {...props} />
        <Faq {...props} />
        <Download {...props} />
        <Contribute {...props} />
      </main>
      <Footer {...props} />
    </div>
  );
}
