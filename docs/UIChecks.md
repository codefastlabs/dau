# Kiểm tra giao diện

Danh sách phải chạy hết trước khi báo xong bất kỳ thay đổi giao diện nào của app Dấu. Mỗi mục là một lỗi người dùng đã gặp.

## Khi nào chạy, đạt nghĩa là gì

- Chạy sau mọi thay đổi giao diện, trước khi cho người dùng xem bản build (CLAUDE.md mục "Cách làm việc đã rút ra", ý "Giao diện").
- File này không ghi số. Mức đạt nằm ở [`scripts/selftest/settings-window/Reference.swift`](../scripts/selftest/settings-window/Reference.swift), kèm nguồn của từng số; số đo System Settings gốc ở [`docs/research/SystemSettingsReference.md`](research/SystemSettingsReference.md) (D9 (Giao diện)).
- Mỗi hàng của bảng kết quả là một trong ba:
  - `ok`: đạt;
  - `FAIL`: giao diện không hiện thứ phải hiện, hiện sai trạng thái hoặc lệch `Reference.swift`;
  - `HARNESS`: bộ kiểm không chạy được (thiếu quyền, app không mở, lời gọi Accessibility lỗi, một trạng thái cần chờ không đến: hàng `wait: …`). Không phải kết quả giao diện; sửa bộ kiểm hay máy rồi chạy lại.
- Không có kết quả bỏ qua. Đạt khi mọi hàng `ok` và mọi mục dưới đây đạt.
- Lịch sử (ngày phát hiện lỗi, bài học): [`docs/history/DocsLog.md`](history/DocsLog.md).

## Danh sách

Mỗi mục có ba dòng: lỗi đã gặp, cách kiểm, đạt khi. Tên trong "Cách kiểm" là tên hàng của bảng (`real.txt` khi không ghi bảng khác); các chữ (a)–(g) ở mục "Đọc bảng kết quả".

### 1. Nội dung co thành cột hẹp, căn giữa

- **Lỗi:** `Form(.grouped)` giới hạn độ rộng thẻ và căn giữa khi cột chi tiết quá rộng.
- **Cách kiểm:** "first card" (mỗi mục); "max window width", "min window width", "min window height"; (a) trong `always*.txt`.
- **Đạt khi:**
  - cửa sổ rộng cố định như System Settings (`Reference.windowWidth`), nên Form không bao giờ giới hạn thẻ;
  - thẻ đầu lấp cột chi tiết trừ lề của Form;
  - kéo cửa sổ dừng đúng ở giới hạn cỡ (chỉ chiều cao đổi được).

### 2. Nhảy bố cục khi đổi mục

- **Lỗi:** toolbar đổi cao, tiêu đề đổi chỗ.
- **Cách kiểm:** "toolbar height" (trang không có nút: "toolbar height (close button y)", vì thanh chỉ có khoảng trống không hiện với Trợ năng), "close button", "title text", "title x", "title center y", "first item y", "first card" (mỗi mục, so cùng một số nên giống nhau giữa các mục); (a) trong `always*.txt`.
- **Đạt khi:**
  - thanh công cụ, nút đóng, tiêu đề, mục đầu và thẻ đầu ở cùng chỗ ở mọi mục, trên mọi màn hình;
  - tiêu đề là tiêu đề hệ thống (`navigationTitle`, một chữ tĩnh trên thanh công cụ mang tên cửa sổ), không phải view tự vẽ;
  - độ rộng chỉ được hụt đúng bằng thanh cuộn Always của hệ thống, và chỉ ở mục đang hiện thanh cuộn.

### 3. Màu không theo HIG

- **Lỗi:** tự pha nền, chữ cố định.
- **Cách kiểm:** `grep -rnE 'Color\(red|#[0-9a-fA-F]{6}|\.opacity\(|gradient|blended' Apps/Dau/Sources`.
- **Đạt khi:** không có kết quả (D9: chỉ màu hệ thống, kể cả ô icon sidebar và bóng đổ).

### 4. Mất đèn giao thông

- **Lỗi:** đèn giao thông (nút đóng) không hiện ở một số mục.
- **Cách kiểm:** "close button" (mỗi mục).
- **Đạt khi:** nút đóng có mặt ở mọi mục, vị trí như System Settings.

### 5. Icon sidebar sai

