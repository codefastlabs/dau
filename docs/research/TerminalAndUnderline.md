# Gõ trong terminal (Ghostty, xterm.js) và sửa chữ ở chế độ gạch chân

Vì sao thay tại chỗ hỏng trong Ghostty và terminal dựng bằng xterm.js, và vì sao chế độ gạch chân không sửa được dấu cho từ đã gõ. Cơ chế đọc từ mã nguồn, kết quả đo bằng lượt gõ thử có đối chứng Telex của Apple. Quyết định rút ra là D43 (Ô bỏ qua vùng thay chữ); file này không chép lại nó.

## Hiện trạng (12/11/2026)

- **Ghostty: D43 chạy** (chỉ ở app không chứa nhân web, đọc từ gói app; Ghostty không chứa). Ghostty bỏ qua `replacementRange` và báo vị trí con trỏ luôn `{0,0}`. Dấu nhận ra ô này sau vài phím có thay chữ (một, hai từ đầu sai), rồi gửi ký tự xoá sau khi Ghostty xử lý xong phím. Lượt 11/11/2026 đúng từ từ thứ hai, ở zsh và vim; lượt 12/11/2026 ở bộ gõ chạy sandbox đúng từ từ thứ ba. Từ đầu còn sai vì lúc đó chưa nhận ra (mục 1).
- **xterm.js: Dấu không gửi ký tự xoá, gõ sai như trước D43** (lý do ở ý kế tiếp). Cách gửi trong phím đã được chẩn đoán và đo trước khi tắt (mục 2):
  - Chữ dồn: lần thay có vùng thay trước lúc nhận ra để lại chữ sau con trỏ trong textarea ẩn của xterm.js. Từ đó, mỗi lần gửi ký tự xoá trong phím, xterm.js gửi lại cả textarea.
  - Cách chữa: chỉ gửi trong phím khi không có lần thay có vùng thay nào từ phím Return gần nhất, tức từ dòng sau Return.
  - Đo 12/11/2026 trên trang thử xterm.js (Chrome, bộ gõ Debug f226cc4, 120 ms, một lượt): dòng sau Return ra đúng "tối việt đi học nhà người hò windows ưa ước", mỗi phím một khúc dữ liệu, không lặp lần sửa trước; dòng trước Return sai như dự đoán. Cùng chuỗi phím: Ghostty ra như trước (từ đầu sai, rồi đúng), ô thường của Chrome đúng cả dòng.
- **Terminal và ô soạn thảo trong cùng một view: kết luận "terminal" giữ khi chuyển ô (đã đo trên VS Code).** Ở VS Code, Cursor và có thể cả app Claude, terminal xterm.js và trình soạn thảo là hai phần tử của cùng một trang, tức cùng một client IMK. Đo 12/11/2026 trên VS Code: click từ terminal sang trình soạn thảo không kích hoạt lại bộ gõ (log không có `activate` giữa hai pha). Cách gửi trong phím trước đây sẽ gửi ký tự xoá vào trình soạn thảo (mô hình); vì vậy D43 không gửi ký tự xoá ở kiểu xterm.js, và trình soạn thảo ra đúng, không có ký tự xoá (mục 2, "Chuyển ô trong cùng view").
- **Terminal trong app Claude chưa đo.** Theo bundle Claude.app 5.1231.2 (đọc 12/11/2026), terminal dùng xterm.js 5.x trong Electron 45.2.1 (Chromium 156), và ba hàm nhập liệu `_handleAnyTextareaChanges`, `_inputEvent`, `_keyDown` có cùng logic như mục 2, nên cùng cơ chế với trang thử. Khác trang thử ở ba điểm: app có bộ chặn phím riêng (`attachCustomKeyEventHandler`: ⌃Tab, ⌘ với phím điều hướng, ⌘⇧⌫, ⌘C khi đang bôi đen), có bộ đệm giữ phím khi pty chưa sẵn sàng, và chữ đi vào shell thật. Không đo tự động được: app Claude là nơi chạy phiên điều phối, script gõ phím vào nó sẽ gõ vào chính phiên đó. Thử tay (`docs/Progress.md`, chờ người dùng).
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

Vì sao chữ dồn ở lượt thứ tư:

