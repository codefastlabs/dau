# Ghi chú đọc mã nguồn OpenKey

Tài liệu tham khảo cho engine (M1 (Engine) trở đi): OpenKey làm gì, ở đâu Dấu làm khác và vì sao. Viết bằng lời của Dấu, **không chép mã**. Theo D10 (Engine tự viết), kết quả mong đợi trong test viết theo chính tả tiếng Việt và `docs/Decisions.md`, không lấy từ OpenKey. Bản trước (danh sách ca biên đã duyệt, các điểm mơ hồ đã chốt ngày 29/10/2026): `docs/history/ResearchLog.md` mục 2.

## Hiện trạng (12/11/2026)

- **Đã đọc:** OpenKey https://github.com/tuyenvm/OpenKey, commit `89c2fd3` (15/06/2026), clone ra ngoài repo; `Sources/OpenKey/engine/` (`Engine.cpp`, `Engine.h`, `Vietnamese.cpp`, `DataType.h`, `Macro.cpp`, `SmartSwitchKey.cpp`, `ConvertTool.cpp`, `platforms/mac.h`) và `macOS/ModernKey/OpenKey.mm` để biết engine được gọi thế nào.
- **Không chạy.** Mọi hành vi dưới đây có từ lần theo mã; chỗ chưa chắc ghi "(suy luận)". D10 cấm dùng OpenKey làm đáp án, nên không chạy để kiểm chứng. Test của XKey (engine chuyển từ OpenKey) cho một phần đối chiếu (mục 4).
- **Kiến trúc khác hẳn:** OpenKey chặn phím bằng event tap, gửi Backspace giả, giữ một bộ đệm toàn cục theo mã phím vật lý. Dấu là bộ gõ InputMethodKit, mỗi ô nhập một engine, nhận ký tự (mục 1).
- **Dấu làm phần lớn tính năng gõ của OpenKey**, theo D15 (Cài đặt mặc định) và các quyết định ở mục 2. Không làm: macro, viết hoa đầu câu, bảng mã cũ, chuyển mã, smart switch, phím chuyển và tạm tắt riêng, Quick Telex, `[ ]` thành ơ ư (`docs/Decisions.md` mục "Đã biết nhưng không làm").
- **Chỗ Dấu cố ý khác OpenKey ở cùng một tính năng:**

| Điểm | OpenKey | Dấu |
|---|---|---|
| Ranh giới từ có khôi phục | Space và một tập dấu câu; không có `! ( )` (B10); mũi tên cũng khôi phục | mọi ký tự kết thúc từ có in ra; mũi tên, Esc, chuột, tổ hợp phím chỉ reset (D4 (Từ nước ngoài), D21 (Gõ tắt phụ âm)) |
| Điều kiện khôi phục | chỉ khi có nguyên âm mang dấu/mũ/móc (B7) | mọi chữ không phải âm tiết hợp lệ khi kết thúc từ (D4, D31 (Âm tiết tiếng Việt hợp lệ)) |
| Âm tiết hợp lệ | không xét c/k/q, g/gh, ng/ngh, p cuối với huyền/hỏi/ngã (B5, B6) | bảng vần tự lập, có các luật đó (D31) |
| Gõ tắt phụ âm | mở rộng rồi giữ, kể cả ra chữ không hợp lệ ("big" → "bing", B9) | mở rộng rồi kiểm lại, không hợp lệ thì khôi phục (D21) |

| "uơ"/"ươ" | luôn "ươ", trừ sau "th", "q"; phân biệt hoa thường (B4) | theo vị trí cặp trong từ (D35 ("uơ" và "ươ")) |
| Telex đơn giản | Simple Telex 1 có w → qu | không có w → qu (D29 (Telex đơn giản), D23 (w → qu chỉ ở VNI)) |
| "Bỏ dấu tự do" | biến `vFreeMark` nghĩa là "không dời dấu", và bị ghi đè 0 khi khởi động (B18) | gõ phím dấu ở đâu cũng được, dấu tự dời (D28 (Bỏ dấu tự do)) |
| Kiểm tra chính tả | có công tắc | luôn chạy (D30 (Kiểm tra chính tả)) |
| Từ dài | bộ đệm 32 phần tử, dịch trái (B15) | quá 7 chữ cái thì khôi phục ngay, phím sau đi thẳng (D33 (Độ dài từ)) |
| Backspace | bỏ một chữ hiển thị và một phím gốc, hai bộ đệm có thể lệch; có lịch sử từ qua dấu cách (B12) | bỏ chữ cuối, mốc khôi phục là chữ đang hiển thị (D32 (Backspace)); không có lịch sử từ |
| Thêm dấu cho từ đã gõ | không có | có, cho cả phím dấu và phím biến đổi (D20 (Thêm dấu cho từ đã gõ)) |
| VNI | 7 sau "a", 8 sau "o"/"u" làm bộ đệm lệch màn hình (B13) | chữ số không áp được thì đi thẳng; chữ số sau âm tiết hợp lệ thành dấu (D36 (VNI: chữ số thành dấu)) |
| Chữ hoa | một số luật so cả cờ hoa nên chữ hoa ra khác chữ thường (B4, B14) | phím biến đổi không đổi kiểu hoa (D34 (Chữ hoa với phím biến đổi)) |

