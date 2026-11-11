# Đầu vào test lấy từ bộ gõ khác (thu thập và so sánh)

Chạy engine của Dấu trên **chuỗi phím** lấy từ bộ test của 10 bộ gõ tiếng Việt khác, rồi so với đáp án của họ để tìm ca đáng xem lại. Đáp án của họ không bao giờ là kết quả mong đợi của Dấu (D10 (Engine tự viết)): engine được kiểm bằng bất biến rút từ chính tả và `docs/Decisions.md`, đáp án của họ chỉ dùng để so. Ghi công nguồn và giấy phép: [`docs/research/external-test-inputs/NOTICE.md`](NOTICE.md). Diễn biến các lần đếm, quy trình dự kiến ban đầu và các bước chốt quyết định: `docs/history/ResearchLog.md` mục 3.

## Hiện trạng (12/11/2026)

- **10.303 ca** từ 10 nguồn (Telex 8.222, VNI 2.028, Telex đơn giản 53). Họ không kiểm chữ ở 235 ca; còn lại **8.082 khớp, 1.986 khác**.
- Ca khác theo lớp (mục 1; định nghĩa lớp ở mục 3.3): **A 422** (Dấu cố ý khác theo một quyết định), **B 1.493** (do tuỳ chọn của nguồn mà Dấu không có), **C 67** (đáp án của họ sai chính tả), **X 4** (không so được). **D 0** (lỗi của Dấu), **E 0** (cần quyết định mới), không còn ca chưa xếp lớp.
- **Lỗi của Dấu tìm được: bốn kiểu, đã sửa** (mục 2.1). Mười một câu hỏi về luật đã chốt thành quyết định (mục 2.2).
- Số đếm bằng `scripts/research/external-tests/compare.sh` trên engine sau D31 (Âm tiết tiếng Việt hợp lệ) đổi ngày 10/11/2026, chạy lại 12/11/2026 sau khi D26 (Gõ đúp phím dấu) đổi: ⌫ xoá chữ của phím gõ đúp thì mở khoá, 4 ca lớp A thành khớp (XKey `testTelex_UndoBackspaceRetype_ToneMark#5`, `_DD#5`; bamboo-core `TestProcessRefresh2#1`; gonhanh `bug7_backspace_resets_stroke_reverted#1`); test engine xanh. Khung test mô phỏng D20 (Thêm dấu cho từ đã gõ) theo cách đọc ở chữ cái đầu tiên cùng ba ngoại lệ (mục 3.4); mô phỏng, chưa chạy trên Dấu thật.
- Không chạy mã nào của các dự án khác: chỉ đọc file. Không có đáp án của họ trong thư mục này; vài ca ví dụ ở mục 1 và 2 nhắc đáp án của họ, có ghi nguồn.
- Không có khẳng định nào về API Apple trong file này.

## 1. Kết quả theo lớp

Theo nguồn ("Khác" gồm cả lớp X; cột `src:`: ca có tuỳ chọn của nguồn mà Dấu không có, mục 4.2):

| Nguồn | Ca | Họ không kiểm chữ | Khớp, không `src:` | Khác, không `src:` | Khớp, có `src:` | Khác, có `src:` |
|---|---|---|---|---|---|---|
| gonhanh | 4.110 | 119 | 2.229 | 85 | 1.509 | 168 |
| ibus-teni | 3.050 | 1 | 0 | 0 | 1.627 | 1.422 |
| fcitx5-unikey | 1.325 | 1 | 7 | 0 | 1.225 | 92 |
| uvie-rs | 947 | 37 | 1 | 0 | 744 | 165 |
| ibus-telex | 323 | 11 | 280 | 31 | 0 | 1 |
| XKey | 263 | 30 | 216 | 4 | 10 | 3 |
| vi-rs | 182 | 12 | 166 | 4 | 0 | 0 |
| bamboo-core | 67 | 7 | 51 | 9 | 0 | 0 |
| ibus-bamboo | 32 | 17 | 14 | 1 | 0 | 0 |
| goxkey | 4 | 0 | 3 | 1 | 0 | 0 |
| **Tổng** | **10.303** | **235** | **2.967** | **135** | **5.115** | **1.851** |

Ca khác, theo lớp:

| Nguồn | A | B | C | D | E | X | Chưa xếp |
|---|---|---|---|---|---|---|---|
| gonhanh | 197 | 21 | 34 | 0 | 0 | 1 | 0 |
| ibus-teni | 0 | 1.416 | 6 | 0 | 0 | 0 | 0 |
| fcitx5-unikey | 84 | 8 | 0 | 0 | 0 | 0 | 0 |
| uvie-rs | 102 | 46 | 17 | 0 | 0 | 0 | 0 |
| ibus-telex | 22 | 1 | 9 | 0 | 0 | 0 | 0 |
| XKey | 4 | 1 | 1 | 0 | 0 | 1 | 0 |
| vi-rs | 4 | 0 | 0 | 0 | 0 | 0 | 0 |
| bamboo-core | 7 | 0 | 0 | 0 | 0 | 2 | 0 |
| ibus-bamboo | 1 | 0 | 0 | 0 | 0 | 0 | 0 |
| goxkey | 1 | 0 | 0 | 0 | 0 | 0 | 0 |
| **Tổng** | **422** | **1.493** | **67** | **0** | **0** | **4** | **0** |

### 1.1 Lớp A: Dấu cố ý khác (422)

