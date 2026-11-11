# Gõ trong terminal (Ghostty, xterm.js) và sửa chữ ở chế độ gạch chân

Vì sao thay tại chỗ hỏng trong Ghostty và terminal dựng bằng xterm.js, và vì sao chế độ gạch chân không sửa được dấu cho từ đã gõ. Cơ chế đọc từ mã nguồn, kết quả đo bằng lượt gõ thử có đối chứng Telex của Apple. Quyết định rút ra là D43 (Ô bỏ qua vùng thay chữ); file này không chép lại nó.

## Hiện trạng (11/11/2026)

- **Ghostty: D43 chạy.** Ghostty bỏ qua `replacementRange` và báo vị trí con trỏ luôn `{0,0}`. Dấu nhận ra ô này sau vài phím có thay chữ (ở lượt đo: trong từ thứ hai), rồi gửi ký tự xoá sau khi Ghostty xử lý xong phím. Từ thứ hai trở đi đúng, ở zsh và vim; từ đầu tiên còn sai vì lúc đó chưa nhận ra (mục 1).
- **xterm.js: chờ chẩn đoán.** Gửi ký tự xoá trong lúc xử lý phím đúng khi bật từ đầu, nhưng sai nặng hơn cách cũ khi bật giữa chừng (chữ dồn lại mỗi lần sửa). D43 vì vậy giữ cách thay tại chỗ cũ ở ô kiểu xterm.js, vẫn sai như trước, tới khi chẩn đoán xong (mục 2).
- **Terminal trong app Claude chưa đo** (không tự động hoá được). Theo mã, nó dùng xterm.js trong Electron nên cùng cơ chế với trang thử.
- **Gạch chân không sửa được dấu cho từ đã chốt** (⌫ về từ cũ, ← vào giữa từ), giống Telex của Apple. Trong Sublime Text, thay tại chỗ sửa được cả ba ca, nên tắt gạch chân cho Sublime là đủ; không quyết định nào phải đổi (mục 3).
- **Ghostty nuốt Return ngay sau từ gạch chân**, cả với Telex của Apple: lỗi của Ghostty (mục 1).

## 1. Ghostty

Cơ chế (mã Ghostty 1.4.0):
- `insertText(_:replacementRange:)` bỏ qua tham số vùng thay, gửi chuỗi xuống pty như phím gõ.
- `selectedRange` trả `{0,0}` khi không bôi đen; có bôi đen thì trả vùng bôi đen trên màn hình. Apple quy định `{NSNotFound, 0}` khi không có vùng chọn.
- `attributedSubstring` trả chữ đang bôi đen bất kể vùng hỏi, không bôi đen thì không trả gì. Vì vậy lần đọc kiểm chứng của D43 không bác được Ghostty.
- Chữ bộ gõ đưa **trong lúc** Ghostty xử lý phím mà bắt đầu bằng ký tự điều khiển bị bỏ (`String.keyEventText`). Chữ đưa **sau** đó đi đường khác (`committedTextAction`) và giữ nguyên DEL.
- Sau khi chốt chữ gạch chân, Ghostty chỉ gửi lại ↑ ↓ → (và ← có phím bổ trợ); Return, Tab, Esc, ← thường, ⌃C bị nuốt (`shouldReplayCommittedPreeditKey`). PR #15048 và #14272 tả đúng lỗi này với IME tiếng Hàn, đã đóng, chưa merge.

Trước khi nhận ra ô, Dấu thấy vị trí 0 khác vị trí nó tự theo dõi (`CursorTracker`): vài chữ đầu thì coi app là chậm (D11 (Kiểm tra ngữ cảnh), ý "App trả lời chậm", nhánh `lateGuess`) và thay có vùng thay, nên phần thay bị nối thêm; dài hơn thì `plan` báo `.mismatch`, phím đi thẳng như chữ gốc.

Kết quả (zsh, 120 ms giữa hai phím, một lượt mỗi ô; Telex của Apple ra đúng ở mọi ô):

| Cách | `dd` | `toois` | `vieetj` | Dòng `toois vieetj ddi hocj nhaf nguwowif hoaf⌫ windows ` |
|---|---|---|---|---|
| Thay tại chỗ, trước D43 | "dđ" | "toôis" | "vieetj" | — |
| Ký tự xoá gửi trong phím (bản thử) | "d" | "toi" | "viet" | mọi lần thay có DEL đều mất |
| Ký tự xoá gửi sau phím (bản thử) | "đ" | "tối" | "việt" | đúng, cả ở 30 ms và trong vim |
| D43 | — | — | — | "toôis việt đi học nhà người hò windows ": từ đầu sai, còn lại đúng; zsh và vim |

- D43 ở 30 ms giữa hai phím: không nhận ra (phím dồn không được xét), dòng ra như trước D43.
- Thời gian xử lý mỗi phím của D43 ngang thay tại chỗ thường; số ở nhật ký [`docs/Progress.md`](../Progress.md) ngày 11/11.
- Gạch chân trong Ghostty: chữ đúng, nhưng `toois vieetj↩` không gửi Return (byte gửi không có `<0d>`), với cả Dấu và Telex của Apple.
- Gạch chân không thuộc tính gạch không giúp: Ghostty tự vẽ gạch chân cho chữ đang soạn.

## 2. Terminal dựng bằng xterm.js (trang thử và app Claude)