- Ca thử cho từng điểm khác, kèm tên test: mục 5. Lỗi và điểm lạ của OpenKey để Dấu tránh: mục 3 (B1–B19; mã engine của Dấu dẫn theo các mã này).
- Quy ước: `␣` là phím Space. "Bộ đệm" là từ đang gõ.

## 1. Kiến trúc engine OpenKey

- **Trạng thái là biến toàn cục** (`Engine.cpp`): mọi ứng dụng dùng chung một bộ đệm. Dấu có một `VietEngine` cho mỗi client.
- **Đầu vào là mã phím vật lý** (theo vị trí bàn phím US, `platforms/mac.h`), nên Dvorak/AZERTY bị hiểu sai trừ khi bật "layout compat". Engine của Dấu nhận `Unicode.Scalar`.
- **Đầu ra** gồm mã hành động (không làm gì, xử lý, khôi phục, thay macro, khôi phục rồi mở từ mới), số Backspace cần gửi và chuỗi ký tự mới. Tầng macOS gửi Backspace giả rồi gõ chuỗi mới qua event tap (Dấu đã loại cách này: `docs/Decisions.md` mục "Đã cân nhắc và loại bỏ"). Khi khôi phục, tầng macOS tự gõ thêm phím vừa nhấn.
- **Hai bộ đệm song song**, mỗi bộ 32 phần tử: bộ đệm chữ (chữ cái kèm cờ hoa, mũ, móc/trăng, dấu thanh, "w đứng riêng") và bộ đệm phím gốc dùng để khôi phục.
- **Cờ "tạm tắt xử lý"** (`tempDisableKey`) bật khi từ sai chính tả hoặc vừa gõ đúp; khi bật, mọi phím biến đổi còn lại đi thẳng như chữ thường. Bộ đệm chỉ reset ở ranh giới từ.
- **Lịch sử từ trong dòng** (`_typingStates`): Backspace lùi qua dấu cách lấy lại từ trước để sửa tiếp (mục 2.17).
- OpenKey gửi lại cả đoạn từ vị trí đổi sớm nhất tới cuối từ. Engine của Dấu so phần đầu chung giữa chữ đang hiển thị và chữ mới, chỉ xoá và chèn phần khác (`VietEngine.commonPrefix`), nên số chữ thay là nhỏ nhất.

## 2. Từng tính năng

| # | Tính năng OpenKey (biến cấu hình) | Dấu |
|---|---|---|
| 1 | Telex | D15 |
| 2 | VNI | có (mục 2.4) |
| 3 | Simple Telex 1 và 2 | một kiểu "Telex đơn giản" (D29; mục 2.5) |
| 4 | Đặt dấu kiểu mới/cũ (`vUseModernOrthography`) | D15, mặc định kiểu mới |
| 5 | Bỏ dấu tự do (`vFreeMark`) | D28, nghĩa khác (mục 2.7) |
| 6 | Kiểm tra chính tả (`vCheckSpelling`) | D30, D31 |
| 7 | Khôi phục khi sai chính tả (`vRestoreIfWrongSpelling`) | D4 |
| 8 | Gõ đúp phím dấu để giữ chữ gốc | D26 |
| 9 | Quick Telex (`vQuickTelex`) | không làm |
| 10 | Gõ tắt phụ âm đầu (`vQuickStartConsonant`: f→ph, j→gi, w→qu) | D21, D22 (Gõ tắt loại trừ z, f, w, j), D23 |
| 11 | Gõ tắt phụ âm cuối (`vQuickEndConsonant`: g→ng, h→nh, k→ch) | D21 |
| 12 | Cho phép z, f, w, j (`vAllowConsonantZFWJ`) | D22 |
| 13–16 | Macro, viết hoa đầu câu, bảng mã cũ, công cụ chuyển mã | không làm (D3 (Không macro, chỉ Unicode dựng sẵn)) |
| 17–18 | Smart switch, nhớ bảng mã theo ứng dụng | không làm (D5 (Quy tắc theo ứng dụng), D2 (Chuyển Việt/Anh), D3) |
| 19–21 | Phím chuyển Việt/Anh riêng, tạm tắt chính tả bằng ⌃, tạm tắt bộ gõ bằng ⌘ | không làm (D2, D30) |
| 22 | Tắt tiếng Việt khi bàn phím hệ thống không phải tiếng Anh (`vOtherLanguage`) | không cần: Dấu tự là một nguồn nhập liệu (suy luận) |
| 23 | Sửa gợi ý tự hoàn thành của trình duyệt, gửi từng phím | không làm mẹo của event tap; gợi ý bôi đen sau con trỏ được thay cùng từ trong một `insertText` (D11 (Kiểm tra ngữ cảnh)) |
| 24 | `[` → ơ, `]` → ư | không làm (D27 (Không có phím gõ nhanh ơ, ư)) |
| 25 | Lịch sử từ qua Backspace | không làm; D20 phủ ca này |
| 26 | Thêm dấu cho từ đã gõ | OpenKey không có; D20 |
| 27 | Giới hạn độ dài từ | D33 |
| 28 | Backspace trong từ | D32 |

