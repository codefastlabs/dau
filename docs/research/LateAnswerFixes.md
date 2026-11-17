# Các giới hạn "app trả lời chậm" còn lại của thay tại chỗ: cơ chế và hướng sửa

Bộ test của bộ gõ (`Apps/DauInputMethod/Tests`) ghi 11 known issue, đều thuộc ý "App trả lời chậm" của D11 (Kiểm tra ngữ cảnh). File này tả cơ chế của từng nhóm, các hướng sửa đã thử trên mô hình, và đề xuất. Cơ chế của `CursorTracker` ở [`docs/Architecture.md`](../Architecture.md) mục "App trả lời chậm"; số đo Cursor ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.4.

## Hiện trạng (17/11/2026)

Kết luận, theo nhóm (mục 1):

- **Nhóm 2, D20 sau ⌫ khi app chậm 3–4 thao tác (2 ca): sửa được mà không đổi quyết định nào** (hướng 2A). Trên mô hình, hướng này sửa cả hai ca. Mọi test khác của bộ gõ và mọi bảng mô phỏng giữ nguyên kết quả. Ca này chưa từng đo được ngoài đời (mục 2.1).
- **Nhóm 1, Cursor trả vị trí cũ qua ranh giới từ (7 ca): sửa được nếu đổi N3 (Ít lời gọi vào ứng dụng đích) và D11** (hướng 1B: nhận ra app tính vị trí từ đầu từ, rồi tự tính vùng thay trong từ). Mô hình Cursor gõ câu đầu ở nhịp người rồi gõ dồn 5 ms giảm từ 38/40 xuống 0/40 lượt sai (chuỗi `std`), và từ 40/40 xuống 0/40 (chuỗi `edit`). Chrome, VS Code, Firefox và mô hình `busy` không đổi (0/40). Cả 7 ca đều ra đúng khi phía trước đã có hai từ gõ ở nhịp người. Khi chưa có gì phía trước thì vẫn sai, nên vẫn còn một giới hạn hẹp hơn.
- **Nhóm 3 (1 ca) và nhóm 4 (1 ca): đề xuất giữ là giới hạn.** Với các lời gọi hiện có, không phân biệt được hai trường hợp: Cursor trả lời đúng giờ, và tài liệu mới của một app tính vị trí tuyệt đối chưa áp phím nào (`sameAnswerAsLateNewDocument`). Hai ca chỉ xảy ra khi mọi phím từ đầu tài liệu đều dồn dưới 50 ms. Nhóm 4 chỉ có trên mô hình. Hướng sửa duy nhất là đọc thêm chữ sau con trỏ. Hướng đó phải đổi câu chữ N3 và cách kiểm độ dài của D18 (Phòng thủ với IMK), và phải đo trên nhiều app (mục 4).
- Cursor giữ nhãn "Đề xuất" gạch chân (D13 (Gạch chân là đường lui cuối cùng)) cho tới khi một lượt gõ thật cho thấy hướng 1B đúng.

Quyết định cần người dùng chốt: có làm hướng 1B không. Làm thì sửa N3 và D11 (câu đề xuất ở mục 3.4). Không làm thì nhóm 1 giữ là giới hạn và Cursor giữ nhãn.

Lượt gõ thật cần chạy: mục 6.

Hai hướng sửa Cursor bị dừng ngày 10/11/2026 vì "cần đổi N3 hoặc D11" là: đọc cả chữ sau con trỏ trong cùng lần đọc (đụng câu chữ N3), và nhận ra app tính vị trí theo từ bằng hành vi (cần sửa D11). Nguồn: nhật ký 10/11 ở [`docs/history/LogM6.md`](../history/LogM6.md), mục về ca "anh ddi". Ở đây chúng là hướng 4A và 1B.

## 1. Bốn nhóm

| Nhóm | Test | Ca | App | Đo ngoài đời |
|---|---|---|---|---|
| 1 | `CursorEditorTests.staleAnswerAcrossWords` | 7 | trình soạn thảo Cursor, phím dồn 5 ms | có: các lượt 5 ms ngày 10/11 |
| 2 | `LateBackspaceMarkTests.pastLateLimit` | 2 | mô hình bộ đệm Chromium, D20 sau ⌫ | chưa (mục 2.1) |
| 3 | `CursorEditorTests.burstFromStartOfWord` | 1 | trình soạn thảo Cursor, tài liệu mới, 20 ms | có: lượt 12:42 ngày 10/11 |
| 4 | `CursorEditorTests.wordStartingAsTheText` | 1 | trình soạn thảo Cursor, 20 ms | chưa, chỉ trên mô hình |

