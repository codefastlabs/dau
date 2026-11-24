import { createFileRoute } from "@tanstack/react-router";
import { NotFound } from "#components/NotFound";

/** Prerendered to 404.html, which Vercel serves for unknown paths; never indexed. */
export const Route = createFileRoute("/not-found")({
  head: () => ({
    meta: [{ title: "Dấu – 404" }, { name: "robots", content: "noindex" }],
  }),
  component: NotFound,
});
