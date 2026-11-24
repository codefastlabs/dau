// Every number and promise on the page, read at build time from files in the repository
// (docs/research/WebsiteStack.md, "Dữ liệu lúc build"). A value without data stays undefined,
// and the page shows the bracketed slot instead (N5).

import compatibilityFile from "../../../Apps/Dau/Resources/CompatibilityList.json" with { type: "json" };
import supportersFile from "../../../Apps/Dau/Resources/Supporters.json" with { type: "json" };
import appcastXml from "#site/appcast.xml?raw";
import type { Locale } from "#i18n/Locale";
import { releasesUrl } from "#Links";
import { parseAppcast, selectItem, type AppcastItem } from "#data/Appcast";
import checksums from "#data/Checksums.json" with { type: "json" };
import distribution from "#data/Distribution.json" with { type: "json" };
import expensesFile from "#data/Expenses.json" with { type: "json" };
import measurementsFile from "#data/Measurements.json" with { type: "json" };

export interface HeavyLoad {
  /** The build number of a released build; null for a run on a commit that was not released. */
  sparkleVersion: string | null;
  /** Display names of the apps the run typed in. */
  apps: string[];
  p99Ms: number;
  p99LimitMs: number;
  p99Build: string;
  rssMB: number;
  rssLimitMB: number;
  rssBuild: string;
  machine: string;
  macOS: string;
  date: string;
  commit: string;
}

export interface EngineTests {
  cases: number;
  commit: string;
  date: string;
}

export interface Expense {
  date: string;
  item: Record<Locale, string>;
  amount: number;
  currency: string;
}

export interface Supporter {
  name: string;
  since: string;
}

type LocalizedName = string | Record<Locale, string>;

interface CompatibilityEntry {
  name: LocalizedName;
  suggestUnderline?: boolean;
  measured?: boolean;
  inPlaceCorrect?: boolean;
  measuredMacOS?: string;
}

/** The build the download section offers, or undefined while the feed has no item. */
export const offeredBuild: AppcastItem | undefined = selectItem(parseAppcast(appcastXml));

export const downloadUrl: string = offeredBuild?.url ?? releasesUrl;

export const checksum: string | undefined = offeredBuild
  ? (checksums as Record<string, string>)[offeredBuild.version]
  : undefined;

export const homebrewCask: boolean = distribution.homebrewCask;

/** True once the GitHub Sponsors account takes donations (D39); until then the button is hidden. */
export const githubSponsors: boolean = distribution.githubSponsors;

/** The account the VietQR code pays into, as the code itself encodes it (D39). */
export const vietQR: { recipient: string; bank: string } = distribution.vietQR;

const measurements = measurementsFile as {
  engineTests: EngineTests | null;
  heavyLoad: HeavyLoad | null;
};

export const engineTests: EngineTests | undefined = measurements.engineTests ?? undefined;

/** The latest heavy-load run (D42), shown with its build, Mac and date in Why Dấu (docs/Website.md, section 3). */
export const latestHeavyLoad: HeavyLoad | undefined = measurements.heavyLoad ?? undefined;

/** Heavy-load numbers, only when they were measured on the offered build (docs/Website.md, section 7). */
export const heavyLoad: HeavyLoad | undefined =
  latestHeavyLoad && offeredBuild && latestHeavyLoad.sparkleVersion === offeredBuild.version
    ? latestHeavyLoad
    : undefined;

const compatibility: CompatibilityEntry[] = [
  ...(compatibilityFile.apps as CompatibilityEntry[]),
  ...((compatibilityFile as { webApps?: CompatibilityEntry[] }).webApps ?? []),
];

const nameIn = (name: LocalizedName, locale: Locale) =>
  typeof name === "string" ? name : name[locale];

export const measuredAppCount: number = compatibility.filter((app) => app.measured).length;

/** Measured typing correctly in place and not labelled "Đề xuất" (docs/Website.md, section 3). */
const isVerified = (app: CompatibilityEntry) =>
  Boolean(app.measured && app.inPlaceCorrect && !app.suggestUnderline);

/** Names of the verified apps, in the language's alphabetical order. */
export function verifiedApps(locale: Locale): string[] {
  return compatibility
    .filter(isVerified)
    .map((app) => nameIn(app.name, locale))
    .sort((a, b) => a.localeCompare(b, locale));
}

/** The macOS versions the verified apps were measured on. */
export const verifiedMacOS: string = [
  ...new Set(compatibility.filter(isVerified).map((app) => app.measuredMacOS)),
]
  .filter(Boolean)
  .join(", ");

/** Apps labelled "Đề xuất" for underlining (D13). */
export const suggestedApps: string[] = compatibility
  .filter((app) => app.suggestUnderline)
  .map((app) => nameIn(app.name, "en"));

export const supporters: Supporter[] = supportersFile.supporters as Supporter[];

export const expenses: Expense[] = expensesFile.expenses as Expense[];
