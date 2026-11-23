# Bốn kịch bản "app trả lời chậm": cơ chế và hướng sửa

Kịch bản A có ở Chrome thật khi trang bận và phím dồn; kịch bản B có ở trình soạn thảo của Cursor 3.30.14 (mục "Hiện trạng"). File này giữ cơ chế và hướng sửa ngắn gọn. Cơ chế của `CursorTracker` ở [`docs/Architecture.md`](../Architecture.md) mục "App trả lời chậm"; số đo Cursor ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.4.

## Hiện trạng (23/11/2026)

- **Kịch bản A: D20 sau ⌫ khi app chậm từ 3 thao tác trở lên** (mô hình bộ đệm Chromium, `LateDocument.Cache.chromium`). Ở nhịp người, Chrome thật khi trang bận trả lời lần đọc này đúng giờ (mục 4). Ở 10 ms, Chrome thật khi trang bận có lượt ra "Hocj" ở "Hoc ⌫j", không hỏng chữ. Trên mô hình, nguyên nhân là giới hạn số thao tác được chậm của lần đọc này (mục 1.1). Hướng đã chọn: dạng bộ đệm Chromium được dựng lại tới lần cuối app trả lời đúng lúc, kể cả khi vị trí trùng vị trí theo dõi (mục 1.2). Log Debug của lần đọc có các trường `typed_read_*` để xác nhận nguyên nhân ở app thật ([`docs/Architecture.md`](../Architecture.md) mục "Thêm dấu cho từ đã gõ", ý "Log perf").
- **Kịch bản B: app tính vị trí theo từ** (`LateDocument.Origin.word`, dựng từ log trình soạn thảo Cursor 3.29.15, đo 10/11/2026). Ở Cursor 3.30.14, khung agent (⌘L) và ô nhập Agents tính vị trí từ đầu văn bản và gõ đúng. Trình soạn thảo có lúc tính từ đầu văn bản (đúng), có lúc tính từ đầu từ; ở kiểu sau, chuỗi `edit` gõ cách nhau 5 ms sai vài từ mỗi lượt, không do D20 (D20 chờ hay không chờ phím dồn đều sai như vậy). Chưa rõ vì sao trình soạn thảo đổi kiểu (số đo: [`docs/Compatibility.md`](../Compatibility.md) mục 5.4). Mô hình còn trong test (`WordOriginTests`) cho các ca đạt. Hướng 1B và 4A cần đổi N3 và D11 (mục 2.2).
- **Kịch bản C: trang bận, app chậm qua chỗ ngắt từ** (đo 18/11/2026, mục 3): Chrome và Safari sai khi trang bận, cả ở nhịp người gõ nhanh. Nguyên nhân ở Chrome: hạn mức độ chậm của phép chứng minh về 0 ở mỗi chỗ ngắt từ. Đã sửa (mục 3.3): ở phím thay chữ trong từ, app được chậm mọi thao tác kể từ lần cuối nó trả lời đúng lúc (`d171ab9`). Câu trả lời trùng vị trí theo dõi không còn được coi là đúng lúc khi các thao tác cuối không dời con trỏ (lỗi "được"), lần đọc của D20 chậm quá phép chứng minh trong loạt phím dồn không còn neo vị trí theo dõi vào câu trả lời cũ, và vị trí neo đầu tiên là một mốc như câu trả lời đúng lúc (lỗi "mọot" ở đầu văn bản). Chrome trang bận đúng 9/9 ở 10 ms và 9/9 ở nhịp người gõ nhanh. Safari là kịch bản D.
- **Kịch bản D: Safari (WebKit) để phím đi thẳng chờ trong hàng** (đo 18/11/2026, mục 5): khi trang chưa nhận kịp phím (phím dồn, trang bận), lần thay của bộ gõ tới trang trước các ký tự đi thẳng còn chờ, nên chữ của các phím đó dời chỗ. Đã sửa ngày 22/11/2026 bằng cách bộ gõ tự chèn mọi ký tự engine để nguyên, ở mọi app (mục 5.3, N3): Safari đúng khi gửi cả chuỗi một lần (3/3) và ở ô mũi tên (3/3). ⌫ giữ đi thẳng; ca ⌫ rồi phím dấu ngay sau khi trang bận đã sửa bằng ngoại lệ chờ ⌫ chưa áp của N3, hạn 20 ms, cho mọi app (mục 5.4): Safari trang bận đúng 3/3 ở hai ô.
- Cursor không có nhãn "Đề xuất" (D13 (Gạch chân là đường lui cuối cùng)); số đo ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.4.

Không có quyết định nào chờ người dùng ở file này. Phần đo được và phần giả định của mô hình theo từ ghi trong comment của `LateDocument.Origin`; mô hình vị trí tính từ đầu văn bản là `Origin.document`.

## 1. Kịch bản A: D20 sau ⌫, app chậm từ 3 thao tác trở lên

