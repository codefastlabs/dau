# Tiến độ

Nhật ký điều phối, để phiên sau (hoặc sau khi ngữ cảnh bị nén) tiếp tục đúng chỗ. Phiên chính cập nhật file này sau mỗi bước.

> Từ 02/11/2026 repo ở https://github.com/codefastlabs/dau và lịch sử đã được viết lại: các mã commit ghi trước ngày này là mã cũ, tra `docs/history/COMMIT-MAP.md` để ra mã mới.

## Trạng thái hiện tại

Đang làm M6 (Hiệu năng dưới tải), bắt đầu 09/11/2026.
- M5 đóng 05/11/2026.
- Từ 05/11 tới khi bắt đầu M6 làm ngoài mốc:
  - phần nền của M9 (Đa ngôn ngữ), theo D41 (Ngôn ngữ giao diện): mã xong 06/11, hàng "Ngôn ngữ" xong 08/11; nhật ký ở `docs/history/LOG-M5-M6.md`;
  - rút gọn script và test (09/11; nhật ký ở dưới).

Chờ người dùng: duyệt hàng mẫu Slack (thay Visual Studio Code) trên các artboard SettingsApps*, canvas phiên bản 144; chọn có sửa lỗi nhận nhầm "app chậm" ở trình soạn thảo Cursor không (nhật ký 10/11). Việc tiếp theo: đo lại các ô đối chứng Telex của Apple đã hỏng; nhãn "Đề xuất" của Edge (đủ số đo để bỏ); M6 bước 2 (bài tải nặng). Còn mở: một lượt VS Code mà vài phím đầu không tới bộ gõ, nguyên nhân chưa rõ.

Kế hoạch M6 (tiêu chí ở `docs/ROADMAP.md` mục M6):
1. Đang làm: thay chữ tại chỗ khi trang Chrome bận (câu hỏi của D13).
   - Đã đo (nhật ký 09/11): thay tại chỗ sai 8/9 lượt với chuỗi Telex thứ tự chuẩn, 5/6 với chuỗi có sửa dấu (cả bản Release). Gạch chân đúng 9/9, mới đo với chuỗi thứ tự chuẩn.
   - Đã rõ: kiểu sai (a), lần thay đầu của một từ dùng vị trí con trỏ cũ. Chưa rõ: kiểu sai (b), nhánh đọc lại chữ của D11 (Kiểm tra ngữ cảnh) vẫn ra từ sai, có chỗ con trỏ đi trước vị trí chờ đợi.
   - 1a. Xong 09/11 (nhật ký): đối chứng Telex của Apple chạy đúng trên máy A ở mọi ô thử; lỗi ra nguyên chuỗi phím của lượt 18:21 chưa rõ nguyên nhân, nên 1b chạy Apple trước mọi lần cài lại và chỉ tin ô Apple khi chữ có dấu vết của Apple.
   - 1b. Xong 09/11 (nhật ký). Một lượt đo, khoảng 7 phút, trên máy đang dùng (log `build/` không mang giữa các máy). Mọi ô: Chrome, `typing/run.sh --delay 100 --jitter 30 --keys "$(scripts/selftest/load/run.sh --text edit --print keys)" --save <thư mục ô> chrome`, thêm `--busy 300:1000` ở ô trang bận.
     - Thứ tự: (1) Telex của Apple (`--source com.apple.inputmethod.VietnameseIM.VietnameseTelex`), trang rảnh 1 lần (đáp án của Apple) rồi trang bận 3 lần, trước mọi lần cài lại; chỉ tin ô có dấu vết của Apple (1a). (2) Cài Dấu Debug: trang bận 3 lần (log vị trí cho kiểu (b), đọc bằng `perf-report.sh --input`), trang rảnh 1 lần (đối chứng). (3) Cài lại bản Release.
     - Không đo: gạch chân (đường lui, chỉ đo khi cách sửa ở 1c không đạt); Dấu Release (09/11 đã sai 2/3, đủ cho biết lời gọi thêm của bản Debug không phải nguyên nhân).
     - Apple cũng sai khi trang bận thì lỗi không riêng của Dấu, và câu hỏi của D13 đổi.
   - 1c. Mã xong 09/11 (nhật ký), chưa đo thật. Từ log của 1b, hiểu kiểu (b); sửa độ bền của thay tại chỗ (giao imk-dev). Cách sửa phải nới N3 (Ít lời gọi vào ứng dụng đích) thì hỏi người dùng trước khi đổi `DECISIONS.md`.
   - 1d. Đạt 10/11 với Chrome (nhật ký). Đo lại như 1b. Mục tiêu: thay tại chỗ đúng khi trang bận, ít nhất ngang Telex của Apple trong cùng điều kiện. Gạch chân là cách bộ gõ mặc định của macOS hiện chữ, thứ Dấu muốn làm tốt hơn, nên không phải đích của bước này: sửa không đạt thì tìm cách sửa khác. Có số đo rồi thì đề xuất sửa D13 (Gạch chân là đường lui cuối cùng) và nhãn "Đề xuất" bật gạch chân cho Chrome, VS Code, Firefox trong danh sách tương thích; người dùng duyệt.
2. Bài tải nặng theo `docs/ROADMAP.md` mục M6.
3. Phần còn lại của ma trận tương thích, kể cả gạch chân trên thanh địa chỉ Chrome và các trình soạn thảo web lớn (mục "Việc còn mở").
4. Chốt ngưỡng và D12 (Ưu tiên tiến trình) vào `DECISIONS.md` theo số đo (người dùng duyệt).

So sánh với bộ gõ khác (`docs/research/COMPETITOR-COMPARISON.md`, nghiên cứu cho M10 (Học cách gõ)):
- Phần B, C xong 09/11.
- Phần A dừng: dữ liệu công khai không đủ độ chính xác.
- Câu hỏi của D13 (Gạch chân là đường lui cuối cùng) chuyển sang M6 bước 1 (kế hoạch M6 ở trên).

Việc còn mở:
- Các tiến trình trong thư mục cache được hệ thống bảo vệ (WebKit, bộ đệm của Shortcuts) không xoá được bộ đệm.
  - Ảnh hưởng chưa đo.
  - Gỡ cài đặt chưa xoá bộ đệm của các app (`docs/research/M5-INSTALL.md` mục 10.10).
- "vieetj" giữ nguyên trong thanh địa chỉ tab mới của Chrome (hồ sơ công việc), chưa tái hiện. Phiên chính thử lại thanh địa chỉ khi chạy ma trận Chrome ở M6.
- Chưa có artboard: tên các nguồn tiếng Việt khác trong ghi chú của D14 (Onboarding) vẫn theo tiếng Việt của app (bảng tên `LayoutNames` chỉ có bàn phím).

Việc hoãn:
- Về M6: phần còn lại của ma trận tương thích.
- Về M7 (Phát hành):
  - biểu tượng V;
  - danh sách "+" kiểm bằng mắt;
  - VoiceOver đọc đúng tên;
  - VoiceOver và Tab trong Cài đặt (cả hàng "Ngôn ngữ");
  - máy tiếng Anh hẳn;
  - sheet ở chế độ tối;
  - câu gợi ý của hàng "Gặp ứng dụng gõ bị lỗi?".

Ký và máy:
- Ký bằng Personal Team (Team ID trong D24 (Tên và định danh)), ký tự động "Apple Development". Bản phát hành dùng Developer ID ở M7.
- Máy B ký được (09/11: mọi bản build ký hợp lệ).
- Máy A dùng chứng chỉ tạo ngày 05/11.
- Bản đã cài trên máy B: bộ gõ và `/Applications/Dau.app` bản Release 7f3af4b (09/11). Máy A: bộ gõ Release build 09/11 21:23, `/Applications/Dau.app` 16a7350.
- Xcode 27.2 ở `/Applications/Xcode.app`, nhưng `xcode-select` đang trỏ CommandLineTools. Swift 6.4.
  - Script tự chọn Xcode (`scripts/lib/xcode.sh`).
  - Lệnh gõ tay (`swift test`) cần `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`.

## Mốc

| Mốc | Trạng thái | Kiểm toán |
|---|---|---|
| M0 Khung dự án | xong | ĐẠT (29/10) |
| M1 Engine | xong | ĐẠT (29/10, lần 2) |
| M2 Bộ gõ tối thiểu | xong | ĐẠT (30/10, lần 3; lần 1, 2 CHƯA ĐẠT vì tài liệu) |
| M3 Độ tin cậy | xong | ĐẠT (30/10, lần 3; lần 1, 2 CHƯA ĐẠT vì tài liệu) |
| M4 App Cài đặt | xong | ĐẠT (30/10, lần 3) |
| M5 Onboarding, cài, gỡ | xong | ĐẠT (05/11, lần 1; các mục nên sửa đã xử lý) |
| M6 Hiệu năng dưới tải | chưa | — |
| M7 Phát hành | chưa | — |
| M8 Website | chưa | — |
| M9 Đa ngôn ngữ | phần nền và câu chữ tiếng Anh xong (09/11) | — |
| M10 Học cách gõ | chưa | — |

Ghi chú từng mốc:
- M0: build Debug universal cần `-destination generic/platform=macOS`.
- M1:
  - Telex, Telex đơn giản, VNI; 75 test;
  - release ~0,15 µs/phím;
  - 0 từ sai / 474 từ; 0 khôi phục nhầm / 15.796 âm tiết;
  - fuzz 800k thao tác không crash.
- M2:
  - thay chữ tại chỗ, hỏi vị trí ở mỗi phím có thay chữ (cách A, theo `docs/DECISIONS.md`, mục "Vị trí thay chữ");
  - tự gõ 30 ms/phím đúng ở TextEdit, Safari, Chrome, VS Code, Terminal, Telegram (thay Slack); Sublime gõ tay;
  - `selectedRange` p50 0,2–0,6 ms (Debug);
  - M2-TESTING mục 4 ĐẠT trừ việc hoãn (VoiceOver, biểu tượng V → M3; Telegram Return bỏ qua);
  - test engine 76, IMK 25.
