# Tiến độ

Nhật ký điều phối, để phiên sau (hoặc sau khi ngữ cảnh bị nén) tiếp tục đúng chỗ. Phiên chính cập nhật file này sau mỗi bước.

> Từ 02/11/2026 repo ở https://github.com/codefastlabs/dau và lịch sử đã được viết lại: các mã commit ghi trước ngày này là mã cũ, tra `docs/history/COMMIT-MAP.md` để ra mã mới.

## Trạng thái hiện tại
- Mốc đang làm: M6 — Hiệu năng dưới tải, chưa bắt đầu (lập kế hoạch ở đầu mốc). M5 đóng 05/11/2026.
- Mở: "window size at launch" của bộ kiểm cửa sổ Cài đặt thỉnh thoảng sai: 740×452 (03/11 18:08), 976×700 (05/11, lượt `run.sh` thứ ba trong ngày; hai lượt trước cùng ngày đúng 740×560; khung đã lưu sau lượt đó là 740×560). Chưa rõ do app hay do bộ kiểm.
- Mở: sheet thêm quy tắc chập chờn trong `run.sh` (03/11: 3 dòng; 04/11: danh sách tạm 1–13 dòng lúc mở, một lượt gõ tìm không lọc); 2/3 lượt ngày 04/11 16:xx trượt, lượt sau đạt; chưa rõ do app hay do bộ kiểm (nhật ký 04/11).
- Máy nhà (05/11/2026): chứng chỉ của máy nhà đã bị thay bằng chứng chỉ mới tạo ở máy này; xuất "Apple Development: …" kèm khoá riêng ra `.p12` ở máy này, nhập ở máy nhà, rồi cài lại Dấu ở đó.
- Mở: các tiến trình trong thư mục cache được hệ thống bảo vệ (WebKit, bộ đệm của Shortcuts) không xoá được bộ đệm; ảnh hưởng chưa đo; gỡ cài đặt chưa xoá bộ đệm của các app (`docs/research/M5-INSTALL.md` (d)10).
- Mở: "vieetj" giữ nguyên trong thanh địa chỉ tab mới của Chrome (hồ sơ công việc); chờ người dùng bật `DauPerfLog` (chỉ bản Debug) khi gặp lại.
- Mở, chưa có artboard: tên các nguồn tiếng Việt khác trong ghi chú D14 vẫn theo tiếng Việt của app (bảng tên `LayoutNames` chỉ có bàn phím); ảnh hưởng của mục ẩn sau đăng nhập không còn liên quan vì D16 giữ bước "–".
- Việc hoãn: ma trận tương thích còn lại → M6; biểu tượng V, danh sách "+" bằng mắt, VoiceOver đọc đúng tên, VoiceOver/Tab trong Cài đặt, máy tiếng Anh hẳn, sheet tối, câu gợi ý của hàng "Gặp ứng dụng gõ bị lỗi?" → M7.
- Ký: Personal Team (Team ID trong D24), ký tự động "Apple Development"; bản phát hành dùng Developer ID ở M7.
- Số test và số đo chỉ ghi trong dòng nhật ký có ngày và trong bảng mốc lúc đóng mốc; không ghi ở đây.
- Môi trường: Xcode 27.2 ở `/Applications/Xcode.app` nhưng `xcode-select` đang trỏ CommandLineTools → mọi lệnh build dùng `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`. Swift 6.4.

