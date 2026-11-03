# Kiểm tra giao diện

Danh sách phải chạy hết trước khi báo xong bất kỳ thay đổi giao diện nào của app Dấu. Mỗi mục là một lỗi người dùng đã gặp, kèm cách kiểm và điều kiện đạt. **File này không ghi số.** Mọi số đạt nằm ở `scripts/selftest/settings-window/Reference.swift` (kèm nguồn của từng số); số đo System Settings gốc ở `docs/research/SYSTEM-SETTINGS-REFERENCE.md` (D9).

## Lệnh

1. Build Debug:
   `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project Dau.xcodeproj -scheme Dau -configuration Debug -destination 'generic/platform=macOS' -derivedDataPath build/DerivedData.noindex build`
2. Kiểm cửa sổ (`scripts/selftest/settings-window/run.sh <thư-mục-ra>`). Cần quyền Trợ năng cho Terminal; không đổi giao diện hay cài đặt hệ thống nào.
   - **Chụp bằng `--capture-*`.** Chép bản Debug và ký lại không sandbox để được ghi ảnh. Chạy `Dau --capture-window` với mọi tổ hợp: thanh cuộn {overlay `WhenScrolling`, `Always`, `Automatic`} × cuộn {`--scroll 0`, `--scroll 60`}, cửa sổ cỡ mặc định. Mỗi lần chụp 4 mục × {sáng, tối}. Thêm một lượt ở độ rộng tối đa (`--width`) vào `wide/`.
   - Ảnh lấy từ window server nên có material, vibrancy và hiệu ứng mép cuộn. Cửa sổ chụp hiện giữa màn hình chính vài giây mỗi lần chạy (`centeredFrame`); đừng bấm vào nó lúc chạy.
   - Kiểm (a)–(e), (h) bên dưới. Ghi `matrix-grid.png` (mỗi hàng một tổ hợp).
   - Chụp thêm cửa sổ onboarding (`Dau --capture-onboarding <thư-mục>`, dịch vụ giả: OpenKey đang chạy, Dấu đã cài chưa bật): bước 1, 2, 2 khi macOS vẫn để tắt (`2-not-enabled`, kèm nhắc nguồn tiếng Việt khác), 2 khi macOS chưa liệt kê Dấu (`2-logout`), 2 sau "Bật Dấu", 3 × {sáng, tối} vào `onboarding/`, và một lượt `--shortcut none` vào `onboarding-no-shortcut/`; kèm `onboarding-<bước>-accessibility.txt` (cây trợ năng đọc qua AX API). Kiểm (f).
   - Chụp alert gỡ cài đặt (`Dau --capture-uninstall <thư-mục>`: dựng alert giữa màn hình chính, không gỡ gì) vào `uninstall/`: `uninstall-confirm-*`, `uninstall-done-*` × {sáng, tối}, nền alert đặt trên màu nền cửa sổ (kính của alert cho thấy những gì nằm sau nó). Kiểm (g): đủ 4 ảnh, alert không bị cắt.
   - **Cửa sổ thật** (`ax-check.swift`, kiểm (r)). Mở chính bản Debug như người dùng mở (`open -n Dau.app --args --settings-window`: cờ này chỉ giữ onboarding đóng và không đụng bộ gõ đã cài; không chạy mã chụp nào trong app). Đọc khung phần tử bằng Accessibility API từ tiến trình ngoài, trên **từng màn hình** (mỗi hệ số điểm ảnh một lượt: Retina 2x và màn 1x), cửa sổ cỡ mặc định; chọn từng mục qua trợ năng của sidebar (không bấm chuột), chụp `screencapture -l` vào `real/<mục>-<2x|1x>.png`. Rồi thử giới hạn kích thước cửa sổ và đặt lại cỡ mặc định. Lượt thứ hai với `--not-enabled` (banner "Dấu chưa được bật") vào `real-banner/`. Bảng đầy đủ: `real.txt`, `real-banner.txt`.
   - **Tìm ở sidebar** (kiểm (r), trang `sidebar-search`): trong lượt không banner, trên từng màn hình, đặt ô tìm sidebar thành chuỗi không khớp qua trợ năng, đo, chụp `real/sidebar-search-empty-<2x|1x>.png`, rồi xoá.
   - **Sheet thêm quy tắc** (nút "+" trang Ứng dụng, kiểm (s)). Trong lượt không banner, trên từng màn hình: chọn mục Ứng dụng qua trợ năng, AXPress nút "+" của thanh công cụ (không bấm chuột), đợi danh sách ứng dụng nạp, đo sheet so với sheet của System Settings, chụp `real/apps-add-sheet-<2x|1x>.png` (chưa chọn) `real/apps-add-sheet-bottom-<2x|1x>.png` (danh sách cuộn tới cuối) và `real/apps-add-sheet-selected-<2x|1x>.png` (chọn hàng đầu qua trợ năng), thử ô tìm (đặt giá trị qua trợ năng rồi xoá; sau khi chọn hàng, đặt chuỗi không khớp để kiểm "Thêm" tắt), rồi bấm "Huỷ" qua trợ năng (không thêm quy tắc nào). Lượt thứ ba mở app với `--appearance light|dark` (chỉ bản Debug, đặt giao diện của riêng app, không đổi giao diện hệ thống; `-AppleInterfaceStyle` truyền như đối số không đổi được giao diện cửa sổ, đo 02/11/2026) ở giao diện hệ thống đang không dùng, chỉ kiểm sheet, ảnh vào `real-sheet-light/` hoặc `real-sheet-dark/`, bảng `real-sheet-<giao diện>.txt`.
   - Bài học 02/11/2026: một `layoutProbe` đặt ngoài `listRowInsets` làm ảnh chụp ngoài màn hình lệch so với cửa sổ thật mà các kiểm (a)–(e) vẫn đạt. Vì vậy số đo đối chiếu System Settings lấy từ cửa sổ thật (r); `layoutProbe` giờ luôn cùng một cấu trúc view dù có probe hay không, và chỉ đặt trên nội dung hàng hoặc cả control, không bọc ngoài modifier của hàng list.
   - Thoát với mã 0 chỉ khi mọi kiểm tra đạt.