### 1.1 Cơ chế

Chuỗi phím `Hoc ⌫` gõ dồn, trang bận, rồi `j`. Lần đọc của D20 ở `InPlaceComposer.addMarks` nhận câu trả lời từ bộ đệm Chromium (`LateDocument.Cache.chromium`): vị trí trang báo lần cuối cộng với dấu cách, là chữ chèn tại con trỏ mới nhất mà ⌫ vừa xoá.

- **Chậm 3:** trang mới áp tới "Ho". Bộ đệm ghi "c" rồi dấu cách cùng vào con trỏ của trang, nên chữ trước vị trí trả là "Ho " và vị trí đó trùng `CursorTracker.followed.caret`. Nếu chỉ chứng minh khi vị trí khác `followed.caret`, phép chứng minh không chạy. Chữ đọc được tận cùng là dấu cách nên không có từ, và kết quả là "Hocj".
- **Chậm 4 trở lên:** vị trí lùi sau `followed.caret`. Dấu cách đến sau phím trước 50–60 ms nên `editsInBurst` về 0 ở đó, còn ⌫ thuộc loạt phím dồn. Vì vậy giới hạn `humanPaceEdits` cộng `editsInBurst` chỉ là 3. Trên mô hình trang bận (test "the load-test strings in a burst…"), lần đọc ở "j" chậm 7–18 thao tác; dựng lại đúng số thao tác đó thì mọi phép kiểm khác đều qua (log Debug: `typed_read_reject=limit`, `typed_read_lag` bằng độ chậm). Không chứng minh được thì `addMarks` không gieo từ (mục 3.3), nên kết quả là "Hocj".

Ba giả thuyết khác đã loại trên mô hình. Thứ nhất, thao tác xoá của ⌫ không dựng lại được vì không biết chữ bị xoá: ⌫ xoá dấu cách do bộ gõ chèn, nên chữ đó đã biết. Thứ hai, `editsSinceOnTimeAnswer` chưa có: ở mọi seed hỏng giá trị này là 14–25, không nhỏ hơn độ chậm. Thứ ba, `typedHere` từ chối: phép kiểm này chỉ từ chối khi chữ trước từ không do bộ gõ gõ (test `staleD20ReadInBurst`), còn ở chuỗi `edit` thì bộ gõ gõ mọi chữ. Lần đọc hỏng (`readUnavailable`, D20 "Phạm vi") cũng không phải nguyên nhân: mọi lần đọc đều trả chữ.

Lỗi người dùng báo ngày 17/11 ở app Claude ("Hocj") do cơ chế khác ("một lần đọc hỏng trước đó", `failedReadLimit`).

### 1.2 Hướng đã chọn: dạng bộ đệm Chromium được dựng lại tới mốc đúng lúc

Ở lần đọc của D20 (`InPlaceComposer.answerForRead`, `CursorTracker.prove` với `cacheForm`), phép chứng minh có ba thay đổi:

1. Dạng (b) của phép chứng minh (chữ đọc được kết thúc bằng chữ chèn tại con trỏ mới nhất, như bộ đệm Chromium) được dựng lại tới `editsSinceOnTimeAnswer` (`LatenessBudget.cacheReplayLimit`), qua cả chỗ ngắt từ. Dạng (a) giữ giới hạn `humanPaceEdits` cộng `editsInBurst`. Mọi phép kiểm chặt vẫn áp: khi vượt `humanPaceEdits`, mọi thao tác xoá phải biết chữ nó xoá và `typedHere` phải đạt.
2. Câu trả lời trùng `followed.caret` cũng qua phép chứng minh, chỉ ở dạng (b). Lần đọc này chính là lần đọc vốn có của D20, nên không thêm lời gọi nào.
3. Lần thay sau khi chứng minh được không tính là câu trả lời đúng lúc (`readProvedLate`). Vị trí của lần thay đó là `followed.caret` chứ không phải câu trả lời của app. Nếu tính như vậy thì `editsSinceOnTimeAnswer` về 0 trong khi app vẫn chậm, và lần thay đầu của từ sau sẽ rơi vào chữ trước ("Hêc tie", "nayê Học" trên mô hình).

Đánh giá:

