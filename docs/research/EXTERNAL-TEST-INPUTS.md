# Đầu vào test lấy từ bộ gõ khác (thu thập và so sánh)

Ghi công nguồn và giấy phép: `docs/research/external-test-inputs/NOTICE.md`.

Mục đích: lấy **chuỗi phím** trong bộ test của các bộ gõ tiếng Việt khác để engine của Dấu được thử trên những ca người khác thấy đáng test. Dấu tự viết kết quả mong đợi theo chính tả tiếng Việt và `docs/DECISIONS.md` mà **không nhìn** đáp án của họ; chỉ sau đó mới so với đáp án của họ để tìm ca đáng xem lại (người dùng duyệt cách làm này ngày 05/11/2026). Mục 1–8 là bước 1: tìm nguồn, kiểm giấy phép, trích chuỗi phím, để riêng đáp án của họ; mục 9 là kết quả bước 3 (so với đáp án của họ). Không có kết quả mong đợi nào của dự án khác trong `docs/research/external-test-inputs/`; trong file này chỉ mục 9.7 và 9.8 trích nguyên văn đáp án của họ cho vài ca ví dụ thuộc nhóm D và E, có ghi nguồn.

## Hiện trạng (05/11/2026)

- **Bước 1 xong.** Giữ 10 nguồn, tổng **10.320 ca**: Telex 8.239, VNI 2.028, Telex đơn giản 53. Mỗi nguồn một file TSV trong `docs/research/external-test-inputs/`; đáp án của họ nằm riêng ở `build/external-answers/` (thư mục bị git bỏ qua, xem mục 3).
- **Bỏ:** ibus-unikey, OpenKey, fcitx5-bamboo (không có bộ test chuỗi phím); bộ ca CSV của XKey (8.046 dòng, chính tác giả ghi là do một engine khác sinh ra, không nêu engine nào và giấy phép gì). Mọi nguồn giữ lại có giấy phép tương thích GPLv3 (mục 4).
- **Bước 2 xong** theo cách khác kế hoạch ở mục 1: thay cho đáp án mù từng ca, test `ExternalCasesTests` của engine kiểm các bất biến rút từ DECISIONS.md và ghi đầu ra của Dấu vào `build/external-dau-output/` (nhật ký `docs/PROGRESS.md` ngày 05/11/2026). Chưa chạy gì từ các bản clone: chỉ đọc file.
- **Bước 3 xong** (mục 9): 10.320 ca, 240 ca họ không kiểm chữ, 7.971 ca khớp, 2.109 ca khác. Trong 2.109 ca khác: 359 Dấu cố ý khác theo một quyết định (A), 1.492 do tuỳ chọn của nguồn mà Dấu không có (B), 73 đáp án của họ sai chính tả (C), **10 có vẻ là lỗi của Dấu (D, bốn kiểu, mục 9.7)**, **77 cần người dùng quyết định (E, bảy câu hỏi, mục 9.8)**, 98 không so được vì lỗi trích ở bước 1 hoặc khung test bước 2 chưa mô phỏng D20 (X, mục 9.6). Chưa sửa engine, test, DECISIONS.md hay `docs/OPENKEY-NOTES.md`.
- **Đếm sơ bộ trên đáp án của họ** (mục 6) đã được xem từng ca ở bước 3: các từ có dấu không phải âm tiết hợp lệ trong đáp án của họ phần lớn đúng là do cấu hình test của họ (nhóm B: từ điển của ibus-teni, danh sách từ tiếng Anh của gonhanh và uvie-rs, tắt kiểm tra chính tả của fcitx5-unikey); phần còn lại là đáp án sai chính tả (nhóm C).
- **Người dùng chốt (05/11/2026):** (1) ghi công nguồn trong `docs/research/external-test-inputs/NOTICE.md` (tên, URL, commit, SPDX, dòng bản quyền nguyên văn, toàn văn giấy phép MIT/BSD-3-Clause); (2) giữ ibus-telex dù repo không có file LICENSE, ghi chú rằng giấy phép chỉ được khai trong `Cargo.toml`; (3) chưa trích các kho lớn sinh máy móc, để làm sau (mục 7); (4) script trích nằm ở `scripts/research/external-tests/extract.sh`, ghim commit của từng nguồn và tạo lại đúng từng byte các TSV đã commit (đã kiểm 05/11/2026 bằng `cmp` trên bản clone mới).
- Không có khẳng định nào về API Apple trong file này.

