# Đầu vào test lấy từ bộ gõ khác (bước 1: thu thập)

Ghi công nguồn và giấy phép: `docs/research/external-test-inputs/NOTICE.md`.

Mục đích: lấy **chuỗi phím** trong bộ test của các bộ gõ tiếng Việt khác để engine của Dấu được thử trên những ca người khác thấy đáng test. Dấu tự viết kết quả mong đợi theo chính tả tiếng Việt và `docs/DECISIONS.md` mà **không nhìn** đáp án của họ; chỉ sau đó mới so với đáp án của họ để tìm ca đáng xem lại (người dùng duyệt cách làm này ngày 05/11/2026). File này là bước 1: tìm nguồn, kiểm giấy phép, trích chuỗi phím, để riêng đáp án của họ. Không có kết quả mong đợi nào của dự án khác trong file này hay trong `docs/research/external-test-inputs/`.

## Hiện trạng (05/11/2026)

- **Bước 1 xong.** Giữ 10 nguồn, tổng **10.320 ca**: Telex 8.239, VNI 2.028, Telex đơn giản 53. Mỗi nguồn một file TSV trong `docs/research/external-test-inputs/`; đáp án của họ nằm riêng ở `build/external-answers/` (thư mục bị git bỏ qua, xem mục 3).
- **Bỏ:** ibus-unikey, OpenKey, fcitx5-bamboo (không có bộ test chuỗi phím); bộ ca CSV của XKey (8.046 dòng, chính tác giả ghi là do một engine khác sinh ra, không nêu engine nào và giấy phép gì). Mọi nguồn giữ lại có giấy phép tương thích GPLv3 (mục 4).
- **Chưa làm:** bước 2 (engine-dev viết đáp án mù cho các ca này), bước 3 (so với đáp án của họ). Chưa chạy gì từ các bản clone: chỉ đọc file.
- **Đếm sơ bộ trên đáp án của họ** (chỉ đếm, không trích; mục 6): chỉ 8 ca đặt dấu thanh vào chữ mà cả kiểu cũ lẫn kiểu mới đều không cho, đều là trường hợp khó phân định; không có huyền/hỏi/ngã trên vần tắc; nhưng có nhiều ca mà khi kết thúc từ, đáp án của họ vẫn giữ một từ có dấu không phải âm tiết hợp lệ theo D31 — phần lớn do cấu hình test của họ (tắt kiểm tra chính tả, từ điển riêng).
- **Người dùng chốt (05/11/2026):** (1) ghi công nguồn trong `docs/research/external-test-inputs/NOTICE.md` (tên, URL, commit, SPDX, dòng bản quyền nguyên văn, toàn văn giấy phép MIT/BSD-3-Clause); (2) giữ ibus-telex dù repo không có file LICENSE, ghi chú rằng giấy phép chỉ được khai trong `Cargo.toml`; (3) chưa trích các kho lớn sinh máy móc, để làm sau (mục 7); (4) script trích nằm ở `scripts/research/external-tests/extract.sh`, ghim commit của từng nguồn và tạo lại đúng từng byte các TSV đã commit (đã kiểm 05/11/2026 bằng `cmp` trên bản clone mới).
- Không có khẳng định nào về API Apple trong file này.

## 1. Quy trình mù

1. Engine-dev chỉ đọc `docs/research/external-test-inputs/*.tsv` và file này, viết kết quả mong đợi theo chính tả tiếng Việt và `docs/DECISIONS.md` (D10: không lấy kết quả của bộ gõ khác làm đáp án).
2. Chạy engine của Dấu trên các ca đó; ca nào Dấu khác đáp án của chính Dấu là lỗi của Dấu.
3. Chỉ sau bước 2, người so sánh mới mở `build/external-answers/` và đánh dấu các ca Dấu khác họ. Mỗi ca khác nhau được xét theo DECISIONS.md: hoặc Dấu cố ý khác (ghi vào `docs/OPENKEY-NOTES.md` hoặc ghi chú test), hoặc đáp án của Dấu sai, hoặc cần quyết định mới (hỏi người dùng). Đáp án của họ không bao giờ được chép thẳng vào test.

