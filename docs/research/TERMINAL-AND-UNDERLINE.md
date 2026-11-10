# Gõ trong terminal (Ghostty, terminal của Claude) và sửa chữ ở chế độ gạch chân

Nghiên cứu đọc mã để tìm vì sao (1) chế độ gạch chân kém khi sửa chữ đã gõ và (2) thay tại chỗ hỏng trong Ghostty và trong terminal của ứng dụng Claude desktop. Mục đích là để phiên chính dựng được một lượt gõ thử ít ô phân biệt các giả thuyết.

## Hiện trạng (10/11/2026)

- **Mọi dự đoán ở đây là đọc mã, chưa đo trên máy.** Không có lượt gõ thử nào; chữ "dự đoán" ở các bảng là kết quả truy theo mã nguồn.
- **Phản hồi 2 (thay tại chỗ trong terminal):** Ghostty và terminal của Claude không thay chữ theo `replacementRange`, khác Terminal của Apple; đây không phải lỗi "app trả lời chậm" mà Dấu đã xử lý ở M6. Hai app hỏng theo hai kiểu khác nhau (mục 3), nên một lượt ít ô phân biệt được.
  - Ghostty: chữ thay bị nối thêm vào sau ("dd" → "dđ") khi Dấu tưởng app chậm, còn lại ra nguyên chuỗi phím.
  - Terminal của Claude (xterm.js): ra nguyên chuỗi phím với chữ thường.
- **Phản hồi 1 (gạch chân):** phần lớn do D20 (Thêm dấu cho từ đã gõ) bị tắt ở chế độ gạch chân theo chính D20 (mục Phạm vi). Đã xác nhận sau báo cáo đầu: phản hồi này đến từ Sublime Text (`com.sublimetext.4`) đang bật gạch chân; triệu chứng là không thêm hay sửa dấu được cho từ đã gõ, khớp giả thuyết H1a (mục 6). Riêng Ghostty, gạch chân còn làm mất Return/Tab/Esc ngay sau một từ đang gạch chân (lỗi của Ghostty).
- Việc tiếp theo: lượt gõ thử ở mục 6, rồi chọn hướng sửa ở mục 7 (mỗi hướng đụng một quyết định).

## Nhãn nguồn và bản đã đọc

| Nhãn | Nghĩa |
|---|---|
| **[Mã Dấu]** | mã và tài liệu trong repo này (dẫn theo tên kiểu/hàm) |
| **[Mã Ghostty]** | mã nguồn Ghostty |
| **[Mã xterm.js]** | mã xterm.js, bản thu gọn trong Claude.app và bản gốc |
| **[Mã Chromium]** | mã Chromium/Blink |
| **[Apple]** | tài liệu chính thức của Apple |
| **[Ngoài]** | README, issue, PR của dự án khác |
| **[Suy luận, cần kiểm chứng]** | chưa có nguồn hay số đo |

Bản đã đọc (bản sao tạm ngoài repo, không chép mã nào vào Dấu, D10 (Engine tự viết)):
- Ghostty: nhánh main, commit de70b9f476c39ce3f5b293ecba813b674f037a80 (10/11/2026). Đã so với tag v1.4.0 (bản cài trên máy): file SurfaceView_AppKit.swift (vùng IME) và src/input/key_encode.zig giống hệt. https://github.com/ghostty-org/ghostty
- Claude.app 4.23118.1 (`com.anthropic.claudefordesktop`): chỉ grep và cắt byte trong `ion-dist.asar` của bundle, không giải nén.
- Chromium: nhánh main, tải ngày 10/11/2026 (trang lịch sử cần đăng nhập nên không ghi commit): content/app_shim_remote_cocoa/render_widget_host_view_cocoa.mm, third_party/blink/renderer/core/editing/ime/input_method_controller.cc, third_party/blink/renderer/core/exported/web_input_method_controller_impl.cc, third_party/blink/renderer/core/editing/commands/typing_command.cc, third_party/blink/renderer/core/editing/editing_utilities.cc. https://chromium.googlesource.com/chromium/src/
- xterm.js: master, bản 6.0.0 (src/browser/input/CompositionHelper.ts, src/browser/CoreBrowserTerminal.ts). Bản trong Claude.app cũ hơn một chút (chưa có bản sửa phím bổ trợ của `_keyDown`), hành vi dùng ở đây giống nhau. https://github.com/xtermjs/xterm.js