## 1. Quy trình mù

1. Engine-dev chỉ đọc `docs/research/external-test-inputs/*.tsv` và file này, viết kết quả mong đợi theo chính tả tiếng Việt và `docs/DECISIONS.md` (D10: không lấy kết quả của bộ gõ khác làm đáp án).
2. Chạy engine của Dấu trên các ca đó; ca nào Dấu khác đáp án của chính Dấu là lỗi của Dấu. (Đã làm bằng bất biến thay cho đáp án từng ca, xem Hiện trạng.)
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
- `build/external-review/<nguồn>.tsv` (git bỏ qua, không commit; bước 3): mọi ca của nguồn, cột `id`, `keys`, `dau_output` (đầu ra bước 2), `their_expected`, `class` (`agree`, `no-answer`, A–E, X theo mục 9), `rule_notes` (nhóm, luật, đề xuất cho nhóm D). File này có đáp án của họ.
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

Người trích chạy một bộ kiểm âm tiết tạm (luật D31 rút gọn, viết riêng cho việc đếm này, không dùng trong engine): `scripts/research/external-tests/answer_stats.py`, đọc `build/external-answers/`, chỉ in số đếm. Chỉ xét ca kết thúc bằng ranh giới từ (hoặc ca ibus-teni, vốn là từ trọn vẹn). Đây là số đếm heuristic trước khi xem từng ca; kết quả xem từng ca ở mục 9.

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

## 9. Kết quả so sánh (05/11/2026)

### 9.1 Cách so

- Ghép `docs/research/external-test-inputs/<nguồn>.tsv`, `build/external-dau-output/<nguồn>.tsv` (đầu ra bước 2) và `build/external-answers/<nguồn>.tsv` theo `id`, so ở dạng NFC. Chuẩn hoá theo `their_note`: bỏ ⏎ cuối khi họ chỉ kiểm phần chữ được commit bằng Return; bỏ một ␣ cuối cho bộ corpus của ibus-telex (khung test của họ gõ thêm Space rồi bỏ dấu cách cuối); với "current word only", "getCurrentWord()", "preedit" chỉ so từ cuối; với "covers only the last N keys", "committed part only" và hàng đợi commit của fcitx5-unikey chỉ so phần cuối.
- Mỗi ca khác được xếp vào một lớp. **A**: Dấu cố ý khác, chỉ khi quyết định được dẫn thật sự sinh ra đầu ra của Dấu. **B**: do tuỳ chọn `src:` của nguồn. **C**: đáp án của họ sai chính tả. **D**: Dấu có vẻ sai, không quyết định nào biện minh. **E**: DECISIONS.md chưa nói hoặc nói chưa rõ, cần người dùng chọn. Thêm lớp **X** cho ca không so được (mục 9.6). Ca vừa thuộc B vừa có quyết định cụ thể của Dấu (ví dụ "pass" ở nguồn có từ điển tiếng Anh, Dấu ra "pas" theo D26) xếp vào A.
- Để xếp lớp, người so chạy engine của Dấu bằng một chương trình tạm ngoài repo (gọi `VietEngine` qua API công khai, không sửa engine): chạy lại ca, chạy thêm ␣ ở cuối để xem kết quả khi kết thúc từ, và một mô phỏng D20 theo `InPlaceComposer` (đọc từ cuối trước con trỏ ở phím dấu/biến đổi đầu tiên khi chữ trước con trỏ chưa biết). Mô phỏng này là mô hình của lớp IMK, chưa chạy trên Dấu thật. Chương trình tạm không nằm trong repo; kết quả từng ca nằm ở `build/external-review/`.

### 9.2 Đếm theo nguồn

"Khác" gồm cả lớp X. Cột `src:`: ca có tuỳ chọn của nguồn mà Dấu không có (mục 2.2).