| Quyết định | Ca | Điểm khác |
|---|---|---|
| D26 (Gõ đúp phím dấu) | 213 | gõ đúp phím dấu hay phím biến đổi bỏ biến đổi và khoá tới hết từ, hoặc tới khi ⌫ xoá chữ của phím gõ đúp; mốc khôi phục là chữ đang hiển thị (D4 (Từ nước ngoài)). Trong đó 84 ca của fcitx5-unikey: UniKey dùng w thứ hai để thêm móc cho u ("uow" rồi w ra "ươ"), Dấu coi đó là gõ đúp, còn uơ/ươ do D35 ("uơ" và "ươ") quyết. 4 ca dấu thanh của vần oo ở o thứ hai ("xoòng"). 1 ca "ww" trên "ưa" bỏ móc ("chuawrwz" → "chủawz") |
| D30 (Kiểm tra chính tả), dấu thanh trên vần tắc | 36 | huyền, hỏi, ngã trên vần có âm cuối p, t, c, ch được nhận giữa từ ("catr" hiện "cảt"); kết thúc từ D4 khôi phục; tắt tự khôi phục thì chữ đó ở lại |
| D31, nới cho địa danh | 33 | k đứng trước mọi nguyên âm ("kò", "ká", "Kẩ", "kô" hợp lệ); âm cuối k chỉ sau ă và phải có sắc/nặng, nên "Busk", "Ddawk" được khôi phục |
| D4, tiếng Việt thắng | 21 | từ vừa là tiếng Anh vừa là âm tiết hợp lệ ra chữ Việt (sims → sím, per → pẻ, wrong → ưởng) |
| D32 (Backspace) | 20 | ⌫ xoá chữ cuối đang hiển thị và đặt lại dấu ("tiế" ⌫ → "tí"; "thật" ⌫⌫ → "th"); nguồn khác xoá theo phím ("thật" ⌫⌫ → "thạ") |
| D30 | 19 | từ đã sai chính tả thì phím sau đi thẳng như chữ cái, không biến đổi và không bị nuốt |
| D30, D20, không tự thêm dấu phụ | 15 | không tự thêm mũ hay móc người gõ chưa gõ ("thuocs" giữa từ hiện "thuóc", kết thúc từ khôi phục; uvie-rs ra "thuốc") |
| D26, giới hạn đã biết | 13 | từ tiếng Anh có chữ lặp trùng phím dấu hay phím biến đổi mất cả dấu lẫn chữ ("worry" → "ưory", "express" → "êps", "versus" → "veus") |
| D4, chỉ khôi phục khi kết thúc từ | 10 | giữa từ Dấu còn hiện chữ đã biến đổi; uvie-rs bỏ biến đổi ngay khi vần sai; kết thúc từ hai bên ra cùng chữ |
| D35 | 10 | "uow", "uwo", "nuo7" ở cuối từ ra uơ ("uwo␣" → "uơ␣", "nguwo" → "nguơ", "huwo" → "huơ") |
| D4, D31, khôi phục khi kết thúc từ | 8 | chữ không phải âm tiết hợp lệ (đs, đm, đz, "saax", "tiesz") trả về đúng phím đã gõ |
| D31, b, m, p, v với âm đệm | 5 | "more", "bore", "pore" ra "moẻ", "boẻ", "poẻ" (hợp lệ, tiếng Việt thắng theo D4) |
| D28 (Bỏ dấu tự do) | 3 | bỏ dấu tự do tắt; d sau nguyên âm biến d đầu từ thành đ |
| D28, phím biến đổi khác loại | 3 | "aaw" → "ă", "ooww" → "ow" (đổi dấu, rồi "ww" bỏ móc theo D26) |
| D15 (Cài đặt mặc định) | 2 | kiểu cũ ra "hòa"; đáp án của uvie-rs là kiểu mới dù test chạy kiểu cũ |
| D20, D26 | 2 | sau ⌫ qua dấu cách, phím biến đổi đọc lại từ trước và gõ đúp bỏ mũ ("tuân" + a → "tuana", "tiêng" + e → "tienge"); gonhanh coi a, e là chữ |
| D31, "qui" không hợp lệ | 2 | "quis", "quir" (kiểu cũ) giữ nguyên; uvie-rs ra "quí", "quỉ" |
| D40 (Chữ dựng sẵn và phím z) | 2 | z khi từ chưa có dấu thanh là chữ z, không bỏ mũ ("kongoz" hiện "kôngz" khi tắt tự khôi phục); gonhanh bỏ mọi dấu phụ |
| D31, iê không đứng đầu âm tiết | 1 | "ieje" không biến đổi |
| D31, chữ cái đứng một mình | 1 | "aw␣" ra "ă␣"; gonhanh khôi phục "aw" theo danh sách từ tiếng Anh (`src:`, lớp B nhường A) |
| D21 (Gõ tắt phụ âm), D23 (w → qu chỉ ở VNI), D36 (VNI: chữ số thành dấu) | 1 mỗi quyết định | gõ tắt phụ âm chỉ khi kết thúc từ; Telex không có w → qu; chữ số không đặt được dấu thì đi thẳng |

Chữ tiếng Việt dựng sẵn tới engine như một phím (mục 4.1, 7 ca): cả 7 khớp với họ (D40).

### 1.2 Lớp B: do tuỳ chọn của nguồn (1.493)

| Tuỳ chọn | Ca | Ghi chú |
|---|---|---|
| `src:dictionary` (ibus-teni) | 1.416 | gần hết là từ viết tắt có đ (đbp, hđqt, tnđh…), từ mượn nhiều âm tiết (amiđan, bôxit, café), từ tiếng Anh giữa từ; Dấu không dùng từ điển (D4, D31) |
| `src:englishDictionary` (gonhanh, uvie-rs) | 67 | giữa từ họ đã hiện chữ tiếng Anh ("good"), Dấu hiện "gôd" và khôi phục khi kết thúc từ; từ sai không có trong danh sách của họ thì họ giữ nguyên (chứcc, tàoo, đc). "good←book": "gôd" có sẵn không phải tiếng Việt nên "book" đi thẳng ("gôdbook", D20 ngoại lệ (b)); họ ra "goodbook" |
| `src:spellcheck=off` (fcitx5-unikey, XKey, ibus-telex) | 10 | họ biến đổi cả chữ không phải âm tiết ("baao␣" ra "bâo␣"); Dấu kiểm tra chính tả luôn chạy (D30) |