Lưu ý: engine của XKey ghi trong mã là bản chuyển trực tiếp từ engine OpenKey (`XKey/Core/Engine/VNEngine.swift` của họ), nên đáp án của XKey gần với hành vi OpenKey; theo D10 nó chỉ được dùng để tìm ca đáng xem lại, như mọi nguồn khác.

## 2. Ký hiệu

### 2.1 Cột `keys`

Mỗi ký tự là một phím gửi vào engine theo thứ tự, như `Typist.type` trong test của Dấu. Chữ hoa là phím chữ có Shift (hoặc Caps Lock). Ký hiệu thêm:

| Ký hiệu | Nghĩa |
|---|---|
| `␣` | phím Space |
| `⏎` | Return |
| `⇥` | Tab |
| `⌫` | Backspace |
| `←` | sự kiện chỉ reset bộ đệm, không khôi phục (D4): phím mũi tên, Home/End, tổ hợp có ⌃/⌘, `clear()`/`reset()` của engine họ (thường mô phỏng đổi ô nhập hoặc chọn hết) |
| `⎋` | Esc (với Dấu: chỉ reset, D4) |
| `⟦chữ⟧` ở đầu chuỗi | chữ đã có sẵn trước con trỏ, engine được nạp từ chữ đó (D20, `Typist.seed`); các phím sau đó gõ tiếp |
| `⟦trước|sau⟧` | như trên, `|` là vị trí con trỏ; phần sau con trỏ nằm trong ô nhưng D20 không đọc |
| chữ tiếng Việt dựng sẵn ngoài `⟦⟧` (7 ca) | ký tự đó tới engine như một phím (bố cục bàn phím khác, nhập kiểu dán); Dấu chưa có quyết định cho trường hợp này |

Các phím khác (chữ số, dấu câu, `ß`…) là chính ký tự đó. Không có ca nào chứa ký tự tab hay xuống dòng thật trong TSV.

### 2.2 Cột `options`

Các mục cách nhau bằng `;`. Rỗng nghĩa là mặc định của Dấu (D15: Telex, đặt dấu kiểu mới, bỏ dấu tự do bật, tự khôi phục bật, Nâng cao tắt). Cột `method` ghi kiểu gõ: `telex`, `vni`, `simple-telex` (Telex đơn giản, D29).

| Mục | Cài đặt của Dấu |
|---|---|
| `tone=classic` | đặt dấu kiểu cũ (hòa, thúy) — `EngineOptions.tonePlacement = .classic` |
| `freeMarking=off` | tắt bỏ dấu tự do (D28) |
| `autoRestore=off` | tắt "Tự khôi phục từ không phải tiếng Việt" (D4, D30) |
| `advanced=consonantShortcuts` | gõ tắt phụ âm (D21) |
| `advanced=allowZFWJ` | cho phép z, f, w, j (D22) |

Mục bắt đầu bằng `src:` là **tuỳ chọn của nguồn mà Dấu không có**; ca vẫn chạy với cài đặt Dấu gần nhất, nhưng khi so đáp án phải nhớ rằng họ test trong điều kiện khác:

| Mục | Nghĩa ở nguồn | Ở Dấu |
|---|---|---|
| `src:spellcheck=off` | họ tắt kiểm tra chính tả | kiểm tra chính tả luôn chạy (D30) |
| `src:dictionary` | ibus-teni quyết định bằng từ điển từ (có cả viết tắt, từ mượn) | không dùng từ điển (D4, D31) |
| `src:englishDictionary` | khôi phục từ tiếng Anh dựa vào danh sách từ tiếng Anh (gonhanh "English auto-restore", uvie-rs "english override") | khôi phục theo luật âm tiết hợp lệ, không có từ điển tiếng Anh (D4) |
| `src:modifySurroundingText=off` | fcitx5-unikey đọc chữ xung quanh nhưng không được sửa nó | D20 sửa được chữ trước con trỏ |
| `src:relaxedCoda=on` | uvie-rs nới luật âm cuối | không có (D31) |
| `src:customConsonants=…` | XKey cho phép thêm phụ âm đầu (liệt kê chữ) | gần nhất là D22 (chỉ z, f, w, j). Với `K`: suy luận, cần kiểm chứng, là cho k đứng trước a, o, u; D31 đã nhận điều này nên Dấu không cần tuỳ chọn |