3. So với mockup (chỉ để đối chiếu nội dung, D9):
   `swift run --package-path scripts/snapshot-settings SnapshotSettings <ra> <thư-mục-artboard> [<thư-mục-chụp-thật>]`
   - Ghi ảnh ghép mockup | app (`*-compare-*.png`, sidebar 4×, segmented 3×, header Ứng dụng 3×) và bảng khung phần tử. Sheet thêm quy tắc: `apps-add-sheet-{light,dark}.png` và `apps-add-compare-light.png` dựng bằng `.sheet` thật trên cửa sổ ngoài màn hình; ảnh vẽ lại bằng `cacheDisplay` nên không có thanh nút (nằm trên thanh công cụ của sheet) và control có thể khác cửa sổ thật: chỉ dùng để xem nội dung, số đo lấy từ (s). Bố cục và số đo theo System Settings, không theo mockup: bảng này không có tiêu chí đạt.
   - Thêm đối số thứ tư `<thư-mục-chụp-onboarding>` (vd. `<ra-run.sh>/onboarding`): ghi `onboarding-<bước>-compare-{light,dark}.png` so với artboard OnboardingConflict, OnboardingEnable, Onboarding (không có artboard tối: mockup sáng cạnh app tối).
   - Kiểm khung 4 mục trong cửa sổ dựng tay: in "Layout: identical in all sections", thoát 1 nếu lệch.
4. Test: `swift test --package-path scripts/snapshot-settings` (ví dụ do engine tính, phím tắt, ô tìm sidebar, ô tìm và chọn của sheet thêm quy tắc). Lệnh 3 và 4 cần `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` (Command Line Tools không có plugin macro SwiftUI).

Toạ độ tính bằng pt, gốc ở góc trên-trái cửa sổ. "Như System Settings" nghĩa là khớp số trong `Reference.swift` trong sai số của nó; "mặc định hệ thống" là chỗ không có số để so.

## Danh sách