- **Quyết định:** không trái N1–N5 hay D nào. D11 cho phép "số thao tác được chậm có giới hạn". Giới hạn ở đây là số thao tác kể từ lần cuối app trả lời đúng lúc, cũng là giới hạn của phím thay chữ trong từ. D11 cũng đã nói phép chứng minh dùng cho lần đọc của D20. D20 vẫn chỉ đặt dấu khi tin được chữ: Dấu không gieo từ chữ của chính nó khi chữ app trả không khớp.
- **Ràng buộc phải giữ:** khi tự sửa chính tả biến "car" thành "cả" ("carr", D20 "Từ hệ thống vừa sửa"), chữ app trả trùng đúng chữ bộ gõ có ba thao tác trước, ở dạng (a). Vì vậy dạng (a) giữ giới hạn cũ. Chữ do hệ thống sửa không kết thúc bằng chữ bộ gõ vừa chèn tại con trỏ đặt sau một trạng thái cũ của chữ. Chỉ bộ đệm Chromium trả như vậy. Ca ⌘A bộ gõ không thấy rồi gõ lại đúng từ cũ cũng ở dạng (a). Test: `autocorrectNotTakenForLate`, `retypedAfterUnseenSelectAll`, `appTextChangedAtFollowedCaret` và bộ "Từ hệ thống vừa sửa".
- **Còn lại:** ở mô hình ảnh chụp (`LateDocument.Cache.snapshot`, kiểu Firefox), lần đọc của D20 chậm quá giới hạn của dạng (a) vẫn ra "Hocj". Chữ không hỏng. Số đo Firefox thật khi trang bận nằm ở [`docs/Compatibility.md`](../Compatibility.md), bảng ở mục đầu.

**2B: tin `typedBeforeCaret` thay cho chữ đọc được (không chọn).** Bỏ qua chữ app trả và dùng chữ Dấu đã gõ. Hướng này trái D20: D20 đọc chữ đang hiển thị. Ý "Từ hệ thống vừa sửa" cũng cần chữ thật. Ví dụ "cat" bị tự sửa thành "cắt", rồi ⌫ s: theo D20 phải tính trên "cắt", nhưng tin `typedBeforeCaret` thì tính trên "cat". Khi vị trí trùng `followed.caret`, chữ cũ của bộ đệm và chữ hệ thống vừa sửa không phân biệt được bằng vị trí.

**2C: nâng giới hạn cho mọi dạng (không chọn).** Nhận cả dạng (a) làm hỏng ca "carr" và ca ⌘A rồi gõ lại đúng các chữ cũ ở cùng chỗ (comment của `humanPaceEdits`).

## 2. Kịch bản B: app tính vị trí theo từ

### 2.1 Cơ chế

Mô hình app tính `selectedRange` và vùng thay từ đầu từ đang gõ, về 0 sau mỗi dấu cách. Khi phím dồn, câu trả lời có thể còn ở từ trước hay ở từ mới chưa có chữ nào: vị trí tính theo toạ độ của một từ khác, còn `followed.caret` tính theo toạ độ tài liệu, nên cả hai đều sai. Ba dạng trên mô hình:

- **Câu trả lời cũ qua ranh giới từ** (phím dồn 5 ms, trang chậm): vùng thay bị bỏ, thay nhầm chữ hoặc `mismatch` vì vị trí nhỏ hơn số chữ cần xoá. Câu trả lời cũ theo toạ độ của từ khác, nên không vị trí nào Dấu có là đúng; phép chứng minh app chậm nhận nhầm chỉ giải thích một phần các ca.
- **Phím dồn từ đầu từ trong tài liệu mới** ("anh ddi owr ddaau" ở 20 ms): mọi phím từ lúc neo vị trí ở 0 đều dồn, nên `CursorTracker.typedHere` coi câu trả lời đúng giờ là chậm; Dấu thay ở `followed.caret` và app bỏ vùng. `sameAnswerAsLateNewDocument` chứng minh ca này không phân biệt được với tài liệu mới chưa áp phím của app tính vị trí tuyệt đối dùng bộ đệm Chromium.
- **Từ bắt đầu bằng chữ đầu của chuỗi đã gõ** ("chieeuf nay anh cos " ở 20 ms, vị trí neo ở 0): câu trả lời đúng giờ kiểu bộ đệm Chromium thiếu một chữ, đọc được "c" đúng ở chỗ chữ Dấu đã gõ bắt đầu (đầu tài liệu), nên `typedHere` chấp nhận là câu trả lời chậm.

### 2.2 Hướng sửa cho loại app này

Chưa làm vì chưa có app nào cần; dưới đây là phương án và cái giá, dựng lại theo mục 4 khi có app.

- **1B: nhận ra app tính vị trí từ đầu từ rồi tự tính vùng thay trong từ.** Trên mô hình: 38/40 → 0/40 lượt sai (chuỗi `std`, 5 ms), các ca qua ranh giới từ ra đúng khi phía trước có hai từ gõ ở nhịp người; các mô hình khác không đổi. Cái giá: đổi N3 (thêm ngoại lệ) và D11 (thêm ý mới, bỏ bất biến "vùng thay kết thúc ở vị trí Dấu theo dõi" cho loại app này).
- **4A: đọc cả chữ sau con trỏ trong cùng lần đọc.** Cho dạng tài liệu mới. Cái giá: đổi câu chữ N3 và cách kiểm độ dài của D18; theo mã Chromium (`attributedSubstringForProposedRange:actualRange:`, chưa đo) vùng vượt cuối chữ bị cắt.
- **4B, 4C:** giữ bằng chứng của 1B qua các lần kích hoạt và chỉ áp ý "Ở đầu văn bản" cho từ đầu tiên (mô hình VS Code sai 5/40, Firefox 3/40): làm hỏng các mô hình khác nên không dùng.
- **1A, 1C:** tin vị trí app trả (sai đúng ở các ca này) và tự bật gạch chân (trái D13): không làm.

