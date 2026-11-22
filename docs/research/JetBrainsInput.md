# Gõ trong WebStorm (JetBrains Runtime): terminal và trình soạn thảo

Chữ của bộ gõ đi từ macOS tới terminal và trình soạn thảo của WebStorm theo đường nào, và Dấu (thay tại chỗ bằng `insertText(_:replacementRange:)`) ra chữ gì ở đó. Mục 1–3 tả cơ chế đọc từ mã nguồn. Mục 4 đặt dự đoán cạnh kết quả của lượt đo ngày 17/11/2026. Điều chưa đo được ghi rõ "chỉ từ mã nguồn".

Phiên bản đã đọc:

- WebStorm 2026.3, build WS-263.7307.202, trong `~/Applications`.
- JetBrains Runtime đi kèm: JBR-25.0.4.1+1-b635.79. File `release` của nó ghi commit nguồn `787be56cf077`, trùng tag `jb25.0.4.1-b635.79`.
- intellij-community nhánh `263.7307`, commit `26051d5` (16/11/2026). Không có tag riêng cho WebStorm 263.7307.202. Các file đọc ở đây không đổi từ tag `idea/263.7307.200` tới commit đó.
- JediTerm 3.76 (bản WebStorm khai báo cho terminal cổ điển), commit `1b354a6`.

Đường dẫn trong bài là tên lớp và hàm; liên kết cố định theo commit ở mục 7.

## Hiện trạng (đo 17/11/2026, soát lại 22/11/2026)

**Đổi từ 22/11/2026:** các số đo dưới đây là của bản Dấu trước khi Dấu tự chèn ký tự (N3): khi đó ký tự engine để nguyên đi thẳng tới app và AppKit tự chèn. Nay Dấu tự chèn mọi ký tự đó bằng `insertText`; chỉ ⌫, Return, Tab, Esc, mũi tên và phím có ⌘, ⌃, ⌥ còn đi thẳng. Giả thuyết H1' (mục 4.2) có thể bị ảnh hưởng, vì không còn chữ nào do AppKit chèn ngoài `handle`; chưa đo lại, WebStorm không có trên máy đo ngày 22/11/2026. Chữ "phím đi thẳng" trong file này, trừ chỗ nói khác, có nghĩa phím đó khi ấy do app xử lý.

Đã đo (một lượt mỗi ô, mục 4):

- **Trình soạn thảo, Dấu thay tại chỗ: chữ tiếng Việt đúng, nhưng mất khôi phục từ nước ngoài (D4 (Từ nước ngoài)).** Chuỗi `windows carr tooi yeeu tieengs Vieetj, Sunrise ` ra "ưindows car tôi yêu tiếng Việt, Sủnise".
- **Nguyên nhân gần của lỗi trên (từ log):** sau **mỗi phím Dấu để đi thẳng**, Dấu bị reset. Phím kế tiếp vì vậy đi đường đọc chữ của D20 (Thêm dấu cho từ đã gõ). D20 dựng lại được từ tiếng Việt từ chữ đang hiện, nên chữ tiếng Việt vẫn đúng. Nhưng mỗi lần dựng lại dời mốc khôi phục của D4 tới chữ đang hiện, nên phím gốc của từ nước ngoài bị mất. Sau phím Dấu tự gửi chữ thì không có reset. Mục 4.2.
- **Ai gây reset: chưa rõ.** Giả thuyết duy nhất giải thích mọi quan sát: lời gọi `markedTextAbandoned:` mà JBR làm ở cuối mỗi `insertText` tới được Dấu thành `commitComposition`. Điều kiện là chỉ khi Dấu không còn đang xử lý phím, tức với chữ AppKit tự chèn cho phím đi thẳng. Phần "tới được Dấu" và "chỉ khi không đang xử lý phím" chưa có nguồn. Mục 4.2.
- **Terminal (Reworked), Dấu thay tại chỗ:** ra "ưindows caảr toôi yeêu tieêngs Vieêtj, Sunủnise". Byte xuống pty là đúng chuỗi đó, không có DEL. Đây là ô bỏ qua vùng thay chữ như D43 (Ô bỏ qua vùng thay chữ), khớp cơ chế ở mục 2.2.
- **Gạch chân của Dấu đúng ở cả hai ô.** Telex của Apple ra chữ tiếng Việt đúng ở cả hai ô; Telex của Apple không khôi phục từ nước ngoài, nên cũng ra "ưindows", "Sủnise".
- **JBR làm vùng thay bằng hai bước: chọn vùng rồi gõ chữ mới** (mục 1.2). Lượt đo thấy đúng hai bước này trong trình soạn thảo. Log chẩn đoán hỏi `selectedRange` ngay sau `insertText`, trước khi JBR gửi chữ, và nhận về đúng vùng thay dưới dạng vùng chọn (`after` = `rep`). Chữ cuối cùng đúng chỗ (mục 4.1).
- **Return gõ khi Dấu đang bật tới được terminal:** sau ⌘V, phím Return của script (Dấu để đi, dòng `pass` trong log terminal) chạy được ô ghi byte. Vậy nhánh "giữ phím" của JBR không nuốt Return với Dấu (mục 1.5, 1.6).
- **Terminal đang dùng là Reworked, chạy trình giả lập Ghostty VT** (mục 2.1). Script đo đọc cùng kết luận từ cài đặt; trên màn hình chưa xem.

Chỉ từ mã nguồn, chưa đo:

- **Phím vừa thay chữ vừa để đi** (⌫ dời dấu theo D32 (Backspace), Return/Tab sau từ cần khôi phục): dự đoán sai trong trình soạn thảo. IDE chạy action Backspace/Enter trên vùng vừa chọn rồi bỏ chữ thay: `hoaf⌫` ra "h", từ cần khôi phục rồi Return thì từ biến mất. Chưa đo; mục 3.3, 5.
- **Terminal Classic (JediTerm)**, nếu người dùng chọn lại: `selectedRange` luôn là {0, 0}, không đọc được chữ, vùng thay bị bỏ qua. Cùng kiểu với Ghostty đã đo (D43). Mục 2.3.
- **Return ngay sau từ đang gạch chân không bị nuốt** (khác Ghostty), vì JBR xếp sự kiện Return sau sự kiện chốt chữ. Chuỗi đã đo không có Return; mục 2.2.

## 1. JBR: từ `NSTextInputClient` tới sự kiện Java

`AWTView` (Objective-C) là `NSView` của mọi cửa sổ Java và cài `NSTextInputClient`. Mỗi lời gọi của bộ gõ được chuyển qua JNI sang `sun.lwawt.macosx.CInputMethod` (Java). `CInputMethod` hỏi `InputMethodRequests` của component Java đang có focus, qua `sun.awt.im.InputMethodContext`.

### 1.1 Một phím đi qua `keyDown:` thế nào

