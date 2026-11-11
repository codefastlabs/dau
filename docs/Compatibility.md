# Tương thích ứng dụng

Dấu gõ đúng hay sai trong từng ứng dụng, ở nhịp nào và vì sao; giới hạn còn lại và cách thử. Mọi số đo trên máy M1 (M1 Pro), macOS 27.2; ô nào chưa thử thì để trống, không điền bằng phỏng đoán. Đây không phải lời hứa (N5 (Chỉ hứa điều đã kiểm chứng)): trang web chỉ dùng kết quả theo [`docs/Website.md`](Website.md).

## Hiện trạng (11/11/2026)

Tiêu chí nhãn "Đề xuất" ở D13 (Gạch chân là đường lui cuối cùng). Nhịp là khoảng cách giữa hai phím khi tự gõ; gửi cả chuỗi một lần (0 ms) không phải tốc độ gõ thật, không là tiêu chí. Chi tiết và điều kiện đo: mục 5.

| Ứng dụng | Thay tại chỗ | Gạch chân | Nhãn "Đề xuất" |
|---|---|---|---|
| Safari, TextEdit | đúng ở mọi nhịp đã đo, cả 0 ms | đúng | không |
| Chrome | đúng ở 5–20 ms và khi trang bận | đúng ở 0 ms | không (bỏ 10/11/2026) |
| Edge | đúng ở 5–20 ms và khi trang bận | đúng ở 0 ms | không (bỏ 10/11/2026) |
| Firefox | đúng ở 5–20 ms và khi trang bận | đúng ở 0 ms | không (bỏ 10/11/2026) |
| VS Code | đúng ở 5–20 ms (một lượt sai không do vị trí thay chữ) | đúng ở 0 ms | không (bỏ 10/11/2026) |
| Cursor | trình soạn thảo sai ở 5 ms và một ca phím dồn ở 20 ms, đúng ở 100 ms; ô nhập Agents đúng | đúng ở 5 ms | **có** |
| Terminal | đúng từ 5 ms, sai ở 0 ms; ⌫ không tới bộ gõ (mục 6.5) | sai ở 0 ms | không |
| Ghostty | theo D43: sai ở từ đầu mỗi lần kích hoạt, đúng từ từ thứ hai ở 120 ms; phím dồn sai (mục 6.8) | chữ đúng, Return ngay sau từ bị nuốt | không |
| Sublime Text | đúng, cả thêm dấu cho từ đã gõ sau ⌫ và ← | không thêm dấu được cho từ đã chốt | không |
| Notes | đúng ở 30 và 0 ms | chưa đo | không |
| Mail, Telegram | đúng ở 30 ms | chưa đo | không |

- Brave, Arc và các app Electron khác không có nhãn: chưa đo, nên chưa có số đo cho thấy sai (D13); không suy từ Chrome, Edge, VS Code (Cursor cũng là Electron mà còn sai). Đo mà sai thì gắn lại theo D13.
- Kết quả trình duyệt trước 09/11/2026 (M3) chưa chắc là gõ vào ô của trang: script khi đó chỉ kiểm tiêu đề cửa sổ, nên phím có thể vào thanh địa chỉ mà lượt vẫn đạt. Từ 09/11/2026 script chỉ gõ khi ô của trang có focus; các số M6 của Chrome, Edge, Firefox đo sau ngày đó.
- 13 trong 42 ứng dụng ở mục 3 có số đo; danh sách chưa đo ở mục 7.

## 1. Danh sách tương thích

- Danh sách có sẵn trong bản build: `Apps/Dau/Resources/CompatibilityList.json`, model `CompatibilityList` trong DauShared. Mỗi mục: bundle ID, cờ `suggestUnderline`, ghi chú cho người bảo trì.
- Về sau danh sách được cập nhật riêng bằng file JSON có chữ ký do app chủ tải (D7 (Cập nhật và loại bản dựng)); tiến trình bộ gõ không tải gì (N2 (Bộ gõ không có quyền mạng)).
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

"Máy này": tra ngày 30/10/2026 trong `/Applications`, `~/Applications`, `/System/Applications`, `/System/Library/CoreServices` và `mdfind kMDItemCFBundleIdentifier == '…'`; phiên bản là `CFBundleShortVersionString` lúc tra (Cursor, Ghostty, Sublime Text: lúc đo). Công nghệ đọc từ bundle (`Contents/Frameworks`, `otool -L`, không mở app); app không có trên máy ghi "suy luận". "web" = thử trong trình duyệt. Cột cuối: kết quả đo (mục 5) hoặc dự đoán (suy luận).