## Mốc
| Mốc | Trạng thái | Kiểm toán | Ghi chú |
|---|---|---|---|
| M0 Khung dự án | xong | ĐẠT (29/10) | build Debug universal cần `-destination generic/platform=macOS` |
| M1 Engine | xong | ĐẠT (29/10, lần 2) | Telex, Telex đơn giản, VNI, 75 test; release ~0,15 µs/phím; 0 từ sai / 474 từ, 0 khôi phục nhầm / 15.796 âm tiết, fuzz 800k thao tác không crash |
| M2 Bộ gõ tối thiểu | xong | ĐẠT (30/10, lần 3; lần 1, 2 CHƯA ĐẠT vì tài liệu) | cách A; tự gõ 30 ms/phím đúng ở TextEdit, Safari, Chrome, VS Code, Terminal, Telegram (thay Slack); Sublime gõ tay; selectedRange p50 0,2–0,6 ms (Debug). M2-TESTING mục 4 ĐẠT trừ việc hoãn (VoiceOver, biểu tượng V → M3; Telegram Return bỏ qua). Test engine 76, IMK 25 |
| M3 Độ tin cậy | xong | ĐẠT (30/10, lần 3; lần 1, 2 CHƯA ĐẠT vì tài liệu) | gạch chân D13 theo quy tắc, mặc định tắt, danh sách đề xuất 13 app (VS Code, Electron/Chromium, Firefox); D20 ở bộ gõ (đọc lại 1–4 ms, chỉ phím dấu đầu khi bộ đệm trống); reset khi đổi nguồn không báo; sửa ⌫ xoá hai lần ở Chromium; ma trận `COMPATIBILITY.md` 11 app đã đo; D17: hệ thống tự đọc khi chuyển nguồn. Test engine 77, IMK 70, DauShared 32 |
| M4 App Cài đặt | xong | ĐẠT (30/10, lần 3) | DauShared + cửa sổ 4 mục (2d6206e, c731c61); bộ gõ đọc cài đặt chung (0aa4872). App Group chạy với Team ID M58DANM3ZP (958a5a8). Bỏ chế độ Anh, quy tắc theo app chỉ còn gạch chân (9680c68, ea676ae, b23b266). M4-TESTING ĐẠT trừ việc hoãn sang M7 (máy tiếng Anh hẳn, sheet tối, VoiceOver/Tab). Ma trận UI 12/12. Test DauShared 21, IMK 25, snapshot-settings 10 |
| M5 Onboarding, cài, gỡ | xong | ĐẠT (05/11, lần 1; các mục nên sửa đã xử lý) | onboarding 3 bước; bật không đăng xuất (D37: xoá bộ đệm nguồn đầu vào của mọi app, đăng ký, Allow); gỡ có bước "–" (D16); kiểm chữ ký và Team ID, banner "Cài lại"; tên giao diện macOS theo ngôn ngữ máy (D38); đăng xuất làm mỗi app dựng lại bộ đệm (đo 05/11); snapshot 98 test, `run.sh` đạt trừ lỗi chập chờn "window size at launch"; T4 bỏ |
| M6 Hiệu năng dưới tải | chưa | — | |
| M7 Phát hành | chưa | — | |
| M8 Website | chưa | — | |
| M9 Đa ngôn ngữ | chưa | — | thêm 04/11 |
| M10 Học cách gõ | chưa | — | thêm 04/11 |

## Ghi nhớ cho M7 (từ kiểm toán M0)
- Xem lại gợi ý "Báo lại để bản sau xử lý đúng cho ứng dụng đó" (hàng "Gặp ứng dụng gõ bị lỗi?", `UpdatesSupportView`) theo N5 khi làm báo lỗi (hoãn từ kiểm toán M3).
- ~~Bản Release vẫn có `get-task-allow`~~: đã bỏ (02/11/2026, `CODE_SIGN_INJECT_BASE_ENTITLEMENTS: NO` cho Release). Hardened runtime mới chỉ ở Release.
- `.gitignore` bỏ qua `Package.resolved` → ghim phiên bản Sparkle chính xác trong `project.yml`.
- Thử bỏ `temporary-exception.mach-register.global-name` của bộ gõ khi rà entitlement trước notarize (hoãn từ M3, ARCHITECTURE.md).
- Thêm `*.p8`, `*.pem`, `*.key`, `*.xcarchive` vào `.gitignore`.
- ~~UI.md onboarding viết cứng "⌃Space" — phải hiện phím tắt hệ thống thật (N5), xử lý ở M5.~~ Đã xử lý: `InputSourceShortcut` đọc phím tắt thật, onboarding dùng `InputSourceShortcut.Reading`; `Localizable.xcstrings` không còn chuỗi "⌃Space".
- `en.lproj` khiến menu hệ thống có thể hiện tiếng Anh trên máy tiếng Anh — quyết định ở M4.
- M7: đưa phép đếm cấp phát (`malloc_logger`) vào CI.