| Nguồn | Ca | Họ không kiểm chữ | Khớp, không `src:` | Khác, không `src:` | Khớp, có `src:` | Khác, có `src:` |
|---|---|---|---|---|---|---|
| gonhanh | 4.113 | 122 | 2.176 | 148 | 1.493 | 174 |
| ibus-teni | 3.050 | 1 | 0 | 0 | 1.625 | 1.424 |
| fcitx5-unikey | 1.325 | 1 | 7 | 0 | 1.224 | 93 |
| uvie-rs | 961 | 39 | 1 | 0 | 730 | 191 |
| ibus-telex | 323 | 11 | 271 | 40 | 0 | 1 |
| XKey | 263 | 30 | 208 | 12 | 10 | 3 |
| vi-rs | 182 | 12 | 164 | 6 | 0 | 0 |
| bamboo-core | 67 | 7 | 47 | 13 | 0 | 0 |
| ibus-bamboo | 32 | 17 | 12 | 3 | 0 | 0 |
| goxkey | 4 | 0 | 3 | 1 | 0 | 0 |
| **Tổng** | **10.320** | **240** | **2.889** | **223** | **5.082** | **1.886** |

Theo lớp (chỉ ca khác):

| Nguồn | A | B | C | D | E | X |
|---|---|---|---|---|---|---|
| gonhanh | 150 | 21 | 39 | 2 | 58 | 52 |
| ibus-teni | 0 | 1.416 | 6 | 2 | 0 | 0 |
| fcitx5-unikey | 84 | 7 | 0 | 0 | 0 | 2 |
| uvie-rs | 77 | 46 | 18 | 1 | 13 | 36 |
| ibus-telex | 31 | 1 | 9 | 0 | 0 | 0 |
| XKey | 6 | 1 | 1 | 0 | 1 | 6 |
| vi-rs | 2 | 0 | 0 | 4 | 0 | 0 |
| bamboo-core | 7 | 0 | 0 | 1 | 3 | 2 |
| ibus-bamboo | 1 | 0 | 0 | 0 | 2 | 0 |
| goxkey | 1 | 0 | 0 | 0 | 0 | 0 |
| **Tổng** | **359** | **1.492** | **73** | **10** | **77** | **98** |

### 9.3 Lớp A — Dấu cố ý khác (359)

| Quyết định | Ca | Điểm khác |
|---|---|---|
| D26 | 216 | gõ đúp phím dấu/biến đổi bỏ biến đổi và khoá tới hết từ, kể cả sau ⌫; mốc khôi phục là chữ đang hiển thị (D4), nên từ tiếng Anh mất một chữ (đã chấp nhận ở D26). Trong đó 84 ca của fcitx5-unikey: UniKey dùng w thứ hai để thêm móc cho u ("uow" rồi w ra "ươ"), Dấu coi đó là gõ đúp, còn uơ/ươ do D35 tự quyết. 4 ca dấu thanh của vần oo nằm ở o thứ hai (ví dụ "xoòng" trong D26) |
| D31 (nới cho địa danh) | 33 | k đứng trước mọi nguyên âm nên "kò", "ká", "Kẩ", "kô" hợp lệ; âm cuối k chỉ sau ă và phải có sắc/nặng, nên "Busk" và "Ddawk" (không dấu) được khôi phục |
| D4 (tiếng Việt thắng) | 21 | từ vừa là tiếng Anh vừa là âm tiết hợp lệ ra chữ Việt (sims → sím, per → pẻ, wrong → ưởng) |
| D30 | 19 | từ đã sai chính tả thì phím sau đi thẳng như chữ cái, không biến đổi và không bị nuốt |
| D4, D31 (khôi phục khi kết thúc từ) | 18 | chữ không phải âm tiết (đ, â, ă, ấ, đs, đm, Đ trước "$") được trả về đúng phím đã gõ |
| D30, D20 (không tự thêm dấu phụ) | 15 | Dấu không tự thêm mũ hay móc người gõ chưa gõ (thuocs → thuóc giữa từ, kết thúc từ khôi phục; uvie-rs tự thêm thành thuốc) |
| D32 | 10 | ⌫ xoá chữ cuối đang hiển thị và đặt lại dấu ("tiế" ⌫ → "tí"; "tôi" ⌫⌫ → "t"); nguồn khác xoá theo phím |
| D4 (chỉ khôi phục khi kết thúc từ) | 10 | giữa từ Dấu còn hiện chữ đã biến đổi; uvie-rs bỏ biến đổi ngay khi vần sai; kết thúc từ hai bên ra cùng chữ |
| D35 | 6 | "uow", "nuo7" ở cuối từ ra uơ, không phải ươ |
| D20 | 3 | chữ cái thường sau ⌫ bắt đầu từ mới, không mở lại từ trước ("duow␣⌫c" ra "duơc") |
| D28 | 3 | bỏ dấu tự do tắt; d sau nguyên âm biến d đầu từ thành đ |
| D15 | 2 | kiểu cũ ra "hòa"; đáp án của uvie-rs là kiểu mới dù test chạy kiểu cũ |
| D21, D23, D36 | 1 mỗi quyết định | gõ tắt phụ âm chỉ khi kết thúc từ; Telex không có w → qu; chữ số không đặt được dấu thì đi thẳng |

