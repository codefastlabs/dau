import { HeadContent, Scripts, createRootRoute, useParams } from "@tanstack/react-router";
import { useEffect, type ReactNode } from "react";
import { startAnalytics } from "#analytics/Tracking";
import { NotFound } from "#components/NotFound";
import { platformScript } from "#components/Platform";
import { localeFromParam } from "#i18n/Locale";
import appCss from "#Styles.css?url";

export const Route = createRootRoute({
  head: () => ({
    meta: [
      { charSet: "utf-8" },
      { name: "viewport", content: "width=device-width, initial-scale=1" },
      { name: "theme-color", content: "#f6f1e7" },
    ],
    links: [
      { rel: "stylesheet", href: appCss },
      { rel: "icon", href: "/favicon.ico", sizes: "32x32" },
      { rel: "icon", href: "/favicon.svg", type: "image/svg+xml" },
      { rel: "apple-touch-icon", href: "/apple-touch-icon.png" },
    ],
    scripts: [{ children: platformScript }],
  }),
  shellComponent: RootDocument,
  notFoundComponent: NotFound,
});

function RootDocument({ children }: { children: ReactNode }) {
  const params = useParams({ strict: false }) as { locale?: string };
  useEffect(startAnalytics, []);
  return (
    // The platform script in the head adds data-platform before React hydrates.
    <html lang={localeFromParam(params.locale)} suppressHydrationWarning>
      <head>
        <HeadContent />
      </head>
      <body>
        {children}
        <Scripts />
      </body>
    </html>
  );
}
