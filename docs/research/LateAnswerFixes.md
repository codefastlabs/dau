# Các giới hạn "app trả lời chậm" còn lại của thay tại chỗ: cơ chế và hướng sửa

Bộ test của bộ gõ (`Apps/DauInputMethod/Tests`) ghi 11 known issue, đều thuộc ý "App trả lời chậm" của D11 (Kiểm tra ngữ cảnh). File này tả cơ chế của từng nhóm, các hướng sửa đã thử trên mô hình, và đề xuất. Cơ chế của `CursorTracker` ở [`docs/Architecture.md`](../Architecture.md) mục "App trả lời chậm"; số đo Cursor ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.4.

## Hiện trạng (17/11/2026)

Kết luận, theo nhóm (mục 1):

- **Nhóm 2, D20 sau ⌫ khi app chậm 3–4 thao tác (2 ca): giới hạn chỉ có trên mô hình bộ đệm Chromium, giữ trong test.** Chrome thật, trang bận, nhịp người, chuỗi `edit`: đúng 3/3, và ở lần đọc của D20 sau ⌫ Chrome trả vị trí đúng giờ (mục 4). Hướng 2A sửa được hai ca trên mô hình mà không đổi quyết định nào; nó là phương án áp khi gặp ca thật (mục 2.2).
- **Nhóm 1, 3, 4 (9 ca): giới hạn của loại app tính vị trí theo từ.** Mô hình `LateDocument.Origin.word` dựng từ log trình soạn thảo Cursor 3.29.15 (đo 10/11/2026); hiện chưa biết app nào hoạt động như vậy. Cursor 3.30.14 tính vị trí từ đầu văn bản, ở cả trình soạn thảo, khung agent (⌘L) và ô nhập Agents: `selectedRange` bằng vị trí Dấu theo dõi, hoặc chậm 1–4 thao tác như bộ đệm Chromium (`kind=late`, chữ vẫn đúng). Các ca giữ trong test (known issue) mô tả giới hạn đó. Hướng sửa 1B và 4A cần đổi N3 và D11; mục 3.2 nêu phương án và cái giá.
- Cursor không có nhãn "Đề xuất" (D13 (Gạch chân là đường lui cuối cùng)); số đo ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.4.

Không có quyết định nào chờ người dùng ở file này.

## 1. Bốn nhóm

| Nhóm | Test | Ca | App (mô hình) | Đo ngoài đời |
|---|---|---|---|---|
| 1 | `CursorEditorTests.staleAnswerAcrossWords` | 7 | app tính vị trí theo từ, phím dồn 5 ms | chưa biết app nào; mô hình từ log Cursor 3.29.15 |
| 2 | `LateBackspaceMarkTests.pastLateLimit` | 2 | mô hình bộ đệm Chromium, D20 sau ⌫ | Chrome trang bận, nhịp người: không xảy ra, 3/3 đúng (mục 4) |
| 3 | `CursorEditorTests.burstFromStartOfWord` | 1 | app tính vị trí theo từ, tài liệu mới, 20 ms | chưa biết app nào; mô hình từ log Cursor 3.29.15 |
| 4 | `CursorEditorTests.wordStartingAsTheText` | 1 | app tính vị trí theo từ, 20 ms | chưa, chỉ trên mô hình |

Mô hình `LateDocument.Origin.word` dựng từ log trình soạn thảo Cursor 3.29.15 (10/11/2026). Phần đo được và phần giả định ghi trong comment của `LateDocument.Origin`. Mô hình vị trí tính từ đầu văn bản là `Origin.document`.

## 2. Nhóm 2: D20 sau ⌫, app chậm 3–4 thao tác

### 2.1 Cơ chế

Chuỗi phím `Toi hoc ⌫` gõ đúng giờ, rồi `j` với câu trả lời chậm 3 hoặc 4 thao tác, theo mô hình bộ đệm Chromium (`LateDocument.Cache.chromium`). Lần đọc của D20 ở `InPlaceComposer.addMarks` (vết từng phím trên bản sao):

