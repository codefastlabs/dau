# Bốn kịch bản "app trả lời chậm": cơ chế và hướng sửa

Kịch bản A chưa app thật nào đo ra; kịch bản B có ở trình soạn thảo của Cursor 3.30.14 (mục "Hiện trạng"). File này giữ cơ chế và hướng sửa ngắn gọn. Cơ chế của `CursorTracker` ở [`docs/Architecture.md`](../Architecture.md) mục "App trả lời chậm"; số đo Cursor ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.4.

## Hiện trạng (18/11/2026)

- **Kịch bản A: D20 sau ⌫ khi app chậm 3–4 thao tác** (mô hình bộ đệm Chromium, `LateDocument.Cache.chromium`). Chrome thật, trang bận, nhịp người, chuỗi `edit`: đúng 3/3, và ở lần đọc của D20 sau ⌫ Chrome trả vị trí đúng giờ (mục 3). Chậm 1–2 thao tác thì phép chứng minh hiện có đã xử lý (`LateBackspaceMarkTests`). Hướng 2A là phương án áp khi gặp ca thật (mục 1.2).
- **Kịch bản B: app tính vị trí theo từ** (`LateDocument.Origin.word`, dựng từ log trình soạn thảo Cursor 3.29.15, đo 10/11/2026). Ở Cursor 3.30.14, khung agent (⌘L) và ô nhập Agents tính vị trí từ đầu văn bản và gõ đúng. Trình soạn thảo có lúc tính từ đầu văn bản (đúng), có lúc tính từ đầu từ; ở kiểu sau, chuỗi `edit` gõ cách nhau 5 ms sai vài từ mỗi lượt, không do D20 (D20 chờ hay không chờ phím dồn đều sai như vậy). Chưa rõ vì sao trình soạn thảo đổi kiểu (số đo: [`docs/Compatibility.md`](../Compatibility.md) mục 5.4). Mô hình còn trong test (`WordOriginTests`) cho các ca đạt. Hướng 1B và 4A cần đổi N3 và D11 (mục 2.2).
- **Kịch bản C: trang bận, app chậm qua chỗ ngắt từ** (đo 18/11/2026, mục 3): Chrome và Safari sai khi trang bận, cả ở nhịp người gõ nhanh. Nguyên nhân ở Chrome: hạn mức độ chậm của phép chứng minh về 0 ở mỗi chỗ ngắt từ. Đã sửa phần lớn (commit `d171ab9`, mục 3.3): ở phím thay chữ trong từ, app được chậm mọi thao tác kể từ lần cuối nó trả lời đúng lúc. Còn vài ca ở từ có chuỗi thay phức tạp ("được"); Safari là kịch bản D.
- **Kịch bản D: Safari (WebKit) để phím đi thẳng chờ trong hàng** (đo 18/11/2026, mục 5): khi trang chưa nhận kịp phím (phím dồn, trang bận), lần thay của bộ gõ tới trang trước các phím đi thẳng còn chờ, nên chữ của các phím đó dời chỗ. Bản thử sửa 18/11/2026 theo hướng bộ gõ tự chèn ký tự lẽ ra đi thẳng và tự xoá ⌫ (mục 5.3, 5.4) đúng ở các ô đã đo; chưa gộp vào `main`, chưa chọn hướng.
- Cursor không có nhãn "Đề xuất" (D13 (Gạch chân là đường lui cuối cùng)); số đo ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.4.

Không có quyết định nào chờ người dùng ở file này. Phần đo được và phần giả định của mô hình theo từ ghi trong comment của `LateDocument.Origin`; mô hình vị trí tính từ đầu văn bản là `Origin.document`.

## 1. Kịch bản A: D20 sau ⌫, app chậm 3–4 thao tác

### 1.1 Cơ chế

Chuỗi phím `Toi hoc ⌫` gõ đúng giờ, rồi `j` với câu trả lời chậm 3 hoặc 4 thao tác, theo mô hình bộ đệm Chromium. Lần đọc của D20 ở `InPlaceComposer.addMarks`:

- **Chậm 3:** trang mới áp tới "Toi ho". Bộ đệm ghi hai chữ chèn tại con trỏ ("c", rồi dấu cách) cùng vào con trỏ 6, nên ra "Toi ho c" và con trỏ 7. Vị trí 7 trùng `CursorTracker.known` (7), nên `addMarks` không thử chứng minh app chậm. Chữ đọc được là "Toi ho ", tận cùng là dấu cách, nên không có từ. Phím `j` đi thẳng và ra "Toi hocj".
- **Chậm 4:** vị trí 6 khác `known`, nên `CursorTracker.rebuild` được gọi. Ở nhịp người `burst` = 0, nên rebuild chỉ thử tối đa `lateLimit` = 2 thao tác; muốn khớp thì phải thử 4. Rebuild thất bại, chữ đọc được "Toi h " tận cùng là dấu cách, và kết quả cũng ra "Toi hocj".

Không giả thuyết nào một mình giải thích được cả hai ca: vị trí bộ đệm trả trùng `known` nên không ai kiểm chữ giải thích chậm 3; `rebuild` bị giới hạn ở `lateLimit` giải thích chậm 4. Chỉ sửa một phần thì ca kia vẫn sai; sửa cả hai thì cả hai đúng. Lần đọc hỏng (`readUnavailable`, D20 "Phạm vi") không phải nguyên nhân: cả hai lần đọc đều trả chữ.

Lỗi người dùng báo ngày 17/11 ở app Claude ("Hocj") do cơ chế khác ("một lần đọc hỏng trước đó", `failedReadLimit`).

### 1.2 Hướng sửa

**2A (áp khi gặp ca thật).** Chỉ áp ở lần đọc của D20 sau ⌫ (`addMarks`), gồm hai phần:

1. Vị trí trả trùng `known` mà phần cuối chữ đọc được khác `tail` (chữ Dấu đã gõ ở đó): vẫn chạy `rebuild`, cho phép câu trả lời nằm ở `known`.
2. Nới số thao tác được chậm thêm 4 (tức `lateLimit` + 4), nhưng phần nới chỉ nhận dạng (b) của rebuild. Dạng (b) là dạng của bộ đệm Chromium: chữ đọc được kết thúc bằng chữ chèn tại con trỏ mới nhất. Phần nới vẫn qua phép kiểm chặt như phím dồn: mọi thao tác xoá phải biết chữ nó xoá, và `typedHere` phải đạt.

Đánh giá:

- **Quyết định:** không trái N1–N5 hay D nào. D11 cho phép "số thao tác được chậm có giới hạn", và giới hạn vẫn còn; D11 cũng đã nói phép chứng minh dùng cho lần đọc của D20. Không thêm lời gọi nào: lần đọc ở phần 1 chính là lần đọc D20 vốn có, được chuyển cho `seedWord`. Khi áp phải sửa [`docs/Architecture.md`](../Architecture.md) mục "App trả lời chậm" (số thao tác được chậm; trường hợp vị trí trùng `known`).
- **Ràng buộc phải giữ:** test "carr → car, hệ thống sửa thành cả, ⌫r → car" (D20 "Từ hệ thống vừa sửa") phải vẫn đúng. Tự sửa chính tả biến "car" thành "cả", trùng đúng chữ trước 3 thao tác, nên nếu phần nới nhận cả dạng (a), phép dựng lại qua 3 thao tác khớp và Dấu tưởng app chậm. Vì vậy phần nới chỉ nhận dạng (b): chữ đọc được kết thúc bằng chính ký tự Dấu vừa chèn tại con trỏ, ở đây là dấu cách mà ⌫ vừa xoá. App đúng giờ chỉ trả như vậy khi trước con trỏ cũng là dấu cách; khi đó D20 không tìm thấy từ và phím đi thẳng.
- **Rủi ro với app đang đúng:** Chrome, VS Code, Firefox, Safari không đổi trên mô hình (bảng `RapidKeysTests.burstTable`, `stalledStartTable`, `LateAnswerTests.wholeStringLate`).
- **Test khi áp:** ca "Hoc ⌫ j" chậm 3 và 4 trên bộ đệm Chromium ra "Toi học"; giữ `doubleKeyWord` (ràng buộc "carr") và cả bộ "Từ hệ thống vừa sửa"; thêm ca ảnh chụp "Toi hoc␣⌫j" chậm 3–4 (đúng) và hai ca ảnh chụp có lần thay chữ chưa áp ở trên (sai, ghi như giới hạn của mô hình ảnh chụp).
- **Chỉ kiểm được bằng gõ thật ở mức hồi quy:** không gây được chậm 3–4 theo ý muốn (mục 3).