### 2.1 Telex: các phím biến đổi

Phím được xử lý (`IS_SPECIALKEY`): `a e o w d s f r x j z` và, chỉ ở Telex, `[ ]`.

- **aa → â, ee → ê, oo → ô** (`insertAOE`): phím không cần sát nguyên âm, engine tìm ngược chữ cùng loại gần nhất nếu đuôi từ khớp một mẫu vần (`_vowel`): "viet" + `e` → "viêt". Nguyên âm đang có móc/trăng thì đổi sang mũ ("ă" + `a` → "â").
- **aw → ă, ow → ơ, uw → ư** (`insertW`). Cụm hai nguyên âm: "uo" → "ươ" (sau "th" chỉ móc "o", để có "thuở", trừ khi theo sau là "n"; sau "q" chỉ móc "o"); "ua", "ui", "uu", "oi" móc chữ đầu; "io", "oa" móc chữ sau; cụm khác thì w không làm gì và tạm tắt cả từ. w cũng bỏ mũ ("â" + `w` → "ă").
- **Tự sửa "ưo"/"uơ" thành "ươ"** (`checkGrammar`) khi sau "uo" có n, c, i, m, p, t.
- **w đứng riêng → ư** (`checkForStandaloneChar`, không có ở Simple Telex 1): w đầu từ; sau đúng một phụ âm, trừ w, e, y, f, j, k, z (`_standaloneWbad`, có lẫn e, y); sau tr, th, ch, nh, ng, kh, gi, ph, gh. Gõ w lần nữa thì về chữ "w".
- **dd → đ** (`insertD`): d thứ hai có thể sau nguyên âm và phụ âm cuối ("did" → "đi"). Luật lạ: d sau một phụ âm khác luôn được nhận và gỡ cờ tạm tắt (B19).
- **`[` → ơ, `]` → ư**: gõ đúp ra ngoặc, ngoặc là ranh giới từ.
- **w → qu không bao giờ chạy ở Telex**: w đầu từ đã thành "ư" trước khi xét gõ tắt; gõ `ww` thì bật cờ tạm tắt, mà gõ tắt cần cờ này tắt. Ở Simple Telex 1 thì có (mục 2.5).

Dấu: D23, D26, D27, D28, D35; khác OpenKey ở "uơ"/"ươ" (B4, D35) và `[ ]` (D27).

### 2.2 Phím dấu thanh s f r x j và z

- Phím dấu chỉ có tác dụng khi đuôi từ khớp mẫu vần `_vowelForMark`, không thì là chữ ("b" + `s` → "bs"). Gõ phím dấu khác thì đổi dấu. Gõ được sau phụ âm cuối ("vieetj" → "việt").
- `checkCorrectVowel` chặn f, r, x khi vần kết thúc bằng c hoặc t, nhưng không chặn với p ("cap" + `f` → "càp", B5).
- **z xoá dấu thanh** (`removeMark`), không xoá mũ hay móc; không có dấu thì z là chữ.

Dấu: D31 (vần tắc chỉ sắc/nặng), D40 (Chữ dựng sẵn và phím z).

### 2.3 Gõ đúp để giữ chữ gốc

**OpenKey:**
- Gõ lại cùng phím dấu, phím mũ, w hoặc d thì bỏ biến đổi và thêm phím đó như chữ: "as" + `s` → "as", "â" + `a` → "aa", "đ" + `d` → "dd", "ư" (w đứng riêng) + `w` → "w".
- Sau gõ đúp, cờ tạm tắt bật (cũng là cờ "từ sai chính tả"): phím biến đổi gõ sau đều là chữ ("tess" + `t` → "test").
- Khi bật kiểm tra chính tả, mỗi lần thêm chữ hay Backspace engine kiểm lại phần chữ đang có và đặt cờ theo kết quả. Chữ còn lại sau gõ đúp thường không hợp lệ nên khoá thường giữ tới hết từ; nhưng Backspace về lại chữ hợp lệ thì khoá mở ("nhâmf" ⌫ → "nhâm", rồi `f` đặt dấu). Đọc mã, chưa chạy.
- Ngoại lệ "oo": "ô" + `o` → "oo" không bật cờ (để gõ "thoòng"), nên "xooongf" → "xoòng".
- Bộ đệm phím gốc bớt một phím sau gõ đúp ("car", không phải "carr"), nên lần khôi phục sau trả về đúng chữ đang hiển thị.