- M3:
  - gạch chân (D13) theo quy tắc, mặc định tắt; danh sách đề xuất 13 app (VS Code, Electron/Chromium, Firefox);
  - D20 (Thêm dấu cho từ đã gõ) ở bộ gõ: đọc lại 1–4 ms, chỉ ở phím dấu đầu khi bộ đệm trống;
  - reset khi đổi nguồn không báo;
  - sửa ⌫ xoá hai lần ở Chromium;
  - ma trận `COMPATIBILITY.md`: 11 app đã đo;
  - D17 (Trợ năng): hệ thống tự đọc khi chuyển nguồn;
  - test engine 77, IMK 70, DauShared 32.
- M4:
  - DauShared và cửa sổ 4 mục (2d6206e, c731c61); bộ gõ đọc cài đặt chung (0aa4872);
  - App Group chạy với Team ID M58DANM3ZP (958a5a8);
  - bỏ chế độ Anh, quy tắc theo app chỉ còn gạch chân (9680c68, ea676ae, b23b266);
  - M4-TESTING ĐẠT trừ việc hoãn sang M7 (máy tiếng Anh hẳn, sheet tối, VoiceOver/Tab);
  - ma trận giao diện 12/12;
  - test DauShared 21, IMK 25, snapshot-settings 10.
- M5:
  - onboarding 3 bước;
  - bật không cần đăng xuất (D37 (Cài đặt bộ gõ): xoá bộ đệm nguồn đầu vào của mọi app, đăng ký, Allow);
  - gỡ có bước "–" (D16 (Bảo trì và gỡ cài đặt));
  - kiểm chữ ký và Team ID, banner "Cài lại";
  - tên giao diện macOS theo ngôn ngữ máy (D38 (Chữ trên giao diện));
  - đăng xuất làm mỗi app dựng lại bộ đệm (đo 05/11);
  - snapshot 98 test; `run.sh` đạt trừ lỗi chập chờn "window size at launch" (nguyên nhân tìm ra và hàng đo đó bỏ ngày 09/11/2026);
  - bỏ lượt đo trên tài khoản macOS mới.
- M9: phần nền (D41) xong 06–08/11; câu chữ tiếng Anh chốt và sửa trong catalog 09/11.

## Ghi nhớ cho M7 (từ kiểm toán M0)
- Xem lại gợi ý "Báo lại để bản sau xử lý đúng cho ứng dụng đó" (hàng "Gặp ứng dụng gõ bị lỗi?", `UpdatesSupportView`) theo N5 (Chỉ hứa điều đã kiểm chứng) khi làm báo lỗi.
- `.gitignore` bỏ qua `Package.resolved`: ghim phiên bản Sparkle chính xác trong `project.yml`.
- Thử bỏ `temporary-exception.mach-register.global-name` của bộ gõ khi rà entitlement trước notarize (xem `docs/ARCHITECTURE.md`).
- Thêm `*.p8`, `*.pem`, `*.key`, `*.xcarchive` vào `.gitignore`.
- Đưa phép đếm cấp phát (`malloc_logger`) vào CI.

## Nhật ký
Nhật ký M0–M4 ở `docs/history/LOG-M0-M4.md` (kèm bảng số đo M1–M3), M5 ở `docs/history/LOG-M5.md`, 05–08/11 (giữa M5 và M6) ở `docs/history/LOG-M5-M6.md`.

(ngày — việc — agent — kết quả — commit)

- 09/11/2026 — M6 bước 1, công cụ đo — imk-dev, phiên chính — dòng log mỗi phím (Debug, `DauPerfLog`) thêm `t_ns` (lúc phím tới bộ gõ) và `ev_ns` (giờ của sự kiện phím); `perf-report.sh` in phân bố khoảng cách phím và mismatch theo khoảng cách; `typing/run.sh` thêm `--jitter`, `--busy` (trang thử chặn luồng chính) và lưu cả log `diag`; script mới `scripts/selftest/load/run.sh` (`--apps`, `--loads`). Kiểm: test IMK 111 đạt, `perf-report.sh` với log tự tạo ra đúng số tính tay, `check.sh` đạt.
- 09/11/2026 — M6 bước 1, ba lượt đo (người dùng cho chạy; bộ gõ Debug; `build/load/20261109-161435/`, `-162856/`, `-171006/`, không commit) — phiên chính.
  - Chrome, trang chặn luồng chính 300 ms mỗi giây, phím cách nhau 100 ± 30 ms: thay tại chỗ sai 8/9 lượt, gạch chân đúng 9/9; trang rảnh: đúng mọi lượt.
  - Phím tới bộ gõ đều (mọi khoảng từ 20 ms trở lên), nên lỗi không do phím dồn (H1 loại); Chrome trả `selectedRange` cũ khi chưa áp xong phím trước (H2).
  - Hai kiểu sai trong log vị trí: (a) lần thay đầu của một từ, chưa có vị trí chờ đợi để so (D11 (Kiểm tra ngữ cảnh)), con trỏ chậm một chữ, bộ gõ thay nhầm chữ đứng trước ("mìnhđdi", "anhóco"); (b) D11 bắt được lệch, đọc lại chữ để dựng lại từ, vẫn ra từ sai ("Đaaline", "mêting", "àyy"): cơ chế chưa rõ.
  - Gõ bằng U.S. cùng điều kiện đúng 3/3: chỉ cho biết trang thử và cách gửi phím không tự làm sai chữ; chưa có đối chứng bằng bộ gõ tiếng Việt khác.
  - VS Code, Terminal: đúng mọi lượt, trừ một lượt (VS Code gạch chân, app rảnh) mà System Events gửi phím dồn dưới 10 ms; chưa rõ nguyên nhân. Safari: không dùng được (mục thanh địa chỉ bên dưới).
  - Điều kiện CPU đầy (một `yes` mỗi CPU) không cho thêm thông tin; đã bỏ khỏi script.
  - Dọn: không còn `yes`, `DauPerfLog`, `DauDebugForceUnderline`; Safari, Chrome, VS Code, Terminal để mở.
- 09/11/2026 — `typing/run.sh` gõ vào thanh địa chỉ của Safari (người dùng thấy trên màn hình, trong các lượt M6 bước 1) — phiên chính — guard chỉ kiểm tiêu đề cửa sổ, không kiểm ô nào có focus; ⌘A ⌘C lúc đọc lại chép chính chữ ở thanh địa chỉ nên lượt đó vẫn "đạt". Không nhấn Return, nhưng chữ thử đã đi qua gợi ý tìm kiếm của Safari. Kết quả Safari của các lượt 09/11 không dùng được (không biết lượt nào gõ vào đâu); lượt Safari chữ rối nặng có thể do gợi ý của thanh địa chỉ. Kết quả Chrome giữ: lỗi chỉ có khi trang bận, mà vòng bận chỉ chặn trang (thanh địa chỉ không bị chặn), nên chữ đã vào trang. Sửa: trang thử tự đổi tiêu đề thành "Dấu self test [focus]" chỉ khi ô gõ có focus; phím và ⌘A ⌘C của trình duyệt chỉ gửi dưới tiêu đề đó. Chưa chạy thật cách sửa này.
- 09/11/2026 — M6 bước 1, chuỗi thử có sửa dấu (người dùng cho chạy; 11 ô, 18:21–18:29; `build/load/edit-20261109-182149/`, không commit) — phiên chính.
  - Chuỗi 283 phím: bỏ dấu tự do (D28 (Bỏ dấu tự do)), đổi dấu (`vieetjs`), xoá dấu (`Chaofz`), Backspace (D32 (Backspace)), thêm dấu cho từ đã gõ (D20 (Thêm dấu cho từ đã gõ)), từ tiếng Anh (D4 (Từ nước ngoài)); đáp án tính bằng engine.
  - Chrome, trang bận 300 ms mỗi giây: Dấu bản Release sai 2/3, bản Debug sai 3/3; trang rảnh (Debug) đúng. Bản Release cũng sai nên lời gọi thêm của log vị trí ở bản Debug không phải nguyên nhân.
  - Chỗ sai có cả ở các thao tác sửa: thêm dấu cho từ đã gõ không chạy ("Hocj", 2 lượt), xoá dấu hỏng ("Càooz", 2 lượt), cùng các từ hỏng như các lượt trước ("ọoot", "nươiif", "ìnhh", "êeting", "kôong kóo").
  - Cách sửa focus chạy đúng: mọi ô gõ vào ô của trang thử, không ô nào dừng.
  - Đối chứng Telex của Apple không dùng được: cả ô trang rảnh lẫn trang bận ra nguyên chuỗi phím (không biến đổi chữ nào), dù script xác nhận nguồn hiện tại là Telex của Apple; sáng cùng ngày cùng cách chọn nguồn thì chạy đúng (phần C). Nguyên nhân chưa rõ.
  - Đã cài lại bộ gõ bản Release trong lượt; không còn `DauPerfLog`.
- 09/11/2026 — dữ liệu INP công khai của Chrome cho câu hỏi của D13 — researcher — `docs/research/WEB-INPUT-DELAY.md`.