**2B: tin `tail` thay cho chữ đọc được (không đề xuất).** Bỏ qua chữ app trả và dùng chữ Dấu đã gõ. Hướng này trái D20: D20 đọc chữ đang hiển thị, và ý "Từ hệ thống vừa sửa" cần chữ thật. Ví dụ "cat" bị tự sửa thành "cắt", rồi ⌫ s: theo D20 phải tính trên "cắt", nhưng tin `tail` thì tính trên "cat". Khi vị trí trùng `known`, chữ cũ của bộ đệm và chữ hệ thống vừa sửa không phân biệt được bằng vị trí.

**2C: nâng `lateLimit` cho mọi lần đọc (không đề xuất).** Ở phạm vi hẹp của 2A, nhận cả dạng (a) làm hỏng ca "carr", nên nâng cho mọi lần đọc càng rủi ro hơn. Comment của `lateLimit` nêu thêm lý do: ⌘A rồi gõ lại đúng các chữ cũ ở cùng chỗ.

**2D: giữ nguyên (đang áp dụng).** Ở Chrome thật, trang bận, nhịp người, lần đọc này không chậm (mục 3). 2A thêm nhánh vào phép chứng minh của D11 cho một ca chưa thấy ngoài đời, nên chỉ áp khi có ca thật.

## 2. Kịch bản B: app tính vị trí theo từ

### 2.1 Cơ chế

Mô hình app tính `selectedRange` và vùng thay từ đầu từ đang gõ, về 0 sau mỗi dấu cách. Khi phím dồn, câu trả lời có thể còn ở từ trước hay ở từ mới chưa có chữ nào: vị trí tính theo toạ độ của một từ khác, còn `known` tính theo toạ độ tài liệu, nên cả hai đều sai. Ba dạng trên mô hình:

- **Câu trả lời cũ qua ranh giới từ** (phím dồn 5 ms, trang chậm): vùng thay bị bỏ, thay nhầm chữ, hoặc `mismatch` vì vị trí nhỏ hơn số chữ cần xoá. Câu trả lời cũ theo toạ độ của từ khác, nên không vị trí nào Dấu có là đúng; phép chứng minh app chậm nhận nhầm chỉ giải thích một phần các ca.
- **Phím dồn từ đầu từ trong tài liệu mới** ("anh ddi owr ddaau" ở 20 ms): mọi phím từ lúc neo vị trí ở 0 đều dồn, nên `CursorTracker.typedHere` coi câu trả lời đúng giờ là chậm; Dấu thay ở `known` và app bỏ vùng. `sameAnswerAsLateNewDocument` chứng minh ca này không phân biệt được với tài liệu mới chưa áp phím của app tính vị trí tuyệt đối dùng bộ đệm Chromium.
- **Từ bắt đầu bằng chữ đầu của chuỗi đã gõ** ("chieeuf nay anh cos " ở 20 ms, vị trí neo ở 0): câu trả lời đúng giờ kiểu bộ đệm Chromium thiếu một chữ, đọc được "c" đúng ở chỗ chữ Dấu đã gõ bắt đầu (đầu tài liệu), nên `typedHere` chấp nhận là câu trả lời chậm.

### 2.2 Hướng sửa cho loại app này

Chưa làm vì chưa có app nào cần; dưới đây là phương án và cái giá, dựng lại theo mục 4 khi có app.