- **Chậm 3:** trang mới áp tới "Toi ho". Bộ đệm ghi hai chữ chèn tại con trỏ ("c", rồi dấu cách) cùng vào con trỏ 6, nên ra "Toi ho c" và con trỏ 7. Vị trí 7 trùng `CursorTracker.known` (7), nên `addMarks` không thử chứng minh app chậm. Chữ đọc được là "Toi ho ", tận cùng là dấu cách, nên không có từ. Phím `j` đi thẳng và ra "Toi hocj".
- **Chậm 4:** vị trí 6 khác `known`, nên `CursorTracker.rebuild` được gọi. Ở nhịp người `burst` = 0, nên rebuild chỉ thử tối đa `lateLimit` = 2 thao tác. Muốn khớp thì phải thử 4. Rebuild thất bại, chữ đọc được "Toi h " tận cùng là dấu cách, và kết quả cũng ra "Toi hocj".

Giả thuyết đã xét:

| Giả thuyết | Dự đoán | Quan sát |
|---|---|---|
| H1: rebuild bị giới hạn ở `lateLimit` | sai ở chậm 4, có lần gọi rebuild | đúng với chậm 4; với chậm 3 thì rebuild không được gọi |
| H2: vị trí bộ đệm trả trùng `known` nên không ai kiểm chữ | sai ở chậm 3, lần đọc ở `known` | đúng với chậm 3 |
| H3: lần đọc hỏng (`readUnavailable`, D20 "Phạm vi") | lần đọc trả nil | sai: cả hai lần đọc đều trả chữ |

Không giả thuyết nào một mình giải thích được cả hai ca. H2 giải thích chậm 3, H1 giải thích chậm 4. Thí nghiệm khẳng định điều đó: chỉ sửa H2 thì chậm 3 hết sai, chậm 4 vẫn sai; sửa thêm H1 thì cả hai hết sai.

Nhóm 2 là cơ chế chưa đo được ngoài đời. Lỗi người dùng báo ngày 17/11 ở app Claude do cơ chế khác ("một lần đọc hỏng trước đó", `failedReadLimit`): mô hình chậm 3 ra "caos" rồi "cá", không khớp chuỗi đã báo. Ở lượt Chrome trang bận (1b, M6), mọi câu trả lời chậm đều chậm đúng 1 phím.

### 2.2 Hướng sửa

**2A (thử trên mô hình; áp khi gặp ca thật).** Chỉ áp ở lần đọc của D20 sau ⌫ (`addMarks`), gồm hai phần:

1. Vị trí trả trùng `known` mà phần cuối chữ đọc được khác `tail` (chữ Dấu đã gõ ở đó): vẫn chạy `rebuild`, cho phép câu trả lời nằm ở `known`.
2. Nới số thao tác được chậm thêm 4 (tức `lateLimit` + 4), nhưng phần nới chỉ nhận dạng (b) của rebuild. Dạng (b) là dạng của bộ đệm Chromium: chữ đọc được kết thúc bằng chữ chèn tại con trỏ mới nhất. Phần nới vẫn qua phép kiểm chặt như phím dồn: mọi thao tác xoá phải biết chữ nó xoá, và `typedHere` phải đạt.

Đánh giá:

- **Quyết định:** không trái N1–N5 hay D nào. D11 cho phép "số thao tác được chậm có giới hạn", và giới hạn vẫn còn. D11 cũng đã nói phép chứng minh dùng cho lần đọc của D20. Không thêm lời gọi nào: lần đọc ở phần 1 chính là lần đọc D20 vốn có, được chuyển cho `seedWord`. Phải sửa [`docs/Architecture.md`](../Architecture.md) mục "App trả lời chậm" (số thao tác được chậm; trường hợp vị trí trùng `known`).
- **Ràng buộc phải giữ:** test "carr → car, hệ thống sửa thành cả, ⌫r → car" (D20 "Từ hệ thống vừa sửa") phải vẫn đúng. Tự sửa chính tả biến "car" thành "cả", trùng đúng chữ trước 3 thao tác, nên nếu phần nới nhận cả dạng (a), phép dựng lại qua 3 thao tác khớp và Dấu tưởng app chậm. Vì vậy phần nới chỉ nhận dạng (b): chữ đọc được kết thúc bằng chính ký tự Dấu vừa chèn tại con trỏ, ở đây là dấu cách mà ⌫ vừa xoá. App đúng giờ chỉ trả như vậy khi trước con trỏ cũng là dấu cách; khi đó D20 không tìm thấy từ và phím đi thẳng.
- **Rủi ro với app đang đúng:** Chrome, VS Code, Firefox, Safari không đổi trên mô hình (bảng `RapidKeysTests.burstTable`, `stalledStartTable`, `CursorEditorTests.table`, `LateAnswerTests.wholeStringLate`). Mô hình ảnh chụp kiểu Firefox (`LateDocument.Cache.snapshot`) trên "Toi hoc␣⌫j" chậm 3–4 thì đúng cả khi không có 2A: chữ đọc được là chữ Dấu đã gõ thiếu một, hai đơn vị cuối, và phép chứng minh hiện có nhận dạng đó. Ảnh chụp sai khi trong các thao tác chưa áp có một lần thay chữ ("Caau ddoo␣⌫s" chậm 3 ra "Câu đó", "Caau ddo␣⌫s" chậm 4 ra "Câu đos"), với cả mã hiện tại và 2A; Firefox chưa có số đo nào như vậy.
- **Test chứng minh:** đổi `LateBackspaceMarkTests.pastLateLimit` thành test đạt; giữ `doubleKeyWord` (giữ ràng buộc "carr") và cả bộ "Từ hệ thống vừa sửa"; thêm ca ảnh chụp "Toi hoc␣⌫j" chậm 3–4 (đạt) và hai ca ảnh chụp có lần thay chữ chưa áp (giới hạn đã biết).
- **Chỉ kiểm được bằng gõ thật:** không gây được chậm 3–4 theo ý muốn. Lượt gõ thật chỉ kiểm hồi quy (mục 4).

