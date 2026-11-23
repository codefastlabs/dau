# Monaco đưa chữ cho bộ gõ thế nào: VS Code và Cursor

File này tìm cơ chế gốc của kịch bản B ở [`LateAnswerFixes.md`](LateAnswerFixes.md): trình soạn thảo của Cursor có lúc trả `selectedRange` tính từ đầu từ, có lúc tính từ đầu văn bản, còn VS Code luôn tính từ đầu văn bản. Số đo nằm ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.3 và 5.4; mô hình trong test là `LateDocument.Origin.word`.

Cách ghi: mỗi khẳng định ghi nguồn. "Đọc mã" là điều đọc thấy trong mã nguồn, tả bằng lời của file này (không chép mã, D10 (Engine tự viết)). "Đọc gói app" là điều đọc thấy trong file JavaScript đã đóng gói của app cài trên máy, không chạy app. "Tác giả ghi" là điều tài liệu, ghi chú phát hành hay trả lời trên diễn đàn nói, chưa ai kiểm lại. "Suy luận, cần kiểm chứng" là ý của file này.

## Hiện trạng (23/11/2026)

- **Cursor 3.31.15 nhận chữ qua ô `<textarea>` ẩn, VS Code 1.147.0 qua EditContext.** Hai app chạy cùng Electron 43.8.9 và Chromium 150.0.7871.250 (đọc gói app). Phần khác nhau chỉ nằm ở Monaco. Trong gói của Cursor, tuỳ chọn `editor.experimentalEditContextEnabled` mặc định tắt ở bản `stable`, như VS Code trước 1.101. VS Code bật EditContext mặc định từ 1.101 (mục 1).
- **Ô textarea chứa gì tuỳ chế độ hỗ trợ trình đọc màn hình của Monaco** (mục 2). Ở chế độ tắt, trên macOS, ô chỉ chứa từ ngay trước con trỏ, hoặc một ký tự trước con trỏ nếu không có từ. Ô được viết lại ngay mỗi khi con trỏ đổi. Ở chế độ bật, ô chứa cả một trang dòng, nên vị trí tính từ đầu văn bản. Với giá trị mặc định `auto`, chế độ đi theo việc Electron có thấy công nghệ hỗ trợ (assistive technology) hay không.
- **Chromium trả lời bộ gõ theo toạ độ của ô textarea** (mục 3). Vì vậy ở chế độ tắt, `selectedRange` và vùng thay tính từ đầu từ. Câu trả lời lấy từ bản sao bất đồng bộ đã tả ở [`WebEditorInput.md`](WebEditorInput.md) mục 8 và 10.2. Blink áp vùng thay theo nội dung ô lúc nó xử lý lời gọi. Vùng bắt đầu sau cuối ô bị bỏ, vùng chỉ có phần cuối vượt ô bị cắt.
- **Giả thuyết H1 giải thích mọi quan sát của trình soạn thảo Cursor, trừ điều gì bật chế độ hỗ trợ trình đọc màn hình** (mục 4). H1: Cursor dùng ô textarea, kiểu vị trí đi theo chế độ đó, và chế độ được chốt khi mở cửa sổ. Nó giải thích ba câu trả lời ở "j" của "Hoc␣⌫j" (3 với "Hoc", 4 với "Hoc␣", 1 với một dấu cách) và các từ sai qua ranh giới từ. Điều gì làm Electron bật chế độ đó trên máy đo thì chưa rõ. Script gõ thử hỏi Cursor qua System Events, nhưng theo mã Electron, chỉ hỏi như vậy thì chưa đủ để bật.
- **Phép đo rẻ nhất** (mục 5): đọc cài đặt của Cursor, nhìn thanh trạng thái tìm mục "Screen Reader Optimized", rồi chạy câu `edit` 10 ms với `editor.accessibilitySupport` đặt cố định `off` rồi `on`.
- **Hướng sửa** (mục 6): ở chế độ tắt, vùng thay đúng tính theo từ trước con trỏ lúc app áp lời gọi. Dấu tự tính được vùng đó từ chữ nó đã gõ, không cần câu trả lời cũ. Cách này cần đổi N3 và D11. Phương án không đổi quyết định nào là ghi cho người dùng bật EditContext trong Cursor, nhưng cách đó chưa đo.

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
- **Đối chiếu mô hình.** Comment của `LateDocument.Origin.word` ghi các điều đo được từ log Cursor 3.29.15. Thứ nhất, vùng bắt đầu sau cuối chữ app giữ bị bỏ. Thứ hai, vùng bắt đầu đúng ở cuối chèn tại đó. Thứ ba, trang áp vùng theo toạ độ nó có lúc xử lý. Thứ tư, con trỏ ở lại sau chữ theo sau vùng thay. Bốn điều này khớp từng nhánh của mã Blink ở trên. Mô hình vì vậy tả đúng đường textarea, không phải đường EditContext.
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

## 5. Phép đo rẻ nhất để phân biệt

Phiên chính chạy theo thứ tự rẻ tới đắt. Bước 1 không chiếm màn hình.