1. Trước khi nhận ra ô, các lần thay có vùng thay để chữ thay lại sau con trỏ của textarea. Trạng thái mà các khúc dữ liệu đo được buộc phải có ở phím j: textarea " ê", con trỏ ở 1. Tức là lần thay ở chữ e thứ hai của "vieetj" đổi chữ "í" (của lần thay "tối" trước đó) thành "ê" với con trỏ đứng trước; phím cách (đi qua keypress) nằm trước con trỏ.
2. Từ phím j, ký tự xoá gửi trong phím đi qua keydown 229 và chèn ở con trỏ: " ⌫⌫ệtê". Giá trị cũ " ê" không còn liền, nên xterm.js gửi cả chuỗi. Mỗi lần sửa sau cũng chèn ở giữa, nên gửi lại mọi lần sửa trước cộng "ê" ở cuối. Nhật ký 11/11 chép các khúc không có dấu cách đầu ("⌫⌫ệtê"); dòng chữ đo được ("vieêeệtê") chỉ ra được khi khúc bắt đầu bằng một ký tự mà ⌫ đầu tiên xoá đi.
3. Lượt thứ hai đúng vì bật từ phím đầu: không có lần thay có vùng thay nào, con trỏ luôn ở cuối textarea.

Giả thuyết đã xét, dự đoán cho từng quan sát (O1: cách cũ ra "toôoiís vieêetj dđd "; O2: gửi trong phím từ phím đầu ra "tối việt đ "; O3: lượt thứ tư, mỗi lần gửi lặp lại các lần sửa trước cộng "ê"):

| Giả thuyết | O1 | O2 | O3 | Kết luận |
|---|---|---|---|---|
| H1. Chữ còn lại sau con trỏ của textarea, phép trừ của `_handleAnyTextareaChanges` hỏng | khớp | khớp (con trỏ luôn ở cuối) | khớp từng ký tự: " ⌫⌫ệtê", " ⌫⌫ệt ⌫đê", dòng "toôoiís vieêeệtê ệtđêi hoệtọcê" | nguyên nhân |
| H2. Lần thay có vùng thay mở một phiên soạn chữ, `compositionend` gửi phần đuôi textarea | không: `ImeCommitText` không có phiên soạn chữ thì không phát sự kiện `composition*` | khớp | không: phần đuôi tính từ lúc `compositionstart` không gồm chữ đứng trước | loại |
| H3. Mỗi lần sửa gửi hai lần (`_inputEvent` và `_handleAnyTextareaChanges`) | — | không: sẽ ra mỗi lần sửa hai lần | không: lặp cả các lần sửa trước, không phải lần sửa hiện tại | loại |
| H4. Textarea chỉ đầy dần (không bao giờ làm rỗng), con trỏ vẫn ở cuối | — | khớp | không: khi con trỏ ở cuối, phép trừ ra đúng phần mới (test đối chứng) | không đủ |

Mô hình: `FakeXtermPage` (test của bộ gõ) dựng ba lớp trên theo mã, dẫn từng hàm trong comment. Với view mới (`_markedRange` {0,0}), nó cho lại đúng O1 và O2. O3 cho lại đúng từng ký tự khi bắt đầu từ trạng thái textarea mà các khúc dữ liệu đo được buộc phải có (" ê", con trỏ ở 1); cùng phím đó với con trỏ ở cuối thì không dồn (H4). Mô hình chưa cho lại câu trả lời `selectedRange` 2 ở chữ e thứ hai: con số đó phụ thuộc `_markedRange` của view, không đọc được từ dữ liệu đã lưu (chưa rõ).

Cách gửi trong phím (`InPlaceComposer.EraseMode.inKey`; nay `InPlaceComposer.eraseMode(for:)` không bao giờ chọn nó, D43, chỉ test đặt bằng tay để tả trang; phần chờ Return đã bỏ khỏi mã):

- Bản đã đo 12/11 chỉ gửi trong phím khi không có `insertText` có vùng thay nào từ lần Return (hay Enter bàn phím số) gần nhất mà bộ gõ để đi tới app. Return làm xterm.js xoá textarea. Lúc kích hoạt coi như chưa biết. Thường là bắt đầu ở phím Return đầu tiên sau khi nhận ra.
- Delete có sửa dấu (D32 (Backspace)) bị giữ lại và gửi phần sửa không kèm chữ mà Delete sẽ xoá: để Delete đi tiếp thì trang nhận keydown thật sau phần chữ, thứ tự giữa phần sửa và DEL của phím do trang quyết.
- Return và Tab không gửi phần sửa: keydown thật của chúng tới trước khi xterm.js gửi phần sửa. Từ cần khôi phục giữ như đang hiện, như ở Ghostty.
- Một đơn vị chữ khác phím vừa gõ (`w` ra "ư" ở đầu từ) gửi thành chữ, DEL, chữ: một đơn vị đi đường keydown thật, trên đường đó xterm.js gửi phím gốc chứ không gửi chữ.
- Mỗi phím vẫn tối đa một `insertText`, không hỏi vị trí, không đọc chữ; Ghostty và ô thường không đổi (test `XtermPageTests`, `RangeIgnoreTests`).