### 9.4 Lớp B — do tuỳ chọn của nguồn (1.492)

| Tuỳ chọn | Ca | Ghi chú |
|---|---|---|
| `src:dictionary` (ibus-teni) | 1.416 | gần hết là từ viết tắt có đ (đbp, hđqt, tnđh…), từ mượn nhiều âm tiết (amiđan, bôxit, café), từ tiếng Anh giữa từ; Dấu không dùng từ điển (D4, D31) |
| `src:englishDictionary` (gonhanh, uvie-rs) | 67 | giữa từ họ đã hiện chữ tiếng Anh ("good"), Dấu hiện "gôd" và khôi phục khi kết thúc từ; từ sai không có trong danh sách của họ thì họ giữ nguyên (chứcc, tàoo, đc) |
| `src:spellcheck=off` (fcitx5-unikey, XKey, ibus-telex) | 9 | họ biến đổi cả chữ không phải âm tiết; Dấu kiểm tra chính tả luôn chạy (D30) |

### 9.5 Lớp C — đáp án của họ sai chính tả (73)

| Luật | Ca |
|---|---|
| vần không có trong tiếng Việt: âi, êi, ăi, ăo, âo, oâ, ôa, ơng, aum, âum, uôp, uên, ưn, ươ đứng một mình, "uo" không mũ trước âm cuối, oo không âm cuối | 25 |
| iê không đứng đầu âm tiết, phải viết yê (D31) | 20 |
| vần kết thúc p, t, c, ch chỉ mang sắc hoặc nặng (D31): âp, ăp, ăc, ôc, têp, ưc, ưt, ưp, ươc, ươt, ươp | 11 |
| dấu thanh của vần oo nằm ở o thứ hai (soóc, moóc), không ở o thứ nhất | 6 |
| ă, â không đứng cuối âm tiết (D31) | 6 |
| phân bố c/k, g/gh, ng/ngh, q+u (D31): cí, ghá, nghá, qá, qư | 5 |

### 9.6 Lớp X — không so được (98)

| Nguyên nhân | Ca | Cần làm |
|---|---|---|
| Khung test bước 2 (`ExternalCasesTests`) chưa mô phỏng D20: không đọc chữ trước con trỏ ở phím dấu/biến đổi đầu tiên sau ⌫ qua dấu cách hay dấu câu, sau Return, mũi tên; và nạp cả "ngả nghieng" làm một từ thay vì chỉ từ cuối như `InPlaceComposer` | 48 | với mô phỏng D20 (mục 9.1) cả 48 ca ra đúng chữ của họ (ví dụ gonhanh `integration_test.rs:backspace_after_space_telex_add_mark#1`, `du␣⌫j` → "dụ"); thêm mô phỏng này vào khung test thì các ca này kiểm được |
| Lỗi trích ở bước 1 (`extract.sh`) | 43 | uvie-rs: hàm phụ `backspace(&mut e, &mut screen)` không được nhận và vòng lặp `for _ in 0..N` gọi `backspace_diff` chỉ ghi một ⌫ (ví dụ `ghost_regression_tests.rs:backspace_after_mid_nucleus_tone#3`); test chỉ in, không assert (`vcv_tests.rs:debug_phat_sequences`, `debug_when_phast_passthrough`, `test_ua_diphthong_tone`); vòng lặp qua mảng từ không được trích (`real_api_sim.rs:real_multiple_words_mixed#1` còn mỗi ␣). gonhanh: hàm `engine_on()` của `english_auto_restore_toggle_test.rs` bật khôi phục tiếng Anh nhưng bị ghi thành `autoRestore=off` (5 ca; với tuỳ chọn đúng Dấu ra đúng chữ của họ). XKey: hai nhánh `if` bị gộp (`VNEngineTests.swift:testTelex_BackspaceAndRetype_LY#3`). fcitx5-unikey: ghép hàng đợi commit theo thứ tự sai ở `testunikey.cpp:testBasic#2` |
| Họ không kiểm chữ trên màn hình | 7 | "raw-keys view" của bamboo-core (2); `getCurrentWord()` sau ⌫ qua ranh giới từ của XKey là từ lấy lại từ lịch sử từ (D20: Dấu không có lịch sử từ), và các vòng ⌫ cũng chỉ được ghi một lần (5) |