Mô hình Cursor (`LateDocument.Origin.word`) dựng từ log đo. Phần đo được và phần giả định ghi trong comment của `LateDocument.Origin`. Mọi kết luận về Cursor dưới đây đúng trong phạm vi các giả định đó.

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

Liên hệ với lỗi người dùng báo ngày 17/11: nhật ký 17/11 trong [`docs/Progress.md`](../Progress.md) cho thấy chỉ cơ chế "một lần đọc hỏng trước đó" ra đủ chuỗi đã báo ở app Claude. Mô hình chậm 3 ra "caos" rồi "cá", không khớp đoạn sau của chuỗi đã báo. Cơ chế đó đã sửa (`failedReadLimit`). Nhóm 2 là một cơ chế có thể xảy ra, không phải nguyên nhân đã xác định của lỗi được báo. Ở lượt Chrome trang bận (1b, M6), mọi câu trả lời chậm đều chậm đúng 1 phím.

### 2.2 Hướng sửa

**2A (đã thử, đề xuất).** Chỉ áp ở lần đọc của D20 sau ⌫ (`addMarks`), gồm hai phần:

1. Vị trí trả trùng `known` mà phần cuối chữ đọc được khác `tail` (chữ Dấu đã gõ ở đó): vẫn chạy `rebuild`, cho phép câu trả lời nằm ở `known`.
2. Nới số thao tác được chậm thêm 4 (tức `lateLimit` + 4), nhưng phần nới chỉ nhận dạng (b) của rebuild. Dạng (b) là dạng của bộ đệm Chromium: chữ đọc được kết thúc bằng chữ chèn tại con trỏ mới nhất. Phần nới vẫn qua phép kiểm chặt như phím dồn: mọi thao tác xoá phải biết chữ nó xoá, và `typedHere` phải đạt.

Đánh giá:

- **Quyết định:** không trái N1–N5 hay D nào. D11 cho phép "số thao tác được chậm có giới hạn", và giới hạn vẫn còn. D11 cũng đã nói phép chứng minh dùng cho lần đọc của D20. Không thêm lời gọi nào: lần đọc ở phần 1 chính là lần đọc D20 vốn có, được chuyển cho `seedWord`. Phải sửa [`docs/Architecture.md`](../Architecture.md) mục "App trả lời chậm" (số thao tác được chậm; trường hợp vị trí trùng `known`).
- **Hồi quy đã gặp và đã chặn:** bản đầu của phần 2 nhận cả dạng (a). Khi đó test "carr → car, hệ thống sửa thành cả, ⌫r → car" (D20 "Từ hệ thống vừa sửa") hỏng. Lý do: tự sửa chính tả biến "car" thành "cả", trùng đúng chữ trước 3 thao tác, nên phép dựng lại qua 3 thao tác khớp và Dấu tưởng app chậm. Chỉ nhận dạng (b) thì hết hồi quy. Dạng (b) đòi chữ đọc được kết thúc bằng chính ký tự Dấu vừa chèn tại con trỏ, ở đây là dấu cách mà ⌫ vừa xoá. App đúng giờ chỉ trả như vậy khi trước con trỏ cũng là dấu cách, và khi đó D20 vốn không tìm thấy từ, phím đi thẳng như hiện nay.
- **Rủi ro với app đang đúng:** Chrome, VS Code, Firefox, Safari không đổi trên mô hình (bảng `RapidKeysTests.burstTable`, `stalledStartTable`, `CursorEditorTests.table`, `LateAnswerTests.wholeStringLate`). Mô hình ảnh chụp kiểu Firefox chậm 3–4 ở lần đọc này trả dạng (a), mà phần nới bỏ dạng (a), nên theo cách làm thì ca đó không được sửa. Chưa chạy test cho ca này; Firefox cũng chưa có số đo nào như vậy.
- **Test chứng minh:** đổi `LateBackspaceMarkTests.pastLateLimit` thành test đạt; giữ `doubleKeyWord` và cả bộ "Từ hệ thống vừa sửa"; thêm một ca ảnh chụp kiểu Firefox chậm 3 làm giới hạn đã biết.
- **Chỉ kiểm được bằng gõ thật:** không gây được chậm 3–4 theo ý muốn. Lượt gõ thật chỉ kiểm hồi quy (mục 6).