Chuyển ô trong cùng view (mô hình: test `SharedViewTests`; phần đo trên VS Code ở cuối mục này):

- Theo mã Chromium (`RenderWidgetHostViewCocoa`, nhánh main 12/11/2026), `mouseEvent:` không chuyển mouse down cho input context, còn `finishComposingText` thoát ngay khi không có marked text. Vì vậy click giữa hai phần tử của trang không tới bộ gõ: không reset, kết luận của D43 giữ nguyên. `insertText:replacementRange:` không lọc ký tự điều khiển.
- Giả định của mô hình:
  - Đổi focus giữa hai phần tử soạn thảo không đổi client IMK và không gọi `activateServer`.
  - Ô soạn thảo nhận DEL như một ký tự. Chưa đọc TipTap hay EditContext của Monaco.
- Kết quả trên mô hình; chuỗi gõ trong ô soạn thảo là `hoom nay tooi ddi hocj vui ver ↩camr own banj `, đáp án "hôm nay tôi đi học vui vẻ ⏎cảm ơn bạn ":

| Ca | Ô soạn thảo giữ (␡ là DEL) |
|---|---|
| a. xterm.js đã nhận ra, đã qua Return, rồi click sang ô soạn thảo | "ho␡ôm nay to␡ôi d␡đi hoc␡␡ọc vui ve␡ẻ ⏎cam␡␡ảm o␡ơn ban␡␡ạn ": DEL ở mọi phím thay chữ |
| b. xterm.js đã nhận ra, chưa có Return | dòng đầu đúng; Return gõ trong ô soạn thảo bật cách gửi DEL, nên dòng sau sai như ca a |
| c. Ô kiểu Ghostty cùng view (giả định, chưa thấy app nào như vậy) | DEL sau mọi phím thay chữ |
| d. Ô soạn thảo rồi click sang terminal | ô soạn thảo đúng; terminal tới dòng thứ ba mới được nhận ra, nên cả ba dòng sai như trước D43. Nguyên nhân là trạng thái của composer còn từ ô soạn thảo; coi click như reset thì nhận ra như lần kích hoạt mới |

Cách đã xét để vẫn gửi trong phím (không chọn, D43: còn lọt ký tự xoá):

- Sau khi đã có kết luận "terminal", ở mỗi phím thay chữ hỏi `selectedRange` một lần, như ô thường (N3). Vị trí lớn hơn 2 thì bỏ kết luận và thay tại chỗ.
- Không đọc thêm chữ; mỗi phím vẫn tối đa một `insertText`.
- Thử trên mô hình (đã bỏ khỏi mã):
  - Ghostty và xterm.js vẫn được nhận ra như cũ; Ghostty tốn thêm một `selectedRange` mỗi phím thay chữ.
  - Mọi client giả của ô thường cho ra chữ như cũ.
  - Ca a–c đúng hết khi ô soạn thảo đã có chữ. Khi ô soạn thảo rỗng, từ đầu tiên còn lọt DEL ("ho␡ôm") vì vị trí lúc đó còn ≤ 2. Trình soạn thảo kiểu Cursor (vị trí tính từ đầu từ) còn lọt DEL ở các từ ngắn.
  - Ca d không sửa được bằng cách này.

Đo trên VS Code (12/11/2026, bộ gõ Debug 3325750, 120 ms, một lượt mỗi ô; `scripts/research/terminal-underline/run.sh 't5-*'`):

- Terminal tích hợp, `toois vieetj ddi hocj nhaf nguwowif hoaf⌫ windows ↩uwa uwowcs `: D43 nhận ra ô (`in-key`), không gửi ký tự xoá; chữ ra "toois vieêetj dđdi hocọcj nhaàf nguưwoơwif hoaà windowswindows ↩uwa uưwoơwcs ", sai như cách cũ. Telex của Apple cùng ô: "tối việt đi học nhà người ho ưindows ↩ưa ước " (đúng tiếng Việt; khác ở từ tiếng Anh, D4, và ở ⌫).
- Chuyển ô: terminal `tooi vieetj ddi hocj ↩`, click sang tài liệu trống cùng cửa sổ, gõ `hoom nay tooi ddi hocj vui ver `: trình soạn thảo ra đúng "hôm nay tôi đi học vui vẻ ", 0 ký tự xoá; không có `activate` giữa lúc click và lúc gõ xong.
- Lượt này xếp ô vào `in-key`, không gặp ca bị xếp nhầm vào kiểu Ghostty. Ca đó nay cũng không gửi ký tự xoá: kiểu Ghostty chỉ dùng ở app không chứa nhân web (D43; `WebHost`).

