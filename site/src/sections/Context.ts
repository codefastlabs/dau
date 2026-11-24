import type { Locale } from "#i18n/Locale";
import type { Messages } from "#i18n/vi";

/** What every section needs: the language, its strings and the page's canonical URL. */
export interface SectionProps {
  locale: Locale;
  messages: Messages;
  pageUrl: string;
}