**2B: tin `tail` thay cho chữ đọc được (không đề xuất).** Bỏ qua chữ app trả và dùng chữ Dấu đã gõ. Hướng này trái D20: D20 đọc chữ đang hiển thị, và ý "Từ hệ thống vừa sửa" cần chữ thật. Ví dụ "cat" bị tự sửa thành "cắt", rồi ⌫ s: theo D20 phải tính trên "cắt", nhưng tin `tail` thì tính trên "cat". Khi vị trí trùng `known`, chữ cũ của bộ đệm và chữ hệ thống vừa sửa không phân biệt được bằng vị trí.

**2C: nâng `lateLimit` cho mọi lần đọc (không thử).** 2A đã gặp hồi quy ngay ở phạm vi hẹp, nên nâng cho mọi lần đọc càng rủi ro hơn. Comment của `lateLimit` nêu thêm lý do: ⌘A rồi gõ lại đúng các chữ cũ ở cùng chỗ.

**2D: giữ là giới hạn.** Có lý: chưa đo được ngoài đời, và lỗi người dùng báo có nguyên nhân khác, đã sửa. Nhưng 2A rẻ, không đổi quyết định và không hồi quy trên mô hình, nên đề xuất làm.

## 3. Nhóm 1: Cursor trả vị trí cũ qua ranh giới từ

### 3.1 Cơ chế

Trình soạn thảo Cursor tính `selectedRange` và vùng thay từ đầu từ đang gõ. Vùng thay được áp theo toạ độ trang có lúc tới lượt nó (comment của `LateDocument.Origin`). Khi phím dồn, câu trả lời có thể còn ở từ trước, hoặc ở từ mới nhưng chưa có chữ nào. Vị trí đó tính theo toạ độ của một từ khác. Còn `known` tính theo toạ độ tài liệu, nên cả hai đều sai. Mã trước M6 cũng cho đúng các chữ sai này (mô hình, lượt 10/11). Vết của 7 ca:

| Ca | Phím hỏng | Nhánh | Kết quả |
|---|---|---|---|
| `anh co`+s, chậm 3 | sel 4, known 6 | `late`, vùng 5,1 | Cursor bỏ vùng thay: "anh co" |
| `anh co`+s, chậm 2 | sel 1 | `replace` ở 0,1 | "anh óo" |
| `minh`+f | sel 2 < số chữ cần xoá 3 | `mismatch` | "minhf" |
| `ve`+e, f | sel 6, known 8 | `late`, vùng 7,1 | bị bỏ: "ve" |
| `la`+f | sel 1 | `replace` ở 0,1 | "àa" |
| `cua`+r | sel 2 | `replace` ở 0,2 | "ủaa" |
| `me`+e | sel 5, known 7 | `late`, vùng 6,1 | bị bỏ: "meting" |

Giả thuyết: (H1) câu trả lời cũ theo toạ độ của từ khác, nên không có vị trí nào trong số Dấu có là đúng; (H2) phép chứng minh app chậm nhận nhầm, như nhóm "uongs" đã sửa ngày 10/11. H2 chỉ giải thích được ba dòng `late`. H1 giải thích cả bảy dòng, và hướng 1B (tính vùng theo vị trí trong từ) cho đúng cả bảy. Vậy H1 là nguyên nhân, trong phạm vi mô hình.

### 3.2 Hướng sửa

**1B: nhận ra app tính vị trí từ đầu từ (đã thử, đề xuất nếu người dùng đổi N3 và D11).**