- `AWTView.keyDown:` bật cờ "đang xử lý phím", rồi gọi `interpretKeyEvents:` để hệ thống đưa phím cho bộ gõ. Theo [`docs/Architecture.md`](../Architecture.md) mục "Backspace thay tại chỗ", AppKit áp lời gọi của bộ gõ trong lúc `handle` chạy, nên `selectedRange`, `insertText`… của Dấu tới ngay trong bước này.
- Sau đó, nếu không có marked text và cờ "cần sự kiện phím" đang bật, JBR tạo sự kiện phím Java (`deliverJavaKeyEventHelper` → `CPlatformResponder.handleKeyEvent`): một KEY_PRESSED mang mã phím thật, rồi một KEY_TYPED cho **mỗi ký tự** của chuỗi mà `insertText` vừa đưa (`actualCharacters`). Không có chuỗi nào thì KEY_TYPED mang ký tự gốc của phím.
- Có marked text sau `interpretKeyEvents` thì JBR không tạo sự kiện phím Java nào.
- `doCommandBySelector` với `insertNewline:`, `insertTab:`, `deleteBackward:` bật lại cờ "cần sự kiện phím". Phím bộ gõ để đi vẫn tới Java như phím thường.
- Mọi sự kiện Java vào cùng một hàng đợi (`EventQueue`, trong IntelliJ là `IdeEventQueue`) và được xử lý trên luồng sự kiện (EDT), theo thứ tự vào hàng.

Hệ quả, suy từ mã: nếu bộ gõ nuốt phím mà không gọi `insertText` hay `setMarkedText`, JBR vẫn gõ ký tự gốc của phím. Với Dấu, chỉ nhánh "Từ hệ thống vừa sửa" của D20 nuốt phím như vậy, và nhánh này chỉ chạy sau tự sửa chính tả của macOS, thứ ô Java không có. Nên trên thực tế không gặp.

### 1.2 `insertText(_:replacementRange:)`

Theo `AWTView.insertText:replacementRange:`:

1. Vùng thay có độ dài lớn hơn 0 thì gọi `CInputMethod.selectRange(vị trí, độ dài)`. Hàm này **không chọn ngay**: nó đặt một việc vào cuối hàng đợi EDT (`LWCToolkit.invokeLater`). Việc đó:
   - component là `JTextComponent` hoặc `TextComponent` của AWT: gọi `select(đầu, cuối)`;
   - component khác: chuyển cho bộ nghe chung `TextInput` của JBR (JBR-7133). Trong IntelliJ, bộ nghe này (`IdeEventQueue.addTextInputListener`) chỉ chọn chữ trong ô tìm nhanh của danh sách và cây (`SpeedSearchSupply`); component khác thì không có gì xảy ra.
2. Chọn đường gửi chữ: có marked text, hoặc lời gọi tới ngoài lúc xử lý phím, thì đi đường "bộ gõ phức tạp": `CInputMethod.insertText` tạo một `InputMethodEvent` với toàn bộ chuỗi là chữ đã chốt, và tắt việc tạo sự kiện phím cho phím này. Còn lại, tức không marked text và đang trong `keyDown:`, chuỗi được giữ làm `actualCharacters`, và `keyDown:` biến nó thành các KEY_TYPED (mục 1.1).
3. Cuối cùng gọi `abandonInput:`. Hàm này gửi `markedTextAbandoned:` tới `[NSInputManager currentInputManager]`, rồi chốt marked text còn lại phía Java (không còn gì sau bước 2).

Vậy vùng thay **được tôn trọng**, nhưng dưới dạng "đổi vùng chọn của component, rồi gõ chữ mới". Có hai điều kiện:

- Component phải biết chọn theo vị trí bộ gõ đưa, tức `select` của `JTextComponent`.
- Phần gõ chữ phải thay vùng chọn. Với KEY_TYPED, điều này tuỳ component xử lý phím có vùng chọn thế nào.

Thứ tự trên EDT với lời gọi của Dấu trong lúc xử lý phím: việc chọn vùng, rồi KEY_PRESSED của phím, rồi các KEY_TYPED của chữ thay. Việc chọn vào hàng trong `interpretKeyEvents`; sự kiện phím vào hàng sau khi `interpretKeyEvents` xong.