### 9.7 Lớp D — có vẻ là lỗi của Dấu (10 ca, 4 kiểu)

Đáp án của họ trích nguyên văn chỉ để mô tả; giá trị đề xuất cho Dấu suy từ DECISIONS.md, không lấy từ họ.

| Kiểu | Ví dụ (nguồn, id) | Phím | Dấu ra | Bộ gõ kia ra | Đề xuất cho Dấu | Dựa vào |
|---|---|---|---|---|---|---|
| D1. w sau "gi" không thành ư (2 ca) | vi-rs `simple_telex.txt:56.1`, `simple_telex.txt:57.1` | `giw`, `giwax` | giw, giwax | vi-rs: giư, giữa | giư, giữa (cùng lối: `giwx␣` → "giữ␣") | D29 (Telex khác Telex đơn giản ở chỗ w không có a, o, u để biến đổi thì thành ư; "tw" → "tư" đã chạy), D31 (gi + ư hợp lệ) |
| D2. w thứ hai trên "ưa" không bỏ móc mà thêm chữ w (3 ca) | ibus-teni `nodict.tdata:9`; vi-rs `simple_telex.txt:65.1` | `huaww`, `chuawrwz` | hưaw, chửawz | ibus-teni: huaw; vi-rs: chuảwz | huaw; chủawz (bỏ móc, w thành chữ, từ khoá nên z là chữ; dấu hỏi ở u như vần "ua" của "của"); `chuaww␣` → "chuaw␣" | D26 ("ww" → "w"; "aww" → "aw", "tuongww" → "tuongw" đã đúng) |
| D3. "uwo" không cho uơ/ươ (3 ca) | gonhanh `permutation_test.rs:horn_order_diphthong#4`; uvie-rs `bugfix_tests.rs:test_uw_then_o_open_syllable#1`; bamboo-core `bamboo_test.go:TestDoubleTyping#2` | `uwo␣`, `nguwo`, `buwoo` | ưo␣, ngưo, bươo | gonhanh: ươ␣; uvie-rs: ngươ; bamboo-core: buô | uơ␣, nguơ; "buwo" → "buơ" (phím o tiếp theo thuộc câu hỏi E2) | D35 nêu rõ Telex "uwo" như "uow"; hiện "huwo␣" bị khôi phục thành "huwo␣" (D31 nhận "huơ") |
| D4. bảng vần thiếu "oao" (2 ca) | vi-rs `simple_telex.txt:54.1`; gonhanh `english_auto_restore_test.rs:pattern2_aa_vowel_pair#8` | `ngoaos`, `ngoafo␣` | ngoaos, ngoafo␣ | vi-rs: ngoáo; gonhanh: ngoào␣ | ngoáo, ngoào␣ | D31 (bảng vần theo chính tả; "ngoao", "ngoáo ộp" có trong từ điển) |

### 9.8 Lớp E — cần người dùng quyết định (77 ca, 7 câu hỏi)