Cách quy đổi kiểu gõ của nguồn sang `method` nằm ở mục 5 của từng nguồn.

## 3. Bố cục file

- `docs/research/external-test-inputs/<nguồn>.tsv`: hàng tiêu đề rồi một ca mỗi hàng, cột `id`, `method`, `options`, `keys`, `source_ref`. `id` ổn định, dạng `file:tên test#thứ tự` (hoặc `file:dòng`), đủ để tìm lại ca trong repo của họ ở commit ghi ở mục 5. `source_ref` là đường dẫn file trong repo của họ. Không có cột đáp án.
- `build/external-answers/<nguồn>.tsv` (git bỏ qua, không commit): cột `id`, `their_expected`, `their_note`. `their_expected` dùng cùng ký hiệu `␣`/`⏎` như cột `keys`; để trống khi test của họ không kiểm chữ (chỉ kiểm cờ hợp lệ, số Backspace…). Cột thứ ba `their_note` (thêm so với yêu cầu ban đầu) ghi họ kiểm cái gì, ví dụ "chỉ từ đang gõ", "chỉ phần chữ do các phím cuối sinh ra", "khung test tự thêm một Space cuối". Thư mục này dựng lại được bằng cách trích lại từ đúng commit ở mục 5.
- Script trích: `scripts/research/external-tests/extract.sh` (lấy từng nguồn ở đúng commit ghi ở mục 5 vào `/tmp/ext-ime/`, rồi gọi các helper Python cùng thư mục bằng `python3 -I`; chỉ đọc file văn bản, không build, không chạy gì của các bản clone). Chạy lại thì ra đúng các TSV đã commit, cùng `build/external-answers/` và `build/external-tests-stats/` (số đếm, lý do bỏ; không có đáp án). Ghi công: `docs/research/external-test-inputs/NOTICE.md`.

Một số ca dùng chung một engine qua nhiều lời gọi trong cùng test của họ: khi đó `keys` là toàn bộ phím từ lúc tạo engine (hoặc từ lần `clear`/`reset` gần nhất) và `their_note` ghi rằng đáp án của họ chỉ phủ phần cuối. Một số ca là trạng thái giữa từ (họ kiểm chữ đang gõ, chưa có ranh giới từ); `keys` khi đó không kết thúc bằng `␣`/`⏎`, và đáp án của Dấu cũng là chữ hiển thị giữa từ (trước D4).

## 4. Giấy phép

Chuỗi phím là dữ liệu ngắn, gần như không có tính sáng tạo; dù vậy mọi nguồn đều được ghi công ở mục 5 và chỉ giữ nguồn có giấy phép tương thích GPLv3.

| Nguồn | SPDX | Dùng cho Dấu (GPLv3) |
|---|---|---|
| bamboo-core | MIT | được, giữ thông báo bản quyền |
| ibus-bamboo | GPL-3.0 (file LICENSE, không ghi "or later") | được, cùng GPLv3 |
| fcitx5-unikey (thư mục test) | GPL-2.0-or-later (SPDX trong file test) | được, nhờ "or later" |
| goxkey | BSD-3-Clause | được, giữ thông báo bản quyền |
| vi-rs | MIT | được |
| ibus-teni | GPL-3.0-or-later (thư mục test-data có LICENSE riêng) | được |
| uvie-rs | MIT OR Apache-2.0 | được (chọn MIT) |
| ibus-telex | GPL-3.0-or-later, chỉ khai trong `Cargo.toml`, repo không có file LICENSE | được; người dùng chốt giữ kèm ghi chú (05/11/2026) |
| gonhanh.org | BSD-3-Clause | được, giữ thông báo bản quyền |
| XKey | MIT (file LICENSE); engine ghi là chuyển từ OpenKey (GPL-3.0) | được ở cả hai trường hợp: MIT hay GPL-3.0 đều tương thích GPLv3 |