- 09/11/2026 — rà soát các commit 08/11, sửa hai điểm. (1) Giá trị của hàng "Ngôn ngữ" lặp trong cây trợ năng: đọc AX của Dấu thật (người dùng cho chạy ngay; `install-app.sh` cài 6d772e6+, máy en-VN): giá trị là một AXStaticText "English" chứa thêm một AXStaticText "English" con; hàng phím tắt cùng kiểu thì không lặp. Bỏ `.fixedSize()` vẫn lặp, nên không phải do nó. Sửa: `Text` giá trị thành một phần tử riêng (`.accessibilityElement(children: .ignore)`, nhãn là tên ngôn ngữ), như phím tắt; cài lại, đọc AX: còn một "English". Chưa nghe bằng VoiceOver thật, chưa đọc AX ở trạng thái chờ mở lại (cùng `Text`). Ca này không có test: dựng ngoài màn hình thì SwiftUI không trả cây trợ năng. (2) `dau-version.sh` báo bộ gõ hoặc `/Applications/Dau.app` build từ commit khác HEAD, kèm lệnh cài lại; `install-app.sh` bỏ đoạn so riêng (6d772e6). Snapshot 149 test, check-docs, check-l10n đạt — phiên chính
- 09/11/2026 — đầu ra thống nhất cho mọi script (người dùng chọn: tiếng Việt, toàn bộ `scripts/`, dấu ✓ ! ✗): `scripts/lib/log.sh` (bước `==>`, chi tiết, đạt, cảnh báo và lỗi ra stderr, câu hỏi, dòng kết thúc kèm thời gian; màu chỉ khi ra terminal, `NO_COLOR` tắt), quy ước ở `scripts/README.md` mục "Đầu ra", `check-docs` chặn mã màu và `==>` ngoài `log.sh`. Ba subagent (sonnet) chuyển 20 script và hook; mã thoát 2 cho gọi sai. Dữ liệu cho máy đọc giữ nguyên (cột của `dau-version.sh`, bảng `perf-report.sh`, nhật ký bước của `step.sh`, hàng `ok`/`FAIL`/`HARNESS` của bộ kiểm cửa sổ). Hook không còn chặn `zsh -n` (chỉ kiểm cú pháp) và `step.sh --dry-run`. Đã chạy: `zsh -n` mọi file, check-docs, check-l10n, `dau-version.sh`, `clean-dau.sh` (chỉ đọc), `perf-report.sh`, `install-input-method.sh --build-only`, `probe/cleanup.sh` (chỉ đọc), `step.sh --dry-run`, `compare.sh`, hook với 6 lệnh mẫu. Chưa chạy (chiếm màn hình hoặc cài): `install-app.sh`, `app-group.sh`, `typing/run.sh`, `settings-window/run.sh`, `clean-dau.sh --yes`, `make-*-icon.sh`, `extract.sh` (mạng) — phiên chính
- 09/11/2026 — chạy thật các script còn lại sau khi đổi đầu ra (người dùng duyệt): `make-app-icon.sh`, `make-mode-icons.sh` (repo không đổi byte nào; câu tiếng Anh của công cụ Swift và `tiffutil` giờ chỉ hiện khi lỗi), `extract.sh` (TSV khớp bản commit), `install-app.sh --with-input-method`, `app-group.sh` (lần đầu trượt vì bộ gõ đã cài là Release, không ghi `event=settings-loaded`; câu lỗi nay chỉ cách chạy lại với `--install`; `--install` đạt), `typing/run.sh safari chrome vscode terminal` đạt (không dùng TextEdit), `settings-window/run.sh` đạt cả (387, 15, 2, 28; 292), 3 phút 26 giây. Sau đó cài lại bộ gõ Release, chọn lại nguồn Dấu (dừng bộ gõ làm macOS lùi về U.S.), mở lại Dấu.app. Chưa chạy: `clean-dau.sh --yes` (gỡ Dấu khỏi máy, người dùng tự chạy). Còn tiếng Anh do công cụ Swift in: dòng tổng "… checks passed (N)" của bộ kiểm cửa sổ — phiên chính
- 09/11/2026 — `typing/run.sh`: khi Terminal chưa chạy, mở Terminal ra cửa sổ khởi động rồi `do script ""` mở thêm cửa sổ thứ hai; script chỉ đóng cửa sổ thứ hai nên bỏ lại một cửa sổ (người dùng thấy). Sửa: Terminal do script mở thì gõ vào chính cửa sổ khởi động. Chạy lại cả hai đường (Terminal chưa chạy: sau thử 0 cửa sổ; Terminal đang mở 1 cửa sổ: sau thử vẫn 1), đều đạt; đã thoát Terminal (trước khi thử nó không chạy) — phiên chính
- 09/11/2026 — rà soát `scripts/` và mọi bài test (người dùng duyệt: làm theo góp ý trừ CI; mỗi bài test phải đáng với cái giá của nó; dọn mọi thứ các lần thử để lại trên máy). Kết quả cuối: cài bộ gõ và Dấu.app chép vào bản ẩn cạnh rồi đổi tên, Thùng rác bằng `/usr/bin/trash -s` (đã chạy thật); mọi script có `set -u`, `pipefail`, `zsh -n`; Xcode chọn ở `scripts/lib/xcode.sh`; bộ tự kiểm chờ theo trạng thái (`scripts/lib/wait.sh`); `scripts/README.md` chỉ còn quy ước, đầu mỗi script là mô tả duy nhất; hook chặn script dùng bảng ghi thẳng, `check.sh` báo khi script làm phiền chưa có trong bảng; `check.sh` bỏ kiểm số test và mục "Hiện trạng" (quy tắc vẫn ở CLAUDE.md), bỏ kiểm đường dẫn trong nhật ký có ngày; xoá scripts/probe (vòng thử M5 xong); bỏ `LegacyModeMemory` (chỉ cho bản build trước 30/10, chưa phát hành; `LaunchOrigin` là mã đang dùng, giữ). Bộ kiểm cửa sổ: 8 lần mở → 6, 2 phút 43 giây → 1 phút 58 giây, đạt cả; bỏ hàng "window size at launch" (so một hằng số), chuột giả của sidebar và menu View (test đơn vị đã có), lần mở `--not-enabled` và ảnh banner (thay bằng `NotEnabledBannerTests`, đỏ khi đổi chỗ banner), sheet chỉ một màn hình và các hàng hành vi. Hai lỗi chập chờn cũ: sheet vì danh sách cần 5–6 s mới đủ (bộ kiểm cũ chờ 0,6 s); cỡ cửa sổ 740×747 vì app thử bị dừng bằng `kill` nên macOS khôi phục cửa sổ ở lần mở sau của cùng bundle ID (đo: mở với `-ApplePersistenceIgnoreState YES` 560 3/3, mở thường 747 3/3; thoát thường một lần thì hết), nay `run.sh` thoát app thử bằng `NSRunningApplication.terminate`; các cỡ 740×452, 976×700 của 03–05/11 chưa đo, chỉ có thể cùng nguyên nhân. Giả thuyết đầu (Dấu.app Release đang chạy) sai và đã hoàn tác (fc47a22). Test gộp thành bảng, bỏ assert chỉ ghim câu chữ; test không còn để lại plist trong `~/Library/Preferences`. Dọn máy: các mục `local.probe.*` (người dùng xoá container), đăng ký LaunchServices trỏ tới bản build không còn, `build/probe-fixed-sidebar`. Test: engine 100, DauShared 35, snapshot 139, IMK 111 đạt; `typing/run.sh` (Safari, Chrome, VS Code, Terminal, nhánh ⇄) và `app-group.sh --install` đạt. Cài lại bộ gõ và Dấu.app Release 24e61ec, chọn lại Dấu — phiên chính
- 09/11/2026 — câu chữ tiếng Anh của M9: phiên chính chốt các đề xuất của bản duyệt tạm (người dùng giao chốt): sửa câu tiếng Anh ở 13 khoá (câu "app gõ sai" thành "Text may come out wrong…", tiêu đề alert gỡ thành "Uninstall Dấu?", bỏ "the" trước tên Thùng rác vì máy tiếng Việt hiện "the Thùng rác", câu không còn viết cứng tên mục "Accessibility" và "Apple menu"…), giữ nguyên mọi bản `vi`; luật viết hoa tiêu đề và "Gõ Nhanh" vào `docs/GLOSSARY.md`; xoá bản duyệt tạm. Build hai scheme, check-l10n (4 catalog), snapshot 139 test đạt — app-ui-dev, phiên chính
- 09/11/2026 — bỏ các chỗ lệch còn lại: bản `vi` của hai câu theo đúng ý bản tiếng Anh ("Dấu không cần quyền điều khiển máy Mac.", không viết cứng tên mục "Trợ năng", D38; "sau đó bộ gõ được chuyển vào Thùng rác"), sửa cả 12 artboard trên canvas (phiên bản 138) và bản chụp `docs/ui/canvas/`; cửa sổ Cài đặt rộng cố định 740 như System Settings, chỉ đổi chiều cao (trước cho kéo tới 976). Build Debug, snapshot 139 test, check-l10n, check-docs đạt; chưa chạy bộ kiểm cửa sổ thật — phiên chính
- 09/11/2026 — bộ kiểm cửa sổ thật sau khi cố định độ rộng 740 (người dùng cho chạy): lượt đầu 5 dòng không đạt, đều là kiểm cũ chờ cửa sổ kéo rộng tới 976; sửa bộ kiểm (rộng tối đa 740, bỏ dòng thẻ ở cửa sổ rộng nhất, bf5a35b), chạy lại đạt hết (302, 15, 28; 286), 2 phút 2 giây — phiên chính
- 09/11/2026 — script chỉ còn zsh và Swift biên dịch một lần (`scripts/README.md` mục "Ngôn ngữ", `check-docs` kiểm 11); `scripts/research/external-tests/` giữ Python. Công cụ Swift mới cho đầu ra giống bản Python cũ. Chạy thật đạt: `app-group.sh`, `typing/run.sh` (Safari, Chrome), `compare-ims/run.sh dau`, `clean-dau.sh --yes` rồi cài lại Release. `clean-dau.sh` không xoá được container của bộ gõ ("Operation not permitted"; tiến trình chạy script không có Full Disk Access) — phiên chính, 2 subagent
- 09/11/2026 — M6 bước 1a: vì sao đối chứng Telex của Apple ra nguyên chuỗi phím lúc 18:21 (máy A; log của lượt 18:21 ở máy B) — phiên chính.
  - Quan sát cũ: phần C sáng 09/11 (30 ms, không jitter, Telex thứ tự chuẩn) Apple biến đổi đúng; lượt 18:21 (Chrome, 100 ± 30 ms, chuỗi có sửa dấu, trang rảnh và bận) ra nguyên chuỗi phím, dù TIS báo nguồn hiện tại là Apple; trong lượt đó bộ gõ Dấu được cài lại, không còn biết trước hay sau các ô của Apple.
  - Giả thuyết: H1, sau khi tiến trình bộ gõ bị dừng và macOS lùi về U.S., app gõ bằng U.S. dù TIS báo Apple; H2, nhịp 100 ± 30 ms làm Apple không biến đổi; H3, một phím trong chuỗi có sửa dấu (⌫, chữ hoa) làm Apple ngừng biến đổi.
  - Lượt phân biệt (người dùng cho chạy; 21:23–21:25, khoảng 1,5 phút; Chrome trang rảnh, `typing/run.sh --source com.apple.inputmethod.VietnameseIM.VietnameseTelex chrome`, phím lấy từ `load/run.sh --text std|edit --print keys`): (a) chuỗi thứ tự chuẩn, `--delay 30`; (b) chuỗi có sửa dấu, `--delay 100 --jitter 30`; (c) `install-input-method.sh --release --no-build` (dừng tiến trình Dấu) rồi lặp (b). Cả ba ô Apple biến đổi chữ, đúng kiểu của Apple: không khôi phục từ tiếng Anh ("mêting"), không có D20 (Thêm dấu cho từ đã gõ) ("Hocj"), "Chaofz" ra "Chao". (b) và (c) ra cùng một chữ.
  - Kết luận: H2, H3 bị loại trên máy này. H1 chưa kiểm được: ở (c) tiến trình Dấu đã dừng nhưng nguồn hiện tại vẫn là Dấu, macOS không lùi về U.S., nên điều kiện của H1 không dựng lại được. Khác biệt còn lại giữa hai lượt: máy (lượt 18:21 ở máy công việc). Nguyên nhân: chưa rõ.
  - Cho 1b: đối chứng Apple dùng được trên máy này. Chạy các ô của Apple trước mọi lần cài lại, và chỉ tin ô Apple khi chữ có dấu vết của Apple (như "mêting"), không phải nguyên chuỗi phím.
  - Sửa: `typing/run.sh --save DIR` tự tạo DIR (lượt này lộ ra: thư mục chưa có thì không ghi được chữ đọc lại).
  - Máy: Telex của Apple đã bật sẵn, không cần người dùng bật. Bộ gõ đã cài nay là bản Release build trong lượt (mã nguồn bộ gõ như HEAD); Dấu.app vẫn 16a7350 (chưa cài lại). Dọn: tab thử đã đóng, nguồn trả về Dấu, không còn khoá `defaults` có chữ `Dau`, đã xoá `build/load/`.