- **Lỗi:** glyph, màu, cỡ, sát chữ.
- **Cách kiểm:** "sidebar search", "sidebar row 0…3", "sidebar icon x", "sidebar icon height", "sidebar text x" (mỗi mục); `sidebar-compare-*.png`.
- **Đạt khi:**
  - ô tìm, hàng, vệt chọn, ô icon và chữ như System Settings;
  - màu ô `systemBlue` / `systemPurple` / `systemOrange` / `systemGreen`;
  - glyph nét trắng theo SVG mockup (nội dung).

### 6. Segmented "Kiểu gõ" hẹp, căn giữa

- **Lỗi:** segmented không trải hết hàng; nút, pop-up, công tắc khác cỡ hệ thống.
- **Cách kiểm:** "segmented "Kiểu gõ" spans its row"; "RadioGroup … height", "PopUpButton … height", "Button … height", "switch …" (mỗi mục).
- **Đạt khi:**
  - segmented không nhãn trải hết hàng như System Settings (macOS 26+, `buttonSizing(.flexible)`);
  - segmented, nút, pop-up, công tắc đúng cỡ hệ thống.

### 7. Ô tìm và "+" dính nhau thành một khối glass

- **Lỗi:** nút "+" và ô tìm của trang Ứng dụng gộp thành một khối, sát tiêu đề hoặc tràn mép phải.
- **Cách kiểm:** "+ right of the title", "+ before the search field", "search field right inset", "search field height" (trang Ứng dụng); `apps-header-compare-*.png`.
- **Đạt khi:** control hệ thống: nút "+" rồi ô tìm của `searchable` ở mép phải thanh công cụ (thứ tự do hệ thống đặt), tách khỏi tiêu đề, không tràn mép phải.

### 8. Nút "+" méo (bầu dục)

- **Lỗi:** nút "+" vẽ thành hình bầu dục.
- **Cách kiểm:** (e) "+ drawn round" trong `check.txt`.
- **Đạt khi:** nút "+" vẽ ra rộng bằng cao (nút thanh công cụ của hệ thống).

### 9. Header không che nội dung khi cuộn

- **Lỗi:** nội dung cuộn hiện qua vùng thanh công cụ.
- **Cách kiểm:** (d) "page scrolls with its bar" trong `always*.txt`; (d) "header when scrolled" trong `check.txt`.
- **Đạt khi:**
  - trang cuộn thật;
  - vùng thanh công cụ bên phải tiêu đề gần như không đổi so với ảnh chưa cuộn (mép cuộn kiểu cứng của hệ thống, `scrollEdgeEffectStyle(.hard)`).

### 10. Thiếu thanh cuộn (nằm ngoài cửa sổ)

- **Lỗi:** mục tràn không có thanh cuộn, hoặc thanh nằm ngoài cửa sổ.
- **Cách kiểm:** (d) "scroll bar of the page that overflows", "scroll bar lane" trong `always*.txt` (trang Gõ phím, cửa sổ thu về chiều cao nhỏ nhất vì ở cỡ mặc định không trang nào tràn); (b) "scroll bar ends at the window edge" trong `check.txt`.
- **Đạt khi:** mục tràn có thanh cuộn, nằm trong lề phải của Form, trong cửa sổ, dưới thanh công cụ.

### 11. Dải hở ở mép phải

- **Lỗi:** cột thanh cuộn chừa sẵn.
- **Cách kiểm:** (b) "page color at the right edge", "toolbar color at the right edge", (c) "right margin is page color" trong `check.txt`; (a) trong `always*.txt`.
- **Đạt khi:**
  - màu nền trang ở mép phải trùng màu lề trái của Form;
  - thanh công cụ cùng màu tới mép phải;
  - lề phải của Form không có điểm khác màu nền, trừ thanh cuộn;
  - không chừa chỗ cho thanh cuộn ở trang không có thanh (mục "Quy tắc thanh cuộn").

### 12. Onboarding lệch mockup

- **Lỗi:** tên app, tiêu đề, thẻ hay cụm nút đổi chỗ giữa các bước, hoặc một view biến mất.
- **Cách kiểm:** (f) trong `check.txt`.
- **Đạt khi:** tên app, tiêu đề, thẻ, cụm nút ở cùng chỗ ở mọi bước, cả hai chế độ; không ảnh nào thiếu view.

### 13. Ảnh chụp ngoài màn hình khác cửa sổ thật

