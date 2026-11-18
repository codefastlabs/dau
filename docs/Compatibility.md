# Tương thích ứng dụng

Dấu gõ đúng hay sai trong từng ứng dụng, ở nhịp nào và vì sao; giới hạn còn lại và cách thử. Mọi số đo trên máy M1 (M1 Pro), macOS 27.2, trừ các lượt trên máy M3 Max (Chrome khi trang bận, phím dồn ở Chrome và Firefox, 10/11/2026); ô nào chưa thử thì để trống, không điền bằng phỏng đoán. Đây không phải lời hứa (N5 (Chỉ hứa điều đã kiểm chứng)): trang web chỉ dùng kết quả theo [`docs/Website.md`](Website.md).

## Hiện trạng (17/11/2026)

Tiêu chí nhãn "Đề xuất" ở D13 (Gạch chân là đường lui cuối cùng). Nhịp là khoảng cách giữa hai phím khi tự gõ; gửi cả chuỗi một lần (0 ms) không phải tốc độ gõ thật, không là tiêu chí. Chi tiết và điều kiện đo: mục 5.

Dưới tải nặng (`scripts/selftest/load/heavy.sh`, 12/11/2026, một lượt, máy M1 đang bận): chữ đúng ở mọi ô của Dấu, thời gian thay chữ đạt ngưỡng D42 (Ngưỡng hiệu năng); số chi tiết ở nhật ký `docs/history/LogM6.md`.

| Ứng dụng | Thay tại chỗ | Gạch chân | Nhãn "Đề xuất" |
|---|---|---|---|
| Safari, TextEdit | đúng ở 30 ms (29–30/10/2026) và 120 ms (Backspace, thêm dấu); Safari 27.2 ở 5 ms đúng 2/3 (17/11/2026), lượt sai hỏng đúng từ đầu của tài liệu mới, chưa rõ nguyên nhân (mục 5.1); Safari 27.2 ở 5–20 ms đúng 18/18 lúc trang rảnh, sai 9/9 khi trang bận (18/11/2026, máy M3 Max, mục 5.1) | đúng | không |
| Chrome | đúng ở 5–20 ms (10/11/2026, máy M3 Max), khi trang bận (10/11/2026, máy M3 Max; 17/11/2026, Chrome 157, máy M1) và trong trình soạn thảo TipTap (9/9, 12/11/2026); khi trang bận: bản `0b1a42d` sai ở 5–20 ms (9/9) và ở nhịp người gõ nhanh (4/6); từ `85dd1b1` sai 2/6 ở nhịp người, lỗi nhỏ hơn nhiều ở 10 ms (18/11/2026, máy M3 Max, mục 5.2) | đúng ở 0 ms | không |
| Edge | đúng ở 5–20 ms và khi trang bận (10/11/2026, máy M1; 17/11/2026, Edge 157.0.4341.60) | đúng ở 0 ms | không |
| Firefox | đúng ở 5–20 ms (10/11/2026, máy M3 Max) và khi trang bận (10/11/2026, máy M1; 17/11/2026, Firefox 160.0) | đúng ở 0 ms | không |
| VS Code | đúng ở 5–20 ms: 14/15 lượt (10/11/2026, VS Code 1.145.2) và 2/2 lượt (17/11/2026, VS Code 1.146.0, mỗi lượt sau một ô Telex của Apple), máy M1 (mục 5.3) | đúng ở 0 ms | không |
| Cursor (3.30.14) | khung agent (⌘L) và ô nhập Agents đúng ở 5 ms; trình soạn thảo đúng khi trả vị trí từ đầu văn bản, sai vài từ ở 5 ms khi trả vị trí từ đầu từ (mục 5.4) | chưa đo | không |
| Terminal | đúng ở 30 và 120 ms (12/11/2026; 30 ms lại 1/1 ngày 17/11/2026), sai khi phím dồn dưới 30 ms và ở 0 ms; ⌫ không tới bộ gõ (mục 5.5, 6.5) | đúng ở 5–20 ms (17/11/2026), sai ở 0 ms | **có** |
| Ghostty | sai: app bỏ qua vùng thay, Dấu không xử lý riêng (D43; mục 6.8) | chữ đúng, Return ngay sau từ bị nuốt | **có** |
| xterm.js (trang thử trong Chrome) | sai (D43; mục 6.8) | đúng | không |
| Terminal tích hợp của VS Code (xterm.js) | sai (D43); trình soạn thảo cùng cửa sổ vẫn đúng sau khi chuyển từ terminal sang (mục 6.8) | đúng, cả khi chuyển sang trình soạn thảo | không: bật cho cả app thì mọi ô mất D20 |
| Sublime Text | đúng, cả thêm dấu cho từ đã gõ sau ⌫ và ← | không thêm dấu được cho từ đã chốt | không |
| WebStorm, trình soạn thảo | chữ tiếng Việt đúng ở 80 ms; từ tiếng Anh không được khôi phục (D4), lỗi của Dấu chưa sửa (mục 5.9) | đúng ở 80 ms | không |
| WebStorm, terminal | sai (D43; mục 6.8) | đúng ở 80 ms | không: bật cho cả app thì mọi ô mất D20 |
| Notes | đúng ở 30 ms (30/10/2026) | chưa đo | không |
| Mail | đúng ở 30 ms (30/10/2026); số đo 11/11 (120 ms) và 12/11/2026 (30 ms) chỉ về tự sửa chính tả của macOS (mục 6.1) | chưa đo | không |
| Telegram | đúng ở 5 và 30 ms (chuỗi chuẩn) và ở 100 ± 30 ms (chuỗi `edit`), 17/11/2026 (mục 5.8) | chưa đo | không |
| Word trên web (Chrome) | đúng ở 80 ± 30 ms, cả thêm dấu cho từ đã gõ: 6/6 lượt (17/11/2026, máy M3 Max; mục 5.10) | chưa đo | không |
| Google Docs (Chrome) | sai 3/3 lượt ở 80 ± 30 ms: không thêm dấu được cho từ đã gõ, và sai mọi lần thay quá một ký tự, nên sai cả chữ gõ liền mà Telex của Apple gõ đúng (17/11/2026, máy M3 Max): Google Docs trả vị trí con trỏ luôn là (1, 0), Dấu chỉ thay được một ký tự (mục 5.10) | chưa đo | không |

- Brave, Arc và các app Electron khác không có nhãn: chưa đo, nên chưa có số đo cho thấy sai (D13); không suy từ Chrome, Edge, VS Code, Cursor: kết quả đo ở app này không suy ra cho app kia. Đo mà sai thì gắn lại theo D13.
- Trình duyệt: script chỉ gõ khi ô của trang có focus, nên mọi số đo trình duyệt là gõ vào ô của trang.
- 16 trong 43 ứng dụng ở mục 3 có số đo (JetBrains IDE: chỉ WebStorm); danh sách chưa đo ở mục 7.

