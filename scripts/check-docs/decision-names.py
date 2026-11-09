"""Check 3b of scripts/check-docs/check.sh: the first citation of each principle or decision
in a document carries its name, as written in docs/DECISIONS.md.

    python3 -I decision-names.py FILE...

DECISIONS.md defines names as "- **D4. Từ nước ngoài.**". In any other document, the first
time "D4" appears it must read "D4 (Từ nước ngoài)", so a reader knows what D4 is without
opening DECISIONS.md; later citations in the same file may be bare. Text inside backticks
is skipped (code, paths), and so are ranges ("N1–N5", "D1–D…"). Prints one line per problem: FILE<TAB>number<TAB>what it found.
"""

import pathlib
import re
import sys

DEF = re.compile(r"^- \*\*([DN]\d+)\. (.+?)\.\*\*", re.M)
CITE = re.compile(r"(?<![\w/.\-–])([DN]\d{1,2})(?![\w–])")
CODE = re.compile(r"`[^`\n]*`")


def names():
    text = pathlib.Path("docs/DECISIONS.md").read_text(encoding="utf-8")
    return {m.group(1): m.group(2) for m in DEF.finditer(text)}


def main():
    known = names()
    for path in sys.argv[1:]:
        text = pathlib.Path(path).read_text(encoding="utf-8")
        # Blank out code spans, keeping offsets.
        text = CODE.sub(lambda m: " " * len(m.group(0)), text)
        seen = set()
        for m in CITE.finditer(text):
            num = m.group(1)
            if num in seen or num not in known:
                continue
            seen.add(num)
            expected = f" ({known[num]})"
            after = text[m.end():m.end() + len(expected)]
            if after != expected:
                snippet = text[m.start():m.end() + 40].split("\n")[0]
                print(f"{path}\t{num}\t{snippet}")


if __name__ == "__main__":
    main()