- 09/11/2026 — M6 bước 1b (người dùng cho chạy; máy A, 21:35–21:40; log ở `build/load/1b-20261109-213527/`, không commit) — phiên chính. Chrome, chuỗi có sửa dấu, 100 ± 30 ms, trang bận 300 ms mỗi giây; lệnh ở kế hoạch 1b.
  - Telex của Apple: trang rảnh 1/1 và trang bận 2/3 ra cùng một chữ (chữ của Apple: "mêting", "Hocj"), nên trang bận không làm Apple sai. Ô trang bận đầu tiên ra nguyên chuỗi phím (⌫ vẫn xoá), đúng hiện tượng của lượt 18:21; ô đó không theo sau lần cài lại nào (bản Release cài lúc 21:23, ô (c) của 1a sau đó vẫn đúng), nên H1 của 1a không phải điều kiện cần. Nguyên nhân: chưa rõ.
  - Dấu Debug: trang rảnh 1/1 đúng; trang bận 0/3: "áng" (mất "S" của "Sáng"), "êeting", "nàyy"; "Hocj" (D20 (Thêm dấu cho từ đã gõ) không chạy); "ạnn", "đaaline", "vêetjs", "chêeuf".
  - Phím tới bộ gõ đều: mọi khoảng cách từ 20 ms trở lên ở cả 4 ô, độ trễ phím p99 dưới 1,3 ms (H1 của M6 loại lần nữa).
  - Kiểu (a) thấy rõ trong log vị trí: "bạn" (phím b a n j) ở lần thay đầu của từ có `sel` 21 thay vì 22 (chữ "n" chưa được Chrome áp), nên bộ gõ thay "ba" thành "ạn" và ra "ạnn"; không có vị trí chờ đợi để so (D11 (Kiểm tra ngữ cảnh)), nên không bắt được. Mỗi ô trang bận chỉ có 1–3 dòng resync, ít hơn số từ sai: phần lớn chỗ sai không được D11 phát hiện. Kiểu (b) phân tích ở 1c.
  - So với mục tiêu của 1d: trong điều kiện này Apple đúng 2/2 lần nó biến đổi chữ, Dấu thay tại chỗ đúng 0/3.
  - Dọn: tab thử đã đóng, nguồn trả về Dấu, không còn khoá `defaults` có chữ `Dau`; bộ gõ đã cài lại bản Release (build lúc 21:23, mã bộ gõ như HEAD). Giữ `build/load/1b-20261109-213527/` cho 1c.
- 09/11/2026 — M6 bước 1c: thay tại chỗ khi app trả lời chậm — imk-dev, phiên chính.
  - Cơ chế (từ log 1b): Chrome áp phím đúng thứ tự nhưng trả `selectedRange` và `attributedSubstring` từ chữ cũ, thường thiếu đúng một phím. Kiểu (b) không phải lỗi riêng: vị trí chờ đợi của D11 (Kiểm tra ngữ cảnh) tính từ lần thay đầu đã sai, nên lần dựng lại đọc đúng từ đã hỏng. Chi tiết và cách xử lý: `docs/ARCHITECTURE.md` mục "App trả lời chậm".
  - Client giả trong `LateAnswerTests` tái hiện đúng chữ của log cho "ạnn", "êeting", "nàyy", "vêetjs", "chêeuf", "Hocj" (đỏ trước khi sửa). "đaaline": mô hình ra "đealine", chữ cụ thể chưa rõ. "áng": "S" chưa từng vào ô, không phải lỗi vị trí, nguyên nhân chưa rõ, cách sửa không đụng tới.
  - Sửa thêm một lỗi có sẵn: khi D11 dựng lại từ mà phím chỉ thêm chữ, chữ bị chèn hai lần (test `resyncAppends`).
  - Số lời gọi tối đa mỗi phím không đổi (1 `selectedRange`, 1 `attributedSubstring`, 1 `insertText`), nhưng lần đọc khi lệch nay có thể xảy ra ở lần thay đầu của từ, và bộ gõ thay ở vị trí nó tự theo dõi khi chữ đọc được cho thấy app chỉ chậm: câu chữ của D11 cần sửa, đề xuất sau khi 1d có số đo. `lateLimit` = 2 (mọi câu trả lời chậm trong 1b chỉ chậm một phím; mô phỏng 200 seed: chậm 0–2 phím 0 sai, chậm 3 phím lùi về cách cũ).
  - Kiểm: test IMK 124 đạt (trước 111; `xcodebuild test -scheme DauInputMethod`, phiên chính chạy lại), build Debug và Release, check-docs. Chưa đo trên Chrome thật (bước 1d).
- 09/11/2026 — M6 bước 1d, lần 1 (người dùng cho chạy; máy A, 22:58–23:01; Dấu Debug e5201e3; log `build/load/1d-20261109-225810/`, không commit) — phiên chính. Lệnh như 1b, chỉ các ô của Dấu (Apple đã đo ở 1b).
  - Trang rảnh 1/1 đúng. Trang bận vẫn 0/3, nhưng ít từ sai hơn 1b: "ỏii", "ìnhh", "chêeuf"; "kôong kóo"; "née". Phím tới bộ gõ đều (mọi khoảng ≥ 20 ms).
  - Nhánh mới chỉ chạy 1 lần (`count_late` 1, ở busy-3, và ở đó đúng). Ở các từ sai: `selectedRange` khác `known`, lần đọc có chạy, nhưng chữ đọc được không khớp mô hình "app chậm", nên rơi về nhánh tin `selectedRange` (đầu từ), và sau đó `known` đi theo vị trí sai. Vì sao không khớp: chưa rõ; một giả thuyết là `selectedRange` và `attributedSubstring` không trả cùng một trạng thái của chữ. Giao lại imk-dev.
  - Dọn: tab thử đã đóng, nguồn trả về Dấu, không còn khoá `defaults` có chữ `Dau`, đã cài lại bản Release (e5201e3).
- 09/11/2026 — M6 bước 1c, lượt sửa thứ hai (từ log 1d lần 1) — imk-dev, phiên chính.
  - Cơ chế (mã nguồn Chromium, chưa đo trên bản Chrome đã cài): `selectedRange` và `attributedSubstring` trả từ bộ đệm phía trình duyệt; phím đi thẳng được ghi ngay vào bộ đệm ở vị trí con trỏ trang báo lần trước, nên chữ đọc được có thể thiếu một chữ ở giữa ("…hi" thay vì "…hoi"), không phải ảnh chụp của một lúc cũ. Client giả thêm chế độ đó tái hiện đúng mọi từ sai của 1d lần 1 và "đaaline" của 1b.
  - Sửa: thêm cách chứng minh app chậm bằng chữ bộ gõ đã gõ; `known` không còn bị ghi đè bởi một `selectedRange` cũ; lần thay đầu của từ, app chậm 1–2 chữ mà không chứng minh được, và trước vị trí app trả không có đủ cả từ: thay ở `known` (kind `late_guess`). Chi tiết: `docs/ARCHITECTURE.md` mục "App trả lời chậm". `late_guess` thay ở vị trí app chưa xác nhận, nên câu chữ của D11 (Kiểm tra ngữ cảnh) cần sửa; đề xuất sau lượt đo.
  - Kiểm: test IMK 128 đạt (phiên chính chạy lại), check-docs. Chưa đo trên Chrome thật.
