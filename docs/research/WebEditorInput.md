# Gõ trong Google Docs: các bộ gõ macOS khác làm gì

Google Docs trong Chrome và Safari làm Dấu sai chữ: mọi lần thay hai, ba ký tự đều hỏng, vì Google Docs báo vị trí con trỏ luôn là `(1, 0)` và trước con trỏ chỉ đưa bộ gõ một ký tự (số đo và chẩn đoán: [`docs/Compatibility.md`](../Compatibility.md) mục 5.10). File này ghi các bộ gõ tiếng Việt khác trên macOS, nhất là bộ gõ dựng trên InputMethodKit (IMK) như Dấu, gõ vào Google Docs bằng cách nào, để chọn cách sửa cho Dấu.

Cách ghi: mỗi khẳng định ghi nguồn. "Đọc mã" là điều đọc thấy trong mã nguồn của dự án đó, tả bằng lời của file này (không chép mã, D10 (Engine tự viết)). "Tác giả ghi" là điều chú thích, tài liệu hay trả lời issue của dự án nói, chưa ai kiểm lại. "Suy luận, cần kiểm chứng" là ý của file này. Không chạy mã của dự án nào.

## Hiện trạng (22/11/2026)

### Bảng tóm tắt

| Bộ gõ | Kiến trúc | Sửa chữ đã gõ | Trong Google Docs |
|---|---|---|---|
| VietTelex | IMK; thêm event tap khi có quyền Trợ năng | mặc định thay tại chỗ (`insertText` với `replacementRange`); app hay ô không đạt thì chữ đánh dấu (marked text) hoặc event tap | nhận ra ô Google Docs qua URL bằng Accessibility và ép chữ đánh dấu; không có quyền Trợ năng thì mọi ô của trình duyệt đều chữ đánh dấu (mục 1) |
| XKey (XKeyIM) | IMK; khi có quyền thì event tap làm hết | chữ đánh dấu ở mọi app; bỏ chế độ thay tại chỗ, trừ Spotlight, Raycast, Alfred | không quyền: chữ đánh dấu. Có quyền: event tap, quy tắc riêng cho Google Docs (gửi chậm, từng ký tự, ký tự rỗng trước) (mục 2) |
| Phím Việt | IMK (bản chính); app event tap tách riêng | chữ đánh dấu cho tới khi app chứng minh đọc lại đúng ở hai vị trí khác nhau, rồi thay tại chỗ, kiểm sau mỗi lần ghi | không có xử lý riêng; tác giả ghi Google Docs sẽ tự về chữ đánh dấu, ô kiểm thử Google Docs còn trống (mục 3) |
| fcitx5-macos (fcitx5-unikey, fcitx5-bamboo) | IMK | luôn chữ đánh dấu cho cả từ; chốt bằng `insertText` không có vùng thay | không có xử lý riêng (mục 4) |
| KeyIn, VietIME, InputKey, GoTiengViet (isthaison) | IMK | chỉ chữ đánh dấu | không có xử lý riêng (mục 5) |
| Telex của Apple | IMK | chữ đánh dấu | gõ đúng (Dấu đo, [`docs/Compatibility.md`](../Compatibility.md) mục 5.10); tác giả VietTelex cũng ghi bộ gõ của Apple gạch chân trong Google Docs; theo WebKit, Telex đơn giản thay tại chỗ và chỉ lùi về chữ đánh dấu khi app không áp đúng (mục 6) |
| OpenKey, EVKey, Gõ Nhanh, PHTV, goxkey, DauKey, VnKey; XKey.app | event tap, Backspace giả | xoá bằng Backspace giả rồi gõ chữ mới | tuỳ chọn hay quy tắc "gửi từng phím", gửi chậm, ký tự rỗng trước (mục 7) |
| Keyman (SIL, nhiều thứ tiếng) | IMK, kèm gửi phím ⌫ giả (cần quyền Trợ năng) | app "tuân thủ": thay tại chỗ bằng `insertText` với vùng thay; app khác: ⌫ giả rồi chèn | Chrome bị ghi cứng là app không tuân thủ, vì Google Docs (mục 11.1) |
| macSKK, Gureum, Squirrel, OpenVanilla, iAvro (tiếng Nhật, Hàn, Trung, Bangla) | IMK | chữ đánh dấu; macSKK đưa chữ vừa chốt về chữ đánh dấu, chỉ sau khi đọc lại thấy đúng chữ đó | không có xử lý riêng (mục 11.2) |

### Kết luận

- **Không bộ gõ IMK nào đã đọc gõ Google Docs bằng thay tại chỗ.** VietTelex ép chữ đánh dấu cho cả từ riêng ở Google Docs; XKeyIM khi không có quyền Trợ năng, fcitx5-macos và các bộ gõ ở mục 5 dùng chữ đánh dấu ở mọi app; Phím Việt dùng chữ đánh dấu tới khi app chứng minh đọc lại đúng. Tác giả VietTelex ghi rằng chữ đánh dấu là cách duy nhất chạy đúng với trình soạn thảo của Google Docs (mục 1). Khớp với số đo của Dấu: Telex của Apple gõ đúng ở đó. Theo hai tác giả khác thì nó cũng dùng chữ đánh dấu (mục 6; Dấu chưa đo điều này).
- **Nhận ra ô Google Docs:**
  - VietTelex đọc URL của vùng web đang có con trỏ bằng Accessibility, nên cần quyền Trợ năng. Dấu không xin quyền đó (N4 (Không tự đổi cài đặt hệ thống), ý cuối).
  - Chỉ dùng IMK thì có Phím Việt: một app được tin khi đọc lại đúng ở **hai vị trí khác nhau**. Tác giả ghi lý do: app báo một vị trí sai cố định chỉ có thể trùng đúng ở một vị trí. Đây chính là ca `(1, 0)` của Google Docs. Nhưng Phím Việt tin hay không theo cả app (bundle id), nên một tab Google Docs làm cả Chrome về chữ đánh dấu tới hết phiên (mục 3).
  - VietTelex có thêm một phép thử riêng từng ô chỉ dùng IMK: kiểm sau lần thay, hỏng hai lần thì ô đó về chữ đánh dấu. "Ô" được tính lại khi bộ gõ được kích hoạt và khi có click hay phím tắt, vì theo tác giả, Chromium báo cả cửa sổ là một client IMK. Phép thử này không bắt được Google Docs: theo tác giả, ô nhập ẩn của Google Docs tự báo một vị trí nhất quán (mục 1).