## 3. Kịch bản C: trang bận, app chậm qua chỗ ngắt từ

Đo 18/11/2026 trên máy M3 Max (Chrome 157.0.8103.79, Safari 27.2), số đo ở [`docs/history/CompatibilityFixed.md`](../history/CompatibilityFixed.md) mục "Safari và Chrome khi phím dồn hay trang bận, trước khi Dấu tự chèn ký tự". Hướng đã chọn ở mục 3.3; còn mở vài ca.

### 3.1 Cơ chế (Chrome)

- Trang bận (`--busy 300:1000`) làm Chrome trả vị trí chậm nhiều thao tác. Phím vẫn tới bộ gõ đều đặn (khoảng 17 ms một phím ở nhịp 10 ms); chỗ ngắt từ đến sau phím trước 50–60 ms.
- `CursorTracker.rebuild` cho app chậm tối đa `humanPaceEdits` cộng `editsInBurst` thao tác. `editsInBurst` chỉ đếm các phím đến cách nhau dưới `InPlaceComposer.settleInterval`, nên về 0 ở mỗi chỗ ngắt từ, trong khi Chrome vẫn chậm.
- Các con số của phép chứng minh (log Debug, trường `read`, `tail`, `edits`, `burst`, `rebuilt`): mọi lần không chứng minh được đều có độ chậm lớn hơn `humanPaceEdits` + `burst` (chậm 10 khi `burst` 3, chậm 6 khi `burst` 0); chữ đọc được vẫn đủ 16 đơn vị và `tail` dài hơn nhiều. Không chứng minh được thì Dấu tin vị trí cũ của app. Chữ bị thay lùi về đó ("bạn gửi" ra "bạửigui").
- Ở nhịp người gõ nhanh (40 ± 20 ms, nghỉ 150 ms sau mỗi từ) lỗi vẫn có, ít hơn: Chrome sai 2/3 lượt, mỗi lượt một từ.
- Safari khác: cơ chế riêng của WebKit, mục 5.

### 3.2 Các hướng không chọn

Mỗi hướng thử trên mô hình (`LateAnswerTests`, `RapidKeysTests`, `InPlaceComposerTests`) và, khi mô hình đạt, trên Chrome thật.

| Hướng | Kết quả |
|---|---|
| Phím dồn thì tin vị trí Dấu theo dõi ở lần thay đầu của từ, dù chậm bao nhiêu (`late_guess` không giới hạn khi `keyInBurst`) | Chrome trang bận 5–20 ms: tổng khoảng cách chỉnh sửa 176 → 129 (18 ô), trang rảnh 27/27 và nhánh mới không chạy lần nào. Nhưng app tự xoá ô nhập giữa loạt phím thì thay ra ngoài chữ của app (`noResyncWhenFast`) |
| Bỏ `editsInBurst`, cho thử mọi thao tác đã ghi | Hỏng ba ca thật: ⌘A bộ gõ không thấy rồi gõ lại, log Cursor, tự sửa chính tả của hệ thống làm từ ngắn đi rồi D20 |
| Đếm thao tác kể từ lần cuối app trả lời đúng lúc | Hỏng ca tự sửa chính tả ("carr", hệ thống sửa thành "cả", ⌫ r) |
| `editsInBurst` không về 0 ở quãng nghỉ khi lần trả lời gần nhất của app đang chậm | Các ca cũ đều đạt; mô hình độ chậm vật lý (mỗi phím chậm thêm tối đa một thao tác) vẫn hỏng, vì app có thể đúng lúc ở lần hỏi gần nhất rồi chậm dần qua các phím đi thẳng |

Điều rút ra: thời gian giữa hai phím đang làm hai việc. Việc thứ nhất là chặn các ca app đổi chữ (nhờ quãng nghỉ của người), việc thứ hai là giới hạn độ chậm chấp nhận được. Hướng đã chọn (mục 3.3) tách hai việc đó cho phím thay chữ trong từ.

### 3.3 Hướng đã chọn: mốc "app trả lời đúng lúc"