### 1.3 Lớp C: đáp án của họ sai chính tả (67)

| Luật | Ca |
|---|---|
| vần không có trong tiếng Việt: âi, êi, ăi, ăo, âo, oâ, ôa, ơng, aum, âum, uôp, uên, ưn, ươ đứng một mình, "uo" không mũ trước âm cuối, oo không âm cuối | 25 |
| iê không đứng đầu âm tiết, phải viết yê (D31) | 20 |
| vần kết thúc p, t, c, ch chỉ mang sắc hoặc nặng (D31): âp, ăp, ăc, ôc, têp, ưc, ưt, ưp, ươc, ươt, ươp | 11 |
| dấu thanh của vần oo ở o thứ hai (soóc, moóc), không ở o thứ nhất | 6 |
| phân bố c/k, g/gh, ng/ngh, q+u (D31): cí, ghá, nghá, qá, qư | 5 |

### 1.4 Lớp X: không so được (4)

| Nguyên nhân | Ca | Ghi chú |
|---|---|---|
| `←` là `clear()` của engine họ, không phải phím mũi tên (mục 4.1) | 1 | gonhanh `integration_test.rs:complex_mau_sac_continuous_session#24`: sau `clear()` họ gõ tiếp sát chữ cũ như trong ô mới; khung test của Dấu coi `←` là mũi tên nên D20 đọc từ ngay trước con trỏ ("mà" + "sawsc" ra "măsc", họ ra "sắc"). Muốn so được thì khung test phải chạy `clear()` như đổi ô nhập |
| Họ không kiểm chữ trên màn hình | 2 | "raw-keys view" của bamboo-core |
| Nhánh `if` trên trạng thái engine của họ không xảy ra ở Dấu | 1 | XKey `VNEngineTests.swift:testTelex_BackspaceAndRetype_LY#3` chỉ chạy khi engine của họ còn "l" sau hai ⌫; ở Dấu "lý" ⌫⌫ còn rỗng (D32), nhánh kia (`#2`) khớp |

## 2. Lỗi của Dấu và câu hỏi đã chốt

### 2.1 Lỗi của Dấu đã tìm và đã sửa

Bốn kiểu lỗi (lớp D) ở lần xét đầu ngày 05/11/2026, sửa ở commit 4d908e3 (và 36da993 cho VNI "u7o"); luật ghi ở D26, D29 (Telex đơn giản), D31, D35.

| Kiểu | Ví dụ (nguồn, id) | Phím | Dấu ra trước | Dấu ra bây giờ | Dựa vào |
|---|---|---|---|---|---|
| 1. w sau "gi" không thành ư (2 ca) | vi-rs `simple_telex.txt:56.1`, `57.1` | `giw`, `giwax` | giw, giwax | giư, giữa (khớp) | D29, D31 |
| 2. w thứ hai trên "ưa" không bỏ móc (3 ca) | ibus-teni `nodict.tdata:9`; vi-rs `simple_telex.txt:65.1` | `huaww`, `chuawrwz` | hưaw, chửawz | huaw (khớp); chủawz (lớp A, D26: vi-rs đặt dấu hỏi ở a) | D26 |
| 3. "uwo" không cho uơ/ươ (3 ca) | gonhanh `permutation_test.rs:horn_order_diphthong#4`; uvie-rs `bugfix_tests.rs:test_uw_then_o_open_syllable#1`; bamboo-core `bamboo_test.go:TestDoubleTyping#2` | `uwo␣`, `nguwo`, `buwoo` | ưo␣, ngưo, bươo | uơ␣, nguơ (lớp A, D35: hai bộ gõ kia ra ươ); buô (khớp) | D35, D28 |
| 4. bảng vần thiếu "oao" (2 ca) | vi-rs `simple_telex.txt:54.1`; gonhanh `english_auto_restore_test.rs:pattern2_aa_vowel_pair#8` | `ngoaos`, `ngoafo␣` | ngoaos, ngoafo␣ | ngoáo, ngoào␣ (khớp) | D31 |

### 2.2 Câu hỏi đã chốt thành quyết định

Chín câu hỏi lớp E của lần xét đầu (mã E1–E9) và hai câu của lần xét thứ hai, đều chốt ngày 05/11/2026; ca nào còn khác nay thuộc lớp A. Bảng câu hỏi, số ca và ví dụ: `docs/history/ResearchLog.md` mục 3.
- D30: huyền/hỏi/ngã trên vần tắc nhận giữa từ, kết thúc từ khôi phục (E1).
- D28: phím biến đổi khác loại đổi sang dấu mới, kể cả "ươ" + o → "uô" (E2).
- D31: dấu ngay sau "qu" được nhận, "qui" vẫn không hợp lệ (E3); b, m, p, v đi với âm đệm (E5); thêm vần "uêu", "oao" (E7). D32: "quá" ⌫ → "qu".
- D26: từ tiếng Anh mất hơn một chữ do mốc khôi phục sau gõ đúp là giới hạn đã biết (E4).
- D40: z khi từ chưa có dấu thanh là chữ (E6).
- D20: chữ cái gõ sát chữ có sẵn cũng đọc từ trước con trỏ, chỉ nối khi từ ghép còn là tiền tố hợp lệ (E8; `⟦q⟧uer⏎` nay ra "quẻ⏎"), cùng ba ngoại lệ (mục 3.4).
- D33 (Độ dài từ): xoá hết một từ dài quá 7 chữ bằng ⌫ thì hết trạng thái đi thẳng (E9; `permission` + 10 ⌫ + `vieetj` nay ra "việt").

