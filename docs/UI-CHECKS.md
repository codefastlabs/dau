# Kiểm tra giao diện

Danh sách phải chạy hết trước khi báo xong bất kỳ thay đổi giao diện nào của app Dấu. Mỗi mục là một lỗi người dùng đã gặp ở M4, kèm cách kiểm và chỉ số đạt.

## Lệnh

1. Build Debug:
   `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project Dau.xcodeproj -scheme Dau -configuration Debug -destination 'generic/platform=macOS' -derivedDataPath build/DerivedData build`
2. Kiểm cửa sổ (`scripts/check-settings-window/run.sh <thư-mục-ra>`). Cần quyền Trợ năng cho Terminal; không đổi giao diện hay cài đặt hệ thống nào.
   - **Chụp ngoài màn hình.** Chép bản Debug và ký lại không sandbox để được ghi ảnh. Chạy `Dau --capture-window` với mọi tổ hợp: thanh cuộn {overlay `WhenScrolling`, `Always`, `Automatic`} × cuộn {0, 60 pt}, cửa sổ 740×560. Mỗi lần chụp 4 mục × {sáng, tối}. Thêm một lượt ở độ rộng tối đa (`--width 976`) vào `wide/`.
   - Ảnh lấy từ window server nên có material, vibrancy và hiệu ứng mép cuộn. Cửa sổ được đưa ra ngoài màn hình nhưng vẫn tồn tại vài giây mỗi lần chạy.
   - Kiểm (a)–(e), (h) bên dưới. Ghi `matrix-grid.png` (mỗi hàng một tổ hợp).
   - Chụp thêm cửa sổ onboarding (`Dau --capture-onboarding <thư-mục>`, dịch vụ giả: OpenKey đang chạy, Dấu đã cài chưa bật): bước 1, 2, 2 khi macOS vẫn để tắt (`2-not-enabled`, kèm nhắc nguồn tiếng Việt khác), 2 khi macOS chưa liệt kê Dấu (`2-logout`), 2 sau "Bật Dấu", 3 × {sáng, tối} vào `onboarding/`, và một lượt `--shortcut none` vào `onboarding-no-shortcut/`; kèm `onboarding-<bước>-accessibility.txt` (cây trợ năng đọc qua AX API). Kiểm (f).
   - Chụp alert gỡ cài đặt (`Dau --capture-uninstall <thư-mục>`: dựng alert ngoài màn hình, không gỡ gì) vào `uninstall/`: `uninstall-confirm-*`, `uninstall-done-*` × {sáng, tối}, nền alert đặt trên màu nền cửa sổ (kính của alert trong suốt khi ở ngoài màn hình). Kiểm (g): đủ 4 ảnh, alert ≥ 200×120.
   - **Cửa sổ thật** (`ax-check.swift`, kiểm (r)). Mở chính bản Debug như người dùng mở (`open -n Dau.app --args --settings-window`: cờ này chỉ giữ onboarding đóng và không đụng bộ gõ đã cài; không chạy mã chụp nào trong app). Đọc khung phần tử bằng Accessibility API từ tiến trình ngoài, trên **từng màn hình** (mỗi hệ số điểm ảnh một lượt: Retina 2x và màn 1x), cửa sổ 740×560; chọn từng mục qua trợ năng của sidebar (không bấm chuột), chụp `screencapture -l` vào `real/<mục>-<2x|1x>.png`. Rồi thử giới hạn kích thước cửa sổ và đặt lại 740×560. Lượt thứ hai với `--not-enabled` (banner "Dấu chưa được bật") vào `real-banner/`. Bảng đầy đủ: `real.txt`, `real-banner.txt`.
   - Bài học 02/11/2026: một `layoutProbe` đặt ngoài `listRowInsets` làm ảnh chụp ngoài màn hình lệch 8 pt so với cửa sổ thật mà các kiểm (a)–(e) vẫn đạt. Vì vậy số đo đối chiếu System Settings lấy từ cửa sổ thật (r); `layoutProbe` giờ luôn cùng một cấu trúc view dù có probe hay không, và chỉ đặt trên nội dung hàng hoặc cả control, không bọc ngoài modifier của hàng list.
   - Thoát với mã 0 chỉ khi mọi kiểm tra đạt.