- **Lỗi:** lệch mà vẫn đạt.
- **Cách kiểm:** cửa sổ Cài đặt chỉ được đo trên cửa sổ thật: mọi hàng của `real.txt` (các mục trên mọi màn hình); `swift test` "Not-enabled banner".
- **Đạt khi:**
  - trên cả màn Retina và 1x, mọi số trong `real.txt` đạt: thanh công cụ, tiêu đề trang, sidebar, mục đầu trang (lề trên mặc định của SwiftUI, giữ có chủ ý), tiêu đề nhóm và khoảng cách thẻ, control như mục 6;
  - hàng "Nâng cao" là nút trơn kèm chevron (D9), không so chiều cao;
  - banner "Dấu chưa được bật" là thẻ đầu của mọi trang khi Dấu chưa bật, ở từng trạng thái sau "Bật lại" (chờ Allow, chưa bật được, đã bật);
  - banner không hiện khi đã bật hay không đọc được (N5 (Chỉ hứa điều đã kiểm chứng); `swift test`, dựng split view thật trong cửa sổ không hiện).
- `layoutProbe` (vật dò bố cục) chỉ còn cho ảnh chụp onboarding và bảng so mockup: luôn cùng một cấu trúc view dù có probe hay không, chỉ đặt trên nội dung hàng hoặc cả control, không bọc ngoài `listRowInsets`. Probe đặt ngoài `listRowInsets` từng làm ảnh chụp lệch cửa sổ thật mà các kiểm vẫn đạt.

### 14. Sheet thêm quy tắc

- **Lỗi:**
  - danh sách không cuộn được;
  - danh sách thiếu ứng dụng (một lần chỉ có vài dòng, không thanh cuộn);
  - ô tìm hay chọn hàng không nối với nút.
- **Cách kiểm:**
  - trang `add-sheet` (màn hình chính): "sheet opened by +", "app list settles", "search prompt", "header", "segmented label", "Thêm without selection", "list overflows its card", "list vertical scroll bar", "list scrolls with the wheel", "lists "`<app>`"", "last app visible at the end", "Khi đang gõ in view while scrolled", "search with no match", "search cleared", "Thêm with selection", "Thêm after search hides selection", "Thêm after search cleared", "Huỷ closes the sheet";
  - `AddAppRuleSheetTests` ("Add-rule sheet search");
  - ảnh ở giao diện còn lại trong `always-<light|dark>/`.
- **Đạt khi:**
  - "+" mở sheet; tiêu đề, gợi ý ô tìm, segmented "Khi đang gõ" đúng chữ; có "Chọn ứng dụng khác…", "Huỷ", "Thêm";
  - danh sách ổn định trong thời hạn (bảng ghi thời gian), tràn thẻ và có thanh cuộn dọc;
  - cuộn được bằng lăn chuột thật (bảng ghi số lần thử);
  - có các ứng dụng luôn có của macOS trong `Reference.alwaysInstalledApps` (thiếu thì có thể vì đã có quy tắc cho ứng dụng đó);
  - kéo thanh cuộn tới cuối thì ứng dụng cuối hiện trọn trong thẻ, "Khi đang gõ" vẫn trong sheet;
  - ô tìm nối với danh sách: chuỗi không khớp thì không còn hàng, xoá thì đủ lại số hàng lúc ổn định (lọc thế nào: `AddAppRuleSheetTests`);
  - "Thêm" tắt khi chưa chọn, bật khi chọn; chọn một hàng rồi gõ tìm làm ẩn hàng đó thì "Thêm" tắt, xoá ô tìm vẫn tắt;
  - "Huỷ" đóng sheet;
  - vị trí và cỡ các phần trong sheet không đo trên cửa sổ thật.

### 15. Tìm ở sidebar không khớp mục nào

- **Lỗi:** sidebar trống, trang cũ vẫn hiện như chưa tìm.
- **Cách kiểm:** trang `sidebar-search` (màn hình chính): "rows without a match", "empty state", "toolbar height" (hoặc "toolbar height (close button y)"), "rows after clearing"; `swift test` "Sidebar search".
- **Đạt khi:**
  - ô tìm nhận tiêu điểm rồi đặt chuỗi không khớp (không có tiêu điểm thì SwiftUI không đọc giá trị) thì sidebar không còn hàng và có trạng thái trống hệ thống nêu chuỗi tìm (`ContentUnavailableView.search`), thanh công cụ không đổi;
  - xoá ô tìm thì đủ lại mọi mục (`Reference.sections`);
  - mỗi chữ nhìn thấy trong mục tìm ra mục đó, không phân biệt hoa thường, dấu, "đ"/"d" (`swift test`);
  - ảnh `real/sidebar-search-empty-<2x|1x>.png` (hệ số của màn hình chính).

