# Khả năng của InputMethodKit so với cách Dấu đang dùng

Kiểm toán các API của InputMethodKit (IMK) và phía app (`NSTextInputClient`, `NSTextInputContext`), để tìm API của Apple có thể sửa các lỗi đang mở thay cho cách vá vòng. Danh sách lỗi đang mở: [`docs/Progress.md`](../Progress.md) mục "Trạng thái hiện tại", ý "Việc mở". Điều đã ghi ở [`docs/research/IMKAPINotes.md`](IMKAPINotes.md) (tham số nil, TSMDocumentAccess, cặp surrogate, kết nối `IMKServer` và sandbox) không chép lại ở đây.

Cách ghi nguồn cho từng khẳng định:

- **[Apple]**: header trong SDK `MacOSX27.2.sdk` của Xcode 27.2 (`IMKInputController.h`, `IMKServer.h`, `IMKInputSession.h`, `NSTextInputClient.h`, `NSTextInputContext.h`, `AERegistry.h`) hoặc trang tài liệu của Apple.
- **[WebKit]**, **[Chromium]**, **[VS Code]**: đọc mã nhánh main ngày 18/11/2026, ghi file và tên hàm. Chưa đối chiếu với đúng bản Safari 27.2, Chrome 157, Cursor 3.30.14 đã đo.
- **[Đo offline]**: chạy trên máy M1 Pro, macOS 27.2.1, không mở cửa sổ, không chạm app nào (mục 3.1).
- **[Suy luận]**: ý của file này, cần kiểm chứng.

## Hiện trạng (18/11/2026)

**Kết luận chung:** IMK công khai không có API nào sửa thẳng các lỗi đang mở. Mọi lời gọi tới app vẫn chỉ là các lời gọi Dấu đã dùng (`selectedRange`, đọc chữ, `insertText`, `setMarkedText`); các API còn lại là hình học (khung chữ, chỉ số theo điểm), thông tin phiên (bundle ID, độ dài tài liệu) hoặc luồng soạn chữ dựng sẵn mà Dấu không cần. Phần có giá trị nằm ở mã của app: WebKit và VS Code cho thấy nguyên nhân hoặc tín hiệu mà Dấu chưa dùng.

Các hướng, xếp theo triển vọng:

1. **App không gửi `activateServer` sau khi cài lại bộ gõ:** làm phần việc của lần kích hoạt ngay ở phím đầu tiên của controller chưa được kích hoạt (đọc `bundleIdentifier()` từ client của phím đó, đăng ký các bộ nghe). Chỉ đổi mã của Dấu, không cần API mới, không trái quyết định nào. Đo trước: test với client giả cho "phím đến khi chưa có `activateServer`"; rồi cài lại bộ gõ và gõ ngay một từ ở Safari, xem log có còn `app=?` không. Mục 4.5.
2. **Cursor trả vị trí theo từ:** mã VS Code cho một giải thích khớp quan sát. Ô nhập dạng `textarea` của VS Code trên macOS chỉ chứa **từ ngay trước con trỏ** khi trình soạn thảo tin là không có trình đọc màn hình. Ở chế độ hỗ trợ trình đọc màn hình, ô đó chứa một trang chữ; ô dùng EditContext chứa các dòng có con trỏ. Đo trước: đọc hai cài đặt `editor.editContext`, `editor.accessibilitySupport` của Cursor, rồi chạy ô `edit` 5 ms một lượt với `editor.accessibilitySupport` đặt "on" và một lượt đặt "off". Mục 4.6.
3. **WebStorm reset sau mỗi phím đi thẳng:** IMK không cho biết vì sao `commitComposition` tới. Hướng khả dĩ là ở chế độ thay tại chỗ, coi `commitComposition` chỉ là gợi ý, vì phép kiểm vị trí của D11 vẫn chạy ở mọi phím thay chữ. Đo trước: phép đo log đã lên kế hoạch ([`docs/research/JetBrainsInput.md`](JetBrainsInput.md) mục 5); có kết quả mới chọn hướng. Mục 4.4.
4. **⌫ ở Safari:** theo mã WebKit, `setMarkedText` với chuỗi rỗng và vùng thay xoá được vùng đó, nên có thể thay mẹo hiện tại (thay hai ký tự bằng ký tự đầu, bản thử chưa gộp, giữ ở tag cục bộ `archive/safari-webkit-key-queue`, chưa push). Giá trị thấp, vì mẹo hiện tại đã đo đúng. Đo trước: một ô Safari. Mục 4.2.
5. **Safari thay sai khi trang chưa nhận kịp phím:** IMK không có cách giữ thứ tự với các phím đang chờ trong hàng của WebKit. Đường duy nhất giữ được thứ tự là mọi thao tác chữ đều do bộ gõ gửi, tức hướng bộ gõ tự chèn ký tự lẽ ra đi thẳng (bản thử chưa gộp, chưa chọn trên `main`, giữ ở tag cục bộ `archive/safari-webkit-key-queue`, chưa push). WebKit từng bật rồi tắt (15/06/2026) một chế độ giữ thứ tự; nếu bật lại, hành vi của `selectedRange` trong lúc xử lý phím sẽ đổi. Không cần đo thêm bây giờ. Mục 4.1.
6. **Google Docs:** không có API công khai nào cho bộ gõ thấy hay sửa quá cửa sổ một ký tự. WebKit có một đường riêng báo cho bộ gõ "trang này cần chữ đánh dấu" với docs.google.com, nhưng `IMKTextInput` không có lời gọi đó, nên bộ gõ bên thứ ba không dùng được. Mục 4.3.
7. **Chữ đánh dấu không gạch chân:** không làm được ở Chromium (đọc mã), làm được ở WebKit bằng thuộc tính màu chữ (đọc mã), và vẫn là chữ đánh dấu với mọi hệ quả của nó. Không phải hướng sửa. Mục 3.

Điều mới so với tài liệu khác (mục 5): theo commit message của WebKit, Telex đơn giản của Apple (commit gọi theo tên, không ghi ID nguồn) gõ bằng `insertText` có vùng thay (thay tại chỗ), kiểm lại bằng `selectedRange`, và tự chuyển sang chữ đánh dấu khi app không áp đúng. Điều này khác cách nói "Telex của Apple dùng chữ đánh dấu" ở [`docs/research/WebEditorInput.md`](WebEditorInput.md) mục 6.

## 1. Dấu đang dùng gì

