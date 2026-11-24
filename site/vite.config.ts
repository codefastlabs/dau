import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import tailwindcss from "@tailwindcss/vite";
import { tanstackStart } from "@tanstack/react-start/plugin/vite";
import viteReact from "@vitejs/plugin-react";
import { defineConfig, type Plugin } from "vite";

import { siteOrigin } from "#Links";

/**
 * Copies the Sparkle feed into the output byte for byte: the release scripts keep it at
 * site/appcast.xml and every released app reads it from the domain (D45, D7).
 */
function appcast(): Plugin {
  return {
    name: "dau-appcast",
    apply: "build",
    applyToEnvironment: (environment) => environment.name === "client",
    generateBundle() {
      this.emitFile({
        type: "asset",
        fileName: "appcast.xml",
        source: readFileSync(new URL("appcast.xml", import.meta.url)),
      });
    },
  };
}

export default defineConfig({
  server: {
    // The page reads data files the app also ships (Apps/Dau/Resources), outside site/ (D45).
    fs: { allow: [fileURLToPath(new URL("..", import.meta.url))] },
  },
  build: {
    // Fonts stay files: CSP font-src is 'self', so data: URLs would be blocked.
    assetsInlineLimit: 0,
  },
  plugins: [
    tailwindcss(),
    tanstackStart({
      prerender: {
        enabled: true,
        crawlLinks: true,
        failOnError: true,
        autoSubfolderIndex: false,
        // A link to a built file (the VietQR image download) is not a page: rendering it would
        // overwrite the file with the response.
        filter: (page) => !page.path.startsWith("/assets/"),
      },
      pages: [
        {
          path: "/not-found",
          prerender: { enabled: true, outputPath: "/404.html" },
          sitemap: { exclude: true },
        },
      ],
      sitemap: { enabled: true, host: siteOrigin },
    }),
    viteReact(),
    appcast(),
  ],
});