## 1. Danh sách tương thích

- Danh sách có sẵn trong bản build: `Apps/Dau/Resources/CompatibilityList.json`, model `CompatibilityList` trong DauShared. Mỗi mục: bundle ID, cờ `suggestUnderline`, ghi chú cho người bảo trì.
- Danh sách đi kèm app và đổi theo bản cập nhật app, không tải riêng (D7 (Cập nhật và loại bản dựng)); tiến trình bộ gõ không tải gì (N2 (Bộ gõ không có quyền mạng)).
- Ứng dụng có `suggestUnderline` hiện ở mục "Đề xuất" của trang Ứng dụng (D5 (Quy tắc theo ứng dụng); hành vi: [`docs/UI.md`](UI.md) mục "Ứng dụng"). Mặc định mọi ứng dụng không gạch chân; người dùng tự bật.
- Ai có nhãn: D13. Bundle ID lấy từ mục 3.

## 2. Vì sao ghi công nghệ giao diện

Dấu thay chữ tại chỗ: ở phím có thay chữ, hỏi `selectedRange` một lần rồi gọi `insertText(_:replacementRange:)` (D11 (Kiểm tra ngữ cảnh), N3 (Ít lời gọi vào ứng dụng đích)). Cách này cần ứng dụng trả vị trí con trỏ đúng lúc hỏi và thay theo vùng thay. Công nghệ giao diện là dấu hiệu dự đoán tốt nhất trước khi đo:

- AppKit, WebKit (TextEdit, Safari, Notes): áp phím ngay, chưa thấy lỗi.
- Chromium, Electron, Terminal: áp phím bất đồng bộ, trả vị trí cũ khi phím dồn hay app bận (mục 6.2).
- Terminal tự vẽ (Ghostty) và xterm.js: bỏ qua vùng thay (mục 6.8).
- Client không hỗ trợ TSMDocumentAccess thì `selectedRange` trả `NSNotFound` và `replacementRange` bị bỏ qua (header `IMKInputSession.h`, SDK macOS 27.0; header ghi trường hợp này "cực kỳ hiếm"). Bộ gõ đếm là `unsupported`; chưa gặp ở ứng dụng nào. Trang tài liệu web của `IMKTextInput` trả 404 ([`docs/research/IMKAPINotes.md`](research/IMKAPINotes.md)); phía ứng dụng: https://developer.apple.com/documentation/appkit/nstextinputclient/selectedrange() và https://developer.apple.com/documentation/appkit/nstextinputclient/inserttext(_:replacementrange:)
- Gạch chân dùng `setMarkedText(_:selectionRange:replacementRange:)`, không hỏi vị trí nên không bị lỗi bất đồng bộ; đổi lại không có D20 (Thêm dấu cho từ đã gõ).

## 3. Ứng dụng và công nghệ giao diện

"Máy này": tra trong `/Applications`, `~/Applications`, `/System/Applications`, `/System/Library/CoreServices` và `mdfind kMDItemCFBundleIdentifier == '…'`; phiên bản là `CFBundleShortVersionString` lúc tra (Cursor, Ghostty, Sublime Text: lúc đo). Chrome, Edge, Firefox, VS Code, Cursor, Safari, Terminal, Ghostty, Sublime Text, Notes, Mail, Telegram, WebStorm: tra lại ngày 17/11/2026; các dòng khác: tra ngày 30/10/2026. Cột cuối ghi phiên bản lúc đo khi nhật ký có, "không rõ" khi không. Công nghệ đọc từ bundle (`Contents/Frameworks`, `otool -L`, không mở app); app không có trên máy ghi "suy luận". "web" = thử trong trình duyệt. Cột cuối: kết quả đo (mục 5) hoặc dự đoán (suy luận).

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
| Soạn mã | Zed | `dev.zed.Zed` | có (1.23.2) | tự vẽ bằng Metal (GPUI, Rust), vỏ AppKit | chưa biết |
| Soạn mã | Sublime Text | `com.sublimetext.4` | có (Build 4215) | tự vẽ, vỏ AppKit | đã đo, mục 5.7 (lúc đo: Build 4215) |
| Soạn mã | JetBrains IDE | `com.jetbrains.WebStorm`; khác: `com.jetbrains.intellij`, `com.jetbrains.intellij.ce`, `com.jetbrains.pycharm`, `com.jetbrains.goland`, `com.google.android.studio` | WebStorm có (2026.3, `~/Applications`); các ID khác không | Java (JetBrains Runtime); terminal Reworked dựng trên trình giả lập Ghostty VT | WebStorm đã đo, mục 5.9 (lúc đo: 2026.3) |
| Soạn mã | Xcode | `com.apple.dt.Xcode` | có (27.1) | AppKit, trình soạn mã riêng | chưa biết; có gợi ý hoàn thành mã |
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
| Văn phòng | Word trên web | web | web | trình duyệt | đã đo, mục 5.10: đúng (lúc đo: Chrome 157.0.8103.79) |
| Văn phòng | Google Sheets | web | web | trình duyệt | chưa biết |
| Văn phòng | Notion | `notion.id` | có (7.41.1) | Electron | như VS Code (suy luận) |
| Văn phòng | Obsidian | `md.obsidian` | không | Electron (suy luận) | như VS Code (suy luận) |
| Apple | Ghi chú (Notes) | `com.apple.Notes` | có (4.13) | AppKit | đã đo, mục 5.8 (lúc đo: 4.13) |
| Apple | Mail | `com.apple.mail` | có (16.0) | AppKit; khung soạn thư dùng WebKit (suy luận) | đã đo, mục 5.8 (lúc đo: 16.0) |
| Apple | Tin nhắn (Messages) | `com.apple.MobileSMS` | có (26.0) | Mac Catalyst | chưa biết |
| Apple | Spotlight | `com.apple.Spotlight` | có | giao diện hệ thống | chưa biết; ô tìm có gợi ý tự hoàn thành |
| Apple | Finder (đổi tên tệp) | `com.apple.finder` | có (27.2) | AppKit | thấp (suy luận) |
| Khác | Figma | `com.figma.Desktop` | có (126.11.7) | Electron, nội dung vẽ bằng canvas | rủi ro cao (suy luận) |
| Khác | Raycast | `com.raycast.macos` | không | AppKit (suy luận) | chưa biết; ô tìm có gợi ý |
| Khác | Alfred | `com.runningwithcrayons.Alfred` | không | AppKit (suy luận) | chưa biết; ô tìm có gợi ý |

Bundle ID mà bộ gõ thật sự nhận có thể khác cột trên (ví dụ tiến trình con của trình duyệt): khi thử, đọc ID từ `scripts/perf/perf-report.sh` (mục 4.4) và sửa cột nếu khác.

## 4. Cách thử

### 4.1 Chuẩn bị