- 09/11/2026 — M6 bước 1d, lần đo lại sau lượt sửa thứ hai (người dùng cho chạy, 23:15) — phiên chính. Không có kết quả: màn hình Mac đã khoá và tắt từ 23:14:29, nên Chrome không lên trước được; script không gửi phím nào (mã thoát 3 ở cả 4 ô) nhưng đã mở tới 4 tab "Dấu self test" (3 tab có vòng chặn luồng chính) và không đóng được. Sửa: `typing/run.sh` từ chối chạy khi màn hình khoá (`CGSSessionScreenIsLocked`), trước khi mở app nào; đã chạy thật khi màn hình khoá: dừng ngay, không mở tab. Dọn: bộ gõ đã cài lại bản Release, không còn khoá `defaults` có chữ `Dau`, đã xoá log của lượt; các tab còn lại phiên chính đóng sau khi người dùng mở khoá.
- 10/11/2026 — M6 bước 1d, đo lại sau lượt sửa thứ hai (người dùng cho chạy; máy A, 06:13–06:16; Dấu Debug bcd4e54; `typing/run.sh` khi đó thiếu bước kiểm màn hình khoá của 0298b49 (thay đổi chưa commit, đã khôi phục sau lượt), phần gõ không đổi; log `build/load/1d2-20261110-061308/`, không commit) — phiên chính. Lệnh như 1b, chỉ các ô của Dấu.
  - Trang bận 3/3 đúng, trang rảnh 1/1 đúng (1b: trang bận 0/3; 1d lần 1: 0/3).
  - Nhánh app chậm chạy 5, 7, 4 lần ở ba ô trang bận (`late`; một lần `late_guess`, ở busy-1, chữ vẫn đúng), 0 lần ở ô trang rảnh; không còn dòng resync nào. Phím tới bộ gõ đều (mọi khoảng ≥ 20 ms).
  - So với mục tiêu của 1d: cùng điều kiện, Telex của Apple (1b) ra chữ của nó ở 2/3 ô trang bận, ô còn lại ra nguyên chuỗi phím; Dấu thay tại chỗ đúng 3/3.
  - Phạm vi: một máy, Chrome, một kiểu tải (trang chặn 300 ms mỗi giây), nhịp 100 ± 30 ms, 3 lượt. Chưa đo app Electron (VS Code), phím dồn dưới 20 ms, kiểu tải khác.
  - Dọn: không còn tab thử, nguồn trả về Dấu, không còn khoá `defaults` có chữ `Dau`, đã cài lại bản Release.
- 10/11/2026 — M6: "App trả lời chậm" cho phím dồn dưới 50 ms — imk-dev, phiên chính. Tiêu chí đạt: đúng ở 5, 10, 20 ms (người gõ nhanh nhấn chồng phím); 0 ms chỉ ghi giới hạn (máy gửi cả chuỗi một lần, không phải tốc độ gõ thật, D13 (Gạch chân là đường lui cuối cùng)).
  - Nhánh app chậm chạy ở mọi tốc độ (D20, phép kiểm từ đã hết hợp lệ và lần dựng lại của D11 vẫn chờ 50 ms); app được chậm tới 2 thao tác cộng số thao tác của loạt phím dồn, vượt 2 thì chữ của app trước đó phải trùng chữ Dấu đã gõ. Vùng thay luôn kết thúc ở vị trí Dấu theo dõi: theo mã nguồn, VS Code (EditContext) và Firefox đưa con trỏ về cuối vùng vừa thay, nên cách cắt phần cuối từ cũ làm phím sau rơi vào giữa từ. Chi tiết: `docs/ARCHITECTURE.md` mục "App trả lời chậm".
  - Mô phỏng (client giả theo mã nguồn Chromium, VS Code, Firefox; thời gian xử lý của app là số chọn để bản cũ sai đúng như M3, không phải số đo; 40 seed × 2 chuỗi): 5, 10, 20 ms 0 sai ở cả ba mô hình (bản cũ: VS Code, Firefox sai ở 5 ms); 0 ms: Chrome 0 sai, VS Code và Firefox còn sai 30/40 với chuỗi std.
  - Câu chữ của D11 ("phím trước cách ít nhất 50 ms", "tối đa 2 chữ", "Phím dồn dưới 50 ms: chưa áp dụng") và câu tương ứng trong "Câu hỏi đã trả lời" chưa khớp mã mới; đề xuất sửa cùng kết quả đo thật.
  - Kiểm: test IMK 133 đạt (phiên chính chạy lại), build Debug và Release, check-docs. Chưa đo trên app thật.
- 10/11/2026 — M6: đo phím dồn sau 50b67ec (người dùng cho chạy; máy A, 06:58–07:04; Dấu Debug; chuỗi std; app rảnh; log `build/load/fast-20261110-065810/`, không commit) — phiên chính.
  - `--delay 5` và `--delay 10` cho khoảng cách thật gần như nhau: phần lớn phím 10–20 ms, chỉ 0–7 phím mỗi lượt dưới 10 ms (System Events tốn ~10 ms mỗi phím). Nên "5 ms" ở đây (và ở M3, cùng script) là nhịp danh nghĩa; nhịp thật dưới 10 ms chưa đo được bằng script này.
  - Chrome: 5 và 10 ms 6/6 đúng, 20 ms 1/1; trang bận 100 ± 30 ms (chuỗi edit, hồi quy vì vùng thay không còn cắt) 3/3 đúng. Ở trang rảnh không có lần app chậm nào (`late` 0).
  - Firefox: 5 và 10 ms 6/6 đúng, 20 ms 1/1 (M3: sai ở 5 ms danh nghĩa). Không có lần `late` nào, nên cái sửa được là vùng thay luôn kết thúc ở vị trí Dấu theo dõi (Firefox đưa con trỏ về cuối vùng thay).
  - VS Code: 7/9 đúng, 20 ms 1/1. Hai lượt sai cùng một chỗ: từ đầu tiên của tài liệu mới, "Chieeuf" ra "êhieuf": ở lần thay đầu, VS Code mới áp "C" (`sel` 1, `known` 4, chậm 3 thao tác, ngoài `lateLimit`) và đầu văn bản không có chữ nào của app để chứng minh, nên Dấu tin `selectedRange`. Các từ sau đúng.
  - Telex của Apple, 5 ms: Chrome và Firefox ra nguyên chuỗi phím (hiện tượng đã thấy ở 1b, nguyên nhân chưa rõ); VS Code ra chữ của Apple nhưng mất "h" của từ đầu ("Ciều") và "mêting".
  - Dọn: không còn cửa sổ thử ở Chrome, VS Code, Firefox; nguồn trả về Dấu; không còn khoá `defaults` có chữ `Dau`; đã cài lại bản Release 50b67ec; giữ log cho việc sửa VS Code.
- 10/11/2026 — M6: từ đầu tiên của tài liệu mới trong VS Code — imk-dev, phiên chính.
  - Sửa (`CursorTracker.typedHere`): các thao tác app chưa áp bắt đầu từ đầu văn bản, mọi chữ trước con trỏ là chữ Dấu đã gõ, và phím đang xử lý thuộc cùng loạt phím dồn thì coi là app chậm mà không cần chữ của app để so; sau một quãng nghỉ từ 50 ms thì không áp dụng. Số lời gọi mỗi phím không đổi (N3). Chi tiết và giới hạn mới (app tự xoá hết chữ ở đầu văn bản giữa hai phím dồn): `docs/ARCHITECTURE.md` mục "App trả lời chậm".
  - Mô phỏng: test dựng lại ca này đỏ trước khi sửa (mô hình bộ đệm Chromium, trang chưa báo phím nào, ra "êhieuf nay …"), xanh sau; nhịp 5, 10, 20 ms 0 sai ở ba mô hình, kể cả khi app chưa áp phím nào trong 40 hoặc 80 ms đầu tài liệu (số chọn, không phải số đo). Test IMK 140 đạt (phiên chính chạy lại), check-docs đạt.
  - Đo trên VS Code thật (người dùng cho chạy; máy B, 08:48–08:50; Dấu Debug 869f05a kèm bản sửa; chuỗi std, tài liệu mới mỗi lượt, lệnh như lượt 06:58; log `build/load/vscode-first-20261110-084827/`, không commit): 8/9 lượt đúng (5 ms 3/4, 10 ms 4/4, 20 ms 1/1). Ca của lượt 06:58 (`sel` 1, `known` 4 ở lần thay đầu của từ đầu tiên) xảy ra ở 7 trong 8 lượt 5 và 10 ms, cả 7 lần đi nhánh `late` và ra "Chiều". Sau lần thay đó VS Code vẫn trả `sel` 1.
  - Lượt sai (lượt đầu tiên sau khi cài bản Debug): từ đầu ra nguyên "Chieeuf", các từ sau đúng; mọi phím của từ đó là `pass`, log có 225 phím so với 232 ở các lượt khác, tức vài phím đầu không tới bộ gõ. Khác kiểu sai "êhieuf".
  - Lượt phân biệt (người dùng cho chạy; 09:12–09:14; 5 ms; log `build/load/vscode-cold-20261110-091257/`, không commit): giả thuyết là tiến trình bộ gõ vừa cài chỉ khởi động ở phím đầu tiên nên vài phím đầu lọt. 3 lượt ngay sau `install-input-method.sh --no-build` xen kẽ 3 lượt khi tiến trình đã chạy: 6/6 đúng, mọi lượt đủ 232 phím. Giả thuyết không tái hiện được. Khác biệt còn lại của lượt sai: nó chạy ngay sau ô Telex của Apple. Nguyên nhân chưa rõ; tổng VS Code sau sửa 14/15.
  - Chưa rõ: mô hình VS Code trong test (con trỏ về cuối vùng thay) không ra chữ "êhieuf" của lượt 06:58, mô hình giữ con trỏ thì ra; cách sửa đạt ở cả hai.
  - Telex của Apple, 5 ms, 1 lượt: ra nguyên chuỗi phím (hiện tượng đã thấy, nguyên nhân chưa rõ).
  - Dọn: cửa sổ thử đã đóng, nguồn trả về Dấu, không còn khoá `defaults` có chữ `Dau`, đã cài bộ gõ bản Release (869f05a kèm bản sửa). `/Applications/Dau.app` trên máy B vẫn d8af10f.