- **1B: nhận ra app tính vị trí từ đầu từ rồi tự tính vùng thay trong từ.** Trên mô hình: 38/40 → 0/40 lượt sai (chuỗi `std`, 5 ms), các ca qua ranh giới từ ra đúng khi phía trước có hai từ gõ ở nhịp người; các mô hình khác không đổi. Cái giá: đổi N3 (thêm ngoại lệ) và D11 (thêm ý mới, bỏ bất biến "vùng thay kết thúc ở vị trí Dấu theo dõi" cho loại app này).
- **4A: đọc cả chữ sau con trỏ trong cùng lần đọc.** Cho dạng tài liệu mới. Cái giá: đổi câu chữ N3 và cách kiểm độ dài của D18; theo mã Chromium (`attributedSubstringForProposedRange:actualRange:`, chưa đo) vùng vượt cuối chữ bị cắt.
- **4B, 4C:** giữ bằng chứng của 1B qua các lần kích hoạt, và chỉ áp ý "Ở đầu văn bản" cho từ đầu tiên (mô hình VS Code sai 5/40, Firefox 3/40): làm hỏng các mô hình khác nên không dùng.
- **1A, 1C:** tin vị trí app trả (sai đúng ở các ca này) và tự bật gạch chân (trái D13): không làm.

## 3. Kịch bản C: trang bận, app chậm qua chỗ ngắt từ

Đo 18/11/2026 trên máy M3 Max (Chrome 157.0.8103.79, Safari 27.2), số đo ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.1, 5.2. Hướng đã chọn ở mục 3.3; còn mở vài ca.

### 3.1 Cơ chế (Chrome)

- Trang bận (`--busy 300:1000`) làm Chrome trả vị trí chậm nhiều thao tác. Phím vẫn tới bộ gõ đều đặn (khoảng 17 ms một phím ở nhịp 10 ms); chỗ ngắt từ đến sau phím trước 50–60 ms.
- `CursorTracker.rebuild` cho app chậm tối đa `lateLimit` cộng `burst` thao tác. `burst` chỉ đếm các phím đến cách nhau dưới `InPlaceComposer.settleInterval`, nên về 0 ở mỗi chỗ ngắt từ, trong khi Chrome vẫn chậm.
- Các con số của phép chứng minh (log Debug, trường `read`, `tail`, `edits`, `burst`, `rebuilt`): mọi lần không chứng minh được đều có độ chậm lớn hơn `lateLimit + burst` (chậm 10 khi `burst` 3, chậm 6 khi `burst` 0); chữ đọc được vẫn đủ 16 đơn vị và `tail` dài hơn nhiều. Không chứng minh được thì vị trí cũ của app được tin, và chữ bị thay lùi về đó ("bạn gửi" ra "bạửigui").
- Ở nhịp người gõ nhanh (40 ± 20 ms, nghỉ 150 ms sau mỗi từ) lỗi vẫn có, ít hơn: Chrome sai 2/3 lượt, mỗi lượt một từ.
- Safari khác: cơ chế riêng của WebKit, mục 5.

### 3.2 Các hướng không chọn

Mỗi hướng thử trên mô hình (`LateAnswerTests`, `RapidKeysTests`, `InPlaceComposerTests`) và, khi mô hình đạt, trên Chrome thật.

| Hướng | Kết quả |
|---|---|
| Phím dồn thì tin vị trí Dấu theo dõi ở lần thay đầu của từ, dù chậm bao nhiêu (`late_guess` không giới hạn khi `keyInBurst`) | Chrome trang bận 5–20 ms: tổng khoảng cách chỉnh sửa 176 → 129 (18 ô), trang rảnh 27/27 và nhánh mới không chạy lần nào. Nhưng app tự xoá ô nhập giữa loạt phím thì thay ra ngoài chữ của app (`noResyncWhenFast`) |
| Bỏ `burst`, cho thử mọi thao tác đã ghi | Hỏng ba ca thật: ⌘A bộ gõ không thấy rồi gõ lại, log Cursor, tự sửa chính tả của hệ thống làm từ ngắn đi rồi D20 |
| Đếm thao tác kể từ lần cuối app trả lời đúng lúc | Hỏng ca tự sửa chính tả ("carr", hệ thống sửa thành "cả", ⌫ r) |
| `burst` không về 0 ở quãng nghỉ khi lần trả lời gần nhất của app đang chậm | Các ca cũ đều đạt; mô hình độ chậm vật lý (mỗi phím chậm thêm tối đa một thao tác) vẫn hỏng, vì app có thể đúng lúc ở lần hỏi gần nhất rồi chậm dần qua các phím đi thẳng |