Tài liệu Apple đã tra:
- `insertText(_:replacementRange:)`: https://developer.apple.com/documentation/appkit/nstextinputclient/inserttext(_:replacementrange:)
- `selectedRange()`: "The range of selected text or {NSNotFound, 0} if there is no selection." https://developer.apple.com/documentation/appkit/nstextinputclient/selectedrange()
- `attributedSubstring(forProposedRange:actualRange:)`: https://developer.apple.com/documentation/appkit/nstextinputclient/attributedsubstring(forproposedrange:actualrange:)
- `interpretKeyEvents(_:)`: gửi phím cho hệ thống nhập liệu. https://developer.apple.com/documentation/appkit/nsresponder/interpretkeyevents(_:)
- `NSTextInputContext.handleEvent(_:)`: "mouse or key events". https://developer.apple.com/documentation/appkit/nstextinputcontext/handleevent(_:)

## 1. Bảng khả năng

| Khả năng | Ghostty 1.4.0 | Terminal của Claude (xterm.js trong Electron) | Terminal của Apple (mốc) |
|---|---|---|---|
| Thay theo `replacementRange` | **Không.** `insertText(_:replacementRange:)` bỏ qua tham số, gửi chuỗi xuống pty như phím gõ [Mã Ghostty `insertText`, `committedTextAction`] | **Không.** Chromium gửi `ImeCommitText(text, range)` ngay [Mã Chromium `insertText:replacementRange:`]; Blink chọn vùng đó trong textarea ẩn rồi chèn, sự kiện `input` có `inputType` "insertText" và `data` chỉ là chữ mới, không có lệnh xoá [Mã Chromium `ReplaceTextAndKeepSelection`, `TypingCommand::GetInputType`]. Textarea của xterm gần như luôn rỗng nên vùng thay nằm ngoài chữ và bị bỏ (`SetSelectionOffsets` trả false khi vùng rỗng [Mã Chromium]; vùng ngoài chữ cho vùng rỗng [Suy luận, cần kiểm chứng]) | Có: thay đúng khi phím cách nhau từ 20 ms [Mã Dấu: `docs/COMPATIBILITY.md` mục 6.2] |
| Vị trí con trỏ (`selectedRange`) | **Luôn `{0,0}` khi không bôi đen** (`NSRange()`); có bôi đen bằng chuột thì trả vị trí vùng bôi đen trong màn hình, không phải con trỏ [Mã Ghostty `selectedRange`, `ghostty_surface_read_selection`]. Apple quy định `{NSNotFound, 0}` khi không có vùng chọn [Apple] | Vùng chọn của textarea ẩn [Mã Chromium `selectedRange`]. Textarea rỗng vì xterm gửi phím thường ngay ở `keydown` rồi chặn mặc định [Mã xterm.js `_keyDown`], nên thường là `{0,0}`, hoặc `{1,1}` cục bộ sau một lần chèn [Mã Chromium `insertText:replacementRange:` cập nhật `_textSelectionRange`; giá trị cụ thể: Suy luận, cần kiểm chứng] | Có, là ảnh chụp cũ khi phím dồn [Mã Dấu: `docs/COMPATIBILITY.md` mục 6.2] |
| `attributedSubstring` | Trả **chữ đang bôi đen** bất kể vùng hỏi; không bôi đen thì nil [Mã Ghostty] | Chữ trong textarea, thường rỗng [Mã Chromium; Suy luận, cần kiểm chứng] | Có (D20 chạy, trừ sau ⌫) |
| ⌫ tới bộ gõ | **Có**: `keyDown` luôn gọi `interpretKeyEvents` [Mã Ghostty `keyDown`] | Có: Chromium gọi `interpretKeyEvents` trước [Mã Chromium `keyEvent:`] | **Không** [Mã Dấu: `docs/COMPATIBILITY.md` mục 6.5] |
| Phím không tới bộ gõ | Phím tắt menu của Ghostty xử lý (`performGhosttyBindingMenuKeyEquivalent`). Bấm chuột: `mouseDown` không gọi `inputContext.handleEvent`, nên Dấu không nhận click [Mã Ghostty; Apple `handleEvent`; kết luận về Dấu: Suy luận, cần kiểm chứng] | Phím có ⌘ là phím tắt hệ thống [Mã Chromium] | ⌫ |
| Marked text | Có: `setMarkedText` → `syncPreedit` vẽ đè tại con trỏ; `insertText` gọi `unmarkText` rồi gửi chữ. `setMarkedText` bỏ qua `replacementRange`. **Sau khi chốt chỉ gửi lại ↑ ↓ → (và ← có phím bổ trợ); Return, Tab, Esc, ← thường, ⌃C bị nuốt** [Mã Ghostty `keyDown`, `shouldReplayCommittedPreeditKey`; Ngoài: PR #15048, #14272 tả đúng lỗi này với IME tiếng Hàn, đã đóng, chưa merge] | Có, qua `compositionstart/update/end`; phím trong lúc soạn là 229 (`VKEY_PROCESSKEY`), xterm bỏ qua; Return sau khi chốt được Chromium gửi lại sau phần chữ [Mã xterm.js CompositionHelper; Mã Chromium `delayEventUntilAfterImeComposition`] | Có; ở 0 ms còn vẽ marked text cũ [Mã Dấu: D13 (Gạch chân là đường lui cuối cùng)] |

## 2. Cơ chế trong Dấu ở hai app này

Theo [Mã Dấu] `InPlaceComposer`, `CursorTracker`:
- Phím chữ hoặc phím dấu đầu tiên khi bộ đệm trống mà chưa biết chữ trước con trỏ (sau kích hoạt, Return, ⌫ hết từ, mũi tên, ⌃C) làm một lần đọc D20 (`addMarks`). App trả `{0,0}`, nên `tracker.anchor(at: 0)`: Dấu coi con trỏ ở đầu tài liệu. Vì vị trí là 0, `text(in:)` không bao giờ được gọi nên `readUnavailable` không bật.
- Ở phím có thay chữ, vị trí app trả (0) khác vị trí Dấu theo dõi (`known`):
  - `known ≤ 2`: `rebuild` hoặc nhánh `lateGuess` (D11 (Kiểm tra ngữ cảnh), ý "App trả lời chậm", trường hợp "Không chứng minh được, ở lần thay đầu của một từ") coi app là chậm, Dấu nuốt phím và gọi `insertText` có vùng thay;
  - phím dồn dưới 50 ms: `rebuild` xét thêm các thao tác của loạt phím dồn, nhánh `typedHere` chấp nhận cả từ dài hơn;
  - còn lại: `plan` báo `.mismatch` (0 nhỏ hơn số chữ cần xoá), dựng lại ở vị trí 0 không có từ, reset, phím đi thẳng như chữ gốc.
- Nếu app trả `{NSNotFound, …}` như Apple quy định cho client không có vùng chọn, Dấu sẽ vào nhánh `unsupported` và ra chữ gốc, không nhân đôi [Mã Dấu `CursorTracker.plan`].
- Ghostty: phần thay bị nối vào sau. Terminal của Claude: `keydown` của xterm vẫn gửi phím gốc (chữ thường, chữ số, dấu câu) dù Dấu đã nuốt phím, phần thay bị bỏ; chữ hoa A–Z đi đường `keypress` nên phím hoa bị nuốt thì mất hẳn [Mã xterm.js `_keyDown`, `_keyPress`; Mã Chromium `keyEvent:`].
- Ghostty, ca hiếm: khi Dấu chốt D32 (Backspace) hay khôi phục D4 (Từ nước ngoài) bằng `insertText` rồi để phím đi tiếp, bộ mã hoá phím không gửi gì cho ⌫ có kèm chữ, và với Return thì gửi phần chữ thay cho Enter [Mã Ghostty `key_encode.zig`, hàm `legacy`]. Chỉ xảy ra khi lần thay đó đi nhánh app chậm.

## 3. Dự đoán theo chuỗi phím (thay tại chỗ)

Gõ ở dấu nhắc zsh, ngay sau Return.

| Phím | Ghostty, nhịp ≥ 50 ms | Ghostty, phím dồn < 50 ms | Terminal của Claude | Terminal của Apple |
|---|---|---|---|---|
| `dd` | "dđ" | "dđ" | "dd" | "đ" |
| `toois` | "toôis" | "toôiối" | "toois" | "tối" |
| `vieetj` | "vieetj" | "vieêtệt" (đuôi tuỳ số chữ engine xoá) | "vieetj" | "việt" |
| `viet` + `j` | "vietj" | đuôi bị nhân đôi, kiểu "vietẹt" | "vietj" | "vietj" (D20: "viẹt" không hợp lệ) |
| `w` (đầu từ) | "ư" (chèn tại con trỏ, không xoá) | "ư" | "w" (Blink bỏ sự kiện Char sau `keydown` đã bị chặn; nếu không bỏ thì "wư") [Suy luận, cần kiểm chứng] | "ư" |
| `DD` | "DĐ" | "DĐ" | "DD" hoặc "D", không bao giờ "Đ" | "Đ" |
| `ba` ␣ ⌫ (nghỉ) `j` ␣ (D20) | "baj " | như cột trái | "baj " | "baj " (⌫ không tới bộ gõ) |
| `hoaf` ⌫ ␣ (D32) | "hoa " (từ đã ra chữ gốc từ trước) | — | "hoa " | "ho " (`docs/ARCHITECTURE.md`) |

## 4. Chế độ gạch chân: thao tác sửa

Theo [Mã Dấu] `MarkedComposer`. Telex của Apple ở các ca này: không tìm thấy nguồn, phải đo cùng ô.

| Thao tác | Dấu làm gì | Người dùng thấy | Vì sao "tệ" |
|---|---|---|---|
| ⌫ trong từ đang gạch chân | `engine.backspace` (D32), `setMarkedText` chữ ngắn hơn | "hoà" ⌫ → "hò", vẫn gạch chân | Ổn theo mã |
| ⌫ khi không còn gạch chân | Phím đi thẳng; engine rỗng; không có D20 (D20, mục Phạm vi) | App xoá một ký tự; phím dấu sau đó bắt đầu từ mới: "ba␣⌫j␣" → "baj " (thay tại chỗ ra "bạ ") | Không quay lại sửa được từ đã chốt |
| Mũi tên, bấm chuột giữa từ | Chốt chữ đang hiện, phím/click tới app | "tooi" ← `s` → "tôsi" (thay tại chỗ, theo D20: "tối") | Không đặt dấu được sau khi di chuyển con trỏ |
| Đổi dấu, gõ lại dấu (D26 (Gõ đúp phím dấu)) | Như thay tại chỗ | Đúng | — |
| D4 khôi phục | Từ hiện dạng Telex dở khi đang gạch chân ("ưindows"), chốt mới về "windows" | Chữ gạch chân lạ rồi đổi | Như thay tại chỗ |
| Return, Tab, Esc, ⌃C khi đang gạch chân | `insertText` từ, trả false | Phần lớn app đúng; **Ghostty nuốt phím** | Lỗi của Ghostty (mục 1) |

Quan sát đã xác nhận (10/11/2026, theo phản hồi khi dùng hằng ngày, chưa đo bằng script): ở Sublime Text bật gạch chân, không thêm hay sửa dấu được cho từ đã gõ. Khớp hai dòng "⌫ khi không còn gạch chân" và "Mũi tên, bấm chuột giữa từ". Sublime Text là app tự vẽ chữ; nó trả được vị trí con trỏ (đã đo chi phí `selectedRange` ở M2, mục "Câu hỏi đã trả lời" của `docs/DECISIONS.md`), nhưng thay tại chỗ có D20 trong Sublime chưa đo.

## 5. Bộ gõ khác

- VietTelex (bộ gõ IMK): README ghi phải cấp quyền Accessibility mới gõ được trong Terminal, iTerm, Chrome/Edge/Brave, và nhắc "dấu Backspace của tap", tức gửi Backspace giả qua event tap ở các app đó [Ngoài: https://github.com/ptrinh/viettelex].
- OpenKey: Backspace giả qua event tap [Mã Dấu: `docs/research/OPENKEY-NOTES.md`]. goxkey bắt buộc quyền Accessibility [Ngoài: https://github.com/huytd/goxkey]; cơ chế chi tiết không có trong phần README đã đọc.
- Bộ gõ tiếng Việt của Apple dùng marked text; một PR (không merge) tả bộ gõ tiếng Việt trong Ghostty giữ từ gạch chân tới ký tự ngắt từ [Ngoài: https://github.com/ghostty-org/ghostty/pull/12976].
- Chương trình chạy trong terminal cũng có lỗi riêng: Claude Code (giao diện Ink) làm rơi chữ với bộ gõ Backspace giả [Ngoài: https://github.com/anthropics/claude-code/issues/22853]; lỗi Backspace của IME trong Ghostty: https://github.com/ghostty-org/ghostty/issues/7225.
- Không tìm thấy issue nào của Ghostty về `replacementRange` hay IME tiếng Việt trên macOS (tìm 10/11/2026).

## 6. Giả thuyết và chuỗi phân biệt

Gõ ở dấu nhắc zsh (không chạy Claude Code), nhịp ≥ 100 ms; đối chứng Telex của Apple cùng ô, chuyển nguồn bằng phím tắt hệ thống.

Phản hồi 2 (thay tại chỗ trong terminal):
- **H2a** app bỏ qua `replacementRange`, trả `{0,0}`, Dấu tưởng app chậm và thay "thành công": Ghostty `dd` → "dđ", `toois` → "toôis"; Claude `dd` → "dd".
- **H2b** Dấu thấy lệch, reset, phím đi thẳng: ra đúng chuỗi phím (`toois` → "toois") ở cả hai. Theo mã H2a và H2b cùng xảy ra; ô `dd`/`toois` sau Return thấy H2a, ô `vieetj` thấy H2b.
- **H2c** (Claude) `keydown` của xterm gửi phím gốc dù Dấu nuốt phím: `w` → "w" ở Claude, "ư" ở Ghostty; `W` → "Ư" ở cả hai.
- **H2d** lỗi do chương trình bên trong (Claude Code) chứ không do Dấu: zsh đúng mà Claude Code sai. Theo mã zsh cũng sai; kiểm bằng cùng chuỗi ở zsh và trong `claude`.
- **H2e** Ghostty còn vùng bôi đen bằng chuột: mọi phím thay đều nối thêm chữ. Ghostty mặc định bỏ bôi đen khi gõ (`selection-clear-on-typing`), nên chỉ ảnh hưởng phím đầu.

Phản hồi 1 (gạch chân):
- **H1a** thiếu D20 ở gạch chân. Đã khớp với quan sát ở Sublime Text (mục 4). Ô phân biệt: `ba` ␣ ⌫ `j` ␣ và `tooi` ← `s`, gạch chân và thay tại chỗ: dự đoán "baj ", "tôsi" và "bạ ", "tối".
- **H1b** app nuốt phím sau khi chốt: gạch chân ở Ghostty, `ls` Return: hiện "ls", lệnh chưa chạy; Telex của Apple cùng ô cũng bị (lỗi của Ghostty).
- **H1c** app vẽ marked text sai (Terminal ở 0 ms): chỉ thấy khi phím dồn, không ưu tiên.
- **H1d** khác Telex của Apple ở ⌫ quay về từ đã chốt: không có nguồn; ô `ba` ␣ ⌫ `j` với Telex của Apple trả lời.

## 7. Hướng sửa có thể

Mỗi hướng ghi quyết định nó đụng tới; không hướng nào đã được chọn.
- **H2a, hướng 1:** không neo vị trí 0 khi app trả `{0,0}` mà chưa đọc được chữ nào; bỏ `lateGuess`/`rebuild` khi phần app trả là rỗng ở vị trí 0. Hết nhân đôi chữ, nhưng chữ vẫn ra chuỗi phím gốc. Đụng D11 (ý "App trả lời chậm") và D20 (lần đọc khi bộ đệm trống).
- **H2a–H2c, hướng 2:** tự dùng marked text cho client không thay theo `replacementRange` (nhận ra qua `selectedRange` đứng yên ở 0 dù Dấu đã gõ). Đụng D13 và D5 (Quy tắc theo ứng dụng). Ở xterm.js đây là đường duy nhất chạy được; ở Ghostty dính H1b.
- **H2a, hướng 3 (Ghostty):** gửi lệnh xoá dưới dạng ký tự DEL 0x7F trong chuỗi `insertText`. Thực chất là Backspace giả ở tầng pty; mục "Đã cân nhắc và loại bỏ" của `docs/DECISIONS.md` đã loại "event tap + Backspace giả". Hỏng trong vim, giao diện TUI; ở xterm.js chưa rõ [Suy luận, cần kiểm chứng].
- **H2, hướng 4:** không sửa; ghi Ghostty và terminal xterm.js là không tương thích với thay tại chỗ trong `docs/COMPATIBILITY.md` và danh sách tương thích, theo N5 (Chỉ hứa điều đã kiểm chứng).
- **H1a:** cho D20 chạy ở gạch chân: đọc từ trước con trỏ (sau 50 ms như D20) rồi `setMarkedText(…, replacementRange: vùng của từ)` để đánh dấu lại từ đó. Đụng D20 (mục Phạm vi), N3 (Ít lời gọi vào ứng dụng đích) và D13. Nhớ từ vừa chốt thay vì đọc thì đụng câu "Không giữ lịch sử từ" của D20. Không dùng được ở Ghostty (`setMarkedText` bỏ qua `replacementRange`). Với Sublime Text, hướng khác không đụng quyết định: đo thay tại chỗ (có D20) trong Sublime; nếu đúng thì tắt gạch chân cho app đó là đủ.
- **H1b:** chỉ có cách vòng theo từng app (ví dụ chốt kèm "\r"), đụng D5 và D13; hoặc báo lỗi cho Ghostty (PR #15048 có cách sửa, đóng chưa merge).

## 8. Chỗ lệch với tài liệu và quyết định

- `docs/COMPATIBILITY.md` mục 3, hàng Ghostty ghi "như Terminal (suy luận)": theo mã là sai (Ghostty bỏ qua `replacementRange` và trả `{0,0}`; Terminal thay đúng và không chuyển ⌫). Câu khái quát "app áp phím bất đồng bộ (Chromium, Electron, terminal)" ở `docs/ARCHITECTURE.md` và `docs/COMPATIBILITY.md` mục 6.2 không đúng với Ghostty và xterm.js: đây là bỏ qua vùng thay, không phải trả lời chậm. Chưa sửa ở hai file đó.
- D11, trường hợp "Không chứng minh được, ở lần thay đầu của một từ… vẫn thay ở vị trí Dấu theo dõi", cộng với việc D20 neo ở vị trí app trả, gây nhân đôi chữ với app trả `{0,0}`; D11 không xét ca này.
- Phản hồi 1 phần lớn là do D20 (mục Phạm vi) cố ý tắt D20 ở gạch chân.
- D13 coi gõ sai ở một app là lỗi của Dấu cần sửa và gạch chân chỉ là đường lui; với Ghostty và terminal xterm.js, thay tại chỗ không có đường sửa nào trong IMK mà không đụng một quyết định khác (mục 7).
