"""Check 10 of scripts/check-docs/check.sh: every option a document cites for a script
exists in that script.

    python3 -I script-flags.py FILE...

Looks at code spans (text in backticks) that name a script, by path ("scripts/dev/x.sh")
or by file name alone ("x.sh", when only one script has that name), and at every option in
the same span ("--release", "--keys=…"). The option must appear in the script's own text
(its usage header or its argument parsing). Prints one line per problem:
FILE<TAB>script<TAB>option.
"""

import pathlib
import re
import sys

SPAN = re.compile(r"`([^`\n]+)`")
SCRIPT = re.compile(r"(?:^|[\s/])((?:scripts/)?[\w./-]*?([\w-]+\.sh))(?=\s|$)")
OPTION = re.compile(r"(?<![\w-])(--[a-z][a-z0-9-]*)")


def scripts():
    by_path = {str(p): p for p in pathlib.Path("scripts").rglob("*.sh") if ".build" not in p.parts}
    by_path[".claude/hooks/guard-scripts.sh"] = pathlib.Path(".claude/hooks/guard-scripts.sh")
    by_name = {}
    for path, p in by_path.items():
        by_name.setdefault(p.name, []).append(p)
    return by_path, by_name


def main():
    by_path, by_name = scripts()
    texts = {}
    for doc in sys.argv[1:]:
        for span in SPAN.findall(pathlib.Path(doc).read_text(encoding="utf-8")):
            m = SCRIPT.search(span)
            if not m:
                continue
            cited, name = m.group(1), m.group(2)
            target = by_path.get(cited.lstrip("./"))
            if target is None:
                found = by_name.get(name, [])
                if len(found) != 1:
                    continue  # unknown or ambiguous: check 1 reports missing paths
                target = found[0]
            if target not in texts:
                texts[target] = target.read_text(encoding="utf-8")
            for option in OPTION.findall(span[m.end():]):
                if option not in texts[target]:
                    print(f"{doc}\t{target}\t{option}")


if __name__ == "__main__":
    main()