**2B: tin `tail` thay cho chữ đọc được (không đề xuất).** Bỏ qua chữ app trả và dùng chữ Dấu đã gõ. Hướng này trái D20: D20 đọc chữ đang hiển thị, và ý "Từ hệ thống vừa sửa" cần chữ thật. Ví dụ "cat" bị tự sửa thành "cắt", rồi ⌫ s: theo D20 phải tính trên "cắt", nhưng tin `tail` thì tính trên "cat". Khi vị trí trùng `known`, chữ cũ của bộ đệm và chữ hệ thống vừa sửa không phân biệt được bằng vị trí.

**2C: nâng `lateLimit` cho mọi lần đọc (không thử).** Ở phạm vi hẹp của 2A, nhận cả dạng (a) làm hỏng ca "carr" (ràng buộc ở 2A), nên nâng cho mọi lần đọc càng rủi ro hơn. Comment của `lateLimit` nêu thêm lý do: ⌘A rồi gõ lại đúng các chữ cũ ở cùng chỗ.

**2D: giữ là giới hạn (đang áp dụng).** Ở Chrome thật, trang bận, nhịp người, lần đọc này không chậm (mục 4); lỗi người dùng báo về "Hocj" do cơ chế khác (`failedReadLimit`). 2A thêm nhánh vào phép chứng minh của D11 cho một ca chưa thấy ngoài đời, nên chỉ áp khi có ca thật.

## 3. Nhóm 1, 3, 4: app tính vị trí theo từ (giới hạn; chưa biết app nào)

### 3.1 Cơ chế

Mô hình app tính `selectedRange` và vùng thay từ đầu từ đang gõ, về 0 sau mỗi dấu cách. Khi phím dồn, câu trả lời có thể còn ở từ trước hay ở từ mới chưa có chữ nào: vị trí tính theo toạ độ của một từ khác, còn `known` tính theo toạ độ tài liệu, nên cả hai đều sai. Tên test giữ nguyên (`CursorEditorTests`).

- **Nhóm 1 (7 ca):** `anh co`+s chậm 3 (sel 4, known 6; vùng thay bị bỏ), `anh co`+s chậm 2 (thay nhầm ở 0,1), `minh`+f (sel 2 < 3 chữ cần xoá: `mismatch`), `ve`+e,f, `la`+f, `cua`+r, `me`+e. H1 (câu trả lời cũ theo toạ độ của từ khác, nên không vị trí nào Dấu có là đúng) giải thích cả bảy; H2 (phép chứng minh app chậm nhận nhầm) chỉ giải thích ba ca `late`.
- **Nhóm 3 (1 ca):** "anh ddi owr ddaau" ở 20 ms trong tài liệu mới. Mọi phím từ lúc neo vị trí ở 0 đều dồn, nên `CursorTracker.typedHere` coi câu trả lời đúng giờ là chậm; Dấu thay ở `known` và app bỏ vùng. `sameAnswerAsLateNewDocument` chỉ chứng minh được tài liệu mới của app tính vị trí tuyệt đối, nên ca này không phân biệt được với app tính vị trí tuyệt đối trả đúng giờ.
- **Nhóm 4 (1 ca, chỉ trên mô hình):** `wordStartingAsTheText`, "chieeuf nay anh cos " ở 20 ms: câu trả lời kiểu bộ đệm Chromium thiếu một chữ, đọc được "c" đúng ở chỗ chữ Dấu đã gõ bắt đầu (đầu tài liệu), nên `typedHere` chấp nhận. Chưa đo ở app thật.

