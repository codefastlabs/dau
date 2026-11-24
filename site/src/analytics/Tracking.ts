// Page views and three events, counted by Vercel Web Analytics without cookies or identifiers
// (D45). Events go only to the consent-exempt lane of @codefast/tracking.

import { createClientTracker } from "@codefast/tracking/client/create-client-tracker";
import { defineEventCatalog } from "@codefast/tracking/core/event-catalog";
import { createVercelAnalyticsDestination } from "@codefast/tracking/destinations/vercel-analytics";
import { inject } from "@vercel/analytics";
import * as v from "valibot";
import { siteHostname } from "#Links";

const locale = v.picklist(["vi", "en"]);

const catalog = defineEventCatalog({
  download_click: { schema: v.object({ locale }) },
  homebrew_copy: { schema: v.object({ locale }) },
  language_switch: { schema: v.object({ from: locale, to: locale }) },
});

const tracker = createClientTracker({
  catalog,
  destinations: [createVercelAnalyticsDestination({ consentRequirement: "exempt" })],
  // Closed gate: only exempt destinations receive events and no identifier is ever made.
  isAnalyticsAllowed: () => false,
  anonymousId: () => "",
});

// Vercel serves /_vercel/insights only on its own deployment; on localhost, CI and previews the
// script would 404 in the console and the counts would mix in test visits.
const onProductionHost = () =>
  typeof window !== "undefined" && window.location.hostname === siteHostname;

let injected = false;

/** Starts page-view counting once, on the production host only. */
export function startAnalytics(): void {
  if (injected || !onProductionHost()) return;
  injected = true;
  inject({ mode: "production", framework: "tanstack-start" });
}

type Catalog = typeof catalog;

export function track<Name extends keyof Catalog & string>(
  name: Name,
  properties: v.InferOutput<Catalog[Name]["schema"]>,
): void {
  if (!onProductionHost()) return;
  tracker.track(name, properties);
}