Lịch sử: JBR-7119 (5/2024) thêm bước chọn vùng, vì chọn chữ Hán thay chữ Hangul/Kana không thay mà thêm vào sau ([JBR-7119](https://youtrack.jetbrains.com/issue/JBR-7119)). JBR-7133 thêm bộ nghe `TextInput` cho component không phải `JTextComponent`, vì Fleet không dùng được bản sửa của JBR-7119 ([JBR-7133](https://youtrack.jetbrains.com/issue/JBR-7133)). Trước đó, JBR bỏ hẳn vùng thay. Đường "chuỗi một ký tự trong lúc xử lý phím" đến từ JDK-8195675, sửa lỗi bộ gõ tự viết đưa một ký tự mà bị bỏ qua.

Apple quy định vùng thay đo từ đầu kho chữ của view ([`insertText(_:replacementRange:)`](https://developer.apple.com/documentation/appkit/nstextinputclient/inserttext(_:replacementrange:))). JBR chuyển nguyên vị trí và độ dài sang `select`, nên ý nghĩa của chúng tuỳ `InputMethodRequests` của từng component (mục 2, 3).

### 1.3 `setMarkedText`

- Có vùng thay thì cũng hẹn chọn vùng như trên.
- `CInputMethod.startIMUpdate` lưu chuỗi đang soạn. Đây là thứ `hasMarkedText` dựa vào, và nó được đặt ngay trên luồng AppKit.
- `dispatchText` gửi một `InputMethodEvent` với toàn bộ chuỗi là chữ đang soạn (0 ký tự đã chốt).
- Chuỗi rỗng xoá marked text và tắt sự kiện phím cho phím đó.

### 1.4 Các câu hỏi của bộ gõ trả gì

Mọi câu hỏi chạy trên EDT bằng `LWCToolkit.invokeAndWait`. Việc hỏi được đặt vào **cuối** hàng đợi, luồng AppKit quay vòng chờ, nên câu trả lời đến sau khi EDT đã xử lý mọi sự kiện vào hàng trước nó, kể cả các phím trước. Hai trường hợp không có câu trả lời:

- EDT đang chờ ngược luồng AppKit (`isBlockingEventDispatchThread`): JBR bỏ câu hỏi.
- Không có component có focus hay `InputMethodContext`.

Khi đó, giá trị trả về là giá trị mặc định ghi ở cột cuối.

| Lời gọi | Phía Java | Trả gì | Không có câu trả lời |
|---|---|---|---|
| `selectedRange` | `CInputMethod.selectedRange`: `getSelectedText`; không có vùng chọn thì `getInsertPositionOffset` | Không vùng chọn: {vị trí chèn, 0}. Có vùng chọn: `JTextComponent` lấy đầu vùng từ `getSelectionStart`, component khác thì đoán từ vị trí chèn trừ độ dài | {0, 0}, **không phải** {NSNotFound, 0} như Apple quy định ([`selectedRange()`](https://developer.apple.com/documentation/appkit/nstextinputclient/selectedrange())) |
| `markedRange` | `CInputMethod.markedRange` | Không marked text: {NSNotFound, 0}. Có: {vị trí chèn, độ dài chuỗi đang soạn} | {NSNotFound, 0} |
| `attributedSubstringForProposedRange` | `CInputMethod.attributedSubstringFromRange`: `getCommittedText` (có marked text thì ghép phần đang soạn), cắt độ dài nếu vượt độ dài chữ đã chốt | Chuỗi không thuộc tính; `actualRange` không được điền | nil (kể cả khi `getCommittedText` của component trả null: lỗi trong việc hỏi bị bắt và in ra stderr) |
| `firstRectForCharacterRange` | `getTextLocation`: chỉ dùng vị trí đầu, tính từ vị trí chèn | Hình chữ nhật tại vị trí chèn; độ dài vùng và `actualRange` bị bỏ | hình rỗng |
| `characterIndexForPoint` | `getLocationOffset` | Chỉ trúng chữ đang soạn mới trả chỉ số trong đó; trượt thì trả vị trí chèn | NSNotFound khi không có bộ gõ Java |

Dấu chỉ dùng hàng đầu và hàng thứ ba (D11, D20).

### 1.5 Bản vá JBR khác có liên quan

- **JBR-6704:** sau tổ hợp ⌃ làm đổi cửa sổ, `insertText` một ký tự trùng ký tự của tổ hợp, tới ngoài lúc xử lý phím, bị bỏ. Không ảnh hưởng chữ tiếng Việt.
- **JBR-1144** (gốc của `abandonInput:` trong `insertText`): sửa lỗi bảng chọn dấu khi giữ phím.
- **Giữ phím để chọn dấu** (JBR-7426, JBR-7449, JBR-7529): `keyDown:` coi một phím là "giữ phím" khi `[event willBeHandledByComplexInputMethod]` trả có. Với phím như vậy, sau `interpretKeyEvents` JBR nuốt Return, Esc, mũi tên, Page Up/Down, Home, End.
- **JBR-6297:** `mouseDown:` không hỏi bộ gõ có muốn nhận chuột không. Bấm chuột không tới Dấu; Dấu nhận ra con trỏ đã đi chỗ khác qua `selectedRange` (D11).

### 1.6 Điểm chưa rõ (suy luận, cần kiểm chứng)

- **`markedTextAbandoned:` sau mỗi `insertText`.** `NSInputManager` bị bỏ từ macOS 10.6 ([tài liệu Apple](https://developer.apple.com/documentation/appkit/nsinputmanager)). Lượt đo 17/11 cho thấy Dấu bị reset sau mỗi phím đi thẳng, không sau phím Dấu tự gửi chữ. Lời gọi này là ứng viên duy nhất khớp mọi quan sát; cách nó tới Dấu chưa có nguồn (mục 4.2).
- **`willBeHandledByComplexInputMethod`** không có trong header của SDK. Nếu nó trả "có" với Dấu, Return, Esc và mũi tên không tới IDE. Lượt đo 17/11: Return gõ khi Dấu bật tới được terminal, nên với Return giá trị là "không". Esc và mũi tên chưa đo.
- **Lời gọi tới sau `keyDown:`.** Nếu `insertText` của Dấu tới sau khi `keyDown:` đã trả, JBR đã gõ ký tự gốc của phím (mục 1.1) rồi mới nhận chữ thay qua `InputMethodEvent`. Kết quả là phím gốc cộng chữ thay. Theo mô tả ở [`docs/Architecture.md`](../Architecture.md), AppKit không giao như vậy; chưa thấy ở ứng dụng nào.

## 2. Terminal

### 2.1 Engine nào đang chạy

- `TerminalEngine` có ba giá trị: `REWORKED`, `CLASSIC`, `NEW_TERMINAL`. Giá trị mặc định trong `TerminalOptionsProvider` là `REWORKED`. `ClassicTerminalMigration` (chạy một lần ở 2026.3) chuyển người dùng Classic sang Reworked khi bật giao diện mới; `ExperimentalTerminalMigration` (2026.1) chuyển `NEW_TERMINAL` sang Reworked.
- Thư mục cài đặt `~/Library/Application Support/JetBrains/WebStorm2026.3` (chỉ đọc):
  - `options/terminal.xml` không có `terminalEngine`, tức dùng mặc định.
  - `options/other.xml` ghi cả hai lần chuyển engine đã chạy.
  - Registry người dùng đổi có `ide.experimental.ui = true`, `terminal.new.ui = true`. Khoá sau giờ không làm gì; theo `terminal.xml` của plugin, nó chỉ dùng cho lần chuyển cài đặt cũ.
- Trong Reworked, trình giả lập (phân tích chuỗi điều khiển) là Ghostty VT khi `terminal.use.ghostty.emulator` bật. Khoá này mặc định bật trong `META-INF/terminal.xml` của plugin đi kèm, dù comment của `TerminalEmulatorType` còn nói mặc định là JediTerm. `idea.log` ngày 16/11/2026 có dòng nạp `libghostty-vt` ngay sau lúc mở một shell. Trình giả lập chỉ đổi cách mã hoá phím thành byte; đường nhập liệu ở mục 2.2 không đổi.
- `~/Library/Application Support/JetBrains/WebStorm2026.3/plugins/terminal` là plugin Terminal 253.30387.92. `idea.log` ghi nó bị loại vì chỉ hợp với build tới 253.*. IDE nạp bản đi kèm 263.7307.202.

### 2.2 Reworked

- **Component có focus:** `EditorComponentImpl` của một trình soạn thảo IntelliJ chỉ đọc (viewer), tạo trong `TerminalViewImpl`. Tài liệu của nó là chữ trên màn hình cộng phần đã cuộn lên. Màn hình phụ (vim, less) có trình soạn thảo riêng, lắp cùng các tính năng (`installBufferEditorFeatures`).
- **`InputMethodRequests`:** `TerminalOutputEditorInputMethodSupport.MyInputMethodRequests`, gắn vào trình soạn thảo qua `EditorImpl.setInputMethodSupport`.
  - `getInsertPositionOffset`: vị trí con trỏ terminal, đổi ra vị trí trong tài liệu đầu ra. Vậy `selectedRange` là {vị trí con trỏ, 0}.
  - `getSelectedText`: luôn null. Người dùng bôi đen chữ trong terminal cũng không làm `selectedRange` có độ dài.
  - `getCommittedText`: chữ của tài liệu đầu ra. `attributedSubstring` trước con trỏ trả dấu nhắc và chữ đang gõ **như shell đã in lại**.
- **Chữ đã chốt và phím:**
  - `TerminalEventDispatcher` (bộ chặn trong `IdeEventQueue`, khi "Override IDE shortcuts" bật) hoặc `TerminalKeyListener` chuyển sự kiện phím cho `TerminalKeyEventsHandlerImpl`.
  - KEY_TYPED đi qua `TerminalEmulatorKeyEventEncoder` (Ghostty) thành byte UTF-8, gửi bằng `TerminalInput.sendString` qua một kênh tới pty (bất đồng bộ).
  - Sau mỗi phím đã gửi, bộ xử lý **xoá vùng chọn** của trình soạn thảo và đưa con trỏ trình soạn thảo về con trỏ terminal (`syncEditorCaretWithModel`).
  - KEY_PRESSED của phím chữ không được xử lý; Backspace, Return, phím có ⌃/⌥ được mã hoá ngay ở KEY_PRESSED.
- **Chữ của `InputMethodEvent`:** `handleInputMethodTextChanged`. Phần đã chốt gửi thẳng xuống pty bằng `sendString`. Phần đang soạn hiện bằng một inlay tại con trỏ, không gửi gì.
- **Vùng thay:** `select` của `EditorComponentImpl` (mục 3.1) đặt vùng chọn lên chữ đầu ra. KEY_TYPED sau đó gửi chữ mới xuống pty và xoá vùng chọn. Chữ cũ đã nằm trong bộ đệm dòng của shell từ trước; không có gì gửi lệnh xoá. **Thay chữ đã gửi không có tác dụng nào**, ngoài vùng chọn nháy lên một lúc.
- **Vị trí trả về đi sau shell:** đoán chữ trước (type-ahead) chỉ bật ở chế độ tách frontend/backend; `TerminalViewImpl.createOutputModelController` tắt nó khi IDE chạy một tiến trình. Vì vậy vị trí con trỏ chỉ đổi khi shell đã in lại chữ: phím đi qua kênh, xuống pty, shell in lại, trình giả lập xử lý, mô hình đầu ra cập nhật trên EDT. Ở nhịp chậm, `selectedRange` gần như luôn đã có phím trước; ở nhịp nhanh thì có thể chưa.
- **Nuốt KEY_TYPED:** sau một KEY_PRESSED đã xử lý (Backspace, Return…), `TerminalKeyEventsHandlerImpl` bỏ **mọi** KEY_TYPED cho tới KEY_PRESSED kế. Chữ JBR gắn vào các phím đó (mục 1.1) không bao giờ tới pty. `TerminalEventDispatcher` còn bỏ KEY_TYPED đầu tiên sau khi terminal nhận focus, nếu chưa có KEY_PRESSED nào trước nó.

### 2.3 Classic (JediTerm)

- **Component có focus:** `JBTerminalPanel`, lớp con của `TerminalPanel` (JediTerm), là `JComponent`, không phải `JTextComponent`.
- **`InputMethodRequests`** (`TerminalPanel.MyInputMethodRequests`):
  - `getInsertPositionOffset` luôn 0, `getSelectedText` null, nên `selectedRange` luôn {0, 0}.
  - `getCommittedText` trả null, nên `attributedSubstring` trả nil.
  - `getTextLocation` là ô của con trỏ.
- **Chữ:** `processInputMethodEvent` gửi phần đã chốt xuống pty (`sendString`); phần đang soạn chỉ được vẽ đè tại con trỏ. KEY_TYPED đi `TerminalKeyEventProcessor`. Khi đang có chữ soạn dở, bộ xử lý phím không gửi gì.
- **Vùng thay:** `select` không áp dụng; bộ nghe `TextInput` của IntelliJ không xử lý component này. Vùng thay bị bỏ hẳn. Về mặt bộ gõ, đây giống ứng dụng Ghostty: vị trí 0, không có chữ để đọc.

### 2.4 Thay chữ đã gửi có tác dụng gì không

Không, ở cả hai engine. Byte đã ghi xuống pty thuộc về chương trình đang chạy (shell). Thứ duy nhất sửa được chúng là byte xoá (DEL), mà Dấu không gửi (D43; cách gửi DEL đã bỏ). Chỉ phần chữ chưa chốt (marked text) là chưa tới pty.

## 3. Trình soạn thảo

### 3.1 Cơ chế

- **Component có focus:** `EditorComponentImpl`, lớp con của `JTextComponent` (để có trợ năng). Nó ghi đè `select(đầu, cuối)` cho đúng trường hợp này: comment nói JDK gọi hàm khi bộ gõ muốn thay chữ đã chốt.
  - Hàm đặt vùng chọn cùng độ lệch so với mọi con trỏ, nếu chữ ở mọi con trỏ giống nhau.
  - Không thì đặt một vùng chọn theo vị trí tuyệt đối.
  - Hàm lấy chữ theo vùng trước khi chọn; vùng vượt độ dài tài liệu thì ném lỗi trong việc đặt trên EDT. Lỗi đó IDE ghi là lỗi nội bộ (suy luận).
- **`InputMethodRequests`:** `EditorImpl.MyInputMethodHandler`, bọc trong `EditorInputMethodHandleSwingThreadWrapper`. Nếu `IdeEventQueue.isInputMethodEnabled` tắt thì không có `InputMethodRequests`; trên macOS nó chỉ tắt khi có mã gọi `disableInputMethods`.
  - `getInsertPositionOffset`: vị trí con trỏ chính trong tài liệu, trừ phần đang soạn.
  - `getSelectedText`: chữ đang chọn. Có vùng chọn thì JBR lấy đầu vùng từ con trỏ Swing của trợ năng (`EditorAccessibilityCaret`), tức đầu vùng chọn thật.
  - `getCommittedText`: chữ tài liệu, bỏ phần đang soạn.
  - `getTextLocation`: luôn ở con trỏ chính.
  - Vị trí tính bằng đơn vị UTF-16 từ đầu tài liệu, như Apple quy định.
- **KEY_TYPED:** bộ nghe phím của `EditorImpl` gọi `processKeyTyped`, đi qua `TypedAction`. Gõ khi đang có vùng chọn thì thay vùng chọn, nên cặp "chọn rồi gõ" của JBR ra đúng thay tại chỗ.
- **`InputMethodEvent`:** `EditorInputMethodListener` → `replaceInputMethodText`.
  - Xoá chữ đang soạn cũ.
  - Gõ phần đã chốt từng ký tự bằng `processKeyTyped0`.
  - Chèn phần đang soạn vào tài liệu như một vùng đánh dấu, không vào lịch sử hoàn tác. Inlay là cách khác, sau khoá registry `editor.input.method.inlay`, mặc định tắt.
- **Action trên KEY_PRESSED:** `IdeKeyEventDispatcher` chạy action theo phím tắt (Backspace, Enter, Tab…) ngay ở KEY_PRESSED. Khi một action đã chạy, nó **bỏ mọi KEY_TYPED** cho tới sự kiện kế không phải KEY_TYPED (`isPressedWasProcessed`, `inProcessedState`).
- **Vá giữ phím chọn dấu** (khoá `ide.mac.pressAndHold.workaround`, mặc định bật):
  - `getSelectedText` bật cờ "chọn ký tự trước" nếu một phím chữ A–Z đang được giữ (đã KEY_PRESSED, chưa KEY_RELEASED).
  - `InputMethodEvent` kế tiếp có chữ chốt sẽ chọn ký tự trước con trỏ rồi gõ đè lên.
  - Mọi KEY_TYPED xoá cờ.
  - Với Dấu thay tại chỗ, chữ đi bằng KEY_TYPED nên cờ bị xoá trước khi gây hại. Với gạch chân, Dấu không hỏi `selectedRange`.
  - Cờ chỉ gây hại khi `insertText` tới ngoài lúc xử lý phím, mà một câu hỏi `selectedRange` trước đó rơi vào lúc người gõ đè phím (suy luận).

### 3.2 Thay tại chỗ: phím chữ cái và phím dấu

Với `toois`, mỗi lần thay là một chuỗi "chọn" → KEY_PRESSED (không action) → KEY_TYPED:

- "o" thứ hai: chọn "o", gõ "ô".
- "s": chọn "ôi", gõ "ố" rồi "i".

`selectedRange` đến sau mọi phím trước trên EDT (mục 1.4), nên luôn khớp vị trí Dấu theo dõi; nhánh "App trả lời chậm" của D11 không bao giờ cần. D20 đọc được chữ thật. Đã đo: mọi lần thay trong lượt 17/11 ra đúng chỗ; `selectedRange` tốn 0,4–3,8 ms, mỗi lần đọc chữ 0,6–1,6 ms (mục 4.1). Bấm chuột không tới Dấu (JBR-6297), nhưng `selectedRange` lệch sau cú bấm cho Dấu biết (D11, "Dựng lại khi lệch").

Ngoại lệ có thể:

- Khi focus đang chuyển, IntelliJ có thể giữ lại sự kiện phím (type-ahead của `IdeEventQueue`) trong khi việc hỏi vẫn chạy. Câu trả lời khi đó có thể cũ (suy luận, chưa đọc kỹ).
- Mỗi `selectedRange` tốn một vòng chờ EDT. EDT bận thì phím chờ theo; số đo thời gian mỗi phím sẽ cho thấy.

### 3.3 Phím vừa thay chữ vừa để đi

Dấu có hai đường gọi `insertText` rồi trả phím cho ứng dụng: ⌫ dời dấu (D32; [`docs/Architecture.md`](../Architecture.md) mục "Backspace thay tại chỗ"), và Return/Tab sau một từ cần khôi phục (D4; `InPlaceComposer`, nhánh `endWord`). Trong JBR, trên EDT:

1. Việc chọn vùng thay.
2. KEY_PRESSED của ⌫, Return hay Tab. `IdeKeyEventDispatcher` chạy action trên vùng vừa chọn:
   - Backspace xoá vùng chọn;
   - Enter (`EnterAction.insertNewLineAtCaret`) xoá vùng chọn rồi xuống dòng;
   - Tab có vùng chọn thì thụt lề các dòng được chọn (suy luận, chưa đọc `TabAction`).
3. Các KEY_TYPED mang chữ thay bị bỏ, vì action đã chạy (mục 3.1).

Dự đoán:

- `hoaf⌫`: chọn "oà", Backspace xoá, chữ "òà" bị bỏ, ra "h". Đúng phải là "hò".
- Một từ Dấu khôi phục ở cuối từ, gõ Return ngay sau: từ đang hiện bị xoá, xuống dòng, chữ khôi phục bị bỏ. Từ biến mất.
- Cùng từ đó với dấu cách thì đúng: Dấu nuốt dấu cách và đưa từ khôi phục kèm dấu cách trong một `insertText`.

Terminal Reworked có hiện tượng gần giống: chữ gắn vào ⌫/Return bị bỏ (mục 2.2). Ở đó chữ đã sai từ trước.

## 4. Dự đoán và kết quả đo

### 4.1 Lượt đo 17/11/2026

Điều kiện:

- Máy M1 Pro, macOS 27.2, WebStorm 2026.3 (WS-263.7307.202).
- Terminal Reworked theo mặc định (`webstormterm.engine`), trình soạn thảo trên tệp `.txt` trống của một dự án tạm.
- Dấu bản Debug của commit 2990a91, cộng ô `webstorm`, `webstormterm` mới của script.
- Nhịp 80 ± 30 ms mỗi phím, nghỉ 250 ms sau mỗi từ. Một lượt mỗi ô.

Lệnh: `scripts/selftest/typing/run.sh --delay 80 --jitter 30 --word-pause 250 --save DIR --shot webstorm webstormterm`. Thêm `--underline` cho gạch chân, `--source com.apple.inputmethod.VietnameseIM.VietnameseTelex` cho Telex của Apple. Log của lượt đo không đưa lên repo; chạy lại lệnh trên với `--save` để có lại.

Chuỗi phím `windows carr tooi yeeu tieengs Vieetj, Sunrise `, đáp án "windows car tôi yêu tiếng Việt, Sunrise ".

| Ô | Dấu thay tại chỗ | Dấu gạch chân (D13) | Telex của Apple |
|---|---|---|---|
| Trình soạn thảo | "ưindows car tôi yêu tiếng Việt, Sủnise " | đúng | "ưindows car tôi yêu tiếng Việt, Sủnise " |
| Terminal Reworked | "ưindows caảr toôi yeêu tieêngs Vieêtj, Sunủnise " | đúng | "ưindows car tôi yêu tiếng Việt, Sủnise " |

- Telex của Apple không khôi phục từ nước ngoài, nên "ưindows", "Sủnise" là cách gõ của nó, không phải lỗi của ô.
- Terminal, Dấu thay tại chỗ: byte xuống pty (`webstormterm.raw`) đúng chuỗi trên, không có DEL. Chữ thay được nối sau chữ cũ, đúng cơ chế mục 2.2. Log chẩn đoán: ở chữ "r" thứ hai của `carr`, vị trí app trả (510) đi trước vị trí Dấu theo dõi (509) một ký tự, nên Dấu đọc lại và để phím đi thẳng (`resync_pass`). Đây là cách giải ở mục 4.3.
- Terminal, gạch chân: mỗi từ cùng dấu cách xuống pty một lần, như dự đoán.
- Thời gian xử lý mỗi phím trong trình soạn thảo (47 phím của chuỗi): trung vị 1,4 ms, lớn nhất 4,9 ms.

### 4.2 Chẩn đoán trình soạn thảo: vì sao mất khôi phục D4

Log theo phím của ô trình soạn thảo (`webstorm.perf.log` do `--save` ghi), 47 dòng phím cho 47 phím của chuỗi (khớp từng phím):

- **Phím ngay sau một phím đi thẳng** (bản trước 22/11/2026; `pass` hay `seed_pass`, Dấu để app tự chèn chữ, nay Dấu tự chèn) luôn gặp engine rỗng và chưa biết chữ trước con trỏ. Phím đó đi đường đọc của D20 (`seed_none`, `seed_pass`, `seed`), kể cả chữ cái đầu mỗi từ sau dấu cách, nơi lẽ ra không cần đọc.
- **Phím ngay sau một phím Dấu tự gửi chữ** (`seed`, `replace`, hay `seed_none` có `insertText`) luôn còn từ trong engine (`d20=none`, `diff=1`). Ví dụ: "o" thứ hai của `tooi` thay thành "ô", rồi "i" đi thẳng không đọc; hai chữ "r" của `carr` liền nhau, nên D26 (Gõ đúp phím dấu) ra "car" đúng.
- Không có dòng `activate` nào trong lúc gõ (một dòng trước phím đầu). Không có `client-changed`, `source-changed-reset`, phím `reset` hay `commit` do chuột.

Giả thuyết và dự đoán của từng giả thuyết:

| Giả thuyết | Dự đoán | Khớp log? |
|---|---|---|
| H1. `markedTextAbandoned:` ở cuối **mọi** `insertText` của JBR (mục 1.2) tới Dấu thành `commitComposition`, engine reset | Reset sau cả phím đi thẳng lẫn phím Dấu tự gửi chữ | Không: phím sau phím Dấu tự gửi chữ còn từ |
| H1'. Như H1, nhưng chỉ lời gọi đến khi Dấu không còn trong `handle` mới có tác dụng: chữ AppKit tự chèn cho phím đi thẳng (hành vi trước 22/11/2026; nay Dấu tự chèn các ký tự đó, nên H1' có thể không còn áp dụng, chưa đo). Lời gọi sinh ra từ chính `insertText` của Dấu, trong lúc IMK chờ Dấu trả lời, không tới hoặc bị bỏ | Reset sau mọi phím đi thẳng, không bao giờ sau phím Dấu tự gửi chữ | Khớp mọi dòng. Phần "chỉ khi không trong `handle`" chưa có nguồn |
| H2. IntelliJ gọi `InputContext.endComposition` khi tài liệu hay con trỏ đổi; JBR chuyển thành `abandonInput:` trên luồng chính (`nativeEndComposition`, không chờ) | Reset sau mọi phím làm đổi chữ, gồm cả phím Dấu tự gửi chữ | Không |
| H3. Nguồn reset riêng của Dấu: kích hoạt lại, đổi client, chuột, đổi nguồn đầu vào, phím đến lúc đang bận (D18) | Có dòng `activate`, `client-changed`, `reset`, `source-changed-reset`, hoặc thiếu dòng phím | Không: không có dòng nào như vậy, đủ 47 dòng |
| H4. macOS reset bộ gõ sau mọi phím đi thẳng, ở mọi app | Mất khôi phục D4 ở mọi app | Không: cùng chuỗi phím ra đúng "windows … Sunrise" trong TextEdit ngày 03/11/2026 ([`docs/history/LogM5.md`](../history/LogM5.md)) |

Kết luận:

- **Reset sau mỗi phím đi thẳng là quan sát chắc** từ log.
- **Ai gây reset thì chưa rõ.** H1' giải thích mọi quan sát, nhưng phần quyết định của nó chưa có nguồn: chỉ chữ chèn ngoài `handle` mới làm Dấu reset. Các lời gọi `commitComposition` và `deactivateServer` không được ghi vào log perf, nên log không thấy trực tiếp chúng.
- **Cách phân biệt:** ghi một dòng `perf.note` trong `commitComposition` và `deactivateServer` của bản Debug, rồi chạy lại ô `webstorm` một lần. H1' dự đoán một dòng `commitComposition` ngay sau mỗi phím đi thẳng, và không có dòng nào sau phím Dấu tự gửi chữ.

Vì sao mất khôi phục:

- D20 dựng lại từ từ chữ đang hiện. Theo [`docs/Architecture.md`](../Architecture.md) mục "Thêm dấu cho từ đã gõ", mốc khôi phục D4 là chữ đã đọc.
- `windows`: "w" đầu từ thành "ư". "i" đi thẳng rồi reset. Từ đó mỗi phím đọc lại, và mốc khôi phục luôn là chữ đang hiện "ưi…". Phím gốc "w" không còn trong engine, nên ở dấu cách không có gì để khôi phục: "ưindows".
- `Sunrise`: "S", "u", "n" mỗi phím một lần đọc. "r" đặt dấu hỏi lên từ vừa đọc: "Sủn" (Dấu tự gửi chữ, engine còn từ). "i" đi thẳng rồi reset. "s", "e" đọc lại "Sủni…", không còn là tiếng Việt nên đi thẳng. Mốc là "Sủni", nên dấu cách không khôi phục: "Sủnise". Ở app không reset, từ hết hợp lệ và dấu cách khôi phục "Sunrise".
- Chữ tiếng Việt vẫn đúng: mỗi lần đọc dựng lại đúng từ đang hiện, và các phím biến đổi hay dấu thanh áp lên từ đó (D20). Dự đoán cũ "mọi nhịp đều đúng" sai ở phần D4; dự đoán phụ "reset sau mỗi lần thay" sai ở chỗ reset theo phím đi thẳng chứ không theo lần thay.

### 4.3 Dự đoán trước lượt đo (chuỗi `toois vieetj dd `)

Giữ lại để so với các ca chưa đo ở mục 5. Đáp án "tối việt đ "; "120 ms" là khoảng cách giữa hai phím, như các lượt đo terminal trước ([`docs/research/TerminalAndUnderline.md`](TerminalAndUnderline.md)).

| Ô | Dấu thay tại chỗ | Dấu gạch chân (D13) | Telex của Apple |
|---|---|---|---|
| Trình soạn thảo (tệp .txt) | "tối việt đ "; đã đo cùng loại phím trên chuỗi khác: chữ tiếng Việt đúng ở 80 ± 30 ms (mục 4.1) | "tối việt đ "; đo: đúng | "tối việt đ "; đo: đúng |
| Terminal Reworked (đang cấu hình) | 120 ms: "toôis vieêtj dđ "; đo trên chuỗi khác: chữ thay nối sau chữ cũ như dự đoán | "tối việt đ "; đo: đúng | "tối việt đ "; đo: đúng |
| Terminal Classic (tham khảo) | như Ghostty đã đo (D43, [`docs/research/TerminalAndUnderline.md`](TerminalAndUnderline.md) mục 1); chưa đo | "tối việt đ "; chưa đo | "tối việt đ "; chưa đo |

Cách ra "toôis vieêtj dđ " (terminal Reworked, 120 ms, shell kịp in lại mỗi phím):

1. `t`: lần đọc của D20 thấy dấu nhắc, không có từ; Dấu biết vị trí. `o`, `o`: lần thay đầu khớp vị trí, nên Dấu thay "o" bằng "ô". Terminal nhận thêm "ô": "toô". Từ đây vị trí thật đi trước vị trí Dấu theo dõi một ký tự.
2. `i` đi thẳng. `s` cần thay "ôi": `selectedRange` lệch, phím trước cách quá 50 ms. Dấu đọc từ trước con trỏ là "toôi" (D11, "Dựng lại khi lệch"). Đó không phải tiếng Việt, nên `s` đi thẳng: "toôis".
3. `vieetj` diễn ra như vậy: "ê" được thêm vào ("vieê"), `j` gặp lệch, đọc "vieêt", đi thẳng: "vieêtj". `dd`: "dđ".

Lượt đo cũng có reset sau mỗi phím đi thẳng trong terminal (cùng mẫu trong `webstormterm.perf.log`). Nó đổi phím nào đi đường đọc, nhưng không đổi kết luận: chữ thay luôn nối sau chữ cũ.

Byte xuống pty theo dự đoán:

- **Dấu thay tại chỗ, Reworked, 120 ms:** `74 6f c3b4 69 73 20 76 69 65 c3aa 74 6a 20 64 c491 20`, tức t o ô i s ␠ v i e ê t j ␠ d đ ␠. Mỗi phím một lần ghi, không có byte DEL (`7f`). Lượt đo: không DEL, đúng.
- **Dấu gạch chân:** mỗi từ cùng dấu cách là một lần ghi. Lượt đo: đúng.
- **Return:**
  - Gạch chân: Return ngay sau từ đang soạn ra chữ của từ rồi `0d`, không bị nuốt.
  - Thay tại chỗ: Return sau từ cần khôi phục chỉ ra `0d`; chữ khôi phục bị bỏ (mục 2.2).
  - Chưa đo.

## 5. Ca còn đáng đo

Đáp án theo luật, không theo dự đoán. Mỗi ca kèm điều nó quyết định:

- **Ghi `commitComposition` vào log Debug rồi chạy lại ô `webstorm`** (mục 4.2). Quyết định H1' đúng hay sai, tức lỗi D4 ở WebStorm đến từ JBR hay từ chỗ khác. Đây là điều kiện để chọn cách sửa: Dấu bỏ qua `commitComposition` ngay sau phím đi thẳng, hay sửa ở chỗ khác.
- **Trình soạn thảo: `hoaf⌫`** (đáp án "hò"; dự đoán "h"). Quyết định đường "thay rồi để phím đi" của D32 có hỏng trong JBR không (mục 3.3).
- **Trình soạn thảo: một từ Dấu khôi phục theo D4, rồi Return ngay sau.** Dự đoán từ biến mất. Với reset sau phím đi thẳng (mục 4.2), từ nước ngoài có thể không được khôi phục chút nào, khi đó Return không có chữ để thay. Chọn từ mà phím ngay trước Return là phím Dấu tự gửi chữ (ví dụ một từ kết thúc bằng phím dấu), soát chuỗi với engine trước khi chạy. Quyết định Return/Tab có cần đường riêng trong JBR không.
- **Trình soạn thảo ở nhịp 30 ms:** D20 đọc lại sau reset ở mọi nhịp (D20, "Phạm vi"), nên nếu H1' đúng thì chữ ở 30 ms dự đoán như ở nhịp 80 ms đã đo. Quyết định lỗi có lan sang chữ tiếng Việt khi gõ nhanh không, tức mức nghiêm trọng của lỗi cho người dùng thật.

## 6. Đo tự động: những điều phải xử lý

Script đo: `scripts/selftest/typing/run.sh` (ô `webstorm`, `webstormterm`). Các điểm dưới đây đến từ mã nguồn ở trên.

- **Focus và cửa sổ:**
  - Terminal chỉ có trong cửa sổ dự án. Chế độ LightEdit (mở một tệp không có dự án) không có terminal.
  - Dự án lạ hiện hộp thoại tin cậy, trừ khi IDE tự đánh dấu tin cậy như `--temp-project`.
  - ⌥F12 mở cửa sổ công cụ Terminal và đưa focus vào đó. KEY_TYPED đầu tiên sau khi terminal nhận focus mà không có KEY_PRESSED trước sẽ bị bỏ (mục 2.2). Phím thật luôn có KEY_PRESSED, nên chỉ ảnh hưởng chữ dán hay chữ gửi bằng đường khác.
- **Đọc chữ trình soạn thảo:** chép qua clipboard (⌘A ⌘C) đúng hơn đọc tệp trên đĩa. Khi lưu, IntelliJ mặc định xoá khoảng trắng cuối dòng ở dòng đã sửa, nên dấu cách cuối của đáp án có thể mất.
- **Ô trong trình soạn thảo:** dùng tệp `.txt`. Ở tệp mã, bảng gợi ý (lookup) và các bộ xử lý gõ của ngôn ngữ chen vào KEY_TYPED và Enter; chưa đọc kỹ.
- **Gợi ý lệnh ở dấu nhắc của terminal:** `commandCompletionShowingMode` = `ALWAYS` trong `terminal.xml`. Ở dấu nhắc shell, bảng gợi ý lệnh có thể bắt Return hay Tab. Gõ trong một chương trình đang chạy (như ô `vared` của script) thì trạng thái shell không phải "đang gõ lệnh", nên không có bảng gợi ý (suy luận, theo `TerminalOutputStatus`).
- **Nhịp gõ:** kết quả thay tại chỗ ở terminal Reworked phụ thuộc shell in lại chữ nhanh hay chậm so với nhịp gõ (mục 2.2). Ghi nhịp và cấu hình shell cạnh kết quả; một nhịp chậm và một nhịp nhanh đủ để thấy.
- **Log nên đọc sau lượt chạy:**
  - Log bản Debug của Dấu: kiểu của phím sau mỗi phím đi thẳng (mục 4.2); kiểu thay (`late`, `seed`…); thời gian đọc (vòng chờ EDT).
  - `idea.log`: lỗi từ `EditorComponentImpl.select` (vùng vượt tài liệu); dòng "invokeAndWait is discarded" (câu hỏi bị bỏ, `selectedRange` thành {0, 0}).
- **Ảnh chụp terminal:** sau mỗi lần thay tại chỗ, vùng chọn nháy trên chữ đầu ra. Đó là bước chọn của JBR, không phải chữ sai.
- **Return, Esc và mũi tên:** nếu không tới IDE khi Dấu bật, đó là nhánh "giữ phím" của JBR (mục 1.5, 1.6). Return đã qua được ở lượt 17/11.

## 7. Nguồn

Mã nguồn, cố định theo commit:

- JBR `787be56` (tag `jb25.0.4.1-b635.79`):
  - [`AWTView.m`](https://github.com/JetBrains/JetBrainsRuntime/blob/787be56cf0774a46defa818051f686b7bb18b0d5/src/java.desktop/macosx/native/libawt_lwawt/awt/AWTView.m): `keyDown:`, `deliverJavaKeyEventHelper`, `insertText:replacementRange:`, `setMarkedText:selectedRange:replacementRange:`, `selectedRange`, `markedRange`, `attributedSubstringForProposedRange:actualRange:`, `firstRectForCharacterRange:actualRange:`, `characterIndexForPoint:`, `abandonInput:`, `doCommandBySelector:`.
  - [`CInputMethod.java`](https://github.com/JetBrains/JetBrainsRuntime/blob/787be56cf0774a46defa818051f686b7bb18b0d5/src/java.desktop/macosx/classes/sun/lwawt/macosx/CInputMethod.java): `insertText`, `selectRange`, `dispatchText`, `selectedRange`, `markedRange`, `attributedSubstringFromRange`, `firstRectForCharacterRange`, `characterIndexForPoint`.
  - [`CPlatformResponder.java`](https://github.com/JetBrains/JetBrainsRuntime/blob/787be56cf0774a46defa818051f686b7bb18b0d5/src/java.desktop/macosx/classes/sun/lwawt/macosx/CPlatformResponder.java): `handleKeyEvent`.
  - [`LWCToolkit.java`](https://github.com/JetBrains/JetBrainsRuntime/blob/787be56cf0774a46defa818051f686b7bb18b0d5/src/java.desktop/macosx/classes/sun/lwawt/macosx/LWCToolkit.java): `invokeAndWait`, `invokeLater`.
  - [`JBRTextInputMacOS.java`](https://github.com/JetBrains/JetBrainsRuntime/blob/787be56cf0774a46defa818051f686b7bb18b0d5/src/java.desktop/macosx/classes/sun/lwawt/macosx/JBRTextInputMacOS.java).
  - [`AWTEvent.m`](https://github.com/JetBrains/JetBrainsRuntime/blob/787be56cf0774a46defa818051f686b7bb18b0d5/src/java.desktop/macosx/native/libawt_lwawt/awt/AWTEvent.m): `NsCharToJavaChar`.
  - Commit [JBR-7119](https://github.com/JetBrains/JetBrainsRuntime/commit/89f92798d63cf907a755e10343792bdf5e1dd668) và [JBR-7133](https://github.com/JetBrains/JetBrainsRuntime/commit/b4715a6653e86746d3f05c239716800c5d5e3239).
- intellij-community `26051d5` (nhánh `263.7307`):
  - [`EditorComponentImpl.java`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/platform/platform-impl/src/com/intellij/openapi/editor/impl/EditorComponentImpl.java): `select`, `processInputMethodEvent`, `getInputMethodRequests`.
  - [`EditorImpl.java`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/platform/platform-impl/src/com/intellij/openapi/editor/impl/EditorImpl.java): `MyInputMethodHandler`, `EditorInputMethodListener`, bộ nghe phím trong hàm dựng.
  - [`EditorAccessibilityCaret.java`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/platform/platform-impl/src/com/intellij/openapi/editor/impl/EditorAccessibilityCaret.java).
  - [`IdeEventQueue.kt`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/platform/platform-impl/src/com/intellij/ide/IdeEventQueue.kt): `addTextInputListener`, `isInputMethodEnabled`.
  - [`IdeKeyEventDispatcher.kt`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/platform/platform-impl/src/com/intellij/openapi/keymap/impl/IdeKeyEventDispatcher.kt): `isPressedWasProcessed`, `inProcessedState`.
  - [`EnterAction.java`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/platform/platform-impl/src/com/intellij/openapi/editor/actions/EnterAction.java): `insertNewLineAtCaret`.
  - [`registry.properties`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/platform/util/resources/misc/registry.properties): `ide.mac.pressAndHold.workaround`, `editor.input.method.inlay`.
  - [`TerminalOutputEditorInputMethodSupport.kt`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/plugins/terminal/src/org/jetbrains/plugins/terminal/block/output/TerminalOutputEditorInputMethodSupport.kt).
  - [`TerminalKeyEventsHandlerImpl.kt`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/plugins/terminal/frontend/src/com/intellij/terminal/frontend/view/impl/TerminalKeyEventsHandlerImpl.kt).
  - [`TerminalEventDispatcher.kt`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/plugins/terminal/frontend/src/com/intellij/terminal/frontend/view/impl/TerminalEventDispatcher.kt).
  - [`TerminalViewImpl.kt`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/plugins/terminal/frontend/src/com/intellij/terminal/frontend/view/impl/TerminalViewImpl.kt): `installBufferEditorFeatures`, `createOutputModelController`.
  - [`TerminalEmulatorKeyEventEncoder.kt`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/plugins/terminal/frontend/src/com/intellij/terminal/frontend/session/ghostty/TerminalEmulatorKeyEventEncoder.kt).
  - [`TerminalSessionStart.kt`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/plugins/terminal/frontend/src/com/intellij/terminal/frontend/session/TerminalSessionStart.kt).
  - [`TerminalEmulatorType.kt`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/plugins/terminal/src/org/jetbrains/plugins/terminal/TerminalEmulatorType.kt).
  - [`TerminalEngine.kt`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/plugins/terminal/src/org/jetbrains/plugins/terminal/TerminalEngine.kt).
  - [`TerminalOptionsProvider.kt`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/plugins/terminal/src/org/jetbrains/plugins/terminal/TerminalOptionsProvider.kt).
  - [`ClassicTerminalMigration.kt`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/plugins/terminal/src/org/jetbrains/plugins/terminal/ClassicTerminalMigration.kt).
  - [`terminal.xml`](https://github.com/JetBrains/intellij-community/blob/26051d5f54ea174bdc8a89622f0ea375777a2c6e/plugins/terminal/resources/META-INF/terminal.xml) (khoá registry).
- JediTerm `1b354a6` (3.76): [`TerminalPanel.java`](https://github.com/JetBrains/jediterm/blob/1b354a63f9845aee3474b0749af0a62e406f0076/ui/src/com/jediterm/terminal/ui/TerminalPanel.java): `processInputMethodEvent`, `MyInputMethodRequests`, `TerminalKeyHandler`.

Tài liệu Apple:

- [`NSTextInputClient.insertText(_:replacementRange:)`](https://developer.apple.com/documentation/appkit/nstextinputclient/inserttext(_:replacementrange:))
- [`NSTextInputClient.selectedRange()`](https://developer.apple.com/documentation/appkit/nstextinputclient/selectedrange()): {NSNotFound, 0} khi không có vùng chọn; vị trí tính từ đầu kho chữ.
- [`NSInputManager`](https://developer.apple.com/documentation/appkit/nsinputmanager): bỏ từ macOS 10.6.

Issue:

- [JBR-7119](https://youtrack.jetbrains.com/issue/JBR-7119), [JBR-7133](https://youtrack.jetbrains.com/issue/JBR-7133).
- YouTrack có các issue mở về bộ gõ tiếng Việt kiểu gửi Backspace (Unikey, EVKey) trong trình soạn thảo, ví dụ [IJPL-54498](https://youtrack.jetbrains.com/issue/IJPL-54498), [IJPL-54542](https://youtrack.jetbrains.com/issue/IJPL-54542). Cơ chế đó khác Dấu; chưa đọc nội dung.

Dữ liệu trên máy, chỉ đọc ngày 17/11/2026:

- `~/Applications/WebStorm.app/Contents/Resources/product-info.json`;
- `jbr/Contents/Home/release`;
- `plugins/terminal/lib/terminal.jar` (`META-INF/plugin.xml`);
- `~/Library/Application Support/JetBrains/WebStorm2026.3/options/terminal.xml`, `other.xml`;
- `~/Library/Logs/JetBrains/WebStorm2026.3/idea.log`.