## 3. Cách làm

### 3.1 Bất biến thay cho đáp án từng ca

`ExternalCasesTests` (`Packages/DauEngine/Tests/DauEngineTests`) chạy mọi ca qua engine, kiểm các bất biến rút từ chính tả và `docs/Decisions.md`, và ghi đầu ra của Dấu vào `build/external-dau-output/`. Không ai viết đáp án từng ca; người viết test chỉ đọc các file `*.tsv` và file này, không mở đáp án của họ.

### 3.2 So với đáp án của họ

`scripts/research/external-tests/compare.sh` (helper `compare.py`) ghép ba file theo `id`, so ở dạng NFC, ghi `build/external-review/` và in hai bảng ở mục 1. Ba file: `docs/research/external-test-inputs/<nguồn>.tsv`, `build/external-dau-output/<nguồn>.tsv`, `build/external-answers/<nguồn>.tsv`.

Chuẩn hoá theo `their_note` trước khi so:
- bỏ phím commit cuối (⏎, ß…) và phần chữ sau con trỏ khi họ chỉ kiểm phần chữ được commit;
- bỏ một ␣ cuối (và ⏎/⇥ ngay trước nó) cho bộ corpus của ibus-telex (khung test của họ gõ thêm Space rồi bỏ dấu cách cuối);
- "current word only", "getCurrentWord()", "preedit": chỉ so từ cuối; "covers only the last N keys", "committed part only": chỉ so phần cuối.

Chạy lại: `swift test --package-path Packages/DauEngine` (ghi đầu ra của Dấu), rồi `scripts/research/external-tests/compare.sh`. Để xem từng ca, người so chạy engine qua API công khai bằng chương trình tạm ngoài repo.

### 3.3 Xếp lớp

Mỗi ca mà Dấu và đáp án của họ khác nhau thuộc đúng một lớp:
- **A**: Dấu cố ý khác, chỉ khi quyết định được dẫn thật sự sinh ra đầu ra của Dấu;
- **B**: khác do tuỳ chọn `src:` của nguồn mà Dấu không có (mục 4.2);
- **C**: đáp án của họ sai chính tả;
- **D**: Dấu có vẻ sai, không quyết định nào biện minh;
- **E**: `docs/Decisions.md` chưa nói hoặc nói chưa rõ, cần người dùng chọn;
- **X**: không so được.

Ca vừa thuộc B vừa có quyết định cụ thể của Dấu xếp vào A ("pass" ở nguồn có từ điển tiếng Anh, Dấu ra "pas" theo D26). Các ca còn lại: `agree` (khớp), `no-answer` (họ không kiểm chữ), `unreviewed` (khác nhưng chưa xếp).

Script không tự xếp lớp. Ca khác giữ lớp cũ nếu phím, đầu ra của Dấu và đáp án của họ không đổi; còn lại thành `unreviewed` (lớp cũ ghi trong `rule_notes`), người so xem từng ca rồi áp lớp bằng `compare.sh --set`. Ca lớp D là lỗi của Dấu, sửa engine; ca lớp E hỏi người dùng rồi ghi quyết định.

### 3.4 Mô phỏng D20 trong khung test

Khung test chạy việc đọc chữ trước con trỏ của D20 như lớp IMK (`ExternalCasesTests.d20Seed`, mô hình theo `InPlaceComposer`; mô phỏng, chưa chạy trên Dấu thật): đọc ở phím dấu/biến đổi và ở chữ cái đầu tiên khi bộ đệm trống, chữ cái chỉ nối khi từ ghép còn là tiền tố hợp lệ, cùng ba ngoại lệ: (a) chữ hoa sau chữ thường bắt đầu từ mới, (b) từ có sẵn không phải tiếng Việt nhận chữ gõ tiếp nguyên văn tới hết từ, (c) phím dấu/biến đổi đầu tiên không áp được lên từ tiếng Việt có sẵn thì bắt đầu từ mới. Từ dài hơn 7 chữ vào trạng thái đi thẳng của D33 bằng `VietEngine.seedOverflow`.

Cách chọn (mô phỏng trên 10.303 ca và các tình huống sửa chữ, 05/11/2026):
- so với chỉ đọc ở phím dấu/biến đổi, **luôn nối** chữ cái vào từ đọc được ra khác ở 38 ca và làm hỏng 34, vì dính từ mới vào từ trước con trỏ ("ddi␣⌫hocj" ra "đihocj" thay vì "đihọc");
- **nối có điều kiện** (tiền tố hợp lệ) ra khác ở 4 ca, cả 4 khớp với họ;
- ba ngoại lệ đổi đầu ra: (a) 0 ca, (b) 2, (c) 24, không bất biến nào hỏng.
D20 chọn nối có điều kiện cùng ba ngoại lệ. Lớp IMK làm ở `InPlaceComposer` (test `InPlaceComposerLetterTests`, `InPlaceComposerExceptionTests`).

### 3.5 Đếm sơ bộ không xem đáp án

`scripts/research/external-tests/answer_stats.py` đếm đáp án của họ có từ không phải âm tiết hợp lệ, bằng một bộ kiểm âm tiết tạm, chỉ in số đếm. Đã dùng một lần trước khi xem từng ca; số đếm đó nay được thay bằng các lớp ở mục 1 (bảng cũ: `docs/history/ResearchLog.md` mục 3).