## Số đo
(engine µs/phím, chi phí selectedRange theo app, độ trễ p50/p99 dưới tải, bộ nhớ…)
| Ngày | Số đo | Giá trị | Cách đo |
|---|---|---|---|
| 29/10/2026 | `VietEngine.handle` Telex, release | 0,148 µs/phím (8,9 ms / 60.325 phím, best of 5) | `swift test -c release`, `PerformanceTests` (văn bản Việt/Anh trộn, có Backspace), Mac arm64 |
| 29/10/2026 | `VietEngine.handle` Telex, debug | 3,0–3,4 µs/phím | như trên, debug |
| 29/10/2026 | `VietEngine.handle` VNI, release | 0,142 µs/phím (8,5 ms / 60.071 phím, best of 5) | `PerformanceTests`, đoạn VNI dài; Telex đo lại cùng lượt 0,154 µs/phím |
| 29/10/2026 | IMK cách A, Sublime Text 4 (Debug, sơ bộ) | `selectedRange` p50 334 / p99 3.718 µs; `insertText` p50 1.466 / p99 7.787 µs; cả phím có thay p50 2.002 / p99 8.087 µs (n=35) | `scripts/perf/perf-report.sh`, người dùng gõ tay |
| 29/10/2026 | IMK cách A, TextEdit (Debug, sơ bộ) | `selectedRange` p50 288 / p99 7.306 µs; `insertText` p50 3.760 / p99 8.546 µs; cả phím có thay p50 4.536 / p99 15.933 µs (n=11) | như trên |
| 29/10/2026 | IMK cách A, Safari (Debug, sơ bộ) | `selectedRange` p50 333 / p99 1.639 µs; `insertText` p50 4.298 / p99 13.696 µs; cả phím có thay p50 4.790 / p99 14.242 µs (n=11) | `scripts/perf/perf-report.sh`, người dùng gõ tay |
| 29/10/2026 | IMK cách A, Chrome (Debug, sơ bộ) | `selectedRange` p50 380 / p99 3.976 µs; `insertText` p50 4.581 / p99 11.309 µs; cả phím có thay p50 5.013 / p99 14.964 µs (n=11); không có `event_client-not-text-input` | `scripts/perf/perf-report.sh --last 5m --app Chrome` |
| 29/10/2026 | IMK cách A, VS Code (Debug, tự gõ bằng System Events) | `selectedRange` p50 224 / p99 732 µs; `insertText` p50 346 µs; **4 lần lệch dự đoán con trỏ** → kết quả sai: "arroi yeu tiengs Vietj, ?indows Suni c" | `scripts/perf/perf-report.sh --app Code` |
| 29/10/2026 | IMK cách A, Terminal (Debug, tự gõ) | `selectedRange` p50 179 / p99 314 µs; `insertText` p50 243 µs; **3 lần lệch** → "tôi yêu tiêngs Viêtj, windows Sủnise car" (sai từ thứ 3) | `--app Terminal` |
| 29/10/2026 | TextEdit (tự gõ lại) | đúng: "tôi yêu tiếng Việt, windows Sunrise car" | |
| 29/10/2026 | Cấp phát trong `handle` VNI | 0 lần / 37.200 phím | như đo Telex |
| 29/10/2026 | Cấp phát bộ nhớ trong `handle` | 0 lần / 41.600 phím | chương trình ngoài repo móc `malloc_logger`, có đối chứng dương; chưa có trong CI |
| 29/10/2026 | Cách A theo tốc độ gõ (Debug), câu mẫu `tooi yeeu tieengs Vieetj, windows Sunrise carr ` | 0 ms/phím (System Events gõ cả chuỗi, ~1–2 ms): TextEdit, Safari đúng; Chrome, VS Code, Terminal SAI (mismatch 3–4, thay nhầm vùng ở lần thay đầu của từ). 5 và 10 ms: Chrome, Terminal đúng; VS Code sai từ đầu ("ôoi"). 20, 30, 60, 120 ms: cả 5 app đúng | `scripts/selftest/typing/run.sh --delay N all`, log `diag` |
| 29/10/2026 | Cách A, 30 ms/phím, phím có thay (n=12 mỗi app) | `selectedRange` p50/p99 µs: TextEdit 327/606, Safari 622/1.057, Chrome 415/694, VS Code 230/885, Terminal 408/637; cả phím có thay p50/p99 µs: 3.406/7.617, 1.494/4.731, 1.081/5.296, 617/1.236, 1.165/1.669; mismatch 0 | như trên |
| 30/10/2026 | IMK cách A, Telegram (Debug, tự gõ 30 ms/phím) | `selectedRange` p50 240 / p99 1.670 µs; `insertText` p50 1.830 / p99 3.491 µs; cả phím có thay p50 2.171 / p99 5.313 µs; replace 12, pass 34; mismatch 0, unsupported 0; câu mẫu đúng, không gạch chân, không nhảy chữ | `scripts/perf/perf-report.sh --app Telegram`; agent tự gõ qua System Events trong Saved Messages (`ru.keepcoder.Telegram`), chỉ gõ, không gửi |
| 30/10/2026 | D20 chi phí thêm mỗi phím có đọc (Debug, tự gõ 120 ms/phím, n=6 mỗi app) | `selectedRange` trung vị µs: TextEdit 394, Safari 625, Chrome 327, VS Code 347; `attributedSubstring` trung vị (min–max) µs: TextEdit 1.023 (570–11.189), Safari 3.683 (2.702–12.788), Chrome 765 (484–1.216), VS Code 680 (512–2.537). Chỉ ở phím dấu ngay sau reset/⌫; câu mẫu không đọc lần nào | `run.sh --delay 120 --keys "hoc ⌫j tooi ⌫s carr ⌫s hoc ⌫f viet ⌫j xin chao ⌫f "`, log perf kind `seed`/`seed_pass`, trường `read_ns`; 4 app PASS, Terminal ra "hocj…" (⌫ không tới bộ gõ) |
| 30/10/2026 | D20 không chờ (thử, `settleInterval` = 0) | 0/10/30 ms: TextEdit, Safari, Chrome đúng; VS Code 0 ms không áp dụng (ảnh chụp cũ, không thấy từ), 10/30 ms đúng; không ca nào hỏng chữ. Chốt chờ 50 ms; 30 ms/phím ra "hocj tôis" ở Safari, Chrome (PASS) | `run.sh --delay N` (N = 0, 10, 30) `--keys "hoc ⌫j tooi ⌫s carr ⌫s hoc ⌫f "` |
| 30/10/2026 | Reset khi đổi nguồn không qua `activateServer` | `to⇄cj␣` (⇄ = U.S. rồi Dấu bằng `TISSelectInputSource` từ tiến trình script): có bộ nghe `kTISNotifySelectedKeyboardInputSourceChanged` → "tocj" (TextEdit, Safari PASS); tắt bộ nghe (đối chứng) → "tọc" | `run.sh --keys "to⇄cj " --expect "tocj " textedit` |

