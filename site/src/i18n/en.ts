// English strings. Same keys and order as vi.ts; text comes from the English artboards
// (docs/canvas/src/LandingEn*.dc.html).

import type { Messages } from "#i18n/vi";

export const en = {
  head: {
    title: "Dấu – Vietnamese input method for macOS",
    description:
      "Dấu changes letters right where you type: no underline, no fake Delete keys. Telex or VNI, as you’re used to. Free and open source.",
    ogLocale: "en_US",
    ogImage: "/og-image-en.png",
    ogImageAlt: "Dấu – Vietnamese input method for macOS",
  },
  nav: {
    label: "Main",
    features: "Features",
    typingTable: "Key Chart",
    faq: "FAQ",
    github: "GitHub",
    otherLanguage: "Tiếng Việt",
    download: "Download",
  },
  copyLink: {
    label: "Copy Link",
    copied: "Link copied",
    macOnly: "Dấu runs only on Mac. Open this page on your Mac to download it.",
  },
  hero: {
    eyebrow: "Vietnamese input method for macOS",
    eyebrowSuffix: " · Open source",
    title: "Vietnamese typing that feels native to your Mac.",
    subtitle:
      "Dấu changes letters right where you type: no underline, no fake Delete keys. Telex or VNI, as you’re used to.",
    download: "Download",
    source: "View Source Code",
    requirements:
      "Free · macOS 14 or later, tested on macOS 15 and macOS 27 · Apple silicon and Intel",
    windowTitle: "Notes",
    lastKey: "Last key",
    illustration:
      "Illustration: typing {keys1} gives {text1} (I love Vietnamese), then typing {keys2} gives {text2} (peace)",
  },
  why: {
    eyebrow: "Why Dấu",
    title: "Three ways to type Vietnamese.",
    lead: "Given the same four keys, h, o, a, f, three kinds of input methods put text into an app in three ways. The pictures only show how each works. Dấu measures only itself, so only its column has a busy-Mac number.",
    builtInTitle: "Built-in macOS input: underline",
    builtInCaption:
      "The input method underlines the word you’re typing until you press Space, then commits it to the app.",
    simulatedTitle: "Simulated keys: delete and retype",
    simulatedFakeDelete: "fake ⌫",
    simulatedRetype: "retype",
    simulatedCaption:
      "It blocks f, sends fake ⌫ keys to erase the old letters, then fake-types the new ones. The app receives both the deletes and the retyped keys.",
    dauTitle: "Dấu: replaces in place",
    dauCaption:
      "Dấu replaces just the letters that change, in one step. No fake keys, and no underline by default.",
    busyEyebrow: "Dấu on a busy Mac",
    busyValue: "under {ms} ms",
    busyPlaceholder: "[Heavy-load test result]",
    busyText:
      "is how long Dấu takes to handle 99% of the keys that change text while the Mac is under heavy load. A 60 Hz screen redraws every 16.7 ms. Text came out right in every run in {apps}.",
    busyConditions:
      "Measured {date} on an {machine}, measurement ({build}) build. A build slower than {limit} ms is not released.",
    verifiedTitle: "Tested and typing correctly in {count} apps (macOS {macOS})",
  },
  features: {
    eyebrow: "Features",
    title: "Smart where it matters. Quiet everywhere else.",
    foreignTitle: "Keeps foreign words",
    foreignText:
      "Type “windows” or “Sunrise”, press Space, and it stays as typed. A word that’s also Vietnamese stays Vietnamese; press the mark key twice to keep your letters.",
    addMarksContext: "Hẹn gặp ở ",
    addMarksTitle: "Add marks to typed words",
    addMarksText:
      "Forgot a mark? Put the cursor right after the word and type a mark key, no retyping. Not in apps with underline on.",
    perAppInPlace: "In place",
    perAppUnderline: "Underline",
    perAppSuggested: "Suggested",
    perAppSwitch: "Underline while typing in {app}",
    perAppTitle: "Underline when needed",
    perAppText:
      "By default, Dấu replaces letters in place, without underline. If an app garbles text when you type fast, turn on underline just for that app.",
    menuClock: "Thu 9:41",
    menuDau: "Dấu – Vietnamese",
    menuUS: "U.S.",
    menuSettings: "Dấu Settings…",
    macOSTitle: "Feels like part of macOS",
    macOSText:
      "Switch languages with the system shortcut, see an indicator under the cursor, and use settings laid out like System Settings. The menu bar shows only the macOS input source icon.",
  },
  typingTable: {
    eyebrow: "Key Chart",
    title: "Telex and VNI at a glance.",
    lead: "Type a mark key anywhere in the word. Press a mark key twice to remove the mark and keep the letter you typed.",
    caption: "Telex and VNI keys",
    result: "Result",
    name: "Name",
    telex: "Telex",
    vni: "VNI",
    rows: {
      sac: "Acute (sắc)",
      huyen: "Grave (huyền)",
      hoi: "Hook (hỏi)",
      nga: "Tilde (ngã)",
      nang: "Dot below (nặng)",
      circumflex: "Circumflex",
      breve: "Breve",
      horn: "Horn",
      wAlone: "Letter ư (Telex only)",
      dStroke: "Letter đ",
      removeMark: "Remove mark",
    },
    vniTitle: "VNI: digits are marks",
    vniCaption: "6 adds the circumflex, 5 the dot below.",
    doubleTitle: "Type twice to keep the digit",
    doubleCaption: "Type a digit twice to drop the mark and keep the digit.",
    standaloneTitle: "Standalone numbers",
    standaloneCaption: "Digits typed before any letter stay as they are.",
  },
  privacy: {
    eyebrow: "Privacy",
    title: "What you type stays on your Mac",
    lead: "Dấu never sends what you type anywhere. macOS blocks the part of Dấu that reads your keys from the internet entirely.",
    inputMethodTitle: "The part that reads your keys",
    inputMethodSubtitle: "runs whenever you type",
    inputMethodNetwork:
      "macOS blocks it from the internet, so it cannot send what you type anywhere.",
    inputMethodSandbox: "It runs in a macOS sandbox.",
    inputMethodLog:
      "The downloadable build keeps no record of what you type, in which app, or when.",
    link: "The two parts share only settings, such as Telex or VNI, never what you type",
    appTitle: "The Dấu app",
    appSubtitle: "the settings window",
    appNetwork:
      "Goes online only to check for and download updates. The list of compatible apps comes with the install; the list isn’t downloaded separately.",
    appReports:
      "Report a Problem opens a prefilled GitHub page. You review it and send it yourself.",
    appTelemetry: "Dấu collects no usage data.",
    sourceLead: "Open source.",
    sourceText:
      " Anyone can read all of the code on GitHub (GPLv3 license) and build it themselves.",
    countsLead: "This site only counts visits and button clicks.",
    countsText:
      " No cookies, nothing that identifies you. The counts are kept at Vercel, which hosts the site.",
  },
  measured: {
    eyebrow: "Measured",
    title: "Numbers, not promises.",
    lead: "Engine tests run on every commit. Before each release, Dấu also runs a typing test under heavy load in Safari, Chrome, and VS Code. Every number below lists how it was measured.",
    appCountText: "apps tested, including where Dấu still fails.",
    appCountLink: "See the Compatibility List",
    otherLabel: "Other measurements",
    casesPlaceholder: "[case count]",
    casesText: "engine test cases, rerun on every commit.",
    casesNote: "Telex, VNI, and Simple Telex.",
    p99Text:
      "is the p99 time to handle a key that replaces text, under heavy load. Limit: {limit} ms.",
    p99Note: "{build} build, 20 keys/s, {machine}, {date}.",
    gate: "A build over the limit here or for memory isn’t released.",
    rssText: "is input method memory under heavy load. Limit: {limit} MB.",
    rssNote: "Heavy-load test, {build} build, {machine}, {date}.",
    machine: "{chip} Mac, macOS {macOS}",
  },
  faq: {
    eyebrow: "FAQ",
    title: "Common questions",
    free: {
      q: "Is Dấu free?",
      a: "Yes. It’s completely free and open source under the GPLv3 license. There’s no paid version and no ads.",
    },
    data: {
      q: "Does Dấu collect what I type?",
      a: "No. The input method can’t access the network, so it can’t send anything out. Dấu sends no usage data; you send problem reports yourself.",
    },
    permissions: {
      q: "Does it need permissions?",
      a: "No Accessibility access needed. The first time you turn Dấu on, macOS may ask “Allow “Dấu” to enable “Dấu”?”, since an input method receives every key you type. Click Allow.",
    },
    builtIn: {
      q: "How does it differ from the built-in Vietnamese input?",
      aBefore:
        "The built-in one underlines the word you’re typing; Dấu changes letters in place, as shown in ",
      aLink: "Three ways to type Vietnamese",
      aAfter: ".",
      verified: "Verified correct in {apps} (macOS {macOS}).",
    },
    switching: {
      q: "I use another input method. How do I switch?",
      a: "When you first open Dấu, it finds an old input method still running and shows how to turn it off, since two running at once garble text.",
    },
    skipped: {
      q: "Why no macros, auto-capitalization, or encoding conversion?",
      intro:
        "Dấu deliberately skips what macOS already does and what makes an input method more complex. If you used these elsewhere:",
      items: [
        { term: "Macros:", text: "use Text Replacements… in System Settings › Keyboard." },
        {
          term: "Auto-capitalization:",
          text: "turn on Capitalize words automatically in macOS.",
        },
        {
          term: "Switching Vietnamese/English per app:",
          text: "turn on Automatically switch to a document’s input source, and each window remembers its own input source.",
        },
        { term: "Legacy encodings, converters:", text: "Dấu outputs standard Unicode only." },
        {
          term: "Custom switch key, custom icon, switch sounds:",
          text: "Dấu uses the macOS input source shortcut and icon.",
        },
        { term: "Typing statistics:", text: "Dấu doesn’t record what you type." },
      ],
    },
    vni: {
      q: "In VNI, why do digits turn into marks?",
      a: "In VNI, a digit typed right after a Vietnamese syllable is a mark key: {markKeys} gives {mark}. To keep the digit, type it twice: {digitKeys} gives {digit}. Standalone numbers, like {standalone}, stay as they are.",
    },
    cannotChoose: {
      q: "An app won’t let you choose Dấu?",
      a: "That app may still have an old list of input sources from before Dấu was installed. Log out (Apple menu › Log Out) and log back in once: when apps open again, each one reads the list again. Just quitting and reopening the app isn’t enough.",
    },
    uninstall: {
      q: "How do I uninstall Dấu?",
      a: "Open Dấu, go to Updates & Support, and click Uninstall…. Dấu opens the Input Sources list in System Settings for you: select “Dấu – Vietnamese” and click “–”. Once Dấu is off the list, Dấu moves the input method and then the app itself to the Trash, and quits. If you don’t click “–”, nothing is removed.",
    },
  },
  download: {
    name: "Dấu {version}",
    versionPlaceholder: "[version]",
    datePlaceholder: "[release date]",
    sizePlaceholder: "[size]",
    sizeValue: "{size} MB",
    requirements:
      "macOS 14 or later, tested on macOS 27 (Apple silicon) and macOS 15 (Intel) · [signing, notarization, how updates work — fill in at M7]",
    dmg: "Download (.dmg)",
    history: "Version History",
    homebrewTitle: "Or install with Homebrew",
    homebrewCopy: "Copy",
    homebrewCopyLabel: "Copy Homebrew command",
    homebrewCopied: "Homebrew command copied",
    checksum: "SHA-256: {checksum}",
    checksumPlaceholder: "[checksum]",
    verifiableTitle: "A download you can verify",
    verifiableText:
      "[Built automatically from public source, signed, notarized, provenance attestation — fill in at M7]",
    otherDeviceBefore: "On an iPhone or a Windows PC? Dấu runs only on Mac. ",
    otherDeviceLink: "Copy the link",
    otherDeviceAfter: " to open it on your Mac.",
  },
  contribute: {
    eyebrow: "Contribute",
    title: "Help make Dấu better.",
    lead: "Dấu is open source and completely free. If Dấu helps you, you can pitch in however suits you. None of it is required.",
    handTitle: "Lend a hand",
    reportTitle: "Report a problem",
    reportText:
      "Wrong letters in an app, or a word Dấu got wrong? Open Dấu › Updates & Support › Report a Problem…. Each report makes Dấu more accurate for everyone.",
    betaTitle: "Try the beta",
    betaText:
      "Choose the Beta channel in Updates & Support to get new builds sooner and tell us what you find.",
    codeTitle: "Contribute code",
    codeText:
      "Dấu’s source code is on GitHub under the GPLv3 license. You can read it, give feedback, and send changes.",
    shareTitle: "Tell people you know",
    shareText: "Share this page with friends and colleagues, or star Dấu on GitHub.",
    donateEyebrow: "Donate",
    donateTitle: "Buy the Dấu team a coffee",
    donateText:
      "Dấu stays completely free whether you donate or not. The end of this section shows what donations have paid for.",
    vietQRAlt: "VietQR code for a bank transfer",
    vietQRTitle: "Bank transfer in Vietnam",
    vietQRRecipient: "Recipient",
    vietQRBank: "Bank",
    vietQRNote:
      "Scan the code with a Vietnamese banking app. To be named under Thanks, put the name you want shown in the transfer message.",
    vietQRDownload: "Download the QR image",
    sponsorsButton: "Donate via GitHub Sponsors",
    sponsorsNote: "GitHub Sponsors accepts international cards or PayPal.",
    thanksTitle: "Thank you",
    thanksText:
      "Thanks to everyone who reported problems, contributed code, or donated. Supporters’ names also appear in the Dấu app under Updates & Support, and in the notes of the releases they helped make.",
    supportersLabel: "Supporters",
    consent:
      "Dấu lists your name only if you agree. Sponsoring publicly on GitHub Sponsors counts as agreeing. For a VietQR transfer, put the name you want shown in the transfer message; Dấu never shows the name on the account that sent the money. Dấu shows no amounts and no rankings.",
    expensesTitle: "What donations have paid for",
    expensesText: "This lists only money actually spent.",
    expensesDate: "Date",
    expensesItem: "Expense",
    expensesAmount: "Amount",
  },
  footer: {
    tagline: "Vietnamese input method for macOS. Open source, GPLv3.",
    label: "Footer links",
    source: "Source Code",
    issues: "Report a Problem",
    history: "Version History",
    uninstall: "Uninstall Guide",
    donate: "Donate",
  },
  notFound: {
    title: "Page not found",
    text: "There’s no page at this address.",
    home: "Go to the Dấu home page",
  },
} satisfies Messages;