Cơ chế (mã Chromium và xterm.js):
- Chromium gửi `insertText` có vùng thay thành `ImeCommitText(text, range)`; Blink chọn vùng đó trong textarea ẩn của xterm rồi chèn, sự kiện `input` chỉ mang chữ mới, không có lệnh xoá.
- Textarea gần như luôn rỗng vì xterm gửi phím thường ngay ở `keydown` rồi chặn mặc định (`_keyDown`), nên vị trí con trỏ thường là 0, đôi khi 1–2. Đo được: dao động 0–2 dù đã gõ nhiều chữ hơn.
- Phím chữ hoa A–Z đi đường `keypress` (`_keyPress`).

Kết quả trên trang thử (xterm.js 5.5.0 trong Chrome, 120 ms, một lượt mỗi ô; Telex của Apple ra đúng):

| Cách | `toois vieetj dd ` |
|---|---|
| Thay tại chỗ, trước D43 | "toôoiís vieêetj dđd ": phím gốc và chữ thay đều tới shell |
| Ký tự xoá gửi trong phím, bật từ đầu (bản thử) | "tối việt đ " |
| D43 gửi trong phím, sau khi nhận ra (lượt thứ tư) | sai nặng hơn: mỗi lần sửa gửi lại các lần sửa trước cộng một chữ "ê" thừa |
| D43 hiện nay | như trước D43 (ghi log `range-ignored`, không gửi ký tự xoá) |

- Giả thuyết cho lượt thứ tư: lần thay có vùng thay ngay trước lúc nhận ra (`sel=2,0`) để lại chữ và trạng thái soạn chữ trong textarea, nên các lần chèn sau đó xterm.js gửi cả textarea. Chưa kiểm: chưa đọc `CompositionHelper` cho ca này.
- Việc tiếp theo: chẩn đoán giả thuyết trên, rồi bật lại cách gửi trong phím; thử tay trong app Claude sau khi sửa.

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
- App Claude chưa đo; bản xterm.js trong app cũ hơn trang thử.
- Chưa đo: Ghostty khi còn vùng bôi đen bằng chuột (Ghostty mặc định bỏ bôi đen khi gõ, `selection-clear-on-typing`, nên theo mã chỉ ảnh hưởng phím đầu); Claude Code chạy trong terminal (chỉ đo ở dấu nhắc zsh và vim).
- Chương trình không coi DEL là lệnh xoá (vim ở chế độ lệnh, less) nhận ký tự đó như phím thường (theo mã, chưa đo; giới hạn đã ghi ở D43).

## Phương pháp và bản mã đã đọc

- Chuỗi phím và đáp án: [`scripts/research/terminal-underline/run.sh`](../../scripts/research/terminal-underline/run.sh) (gọi `scripts/selftest/typing/run.sh` cho từng ô; đáp án là chữ đúng theo luật Telex, không phải chữ dự đoán). Số đo từng lượt: nhật ký [`docs/Progress.md`](../Progress.md) ngày 11/11/2026.
- Đối chứng: Telex của Apple trong cùng ô. Byte gửi cho shell đọc ở Ghostty, dữ liệu xterm.js gửi đọc ở trang thử.
- Bản đã đọc (bản sao tạm ngoài repo, không chép mã nào vào Dấu, D10 (Engine tự viết)):
  - Ghostty: nhánh main, commit de70b9f476c39ce3f5b293ecba813b674f037a80 (10/11/2026), đã so với tag v1.4.0: SurfaceView_AppKit.swift (vùng IME) và src/input/key_encode.zig giống hệt. https://github.com/ghostty-org/ghostty
  - Claude.app 4.23118.1 (`com.anthropic.claudefordesktop`): chỉ grep và cắt byte trong `ion-dist.asar` của bundle, không giải nén.
  - Chromium: nhánh main, tải ngày 10/11/2026: content/app_shim_remote_cocoa/render_widget_host_view_cocoa.mm, third_party/blink/renderer/core/editing/ime/input_method_controller.cc, third_party/blink/renderer/core/exported/web_input_method_controller_impl.cc, third_party/blink/renderer/core/editing/commands/typing_command.cc, third_party/blink/renderer/core/editing/editing_utilities.cc. https://chromium.googlesource.com/chromium/src/
  - xterm.js: master, bản 6.0.0 (src/browser/input/CompositionHelper.ts, src/browser/CoreBrowserTerminal.ts). https://github.com/xtermjs/xterm.js
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
| Thay theo `replacementRange` | không | không (vùng thay rơi ngoài textarea rỗng) | có, khi phím cách nhau từ 20 ms |
| Vị trí con trỏ | luôn `{0,0}` khi không bôi đen | của textarea ẩn: 0–2 | có, là ảnh chụp cũ khi phím dồn |
| Đọc chữ trước con trỏ | chỉ chữ đang bôi đen | chữ trong textarea, thường rỗng | có (D20 chạy, trừ sau ⌫) |
| ⌫ tới bộ gõ | có (`keyDown` luôn gọi `interpretKeyEvents`) | có | không |
| Phím không tới bộ gõ | phím tắt menu của Ghostty; bấm chuột (`mouseDown` không gọi `handleEvent`, kết luận về Dấu: suy luận, cần kiểm chứng) | phím có ⌘ | ⌫ |
| Marked text | có, vẽ đè tại con trỏ; `setMarkedText` bỏ qua vùng thay; nuốt Return, Tab, Esc sau khi chốt | có, qua `compositionstart/update/end`; Return sau khi chốt được gửi lại sau phần chữ | có; ở 0 ms còn vẽ marked text cũ |
