# Hai kịch bản "app trả lời chậm" chỉ có trên mô hình: cơ chế và hướng sửa dự phòng

Không app thật nào đã đo ra hai kịch bản dưới đây, và bộ test của bộ gõ (`Apps/DauInputMethod/Tests`) không có known issue nào. File này giữ cơ chế và hướng sửa ngắn gọn để dùng khi gặp ca thật. Cơ chế của `CursorTracker` ở [`docs/Architecture.md`](../Architecture.md) mục "App trả lời chậm"; số đo Cursor ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.4.

## Hiện trạng (17/11/2026)

- **Kịch bản A: D20 sau ⌫ khi app chậm 3–4 thao tác** (mô hình bộ đệm Chromium, `LateDocument.Cache.chromium`). Chrome thật, trang bận, nhịp người, chuỗi `edit`: đúng 3/3, và ở lần đọc của D20 sau ⌫ Chrome trả vị trí đúng giờ (mục 3). Chậm 1–2 thao tác thì phép chứng minh hiện có đã xử lý (`LateBackspaceMarkTests`). Hướng 2A là phương án áp khi gặp ca thật (mục 1.2).
- **Kịch bản B: app tính vị trí theo từ** (`LateDocument.Origin.word`, dựng từ log trình soạn thảo Cursor 3.29.15, đo 10/11/2026). Cursor 3.30.14 tính vị trí từ đầu văn bản, ở cả trình soạn thảo, khung agent (⌘L) và ô nhập Agents, và gõ đúng ở mọi ô đã đo: `selectedRange` bằng vị trí Dấu theo dõi, hoặc chậm 1–4 thao tác như bộ đệm Chromium (`kind=late`, chữ vẫn đúng). Chưa biết app nào tính theo từ. Mô hình còn trong test (`WordOriginTests`) cho các ca đạt. Hướng 1B và 4A cần đổi N3 và D11 (mục 2.2).
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

## 3. Số đo ngoài đời

- Chrome, trang bận (`scripts/selftest/load/run.sh --apps chrome --loads busy --text edit --reps 3`), 100 ± 30 ms một phím, bản Debug của mã hiện tại (17/11/2026, máy M1): thay tại chỗ đúng 3/3. Ở "Hoc ⌫j", lần đọc của D20 có vị trí app trả bằng vị trí Dấu theo dõi ở cả 3 lượt (không chậm thao tác nào), và D20 ra "Học". Gạch chân ra "Hocj" 3/3: gạch chân không thêm dấu được cho từ đã chốt ([`docs/Compatibility.md`](../Compatibility.md) mục 6.8).
- Khi áp 2A: chạy lại lệnh trên với `--reps 1` và `scripts/selftest/typing/run.sh --delay 5 vscodefile` để kiểm hồi quy.

## 4. Cách dựng lại thí nghiệm

Bản vá 2A nằm ngoài repo, ở `build/patches/late-answer-2A.patch` (git bỏ qua `build/`; mất thì dựng lại theo dưới đây). Thí nghiệm chạy trên bản sao của repo trong `build/`. Lệnh test theo [`CONTRIBUTING.md`](../../CONTRIBUTING.md) mục "Chạy test". Bật từng hướng bằng biến môi trường `TEST_RUNNER_EXP_A`/`TEST_RUNNER_EXP_B`. Phần đổi mã:

- 2A: `CursorTracker.rebuild` nhận thêm số thao tác được nới và cờ cho phép câu trả lời ở `known`. Phần nới chỉ nhận dạng (b). `InPlaceComposer.addMarks` có thêm nhánh vị trí trùng `known`, chữ khác `tail`.
- 1B: `InPlaceComposer.replace` có thêm phần đếm bằng chứng (dùng chung lần đọc D11 của phím đó, `lateRead`) và phần thay theo vị trí trong từ. Đếm lại từ đầu ở `activate`. Bằng chứng: phím trước cách ít nhất `settleInterval`, `selectedRange` bằng số chữ của từ, `known` lớn hơn, chữ đọc được chỉ có từ đó; hai từ khác nhau; thoát khi vị trí vượt `readLength`.
- Test thêm: các ca qua ranh giới từ có "Mai minhf ddi " phía trước; bảng nhịp hỗn hợp (câu đầu 120 ms, `RapidSession` với từng mô hình, 40 seed) cho chuỗi `std` và `edit`.
