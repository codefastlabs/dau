# Monaco đưa chữ cho bộ gõ thế nào: VS Code và Cursor

File này tìm cơ chế gốc của kịch bản B ở [`LateAnswerFixes.md`](LateAnswerFixes.md): trình soạn thảo của Cursor có lúc trả `selectedRange` tính từ đầu từ, có lúc tính từ đầu văn bản, còn VS Code luôn tính từ đầu văn bản. Số đo nằm ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.3 và 5.4. Mục 6 là thiết kế bản sửa.

Cách ghi: mỗi khẳng định ghi nguồn. "Đọc mã" là điều đọc thấy trong mã nguồn, tả bằng lời của file này (không chép mã, D10 (Engine tự viết)). "Đọc gói app" là điều đọc thấy trong file JavaScript đã đóng gói của app cài trên máy, không chạy app. "Tác giả ghi" là điều tài liệu, ghi chú phát hành hay trả lời trên diễn đàn nói, chưa ai kiểm lại. "Suy luận, cần kiểm chứng" là ý của file này.

## Hiện trạng (23/11/2026)

- **Cursor 3.31.15 nhận chữ qua ô `<textarea>` ẩn, VS Code 1.147.0 qua EditContext.** Hai app chạy cùng Electron 43.8.9 và Chromium 150.0.7871.250 (đọc gói app). Phần khác nhau chỉ nằm ở Monaco. Trong gói của Cursor, tuỳ chọn `editor.experimentalEditContextEnabled` mặc định tắt ở bản `stable`, như VS Code trước 1.101. VS Code bật EditContext mặc định từ 1.101 (mục 1).
- **Ô textarea chứa gì tuỳ chế độ hỗ trợ trình đọc màn hình của Monaco** (mục 2). Ở chế độ tắt, trên macOS, ô chỉ chứa từ ngay trước con trỏ, hoặc một ký tự trước con trỏ nếu không có từ. Ô được viết lại ngay mỗi khi con trỏ đổi. Ở chế độ bật, ô chứa cả một trang dòng, nên vị trí tính từ đầu văn bản. Với giá trị mặc định `auto`, chế độ đi theo việc Electron có thấy công nghệ hỗ trợ (assistive technology) hay không.
- **Chromium trả lời bộ gõ theo toạ độ của ô textarea** (mục 3). Vì vậy ở chế độ tắt, `selectedRange` và vùng thay tính từ đầu từ. Câu trả lời lấy từ bản sao bất đồng bộ đã tả ở [`WebEditorInput.md`](WebEditorInput.md) mục 8 và 10.2. Blink áp vùng thay theo nội dung ô lúc nó xử lý lời gọi. Vùng bắt đầu sau cuối ô bị bỏ, vùng chỉ có phần cuối vượt ô bị cắt.
- **Giả thuyết H1 giải thích mọi quan sát của trình soạn thảo Cursor, trừ điều gì bật chế độ hỗ trợ trình đọc màn hình, và phép đo đã xác nhận nó** (mục 4, 5). H1: Cursor dùng ô textarea, kiểu vị trí đi theo chế độ đó, và chế độ được chốt khi mở cửa sổ. Nó giải thích ba câu trả lời ở "j" của "Hoc␣⌫j" (3 với "Hoc", 4 với "Hoc␣", 1 với một dấu cách) và các từ sai qua ranh giới từ. Điều gì làm Electron bật chế độ đó trên máy đo thì chưa rõ. Script gõ thử hỏi Cursor qua System Events, nhưng theo mã Electron, chỉ hỏi như vậy thì chưa đủ để bật.
- **Phép đo xác nhận** (mục 5, 23/11/2026): với `accessibilitySupport` `off`, vị trí tính từ đầu từ và chữ sai; với `on`, hoặc với `off` kèm EditContext, vị trí tính từ đầu văn bản và chữ đúng cả câu.
- **Bản sửa** (mục 6, đã đo ở mục 6.11): Dấu nhận ra ô chỉ giữ từ trước con trỏ qua câu trả lời mà lần đọc vốn có của D11 và D20 đã lấy. Ở ô đó, Dấu tính vùng thay trong chữ ô giữ lúc trang áp lời gọi, từ chữ chính nó đã gõ; câu trả lời của app chỉ dùng để kiểm. N3 và D11 đã đổi theo đó. `CursorTracker.wordFromWordStart` và mô hình `LateDocument.Origin.word` đã bỏ. Với câu `edit` ở chế độ tắt, Cursor 3.31.15 đúng 9/10 lượt ở 5 ms và 3/3 ở 10 ms. Hai ca còn sai nằm ở mục 6.7.

## 1. Hai đường nhập của Monaco và bản Cursor dùng

**Hai đường** (đọc mã, VS Code `main` commit `a902b1c8`, 23/11/2026; `src/vs/editor/browser/view.ts`, hàm `_instantiateEditContext`):
- `NativeEditContext` dùng API EditContext của trình duyệt. Monaco đặt vào EditContext chữ của các dòng chứa vùng chọn, từ đầu dòng đầu tới cuối dòng cuối, và vùng chọn tính từ đầu dòng (`_getNewEditContextState`). Chữ và vùng chọn được cập nhật khi con trỏ đổi và khi nội dung các dòng đó đổi. Cách làm này không phụ thuộc chế độ hỗ trợ trình đọc màn hình. Phần cho trình đọc màn hình nằm ở một nút DOM riêng (`ScreenReaderSupport`).
- `TextAreaEditContext` dùng một ô `<textarea>` ẩn. Nội dung ô tả ở mục 2.
- Monaco chọn đường EditContext khi trình duyệt có EditContext và tuỳ chọn tương ứng bật (`EffectiveEditContextEnabled`). Khi chế độ hỗ trợ trình đọc màn hình đổi, Monaco dựng lại đối tượng nhập theo cùng đường.

**VS Code:**
- Ghi chú phát hành 1.101 (05/2025) viết rằng `editor.editContext` bật mặc định ở bản Stable và ô nhập của trình soạn thảo từ nay chạy bằng API EditContext (tác giả ghi).
- Ở tag 1.99.3, tuỳ chọn tên là `experimentalEditContextEnabled` và mặc định bật mọi nơi trừ bản `stable` (đọc mã, `editorOptions.ts`). Từ 1.105.1, tuỳ chọn tên là `editContext`, mặc định bật, và tên cũ được chuyển sang tên mới (`migrateOptions.ts`).
- Gói của VS Code 1.147.0 cài trên máy (commit `8a14f0cc`) đăng ký `editContext` mặc định bật (đọc gói app).