1. Thoát các bộ gõ tiếng Việt khác đang chạy (OpenKey, EVKey, GoTiengViet…), kể cả trong Mục đăng nhập.
2. Cài bản Debug: `scripts/dev/install-app.sh --debug` (chỉ bản Debug có nhật ký từng phím, D8 (Không telemetry)). Thử xong cài lại bản dùng hằng ngày: `scripts/dev/install-app.sh --ref stable`.
3. Lần đầu trên máy: mở Dấu trong `/Applications`, bấm "Bật Dấu" rồi Allow (D37 (Cài bộ gõ)). Không bật được thì theo đường lui của D37: tự thêm bằng "+" trong danh sách nguồn đầu vào của System Settings, "+" không có Dấu thì đăng xuất một lần ([`docs/research/InputMethodInstall.md`](research/InputMethodInstall.md) mục 1.3, 3.2).
4. Giữ U.S. (hoặc một nguồn tiếng Anh khác) trong danh sách nguồn: Dấu chỉ có nguồn tiếng Việt (D2 (Chuyển Việt/Anh)).
5. Máy bật "Automatically switch to a document’s input source" thì mỗi ứng dụng nhớ nguồn riêng: chọn lại Dấu sau khi chuyển sang ứng dụng cần thử.
6. Bộ gõ không chạy: xem log bằng `/usr/bin/log stream --predicate 'process == "DauInputMethod"'` (trong zsh, `log` là lệnh có sẵn khác).
7. Chỉ gõ vào ô nháp: tài liệu mới không lưu, Saved Messages của Telegram, ô soạn tin không gửi. Không gửi tin, không lưu tệp nếu người dùng chưa cho phép.
8. Ghi lại: ngày, commit của Dấu, phiên bản ứng dụng, phiên bản macOS, chế độ gạch chân của ứng dụng đó.

### 4.2 Gõ

- Ứng dụng có trong `scripts/selftest/typing/run.sh`: tự gõ bằng script. Ứng dụng nào, câu mẫu và đáp án, tuỳ chọn (`--delay`, `--keys`, `--underline`, `--source`, `--busy`…), cách mở và đọc chữ, quyền cần cấp: đầu script. Script chiếm màn hình: hỏi giờ chạy trước (CLAUDE.md).
- Nhịp: 120 ms gần gõ thường; 5, 10, 20 ms để tìm ngưỡng phím dồn; `--busy` cho trang bận (M6).
- Đối chứng: Telex của Apple cùng điều kiện (`--source`), theo [`scripts/CLAUDE.md`](../scripts/CLAUDE.md) mục "Đo độ đúng khi gõ".
- Ứng dụng khác: gõ tay (tốc độ bình thường, rồi gõ nhanh hết sức), ghi rõ cách thử ở mục 5.

### 4.3 Những gì cần kiểm tra

| Kiểm tra | Cách làm | Mong đợi |
|---|---|---|
| Chữ đúng | so từng ký tự với đáp án | khớp hoàn toàn |
| Gạch chân, nhảy chữ | nhìn trong lúc gõ | chế độ thường: không gạch chân; không lặp, mất, đảo chữ; con trỏ không nhảy |
| Backspace (D32 (Backspace)) | `hoaf` rồi ⌫ | "hoà" rồi "hò" |
| Click reset (D4 (Từ nước ngoài), D11) | `tooi`, click sau dấu cách hoặc đầu dòng, `s` | chỉ thêm "s" ở chỗ mới. Click ngay sau một chữ thì D20 có thể đặt dấu vào chữ đó |
| Mũi tên reset (D4 × D20) | `tooi`, ←, nghỉ một nhịp, `s` | D20 bật: "tối" (dấu vào chữ trước con trỏ, "i" giữ nguyên). D20 tắt: "tôsi" |
| Thêm dấu cho từ đã gõ (D20) | `hoc`, dấu cách, ⌫, `j` | "học", ở mọi nhịp gõ; ứng dụng gạch chân: "hocj" |
| Tự sửa chính tả (D4) | câu tiếng Việt rồi `Sunrise carr␣` | "car". Thành "cả" là macOS sửa, không phải Dấu: Telex của Apple cũng bị (mục 6.1) |

### 4.4 Số đo

- `scripts/perf/perf-report.sh --last 5m --app <tên app hoặc một phần bundle ID>` ngay sau khi gõ; `typing/run.sh` tự in báo cáo này. Cột, cách bật nhật ký từng phím (`DauPerfLog`) và tắt sau khi đo: đầu script.
- Ghi: `selectedRange` p50 / p99 µs, `count_mismatch` (vị trí khác dự đoán), `count_unsupported` (ứng dụng trả `NSNotFound`).
- `event_client-changed` tăng theo từng phím, hay `event_client-not-text-input` khác 0: báo lại ngay.
- Bản Debug có thêm một lần hỏi chẩn đoán sau mỗi lần thay (`ReplaceDiag.swift`), chạy sau khi ghi thời gian nên không nằm trong số. Bản phát hành không ghi gì theo từng phím (D8), nên số đo lấy từ bản Debug. Cần p99 đáng tin thì gõ thêm vài trăm phím có dấu.

## 5. Số đo theo ứng dụng

Nguồn: số M1–M3 (29–30/10/2026) ở bảng "Số đo (M1–M3)" của [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md) và nhật ký 30/10 cùng file; lượt chạy ma trận 30/10/2026 ở [`docs/history/CompatibilityFixed.md`](history/CompatibilityFixed.md); số M6 ở [`docs/history/LogM6.md`](history/LogM6.md), sau M6 ở nhật ký [`docs/Progress.md`](Progress.md), theo ngày. Số µs là `selectedRange` p50 / p99 ở 30 ms, phím có thay chữ, bản Debug. Phím dồn M6: nhịp danh nghĩa 5, 10, 20 ms, khoảng cách phím thật phần lớn 10–20 ms. Trang bận M6: trang thử chặn luồng chính 300 ms mỗi giây, phím cách 100 ± 30 ms.

### 5.1 Safari, TextEdit