- Hai ca mơ hồ cho thấy chữ không đủ để phân biệt: sau ⌘A rồi gõ lại đúng mấy chữ cũ hay sau khi hệ thống sửa "car" thành "cả", chữ app đang có trùng một trạng thái cũ của chính bộ gõ. Cái phân biệt được là lần cuối app trả lời đúng `followed.caret`: lúc đó app đã có mọi thao tác, nên sau đó nó không thể thiếu xa hơn mốc ấy.
- `CursorTracker.LatenessBudget.editsSinceOnTimeAnswer` đếm số thao tác kể từ mốc đó. Ở phím thay chữ trong từ, `rebuild` cho thử tới số đó (nếu lớn hơn `humanPaceEdits` cộng `editsInBurst`), ở mọi nhịp. Phép kiểm từ đã hết hợp lệ giữ hạn mức cũ, lần đọc của D20 cũng giữ nó cho dạng (a), vì sau chỗ ngắt từ, ca "car" thành "cả" và ca app chậm ba thao tác để lại cùng một chữ ở cùng vị trí. Dạng (b) của lần đọc D20 được dựng lại tới mốc này (mục 1.2). Không chờ, không thêm lời gọi vào app.
- Chrome trang bận, máy M3 Max, cùng chuỗi `edit`:

| Điều kiện | Bản trước (`0b1a42d`) | Bản sửa (`d171ab9`) |
|---|---|---|
| Nhịp người gõ nhanh (40 ± 20 ms, nghỉ 150 ms sau mỗi từ), 6 lượt | sai 4/6, tổng khoảng cách chỉnh sửa 14 | sai 2/6, tổng 7 |
| 10 ms, 3 lượt | sai 3/3, khoảng 10 mỗi lượt | sai 2/3, khoảng 1,7 mỗi lượt |
| Trang rảnh 5 ms (Chrome, VS Code, Safari) | đúng | đúng |

- Thời gian xử lý phím có thay chữ không đổi (p99 khoảng 2 ms trong các lượt trên).
- Sửa tiếp ngày 22–23/11/2026, ba chỗ (số đo ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.2):
  - **Câu trả lời trùng `followed.caret` chưa chắc là đúng lúc.** Phép thay không dời con trỏ (dấu trên một chữ, "u" thành "ư") cho cùng một vị trí dù app đã áp nó hay chưa. Bộ đệm Chromium cũng trả vị trí trang báo cộng chữ chèn tại con trỏ mới nhất, nên chữ đó cũng có thể còn thiếu. Trước đây mọi câu trả lời trùng `followed.caret` đặt `editsSinceOnTimeAnswer` về 0, nên ở "dduwowjc", câu trả lời ở "o" chậm một thao tác (thiếu "ư") được coi là đúng lúc, rồi ở "j" app chậm ba thao tác mà `rebuild` chỉ cho dựng lại hai. Kết quả là "đụơc". Nay `answeredOnTime` để `editsSinceOnTimeAnswer` bằng số thao tác cuối mà câu trả lời đó không phân biệt được: các phép thay không dời con trỏ, cộng tối đa một chữ chèn tại con trỏ theo dạng bộ đệm Chromium. Trên mô hình, mọi chuỗi độ chậm từ 0 tới 3 của "dduwowjc" (mỗi phím chậm thêm tối đa một thao tác, hai dạng bộ đệm, nhịp 17 và 60 ms) đều ra "được"; trước bản sửa có 533 và 1 573 chuỗi sai ở hai dạng. Mô hình trang bận khắc nghiệt (test "the load-test strings in a burst…") giảm từ 124 xuống 76 lần ghi lỗi đã biết.
  - **Lần đọc của D20 chậm quá phép chứng minh không neo vị trí.** Ở Chrome trang bận 10 ms (1/3 lượt), lần đọc của D20 ở "j" sau "Hoc ⌫" trả vị trí sau "Ho", chậm hơn mức `rebuild` dựng lại được. `addMarks` neo `followed.caret` vào vị trí cũ đó, nên `typedBeforeCaret` bắt đầu lại và lần thay đầu của từ sau không chứng minh được app chậm, rồi thay vào chữ "o" của "Hoc" ("Hếcj tieng"). Nay khi câu trả lời lùi sau `followed.caret`, phép chứng minh không qua và phím thuộc loạt phím dồn, `addMarks` giữ `followed.caret` và không gieo từ (D11, bất biến "vị trí có thể là vị trí cũ thì không ghi đè"; D20 "nếu không tin được chữ đó"). Phím bắt đầu từ mới, nên chữ ra "Hocj tiếng": D20 không áp ở lần đó nhưng chữ không hỏng. Sau một quãng nghỉ, Dấu vẫn neo như trước, vì người dùng có thể đã bấm chuột mà IMK không báo.
  - **Vị trí neo đầu tiên là một mốc** (23/11/2026). Ở Chrome thật, 1/3 lượt ở nhịp người gõ nhanh, "mojot" ra "mọot". Trang bị chặn sau "Sáng nay ", nên ở "o" thứ hai app chậm 3 thao tác. Từ đầu văn bản app chưa trả lời đúng lúc lần nào, nên `editsSinceOnTimeAnswer` chưa có và giới hạn chỉ là `humanPaceEdits` + `editsInBurst` = 2. Nay khi `CursorTracker.anchor` nhận một vị trí mới (lần đọc của D20 hay phép kiểm từ đã hết hợp lệ khi chưa có `followed.caret`), `editsSinceOnTimeAnswer` bắt đầu từ 0: app vừa cho biết vị trí đó và chưa có thao tác nào của bộ gõ sau nó, như một câu trả lời đúng lúc. Phép dựng lại vượt `humanPaceEdits` vẫn phải qua `typedHere` và phải biết chữ bị xoá. Mô hình trang bận khắc nghiệt hỏng 22 trên 96 seed (trước ba bản sửa 62, sau hai bản đầu 38), không seed nào trước đó đúng bị hỏng.