- 10/11/2026 — D11 (Kiểm tra ngữ cảnh) viết lại theo mã, và Chrome, Firefox, VS Code bỏ nhãn "Đề xuất" (người dùng duyệt) — phiên chính, app-ui-dev. `DECISIONS.md` (D11 ý "App trả lời chậm", D13 (Gạch chân là đường lui cuối cùng), "Câu hỏi đã trả lời"), `docs/history/DECISIONS-LOG.md`, `superseded.txt`, ghi chú trên canvas; `CompatibilityList.json` (ba mục giữ lại với `suggestUnderline` tắt), test, `docs/COMPATIBILITY.md`. Artboard SettingsApps* (canvas phiên bản 144): hàng mẫu Google Chrome đổi thành Microsoft Edge (đã duyệt), Visual Studio Code đổi thành Slack (chờ duyệt); bản chụp `docs/ui/canvas/` dựng lại. Kiểm: DauShared 35, snapshot 139 test đạt, check-docs, check-l10n đạt. Chưa cài lại `/Applications/Dau.app` trên máy B.
- 10/11/2026 — M6: đo Edge, và Firefox khi trang bận, sau các lần sửa (người dùng cho chạy; máy B; Dấu Debug dc7208c; log `build/load/pilot-20261110-092848/`, `build/load/full-20261110-093244/`, không commit) — phiên chính.
  - Lượt thử trước (09:28, 5 ms, mỗi app một lượt) để chốt cách đo: ô mốc VS Code đúng, đủ 232 phím; Edge đúng, đủ 229 phím, phím vào ô của trang thử, log mang đúng bundle ID, có 1 lần `late`.
  - Edge, chuỗi std, app rảnh (09:32–09:42): 5 ms 4/4, 10 ms 4/4, 20 ms 1/1; `late` 0–3 lần mỗi lượt, không có resync. Một ô 5 ms nữa dừng trước khi gõ (Edge vừa mở hiện trang "Is this the new tab you expected?" thay cho trang thử), không tính.
  - Trang bận 300 ms mỗi giây, chuỗi edit, 100 ± 30 ms: Edge 3/3 đúng (`late` 4–7 lần), Firefox 3/3 đúng (`late` 8–14 lần); không có `late_guess`, không resync.
  - Cursor không đo được ở lượt này: thử thêm `cursor` vào `typing/run.sh` theo cách của VS Code (⌘N mở tệp mới), nhưng ở Cursor ⌘N mở một agent mới, cửa sổ vẫn tên "Cursor Agents", nên script dừng trước khi gửi chữ nào (ô đầu: Cursor chưa lên trước). Đo được ở lượt sau (mục dưới).
  - Zalo, Discord, Notion, Figma không đưa vào lượt tự động: gõ thử ở đó là gõ vào cuộc trò chuyện hay tài liệu thật của tài khoản.
  - Dọn: Edge và Firefox do script mở đã thoát; Cursor để như trước lượt đo (đang chạy); nguồn trả về Dấu, không còn khoá `defaults` có chữ `Dau`, đã cài lại bộ gõ bản Release.
- 10/11/2026 — M6: đo Cursor (người dùng yêu cầu; máy B, 09:46–09:49; Dấu Debug dc7208c; Cursor 3.24.12; chuỗi std; log `build/load/cursor-20261110-094602/`, không commit) — phiên chính.
  - Cách đo: `typing/run.sh` thêm app `cursor`, mở trình soạn thảo trên một tệp trống tạm (`cursor --new-window`), tiêu đề cửa sổ là tên tệp. Mọi ô đủ 232 phím tới bộ gõ, log mang đúng bundle ID.
  - Thay tại chỗ: 5 ms sai 3/3 ("co", "uongs", "tuan", "veề", "meting"; lượt khác "minhf", "guir", "àyy la tứu áuu"), 20 ms sai 1/1 ("uongs", "tuanf"), 100 ms đúng 1/1. Gạch chân (`--underline`) ở 5 ms đúng 1/1.
  - Log vị trí: từ từ thứ hai trở đi, `selectedRange` của Cursor là số nhỏ (2–6) trong khi vị trí Dấu tự theo dõi (`known`) là 5–21, tức Cursor trả vị trí theo một gốc toạ độ khác và gốc đó đổi theo từ. Phần lớn lần thay tin `selectedRange` và đúng. Các từ sai nằm ở lần thay đi nhánh `late` (thay ở `known`, 5–8 lần mỗi lượt 5 ms, 2 lần ở 20 ms) và ở các dòng `mismatch` (2–4 lần, reset không thay). Ở 100 ms không có `late` hay `mismatch`.
  - Chưa rõ: trước các lần sửa ở M6 Cursor đúng hay sai ở các nhịp này (chưa từng đo), nên chưa biết nhánh `late` làm Cursor sai thêm hay Cursor vốn đã sai khi phím dồn. VS Code cùng ngày trả vị trí tuyệt đối (`sel` 15, `known` 16) và đúng.
  - Hệ quả: Cursor giữ nhãn "Đề xuất" (số đo cho thấy còn sai ở 5 và 20 ms, gạch chân sửa được). App Electron chưa đo không suy ra được từ Chrome hay VS Code.
  - Còn mở ở script: sau mỗi ô, cửa sổ thử của Cursor ở lại với hộp hỏi lưu; lượt này phiên chính đóng bằng "Don't Save" qua Accessibility.
  - Dọn: các cửa sổ thử của Cursor đã đóng, nguồn trả về Dấu, không còn khoá `defaults` có chữ `Dau`, đã cài lại bộ gõ bản Release.
- 10/11/2026 — M6: Cursor ở hai chỗ gõ, có đối chứng cho cách mở (người dùng cho chạy; máy B, 10:04–10:08; Dấu Debug dc7208c; Cursor 3.29.15, nền VS Code 1.128.0; VS Code 1.145.2; chuỗi std; log và ảnh chụp cửa sổ giữa lúc gõ ở `build/load/cursor2-20261110-100405/`, không commit) — phiên chính, imk-dev (đọc log).
  - Cách đo: `typing/run.sh` có `cursor` (trình soạn thảo mở trên một tệp trống của lượt chạy), `cursoragents` (ô nhập của cửa sổ "Cursor Agents": ⌘N mở agent mới, ô không trống thì dừng, không nhấn Return) và `vscodefile` (VS Code mở cùng kiểu với `cursor`). Lượt thử trước ba ô, phiên chính xem ảnh chụp: chữ vào đúng trình soạn thảo và đúng ô nhập, không có lớp gợi ý nào chen vào; cửa sổ thử tự đóng.
  - Đối chứng cách mở: VS Code mở trên tệp, 5 ms: đúng 1/1, vị trí tuyệt đối (`sel` bằng `known`). Cách mở không làm sai.
  - Trình soạn thảo của Cursor: 5 ms sai 2/2, 20 ms sai 1/1, 100 ms đúng 1/1 (cùng kết quả với lượt 09:46 trên bản 3.24.12). `selectedRange` tính từ đầu từ đang gõ (`sel` 2 khi `known` 16), khác VS Code.
  - Ô nhập Agents của Cursor: 5 ms đúng 2/2, 20 ms đúng 1/1, 100 ms đúng 1/1; vị trí tuyệt đối; `late` 2 lần mỗi lượt 5 ms, chữ đúng.
  - Hai nhóm lỗi ở trình soạn thảo (imk-dev đọc log, tính tay `CursorTracker.rebuild`, chưa chạy bằng test): (1) "uongs", "tuanf" có ở mọi lượt 5 và 20 ms, đúng cùng phím: `sel` của Cursor đúng nhưng Dấu nhận nhầm là app chậm (gốc toạ độ về 0 mỗi từ làm phép dựng lại khớp tình cờ qua một thao tác xoá không biết chữ) và thay ở `known`; phím sau đó `mismatch`. Nhóm này do nhánh "App trả lời chậm" của M6. (2) Các từ khác ở 5 ms ("co", "guir", "meting", "minhf"): Cursor trả `sel` của từ trước; tin `sel` hay dùng `known` đều sai. Mã trước M6 có sai ở nhóm (2) không: chưa đo.
  - Telex của Apple: ở trình soạn thảo Cursor ra nguyên chuỗi phím ở 5 và 20 ms (hiện tượng còn mở, nên không có đối chứng ở đây); ở ô nhập Agents 5 ms ra chữ của Apple ("Ciều", "mêting").
  - Dọn: cửa sổ thử đã đóng (Cursor còn cửa sổ "Cursor Agents" như trước, VS Code còn cửa sổ của người dùng), nguồn trả về Dấu, không còn khoá `defaults` có chữ `Dau`, đã cài lại bộ gõ bản Release.