## Nhật ký
Nhật ký M0–M4 ở `docs/history/LOG-M0-M4.md`, M5 ở `docs/history/LOG-M5.md`.

(ngày — việc — agent — kết quả — commit)

- 05/11/2026 — đóng M5 (người dùng chốt): kiểm toán lần 1 ĐẠT, các mục nên sửa đã xử lý; nhật ký M5 chuyển sang `docs/history/LOG-M5.md`, kế hoạch M5 sang `docs/history/PLANS.md`; bảng mốc cập nhật. Mốc tiếp theo: M6 — phiên chính
- 05/11/2026 — ca thử từ bộ gõ khác, bước 1 (người dùng chốt cách làm "mù": lấy đầu vào, không lấy đáp án) — researcher: 10 nguồn giữ (gonhanh, ibus-teni, fcitx5-unikey, uvie-rs, ibus-telex, XKey, vi-rs, bamboo-core, ibus-bamboo, goxkey; MIT, BSD-3, GPL), 10.320 ca (Telex 8.239, VNI 2.028, Telex đơn giản 53), bỏ ibus-unikey/OpenKey/fcitx5-bamboo (không có test chuỗi phím) và kho sinh máy (để sau, người dùng chốt); `docs/research/EXTERNAL-TEST-INPUTS.md`, các TSV trong `docs/research/external-test-inputs/` (không cột đáp án), `NOTICE.md`; đáp án của họ để riêng ở `build/external-answers/` (git bỏ qua); script `scripts/research/external-tests/extract.sh` (chạy lại ra trùng từng byte). Tiếp theo: bước 2, engine-dev viết đáp án mù theo DECISIONS — phiên chính