**Dấu (D26 (Gõ đúp phím dấu)):** cùng luật, kể cả phím biến đổi và VNI ("a11" → "a1"), cùng ngoại lệ "ooo". Backspace: Dấu mở khoá khi ⌫ xoá chữ của phím gõ đúp ("nhâmf" ⌫ rồi `f` → "nhầm", "aaa" ⌫ a → "â"). Điều kiện khác OpenKey (xoá chữ đó, thay vì về lại chữ hợp lệ) nhưng kết quả trùng ở các ca đã xem: khi chữ của phím gõ đúp còn hiện, từ không phải tiếng Việt nên OpenKey vẫn khoá; khi phần còn lại không hợp lệ, D30 (Kiểm tra chính tả) của Dấu vẫn khoá.

### 2.4 VNI

- 1 sắc, 2 huyền, 3 hỏi, 4 ngã, 5 nặng; 6 mũ cho a/e/o gần cuối từ nhất; 7 móc cho o/u (cả "uo" → "ươ"); 8 trăng cho a; 9 đ; 0 xoá dấu. Gõ đúp số thì huỷ như Telex.
- Số gõ khi bộ đệm rỗng và Shift+số là ranh giới từ, nên "2024" đi thẳng.
- w ở VNI là chữ, nên gõ tắt w → qu có tác dụng ("wen␣" → "quen␣").
- 7 gặp "a" (không có "u" trước) hay 8 gặp "o"/"u": engine báo "đã xử lý" mà không đổi gì và không ghi phím, trong khi phím vẫn ra ứng dụng; bộ đệm và màn hình lệch (B13, suy luận).

Dấu: D36, D23; khác OpenKey ở B13.

### 2.5 Simple Telex

OpenKey có hai biến thể; phím dấu, aa/ee/oo, aw/ow/uw, dd và z giống Telex. Khác ở:

| | Telex | Simple Telex 1 | Simple Telex 2 |
|---|---|---|---|
| `[` → ơ, `]` → ư | có | không (ngoặc là ký tự thường, kết thúc từ) | không |
| w đứng riêng → ư | có | **không**: w chỉ biến đổi sau a/o/u | có |
| w → qu khi bật gõ tắt phụ âm đầu | không bao giờ (mục 2.1) | **có**, vì w đầu từ còn là w | không |

Mã không có khác biệt nào khác (đã tìm mọi nhánh theo kiểu gõ trong `Engine.cpp`, `DataType.h`).

Dấu: D29 theo Simple Telex 1 nhưng bỏ w → qu (D23 chỉ VNI). Telex đơn giản có sẵn của macOS hoạt động ra sao thì chưa kiểm chứng, không có tài liệu Apple; đo được bằng `scripts/selftest/typing/run.sh --source com.apple.inputmethod.VietnameseIM.VietnameseSimpleTelex` khi trang so sánh M10 cần.

### 2.6 Đặt dấu kiểu mới, kiểu cũ

`handleModernMark`, `handleOldMark`. Engine bỏ "u" sau "q" và "i" sau "g" khỏi cụm nguyên âm (`findAndCalculateVowel`); "gì" đi qua một nhánh riêng.

Kiểu mới:
- một nguyên âm: dấu trên nó; oai, oeo, uyu, uya: ở giữa; oi, ai, ui, ay và cụm có chữ thứ hai là o/u: chữ đầu;
- cụm bắt đầu bằng o/u (oa, oe, uy, uê…): chữ sau, tức **hoà, hoè, thuý**;
- iê, yê, uô, ươ: chữ thứ hai nếu sau đó còn phụ âm hoặc nguyên âm;
- ia, iu, io: chữ đầu; ua không có q và không có phụ âm cuối: chữ đầu ("mùa"); có q: chữ sau ("quá"); oo: chữ cuối ("xoòng").

Kiểu cũ: mặc định nguyên âm đầu; cụm ba nguyên âm hoặc cụm có phụ âm cuối hợp lệ: chữ thứ hai; cụm có ê, ơ: chữ đó. Kết quả **hòa, hòe, thúy**. Hai kiểu chỉ khác ở oa, oe, uy không có phụ âm cuối.

Điểm lạ trong mã: B2, B3, B4. Dấu: D15.

### 2.7 Bỏ dấu tự do

- Sau mỗi phím, nếu từ có dấu thanh, engine gỡ ra và đặt lại theo cụm nguyên âm hiện tại (`checkGrammar`): "ho" + `f` → "hò", thêm `a` → "hoà".
- Biến `vFreeMark` nghĩa ngược với tên: bật thì **không** đặt lại dấu. Bản macOS luôn gán 0 khi khởi động (`OpenKey.mm`), nên trên thực tế dấu luôn được đặt lại và nút "FreeMark" chỉ có tác dụng tới lần mở app sau (B18).

Dấu: D28, nghĩa khác `vFreeMark` (phím dấu gõ ở đâu cũng được; tắt thì phải gõ sát nguyên âm).