## 4. Định dạng dữ liệu

### 4.1 Cột `keys`

Mỗi ký tự là một phím gửi vào engine theo thứ tự, như `Typist.type` trong test của Dấu. Chữ hoa là phím chữ có Shift (hoặc Caps Lock).

| Ký hiệu | Nghĩa |
|---|---|
| `␣` | phím Space |
| `⏎` | Return |
| `⇥` | Tab |
| `⌫` | Backspace |
| `←` | sự kiện **reset engine của họ**: `clear()`/`reset()`, hoặc mũi tên, Home/End, tổ hợp có ⌃/⌘ mà engine của họ chỉ coi là reset. Không nói gì về chữ trước con trỏ: trong test của họ `clear()` thường là ô nhập mới. Khung test của Dấu chạy `←` như phím mũi tên (D4: chỉ reset, không khôi phục), nên D20 có thể đọc từ ngay trước con trỏ. Ca nào họ mở ô mới bằng `clear()` rồi gõ tiếp sát chữ cũ thì không so được (lớp X, mục 1.4) |
| `⎋` | Esc (với Dấu: chỉ reset, D4) |
| `⟦chữ⟧` ở đầu chuỗi | chữ có sẵn trước con trỏ, engine được nạp từ chữ đó (D20, `Typist.seed`); các phím sau đó gõ tiếp |
| `⟦trước\|sau⟧` | như trên, `\|` là vị trí con trỏ; phần sau con trỏ nằm trong ô nhưng D20 không đọc |
| chữ tiếng Việt dựng sẵn ngoài `⟦⟧` (7 ca) | ký tự đó tới engine như một phím (bố cục khác, nhập kiểu dán); D40: Dấu coi là một chữ cái của từ |

Các phím khác (chữ số, dấu câu, `ß`…) là chính ký tự đó. TSV không chứa ký tự tab hay xuống dòng thật.

Một số ca dùng chung một engine qua nhiều lời gọi trong cùng test của họ: `keys` là mọi phím từ lúc tạo engine (hoặc từ lần `clear`/`reset` gần nhất), `their_note` ghi rằng đáp án chỉ phủ phần cuối. Ca là trạng thái giữa từ (họ kiểm chữ đang gõ) thì `keys` không kết thúc bằng `␣`/`⏎`, và đầu ra của Dấu cũng là chữ hiển thị giữa từ.

### 4.2 Cột `options`

Các mục cách nhau bằng `;`. Rỗng là mặc định của Dấu (D15: Telex, đặt dấu kiểu mới, bỏ dấu tự do bật, tự khôi phục bật, Nâng cao tắt). Cột `method` ghi kiểu gõ: `telex`, `vni`, `simple-telex` (D29).

| Mục | Cài đặt của Dấu |
|---|---|
| `tone=classic` | đặt dấu kiểu cũ (hòa, thúy), `EngineOptions.tonePlacement = .classic` |
| `freeMarking=off` | tắt bỏ dấu tự do (D28) |
| `autoRestore=off` | tắt "Tự khôi phục từ không phải tiếng Việt" (D4, D30) |
| `advanced=consonantShortcuts` | gõ tắt phụ âm (D21) |
| `advanced=allowZFWJ` | cho phép z, f, w, j (D22 (Gõ tắt loại trừ z, f, w, j)) |

Mục bắt đầu bằng `src:` là **tuỳ chọn của nguồn mà Dấu không có**; ca vẫn chạy với cài đặt Dấu gần nhất:

| Mục | Nghĩa ở nguồn | Ở Dấu |
|---|---|---|
| `src:spellcheck=off` | họ tắt kiểm tra chính tả | kiểm tra chính tả luôn chạy (D30) |
| `src:dictionary` | ibus-teni quyết định bằng từ điển từ (có viết tắt, từ mượn) | không dùng từ điển (D4, D31) |
| `src:englishDictionary` | khôi phục từ tiếng Anh theo danh sách từ (gonhanh "English auto-restore", uvie-rs "english override") | khôi phục theo luật âm tiết hợp lệ (D4) |
| `src:modifySurroundingText=off` | fcitx5-unikey đọc chữ xung quanh nhưng không được sửa | D20 sửa được chữ trước con trỏ |
| `src:relaxedCoda=on` | uvie-rs nới luật âm cuối | không có (D31) |
| `src:customConsonants=…` | XKey cho thêm phụ âm đầu (liệt kê chữ) | gần nhất là D22. Với `K`: suy luận, cần kiểm chứng, là cho k đứng trước a, o, u; D31 đã nhận điều này |

Cách quy đổi kiểu gõ của từng nguồn sang `method` và `options`: mục 5.

### 4.3 Bố cục file

- `docs/research/external-test-inputs/<nguồn>.tsv` (commit): hàng tiêu đề, một ca mỗi hàng, cột `id`, `method`, `options`, `keys`, `source_ref`. `id` ổn định, dạng `file:tên test#thứ tự` (hoặc `file:dòng`), đủ để tìm lại ca trong repo của họ ở commit ghi ở mục 5; `source_ref` là đường dẫn file của họ. Không có cột đáp án.
- `build/external-answers/<nguồn>.tsv` (git bỏ qua): cột `id`, `their_expected` (cùng ký hiệu với `keys`; trống khi họ không kiểm chữ), `their_note` (họ kiểm cái gì).
- `build/external-review/<nguồn>.tsv` (git bỏ qua, do `compare.sh` ghi): cột `id`, `keys`, `dau_output`, `their_expected`, `class` (mục 3.3), `rule_notes` (nhãn lớp như `A-D32`).
- `scripts/research/external-tests/extract.sh` lấy từng nguồn ở đúng commit ghi ở mục 5 vào thư mục tạm, gọi các helper cùng thư mục, chỉ đọc file văn bản (không build, không chạy gì của các bản clone), và tạo lại đúng từng byte các TSV đã commit cùng `build/external-answers/`.
  - Vòng lặp có số lần ghi trong mã được trải ra, nên mỗi phím trong vòng được ghi đủ số lần; vòng có số lần tính lúc chạy thì bỏ các ca sau nó.
  - Test chỉ in kết quả, không kiểm gì, thì bỏ.