## 5. Từng nguồn

Số "ca" là số hàng trong TSV. "Bỏ" ghi đơn vị: ca (một chuỗi phím) hoặc test (một hàm test của họ).

### 5.1 bamboo-core (Go)

- https://github.com/BambooEngine/bamboo-core, commit `b2e49a2b48c7d3772a3673142a7747eccd9d5f79` (16/09/2024). MIT, © 2018 Luong Thanh Lam.
- File: `bamboo_test.go` (chép tay từng điểm kiểm; `rules_parser_test.go`, `utils_test.go` là test hàm nội bộ).
- 67 ca: Telex 66, VNI 1; 60 ca có đáp án chữ, 7 ca họ chỉ kiểm cờ hợp lệ.
- Cấu hình test của họ: kiểu "Telex 2" (Telex có `[ ]` và w đứng riêng thành ư) → `telex`; cờ `EstdFlags` = bỏ dấu tự do + `EstdToneStyle`. Đọc mã `findToneTarget`: `EstdToneStyle` đặt dấu "oa, oe, uy" không âm cuối ở nguyên âm đầu, tức kiểu cũ → `tone=classic`. Một test bỏ cờ đó → mặc định Dấu. Họ kiểm chữ của từ đang gõ (`GetProcessedString`), không có ranh giới từ.
- Ba ca bamboo đưa chữ dựng sẵn ("tôi", "tối", "chuyển") vào engine rồi gõ tiếp: ghi thành `⟦…⟧` (D20).
- Bỏ: 7 ca D27 (`[ ] { }` thành ơ ư); 4 ca gõ giữa từ bằng "EnglishMode" của họ (D2: Dấu không có chế độ Anh); 2 test lệnh "khôi phục từ vừa gõ" (Dấu không có lệnh này); 3 ca bố cục bàn phím "Microsoft layout" (TCVN, không có ở Dấu); 1 ca trùng; benchmark; 6 test hàm nội bộ.

### 5.2 ibus-bamboo (Go)

- https://github.com/BambooEngine/ibus-bamboo, commit `49e03d7a36b8a8b796950c158b545af8cf9707d4` (19/05/2026). GPL-3.0, © 2018 Luong Thanh Lam.
- File: `engine_test.go`, `tests/xtest.data` (14 câu dùng cho script gõ thử X11 của họ, không có đáp án).
- 32 ca, tất cả `simple-telex`, `tone=classic`; 15 ca có đáp án.
- Quy đổi: mặc định của họ là kiểu "Telex" của bamboo, trong đó w chỉ biến đổi u, o, a (không có w đứng riêng thành ư, không có `[ ]`) — đúng định nghĩa Telex đơn giản của Dấu (D29). Cờ mặc định giống bamboo-core (kiểu cũ).
- Bỏ: 12 test bật macro (D3); 8 test lặp lại chuỗi phím đã có (hai chế độ preedit/backspace của họ chạy cùng chuỗi); 6 test Ctrl+A hoặc sự kiện rỗng (không sinh chữ); 3 test emoji và hàm phụ.

### 5.3 fcitx5-unikey (C++, engine ukengine của UniKey)