### 3.2 Hướng sửa cho loại app này

Chưa làm vì chưa có app nào cần; dưới đây là phương án và cái giá, dựng lại theo mục 5 khi có app.

- **1B: nhận ra app tính vị trí từ đầu từ rồi tự tính vùng thay trong từ.** Trên mô hình: 38/40 → 0/40 lượt sai (chuỗi `std`, 5 ms), 7 ca nhóm 1 ra đúng khi phía trước có hai từ gõ ở nhịp người; các mô hình khác không đổi. Cái giá: đổi N3 (thêm ngoại lệ) và D11 (thêm ý mới, bỏ bất biến "vùng thay kết thúc ở vị trí Dấu theo dõi" cho loại app này).
- **4A: đọc cả chữ sau con trỏ trong cùng lần đọc.** Cho nhóm 3. Cái giá: đổi câu chữ N3 và cách kiểm độ dài của D18; theo mã Chromium (`attributedSubstringForProposedRange:actualRange:`, chưa đo) vùng vượt cuối chữ bị cắt.
- **4B, 4C:** giữ bằng chứng của 1B qua các lần kích hoạt, và chỉ áp ý "Ở đầu văn bản" cho từ đầu tiên (mô hình VS Code sai 5/40, Firefox 3/40): làm hỏng các mô hình khác nên không dùng.
- **1A, 1C:** tin vị trí app trả (sai đúng ở các ca này) và tự bật gạch chân (trái D13): không làm.

## 4. Số đo ngoài đời

- Chrome, trang bận (`scripts/selftest/load/run.sh --apps chrome --loads busy --text edit --reps 3`), 100 ± 30 ms một phím, bản Debug của mã hiện tại (17/11/2026, máy M1): thay tại chỗ đúng 3/3. Ở "Hoc ⌫j", lần đọc của D20 có vị trí app trả bằng vị trí Dấu theo dõi ở cả 3 lượt (không chậm thao tác nào), và D20 ra "Học". Gạch chân ra "Hocj" 3/3: gạch chân không thêm dấu được cho từ đã chốt ([`docs/Compatibility.md`](../Compatibility.md) mục 6.8).
- Khi áp 2A: chạy lại lệnh trên với `--reps 1` và `scripts/selftest/typing/run.sh --delay 5 vscodefile` để kiểm hồi quy. Không gây được chậm 3–4 theo ý muốn.

## 5. Cách dựng lại thí nghiệm

Các thí nghiệm chạy trên bản sao của repo trong `build/`. Lệnh test theo [`CONTRIBUTING.md`](../../CONTRIBUTING.md) mục "Chạy test". Bật từng hướng bằng biến môi trường `TEST_RUNNER_EXP_A`/`TEST_RUNNER_EXP_B`. Phần đổi mã:

- 2A: `CursorTracker.rebuild` nhận thêm số thao tác được nới và cờ cho phép câu trả lời ở `known`. Phần nới chỉ nhận dạng (b). `InPlaceComposer.addMarks` có thêm nhánh vị trí trùng `known`, chữ khác `tail`.
- 1B: `InPlaceComposer.replace` có thêm phần đếm bằng chứng (dùng chung lần đọc D11 của phím đó, `lateRead`) và phần thay theo vị trí trong từ. Đếm lại từ đầu ở `activate`. Bằng chứng: phím trước cách ít nhất `settleInterval`, `selectedRange` bằng số chữ của từ, `known` lớn hơn, chữ đọc được chỉ có từ đó; hai từ khác nhau; thoát khi vị trí vượt `readLength`.
- Test thêm: 7 ca nhóm 1 có "Mai minhf ddi " phía trước; bảng nhịp hỗn hợp (câu đầu 120 ms, `RapidSession` với từng mô hình, 40 seed) cho chuỗi `std` và `edit`.