Điều rút ra: thời gian giữa hai phím đang làm hai việc: chặn các ca app đổi chữ (nhờ quãng nghỉ của người) và giới hạn độ chậm được chấp nhận. Hướng đã chọn (mục 3.3) tách hai việc đó cho phím thay chữ trong từ.

### 3.3 Hướng đã chọn: mốc "app trả lời đúng lúc"

- Hai ca mơ hồ cho thấy chữ không đủ để phân biệt: sau ⌘A rồi gõ lại đúng mấy chữ cũ, hay sau khi hệ thống sửa "car" thành "cả", chữ app đang có trùng một trạng thái cũ của chính bộ gõ. Cái phân biệt được là lần cuối app trả lời đúng `known`: lúc đó app đã có mọi thao tác, nên sau đó nó không thể thiếu xa hơn mốc ấy.
- `CursorTracker.sinceOnTime` đếm số thao tác kể từ mốc đó. Ở phím thay chữ trong từ, `rebuild` cho thử tới số đó (nếu lớn hơn `lateLimit` cộng `burst`), ở mọi nhịp. Lần đọc của D20 và ở từ đã hết hợp lệ giữ hạn mức cũ, vì sau chỗ ngắt từ, ca "car" thành "cả" và ca app chậm ba thao tác để lại cùng một chữ ở cùng vị trí. Không chờ, không thêm lời gọi vào app.
- Chrome trang bận, máy M3 Max, cùng chuỗi `edit`:

| Điều kiện | Bản trước (`0b1a42d`) | Bản sửa (`d171ab9`) |
|---|---|---|
| Nhịp người gõ nhanh (40 ± 20 ms, nghỉ 150 ms sau mỗi từ), 6 lượt | sai 4/6, tổng khoảng cách chỉnh sửa 14 | sai 2/6, tổng 7 |
| 10 ms, 3 lượt | sai 3/3, khoảng 10 mỗi lượt | sai 2/3, khoảng 1,7 mỗi lượt |
| Trang rảnh 5 ms (Chrome, VS Code, Safari) | đúng | đúng |

- Thời gian xử lý phím có thay chữ không đổi (p99 khoảng 2 ms trong các lượt trên).
- Còn lại: phép chứng minh không qua dù app chỉ chậm một thao tác ở từ có chuỗi thay phức tạp ("được"; dạng bộ đệm Chromium chưa có trong mô hình), và lỗi riêng của Safari (mục 5). Mô hình trang bận trong `LateAnswerTests` khắc nghiệt hơn (chậm ngay từ đầu văn bản, trước mọi mốc) và còn được đánh dấu lỗi đã biết.

### 3.4 Cách dựng lại

- Mô hình: `LateAnswerTests`, test "the load-test strings in a burst…" (đánh dấu lỗi đã biết).
- Chạy thật: `scripts/selftest/typing/run.sh --busy 300:1000 --delay 10 --keys "$(scripts/selftest/load/run.sh --text edit --print keys)" --expect "$(scripts/selftest/load/run.sh --text edit --print expect)" --save <dir> chrome`, bản Debug; dòng `replace` trong `<dir>/chrome.perf.log` có các con số của phép chứng minh. Nhịp người: `--delay 40 --jitter 20 --word-pause 150`.

## 4. Số đo ngoài đời

- Chrome, trang bận (`scripts/selftest/load/run.sh --apps chrome --loads busy --text edit --reps 3`), 100 ± 30 ms một phím, bản Debug của mã hiện tại (17/11/2026, máy M1): thay tại chỗ đúng 3/3. Ở "Hoc ⌫j", lần đọc của D20 có vị trí app trả bằng vị trí Dấu theo dõi ở cả 3 lượt (không chậm thao tác nào), và D20 ra "Học". Gạch chân ra "Hocj" 3/3: gạch chân không thêm dấu được cho từ đã chốt ([`docs/Compatibility.md`](../Compatibility.md) mục 6.8).
- Khi áp 2A: chạy lại lệnh trên với `--reps 1` và `scripts/selftest/typing/run.sh --delay 5 vscodefile` để kiểm hồi quy.