- https://github.com/fcitx/fcitx5-unikey, commit `ed9170c35c1a6275d105e03d7f9bc4f674c1469c` (05/09/2026). Thư mục test GPL-2.0-or-later, © 2021 CSSlayer.
- File: `test/testunikey.cpp`.
- 1.325 ca, tất cả `telex`; 1.324 có đáp án. Gồm 1.307 mục đang chạy của bảng `expectedTelexData` (mỗi chuỗi phím rồi Return), 11 ca đầu `testBasic`, 6 ca dùng chữ xung quanh con trỏ (ghi thành `⟦…⟧`), 1 ca `testType` (không có đáp án).
- Cấu hình: Telex của UniKey (có `[ ]`, w đứng đầu từ thành ư) → `telex`; `ModernStyle` mặc định tắt → `tone=classic`. Bảng `expectedTelexData` chạy với `AutoNonVnRestore=False`, `SpellCheck=False` → `autoRestore=off;src:spellcheck=off`. Đáp án `testBasic` là hàng đợi chữ commit; ghép đáp án với nhóm phím theo thứ tự là cách đọc của người trích.
- Bỏ: 414 mục của bảng đang bị comment trong mã của họ (họ không chạy). Không có ca nào cần `[ ]`.

### 5.4 goxkey (Rust, macOS)

- https://github.com/huytd/goxkey, commit `b197c57218ceb9096c341a9862acfabf7cb6932b` (23/09/2026). BSD-3-Clause, © 2023 Huy Tran. Engine của goxkey là vi-rs (5.5).
- File: `src/main.rs` (test trong mã).
- 4 ca: Telex 3, VNI 1, đều có đáp án.
- Bỏ: 2 test gọi hàm quyết định khôi phục với một "chữ đã biến đổi" mà chuỗi phím không thể sinh ra; 1 test danh sách từ được phép của người dùng (D4: không có danh sách); 1 test kiểu gõ Telex+VNI gộp (không có ở Dấu); 76 test hàm nội bộ (`input.rs`, `hotkey.rs`, `scripting/parser.rs`).

### 5.5 vi-rs (Rust)

- https://github.com/zerox-dg/vi-rs, commit `192e246d37e83094a1228e798b160f3cee14c879` (22/06/2026). MIT, © 2020 Hung Nguyen.
- File: `testdata/input/simple_telex.txt`, `non_vietnamese_telex.txt`, `simple_vni.txt`, `non_vietnamese_vni.txt` (đáp án của họ: các file `.snap` trong `testdata/output/`), `tests/incremental.rs`.
- 182 ca: Telex 139, VNI 43; 170 có đáp án. Họ biến đổi **từng từ riêng** (không có ranh giới từ, không có khôi phục), nên mỗi từ trong file đầu vào là một ca, không có `␣`. Kiểu đặt dấu mặc định của họ là kiểu mới → mặc định Dấu; 1 ca kiểu cũ.
- Bỏ: `all_telex.txt` và `all_vni.txt` (mỗi file 24.226 dòng, sinh máy móc từ danh sách âm tiết) — kho lớn, không trích (mục 7); 20 test hàm nội bộ; 2 test không có chuỗi phím.

### 5.6 ibus-teni (Go)

- https://github.com/teni-ime/ibus-teni, commit `a3824854c0f5e85dcfea66d984b9bad0c16c2bf2` (10/04/2020). GPL-3.0-or-later, © 2018 Nguyen Cong Hoang.
- File: `test-data/*.tdata` (mỗi dòng: đáp án, dấu cách, chuỗi phím; chuỗi phím do `test-data/test-data-gen.go` của họ sinh từ từ điển trong `dict/`, theo ba thứ tự gõ telex1/2/3 và vni1/2/3), `src/teni/teni_coverage_test.go`.
- 3.050 ca: Telex 1.533, VNI 1.517; 3.049 có đáp án. Gồm các file `nodict`, `vietnamese.std.dict.*` (kiểu cũ → `tone=classic`), `vietnamese.new.dict.*` (kiểu mới → mặc định), `vietnamese.sp.dict.*` (từ đặc biệt: viết tắt, từ mượn có đ) và 4 ca của `teni_coverage_test.go`. Mọi ca mang `src:dictionary`: engine của họ quyết định bằng từ điển. Họ kiểm chữ giữa từ, không có ranh giới từ.
- Quy đổi: kiểu gõ "Teni" (Telex của họ) → `telex`; file `.telexw` (kiểu Telex có `[ ]`) chỉ giữ ca không có ngoặc.
- Bỏ: 11 ca D27; 1 dòng khung test của họ cũng bỏ qua; `vietnamese.cm.dict.*` (7 file, 47.767 dòng, sinh từ danh sách từ thông dụng) — kho lớn, không trích.

