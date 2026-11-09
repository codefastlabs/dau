# Tiến độ

Nhật ký điều phối, để phiên sau (hoặc sau khi ngữ cảnh bị nén) tiếp tục đúng chỗ. Phiên chính cập nhật file này sau mỗi bước.

> Từ 02/11/2026 repo ở https://github.com/codefastlabs/dau và lịch sử đã được viết lại: các mã commit ghi trước ngày này là mã cũ, tra `docs/history/COMMIT-MAP.md` để ra mã mới.

## Trạng thái hiện tại

Đang ở giữa M5 (Onboarding, cài đặt, gỡ cài đặt) và M6 (hiệu năng dưới tải).
- M5 đóng 05/11/2026.
- M6 chưa bắt đầu; kế hoạch lập ở đầu mốc.
- Từ 05/11 làm ngoài mốc:
  - phần nền của M9 (Đa ngôn ngữ), theo D41 (Ngôn ngữ giao diện): mã xong 06/11, hàng "Ngôn ngữ" xong 08/11; nhật ký ở `docs/history/LOG-M5-M6.md`;
  - rút gọn script và test (09/11; nhật ký ở dưới).

Chờ người dùng:
- Duyệt câu chữ tiếng Anh trong `docs/L10N-REVIEW.md` (bản tạm, xoá khi đã sửa catalog).

So sánh với bộ gõ khác (`docs/research/COMPETITOR-COMPARISON.md`, nghiên cứu cho M10 (Học cách gõ)):
- Phần B, C xong 09/11.
- Phần A dừng: dữ liệu công khai không đủ độ chính xác.
- Câu hỏi của D13 (Gạch chân làm đường lui) chuyển sang bài test tải nặng của M6.

Việc còn mở:
- Các tiến trình trong thư mục cache được hệ thống bảo vệ (WebKit, bộ đệm của Shortcuts) không xoá được bộ đệm.
  - Ảnh hưởng chưa đo.
  - Gỡ cài đặt chưa xoá bộ đệm của các app (`docs/research/M5-INSTALL.md` (d)10).
- "vieetj" giữ nguyên trong thanh địa chỉ tab mới của Chrome (hồ sơ công việc). Chờ người dùng bật `DauPerfLog` (chỉ bản Debug) khi gặp lại.
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
- Máy này ("Valentino’s MacBook Pro") ký được (09/11: mọi bản build ký hợp lệ).
- Máy nhà ("Vương's MacBook Pro") dùng chứng chỉ tạo ngày 05/11.
- Bản đã cài trên máy này: bộ gõ và `/Applications/Dau.app` bản Release 24e61ec (09/11).
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
| M9 Đa ngôn ngữ | phần nền xong; còn duyệt câu chữ tiếng Anh | — |
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
  - snapshot 98 test; `run.sh` đạt trừ lỗi chập chờn "window size at launch";
  - bỏ lượt đo trên tài khoản macOS mới.
- M9: phần nền (D41) xong 06–08/11; còn duyệt câu chữ tiếng Anh.

## Ghi nhớ cho M7 (từ kiểm toán M0)
- Xem lại gợi ý "Báo lại để bản sau xử lý đúng cho ứng dụng đó" (hàng "Gặp ứng dụng gõ bị lỗi?", `UpdatesSupportView`) theo N5 (Chỉ hứa điều đã kiểm chứng) khi làm báo lỗi.
- `.gitignore` bỏ qua `Package.resolved`: ghim phiên bản Sparkle chính xác trong `project.yml`.
- Thử bỏ `temporary-exception.mach-register.global-name` của bộ gõ khi rà entitlement trước notarize (xem `docs/ARCHITECTURE.md`).
- Thêm `*.p8`, `*.pem`, `*.key`, `*.xcarchive` vào `.gitignore`.
- Đưa phép đếm cấp phát (`malloc_logger`) vào CI.

## Nhật ký
Nhật ký M0–M4 ở `docs/history/LOG-M0-M4.md` (kèm bảng số đo M1–M3), M5 ở `docs/history/LOG-M5.md`, 05–08/11 (giữa M5 và M6) ở `docs/history/LOG-M5-M6.md`.

