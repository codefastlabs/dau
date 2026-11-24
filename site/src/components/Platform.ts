/**
 * Runs in the document head before first paint and marks a reader not on a Mac with
 * `data-platform="other"` on <html>; Styles.css then swaps the download buttons for the
 * copy-link buttons (docs/Website.md, section 9). Deciding before paint keeps the layout from
 * shifting, and the prerendered HTML stays the Mac state for readers without JavaScript.
 *
 * Chromium browsers report the platform in `userAgentData`. Safari and Firefox do not, and
 * Safari on iPad sends the Mac user agent; its `maxTouchPoints` (5, against 0 on a Mac) tells
 * it apart. The values never leave the page.
 */
export const platformScript =
  "(function(){var n=navigator,d=n.userAgentData;" +
  "var mac=d?d.platform==='macOS':/Macintosh/.test(n.userAgent)&&n.maxTouchPoints<2;" +
  "if(!mac)document.documentElement.setAttribute('data-platform','other')})()";