### 2.8 Kiểm tra chính tả âm tiết

`checkSpelling` chạy sau mỗi phím thêm như chữ; ở ranh giới từ chạy thêm chế độ "ép" có kiểm tổ hợp nguyên âm.
- Phụ âm đầu: ngh, ph, th, tr, gi, ch, nh, ng, kh, gh, g, c, q, k, t, r, h, b, m, v, n, l, x, p, s, d, đ; thêm f, w, z, j khi bật "cho phép zfwj", hoặc f, w, j khi bật gõ tắt phụ âm đầu.
- Nguyên âm tối đa 3 chữ; ở chế độ ép cụm phải nằm trong `_vowelCombine`, mỗi mục có cờ "được có phụ âm cuối".
- Phụ âm cuối: c, ch, m, n, ng, nh, p, t; thêm g, h, k khi bật gõ tắt phụ âm cuối.
- Vần kết thúc t hoặc ch không mang huyền, hỏi, ngã.
- **Không** kiểm: phân bố c/k/q, g/gh, ng/ngh; p cuối với huyền/hỏi/ngã, c cuối khi phím dấu gõ trước phụ âm cuối (B5); ă/â đứng cuối âm tiết; âm tiết tắc không dấu (B6).

Dấu: D30, D31 (có "p" đầu từ, có các luật phân bố, bảng vần tự lập, vần tắc chỉ sắc/nặng và không dấu là sai, ă/â không đứng cuối trừ chữ đứng một mình).

### 2.9 Khôi phục khi sai chính tả

- Chỉ chạy khi bật cả kiểm tra chính tả, ở Space hoặc phím ranh giới từ (mục 2.16). Cờ tạm tắt đang bật thì thay cả từ bằng chuỗi phím gốc, rồi tầng macOS gõ thêm phím vừa nhấn ("Sunrise␣").
- Điều kiện ẩn (`checkRestoreIfWrongSpelling`): chỉ khôi phục nếu có nguyên âm mang dấu, mũ hoặc móc; từ chỉ bị đổi phụ âm (đ, Quick Telex) thì không (B7).
- Từ trùng Anh–Việt hợp lệ (car → cả, test → tét) không bị khôi phục.

Dấu: D4; khác OpenKey ở B7.

### 2.10 Quick Telex

Gõ hai lần c, g, k, n, q, p, t thì ra ch, gi, kh, ng, qu, ph, th (`handleQuickTelex`), ở **bất kỳ vị trí nào** trong từ ("conn" → "cong"), nên phá từ tiếng Anh có phụ âm đôi và theo B7 không được khôi phục ("connect" → "congect"). Chữ hoa của chữ đầu lấy theo phím thứ hai (B14). Dấu không làm (`docs/Decisions.md` mục "Đã biết nhưng không làm"); gõ tắt phụ âm (D21) là tính năng khác.

### 2.11 Gõ tắt phụ âm

- `checkQuickConsonant`, chỉ khi từ có từ 2 chữ: đầu từ f → ph, j → gi, w → qu; cuối từ g → ng, h → nh, k → ch sau nguyên âm. Chữ thứ hai của phụ âm mở rộng chỉ hoa khi cả chữ gốc lẫn chữ kế tiếp hoa ("Fan" → "Phan", "FAN" → "PHAN").
- Chạy ở Space và Return , . / ; ' \ - = (`_macroBreakCode`); không ở Tab, Esc, mũi tên.
- Thứ tự ở Space: macro, rồi gõ tắt, rồi khôi phục, theo kiểu "nếu không thì": gõ tắt chạy được thì không khôi phục.
- Khi bật, kiểm tra chính tả được nới (f, j, w là phụ âm đầu, g, h, k là phụ âm cuối), nên "big␣" → "bing␣" và không kiểm lại (B9). Trong lúc gõ chữ hiện chưa mở rộng ("fán"), chỉ thay ở Space.
- Telex không có w → qu (mục 2.1); Simple Telex 1 và VNI có.

Dấu: D21 (mở rộng rồi kiểm lại, không hợp lệ thì khôi phục; chạy ở mọi ranh giới từ của D4; cùng luật chữ hoa), D23.

### 2.12 Cho phép z, f, w, j

Chỉ nới kiểm tra chính tả, không đổi chữ. Ở Telex w đầu từ đã thành "ư" trước khi xét, nên "cho phép w" không có tác dụng ở Telex. OpenKey cho bật cùng gõ tắt phụ âm; khi đó gõ tắt chạy trước.

Dấu: D22 (hai tuỳ chọn loại trừ nhau; giao diện ghi chú "w" không có tác dụng với Telex).

### 2.13 Chữ hoa, Caps Lock

Mỗi chữ có cờ hoa riêng; Shift hay Caps Lock đều ra hoa, cả hai cùng lúc vẫn hoa. Phím biến đổi không đổi kiểu hoa của chữ bị biến đổi ("Dd" → "Đ", "dD" → "đ"), riêng w đứng riêng lấy kiểu hoa của phím w. Khôi phục giữ chữ hoa như đã gõ. Lỗi: B4, B14.