### 5.7 uvie-rs (Rust)

- https://github.com/uvie-project/uvie-rs, commit `555ef9dd31b6bf208343a70484e84db79f1bddfe` (21/10/2026). MIT OR Apache-2.0, © 2026 thuupx.
- File: `tests/*.rs` (trích tự động các mẫu `type_seq`, `type_seq_vni`, `type_diff`, hàm phụ hai tham số, vòng lặp trên mảng cặp, chuỗi gọi `type_chars`/`press_space`/`press_backspace` kèm kiểm `screen`).
- 961 ca: Telex 939, VNI 22; 934 có đáp án.
- Cấu hình: `set_modern_orthography` mặc định tắt → `tone=classic` khi test không bật; "english override" (từ điển tiếng Anh) mặc định bật → `src:englishDictionary`; `set_quick_start` → `advanced=consonantShortcuts`; `set_relaxed_coda` → `src:relaxedCoda=on`.
- Bỏ: 14 ca bật Quick Telex (cc → ch…, mục "Đã biết nhưng không làm" của DECISIONS.md); 3 test đọc file dữ liệu (`tests/data/`: 22k từ Việt, 100k từ Anh, cặp Telex — kho lớn); 74 test không trích được (bảng nội bộ, kích thước diff, lịch sử sửa từ trước, bất biến sinh ngẫu nhiên).

### 5.8 ibus-telex (Rust)

- https://github.com/manhavn/ibus-telex, commit `fb522b4804c2ef8496ec8746f7b1e4043b3716c2` (05/10/2026). GPL-3.0-or-later (khai trong `Cargo.toml`), tác giả commit Bùi Văn Mạnh.
- File: `tests/parity_corpus.tsv` (chuỗi phím và kết quả mà họ ghi là chụp từ ibus-unikey 0.7.0), `tests/typing.rs`.
- 323 ca: Telex 311, VNI 10, Telex đơn giản 2; tất cả có đáp án.
- Quy đổi: tuỳ chọn mặc định của họ (giống UniKey: kiểu cũ) → `tone=classic`; `standalone_w: false` → `simple-telex`; `free_marking: false` → `freeMarking=off`; `spell_check: false` → `src:spellcheck=off`. Khung `parity.rs` của họ gõ thêm một Space ở cuối rồi bỏ một dấu cách cuối khỏi kết quả: các ca corpus vì vậy kết thúc bằng `␣`, `their_note` ghi rõ.
- Bỏ: 9 ca D27; 2 test chỉ gọi API; `keys.rs` (phân loại mã phím) và `protocol.rs` (thử giao thức D-Bus với engine đang chạy).

### 5.9 gonhanh.org — Gõ Nhanh (Rust, macOS)