(ngày — việc — agent — kết quả — commit)

- 09/11/2026 — rà soát các commit 08/11, sửa hai điểm. (1) Giá trị của hàng "Ngôn ngữ" lặp trong cây trợ năng: đọc AX của Dấu thật (người dùng cho chạy ngay; `install-app.sh` cài 6d772e6+, máy en-VN): giá trị là một AXStaticText "English" chứa thêm một AXStaticText "English" con; hàng phím tắt cùng kiểu thì không lặp. Bỏ `.fixedSize()` vẫn lặp, nên không phải do nó. Sửa: `Text` giá trị thành một phần tử riêng (`.accessibilityElement(children: .ignore)`, nhãn là tên ngôn ngữ), như phím tắt; cài lại, đọc AX: còn một "English". Chưa nghe bằng VoiceOver thật, chưa đọc AX ở trạng thái chờ mở lại (cùng `Text`). Ca này không có test: dựng ngoài màn hình thì SwiftUI không trả cây trợ năng. (2) `dau-version.sh` báo bộ gõ hoặc `/Applications/Dau.app` build từ commit khác HEAD, kèm lệnh cài lại; `install-app.sh` bỏ đoạn so riêng (6d772e6). Snapshot 149 test, check-docs, check-l10n đạt — phiên chính
- 09/11/2026 — đầu ra thống nhất cho mọi script (người dùng chọn: tiếng Việt, toàn bộ `scripts/`, dấu ✓ ! ✗): `scripts/lib/log.sh` (bước `==>`, chi tiết, đạt, cảnh báo và lỗi ra stderr, câu hỏi, dòng kết thúc kèm thời gian; màu chỉ khi ra terminal, `NO_COLOR` tắt), quy ước ở `scripts/README.md` mục "Đầu ra", `check-docs` chặn mã màu và `==>` ngoài `log.sh`. Ba subagent (sonnet) chuyển 20 script và hook; mã thoát 2 cho gọi sai. Dữ liệu cho máy đọc giữ nguyên (cột của `dau-version.sh`, bảng `perf-report.sh`, nhật ký bước của `step.sh`, hàng `ok`/`FAIL`/`HARNESS` của bộ kiểm cửa sổ). Hook không còn chặn `zsh -n` (chỉ kiểm cú pháp) và `step.sh --dry-run`. Đã chạy: `zsh -n` mọi file, check-docs, check-l10n, `dau-version.sh`, `clean-dau.sh` (chỉ đọc), `perf-report.sh`, `install-input-method.sh --build-only`, `probe/cleanup.sh` (chỉ đọc), `step.sh --dry-run`, `compare.sh`, hook với 6 lệnh mẫu. Chưa chạy (chiếm màn hình hoặc cài): `install-app.sh`, `app-group.sh`, `typing/run.sh`, `settings-window/run.sh`, `clean-dau.sh --yes`, `make-*-icon.sh`, `extract.sh` (mạng) — phiên chính
- 09/11/2026 — chạy thật các script còn lại sau khi đổi đầu ra (người dùng duyệt): `make-app-icon.sh`, `make-mode-icons.sh` (repo không đổi byte nào; câu tiếng Anh của công cụ Swift và `tiffutil` giờ chỉ hiện khi lỗi), `extract.sh` (TSV khớp bản commit), `install-app.sh --with-input-method`, `app-group.sh` (lần đầu trượt vì bộ gõ đã cài là Release, không ghi `event=settings-loaded`; câu lỗi nay chỉ cách chạy lại với `--install`; `--install` đạt), `typing/run.sh safari chrome vscode terminal` đạt (không dùng TextEdit), `settings-window/run.sh` đạt cả (387, 15, 2, 28; 292), 3 phút 26 giây. Sau đó cài lại bộ gõ Release, chọn lại nguồn Dấu (dừng bộ gõ làm macOS lùi về U.S.), mở lại Dấu.app. Chưa chạy: `clean-dau.sh --yes` (gỡ Dấu khỏi máy, người dùng tự chạy). Còn tiếng Anh do công cụ Swift in: dòng tổng "… checks passed (N)" của bộ kiểm cửa sổ — phiên chính
- 09/11/2026 — `typing/run.sh`: khi Terminal chưa chạy, mở Terminal ra cửa sổ khởi động rồi `do script ""` mở thêm cửa sổ thứ hai; script chỉ đóng cửa sổ thứ hai nên bỏ lại một cửa sổ (người dùng thấy). Sửa: Terminal do script mở thì gõ vào chính cửa sổ khởi động. Chạy lại cả hai đường (Terminal chưa chạy: sau thử 0 cửa sổ; Terminal đang mở 1 cửa sổ: sau thử vẫn 1), đều đạt; đã thoát Terminal (trước khi thử nó không chạy) — phiên chính
- 09/11/2026 — rà soát `scripts/` và mọi bài test (người dùng duyệt: làm theo góp ý trừ CI; mỗi bài test phải đáng với cái giá của nó; dọn mọi thứ các lần thử để lại trên máy). Kết quả cuối: cài bộ gõ và Dấu.app chép vào bản ẩn cạnh rồi đổi tên, Thùng rác bằng `/usr/bin/trash -s` (đã chạy thật); mọi script có `set -u`, `pipefail`, `zsh -n`; Xcode chọn ở `scripts/lib/xcode.sh`; bộ tự kiểm chờ theo trạng thái (`scripts/lib/wait.sh`); `scripts/README.md` chỉ còn quy ước, đầu mỗi script là mô tả duy nhất; hook chặn script dùng bảng ghi thẳng, `check.sh` báo khi script làm phiền chưa có trong bảng; `check.sh` bỏ kiểm số test và mục "Hiện trạng" (quy tắc vẫn ở CLAUDE.md), bỏ kiểm đường dẫn trong nhật ký có ngày; xoá scripts/probe (vòng thử M5 xong); bỏ `LegacyModeMemory` (chỉ cho bản build trước 30/10, chưa phát hành; `LaunchOrigin` là mã đang dùng, giữ). Bộ kiểm cửa sổ: 8 lần mở → 6, 2 phút 43 giây → 1 phút 58 giây, đạt cả; bỏ hàng "window size at launch" (so một hằng số), chuột giả của sidebar và menu View (test đơn vị đã có), lần mở `--not-enabled` và ảnh banner (thay bằng `NotEnabledBannerTests`, đỏ khi đổi chỗ banner), sheet chỉ một màn hình và các hàng hành vi. Hai lỗi chập chờn cũ: sheet vì danh sách cần 5–6 s mới đủ (bộ kiểm cũ chờ 0,6 s); cỡ cửa sổ 740×747 vì app thử bị dừng bằng `kill` nên macOS khôi phục cửa sổ ở lần mở sau của cùng bundle ID (đo: mở với `-ApplePersistenceIgnoreState YES` 560 3/3, mở thường 747 3/3; thoát thường một lần thì hết), nay `run.sh` thoát app thử bằng `NSRunningApplication.terminate`; các cỡ 740×452, 976×700 của 03–05/11 chưa đo, chỉ có thể cùng nguyên nhân. Giả thuyết đầu (Dấu.app Release đang chạy) sai và đã hoàn tác (fc47a22). Test gộp thành bảng, bỏ assert chỉ ghim câu chữ; test không còn để lại plist trong `~/Library/Preferences`. Dọn máy: các mục `local.probe.*` (người dùng xoá container), đăng ký LaunchServices trỏ tới bản build không còn, `build/probe-fixed-sidebar`. Test: engine 100, DauShared 35, snapshot 139, IMK 111 đạt; `typing/run.sh` (Safari, Chrome, VS Code, Terminal, nhánh ⇄) và `app-group.sh --install` đạt. Cài lại bộ gõ và Dấu.app Release 24e61ec, chọn lại Dấu — phiên chính