- Còn lại: mô hình trang bận trong `LateAnswerTests` khắc nghiệt hơn ô đo thật (chậm ngay từ đầu văn bản, trước mọi mốc). Với bộ đệm Chromium, mọi seed của mô hình này đều đúng. Với mô hình ảnh chụp, 10 trên 48 seed còn đánh dấu lỗi đã biết, đều là "Hocj" ở "Hoc ⌫j" khi lần đọc của D20 chậm quá giới hạn của dạng (a) (mục 1.2), không hỏng chữ. Lỗi riêng của Safari ở mục 5.

### 3.4 Cách dựng lại

- Mô hình: `LateAnswerTests`, test "the load-test strings in a burst…" (đánh dấu lỗi đã biết ở mô hình ảnh chụp) và `LateBackspaceMarkTests`.
- Chạy thật: `scripts/selftest/typing/run.sh --busy 300:1000 --delay 10 --keys "$(scripts/selftest/load/run.sh --text edit --print keys)" --expect "$(scripts/selftest/load/run.sh --text edit --print expect)" --save <dir> chrome`, bản Debug; dòng `replace` trong `<dir>/chrome.perf.log` có các con số của phép chứng minh, còn dòng `key` của phím có lần đọc D20 có các trường `typed_read_*`. Nhịp người: `--delay 40 --jitter 20 --word-pause 150`.

## 4. Số đo ngoài đời

- Chrome, trang bận (`scripts/selftest/load/run.sh --apps chrome --loads busy --text edit --reps 3`), 100 ± 30 ms một phím, bản Debug của mã hiện tại (17/11/2026, máy M1): thay tại chỗ đúng 3/3. Ở "Hoc ⌫j", lần đọc của D20 có vị trí app trả bằng vị trí Dấu theo dõi ở cả 3 lượt (không chậm thao tác nào) và D20 ra "Học". Gạch chân ra "Hocj" 3/3: gạch chân không thêm dấu được cho từ đã chốt ([`docs/Compatibility.md`](../Compatibility.md) mục 6.8).
- Kiểm hồi quy cho mục 1.2: chạy lại lệnh trên với `--reps 1`, lệnh chạy thật ở mục 3.4 (10 ms, trang bận) và `scripts/selftest/typing/run.sh --delay 5 vscodefile`.

## 5. Kịch bản D: Safari (WebKit) để phím đi thẳng chờ trong hàng

Đo 18/11/2026 trên máy M1 Pro (lỗi) và 22/11/2026 trên máy M3 Max (sau khi sửa), cả hai lần ở Safari 27.2; số đo và các quan sát nó giải thích ở [`docs/history/CompatibilityFixed.md`](../history/CompatibilityFixed.md) mục "Safari và Chrome khi phím dồn hay trang bận, trước khi Dấu tự chèn ký tự" (lỗi) và [`docs/Compatibility.md`](../Compatibility.md) mục 5.1 (sau khi sửa).

### 5.1 Cơ chế

Đọc trong mã WebKit (nhánh main, 18/11/2026, đọc lại 22/11/2026 ở `WebViewImpl::keyDown/keyUp` và `WebPageProxy::handleKeyboardEvent`; chưa biết Safari 27.2 khác tới đâu):

- Mọi sự kiện phím (nhấn và nhả, bộ gõ đã xử lý hay chưa) đều vào `keyEventQueue` của tiến trình giao diện. Hàng này gửi trang mỗi lần một sự kiện, sự kiện sau chỉ gửi khi trang đã xử lý xong sự kiện trước (`keyEventHandlingCompleted`). Chỉ phím mà bộ gõ trả NO mới mang chữ tới trang.
- `insertText` của bộ gõ (`insertTextAsync`), `selectedRange` (`getSelectedRangeAsync`) và lần đọc chữ (`attributedSubstringForCharacterRangeAsync`) gửi tới trang ngay, không qua hàng đó. Trang trả vị trí và chữ của chính nó lúc nhận tin, không từ bộ đệm.
- Trang áp `replacementRange` lên chữ nó đang có lúc nhận tin, không có số phiên bản để nhận ra lời gọi cũ (`WebPage::insertTextAsync`).
- Cờ `InputMethodUsesCorrectKeyEventOrder` (gửi lời gọi của bộ gõ kèm sự kiện phím, giữ thứ tự) có trong mã nhưng tắt mặc định (`status: unstable`).