- https://github.com/khaphanspace/gonhanh.org, commit `1fdac7aec67663f2c23df6addfb13c59bbc5f374` (05/11/2026). BSD-3-Clause, © 2025 Gõ Nhanh Contributors.
- File: `core/tests/*.rs` (trích tự động: mảng hằng cặp phím/đáp án và các hàm chạy `telex`, `vni`, `telex_auto_restore`, `telex_traditional`, `vni_traditional`, hàm phụ trong từng file, vòng lặp trên mảng cặp, chuỗi `type_word` trên cùng engine, `restore_and_type` → `⟦…⟧`, và chuỗi mã phím `on_key` (chỉ lấy phím, không lấy đáp án)). Ký hiệu của họ: `<` là Backspace → `⌫`.
- 4.113 ca: Telex 3.683, VNI 411, Telex đơn giản 19; 3.992 có đáp án.
- Cấu hình: mặc định của họ là kiểu mới, "English auto-restore" tắt → `autoRestore=off`; bật → `src:englishDictionary` (họ dùng danh sách từ tiếng Anh); `set_modern_tone(false)` → `tone=classic`; `set_allow_foreign_consonants(true)` → `advanced=allowZFWJ`; `set_skip_w_shortcut(true)` (w đầu từ giữ là w) → `simple-telex`; `set_free_tone(true)` (bỏ kiểm tra) → `src:spellcheck=off`.
- Bỏ: 34 test viết hoa đầu câu và 59 test macro/gõ tắt văn bản (D3); 4 ca D27 (họ bật phím ngoặc); 124 ca `rstest` sinh từ tham số lúc chạy; 13 test đọc file dữ liệu hoặc sinh đầu vào (kho 22k từ Việt, 100k từ Anh, hoán vị thứ tự gõ); 43 test không trích được (hoán vị sinh lúc chạy, kiểm trường kết quả của engine). Kho dữ liệu `core/tests/data/` không trích.

### 5.10 XKey (Swift, macOS)

- https://github.com/xmannv/xkey, commit `398e78e9c1a92f740d5cbf1673914a3b3c458eff` (11/10/2026). MIT, © 2025 XKey.
- File: `XKeyTests/VNEngineTests.swift`, `VNEngineBackspaceRestoreTests.swift`, `VNEngineBufferIntegrationTests.swift`, `TypingBufferTests.swift` (trích tự động chuỗi `processKey`/`typeWord`/`typeTelex`/`vni([...])` và các lần kiểm `getCurrentWord()`), danh sách `corpus` của `ScreenSimulationTests.swift` (chỉ phím, họ kiểm bất biến).
- 263 ca: Telex 240, VNI 23; 234 có đáp án (từ đang gõ, `getCurrentWord()`).
- Cấu hình: engine mặc định của họ kiểu mới, kiểm tra chính tả và khôi phục bật, **Quick Telex bật**. Ca nào có cặp phụ âm đôi mà Quick Telex có thể đổi (cc, gg, kk, nn, qq, pp, tt) thì bỏ; các ca còn lại không chịu ảnh hưởng của Quick Telex nên chạy với mặc định Dấu. `vUseModernOrthography = 0` → `tone=classic`; `vCheckSpelling = 0` → `src:spellcheck=off`; `vCustomConsonants` → `advanced=allowZFWJ` và/hoặc `src:customConsonants`.
- Bỏ: `XKeyTests/Resources/telex_test_suite.csv` (8.046 ca) vì nguồn gốc không rõ (mục Hiện trạng); 4 test macro, cả file viết hoa đầu câu (D3); 14 ca D27; 1 ca Quick Telex; kiểu "adaptive" Telex+VNI (1 ca, cả file `VNEngineAdaptiveTests.swift`); 166 test không có chuỗi phím kèm kiểm chữ (cờ, lịch sử, hoàn tác, cấu trúc bộ đệm); các file test còn lại là phần ứng dụng (event tap, Trợ năng, cài đặt, đồng bộ).

## 6. Đếm sơ bộ trên đáp án của họ (không trích đáp án)

Người trích chạy một bộ kiểm âm tiết tạm (luật D31 rút gọn, viết riêng cho việc đếm này, không dùng trong engine): `scripts/research/external-tests/answer_stats.py`, đọc `build/external-answers/`, chỉ in số đếm. Chỉ xét ca kết thúc bằng ranh giới từ (hoặc ca ibus-teni, vốn là từ trọn vẹn). Đây là số đếm heuristic, chưa ai xem từng ca.