- **Bằng chứng:** ở phím có thay chữ, khi phím trước đã cách ít nhất `settleInterval`, Dấu xét ba điều. `selectedRange` bằng số chữ của từ đang gõ. `known` lớn hơn vị trí đó. Lần đọc D11 vốn có (vị trí khác `known`) chỉ thấy đúng từ đó, không có chữ nào trước nó. Đủ ba điều thì tính là một lần bằng chứng. Cần bằng chứng ở hai từ khác nhau. Ở app tính vị trí tuyệt đối, ba điều chỉ cùng xảy ra khi tài liệu bắt đầu bằng đúng từ đang gõ, nên không bao giờ đủ hai từ.
- **Khi đã nhận ra (tới lần kích hoạt sau):** vùng thay là `(số chữ của từ − số chữ cần xoá, số chữ cần xoá)` trong từ, tính từ chữ Dấu đã gõ, không theo `selectedRange`. Cursor áp vùng thay theo toạ độ từ nó có lúc tới lượt, mà lúc đó nó đã áp mọi phím trước, nên vùng này đúng cả khi câu trả lời cũ. Vẫn hỏi `selectedRange` mỗi phím (N3), nhưng chỉ để thoát: vị trí trả vượt `InPlaceComposer.readLength` thì đây không phải app tính theo từ, và Dấu về cách cũ. Không đọc chữ ở phím nào nữa, nên ít lời gọi hơn hiện nay (ở Cursor 26/41 lần thay có một lần đọc, nhật ký 10/11).
- **Số đo trên mô hình (40 seed, câu đầu 120 ms rồi phần còn lại ở 5, 10, 20 ms):**
  - Cursor 5 ms: chuỗi `std` 38/40 → 0/40 lượt sai, chuỗi `edit` 40/40 → 0/40.
  - Cursor 10, 20 ms: 0/40 trước và sau.
  - Chrome, VS Code, Firefox, `busy`: 0/40 trước và sau, không lần nào thừa lời gọi hay vùng thay ra ngoài chữ.
  - 7 ca của nhóm 1, thêm phía trước "Mai minhf ddi " gõ ở 100 ms: 0/7 → 7/7 ra đúng. Bản đầu của 1B thoát chế độ mỗi khi vị trí trả lớn hơn số chữ của từ, và chỉ được 4/7: câu trả lời cũ của từ trước làm nó thoát. Vì vậy ngưỡng thoát là `readLength`.
  - Bảng hiện có (`table`, `burstTable`, `stalledStartTable`, `wholeStringLate`): không đổi.
  - Test duy nhất đổi kết quả là `afterOneLetterWord`: chữ vẫn đúng, chỉ phép so `known` với log hỏng, vì ở chế độ mới Dấu không theo dõi `known` nữa.
- **Quyết định phải đổi:**
  - N3: "không tự cộng dồn vị trí từ một vị trí gốc; trừ chế độ gạch chân" phải thêm ngoại lệ thứ hai cho app đã được nhận ra là tính vị trí từ đầu từ.
  - D11: thêm một ý cho loại app này (cách nhận ra, cách thoát). Bất biến "Vùng thay luôn kết thúc ở vị trí Dấu theo dõi" không áp cho chúng: vùng kết thúc ở cuối từ.
  - Câu đề xuất ở mục 3.4.
- **Rủi ro:**
  - Nhận nhầm một app tính vị trí tuyệt đối thì vùng thay rơi vào đầu tài liệu, cho tới khi vị trí vượt 16. Điều kiện bằng chứng (nhịp người, hai từ, chữ đọc được chỉ có từ đó) làm việc này gần như không thể; các mô hình Chrome, VS Code, Firefox không bao giờ vào chế độ này.
  - Các giả định chưa đo của mô hình Cursor quyết định chế độ này đúng hay sai: mọi ký tự không phải chữ hay số đều bắt đầu từ mới; sau ⌫ qua đầu từ, Cursor giữ từ đứng trước con trỏ. Chỉ lượt gõ thật trả lời được.
  - Cursor đổi phiên bản mà chuyển sang vị trí tuyệt đối thì không còn bằng chứng, Dấu chạy như hiện nay: an toàn.
- **Giới hạn còn lại:** câu trả lời cũ trước khi đủ hai từ bằng chứng (đầu tài liệu, hay ngay sau khi kích hoạt) vẫn sai như hiện nay. Gõ dồn từ đầu tài liệu thì không bao giờ có bằng chứng, vì bằng chứng chỉ lấy ở nhịp người.
- **Test chứng minh:**
  - 7 ca có đoạn gõ trước ở nhịp người: đạt.
  - Bảng nhịp hỗn hợp cho năm mô hình: Cursor 0/40, các mô hình khác 0/40.
  - Ca app tính vị trí tuyệt đối không vào chế độ này: ô nhập Agents, ảnh chụp kiểu Firefox, tài liệu mới chậm kiểu VS Code.
  - Ca thoát khi vị trí vượt 16.
  - 7 ca không có đoạn gõ trước giữ là known issue, đặt lại tên theo giới hạn mới.
  - `afterOneLetterWord` bỏ phép so `known` ở chế độ mới.
