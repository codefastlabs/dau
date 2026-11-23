# Tương thích ứng dụng

Tài liệu này ghi Dấu gõ đúng hay sai trong từng ứng dụng, ở nhịp nào và vì sao, cùng các giới hạn còn lại và cách thử. Mọi số đo được lấy trên máy M1 (M1 Pro), macOS 27.2, trừ các lượt trên máy M3 Max (Chrome khi trang bận, phím dồn ở Chrome và Firefox, 10/11/2026). Ô nào chưa thử thì để trống, không điền bằng phỏng đoán. Đây không phải lời hứa (N5 (Chỉ hứa điều đã kiểm chứng)); trang web chỉ dùng kết quả theo [`docs/Website.md`](Website.md).

## Hiện trạng (23/11/2026)

Tiêu chí của nhãn "Đề xuất" nằm ở D13 (Gạch chân là đường lui cuối cùng). Nhịp là khoảng cách giữa hai phím khi tự gõ. Gửi cả chuỗi một lần (0 ms) không phải tốc độ gõ thật, nên không là tiêu chí. Chi tiết và điều kiện đo nằm ở mục 5.

Dưới tải nặng (`scripts/selftest/load/heavy.sh`, 22/11/2026, sau khi Dấu tự chèn ký tự, một lượt, máy M3 Max), chữ đúng ở mọi ô của Dấu ở Safari, Chrome và VS Code. Thời gian mỗi phím cùng bộ nhớ đều đạt ngưỡng D42 (Ngưỡng hiệu năng). Số chi tiết nằm ở nhật ký [`docs/Progress.md`](Progress.md) ngày 22/11.

| Ứng dụng | Thay tại chỗ | Gạch chân | Nhãn "Đề xuất" |
|---|---|---|---|
| Safari, TextEdit | Đúng ở 30 ms (29–30/10/2026) và ở 120 ms (Backspace, thêm dấu). Từ khi Dấu tự chèn ký tự (N3, 22/11/2026, máy M3 Max), Safari 27.2 đúng khi gửi cả chuỗi một lần (3/3), khi trang bận ở nhịp người gõ nhanh (3/3), ở ô mũi tên khi trang bận (3/3) và ở ca ⌫ rồi phím dấu ngay sau khi trang bận (3/3 ở hai ô, nhờ ngoại lệ chờ ⌫ chưa áp của N3). Xem mục 5.1. | Đúng, kể cả khi gửi cả chuỗi một lần (2/2, 22/11/2026). | không |
| Chrome | Đúng ở 5–20 ms (10/11/2026, máy M3 Max) và trong trình soạn thảo TipTap (9/9, 12/11/2026). Từ khi Dấu tự chèn ký tự (N3, 22/11/2026, máy M3 Max, Chrome 157), khi trang bận ở nhịp người gõ nhanh Dấu đúng 3/3, rồi 5/6 với ngoại lệ chờ ⌫. Sau bản sửa phép chứng minh app chậm (22/11/2026, Chrome 158), Dấu đúng 9/9 khi trang bận ở nhịp người gõ nhanh và 9/9 khi trang bận ở 10 ms (trước đó sai 5/5). Xem mục 5.2. | Đúng ở 0 ms. | không |
| Edge | Đúng ở 5–20 ms và khi trang bận (10/11/2026, máy M1; 17/11/2026, Edge 157.0.4341.60). | Đúng ở 0 ms. | không |
| Firefox | Đúng ở 5–20 ms (10/11/2026, máy M3 Max) và khi trang bận (10/11/2026, máy M1; 17/11/2026, Firefox 160.0; 22/11/2026, máy M3 Max, Firefox 160.0.1, sau khi Dấu tự chèn ký tự, 2/2 ở 10 ms và nhịp người gõ nhanh). | Đúng ở 0 ms. | không |
| VS Code | Đúng ở 5–20 ms: 14/15 lượt (10/11/2026, VS Code 1.145.2) và 2/2 lượt (17/11/2026, VS Code 1.146.0, mỗi lượt sau một ô Telex của Apple), máy M1 (mục 5.3). Đúng 15/15 tới khoảng 8,5 ms một phím và khi gửi cả chuỗi một lần (18/11/2026, máy M1 Pro, mục 5.1). | Đúng ở 0 ms. | không |
| Cursor (3.30.14) | Khung agent (⌘L) và ô nhập Agents đúng ở 5 ms. Trình soạn thảo đúng khi trả vị trí từ đầu văn bản và sai vài từ ở 5 ms khi trả vị trí từ đầu từ (mục 5.4; ngày 22/11/2026 sai 1 từ, "kế" ra "ke"). | chưa đo | không |
| Terminal | Đúng ở 30 và 120 ms (12/11/2026; 30 ms lại đúng 1/1 ngày 17/11/2026). Từ khi Dấu tự chèn ký tự (22/11/2026), kết quả là 5 ms 2/2, 10 ms 4/5, 20 ms 2/2, nên Dấu còn sai khi phím dồn. ⌫ không tới bộ gõ (mục 5.5, 6.5). | Đúng ở 5–20 ms (17/11/2026), sai ở 0 ms. | **có** |
| Ghostty | Sai, vì app bỏ qua vùng thay và Dấu không xử lý riêng (D43; mục 6.8). | Chữ đúng, nhưng Return ngay sau từ bị nuốt. | **có** |
| xterm.js (trang thử trong Chrome) | Sai (D43; mục 6.8). | Đúng. | không |
| Terminal tích hợp của VS Code (xterm.js) | Sai (D43). Trình soạn thảo cùng cửa sổ vẫn đúng sau khi chuyển từ terminal sang (mục 6.8). | Đúng, cả khi chuyển sang trình soạn thảo. | không: bật cho cả app thì mọi ô mất D20 |
| Sublime Text | Đúng, kể cả thêm dấu cho từ đã gõ sau ⌫ và sau ←. Đo lại sau khi Dấu tự chèn ký tự (23/11/2026, 30 ms) vẫn đúng. | Không thêm dấu được cho từ đã chốt. | không |
| Zed | Đúng ở 30 ms, kể cả ⌫ và thêm dấu cho từ đã gõ (23/11/2026, mục 5.11). | chưa đo | không |
| Xcode | Đúng ở 30 ms trên tệp văn bản, kể cả ⌫ và thêm dấu cho từ đã gõ (23/11/2026, mục 5.11). | chưa đo | không |
| WebStorm, trình soạn thảo | Chữ tiếng Việt đúng ở 80 ms. Từ tiếng Anh không được khôi phục (D4); đây là lỗi của Dấu, chưa sửa (mục 5.9). | Đúng ở 80 ms. | không |
| WebStorm, terminal | Sai (D43; mục 6.8). | Đúng ở 80 ms. | không: bật cho cả app thì mọi ô mất D20 |
| Notes | Đúng ở 30 ms (30/10/2026). | chưa đo | không |
| Mail | Đúng ở 30 ms (30/10/2026). Số đo ngày 11/11 (120 ms) và 12/11/2026 (30 ms) chỉ nói về tự sửa chính tả của macOS (mục 6.1). | chưa đo | không |
| Telegram | Đúng ở 5 và 30 ms (chuỗi chuẩn) và ở 100 ± 30 ms (chuỗi `edit`), ngày 17/11/2026 (mục 5.8). | chưa đo | không |
| Antigravity | Ô nhắn tin đúng ở 30 ms, kể cả ⌫ và thêm dấu cho từ đã gõ (23/11/2026, mục 5.11). | chưa đo | không |
| Obsidian | Đúng ở 30 ms, kể cả ⌫ và thêm dấu cho từ đã gõ (23/11/2026, mục 5.11). | chưa đo | không |
| Notion | Đúng ở 30 ms, kể cả ⌫ và thêm dấu cho từ đã gõ (23/11/2026, mục 5.11). | chưa đo | không |
| Word trên web (Chrome) | Đúng ở 80 ± 30 ms, kể cả thêm dấu cho từ đã gõ: 6/6 lượt (17/11/2026, máy M3 Max) và 9/9 sau khi Dấu tự chèn ký tự (22/11/2026, Chrome 158); mục 5.10. | Mất ký tự đầu tiên của tài liệu trống, 6/6 (22/11/2026), như Telex của Apple; mục 5.10. | không |
| Google Docs (Chrome) | Sai 3/3 lượt ở 80 ± 30 ms (17/11/2026, máy M3 Max). Dấu không thêm dấu được cho từ đã gõ và sai mọi lần thay quá một ký tự, nên sai cả chữ gõ liền mà Telex của Apple gõ đúng. Lý do là Google Docs luôn trả vị trí con trỏ là (1, 0), nên Dấu chỉ thay được một ký tự (mục 5.10). | Chữ gõ liền đúng 5/5 (23/11/2026, Chrome 158); không thêm dấu cho từ đã chốt (mục 6.8). Mục 5.10. | không |

- Brave, Arc và các app Electron khác không có nhãn. Chúng chưa được đo, nên chưa có số đo nào cho thấy sai (D13). Kết quả của Chrome, Edge, VS Code hay Cursor không được suy ra cho các app này, vì kết quả đo ở app này không suy ra cho app kia. Nếu đo mà thấy sai thì gắn lại nhãn theo D13.
- Với trình duyệt, script chỉ gõ khi ô của trang có focus, nên mọi số đo trình duyệt là gõ vào ô của trang.
- 21 trong 44 ứng dụng ở mục 3 có số đo (với JetBrains IDE thì chỉ có WebStorm). Danh sách chưa đo nằm ở mục 7.

## 1. Danh sách tương thích

- Danh sách có sẵn trong bản build, ở `Apps/Dau/Resources/CompatibilityList.json`, với model `CompatibilityList` trong DauShared. Mỗi mục gồm bundle ID, cờ `suggestUnderline` và ghi chú cho người bảo trì.
- Danh sách đi kèm app và đổi theo bản cập nhật app, không tải riêng (D7 (Cập nhật và loại bản dựng)). Tiến trình bộ gõ không tải gì (N2 (Bộ gõ không có quyền mạng)).
- Ứng dụng có `suggestUnderline` hiện ở mục "Đề xuất" của trang Ứng dụng (D5 (Quy tắc theo ứng dụng); hành vi nằm ở [`docs/UI.md`](UI.md), mục "Ứng dụng"). Mặc định mọi ứng dụng đều không gạch chân. Người dùng tự bật.
- Ứng dụng nào được gắn nhãn thì theo D13. Bundle ID lấy từ mục 3.

## 2. Vì sao ghi công nghệ giao diện

Dấu thay chữ tại chỗ: ở phím có thay chữ, Dấu hỏi `selectedRange` một lần rồi gọi `insertText(_:replacementRange:)` (D11 (Kiểm tra ngữ cảnh), N3 (Ít lời gọi vào ứng dụng đích)). Cách này cần ứng dụng trả vị trí con trỏ đúng vào lúc hỏi và thay theo vùng thay. Trước khi đo, công nghệ giao diện là dấu hiệu dự đoán tốt nhất:

- AppKit (TextEdit, Notes) áp phím ngay và chưa thấy lỗi.
- WebKit (Safari) giữ phím đi thẳng trong một hàng riêng khi trang bận hay khi phím dồn, còn lời gọi của bộ gõ tới trang ngay. Vì vậy Dấu tự chèn mọi ký tự (N3, mục 5.1).
- Chromium, Electron và Terminal áp phím bất đồng bộ và trả vị trí cũ khi phím dồn hay khi app bận (mục 6.2).
- Terminal tự vẽ (Ghostty) và xterm.js bỏ qua vùng thay (mục 6.8).
- Với client không hỗ trợ TSMDocumentAccess, `selectedRange` trả `NSNotFound` và `replacementRange` bị bỏ qua. Header `IMKInputSession.h` của SDK macOS 27.0 ghi trường hợp này là "cực kỳ hiếm". Bộ gõ đếm trường hợp này là `unsupported`. Trường hợp này chưa gặp ở ứng dụng nào. Trang tài liệu web của `IMKTextInput` trả 404 ([`docs/research/IMKAPINotes.md`](research/IMKAPINotes.md)). Tài liệu phía ứng dụng nằm ở https://developer.apple.com/documentation/appkit/nstextinputclient/selectedrange() và https://developer.apple.com/documentation/appkit/nstextinputclient/inserttext(_:replacementrange:)
- Gạch chân dùng `setMarkedText(_:selectionRange:replacementRange:)` và không hỏi vị trí, nên không bị lỗi bất đồng bộ; đổi lại, chế độ này không có D20 (Thêm dấu cho từ đã gõ).

