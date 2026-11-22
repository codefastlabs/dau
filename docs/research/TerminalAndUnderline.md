# Gõ trong terminal (Ghostty, xterm.js) và sửa chữ ở chế độ gạch chân

Vì sao thay tại chỗ hỏng trong Ghostty và terminal dựng bằng xterm.js, và vì sao chế độ gạch chân không sửa được dấu cho từ đã gõ. Cơ chế đọc từ mã nguồn, kết quả đo bằng lượt gõ thử có đối chứng Telex của Apple. Quyết định rút ra là D43 (Ô bỏ qua vùng thay chữ); file này không chép lại nó.

## Hiện trạng (12/11/2026, soát lại 22/11/2026)

- **Dấu không xử lý riêng terminal bỏ qua vùng thay (D43, 12/11/2026).** Ở Ghostty và terminal dựng bằng xterm.js, Dấu thay tại chỗ như mọi ô nên chữ ra sai; cách gõ đúng là gạch chân, người dùng tự bật theo app. Ghostty mang nhãn "Đề xuất" (D13). Cách gửi ký tự xoá đã thử ([`docs/history/ResearchLog.md`](../history/ResearchLog.md) mục 4) cùng mã và mô hình của nó (`RangeIgnoreDetector`, `WebHost`, `FakeXtermPage`, `SharedViewTests`) đã bỏ; còn trong git ở commit d916a0d.
- **Gạch chân đúng ở cả hai loại terminal:** Ghostty (zsh, vim; mục 1) và terminal tích hợp của VS Code, kể cả trình soạn thảo cùng cửa sổ khi chuyển ô (mục 2, cuối phần đo trên VS Code). Telex của Apple, cũng là gạch chân, đúng ở cả hai.
- **Vì sao bỏ cách gửi ký tự xoá:** ở Ghostty nó chỉ đúng từ từ thứ hai, thứ ba sau mỗi lần chuyển vào app; lệnh thật thường ngắn, nên trong shell thật dùng hằng ngày gần như luôn sai ([`docs/history/ResearchLog.md`](../history/ResearchLog.md) mục 4). Ở xterm.js nó không bật được vì ký tự xoá lọt vào trình soạn thảo cùng view (cùng mục đó). Tất cả tốn khoảng 2 600 dòng mã và test.
- **Ghostty nuốt Return ngay sau từ gạch chân**, cả với Telex của Apple: lỗi của Ghostty (mục 1).
- **Gạch chân không sửa được dấu cho từ đã chốt** (⌫ về từ cũ, ← vào giữa từ), giống Telex của Apple. Bật gạch chân cho app mà terminal chỉ là một ô (VS Code, Cursor, app Claude) thì mọi ô của app đó mất D20 (mục 3); vì vậy các app này không mang nhãn vì terminal.
- **Terminal trong app Claude chưa đo.** Theo bundle Claude.app 5.1231.2 (đọc 12/11/2026; bản hiện có 5.11492.5, cùng Electron và Chromium), terminal dùng xterm.js 5.x trong Electron 45.2.1 (Chromium 156) với cùng logic nhập liệu như mục 2. Không đo tự động được: app Claude là nơi chạy phiên điều phối.

## 1. Ghostty

Cơ chế (mã Ghostty 1.4.0):
- `insertText(_:replacementRange:)` bỏ qua tham số vùng thay, gửi chuỗi xuống pty như phím gõ.
- `selectedRange` trả `{0,0}` khi không bôi đen; có bôi đen thì trả vùng bôi đen trên màn hình. Apple quy định `{NSNotFound, 0}` khi không có vùng chọn.
- `attributedSubstring` trả chữ đang bôi đen bất kể vùng hỏi, không bôi đen thì không trả gì. Vì vậy lần đọc kiểm chứng của D43 cũ không bác được Ghostty.
- Chữ bộ gõ đưa **trong lúc** Ghostty xử lý phím mà bắt đầu bằng ký tự điều khiển bị bỏ (`String.keyEventText`). Chữ đưa **sau** đó đi đường khác (`committedTextAction`) và giữ nguyên DEL.
- Sau khi chốt chữ gạch chân, Ghostty chỉ gửi lại ↑ ↓ → (và ← có phím bổ trợ); Return, Tab, Esc, ← thường, ⌃C bị nuốt (`shouldReplayCommittedPreeditKey`). PR #15048 và #14272 tả đúng lỗi này với IME tiếng Hàn, đã đóng, chưa merge.