- Câu mẫu đúng ở 30 ms, gõ tay đúng; gạch chân đúng ở 30 ms (29–30/10/2026). Cả hai cũng đúng khi gửi cả chuỗi một lần (0 ms), không là tiêu chí (D13).
- Safari 27.2 (17/11/2026, bản Debug của `8d3e93a`, máy M1, chuyển nguồn bằng phím tắt hệ thống, có xác nhận trong ô): chuỗi `std` ở 5 ms đúng 2/3; Telex của Apple cùng điều kiện đúng (hợp lệ). Lượt sai hỏng đúng từ đầu ("Chiều" ra "hieCeuf"). Log: ở lần thay đầu của tài liệu mới, Safari trả vị trí chậm (`selectedRange` 2, Dấu theo dõi 4, `kind=late`). Nguyên nhân chưa rõ; việc mở ở mục 7. Mô hình test: `stalledStartTable`, `typedHere`.
- Safari 27.2 (18/11/2026, máy M3 Max, bản Debug của `f0a9102`, chuỗi `edit`, nhịp 5, 10, 20 ms, 3 lượt mỗi nhịp, hai bản có và không có ngưỡng 50 ms của D11): trang rảnh đúng 18/18; trang bận (`--busy 300:1000`) sai 9/9 với bản đang dùng, Telex của Apple cùng điều kiện ra đúng chữ của chính nó.
  - Chẩn đoán (18/11/2026, 3 lượt 10 ms): khác Chrome. Safari dồn phím: mỗi lượt khoảng 59 phím tới bộ gõ cách nhau dưới 2 ms, cùng dấu thời gian, sau những quãng trang bị chặn. Chỉ 1 lần mỗi lượt Dấu tin vị trí cũ chậm từ 3 ký tự, nhưng mỗi lượt có 3–4 lần Safari báo vị trí **vượt** vị trí Dấu theo dõi, điều mà một app chỉ trả lời chậm không làm ra. Chưa rõ nguyên nhân; giả thuyết: (a) trong một loạt phím dồn, Safari tự chèn một phím mà bộ gõ cũng xử lý; (b) Safari áp vùng thay của một lần thay `late` vào chữ đã đổi, nên lệch chỗ ("một" ra "mọoot"). Nhịp người gõ nhanh (cùng điều kiện như Chrome ở mục 5.2): sai 2/3, mỗi lượt vài từ.
- Backspace, thêm dấu cho từ đã gõ (120 ms): đúng.
- `selectedRange`: TextEdit 327 / 606, Safari 622 / 1.057 µs; mismatch 0.
- TextEdit: mũi tên reset theo mong đợi D4 × D20 chưa đo ([`docs/history/M2Testing.md`](history/M2Testing.md) mục 4). TextEdit không nằm trong script vì tự lưu tài liệu thử lên iCloud Drive ([`docs/Troubleshooting.md`](Troubleshooting.md)).

### 5.2 Chrome, Edge, Firefox

- Gạch chân ở 0 ms đúng ở cả ba.
- Phím dồn (10/11/2026, nhịp danh nghĩa 5, 10, 20 ms, app rảnh): Chrome và Firefox đúng 7/7 lượt mỗi app (máy M3 Max), Edge 9/9 (máy M1).
- Trang bận (chuỗi `edit`, 100 ± 30 ms, 3 lượt mỗi app): Chrome 3/3 (10/11/2026, 06:13, máy M3 Max), Edge 3/3 và Firefox 3/3 (10/11/2026, máy M1). Chrome 157 với mã `5564963`, 17/11/2026, máy M1: thay tại chỗ lại đúng 3/3; Edge 157.0.4341.60 và Firefox 160.0 (17/11/2026, máy M1, bản Debug của `8d3e93a`, chuỗi `edit`, 100 ± 30 ms, trang bận `--busy 300:1000`): đúng 1/1 mỗi app; ở chế độ gạch chân, "Hoc ⌫ j" ra "Hocj" 3/3 vì gạch chân không thêm dấu cho từ đã chốt (mục 6.8).
- Trình soạn thảo TipTap/ProseMirror trong Chrome (12/11/2026, Dấu Release 4ae3646, `typing/run.sh tiptap`, câu mẫu 41 phím, 5/10/20 ms có jitter, 3 lượt mỗi mức): đúng 9/9 lượt; Telex của Apple cùng điều kiện ra cùng một chữ ở cả 9 lượt, khác Dấu chỉ ở từ tiếng Anh (D4), nên phép đo hợp lệ. Không tái hiện được lỗi mất dấu khi gõ nhanh trong trình soạn thảo web.
- Phím dồn, chuỗi `std` ở 5 ms (17/11/2026, máy M1, bản Debug của `8d3e93a`, chuyển nguồn bằng phím tắt hệ thống, có xác nhận trong ô): Edge 2/2, Firefox 2/2. Telex của Apple cùng điều kiện hợp lệ ở cả hai (ra "mêting"; ở Edge thêm "Ciều").
- Backspace, thêm dấu cho từ đã gõ (120 ms): đúng ở cả ba (Backspace, 82d9ecc).
- `selectedRange`: Chrome 415 / 694, Edge 369 / 6.828, Firefox 265 / 1.174 µs.
- Phím dồn khi trang bận (18/11/2026, máy M3 Max, Chrome 157.0.8103.79, bản Debug của `f0a9102`, chuỗi `edit`, nhịp 5, 10, 20 ms, `--busy 300:1000`, 3 lượt mỗi nhịp): Chrome sai 9/9, chữ hỏng nhiều chỗ ("bạửigui", "projecả"); Telex của Apple cùng điều kiện ra đúng chữ của chính nó lúc trang rảnh ở cả 3 nhịp, nên trang không làm rơi phím. Cùng lượt, lúc trang rảnh: đúng 18/18. Edge, Firefox chưa đo.
  - Chẩn đoán (18/11/2026, bản Debug của `f0a9102`, 10 ms, 3 lượt trang bận và 1 lượt 100 ± 30 ms trang bận làm đối chứng): phím tới bộ gõ đều, khoảng 17 ms một phím (không dồn). Trang bận làm Chrome trả vị trí chậm tới 12 ký tự. Phần lớn các lần chậm được phép chứng minh app chậm của D11 nhận ra (`late`). Lỗi nằm ở các lần phép chứng minh không qua, ở lần thay đầu của một từ, khi vị trí chậm từ 3 ký tự trở lên: quá `CursorTracker.lateLimit` (2) nên Dấu không đoán là app chậm, mà tin vị trí cũ và thay chữ lùi về đó (`kind=replace`, vị trí app báo nhỏ hơn vị trí Dấu theo dõi). Ví dụ "bạn gửi" ra "bạửigui": Dấu ở 26, Chrome báo 23, Dấu thay ở 21–23. Số lần như vậy đi cùng mức hỏng: 3, 4, 6 lần cho khoảng cách chỉnh sửa 11, 10, 21; lượt 100 ms không có lần nào và đúng. Sau mỗi lần thay sai, vị trí Dấu theo dõi lệch theo nên các lần sau cũng lệch. Nguyên nhân gốc (log Debug có các con số của phép chứng minh): độ chậm được chấp nhận là `lateLimit` cộng số phím dồn liền nhau, mà số đó về 0 ở mỗi chỗ ngắt từ (50–60 ms) trong khi Chrome vẫn chậm; hướng sửa đã thử ở [`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md) mục 3.
  - Sửa ở commit `85dd1b1` (18/11/2026): ở phím thay chữ trong từ, app được chậm mọi thao tác kể từ lần cuối nó trả lời đúng lúc. Chrome trang bận, nhịp người gõ nhanh: sai 2/6 lượt, tổng khoảng cách chỉnh sửa 7 (bản trước 4/6, 14); 10 ms: khoảng 1,7 mỗi lượt (bản trước khoảng 10); trang rảnh đúng. Số và các ca còn lại: [`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md) mục 3.3.
  - Nhịp người gõ nhanh (18/11/2026, Dấu Release `0b1a42d`, `--delay 40 --jitter 20 --word-pause 150`, trang bận, 3 lượt): Chrome sai 2/3, mỗi lượt một từ ("ngùii", "mêting"); Telex của Apple cùng điều kiện ra cùng chữ ở Chrome và Safari.