Nên khi bộ gõ để một ký tự đi thẳng, ký tự đó chờ trong hàng khi trang chưa nhận kịp, còn lời gọi sau của bộ gõ tới trang trước nó. Phép chứng minh app chậm của D11 coi app áp mọi thứ theo thứ tự (đúng với Chromium và Firefox theo mã nguồn của chúng, `LateDocument`); ở Safari nó vẫn qua, Dấu thay ở vị trí theo dõi, nhưng vùng thay tới trang khi các ký tự đi thẳng chưa có ở đó. Các ký tự ấy rơi ra sau chữ vừa thay; mỗi lần thay sau đặt con trỏ ở cuối vùng thay, trước chúng, nên chúng bị đẩy dần về cuối văn bản.

### 5.2 Khác Chrome ở đâu

Chrome khi trang bận trả vị trí cũ nhưng áp phím và lời gọi của bộ gõ theo đúng thứ tự, nên thay ở vị trí theo dõi là đúng (mục 3). Ở Safari cùng hành động đó sai khi còn ký tự đi thẳng. Từ một câu trả lời, bộ gõ không biết phần nào trong các thao tác app chưa áp là phím đi thẳng còn chờ trong hàng của WebKit, phần nào đã tới trang.

### 5.3 Hướng đã chọn: bộ gõ tự chèn ký tự, cho mọi app

Chọn ngày 22/11/2026 và ghi ở [`docs/Decisions.md`](../Decisions.md) N3 (ý 2 và đoạn "Vì sao Dấu tự chèn ký tự"). Ký tự mà engine để nguyên (chữ, số, dấu câu, dấu cách, phím không kèm ⌘, ⌃, ⌥) do bộ gõ chèn bằng `insertText` tại con trỏ (NSNotFound), như phím chỉ thêm chữ ở cuối từ. Mọi thao tác chữ đi cùng một đường, theo thứ tự. `selectedRange` trả vị trí đã có mọi lời gọi trước nó. Ở chế độ gạch chân, ký tự chốt chữ đi cùng chữ chốt trong một `insertText`. Áp cho mọi app, không theo bundle ID, vì Dấu không xử lý riêng theo app.

Cái giá: thêm một `insertText` cho mỗi ký tự đó. N3 vẫn tối đa một lần cho mỗi phím, nhưng bảng "phím nào gọi gì" ở [`docs/Architecture.md`](../Architecture.md) đổi. Trang web nhận ký tự đó như phím bộ gõ đã xử lý. Theo mã WebKit, `keydown` có `keyCode` 229, `key` vẫn là chữ thật, không có `keypress` và chữ tới trước `keydown`, nên `preventDefault` ở `keydown` không chặn được chữ. Chưa đo trên trang thật.

Số đo sau khi sửa (22/11/2026): [`docs/Compatibility.md`](../Compatibility.md) mục 5.1.

Các hướng khác không chọn:

| Hướng | Cách làm | Vì sao không chọn |
|---|---|---|
| Tự chèn chỉ ở Safari theo bundle ID (bản thử 18/11/2026, không gộp) | Như hướng đã chọn nhưng chỉ khi nhận ra Safari. | Đúng ở các ô đã đo, nhưng phải nhận ra app theo bundle ID (app khác nhúng WKWebView như Mail không có cách) và tạo một ngoại lệ theo app, trong khi Dấu không xử lý riêng theo app. |
| Không thay ở vị trí theo dõi trong Safari khi app chậm từ hai phím đi thẳng trở lên | Coi như không chứng minh được (lệch, D11): reset, phím tự bắt đầu từ mới. | Chữ không bị xáo, nhưng từ đó mất dấu ("viết" ra chữ không dấu hay dở dang). Thêm một ngoại lệ theo app vào D11. |
| Chờ Safari bắt kịp | Hỏi lại `selectedRange` tới khi bằng vị trí theo dõi, có giới hạn thời gian. | Thêm lời gọi (trái N3), bộ gõ đứng chờ trong lúc trang bị chặn (tới 300 ms trong ô đo), là cách vá vòng có hẹn giờ. |
| Giữ nguyên | Chỉ xảy ra khi trang Safari không nhận kịp phím; người dùng gặp lỗi tự bật gạch chân (D13). | Safari trang bận ở nhịp người gõ nhanh sai 3/3 lượt, mỗi lượt một từ (đo 18/11/2026, mục 5.1 của `docs/Compatibility.md`). |

### 5.4 ⌫

⌫ giữ đi thẳng (D32: lệnh xoá của chính app bỏ chữ cuối) ở mọi app. Lý do: Chromium tự chạy lệnh xoá cho ⌫ dù bộ gõ đã nhận phím, kể cả khi `insertText` có vùng thay (gửi ngay, không phải "chữ chờ chèn"), còn Safari thì không; nên tự xoá cho mọi app sẽ xoá hai lần ở Chromium.