Kiểm bằng grep trong `Apps/DauInputMethod/Sources/` (18/11/2026, nhánh main):

- Ghi đè trong `DauInputController`: `recognizedEvents`, `handle(_:client:)`, `activateServer`, `deactivateServer`, `commitComposition`, `inputControllerWillClose`, `setValue(_:forTag:client:)`, `menu`. Không ghi đè `init(server:delegate:client:)`.
- Gọi vào client (`IMKTextInput`): `selectedRange`, `attributedSubstring(from:)`, `insertText(_:replacementRange:)`, `setMarkedText(_:selectionRange:replacementRange:)` (chỉ ở chế độ gạch chân, chuỗi trơn, vùng thay `NSNotFound`, `MarkedComposer.showMarked`), `bundleIdentifier()` (một lần ở `activateServer`). `IMKInputController.client()` dùng ở `apply` khi đổi cài đặt.
- `IMKServer(name:bundleIdentifier:)` một lần trong `main.swift`.

## 2. Bảng API

Cột "Giúp gì" ghi việc mở mà API có thể chạm tới; "—" là không giúp việc nào.

### 2.1 Phía bộ gõ: `IMKInputController` và các giao thức nó nhận

| API | Apple nói gì | Dấu | WebKit, Chromium | Giúp gì |
|---|---|---|---|---|
| `handle(_:client:)` | Nhận mọi keyDown và chuột dạng `NSEvent`; trả có nếu đã xử lý. Là một trong ba cách nhận phím, bộ gõ chọn một [Apple] | có | — | cách nhận phím hiện tại |
| `inputText(_:key:modifiers:client:)`, `inputText(_:client:)` | Hai cách nhận phím khác: ký tự kèm mã phím, hoặc chuỗi khi phím không ánh xạ ra lệnh [Apple] | không | — | — |
| `didCommand(by:client:)` | Gọi khi hệ thống ánh xạ phím ra một lệnh (`insertNewline:`, `deleteBackward:`…); trả không để phím tới app. Chỉ thuộc cách nhận phím theo ánh xạ phím [Apple] | không | Chromium vẫn gửi phím gốc cho trang sau lời gọi của bộ gõ, bất kể bộ gõ nhận phím theo cách nào (`keyEvent:` trong `render_widget_host_view_cocoa.mm`) [Chromium] | — (mục 4.2) |
| `recognizedEvents(_:)` | Mặc định chỉ keyDown. Khi chỉ nhận keyDown, IMK tự gửi `commitComposition` lúc người dùng bấm chuột ngoài vùng đang soạn [Apple] | có, thêm chuột | — | — |
| `activateServer(_:)`, `deactivateServer(_:)` | "Kích hoạt", "thôi kích hoạt" bộ gõ; header không nói khi nào hệ thống gọi [Apple] | có | — | việc mở về `activateServer`, mục 4.5 |
| `init(server:delegate:client:)` | IMKServer tạo một controller cho mỗi phiên nhập của client; client lưu trong controller [Apple] | không ghi đè | — | mục 4.5 |
| `client()` | Trả client của controller, luôn theo `IMKTextInput` [Apple] | có (`apply`) | — | mục 4.5 |
| `inputControllerWillClose()` | Báo controller sắp bị đóng [Apple] | có | — | — |
| `commitComposition(_:)` | Client muốn kết thúc phiên soạn ngay; bộ gõ thường gọi `insertText` rồi dọn bộ đệm [Apple] | có, reset (gạch chân: chốt chữ đang hiện) | JBR gửi một lời báo bỏ chữ đang soạn sau mỗi `insertText` ([`docs/research/JetBrainsInput.md`](JetBrainsInput.md) mục 1.2); lời báo đó tới bộ gõ thành `commitComposition` hay không thì chưa có nguồn | WebStorm, mục 4.4 |
| `updateComposition()` | Gọi `composedString(_:)` rồi gửi cho client bằng `setMarkedText`, kèm `selectionRange()` và `replacementRange()` [Apple] | không | — | — (luồng soạn dựng sẵn; Dấu tự gọi `setMarkedText`) |
| `composedString(_:)`, `originalString(_:)` | Chuỗi đang soạn, chuỗi gốc trước khi soạn [Apple] | không | — | — |
| `cancelComposition()` | Thôi soạn, gửi `originalString` cho client bằng `insertText` [Apple] | không | — | — |
| `selectionRange()`, `replacementRange()` | Mặc định: con trỏ ở cuối chữ đánh dấu; vùng thay `NSNotFound` (chèn tại con trỏ). Ghi đè `replacementRange()` để đặt chữ đánh dấu ở chỗ khác con trỏ, ví dụ thay một từ bằng từ đồng nghĩa [Apple]; giá trị mặc định đã đo, mục 3.1 | không | — | — |
| `mark(forStyle:at:)` | Trả bộ thuộc tính để đánh dấu một đoạn chữ đánh dấu, cho kiểu 3, 4, 5 (`kTSMHiliteSelectedRawText`, `kTSMHiliteConvertedText`, `kTSMHiliteSelectedConvertedText`) [Apple]; giá trị đã đo, mục 3.1 | không | mục 3 | — (mục 3) |
| `compositionAttributes(at:)` | Thuộc tính thêm (phông, glyph) cho chữ đánh dấu; mặc định rỗng [Apple] | không | WebKit bỏ qua phông và glyph của chữ đánh dấu (`WebViewImpl::setMarkedText`) [WebKit] | — |
| `setValue(_:forTag:client:)`, `value(forTag:client:)`, `modes(_:)` | Đặt, đọc trạng thái của bộ gõ; danh sách mode [Apple] | `setValue` có | — | — |
| `menu()`, `doCommand(by:command:)`, `showPreferences(_:)` | Menu của bộ gõ và hành động của nó [Apple] | `menu` có | — | — |
| `IMKMouseHandling` (`mouseDown(onCharacterIndex:…)`…) | Chuột tại một chỉ số ký tự trong chữ của client [Apple] | không | — | — |
| `candidates(_:)`, `hidePalettes()`, các hàm của cửa sổ ứng viên | Cửa sổ chọn chữ [Apple] | không | — | — |

### 2.2 Phía bộ gõ: `IMKServer`

| API | Apple nói gì | Dấu | Giúp gì |
|---|---|---|---|
| `init(name:bundleIdentifier:)` | Đọc lớp controller từ Info.plist, đăng ký kết nối theo tên; mỗi phiên của client một controller, controller chỉ nhận lời gọi của một phiên [Apple] | có | — |
| `lastKeyEventWasDeadKey()` | Phím vừa rồi có phải phím chết không [Apple] | không | — |
| `paletteWillTerminate()` | Chỉ cho bộ gõ dạng bảng [Apple] | không | — |