Lượt xác nhận `WebHost` (12/11/2026, bộ gõ Debug 2bea19c chạy sandbox, 120 ms, một lượt mỗi ô; câu `tooi dungf windows ddeer hoaf⌫ hats vowis banj `, dòng hai `dduwowngf ddepj vui ver `):

- Kết quả đọc gói (`event=web-host`): Terminal và Ghostty không chứa nhân web, VS Code có (Chromium); 0,4–17 ms từ lúc hỏi tới lúc có kết quả, một lần 51 ms (lần đọc đầu sau khi cài), đều ngoài đường phím.
- Ghostty: nhận ra ô (`after-key`, không bị chặn), gửi ký tự xoá; "toôi dungf windows để hò hát với bạn ": hai từ đầu sai (trước khi nhận ra), từ thứ ba trở đi đúng.
- VS Code: lượt này không nhận ra ô; terminal sai như cách cũ, trình soạn thảo sau khi chuyển ô đúng "hôm nay đường đẹp vui vẻ ", 0 ký tự xoá. Terminal.app: đúng trừ ⌫ ("ho"). Telex của Apple trong terminal VS Code: "tôi dùng ưindows để ho hát với bạn ↩đường đẹp vui vẻ " (phép đo hợp lệ).
- Cửa sổ mở trên một file trong thư mục chưa được tin cậy thì VS Code hỏi tin cậy trước khi tạo terminal; ô `vscodeterm` mở cửa sổ trống (VS Code mặc định tin cửa sổ trống).

Kết quả trên trang thử (xterm.js 5.5.0 trong Chrome, 120 ms, một lượt mỗi ô; Telex của Apple ra đúng):

| Cách | `toois vieetj dd ` |
|---|---|
| Thay tại chỗ, trước D43 | "toôoiís vieêetj dđd ": phím gốc và chữ thay đều tới shell |
| Ký tự xoá gửi trong phím, bật từ đầu (bản thử) | "tối việt đ " |
| D43 gửi trong phím ngay từ phím nhận ra (lượt thứ tư) | sai nặng hơn: mỗi lần gửi lặp lại các lần sửa trước cộng một chữ "ê" thừa (H1) |
| D43 gửi trong phím từ dòng sau Return (đo 12/11/2026, chuỗi dài hơn có Return; nay đã tắt) | dòng đang gõ lúc nhận ra sai như trước D43; dòng sau Return đúng ("tối việt đi học nhà người hò windows ưa ước"), như mô hình dự đoán |

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
- Chương trình không coi DEL là lệnh xoá (vim ở chế độ lệnh, less) nhận ký tự đó như phím thường (theo mã, chưa đo; giới hạn đã ghi ở D43).
- Cách sửa cho xterm.js đã kiểm trên mô hình mã (`FakeXtermPage`) và đo trên trang thử một lượt (120 ms; chưa đo phím dồn). Mô hình giả định `setTimeout(0)` của xterm.js chạy sau mọi sự kiện Chromium gửi cho cùng phím (Blink ưu tiên sự kiện nhập), và keyup tới trước phím kế; chưa đọc mã lịch chạy của Blink. Gửi sau phím (cách của Ghostty) ở xterm.js theo mã sẽ mất phần sửa (`_inputEvent` bỏ chữ tới trước keyup), chưa đo.

## Phương pháp và bản mã đã đọc

- Chuỗi phím và đáp án: [`scripts/research/terminal-underline/run.sh`](../../scripts/research/terminal-underline/run.sh) (gọi `scripts/selftest/typing/run.sh` cho từng ô; đáp án là chữ đúng theo luật Telex, không phải chữ dự đoán). Số đo từng lượt: nhật ký [`docs/Progress.md`](../Progress.md) ngày 11/11 và 12/11/2026 (lượt 12/11 dùng `scripts/selftest/typing/run.sh xterm` với phím Return trong chuỗi).
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
