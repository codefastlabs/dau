"""Tiny reader for Rust/Swift/Go source text: string literals, brace matching, test fns.
Only parses text; never runs anything."""
import re

STR_RE = re.compile(r'r(#*)"(.*?)"\1|"((?:[^"\\]|\\.)*)"', re.S)


def unescape(body):
    out, i = [], 0
    while i < len(body):
        c = body[i]
        if c == "\\" and i + 1 < len(body):
            n = body[i + 1]
            if n == "n": out.append("\n"); i += 2; continue
            if n == "t": out.append("\t"); i += 2; continue
            if n == "r": out.append("\r"); i += 2; continue
            if n == "0": out.append("\0"); i += 2; continue
            if n in "\\\"'": out.append(n); i += 2; continue
            if n == "x":
                out.append(chr(int(body[i + 2:i + 4], 16))); i += 4; continue
            if n == "u" and body[i + 2] == "{":
                j = body.index("}", i)
                out.append(chr(int(body[i + 3:j], 16))); i = j + 1; continue
            if n == "\n":  # line continuation
                i += 2
                while i < len(body) and body[i] in " \t\n": i += 1
                continue
            raise ValueError("escape " + body[i:i + 4])
        out.append(c); i += 1
    return "".join(out)


def lit_at(text, pos):
    """If a string literal starts at pos, return (value, end)."""
    m = STR_RE.match(text, pos)
    if not m:
        return None
    if m.group(3) is not None:
        return unescape(m.group(3)), m.end()
    return m.group(2), m.end()


def strip_comments(text):
    """Blank out // and /* */ comments, keeping string literals and offsets."""
    out = list(text)
    i, n = 0, len(text)
    while i < n:
        c = text[i]
        if c == '"' or (c == "r" and i + 1 < n and text[i + 1] in '"#' and (i == 0 or not (text[i - 1].isalnum() or text[i - 1] == "_"))):
            m = STR_RE.match(text, i)
            if m:
                i = m.end(); continue
        if c == "'":
            m = re.match(r"'(?:\\.|\\u\{[0-9a-fA-F]+\}|[^'\\])'", text[i:i + 12])
            if m:
                i += m.end(); continue
        if text.startswith("//", i):
            j = text.find("\n", i)
            j = n if j < 0 else j
            for k in range(i, j): out[k] = " "
            i = j; continue
        if text.startswith("/*", i):
            j = text.find("*/", i)
            j = n if j < 0 else j + 2
            for k in range(i, j):
                if out[k] != "\n": out[k] = " "
            i = j; continue
        i += 1
    return "".join(out)


def match_close(text, pos, open_ch="{", close_ch="}"):
    """pos at an opening bracket; return index after its match. Text must be comment-free."""
    depth, i, n = 0, pos, len(text)
    while i < n:
        c = text[i]
        if c == '"' or (c == "r" and text[i + 1:i + 2] in ('"', "#")):
            m = STR_RE.match(text, i)
            if m:
                i = m.end(); continue
        if c == "'":
            m = re.match(r"'(?:\\.|\\u\{[0-9a-fA-F]+\}|[^'\\])'", text[i:i + 12])
            if m:
                i += m.end(); continue
        if c == open_ch: depth += 1
        elif c == close_ch:
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    raise ValueError("unbalanced")


def literals(text):
    """All string literals in text, in order."""
    res, i = [], 0
    while True:
        m = STR_RE.search(text, i)
        if not m:
            return res
        res.append((unescape(m.group(3)) if m.group(3) is not None else m.group(2), m.start()))
        i = m.end()


PAIR_RE = re.compile(r'\(\s*(r#*"|")')


def pairs(text):
    """All ("a", "b"[, ...]) tuples of string literals in text (first two literals of each tuple)."""
    res = []
    for m in re.finditer(r'\(\s*(?=r#*"|")', text):
        a = lit_at(text, m.end())
        if not a:
            continue
        j = a[1]
        mm = re.match(r'\s*,\s*', text[j:])
        if not mm:
            continue
        b = lit_at(text, j + mm.end())
        if not b:
            continue
        k = b[1]
        tail = re.match(r'\s*[,)]', text[k:])
        if not tail:
            continue
        res.append((a[0], b[0], m.start()))
    return res