Header không nói gì về việc app nối lại vào tiến trình bộ gõ mới sau khi tiến trình cũ thoát, hay có gọi lại `activateServer` không. Kết nối qua endpoint XPC: [`docs/research/IMKAPINotes.md`](IMKAPINotes.md) mục "Kết nối của IMKServer và sandbox".

### 2.3 Lời gọi vào client: `IMKTextInput`

Header ghi cho cả nhóm: `selectedRange`, `attributedSubstring(from:)` và `length` cần client hỗ trợ TSMDocumentAccess, nên bộ gõ phải chịu được nil và `NSNotFound` [Apple].

| API | Apple nói gì | Dấu | WebKit (Safari) | Chromium | Giúp gì |
|---|---|---|---|---|---|
| `insertText(_:replacementRange:)` | Gửi chữ đã chốt; vùng thay tính từ đầu tài liệu, `NSNotFound` là tại vùng chọn [Apple] | có | Tới trang ngay, không qua hàng phím (`WebViewImpl::insertText` → `WebPage::insertTextAsync`). Chuỗi rỗng khi có vùng chọn thì xoá lùi một ký tự [WebKit]. Safari 27.2 lại bỏ qua chuỗi rỗng (đã đo, mục 4.2) | Có vùng thay: gửi trang ngay. Không vùng thay, trong lúc xử lý phím: gom lại, gửi sau `interpretKeyEvents` (`insertText:replacementRange:`) [Chromium] | Safari, mục 4.1 |
| `setMarkedText(_:selectionRange:replacementRange:)` | Chuỗi trơn có gạch chân mặc định; vùng thay dùng được khi client hỗ trợ TSMDocumentAccess [Apple] | có (gạch chân) | Có vùng thay: chọn vùng rồi soạn; chuỗi rỗng xoá vùng chọn (`WebPage::setCompositionAsync`, `Editor::setComposition`) [WebKit] | Vùng thay chuyển cho trang; chuỗi rỗng là huỷ phiên soạn [Chromium] | ⌫ Safari, mục 4.2; mục 3 |
| `selectedRange()` | Vùng chọn, tính từ đầu tài liệu [Apple] | có | Hỏi trang ngay, trang trả vị trí của chính nó (`getSelectedRangeAsync`) [WebKit] | Trả bản sao trong view, không hỏi trang (`selectedRange`) [Chromium] | — |
| `markedRange()` | Vùng chữ đánh dấu trong tài liệu, không có thì `NSNotFound` [Apple] | không | Hỏi trang [WebKit] | Trả bản sao [Chromium] | — |
| `attributedSubstring(from:)` | Chữ kèm thuộc tính; có thể dài hay ngắn hơn vùng xin [Apple] | có | Hỏi trang ngay [WebKit] | Cắt từ bản sao chữ quanh vùng chọn, ngoài đó nil [Chromium] | — |
| `string(from:actualRange:)` | Như trên nhưng trả cả vùng thật của chuỗi trả về [Apple] | không | trả `actualRange` của trang | `actualRange` là phần giao giữa vùng xin và bản sao, tức lộ ra chỗ bắt đầu của bản sao (`attributedSubstringForProposedRange:actualRange:`) [Chromium] | chẩn đoán Cursor và Google Docs, mục 4.3, 4.6 |
| `length()` | Độ dài tài liệu; có thể rất tốn, tránh gọi thường xuyên [Apple] | không | — | `NSTextInputClient` của Chromium không có lời gọi tương ứng; IMK trả gì thì chưa rõ | — |
| `firstRect(forCharacterRange:actualRange:)` | Khung chữ đầu tiên của vùng, toạ độ màn hình [Apple] | không | Hỏi trang [WebKit] | Hỏi renderer **đồng bộ** (`SyncGetFirstRectForRange`), không dùng bản sao [Chromium] | — (mục 4.3) |
| `characterIndex(for:tracking:inMarkedRange:)` | Điểm trên màn hình ra chỉ số ký tự [Apple] | không | Hỏi trang [WebKit] | Hỏi renderer đồng bộ (`SyncGetCharacterIndexAtPoint`) [Chromium] | — |
| `attributes(forCharacterIndex:lineHeightRectangle:)` | Phông, hướng chữ, khung dòng; để đặt cửa sổ ứng viên [Apple] | không | — | — | — |
| `validAttributesForMarkedText()` | Thuộc tính client nhận cho chữ đánh dấu; bộ gõ nên chỉ dùng các thuộc tính này [Apple] | không | gạch chân, màu gạch chân, đoạn soạn, phương án chữ, hoàn tác chèn, **màu nền, màu chữ** (`validAttributesForMarkedTextSingleton`) [WebKit] | gạch chân, màu gạch chân, đoạn soạn, vùng thay (`validAttributesForMarkedText`) [Chromium] | mục 3 |
| `bundleIdentifier()` | Bundle ID của tiến trình chứa phiên nhập [Apple] | có, ở `activateServer` | — | Chrome đôi khi trả nil ([`docs/Architecture.md`](../Architecture.md) mục "Input mode, quy tắc theo app, cài đặt") | mục 4.5 |
| `uniqueClientIdentifierString()` | Header: bọc quanh `globallyUniqueString` của `NSProcessInfo` [Apple] | không | — | — | — (không phân biệt được ô nhập) |
| `supportsProperty(_:)` | Hỏi phiên có hỗ trợ một thuộc tính TSM không [Apple]. SDK 27.2 không còn khai các hằng thuộc tính tài liệu TSM (grep header HIToolbox chỉ thấy hai hằng nguồn đầu vào) | không | — | — | — |
| `overrideKeyboard(withKeyboardNamed:)`, `selectInputMode(_:)`, `supportsUnicode()`, `windowLevel()` | Bố cục bàn phím, đổi mode, Unicode, mức cửa sổ [Apple] | không | — | — | — |

### 2.4 Phía app: `NSTextInputClient`, `NSTextInputContext`

Các lời gọi của 2.3 tới app thành lời gọi `NSTextInputClient` cùng tên. Điều Apple ghi mà 2.3 chưa có:

- `setMarkedText(_:selectedRange:replacementRange:)`: chuỗi trơn thì app phải vẽ chữ đánh dấu cho khác đi (`NSTextView` dùng `markedTextAttributes`) [Apple]. Header không nói app làm gì với chuỗi có thuộc tính; WebKit và Chromium dùng thuộc tính gạch chân của chuỗi (mục 3).
- `attributedSubstring(forProposedRange:actualRange:)`: có thể trả nil; vùng thật có thể bị chỉnh "theo ranh giới cụm chữ, tối ưu hiệu năng…" [Apple].
- `doCommand(by:)`: app chạy lệnh của phím (`deleteBackward:`…). Bộ gõ không gọi được lời này qua `IMKTextInput`.
- `attributedString()` (tuỳ chọn): toàn bộ chữ của tài liệu, nếu app làm được rẻ [Apple]. `IMKTextInput` không có lời gọi tương ứng.
- `NSTextInputContext.discardMarkedText()`: app báo hệ thống bỏ phiên soạn [Apple]. WebKit gọi nó khi không cho bộ gõ vùng soạn tại chỗ (ô mật khẩu) [WebKit]. Nó tới bộ gõ thành `commitComposition` hay lời gọi khác: [Suy luận], header không nói.
- `NSTextInputContext.invalidateCharacterCoordinates()`, `textInputClientDidUpdateSelection()` (macOS 15.4): app báo vị trí, vùng chọn hay chữ đã đổi [Apple]. IMK công khai không có lời gọi nào báo các tin này cho bộ gõ; theo header, `textInputClientDidUpdateSelection` dành cho Writing Tools.
- `NSTextInputContext.activate()`/`deactivate()`: ngữ cảnh nhập được kích hoạt [Apple]. Chúng ứng với `activateServer`/`deactivateServer` của bộ gõ: [Suy luận].

## 3. Chữ đánh dấu không gạch chân

Câu hỏi: có thể gửi chữ đánh dấu mà app không vẽ gạch chân không, và nếu được thì có thay được thay tại chỗ ở các app sai không.

### 3.1 IMK trả thuộc tính gì

[Đo offline] 18/11/2026: tạo `IMKInputController(server: nil, delegate: nil, client: nil)` trong một chương trình dòng lệnh (không cửa sổ, không nối với app nào), in `mark(forStyle:at:)` cho kiểu 1–9 và hai giá trị mặc định:

- Kiểu 3, 4, 5: đoạn soạn (`NSMarkedClauseSegment`) bằng số kiểu, kèm thuộc tính gạch chân (giá trị 3, 1, 2) và màu gạch chân (xám đậm, đen).
- Kiểu 1, 2, 6, 7, 8, 9 (kể cả `kTSMHiliteNoHilite` = 9, "đoạn chữ không tô"): chỉ có đoạn soạn, **không có thuộc tính gạch chân**.
- `selectionRange()` mặc định (0, 0); `replacementRange()` mặc định (`NSNotFound`, `NSNotFound`).

Vậy IMK tạo được chuỗi chữ đánh dấu không mang gạch chân. Cái app vẽ ra thì do app quyết định.

### 3.2 App vẽ gì

| Chuỗi gửi cho `setMarkedText` | WebKit (Safari) [WebKit] | Chromium [Chromium] |
|---|---|---|
| Chuỗi trơn (Dấu hiện nay) | gạch chân mảnh màu chữ | gạch chân mảnh đen |
| Có thuộc tính gạch chân, mọi giá trị (kể cả 0) | gạch chân; bỏ đoạn có màu gạch chân trong suốt | gạch chân mảnh hoặc dày; màu gạch chân trong suốt thì vẽ bằng màu chữ (`StyleableMarker::UseTextColor`), nên vẫn thấy |
| Không có thuộc tính gạch chân, không màu nền, không màu chữ (ví dụ chỉ có đoạn soạn, như kiểu 9 ở 3.1) | không gạch chân, nhưng **tô nền vàng nhạt** mặc định cho cả vùng soạn (`TextBoxPainter::paintBackgroundFill`, `CompositionHighlight::defaultCompositionFillColor`) | Blink thêm gạch chân mảnh và màu nền mặc định (`InputMethodController`, nhánh không có đoạn nào) |
| Chỉ có màu chữ (ví dụ màu chữ thường của hệ thống) | đi đường "tô sáng": không gạch chân, không tô nền, chữ vẽ bằng màu đã cho (`shouldUseHighlightsForMarkedText`, `compositionHighlights`) | màu chữ không nằm trong `validAttributesForMarkedText`; chuỗi không có đoạn gạch chân nên như dòng trên |

- AppKit (`NSTextView`): header chỉ nói chuỗi trơn dùng `markedTextAttributes`. Chuỗi có thuộc tính thì vẽ theo thuộc tính đó, nên không gạch chân: [Suy luận], chưa đo.
- Trang tự vẽ (Google Docs) vẽ theo cách của nó ([`docs/research/WebEditorInput.md`](WebEditorInput.md) mục 8).

### 3.3 Kết luận

- Không có cách nào giấu gạch chân ở Chromium (Chrome, Edge, VS Code, Cursor, mọi app Electron). Khớp với điều [`docs/research/WebEditorInput.md`](WebEditorInput.md) mục 8 đã ghi; mục này thêm hai chi tiết: màu gạch chân trong suốt cũng không giấu được, và màu chữ không được nhận.
- Ở WebKit giấu được, bằng chuỗi chỉ mang màu chữ. Đọc mã, chưa đo.
- Chữ không gạch chân vẫn là chữ đánh dấu: trang nhận sự kiện soạn chữ (`compositionstart`, `compositionupdate`…), D20 (Thêm dấu cho từ đã gõ) không chạy, Return ngay sau từ đang soạn bị nuốt ở Ghostty (D43 (Ô bỏ qua vùng thay chữ)). Đổi màu không đổi các điều đó.
- **Đối chiếu:** dùng chữ đánh dấu (có hay không gạch chân) làm cách gõ mặc định ở app nào là đổi D13 (Gạch chân là đường lui cuối cùng: thay tại chỗ là cách gõ; gạch chân chỉ do người dùng bật) và D5 (Quy tắc theo ứng dụng). Hướng này không được đề xuất.

## 4. Từng việc mở

### 4.1 Safari thay sai khi trang chưa nhận kịp phím