3. So với mockup (chỉ để đối chiếu nội dung, D9):
   `swift run --package-path scripts/snapshot-settings SnapshotSettings <ra> <thư-mục-artboard> [<thư-mục-chụp-thật>]`
   - Ghi ảnh ghép mockup | app (`*-compare-*.png`, sidebar 4×, segmented 3×, header Ứng dụng 3×) và bảng khung phần tử. Bố cục và số đo theo System Settings, không theo mockup: bảng này không có tiêu chí đạt.
   - Thêm đối số thứ tư `<thư-mục-chụp-onboarding>` (vd. `<ra-run.sh>/onboarding`): ghi `onboarding-<bước>-compare-{light,dark}.png` so với artboard OnboardingConflict, OnboardingEnable, Onboarding (không có artboard tối: mockup sáng cạnh app tối).
   - Kiểm khung 4 mục trong cửa sổ dựng tay: in "Layout: identical in all sections", thoát 1 nếu lệch.
4. Test: `swift test --package-path scripts/snapshot-settings` (ví dụ do engine tính, phím tắt, ô tìm sidebar). Lệnh 3 và 4 cần `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` (Command Line Tools không có plugin macro SwiftUI).

Toạ độ tính bằng pt, gốc ở góc trên-trái cửa sổ 740×560. Số đối chiếu: System Settings của macOS 27.2 (`docs/research/SYSTEM-SETTINGS-REFERENCE.md`, D9); "mặc định hệ thống" là chỗ không có số để so.

## Danh sách