| Câu hỏi | Ca | Ví dụ (nguồn, id) | Phím | Dấu ra | Bộ gõ kia ra |
|---|---|---|---|---|---|
| E1. Huyền/hỏi/ngã gõ khi vần đã có âm cuối p, t, c, ch: hiện dấu giữa từ (hiện nay, theo ví dụ "hoc" + f → "hòc" ở D20; kết thúc từ D31 khôi phục, nhưng khi tắt tự khôi phục thì chữ sai chính tả ở lại) hay coi phím đó là chữ? D30 nói "tiền tố của âm tiết hợp lệ", mà "cảt" không là tiền tố của âm tiết nào | 36 | bamboo-core `bamboo_test.go:TestProcessCatrString#1`; gonhanh `english_words_test.rs:protect_final_clusters#1` (tắt tự khôi phục); gonhanh `checked_tone_stop_final_test.rs:hoi_on_stop_final_is_rejected#2` | `catr`, `metric`, `atr` | cảt, mẻtic, ảt | bamboo-core: catr; gonhanh: metric, atr |
| E2. Phím biến đổi khác loại gõ lên nguyên âm đã có dấu phụ: Dấu đổi dấu với một nguyên âm ("aaw" → "ă", "oow" → "ơ", "owo" → "ô") nhưng không với cặp ươ ("cuoiw" + o → "cươio") | 10 | bamboo-core `bamboo_test.go:TestDoubleTyping#4` (XKey cùng kết quả); gonhanh `typing_test.rs:vni_switch_diacritics#7`; uvie-rs `vcv_tests.rs:comprehensive_vietnamese_phonotactics#277` | `cuoiwo`, VNI `buong76`, `aaw` | cươio, bương6, ă | bamboo-core: cuôi; gonhanh: buông; uvie-rs: aaw |
| E3. Phím dấu gõ ngay sau "qu", trước nguyên âm chính: Dấu bỏ qua ("qusa" → "qusa") nhưng nhận sau "gi" ("gisa" → "giá"). Và "qui/quí/quỉ" (cách viết cũ của quy/quý/quỷ) có là âm tiết hợp lệ không (hiện nay: không) | 10 | gonhanh `typing_test.rs:telex_typos#27`; gonhanh `english_auto_restore_test.rs:issue26_thuy_with_hook_before_y#4`; uvie-rs `phonotactics_tests.rs:test_qu_i_glide#1` | `qusa`, `qury␣`, `quis` (kiểu cũ) | qusa, qury␣, quis | gonhanh: quá, quỷ␣; uvie-rs: quí |
| E4. Mốc khôi phục sau gõ đúp là chữ đang hiển thị (D4, D26), nên từ tiếng Anh còn chữ Việt hoặc mất hơn một chữ; D26 chỉ ghi nhận hệ quả "mất một chữ" | 13 | gonhanh `auto_restore_dynamic_test.rs:w_initial_comprehensive#32`; gonhanh `english_auto_restore_test.rs:pattern1_modifier_then_consonant#13`; gonhanh `revert_auto_restore_test.rs:consecutive_modifiers_followed_by_vowel#5` | `worry␣`, `express␣`, `versus␣` | ưory␣, êps␣, veus␣ | gonhanh: worry␣, express␣, versus␣ |
| E5. Phụ âm môi (b, m, p) đi với âm đệm o/u: D31 chưa nói, nên "moẻ", "boẻ", "poẻ" hợp lệ và thắng từ tiếng Anh theo D4 | 5 | gonhanh `auto_restore_dynamic_test.rs:ore_are_ure_ire_comprehensive#13` | `more␣` | moẻ␣ | gonhanh: more␣ |
| E6. z khi từ chưa có dấu thanh: Dấu thêm chữ z; gonhanh bỏ mọi dấu phụ | 2 | gonhanh `bug_reports_test.rs:bug_bac_kan_hong_kong_telex_cancel_keys#4` (tắt tự khôi phục) | `kongoz` | kôngz | gonhanh: kong |
| E7. Vần hiếm "uêu" (nguều) chưa có trong bảng vần | 1 | gonhanh `english_auto_restore_test.rs:pattern2_aa_vowel_pair#7` | `ngueeuf␣` | ngueeuf␣ | gonhanh: nguều␣ |

Chữ tiếng Việt dựng sẵn đến như một phím (mục 2.1, 7 ca): cả 7 ca khớp với họ (Dấu coi là một chữ cái của từ); DECISIONS.md vẫn chưa có quyết định cho trường hợp này.