Nguyên nhân và bản thử sửa (chưa gộp vào `main`, giữ ở tag cục bộ `archive/safari-webkit-key-queue`, chưa push): `docs/research/LateAnswerFixes.md` mục 5 và `docs/Compatibility.md` mục 5.1 trong tag đó (Safari giữ phím bộ gõ để đi thẳng trong hàng của WebKit; lời gọi của bộ gõ tới trang ngay; bản thử: ở Safari, Dấu tự chèn ký tự lẽ ra đi thẳng).

**API nào có thể giúp:**

- Không API nào của `IMKTextInput` cho bộ gõ biết còn bao nhiêu phím đang chờ, hay xin app áp hết trước khi trả lời [Apple].
- Mọi lời gọi của bộ gõ (`insertText`, `setMarkedText`, `selectedRange`, đọc chữ) đi cùng một đường tới trang theo đúng thứ tự gọi (`WebViewImpl::insertText`, `selectedRangeWithCompletionHandler`, `attributedSubstringForProposedRange` → `WebPageProxy` → trang) [WebKit]. Nên cách duy nhất giữ thứ tự là để mọi thao tác chữ do bộ gõ gửi. Đó chính là hướng bộ gõ tự chèn: không có API nào rẻ hơn thay được nó.
- Trả "đã xử lý" cho phím mà không gửi chữ không giúp: chữ của phím đó mất.

**Điều có thể đổi trong Safari sau này** [WebKit, lịch sử commit]:

- Cờ `InputMethodUsesCorrectKeyEventOrder` gom `insertText`/`setMarkedText` của bộ gõ trong lúc xử lý một phím vào hàng cùng phím đó, gửi trang kèm phím, giữ đúng thứ tự (`WebViewImpl::interpretKeyEvent`, `insertText`, `setMarkedText`). Khi cờ bật:
  - `selectedRange` và đọc chữ trong lúc xử lý phím trả vị trí và chữ **đã cộng** các `insertText` đang gom, kể cả `insertText` có vùng thay (`selectedRangeWithCompletionHandler`, `attributedSubstringForProposedRange`).
  - Phím mà bộ gõ chỉ gửi `insertText` (không chữ đánh dấu) được chuyển thành phím thường cho trang: `keydown` mang mã phím thật và có `keypress`.
- Cờ được bật mặc định ngày 08/04/2026 (310826@main), gây nhiều lỗi với bộ gõ (có Telex đơn giản của Apple và tiếng Hàn trong Mail), rồi bị tắt ngày 15/06/2026 (315228@main, "gây quá nhiều lỗi"). Nhánh main hiện để `status: unstable`, mặc định tắt. Hàng phím mà Dấu đã đo ở Safari 27.2 khớp với cờ tắt.
- Nếu Safari bật lại cờ này, cách Dấu tự chèn vẫn đúng thứ tự (mọi thao tác vẫn là lời gọi của bộ gõ, đi cùng một hàng) [Suy luận]. Điều phải kiểm lại khi đó: `selectedRange` trong lúc xử lý phím trả vị trí đã cộng chữ vừa gửi, khác Safari hiện nay.

**Đo:** không cần đo thêm bây giờ. Mỗi bản Safari lớn, chạy lại các ô Safari đã có (ma trận ở `docs/Compatibility.md`).

### 4.2 ⌫ ở Safari và Chromium

**Chromium** ([`docs/history/CompatibilityFixed.md`](../history/CompatibilityFixed.md), mục Backspace): app gửi phím gốc cho trang sau lời gọi của bộ gõ, trừ khi có chữ đánh dấu hay chữ chờ chèn dài hơn một ký tự (`keyEvent:`) [Chromium]. Không API nào của IMK đổi được điều này:

- Nhận ⌫ qua `didCommand(by:client:)` (`deleteBackward:`) thay vì `handle` không đổi gì phía Chromium: Chromium không xét bộ gõ nhận phím bằng cách nào.
- Mẹo duy nhất theo mã là làm cho phím đó có chữ đánh dấu, tức thêm một `setMarkedText` trong cùng phím: trái N3 (Ít lời gọi vào ứng dụng đích, mỗi phím tối đa một `insertText`), và vẫn là chữ đánh dấu. Không đề xuất.
- Cách hiện tại (D32 (Backspace): thay kèm lại chữ cuối, để lệnh xoá của app bỏ nó) là cách đúng với mã Chromium; giữ nguyên.

**Safari** (bản thử chưa gộp, giữ ở tag cục bộ `archive/safari-webkit-key-queue`, chưa push; D32 trên `main` chưa có ý "Safari"): Dấu tự xoá. Safari 27.2 bỏ qua `insertText` với chuỗi rỗng (đã đo), nên Dấu thay hai ký tự bằng ký tự đầu.

- Theo mã main, `insertText` rỗng có vùng thay lẽ ra xoá được: trang chọn vùng thay rồi xoá lùi khi chuỗi rỗng và vùng chọn khác rỗng (`WebPage::insertTextAsync`) [WebKit]. Vậy chuỗi rỗng bị bỏ ở chỗ khác: ở phía IMK trong tiến trình app, ở AppKit, hoặc Safari 27.2 khác main. Chưa rõ [Suy luận].
- `setMarkedText("", selectionRange: (0, 0), replacementRange: vùng cần xoá)`: trang chọn vùng thay, rồi `Editor::setComposition` với chuỗi rỗng xoá vùng chọn (`WebPage::setCompositionAsync`, `Editor::setComposition`) [WebKit]. Chuỗi rỗng qua `setMarkedText` tới được app (chế độ gạch chân của Dấu dùng nó để xoá chữ đánh dấu). Hệ quả phụ theo mã: trang nhận một sự kiện `compositionend` không có `compositionstart` đi trước [WebKit].
- **Đo rẻ nhất:** một ô Safari, chuỗi `không⌫g` và `Hoc ⌫j` với ⌫ xoá bằng `setMarkedText` rỗng có vùng thay, trên bản Debug. Chỉ đáng làm nếu mẹo hiện tại gặp vấn đề, vì nó đã đo đúng.
- **Đối chiếu:** vẫn một lời gọi mỗi phím (N3). Đổi cách xoá trong ý "Safari" của D32 ở bản thử.

### 4.3 Google Docs luôn trả vị trí (1, 0)

Các đường đã xét và đã đo: [`docs/research/WebEditorInput.md`](WebEditorInput.md) mục 10.5, 10.6 (vùng thay lớn hơn cửa sổ bị kẹp; không đọc được thêm chữ; sửa nhiều bước sau khi xử lý phím làm hỏng ô nhập; Safari cũng (1, 0); chữ đánh dấu có vùng thay cũng bị kẹp trong chữ của trang). Mục này chỉ thêm điều mới:

- **WebKit có đường riêng cho docs.google.com** [WebKit]: bảng quirk (`QuirkTable.json`) gắn cho `*://docs.google.com/*` hai hành vi, `InputMethodMustUseCompositionEvents` và `InputMethodUsesCorrectKeyEventOrder`.
  - Cái thứ nhất được trả cho bộ gõ qua lời gọi bất đồng bộ `isMarkedTextRequiredForComposition` (`WebViewImpl::isMarkedTextRequiredForCompositionWithCompletionHandler`, `WKWebViewMac.mm`): trang báo "phải dùng chữ đánh dấu". Lời gọi này thuộc giao thức bất đồng bộ riêng của AppKit, **không có trong `IMKTextInput`** [Apple, header], nên bộ gõ bên thứ ba không hỏi được. Commit 315032@main nói tới "AppKit SPI để tắt nhập không chế độ" (modeless input), tức đường riêng của Apple.
  - Cái thứ hai đang tắt cứng (`Quirks::inputMethodUsesCorrectKeyEventOrder` trả không).
  - Hệ quả: bộ gõ của Apple có đường để biết Google Docs cần chữ đánh dấu; Dấu thì không. Khớp với số đo Telex của Apple gõ đúng ở Google Docs (mục 5).
- **Tín hiệu công khai để nhận ra cửa sổ một ký tự** [Suy luận]: `string(from:actualRange:)` ở Chromium trả vùng thật là phần giao với bản sao chữ, nên lộ ra bản sao chỉ dài một ký tự; `length()` có thể nhỏ bất thường. Đây chỉ là cách nhận ra, không phải cách sửa: điều Dấu làm được sau khi nhận ra là chuyển sang chữ đánh dấu, tức tự bật gạch chân, **trái D13 và D5**.
- **Hình học** (`firstRect`, `characterIndex`): Chromium hỏi renderer đồng bộ, nhưng chỉ cho khung và chỉ số trong chữ EditContext của trang, không cho chữ (đã ghi ở [`docs/research/WebEditorInput.md`](WebEditorInput.md) mục 10.2). Không giúp thay quá một ký tự.
- **Đo:** không đề xuất phép đo mới cho việc sửa. Nếu người dùng muốn xét lại D13 cho Google Docs, phép đo rẻ nhất là bản Debug ghi `actualRange` và `length()` ở một lần gõ Google Docs (Chrome, Safari), để biết tín hiệu nhận ra có ổn định không.

### 4.4 WebStorm reset sau mỗi phím đi thẳng

Chẩn đoán và giả thuyết: [`docs/research/JetBrainsInput.md`](JetBrainsInput.md) mục 4.2 (giả thuyết khớp mọi quan sát: lời báo bỏ chữ đang soạn mà JBR gửi sau mỗi `insertText` tới Dấu thành `commitComposition`, chỉ khi Dấu không đang xử lý phím).

**API nào có thể giúp:**

- IMK không cho bộ gõ biết vì sao `commitComposition` tới (bấm chuột, đổi ô, hay lời báo của JBR) [Apple]. `markedRange()` không phân biệt được: ở chế độ thay tại chỗ không bao giờ có chữ đánh dấu.
- Hướng khả dĩ [Suy luận]: ở chế độ thay tại chỗ, coi `commitComposition` là gợi ý, không reset. Lý do:
  - Header định nghĩa `commitComposition` là kết thúc **phiên soạn chữ đánh dấu**; ở chế độ thay tại chỗ không có phiên đó.
  - Bấm chuột tới Dấu qua `handle` (Dấu nhận chuột, `recognizedEvents`), đổi app tới qua `deactivateServer`, đổi client qua `noteClient`.
  - Con trỏ đi chỗ khác mà không có tín hiệu nào thì D11 (Kiểm tra ngữ cảnh) bắt ở phím thay chữ kế tiếp (lệch thì đọc lại hoặc reset); khôi phục D4 ở cuối từ cũng là một lần thay, nên cũng qua phép kiểm đó.
  - Rủi ro: app chỉ báo đổi ô bằng `commitComposition` (không có `deactivateServer`, không đổi client). Khi đó phím đi thẳng ở ô mới được ghi vào từ cũ trong engine, cho tới phím thay chữ đầu tiên. Chưa biết app nào như vậy; [`docs/research/TerminalAndUnderline.md`](TerminalAndUnderline.md) ghi rằng đổi giữa hai phần tử soạn thảo trong VS Code không đổi client và không gọi `activateServer`, nhưng không ghi có `commitComposition` hay không.
  - Chế độ gạch chân vẫn phải chốt chữ khi nhận `commitComposition`.
- **Đo, theo thứ tự:**
  1. Phép đo đã lên kế hoạch: ghi `commitComposition` và `deactivateServer` vào log Debug, chạy lại ô `webstorm` một lượt. Có kết quả mới chọn hướng.
  2. Nếu đúng là `commitComposition`: test với client giả (offline) cho hướng gợi ý, gồm ca "đổi ô chỉ báo bằng `commitComposition`" (phím đi thẳng ở ô mới rồi phím dấu, rồi kết thúc từ), so với cách hiện tại.
  3. Một lượt app thật gộp: WebStorm (chuỗi đã đo ở JetBrainsInput mục 4), cộng VS Code chuyển giữa trình soạn thảo và terminal, Safari, Chrome, để kiểm không hỏng app khác.
- **Đối chiếu:** không trái quyết định nào trong `Decisions.md`; D4 chỉ yêu cầu reset khi đổi ô hay app, và D11 vẫn chặn thay sai chỗ. Đổi danh sách sự kiện reset ở [`docs/Architecture.md`](../Architecture.md) mục "Điều khiển và hai chế độ ghi chữ".

### 4.5 App không gửi `activateServer` sau khi cài lại bộ gõ

Hiện tượng: [`docs/Progress.md`](../Progress.md), Việc mở về cài lại bộ gõ (17/11/2026, 2/2 lần, Safari và Chrome: phím vẫn tới, log ghi `app=?`).

**Cơ chế trong mã Dấu** (đọc `DauInputController`):