## 5. Kịch bản D: Safari (WebKit) để phím đi thẳng chờ trong hàng

Đo 18/11/2026 trên máy M1 Pro (Safari 27.2), số đo và các quan sát nó giải thích ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.1, ý "Nguyên nhân".

### 5.1 Cơ chế

Đọc trong mã WebKit (nhánh main, 18/11/2026; chưa biết Safari 27.2 khác tới đâu):

- Phím bộ gõ trả NO đi vào `keyEventQueue` của tiến trình giao diện (`WebPageProxy::handleKeyboardEvent`). Hàng này gửi trang mỗi lần một phím, phím sau chỉ gửi khi trang đã xử lý xong phím trước (`keyEventHandlingCompleted`).
- `insertText` của bộ gõ (`insertTextAsync`), `selectedRange` (`getSelectedRangeAsync`) và lần đọc chữ (`attributedSubstringForCharacterRangeAsync`) gửi tới trang ngay, không qua hàng đó. Trang trả vị trí và chữ của chính nó lúc nhận tin, không từ bộ đệm.
- Trang áp `replacementRange` lên chữ nó đang có lúc nhận tin, không có số phiên bản để nhận ra lời gọi cũ (`WebPage::insertTextAsync`).
- Cờ `InputMethodUsesCorrectKeyEventOrder` (gửi lời gọi của bộ gõ kèm sự kiện phím, giữ thứ tự) có trong mã nhưng tắt mặc định (`status: unstable`).

Nên một phím đi thẳng đang tới trang vẫn được áp trước lời gọi sau của bộ gõ (cùng một đường tới trang), còn từ phím thứ hai trở đi thì không. Phép chứng minh app chậm của D11 coi app áp mọi thứ theo thứ tự (đúng với Chromium và Firefox theo mã nguồn của chúng, `LateDocument`); ở Safari nó vẫn qua, Dấu thay ở vị trí theo dõi, nhưng vùng thay tới trang khi các phím đi thẳng chưa có ở đó. Các phím ấy rơi ra sau chữ vừa thay; mỗi lần thay sau đặt con trỏ ở cuối vùng thay, trước chúng, nên chúng bị đẩy dần về cuối văn bản.

### 5.2 Khác Chrome ở đâu

Chrome khi trang bận trả vị trí cũ nhưng áp phím và lời gọi của bộ gõ theo đúng thứ tự, nên thay ở vị trí theo dõi là đúng (mục 3). Ở Safari cùng hành động đó sai. Từ một câu trả lời, bộ gõ không biết phần nào trong các thao tác app chưa áp là phím đi thẳng còn chờ trong hàng của WebKit, phần nào đã tới trang.

### 5.3 Hướng sửa

| Hướng | Cách làm | Cái giá |
|---|---|---|
| Bộ gõ tự chèn ký tự lẽ ra đi thẳng, ở app dùng WebKit (đã thử, chưa gộp) | Phím chữ cái, dấu cách, dấu câu mà engine để đi thẳng thì bộ gõ chèn bằng `insertText` tại con trỏ (NSNotFound), như phím chỉ thêm chữ ở cuối từ. Mọi thao tác chữ đi cùng một đường, theo thứ tự; `selectedRange` trả vị trí đã có mọi lời gọi trước nó. | Thêm một `insertText` cho mỗi phím đó (N3 vẫn tối đa một lần, nhưng bảng "phím nào gọi gì" đổi). Phải nhận ra app dùng WebKit (Safari theo bundle ID; app khác nhúng WKWebView như Mail thì chưa có cách). Trang web nhận phím đó như phím bộ gõ đã xử lý (theo mã WebKit: `keydown` có `keyCode` 229, `key` vẫn là chữ thật, không có `keypress`, chữ tới trước `keydown`, nên `preventDefault` ở `keydown` không chặn được chữ; chưa đo trên trang thật). Không sửa ⌫ (vẫn đi thẳng, vẫn có thể chờ; sửa riêng sau đó, mục 5.4). |
| Không thay ở vị trí theo dõi trong Safari khi app chậm từ hai phím đi thẳng trở lên | Coi như không chứng minh được (lệch, D11): reset, phím tự bắt đầu từ mới. | Chữ không bị xáo, nhưng từ đó mất dấu ("viết" ra chữ không dấu hay dở dang). Thêm một ngoại lệ theo app vào D11. |
| Chờ Safari bắt kịp | Hỏi lại `selectedRange` tới khi bằng vị trí theo dõi, có giới hạn thời gian. | Thêm lời gọi (trái N3), bộ gõ đứng chờ trong lúc trang bị chặn (tới 300 ms trong ô đo), là cách vá vòng có hẹn giờ. |
| Giữ nguyên | Chỉ xảy ra khi trang Safari không nhận kịp phím; người dùng gặp lỗi tự bật gạch chân (D13), ở đó chữ cái đúng, chỉ dấu cách có thể dời như với Telex của Apple. | Safari trang bận ở nhịp người gõ nhanh sai 3/3 lượt, mỗi lượt một từ (mục 5.1 của `docs/Compatibility.md`). |