### 16. Thanh công cụ co, tiêu đề vẽ tay

- **Lỗi:** thanh công cụ co còn thanh tiêu đề nhỏ, tiêu đề vẽ tay lệch tiêu đề hệ thống (D9).
- **Cách kiểm:**
  - trang `launch`: "page at launch";
  - mục 2;
  - `swift test` "Settings window shell" ("AppKit's Show/Hide Sidebar action stays off").
- **Đạt khi:**
  - cửa sổ mở ở mục Gõ phím; thanh công cụ cao như System Settings ở mọi mục (mục 2), kể cả mục không có nút nào trên thanh công cụ;
  - hành động ẩn/hiện sidebar của AppKit luôn tắt (D9; `swift test`);
  - bước nhảy của ô tìm sidebar đúng như test (`swift test` "Sidebar search").

### 17. Sidebar kéo thu lại được

- **Lỗi:** sidebar kéo thu lại được, kéo bị giật; System Settings không cho kéo (D9).
- **Cách kiểm:** trang `sidebar-fixed`: "sidebar width at the start", "sidebar width at the widest window", "sidebar width at the narrowest window"; `swift test` "Settings window shell" (sidebar cố định, đường chia không có vùng chuột).
- **Đạt khi:**
  - sidebar giữ đúng độ rộng cột của System Settings khi đổi cỡ cửa sổ;
  - split view không cho thu sidebar, độ rộng tối thiểu và tối đa bằng nhau;
  - đường chia không có vùng chuột (không kéo, không con trỏ đổi cỡ; `swift test`).

### 18. Mở cửa sổ mà danh sách sidebar không có tiêu điểm

- **Lỗi:** hàng đang chọn vẽ xám (không nhấn) thay vì màu nhấn như canvas.
- **Cách kiểm:**
  - trang `launch-focus`: "sidebar list has the focus at launch", "search field without focus at launch", "selected row drawn with the accent selection (`light|dark`)";
  - trang `search-keyboard`: "Tab from the list reaches the search field", "Edit › Find › Find… before ⌘F" (tên mục đọc từ chuỗi hệ thống, phím tắt, bật hay tắt), "⌘F from the list focuses the search field";
  - `swift test` "Settings window shell";
  - ảnh `real/launch-focus.png`, `always-<light|dark>/launch-focus.png`.
- **Đạt khi:**
  - lúc mở, trước mọi thao tác: danh sách sidebar có tiêu điểm, ô tìm không;
  - nền hàng đang chọn gần màu nhấn của hệ thống hơn màu chọn xám, ở cả hai giao diện;
  - từ danh sách, Tab (hoặc Shift-Tab) và ⌘F đưa tiêu điểm vào ô tìm.

## Chạy

1. Build Debug:

   ```
   DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project Dau.xcodeproj -scheme Dau -configuration Debug -destination 'generic/platform=macOS' -derivedDataPath build/DerivedData.noindex build
   ```

2. Kiểm trên cửa sổ thật: `scripts/selftest/settings-window/run.sh <thư-mục-ra>`.
   - **Chiếm màn hình:** hỏi người dùng giờ chạy trước (CLAUDE.md).
   - Cần quyền Trợ năng và Ghi màn hình cho Terminal. Không đổi cài đặt hệ thống nào.
   - Các lần mở app, mỗi lần kiểm gì, cách chờ và thử lại: chú thích đầu [`run.sh`](../scripts/selftest/settings-window/run.sh), [`ax-check.swift`](../scripts/selftest/settings-window/ax-check.swift), [`check.swift`](../scripts/selftest/settings-window/check.swift).
   - Lượt nhanh chỉ cho tiêu điểm và ô tìm sidebar (mục 15, 18): `run.sh --focus <thư-mục-ra>`, vẫn chiếm màn hình.

