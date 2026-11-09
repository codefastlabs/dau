"""Builds the typing cases for scripts/research/compare-ims/run.sh and scores the result.

    python3 -I cases.py keys            prints the Telex keys of every case, one line
    python3 -I cases.py expect          prints the text the keys must give, one line
    python3 -I cases.py score FILE...   scores the text read back from each run

Cases: vi-sentences.txt (group "vi"), mixed-sentences.txt ("mixed"), en-words.txt ("en").
Vietnamese letters become standard-order Telex: aa ee oo aw ow uw dd for the letters,
the tone key (s f r x j) at the end of the word, modifier keys in lower case after a
capital ("Đ" → "Dd"). ASCII tokens are typed as they are. Tokens are separated by one
space and the line ends with a space, so every word is ended.

Scoring compares token by token after NFC and after moving the tone mark out of the
word, so old and new tone placement ("hòa", "hoà") both count as right. That also hides
a tone placed on the wrong vowel: it is a limit of this comparison, not a finding.
"""

import difflib
import pathlib
import sys
import unicodedata

HERE = pathlib.Path(__file__).resolve().parent
GROUPS = [("vi", "vi-sentences.txt"), ("mixed", "mixed-sentences.txt"), ("en", "en-words.txt")]
TONES = {"́": "s", "̀": "f", "̉": "r", "̃": "x", "̣": "j"}
PUNCT = ".,?!:;"


def tokens():
    seen = set()
    out = []
    for group, name in GROUPS:
        for line in (HERE / name).read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            words = line.split()
            if group == "en":
                if line in seen:
                    continue
                seen.add(line)
            for w in words:
                out.append((group, unicodedata.normalize("NFC", w)))
    return out


def telex_word(word):
    if word.isascii():
        return word
    core = word.rstrip(PUNCT)
    tail = word[len(core):]
    keys = []
    tone = ""
    for ch in core:
        if ch in "đĐ":
            keys.append("Dd" if ch == "Đ" else "dd")
            continue
        parts = unicodedata.normalize("NFD", ch)
        base, marks = parts[0], parts[1:]
        keys.append(base)
        for m in marks:
            if m in TONES:
                tone = TONES[m]
            elif m == "̂":
                keys.append(base.lower())
            elif m in ("̆", "̛"):
                keys.append("w")
            else:
                raise SystemExit(f"Không chuyển được dấu U+{ord(m):04X} trong \"{word}\"")
    return "".join(keys) + tone + tail


def canon(token):
    """NFC token with the tone mark taken out and appended, so tone placement is ignored."""
    tone = ""
    kept = []
    for ch in unicodedata.normalize("NFD", token):
        if ch in TONES:
            tone = TONES[ch]
        else:
            kept.append(ch)
    return unicodedata.normalize("NFC", "".join(kept)) + ("/" + tone if tone else "")


def score(paths):
    cases = tokens()
    expected = [canon(t) for _, t in cases]
    for path in paths:
        got_raw = pathlib.Path(path).read_text(encoding="utf-8").split()
        got = [canon(t) for t in got_raw]
        right = {g: 0 for g, _ in GROUPS}
        total = {g: 0 for g, _ in GROUPS}
        wrong = []
        matcher = difflib.SequenceMatcher(a=expected, b=got, autojunk=False)
        ok_index = set()
        for block in matcher.get_matching_blocks():
            ok_index.update(range(block.a, block.a + block.size))
        # Pair the non-matching expected tokens with what stands in their place.
        for tag, i1, i2, j1, j2 in matcher.get_opcodes():
            if tag == "equal":
                continue
            for k in range(i1, i2):
                j = j1 + (k - i1)
                wrong.append((cases[k][0], cases[k][1], got_raw[j] if j < j2 else "∅"))
        for k, (g, _) in enumerate(cases):
            total[g] += 1
            right[g] += k in ok_index
        p = pathlib.Path(path)
        print(f"## {p.parent.name}/{p.name}")
        print("| Nhóm | Đúng | Tổng | Tỉ lệ |")
        print("|---|---|---|---|")
        for g, _ in GROUPS:
            pct = 100 * right[g] / total[g] if total[g] else 0
            print(f"| {g} | {right[g]} | {total[g]} | {pct:.1f}% |")
        if len(got_raw) != len(cases):
            print(f"(số từ đọc lại {len(got_raw)}, mong đợi {len(cases)})")
        print("\nSai (nhóm, mong đợi, ra):")
        for g, e, o in wrong:
            print(f"{g}\t{e}\t{o}")
        print()


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "keys":
        print(" ".join(telex_word(t) for _, t in tokens()) + " ")
    elif cmd == "expect":
        print(" ".join(t for _, t in tokens()) + " ")
    elif cmd == "score" and len(sys.argv) > 2:
        score(sys.argv[2:])
    else:
        print(__doc__)
        sys.exit(2)


if __name__ == "__main__":
    main()