Bản thử tự xoá riêng cho Safari (18/11/2026) không gộp vì không xử lý riêng theo app. Trong bản thử đó, Safari bỏ qua `insertText` với chuỗi rỗng ("không" ⌫ g ra "khôngg" 4/4 lượt), nên thao tác xoá phải thay hai ký tự cuối bằng ký tự đầu.

Sau khi tự chèn, ⌫ vẫn có thể chờ trong hàng khi trang Safari bận và bị lời gọi kế vượt, nên phím dấu ngay sau ⌫ không được thêm cho từ trước ("Hoc ⌫j" ra "Hocj", "khoong⌫g" ra "khôngg kó"; 22/11/2026). Lúc j đọc chữ cho D20, Safari trả vị trí hơn vị trí Dấu theo dõi 1 (⌫ chưa áp), rồi lần đọc không cho chữ dùng được, nên j bắt đầu từ mới. Chữ không bị xáo nhưng D20 không áp: đây là lỗi của Dấu (Telex của Apple không có D20 nên không dùng để so).

**Hướng đã chọn: chờ ⌫ chưa áp, cho mọi app** (ngoại lệ của N3, lý do và số đo ở [`docs/Decisions.md`](../Decisions.md) N3 đoạn "Vì sao ngoại lệ sau ⌫ chưa áp"). Khi `selectedRange` đầu tiên sau ⌫ trả đúng vị trí Dấu theo dõi cộng số đơn vị ⌫ xoá, Dấu hỏi lại tới khi app áp ⌫ hoặc hết hạn 20 ms, trong khoảng xét 0,3 s sau ⌫. Đo 22/11/2026 (máy M3 Max, [`docs/Compatibility.md`](../Compatibility.md) mục 5.1): ở Safari ⌫ áp trong khoảng 3 ms và trang bận đúng 3/3 ở hai ô (trước: "Hocj" 1/3, "khôngg kó" 2/3); ở Chrome câu trả lời không đổi trong lúc chờ nên mỗi lần chờ hết hạn sau 21–22 ms và chữ không đổi (hạn 0,3 s làm Chrome đứng 402–414 ms và sai chữ ở từ khác). Mô hình WebKit đầy đủ trang bận và phím dồn: 0/40 sai.

Các cách khác không chọn:

- Dấu tự xoá ⌫ ở mọi app: ứng dụng Chromium vẫn chạy lệnh xoá của nó sau `insertText` có vùng thay, nên xoá hai lần. Vùng thay gửi trang ngay, nên không phải "chữ chờ chèn" khiến Chromium bỏ phím gốc.
- Dấu tự xoá ⌫ chỉ ở Safari (bản thử 18/11): cần nhận ra app, trái N3 (không có ngoại lệ theo app).
- Coi lần đọc của D20 thấy ⌫ chưa áp là app chậm và thay ở vị trí Dấu theo dõi: ở Chromium, ⌫ áp trước lần thay nên đúng; ở WebKit, ⌫ đang chờ được áp sau lần thay, xoá ký tự cuối của vùng vừa thay ("Họ "). Hai app cần hai vùng thay khác nhau cho cùng một câu trả lời.
- Chờ ⌫ với hạn 0,3 s: làm Chrome đứng khoảng 410 ms, nên hạn là 20 ms (D42).

## 6. Cách dựng lại thí nghiệm

Bản vá thí nghiệm nằm ngoài repo, ở `build/patches/late-answer-2A.patch` (git bỏ qua `build/`; mất thì dựng lại theo dưới đây). Thí nghiệm chạy trên bản sao của repo trong `build/`. Lệnh test theo [`CONTRIBUTING.md`](../../CONTRIBUTING.md) mục "Chạy test". Bật từng hướng bằng biến môi trường `TEST_RUNNER_EXP_A`/`TEST_RUNNER_EXP_B`. Phần đổi mã:

- 2A, bản thí nghiệm: `CursorTracker.rebuild` nhận thêm số thao tác nới thêm (4) và cờ cho phép câu trả lời ở `followed.caret`. Phần nới chỉ nhận dạng (b). Hướng đang dùng (mục 1.2) nới tới `editsSinceOnTimeAnswer` thay cho 4.
- 1B: `InPlaceComposer.replaceIfLate` có thêm phần đếm bằng chứng (dùng chung lần đọc D11 của phím đó, `lateRead`) và phần thay theo vị trí trong từ. Đếm lại từ đầu ở `activate`. Bằng chứng: phím trước cách ít nhất `settleInterval`, `selectedRange` bằng số chữ của từ, `followed.caret` lớn hơn, chữ đọc được chỉ có từ đó; hai từ khác nhau; thoát khi vị trí vượt `readLength`.
- Test thêm: các ca qua ranh giới từ có "Mai minhf ddi " phía trước; bảng nhịp hỗn hợp (câu đầu 120 ms, `RapidSession` với từng mô hình, 40 seed) cho chuỗi `std` và `edit`.