- **Chỉ kiểm được bằng gõ thật:** Cursor có giữ đúng từ như mô hình không, và kết quả ở nhịp hỗn hợp (mục 6).

**1A: tin vị trí app trả khi không chứng minh được (như trước M6).** Mô hình cho thấy mã trước M6 sai ở đúng các ca này. Không sửa được.

**1C: tự bật gạch chân cho app được nhận ra là tính theo từ (không đề xuất).** Trái D13: người dùng tự bật gạch chân, mặc định không app nào gạch chân. Gạch chân còn làm mất D20.

**1D: giữ là giới hạn.** Nhóm 1 chỉ xảy ra khi phím cách nhau dưới khoảng 10 ms. Ở 20 ms (chuỗi chuẩn) và 100 ms, Cursor đã đúng (`docs/Compatibility.md` mục 5.4), và Cursor đã có nhãn gạch chân. Nhưng D13 nói gõ sai là lỗi của Dấu phải sửa, và gạch chân chỉ là đường lui. 1B có số đo offline tốt và không hồi quy trên mô hình, nên đề xuất 1B nếu người dùng chấp nhận đổi N3 và D11.

### 3.3 Thứ tự

Làm 2A trước: không đổi quyết định, độc lập với 1B (chạy cả hai cùng lúc trên bản sao: chỉ đổi đúng các test dự kiến). 1B làm sau khi người dùng chốt, rồi chạy lượt gõ thật ở mục 6. Bỏ nhãn "Đề xuất" của Cursor chỉ khi lượt đó đạt (D13).

### 3.4 Câu đề xuất cho Decisions.md (chưa sửa; chờ người dùng)

- N3, ý thứ hai, thêm vào sau "trừ chế độ gạch chân (D13)": "và app đã được nhận ra là tính vị trí từ đầu từ đang gõ (D11)".
- D11, ý mới "**App tính vị trí từ đầu từ**" (như trình soạn thảo Cursor): ở hai từ gõ ở nhịp người, `selectedRange` bằng số chữ của từ và chữ trước nó chỉ có từ đó. Khi đó, tới lần kích hoạt sau, Dấu thay theo vị trí trong từ, tính từ chữ chính nó đã gõ, và không dùng vị trí Dấu theo dõi. Vị trí app trả vượt 16 thì quay về cách thường. Vì sao: vị trí cũ của loại app này tính theo toạ độ của từ khác, nên không vị trí nào trong số Dấu có là đúng; trên mô hình, Cursor 5 ms ở nhịp hỗn hợp hết sai.

## 4. Nhóm 3: phím dồn từ đầu tài liệu mới (Cursor, 20 ms)

### 4.1 Cơ chế

"anh ddi owr ddaau" ở 20 ms trong tài liệu mới. Ở phím thứ hai của "dd", Cursor trả đúng (sel 1, đọc được "d"). Mọi phím từ lúc neo vị trí ở 0 đều dồn, nên `CursorTracker.typedHere` (ý "Ở đầu văn bản" của D11) coi đây là app chậm. Dấu thay ở `known` 5, vùng 4,1, và Cursor bỏ vùng đó, ra "anh di". `sameAnswerAsLateNewDocument` chứng minh rằng tài liệu mới của app tính vị trí tuyệt đối (mô hình VS Code) chưa áp phím nào trả cùng vị trí, cùng chữ đọc, cùng `known`. Không có một `insertText` nào đúng cho cả hai.

### 4.2 Hướng sửa