- `clientApp`, quy tắc gạch chân theo app, bộ nghe cài đặt, nguồn đầu vào và yêu cầu thoát chỉ được đặt trong `activate`, tức chỉ sau `activateServer`.
- Cài đặt (kiểu gõ, D20) vẫn đúng: đọc khi tạo controller.
- Controller chưa được kích hoạt nên: không biết app (`app=?`), không áp quy tắc gạch chân (D5), không nghe đổi cài đặt (đổi kiểu gõ trong app chủ không tới controller này), không nghe yêu cầu thoát.

**API nào có thể giúp:**

- Phím vẫn tới `handle(_:client:)` kèm client, và `client()` trả client của controller [Apple]. `bundleIdentifier()` đọc được từ client đó bất cứ lúc nào.
- Hướng [Suy luận]: ở phím đầu tiên của một controller chưa từng nhận `activateServer`, chạy phần việc của `activate` một lần (đọc bundle ID, đăng ký bộ nghe, áp quy tắc theo app), rồi xử lý phím. Có thể gộp vào chỗ `noteClient` đã nhận ra client mới.
- Ghi đè `init(server:delegate:client:)` để đọc bundle ID ngay khi IMK tạo controller cũng được, nhưng header không bảo đảm client đã sẵn sàng trả lời lúc đó [Suy luận]; phím đầu tiên là chỗ chắc hơn.
- **Đo, theo thứ tự:**
  1. Offline: tách phần "kích hoạt khi cần" thành hàm thuần, test với client giả: phím đến khi chưa có `activateServer` thì quy tắc gạch chân của app được áp từ phím đó; `activateServer` đến sau thì không chạy lại hai lần.
  2. App thật: cài lại bộ gõ (`scripts/dev/install-app.sh`), gõ ngay một từ ở Safari và Chrome đang mở, đọc log (`app=` khác `?`). Gộp vào lượt có cài bộ gõ sẵn (bước 3 của kế hoạch M7 đã có ô đo việc này khi Sparkle cập nhật).
- **Đối chiếu:** thêm một lời gọi `bundleIdentifier()` mỗi controller, không theo phím. N3 giới hạn lời gọi khi gõ (`insertText`, `selectedRange`, đọc chữ); lời gọi này một lần mỗi phiên như ở `activateServer` hiện nay. Không trái quyết định nào; đổi [`docs/Architecture.md`](../Architecture.md) mục "Input mode, quy tắc theo app, cài đặt" ("Bundle ID lấy từ client lúc `activateServer`").

### 4.6 Cursor trả vị trí theo từ

Hiện tượng: trình soạn thảo Cursor 3.30.14 có lúc tính vị trí từ đầu văn bản, có lúc từ đầu từ ([`docs/research/LateAnswerFixes.md`](LateAnswerFixes.md) mục 2; số đo ở `docs/Compatibility.md` mục 5.4).

**Mã VS Code giải thích được** [VS Code; Cursor là bản tách từ VS Code, chưa đối chiếu mã của Cursor]. VS Code có hai cách nhận chữ từ bộ gõ, chọn bằng cài đặt `editor.editContext`:

- **EditContext** (`NativeEditContext._getNewEditContextState`): chữ đưa cho trình duyệt là các dòng có vùng chọn, từ cột 1. Vị trí tính từ đầu dòng. Ở tài liệu một dòng (như ô đo), đầu dòng là đầu văn bản.
- **Ô `textarea` ẩn** (`TextAreaEditContext`, hàm `getScreenReaderContent`):
  - Khi trình soạn thảo coi là không có trình đọc màn hình (`AccessibilitySupport.Disabled`), trên macOS, không có vùng chọn: ô chỉ chứa **từ ngay trước con trỏ** (`_getWordBeforePosition`); không có từ thì một ký tự trước con trỏ. Chú thích trong mã: để giữ phím chọn dấu và gợi ý của Bàn phím trợ năng.
  - Còn lại (chưa biết hoặc có trình đọc màn hình): một trang chữ quanh con trỏ (`SimplePagedScreenReaderStrategy`).
- Chromium trả `selectedRange` và chữ từ bản sao của chính phần tử đó (mục 2.3), nên ở cách thứ hai, khi coi là không có trình đọc màn hình, vị trí tính từ đầu từ. Khớp cả hai quan sát của Dấu: vị trí về 0 sau mỗi dấu cách, và lần đọc chỉ thấy phần cuối ("co" ở chỗ đã gõ "ừ co", [`docs/Architecture.md`](../Architecture.md) mục "App trả lời chậm").
- Trạng thái trình đọc màn hình với cài đặt `editor.accessibilitySupport` "auto" đổi theo việc hệ thống báo có công cụ trợ năng đang dùng hay không. Script gõ thử dùng System Events, một client Accessibility, nên có thể làm đổi trạng thái này giữa các lượt [Suy luận]. Chưa rõ vì sao buổi sáng và buổi chiều khác nhau.

**API IMK nào giúp:** không có lời gọi nào cho bộ gõ biết gốc toạ độ của app. `string(from:actualRange:)` cho thấy chỗ bắt đầu của bản sao (mục 2.3) nhưng bản sao ở đây bắt đầu đúng ở đầu từ, nên không phân biệt được với một tài liệu chỉ có một từ. Sửa trong Dấu vẫn là các hướng ở `LateAnswerFixes.md` mục 2.2 (đổi N3 và D11).

**Đo rẻ nhất:**

1. Đọc cài đặt của Cursor (`editor.editContext`, `editor.accessibilitySupport`) trên máy đo. Không cần chạy gì.
2. Một lượt app thật, ô `edit` 5 ms ở trình soạn thảo Cursor, hai cấu hình: `editor.accessibilitySupport` "off" và "on" (cùng `editor.editContext` như đang dùng). Dự đoán theo mã: nếu Cursor dùng ô `textarea`, "off" cho vị trí theo từ (sai như đã đo), "on" cho vị trí theo trang (đúng). Nếu Cursor dùng EditContext, cả hai cấu hình như nhau, và giả thuyết sai.
3. Nếu dự đoán đúng: đó là một chế độ của app. Đổi cài đặt của Cursor là việc của người dùng (N4 (Không tự đổi cài đặt hệ thống) chỉ nói cài đặt hệ thống, nhưng Dấu cũng không đổi cài đặt của app khác); hướng dẫn hay sửa trong Dấu là quyết định của người dùng.

## 5. Điều mới so với tài liệu khác