- 10/11/2026 — M6: vì sao đối chứng Telex của Apple ra nguyên chuỗi phím (người dùng cho chạy; máy B; Chrome, trang thử rảnh, chuỗi std; log `build/load/apple-20261110-101503/`, `build/load/apple2-20261110-102010/`, không commit) — phiên chính.
  - Giả thuyết: H1 phím quá dồn làm Apple bỏ biến đổi; H2 script gõ quá sớm sau khi chọn nguồn (nghỉ 0,3 s); H3 nguồn bị đổi đi sau lúc script kiểm (máy bật "Automatically switch to a document's input source").
  - Lượt 10:15 (7 ô liền nhau): 5 ms gõ ngay, 5 ms chờ 2 s sau khi chọn nguồn, 100 ms gõ ngay, rồi lặp 5 ms gõ ngay và chờ 2 s. Chỉ ô đầu ra chữ tiếng Việt; 6 ô sau ra nguyên chuỗi phím, kể cả ô 100 ms và các ô chờ 2 s. H1, H2 bị loại.
  - Lượt 10:20 (4 ô Apple rồi 1 ô Dấu, 30 ms): `typing/run.sh` nay đọc nguồn ngay sau phím cuối và báo khi khác nguồn đã chọn; không ô nào báo. Ảnh chụp màn hình giữa lúc gõ: thanh menu hiện biểu tượng Telex của Apple ở cả ô ra chữ tiếng Việt (ô 1) lẫn ô ra nguyên chuỗi phím (ô 2); ô Dấu hiện biểu tượng của Dấu và đúng. H3 bị loại ở mức người dùng nhìn thấy.
  - Còn lại: ở cả hai lượt chỉ ô Apple đầu tiên ra chữ tiếng Việt, và ô đó chạy sau một quãng vài phút không có ô Apple nào; các ô cách nhau vài giây thì không. Chưa thử phân biệt (quãng nghỉ giữa các ô; không trả nguồn về Dấu giữa các ô). Nguyên nhân chưa rõ. Các ô Apple "ra nguyên chuỗi phím" trước đây không dùng làm đối chứng.
  - Dọn: tab thử đã đóng, nguồn trả về Dấu, không còn khoá `defaults` có chữ `Dau`; bộ gõ vẫn là bản Release.
- 10/11/2026 — đối chứng Telex của Apple ra nguyên chuỗi phím: nguyên nhân ở cách script chuyển nguồn, đã sửa (người dùng cho chạy; Chrome; log `build/load/apple3-…` tới `apple6-20261110-104207/`, không commit) — phiên chính.
  - `typing/run.sh --source` nay xác nhận bộ gõ ngay trong ô đang focus trước khi gõ chuỗi thử (`confirm_source`): gõ hai phím thử và một dấu cách (`aa␣`, VNI `a6␣`), đọc lại phải ra "â", rồi xoá ô; không được thì dừng với mã 4, không báo ô đó như một kết quả.
  - Đo: nguồn chọn bằng `TISSelectInputSource` từ tiến trình của script thì macOS báo nguồn hiện tại và thanh menu đều là Telex của Apple, nhưng phím thử ra "aa" ở 12/12 lần (4 ô × 3 lần, kể cả khi chọn lại bằng API). Sau khi nhấn phím tắt "Select next source in Input menu" của macOS (đọc từ cài đặt người dùng, ở máy này ⌃⌥Space) tới khi macOS báo đúng nguồn (`cycle_to_source`): 2/2 ô xác nhận ngay lần thử đầu và ra đúng "tiếng Việt có dấu".
  - Hai lần sửa phím thử trong lúc làm: gửi hai phím trong một lệnh (cách nhau khoảng 1 ms) là điều kiện đang đo, nên gửi từng phím; bộ gõ của Apple giữ chữ ở trạng thái soạn dở (gạch chân) tới hết từ và ⌘A ⌘C không chép chữ đó, nên phím thử phải có dấu cách.
  - Kết luận: các ô Apple "ra nguyên chuỗi phím" từ 09/11 tới nay là đo hỏng (ô gõ không dùng bộ gõ của Apple), không nói gì về Telex của Apple. Chưa rõ vì sao ở các loạt trước ô Apple đầu tiên vẫn ra chữ tiếng Việt.
  - Chưa làm: đo lại các ô đối chứng Apple đã hỏng (trình soạn thảo Cursor, VS Code, Chrome và Firefox phím dồn). Không có `--confirm` thì Dấu vẫn được chọn bằng API (Dấu tự nhận lần chuyển đó, `docs/ARCHITECTURE.md` mục "Đổi nguồn nhập liệu không qua `activateServer`"); lượt VS Code 08:48 mà vài phím đầu không tới bộ gõ có thể cùng nguyên nhân, chưa thử.
  - Dọn: tab thử đã đóng, nguồn trả về Dấu, không còn khoá `defaults` có chữ `Dau`; bộ gõ vẫn là bản Release.
- 10/11/2026 — M6: đối chứng Telex của Apple ở trình soạn thảo Cursor, đo lại bằng cách chuyển nguồn đã sửa (người dùng cho chạy; 10:45–10:47; chuỗi std; log `build/load/apple-cursor-20261110-104516/`, không commit) — phiên chính. Bộ gõ được xác nhận trong ô gõ ở cả hai ô. 5 ms 1/1 và 20 ms 1/1: mọi từ tiếng Việt đúng, chỉ khác Dấu ở "mêting" (Apple không khôi phục từ tiếng Anh). Cùng chỗ, cùng nhịp, Dấu thay tại chỗ sai 5/5 lượt ở 5 ms và 2/2 ở 20 ms (các mục 09:46 và 10:04): lỗi ở trình soạn thảo Cursor là của riêng Dấu. Một ô 5 ms trước đó dừng trước khi gõ (cửa sổ soạn thảo chưa lên trước kịp), không tính. Dọn: cửa sổ thử đã đóng, nguồn trả về Dấu.
- 10/11/2026 — M6: Dấu và Telex của Apple ở trình soạn thảo Cursor, đo cùng một cách (người dùng cho chạy; 11:12–11:14; chuỗi std; Dấu bản Release có bản sửa dc7208c; log `build/load/fair-20261110-111203/`, không commit) — phiên chính.
  - Cách đo: `typing/run.sh` có `--confirm` cho Dấu. Cả Dấu lẫn nguồn `--source` được chuyển bằng phím tắt chuyển nguồn của macOS rồi xác nhận trong ô gõ bằng từ thử "ân " (Telex `aan␣`); cả bốn ô xác nhận ngay lần thử đầu. Script nay đưa cửa sổ soạn thảo của Cursor lên trước bằng AXRaise: Cursor mở cửa sổ tệp trong 1 giây nhưng vẫn để cửa sổ "Cursor Agents" giữ focus (quan sát từng giây).
  - Cursor có hai kiểu cửa sổ (đọc từ menu): cửa sổ Agents (File › New Agent, Open IDE…; chỗ gõ là ô nhập của agent) và cửa sổ IDE (menu đủ của VS Code, File › New Text File, Switch to Agents Window; chỗ gõ là trình soạn thảo).
  - Kết quả: Dấu 5 ms sai 2/2, 20 ms sai 1/1, cả ba lượt đều có "uongs" và "tuanf"; một lượt 5 ms có thêm "êhieuf" (từ đầu) và "daay". Telex của Apple 5 ms đúng 1/1 (chỉ khác ở "mêting"). Cùng cách chuyển nguồn và cùng bước xác nhận, lỗi ở trình soạn thảo Cursor là của Dấu.
  - Ba phím thử sai trong lúc dựng bước xác nhận, đều do phím thử chứ không do bộ gõ: gửi dồn hai phím; đọc lại khi chữ của Apple còn soạn dở; và `aa␣` với Dấu ra "aa " vì Dấu trả một từ không phải tiếng Việt về phím gốc khi hết từ (D4 (Từ nước ngoài); `SpellingTests` có ca này). Các ô Dấu bị dừng vì phím thử `aa␣` (10:51–11:10) không nói gì về Dấu.
  - Dọn: cửa sổ thử đã đóng, nguồn trả về Dấu, không còn khoá `defaults` có chữ `Dau`; bộ gõ là bản Release.
- 10/11/2026 — M6: sửa lỗi nhận nhầm "app chậm" ở app tính vị trí theo từ (trình soạn thảo Cursor) — imk-dev, phiên chính. Chưa đo trên Cursor thật.
  - Cơ chế (test phát lại lượt 20 ms của 09:46 theo đúng khoảng cách phím trong log, app không chậm): mã cũ ra đúng văn bản đã đo ("uongs", "tuanf") và đúng các phím `late`, `mismatch` trong log. Khi app được chậm quá `lateLimit`, phép dựng lại của `CursorTracker.rebuild` đi qua một thao tác xoá không biết chữ bị xoá, thao tác đó khớp với mọi chữ. Theo mô hình, mã trước M6 gõ đúng lượt này: lỗi do nhánh "App trả lời chậm" tạo ra.
  - Sửa: quá `lateLimit` thì thao tác xoá phải biết chữ nó xoá. Số lời gọi mỗi phím không đổi (N3), câu chữ D11 (Kiểm tra ngữ cảnh) không đổi. Chi tiết: `docs/ARCHITECTURE.md` mục "App trả lời chậm".
  - Mô hình Cursor mới trong test (`CursorEditorTests`, `LateDocument.Origin.word`; phần theo log và phần giả định ghi trong mã). Mô phỏng 40 seed: Cursor trước sửa sai 40/40 ở 5, 10, 20 ms; sau sửa 0 ở 10 và 20 ms, vẫn 40/40 ở 5 ms (app chậm thật qua ranh giới từ; mô hình không có quãng nghỉ nên nặng hơn lượt đo). Chrome, VS Code, Firefox 0 sai trước và sau.
  - Còn lại, chưa sửa: (1) nhóm lỗi ở 5 ms khi Cursor trả vị trí của từ trước; theo mô hình mã trước M6 cũng sai ở đây, cách sửa (thay theo vị trí trong từ) cần đổi D11. (2) Mô hình dự đoán thêm hai ca nhận nhầm chưa đo trên Cursor thật: sau một từ một chữ cái có thay chữ ("ở đâu" ra "ở dâu" ở 100 ms), và "anh ddi" ra "anh di" ở 20 ms; test ghi nhận bằng `withKnownIssue`.
  - Kiểm: test IMK 145 đạt với 11 known issue (phiên chính chạy lại), check-docs đạt.