Dấu không nhận ra riêng ô này (D43), nên thấy vị trí 0 khác vị trí nó tự theo dõi (`CursorTracker`): vài chữ đầu thì coi app là chậm (D11 (Kiểm tra ngữ cảnh), ý "App trả lời chậm", nhánh `lateGuess`) và thay có vùng thay, nên phần thay bị nối thêm; dài hơn thì `plan` báo `.mismatch`, phím đi thẳng như chữ gốc.

Thay tại chỗ sai ở Ghostty từ phím đầu ("toois" ra "toôis", "dd" ra "dđ"; zsh, 120 ms, 12/11/2026, trước khi Dấu tự chèn ký tự). Các cách gửi ký tự xoá đã thử và lượt đo trong shell thật ở [`docs/history/ResearchLog.md`](../history/ResearchLog.md) mục 4.

- Gạch chân trong Ghostty: chữ đúng, nhưng `toois vieetj↩` không gửi Return (byte gửi không có `<0d>`), với cả Dấu và Telex của Apple.
- Gạch chân không thuộc tính gạch không giúp: Ghostty tự vẽ gạch chân cho chữ đang soạn.

Gạch chân, sau khi bỏ D43 cũ (12/11/2026, cùng script và ba dòng; cửa sổ Ghostty mới, cùng cấu hình zsh; Dấu Debug 9590ff3, gạch chân ép cho Ghostty bằng khoá Debug như khi người dùng bật theo D13; một lượt): Dấu ra đúng cả ba dòng ngay từ từ đầu, "tôi dùng windows để hò hát với bạn ", "đường đẹp vui vẻ ", "hôm nay tôi đi học "; Telex của Apple ra như lượt trên. Return ở đây đi sau dấu cách, nên không gặp lỗi Ghostty nuốt Return sau từ đang gạch chân.

## 2. Terminal dựng bằng xterm.js (trang thử và app Claude)

Cơ chế (mã Chromium nhánh main ngày 12/11/2026 và xterm.js 5.5.0, bản trang thử nạp):

- **Chromium** (`RenderWidgetHostViewCocoa`):
  - `insertText` có vùng thay gửi ngay `ImeCommitText(text, range)` cho trang. `insertText` không vùng thay trong lúc xử lý phím chỉ được gom lại (`_textToBeInserted`).
  - Sau `interpretKeyEvents`, gom được hơn một đơn vị thì trang nhận keydown mã 229 (`VKEY_PROCESSKEY`) rồi `ImeCommitText` của phần đã gom. Gom được một đơn vị hoặc không gì: trang nhận keydown thật của phím, rồi keypress mang đơn vị đó. Phím bộ gõ để đi (Delete, Return) còn sinh lệnh soạn thảo: sau phần chữ, trang nhận thêm keydown thật của phím.
  - `selectedRange` và `attributedSubstring` trả từ bộ đệm (`_textSelectionRange`, `_availableText`), trang chỉ cập nhật khi chữ hay vùng chọn của nó đổi. Sau mỗi `insertText` không vùng thay, Chromium tự đặt con trỏ trong bộ đệm ở `_markedRange.location` cộng độ dài chữ (cắt về `int`), và chèn chữ vào bộ đệm ở `_markedRange.location`. `_markedRange` chỉ đổi khi có marked text, nên câu trả lời phụ thuộc lịch sử của view. Đây là một nguồn của dao động 0–2 đo được ở trang thử; con số từng lần chưa dựng lại được (bên dưới).
- **Blink:**
  - Chữ có vùng thay đi `ReplaceTextAndKeepSelection`: chọn vùng, chèn, rồi đặt lại con trỏ cũ. Con trỏ cũ đứng trước cuối vùng thì giữ nguyên chỗ, nên chữ vừa thay nằm **sau** con trỏ. Vùng bắt đầu sau hết chữ thì bỏ (textarea rỗng có một `<br>` giữ chỗ).
  - Chữ không vùng thay đi `InsertTextAndMoveCaret`: chèn ở con trỏ, con trỏ ra sau.
  - Mỗi lần chèn phát sự kiện `input` (`composed` luôn đúng). Keydown bị chặn mặc định thì keypress của nó bị bỏ; keypress không bị chặn thì chữ của nó vào textarea ở con trỏ.