- **Telex của Apple có chế độ thay tại chỗ.** Commit 313286@main của WebKit (14/05/2026) viết rằng Telex đơn giản của Apple và bàn phím tiếng Hàn 2-Set là bộ gõ "không chế độ" (modeless): gõ bằng `insertText` có vùng thay (ví dụ thay "v" bằng "vi"), trong lúc xử lý phím hỏi `selectedRange` để kiểm chữ đã vào chưa, và nếu thấy chưa thì chuyển sang chữ đánh dấu tới hết phiên. Commit 315032@main nói AppKit có đường riêng để tắt chế độ này (dùng cho Google Docs).
  - Khác với [`docs/research/WebEditorInput.md`](WebEditorInput.md) mục 6 và bảng tóm tắt ở đó ("Telex của Apple: chữ đánh dấu", theo lời tác giả bộ gõ khác, Dấu chưa đo).
  - Commit nói về Telex **đơn giản**, gọi theo tên (ID nguồn có lẽ là `…VietnameseSimpleTelex`, suy luận). Bộ gõ đối chứng của Dấu là `…VietnameseTelex`; nó có cùng cơ chế không thì chưa rõ.
  - Liên quan D13: cách của Apple là thay tại chỗ, tự lùi về chữ đánh dấu khi app không áp đúng, tức tự bật gạch chân. D13 chọn để người dùng tự bật. Đây là dữ kiện cho người dùng nếu muốn xét lại, không phải đề xuất.

## Nguồn

Apple:

- Header SDK `MacOSX27.2.sdk` (Xcode 27.2, build 27B52): `InputMethodKit.framework/Headers/IMKInputController.h`, `IMKServer.h`; `Carbon.framework/Frameworks/HIToolbox.framework/Headers/IMKInputSession.h`; `AppKit.framework/Headers/NSTextInputClient.h`, `NSTextInputContext.h`, `NSAttributedString.h`; `CoreServices.framework/Frameworks/AE.framework/Headers/AERegistry.h`.
- IMKInputController: https://developer.apple.com/documentation/inputmethodkit/imkinputcontroller
- mark(forStyle:at:): https://developer.apple.com/documentation/inputmethodkit/imkinputcontroller/mark(forstyle:at:)
- updateComposition(): https://developer.apple.com/documentation/inputmethodkit/imkinputcontroller/updatecomposition()
- cancelComposition(): https://developer.apple.com/documentation/inputmethodkit/imkinputcontroller/cancelcomposition()
- init(server:delegate:client:): https://developer.apple.com/documentation/inputmethodkit/imkinputcontroller/init(server:delegate:client:)
- client(): https://developer.apple.com/documentation/inputmethodkit/imkinputcontroller/client()
- IMKServerInput: https://developer.apple.com/documentation/inputmethodkit/imkserverinput
- commitComposition(_:): https://developer.apple.com/documentation/objectivec/nsobject-swift.class/commitcomposition(_:)
- didCommand(by:client:): https://developer.apple.com/documentation/objectivec/nsobject-swift.class/didcommand(by:client:)
- composedString(_:): https://developer.apple.com/documentation/objectivec/nsobject-swift.class/composedstring(_:)
- IMKStateSetting: https://developer.apple.com/documentation/inputmethodkit/imkstatesetting
- IMKServer: https://developer.apple.com/documentation/inputmethodkit/imkserver
- NSTextInputClient: https://developer.apple.com/documentation/appkit/nstextinputclient
- NSTextInputContext.discardMarkedText(): https://developer.apple.com/documentation/appkit/nstextinputcontext/discardmarkedtext()
- NSTextInputContext.invalidateCharacterCoordinates(): https://developer.apple.com/documentation/appkit/nstextinputcontext/invalidatecharactercoordinates()

WebKit (nhánh main, đọc 18/11/2026):

- https://github.com/WebKit/WebKit/blob/main/Source/WebKit/UIProcess/mac/WebViewImpl.mm
- https://github.com/WebKit/WebKit/blob/main/Source/WebKit/WebProcess/WebPage/Cocoa/WebPageCocoa.mm
- https://github.com/WebKit/WebKit/blob/main/Source/WebKit/WebProcess/WebPage/mac/WebPageMac.mm
- https://github.com/WebKit/WebKit/blob/main/Source/WebKit/UIProcess/API/mac/WKWebViewMac.mm
- https://github.com/WebKit/WebKit/blob/main/Source/WebCore/editing/Editor.cpp
- https://github.com/WebKit/WebKit/blob/main/Source/WebCore/rendering/paint/TextBoxPainter.cpp
- https://github.com/WebKit/WebKit/blob/main/Source/WebCore/editing/CompositionHighlight.h
- https://github.com/WebKit/WebKit/blob/main/Source/WebCore/page/QuirkTable.json
- https://github.com/WebKit/WebKit/blob/main/Source/WebCore/page/Quirks.cpp
- https://github.com/WebKit/WebKit/blob/main/Source/WTF/Scripts/Preferences/UnifiedWebPreferences.yaml
- Bật cờ giữ thứ tự mặc định: https://commits.webkit.org/310826@main
- Telex đơn giản và tiếng Hàn trong Mail: https://commits.webkit.org/313286@main
- Telex đơn giản và tiếng Hàn trong Google Docs: https://commits.webkit.org/315032@main
- Tắt cờ giữ thứ tự: https://commits.webkit.org/315228@main

Chromium (nhánh main, đọc 18/11/2026):

- https://chromium.googlesource.com/chromium/src/+/main/content/app_shim_remote_cocoa/render_widget_host_view_cocoa.mm
- https://chromium.googlesource.com/chromium/src/+/main/third_party/blink/renderer/core/editing/ime/input_method_controller.cc
- https://chromium.googlesource.com/chromium/src/+/main/third_party/blink/renderer/core/editing/markers/styleable_marker.cc
- https://chromium.googlesource.com/chromium/src/+/main/third_party/blink/renderer/core/paint/styleable_marker_painter.cc

VS Code (nhánh main, đọc 18/11/2026):

- https://github.com/microsoft/vscode/blob/main/src/vs/editor/browser/controller/editContext/textArea/textAreaEditContext.ts
- https://github.com/microsoft/vscode/blob/main/src/vs/editor/browser/controller/editContext/native/nativeEditContext.ts

Đo offline (mục 3.1): chương trình Swift một file, tạo `IMKInputController(server: nil, delegate: nil, client: nil)`, in `mark(forStyle:at:)` với kiểu 1–9 và `selectionRange()`, `replacementRange()`; biên dịch bằng `xcrun swiftc`, chạy trong terminal. Mã không nằm trong repo; dựng lại theo mô tả này.
