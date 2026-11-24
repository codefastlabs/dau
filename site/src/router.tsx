import { createRouter } from "@tanstack/react-router";
import { routeTree } from "#routeTree.gen";

export function getRouter() {
  return createRouter({
    routeTree,
    // One spelling for links, prerendered paths, canonical and sitemap: /en, never /en/.
    trailingSlash: "never",
    scrollRestoration: true,
  });
}

declare module "@tanstack/react-router" {
  interface Register {
    router: ReturnType<typeof getRouter>;
  }
}