Dấu: D34.

### 2.14 Chữ số

Ở Telex, số giữa từ là chữ và làm từ sai chính tả; số khi bộ đệm rỗng và Shift+số là ranh giới từ. VNI: mục 2.4.

### 2.15 Từ dài

Bộ đệm 32 phần tử; tràn thì dịch trái và lưu phần đầu ra danh sách phụ (`_longWordHelper`). Bộ đệm phím gốc dịch theo nhịp riêng, nên khôi phục từ dài hơn 32 có thể sai (B15, suy luận).

Dấu: D33.

### 2.16 Ranh giới từ

Từ `_breakCode` và nhánh đầu của `vKeyHandleEvent`:
- Có khôi phục: Space; Esc, Tab, Enter, Return; bốn mũi tên; , . / ; ' \ - = và backtick, kể cả với Shift (? : " | _ + ~ < >); nhấn chuột chỉ reset (tầng macOS bỏ qua kết quả).
- Không khôi phục: Shift+số (! @ # $ % ^ & * ( )) và mọi tổ hợp có ⌘, ⌃, ⌥, Fn ("Sunrise!" giữ chữ đã biến đổi, B10).
- Space không reset ngay mà đếm số dấu cách để Backspace quay lại (mục 2.17).
- Khôi phục bởi phím không in ra (Tab, mũi tên): tầng macOS gõ chuỗi khôi phục rồi gửi lại chính phím đó.

Dấu: D4 (ý "Ranh giới từ"), D21: mọi ký tự kết thúc từ có in ra khôi phục và chạy gõ tắt; mũi tên, Esc, chuột, tổ hợp ⌘/⌃/⌥ chỉ reset, vì con trỏ có thể đã đi chỗ khác.

### 2.17 Backspace và lịch sử từ

- Backspace bỏ một chữ hiển thị và một phím gốc, rồi kiểm chính tả và đặt lại dấu ("hoà" ⌫ → "hò"). Chữ tạo từ nhiều phím ("ệ" = e, e, j) làm hai bộ đệm lệch (suy luận).
- Bộ đệm rỗng, hoặc Backspace xoá dấu cách vừa gõ, thì engine lấy từ trước ra khỏi lịch sử để sửa tiếp ("viet␣" ⌫ `j` → "việt"). Lịch sử bị xoá ở Enter, Tab, mũi tên, Esc, chuột, tổ hợp phím. Lấy ra thì chỉ có bộ đệm chữ, không có phím gốc (B12).
- Không có "Thêm dấu cho từ đã gõ": bộ đệm rỗng (sau khi click vào chữ có sẵn) thì phím dấu là chữ ("hoc" + `j` → "hocj").

Dấu: D32 (mốc khôi phục là chữ đang hiển thị), D20 (không lịch sử từ; phím đầu tiên khi bộ đệm trống đọc lại chữ trước con trỏ).

### 2.18 Mũi tên, chuột, tổ hợp phím

Đều reset bộ đệm; mũi tên còn khôi phục (mục 2.16). Tổ hợp có ⌘/⌃/⌥ reset, riêng tổ hợp với phím dấu câu còn chạy khôi phục (B11, suy luận). Dấu: D4.

### 2.19 Smart switch

Lưu Việt/Anh (cùng bảng mã) theo bundle ID; app gặp lần đầu ghi theo chế độ hiện tại, đổi chế độ thì cập nhật cho app đang dùng (`SmartSwitchKey.cpp`, `OpenKey.mm`). Độ dài bundle ID lưu trong 1 byte, ID dài hơn 255 bị cắt.

Dấu không làm (D5, D2): Dấu chỉ có một input mode tiếng Việt, gõ tiếng Anh bằng U.S.; nhớ nguồn theo cửa sổ là việc của tuỳ chọn macOS "Tự động chuyển sang nguồn đầu vào của tài liệu" (N1 (Không làm lại việc hệ thống đã có)).

### 2.20 Macro, viết hoa đầu câu, bảng mã, chuyển mã

Macro tra cụm vừa gõ ở Space hoặc dấu câu, có thể tự viết hoa theo kiểu gõ và chạy cả ở chế độ Anh. Viết hoa chữ đầu sau ". " hoặc Enter. Bảng mã TCVN3, VNI-Windows, Unicode tổ hợp, CP1258 và công cụ chuyển mã. Dấu không làm (D3), chỉ xuất NFC.

## 3. Lỗi và điểm lạ (B1–B19)

Từ đọc mã; "(suy luận)" là chưa chạy để xác nhận. Đây là danh sách để Dấu **tránh**. Mã B1–B19 cố định; mã nguồn của Dấu (`VietEngine.swift`, `VNITests.swift`) dẫn theo mã này.

- **B1.** `checkForStandaloneChar`: khi w, `[` hoặc `]` là phím đầu từ, hàm đọc phần tử ngay trước đầu mảng bộ đệm (hành vi không xác định trong C++); kết quả thường đúng nhờ nhánh bộ đệm rỗng chạy sau.
- **B2.** `handleModernMark`, nhánh iê/yê: dùng AND bit thay cho so bằng, nên khớp cả chữ có mã trùng bit với e; hậu quả bị các luật sau che (suy luận).
- **B3.** `handleModernMark`: hai nhóm điều kiện luôn sai vì so cùng một vị trí với hai chữ khác nhau ("ch/nh/ng sau iê", nhóm "ia/ya/ua"); mã chết.
- **B4.** `insertW`: kiểm "th" và "q" trước "uo" bằng giá trị kèm cờ hoa, nên "thuowr" → "thuở" nhưng "THUOWR" → "THƯỞ"; và chỉ "th" được ngoại lệ, nên "huow" → "hươ" thay vì "huơ". Dấu theo D35.
- **B5.** Ràng buộc dấu với âm cuối tắc không nhất quán: lúc gõ phím dấu chặn f/r/x với c, t, ch nhưng không với p ("capf" → "càp"); phím dấu gõ trước phụ âm cuối thì chỉ `checkSpelling` kiểm, mà hàm này chỉ chặn t và ch ("carc" → "cảc", suy luận). Chính tả đúng: vần p, t, c, ch chỉ mang sắc hoặc nặng.
- **B6.** Không kiểm phân bố c/k/q, g/gh, ng/ngh, và ă/â đứng cuối (mục 2.8).
- **B7.** Chỉ khôi phục khi có nguyên âm mang dấu/mũ/móc: "pdd␣" → "pđ␣" (suy luận), "connect␣" → "congect␣".
- **B8.** Khi bật gõ tắt phụ âm, nhánh dấu câu gọi gõ tắt thay vì kiểm chính tả chế độ ép: từ có tổ hợp nguyên âm sai theo sau là dấu phẩy không được khôi phục, theo sau là Space thì có (suy luận).
- **B9.** Gõ tắt phụ âm chạy trước và chặn khôi phục; chính tả bị nới nên "big" → "bing".
- **B10.** Tập phím kết thúc từ không nhất quán: "Sunrise," được khôi phục, "Sunrise!" thì không.
- **B11.** ⌘ với phím dấu câu (⌘, ⌘. ⌘/) sau một từ sai chính tả vẫn khôi phục và gõ thêm dấu câu, phím tắt gốc có thể bị nuốt (suy luận từ `vKeyHandleEvent`, `OpenKeyCallback`).
- **B12.** Lấy từ khỏi lịch sử (Backspace qua dấu cách) không khôi phục bộ đệm phím gốc: "nhaf␣x" ⌫ ⌫ rồi `k␣` xoá "nhàk" mà chỉ ghi lại "k" (suy luận). Bài học cho D20: mốc khôi phục là chữ đang hiển thị cộng phím mới gõ.
- **B13.** VNI: 7 sau "a", 8 sau "o"/"u" làm bộ đệm lệch màn hình; "a71" có thể mất ký tự (suy luận).
- **B14.** Quick Telex: "Cc" → "ch" (mất chữ hoa) trong khi bộ đệm ghi "Ch" (suy luận).
- **B15.** Từ dài hơn 32: hai bộ đệm dịch theo nhịp khác nhau, khôi phục có thể sai vùng (suy luận).
- **B16.** Trạng thái toàn cục dùng chung mọi ứng dụng; bảng toàn cục bị ghi thêm khoá rỗng trên đường nóng vì tra bằng `[]` của `std::map` (`checkSpelling`, `canHasEndConsonant`). Không an toàn đa luồng.
- **B17.** Dựa trên mã phím vật lý: sai với bố cục không phải QWERTY nếu không bật "layout compat".
- **B18.** Nút FreeMark lưu được giá trị nhưng app ghi đè 0 khi khởi động.
- **B19.** "d sau phụ âm" gỡ cờ tạm tắt, làm từ đã sai bị biến đổi tiếp ("pd" + `d` → "pđ"); không rõ mục đích.

## 4. Đối chiếu với test của XKey (05/11/2026)

XKey (macOS, MIT, commit ở `docs/research/external-test-inputs/README.md` mục 5.10) ghi trong mã rằng engine của họ là bản chuyển engine OpenKey sang Swift, nên test của XKey cho thấy hành vi kiểu OpenKey ở chỗ XKey chưa đổi. Các điểm rút từ lần so ca thử (`docs/research/external-test-inputs/README.md` mục 1, lớp A). Cột OpenKey từ đọc mã; cột XKey là đáp án trong test của họ; cột Dấu là đầu ra engine của Dấu. Theo D10, test của XKey chỉ để tìm ca đáng xem lại.

| Hành vi | OpenKey (đọc mã) | XKey (test của họ) | Dấu |
|---|---|---|---|
| Khoá sau gõ đúp, rồi Backspace | khoá mở lại khi phần còn lại hợp lệ (mục 2.3); suy luận: tắt kiểm tra chính tả thì khoá còn | "nhaamff⌫f" → "nhầm", "ddd⌫d" → "đ" | D26: ⌫ xoá chữ của phím gõ đúp thì mở khoá, "nhaamff⌫f" → "nhầm", "ddd⌫d" → "đ" |
| "ooo" rồi phím dấu | không khoá sau "ooo", phím dấu vẫn đặt dấu (suy luận: "pooor" giữa từ hiện "poỏ") | khoá cả sau "ooo", "pooor" → "poor" (test của họ gọi hành vi cũ là lỗi) | D26, ngoại lệ "ooo" như OpenKey: "pooor" giữa từ hiện "poỏ"; kết thúc từ D4 khôi phục "poor␣"; "xooongf" → "xoòng" |
| Móc trên "uo" cuối từ (VNI "nuo7", Telex "nuow") | luôn "ươ", trừ sau "th", "q" (B4) | "nuo7" → "nươ" | D35: "nuo7" → "nuơ", gõ thêm chữ thì "nuo7c" → "nươc" |
| Âm cuối k | không hợp lệ, trừ khi bật gõ tắt phụ âm cuối | hợp lệ sau mọi nguyên âm ("desk" → "dék", "oaks" → "oák") | D31: chỉ sau ă (Đắk Lắk); "oaks" giữ nguyên, "desk" giữa từ hiện "dék", kết thúc từ khôi phục "desk" |
| Backspace qua dấu cách rồi gõ tiếp | lấy từ trước khỏi lịch sử, nối phím vào (B12) | cũng có lịch sử từ | D20: không lịch sử từ; phím đầu tiên đọc lại chữ trước con trỏ ("du␣⌫j" → "dụ"); chữ cái chỉ nối khi từ ghép còn hợp lệ ("ba␣⌫nj" → "bạn"), không thì bắt đầu từ mới ("ddi␣⌫hocj" → "đihọc") |

## 5. Ca Dấu cố ý khác OpenKey

Kết quả mong đợi theo chính tả và `docs/Decisions.md` (D10), cấu hình mặc định D15 trừ khi ghi khác. Mọi ca này nằm trong test của engine (`Packages/DauEngine/Tests/DauEngineTests`), trừ dòng ghi "chưa có test". Ca kiểm từng tính năng mà Dấu và OpenKey cho cùng kết quả cũng nằm trong các test đó.

| Chuỗi phím | Dấu | OpenKey | Căn cứ | Test |
|---|---|---|---|---|
| `Sunrise!` (và mọi dấu câu) | `Sunrise!` | giữ chữ đã biến đổi | D4; B10 | `EnglishVietnameseTests.everyPrintedBoundaryRestores` |
| `Sunrise←` (mũi tên) | `Sủnise` (chỉ reset) | khôi phục | D4 | `EnglishVietnameseTests.resetDoesNotRestore` |
| `pdd␣` | `pdd␣` | `pđ␣` | D4, D31; B7, B19 | `EnglishVietnameseTests.restoreAtBoundary` |
| `THUOWR`, `huow` | `THUỞ`, `huơ` | `THƯỞ`, `hươ` | D35, D34; B4 | `TransformTests.hornedUO` |
| `a71␣` (VNI) | `a71␣` | có thể mất ký tự | D36; B13 | `VNITests.digitsAsCharacters` |
| từ dài hơn 7 chữ cái + `␣` | giữ nguyên, không mất chữ | có thể sai khi quá 32 | D33; B15 | `EditingTests.sevenLetters` |
| `big␣` (gõ tắt phụ âm bật) | `big␣` | `bing␣` | D21; B9 | `ShortcutTests.consonantShortcuts` |
| `bak␣` (gõ tắt phụ âm bật) | `bak␣` | `bach␣` | D31 | `ShortcutTests.consonantShortcuts` |
| `capf␣` | `capf␣` | `càp␣` | D31; B5 | `SpellingTests.stopFinals` |
| `ghus` | `ghus` | `ghú` (suy luận) | D31; B6 | `SpellingTests.initialDistribution` |

| `u[` (Telex đơn giản), `[ ]` ở Telex | ngoặc là dấu câu | `[` → ơ ở Telex | D27 | `TransformTests.simpleTelexW`, `EnglishVietnameseTests.bracketsArePunctuation` |
| `wen␣` (Telex đơn giản, gõ tắt phụ âm bật) | `wen␣` | `quen␣` (Simple Telex 1) | D29, D23 | chưa có test |
| chữ có sẵn `hoc` + `j` | `học` | `hocj` | D20 | `SeedTests.seeded` |

## Nguồn

- OpenKey: https://github.com/tuyenvm/OpenKey, commit `89c2fd3`.
- XKey: https://github.com/xmannv/xkey (commit và giấy phép: `docs/research/external-test-inputs/NOTICE.md`).
