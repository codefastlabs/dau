import { Section, SectionHeading } from "#components/SectionHeading";
import { typingExample } from "#data/Examples";
import type { Messages } from "#i18n/vi";
import { Vni } from "#models/Vni";
import type { SectionProps } from "#sections/Context";

type RowName = keyof Messages["typingTable"]["rows"];

// Each row's result and keys come from TypingExamples.json; some rows group several examples
// (â ê ô, ơ ư). A row shows either the whole key sequence (aa, dd) or only the mark key typed
// after the vowel (s, 1).
type Shown = "whole" | "markKey";
interface Row {
  name: RowName;
  telex: string[];
  telexShown: Shown;
  vni: string[];
}

const rows: Row[] = [
  { name: "sac", telex: ["table-telex-sac"], telexShown: "markKey", vni: ["table-vni-sac"] },
  { name: "huyen", telex: ["table-telex-huyen"], telexShown: "markKey", vni: ["table-vni-huyen"] },
  { name: "hoi", telex: ["table-telex-hoi"], telexShown: "markKey", vni: ["table-vni-hoi"] },
  { name: "nga", telex: ["table-telex-nga"], telexShown: "markKey", vni: ["table-vni-nga"] },
  { name: "nang", telex: ["table-telex-nang"], telexShown: "markKey", vni: ["table-vni-nang"] },
  {
    name: "circumflex",
    telex: ["table-telex-circumflex-a", "table-telex-circumflex-e", "table-telex-circumflex-o"],
    telexShown: "whole",
    vni: ["table-vni-circumflex"],
  },
  { name: "breve", telex: ["table-telex-breve"], telexShown: "whole", vni: ["table-vni-breve"] },
  {
    name: "horn",
    telex: ["table-telex-horn-o", "table-telex-horn-u"],
    telexShown: "whole",
    vni: ["table-vni-horn-o", "table-vni-horn-u"],
  },
  { name: "wAlone", telex: ["table-telex-w-alone"], telexShown: "whole", vni: [] },
  {
    name: "dStroke",
    telex: ["table-telex-d-stroke"],
    telexShown: "whole",
    vni: ["table-vni-d-stroke"],
  },
  {
    name: "removeMark",
    telex: ["table-telex-remove-mark"],
    telexShown: "markKey",
    vni: ["table-vni-remove-mark"],
  },
];

const markKey = (keys: string) => keys.slice(-1);

function telexKeys(row: Row): string {
  return row.telex
    .map((id) => typingExample(id).keys)
    .map((keys) => (row.telexShown === "whole" ? keys : markKey(keys)))
    .join(" ");
}

/** VNI marks are digits; letters sharing one (ơ ư both 7) show it once. */
function vniKeys(row: Row): string {
  if (row.vni.length === 0) return "—";
  return [...new Set(row.vni.map((id) => markKey(typingExample(id).keys)))].join(" ");
}

function rowResult(row: Row): string {
  return row.telex.map((id) => typingExample(id).expected).join(" ");
}

const cell = "border-t border-black/7 px-4 py-3";

/** 5. Telex and VNI chart, a real table; the Name column hides on phones. */
export function TypingTable({ messages }: SectionProps) {
  const t = messages.typingTable;
  return (
    <Section id="typing-table" className="bg-mist">
      <SectionHeading eyebrow={t.eyebrow} title={t.title} lead={t.lead} leadWidth="max-w-[680px]" />
      <div className="grid grid-cols-1 items-start gap-5 min-[901px]:grid-cols-[minmax(0,1.35fr)_minmax(0,1fr)]">
        <div className="overflow-x-auto rounded-3xl border border-ink/8 bg-white">
          <table className="w-full border-collapse text-left text-base text-charcoal">
            <caption className="sr-only">{t.caption}</caption>
            <thead>
              <tr>
                <th scope="col" className="px-4 py-3.5 text-[13px] text-muted">
                  {t.result}
                </th>
                <th scope="col" className="px-4 py-3.5 text-[13px] text-muted max-[640px]:hidden">
                  {t.name}
                </th>
                <th scope="col" className="px-4 py-3.5 text-[13px] text-muted">
                  {t.telex}
                </th>
                <th scope="col" className="px-4 py-3.5 text-[13px] text-muted">
                  {t.vni}
                </th>
              </tr>
            </thead>
            <tbody>
              {rows.map((row) => (
                <tr key={row.name}>
                  <td className={`${cell} text-xl font-bold`}>{rowResult(row)}</td>
                  <td className={`${cell} text-slate max-[640px]:hidden`}>{t.rows[row.name]}</td>
                  <td className={`${cell} font-mono`}>{telexKeys(row)}</td>
                  <td className={`${cell} font-mono`}>{vniKeys(row)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <Vni messages={messages} />
      </div>
    </Section>
  );
}