## 5. Nguồn và giấy phép

Chuỗi phím là dữ liệu ngắn, gần như không có tính sáng tạo; dù vậy mọi nguồn đều được ghi công trong [`NOTICE.md`](NOTICE.md) (tên, URL, commit, SPDX, dòng bản quyền nguyên văn, toàn văn giấy phép MIT/BSD-3-Clause) và chỉ giữ nguồn có giấy phép tương thích GPLv3.

| Nguồn | SPDX | Dùng cho Dấu (GPLv3) |
|---|---|---|
| bamboo-core | MIT | được, giữ thông báo bản quyền |
| ibus-bamboo | GPL-3.0 (file LICENSE, không ghi "or later") | được, cùng GPLv3 |
| fcitx5-unikey (thư mục test) | GPL-2.0-or-later (SPDX trong file test) | được, nhờ "or later" |
| goxkey | BSD-3-Clause | được, giữ thông báo bản quyền |
| vi-rs | MIT | được |
| ibus-teni | GPL-3.0-or-later (thư mục test-data có LICENSE riêng) | được |
| uvie-rs | MIT OR Apache-2.0 | được (chọn MIT) |
| ibus-telex | GPL-3.0-or-later, chỉ khai trong `Cargo.toml`, repo không có file LICENSE | được, giữ kèm ghi chú đó |
| gonhanh.org | BSD-3-Clause | được, giữ thông báo bản quyền |
| XKey | MIT (file LICENSE); engine ghi là chuyển từ OpenKey (GPL-3.0) | được ở cả hai trường hợp |

Số "ca" là số hàng trong TSV. "Bỏ" ghi đơn vị: ca (một chuỗi phím) hoặc test (một hàm test của họ).

### 5.1 bamboo-core (Go)

- https://github.com/BambooEngine/bamboo-core, commit `b2e49a2b48c7d3772a3673142a7747eccd9d5f79` (16/09/2024). MIT, © 2018 Luong Thanh Lam.
- File: `bamboo_test.go` (`rules_parser_test.go`, `utils_test.go` là test hàm nội bộ).
- 67 ca: Telex 66, VNI 1; 60 ca có đáp án chữ, 7 ca họ chỉ kiểm cờ hợp lệ.
- Cấu hình: kiểu "Telex 2" (có `[ ]` và w đứng riêng thành ư) → `telex`; cờ `EstdFlags` = bỏ dấu tự do + `EstdToneStyle`, mà `findToneTarget` cho thấy là kiểu cũ → `tone=classic`; một test bỏ cờ đó → mặc định Dấu; họ kiểm chữ của từ đang gõ, không có ranh giới từ.
- Ba ca đưa chữ dựng sẵn ("tôi", "tối", "chuyển") vào engine rồi gõ tiếp: ghi thành `⟦…⟧`.
- Bỏ: 7 ca D27 (Không có phím gõ nhanh ơ, ư); 4 ca "EnglishMode" (D2 (Chuyển Việt/Anh)); 2 test "khôi phục từ vừa gõ"; 3 ca bố cục "Microsoft layout"; 1 ca trùng; benchmark; 6 test hàm nội bộ.

### 5.2 ibus-bamboo (Go)

- https://github.com/BambooEngine/ibus-bamboo, commit `49e03d7a36b8a8b796950c158b545af8cf9707d4` (19/05/2026). GPL-3.0, © 2018 Luong Thanh Lam.
- File: `engine_test.go`, `tests/xtest.data` (14 câu cho script gõ thử X11 của họ, không đáp án).
- 32 ca, tất cả `simple-telex`, `tone=classic`; 15 ca có đáp án. Kiểu "Telex" của bamboo (w chỉ biến đổi u, o, a; không `[ ]`) đúng là Telex đơn giản của Dấu.
- Bỏ: 12 test bật macro (D3 (Không macro, chỉ Unicode dựng sẵn)); 8 test lặp chuỗi phím đã có; 6 test Ctrl+A hoặc sự kiện rỗng; 3 test emoji và hàm phụ.

### 5.3 fcitx5-unikey (C++, engine ukengine của UniKey)

- https://github.com/fcitx/fcitx5-unikey, commit `ed9170c35c1a6275d105e03d7f9bc4f674c1469c` (05/09/2026). Thư mục test GPL-2.0-or-later, © 2021 CSSlayer.
- File: `test/testunikey.cpp`.
- 1.325 ca, tất cả `telex`; 1.324 có đáp án: 1.307 mục đang chạy của `expectedTelexData` (mỗi chuỗi phím rồi Return), 11 ca đầu `testBasic`, 6 ca dùng chữ quanh con trỏ (`⟦…⟧`), 1 ca `testType`.
- Cấu hình: Telex của UniKey → `telex`; `ModernStyle` mặc định tắt → `tone=classic`; `expectedTelexData` chạy với `AutoNonVnRestore=False`, `SpellCheck=False` → `autoRestore=off;src:spellcheck=off`. Đáp án `testBasic` là hàng đợi chữ commit; nhóm `baao␣` (Macro và ModifySurroundingText tắt) chỉ commit phần sau chữ b, `their_note` ghi "committed part only" (cách đọc mã của người trích).
- Bỏ: 414 mục của bảng đang bị comment trong mã của họ.