- 10/11/2026 — M6: đo bản sửa dc71b7f trên Cursor thật (người dùng cho chạy; 11:44–11:48; Dấu Debug dc71b7f; Cursor 3.29.15; mọi ô Cursor dùng `--confirm`; log `build/load/fix2-20261110-114446/`, không commit) — phiên chính.
  - Trình soạn thảo Cursor, chuỗi std: 20 ms đúng 2/2 (trước sửa sai 3/3), không còn `late` hay `mismatch`. 5 ms: 1 lượt, sai, nhưng hết "uongs" và "tuanf"; còn "êhieuf", "kôong", "ca", "èttlix" (nhóm Cursor trả vị trí của từ trước). Một ô 5 ms nữa dừng trước khi gõ (Cursor chưa chạy lúc bắt đầu, cửa sổ soạn thảo chưa lên trước trong 20 s), không tính.
  - Ca mô hình dự đoán sau từ một chữ cái có thay chữ là thật, ở cả nhịp người gõ: 100 ms, `owr ddaau, uwf cos. anh ddi ` ra "ở dâu, ừ co. anh đi"; 20 ms, `anh ddi owr ddaau ` ra "anh đi ở dâu". "anh ddi" ra đúng ở cả hai nhịp, tức ca dự đoán thứ hai của mô hình không xảy ra ở lượt này. Giao lại imk-dev sửa ca "ở đâu".
  - Hồi quy: Chrome trang bận (chuỗi edit, 100 ± 30 ms) đúng 1/1, VS Code 5 ms đúng 1/1.
  - Dọn: cửa sổ thử đã đóng, Cursor còn cửa sổ "Cursor Agents" (script mở Cursor vì nó chưa chạy), nguồn trả về Dấu, không còn khoá `defaults` có chữ `Dau`, đã cài lại bộ gõ bản Release (dc71b7f).
- 10/11/2026 — M6: từ đứng sau một từ một chữ cái ở app tính vị trí theo từ ("ở đâu" ra "ở dâu") — imk-dev, phiên chính. Chưa đo trên Cursor thật.
  - Test gõ đúng chuỗi của ô 100 ms đã đo (mục 11:44): đỏ trước khi sửa, ra đúng văn bản đã đo và đúng `kind`, `sel`, `known` từng phím trong log.
  - Sửa (`CursorTracker`): trong `lateLimit`, chữ dựng lại phải trùng chữ Dấu đã gõ ở phần hai bên cùng có; ở nhánh thiếu vài đơn vị, đơn vị thiếu phải đứng sau ít nhất một đơn vị đã so. Hai phép chứng minh bị từ chối thì phím thay ở vị trí app trả. Số lời gọi mỗi phím không đổi. Chi tiết: `docs/ARCHITECTURE.md` mục "App trả lời chậm".
  - Kiểm: test IMK 147 đạt với 9 known issue (phiên chính chạy lại); bảng mô phỏng Chrome, VS Code, Firefox, Cursor không đổi; check-docs đạt.
- 10/11/2026 — tham chiếu: Telex của Apple với chữ cái đứng một mình (người dùng yêu cầu; Chrome, 100 ms, bộ gõ được xác nhận trong ô gõ; `build/load/apple-letters-20261110-115357/`, không commit) — phiên chính. Phím `aw, aa, dd, ee. AW, AA, DD. Aa, Aw, Dd. aas, aws. aaa, ddd, AAA, DDD. DD/c pin AA ` ra "ă, â, đ, ê. Ă, Â, Đ. Â, Ă, Đ. ấ, ắ. aa, dd, AA, DD. Đ/c pin Â ". Apple luôn giữ chữ cái đứng một mình, hoa hay thường, không có ngoại lệ cho chữ viết tắt; gõ đúp phím thì ra chữ gốc. Dấu hiện trả `aw`, `aa`, `dd`, `aas`, `aws` về phím gốc khi hết từ (D31 (Âm tiết tiếng Việt hợp lệ), D4 (Từ nước ngoài)). Đề xuất sửa D31 đang chờ người dùng chốt.
- 10/11/2026 — D31 (Âm tiết tiếng Việt hợp lệ): chữ ă, â (mọi dấu thanh) và đ đứng một mình được giữ khi kết thúc từ, hoa hay thường (người dùng duyệt, theo tham chiếu Telex của Apple ở mục trên) — engine-dev, phiên chính. `DECISIONS.md`, `docs/history/DECISIONS-LOG.md`, `superseded.txt`, ghi chú trên canvas (phiên bản 146). Engine: `Spelling.check` ở chế độ kết thúc từ; test viết trước và đỏ ở đúng các ca mới. Kiểm tra chéo với D26, D20, D21, D30, D32, D33, VNI, Telex đơn giản, chữ hoa: không có đầu vào nào hai tính năng cho kết quả trái nhau; hệ quả với D20 ghi ở D31. Bộ ca ngoài không đổi số nào. Kiểm (phiên chính chạy lại): test engine 110 đạt, test IMK 147 đạt với 9 known issue, check-docs đạt. Chưa gõ thử trong app thật.
- 10/11/2026 — `typing/run.sh`: bỏ bước gõ từ thử để xác nhận bộ gõ (nguyên nhân đã rõ: chọn nguồn bằng API từ script không làm ô gõ đổi bộ gõ; chuyển bằng phím tắt hệ thống thì có, 6/6 ô xác nhận ngay lần đầu), vì nó kéo dài mỗi ô — phiên chính. Còn lại: nguồn `--source` được chuyển bằng phím tắt hệ thống khi ô gõ đã có focus (`switch_in_field`, chờ 0,5 s mỗi lần nhấn thay cho 0,8 s); `--confirm` đổi tên thành `--system-switch` (chuyển Dấu cùng cách, không gõ thử); ô `--source` ra nguyên chuỗi phím thì báo "ô không hợp lệ", mã thoát 4. Chưa chạy thật sau khi đổi.
- 10/11/2026 — M6: đo bản sửa ae2625d, luật chữ cái đứng một mình và script đã rút gọn (người dùng cho chạy; 12:42–12:45; Dấu Debug 1c6326a; các ô Cursor dùng `--system-switch`, không còn bước gõ thử; log `build/load/fix3-20261110-124244/`, không commit) — phiên chính.
  - Trình soạn thảo Cursor: 100 ms, `owr ddaau, uwf cos. anh ddi ` ra đúng "ở đâu, ừ có. anh đi" (trước sửa: "ở dâu, ừ co"); 20 ms chuỗi std đúng 1/1.
  - Còn sai: 20 ms, `anh ddi owr ddaau ` ra "anh di ở đâu" (`late` 1 lần ở "dd"). Đây là ca mô hình đã dự đoán (loạt phím dồn từ vị trí neo ở đầu chữ; ý "Ở đầu văn bản" của D11 (Kiểm tra ngữ cảnh) áp nhầm vì ở Cursor từ nào cũng bắt đầu từ 0). Lượt 11:44 không gặp vì bước gõ thử khi đó làm Dấu chưa có vị trí theo dõi ở phím đầu. Giao imk-dev.
  - Chữ cái đứng một mình trong app thật (Chrome, 100 ms): `aw, aa, dd, ee. AW, AA, DD. aas, aws. aaa, ddd. DD/c traw ` ra "ă, â, đ, ê. Ă, Â, Đ. ấ, ắ. aa, dd. Đ/c traw", đúng như engine.
  - Hồi quy: Chrome trang bận (chuỗi edit) đúng 1/1, VS Code 5 ms đúng 1/1.
  - Script: chuyển nguồn bằng phím tắt với 0,5 s mỗi lần nhấn chạy đúng ở cả ba ô Cursor.
  - Dọn: cửa sổ thử đã đóng, nguồn trả về Dấu, không còn khoá `defaults` có chữ `Dau`, đã cài bộ gõ bản Release 1c6326a. Cursor: trước lượt đo có cửa sổ "codefast" và "Cursor Agents"; sau lượt đo cửa sổ "codefast" còn nhưng không ở màn hình đang xem, không thấy cửa sổ "Cursor Agents"; chưa rõ có phải do script.
- 10/11/2026 — `typing/run.sh`: nguồn cần gõ (Dấu hay `--source`) đang là nguồn hiện tại thì không chuyển gì; khác thì chuyển bằng phím tắt chuyển nguồn của hệ thống tới khi macOS báo đúng nguồn, và trả lại nguồn cũ cùng cách khi xong. Script không còn chọn nguồn bằng API trên đường này (trừ ký hiệu ⇄, là ca thử cố ý, và khi không đọc được phím tắt). Bỏ `--system-switch`. Chưa chạy thật sau khi đổi — phiên chính.
- 10/11/2026 — M6: ca "anh ddi" ra "anh di" ở trình soạn thảo Cursor (20 ms, tài liệu mới): chưa sửa, vì không phân biệt được — imk-dev, phiên chính.
  - Test `sameAnswerAsLateNewDocument`: cùng phím, cùng nhịp, ở phím "d" thứ hai Cursor đúng giờ và một tài liệu mới của app tính vị trí tuyệt đối chưa áp phím nào cho cùng `selectedRange` (1), cùng chữ đọc được ("d"), cùng `known` (5); vùng thay đúng thì khác nhau (0,1 và 4,1). Không có một `insertText` nào đúng cho cả hai. Hai ca chỉ trùng khi cả đoạn từ lúc neo vị trí (đầu tài liệu) được gõ dồn dưới 50 ms mỗi phím và phím thay chữ là phím thứ hai của một từ không phải từ đầu.
  - Đã thử và loại: chỉ áp ý "Ở đầu văn bản" của D11 (Kiểm tra ngữ cảnh) cho từ đầu tiên thì Cursor đúng nhưng mô phỏng VS Code sai 5/40 và Firefox 3/40 ở 5 ms khi app chưa sẵn sàng 80 ms (trước đó 0).
  - Test phát lại lượt đo 12:42 ghi nhận hiện trạng (`withKnownIssue`), khớp `kind`, `sel`, `known`, vùng thay và văn bản của log. Test IMK 149 đạt với 9 known issue (phiên chính chạy lại). Mã sản phẩm không đổi.
  - Phương án còn mở, chờ người dùng: giữ như hiện nay; đọc cả chữ sau con trỏ trong cùng lần đọc (cần đo trên VS Code và Cursor, đụng câu chữ N3); nhận ra app tính vị trí theo từ bằng hành vi (cần sửa D11, sửa được cả nhóm lỗi ở 5 ms).