- Chưa đo: click reset, mũi tên reset.

### 5.3 VS Code

- Thay tại chỗ đúng ở 5–20 ms (phím dồn, máy M1): 14/15 lượt ngày 10/11/2026 (VS Code 1.145.2) và 2/2 lượt ngày 17/11/2026 (VS Code 1.146.0, ô `vscode`, `std` ở 5 ms, bản Debug của `8d3e93a`, mỗi lượt chạy ngay sau một ô Telex của Apple, chuyển nguồn bằng phím tắt hệ thống; không mất phím đầu nào). Telex của Apple cùng điều kiện hợp lệ 2/2 (ra "mêting"). Lượt mất vài phím đầu ngày 10/11 chạy sau ô Apple chọn bằng API, không tái hiện khi chuyển bằng phím tắt. Gạch chân đúng ở 0 ms.
- Backspace, thêm dấu cho từ đã gõ (120 ms): đúng. `selectedRange` 230 / 885 µs.
- Phím dồn, chuỗi `edit` (18/11/2026, máy M3 Max, VS Code 1.146.0, bản Debug của `f0a9102`, nhịp 5, 10, 20 ms, 3 lượt mỗi nhịp, hai bản có và không có ngưỡng 50 ms của D11): đúng 18/18.
- Chưa đo: khi app bận.

### 5.4 Cursor

Một app, một bundle ID, hai kiểu cửa sổ: Agents (mở khi chạy app, có ô nhập ở giữa) và IDE (giao diện kiểu VS Code: trình soạn thảo và khung agent, mở bằng ⌘L). File › Open IDE trong cửa sổ Agents khi chưa có workspace thì không mở gì; `cursor --new-window <tệp>` mở được.

**Hiện trạng (3.30.14, đo 17/11/2026, máy M1, macOS 27.2):** khung agent (`cursorchat`) và ô nhập Agents (`cursoragents`) thay tại chỗ đúng ở mọi chuỗi đã đo. Trình soạn thảo (`cursor`) trả vị trí theo hai kiểu, chưa rõ vì sao: tính từ đầu văn bản (các lượt buổi sáng, chữ đúng) hoặc tính từ đầu từ (7/7 lượt buổi chiều, cùng bản Cursor); ở kiểu sau, chuỗi `edit` gõ cách nhau 5 ms sai 0–7 từ mỗi lượt. Chuyển nguồn bằng phím tắt hệ thống, có xác nhận bộ gõ trong ô.

| Chuỗi | Nhịp | `cursorchat` | `cursoragents` | `cursor` |
|---|---|---|---|---|
| câu mẫu mặc định | 5 ms | đúng | đúng | đúng |
| `std` | 5 ms | đúng 1/1 | đúng 1/1 | đúng 3/3 (vị trí từ đầu văn bản) |
| `std` | 20 ms | — | — | đúng 1/1 (vị trí từ đầu văn bản) |
| "anh ddi " từ tài liệu mới | 20 ms | — | — | đúng 2/2 (vị trí từ đầu văn bản) |
| `edit` | 100 ± 30 ms | đúng 1/1 | đúng 1/1 | đúng 1/1 (vị trí từ đầu văn bản) |
| `edit` | 5 ms | đúng 1/1 | đúng 1/1 | đúng 1/4, ba lượt kia sai 5, 3 và 2 từ (vị trí từ đầu từ) |