- **xterm.js:**
  - `_keyDown` gửi ngay chữ thường, số, dấu câu (mã phím từ 48, một ký tự) rồi chặn mặc định, nên textarea gần như rỗng. Chữ hoa A–Z và phím cách không có `result.key` ở đây, đi tiếp sang `_keyPress`; `_keyPress` gửi chữ mà không chặn mặc định (`cancelEvents` mặc định tắt), nên chữ đó cũng vào textarea.
  - `_inputEvent` chỉ gửi chữ tới giữa keyup và keydown kế (`!ev.composed || !this._keyDownSeen`): chữ có vùng thay tới trước keydown của chính phím đó, nên tới shell, rồi keydown thật gửi thêm phím gốc. Đây là "phím gốc và chữ thay đều tới shell" của cách cũ.
  - Keydown 229 khi không soạn chữ đi `CompositionHelper._handleAnyTextareaChanges`: nhớ giá trị textarea, sau `setTimeout(0)` gửi `newValue.replace(oldValue, '')`. Phép trừ này chỉ đúng khi chữ mới chèn ở cuối (hoặc đầu) giá trị cũ. Chèn ở giữa thì giá trị cũ không còn là một đoạn liền của giá trị mới, và xterm.js gửi **cả textarea**.
  - Textarea chỉ được làm rỗng khi Return, ⌃C, hay mất focus.

Thay tại chỗ sai ở trang thử (xterm.js 5.5.0 trong Chrome) và ở terminal tích hợp của VS Code: phím gốc và chữ thay đều tới shell ("toôoiís vieêetj dđd "; 12/11/2026, 120 ms, một lượt mỗi ô, Telex của Apple ra đúng). Số đo này có từ trước khi Dấu tự chèn ký tự (N3, 22/11/2026) và chưa đo lại; D43 không đổi theo nó, vì gạch chân là cách gõ đúng ở các ô này. Các cách gửi ký tự xoá đã thử, bảng giả thuyết và các lượt đo của chúng ở [`docs/history/ResearchLog.md`](../history/ResearchLog.md) mục 4.

Gạch chân trong VS Code (12/11/2026, bộ gõ Debug 2122e53, 120 ms, một lượt mỗi ô; `scripts/research/terminal-underline/run.sh 't6-*'`; cùng chuỗi phím với lượt xác nhận `WebHost`; gạch chân ép cho cả app, như khi người dùng bật theo D13):

- Terminal tích hợp: đúng cả hai dòng, "tôi dùng windows để hò hát với bạn ↩đường đẹp vui vẻ ". Byte gửi cho shell chỉ có chữ đã chốt và Return, không có phím gốc hay chữ lặp. Từ tiếng Anh (D4) và ⌫ giữa từ (D32) cũng đúng; Telex của Apple cùng ô khác ở hai chỗ này ("ưindows", "ho").
- Chuyển ô: terminal đúng, rồi trình soạn thảo cùng cửa sổ đúng "hôm nay đường đẹp vui vẻ ". Trong trình soạn thảo, gạch chân mất D20 (mục 3); chuỗi phím này không có ca D20 nên không đo cái giá đó.
- Log: mọi phím có chữ đi đường đánh dấu chữ (63 phím đánh dấu, 13 lần chốt), không có `range-ignored`: gạch chân không dùng vùng thay nên không cần nhận ra ô.

## 3. Gạch chân khi sửa chữ

Theo `MarkedComposer`, ở chế độ gạch chân:

| Thao tác | Dấu làm gì | Người dùng thấy |
|---|---|---|
| ⌫ trong từ đang gạch chân | xoá theo D32 (Backspace) trong engine, gạch chân chữ ngắn hơn | "hoà" ⌫ → "hò", vẫn gạch chân |
| ⌫ khi không còn gạch chân | phím đi thẳng, bộ đệm rỗng; D20 (Thêm dấu cho từ đã gõ) không chạy ở gạch chân (D20, mục Phạm vi) | phím dấu sau đó bắt đầu từ mới: "ba␣⌫j␣" → "baj " |
| Mũi tên, bấm chuột giữa từ | chốt chữ đang hiện, phím tới app | "tooi" ← `s` → "tôsi" |
| Đổi dấu, gõ lại dấu (D26 (Gõ đúp phím dấu)) | như thay tại chỗ | đúng |
| Khôi phục D4 (Từ nước ngoài) | từ hiện dạng Telex dở khi đang gạch chân ("ưindows"), chốt mới về "windows" | chữ gạch chân lạ rồi đổi |
| Return, Tab, Esc, ⌃C khi đang gạch chân | chốt từ, phím đi tiếp | đúng ở phần lớn app; Ghostty nuốt phím (mục 1) |