1. **Đọc cài đặt Cursor** (`~/Library/Application Support/Cursor/User/settings.json`). Tìm `editor.accessibilitySupport`, `editor.experimentalEditContextEnabled` và `editor.editContext`. Nếu `accessibilitySupport` là `off`, H1 dự đoán luôn tính từ đầu từ, trừ khi EditContext bật. Nếu là `on`, H1 dự đoán luôn tính từ đầu văn bản.
2. **Nhìn thanh trạng thái** của cửa sổ thử ngay trước mỗi lượt `cursor`, có chụp màn hình. H1 dự đoán mục "Screen Reader Optimized" có mặt đúng ở các lượt tính từ đầu văn bản và vắng ở các lượt tính từ đầu từ. Có thể kèm thêm DevTools (Help › Toggle Developer Tools, nhãn chưa kiểm trên Cursor). Khi trình soạn thảo đang focus, `document.activeElement.className` chứa `inputarea` nghĩa là đường textarea, chứa `native-edit-context` nghĩa là đường EditContext. Còn `document.activeElement.value` cho thấy ô chứa một từ (chế độ tắt) hay nhiều dòng (chế độ bật).
3. **Thử có đối chứng:** chạy câu `edit` 10 ms ở ô `cursor`, bản Debug có log `selectedRange`, ba lượt cho mỗi cài đặt. Cài đặt thứ nhất là `"editor.accessibilitySupport": "off"`; H1 dự đoán mọi lượt tính từ đầu từ. Cài đặt thứ hai là `"on"`; H1 dự đoán mọi lượt tính từ đầu văn bản và chữ đúng như VS Code. Cài đặt thứ ba là `"off"` kèm `"editor.experimentalEditContextEnabled": true`, rồi tải lại cửa sổ; dự đoán là mọi lượt tính từ đầu dòng và chữ đúng. Nếu cả ba ra như dự đoán, cơ chế là đường textarea ở chế độ tắt. Sau lượt đo, trả cài đặt về như cũ.

## 6. Hệ quả cho hướng sửa

Ở đường textarea chế độ tắt, toạ độ đúng cho vùng thay là toạ độ trong từ trước con trỏ **lúc trang áp lời gọi**. Toạ độ đó không phải toạ độ của câu trả lời Dấu vừa đọc. Trang áp mọi lời gọi theo thứ tự Dấu gửi, nên Dấu biết lúc đó ô chứa gì nếu nó biết chữ trước con trỏ theo luật ở mục 2. Đó là từ theo `editor.wordSeparators`, tối đa khoảng 50 ký tự, hoặc một ký tự nếu không có từ. Vùng thay k đơn vị cuối của từ dài L là (L − k, k).

Các hướng dưới đây chỉ liệt kê, chưa thiết kế:

- **A. Người dùng bật EditContext trong Cursor** (`editor.experimentalEditContextEnabled`). Cursor khi đó đi đường của VS Code 1.147, vốn đúng ở mọi ô đã đo. Dấu không đổi mã và không chạm quyết định nào. Dấu không tự sửa cài đặt của app khác. Cái giá: Cursor chưa được đo với tuỳ chọn này (N5 (Chỉ hứa điều đã kiểm chứng)). Trên diễn đàn Cursor có người báo bật tuỳ chọn này sửa được lỗi tiếng Nhật, có người báo không sửa được lỗi tiếng Trung khác (tác giả ghi). Cursor có thể đổi mặc định ở bản sau. Hướng này chỉ là ghi chú trong `docs/Compatibility.md`, không phải cách sửa của Dấu.
- **B. Dấu nhận ra toạ độ theo từ và tự tính vùng thay trong từ.** Đây là hướng 1B ở [`LateAnswerFixes.md`](LateAnswerFixes.md) mục 2.2, nay có luật chính xác từ mã. Vùng thay tính từ chữ Dấu đã gõ, không từ câu trả lời cũ. Câu trả lời chỉ dùng để nhận ra kiểu toạ độ và chữ trước từ mà Dấu không gõ.
  - Cái giá: N3 cấm tự cộng dồn vị trí ngoài chế độ gạch chân, nên cần một ngoại lệ. D11 có bất biến "vùng thay luôn kết thúc ở vị trí Dấu theo dõi". Bất biến này phải hiểu theo toạ độ của từ. Lần đọc của D20 cũng dùng toạ độ này; bản sửa ở `LateAnswerFixes.md` mục 2.3 mới nhận 3 với "Hoc" và 4 với "Hoc␣", chưa nhận 1 với " ".
  - Rủi ro: nhận ra kiểu toạ độ từ câu trả lời dễ lẫn với câu trả lời cũ của app tính từ đầu văn bản khi phím dồn (`sameAnswerAsLateNewDocument`, `staleAnswerAtDocumentStartLooksLikeWordStart` ở `LateAnswerFixes.md`). Cũng cần chép luật ngăn từ của Monaco, mà luật này đổi theo `editor.wordSeparators` và theo ngôn ngữ của tệp.
  - Hướng này không cần biết app là gì, vì Dấu nhận ra kiểu toạ độ qua câu trả lời, nên không trái D5. Nó cũng không phụ thuộc cài đặt: ở chế độ bật và ở EditContext, Dấu vẫn đi đường hiện có.
- **C. Gạch chân cho trình soạn thảo Cursor.** `setMarkedText` với vùng thay `NSNotFound` không cần toạ độ, nên không chịu ảnh hưởng của cơ chế này (suy luận, cần kiểm chứng: gạch chân chưa đo trên Cursor 3.30.14 trở đi). Cái giá: D13 (Gạch chân là đường lui cuối cùng) đặt sửa lỗi trước gạch chân và hiện ghi Cursor không có nhãn. Ở chế độ gạch chân, D20 không chạy.
- **Không có API giúp bỏ qua toạ độ.** Theo tài liệu Apple, cả `selectedRange()` và vùng thay của `insertText(_:replacementRange:)` đều tính trong kho chữ của đối tượng nhận. `NSTextInputClient` không có vùng thay tính tương đối với con trỏ. Giả phím ⌫ như OpenKey thì trái cách thay tại chỗ của Dấu (D1 (Nền tảng)). Một cách không phụ thuộc cài đặt chỉ có thể đến từ việc Dấu tự nhận ra kiểu toạ độ, tức hướng B.

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
