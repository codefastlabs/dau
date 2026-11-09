"""Reads the design canvas layout (canvas.json) for scripts/design/render-canvas.sh.

    python3 -I canvas-index.py boards canvas.json   name<TAB>width<TAB>height, design page only
    python3 -I canvas-index.py readme canvas.json   docs/ui/canvas/README.md (index by section)

Boards on the archive page ("page": "archive") are left out. Order: the canvas order.
A board's section is the part of its title before " – " ("Cài đặt – bản tối" → "Cài đặt").
"""

import json
import sys


def design_boards(path):
    data = json.load(open(path, encoding="utf-8"))
    boards = data["boards"]
    for name in data["order"]:
        board = boards[name]
        if board.get("page") != "archive":
            yield name, board


def main():
    cmd, path = sys.argv[1], sys.argv[2]
    if cmd == "boards":
        for name, b in design_boards(path):
            print(f"{name}\t{b['w']}\t{b['h']}")
    elif cmd == "readme":
        sections = {}
        for name, b in design_boards(path):
            title = b["title"]
            section = title.split(" – ", 1)[0] if " – " in title else "Khác"
            sections.setdefault(section, []).append((title, name.removesuffix(".dc.html")))
        print("# Bản chụp canvas thiết kế\n")
        print("Ảnh chụp các artboard trên trang \"Thiết kế\" của canvas mockup, để xem thiết kế đã duyệt mà "
              "không cần mở canvas trên claude.ai. Canvas vẫn là nơi sửa thiết kế (CLAUDE.md, mục Điều phối); "
              "thư mục này chỉ là bản chụp, sinh bằng `scripts/design/render-canvas.sh`, không sửa tay.\n")
        print("- `*.png`: ảnh chụp từng artboard.")
        print("- `src/*.dc.html`: nguồn của artboard (nội dung, câu chữ chính xác); agent đọc file này thay cho canvas.")
        print("- `canvas.json`: vị trí, kích thước và tiêu đề các artboard.\n")
        for section, items in sections.items():
            print(f"## {section}\n")
            for title, stem in items:
                print(f"- [{title}]({stem}.png) · [nguồn](src/{stem}.dc.html)")
            print()
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