| # | Lỗi đã gặp | Cách kiểm | Đạt khi |
|---|---|---|---|
| 1 | Nội dung co thành cột hẹp, căn giữa (`Form(.grouped)` giới hạn thẻ 704 pt và căn giữa khi cột chi tiết rộng hơn 744) | run.sh (e), (h), (r) | Cửa sổ rộng 740–976 (mặc định 740×560, cao tối thiểu 452). (e) hàng đầu `firstRow` x = cột + 30, rộng = cột − 60 (thẻ = cột − 40, lề hàng 10). (h) ở 976: cột 744, hàng đầu x 262 rộng 684; giới hạn cửa sổ đọc được: rộng tối thiểu 740, tối đa 976. (r) thẻ x 252, rộng = cột − 40; kéo cửa sổ tới 1400 thì dừng ở 976, kéo về 600×300 thì dừng ở 740×452 |
| 2 | Nhảy bố cục khi đổi mục (toolbar đổi cao, tiêu đề đổi chỗ) | run.sh (a), (r); snapshot-settings "Layout" | (a) x, y của `content`, `title`, `close` và x của `firstRow` bằng nhau ở 4 mục, lệch 0 pt. Độ rộng của `content` và `firstRow` chỉ được lệch đúng bằng độ rộng thanh cuộn legacy của hệ thống (`NSScroller.scrollerWidth`, 17 pt), và chỉ ở mục đang hiện thanh cuộn. Tọa độ y của `firstRow` không so, vì phụ thuộc mục có tiêu đề nhóm đầu trang hay không. (r) toolbar cao 52 và tiêu đề ở cùng chỗ ở mọi mục, cả hai màn hình |
| 3 | Màu không theo HIG (tự pha nền, chữ cố định) | `grep -nE "Color\(red\|#[0-9a-fA-F]{6}\|\.opacity\(\|gradient\|blended" Apps/Dau/Sources` | Không có kết quả (D9: chỉ màu hệ thống, kể cả ô icon sidebar) |
| 4 | Mất đèn giao thông | run.sh (e), (r) | (e) `close` = 19,19 14×14 ở mọi ảnh. (r) nút đóng (AX) 18,18 16×16 như System Settings |
| 5 | Icon sidebar sai (glyph, màu, cỡ, sát chữ) | run.sh (r); `sidebar-compare-*.png` | Theo System Settings: ô tìm 10,61 212×28; hàng 32 từ y 98, vệt chọn x 10 rộng 212; ô icon 20 pt từ x 19; chữ bắt đầu x 46 (đo điểm ảnh) ±1. Màu ô `systemBlue` / `systemPurple` / `systemOrange` / `systemGreen`, glyph nét trắng theo SVG mockup (nội dung) |
| 6 | Segmented "Kiểu gõ" hẹp, căn giữa | run.sh (r); khung `segmented` (frames.json) | Segmented không nhãn trải hết hàng như System Settings (Âm thanh): x = thẻ + 10, rộng = thẻ − 20 (macOS 26+, `buttonSizing(.flexible)`); mọi segmented, nút, pop-up cao 24, công tắc 36×16 |
| 7 | Ô tìm và "+" dính nhau thành một khối glass | run.sh (e), (r); `apps-header-compare-*.png` | Control hệ thống: nút "+" rồi ô tìm của `searchable` ở mép phải thanh công cụ (thứ tự do hệ thống đặt), "+" bắt đầu sau tiêu đề ≥ 8 pt, ô tìm kết thúc cách mép phải 4–24 pt, cao ≥ 24 |
| 8 | Nút "+" méo (bầu dục) | run.sh (e) | Khung `headerAdd` rộng bằng cao (nút thanh công cụ của hệ thống) |
| 9 | Header không che nội dung khi cuộn | run.sh (d), cuộn 60 pt | Vùng thanh công cụ bên phải tiêu đề (x 400 → mép phải − 24, y 6–46) khác ảnh chưa cuộn trung bình ≤ 4/255 (mép cuộn kiểu cứng của hệ thống, `scrollEdgeEffectStyle(.hard)`) |
| 10 | Thiếu thanh cuộn (nằm ngoài cửa sổ) | run.sh (b), (d); khung `scroller` | Mục có cuộn: `scroller` nằm trong lề phải 20 pt của Form (x ≥ 720), mép phải ≤ 740, y ≥ 51 |
| 11 | Dải hở ở mép phải (cột thanh cuộn chừa sẵn) | run.sh (b), (c) | (b) màu nền trang ở mép phải (hoặc sát trái thanh cuộn) trùng màu lề trái của Form, lệch ≤ 6/255; thanh công cụ cùng màu từ giữa tới mép phải. (c) lề phải 20 pt của Form không có điểm nào khác màu nền trang, trừ thanh cuộn |
| 12 | Onboarding lệch mockup | run.sh (f) | Cửa sổ 720×500; tên app x 20 y 50; tiêu đề x 266 y 40; thẻ x 266 rộng 418; cụm nút mép phải 684, mép dưới 472 — ở mọi bước, cả hai chế độ |
| 13 | Ảnh chụp ngoài màn hình khác cửa sổ thật (lệch 8 pt mà vẫn đạt) | run.sh (r) | Trên cả màn Retina và 1x, mọi số trong bảng `real.txt` khớp System Settings ±1 pt: cửa sổ 740×560; thanh công cụ 52; tiêu đề trang x 252, tâm y 26 (15 đậm); sidebar như mục 5; mục đầu trang (thẻ hoặc tiêu đề nhóm) y 72 (lề trên 20 mặc định của SwiftUI, giữ có chủ ý; System Settings 12 → 64); tiêu đề nhóm x = thẻ + 10, cách thẻ 10, thẻ trước → tiêu đề nhóm sau 30; control như mục 6. Riêng hàng "Nâng cao" là nút trơn kèm chevron (D9), không có viền nên không so chiều cao. `real-banner.txt`: banner là thẻ đầu, y 72 |

## Quy tắc thanh cuộn (chốt 29/10/2026)

Hệ thống quyết định cách hiện thanh cuộn.

- **Overlay:** không chiếm chỗ.
- **Legacy** (`Always`, hoặc `Automatic` khi có chuột): chỉ mục thực sự cần cuộn mới có rãnh thanh cuộn ở mép phải, và mục đó hẹp hơn đúng 17 pt. Vị trí x, y của mọi thứ giữ nguyên.
- Không chừa sẵn khoảng trống cho thanh cuộn: cách đó sinh lỗi 11.