| Nguồn | Ca kết thúc từ có đáp án | Đáp án còn một từ có dấu không phải âm tiết hợp lệ | Dấu thanh ở chữ mà cả hai kiểu đều không cho | Kiểu đặt dấu khác tuỳ chọn của chính test |
|---|---|---|---|---|
| fcitx5-unikey | 1.323 | 384 (họ tắt kiểm tra chính tả và khôi phục) | 0 | 0 |
| ibus-teni | 3.049 | 1.579 (từ điển riêng của họ có viết tắt, từ mượn) | 6 (cùng một từ trong từ điển đặc biệt, 6 thứ tự gõ) | 0 |
| gonhanh | 1.819 | 42 | 2 (gi + i, khó phân định) | 0 |
| ibus-telex | 250 | 20 | 0 | 0 |
| uvie-rs | 82 | 2 | 0 | 2 |
| goxkey | 2 | 1 | 0 | 0 |
| bamboo-core, ibus-bamboo, vi-rs, XKey | 0–5 | 0 | 0 | 0 |

Không có ca nào có huyền, hỏi hoặc ngã trên vần kết thúc bằng p, t, c, ch. Cột thứ ba là nhóm đáng xem lại nhất ở bước 3: theo D4 và D31, Dấu khôi phục các từ đó khi kết thúc từ, nên đáp án của Dấu sẽ khác ở hầu hết các ca này; một phần là khác biệt có chủ ý (bộ gõ không khôi phục), một phần có thể là lỗi chính tả trong đáp án của họ (sai luật phân bố phụ âm đầu hoặc vần không có trong tiếng Việt).

## 7. Không trích và vì sao

- **Kho lớn sinh máy móc** (vi-rs `all_*.txt`, ibus-teni `vietnamese.cm.dict.*`, dữ liệu `tests/data/` của uvie-rs và `core/tests/data/` của gonhanh): là bảng phủ toàn bộ âm tiết hoặc danh sách từ, không phải ca người viết chọn; Dấu đã có phép thử trên kho âm tiết của riêng mình (bảng mốc M1 trong `docs/PROGRESS.md`). Người dùng chốt chưa trích (05/11/2026); việc làm sau: thêm vào `extract.sh` khi cần (vài chục nghìn ca mỗi nguồn).
- **Test sinh lúc chạy** (`rstest`, hoán vị thứ tự gõ, bất biến ngẫu nhiên): đầu vào không nằm trong mã.
- **Test API** (số Backspace, cờ hợp lệ, cấu trúc bộ đệm, lịch sử sửa từ trước, hoàn tác): không phải chuỗi phím với chữ mong đợi.
- **Tính năng Dấu không có**: macro, viết hoa đầu câu, bảng mã cũ (D3); chế độ Anh riêng (D2); `[ ]` thành ơ ư (D27); Quick Telex (mục "Đã biết nhưng không làm"); kiểu gõ Telex+VNI gộp; danh sách từ được phép (D4); Esc khôi phục chuỗi phím (D4: Esc chỉ reset).

## 8. Nguồn đã thấy nhưng chưa xem

Tìm trên GitHub ngày 05/11/2026, chưa clone, chưa kiểm giấy phép hay bộ test: bogo-python (BoGoEngine, GPL-3.0), avim (1ec5, MIT), vietc (vndangkhoa, MIT), Funput (MIT), ibus-mangrs (fundokukiri, GPL-3.0, README nói có bảng 480 ca), bamboo-core bản Rust (bamboo-vi, MIT), TypeVN, gotivi, InputKey, unikey-rust, 1xkey-src (GPL-3.0), daukey (emizuki, GPL-3.0), PHTV. Nhiều repo mới trong năm 2026 có bộ test lớn sinh tự động; nên ưu tiên repo có lịch sử và người dùng thật.

Nguồn tra: GitHub (`gh search repos "vietnamese input method"`), https://github.com/topics/telex, https://github.com/topics/vni, https://github.com/topics/vietnamese-ime, https://formulae.brew.sh/cask/gonhanh.