3. So với mockup (chỉ đối chiếu nội dung, D9; không có tiêu chí đạt, số đo lấy từ `real.txt`):

   ```
   DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path scripts/snapshot-settings SnapshotSettings <ra> <thư-mục-artboard> [<ra-run.sh>/real] [<ra-run.sh>/onboarding]
   ```

   - Ghi ảnh ghép mockup | app (`*-compare-*.png`, kèm ảnh phóng to sidebar, segmented, header trang Ứng dụng) và bảng khung phần tử.
   - Có `<ra-run.sh>/real`: phía app ở giao diện lúc chạy `run.sh` dùng ảnh và khung của cửa sổ thật (`frames.json`); giao diện còn lại dùng cửa sổ dựng tay của công cụ.
   - Sheet thêm quy tắc dựng bằng `.sheet` thật trên cửa sổ ngoài màn hình, vẽ lại bằng `cacheDisplay`: không có thanh nút, control có thể khác cửa sổ thật; chỉ để xem nội dung.
   - Có thư mục chụp onboarding: thêm `onboarding-<bước>-compare-{light,dark}.png`, so với các artboard onboarding trong [`docs/canvas/README.md`](canvas/README.md). Không có artboard tối: mockup sáng cạnh app tối.

4. Test:

   ```
   DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path scripts/snapshot-settings
   ```

   Gồm: ví dụ do engine tính, phím tắt, ô tìm sidebar, ô tìm và chọn của sheet thêm quy tắc, vỏ cửa sổ, banner "Dấu chưa được bật".

Lệnh 3 và 4 cần `DEVELOPER_DIR` vì Command Line Tools không có plugin macro SwiftUI.

## Đọc bảng kết quả

- Mỗi lần mở app ghi một bảng `<thư-mục>.txt` (`real.txt`, `always.txt`, `always-<light|dark>.txt`); kiểm điểm ảnh ghi `check.txt`.
- Toạ độ tính bằng pt, gốc ở góc trên-trái cửa sổ. Màn hình chính là 1x thì bảng ghi rõ (vị trí dò trong `Reference.swift` đặt trên màn 2x).
- "Như System Settings" nghĩa là khớp số trong `Reference.swift` trong sai số của nó. "Mặc định hệ thống" là chỗ không có số để so.
- "Mỗi mục" nghĩa là có một hàng cho từng mục và từng màn hình.
- Kiểm theo chữ cái:
  - (a) `always*.txt`: thẻ đầu đúng x, mục đầu đúng y; trang không có thanh cuộn thì thẻ rộng đủ cột trừ lề Form; trang có thanh cuộn thì thanh rộng đúng thanh cuộn Always của hệ thống và thẻ rộng đủ cột hoặc hụt đúng một thanh.
  - (b) `check.txt`: màu nền trang tới mép phải (hoặc tới thanh cuộn nằm ở đó); thanh cuộn chạm mép cửa sổ; dải thanh công cụ một màu từ giữa tới mép phải (trừ trang Ứng dụng, nơi có "+" và ô tìm).
  - (c) `check.txt`: lề phải của Form không có điểm khác màu nền; mọi ảnh When scrolling, và ảnh Always chỉ ở trang không có thanh cuộn.
  - (d) `always*.txt`: mục tràn có thanh cuộn, cuộn được bằng thanh cuộn, thanh nằm trong làn lề phải và dưới thanh công cụ; `check.txt`: vùng thanh công cụ bên phải tiêu đề gần như không đổi so với lúc chưa cuộn.
  - (e) `check.txt`: nút "+" trang Ứng dụng vẽ tròn (khung trợ năng của nút là khung mục thanh công cụ, nên đo hình vẽ bằng điểm ảnh).
  - (f) `check.txt`, onboarding: cửa sổ không hiện chữ tiêu đề; tên app, tiêu đề, thẻ, cụm nút ở chỗ của mockup ở mọi bước, cả hai giao diện; thẻ rộng đủ cột, hoặc hụt đúng một thanh cuộn Always chỉ khi nội dung cuộn; view vắng trong một ảnh là `FAIL`.
  - (g) `check.txt`: mọi ảnh gỡ cài đặt (mỗi alert, mỗi sheet "Bỏ Dấu khỏi nguồn đầu vào", ở cả hai giao diện), không bị cắt.

## Quy tắc thanh cuộn

Hệ thống quyết định cách hiện thanh cuộn.

- **When scrolling:** không chiếm chỗ.
- **Always** (`Always`, hoặc `Automatic` khi có chuột):
  - chỉ mục thực sự cần cuộn mới có rãnh thanh cuộn ở mép phải;
  - mục đó hẹp hơn đúng độ rộng thanh cuộn của hệ thống;
  - vị trí x, y của mọi thứ giữ nguyên.
- Không chừa sẵn khoảng trống cho thanh cuộn: cách đó sinh lỗi 11.