- Các ô `std`, câu mẫu, "anh ddi " và `edit` 100 ms đo bằng bản Debug fa5ce8f+; các ô `edit` 5 ms đo bằng bản Debug của mã hiện tại.
- Vị trí từ đầu văn bản (dòng `diag replace`): `selectedRange` bằng vị trí Dấu theo dõi hoặc chậm 1–4 thao tác kiểu bộ đệm Chromium (`kind=late`, chữ vẫn đúng). Ba lượt `std` 5 ms ở trình soạn thảo: 41, 39 và 41 lần thay, trong đó 37, 39 và 35 đúng vị trí, còn lại trễ mà vẫn đúng chữ. Khung agent và ô nhập Agents luôn trả vị trí kiểu này.
- Vị trí từ đầu từ: `selectedRange` không quá 6 trong cả câu dài, như mô hình `LateDocument.Origin.word` (dựng từ Cursor 3.29.15). Từ sai giống nhóm lỗi của mô hình đó: câu trả lời cũ khi gõ qua ranh giới từ ("ộot", "trươcs", "duwowjc", "kóo"). Mã trước khi bỏ chờ ở D20 cũng sai như vậy trong cùng trạng thái Cursor (3/3 lượt sai 7, 3 và 2 từ, kể cả "Hocj"), nên lỗi không do D20.
- Gạch chân chưa đo trên 3.30.14.
- Cursor không có nhãn "Đề xuất".
- Mô hình `LateDocument.Origin.word` (test): app tính `selectedRange` và vùng thay từ đầu từ đang gõ, dựng từ log trình soạn thảo Cursor 3.29.15 (đo 10/11/2026); trình soạn thảo của 3.30.14 có lúc cũng vậy (trên). Hướng xử lý: [`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md).

### 5.5 Terminal

- Thay tại chỗ, chuỗi `std` (17/11/2026, Terminal 2.15, máy M1, bản Debug của `8d3e93a`, chuyển nguồn bằng phím tắt hệ thống, có xác nhận trong ô): 5 ms đúng 0/2, 10 ms 1/2, 20 ms 1/2, 30 ms 1/1. Lượt sai ở 10 và 20 ms sai một từ ("về" ra "veêf"), ở 5 ms sai nhiều từ. Telex của Apple cùng điều kiện sai ở 5, 10 và 20 ms, nhiều từ hơn Dấu (ô đối chứng hợp lệ). Thay tại chỗ sai khi phím dồn dưới 30 ms. Ở 0 ms sai.
- Gạch chân ở 0 ms vẫn sai (chữ chốt đúng nhưng Terminal còn vẽ marked text cũ tới phím sau); 5–30 ms đúng (5, 10, 20 ms: 3/3 ngày 17/11/2026). Thay tại chỗ sai khi phím dồn dưới 30 ms còn gạch chân đúng, nên Terminal có nhãn "Đề xuất" (D13).
- Thêm dấu cho từ đã gõ ra "hocj": ⌫ không tới bộ gõ (mục 6.5). `selectedRange` 408 / 637 µs.
- 12/11/2026 (120 và 30 ms, một lượt mỗi mức): đúng, trừ ⌫ (mục 6.5).

### 5.6 Ghostty

- 1.4.0, đo 11/11/2026, `scripts/research/terminal-underline/run.sh` và `typing/run.sh` (`ghostty`, `ghosttyvim`), dấu nhắc của trình sửa dòng zsh và vim, có đối chứng Telex của Apple.
- Thay tại chỗ sai ở 120 ms (`dd` → "dđ", `toois` → "toôis", `vieetj` → "vieetj"); `selectedRange` luôn `{0,0}`. Telex của Apple đúng.
- Cách gửi ký tự xoá (D43 cũ, đã bỏ 12/11/2026) chỉ đúng từ từ thứ hai, thứ ba sau mỗi lần chuyển vào Ghostty, cả trong shell thật của người dùng (oh-my-zsh, powerlevel10k, zsh-autosuggestions; `scripts/research/terminal-underline/real-shell.sh`): lệnh thật thường ngắn nên gần như luôn sai. Số đo: [`docs/research/TerminalAndUnderline.md`](research/TerminalAndUnderline.md) mục 1.
- Gạch chân: chữ đúng, cả trong shell thật của người dùng ngay từ từ đầu (12/11/2026, bản sau khi bỏ D43 cũ); Return ngay sau từ đang gạch chân bị nuốt, cả với Telex của Apple (mục 6.8).

### 5.7 Sublime Text

- Build 4215, đo 11/11/2026 ở 120 ms (`scripts/research/terminal-underline/run.sh`): thay tại chỗ đúng, cả thêm dấu cho từ đã gõ sau ⌫ và sau ←.
- Gạch chân không thêm dấu được cho từ đã chốt, như Telex của Apple (mục 6.8): ở Sublime Text không nên bật gạch chân.
- Gõ tay 29/10/2026: `selectedRange` 334 / 3.718 µs (n=35, sơ bộ).

### 5.8 Notes, Mail, Telegram

- Notes 4.13 (30/10/2026): câu mẫu đúng ở 30 ms (mismatch 0); Backspace và thêm dấu cho từ đã gõ đúng ("Học": Notes tự viết hoa chữ đầu); không tự sửa "car". `selectedRange` 330 / 1.135 µs; `insertText` cao nhất các app đã đo (3.799 / 10.207 µs).
- Mail 16.0 (30/10/2026): câu mẫu đúng ở 30 ms (Mail tự viết hoa chữ đầu); phần còn lại chưa thử. `selectedRange` 375 / 1.245 µs. Số đo tự sửa chính tả của macOS ở Mail: 11/11/2026 (120 ms) và 12/11/2026 (30 ms), mục 6.1.
- Telegram 13.1.0 (30/10/2026, tự gõ 30 ms mỗi phím qua System Events, Saved Messages, không gửi): câu mẫu cũ đúng, không gạch chân, không nhảy chữ. `selectedRange` 240 / 1.670 µs.
- Telegram 13.1.0 (17/11/2026, ô `telegram` của `typing/run.sh`: ô soạn tin của Saved Messages, không gửi; bản Debug của `8d3e93a`, máy M1, chuyển nguồn bằng phím tắt hệ thống, có xác nhận trong ô): `std` ở 5 ms đúng 1/1 và ở 30 ms 1/1, `edit` ở 100 ± 30 ms 1/1; Telex của Apple ở 5 ms hợp lệ.
- Hai ca sai ở Notes và Mail khi gõ hằng ngày (11/11/2026) là do tự sửa của macOS, với mọi bộ gõ (mục 6.1).

### 5.9 WebStorm

- 2026.3 (WS-263.7307.202, JetBrains Runtime 25.0.4.1 b635.79), đo 17/11/2026, `typing/run.sh` (`webstorm`: trình soạn thảo, tệp `.txt` trong dự án tạm; `webstormterm`: terminal Reworked, mặc định của bản này), câu mẫu mặc định, 80 ± 30 ms một phím, nghỉ 250 ms sau mỗi từ, một lượt mỗi ô, đối chứng Telex của Apple. Cơ chế và chẩn đoán: [`docs/research/JetBrainsInput.md`](research/JetBrainsInput.md).
- Trình soạn thảo, thay tại chỗ: "ưindows car tôi yêu tiếng Việt, Sủnise". Từ tiếng Việt đúng, hai từ tiếng Anh không được khôi phục (D4). Sau mỗi phím Dấu để đi thẳng, Dấu bị reset, nên phím kế tiếp đi qua lần đọc của D20 (`seed`, `seed_pass`, `seed_none`) và mốc khôi phục của D4 dời tới chữ đang hiện; ai gây reset chưa rõ (giả thuyết: `markedTextAbandoned:` của JetBrains Runtime). Lỗi của Dấu (D13), chưa sửa (mục 7).
- Terminal, thay tại chỗ: "ưindows caảr toôi yeêu tieêngs Vieêtj, Sunủnise", byte gửi xuống shell giống hệt, không có ký tự xoá: ô bỏ qua vùng thay (mục 6.8).
- Gạch chân: đúng cả hai ô. Telex của Apple: "ưindows car tôi yêu tiếng Việt, Sủnise" cả hai ô (không có khôi phục từ tiếng Anh).

### 5.10 Google Docs, Word trên web

- Đo 17/11/2026, máy M3 Max, macOS 27.2.1, Chrome 157.0.8103.79, bộ gõ Release `0b1a42d`: `scripts/selftest/typing/d20-docs.sh` (ô `gdocs`, `wordweb` của `typing/run.sh`, tài liệu trống của người dùng đã đăng nhập sẵn), 80 ± 30 ms một phím, nghỉ 250 ms sau mỗi từ, đối chứng Telex của Apple. Câu thử có bốn lần ⌫ qua dấu cách rồi thêm dấu cho từ vừa gõ (D20) và một ⌫ trong từ tiếng Anh; chuỗi phím và đáp án ở đầu script.
- Word trên web: đúng 6/6 lượt (hai lượt chạy, mỗi lượt 3), cả bốn chỗ D20. Telex của Apple: "Homo nay mình hocj tiengé Vietẹ với bạn, buổi học online rất vui." (Apple không có D20).
- Google Docs (giao diện tiếng Việt): sai 3/3 lượt, cả ba ra cùng một chữ: "Homo nay minhf hocj tiengé Vietẹ voiws banj, buôỉ học online râts vui." D20 không đặt dấu ở cả bốn chỗ, và chữ gõ liền cũng sai ("minhf", "voiws banj", "buôỉ", "râts"), trong khi Telex của Apple gõ đúng các từ đó ("mình", "với bạn", "buổi", "rất").
- Google Docs, chẩn đoán (17/11/2026, cùng máy và Chrome, bộ gõ Debug `34644a3`, ô `gdocs` với `--save`, một lượt câu trên và một lượt câu không có ⌫ "Hoom nay minhf hojc tieengs Vieetj voiws banj, buooir hojc online raats vui. "): câu không có ⌫ cũng sai ("Hôm nay minhf học tiêngs Viêtj voiws banj, buôỉ học online râts vui."), nên lỗi không do D20. Ở cả 24 lần hỏi, Google Docs trả vị trí con trỏ `(1, 0)` dù con trỏ ở đâu trong tài liệu: suy ra ô nhập ẩn mà nó cho bộ gõ thấy chỉ có một ký tự (không đo trực tiếp độ dài chữ đọc được: D8 không ghi chữ). Mọi lần thay một ký tự đều được Google Docs áp đúng chỗ (12/12, như "oo" → "ô", "hojc" → "học"); mọi lần thay hai, ba ký tự (dấu thanh trên vần "inh", "ăn", "ơi"…) đều không làm được: Dấu thấy chữ không khớp (`resync`) và cho phím đi thẳng (12/12). Sau đó Dấu đọc lại được đúng một ký tự làm từ, nên "buooir" ra "buôỉ" (r đặt lên "i"). Lần đọc của D20 không có chữ (`seed_none`). Telex của Apple đúng, có lẽ vì nó soạn chữ bằng chữ đánh dấu (marked text) thay vì thay chữ đã có (suy luận, chưa đo).
  - Giả thuyết bị loại: Google Docs bỏ qua vùng thay (thì cả lần thay một ký tự cũng sai, "Hoôm"); Google Docs trả vị trí chậm (khoảng cách giữa hai phím luôn ≥ 20 ms, không có `mismatch`, vị trí không đổi theo nhịp, ba lượt Release ra cùng một chữ).
- Google Docs trên Safari 27.2 (17/11/2026, cùng máy, bộ gõ Debug `34644a3`, ô `gdocssafari`, cùng hai câu, một lượt mỗi câu): cũng sai, gần như Chrome ("Homo nay minhf hocj tiengé Vietẹ voiws banj, buôir học online râts vui."; câu không có ⌫: "Hôm nay minhf học tiêngs Viêtj voiws banj, buôir học online râts vui."). Safari cũng trả vị trí `(1, 0)` ở cả 24 lần hỏi; thay một ký tự được, thay hai, ba ký tự không được. Safari chưa có EditContext, nên cửa sổ một ký tự là cách Google Docs tự làm ở cả hai trình duyệt, không do EditContext của Chrome.

## 6. Giới hạn đã biết

Lỗi đã sửa (mục cũ 6.4 Backspace trong Chromium, 6.6 và 6.7 biểu tượng nguồn): [`docs/history/CompatibilityFixed.md`](history/CompatibilityFixed.md).

### 6.1 Tự sửa chính tả của macOS đè lên chữ đã giữ

- Ở ứng dụng bật tự sửa chính tả, khi phía trước là câu tiếng Việt, macOS 27.2 có thể sửa chữ tiếng Anh vừa gõ thành chữ tiếng Việt ("…Sunrise car␣" → "cả"), với Dấu và với Telex của Apple (log Dấu chỉ có `pass`); tắt "Correct Spelling Automatically" thì hết. Với bàn phím U.S. chưa kiểm. Việc này xảy ra sau khi Dấu đã trả đúng chữ, nên đè lên kết quả gõ đúp ("carr" → "car").
- Chữ cái đứng một mình cũng bị đổi ("Mình chọn phương án d." → "Mình chọn phương án Đ.").
- Từ quên dấu có thể bị sửa thành từ khác ý người gõ ("Bé xây lâu đài cat␣" → "cắt"). Quay lại thêm dấu lúc đó tính trên chữ đang hiện ("cắt" + ⌫s → "căts"); Dấu không đoán từ người gõ định viết.
- Tự sửa cũng sửa từ mà D4 trả về chuỗi phím (12/11/2026, `typing/run.sh --keys`, 30 ms, một lượt mỗi câu): Mail sửa "ddep" → "đẹp", "vieet" → "việt", "ddungsg" → "đúng"; Notes sửa "vieet" → "việt", "ddungsg" → "đúng", nhưng "ddep" → "đé". Vì vậy ở ứng dụng bật tự sửa, nhóm lỗi K1 ([`docs/research/EditingTypedText.md`](research/EditingTypedText.md) mục 3) phần lớn không tới tay người gõ; ở ứng dụng không có tự sửa (Chrome, trình soạn thảo mã) vẫn còn.
- Các ca đã thấy đều là chữ còn thiếu dấu lúc bấm dấu cách; từ đã gõ dấu ngay trong từ không bị sửa ở lần đo nào ("Bé xây lâu đài cats␣" → "cát", gõ tay).
- Hệ thống hiện chữ định sửa trong một bong bóng dưới từ khi người gõ dừng sau từ; dấu cách chấp nhận chữ trong bong bóng.
- Giới hạn và cách Dấu xử lý: D4 (đoạn "Giới hạn đã biết") và D20 (ý "Từ hệ thống vừa sửa"). Dấu không tắt tự sửa của hệ thống (N4 (Không tự đổi cài đặt hệ thống)); người dùng hoàn tác bằng ⌘Z hoặc bấm vào chữ bị sửa.
- Tự sửa là thuộc tính của từng ô do ứng dụng quyết định (ví dụ `NSTextView.isAutomaticSpellingCorrectionEnabled`, https://developer.apple.com/documentation/appkit/nstextview/isautomaticspellingcorrectionenabled), nên ứng dụng không dùng hệ thống văn bản của Apple có thể không bị (suy luận).
- Câu mẫu của `typing/run.sh` đặt "carr" trước câu tiếng Việt để né (chú thích đầu script).

### 6.2 Ứng dụng áp phím bất đồng bộ

- Chromium, Electron và Terminal áp phím bất đồng bộ, nên khi phím đến dồn hay app bận, `selectedRange` trả vị trí cũ. Ảnh chụp cũ không cập nhật trong lúc `handle` đang chạy (hỏi lại 10 lần, cách 2 ms, vẫn y nguyên).
- Không phải do thiếu quyền Trợ năng: bộ gõ không có quyền đó mà vẫn đúng ở 20 ms trở lên.
- Cách xử lý (D11 ý "App trả lời chậm"; cơ chế: [`docs/Architecture.md`](Architecture.md) mục "App trả lời chậm"): Dấu vẫn hỏi `selectedRange` ở phím có thay chữ và tự theo dõi vị trí con trỏ. Khi vị trí app trả khác, Dấu đọc chữ trước con trỏ một lần để chứng minh app chỉ chưa áp các thao tác vừa gõ, rồi thay ở vị trí tự theo dõi; không chứng minh được thì dựng lại hoặc reset.
- Ở các app đã đo, chữ tiếng Việt đúng, trừ app bỏ qua vùng thay (mục 6.8); riêng trình soạn thảo WebStorm mất khôi phục D4 (mục 5.9). Ngoại lệ: Terminal đúng từ 30 ms, trừ ⌫ (mục 5.5, 6.5), và sai khi phím dồn dưới 30 ms; Safari ở 5 ms hỏng từ đầu của tài liệu mới 1/3 lượt (mục 5.1).
- Các hướng không dùng: tự cộng dồn vị trí từ một vị trí gốc thay cho việc hỏi (vị trí gốc cũng là ảnh chụp cũ, VS Code đổi gốc toạ độ); chờ ứng dụng rồi hỏi lại; so chữ trước con trỏ bằng `attributedSubstring` làm phép thay (Safari trả chữ cũ nên hỏng cả Safari).
- Người gõ tay hiếm khi có hai phím cách nhau dưới 10 ms, nhưng phím lặp khi giữ phím, máy tải nặng hay ứng dụng tạm đứng có thể làm phím đến dồn (suy luận).

### 6.3 Ô mật khẩu

Ở ô nhập bảo mật (ví dụ ô mật khẩu trong Safari), macOS giữ bàn phím `com.apple.keylayout.US` (theo nguồn TIS báo; `M2Testing.md` không ghi cách quan sát khác) và Dấu không nhận phím nào. Đây là hành vi của hệ thống, không phải lỗi ([`docs/history/M2Testing.md`](history/M2Testing.md) mục 4 dòng 17).

### 6.5 Terminal không gửi ⌫ cho bộ gõ

Terminal xử lý ⌫ mà không đưa phím cho bộ gõ, nên D32 không giữ được ở đó và D20 sau ⌫ không chạy ("hocj"; phát hiện ở lượt đo D20 ngày 30/10/2026, nhật ký 30/10 trong [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md)). Lượt đo 12/11/2026 (`hoaf⌫` trong câu, 120 và 30 ms) xác nhận: Terminal ra "ho" thay vì "hò".

### 6.8 Terminal bỏ qua vùng thay; gạch chân không sửa được từ đã chốt

- Cơ chế (đọc mã) và các hướng đã xét: [`docs/research/TerminalAndUnderline.md`](research/TerminalAndUnderline.md). Chuỗi phím và đáp án: `scripts/research/terminal-underline/run.sh`. Quyết định: D43.
- Ghostty 1.4.0 không thay theo `replacementRange` và báo `selectedRange` là `{0,0}`: không phải app trả lời chậm (mục 6.2), hỏi lại bao lâu cũng không đúng. Dấu không xử lý riêng (D43): thay tại chỗ sai, gạch chân đúng; Ghostty mang nhãn "Đề xuất". Số đo: mục 5.6.
- Terminal Reworked của WebStorm 2026.3 cùng loại: thay tại chỗ sai, gạch chân đúng (mục 5.9). Không gắn nhãn, cùng lý do như VS Code.
- Terminal dựng bằng xterm.js (terminal tích hợp của VS Code; Cursor và app Claude cùng cơ chế, chưa đo): thay tại chỗ sai, gạch chân đúng, kể cả trình soạn thảo cùng cửa sổ khi chuyển ô (số đo: research mục 2). Không gắn nhãn: các app này có nhiều ô gõ khác, bật gạch chân cho cả app thì mọi ô mất D20.
- Ghostty nuốt Return ngay sau khi chốt chữ gạch chân, với Dấu và với Telex của Apple: lỗi của Ghostty (PR #15048 của Ghostty tả lỗi này, đóng chưa merge).
- Gạch chân (D13) không có D20: ⌫ về từ đã chốt hay ← vào giữa từ rồi gõ dấu thì ra chữ gốc ("baj", "tôsi"); Telex của Apple cũng vậy. Ứng dụng thay tại chỗ đúng (như Sublime Text) không nên bật gạch chân.

## 7. Còn mở

Các mục dưới đây làm sau bản thử đầu: người thử báo lỗi thay cho đo trước (`docs/Roadmap.md` mục "Tồn đọng chưa gắn mốc").

- Ứng dụng chưa đo (mục 3): Arc, Brave, Zed, JetBrains IDE trừ WebStorm, Xcode, iTerm2, Warp, Zalo, Messenger (web), Telegram Desktop, Discord, Slack, Microsoft Teams, Word, Excel, PowerPoint, Pages, Numbers, Keynote, Google Sheets, Notion, Obsidian, Messages, Spotlight, Finder, Figma, Raycast, Alfred; phần còn lại của Mail. Ứng dụng Electron đáng thử thêm: Claude (`com.anthropic.claudefordesktop`), GitHub Desktop (`com.github.GitHubClient`), Postman (`com.postmanlabs.mac`); Zoom (`us.zoom.xos`).
- Chưa đo: VS Code khi app bận.
- Google Docs (Chrome và Safari): tìm cách sửa khi vị trí con trỏ luôn là (1, 0) (mục 5.10; các đường thay tại chỗ còn mở: [`docs/research/WebEditorInput.md`](research/WebEditorInput.md) mục 10). Sửa nhiều bước trong cửa sổ một ký tự đã đo, không được (mục 10.6 A của file đó). Chưa thử: chế độ hỗ trợ chữ nổi của Google Docs (Tools › Accessibility settings, hoặc ⌘⌥H) có cho bộ gõ thấy cả đoạn văn không.
- Safari: chẩn đoán lần thay đầu của tài liệu mới, nơi Safari trả vị trí chậm và từ đầu hỏng (5 ms, 1/3; mục 5.1).
- Click reset và mũi tên reset cho phần lớn ứng dụng (mũi tên reset theo D4 × D20).
- Trình soạn thảo WebStorm: mất khôi phục D4 vì Dấu bị reset sau mỗi phím đi thẳng (mục 5.9). Bước kế và các ca còn đáng đo (⌫ dời dấu, Return sau từ cần khôi phục, nhịp 30 ms): [`docs/research/JetBrainsInput.md`](research/JetBrainsInput.md) mục 5.
- Chrome: "vieetj" giữ nguyên trong thanh địa chỉ tab mới, chưa tái hiện.
- Chrome, Safari: thay tại chỗ sai khi phím dồn (5–20 ms) và trang bận, Telex của Apple đúng (mục 5.1, 5.2). Chrome: đã sửa phần lớn ở `85dd1b1`, còn sai 2/6 lượt ở nhịp người gõ nhanh, ở từ có chuỗi thay phức tạp ([`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md) mục 3.3). Safari: chưa rõ (phím dồn, vị trí vượt vị trí Dấu theo dõi). Edge, Firefox: chưa đo trong điều kiện này.
- Tự sửa chính tả của macOS (mục 6.1): những ứng dụng nào bật nó, và từ nào bị sửa.
- Terminal trong app Claude (xterm.js trong Electron): chưa đo; VS Code dùng cùng cơ chế và đã đo (mục 6.8).
- Pages có hai bundle ID trên cùng máy; Numbers, Keynote bản mới đổi ID. Nếu các ứng dụng này cần quy tắc, danh sách tương thích phải ghi đủ các ID.