- **4A: đọc cả chữ sau con trỏ trong cùng lần đọc.** Ở VS Code chậm, bộ đệm Chromium có chữ sau con trỏ (mô hình: "d hna"). Ở Cursor đúng giờ thì không. Hướng này đổi câu chữ N3 ("đọc chữ trước con trỏ"). Theo mã nguồn Chromium (`attributedSubstringForProposedRange:actualRange:`, đọc 17/11/2026, chưa đo), vùng vượt cuối chữ bị cắt và trả chuỗi ngắn hơn. Mà `attributedSubstring(from:)` của IMK không cho biết vùng thật, và Dấu coi chuỗi sai độ dài là không đọc được (D18). Vậy phải đổi phép kiểm đó, và phải đo cách Safari, AppKit, Firefox, Chromium, Cursor trả lời vùng vượt cuối chữ. Hướng này chỉ sửa nhóm 3 và 4. Không thử.
- **4B: giữ bằng chứng của 1B qua các lần kích hoạt, theo app.** Ở lượt 12:42, Cursor đã được gõ trước đó nên có thể đã có bằng chứng. Nhưng ô nhập Agents của cùng app tính vị trí tuyệt đối. Từ thứ hai trong ô đó sẽ bị thay theo vị trí trong từ (vị trí còn dưới 16), cho tới khi có luật thoát chặt hơn. Không thử.
- **4C: chỉ áp ý "Ở đầu văn bản" cho từ đầu tiên.** Đã thử ngày 10/11: mô hình VS Code sai 5/40, Firefox 3/40 khi tài liệu mới chậm 80 ms.
- **4D: giữ là giới hạn (đề xuất).** Cần mọi phím từ đầu tài liệu dồn dưới 50 ms qua hai từ. Người gõ hiếm khi có sáu phím liền nhau như vậy ngay khi mở tài liệu. Cursor có nhãn gạch chân. Sửa phải đổi N3 và D18, và đo thêm năm loại app.

## 5. Nhóm 4: từ bắt đầu giống chữ đầu tài liệu (chỉ trên mô hình)

`wordStartingAsTheText`: "chieeuf nay anh cos " ở 20 ms. Ở "co"+s, Cursor trả đúng (sel 2). Câu trả lời của mô hình bộ đệm Chromium, thiếu một chữ của từ, đọc được chữ "c", đúng ở chỗ chữ Dấu đã gõ bắt đầu (đầu tài liệu). `typedHere` chấp nhận, Dấu thay ở `known` 16, và vùng bị bỏ. Cùng loại với nhóm 3, nhưng cần cả đoạn văn từ đầu tài liệu được gõ dồn. Chưa thấy ở lượt đo nào. Các hướng giống mục 4.2. Đề xuất giữ là giới hạn.

## 6. Lượt gõ thật

Một lượt chiếm màn hình. Phiên chính xin giờ. Bản Debug, đối chứng Telex của Apple ở ô Cursor.

- **Sau 2A (khoảng 5 phút):** hồi quy.
  - `scripts/selftest/load/run.sh --apps chrome --loads busy --text edit --reps 1`: chuỗi `edit` có "Hoc ⌫j".
  - `scripts/selftest/typing/run.sh --delay 5 vscodefile`.
  - Không gây được chậm 3–4 theo ý muốn.
- **Sau 1B (khoảng 10–15 phút):**
  - Trình soạn thảo Cursor, câu đầu ở nhịp người rồi gõ dồn 5 ms, hai lượt. Chuỗi phím và đáp án lấy từ `LateAnswerTests.stdKeys`.
  - Cursor 100 ms, một lượt.
  - Ô nhập Agents 5 ms, một lượt: không được vào chế độ mới.
  - `vscodefile` 5 ms và Chrome 5 ms, một lượt mỗi app.
  - `typing/run.sh` chưa có cách gõ một đoạn đầu ở nhịp khác. imk-dev thêm tuỳ chọn đó trước lượt chạy (script, tác dụng phụ `writes repo files` khi sửa).

## 7. Cách dựng lại thí nghiệm

Các thí nghiệm chạy trên bản sao của repo trong `build/`, đã xoá sau khi chạy. Lệnh test theo [`CONTRIBUTING.md`](../../CONTRIBUTING.md) mục "Chạy test". Bật từng hướng bằng biến môi trường `TEST_RUNNER_EXP_A`/`TEST_RUNNER_EXP_B`. Phần đổi mã:

- 2A: `CursorTracker.rebuild` nhận thêm số thao tác được nới và cờ cho phép câu trả lời ở `known`. Phần nới chỉ nhận dạng (b). `InPlaceComposer.addMarks` có thêm nhánh vị trí trùng `known`, chữ khác `tail`.
- 1B: `InPlaceComposer.replace` có thêm phần đếm bằng chứng (dùng chung lần đọc D11 của phím đó, `lateRead`) và phần thay theo vị trí trong từ. Đếm lại từ đầu ở `activate`.
- Test thêm: 7 ca nhóm 1 có "Mai minhf ddi " phía trước; bảng nhịp hỗn hợp (câu đầu 120 ms, `RapidSession` với từng mô hình, 40 seed) cho chuỗi `std` và `edit`.