Đo ở Sublime Text, `tooisf ba ⌫j tooi←s` (đổi dấu, ⌫ về từ đã chốt rồi thêm dấu, ← vào giữa từ rồi thêm dấu), 120 ms:

| Bộ gõ, chế độ | Chữ ra |
|---|---|
| Dấu, thay tại chỗ | "tồi bạ tối" (đúng cả ba) |
| Dấu, gạch chân | "tồi baj tôsi" |
| Telex của Apple | "tồi baj tôsi" |

Sublime Text tự vẽ chữ nhưng trả đúng vị trí con trỏ và chữ trước con trỏ, nên D20 chạy khi thay tại chỗ.

## 4. Bộ gõ khác

- VietTelex (bộ gõ IMK): README ghi phải cấp quyền Accessibility mới gõ được trong Terminal, iTerm, Chrome/Edge/Brave, và nhắc "dấu Backspace của tap", tức Backspace giả qua event tap. https://github.com/ptrinh/viettelex
- OpenKey: Backspace giả qua event tap ([`docs/research/OpenKeyNotes.md`](OpenKeyNotes.md)). goxkey bắt buộc quyền Accessibility (https://github.com/huytd/goxkey); cơ chế chi tiết không có trong phần README đã đọc.
- Bộ gõ tiếng Việt của Apple dùng marked text; một PR không merge tả bộ gõ đó trong Ghostty giữ từ gạch chân tới ký tự ngắt từ: https://github.com/ghostty-org/ghostty/pull/12976
- Chương trình trong terminal cũng có lỗi riêng: Claude Code làm rơi chữ với bộ gõ Backspace giả (https://github.com/anthropics/claude-code/issues/22853); lỗi Backspace của IME trong Ghostty: https://github.com/ghostty-org/ghostty/issues/7225
- Không tìm thấy issue nào của Ghostty về `replacementRange` hay IME tiếng Việt trên macOS (tìm 10/11/2026).

## Giới hạn

- Một máy, một lượt mỗi ô, phím gửi bằng script, 120 ms giữa hai phím (một ô 30 ms). Ghostty 1.4.0, trang thử xterm.js 5.5.0.
- App Claude và Cursor chưa đo; terminal tích hợp của VS Code và việc chuyển ô ở VS Code đo một lượt (mục 2). Bản xterm.js trong app Claude là 5.x, cùng logic nhập liệu như trang thử, nhưng chưa xác định bản cụ thể.
- Script gửi phím tuần tự: nhả phím trước rồi mới nhấn phím sau. Người gõ nhanh hay nhấn phím sau trước khi nhả phím trước. Khi đó `_keyDownSeen` của xterm.js còn đúng lúc chữ có vùng thay tới, nên theo mã `_inputEvent` bỏ chữ đó. Chưa mô hình, chưa đo.
- Chưa đo: Ghostty khi còn vùng bôi đen bằng chuột (Ghostty mặc định bỏ bôi đen khi gõ, `selection-clear-on-typing`, nên theo mã chỉ ảnh hưởng phím đầu); Claude Code chạy trong terminal (chỉ đo ở dấu nhắc zsh và vim).

## Phương pháp và bản mã đã đọc

- Chuỗi phím và đáp án: [`scripts/research/terminal-underline/run.sh`](../../scripts/research/terminal-underline/run.sh) (gọi `scripts/selftest/typing/run.sh` cho từng ô; đáp án là chữ đúng theo luật Telex, không phải chữ dự đoán). Số đo từng lượt: nhật ký [`docs/history/LogM6.md`](../history/LogM6.md) ngày 11/11 và 12/11/2026 (lượt 12/11 dùng `scripts/selftest/typing/run.sh xterm` với phím Return trong chuỗi).
- Đối chứng: Telex của Apple trong cùng ô. Byte gửi cho shell đọc ở Ghostty, dữ liệu xterm.js gửi đọc ở trang thử.
- Bản đã đọc (bản sao tạm ngoài repo, không chép mã nào vào Dấu, D10 (Engine tự viết)):
  - Ghostty: nhánh main, commit de70b9f476c39ce3f5b293ecba813b674f037a80 (10/11/2026), đã so với tag v1.4.0: SurfaceView_AppKit.swift (vùng IME) và src/input/key_encode.zig giống hệt. https://github.com/ghostty-org/ghostty
  - Claude.app 4.23118.1 (`com.anthropic.claudefordesktop`): chỉ grep và cắt byte trong `ion-dist.asar` của bundle, không giải nén.
  - Chromium: nhánh main, tải ngày 10/11/2026: content/app_shim_remote_cocoa/render_widget_host_view_cocoa.mm, third_party/blink/renderer/core/editing/ime/input_method_controller.cc, third_party/blink/renderer/core/exported/web_input_method_controller_impl.cc, third_party/blink/renderer/core/editing/commands/typing_command.cc, third_party/blink/renderer/core/editing/editing_utilities.cc. Tải thêm ngày 12/11/2026 (chẩn đoán chữ dồn): third_party/blink/renderer/core/editing/plain_text_range.cc, third_party/blink/renderer/core/html/forms/text_control_element.cc, third_party/blink/renderer/core/events/input_event.cc, third_party/blink/renderer/core/editing/editor.cc, content/renderer/render_frame_impl.cc, content/browser/renderer_host/render_widget_host_view_mac.mm. https://chromium.googlesource.com/chromium/src/
  - xterm.js: master, bản 6.0.0 (src/browser/input/CompositionHelper.ts, src/browser/CoreBrowserTerminal.ts); tag 5.5.0, commit 9ba6c00a195c95fcf8292a2b9084d91450e5daae, bản trang thử nạp (src/browser/Terminal.ts, src/browser/input/CompositionHelper.ts, src/common/input/Keyboard.ts). https://github.com/xtermjs/xterm.js
- Tài liệu Apple:
  - `insertText(_:replacementRange:)`: https://developer.apple.com/documentation/appkit/nstextinputclient/inserttext(_:replacementrange:)
  - `selectedRange()`: "The range of selected text or {NSNotFound, 0} if there is no selection." https://developer.apple.com/documentation/appkit/nstextinputclient/selectedrange()
  - `attributedSubstring(forProposedRange:actualRange:)`: https://developer.apple.com/documentation/appkit/nstextinputclient/attributedsubstring(forproposedrange:actualrange:)
  - `interpretKeyEvents(_:)`: https://developer.apple.com/documentation/appkit/nsresponder/interpretkeyevents(_:)
  - `NSTextInputContext.handleEvent(_:)`: "mouse or key events". https://developer.apple.com/documentation/appkit/nstextinputcontext/handleevent(_:)

## Phụ lục: khả năng nhập liệu theo app

Ghostty và xterm.js theo mã nguồn (kết quả đo ở mục 1, 2); Terminal của Apple theo số đo của Dấu ([`docs/Compatibility.md`](../Compatibility.md)).

| Khả năng | Ghostty 1.4.0 | xterm.js trong Chromium | Terminal của Apple |
|---|---|---|---|
| Thay theo `replacementRange` | không | không: Blink thay trong textarea ẩn, xterm.js gửi shell chữ mới rồi thêm phím gốc | có, khi phím cách nhau từ 20 ms |
| Vị trí con trỏ | luôn `{0,0}` khi không bôi đen | từ bộ đệm của Chromium (textarea ẩn, và phần Chromium tự đặt sau mỗi `insertText`): 0–2 | có, là ảnh chụp cũ khi phím dồn |
| Đọc chữ trước con trỏ | chỉ chữ đang bôi đen | chữ trong textarea, thường rỗng | có (D20 chạy, trừ sau ⌫) |
| ⌫ tới bộ gõ | có (`keyDown` luôn gọi `interpretKeyEvents`) | có | không |
| Phím không tới bộ gõ | phím tắt menu của Ghostty; bấm chuột (`mouseDown` không gọi `handleEvent`, kết luận về Dấu: suy luận, cần kiểm chứng) | phím có ⌘ | ⌫ |
| Marked text | có, vẽ đè tại con trỏ; `setMarkedText` bỏ qua vùng thay; nuốt Return, Tab, Esc sau khi chốt | có, qua `compositionstart/update/end`; Return sau khi chốt được gửi lại sau phần chữ | có; ở 0 ms còn vẽ marked text cũ |