**Cursor 3.31.15** (gói cài trên máy, commit `3eb8c133`, ngày đóng gói 20/11/2026; đọc gói app):
- `product.json` ghi `vscodeVersion` 1.128.0 và `quality` `stable`.
- Monaco trong gói chỉ có tuỳ chọn `experimentalEditContextEnabled`, mặc định bật khi `quality` khác `stable`. Vậy ở bản phát hành, Cursor dùng ô textarea, trừ khi người dùng hay một cấu hình từ xa bật tuỳ chọn đó.
- Hàm chọn nội dung ô textarea trong gói giống hệt mã VS Code ở mục 2, kể cả nhánh macOS chỉ đặt từ trước con trỏ.
- Như vậy, phần trình soạn thảo của Cursor thuộc dòng mã trước 1.101, dù số phiên bản API ghi 1.128.0. Nhân viên Cursor viết trên diễn đàn rằng phiên bản API khai báo "không phải lúc nào cũng khớp một-một" với phần lõi trình soạn thảo, vốn có thể nằm trên một nền cũ hơn (tác giả ghi, 05/06/2026). Trong một báo lỗi bộ gõ tiếng Nhật ở Cursor 3.15.19 (08/2026), nhân viên Cursor khuyên bật `editor.experimentalEditContextEnabled` để vá. Lời khuyên đó chỉ có nghĩa khi tuỳ chọn này mặc định tắt (tác giả ghi).

## 2. Ô textarea chứa gì và khi nào được viết lại

Đọc mã VS Code `main` `a902b1c8`, `textAreaEditContext.ts` (hàm `getScreenReaderContent` trong phần khởi tạo, `_getWordBeforePosition`, `_getCharacterBeforePosition`, `onCursorStateChanged`) và `textAreaEditContextInput.ts` (`writeNativeTextAreaContent`, xử lý sự kiện `input`). Tag 1.99.3 có cùng logic. Gói Cursor 3.31.15 cũng vậy (đọc gói app).

**Chế độ hỗ trợ trình đọc màn hình có ba giá trị.** Cài đặt `editor.accessibilitySupport` nhận `auto`, `on`, `off`. Giá trị `on` là bật, `off` là tắt. Với `auto`, Monaco lấy giá trị từ môi trường. Trong app Electron, môi trường luôn là bật hoặc tắt, không có "chưa biết" (mục "Electron" bên dưới).

**Nội dung ô theo chế độ:**

| Chế độ | Nội dung ô khi không có vùng chọn (macOS) | Vị trí con trỏ trong ô |
|---|---|---|
| tắt | Từ ngay trước con trỏ trên dòng hiện tại. Nếu không có từ thì là một ký tự ngay trước con trỏ. Nếu đầu dòng thì ô rỗng. | Cuối ô, tức số đơn vị UTF-16 của từ đó |
| bật | Một "trang" dòng chứa con trỏ: từ đầu trang tới con trỏ, rồi phần sau con trỏ tới cuối trang. Trang dài 500 dòng khi bật (mặc định của `editor.accessibilityPageSize`). | Số đơn vị từ đầu trang. Với tài liệu dưới 500 dòng, đó là vị trí tính từ đầu văn bản. |
| chưa biết (chỉ ngoài Electron) | Như chế độ bật, nhưng phần trước và sau con trỏ bị cắt còn 500 ký tự | Tính từ chỗ bắt đầu phần đã cắt |

- Từ trước con trỏ dừng ở ký tự đầu tiên không thuộc loại chữ của từ, theo `editor.wordSeparators`. Giá trị mặc định là các dấu ``` `~!@#$%^&*()-=+[{]}\|;:'",.<>/? ```, cộng dấu cách và Tab (`wordHelper.ts`, `wordCharacterClassifier.ts`). Chữ có dấu tiếng Việt, chữ số và `_` thuộc từ. Hàm dừng khi đã lùi quá 50 ký tự.
- Ghi chú trong mã nêu lý do. Trên macOS, Monaco đặt ký tự trước con trỏ để giữ phím cho bảng chọn dấu (bấm giữ phím), và đặt từ trước con trỏ để Bàn phím trợ năng (Accessibility Keyboard) gợi ý được.
- Có vùng chọn dưới 500 ký tự thì ô chứa đúng vùng chọn đó.
- Ví dụ ở chế độ tắt: sau "chiều nay. Hoc", ô là "Hoc", con trỏ ở 3. Sau dấu cách, từ trước con trỏ rỗng nên ô là " ", con trỏ ở 1. Sau "nay.", ô là ".", vì dấu chấm là dấu ngăn từ.