## 3. Ứng dụng và công nghệ giao diện

Cột "Máy này" tra trong `/Applications`, `~/Applications`, `/System/Applications`, `/System/Library/CoreServices` và bằng `mdfind kMDItemCFBundleIdentifier == '…'`. Phiên bản là `CFBundleShortVersionString` vào lúc tra (với Cursor, Ghostty, Sublime Text là lúc đo). Chrome, Edge, Firefox, VS Code, Cursor, Safari, Terminal, Ghostty, Sublime Text, Notes, Mail, Telegram và WebStorm tra lại ngày 17/11/2026; Zed, Xcode, Antigravity, Notion và Obsidian tra ngày 23/11/2026; các dòng khác tra ngày 30/10/2026. Cột cuối ghi phiên bản lúc đo nếu nhật ký có và ghi "không rõ" nếu không có. Công nghệ đọc từ bundle (`Contents/Frameworks`, `otool -L`, không mở app); với app không có trên máy, cột này ghi "suy luận". "web" nghĩa là thử trong trình duyệt. Cột cuối là kết quả đo (mục 5) hoặc dự đoán (suy luận).

| Nhóm | Ứng dụng | Bundle ID | Máy này | Công nghệ giao diện | Kết quả hoặc dự đoán |
|---|---|---|---|---|---|
| Hệ thống | TextEdit | `com.apple.TextEdit` | có (1.21) | AppKit (NSTextView) | đã đo, mục 5.1 (phiên bản lúc đo: không rõ) |
| Trình duyệt | Safari | `com.apple.Safari` | có (27.2) | WebKit | đã đo, mục 5.1 (lúc đo: 27.2 ngày 17/11/2026; các lượt trước: không rõ) |
| Trình duyệt | Chrome | `com.google.Chrome` | có (157.0.8103.79) | Chromium | đã đo, mục 5.2 (lúc đo: 157 ngày 17/11/2026; các lượt trước: không rõ) |
| Trình duyệt | Firefox | `org.mozilla.firefox` (Nightly: `org.mozilla.nightly`) | có (160.0; Nightly 162.0a1) | Gecko | đã đo, mục 5.2 (lúc đo: 160.0 ngày 17/11/2026; các lượt trước: không rõ) |
| Trình duyệt | Edge | `com.microsoft.edgemac` | có (157.0.4341.60) | Chromium (`Microsoft Edge Framework`) | đã đo, mục 5.2 (lúc đo: 157.0.4341.60 ngày 17/11/2026; các lượt trước: không rõ) |
| Trình duyệt | Arc | `company.thebrowser.Browser` | không | Chromium (suy luận) | như Chrome |
| Trình duyệt | Brave | `com.brave.Browser` | không | Chromium (suy luận) | như Chrome |
| Soạn mã | VS Code | `com.microsoft.VSCode` | có (1.146.0) | Electron | đã đo, mục 5.3 (lúc đo: 1.146.0 ngày 17/11/2026; 1.145.2 ngày 10/11/2026) |
| Soạn mã | Cursor | `com.todesktop.230313mzl4w4u92` | có (3.30.14) | Electron (dựng từ VS Code) | đã đo, mục 5.4 (lúc đo: 3.30.14) |
| Soạn mã | Zed | `dev.zed.Zed` | có (1.29.2) | tự vẽ bằng Metal (GPUI, Rust), vỏ AppKit | đã đo, mục 5.11 (lúc đo: 1.29.2) |
| Soạn mã | Sublime Text | `com.sublimetext.4` | có (Build 4215) | tự vẽ, vỏ AppKit | đã đo, mục 5.7 (lúc đo: Build 4215) |
| Soạn mã | JetBrains IDE | `com.jetbrains.WebStorm`; khác: `com.jetbrains.intellij`, `com.jetbrains.intellij.ce`, `com.jetbrains.pycharm`, `com.jetbrains.goland`, `com.google.android.studio` | WebStorm có (2026.3, `~/Applications`); các ID khác không | Java (JetBrains Runtime); terminal Reworked dựng trên trình giả lập Ghostty VT | WebStorm đã đo, mục 5.9 (lúc đo: 2026.3) |
| Soạn mã | Xcode | `com.apple.dt.Xcode` | có (27.2) | AppKit, trình soạn mã riêng | đã đo trên tệp văn bản, mục 5.11 (lúc đo: 27.2); có gợi ý hoàn thành mã, chưa đo ở tệp mã |
| Soạn mã | Antigravity | `com.google.antigravity` | có (2.33.0) | Electron; bản 2.x là app agent, chỉ có ô nhắn tin | đã đo, mục 5.11 (lúc đo: 2.33.0) |
| Terminal | Terminal | `com.apple.Terminal` | có (2.15) | AppKit, chờ shell in lại chữ | đã đo, mục 5.5 (lúc đo: 2.15 ngày 17/11/2026; các lượt trước: không rõ) |
| Terminal | iTerm2 | `com.googlecode.iterm2` | không | AppKit (suy luận) | như Terminal (suy luận) |
| Terminal | Warp | `dev.warp.Warp-Stable` | không | tự vẽ bằng Metal, Rust (suy luận) | chưa biết |
| Terminal | Ghostty | `com.mitchellh.ghostty` | có (1.4.0) | AppKit + SwiftUI, vẽ bằng Metal | đã đo, mục 5.6 (lúc đo: 1.4.0) |
| Chat | Zalo | `com.vng.zalo` | có (26.10.10) | Electron | như VS Code (suy luận) |
| Chat | Messenger | web (`messenger.com`, `facebook.com`) | web | trình duyệt | theo trình duyệt. Meta ngừng app Messenger cho Mac từ 15/12/2025 ([TechCrunch](https://techcrunch.com/2025/10/16/meta-to-shut-down-messenger-desktop-apps-for-mac-and-windows/), [AppleInsider](https://appleinsider.com/articles/25/12/15/facebook-messenger-for-macos-departs-the-desktop)) |
| Chat | Telegram | `ru.keepcoder.Telegram` | có (13.1.0) | AppKit, Swift ("Telegram for macOS") | đã đo, mục 5.8 (lúc đo: 13.1.0) |
| Chat | Telegram Desktop | `org.telegram.desktop` | không | Qt (suy luận) | chưa biết; đại diện nhóm Qt |
| Chat | Discord | `com.hnc.Discord` | có (0.0.415) | Electron | như VS Code (suy luận) |
| Chat | Slack | `com.tinyspeck.slackmacgap` | không | Electron (suy luận) | như VS Code (suy luận) |
| Chat | Microsoft Teams | `com.microsoft.teams2` (bản cũ `com.microsoft.teams`) | không | web view (suy luận) | chưa biết |
| Văn phòng | Word | `com.microsoft.Word` | không | vỏ AppKit, bộ soạn chữ riêng (suy luận) | chưa biết |
| Văn phòng | Excel | `com.microsoft.Excel` | không | như Word (suy luận) | chưa biết; ô bảng tính có chế độ sửa riêng |
| Văn phòng | PowerPoint | `com.microsoft.Powerpoint` | không | như Word (suy luận) | chưa biết |
| Văn phòng | Pages | `com.apple.Pages` (bản "Creator Studio" 15.4) và `com.apple.iWork.Pages` (14.5) | có, cả hai bản | AppKit, bộ soạn chữ riêng của iWork | chưa biết; quy tắc phải ghi cả hai ID |
| Văn phòng | Numbers | `com.apple.Numbers` (Creator Studio 15.4); ID cũ `com.apple.iWork.Numbers` không có trên máy | có | như Pages | chưa biết; ô bảng tính |
| Văn phòng | Keynote | `com.apple.Keynote` (Creator Studio 15.4); ID cũ `com.apple.iWork.Keynote` không có trên máy | có | như Pages | chưa biết |
| Văn phòng | Google Docs | web | web | trình duyệt; vẽ bằng canvas từ 2021 ([Google Workspace Updates](https://workspaceupdates.googleblog.com/2021/05/Google-Docs-Canvas-Based-Rendering-Update.html)), chữ nhập qua một ô ẩn (suy luận) | đã đo, mục 5.10: sai (lúc đo: Chrome 157.0.8103.79) |
| Văn phòng | Word trên web | web | web | trình duyệt | đã đo, mục 5.10: đúng (lúc đo: Chrome 158.0.8127.37) |
| Văn phòng | Google Sheets | web | web | trình duyệt | chưa biết |
| Văn phòng | Notion | `notion.id` | có (7.44.1) | Electron, trình soạn khối riêng | đã đo, mục 5.11 (lúc đo: 7.44.1) |
| Văn phòng | Obsidian | `md.obsidian` | có (1.15.1) | Electron, trình soạn thảo CodeMirror | đã đo, mục 5.11 (lúc đo: 1.15.1) |
| Apple | Ghi chú (Notes) | `com.apple.Notes` | có (4.13) | AppKit | đã đo, mục 5.8 (lúc đo: 4.13) |
| Apple | Mail | `com.apple.mail` | có (16.0) | AppKit; khung soạn thư dùng WebKit (suy luận) | đã đo, mục 5.8 (lúc đo: 16.0) |
| Apple | Tin nhắn (Messages) | `com.apple.MobileSMS` | có (26.0) | Mac Catalyst | chưa biết |
| Apple | Spotlight | `com.apple.Spotlight` | có | giao diện hệ thống | chưa biết; ô tìm có gợi ý tự hoàn thành |
| Apple | Finder (đổi tên tệp) | `com.apple.finder` | có (27.2) | AppKit | thấp (suy luận) |
| Khác | Figma | `com.figma.Desktop` | có (126.11.7) | Electron, nội dung vẽ bằng canvas | rủi ro cao (suy luận) |
| Khác | Raycast | `com.raycast.macos` | không | AppKit (suy luận) | chưa biết; ô tìm có gợi ý |
| Khác | Alfred | `com.runningwithcrayons.Alfred` | không | AppKit (suy luận) | chưa biết; ô tìm có gợi ý |

Bundle ID mà bộ gõ thật sự nhận có thể khác cột trên, ví dụ khi đó là tiến trình con của trình duyệt. Khi thử, hãy đọc ID từ `scripts/perf/perf-report.sh` (mục 4.4) và sửa cột nếu khác.

## 4. Cách thử

### 4.1 Chuẩn bị

1. Thoát các bộ gõ tiếng Việt khác đang chạy (OpenKey, EVKey, GoTiengViet…), kể cả các bộ gõ trong Mục đăng nhập.
2. Cài bản Debug bằng `scripts/dev/install-app.sh --debug`, vì chỉ bản Debug có nhật ký từng phím (D8 (Không telemetry)). Thử xong thì cài lại bản dùng hằng ngày bằng `scripts/dev/install-app.sh --ref main`.
3. Lần đầu trên một máy, mở Dấu trong `/Applications`, bấm "Bật Dấu" rồi bấm Allow (D37 (Cài bộ gõ)). Nếu không bật được thì theo đường lui của D37: tự thêm Dấu bằng "+" trong danh sách nguồn đầu vào của System Settings. Nếu "+" không có Dấu thì đăng xuất một lần ([`docs/research/InputMethodInstall.md`](research/InputMethodInstall.md) mục 1.3, 3.2).
4. Giữ U.S. (hoặc một nguồn tiếng Anh khác) trong danh sách nguồn, vì Dấu chỉ có nguồn tiếng Việt (D2 (Chuyển Việt/Anh)).
5. Nếu máy bật "Automatically switch to a document’s input source", mỗi ứng dụng nhớ nguồn riêng, nên phải chọn lại Dấu sau khi chuyển sang ứng dụng cần thử.
6. Nếu bộ gõ không chạy, xem log bằng `/usr/bin/log stream --predicate 'process == "DauInputMethod"'` (trong zsh, `log` là một lệnh có sẵn khác).
7. Chỉ gõ vào ô nháp: tài liệu mới không lưu, Saved Messages của Telegram hay ô soạn tin không gửi. Không gửi tin và không lưu tệp nếu người dùng chưa cho phép.
8. Ghi lại ngày, commit của Dấu, phiên bản ứng dụng, phiên bản macOS và chế độ gạch chân của ứng dụng đó.

### 4.2 Gõ

- Với ứng dụng có trong `scripts/selftest/typing/run.sh`, script tự gõ. Đầu script ghi ứng dụng nào được hỗ trợ, câu mẫu và đáp án, các tuỳ chọn (`--delay`, `--keys`, `--underline`, `--source`, `--busy`…), cách mở và đọc chữ và các quyền cần cấp. Script chiếm màn hình, nên phiên chính chạy nó theo chế độ quyền của Claude Code (CLAUDE.md, mục "Điều phối").
- Về nhịp, 120 ms gần với gõ thường; 5, 10 và 20 ms dùng để tìm ngưỡng phím dồn; `--busy` dùng cho trang bận (M6).
- Đối chứng là Telex của Apple trong cùng điều kiện (`--source`), theo [`scripts/CLAUDE.md`](../scripts/CLAUDE.md) mục "Đo độ đúng khi gõ".
- Với ứng dụng khác, gõ tay (tốc độ bình thường, rồi gõ nhanh hết sức) và ghi rõ cách thử ở mục 5.

### 4.3 Những gì cần kiểm tra

| Kiểm tra | Cách làm | Mong đợi |
|---|---|---|
| Chữ đúng | So từng ký tự với đáp án. | Chữ khớp hoàn toàn. |
| Gạch chân, nhảy chữ | Nhìn trong lúc gõ. | Ở chế độ thường không có gạch chân; chữ không lặp, không mất, không đảo và con trỏ không nhảy. |
| Backspace (D32 (Backspace)) | Gõ `hoaf` rồi ⌫. | "hoà" rồi "hò". |
| Click reset (D4 (Từ nước ngoài), D11) | Gõ `tooi`, click sau dấu cách hoặc ở đầu dòng, rồi gõ `s`. | Chỉ thêm "s" ở chỗ mới. Nếu click ngay sau một chữ thì D20 có thể đặt dấu vào chữ đó. |
| Mũi tên reset (D4 × D20) | Gõ `tooi`, bấm ←, nghỉ một nhịp, rồi gõ `s`. | Khi D20 bật: "tối" (dấu vào chữ trước con trỏ, "i" giữ nguyên). Khi D20 tắt: "tôsi". |
| Thêm dấu cho từ đã gõ (D20) | Gõ `hoc`, dấu cách, ⌫, rồi `j`. | "học", ở mọi nhịp gõ; ở ứng dụng gạch chân thì ra "hocj". |
| Tự sửa chính tả (D4) | Gõ một câu tiếng Việt rồi `Sunrise carr␣`. | "car". Nếu thành "cả" thì đó là macOS sửa, không phải Dấu, vì Telex của Apple cũng bị (mục 6.1). |

### 4.4 Số đo

- Chạy `scripts/perf/perf-report.sh --last 5m --app <tên app hoặc một phần bundle ID>` ngay sau khi gõ; `typing/run.sh` tự in báo cáo này. Các cột, cách bật nhật ký từng phím (`DauPerfLog`) và cách tắt sau khi đo được ghi ở đầu script.
- Ghi lại `selectedRange` p50 / p99 µs, `count_mismatch` (vị trí khác dự đoán) và `count_unsupported` (ứng dụng trả `NSNotFound`).
- Nếu `event_client-changed` tăng theo từng phím hay `event_client-not-text-input` khác 0, hãy báo lại ngay.
- Bản Debug có thêm một lần hỏi chẩn đoán sau mỗi lần thay (`ReplaceDiag.swift`). Lần hỏi này chạy sau khi thời gian đã được ghi, nên không nằm trong số đo. Bản Release không ghi gì theo từng phím (D8), nên số đo lấy từ bản Debug. Nếu cần p99 đáng tin thì gõ thêm vài trăm phím có dấu.

## 5. Số đo theo ứng dụng

Số M1–M3 (29–30/10/2026) nằm ở bảng "Số đo (M1–M3)" của [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md) và ở nhật ký 30/10 trong cùng file. Lượt chạy ma trận ngày 30/10/2026 nằm ở [`docs/history/CompatibilityFixed.md`](history/CompatibilityFixed.md). Số M6 nằm ở [`docs/history/LogM6.md`](history/LogM6.md). Số sau M6 nằm ở nhật ký [`docs/Progress.md`](Progress.md), theo ngày. Số µs là `selectedRange` p50 / p99 ở 30 ms, với phím có thay chữ, trên bản Debug. Phím dồn ở M6 có nhịp danh nghĩa 5, 10, 20 ms, nhưng khoảng cách phím thật phần lớn là 10–20 ms. Trang bận ở M6 là trang thử chặn luồng chính 300 ms mỗi giây, với phím cách nhau 100 ± 30 ms.

### 5.1 Safari, TextEdit

- Câu mẫu đúng ở 30 ms, gõ tay đúng và gạch chân đúng ở 30 ms (29–30/10/2026). Cả hai app cũng đúng khi gửi cả chuỗi một lần (0 ms), nhưng đó không là tiêu chí (D13). Từ khi Dấu tự chèn ký tự (N3, 22/11/2026), Safari 27.2 đúng ở mọi ô đã đo dưới đây, kể cả khi phím dồn, khi trang bận và ở ca ⌫ khi trang bận. Trước đó Safari sai khi phím dồn hay trang bận, vì WebKit để phím đi thẳng chờ trong hàng, còn lần thay của bộ gõ tới trang trước các phím đó. Số đo và chẩn đoán của giai đoạn đó nằm ở [`docs/history/CompatibilityFixed.md`](history/CompatibilityFixed.md) mục "Safari và Chrome khi phím dồn hay trang bận, trước khi Dấu tự chèn ký tự"; cơ chế nằm ở [`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md) mục 5.
- Sau khi Dấu tự chèn ký tự, trước khi có ngoại lệ chờ ⌫ chưa áp (N3; đo 22/11/2026, máy M3 Max, macOS 27.2.x, Safari 27.2, bản Debug của cây làm việc trên `1bfbcd3` kèm thay đổi tự chèn, cài bằng `scripts/dev/install-app.sh --debug`, 10:23–10:36): Dấu tự chèn bằng `insertText` mọi ký tự mà engine để nguyên, ở mọi app (không theo bundle ID), nên chữ không còn chờ trong hàng phím của Safari. ⌫, Return, Tab, Esc, mũi tên và phím có ⌘, ⌃, ⌥ vẫn đi thẳng. Ở chế độ gạch chân, ký tự chốt chữ đi cùng chữ chốt trong một `insertText`. Lệnh đo là `scripts/selftest/typing/run.sh` với chuỗi `edit` hoặc `std` lấy từ `scripts/selftest/load/run.sh --text edit|std --print keys|expect`; "trang bận, nhịp người gõ nhanh" là `--busy 300:1000 --delay 40 --jitter 20 --word-pause 150`.

  | Ô | Safari | Chrome |
  |---|---|---|
  | `std`, gửi cả chuỗi một lần (`--delay 0`) | đúng 3/3 (trước thay đổi sai 3/3) | đúng 1/1 |
  | `edit`, trang bận, nhịp người gõ nhanh | đúng 2/3; lượt sai chỉ "Hoc ⌫j" ra "Hocj" | đúng 3/3 |
  | mũi tên khi trang bận (`--delay 10 --keys "Hoom nay ← dduowcj" --expect "Hôm nay được "`) | đúng 3/3 | đúng 1/1 |
  | `std`, gửi một lần, gạch chân (`--underline`) | đúng 2/2, không còn dấu cách dời chỗ (trước: dời 2/3) | chưa đo |
  | `edit`, 5 ms, trang rảnh | đúng 1/1 | đúng 1/1 |
  | `hoaf⌫ ` (`--keys "hoaf⌫ " --expect "hò "`, 30 ms) | đúng | đúng |

  - Telex của Apple trong cùng điều kiện (trang bận, chuỗi `edit`) ra đúng chữ của chính nó ("mêting", "Hocj"), nên ô hợp lệ. Telex của Apple không có D20 (Thêm dấu cho từ đã gõ), nên "Hocj" là chữ nó luôn ra, kể cả khi trang rảnh. Vì vậy đối chứng này chỉ cho biết ô hợp lệ và không dùng để so với kết quả "Hocj" của Dấu.
  - Lý do chọn tự chèn cho mọi app, giữ ⌫ đi thẳng và chờ ⌫ chưa áp nằm ở [`docs/Decisions.md`](Decisions.md) N3 (ý 2 và đoạn "Vì sao Dấu tự chèn ký tự"). Các hướng đã xét và lý do không chọn nằm ở [`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md) mục 5.
- Chờ ⌫ chưa áp (ngoại lệ của N3) đo ngày 22/11/2026, 11:14–11:45, trên máy M3 Max, với bản Debug của cây làm việc trên `28901f8`, cài bằng `scripts/dev/install-app.sh --debug`. Đối chứng là bản Release của `28901f8`, không có phần chờ, cùng máy, cùng ô. Lệnh như trên, thêm `--save <dir>`; "trang bận 10 ms" là `--busy 300:1000 --delay 10`. Thời gian chờ đọc từ các trường `bksp`, `bksp_asks`, `bksp_wait_ns` trong log perf của bản Debug.
  - Ở Safari, lần hỏi `selectedRange` đầu tiên bị chặn tới khi trang rảnh (`sel_ns` khoảng 195 ms ở phím đầu khi trang bận); sau đó ⌫ áp trong khoảng 3 ms. Cả 5 lần chờ ở Safari đều thấy ⌫ áp, mỗi lần 3 ms.

  | Ô (Safari) | Bản có chờ | Đối chứng (không chờ) |
  |---|---|---|
  | trang bận 10 ms, "khoong⌫g" | đúng 3/3 (hai bản trước của phần chờ cũng 3/3); 3 lần chờ, mỗi lần 3 ms, đều áp | sáng cùng ngày: "khôngg kó"/"khôngg khó" 2/3 |
  | trang bận, nhịp người gõ nhanh | đúng 3/3 (cộng 3/3 với bản chờ trước đó); không lần chờ nào bật ở ô này | sáng cùng ngày: 2/3 ("Hocj") |
  | VS Code 5 ms, Firefox 5 ms | đúng 2/2 và 1/1, không chờ | — |

  - Ở lượt trước với bản chờ (11:24–11:30), Safari đúng 9/9 ô (5 ms, `std` 0 ms, `hoaf⌫`). Chrome 5 ms, VS Code, Firefox, `cursoragents`, Notes và Terminal đều đúng, `hoaf⌫` ở Chrome, VS Code và Firefox cũng đúng. Không ô nào phải chờ.
  - Ở Chrome, trong lúc bộ gõ chờ, câu trả lời không đổi, vì bộ đệm của Chrome không cập nhật khi bộ gõ đang chặn. Với hạn 0,3 s, mọi lần chờ đều hết hạn sau 402–414 ms. Chữ sai ở từ khác do các phím dồn lại sau lúc đứng. Vì vậy hạn chờ là 20 ms (ngưỡng p99 của D42). Khoảng xét chờ là 0,3 s sau ⌫ (`backspaceWaitWindow`, `backspaceWaitLimit` trong `InPlaceComposer`). Với hạn 20 ms, mỗi lần chờ ở Chrome hết hạn sau 21–22 ms và chữ không đổi; ở Chrome, thứ tự do phép chứng minh app chậm của D11 giữ. Không có ngoại lệ theo app. Số đo Chrome nằm ở mục 5.2.
- Backspace và thêm dấu cho từ đã gõ (120 ms) đều đúng.
- `selectedRange` của TextEdit là 327 / 606 µs, của Safari là 622 / 1.057 µs; mismatch là 0.
- Với TextEdit, mũi tên reset theo mong đợi D4 × D20 chưa được đo ([`docs/history/M2Testing.md`](history/M2Testing.md) mục 4). TextEdit không nằm trong script, vì nó tự lưu tài liệu thử lên iCloud Drive ([`docs/Troubleshooting.md`](Troubleshooting.md)).
- Kiểm lại "Hoc ⌫j" (23/11/2026, 12:58–13:10, máy M1 Pro, macOS 27.2.1, bản Release của bản sửa "Hocj"; câu `edit` có "Hoc ⌫j"; Safari 27.2): trang bận 10 ms đúng 2/2, trang bận nhịp người gõ nhanh 1/1, trang rảnh 10 ms 1/1.

### 5.2 Chrome, Edge, Firefox

- Gạch chân ở 0 ms đúng ở cả ba trình duyệt.
- Khi phím dồn (10/11/2026, nhịp danh nghĩa 5, 10, 20 ms, app rảnh), Chrome và Firefox đúng 7/7 lượt mỗi app (máy M3 Max), Edge đúng 9/9 (máy M1).
- Khi trang bận (chuỗi `edit`, 100 ± 30 ms, 3 lượt mỗi app), Chrome đúng 3/3 (10/11/2026, 06:13, máy M3 Max), Edge 3/3 và Firefox 3/3 (10/11/2026, máy M1). Với Chrome 157 và mã `5564963` (17/11/2026, máy M1), thay tại chỗ lại đúng 3/3. Edge 157.0.4341.60 và Firefox 160.0 (17/11/2026, máy M1, bản Debug của `8d3e93a`, chuỗi `edit`, 100 ± 30 ms, trang bận `--busy 300:1000`) đúng 1/1 mỗi app. Ở chế độ gạch chân, "Hoc ⌫ j" ra "Hocj" 3/3, vì gạch chân không thêm dấu cho từ đã chốt (mục 6.8).
- Trong trình soạn thảo TipTap/ProseMirror trên Chrome (12/11/2026, Dấu Release 4ae3646, `typing/run.sh tiptap`, câu mẫu 41 phím, 5/10/20 ms có jitter, 3 lượt mỗi mức), Dấu đúng 9/9 lượt. Telex của Apple trong cùng điều kiện ra cùng một chữ ở cả 9 lượt và chỉ khác Dấu ở từ tiếng Anh (D4), nên phép đo hợp lệ. Lỗi mất dấu khi gõ nhanh trong trình soạn thảo web không tái hiện được.
- Khi phím dồn với chuỗi `std` ở 5 ms (17/11/2026, máy M1, bản Debug của `8d3e93a`, chuyển nguồn bằng phím tắt hệ thống, có xác nhận trong ô), Edge đúng 2/2 và Firefox đúng 2/2. Telex của Apple trong cùng điều kiện hợp lệ ở cả hai (ra "mêting"; ở Edge thêm "Ciều").
- Backspace và thêm dấu cho từ đã gõ (120 ms) đúng ở cả ba (Backspace, 82d9ecc).
- `selectedRange` của Chrome là 415 / 694, của Edge là 369 / 6.828 và của Firefox là 265 / 1.174 µs.
- Về tốc độ cao nhất khi trang rảnh (18/11/2026, máy M1 Pro, Chrome 157.0.8103.79), Dấu đúng 15/15 lượt, ở mọi nhịp từ 20 ms tới khoảng 8,5 ms một phím và khi gửi cả chuỗi một lần (khoảng 1,4 ms một phím). Lượt này chạy trước khi Dấu tự chèn ký tự; số và điều kiện nằm ở [`docs/history/CompatibilityFixed.md`](history/CompatibilityFixed.md).
- Sau khi Dấu tự chèn ký tự (22/11/2026, máy M3 Max, Chrome 157, chuỗi `edit`, trang bận `--busy 300:1000`, nhịp người gõ nhanh `--delay 40 --jitter 20 --word-pause 150`), Dấu đúng 3/3 (trên `main` sau `d171ab9` thì sai 2/6). Chuỗi `std` gửi một lần và ô mũi tên khi trang bận đều đúng 1/1. Bảng đầy đủ nằm ở mục 5.1.
- Sau khi có ngoại lệ chờ ⌫ chưa áp (N3; 22/11/2026, 11:14–11:45, máy M3 Max, bản Debug của cây làm việc trên `28901f8`; đối chứng là bản Release của `28901f8`, không chờ), khi trang bận ở nhịp người gõ nhanh Dấu đúng 5/6. Lượt sai ra "đụơc", là lỗi "được" đã biết. Lượt đó không chờ; có 3 lần chờ, đều hết hạn sau 21–22 ms. Đối chứng đúng 3/3. Khi trang bận ở 10 ms (`--busy 300:1000 --delay 10`), Dấu vẫn sai: bản có chờ sai 2/2 ("kếạhoach", "ếocj tieng", "hướég dânx nhe."). Đối chứng không chờ sai 3/3 cùng kiểu chữ ("hướég dânx nhe.", "êược luyenj", "nay.ếHocj tieng"). Vì vậy lỗi này có từ trước, không do phần chờ. Số đo nằm ở mục 5.1.
- Bản sửa phép chứng minh app chậm của D11 đo ngày 22/11/2026, 23:16–23:29, trên máy M3 Max, macOS 27.2.1, Chrome 158.0.8127.37, Safari 27.2 và VS Code 1.147.0. Bộ gõ là bản Debug của cây làm việc trên `8ce5924`, cài bằng `scripts/dev/install-app.sh --debug`. Lệnh và chuỗi `edit` như mục 5.1. Cơ chế của hai lỗi và của bản sửa nằm ở [`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md) mục 3.3.
  - Lượt 1 (23:16–23:20) chỉ có phần sửa lỗi "được": khi trang bận, ở nhịp người gõ nhanh Dấu đúng 6/6, ở 10 ms đúng 2/3. Lượt sai ra "Hếcj tieng" thay vì "Học tiếng". Telex của Apple trong cùng điều kiện ra đúng chữ của nó ("mêting", "Hocj") ở cả 10 ms lẫn nhịp người gõ nhanh (2/2), nên ô hợp lệ.
  - Lượt 2 (23:24–23:29) có cả hai phần sửa. Khi trang bận, Chrome đúng 9/9 ở 10 ms và 3/3 ở nhịp người gõ nhanh. Ở 10 ms, Safari đúng 2/2. Khi trang rảnh, ở 5 ms, Chrome, Safari và VS Code đúng 1/1 mỗi app. Firefox 160.0.1 (23:31) khi trang bận đúng 1/1 ở 10 ms và 1/1 ở nhịp người gõ nhanh. Trong cả 9 lượt Chrome 10 ms của lượt 2, lần đọc của D20 ở "Hoc ⌫j" đều gieo được từ, nên tình huống của lượt sai ở lượt 1 không lặp lại. Phần sửa cho tình huống đó chỉ kiểm bằng mô hình dựng lại từ log của lượt sai (`LateAnswerTests`, test "busy page, 10 ms: a D20 read in a burst far behind…").
  - Gộp hai lượt, khi trang bận Chrome đúng 9/9 ở nhịp người gõ nhanh. Trước bản sửa, ô này đúng 5/6 với bản có chờ ⌫, còn ở 10 ms Dấu sai 5/5 (bản có chờ và đối chứng không chờ).
- Lượt kiểm hồi quy sau bản sửa (23/11/2026, 00:30–00:54, máy M3 Max, Chrome 158.0.8127.37, Safari 27.2, Firefox 160.0.1, VS Code 1.147.0; bản Debug của `bcfea73`). Khi trang bận, Chrome đúng 3/3 ở 10 ms và 2/3 ở nhịp người gõ nhanh. Lượt sai ra "mọot" thay vì "một", ở từ thứ ba của văn bản. Log khớp dạng bộ đệm Chromium: trang bị chặn sau "Sáng nay ", nên ở "o" thứ hai app chậm 3 thao tác. Vì app chưa trả lời đúng lúc lần nào từ đầu văn bản, giới hạn chỉ là 2 thao tác. Mô hình trang bận của mã trước bản sửa đã ghi đúng ca này là lỗi đã biết ("Sáng nay moj"), nên lỗi có từ trước. Ở ô thay tại chỗ trang rảnh 5 ms, gửi một lần, `hoaf⌫` và mũi tên khi trang bận, Chrome, Safari, Firefox và VS Code đều đúng. Gạch chân ở Chrome và Safari cũng đúng. Safari, Firefox khi trang bận đều đúng (Safari 3/3 ở 10 ms, 3/3 ở nhịp người gõ nhanh; Firefox 1/1 mỗi ô). Terminal và ô Agents của Cursor đúng 1/1.
- Bản sửa lỗi "mọot" (vị trí neo đầu tiên là một mốc như câu trả lời đúng lúc; [`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md) mục 3.3) đo ngày 23/11/2026, 06:14–06:20, cùng máy và các app như lượt kiểm hồi quy, bản Debug của cây làm việc trên `86f7876`. Khi trang bận, Chrome đúng 6/6 ở nhịp người gõ nhanh và 3/3 ở 10 ms. Telex của Apple trong cùng điều kiện ra đúng chữ của nó ("mêting", "Hocj"). Khi trang rảnh, ở 5 ms, Chrome, Safari và VS Code đúng 1/1. Khi trang bận, ở nhịp người gõ nhanh, Safari và Firefox đúng 1/1. Thời gian phím có thay chữ ở Chrome: p50 0,77 ms, p99 1,8 ms.
- Lần đọc của D20 sau ⌫ khi Chrome trả lời chậm (23/11/2026, 12:13–12:22, máy M1 Pro, macOS 27.2.1, Chrome 157.0.8103.79, Safari 27.2, Firefox 160.0.1, VS Code 1.147.0; tải trung bình 1 phút 10–35). Câu `edit`, trang bận `--busy 300:1000`, 10 ms. Bản Debug của bản sửa đúng 10/10. Đối chứng xen kẽ là bản Release của `main` trước bản sửa, đúng 1/4; ba lượt sai đều ra "Hocj tiếng" (trước đó cùng ngày, cùng máy: đúng 6/16). Ở 2 trong 10 lượt của bản sửa, lần đọc của D20 trả vị trí chậm 6 và 7 thao tác, được chứng minh ở dạng bộ đệm Chromium và từ được gieo; ở 8 lượt còn lại vị trí trả trùng vị trí Dấu theo dõi. Cũng với bản sửa: Chrome trang bận ở nhịp người gõ nhanh, Chrome trang rảnh 5 ms, Safari và Firefox trang bận 10 ms, VS Code (ô `vscodefile`) 5 ms đều đúng 1/1.
- Kiểm lại "Hoc ⌫j" sau bản sửa (23/11/2026, 12:58–13:10, máy M1 Pro, macOS 27.2.1, bản Release của bản sửa "Hocj"; câu `edit` có "Hoc ⌫j"; Chrome 157.0.8103.79, Edge 157.0.4341.60, Firefox 160.0.1). Trang bận `--busy 300:1000`: Chrome đúng 3/3 ở 10 ms, 2/2 ở 5 ms, 2/2 ở nhịp người gõ nhanh, 2/2 ở 10 ms khi máy thêm 8 tiến trình chiếm CPU; Edge 2/2 ở 10 ms; Firefox 3/3 ở 10 ms, 1/1 ở nhịp người gõ nhanh. Trang rảnh 10 ms: Chrome, Firefox đúng 1/1. Ô `tiptap` 10 ms đúng 1/1.
- Click reset và mũi tên reset chưa được đo.

### 5.3 VS Code

- Thay tại chỗ đúng ở 5–20 ms (phím dồn, máy M1): 14/15 lượt ngày 10/11/2026 (VS Code 1.145.2) và 2/2 lượt ngày 17/11/2026 (VS Code 1.146.0, ô `vscode`, `std` ở 5 ms, bản Debug của `8d3e93a`, mỗi lượt chạy ngay sau một ô Telex của Apple, chuyển nguồn bằng phím tắt hệ thống; không mất phím đầu nào). Telex của Apple trong cùng điều kiện hợp lệ 2/2 (ra "mêting"). Lượt mất vài phím đầu ngày 10/11 chạy sau ô Apple chọn bằng API và không tái hiện khi chuyển bằng phím tắt. Gạch chân đúng ở 0 ms.
- Backspace và thêm dấu cho từ đã gõ (120 ms) đều đúng. `selectedRange` là 230 / 885 µs.
- Khi phím dồn với chuỗi `edit` (18/11/2026, máy M3 Max, VS Code 1.146.0, bản Debug của `f0a9102`, nhịp 5, 10, 20 ms, 3 lượt mỗi nhịp, hai bản có và không có ngưỡng 50 ms của D11), Dấu đúng 18/18.
- Về tốc độ cao nhất (18/11/2026, máy M1 Pro, VS Code 1.146.0), Dấu đúng 15/15 lượt, ở mọi nhịp từ 20 ms tới khoảng 8,5 ms một phím và khi gửi cả chuỗi một lần (khoảng 1,4 ms một phím). Lượt này chạy trước khi Dấu tự chèn ký tự; số và điều kiện nằm ở [`docs/history/CompatibilityFixed.md`](history/CompatibilityFixed.md).
- Trường hợp app bận chưa được đo.
- Ô `vscodefile`, câu `edit` 10 ms (23/11/2026, 12:58–13:10, máy M1 Pro, macOS 27.2.1, bản Release của bản sửa "Hocj"; câu `edit` có "Hoc ⌫j"): đúng 1/1.

### 5.4 Cursor

Cursor là một app với một bundle ID, nhưng có hai kiểu cửa sổ. Cửa sổ Agents mở khi chạy app và có ô nhập ở giữa. Cửa sổ IDE có giao diện kiểu VS Code, gồm trình soạn thảo và khung agent (mở bằng ⌘L). File › Open IDE trong cửa sổ Agents không mở gì khi chưa có workspace, còn `cursor --new-window <tệp>` thì mở được.

**Hiện trạng (3.30.14, đo 17/11/2026, máy M1, macOS 27.2):** khung agent (`cursorchat`) và ô nhập Agents (`cursoragents`) thay tại chỗ đúng ở mọi chuỗi đã đo. Trình soạn thảo (`cursor`) trả vị trí theo hai kiểu: tính từ đầu văn bản (các lượt buổi sáng, chữ đúng) hoặc tính từ đầu từ (7/7 lượt buổi chiều, cùng bản Cursor). Theo mã nguồn, trình soạn thảo Cursor nhận chữ qua một ô textarea ẩn; khi chế độ trình đọc màn hình của Monaco tắt, ô chỉ chứa từ trước con trỏ nên vị trí tính từ đầu từ, khi chế độ đó bật thì ô chứa nhiều dòng ([`docs/research/MonacoInput.md`](research/MonacoInput.md); cái gì bật chế độ đó trên máy đo chưa kiểm chứng). Ở kiểu sau, chuỗi `edit` gõ cách nhau 5 ms sai 0–7 từ mỗi lượt. Nguồn chuyển bằng phím tắt hệ thống, có xác nhận bộ gõ trong ô.

| Chuỗi | Nhịp | `cursorchat` | `cursoragents` | `cursor` |
|---|---|---|---|---|
| câu mẫu mặc định | 5 ms | đúng | đúng | đúng |
| `std` | 5 ms | đúng 1/1 | đúng 1/1 | đúng 3/3 (vị trí từ đầu văn bản) |
| `std` | 20 ms | — | — | đúng 1/1 (vị trí từ đầu văn bản) |
| "anh ddi " từ tài liệu mới | 20 ms | — | — | đúng 2/2 (vị trí từ đầu văn bản) |
| `edit` | 100 ± 30 ms | đúng 1/1 | đúng 1/1 | đúng 1/1 (vị trí từ đầu văn bản) |
| `edit` | 5 ms | đúng 1/1 | đúng 1/1 | đúng 1/4, ba lượt kia sai 5, 3 và 2 từ (vị trí từ đầu từ) |

- Các ô `std`, câu mẫu, "anh ddi " và `edit` 100 ms đo bằng bản Debug fa5ce8f+; các ô `edit` 5 ms đo bằng bản Debug của mã hiện tại.
- Khi vị trí tính từ đầu văn bản (dòng `diag replace`), `selectedRange` bằng vị trí Dấu theo dõi hoặc chậm 1–4 thao tác kiểu bộ đệm Chromium (`kind=late`, chữ vẫn đúng). Ba lượt `std` 5 ms ở trình soạn thảo có 41, 39 và 41 lần thay; trong đó 37, 39 và 35 lần đúng vị trí, còn lại trễ mà vẫn đúng chữ. Khung agent và ô nhập Agents luôn trả vị trí theo kiểu này.
- Khi vị trí tính từ đầu từ, `selectedRange` không quá 6 trong cả câu dài, như mô hình `LateDocument.Origin.word` (dựng từ Cursor 3.29.15). Các từ sai giống nhóm lỗi của mô hình đó, tức là câu trả lời cũ khi gõ qua ranh giới từ ("ộot", "trươcs", "duwowjc", "kóo"). Mã trước khi bỏ chờ ở D20 cũng sai như vậy trong cùng trạng thái của Cursor (3/3 lượt sai 7, 3 và 2 từ, kể cả "Hocj"), nên lỗi không do D20.
- Sau khi Dấu tự chèn ký tự (22/11/2026, máy M3 Max, bản Debug của cây làm việc trên `1bfbcd3` kèm thay đổi tự chèn, chuỗi `edit` 5 ms, trang rảnh), `cursoragents` đúng 1/1. Trình soạn thảo (`cursor`) sai 1 từ, ra "ke" thay vì "kế", cùng nhóm lỗi vị trí từ đầu từ ở ý trên (trước đó 3/4 lượt sai 2–5 từ).
- Gạch chân chưa được đo trên 3.30.14.
- Cursor không có nhãn "Đề xuất".
- Mô hình `LateDocument.Origin.word` (trong test) tả app tính `selectedRange` và vùng thay từ đầu từ đang gõ. Mô hình dựng từ log trình soạn thảo Cursor 3.29.15 (đo 10/11/2026). Trình soạn thảo của 3.30.14 có lúc cũng như vậy (ý trên). Hướng xử lý nằm ở [`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md).
- Trình soạn thảo (`cursor`, Cursor 3.31.15), câu `edit` 10 ms (23/11/2026, 12:58–13:10, máy M1 Pro, macOS 27.2.1, bản Release của bản sửa "Hocj"; câu `edit` có "Hoc ⌫j"): sai 4/4 (1 lượt Release, 3 lượt Debug), lượt nào cũng ra "Hocj"; lượt Release còn ra "meting". Cursor trả vị trí tính từ đầu từ (`selectedRange` 1–3 khi Dấu theo dõi 14), nên phép chứng minh app chậm không so được (`typed_read_reject=limit`) và Dấu không gieo từ. Đây là kiểu vị trí đã ghi ở trên, có từ trước bản sửa. Lượt đầu dừng trước khi gõ vì cửa sổ Cursor Agents lên trước cửa sổ thử (mã thoát 3); chạy lại thì gõ được.
- Sau bản sửa cho app tính vị trí từ đầu từ (23/11/2026, 13:29–13:47, máy M1 Pro, Cursor 3.31.15, trình soạn thảo, câu `edit` 10 ms, bản Debug của cây làm việc): "Hoc ⌫j" ra "Học" 8/10 lượt (lượt đầu của vòng thứ hai Cursor trả vị trí từ đầu văn bản). Bảy lượt trả vị trí 3, đọc được "Hoc" và được gieo (`typed_read_word_start=1`). Hai lượt còn "Hocj": một lượt trả vị trí 4, đọc được 4 đơn vị không khớp chữ đã gõ, trước khi bản sửa nhận câu trả lời thiếu ⌫ (mô hình cho thấy đó là "Hoc␣" chưa áp ⌫; ca này chưa gặp lại trên app thật sau khi sửa); một lượt trả vị trí 1, đọc được 1 đơn vị không khớp chữ đã gõ. Đối chứng là bản Release trước bản sửa: "Hocj" 1/1 (lượt kia dừng trước khi gõ vì cửa sổ Cursor Agents lên trước). 4/10 lượt của bản sửa vẫn sai 1–2 từ khác ("keế", "àyay", "dđược", "nguoiwf", "moột"): câu trả lời cũ qua ranh giới từ, như ý trên. Cùng bản sửa, Chrome trang bận 10 ms đúng 3/3, Edge, Firefox, Safari trang bận 10 ms và VS Code 5 ms đúng mọi lượt.
- Khung agent (`cursorchat`) và ô nhập Agents (`cursoragents`), câu `edit` 10 ms (23/11/2026, 13:50–13:52, máy M1 Pro, Cursor 3.31.15, bản Release `179b3b6`): đúng cả câu 2/2 mỗi ô.
- Đường nhập của trình soạn thảo theo cài đặt Cursor (cơ chế ở [`docs/research/MonacoInput.md`](research/MonacoInput.md)):

  Đo ngày 23/11/2026, 14:36–14:42, máy M1 Pro, Cursor 3.31.15, ô `cursor`, câu `edit` 10 ms, bản Debug của Dấu ở `a8015af` có log `selectedRange`. Cài đặt của Cursor trên máy lúc đầu không đặt `editor.accessibilitySupport` (tức `auto`) và không bật EditContext; VoiceOver không chạy. Mỗi cài đặt ghi vào `settings.json` của Cursor, thoát Cursor bình thường để nó nạp lại, chạy ba lượt; sau lượt đo file cài đặt được trả về nguyên bản. Lượt đầu của mỗi cài đặt dừng trước khi gõ vì cửa sổ Cursor Agents lên trước cửa sổ thử khi Cursor vừa mở (mã thoát 3), nên mỗi cài đặt có hai lượt gõ được.

  | Cài đặt | `selectedRange` lớn nhất trong 60–61 lần thay | Chữ |
  |---|---|---|
  | `"editor.accessibilitySupport": "off"` | 6 (tính từ đầu từ) | sai 2/2: "dđược", "àyay"; "pảai", "vêetjs" |
  | `"editor.accessibilitySupport": "on"` | 219 (tính từ đầu văn bản) | đúng 2/2, cả "Học" |
  | `"off"` kèm `"editor.experimentalEditContextEnabled": true` | 219 (câu thử một dòng, nên đầu dòng trùng đầu văn bản) | đúng 2/2, cả "Học" |

  Điều gì bật chế độ trình đọc màn hình ở các lượt buổi sáng 17/11 (cài đặt `auto`) chưa rõ.
- Sau bản sửa cho ô chỉ giữ từ trước con trỏ (D11; 23/11/2026, 15:35–15:55, máy M1 Pro, Cursor 3.31.15, bản Debug của bản sửa). Cài đặt `off`: câu `edit` 10 ms đúng 5/5, 100 ms đúng 1/1, câu `std` 5 ms đúng 3/3; câu `edit` 5 ms chỉ đúng 1/5, bốn lượt sai ở 1–3 từ đầu văn bản ("mọot", "mot", "nguoiwf ạnn", "nườii"), trước khi Dấu nhận ra loại ô; "Hoc ⌫j" ra "Học" ở mọi lượt. Đối chứng Telex của Apple ở `edit` 10 ms ra "Sasng", "mêting" (D20, D4 Telex của Apple không có). Cài đặt máy (`auto`) đúng 2/2; `on` và EditContext đúng 2/2 mỗi cài đặt, log không đổi hệ. Đổi chế độ giữa câu ở 100 ms: `off` sang `on` đúng 2/2; `on` sang `off` đúng 1/2, lượt kia thiếu dấu một từ ("phai") ở lúc đổi. Khung agent, ô Agents đúng 1/1. Phím "j" chờ ⌫ khi câu trả lời là " " mất 26 ms (1 lần, 5 ms). Cùng bản: Chrome trang bận 10 ms 3/3, trang rảnh 5 ms 1/1, Edge, Firefox trang bận 1/1, Safari trang bận 2/2, VS Code 5 ms 2/2, Notes, Terminal (`std` 30 ms), TipTap 1/1, log không đổi hệ ở app nào.

### 5.5 Terminal

- Với thay tại chỗ, chuỗi `std` (17/11/2026, Terminal 2.15, máy M1, bản Debug của `8d3e93a`, chuyển nguồn bằng phím tắt hệ thống, có xác nhận trong ô), kết quả là 5 ms đúng 0/2, 10 ms 1/2, 20 ms 1/2, 30 ms 1/1. Các lượt sai ở 10 và 20 ms sai một từ ("về" ra "veêf"), còn ở 5 ms sai nhiều từ. Telex của Apple trong cùng điều kiện sai ở 5, 10 và 20 ms, nhiều từ hơn Dấu (ô đối chứng hợp lệ). Thay tại chỗ sai khi phím dồn dưới 30 ms và sai ở 0 ms.
- Sau khi Dấu tự chèn ký tự (N3; 22/11/2026, 13:56–13:58, máy M3 Max, bản Debug của cây làm việc trên `b28f57b`, chuỗi `std`, `scripts/selftest/typing/run.sh --delay 5|10|20 terminal`), kết quả là 5 ms đúng 2/2, 10 ms 4/5, 20 ms 2/2. Lượt sai ở 10 ms sai một từ ("Sunrise" ra "Suủnise"). Telex của Apple ở 5 ms ra đúng chữ của chính nó ("ưindows", "Sủnise"), nên ô hợp lệ. Thay tại chỗ vẫn còn sai khi phím dồn, nên nhãn giữ nguyên.
- Gạch chân ở 0 ms vẫn sai: chữ chốt đúng, nhưng Terminal còn vẽ marked text cũ tới phím sau. Ở 5–30 ms thì gạch chân đúng (5, 10, 20 ms: 3/3 ngày 17/11/2026). Thay tại chỗ sai khi phím dồn dưới 30 ms còn gạch chân thì đúng, nên Terminal có nhãn "Đề xuất" (D13).
- Thêm dấu cho từ đã gõ ra "hocj", vì ⌫ không tới bộ gõ (mục 6.5). `selectedRange` là 408 / 637 µs.
- Ngày 12/11/2026 (120 và 30 ms, một lượt mỗi mức), Dấu đúng, trừ ⌫ (mục 6.5).

### 5.6 Ghostty

- Phiên bản 1.4.0 đo ngày 11/11/2026 bằng `scripts/research/terminal-underline/run.sh` và `typing/run.sh` (`ghostty`, `ghosttyvim`), ở dấu nhắc của trình sửa dòng zsh và trong vim, có đối chứng Telex của Apple.
- Thay tại chỗ sai ở 120 ms (`dd` → "dđ", `toois` → "toôis", `vieetj` → "vieetj"). `selectedRange` luôn là `{0,0}`. Telex của Apple thì đúng.
- Cách gửi ký tự xoá (D43 cũ, đã bỏ ngày 12/11/2026) chỉ đúng từ từ thứ hai, thứ ba sau mỗi lần chuyển vào Ghostty, kể cả trong shell thật của người dùng (oh-my-zsh, powerlevel10k, zsh-autosuggestions; `scripts/research/terminal-underline/real-shell.sh`). Lệnh thật thường ngắn, nên cách đó gần như luôn sai. Số đo nằm ở [`docs/research/TerminalAndUnderline.md`](research/TerminalAndUnderline.md) mục 1.
- Với gạch chân, chữ đúng, kể cả trong shell thật của người dùng ngay từ từ đầu (12/11/2026, bản sau khi bỏ D43 cũ). Return ngay sau từ đang gạch chân bị nuốt, kể cả với Telex của Apple (mục 6.8).

### 5.7 Sublime Text

- Build 4215 đo ngày 11/11/2026 ở 120 ms (`scripts/research/terminal-underline/run.sh`). Thay tại chỗ đúng, kể cả thêm dấu cho từ đã gõ sau ⌫ và sau ←.
- Sau khi Dấu tự chèn ký tự, Build 4215 đo lại ngày 23/11/2026 ở 30 ms (cách đo ở mục 5.11): câu `edit` và `hoaf⌫` đều đúng 1/1.
- Gạch chân không thêm dấu được cho từ đã chốt, giống Telex của Apple (mục 6.8), nên ở Sublime Text không nên bật gạch chân.
- Khi gõ tay ngày 29/10/2026, `selectedRange` là 334 / 3.718 µs (n=35, sơ bộ).

### 5.8 Notes, Mail, Telegram

- Notes 4.13 (30/10/2026): câu mẫu đúng ở 30 ms (mismatch 0). Backspace và thêm dấu cho từ đã gõ đúng ("Học", vì Notes tự viết hoa chữ đầu). Notes không tự sửa "car". `selectedRange` là 330 / 1.135 µs; `insertText` cao nhất trong các app đã đo (3.799 / 10.207 µs).
- Mail 16.0 (30/10/2026): câu mẫu đúng ở 30 ms (Mail tự viết hoa chữ đầu), còn phần còn lại chưa thử. `selectedRange` là 375 / 1.245 µs. Số đo tự sửa chính tả của macOS ở Mail là ngày 11/11/2026 (120 ms) và 12/11/2026 (30 ms), ở mục 6.1.
- Telegram 13.1.0 (30/10/2026, tự gõ 30 ms mỗi phím qua System Events, trong Saved Messages, không gửi): câu mẫu cũ đúng, không có gạch chân, không nhảy chữ. `selectedRange` là 240 / 1.670 µs.
- Telegram 13.1.0 (17/11/2026, ô `telegram` của `typing/run.sh`, tức ô soạn tin của Saved Messages, không gửi; bản Debug của `8d3e93a`, máy M1, chuyển nguồn bằng phím tắt hệ thống, có xác nhận trong ô): `std` ở 5 ms đúng 1/1 và ở 30 ms đúng 1/1, `edit` ở 100 ± 30 ms đúng 1/1. Telex của Apple ở 5 ms hợp lệ.
- Hai ca sai ở Notes và Mail khi gõ hằng ngày (11/11/2026) là do tự sửa của macOS, xảy ra với mọi bộ gõ (mục 6.1).
- Notes, câu `edit` 10 ms (23/11/2026, 12:58–13:10, máy M1 Pro, macOS 27.2.1, bản Release của bản sửa "Hocj"; câu `edit` có "Hoc ⌫j"): đúng 1/1.

### 5.9 WebStorm

- Phiên bản 2026.3 (WS-263.7307.202, JetBrains Runtime 25.0.4.1 b635.79) đo ngày 17/11/2026 bằng `typing/run.sh`, ở hai ô: `webstorm` (trình soạn thảo, tệp `.txt` trong dự án tạm) và `webstormterm` (terminal Reworked, mặc định của bản này). Lượt đo dùng câu mẫu mặc định, 80 ± 30 ms một phím, nghỉ 250 ms sau mỗi từ, một lượt mỗi ô, có đối chứng Telex của Apple. Cơ chế và chẩn đoán nằm ở [`docs/research/JetBrainsInput.md`](research/JetBrainsInput.md).
- Ở trình soạn thảo, thay tại chỗ ra "ưindows car tôi yêu tiếng Việt, Sủnise". Từ tiếng Việt đúng, nhưng hai từ tiếng Anh không được khôi phục (D4). Sau mỗi phím mà Dấu để đi thẳng, Dấu bị reset. Số đo này có trước khi Dấu tự chèn ký tự theo N3. Nay chỉ ⌫, Return, Tab, Esc, mũi tên và phím có ⌘, ⌃, ⌥ đi thẳng. Phần này chưa đo lại, vì WebStorm không có trên máy đo ngày 22/11/2026. Vì bị reset, phím kế tiếp đi qua lần đọc của D20 (`seed`, `seed_pass`, `seed_none`). Mốc khôi phục của D4 dời tới chữ đang hiện. Ai gây reset thì chưa rõ (giả thuyết: `markedTextAbandoned:` của JetBrains Runtime). Đây là lỗi của Dấu (D13), chưa sửa (mục 7).
- Ở terminal, thay tại chỗ ra "ưindows caảr toôi yeêu tieêngs Vieêtj, Sunủnise", byte gửi xuống shell giống hệt và không có ký tự xoá: đây là ô bỏ qua vùng thay (mục 6.8).
- Gạch chân đúng ở cả hai ô. Telex của Apple ra "ưindows car tôi yêu tiếng Việt, Sủnise" ở cả hai ô (nó không có khôi phục từ tiếng Anh).

### 5.10 Google Docs, Word trên web

- Lượt đo ngày 17/11/2026 chạy trên máy M3 Max, macOS 27.2.1, Chrome 157.0.8103.79, bộ gõ Release `0b1a42d`, bằng `scripts/selftest/typing/typed-word-docs.sh` (ô `gdocs`, `wordweb` của `typing/run.sh`, trong tài liệu trống của người dùng đã đăng nhập sẵn), 80 ± 30 ms một phím, nghỉ 250 ms sau mỗi từ, có đối chứng Telex của Apple. Câu thử có bốn lần ⌫ qua dấu cách rồi thêm dấu cho từ vừa gõ (D20) và một ⌫ trong từ tiếng Anh; chuỗi phím và đáp án nằm ở đầu script.
- Ở Word trên web, Dấu đúng 6/6 lượt (hai lượt chạy, mỗi lượt 3), ở cả bốn chỗ D20. Telex của Apple ra "Homo nay mình hocj tiengé Vietẹ với bạn, buổi học online rất vui." (Apple không có D20).
- Sau khi Dấu tự chèn ký tự (N3), Word trên web đo lại ngày 22/11/2026, 23:36–23:59, trên máy M3 Max, Chrome 158.0.8127.37, cùng câu và nhịp của `typed-word-docs.sh`. Dấu đúng 9/9, ở cả bốn chỗ D20: 3 lượt với bộ gõ Release `fde2fe5`, 6 lượt với bản Debug của cùng mã. Telex của Apple ra "Homo nay mình hocj tiengé Vietẹ với bạn, buổi học online rất vui.", giống ngày 17/11, nên ô hợp lệ.
- **Word trên web bỏ mất lần soạn chữ đánh dấu (marked text) đầu tiên của tài liệu trống** (22/11/2026, cùng máy và Chrome). Khi gõ vào tài liệu trống, Telex của Apple mất ký tự đầu tiên ở mọi lần thử: "qkpb" ra "kpb", "kqpb" ra "qpb", "Toi vui" ra "oi vui", "Hom nay" ra "om nay", cả khi chữ đầu đã viết hoa ("Qkpb" ra "kpb"). Chỉ lần soạn đầu tiên bị mất, vì "qkpb qkpb" ra "kpb qkpb". Chữ số không qua chữ đánh dấu, nên "1qkpb" giữ nguyên (3/3). Bàn phím U.S. cũng không mất chữ. Bỏ vùng chọn của ⌘A (→) hay chờ 2 giây sau khi đổi nguồn cũng không giúp (mỗi ô 3/3 vẫn mất).
  - Dấu ở chế độ gạch chân (D13, chữ đánh dấu, ép bằng `DauDebugForceUnderline` trên bản Debug, có `underline-on` trong nhật ký ở từng lượt) mất y như vậy, 6/6 lượt ("kpb", "om nay"). Dấu thay tại chỗ (mặc định) đúng 3/3 trong cùng điều kiện.
  - Đây là cách Word trên web xử lý chữ đánh dấu, không riêng bộ gõ nào. Ngày 17/11 lượt đối chứng Telex của Apple qua được bước này; vì sao lần này khác thì chưa rõ.
  - Vì vậy ở các ô tài liệu web, `typing/run.sh` gõ chuỗi đánh dấu mở đầu bằng chữ số ("1qkpb ") và gõ câu thử sau nó, để Dấu và Telex của Apple cùng gõ trong một điều kiện. Với chuỗi đánh dấu này, Google Docs trên Chrome (23/11/2026, 00:02–00:04, Chrome 158.0.8127.37, bộ gõ Release `eae4d28`, `typed-word-docs.sh --gdocs`) ra cùng chữ như ngày 17/11. Dấu ra "Homo nay minhf hocj tiengé Vietẹ voiws banj, buôỉ học online râts vui." 3/3, còn Telex của Apple ra "Homo nay mình hocj tiengé Vietẹ với bạn, buổi học online rất vui." 1/1.
- Ở Google Docs (giao diện tiếng Việt), Dấu sai 3/3 lượt. Cả ba lượt ra cùng một chữ: "Homo nay minhf hocj tiengé Vietẹ voiws banj, buôỉ học online râts vui." D20 không đặt dấu ở cả bốn chỗ. Chữ gõ liền cũng sai ("minhf", "voiws banj", "buôỉ", "râts"), trong khi Telex của Apple gõ đúng các từ đó ("mình", "với bạn", "buổi", "rất").
- Chẩn đoán ở Google Docs (17/11/2026, cùng máy và Chrome, bộ gõ Debug `34644a3`, ô `gdocs` với `--save`, một lượt với câu trên và một lượt với câu không có ⌫ "Hoom nay minhf hojc tieengs Vieetj voiws banj, buooir hojc online raats vui. "):
  - Câu không có ⌫ cũng sai ("Hôm nay minhf học tiêngs Viêtj voiws banj, buôỉ học online râts vui."), nên lỗi không do D20.
  - Ở cả 24 lần hỏi, Google Docs trả vị trí con trỏ `(1, 0)` dù con trỏ ở đâu trong tài liệu. Chữ bộ gõ đọc được quanh con trỏ đo ở lượt dò ngày 22/11 (dưới).
  - Google Docs áp đúng chỗ mọi lần thay một ký tự (12/12, như "oo" → "ô", "hojc" → "học"). Mọi lần thay hai, ba ký tự (dấu thanh trên vần "inh", "ăn", "ơi"…) đều không được gửi đi: vị trí 1 nhỏ hơn số ký tự cần xoá, nên Dấu coi là không khớp (`resync`) và cho phím đi thẳng (12/12). Google Docs làm gì với một lần thay như vậy đo ở lượt dò ngày 22/11 (dưới). Sau đó Dấu đọc lại được đúng một ký tự làm từ, nên "buooir" ra "buôỉ" (r đặt lên "i"). Lần đọc của D20 không có chữ (`seed_none`).
  - Telex của Apple đúng, có lẽ vì nó soạn chữ bằng chữ đánh dấu (marked text) thay vì thay chữ đã có (suy luận, chưa đo).
  - Hai giả thuyết đã bị loại. Giả thuyết thứ nhất là Google Docs bỏ qua vùng thay; nếu vậy thì cả lần thay một ký tự cũng sai ("Hoôm"). Giả thuyết thứ hai là Google Docs trả vị trí chậm; nhưng khoảng cách giữa hai phím luôn ≥ 20 ms, không có `mismatch`, vị trí không đổi theo nhịp và ba lượt Release ra cùng một chữ.
- Google Docs trên Safari 27.2 (17/11/2026, cùng máy, bộ gõ Debug `34644a3`, ô `gdocssafari`, cùng hai câu, một lượt mỗi câu) cũng sai, gần giống Chrome ("Homo nay minhf hocj tiengé Vietẹ voiws banj, buôir học online râts vui."; câu không có ⌫ ra "Hôm nay minhf học tiêngs Viêtj voiws banj, buôir học online râts vui."). Safari cũng trả vị trí `(1, 0)` ở cả 24 lần hỏi; thay một ký tự thì được, lần thay hai, ba ký tự thì Dấu không gửi đi, như ở Chrome. Safari chưa có EditContext, nên việc chỉ đưa bộ gõ một ký tự trước con trỏ là cách Google Docs tự làm ở cả hai trình duyệt, không do EditContext của Chrome.
- Lượt dò ngày 22/11/2026 (máy M3 Max, Chrome 157.0.8103.79, Safari 27.2). Bộ gõ là bản Debug của `5637bdf` có thêm mã dò, không giữ lại trong repo. Câu thử là câu không có ⌫ ở trên, 80 ± 30 ms một phím. Mã dò ghi trước mỗi phím vị trí con trỏ, `length()` và kết quả đọc các vùng `(0, 1)`, `(0, 8)`, `(0, 64)`, `(0, 4096)`, 64 ký tự trước và 16 ký tự sau con trỏ. Với mỗi vùng, mã dò chỉ ghi độ dài và số ký tự theo lớp (chữ cái, ký tự vô hình, dấu cách, khác), không ghi chữ (D8). Ở lượt gửi thẳng, lần thay cần xoá N ký tự khi vị trí là 1 được gửi thành `insertText(…, (0, N))`, thay vì cho phím đi thẳng.
  - **Trước con trỏ chỉ có đúng một ký tự, ở cả hai trình duyệt.** Vị trí là `(1, 0)` ở mọi phím đang gõ (Chrome 82/92 lần đọc, Safari 79/80; các lần còn lại rơi vào lúc gõ chuỗi đánh dấu hay lúc script chọn chữ). `length()` luôn trả 0. Đọc vùng vượt quá chữ có sẵn thì trả nil, không cắt bớt.
  - **Chrome:** ký tự ở vị trí 0 đổi lớp theo phím vừa gõ, nên đó là ký tự ngay trước con trỏ. Từ vị trí 1 trở đi còn một đoạn chữ dài gần bằng câu đã gõ: đọc `(0, 64)` có chữ khi câu đã quá 64 ký tự, đọc 16 ký tự từ vị trí 1 có chữ cái dù sau con trỏ trong tài liệu không có gì. Đoạn đó không phải chữ nằm sau con trỏ. Nó là chữ gì thì chưa rõ, vì mã dò không ghi chữ.
  - **Safari:** cả ô chỉ có một ký tự vô hình (79/79). Mọi vùng dài hơn một ký tự đều trả nil.
  - **Thay `(0, N)` với N từ 2 trở lên không chạy ở trình duyệt nào.** Chrome (1 lượt): Google Docs không áp lần thay đầu tiên ("minhf" ra "minh", mất cả dấu lẫn phím f). Sau đó vị trí báo về tăng dần theo phím, nhưng mọi lần thay sau đều mất dấu ("Hôm nay minh hoc tiengs Viet voi ban, buoi hoc online rat vui."). Tải lại trang thì tab về như cũ (một lượt chỉ đọc sau đó ra đúng chữ của ngày 17/11). Safari (1 lượt): Google Docs chỉ thay một ký tự rồi chèn cả phần mới ("Hôm nay minình học tiênếng Viêệt voơới baạn, buôổi học online râất vui."), tab vẫn chạy bình thường.
  - Lượt chỉ đọc ra cùng chữ với ngày 17/11 ở cả hai trình duyệt, nên mã hiện tại (Dấu tự chèn ký tự, N3) không đổi kết quả ở Google Docs.
- Gạch chân ở Google Docs trên Chrome (23/11/2026, 00:08–00:11, máy M3 Max, Chrome 158.0.8127.37). Bộ gõ là bản Debug của `064249e`, ép gạch chân bằng `typing/run.sh --underline`, có `underline-on` trong nhật ký ở từng lượt. Câu không có ⌫ và nhịp như lượt chẩn đoán ngày 17/11, gõ sau chuỗi đánh dấu. Dấu đúng 5/5 ("Hôm nay mình học tiếng Việt với bạn, buổi học online rất vui."), trong khi thay tại chỗ sai ở cùng ô và cùng giờ, 1/1 ("minhf", "tiêngs", "buôỉ"). Gạch chân không hỏi vị trí nên không vướng vị trí `(1, 0)` của Google Docs. Câu của `typed-word-docs.sh` ra "Homo nay mình hocj tiengé Vietẹ với bạn, buổi học online rất vui." 1/1: gạch chân không thêm dấu cho từ đã chốt (mục 6.8), như Telex của Apple. Gạch chân áp theo app (D5), nên bật cho Chrome thì áp cho mọi trang trong Chrome.
- Google Docs trên Safari mất ký tự đầu tiên khi gõ đè lên vùng chọn (22/11/2026, cùng máy và Safari; 4/4 lượt của Dấu, cả khi tắt mã dò). Script chọn toàn bộ tài liệu trống (⌘A ⌘C) rồi gõ chuỗi đánh dấu "qkpb ", và tài liệu ra "kpb ". Log cho thấy Dấu chèn "q" thay vùng chọn, rồi ở phím sau Safari báo vùng chọn `(0, 1)`, tức chữ "q" vẫn đang được chọn, và phím "k" thay mất nó. Telex của Apple ra đúng chuỗi đánh dấu (1/1) khi tài liệu không hiện các nút gợi ý của tài liệu trống ("Ghi chú cuộc họp", "Thư nháp"…). Khi các nút đó hiện, Telex của Apple cũng mất "q" (1/1).
  - Chẩn đoán (22/11/2026, cùng máy và Safari, ô `gdocssafari` với `--keys "vui "`, đã ẩn các nút gợi ý, 3 lượt mỗi ô, các ô xen kẽ nhau). Bản Release `5637bdf` mất "q" 3/3, trong khi Telex của Apple đúng 3/3. Trên một trang có ô soạn thảo thường trong Safari, gõ đè lên chữ đã chọn thì đúng 3/3, nên lỗi chỉ có ở Google Docs. Các ô còn lại dùng bản Debug thử, không giữ lại trong repo. Bản không đổi gì mất 3/3. Bản không hỏi vị trí trước khi chèn (tắt D20) vẫn mất 3/3, nên lần hỏi đó không phải nguyên nhân. Bản cho ký tự đi thẳng như trước khi Dấu tự chèn ký tự (N3) đúng 3/3.
  - **Nguyên nhân:** Google Docs trên Safari áp sai lần `insertText(…, NSNotFound)` của bộ gõ khi đang có vùng chọn: ký tự vào tài liệu nhưng vẫn ở trạng thái được chọn.
  - Hai cách sửa đã thử trên bản Debug. Chèn với vùng thay là chính vùng chọn vẫn mất 3/3. Cho riêng phím gõ đè lên vùng chọn (vùng chọn đã biết từ lần hỏi của D20) đi thẳng thì đúng 3/3.

### 5.11 Zed, Xcode, Antigravity, Obsidian, Notion

Các app này được đo để biết ngoài Terminal (mục 6.5) còn app nào giữ ⌫ lại, không đưa cho bộ gõ. Ở cả năm app, ⌫ tới bộ gõ và chữ đúng.

- Lượt đo chạy ngày 23/11/2026, 06:34–06:44 và 07:03–07:04 (Notion), trên máy M3 Max với bộ gõ Release của `db57e09` đã cài. Nhịp là 30 ms một phím. Có hai chuỗi phím. Chuỗi thứ nhất là câu `edit` (`scripts/selftest/load/run.sh --text edit --print keys|expect`), có ⌫ giữa từ ("khoong⌫g") và ⌫ qua dấu cách rồi thêm dấu (D20, "Hoc ⌫j"). Chuỗi thứ hai là `--keys "hoaf⌫ " --expect "hò "` (D32). Lệnh là `scripts/selftest/typing/run.sh` với ô `zed`, `xcode`, `antigravity`, `obsidian`, `notion`; ô nào gõ vào đâu ghi ở đầu script.
- Zed 1.29.2 (trình soạn thảo, tệp văn bản trống) đúng 1/1 câu `edit` và 2/2 `hoaf⌫`.
- Xcode 27.2 (trình soạn mã, tệp văn bản trống mở bằng `xed`) đúng 1/1 câu `edit` và 1/1 `hoaf⌫`. Lượt này chỉ đo tệp văn bản. Ở tệp mã, Xcode có gợi ý hoàn thành mã, và trường hợp đó chưa đo.
- Antigravity 2.33.0 (ô nhắn tin của app agent, không gửi) đúng 1/1 câu `edit` và 1/1 `hoaf⌫`.
- Obsidian 1.15.1 (ghi chú trong một kho tạm) đúng 1/1 câu `edit` và 1/1 `hoaf⌫`.
- Notion 7.44.1 (thân một trang riêng tư mới, đưa vào Trash sau khi đo) đúng 1/1 câu `edit` và 1/1 `hoaf⌫`.
- Ở lượt này Sublime Text cũng được đo lại (mục 5.7).
- Bộ gõ bản Release không ghi nhật ký từng phím (D8), nên lượt này không có số đo thời gian.

## 6. Giới hạn đã biết

Các lỗi đã sửa (mục cũ 6.4 Backspace trong Chromium, 6.6 và 6.7 biểu tượng nguồn, 6.9 ⌫ rồi phím dấu ở Safari khi trang bận) nằm ở [`docs/history/CompatibilityFixed.md`](history/CompatibilityFixed.md).

### 6.1 Tự sửa chính tả của macOS đè lên chữ đã giữ

- Ở ứng dụng bật tự sửa chính tả, khi phía trước là một câu tiếng Việt, macOS 27.2 có thể sửa chữ tiếng Anh vừa gõ thành chữ tiếng Việt ("…Sunrise car␣" → "cả"). Hiện tượng này xảy ra với Dấu và với Telex của Apple (log của Dấu chỉ có `pass`) và hết khi tắt "Correct Spelling Automatically". Với bàn phím U.S. thì chưa kiểm. macOS sửa chữ sau khi Dấu đã trả đúng chữ, nên bản sửa đè lên kết quả gõ đúp ("carr" → "car").
- Chữ cái đứng một mình cũng bị đổi ("Mình chọn phương án d." → "Mình chọn phương án Đ.").
- Từ quên dấu có thể bị sửa thành một từ khác ý người gõ ("Bé xây lâu đài cat␣" → "cắt"). Nếu quay lại thêm dấu lúc đó, Dấu tính trên chữ đang hiện ("cắt" + ⌫s → "căts"); Dấu không đoán từ người gõ định viết.
- Tự sửa cũng sửa các từ mà D4 trả về chuỗi phím (12/11/2026, `typing/run.sh --keys`, 30 ms, một lượt mỗi câu). Mail sửa "ddep" → "đẹp", "vieet" → "việt", "ddungsg" → "đúng". Notes sửa "vieet" → "việt", "ddungsg" → "đúng", nhưng "ddep" → "đé". Vì vậy ở ứng dụng bật tự sửa, nhóm lỗi K1 ([`docs/research/EditingTypedText.md`](research/EditingTypedText.md) mục 3) phần lớn không tới tay người gõ; ở ứng dụng không có tự sửa (Chrome, trình soạn thảo mã) thì nhóm lỗi này vẫn còn.
- Các ca đã thấy đều là chữ còn thiếu dấu lúc bấm dấu cách. Từ đã gõ dấu ngay trong từ không bị sửa ở lần đo nào ("Bé xây lâu đài cats␣" → "cát", gõ tay).
- Có một ngoại lệ: ngày 23/11/2026 (máy M3 Max, macOS 27.2.1), Notes sửa "mình đi" thành "mình dì" trong chuỗi `std`, 30 ms, ở cả Dấu (3/3) lẫn Telex của Apple (1/1). Log của Dấu cho thấy "đ" được thay đúng chỗ và không còn phép thay nào ở từ đó. Ngày 22/11 cùng ô vẫn ra "đi". Vì sao hệ thống bắt đầu sửa từ này thì chưa rõ.
- Hệ thống hiện chữ định sửa trong một bong bóng dưới từ khi người gõ dừng sau từ đó. Dấu cách chấp nhận chữ trong bong bóng.
- Giới hạn và cách Dấu xử lý nằm ở D4 (đoạn "Giới hạn đã biết") và D20 (ý "Từ hệ thống vừa sửa"). Dấu không tắt tự sửa của hệ thống (N4 (Không tự đổi cài đặt hệ thống)); người dùng hoàn tác bằng ⌘Z hoặc bấm vào chữ bị sửa.
- Tự sửa là thuộc tính của từng ô do ứng dụng quyết định (ví dụ `NSTextView.isAutomaticSpellingCorrectionEnabled`, https://developer.apple.com/documentation/appkit/nstextview/isautomaticspellingcorrectionenabled), nên ứng dụng không dùng hệ thống văn bản của Apple có thể không bị (suy luận).
- Câu mẫu của `typing/run.sh` đặt "carr" trước câu tiếng Việt để né việc này (chú thích đầu script).

### 6.2 Ứng dụng áp phím bất đồng bộ

- Chromium, Electron và Terminal áp phím bất đồng bộ, nên khi phím đến dồn hay app bận, `selectedRange` trả vị trí cũ. Ảnh chụp cũ này không cập nhật trong lúc `handle` đang chạy (hỏi lại 10 lần, cách nhau 2 ms, vẫn y nguyên).
- Nguyên nhân không phải do thiếu quyền Trợ năng, vì bộ gõ không có quyền đó mà vẫn đúng ở 20 ms trở lên.
- Cách xử lý theo D11 ý "App trả lời chậm" (cơ chế nằm ở [`docs/Architecture.md`](Architecture.md) mục "App trả lời chậm"). Dấu vẫn hỏi `selectedRange` ở phím có thay chữ và tự theo dõi vị trí con trỏ. Khi vị trí app trả khác, Dấu đọc chữ trước con trỏ một lần để chứng minh app chỉ chưa áp các thao tác vừa gõ, rồi thay ở vị trí tự theo dõi. Nếu không chứng minh được thì Dấu dựng lại hoặc reset.
- Ở các app đã đo, chữ tiếng Việt đúng, trừ app bỏ qua vùng thay (mục 6.8); riêng trình soạn thảo WebStorm mất khôi phục D4 (mục 5.9). Ngoại lệ là Terminal: nó đúng từ 30 ms trừ ⌫ (mục 5.5, 6.5) và còn có lượt sai khi phím dồn dưới 30 ms.
- Các hướng không dùng gồm: tự cộng dồn vị trí từ một vị trí gốc thay vì hỏi, vì vị trí gốc cũng là ảnh chụp cũ và VS Code đổi gốc toạ độ; chờ ứng dụng rồi hỏi lại; và so chữ trước con trỏ bằng `attributedSubstring` làm phép thay (Safari trả chữ cũ, nên cách này hỏng cả Safari).
- Người gõ tay hiếm khi có hai phím cách nhau dưới 10 ms, nhưng phím lặp khi giữ phím, máy tải nặng hay ứng dụng tạm đứng có thể làm phím đến dồn (suy luận).

### 6.3 Ô mật khẩu

Ở ô nhập bảo mật (ví dụ ô mật khẩu trong Safari), macOS giữ bàn phím `com.apple.keylayout.US`. Đó là nguồn mà TIS báo, còn `M2Testing.md` không ghi cách quan sát nào khác. Dấu không nhận phím nào. Đây là hành vi của hệ thống, không phải lỗi ([`docs/history/M2Testing.md`](history/M2Testing.md) mục 4 dòng 17).

### 6.5 Terminal không gửi ⌫ cho bộ gõ

Terminal xử lý ⌫ mà không đưa phím cho bộ gõ, nên D32 không giữ được ở đó. D20 sau ⌫ không chạy ("hocj"). Lượt đo D20 ngày 30/10/2026 phát hiện lỗi này (nhật ký 30/10 trong [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md)). Lượt đo ngày 12/11/2026 (`hoaf⌫` trong câu, 120 và 30 ms) xác nhận rằng Terminal ra "ho" thay vì "hò". Ở các app khác đã đo `hoaf⌫` (mục 5), ⌫ đều tới bộ gõ, kể cả các app có trình soạn thảo riêng như Zed, Xcode, Obsidian và Notion (mục 5.11).

### 6.8 Terminal bỏ qua vùng thay; gạch chân không sửa được từ đã chốt

- Cơ chế (đọc từ mã) và các hướng đã xét nằm ở [`docs/research/TerminalAndUnderline.md`](research/TerminalAndUnderline.md). Chuỗi phím và đáp án nằm ở `scripts/research/terminal-underline/run.sh`. Quyết định là D43.
- Ghostty 1.4.0 không thay theo `replacementRange` và báo `selectedRange` là `{0,0}`. Đây không phải trường hợp app trả lời chậm (mục 6.2), nên hỏi lại bao lâu cũng không đúng. Dấu không xử lý riêng (D43): thay tại chỗ sai, gạch chân đúng và Ghostty mang nhãn "Đề xuất". Số đo nằm ở mục 5.6.
- Terminal Reworked của WebStorm 2026.3 cùng loại: thay tại chỗ sai, gạch chân đúng (mục 5.9). Terminal này không gắn nhãn, cùng lý do như VS Code.
- Terminal dựng bằng xterm.js cho thay tại chỗ sai và gạch chân đúng, kể cả ở trình soạn thảo cùng cửa sổ khi chuyển ô (số đo nằm ở mục 2 của tài liệu research nói trên). Đó là terminal tích hợp của VS Code. Cursor và app Claude dùng cùng cơ chế nhưng chưa đo. Các app này không được gắn nhãn, vì chúng có nhiều ô gõ khác. Bật gạch chân cho cả app thì mọi ô mất D20.
- Ghostty nuốt Return ngay sau khi chốt chữ gạch chân, với Dấu và với Telex của Apple. Đây là lỗi của Ghostty (PR #15048 của Ghostty tả lỗi này, đã đóng mà chưa merge).
- Gạch chân (D13) không có D20: ⌫ về từ đã chốt hay ← vào giữa từ rồi gõ dấu, thì ra chữ gốc ("baj", "tôsi"); Telex của Apple cũng vậy. Ứng dụng thay tại chỗ đúng (như Sublime Text) không nên bật gạch chân.

## 7. Còn mở

Các mục dưới đây làm sau beta đầu tiên: người thử báo lỗi thay vì đo trước (`docs/Roadmap.md` mục "Tồn đọng chưa gắn mốc").

- Các ứng dụng chưa đo (mục 3) là Arc, Brave, JetBrains IDE trừ WebStorm, iTerm2, Warp, Zalo, Messenger (web), Telegram Desktop, Discord, Slack, Microsoft Teams, Word, Excel, PowerPoint, Pages, Numbers, Keynote, Google Sheets, Messages, Spotlight, Finder, Figma, Raycast, Alfred và phần còn lại của Mail. Các ứng dụng Electron đáng thử thêm là Claude (`com.anthropic.claudefordesktop`), GitHub Desktop (`com.github.GitHubClient`) và Postman (`com.postmanlabs.mac`); ngoài ra còn Zoom (`us.zoom.xos`).
- VS Code khi app bận chưa được đo.
- Với Google Docs (Chrome và Safari), cần tìm cách sửa khi trước con trỏ bộ gõ chỉ thấy một ký tự (mục 5.10; các đường đã xét nằm ở [`docs/research/WebEditorInput.md`](research/WebEditorInput.md) mục 10). Sửa nhiều bước và gửi thẳng vùng thay rộng hơn đều đã đo và không được (mục 10.6 của file đó).
- Google Docs trên Safari mất ký tự đầu tiên khi Dấu gõ đè lên vùng chọn (mục 5.10). Nguyên nhân đã rõ; cách sửa đo được là cho phím đó đi thẳng, tức thêm một ngoại lệ vào N3, nên cần người dùng quyết định.
- Click reset và mũi tên reset chưa được đo cho phần lớn ứng dụng (mũi tên reset theo D4 × D20).
- Trình soạn thảo WebStorm mất khôi phục D4 vì Dấu bị reset sau mỗi phím (mục 5.9). Số đo có trước khi Dấu tự chèn ký tự và chưa đo lại. Bước kế tiếp và các ca còn đáng đo (⌫ dời dấu, Return sau từ cần khôi phục, nhịp 30 ms) nằm ở [`docs/research/JetBrainsInput.md`](research/JetBrainsInput.md) mục 5.
- Ở Chrome, "vieetj" giữ nguyên trong thanh địa chỉ tab mới và chưa tái hiện được.
- Edge chưa được đo trong điều kiện trang bận từ khi Dấu tự chèn ký tự. Word trên web đo lại ngày 22/11 và vẫn đúng (mục 5.10); Google Docs đã đo lại ngày 22/11 và ra chữ như cũ (mục 5.10).
- Với tự sửa chính tả của macOS (mục 6.1), còn phải biết những ứng dụng nào bật nó và từ nào bị sửa.
- Terminal trong app Claude (xterm.js trong Electron) chưa được đo; VS Code dùng cùng cơ chế và đã được đo (mục 6.8).
- Pages có hai bundle ID trên cùng máy. Numbers và Keynote bản mới đã đổi ID. Nếu các ứng dụng này cần quy tắc, danh sách tương thích phải ghi đủ các ID.