| # | Lỗi đã gặp | Cách kiểm | Đạt khi |
|---|---|---|---|
| 1 | Nội dung co thành cột hẹp, căn giữa (`Form(.grouped)` giới hạn độ rộng thẻ và căn giữa khi cột chi tiết quá rộng) | run.sh (e), (h), (r) | Cửa sổ không rộng quá mức làm Form giới hạn thẻ; hàng đầu và thẻ lấp cột chi tiết trừ lề của Form, cả ở độ rộng tối đa; kéo cửa sổ dừng đúng ở giới hạn cỡ |
| 2 | Nhảy bố cục khi đổi mục (toolbar đổi cao, tiêu đề đổi chỗ) | run.sh (a), (r); snapshot-settings "Layout" | Vị trí `content`, `title`, `close` và x của `firstRow` giống hệt ở 4 mục. Độ rộng chỉ được hụt đúng bằng thanh cuộn legacy của hệ thống, và chỉ ở mục đang hiện thanh cuộn. Toolbar và tiêu đề như nhau ở mọi mục, cả hai màn hình |
| 3 | Màu không theo HIG (tự pha nền, chữ cố định) | `grep -nE "Color\(red\|#[0-9a-fA-F]{6}\|\.opacity\(\|gradient\|blended" Apps/Dau/Sources` | Không có kết quả (D9: chỉ màu hệ thống, kể cả ô icon sidebar) |
| 4 | Mất đèn giao thông | run.sh (e), (r) | Nút đóng có mặt ở mọi ảnh, vị trí như System Settings |
| 5 | Icon sidebar sai (glyph, màu, cỡ, sát chữ) | run.sh (r); `sidebar-compare-*.png` | Ô tìm, hàng, vệt chọn, ô icon và chữ như System Settings. Màu ô `systemBlue` / `systemPurple` / `systemOrange` / `systemGreen`, glyph nét trắng theo SVG mockup (nội dung) |
| 6 | Segmented "Kiểu gõ" hẹp, căn giữa | run.sh (r); khung `segmented` (frames.json) | Segmented không nhãn trải hết hàng như System Settings (macOS 26+, `buttonSizing(.flexible)`); segmented, nút, pop-up, công tắc đúng cỡ hệ thống |
| 7 | Ô tìm và "+" dính nhau thành một khối glass | run.sh (e), (r); `apps-header-compare-*.png` | Control hệ thống: nút "+" rồi ô tìm của `searchable` ở mép phải thanh công cụ (thứ tự do hệ thống đặt), tách khỏi tiêu đề, không tràn mép phải |
| 8 | Nút "+" méo (bầu dục) | run.sh (e) | Khung `headerAdd` rộng bằng cao (nút thanh công cụ của hệ thống) |
| 9 | Header không che nội dung khi cuộn | run.sh (d), cuộn | Vùng thanh công cụ bên phải tiêu đề gần như không đổi so với ảnh chưa cuộn (mép cuộn kiểu cứng của hệ thống, `scrollEdgeEffectStyle(.hard)`) |
| 10 | Thiếu thanh cuộn (nằm ngoài cửa sổ) | run.sh (b), (d); khung `scroller` | Mục có cuộn: `scroller` nằm trong lề phải của Form, trong cửa sổ, dưới thanh công cụ |
| 11 | Dải hở ở mép phải (cột thanh cuộn chừa sẵn) | run.sh (b), (c) | Màu nền trang ở mép phải trùng màu lề trái của Form; thanh công cụ cùng màu tới mép phải; lề phải của Form không có điểm khác màu nền, trừ thanh cuộn |
| 12 | Onboarding lệch mockup | run.sh (f) | Tên app, tiêu đề, thẻ, cụm nút ở cùng chỗ ở mọi bước, cả hai chế độ |
| 13 | Ảnh chụp ngoài màn hình khác cửa sổ thật (lệch mà vẫn đạt) | run.sh (r) | Trên cả màn Retina và 1x, mọi số trong `real.txt` đạt: cửa sổ, thanh công cụ, tiêu đề trang, sidebar, mục đầu trang (lề trên mặc định của SwiftUI, giữ có chủ ý), tiêu đề nhóm và khoảng cách thẻ, control như mục 6. Hàng "Nâng cao" là nút trơn kèm chevron (D9), không so chiều cao. `real-banner.txt`: banner là thẻ đầu |
| 14 | Sheet thêm quy tắc lệch System Settings, hoặc danh sách không cuộn được, hoặc tiêu đề và ô tìm không cân | run.sh (s): `real.txt` và `real-sheet-*.txt`, trang `add-sheet` | Trên cả hai màn hình, sheet như sheet của System Settings (Màn hình › Nâng cao…): độ rộng, một hàng đầu có tiêu đề bên trái và ô tìm hệ thống bên phải, giữa nhau theo chiều dọc, thẻ danh sách rồi thẻ segmented "Khi đang gõ" cách nhau như hai thẻ Form. Danh sách cuộn được trong thẻ (lăn chuột thật, rồi kéo thanh cuộn tới cuối: ứng dụng cuối hiện trọn trong thẻ, "Khi đang gõ" vẫn trong sheet), thanh nút "Chọn ứng dụng khác…" / "Huỷ" / "Thêm". "Thêm" tắt khi chưa chọn, bật khi chọn; ô tìm lọc được danh sách; chọn một hàng rồi gõ tìm làm ẩn hàng đó thì "Thêm" tắt, xoá ô tìm vẫn tắt (`AddAppRuleSheetTests`); "Huỷ" đóng sheet |
| 15 | Tìm ở sidebar không khớp mục nào: sidebar trống, trang cũ vẫn hiện như chưa tìm | run.sh (r), trang `sidebar-search`; `swift test` "Sidebar search" | Trên cả hai màn hình: ô tìm nhận tiêu điểm rồi đặt chuỗi không khớp (không có tiêu điểm thì SwiftUI không đọc giá trị) thì sidebar không còn hàng và có trạng thái trống hệ thống nêu chuỗi tìm (`ContentUnavailableView.search`), thanh công cụ không đổi; xoá ô tìm thì đủ 4 hàng. Mỗi chữ nhìn thấy trong mục tìm ra mục đó, không phân biệt hoa thường, dấu, "đ"/"d"; ảnh `real/sidebar-search-empty-<2x\|1x>.png` |

## Quy tắc thanh cuộn (chốt 29/10/2026)

Hệ thống quyết định cách hiện thanh cuộn.

- **Overlay:** không chiếm chỗ.
- **Legacy** (`Always`, hoặc `Automatic` khi có chuột): chỉ mục thực sự cần cuộn mới có rãnh thanh cuộn ở mép phải, và mục đó hẹp hơn đúng độ rộng thanh cuộn của hệ thống. Vị trí x, y của mọi thứ giữ nguyên.
- Không chừa sẵn khoảng trống cho thanh cuộn: cách đó sinh lỗi 11.