### 5.4 goxkey (Rust, macOS)

- https://github.com/huytd/goxkey, commit `b197c57218ceb9096c341a9862acfabf7cb6932b` (23/09/2026). BSD-3-Clause, © 2023 Huy Tran. Engine là vi-rs (mục 5.5).
- File: `src/main.rs`. 4 ca: Telex 3, VNI 1, đều có đáp án.
- Bỏ: 2 test gọi hàm khôi phục với chữ mà chuỗi phím không sinh ra được; 1 test danh sách từ được phép (D4); 1 test kiểu Telex+VNI gộp; 76 test hàm nội bộ.

### 5.5 vi-rs (Rust)

- https://github.com/zerox-dg/vi-rs, commit `192e246d37e83094a1228e798b160f3cee14c879` (22/06/2026). MIT, © 2020 Hung Nguyen.
- File: `testdata/input/simple_telex.txt`, `non_vietnamese_telex.txt`, `simple_vni.txt`, `non_vietnamese_vni.txt` (đáp án: các file `.snap` trong `testdata/output/`), `tests/incremental.rs`.
- 182 ca: Telex 139, VNI 43; 170 có đáp án. Họ biến đổi từng từ riêng (không ranh giới từ, không khôi phục), nên mỗi từ là một ca, không có `␣`. Mặc định kiểu mới; 1 ca kiểu cũ.
- Bỏ: `all_telex.txt`, `all_vni.txt` (kho lớn, mục 6); 20 test hàm nội bộ; 2 test không có chuỗi phím.

### 5.6 ibus-teni (Go)

- https://github.com/teni-ime/ibus-teni, commit `a3824854c0f5e85dcfea66d984b9bad0c16c2bf2` (10/04/2020). GPL-3.0-or-later, © 2018 Nguyen Cong Hoang.
- File: `test-data/*.tdata` (mỗi dòng: đáp án, dấu cách, chuỗi phím; chuỗi phím do `test-data/test-data-gen.go` của họ sinh từ từ điển trong `dict/`, theo ba thứ tự gõ), `src/teni/teni_coverage_test.go`.
- 3.050 ca: Telex 1.533, VNI 1.517; 3.049 có đáp án. Gồm `nodict`, `vietnamese.std.dict.*` (kiểu cũ → `tone=classic`), `vietnamese.new.dict.*` (kiểu mới), `vietnamese.sp.dict.*` (viết tắt, từ mượn có đ) và 4 ca của `teni_coverage_test.go`. Mọi ca mang `src:dictionary`; họ kiểm chữ giữa từ.
- Quy đổi: "Teni" → `telex`; file `.telexw` (có `[ ]`) chỉ giữ ca không có ngoặc.
- Bỏ: 11 ca D27; 1 dòng khung test của họ cũng bỏ; `vietnamese.cm.dict.*` (kho lớn).

### 5.7 uvie-rs (Rust)

- https://github.com/uvie-project/uvie-rs, commit `555ef9dd31b6bf208343a70484e84db79f1bddfe` (21/10/2026). MIT OR Apache-2.0, © 2026 thuupx.
- File: `tests/*.rs`. Trích tự động `type_seq`, `type_seq_vni`, `type_diff`, hàm phụ hai tham số, vòng lặp trên mảng cặp, chuỗi `type_chars`/`press_space`/`press_backspace` và hàm phụ xoá một chữ kèm kiểm `screen`, vòng trên chuỗi và mảng chữ.
- 947 ca: Telex 925, VNI 22; 922 có đáp án.
- Cấu hình: `set_modern_orthography` mặc định tắt → `tone=classic`; "english override" mặc định bật → `src:englishDictionary`; `set_quick_start` → `advanced=consonantShortcuts`; `set_relaxed_coda` → `src:relaxedCoda=on`.
- Bỏ: 14 ca Quick Telex (`docs/Decisions.md` mục "Đã biết nhưng không làm"); 3 test đọc file dữ liệu (kho lớn); 9 test chỉ in kết quả; 68 test không trích được (bảng nội bộ, kích thước diff, lịch sử sửa từ, bất biến ngẫu nhiên).

### 5.8 ibus-telex (Rust)

- https://github.com/manhavn/ibus-telex, commit `fb522b4804c2ef8496ec8746f7b1e4043b3716c2` (05/10/2026). GPL-3.0-or-later (khai trong `Cargo.toml`), tác giả commit Bùi Văn Mạnh.
- File: `tests/parity_corpus.tsv` (chuỗi phím và kết quả họ ghi là chụp từ ibus-unikey 0.7.0), `tests/typing.rs`.
- 323 ca: Telex 311, VNI 10, Telex đơn giản 2; tất cả có đáp án.
- Quy đổi: mặc định của họ (kiểu cũ) → `tone=classic`; `standalone_w: false` → `simple-telex`; `free_marking: false` → `freeMarking=off`; `spell_check: false` → `src:spellcheck=off`; khung `parity.rs` gõ thêm một Space rồi bỏ dấu cách cuối, nên ca corpus kết thúc bằng `␣`, `their_note` ghi rõ.
- Bỏ: 9 ca D27; 2 test chỉ gọi API; `keys.rs`, `protocol.rs`.

### 5.9 gonhanh.org — Gõ Nhanh (Rust, macOS)