Bản thử theo hướng đầu (18/11/2026), áp cho Safari theo bundle ID; chưa gộp vào `main`, chưa chọn hướng. Số đo trước và sau: [`docs/Compatibility.md`](../Compatibility.md) mục 5.1 (ý "Sửa").

### 5.4 ⌫

Sau bản thử tự chèn, ⌫ vẫn đi thẳng (D32: lệnh xoá của chính app bỏ chữ cuối), nên khi trang chưa nhận kịp nó vẫn chờ trong hàng: "Hoc ⌫j" ra "Hocj" ở Safari trang bận 3/6 lượt. Ở lượt sai có ghi vị trí, lúc j đọc chữ cho D20 Safari trả vị trí hơn vị trí Dấu theo dõi 1 (⌫ chưa áp), rồi lần đọc không cho chữ dùng được. Bản thử sửa nốt (18/11/2026, chưa gộp vào `main`): ở Safari, Dấu tự xoá khi Safari trả đúng vị trí Dấu theo dõi và hai ký tự trước con trỏ là chữ chính Dấu gõ. Safari bỏ qua `insertText` với chuỗi rỗng (bản đầu: "không" ⌫ g ra "khôngg" 4/4 lượt), nên thao tác xoá thay hai ký tự bằng ký tự đầu. ⌫ của D32 (dời dấu) thay phần chữ cần đổi mà không kèm lại chữ cuối. Số đo: [`docs/Compatibility.md`](../Compatibility.md) mục 5.1, ý "Sửa ⌫".

## 6. Cách dựng lại thí nghiệm

Bản vá 2A nằm ngoài repo, ở `build/patches/late-answer-2A.patch` (git bỏ qua `build/`; mất thì dựng lại theo dưới đây). Thí nghiệm chạy trên bản sao của repo trong `build/`. Lệnh test theo [`CONTRIBUTING.md`](../../CONTRIBUTING.md) mục "Chạy test". Bật từng hướng bằng biến môi trường `TEST_RUNNER_EXP_A`/`TEST_RUNNER_EXP_B`. Phần đổi mã:

- 2A: `CursorTracker.rebuild` nhận thêm số thao tác được nới và cờ cho phép câu trả lời ở `known`. Phần nới chỉ nhận dạng (b). `InPlaceComposer.addMarks` có thêm nhánh vị trí trùng `known`, chữ khác `tail`.
- 1B: `InPlaceComposer.replace` có thêm phần đếm bằng chứng (dùng chung lần đọc D11 của phím đó, `lateRead`) và phần thay theo vị trí trong từ. Đếm lại từ đầu ở `activate`. Bằng chứng: phím trước cách ít nhất `settleInterval`, `selectedRange` bằng số chữ của từ, `known` lớn hơn, chữ đọc được chỉ có từ đó; hai từ khác nhau; thoát khi vị trí vượt `readLength`.
- Test thêm: các ca qua ranh giới từ có "Mai minhf ddi " phía trước; bảng nhịp hỗn hợp (câu đầu 120 ms, `RapidSession` với từng mô hình, 40 seed) cho chuỗi `std` và `edit`.