| Nhóm | Ứng dụng | Bundle ID | Máy này | Công nghệ giao diện | Kết quả hoặc dự đoán |
|---|---|---|---|---|---|
| Hệ thống | TextEdit | `com.apple.TextEdit` | có (1.21) | AppKit (NSTextView) | đã đo, mục 5.1 |
| Trình duyệt | Safari | `com.apple.Safari` | có (27.2) | WebKit | đã đo, mục 5.1 |
| Trình duyệt | Chrome | `com.google.Chrome` | có (156.0) | Chromium | đã đo, mục 5.2 |
| Trình duyệt | Firefox | `org.mozilla.firefox` (Nightly: `org.mozilla.nightly`) | có (158.0.1; Nightly 160.0a1) | Gecko | đã đo, mục 5.2 |
| Trình duyệt | Edge | `com.microsoft.edgemac` | có (155.0) | Chromium (`Microsoft Edge Framework`) | đã đo, mục 5.2 |
| Trình duyệt | Arc | `company.thebrowser.Browser` | không | Chromium (suy luận) | như Chrome |
| Trình duyệt | Brave | `com.brave.Browser` | không | Chromium (suy luận) | như Chrome |
| Soạn mã | VS Code | `com.microsoft.VSCode` | có (1.144.0) | Electron | đã đo, mục 5.3 |
| Soạn mã | Cursor | `com.todesktop.230313mzl4w4u92` | có (3.29.15) | Electron (dựng từ VS Code 1.128.0) | đã đo, mục 5.4 |
| Soạn mã | Zed | `dev.zed.Zed` | có (1.23.2) | tự vẽ bằng Metal (GPUI, Rust), vỏ AppKit | chưa biết |
| Soạn mã | Sublime Text | `com.sublimetext.4` | có (Build 4215) | tự vẽ, vỏ AppKit | đã đo, mục 5.7 |
| Soạn mã | JetBrains IDE | `com.jetbrains.WebStorm`; khác: `com.jetbrains.intellij`, `com.jetbrains.intellij.ce`, `com.jetbrains.pycharm`, `com.jetbrains.goland`, `com.google.android.studio` | WebStorm có (2026.2.3, `~/Applications`); các ID khác không | Java (JetBrains Runtime) | chưa biết; nhập liệu qua lớp Java |
| Soạn mã | Xcode | `com.apple.dt.Xcode` | có (27.1) | AppKit, trình soạn mã riêng | chưa biết; có gợi ý hoàn thành mã |
| Terminal | Terminal | `com.apple.Terminal` | có (2.15) | AppKit, chờ shell in lại chữ | đã đo, mục 5.5 |
| Terminal | iTerm2 | `com.googlecode.iterm2` | không | AppKit (suy luận) | như Terminal (suy luận) |
| Terminal | Warp | `dev.warp.Warp-Stable` | không | tự vẽ bằng Metal, Rust (suy luận) | chưa biết |
| Terminal | Ghostty | `com.mitchellh.ghostty` | có (1.4.0) | AppKit + SwiftUI, vẽ bằng Metal | đã đo, mục 5.6 |
| Chat | Zalo | `com.vng.zalo` | có (26.10.10) | Electron | như VS Code (suy luận) |
| Chat | Messenger | web (`messenger.com`, `facebook.com`) | web | trình duyệt | theo trình duyệt. Meta ngừng app Messenger cho Mac từ 15/12/2025 ([TechCrunch](https://techcrunch.com/2025/10/16/meta-to-shut-down-messenger-desktop-apps-for-mac-and-windows/), [AppleInsider](https://appleinsider.com/articles/25/12/15/facebook-messenger-for-macos-departs-the-desktop)) |
| Chat | Telegram | `ru.keepcoder.Telegram` | có (13.1.0) | AppKit, Swift ("Telegram for macOS") | đã đo, mục 5.8 |
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
| Văn phòng | Google Docs | web | web | trình duyệt; vẽ bằng canvas từ 2021 ([Google Workspace Updates](https://workspaceupdates.googleblog.com/2021/05/Google-Docs-Canvas-Based-Rendering-Update.html)), chữ nhập qua một ô ẩn (suy luận) | rủi ro cao (suy luận); D20 trên web editor là câu hỏi mở trong `Decisions.md` |
| Văn phòng | Google Sheets | web | web | trình duyệt | chưa biết |
| Văn phòng | Notion | `notion.id` | có (7.41.1) | Electron | như VS Code (suy luận) |
| Văn phòng | Obsidian | `md.obsidian` | không | Electron (suy luận) | như VS Code (suy luận) |
| Apple | Ghi chú (Notes) | `com.apple.Notes` | có (4.13) | AppKit | đã đo, mục 5.8 |
| Apple | Mail | `com.apple.mail` | có (16.0) | AppKit; khung soạn thư dùng WebKit (suy luận) | đã đo, mục 5.8 |
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
3. Lần đầu trên máy: mở Dấu trong `/Applications`, bấm "Bật Dấu" rồi Allow (D37 (Cài đặt bộ gõ)). Không bật được thì theo đường lui của D37: tự thêm bằng "+" trong danh sách nguồn đầu vào của System Settings, "+" không có Dấu thì đăng xuất một lần ([`docs/research/InputMethodInstall.md`](research/InputMethodInstall.md) mục 1.3, 3.2).
4. Giữ U.S. (hoặc một nguồn tiếng Anh khác) trong danh sách nguồn: Dấu chỉ có nguồn tiếng Việt (D2 (Chuyển Việt/Anh)).
5. Máy bật "Automatically switch to a document’s input source" thì mỗi ứng dụng nhớ nguồn riêng: chọn lại Dấu sau khi chuyển sang ứng dụng cần thử.
6. Bộ gõ không chạy: xem log bằng `/usr/bin/log stream --predicate 'process == "DauInputMethod"'` (trong zsh, `log` là lệnh có sẵn khác).
7. Chỉ gõ vào ô nháp: tài liệu mới không lưu, Saved Messages của Telegram, ô soạn tin không gửi. Không gửi tin, không lưu tệp nếu người dùng chưa cho phép.
8. Ghi lại: ngày, commit của Dấu, phiên bản ứng dụng, phiên bản macOS, chế độ gạch chân của ứng dụng đó.

### 4.2 Gõ

- Ứng dụng có trong `scripts/selftest/typing/run.sh`: tự gõ bằng script. Ứng dụng nào, câu mẫu và đáp án, tuỳ chọn (`--delay`, `--keys`, `--underline`, `--source`, `--busy`…), cách mở và đọc chữ, quyền cần cấp: đầu script. Script chiếm màn hình: hỏi giờ chạy trước (CLAUDE.md).
- Nhịp: 120 ms gần gõ thường; 5, 10, 20 ms để tìm ngưỡng phím dồn; `--busy` cho trang bận (M6).
- Đối chứng: Telex của Apple cùng điều kiện (`--source`), theo CLAUDE.md ý "Đo độ đúng khi gõ".
- Ứng dụng khác: gõ tay (tốc độ bình thường, rồi gõ nhanh hết sức), ghi rõ cách thử ở mục 5.

### 4.3 Những gì cần kiểm tra

| Kiểm tra | Cách làm | Mong đợi |
|---|---|---|
| Chữ đúng | so từng ký tự với đáp án | khớp hoàn toàn |
| Gạch chân, nhảy chữ | nhìn trong lúc gõ | chế độ thường: không gạch chân; không lặp, mất, đảo chữ; con trỏ không nhảy |
| Backspace (D32 (Backspace)) | `hoaf` rồi ⌫ | "hoà" rồi "hò" |
| Click reset (D4 (Từ nước ngoài), D11) | `tooi`, click sau dấu cách hoặc đầu dòng, `s` | chỉ thêm "s" ở chỗ mới. Click ngay sau một chữ thì D20 có thể đặt dấu vào chữ đó |
| Mũi tên reset (D4 × D20) | `tooi`, ←, nghỉ một nhịp, `s` | D20 bật: "tối" (dấu vào chữ trước con trỏ, "i" giữ nguyên). D20 tắt: "tôsi" |
| Thêm dấu cho từ đã gõ (D20) | `hoc`, dấu cách, ⌫, nghỉ ≥ 50 ms, `j` | "học". Phím dồn dưới 50 ms thì D20 cố ý không chạy ("hocj"); ứng dụng gạch chân: "hocj" |
| Tự sửa chính tả (D4) | câu tiếng Việt rồi `Sunrise carr␣` | "car". Thành "cả" thì gõ lại bằng U.S.: U.S. cũng bị sửa là macOS (mục 6.1) |

### 4.4 Số đo

- `scripts/perf/perf-report.sh --last 5m --app <tên app hoặc một phần bundle ID>` ngay sau khi gõ; `typing/run.sh` tự in báo cáo này. Cột, cách bật nhật ký từng phím (`DauPerfLog`) và tắt sau khi đo: đầu script.
- Ghi: `selectedRange` p50 / p99 µs, `count_mismatch` (vị trí khác dự đoán), `count_unsupported` (ứng dụng trả `NSNotFound`).
- `event_client-changed` tăng theo từng phím, hay `event_client-not-text-input` khác 0: báo lại ngay.
- Số từ bản Debug có thêm một lần hỏi chẩn đoán sau mỗi lần thay (`ReplaceDiag.swift`), nên cao hơn bản phát hành. Cần p99 đáng tin thì gõ thêm vài trăm phím có dấu.

## 5. Số đo theo ứng dụng

Nguồn: số M1–M3 (29–30/10/2026) ở bảng "Số đo (M1–M3)" của [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md) và nhật ký 30/10 cùng file; lượt chạy ma trận 30/10/2026 ở [`docs/history/CompatibilityFixed.md`](history/CompatibilityFixed.md); số M6 trở đi ở nhật ký [`docs/Progress.md`](Progress.md) theo ngày. Số µs là `selectedRange` p50 / p99 ở 30 ms, phím có thay chữ, bản Debug. Phím dồn M6: nhịp danh nghĩa 5, 10, 20 ms, khoảng cách phím thật phần lớn 10–20 ms. Trang bận M6: trang thử chặn luồng chính 300 ms mỗi giây, phím cách 100 ± 30 ms.

### 5.1 Safari, TextEdit

- Câu mẫu đúng ở 0 và 30 ms, gõ tay đúng; gạch chân đúng ở 0 và 30 ms (29–30/10/2026).
- Backspace, thêm dấu cho từ đã gõ (120 ms): đúng.
- `selectedRange`: TextEdit 327 / 606, Safari 622 / 1.057 µs; mismatch 0.
- TextEdit: mũi tên reset đạt theo mong đợi cũ (trước D20), mong đợi theo D4 × D20 chưa chạy lại ([`docs/history/M2Testing.md`](history/M2Testing.md) mục 4). TextEdit không còn trong script vì tự lưu tài liệu thử lên iCloud Drive ([`docs/Troubleshooting.md`](Troubleshooting.md)).

### 5.2 Chrome, Edge, Firefox

- Trước M6 (M3, 29–30/10/2026, trang thử cục bộ `spellcheck=false`): đúng ở 30 ms; sai ở 0 ms (mismatch 3–4, thay nhầm vùng ở lần thay đầu của từ; Firefox chữ nhảy chỗ). Chrome đúng từ 5 ms; Edge, Firefox sai ở 5 ms, đúng từ 10 ms. Gạch chân ở 0 ms đúng ở cả ba.
- Trang bận trước khi sửa (Chrome, 09/11/2026): thay tại chỗ sai 8/9 lượt; gạch chân đúng 9/9.
- Sau các lần sửa ở M6 (10/11/2026): phím dồn Chrome và Firefox đúng 7/7 lượt mỗi app, Edge 9/9; trang bận đúng 3/3 ở cả ba.
- Backspace, thêm dấu cho từ đã gõ (120 ms): đúng ở cả ba (Backspace sau bản sửa 82d9ecc).
- `selectedRange`: Chrome 415 / 694, Edge 369 / 6.828, Firefox 265 / 1.174 µs.
- Chưa đo: click reset, mũi tên reset; phím dồn khi trang bận.

### 5.3 VS Code

- Trước M6: đúng ở 30 ms; sai ở 0 và 5 ms. Ở 10 ms sai lượt 29/10 (câu mẫu cũ), đúng lượt 30/10 (câu mẫu mới); từ 20 ms đúng mọi lượt. Gạch chân đúng ở 0 và 5 ms.
- Sau các lần sửa ở M6 (10/11/2026): phím dồn đúng 14/15 lượt; lượt sai không phải lỗi vị trí thay chữ (vài phím đầu không tới bộ gõ, nguyên nhân chưa rõ).
- Backspace, thêm dấu cho từ đã gõ (120 ms): đúng. `selectedRange` 230 / 885 µs.
- Chưa đo: khi app bận.

### 5.4 Cursor

- 3.29.15, đo 10/11/2026 sau các lần sửa ở M6, `typing/run.sh` (`cursor`: trình soạn thảo; `cursoragents`: ô nhập của cửa sổ Agents; đối chứng `vscodefile`: VS Code mở cùng kiểu).
- Trình soạn thảo: đúng ở 20 ms với chuỗi chuẩn và ở 100 ms; sai ở 5 ms và ở ca "anh ddi" ở 20 ms. Cursor trả vị trí con trỏ tính từ đầu từ đang gõ; VS Code mở cùng kiểu thì đúng; Telex của Apple cùng chỗ đúng ở 5 và 20 ms.
- Ô nhập Agents: đúng ở 5, 20, 100 ms. Gạch chân trong trình soạn thảo: đúng ở 5 ms.
- Đã dừng sửa trình soạn thảo Cursor (10/11/2026): hai hướng sửa cần đổi N3 hoặc D11 (mục 7).

### 5.5 Terminal

- Đúng ở 30 ms; sai ở 0 ms; đúng ở 5 và 10 ms (29/10/2026).
- Gạch chân ở 0 ms vẫn sai (chữ chốt đúng nhưng Terminal còn vẽ marked text cũ tới phím sau); 5–30 ms đúng. Vì vậy không đề xuất.
- Thêm dấu cho từ đã gõ ra "hocj": ⌫ không tới bộ gõ (mục 6.5). `selectedRange` 408 / 637 µs.
- Chưa đo sau M6.

### 5.6 Ghostty

- 1.4.0, đo 11/11/2026, `scripts/research/terminal-underline/run.sh` và `typing/run.sh` (`ghostty`, `ghosttyvim`), dấu nhắc của trình sửa dòng zsh và vim, có đối chứng Telex của Apple.
- Trước D43: thay tại chỗ sai ở 120 ms (`dd` → "dđ", `toois` → "toôis", `vieetj` → "vieetj"); `selectedRange` luôn `{0,0}`. Telex của Apple đúng.
- Với D43 (Ô bỏ qua vùng thay chữ), bản thật: Ghostty được nhận ra, đúng từ từ thứ hai mỗi lần kích hoạt ở 120 ms, ở zsh và vim; từ đầu còn sai. Ở 30 ms (phím dồn) không nhận ra, sai như trước. Chrome (cả khi trang bận), Safari, Sublime Text không bị nhận nhầm.
- Gạch chân: chữ đúng, nhưng Return ngay sau từ gạch chân bị nuốt, cả với Telex của Apple (mục 6.8).

### 5.7 Sublime Text

- Build 4215, đo 11/11/2026 ở 120 ms (`scripts/research/terminal-underline/run.sh`): thay tại chỗ đúng, cả thêm dấu cho từ đã gõ sau ⌫ và sau ←.
- Gạch chân không thêm dấu được cho từ đã chốt, như Telex của Apple (mục 6.8): ở Sublime Text không nên bật gạch chân.
- Gõ tay 29/10/2026: `selectedRange` 334 / 3.718 µs (n=35, sơ bộ).

### 5.8 Notes, Mail, Telegram

- Notes 4.13 (30/10/2026): câu mẫu đúng ở 30 và 0 ms (mismatch 0); Backspace và thêm dấu cho từ đã gõ đúng ("Học": Notes tự viết hoa chữ đầu); không tự sửa "car". `selectedRange` 330 / 1.135 µs; `insertText` cao nhất các app đã đo (3.799 / 10.207 µs) mà vẫn đúng ở 0 ms.
- Mail 16.0 (30/10/2026): câu mẫu đúng ở 30 ms (Mail tự viết hoa chữ đầu); phần còn lại chưa thử. `selectedRange` 375 / 1.245 µs.
- Telegram 13.1.0 (30/10/2026, System Events, Saved Messages, không gửi): câu mẫu cũ đúng ở 30 ms, không gạch chân, không nhảy chữ. `selectedRange` 240 / 1.670 µs.
- Hai ca sai ở Notes và Mail khi gõ hằng ngày (11/11/2026) là do tự sửa của macOS, với mọi bộ gõ (mục 6.1).

## 6. Giới hạn đã biết

Lỗi đã sửa (mục cũ 6.4 Backspace trong Chromium, 6.6 và 6.7 biểu tượng nguồn): [`docs/history/CompatibilityFixed.md`](history/CompatibilityFixed.md).

### 6.1 Tự sửa chính tả của macOS đè lên chữ đã giữ

- Ở ứng dụng bật tự sửa chính tả, khi phía trước là câu tiếng Việt, macOS 27.2 có thể sửa chữ tiếng Anh vừa gõ thành chữ tiếng Việt ("…Sunrise car␣" → "cả"), kể cả khi gõ bằng U.S. Việc này xảy ra sau khi Dấu đã trả đúng chữ, nên đè lên kết quả gõ đúp ("carr" → "car").
- Chữ cái đứng một mình cũng bị đổi ("Mình chọn phương án d." → "Mình chọn phương án Đ.").
- Từ quên dấu có thể bị sửa thành từ khác ý người gõ ("Bé xây lâu đài cat␣" → "cắt"). Quay lại thêm dấu lúc đó tính trên chữ đang hiện ("cắt" + ⌫s → "căts"); Dấu không đoán từ người gõ định viết.
- Các ca đã thấy đều là chữ còn thiếu dấu lúc bấm dấu cách; từ đã gõ dấu ngay trong từ không bị sửa ở lần đo nào ("Bé xây lâu đài cats␣" → "cát", gõ tay).
- Hệ thống hiện chữ định sửa trong một bong bóng dưới từ khi người gõ dừng sau từ; dấu cách chấp nhận chữ trong bong bóng.
- Giới hạn và cách Dấu xử lý: D4 (đoạn "Giới hạn đã biết") và D20 (ý "Từ hệ thống vừa sửa"). Dấu không tắt tự sửa của hệ thống (N4 (Không tự đổi cài đặt hệ thống)); người dùng hoàn tác bằng ⌘Z hoặc bấm vào chữ bị sửa.
- Tự sửa là thuộc tính của từng ô do ứng dụng quyết định (ví dụ `NSTextView.isAutomaticSpellingCorrectionEnabled`, https://developer.apple.com/documentation/appkit/nstextview/isautomaticspellingcorrectionenabled), nên ứng dụng không dùng hệ thống văn bản của Apple có thể không bị (suy luận).
- Câu mẫu của `typing/run.sh` đặt "carr" trước câu tiếng Việt để né (chú thích đầu script).

### 6.2 Ứng dụng áp phím bất đồng bộ

- Chromium, Electron và Terminal áp phím bất đồng bộ, nên khi phím đến dồn hay app bận, `selectedRange` trả vị trí cũ; trước M6, bộ gõ thấy lệch (`mismatch`), reset từ đang gõ, chữ ra thiếu dấu hoặc thay nhầm vùng. Ảnh chụp cũ không cập nhật trong lúc `handle` đang chạy (hỏi lại 10 lần, cách 2 ms, vẫn y nguyên).
- Ngưỡng đo ở M3 (29–30/10/2026, app rảnh): sai dưới khoảng 10 ms ở Chrome, Terminal; dưới khoảng 20 ms ở VS Code (mục 5).
- Không phải do thiếu quyền Trợ năng: bộ gõ không có quyền đó mà vẫn đúng ở 20 ms trở lên.
- Hiện hành (M6, D11 ý "App trả lời chậm"; cơ chế: [`docs/Architecture.md`](Architecture.md) mục "App trả lời chậm"): Dấu vẫn hỏi `selectedRange` ở phím có thay chữ và tự theo dõi vị trí con trỏ. Khi vị trí app trả khác, Dấu đọc chữ trước con trỏ một lần để chứng minh app chỉ chưa áp các thao tác vừa gõ, rồi thay ở vị trí tự theo dõi; không chứng minh được thì dựng lại hoặc reset.
- Còn sai sau khi sửa: trình soạn thảo Cursor (mục 5.4). Terminal chưa đo lại.
- Đã thử và bỏ (29/10/2026): tự cộng dồn vị trí từ một vị trí gốc thay cho việc hỏi (vị trí gốc cũng là ảnh chụp cũ, VS Code đổi gốc toạ độ); chờ ứng dụng rồi hỏi lại; so chữ trước con trỏ bằng `attributedSubstring` làm phép thay (Safari trả chữ cũ nên hỏng cả Safari).
- Người gõ tay hiếm khi có hai phím cách nhau dưới 10 ms, nhưng phím lặp khi giữ phím, máy tải nặng hay ứng dụng tạm đứng có thể làm phím đến dồn (suy luận).

### 6.3 Ô mật khẩu

Ở ô nhập bảo mật (ví dụ ô mật khẩu trong Safari), macOS giữ bàn phím `com.apple.keylayout.US` và Dấu không nhận phím nào. Đây là hành vi của hệ thống, không phải lỗi ([`docs/history/M2Testing.md`](history/M2Testing.md) mục 4 dòng 17).

### 6.5 Terminal không gửi ⌫ cho bộ gõ

Terminal xử lý ⌫ mà không đưa phím cho bộ gõ, nên D32 không giữ được ở đó và D20 sau ⌫ không chạy ("hocj"; phát hiện ở lượt đo D20 ngày 30/10/2026, nhật ký 30/10 trong [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md)). Chưa kiểm chứng lại bằng `hoaf⌫␣` (mục 7).

### 6.8 Terminal bỏ qua vùng thay; gạch chân không sửa được từ đã chốt

- Cơ chế (đọc mã) và các hướng đã xét: [`docs/research/TerminalAndUnderline.md`](research/TerminalAndUnderline.md). Chuỗi phím và đáp án: `scripts/research/terminal-underline/run.sh`. Quyết định: D43.
- Ghostty 1.4.0 không thay theo `replacementRange` và báo `selectedRange` là `{0,0}`: không phải app trả lời chậm (mục 6.2), hỏi lại bao lâu cũng không đúng. Dấu nhận ra ô này và gửi ký tự xoá sau phím (D43); giới hạn còn lại (từ đầu mỗi lần kích hoạt, phím dồn, Return sau từ cần khôi phục, chương trình không coi DEL là lệnh xoá): D43 mục "Hệ quả đã chấp nhận"; số đo: mục 5.6.
- Terminal dựng bằng xterm.js (terminal trong app Claude): trang thử xterm.js trong Chrome sai như cách cũ, gạch chân đúng. Cách gửi ký tự xoá trong phím của D43 làm chữ dồn lại mỗi lần sửa (chưa rõ nguyên nhân), nên tạm tắt cho kiểu ô này: Dấu thay tại chỗ như trước D43. Chính app Claude chưa đo.
- Ghostty nuốt Return ngay sau khi chốt chữ gạch chân, với Dấu và với Telex của Apple: lỗi của Ghostty (PR #15048 của Ghostty tả lỗi này, đóng chưa merge).
- Gạch chân (D13) không có D20: ⌫ về từ đã chốt hay ← vào giữa từ rồi gõ dấu thì ra chữ gốc ("baj", "tôsi"); Telex của Apple cũng vậy. Ứng dụng thay tại chỗ đúng (như Sublime Text) không nên bật gạch chân.

## 7. Còn mở

- Ứng dụng chưa đo (mục 3): Arc, Brave, Zed, JetBrains IDE, Xcode, iTerm2, Warp, Zalo, Messenger (web), Telegram Desktop, Discord, Slack, Microsoft Teams, Word, Excel, PowerPoint, Pages, Numbers, Keynote, Google Docs, Google Sheets, Notion, Obsidian, Messages, Spotlight, Finder, Figma, Raycast, Alfred; phần còn lại của Mail; terminal trong app Claude. Ứng dụng Electron đáng thử thêm: Claude (`com.anthropic.claudefordesktop`), GitHub Desktop (`com.github.GitHubClient`), Postman (`com.postmanlabs.mac`); Zoom (`us.zoom.xos`).
- Đo lại sau M6: Terminal (phím dồn, và ⌫ không tới bộ gõ bằng `hoaf⌫␣`); VS Code khi app bận.
- Click reset và mũi tên reset cho phần lớn ứng dụng (mũi tên reset theo D4 × D20).
- Trình soạn thảo Cursor: nhóm lỗi ở 5 ms và ca gõ dồn từ phím đầu của tài liệu mới; hai hướng sửa cần đổi N3 hoặc D11.
- VS Code: một lượt mà vài phím đầu không tới bộ gõ, nguyên nhân chưa rõ.
- xterm.js: chẩn đoán chữ dồn khi gửi ký tự xoá trong phím (D43), rồi bật lại.
- Pages có hai bundle ID trên cùng máy; Numbers, Keynote bản mới đổi ID. Nếu các ứng dụng này cần quy tắc, danh sách tương thích phải ghi đủ các ID.