- https://github.com/khaphanspace/gonhanh.org, commit `1fdac7aec67663f2c23df6addfb13c59bbc5f374` (05/11/2026). BSD-3-Clause, © 2025 Gõ Nhanh Contributors.
- File: `core/tests/*.rs`. Trích tự động mảng hằng cặp phím/đáp án và các hàm `telex`, `vni`, `telex_auto_restore`, `telex_traditional`, `vni_traditional`; hàm phụ, vòng lặp, chuỗi `type_word`; `restore_and_type` → `⟦…⟧`; chuỗi mã phím `on_key` (chỉ phím). `<` của họ là Backspace → `⌫`.
- 4.110 ca: Telex 3.680, VNI 411, Telex đơn giản 19; 3.992 có đáp án.
- Cấu hình: mặc định kiểu mới, "English auto-restore" tắt → `autoRestore=off`, bật → `src:englishDictionary`; `set_modern_tone(false)` → `tone=classic`; `set_allow_foreign_consonants(true)` → `advanced=allowZFWJ`; `set_skip_w_shortcut(true)` → `simple-telex`; `set_free_tone(true)` → `src:spellcheck=off`; hàm tạo engine trong file test (`engine_on()`, `engine_off()`, `setup()`) đọc như `Engine::new()` cộng các lệnh `set_…` bên trong.
- Bỏ: 34 test viết hoa đầu câu và 62 test macro (D3); 4 ca D27; 124 ca `rstest` sinh lúc chạy; 13 test đọc file dữ liệu hoặc sinh đầu vào; 43 test không trích được; kho `core/tests/data/`.

### 5.10 XKey (Swift, macOS)

- https://github.com/xmannv/xkey, commit `398e78e9c1a92f740d5cbf1673914a3b3c458eff` (11/10/2026). MIT, © 2025 XKey.
- File: `XKeyTests/VNEngineTests.swift`, `VNEngineBackspaceRestoreTests.swift`, `VNEngineBufferIntegrationTests.swift`, `TypingBufferTests.swift` (chuỗi `processKey`/`typeWord`/`typeTelex`/`vni([...])` và các lần kiểm `getCurrentWord()`), danh sách `corpus` của `ScreenSimulationTests.swift` (chỉ phím).
- 263 ca: Telex 240, VNI 23; 234 có đáp án (từ đang gõ). Hai nhánh của một `if … else` trên trạng thái engine của họ là hai ca riêng; `their_note` ghi điều kiện của nhánh.
- Engine của XKey ghi là bản chuyển từ engine OpenKey (`XKey/Core/Engine/VNEngine.swift`), nên đáp án gần với hành vi OpenKey (`docs/research/OpenKeyNotes.md` mục 4).
- Cấu hình: mặc định kiểu mới, kiểm tra chính tả và khôi phục bật, **Quick Telex bật**: ca có cặp phụ âm đôi mà Quick Telex có thể đổi thì bỏ, ca còn lại chạy với mặc định Dấu; `vUseModernOrthography = 0` → `tone=classic`; `vCheckSpelling = 0` → `src:spellcheck=off`; `vCustomConsonants` → `advanced=allowZFWJ` và/hoặc `src:customConsonants`.
- Bỏ: `XKeyTests/Resources/telex_test_suite.csv` (8.046 ca, chính tác giả ghi là do một engine khác sinh ra, không nêu engine hay giấy phép); 4 test macro và file viết hoa đầu câu (D3); 14 ca D27; 1 ca Quick Telex; kiểu "adaptive" Telex+VNI; 166 test không có chuỗi phím kèm kiểm chữ; các file test của phần ứng dụng.

## 6. Không trích; nguồn chưa xem

**Không trích:**
- Kho lớn sinh máy móc (vi-rs `all_*.txt`, ibus-teni `vietnamese.cm.dict.*`, `tests/data/` của uvie-rs và `core/tests/data/` của gonhanh): bảng phủ toàn bộ âm tiết hoặc danh sách từ, không phải ca người viết chọn; Dấu đã thử trên kho âm tiết của riêng mình (mốc M1 (Engine)). Để sau; khi cần thì thêm vào `extract.sh` (vài chục nghìn ca mỗi nguồn).
- Test sinh lúc chạy (`rstest`, hoán vị, bất biến ngẫu nhiên): đầu vào không nằm trong mã.
- Test API (số Backspace, cờ hợp lệ, cấu trúc bộ đệm, hoàn tác): không phải chuỗi phím với chữ mong đợi.
- Tính năng Dấu không có: macro, viết hoa đầu câu, bảng mã cũ (D3); chế độ Anh riêng (D2); `[ ]` thành ơ ư (D27); Quick Telex; Telex+VNI gộp; danh sách từ được phép (D4); Esc khôi phục chuỗi phím (D4).
- ibus-unikey, OpenKey, fcitx5-bamboo: không có bộ test chuỗi phím.

**Nguồn đã thấy nhưng chưa xem** (GitHub, 05/11/2026; chưa clone, chưa kiểm giấy phép): bogo-python (BoGoEngine, GPL-3.0); avim (1ec5, MIT); vietc (vndangkhoa, MIT); Funput (MIT); ibus-mangrs (fundokukiri, GPL-3.0, README nói có bảng 480 ca); bamboo-core bản Rust (bamboo-vi, MIT); TypeVN, gotivi, InputKey, unikey-rust; 1xkey-src (GPL-3.0); daukey (emizuki, GPL-3.0); PHTV. Nhiều repo mới năm 2026 có bộ test lớn sinh tự động; nên ưu tiên repo có lịch sử và người dùng thật. Nguồn tra: `gh search repos "vietnamese input method"`, https://github.com/topics/telex, https://github.com/topics/vni, https://github.com/topics/vietnamese-ime, https://formulae.brew.sh/cask/gonhanh.