**Khi nào ô được viết lại:**
- Ô được viết lại đồng bộ mỗi khi con trỏ của trình soạn thảo đổi (`onCursorStateChanged`). Ghi chú trong mã nói phải đồng bộ để bấm giữ phím trên macOS không hỏng (vscode issue #165821). Mỗi chữ gõ đều dời con trỏ, nên sau mỗi chữ ô lại chứa từ trước con trỏ mới.
- Ô cũng được viết lại khi nhận focus, khi chế độ hỗ trợ trình đọc màn hình đổi và ở mỗi lần vẽ khung hình. Lần viết lại khi vẽ chỉ chạy khi chế độ bật (vscode issue #192278).
- Đang soạn chữ đánh dấu (composition) thì ô không bị viết lại.
- Khi ô đổi vì bàn phím hay bộ gõ (sự kiện `input`), Monaco so nội dung và vùng chọn mới với trạng thái nó ghi lần trước (`TextAreaState.deduceInput`). Nó suy ra số ký tự bị thay trước con trỏ cùng chữ mới, rồi áp vào mô hình văn bản. Monaco không đọc vị trí tuyệt đối nào từ ô.

**Electron và chế độ `auto`** (đọc mã; VS Code `main` `a902b1c8`; Electron v40.10.3, đối chiếu v43.8.9, phần trợ năng không đổi; gói Cursor 3.31.15 có cùng hai đường dưới đây):
- Khi mở cửa sổ, VS Code đọc `app.accessibilitySupportEnabled` của Electron (`windowsMainService.ts`). Lớp `NativeAccessibilityService` đặt chế độ bật nếu giá trị đó đúng, ngược lại đặt tắt.
- Sau đó, mỗi sự kiện `accessibility-support-changed` của Electron đổi chế độ cho mọi cửa sổ (`app.ts`, `window.ts`).
- Ở Electron (`electron_api_app.cc`), `accessibilitySupportEnabled` chỉ đúng khi chế độ trợ năng của Chromium đầy đủ (`kAXModeComplete`).
- Trên macOS, theo `electron_application.mm`, chế độ đầy đủ bật trong ba trường hợp. VoiceOver đang chạy. Một app đặt thuộc tính `AXEnhancedUserInterface`, sau 2 giây không đổi nữa. Một app đặt `AXManualAccessibility`. Sự kiện `accessibility-support-changed` chỉ phát khi có app đặt một trong hai thuộc tính đó. Chú thích trong mã nói từ macOS Sonoma đôi khi thấy `AXEnhancedUserInterface` bật rồi tắt rất nhanh mà không rõ nguồn.
- Một app chỉ hỏi vai trò (`accessibilityRole`) của app Electron qua API trợ năng chỉ bật chế độ cơ bản (`kAXModeBasic` hoặc `kNativeAPIs`), không bật chế độ đầy đủ. Script gõ thử hỏi Cursor qua System Events (cửa sổ đang focus, phần tử đang focus), nên theo mã thì riêng script không làm Monaco sang chế độ bật. Chromium có tự nâng mức trợ năng khi bị hỏi sâu vào nội dung trang hay không thì chưa đọc (suy luận, cần kiểm chứng).
- Khi chế độ bật mà cài đặt là `auto`, thanh trạng thái hiện mục "Screen Reader Optimized" và app hỏi một lần "Screen reader usage detected…" (`accessibilityStatus.ts`). Gói Cursor có cả hai chuỗi này (đọc gói app). Người dùng trả lời câu hỏi đó thì app ghi `editor.accessibilitySupport` thành `on` hoặc `off` vĩnh viễn.

## 3. Chromium trả lời bộ gõ thế nào với ô textarea

Phần chung đã tả ở [`WebEditorInput.md`](WebEditorInput.md) mục 8 và 10.2: `selectedRange` và `attributedSubstring(forProposedRange:actualRange:)` trả từ bản sao trong tiến trình trình duyệt; bản sao cập nhật bất đồng bộ khi trang báo vùng chọn đổi; `insertText` không có vùng thay sửa tạm bản sao. Phần dưới chỉ ghi điều riêng cho ô textarea (đọc mã Chromium tag 150.0.7871.250, đối chiếu 144.0.7559.236, các hàm dưới đây không đổi).

- **Toạ độ là của ô textarea.** `RenderFrameImpl::SyncSelectionIfRequired` lấy vùng chọn từ `InputMethodController::GetSelectionOffsets`. Hàm này tính vùng chọn trong phần tử soạn thảo gốc đang focus. Với ô textarea, phần tử đó là ô. Chữ gửi lên là giá trị của ô, tối đa 100 ký tự mỗi bên vùng chọn. Ở chế độ tắt, ô ngắn hơn 100 ký tự nên bản sao chứa trọn ô.
- **Vùng thay cũng tính trong ô, lúc trang xử lý lời gọi.** `insertText` có vùng thay đi tới `WebInputMethodControllerImpl::CommitText`, rồi `InputMethodController::ReplaceTextAndKeepSelection`. Hàm này dựng vùng trong phần tử soạn thảo gốc (`EphemeralRangeForOffsets`, `PlainTextRange::CreateRangeFor`), chèn chữ, rồi đặt lại vùng chọn cũ dời theo độ dài chữ mới.
  - Nếu điểm đầu vượt quá cuối ô, vùng rỗng và hàm trả về mà không chèn gì. Lời gọi bị bỏ trọn.
  - Nếu điểm đầu bằng cuối ô, vùng là điểm cuối ô và chữ được chèn ở đó.
  - Nếu chỉ điểm cuối vượt ô, vùng bị cắt tới cuối ô.
  - Con trỏ đứng sau vùng vừa thay thì vẫn ở sau chữ theo sau vùng đó.
- **Đối chiếu log.** Log trình soạn thảo Cursor 3.29.15 (10/11/2026) cho thấy bốn điều. Thứ nhất, vùng bắt đầu sau cuối chữ app giữ bị bỏ. Thứ hai, vùng bắt đầu đúng ở cuối chèn tại đó. Thứ ba, trang áp vùng theo toạ độ nó có lúc xử lý. Thứ tư, con trỏ ở lại sau chữ theo sau vùng thay. Bốn điều này khớp từng nhánh của mã Blink ở trên, tức đường textarea, không phải đường EditContext.
- **Theo Apple, đây không phải lỗi giao thức.** Tài liệu `selectedRange()` của `NSTextInputClient` nói vùng trả về tính từ đầu kho chữ (text storage) của đối tượng nhận, từ 0 tới độ dài tài liệu. Tài liệu `insertText(_:replacementRange:)` nói vùng thay là vùng trong kho chữ của đối tượng nhận. Với Chromium, đối tượng nhận là phần tử đang focus, tức ô textarea. Monaco đổi nội dung ô ở mỗi chữ, nên "tài liệu" mà bộ gõ thấy chỉ là một từ.

## 4. Dự đoán cho "chiều nay. Hoc␣⌫j" ở 10 ms/phím

**Ở chế độ tắt** (đường textarea, theo mục 2 và 3; trình tự trong trang là đọc mã, thời điểm bản sao nhận cập nhật là suy luận):
1. Sau "c", ô là "Hoc", con trỏ ở 3, và trang báo lên bản sao.
2. Dấu chèn dấu cách (`insertText` không có vùng thay). Bản sao lập tức thành "Hoc␣", con trỏ ở 4 (sửa tạm). Trong trang, Blink chèn dấu cách vào ô. Monaco áp dấu cách vào mô hình, con trỏ dời, ô được viết lại thành " ", con trỏ ở 1, và trang báo lên.
3. ⌫ đi thẳng. Trong trang, Blink xoá dấu cách trong ô. Monaco suy ra xoá một ký tự, con trỏ lùi, ô được viết lại thành "Hoc", con trỏ ở 3, và trang báo lên.
4. Ở "j", Dấu đọc bản sao. Tuỳ bản sao đã nhận tới bước nào, có ba câu trả lời:
   - Chưa nhận báo nào sau bước 1: 4 với "Hoc␣". Câu trả lời này cũng có nếu trang chậm hơn nữa, vì các chữ Dấu chèn đều được sửa tạm vào bản sao.
   - Đã nhận báo của bước 2, chưa nhận bước 3: 1 với " ".
   - Đã nhận bước 3: 3 với "Hoc".
5. Lời thay của "j" tới trang sau ⌫, vì trang xử lý theo thứ tự gửi. Lúc đó ô là "Hoc", nên vùng đúng là (1, 2) trong ô, dù bản sao đã trả gì.

**Ở chế độ bật**, ô chứa cả trang, nên vị trí ở "j" tính từ đầu văn bản (14 trở lên). Bản sao chậm theo đúng dạng bộ đệm Chromium mà phép chứng minh app chậm của D11 đã xử lý. **Ở đường EditContext** (VS Code 1.147), chữ là cả dòng hiện tại và vị trí tính từ đầu dòng. Với câu thử một dòng thì đó cũng là đầu văn bản. Chế độ hỗ trợ trình đọc màn hình không đổi gì ở đường này.

**Câu trả lời cũ qua ranh giới từ** (chế độ tắt; suy luận, cần kiểm chứng từng từ). Ở phím thay chữ đầu tiên của một từ mới, bản sao có thể còn chứa từ trước, chỉ " ", hoặc từ trước cộng các chữ Dấu vừa chèn. Vị trí đó tính theo một ô đã không còn. Dấu dựng vùng thay từ vị trí đó hoặc từ vị trí nó theo dõi theo toạ độ tài liệu. Khi lời gọi tới trang, ô chỉ chứa từ mới, nên có ba khả năng. Vùng bắt đầu sau cuối ô thì lời gọi bị bỏ, nên dấu không được đặt ("meting", "nguoiwf", "trươcs"). Vùng rơi vào chỗ khác trong ô thì chữ bị chèn hay thay lệch, sinh chữ lặp ("keế", "moột", "dđược", "àyay"). Vùng trùng đúng chỗ thì chữ đúng. Câu trả lời ở chế độ này không quá độ dài một từ cộng vài chữ sửa tạm, khớp quan sát `selectedRange` không quá 6 trong cả câu dài.

**Ba giả thuyết và các quan sát:**
- H1: Cursor dùng ô textarea. Chế độ hỗ trợ trình đọc màn hình chốt kiểu vị trí cho từng cửa sổ: tắt thì tính từ đầu từ, bật thì tính từ đầu văn bản.
- H2: Cursor có lúc dùng ô textarea ở chế độ tắt, có lúc dùng EditContext, do cài đặt hay cấu hình từ xa đổi.
- H3: chỉ do bản sao của Chromium, không do Monaco.

| Quan sát | H1 | H2 | H3 |
|---|---|---|---|
| Kiểu tính từ đầu từ, `selectedRange` không quá 6 trong câu dài | giải thích | giải thích | không: VS Code cùng Chromium 150 luôn tính từ đầu văn bản, và bản sao giữ vị trí tuyệt đối trong phần tử |
| Ở "j": 3 với "Hoc", 4 với "Hoc␣", 1 với một đơn vị không phải "c" | giải thích cả ba (bước 4 ở trên; đơn vị đó là dấu cách) | giải thích, ở lúc dùng ô textarea | không |
| Từ sai qua ranh giới từ ở 5–10 ms | giải thích loại lỗi (bỏ vùng, cắt vùng); từng từ chưa đối chiếu | như H1 | không |
| Kiểu tính từ đầu văn bản, chậm 1–4 thao tác dạng bộ đệm Chromium, chữ đúng | giải thích (chế độ bật) | giải thích (EditContext) | — |
| Cùng bản Cursor, buổi sáng tính từ đầu văn bản, buổi chiều tính từ đầu từ; 1/10 lượt lẻ tính từ đầu văn bản | giải thích nếu trạng thái trợ năng của Electron khác nhau lúc mở từng cửa sổ thử. Điều gì bật nó thì chưa rõ. | chỉ giải thích nếu cài đặt hay cấu hình từ xa đổi giữa các lượt; lượt lẻ giữa một vòng khó giải thích | không |
| VS Code 1.147 luôn đúng, luôn tính từ đầu văn bản | giải thích (EditContext bật mặc định) | giải thích | — |
| Khung agent và ô nhập Agents luôn đúng | không nói gì: hai ô này không phải trình soạn thảo Monaco (suy luận, cần kiểm chứng) | như H1 | — |

H1 và H2 đều giải thích các câu trả lời ở "j" và các lỗi qua ranh giới từ, vì hai giả thuyết chung phần ô textarea ở chế độ tắt. Hai giả thuyết chỉ khác nhau ở kiểu "tính từ đầu văn bản" đến từ đâu. H1 hợp hơn với lượt lẻ giữa một vòng. Gói Cursor mặc định tắt EditContext, nên H2 cần một thay đổi cài đặt chưa ai thấy. Không giả thuyết nào chỉ ra điều gì đã bật chế độ trợ năng trên máy đo. Các ứng viên gồm VoiceOver, app quản lý cửa sổ hay app tiện ích đặt `AXEnhancedUserInterface`, và một app đặt `AXManualAccessibility` (suy luận, cần kiểm chứng).

## 5. Phép đo xác nhận

Phép đo ngày 23/11/2026 (máy M1 Pro, Cursor 3.31.15, câu `edit` 10 ms; số ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.4) khớp dự đoán của H1 ở cả ba cài đặt: `"editor.accessibilitySupport": "off"` cho vị trí tính từ đầu từ và chữ sai; `"on"`, hoặc `"off"` kèm `"editor.experimentalEditContextEnabled": true`, cho vị trí tính từ đầu văn bản (câu một dòng) và chữ đúng cả câu. Kiểu vị trí đi theo đường nhập và chế độ hỗ trợ trình đọc màn hình của Monaco, không theo Dấu. Điều gì bật chế độ đó khi cài đặt là `auto` vẫn chưa rõ.

## 6. Thiết kế sửa: ô chỉ giữ từ trước con trỏ

Mục này là thiết kế của hướng B, đã làm trong mã (`HeldText`, `CursorTracker.Coordinates.heldText`; cấu trúc ở [`docs/Architecture.md`](../Architecture.md), ý "Ô chỉ giữ từ trước con trỏ"). Luật nằm ở [`docs/Decisions.md`](../Decisions.md) N3 và D11. Bằng chứng là phép đo trên app thật ở cuối mục; test đơn vị chỉ kiểm logic của chính Dấu, không dựng mô hình ô textarea hay bộ đệm của Chromium.

### 6.1 Ý chính

Ở đường textarea chế độ tắt, vùng thay đúng là vùng trong chữ mà ô giữ **lúc trang áp lời gọi**. Trang áp mọi lời gọi theo thứ tự Dấu gửi (mục 3). Vì vậy lúc đó ô chứa đúng từ trước con trỏ sau mọi thao tác Dấu đã gửi. Dấu tự tính được từ đó từ chữ nó đã gõ, theo luật của mục 2. Câu trả lời của app không bao giờ cho vùng thay; nó chỉ dùng để kiểm và để nhận ra kiểu ô.

Thiết kế thêm cho `CursorTracker` một hệ toạ độ thứ hai, "ô chỉ giữ từ trước con trỏ", bên cạnh hệ toạ độ văn bản đang có. Ở hệ mới, mọi vị trí Dấu theo dõi (`followed.caret`, `predictedCaret`) là độ dài chữ ô giữ, gọi là L. Mọi phần còn lại của composer (D4, D20, D26, D30, D32, D33) giữ nguyên, vì chúng chỉ cần "k đơn vị cuối trước con trỏ" và vị trí con trỏ.

### 6.2 Chữ ô giữ, tính từ chữ Dấu biết

Đây là một hàm thuần của trạng thái Dấu. Đầu vào là chữ Dấu biết ngay trước con trỏ (chữ nó đã gõ, `typedBeforeCaret`, cộng chữ đọc được lúc neo) và điều Dấu biết về phần đứng trước chữ đó. Phần đứng trước có ba khả năng: chưa biết, một ranh giới (ký tự không thuộc từ hoặc đầu dòng), hoặc đúng n đơn vị thuộc từ rồi tới một ranh giới.

- Đơn vị thuộc từ là đơn vị UTF-16 không phải dấu cách, Tab, xuống dòng hay một dấu trong giá trị mặc định của `editor.wordSeparators` (mục 2). Chữ có dấu tiếng Việt, chữ số, dấu kết hợp, `_` và các dấu ngoài ASCII như “ ” … – đều thuộc từ.
- Dấu đếm các đơn vị thuộc từ ở cuối chữ nó biết. Gặp ranh giới thì dừng. Tới đầu chữ nó biết thì cộng phần đứng trước nếu biết; nếu không biết thì L chưa biết, trừ khi đã đếm đủ 51.
- Đếm được ít nhất một đơn vị thì L là số đó, tối đa 51, và chữ ô giữ là chừng ấy đơn vị cuối.
- Không có đơn vị nào thì ô giữ một ký tự trước con trỏ, L là 1 (trừ khi ký tự đó là nửa đầu cặp thay thế). Ở đầu dòng, L là 0. Nếu Dấu không biết ký tự trước con trỏ thì L chưa biết.

Dấu ghi kèm mỗi thao tác trong `followed.edits` cặp (L, chữ ô giữ) sau thao tác đó, ở cả hệ toạ độ văn bản. Nhờ vậy việc nhận ra kiểu ô (mục 6.4) và việc kiểm câu trả lời cũ (mục 6.5) không cần đọc thêm.

### 6.3 Vùng thay cho từng thao tác

Mọi lần thay của Dấu thay k đơn vị cuối ngay trước con trỏ, và k đơn vị đó là chữ cái của từ trong engine. Chữ cái luôn thuộc từ theo luật của Monaco, nên chúng nằm trong chữ ô giữ. Vùng thay ở hệ mới luôn là **(L − k, k)**, với L tính sau mọi thao tác Dấu đã gửi trước lời gọi này. Vùng này kết thúc ở cuối ô, nên bất biến "vùng thay kết thúc ở vị trí Dấu theo dõi" của D11 vẫn đúng, tính theo hệ mới.

| Thao tác | k và chữ chèn | L sau thao tác |
|---|---|---|
| Dấu thanh, biến đổi trong từ (D28) | k chữ cuối, chữ mới | L − k + độ dài chữ mới |
| Gõ đúp xoá dấu (D26) | như trên | như trên |
| Lần gieo của D20 sau ⌫ ("Hoc␣⌫j") | k ≤ độ dài từ gieo; L là 3 sau khi ⌫ xoá dấu cách Dấu biết, vùng (1, 2) | như trên |
| Khôi phục khi kết thúc từ (D4) và khôi phục ngay (D33) | k chữ của từ, chữ chèn là phím gốc cộng ký tự kết thúc từ | tính lại từ chữ chèn: ký tự kết thúc là ranh giới thì L là 1, nếu không thì cộng dồn |
| Backspace dời dấu (D32) | k chữ, chữ chèn kèm lại chữ cuối; ⌫ của app xoá chữ đó | như dòng đầu, rồi trừ 1 khi ⌫ áp |
| Ký tự Dấu tự chèn (N3) | không có vùng | thuộc từ thì cộng 1 (tối đa 51), không thuộc từ thì là 1 |
| ⌫ đi thẳng | không có vùng | xoá chữ Dấu biết thì tính lại theo mục 6.2; không biết thì L chưa biết |
| Reset (click, mũi tên, phím tắt, Return, Tab, đổi nguồn) | không có vùng | chưa biết; lần đọc kế tiếp (D20) neo lại |

Khi L chưa biết hoặc k > L, Dấu không gửi lần thay theo hệ mới mà xử lý như lệch vị trí của D11.

Neo lại từ một lần đọc: nếu câu trả lời a ≤ 16 và chữ đọc được dài đúng a, chữ đó là toàn bộ chữ ô giữ. Trước nó là ranh giới, hoặc nó là ký tự đơn ở mục 6.2. Nếu a lớn hơn 16, chữ đọc được là 16 đơn vị cuối, và trước chúng có đúng a − 16 đơn vị thuộc từ.

### 6.4 Nhận ra ô chỉ giữ từ trước con trỏ và khi nào đổi lại

Mỗi client bắt đầu ở hệ toạ độ văn bản, tức hành vi hiện nay. Hệ toạ độ gắn với client. Click hay reset không đổi nó, vì chế độ của Monaco chốt theo cửa sổ (mục 2). Mở lại cửa sổ là một client mới.

**Sang hệ mới.** Dấu chỉ xét ở lần đọc vốn có của D11 (câu trả lời khác vị trí Dấu theo dõi) và của D20, sau khi phép chứng minh app chậm của hệ văn bản không qua. Câu trả lời a với chữ đọc được R phải đạt đủ bốn điều kiện:
1. a ≤ 16 và R dài đúng a, tức Dấu thấy toàn bộ chữ app giữ, từ vị trí 0.
2. (a, R) trùng chữ ô giữ của một trạng thái trong `followed.edits`, ở dạng (a) hoặc dạng (b) của mục 6.5, trong giới hạn chậm của D11.
3. Dấu biết trọn chữ ô giữ của trạng thái đó. Nếu a = 1, R phải là một chữ cái, trạng thái khớp phải thuộc từ đang gõ và chậm ít nhất một thao tác, và R không trùng chữ ô giữ hiện tại.
4. (a, R) không trùng trạng thái nào của chữ Dấu theo dõi theo hệ văn bản mà cũng trùng chữ Dấu đã gõ, ở cả hai dạng và không giới hạn số thao tác (`CursorTracker.fitsDocumentState`). Nếu không đòi trùng chữ Dấu đã gõ, "Hoc" ở vị trí 3 khớp về hình học với trạng thái sau "chi" của "chiều nay. Hoc".

Đạt thì Dấu sang hệ mới ngay ở phím đó và thay ở (L − k, k). Lần xét này không thêm lời gọi nào.

Ở Cursor, phím đầu có lần đọc của D20 neo vị trí theo câu trả lời. Vì vậy ở từ đầu tiên hai hệ cho cùng vùng thay. Lần thay đầu của từ thứ hai trở đi có câu trả lời khác vị trí theo dõi, nên Dấu nhận ra kiểu ô ở đó, trước khi hai hệ cho vùng khác nhau. Khi phím dồn, câu trả lời đó thường là chữ ô giữ một đơn vị. Đó có thể là dấu cách cộng chữ cái Dấu vừa chèn (2 với "␣o" ở "moj"), hoặc chữ cái đầu của từ (1 với "m"). Cả hai đạt điều kiện 3, nên Dấu nhận ra kiểu ô ngay ở phím đó.

**Về hệ văn bản.** Ở hệ mới, câu trả lời khác L thì Dấu đọc một lần (như D11 hiện nay). Dấu về hệ văn bản khi câu trả lời không khớp trạng thái nào của mục 6.5 và cho thấy chữ ngoài từ trước con trỏ, theo một trong hai cách:
- a lớn hơn 52, độ dài lớn nhất ô có thể có (51, cộng một ký tự chèn theo dạng (b));
- R có một ranh giới với đơn vị thuộc từ ở cả hai phía, và phần cuối R trùng chữ Dấu đã gõ qua ranh giới đó.

Khi về, câu trả lời được xử lý như mọi câu trả lời khác vị trí ở hệ văn bản (D11): ở đầu từ thì Dấu tin nó, giữa từ thì dựng lại hoặc reset. Trường hợp này xảy ra khi chế độ hỗ trợ trình đọc màn hình bật giữa phiên, hoặc khi người dùng bật EditContext rồi mở lại trình soạn thảo. Cái giá lớn nhất là một từ không có dấu ở phím đổi.

### 6.5 Dấu dùng câu trả lời `selectedRange` vào việc gì

Ở hệ mới, câu trả lời chỉ dùng để kiểm, không dùng để tính vùng.
- Câu trả lời bằng L: app đúng giờ, Dấu không đọc.
- Câu trả lời khác L: Dấu đọc một lần. Nếu (a, R) khớp chữ ô giữ của một trạng thái sau một trong các thao tác gần nhất, Dấu coi là app chậm và thay ở (L − k, k). Có hai dạng khớp: dạng (a) là đúng trạng thái đó; dạng (b) là trạng thái đó cộng ký tự Dấu chèn tại con trỏ mới nhất sau nó (bộ đệm Chromium, mục 3). Giới hạn số thao tác như D11. Mọi thao tác xoá ở giữa phải biết chữ bị xoá.
- R kết thúc bằng toàn bộ chữ Dấu đã gõ của từ đang gõ, nhưng phần đứng trước khác dự đoán: đó là trạng thái hiện tại, với ranh giới từ khác luật mặc định (mục 6.7). Dấu neo lại L bằng a và phần đứng trước theo R, rồi thay ở (L − k, k).
- Không khớp và không cho thấy hệ văn bản: giữa từ là lệch (D11: dựng lại khi phím trước cách đủ 50 ms, nếu không thì reset). Ở đầu từ, khi phím trước cách đủ 50 ms, Dấu neo lại theo mục 6.3; khi phím dồn, Dấu giữ L, vì người dùng không kịp làm gì mà IMK không báo.

Ba câu trả lời đo được ở "j" của "Hoc␣⌫j" đều được xử lý như vậy: 3 với "Hoc" là đúng giờ; 4 với "Hoc␣" là dạng (b) của trạng thái sau "c"; 1 với "␣" là dạng (a) của trạng thái sau dấu cách. Cả ba cho vùng (1, 2). Lần gieo của D20 dùng chữ dựng lại từ trạng thái đó và các thao tác sau nó, như phép chứng minh app chậm hiện nay.

Chờ ⌫ chưa áp (N3): vị trí "trước khi ⌫ áp" là L của trạng thái ngay trước ⌫, tính theo hệ đang dùng. Ví dụ, sau "Hoc␣⌫" vị trí đó là 1, không phải 3 + 1. Luật chờ giữ nguyên, vì Monaco cũng chạy trong Safari (vscode.dev, github.dev), nơi ⌫ phải chờ trong hàng phím của WebKit.

### 6.6 Số lời gọi mỗi phím (N3)

| Phím ở hệ mới | `selectedRange` | Đọc chữ | `insertText` |
|---|---|---|---|
| Có thay chữ, câu trả lời bằng L | 1 | 0 | 1 |
| Có thay chữ, câu trả lời khác L | 1 | 1 | 1 hoặc 0 |
| Lần đọc của D20, phép kiểm từ đã hết hợp lệ | như bảng ở `docs/Architecture.md`, mục "Vị trí thay chữ" | | |
| Ký tự Dấu tự chèn, phím đi thẳng | 0 (trừ chờ ⌫) | 0 | 1 hoặc 0 |

Ở Cursor chế độ tắt, mã hiện nay đọc một lần ở lần thay đầu của mỗi từ, vì câu trả lời luôn khác vị trí theo dõi. Ở hệ mới, Dấu chỉ đọc khi app chậm. Việc nhận ra kiểu ô dùng lần đọc vốn có, nên không thêm lời gọi.

### 6.7 Ca hỏng và giới hạn

| Ca | Hệ quả | Giới hạn |
|---|---|---|
| `editor.wordSeparators` của người dùng hay của ngôn ngữ tệp khác giá trị mặc định | L sai khi ký tự ngay trước từ được xếp loại khác | Câu trả lời đúng giờ khác L nên Dấu đọc lại và neo lại L (mục 6.5, ý thứ ba). Khi phím dồn và câu trả lời cũ thì không ý nào khớp, nên từ đó có thể không có dấu. Chỉ các từ đứng sát ký tự xếp loại khác bị ảnh hưởng. |
| Click, chọn chữ, mũi tên | reset, L chưa biết | Lần đọc của D20 ở phím đầu neo lại L. Nếu D20 tắt, Dấu tin câu trả lời ở lần thay đầu, như hệ văn bản. |
| Monaco tự sửa chữ: chọn gợi ý bằng ký tự xác nhận (`.` `(`), tự đóng ngoặc, định dạng khi gõ | chữ trước con trỏ khác chữ Dấu biết | Tự đóng ngoặc chỉ thêm chữ sau con trỏ, nằm ngoài ô, nên không đổi L. Các trường hợp còn lại xảy ra ở ranh giới từ. Câu trả lời đúng giờ ở lần thay sau khác L, nên Dấu đọc rồi neo lại (đầu từ) hoặc reset (giữa từ). Đây cũng là giới hạn của hệ văn bản hiện nay. |
| Nhiều con trỏ | Monaco áp cùng một lần thay cho mọi con trỏ, theo con trỏ chính | Đây là cách Monaco làm với mọi bộ gõ; Dấu chỉ theo con trỏ chính. |
| Từ dài hơn 51 đơn vị (tên biến dài) | ô chỉ giữ 51 đơn vị cuối | k ≤ 13 nên vùng (51 − k, k) vẫn đúng. |
| Vùng chọn khác rỗng | ô chứa vùng chọn | Mọi cách chọn chữ đều reset Dấu trước đó. Ở hệ mới, Dấu coi vùng chọn là lệch, không áp ý "Gợi ý tự hoàn thành". |
| Câu trả lời ở lần thay đầu sau ranh giới từ là một trạng thái của từ đầu tiên trong văn bản, nơi chữ ô giữ trùng cả văn bản | hai hệ giải thích câu trả lời như nhau; Dấu theo hệ văn bản (điều kiện 4), nên vùng thay sai và từ đó thiếu dấu ("mot") | Đo được 2 lần trong 49 lượt `edit` 5 ms trên Cursor 3.31.15. Nếu chọn hệ mới ở ca này thì Chrome khi trang kẹt sau từ đầu sẽ bị sửa sai từ đầu. |
| Câu trả lời là chính vùng thay Dấu vừa gửi, có độ dài khác 0 (`(2, 2)` sau lần thay "ươ") | Dấu coi là lệch, nên chữ cái sau đó không thêm dấu ("trươcs") | Gặp 1 lần trên Cursor 3.31.15 ở 5 ms; cơ chế chưa rõ. |
| Dấu đã ở hệ mới, phím dồn | 1 lần ra "đeeuf" thay vì "đều" (câu trả lời 1, chữ đọc được không khớp trạng thái nào) | Gặp 1 lần trong 10 lượt `edit` 5 ms; cơ chế chưa rõ, vì log không ghi chữ đọc được (D8). |

### 6.8 Vì sao app tính từ đầu văn bản không bị nhận nhầm

Dấu chỉ xét việc đổi hệ khi câu trả lời khác vị trí Dấu theo dõi. Vì vậy app trả lời đúng giờ (AppKit, Notes, Safari, mọi app khi rảnh) không bao giờ được xét. Với câu trả lời khác vị trí:

- **App tính từ đầu văn bản, trả lời chậm** (Chrome, Edge khi trang bận hay phím dồn; VS Code; Firefox): điều kiện 1 và 2 cùng đạt chỉ khi cả văn bản trước con trỏ cũ đúng bằng chữ ô giữ ở một trạng thái nào đó. Chữ đó do chính Dấu gõ ở đầu văn bản, nên trạng thái đó có trong `followed.edits` và điều kiện 4 loại nó. Lịch sử dài 256 thao tác, còn Chrome trang bận đã đo chậm tối đa 12. Ca "Hoc nay. Hoc" (test `HeldTextTests.detection`) rơi vào đúng trường hợp này.
- **VS Code 1.147 (EditContext):** vị trí tính từ đầu dòng. Sau Return, Dấu reset và neo lại ở lần đọc của D20, nên lịch sử cũng tính từ đầu dòng và điều kiện 4 vẫn áp.
- **Google Docs:** app luôn trả 1 với ký tự ngay trước con trỏ (`docs/Compatibility.md` mục 5.10). Điều kiện 3 loại ký tự đó khi nó là chữ ô giữ hiện tại, là dấu cách, hay chỉ khớp một từ trước ranh giới. Google Docs chỉ bị nhận nhầm khi chữ cái cuối của từ trùng chữ cái đầu của chính từ đó ("non"). Luật này chưa đo trên Google Docs.
- **Word trên web, TipTap, Notes, Telegram:** vị trí tính từ đầu văn bản và đã đo là đúng giờ hoặc chậm theo dạng bộ đệm. Lý do như ý đầu.
- **Ô bỏ qua vùng thay (D43):** nếu bị nhận nhầm thì vùng thay vẫn bị bỏ qua như hiện nay, nên không có gì tệ hơn.
- **Nhận nhầm còn lại:** con trỏ của một app tính từ đầu văn bản sang chỗ mà cả phần trước nó đúng bằng một từ Dấu vừa gõ, mà IMK không báo (ví dụ click vào thanh địa chỉ Chrome). Khi đó, nếu trạng thái khớp là trạng thái hiện tại thì vùng thay của hai hệ trùng nhau. Ở từ sau, câu trả lời cho thấy chữ ngoài từ, nên Dấu về hệ văn bản (mục 6.4).

### 6.9 Điều thay cho `wordFromWordStart`

Bản sửa ở commit `0208bdd` (`CursorTracker.wordFromWordStart`) đã bỏ, cùng `WordStartAnswer` và các trường log `typed_read_word_start*`. Hệ mới phủ cả ba câu trả lời ở "j", gồm cả câu trả lời 1 mà bản sửa đó không nhận. Ràng buộc duy nhất cần giữ của bản sửa đó, câu trả lời khớp một trạng thái cũ của hệ văn bản thì không hiểu là tính từ đầu từ, trở thành điều kiện 4 của mục 6.4.

Các luật của phép chứng minh app chậm mà lý do ghi là "app tính theo từ" vẫn giữ: hai đơn vị so ở `typedHere`, `agrees`, và luật đơn vị thiếu đứng sau đơn vị đã so ở `withMissingUnits`. Trước khi Dấu nhận ra kiểu ô, Cursor vẫn đi đường của hệ văn bản, và các luật đó giữ cho câu trả lời đúng giờ của Cursor không bị coi là chậm. Nếu phép đo ở mục 6.11 cho thấy Dấu luôn nhận ra kiểu ô trước lần thay thứ hai của phiên, ba luật đó được xem lại.

### 6.10 Test đơn vị

Các test dưới đây (`HeldTextTests`, `HeldTextComposerTests`) là hàm thuần của trạng thái Dấu, hoặc dùng đồ giả chỉ ghi lời gọi và trả câu trả lời đã viết sẵn lấy từ log app thật. Không test nào dựng ô textarea hay bộ đệm Chromium.

1. **Chữ ô giữ** (mục 6.2), từ chữ Dấu biết và phần đứng trước: "nay. Hoc" ra 3 "Hoc"; "nay. Hoc␣" ra 1 "␣"; "x.y" ra 1; "“Hoc" sau dấu cách ra 4; "foo_hoc" ra 7; 60 chữ cái ra 51; Tab ra 1; chữ rỗng ở đầu dòng ra 0; "Hoc" mà phần trước chưa biết ra chưa biết; neo a = 20 với 16 đơn vị đọc được thì cộng 4.
2. **L sau từng thao tác** (bảng mục 6.3): chèn "␣" sau "Hoc" ra 1; ⌫ xoá dấu cách đã biết ra 3 "Hoc"; ⌫ xoá chữ chưa biết ra chưa biết; khôi phục D4 có ký tự kết thúc "," ra 1; khôi phục kết thúc bằng "…" thì cộng dồn.
3. **Vùng thay:** dấu thanh trên "tie" + e ra (2, 1); gieo "Hoc" + j ra (1, 2); D4 "mẻt" + dấu cách ra (1, 2) với chữ "etr␣"; D32 "hoà" ⌫ ra (1, 2) với "òà"; D26 "cả" + r ra (1, 1) với "ar"; từ 55 đơn vị + dấu thanh ra (51 − k, k); k > L thì không gửi.
4. **Câu trả lời ở hệ mới** (mục 6.5), với lịch sử của "chiều nay. Hoc␣⌫": (3, "Hoc") là đúng giờ; (4, "Hoc␣") là dạng (b) thiếu 2; (1, "␣") là dạng (a) thiếu 1; (2, "Ho") không khớp; trạng thái quá giới hạn thì không khớp.
5. **Sang hệ mới** (mục 6.4): lịch sử "chiều nay. Hoc␣⌫" theo hệ văn bản với vị trí 14, câu trả lời (3, "Hoc") thì sang; tài liệu mới "Hoc nay. Hoc␣⌫" với (3, "Hoc") thì không sang (điều kiện 4); (1, "h") kiểu Google Docs thì không sang; câu trả lời chậm của Chrome trong giới hạn thì phép chứng minh app chậm thắng; câu trả lời bằng vị trí theo dõi thì không xét. Với lịch sử "Sáng nay mo", (2, "␣o") là dạng (b) thiếu 2 và (1, "m") là dạng (a) thiếu 1, nên đều sang; (1, "o") trùng chữ ô giữ hiện tại ở "Sáng o o", (1, "o") của từ trước dấu cách ở "Sáng o mo" và (1, "␣") thì không sang.
6. **Về hệ văn bản:** ở hệ mới, (219, "…nay. Hoc") thì về; (53, …) thì về; (14, "ay. Hoc") khi chữ đó trùng chữ Dấu đã gõ thì về; (4, "Hoc␣"), (2, "␣H") và (2, "ab") thì không về.
7. **Chờ ⌫ ở hệ mới:** sau "Hoc␣⌫", vị trí chờ là 1.
8. **Composer với đồ giả ghi lời gọi:** "chieeuf nayf. Hoc␣⌫j" trong tệp mới, câu trả lời viết sẵn ở các phím có hỏi (0 ở "c", rồi 4, 5 và 3 với "nay", là vị trí đúng giờ của trình soạn thảo Cursor chế độ tắt); ở "j" lần lượt 3 "Hoc", 4 "Hoc␣" và 1 "␣" như log Cursor 3.31.15. Dấu nhận ra kiểu ô ở "nayf" và cả ba câu trả lời cho vùng (1, 2). Cũng vậy cho D4, D26, D32 và cho câu trả lời 219 cho thấy văn bản. "Sasng nay moj" với câu trả lời 1 "a" ở "s" và, ở "j", 2 "␣o", 1 "m" hay 2 "mo" như log Cursor 3.31.15 khi phím dồn: Dấu sang hệ mới ở "j" và gửi (1, 1). Test kiểm vùng thay đã gửi và số lời gọi mỗi phím, không kiểm chữ của app.

Mô hình `LateDocument.Origin.word` và các test dựa trên nó đã bỏ; các ca của chúng nay là test 4, 5 và 8.

### 6.11 Phép đo trên app thật

App thật là bằng chứng. Bản Debug có thêm các trường log chỉ có số (D8): `held=0|1` (hệ đang dùng), `held_len` (L), `held_match=now|a|b|anchor|none`, `held_lag` (số thao tác app thiếu), `held_switch=held|doc|-`. Các trường `typed_read_*` hiện có giữ nguyên, trừ `typed_read_word_start*`.

Ở chế độ tắt, Cursor 3.31.15 với câu `edit` đúng 9/10 lượt ở 5 ms và 3/3 ở 10 ms. Ở chế độ bật, khi dùng EditContext và ở cài đặt `auto` của máy đo, log không đổi hệ. Chrome, Edge, Firefox, Safari, VS Code, Notes, Terminal và TipTap cho chữ như trước và không đổi hệ lần nào. Số đo và điều kiện nằm ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.4 (Cursor) và mục của từng app.

### 6.12 Các hướng không chọn

- **A. Người dùng bật EditContext trong Cursor** (`editor.experimentalEditContextEnabled`). Cursor khi đó đi đường của VS Code 1.147, đã đo là đúng (mục 5). Dấu không tự sửa cài đặt của app khác. Hướng này chỉ là ghi chú trong `docs/Compatibility.md`, không phải cách sửa của Dấu, vì người dùng mặc định vẫn gặp lỗi.
- **C. Gạch chân cho trình soạn thảo Cursor.** `setMarkedText` với vùng thay `NSNotFound` không cần toạ độ (suy luận, chưa đo trên Cursor 3.30.14 trở đi). Hướng này trái D13 (Gạch chân là đường lui cuối cùng): sửa lỗi đi trước, gạch chân chỉ là đường lui; ở chế độ gạch chân D20 không chạy.
- **Không có API giúp bỏ qua toạ độ.** Theo tài liệu Apple, cả `selectedRange()` và vùng thay của `insertText(_:replacementRange:)` đều tính trong kho chữ của đối tượng nhận. `NSTextInputClient` không có vùng thay tính tương đối với con trỏ. Giả phím ⌫ như OpenKey thì trái cách thay tại chỗ của Dấu (D1 (Nền tảng)).

## Nguồn

Mã nguồn (đọc 23/11/2026):
- VS Code, nhánh `main`, commit `a902b1c8a50d432e738bec7e31a233e82ce63db6`: https://github.com/microsoft/vscode/tree/a902b1c8a50d432e738bec7e31a233e82ce63db6/src/vs/editor/browser/controller/editContext ; `view.ts`, `editorOptions.ts`, `migrateOptions.ts`, `editorConfiguration.ts`, `screenReaderUtils.ts`, `wordHelper.ts`, `wordCharacterClassifier.ts`; `src/vs/workbench/services/accessibility/electron-browser/accessibilityService.ts`, `src/vs/workbench/electron-browser/window.ts`, `src/vs/code/electron-main/app.ts`, `src/vs/platform/windows/electron-main/windowsMainService.ts`, `src/vs/workbench/contrib/accessibility/browser/accessibilityStatus.ts`.
- VS Code tag 1.99.3 và 1.105.1, cùng các file trên: https://github.com/microsoft/vscode/tree/1.99.3 ; https://github.com/microsoft/vscode/tree/1.105.1
- Electron v43.8.9 (đối chiếu v40.10.3): https://github.com/electron/electron/blob/v43.8.9/shell/browser/mac/electron_application.mm ; https://github.com/electron/electron/blob/v43.8.9/shell/browser/api/electron_api_app.cc
- Chromium tag 150.0.7871.250 (đối chiếu 144.0.7559.236): https://chromium.googlesource.com/chromium/src/+/refs/tags/150.0.7871.250/content/renderer/render_frame_impl.cc ; https://chromium.googlesource.com/chromium/src/+/refs/tags/150.0.7871.250/third_party/blink/renderer/core/exported/web_input_method_controller_impl.cc ; https://chromium.googlesource.com/chromium/src/+/refs/tags/150.0.7871.250/third_party/blink/renderer/core/editing/ime/input_method_controller.cc ; https://chromium.googlesource.com/chromium/src/+/refs/tags/150.0.7871.250/third_party/blink/renderer/core/editing/plain_text_range.cc ; https://chromium.googlesource.com/chromium/src/+/refs/tags/144.0.7559.236/content/browser/accessibility/browser_accessibility_state_impl.cc

Gói app cài trên máy đo (đọc file, không chạy): Cursor 3.31.15 (`product.json`, `out/vs/workbench/workbench.desktop.main.js`, `out/nls.messages.json`, phiên bản Electron trong `Electron Framework.framework`); Visual Studio Code 1.147.0 (cùng các file).

Ghi chú phát hành và diễn đàn:
- VS Code 1.101, mục "Edit Context": https://code.visualstudio.com/updates/v1_101
- Diễn đàn Cursor, nền VS Code và phiên bản API: https://forum.cursor.com/t/how-often-is-the-underlying-vs-code-extension-api-updated-in-cursor/162486 ; https://forum.cursor.com/t/request-please-bump-the-underlying-vs-code-extension-api-electron-version-to-the-latest-upstream-release/166421
- Diễn đàn Cursor, bộ gõ tiếng Nhật và `editor.experimentalEditContextEnabled`: https://forum.cursor.com/t/japanese-ime-editor-text-appears-duplicated-when-the-line-wraps/168435 ; bộ gõ tiếng Trung: https://forum.cursor.com/t/chinese-ime-backspace-during-pinyin-composition-deletes-already-committed-text-in-files/169932

Apple:
- https://developer.apple.com/documentation/appkit/nstextinputclient/selectedrange()
- https://developer.apple.com/documentation/appkit/nstextinputclient/inserttext(_:replacementrange:)