- **Vì sao trước con trỏ bộ gõ chỉ thấy một ký tự (đọc mã Chromium, mục 8 và 10).**
  - Ở Chrome cho macOS, `selectedRange` và `attributedSubstring(forProposedRange:actualRange:)` trả từ một bản sao chữ quanh vùng chọn mà trang gửi lên, không hỏi trang ngay lúc gọi.
  - Khi ô dùng EditContext, bản sao đó cắt từ chính chuỗi `editContext.text` mà trang tự đặt, tối đa 100 ký tự mỗi bên vùng chọn.
  - Một kỹ sư Mozilla viết (W3C edit-context issue #151, 10/2026) rằng Google Docs dùng một phần tử EditContext vô hình (không phải canvas) và vẽ canvas đè lên. Không có nguồn nào nói Google Docs đặt bao nhiêu chữ vào đó.
  - Dấu đã đo (17 và 22/11/2026, mục 10.6): trước con trỏ chỉ có đúng một ký tự ở cả hai trình duyệt. Ở Chrome, đó là ký tự ngay trước con trỏ; từ vị trí 1 trở đi còn một đoạn chữ dài gần bằng câu đã gõ, nhưng không phải chữ nằm sau con trỏ. Ở Safari, cả ô chỉ có một ký tự vô hình (zero-width) Google Docs đặt sẵn.
- **Thay tại chỗ trong Google Docs (mục 10):** không có đường nào chỉ dùng API chính thức để thay quá một ký tự. Sửa nhiều bước qua cửa sổ đã đo và không được (mục 10.6 A).
  - Gửi thẳng vùng thay rộng hơn vị trí, `(0, N)` với N từ 2 trở lên, không chạy (đã đo 22/11/2026, mục 10.6 C). Ở Chrome, Google Docs không áp lần thay đó và tab thôi áp đúng mọi lần thay sau cho tới khi tải lại trang. Ở Safari, Google Docs chỉ thay một ký tự.
  - Đọc lại trong lúc đang xử lý một phím không thấy thay đổi: Dấu đã đo ở Chrome ([`docs/Compatibility.md`](../Compatibility.md) mục 6.2).
  - Sửa nhiều bước theo cửa sổ một ký tự, chạy sau khi phím đã xử lý xong: không được. Ở Chrome, xoá ký tự trong cửa sổ xong thì cửa sổ không trượt về chữ trước mà hiện một dấu cách. Tab đó thôi nhận mọi lần thay chữ cho tới khi tải lại trang; ở Safari cửa sổ không có chữ thật để bắt đầu (mục 10.6 A).
  - Các tuỳ chọn hỗ trợ tiếp cận của Google Docs không đo: kể cả khi chạy được, chúng chỉ là cách vòng người dùng phải tự bật (mục 10.6 B).
  - Một đề xuất đang ở giai đoạn prototype trong Chromium (`contextrequest`, 10/2026) sẽ cho bộ gõ xin thêm chữ quanh con trỏ, nếu Google Docs dùng nó.
- **Bộ gõ IMK cho tiếng khác (mục 11):** không bộ nào thay tại chỗ được trong Google Docs chỉ bằng API chính thức.
  - Keyman là bộ gõ IMK duy nhất tìm được có cùng cách làm với Dấu: thay chữ đã xuất bằng `insertText` có vùng thay, sau khi kiểm app bằng `selectedRange`. Keyman ghi cứng Chrome (cả app) là "không tuân thủ" từ 12/2023. Chú thích trong mã nói lý do: Google Docs trả một vị trí tương đối nhưng sai, nên không tự phát hiện được.
  - Ở app không tuân thủ, Keyman xoá bằng phím ⌫ giả gửi qua `CGEventPost`, nên cần quyền Trợ năng: trái N4 và là cách Dấu đã loại.
  - Các bộ gõ IMK khác (tiếng Nhật, Hàn, Trung, Bangla, Ấn Độ) đều soạn bằng chữ đánh dấu. Không bộ nào có xử lý riêng cho Google Docs.
  - Không tìm được nguồn đáng tin nói chuyển lại tiếng Nhật chạy hay không trong Google Docs.
  - Công cụ nhập liệu dựng sẵn của Google Docs chỉ hiện với ngôn ngữ không dùng chữ Latin, theo trang trợ giúp.
- **Chế độ chữ nổi (⌘⌥H) của Google Docs:** không tìm thấy nguồn nào nói nó đổi chữ mà bộ gõ đọc được. Nguồn gần nhất: người dùng Squirrel (bộ gõ tiếng Trung, IMK) báo rằng bật "screen magnifier support" trong Cài đặt hỗ trợ tiếp cận của Google Docs sửa vị trí khung chọn chữ. Vậy các tuỳ chọn hỗ trợ tiếp cận của Google Docs có đổi ô nhập ẩn, ít nhất về vị trí; về chữ thì chưa ai nói (mục 9). Chỉ đo mới trả lời được.
- **Gạch chân "trong suốt" không có trong Chrome (đọc mã Chromium, mục 8).** GoTiengViet (isthaison) gửi chữ đánh dấu với kiểu gạch chân "không" để giấu gạch chân. Chromium vẫn vẽ gạch chân mảnh khi có thuộc tính gạch chân, bất kể giá trị của nó. Không có thuộc tính nào thì Blink tự thêm gạch chân mặc định cho trang thường. Riêng Google Docs tự vẽ chữ đang soạn: tác giả VietTelex ghi là có gạch chân.

### Ý cho cách sửa của Dấu (suy luận, cần kiểm chứng)

Các phương án đang bàn, đối chiếu với điều bộ gõ khác làm và với `docs/Decisions.md`:

- **Tự bật chữ đánh dấu cho từng ô khi con trỏ đứng yên.**
  - Bộ gõ khác: Phím Việt và VietTelex làm gần như vậy, chỉ bằng IMK.
  - Tín hiệu Dấu đã có: ở phím có thay chữ, `selectedRange` vẫn là `(1, 0)` sau khi Dấu đã gõ vài chữ vào đó. Đây là tín hiệu "vị trí sai cố định" của Phím Việt và cùng loại với "app báo con trỏ sai" mà VietTelex dùng.
  - Giới hạn chung của hai bộ gõ đó: từ đang gõ khi phát hiện thì không cứu được, vì các chữ trước đã nằm trong tài liệu và Google Docs không cho thay chúng. Phím Việt tránh từ hỏng đó bằng cách gõ chữ đánh dấu cho hai từ đầu của mọi app.
  - Đơn vị nhớ: tác giả VietTelex ghi Chrome báo cả cửa sổ là một client. Dấu đo thấy khác (25/11/2026, máy M1 Pro, Chrome 157.0.8103.79, bản Debug có log định danh client, không giữ lại; nhật ký `docs/Progress.md`): mỗi tab là một client IMK riêng với một controller riêng của Dấu, và quay về tab nào thì nhận lại đúng client và controller của tab đó. Vậy trạng thái giữ trong controller là trạng thái của tab và còn nguyên khi chuyển tab. VietTelex quên khi có click, phím tắt hay kích hoạt lại.
  - Trái với D13 (Gạch chân là đường lui cuối cùng) và D5 (Quy tắc theo ứng dụng). Theo D13, gạch chân chỉ do người dùng bật và mặc định mọi app không gạch chân. Muốn làm thì phải sửa quyết định trước.
- **Cài đặt phía người dùng trong Google Docs** (chế độ chữ nổi, hỗ trợ trình đọc màn hình, hỗ trợ kính lúp): không có nguồn nói nó sửa được. Dấu không đo, vì kể cả khi chạy được thì đó cũng chỉ là cách vòng người dùng phải tự bật (mục 10.6 B).
- **Nhận ra Google Docs theo URL hay tiêu đề cửa sổ** (VietTelex, XKey): cần quyền Trợ năng, trái N4. Tiêu đề cửa sổ còn đổi theo ngôn ngữ giao diện ("Google Tài liệu").
- **Bật gạch chân theo app như hiện nay** (D13, D5): người dùng bật cho Chrome thì mọi ô của Chrome mất D20 (Thêm dấu cho từ đã gõ), để chữa một trang. Cùng lý do D43 (Ô bỏ qua vùng thay chữ) không gắn nhãn cho app mà terminal chỉ là một ô.
- **Gửi từng phím, gửi chậm** (OpenKey, XKey, PHTV, Gõ Nhanh): mẹo của event tap, không áp được cho IMK. Thay hai, ba ký tự cần vùng thay vượt ra ngoài chữ Google Docs cho thấy. Bản IMK của ý này là sửa nhiều bước theo cửa sổ một ký tự (mục 10, thí nghiệm A): tách một lần thay thành nhiều lần `insertText`, trái N3 (Ít lời gọi vào ứng dụng đích).
- **Giữ thay tại chỗ:** các đường còn mở và thí nghiệm để phân định ở mục 10.

## 1. VietTelex

- Mã nguồn: https://github.com/ptrinh/VietTelex (MIT), đọc ở commit `74b0fa7` (17/11/2026). Bộ gõ IMK cài vào `~/Library/Input Methods`, kèm một event tap trong cùng tiến trình khi có quyền Trợ năng.
- **Cách sửa chữ đã gõ (tác giả ghi trong `docs/MACOS_IME_NOTES.md` và `typing-modes.yml`):**
  - Mặc định thay tại chỗ: mỗi phím đổi chữ quy thành "xoá n ký tự, chèn chuỗi mới", gửi bằng một `insertText` có vùng thay. Vị trí đầu từ đọc một lần ở phím đầu của từ, sau đó tự theo dõi, không hỏi `selectedRange` sau mỗi lần chèn.
  - Mỗi app có một chế độ trong bảng `typing-modes.yml`: thay tại chỗ, event tap, chữ đánh dấu, chọn rồi gõ đè, hoặc "dò theo ô bằng Accessibility" (Chrome, Brave, Edge, Safari dùng chế độ này).
  - App chưa có trong bảng thì được thử một lần sau lần thay đầu. Bỏ qua vùng thay thì chuyển sang chữ đánh dấu và nhớ lại.
- **Trong trình duyệt (đọc mã, chú thích trong `App/Sources/TerminalTap.swift` và `App/Sources/AppState.swift`):**
  - Thanh địa chỉ: chọn rồi gõ đè.
  - Nội dung trang Chromium: event tap (Backspace giả). Tác giả ghi lý do: `insertText` với vùng thay không có hợp đồng nào với trình soạn thảo JavaScript. Google Docs, Discord, Zalo từng hỏng theo ba kiểu khác nhau trong một tuần. Ca Discord không thể phát hiện từ bên trong: mọi lần tự báo đều nói đã thay đúng trong khi chữ trên màn hình bị nối thêm.
  - Nội dung trang Safari/WebKit: thay tại chỗ. Theo tác giả, Safari trên macOS 26 bỏ các phím giả của event tap trong trang.
  - Ô có URL `docs.google.com/document` (cả `antigravity.google.com` và TikTok): **chữ đánh dấu**. Nhận ra bằng cách đi ngược cây Accessibility từ phần tử đang có con trỏ, đọc thuộc tính URL của các vùng web; ô nhập ẩn nằm trong iframe lồng, nên đi tiếp lên vùng web bên ngoài.
  - Google Sheets: chèn U+202F để huỷ gợi ý, xoá, rồi gõ lại.
  - Không có quyền Trợ năng: mọi ô của trình duyệt về chữ đánh dấu.
- **Vì sao Google Docs phải dùng chữ đánh dấu (tác giả ghi):**
  - Google Docs vẽ theo luồng sự kiện riêng và bỏ qua vùng thay. Thay tại chỗ thì chữ bị nối thêm và ⌫ do bộ gõ theo dõi không còn tác dụng ("Quoocs" ra "Quoôcốc", báo lỗi ngày 30/07/2026).
  - Google Docs xử lý sự kiện soạn chữ (composition) bình thường.
  - Ô nhập ẩn của Google Docs tự báo một vị trí con trỏ nhất quán, nên phép thử từng ô không bao giờ phát hiện ra nó; chỉ nhận ra theo URL mới được.
- **Phép thử từng ô chỉ dùng IMK (đọc mã, `App/Sources/TelexInputController.swift`):**
  - Theo tác giả, Chromium báo cả cửa sổ là một client IMK, nên "ô" được tính lại mỗi lần bộ gõ được kích hoạt và mỗi lần có click hay phím tắt ⌘. Dấu đo thấy mỗi tab một client (ý "Đơn vị nhớ" ở trên).
  - Sau một lần thay, VietTelex so vị trí con trỏ với vị trí lẽ ra có nếu app thay đúng và nếu app nối thêm. Hai lần "nối thêm" thì ô đó dùng chữ đánh dấu tới lần tính lại sau. Vị trí nằm trước đầu từ thì coi là "chưa biết"; bốn lần chưa biết liên tiếp cũng về chữ đánh dấu.
  - Bài học tác giả ghi: Chrome có thể trả chữ cũ ngay sau `insertText`, nên một tín hiệu tự báo trái với tín hiệu khác chỉ là "chưa biết", không phải "hỏng".
- **Báo lỗi liên quan:**
  - Issue #37 (Google Docs trên Safari): ⌫ và dấu cách thôi tác dụng giữa từ ở chế độ chữ đánh dấu. Nguyên nhân là lỗi của chính VietTelex, đã sửa ở 1.5.10. Tác giả trả lời rằng gạch chân trong Google Docs là cố ý, vì chữ đánh dấu là cách duy nhất đúng với trình soạn thảo của Google Docs. Bàn phím tiếng Việt có sẵn của macOS cũng gạch chân như vậy ở đó.
  - `docs/MACOS_IME_NOTES.md`, mục về trình soạn thảo web loại chữ đánh dấu: ở ô bình luận TikTok trên Safari, từ cuối đang soạn không vào tài liệu nếu sau đó không có một phím thật. Một cách vá (nhấn Enter hai lần) đã bỏ vì làm Google Docs tệ hơn: phải nhấn Enter hai lần mới xuống dòng.

## 2. XKey (XKeyIM)

- Mã nguồn: https://github.com/xmannv/xkey (MIT), đọc ở commit `9b5c9ab` (17/11/2026). Gồm app XKey (event tap) và XKeyIM (`com.codetay.inputmethod.XKey`, IMK).
- **Cách sửa chữ đã gõ (đọc mã `XKeyIM/XKeyIMController.swift`, `XKeyIM/IMKitTransport.swift`, `XKeyIM/TapController.swift`; tài liệu thiết kế `docs/superpowers/specs/2026-08-28-xkeyim-event-tap-design.md`):**
  - Có quyền nghe và gửi phím: event tap của XKeyIM làm hết việc (Backspace giả như XKey.app), còn bộ điều khiển IMK trả `false` cho mọi phím.
  - Không có quyền: chữ đánh dấu cho cả từ ở mọi app. Riêng Spotlight, Raycast, Alfred và ô của SecurityAgent dùng `insertText` có vùng thay.
  - Tài liệu thiết kế ghi lý do bỏ chế độ thay tại chỗ: mọi lỗi ghi chữ gần đây (Chrome chốt gợi ý tự hoàn thành, Warp báo con trỏ cố định, iTerm2 nối thêm thay vì thay, mất dấu sau ⌘A) đều nằm ở tầng ghi chữ qua IMK.
- **Google Docs:**
  - Quy tắc dựng sẵn theo tiêu đề cửa sổ ("Google Docs" hoặc "Google Tài liệu", mọi trình duyệt), trong `Shared/AppBehaviorDetector.swift`: gửi chậm, gửi từng ký tự, chèn một ký tự rỗng trước. Quy tắc này áp cho đường event tap. Tiêu đề cửa sổ đọc bằng Accessibility.
  - Cùng quy tắc có ghi "không dùng chữ đánh dấu" cho IMK, nhưng đọc mã thì XKeyIM hiện không đọc gợi ý đó (chỉ màn hình gỡ lỗi của XKey.app in ra).
  - README hướng dẫn người dùng giao diện tiếng Việt tự thêm quy tắc cho tiêu đề "Google Tài liệu". Theo mã hiện tại, quy tắc dựng sẵn đã có tiêu đề đó.
  - Issue #97 ("Lỗi khi gõ trên Google Docs"): người bảo trì chỉ tới mục quy tắc theo ứng dụng trong README, không có chẩn đoán.

## 3. Phím Việt

- Mã nguồn: https://github.com/phamcongdanh98/Phim_Viet (MIT), đọc ở commit `8f75fc2` (09/11/2026). Bản chính là bộ gõ IMK, không event tap, không xin quyền Trợ năng. "Phím Việt Key" là app event tap tách riêng, người dùng tự mở.
- **Cách sửa chữ đã gõ (đọc mã `macos/PhimViet/Composition/ClientTrust.swift`, `DirectEdit.swift`, `CompositionSession.swift`; tác giả ghi trong `docs/DECISIONS.md`, `docs/KNOWN_ISSUES.md`):**
  - Mỗi app bắt đầu bằng chữ đánh dấu. Sau khi chốt một từ, bộ gõ đọc chữ ngay trước con trỏ; khớp đúng chữ vừa chốt là một lần chứng minh.
  - App được tin khi có hai lần chứng minh ở **hai vị trí khác nhau**. Lý do tác giả ghi: app báo vị trí sai cố định chỉ có thể trùng đúng ở một vị trí.
  - App được tin thì thay tại chỗ, chỉ thay phần đuôi khác. Trước khi thay phải đọc lại chữ trước con trỏ và thấy khớp; sau khi thay thì kiểm vị trí con trỏ (cho phép báo trễ một phím).
  - Đọc không khớp thì không ghi gì, bỏ từ đó và **thôi tin cả app tới hết phiên**: app đó về chữ đánh dấu.
  - Tin theo bundle id, nên một ô hỏng làm cả app về chữ đánh dấu (vấn đề S2 trong `docs/KNOWN_ISSUES.md`).
- **Google Docs:**
  - Không có xử lý riêng. `docs/MANUAL_TEST.md` có mục "Chrome — Google Docs", ghi rằng Google Docs dùng ô nhập ẩn và nếu đọc lại không khớp sẽ tự về chữ đánh dấu. Mọi ô kết quả của mục đó còn trống.
  - Theo mã, ở ca `(1, 0)`: nếu Chrome chưa được tin thì hai lần chứng minh ở cùng vị trí 1 không đủ, Chrome ở lại chữ đánh dấu. Nếu Chrome đã được tin từ trang khác thì lần thay hai, ba ký tự đầu tiên ở Google Docs đọc không khớp: từ đó bị bỏ và cả Chrome về chữ đánh dấu (suy luận, cần kiểm chứng).
- **Chrome (tác giả ghi, `docs/DECISIONS.md` D9–D11):**
  - Chrome báo `markedRange` theo toạ độ riêng, nên phép chứng minh chỉ dựa vào `selectedRange` và chữ đọc lại.
  - Chrome và Electron trả độ dài tài liệu là 0, nên coi 0 là "không biết".
  - Chữ đánh dấu gửi dạng chuỗi trơn thì Chrome tô nền, nên phải gửi kèm thuộc tính gạch chân mảnh.
  - Chốt chữ đánh dấu ngay trong lúc xử lý phím tắt thì Chrome bỏ phím tắt đó (⌘A phải nhấn hai lần); tác giả sửa bằng cách chốt khi nhận `flagsChanged`.

## 4. fcitx5-macos, fcitx5-unikey, fcitx5-bamboo

- Mã nguồn: https://github.com/fcitx-contrib/fcitx5-macos (GPLv3) ở commit `6322853`; https://github.com/fcitx/fcitx5-unikey ở commit `ed9170c`; https://github.com/fcitx/fcitx5-bamboo. fcitx5-unikey và fcitx5-bamboo là gói tiếng Việt chính thức của fcitx5-macos (`src/config/officialplugins.swift`).
- **Cách sửa chữ đã gõ (đọc mã `macosfrontend/macosfrontend.swift`, `macosfrontend/macosfrontend.h`, `src/controller.swift`):**
  - Chữ đang soạn luôn là chữ đánh dấu, gạch chân mảnh như bộ gõ bính âm của macOS.
  - Chốt bằng `insertText` không có vùng thay.
  - Phần "xoá chữ quanh con trỏ" của fcitx5 để trống trên macOS, nên mọi cách sửa chữ đã chốt của engine không có tác dụng ở đây.
  - Ở mỗi phím không kèm ⌘ hay ⌃, bộ gõ đọc tới 1024 đơn vị UTF-16 mỗi bên con trỏ bằng `attributedSubstring` và đưa cho engine.
  - Khi không có chữ đang soạn, nó đặt một chữ đánh dấu giả (dấu cách rộng 0) để Chrome, VS Code, Terminal không xử lý ⌫ hai lần và không bỏ qua bộ gõ. Một danh sách app được miễn việc này.
- **fcitx5-unikey (đọc mã `src/unikey-config.h`, `src/unikey-im.cpp`):**
  - Hai tuỳ chọn về chữ quanh con trỏ: "dựng lại trạng thái từ chữ quanh con trỏ", mặc định bật; "cho phép sửa chữ quanh con trỏ (thử nghiệm)", mặc định tắt.
  - Cách thứ nhất đọc từ ngay trước con trỏ để gõ tiếp vào từ đó, giống ý của D20.
  - Cách thứ hai xoá từ đó khỏi tài liệu rồi soạn lại nó thành chữ đánh dấu. Cách này cần phần "xoá chữ quanh con trỏ" mà fcitx5-macos để trống (suy luận, cần kiểm chứng).
- fcitx5-bamboo có tuỳ chọn gạch chân hay không cho chữ đang soạn (`src/bambooconfig.h`).
- **Google Docs:** không thấy xử lý riêng trong mã. Không tìm được tracker issue của fcitx5-macos qua `gh search issues` (kho không cho tìm).

## 5. Bộ gõ IMK chỉ dùng chữ đánh dấu

Không thấy xử lý riêng cho Google Docs hay trình duyệt trong các bộ gõ dưới đây (đọc mã, grep "docs.google", "Google Docs", "Chrome").

- KeyIn (https://github.com/tuoitrevohoc/KeyIn, commit `876b024`): `native/main.m` gửi chữ đánh dấu kèm vùng thay, chốt bằng `insertText`.
- VietIME (https://github.com/truongtv91/VietIME, commit `702a087`): chữ đánh dấu, chốt bằng `insertText` không có vùng thay.
- InputKey (https://github.com/vuminhquang/InputKey, commit `489a742`, bản IMK trong `Implementations/macOS/InputMethodKit`): chữ đánh dấu, chốt bằng `insertText` không có vùng thay.
- GoTiengViet của isthaison (https://github.com/isthaison/gotiengviet, commit `06ae35d`, bản macOS ghi là bản xem trước): chữ đánh dấu với kiểu gạch chân "không". Chú thích trong mã nói cách này bỏ được gạch chân ở mọi app, kể cả trình duyệt. Đọc mã Chromium thì trình duyệt Chromium vẫn vẽ gạch chân mảnh (mục 8).
- Đã thử tìm nhưng không có: kho `manhpham90vn/xkey` (bộ gõ Rust có IMK, theo kết quả tìm kiếm) không clone được, kho không tồn tại.

## 6. Telex của Apple

- Bộ gõ IMK của macOS (`com.apple.inputmethod.VietnameseIM.VietnameseTelex`). Dấu đo: gõ đúng chữ gõ liền trong Google Docs, nơi Dấu sai ([`docs/Compatibility.md`](../Compatibility.md) mục 5.10).
- Dấu chưa đo việc nó dùng chữ đánh dấu ở Google Docs. Hai tác giả khác ghi điều này: VietTelex (issue #37: bàn phím tiếng Việt có sẵn của macOS gạch chân trong Google Docs) và Phím Việt (`docs/DECISIONS.md` D12: bộ gõ tiếng Việt mặc định của Apple gạch chân). [`docs/research/TerminalAndUnderline.md`](TerminalAndUnderline.md) cũng gọi nó là gạch chân ở terminal.
- Theo commit 313286@main của WebKit, Telex đơn giản của Apple (commit gọi theo tên) là bộ gõ "không chế độ": gõ bằng `insertText` có vùng thay, hỏi `selectedRange` trong lúc xử lý phím để kiểm chữ đã vào chưa và chuyển sang chữ đánh dấu tới hết phiên nếu chưa. Nên gạch chân mà hai tác giả trên thấy có thể là chế độ lùi đó, không phải cách gõ mặc định. Bộ gõ Telex (không đơn giản) có cùng cơ chế không: chưa rõ. Chi tiết: [`docs/research/IMKCapabilities.md`](IMKCapabilities.md) mục 5.

## 7. Bộ gõ event tap (đối chiếu)

Các bộ gõ này chặn phím toàn hệ thống, xoá chữ cũ bằng Backspace giả rồi gõ chữ mới, cần quyền Trợ năng. Dấu không làm cách này (`docs/Decisions.md` mục "Đã cân nhắc và loại bỏ"). Vấn đề của chúng ở Google Docs là thứ tự và tốc độ các phím giả, không phải vùng thay.

- **OpenKey** (https://github.com/tuyenvm/OpenKey):
  - Issue #89 (Google Docs trên Safari, còn mở) và #171 (Google Docs, Sheets): tác giả bảo bật "Gửi từng phím". Tác giả viết rằng các bộ gõ khác cũng hỏng với Google Docs.
  - Tuỳ chọn này đã ghi ở [`docs/research/OpenKeyNotes.md`](OpenKeyNotes.md) mục 2, dòng 23.
- **EVKey** (đóng nguồn): issue #47 ở https://github.com/lamquangminh/EVKey (Google Docs + Safari, macOS 12.3.1: chữ tự bị xoá) còn mở, không có cách sửa.
- **Gõ Nhanh** (https://github.com/khaphanspace/gonhanh.org, commit `542a679`):
  - `platforms/macos/RustBridge.swift`: nội dung trang Safari, kể cả Google Docs, gửi từng ký tự với độ trễ; trình duyệt khác dùng Backspace thường.
  - `docs/system-architecture.md` ghi Google Docs là "canvas", dùng Backspace.
  - `docs/common-issues.md` mục 3.1 ghi Google Docs có thể lặp chữ ("trường" ra "TTrường") hoặc mất dấu khi gõ nhanh và khuyên dùng bộ gõ có tuỳ chọn sửa lỗi Google Docs riêng.
  - Issue #235: thêm chế độ gửi từng phím cho Google Docs trên Safari (bản 1.0.108).
- **PHTV** (https://github.com/phamhungtien/PHTV, commit `0a42ef4`): `CHANGELOG.md` ghi nhận ra Google Docs, Sheets, Slides, Forms qua URL hoặc tiêu đề cửa sổ (Accessibility) để giữ cách gửi ký tự rỗng trước, tránh mất ký tự. Issue #134: lặp chữ trong Google Sheets ("Dương" ra "Duương"), sửa ở bản 2.5.5.
- **XKey.app**: quy tắc Google Docs ở mục 2.
- **goxkey** (https://github.com/huytd/goxkey), **DauKey** (https://github.com/emizuki/daukey), **VnKey** (https://github.com/marixdev/vnkey): đọc mã thấy event tap; không thấy xử lý riêng cho Google Docs.
- **GoTiengViet** (bản thương mại), **EVKey**: đóng nguồn, chưa đọc mã.

## 8. Chrome đưa gì cho bộ gõ (đọc mã Chromium)

Mã: `content/app_shim_remote_cocoa/render_widget_host_view_cocoa.mm` và `third_party/blink/renderer/core/editing/ime/input_method_controller.cc`, nhánh `main` lấy ngày 17/11/2026 (https://chromium.googlesource.com/chromium/src/+/main/). Chưa đối chiếu với đúng bản Chrome 157 Dấu đã đo.

- `selectedRange` trả vùng chọn mà view đang giữ.
- `attributedSubstring(forProposedRange:actualRange:)` chỉ cắt từ bản sao "chữ đang có" (chữ quanh vùng chọn, kèm vị trí bắt đầu của nó). Ngoài bản sao đó thì trả nil.
- Cả hai được cập nhật khi trang báo vùng chọn đổi, không hỏi trang ngay lúc bộ gõ gọi. Vì vậy bộ gõ chỉ thấy chữ mà phần tử đang nhận phím có.
- Sau `insertText` không có vùng thay, view tự dời vùng chọn và chèn tạm chữ vừa gõ vào bản sao, chờ trang cập nhật. Chú thích trong mã nói API của macOS là đồng bộ còn Chrome bất đồng bộ (crbug 40165347).
- `insertText` có vùng thay và `setMarkedText` có vùng thay đều chuyển vùng đó cho trang. Trang (Blink, hoặc mã JavaScript của trình soạn thảo khi dùng EditContext) quyết định áp vùng đó thế nào.
- **Gạch chân của chữ đánh dấu:**
  - Chromium chỉ tạo gạch chân cho đoạn có thuộc tính gạch chân và với mọi giá trị của thuộc tính đó (kể cả "không") đều là gạch chân mảnh hoặc dày.
  - Chuỗi trơn: gạch chân mảnh mặc định.
  - Không có đoạn gạch chân nào: Blink thêm gạch chân mảnh và màu nền mặc định cho chữ đang soạn.
  - Trang tự vẽ như Google Docs thì vẽ theo cách của nó.
- **Google Docs nhận chữ thế nào:**
  - Ghi chú giải thích EditContext của W3C viết rằng Google Docs dùng một phần tử contenteditable nằm ngoài màn hình để nhận chữ.
  - Thư "Intent to Ship: EditContext API" (blink-dev, 31/10/2023, Chrome 121) viết rằng trong origin trial, nhóm Google Docs đã dùng EditContext để nhận chữ từ bộ gõ, thay cho phần tử contenteditable ẩn được dời theo con trỏ và rằng Google Docs sẽ dùng nó khi Chrome phát hành.
  - W3C edit-context issue #151 (mở 05/10/2026, một kỹ sư Mozilla viết) nói Google Docs dùng một phần tử EditContext vô hình (không phải canvas) và vẽ canvas đè lên. Đây là nguồn mới nhất tìm được về cách Google Docs nhận chữ; không có nguồn của chính Google.
  - Chú thích của VietTelex (mục 1) nói ô nhập ẩn nằm trong một iframe lồng; đó là lời tác giả, chưa kiểm. Hai nguồn này không trái nhau: phần tử gắn EditContext có thể nằm trong iframe.

## 9. Đối chiếu: ô nhập nhỏ và cài đặt hỗ trợ tiếp cận của Google Docs

- **Không tìm thấy nguồn nào nói thẳng** rằng Google Docs chỉ đưa cho bộ gõ một ký tự quanh con trỏ, với bộ gõ tiếng Nhật (chuyển lại, reconversion), tiếng Trung hay tiếng Hàn trên macOS. Đã tìm: tìm kiếm web tiếng Anh, tiếng Nhật, tiếng Việt; issue của Squirrel, macSKK (không có kết quả), fcitx5-macos (không tìm được).
- **Nguồn gần nhất về ô nhập ẩn:**
  - Squirrel issue #345 (2019, đóng "wontfix", trùng #975): trong Google Docs, khung chọn chữ không theo con trỏ mà nằm ở đầu màn hình. Một người dùng nói bộ gõ của Sogou và bính âm của macOS cũng bị. Người bảo trì nói cần Google sửa.
  - Trong cùng issue, người dùng chỉ cách vá: bật "Turn on screen magnifier support" trong Tools › Accessibility settings của Google Docs. Một người báo vẫn không được trên Edge (2021), một người báo được (2024).
  - Khung chọn chữ đặt theo vị trí mà ô nhập trả cho `firstRect(forCharacterRange:actualRange:)`. Ô nhập ẩn trả vị trí sai. Tuỳ chọn kính lúp đổi vị trí đó (suy luận, cần kiểm chứng).
- **Chế độ chữ nổi (⌘⌥H):**
  - Trang trợ giúp của Google ("Use Google Docs Editors with a screen reader") tả: màn hình chữ nổi hiện nội dung, các nút định tuyến con trỏ dời được con trỏ, trình đọc màn hình đọc theo cài đặt đọc từng ký tự và từng từ của nó. Trang khuyên tắt chữ nổi nếu không dùng màn hình chữ nổi hoặc thấy Sheets, Slides chậm. Không nói gì về bộ gõ.
  - Bài Google Workspace Updates (31/08/2020) về chữ nổi cũng không nói gì về bộ gõ.
  - Một bài tiếng Việt (gcs.vn, 28/01/2026, giả định Windows và UniKey, EVKey, OpenKey) nói chế độ chữ nổi có thể làm con trỏ nhảy về đầu dòng và khuyên **tắt** nó. Bài không nối việc đó với lỗi gõ tiếng Việt.
  - Kết luận: không có nguồn nói chế độ chữ nổi hay hỗ trợ trình đọc màn hình làm bộ gõ thấy cả đoạn văn. Chỉ một lượt đo trên Dấu (Debug, ghi `selectedRange` như lượt chẩn đoán ở mục 5.10) mới trả lời được.

## 10. Thay tại chỗ trong Google Docs: các đường còn mở

Mục này xét các cách giữ thay tại chỗ trong Google Docs chỉ bằng API chính thức: không xin quyền Trợ năng, không dùng chữ đánh dấu.

Mốc là quan sát của Dấu ([`docs/Compatibility.md`](../Compatibility.md) mục 5.10, Chrome 157):
- Vị trí con trỏ là `(1, 0)` ở mọi phím, ở cả Chrome và Safari.
- Google Docs áp mọi lần thay một ký tự ngay trước con trỏ.
- Trước con trỏ chỉ có đúng một ký tự (đo 22/11/2026, 10.6 C). Ở Chrome, đó là ký tự ngay trước con trỏ, và từ vị trí 1 trở đi còn một đoạn chữ không phải chữ sau con trỏ. Ở Safari, cả ô chỉ có một ký tự vô hình. `length()` trả 0 ở cả hai.

Trong mục này, "cửa sổ một ký tự" là phần chữ trước con trỏ mà bộ gõ chạm tới được: đúng một ký tự, trượt theo con trỏ.

### 10.1 Google Docs dùng EditContext, nhưng đặt bao nhiêu chữ thì không nguồn nào nói

- **Có dùng EditContext không:**
  - blink-dev "Intent to Ship: EditContext API" (31/10/2023): nhóm Google Docs đã dùng EditContext trong origin trial và sẽ dùng khi Chrome phát hành (Chrome 121).
  - W3C edit-context issue #151 (05/10/2026, một kỹ sư Mozilla viết): Google Docs dùng một phần tử EditContext vô hình (không phải canvas) và vẽ canvas đè lên.
  - Không tìm được nguồn của chính Google, từ 2024 tới 2026, xác nhận cách làm hiện tại.
- **Đặt chữ gì vào EditContext:** không có nguồn. Các nguồn gần nhất nói về chi phí, không nói về Google Docs:
  - blink-dev "Intent to Prototype: EditContext On-Demand Text & Selection Updates" (20/10/2026): nêu Google Docs và Slides là trình soạn thảo tài liệu lớn và đề xuất `invalidate()` cùng sự kiện `contextrequest`.
  - W3C edit-context issue #156 (14/10/2026), lý do của đề xuất đó:
    - Hiện nay trang phải đẩy chữ và vùng chọn (`updateText`, `updateSelection`) ở mọi thay đổi.
    - Chép vài đoạn văn từ mô hình riêng ra một chuỗi ở mỗi phím tốn CPU và bộ nhớ.
    - Chuyển lại (reconversion), đọc chính tả bằng giọng nói và công cụ viết cần "vài đoạn văn" quanh vùng chọn.
    - `updateSelection` bị kẹp trong độ dài của `editContext.text`.
    - Issue #107 (09/2024) cũng nêu chi phí giữ `editContext.text`.
  - Suy ra Google Docs chỉ đặt một ký tự trước con trỏ để khỏi chép chữ ở mỗi phím. Ý này khớp số đo của Dấu và đúng loại chi phí #156 tả (suy luận). Ở Chrome, chuỗi đó còn một đoạn chữ sau vị trí 1, không phải chữ sau con trỏ; Google Docs đặt nó để làm gì thì không có nguồn (10.6 C).
- **Báo lỗi bộ gõ nhận quá ít chữ:** không tìm thấy crbug hay issue W3C nào nói thẳng về Google Docs với bộ gõ tiếng Việt, tiếng Nhật, tiếng Hàn, tự sửa hay thay thế chữ của macOS. #156 là bản tổng quát của vấn đề này.

### 10.2 Chrome xử lý vùng thay và cập nhật bản sao thế nào (đọc mã)

Mã: `render_widget_host_view_cocoa.mm`, `render_widget_host_view_mac.mm`, `render_frame_impl.cc`, `edit_context.cc`, `runtime_enabled_features.json5`, nhánh `main` ngày 17/11/2026.

- **Vùng thay đi tới trang:** `insertText` có vùng thay được chuyển ngay cho renderer thành lệnh chốt chữ, kèm vùng đó, cả khi đang xử lý phím. Bản sao trong view không được sửa tạm (chỉ nhánh không có vùng thay mới sửa tạm).
- **EditContext kẹp vùng thay:** ngoài lúc đang soạn chữ (cờ `EditContextBeforeInputForIme` ở trạng thái "stable"):
  - EditContext đặt vùng chọn bằng vùng thay, kẹp trong `[0, độ dài editContext.text]`.
  - Rồi nó phát `beforeinput` (trang có thể đổi đích bằng `updateText`, `updateSelection`), chèn chữ vào vùng chọn và phát `textupdate`, kèm chữ mới, đầu và cuối đoạn bị thay, vùng chọn mới.
  - Vậy vùng vượt ra ngoài cửa sổ không bị từ chối mà bị cắt bớt. `NSRange` không có vị trí âm, nên khi Chrome báo `(1, 0)` thì bộ gõ chỉ chạm được đúng một ký tự. Trang có thể tự hiểu sự kiện theo cách khác: Google Docs đóng mã, không biết.
  - Dấu đã đo (22/11/2026, 10.6 C): chuỗi của Google Docs ở Chrome dài hơn một ký tự, nhưng phần sau vị trí 1 không phải chữ sau con trỏ. Vùng `(0, 3)` vì vậy nằm trong chuỗi và không bị cắt; nó chạm cả ký tự trước con trỏ lẫn hai ký tự của phần sau. Google Docs không áp lần thay đó và tab hỏng tới khi tải lại trang.
- **Xoá một ký tự:** `insertText("", replacementRange: (0, 1))` thành một `textupdate` với chữ rỗng thay đoạn 0–1 (đọc mã). Google Docs có xoá ký tự đó trong mô hình của nó không thì không có nguồn. Google Docs đã áp đúng mọi lần thay một ký tự, nên nhiều khả năng là có (suy luận, cần kiểm chứng).
- **Bản sao cập nhật bất đồng bộ:**
  - Trang gọi `updateText` hay `updateSelection`. Khi vùng chọn đổi, EditContext báo cho frame.
  - Renderer lấy chữ quanh vùng chọn (tối đa 100 ký tự mỗi bên) từ EditContext và gửi lên tiến trình trình duyệt qua IPC.
  - `TextInputManager` báo cho view, view thay bản sao.
  - Cần mã JavaScript của trang chạy xong và một lượt IPC. Không có số đo thời gian (suy luận: cỡ vài mili giây tới một khung hình, chưa đo).
- **Hỏi lại trong cùng một phím thì không thấy gì mới:** Dấu đã đo ở Chrome. Trong lúc `handle` còn chạy, hỏi lại 10 lần, cách nhau 2 ms, bản sao vẫn y nguyên ([`docs/Compatibility.md`](../Compatibility.md) mục 6.2). Có lẽ luồng chính của Chrome đang bận trả lời lời gọi của bộ gõ nên chưa nhận tin từ renderer (suy luận). Vậy sửa nhiều bước chỉ chạy được sau khi `handle` đã trả về.
- **Không có đường đọc thêm chữ:** `attributedSubstring` chỉ cắt từ bản sao, ngoài đó trả nil. Chrome chỉ hỏi renderer đồng bộ cho vị trí hình học (chỉ số ký tự tại một điểm, khung của một đoạn), không cho chữ.

### 10.3 Safari

- WebKit chưa có EditContext: caniuse ghi Safari tới 27.2 không hỗ trợ; WebKit bug 269922 chưa kết luận. Nên Google Docs trong Safari phải nhận chữ bằng cách khác, có lẽ phần tử contenteditable ẩn như W3C tả trước đây (suy luận). Phần tử đó giữ bao nhiêu chữ: không có nguồn.
- Báo lỗi có Safari đều từ bộ gõ event tap (Backspace giả), không nói gì về vùng thay của IMK: OpenKey #89, EVKey #47, Gõ Nhanh #235.
- VietTelex: nội dung trang Safari đi thay tại chỗ, nhưng Google Docs trên Safari vẫn bị ép chữ đánh dấu (chú thích trong `App/Sources/AppState.swift`). Issue #37 là Safari ở chế độ chữ đánh dấu.
- Dấu đã đo (17/11/2026, ô `gdocssafari`): Google Docs trên Safari 27.2 cũng trả vị trí `(1, 0)` ở mọi phím; thay một ký tự được, hai ba ký tự không ([`docs/Compatibility.md`](../Compatibility.md) mục 5.10). Vậy cửa sổ một ký tự là cách Google Docs tự làm, không do EditContext.

### 10.4 Chuyển lại chữ đã chốt của bộ gõ tiếng Nhật

- Không có nguồn đáng tin. Một bài blog tiếng Nhật (đăng 2025, sửa 2026, không dẫn nguồn, không nói hệ điều hành hay trình duyệt) viết rằng Google Docs không có sẵn việc chuyển lại chữ đã chốt.
- Chuyển lại cần chữ quanh con trỏ, nên một cửa sổ một ký tự sẽ chặn nó (suy luận).

### 10.5 Các đường đã xét

| Đường | Kết quả |
|---|---|
| Vùng thay lớn hơn cửa sổ | đã đo, không được (thí nghiệm C dưới): Chrome không áp và tab hỏng tới khi tải lại trang; Safari chỉ thay một ký tự |
| Đọc thêm chữ quanh con trỏ | đã đo (thí nghiệm C): trước con trỏ chỉ một ký tự ở cả hai trình duyệt; vùng vượt quá chữ có sẵn trả nil |
| Hỏi lại trong cùng phím chờ cửa sổ trượt | bản sao không đổi trong lúc `handle` chạy (Dấu đo, mục 6.2 của Compatibility) |
| Sửa nhiều bước sau khi `handle` trả về | đã đo, không được (thí nghiệm A dưới) |
| Chữ đánh dấu mở rồi chốt ngay trong cùng phím | vùng thay của `setMarkedText` tính trong cùng chuỗi `editContext.text` (đọc mã `EditContext::SetComposition`), nên không với tới chữ cũ; và vẫn là chữ đánh dấu |
| Đọc hay sửa qua Accessibility | cần quyền Trợ năng, trái N4 |
| Sinh phím ⌫ thật | cần quyền gửi sự kiện, là cách event tap đã loại (`docs/Decisions.md` mục "Đã cân nhắc và loại bỏ") |
| Safari | đã đo: cũng `(1, 0)`, loại (mục 10.3) |
| Tuỳ chọn hỗ trợ tiếp cận của Google Docs | không làm (thí nghiệm B dưới) |
| `contextrequest` (prototype Chromium, 10/2026) | ngoài tầm Dấu: cần Chrome phát hành và Google Docs dùng. #156 còn hỏi cách trả lời bộ gõ hỏi đồng bộ, đúng trường hợp của macOS. Có thể góp ca tiếng Việt (thay hai, ba ký tự) vào issue đó |

### 10.6 Thí nghiệm đề xuất

Các thí nghiệm làm trên bản Debug và ghi riêng nhãn "bản thử" (ý "Bản thử không phải kết luận" của `CLAUDE.md`). Log không ghi chữ (D8 (Không telemetry)), chỉ ghi vị trí, độ dài, số bước, thời gian.

- **A. Sửa nhiều bước theo cửa sổ: đã đo 17/11/2026, không được.**
  - Cách làm: ở phím cần thay từ hai ký tự trở lên khi app báo `(1, 0)`, bộ gõ giữ phím; sau khi `handle` trả về, xoá ký tự trong cửa sổ bằng `insertText("", (0, 1))`, hỏi lại cách 1–2 ms (tối đa 300 ms mỗi bước) tới khi cửa sổ hiện ký tự kế trước, lặp lại, rồi ghi phần đuôi mới bằng một `insertText(đuôi, (0, 1))`; không trượt thì trả lại ký tự đã xoá. Log chỉ ghi số và lớp ký tự (D8). Mã thí nghiệm chỉ dựng ở bản Debug cho lượt đo này và không giữ lại trong repo: hướng này đã đóng.
  - Đo: máy M3 Max, Chrome 157.0.8103.79, Safari 27.2, câu không có ⌫ của mục 5.10 trong Compatibility, 80 ± 30 ms một phím.
  - Chrome (1 lượt có thí nghiệm chạy): lần nhìn đầu, cửa sổ chứa đúng chữ cuối của từ. Xoá xong, cửa sổ vẫn hiện chữ cũ rồi chuyển thành một dấu cách, không thành chữ kế trước, trong khoảng 100 ms trước khi phím kế tiếp (không phải chữ cái) làm thí nghiệm dừng và trả lại chữ đã xoá. Từ đó tab ấy không áp lần thay chữ nào nữa (hai lượt sau: 12 và 13 lần thay gửi đi, chữ không đổi: "hoc", "Viet", "voi"); tải lại trang thì về như cũ (một lượt đối chứng không bật thí nghiệm).
  - Safari (3 lượt, 19 lần thử): lần nào cũng dừng trước khi xoá gì vì cửa sổ không hiện chữ cuối của từ; 7 lần có ghi lớp ký tự, cả 7 là một ký tự vô hình (zero-width) Google Docs đặt sẵn. Chữ trong tài liệu không đổi.
  - Kết luận: không dùng được ở cả hai trình duyệt và ở Chrome còn làm hỏng ô nhập của Google Docs tới khi tải lại trang.
- **B. Đo chữ bộ gõ thấy khi bật tuỳ chọn hỗ trợ tiếp cận của Google Docs: không làm.**
  - Phần Safari đã đo ngày 17/11/2026 (mục 10.3). Chữ bộ gõ thấy khi chưa bật tuỳ chọn nào nằm ở thí nghiệm C.
  - Các tuỳ chọn hỗ trợ trình đọc màn hình (⌘⌥Z), chữ nổi (⌘⌥H) và kính lúp là cài đặt trong tài khoản Google của người dùng. Kể cả khi một tuỳ chọn cho bộ gõ thấy cả từ, đó chỉ là cách vòng mà người dùng phải tự bật, không phải cách sửa trong Dấu. Google cũng khuyên tắt chữ nổi nếu không dùng màn hình chữ nổi (mục 9). Vì vậy không đo.
- **C. Đọc rộng và gửi thẳng vùng thay rộng: đã đo 22/11/2026, không được.**
  - Cách làm: bản Debug ghi trước mỗi phím vị trí con trỏ, `length()` và kết quả đọc nhiều vùng (độ dài và số ký tự theo lớp, không ghi chữ). Ở lượt gửi thẳng, phím cần xoá N ký tự khi vị trí là 1 gửi `insertText(…, (0, N))` thay vì cho phím đi thẳng. Mã thí nghiệm không giữ lại trong repo.
  - Đo: máy M3 Max, Chrome 157.0.8103.79, Safari 27.2, câu không có ⌫, 80 ± 30 ms một phím; mỗi trình duyệt một lượt chỉ đọc và một lượt gửi thẳng. Số và chữ ra ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.10.
  - Kết luận: trước con trỏ chỉ có một ký tự ở cả hai trình duyệt, nên đọc rộng không cho thấy thêm chữ của từ. Gửi thẳng vùng rộng làm hỏng tab ở Chrome và chỉ thay một ký tự ở Safari. Đường này đã đóng.

## 11. Bộ gõ IMK cho tiếng khác

Câu hỏi: có bộ gõ IMK nào cho tiếng khác làm như Dấu (sửa chữ đã xuất bằng `insertText` có vùng thay, không dùng chữ đánh dấu) mà gõ đúng trong Google Docs không. Mã đọc ngày 18/11/2026, chỉ đọc, không chạy.

### 11.1 Keyman (SIL)

- Mã nguồn: https://github.com/keymanapp/keyman (MIT), thư mục `mac/Keyman4MacIM`, commit `e5b4e13`. Bộ gõ IMK cho hàng nghìn bàn phím: Amharic, Khmer, Myanmar, Thái, các tiếng châu Phi, tiếng Việt… Luật của bàn phím viết lại chữ ngay trước con trỏ, nên Keyman thường phải xoá và thay chữ đã xuất. Đây là cùng bài toán với Dấu.
- **Đọc và sửa chữ đã xuất (đọc mã `TextApiCompliance.m`, `KMInputMethodEventHandler.m`, `KeySender.m`):**
  - Keyman xếp mỗi client vào loại "tuân thủ" hay "không tuân thủ".
    - Phép kiểm: hỏi `selectedRange`. Sau lần chèn đầu, xem vị trí có dời đúng như dự kiến không: chèn khác độ dài chữ bị xoá thì vị trí phải đổi. Rồi đọc lại tối đa 80 ký tự trước con trỏ bằng `attributedSubstring` và xem có kết thúc bằng chữ vừa chèn không.
    - Chú thích trong mã ghi: nhiều app trả một vùng chọn hợp lệ nhưng sai, như `{0, 0}`, bất kể con trỏ ở đâu.
  - App tuân thủ: thay bằng một `insertText` có vùng thay tính từ `selectedRange` hiện tại. Xoá mà không chèn thì thay hai ký tự bằng một. Chú thích trong mã nói `insertText` với chuỗi rỗng kèm vùng thay bị coi là lời gọi không hợp lệ và bị bỏ qua.
  - App không tuân thủ:
    - Keyman chỉ dùng ngữ cảnh nó tự nhớ.
    - Keyman xoá bằng phím ⌫ giả gửi qua `CGEventPost`, rồi gửi một mã phím riêng tới đúng tiến trình đó để biết các phím ⌫ đã được xử lý xong, rồi mới chèn chữ mới.
    - Cách này cần quyền Trợ năng hoặc quyền gửi sự kiện (`Privacy/PrivacyConsent.m`). Trang trợ giúp nói thiếu quyền thì có thể có chữ lặp hoặc chữ không bị xoá.
  - Có một danh sách app không tuân thủ ghi cứng và một danh sách người dùng tự thêm (khoá `KMLegacyApps`, có thể viết bằng biểu thức chính quy). Keyman tự phát hiện nhiều app (như của Adobe), không cần ghi cứng.
- **Google Docs và trình duyệt:**
  - `com.google.Chrome` nằm trong danh sách ghi cứng, kèm chú thích ngày 13/12/2023: phải ghi cứng Chrome vì Google Docs trả một vị trí tương đối nhưng sai, nên không cách nào tự phát hiện. Vậy **cả Chrome**, mọi trang, đi đường ⌫ giả. VS Code và Slack cũng bị ghi cứng (2026): xoá thừa một ký tự khi chèn có vùng thay.
  - KB0118 ("Compliant and Non-compliant Applications"): app không hỗ trợ API thay hay xoá chữ thì Keyman sinh phím ⌫. Cách này có thể ra chữ sai khi app xoá nhiều hơn Keyman định. Trên macOS, app không tuân thủ thường trả 0 hay một hằng số bất kể người dùng gõ ở đâu.
  - Issue #10246 (12/2023, Google Docs trên Chrome): ⌫ qua chữ có dấu tổ hợp xoá luôn chữ trước. Người bảo trì ghi rằng hành vi đó không thể phát hiện trong lúc nó xảy ra. Đóng năm 2026 với ghi chú "chạy đúng ở Keyman 19 beta", có thể do Google sửa.
  - Issue #11942 (2024, Amharic, Google Docs trên Safari): sau khi dời con trỏ bằng mũi tên, bàn phím bỏ qua ngữ cảnh. Người bảo trì trả lời Safari không phải app tuân thủ, nên Keyman không đọc được ngữ cảnh khi con trỏ dời. Safari không có trong danh sách ghi cứng, nên đây là kết quả tự phát hiện (suy luận).
  - Issue #14879 (2025, macOS 26): Google Sheets trên Safari lặp chữ, Google Docs trên Safari chỉ ra chữ Latin; hết ở macOS 26.2 và Safari 26.2. Chrome chạy đúng.
  - Issue #6656 (2022): sai chữ ở Word trên web (Chrome) và Google Docs trên Safari; đóng 2026 với ghi chú chạy đúng ở Keyman 19 beta.
- **Dấu học được gì:**
  - Phép kiểm "vị trí có dời sau lần chèn đầu" giống ý của Phím Việt (mục 3). Keyman cũng kết luận rằng Google Docs không bị phép kiểm đó bắt được. Đường lui của Keyman là ⌫ giả, Dấu không làm được (N4; mục "Đã cân nhắc và loại bỏ" của `docs/Decisions.md`).
  - Keyman, bộ gõ IMK nhiều năm tuổi với chính bài toán của Dấu, không tìm ra cách thay tại chỗ trong Google Docs chỉ bằng API của IMK.

### 11.2 Các bộ gõ IMK khác

| Bộ gõ | Thứ tiếng | Sửa chữ đã xuất | Google Docs |
|---|---|---|---|
| macSKK (https://github.com/mtgto/macSKK, commit `e05095c`) | Nhật | chữ đánh dấu. "Huỷ chốt" (確定アンドゥ) đưa chữ vừa chốt về chữ đánh dấu bằng `setMarkedText` có vùng thay, **chỉ sau khi** đọc `attributedSubstring` thấy đúng chữ đó ở vị trí đó. Terminal chỉ nhận vùng kết thúc ngay trước con trỏ; iTerm2 và Hyper không dùng vùng thay | không có xử lý riêng; tìm issue không có kết quả |
| Gureum (https://github.com/gureum/gureum, commit `46c62e5`) | Hàn | chữ đánh dấu | issue #705 (2020, Chrome): sau chữ Hàn chỉ gõ được một chữ số hay ký hiệu, không gõ liền được; một người báo bản mới đã hết |
| Squirrel / Rime (https://github.com/rime/squirrel, commit `b7970a9`) | Trung | chữ đánh dấu, chốt bằng `insertText` không có vùng thay | #345, #975: khung chọn chữ không theo con trỏ (mục 9); #6 (2012): hai dấu câu |
| OpenVanilla (https://github.com/openvanilla/openvanilla, commit `ecf3260`) | Trung, nhiều bảng mã | chữ đánh dấu | không thấy |
| iAvro (https://github.com/torifat/iAvro, commit `645c505`) | Bangla | chữ đánh dấu, chốt khi chọn chữ | không thấy |
| Lipika (bản fork https://github.com/HughP/Lipika_IME, commit `12003ca`, 2014) | các tiếng Ấn Độ | mã cũ: đọc chữ trước con trỏ bằng `attributedSubstring`, kéo nó về chữ đánh dấu bằng `setMarkedText` có vùng thay lùi về trước | không thấy. Kho gốc mới hơn không tìm được |

- Bộ gõ riêng cho Amharic, Myanmar, Thái, Tamil, Sinhala, Mông Cổ trên macOS: không tìm được dự án IMK mã mở nào ngoài Keyman. Các thứ tiếng này trên macOS thường gõ bằng bàn phím của Keyman.
- Ý của macSKK và Lipika (kéo chữ đã chốt về chữ đánh dấu bằng vùng thay) vẫn là chữ đánh dấu. Ở Google Docs nó cũng vướng cửa sổ một ký tự: vùng thay của `setMarkedText` tính trong cùng chuỗi đó (mục 10.5).

### 11.3 Chuyển lại tiếng Nhật trong Google Docs

- Không tìm được nguồn chính (Google, Apple, ATOK, Google Japanese Input, macSKK, Azooky) nói chuyển lại chạy hay không trong Google Docs trên macOS.
- Nguồn thứ cấp duy nhất là một blog (mục 10.4) viết rằng Google Docs không có sẵn việc chuyển lại chữ đã chốt; bài không dẫn nguồn, không nói hệ điều hành.
- Theo cửa sổ một ký tự Dấu đo được, chuyển lại cả một từ không thể có (suy luận).

### 11.4 Hướng dẫn của Google

- **Công cụ nhập liệu dựng sẵn của Google Docs:** trang trợ giúp "Translate documents or write in a different language" viết rằng menu Input tools hiện trên thanh công cụ khi chọn một ngôn ngữ không dùng chữ Latin (ví dụ tiếng Hindi, tiếng Trung). Menu có gõ theo âm, bàn phím ảo hoặc phím thật, viết tay; mở bằng ⌘⌥⇧K. Trang không nói gì về tiếng Việt hay bộ gõ của hệ điều hành.
- **Google Input Tools** (trang danh sách ngôn ngữ): tiếng Việt có "IME", bàn phím Telex, TCVN, VIQR và viết tay. Trang không nói công cụ nào có trong Google Docs. Trang dịch vụ liệt kê Search, Gmail, Drive, Translate, YouTube, không có Docs.
- Tiện ích Chrome AVIM (gõ tiếng Việt bên trong trang, không phải bộ gõ của hệ điều hành) ghi Google Docs trong mục "WHERE IT WORKS" (cập nhật 08/09/2026). Đây là mã chạy trong trang, Dấu không dùng được cách này (suy luận).
- **Hỗ trợ bộ gõ cần chữ quanh con trỏ:** không tìm thấy trang nào của Google Docs nói về vấn đề này. Phía Chromium và W3C chỉ có đề xuất `contextrequest` (mục 10.1), đang ở giai đoạn prototype.

## Nguồn

Kho mã (đọc ngày 17 và 18/11/2026, commit ghi ở từng mục):

- VietTelex: https://github.com/ptrinh/VietTelex ; issue #37: https://github.com/ptrinh/VietTelex/issues/37
- XKey: https://github.com/xmannv/xkey ; issue #97: https://github.com/xmannv/xkey/issues/97
- Phím Việt: https://github.com/phamcongdanh98/Phim_Viet
- fcitx5-macos: https://github.com/fcitx-contrib/fcitx5-macos ; fcitx5-unikey: https://github.com/fcitx/fcitx5-unikey ; fcitx5-bamboo: https://github.com/fcitx/fcitx5-bamboo
- KeyIn: https://github.com/tuoitrevohoc/KeyIn ; VietIME: https://github.com/truongtv91/VietIME ; InputKey: https://github.com/vuminhquang/InputKey ; GoTiengViet (isthaison): https://github.com/isthaison/gotiengviet
- OpenKey: https://github.com/tuyenvm/OpenKey/issues/89 ; https://github.com/tuyenvm/OpenKey/issues/171
- EVKey: https://github.com/lamquangminh/EVKey/issues/47
- Gõ Nhanh: https://github.com/khaphanspace/gonhanh.org ; issue #235: https://github.com/khaphanspace/gonhanh.org/issues/235
- PHTV: https://github.com/phamhungtien/PHTV ; issue #134: https://github.com/phamhungtien/PHTV/issues/134
- goxkey: https://github.com/huytd/goxkey ; DauKey: https://github.com/emizuki/daukey ; VnKey: https://github.com/marixdev/vnkey
- Squirrel: https://github.com/rime/squirrel/issues/345 ; https://github.com/rime/squirrel/issues/975
- Keyman: https://github.com/keymanapp/keyman (thư mục `mac/Keyman4MacIM`) ; issue #10246: https://github.com/keymanapp/keyman/issues/10246 ; #11942: https://github.com/keymanapp/keyman/issues/11942 ; #14879: https://github.com/keymanapp/keyman/issues/14879 ; #6656: https://github.com/keymanapp/keyman/issues/6656
- Keyman KB0118: https://help.keyman.com/kb/118 ; quyền trên macOS: https://help.keyman.com/products/mac/19.0/troubleshooting/configure-security
- macSKK: https://github.com/mtgto/macSKK ; Gureum: https://github.com/gureum/gureum ; issue #705: https://github.com/gureum/gureum/issues/705 ; OpenVanilla: https://github.com/openvanilla/openvanilla ; iAvro: https://github.com/torifat/iAvro ; Lipika (fork): https://github.com/HughP/Lipika_IME ; Squirrel: https://github.com/rime/squirrel

Chromium, chuẩn web, Google:

- Chromium, `render_widget_host_view_cocoa.mm`: https://chromium.googlesource.com/chromium/src/+/main/content/app_shim_remote_cocoa/render_widget_host_view_cocoa.mm
- Blink, `input_method_controller.cc`: https://chromium.googlesource.com/chromium/src/+/main/third_party/blink/renderer/core/editing/ime/input_method_controller.cc
- Intent to Ship: EditContext API: https://groups.google.com/a/chromium.org/g/blink-dev/c/yOxNDSaviyU
- EditContext explainer (W3C): https://w3c.github.io/editing/docs/EditContext/explainer.html
- Chrome for Developers, EditContext: https://developer.chrome.com/blog/introducing-editcontext-api
- Google Docs Editors Help, trình đọc màn hình và chữ nổi: https://support.google.com/docs/answer/6282736
- Google Workspace Updates, chữ nổi (31/08/2020): https://workspaceupdates.googleblog.com/2020/08/improved-braille-google-docs-accessibility.html
- gcs.vn, "Google Docs bị nhảy chữ": https://gcs.vn/google-docs-bi-nhay-chu/
- Chromium, `render_widget_host_view_mac.mm`: https://chromium.googlesource.com/chromium/src/+/main/content/browser/renderer_host/render_widget_host_view_mac.mm
- Chromium, `render_frame_impl.cc` (`SyncSelectionIfRequired`): https://chromium.googlesource.com/chromium/src/+/main/content/renderer/render_frame_impl.cc
- Blink, `edit_context.cc`: https://chromium.googlesource.com/chromium/src/+/main/third_party/blink/renderer/core/editing/ime/edit_context.cc
- Blink, `runtime_enabled_features.json5`: https://chromium.googlesource.com/chromium/src/+/main/third_party/blink/renderer/platform/runtime_enabled_features.json5
- W3C edit-context issue #151 (Google Docs dùng EditContext vô hình): https://github.com/w3c/edit-context/issues/151
- W3C edit-context issue #156 (lấy chữ theo yêu cầu): https://github.com/w3c/edit-context/issues/156 ; issue #107: https://github.com/w3c/edit-context/issues/107
- Intent to Prototype: EditContext On-Demand Text & Selection Updates (20/10/2026): http://www.mail-archive.com/blink-dev@chromium.org/msg17807.html
- WebKit bug 269922: https://bugs.webkit.org/show_bug.cgi?id=269922 ; caniuse EditContext: https://caniuse.com/mdn-api_editcontext
- Blog tiếng Nhật về chuyển lại trong Google Docs (nguồn thứ cấp): https://m32006400n.xsrv.jp/infrastructure/googledocument-1000/
- Google Docs Editors Help, công cụ nhập liệu: https://support.google.com/docs/answer/187189
- Google Input Tools, ngôn ngữ: https://www.google.com/inputtools/help/languages.html ; dịch vụ: https://www.google.com/inputtools/services/
- AVIM (tiện ích Chrome): https://chromewebstore.google.com/detail/avim-vietnamese-input-met/opgbbffpdglhkpglnlkiclakjlpiedoh

Apple (`NSTextInputClient`; `selectedRange` tính từ đầu kho chữ của ô nhận, từ 0 tới độ dài tài liệu):

- https://developer.apple.com/documentation/appkit/nstextinputclient/selectedrange()
- https://developer.apple.com/documentation/appkit/nstextinputclient/attributedsubstring(forproposedrange:actualrange:)
- https://developer.apple.com/documentation/appkit/nstextinputclient/inserttext(_:replacementrange:)
- https://developer.apple.com/documentation/appkit/nstextinputclient/setmarkedtext(_:selectedrange:replacementrange:)
