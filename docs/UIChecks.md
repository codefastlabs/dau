# Kiểm tra giao diện

Danh sách này phải được chạy hết trước khi báo xong bất kỳ thay đổi giao diện nào của app Dấu. Mỗi mục là một lỗi người dùng đã gặp.

## Khi nào chạy, đạt nghĩa là gì

- Danh sách được chạy sau mọi thay đổi giao diện, trước khi cho người dùng xem bản build ([`Apps/Dau/CLAUDE.md`](../Apps/Dau/CLAUDE.md)).
- File này không ghi số. Mức đạt nằm ở [`scripts/selftest/settings-window/Reference.swift`](../scripts/selftest/settings-window/Reference.swift), kèm nguồn của từng số. Số đo System Settings gốc nằm ở [`docs/research/SystemSettingsReference.md`](research/SystemSettingsReference.md) (D9 (Giao diện)).
- Mỗi hàng của bảng kết quả mang một trong ba giá trị:
  - `ok` nghĩa là đạt.
  - `FAIL` nghĩa là giao diện không hiện thứ phải hiện, hiện sai trạng thái, hoặc lệch `Reference.swift`.
  - `HARNESS` nghĩa là bộ kiểm không chạy được: thiếu quyền, app không mở, lời gọi Accessibility lỗi, hoặc một trạng thái cần chờ không đến (hàng `wait: …`). Đây không phải kết quả về giao diện; hãy sửa bộ kiểm hay máy rồi chạy lại.
- Không có kết quả bỏ qua. Lượt kiểm đạt khi mọi hàng là `ok` và mọi mục dưới đây đều đạt.
- Lịch sử (ngày phát hiện lỗi, bài học) nằm ở [`docs/history/DocsLog.md`](history/DocsLog.md).

## Danh sách

Mỗi mục có ba dòng: lỗi đã gặp, cách kiểm, và điều kiện đạt. Tên trong "Cách kiểm" là tên hàng của bảng; nếu không ghi bảng nào khác thì đó là `real.txt`. Các chữ (a)–(i) được giải thích ở mục "Đọc bảng kết quả".

### 1. Nội dung co thành cột hẹp, căn giữa

- **Lỗi:** `Form(.grouped)` giới hạn độ rộng thẻ và căn giữa khi cột chi tiết quá rộng.
- **Cách kiểm:** xem hàng "first card" (mỗi mục); các hàng "max window width", "min window width", "min window height"; và (a) trong `always*.txt`.
- **Đạt khi:**
  - Cửa sổ có độ rộng cố định như System Settings (`Reference.windowWidth`), nên Form không bao giờ giới hạn thẻ.
  - Thẻ đầu lấp đầy cột chi tiết, trừ lề của Form.
  - Khi kéo, cửa sổ dừng đúng ở giới hạn cỡ (chỉ chiều cao đổi được).

### 2. Nhảy bố cục khi đổi mục

- **Lỗi:** thanh công cụ đổi chiều cao, và tiêu đề đổi chỗ.
- **Cách kiểm:** xem các hàng "toolbar height" (ở trang không có nút thì là "toolbar height (close button y)", vì thanh chỉ có khoảng trống thì không hiện với Trợ năng), "close button", "title text", "title x", "title center y", "first item y" và "first card" (mỗi mục; các mục so với cùng một số nên phải giống nhau); và (a) trong `always*.txt`.
- **Đạt khi:**
  - Thanh công cụ, nút đóng, tiêu đề, mục đầu và thẻ đầu ở cùng một chỗ ở mọi mục, trên mọi màn hình.
  - Tiêu đề là tiêu đề hệ thống (`navigationTitle`, một chữ tĩnh trên thanh công cụ mang tên cửa sổ), không phải view tự vẽ.
  - Độ rộng chỉ được hụt đúng bằng thanh cuộn Always của hệ thống, và chỉ ở mục đang hiện thanh cuộn.

### 3. Màu không theo HIG

- **Lỗi:** mã tự pha màu nền, hoặc dùng màu chữ cố định.
- **Cách kiểm:** chạy `grep -rnE 'Color\(red|#[0-9a-fA-F]{6}|\.opacity\(|gradient|blended' Apps/Dau/Sources`.
- **Đạt khi:** lệnh không cho kết quả nào. Theo D9, app chỉ dùng màu hệ thống, kể cả ở ô icon sidebar và bóng đổ.

### 4. Mất đèn giao thông

- **Lỗi:** đèn giao thông (nút đóng) không hiện ở một số mục.
- **Cách kiểm:** xem hàng "close button" (mỗi mục).
- **Đạt khi:** nút đóng có mặt ở mọi mục, ở vị trí như System Settings.

### 5. Icon sidebar sai

- **Lỗi:** glyph, màu hay cỡ của icon sai, hoặc icon nằm sát chữ.
- **Cách kiểm:** xem các hàng "sidebar search", "sidebar row 0…3", "sidebar icon x", "sidebar icon height" và "sidebar text x" (mỗi mục).
- **Đạt khi:**
  - Ô tìm, hàng, vệt chọn, ô icon và chữ giống System Settings.
  - Màu ô là `systemBlue` / `systemPurple` / `systemOrange` / `systemGreen`.
  - Glyph có nét trắng theo SVG của mockup (phần này đối chiếu nội dung).

### 6. Segmented "Kiểu gõ" hẹp, căn giữa

- **Lỗi:** segmented không trải hết hàng, hoặc nút, pop-up, công tắc khác cỡ hệ thống.
- **Cách kiểm:** xem các hàng "segmented "Kiểu gõ" spans its row"; "RadioGroup … height", "PopUpButton … height", "Button … height" và "switch …" (mỗi mục).
- **Đạt khi:**
  - Segmented không có nhãn trải hết hàng như System Settings (macOS 26+, `buttonSizing(.flexible)`).
  - Segmented, nút, pop-up và công tắc đúng cỡ hệ thống.

### 7. Ô tìm và "+" dính nhau thành một khối glass

- **Lỗi:** nút "+" và ô tìm của trang Ứng dụng gộp thành một khối, nằm sát tiêu đề hoặc tràn mép phải.
- **Cách kiểm:** xem các hàng "+ right of the title", "+ before the search field", "search field right inset" và "search field height" (trang Ứng dụng).
- **Đạt khi:** đây là control hệ thống: nút "+" rồi tới ô tìm của `searchable` ở mép phải thanh công cụ (thứ tự do hệ thống đặt), tách khỏi tiêu đề và không tràn mép phải.

### 8. Nút "+" méo (bầu dục)

- **Lỗi:** nút "+" được vẽ thành hình bầu dục.
- **Cách kiểm:** xem (e) "+ drawn round" trong `check.txt`.
- **Đạt khi:** nút "+" vẽ ra rộng bằng cao, như nút thanh công cụ của hệ thống.

### 9. Header không che nội dung khi cuộn

- **Lỗi:** nội dung cuộn hiện qua vùng thanh công cụ.
- **Cách kiểm:** xem (d) "page scrolls with its bar" trong `always*.txt`, và (d) "header when scrolled" trong `check.txt`.
- **Đạt khi:**
  - Trang cuộn được thật.
  - Vùng thanh công cụ bên phải tiêu đề gần như không đổi so với ảnh chưa cuộn (mép cuộn kiểu cứng của hệ thống, `scrollEdgeEffectStyle(.hard)`).

### 10. Thiếu thanh cuộn (nằm ngoài cửa sổ)

- **Lỗi:** mục bị tràn mà không có thanh cuộn, hoặc thanh cuộn nằm ngoài cửa sổ.
- **Cách kiểm:** xem (d) "scroll bar of the page that overflows" và "scroll bar lane" trong `always*.txt` (trang Gõ phím, với cửa sổ thu về chiều cao nhỏ nhất, vì ở cỡ mặc định không trang nào tràn); và (b) "scroll bar ends at the window edge" trong `check.txt`.
- **Đạt khi:** mục bị tràn có thanh cuộn, và thanh nằm trong lề phải của Form, trong cửa sổ, dưới thanh công cụ.

### 11. Dải hở ở mép phải

- **Lỗi:** giao diện chừa sẵn một cột cho thanh cuộn.
- **Cách kiểm:** xem (b) "page color at the right edge", "toolbar color at the right edge" và (c) "right margin is page color" trong `check.txt`; và (a) trong `always*.txt`.
- **Đạt khi:**
  - Màu nền trang ở mép phải trùng màu lề trái của Form.
  - Thanh công cụ cùng một màu tới tận mép phải.
  - Lề phải của Form không có điểm nào khác màu nền, trừ thanh cuộn.
  - Trang không có thanh cuộn thì không chừa chỗ cho thanh cuộn (mục "Quy tắc thanh cuộn").

### 12. Onboarding lệch mockup

- **Lỗi:** tên app, tiêu đề, thẻ hay cụm nút đổi chỗ giữa các bước, hoặc một view biến mất.
- **Cách kiểm:** xem (f) trong `check.txt`.
- **Đạt khi:** tên app, tiêu đề, thẻ và cụm nút ở cùng một chỗ ở mọi bước, trong cả hai chế độ, và không ảnh nào thiếu view.

### 13. Đo trên ảnh dựng thay vì cửa sổ thật

- **Lỗi:** giao diện lệch mà các kiểm vẫn đạt.
- **Cách kiểm:** cửa sổ Cài đặt chỉ được đo trên cửa sổ thật. Hãy xem mọi hàng của `real.txt` (các mục trên mọi màn hình), và `swift test` "Not-enabled banner".
- **Đạt khi:**
  - Trên cả màn Retina và màn 1x, mọi số trong `real.txt` đều đạt: thanh công cụ, tiêu đề trang, sidebar, mục đầu trang (lề trên mặc định của SwiftUI, được giữ có chủ ý), tiêu đề nhóm và khoảng cách thẻ, và control như ở mục 6.
  - Hàng "Nâng cao" là nút trơn kèm chevron (D9), và không so chiều cao của hàng này.
  - Banner "Dấu chưa được bật" là thẻ đầu của mọi trang khi Dấu chưa bật, ở từng trạng thái sau khi bấm "Bật lại" (chờ Allow, chưa bật được, đã bật).
  - Banner không hiện khi Dấu đã bật hay khi không đọc được trạng thái (N5 (Chỉ hứa điều đã kiểm chứng)). Điều này được kiểm bằng `swift test`, trong đó split view thật được dựng trong một cửa sổ không hiện.
- `layoutProbe` (vật dò bố cục) chỉ còn dùng cho ảnh chụp onboarding và test banner. Cấu trúc view phải luôn giống nhau dù có probe hay không; probe chỉ được đặt trên nội dung hàng hoặc trên cả control, không bọc ngoài `listRowInsets`. Probe đặt ngoài `listRowInsets` từng làm ảnh chụp lệch cửa sổ thật mà các kiểm vẫn đạt.

### 14. Sheet thêm quy tắc

- **Lỗi:**
  - Danh sách không cuộn được.
  - Danh sách thiếu ứng dụng; có một lần nó chỉ có vài dòng và không có thanh cuộn.
  - Ô tìm hay việc chọn hàng không nối với các nút.
- **Cách kiểm:**
  - Trên trang `add-sheet` (màn hình chính), xem các hàng "sheet opened by +", "app list settles", "search prompt", "header", "segmented label", "Thêm without selection", "list overflows its card", "list vertical scroll bar", "list scrolls with the wheel", "lists "`<app>`"", "last app visible at the end", "Khi đang gõ in view while scrolled", "search with no match", "search cleared", "Thêm with selection", "Thêm after search hides selection", "Thêm after search cleared" và "Huỷ closes the sheet".
  - Chạy `AddAppRuleSheetTests` ("Add-rule sheet search").
  - Xem ảnh ở giao diện còn lại trong `always-<light|dark>/`.
- **Đạt khi:**
  - "+" mở sheet. Tiêu đề, gợi ý của ô tìm và segmented "Khi đang gõ" đúng chữ, và sheet có "Chọn ứng dụng khác…", "Huỷ", "Thêm".
  - Danh sách ổn định trong thời hạn (bảng ghi thời gian), tràn thẻ và có thanh cuộn dọc.
  - Danh sách cuộn được bằng lăn chuột thật (bảng ghi số lần thử).
  - Danh sách có các ứng dụng luôn có của macOS trong `Reference.alwaysInstalledApps`. Nếu thiếu, lý do có thể là đã có quy tắc cho ứng dụng đó.
  - Khi kéo thanh cuộn tới cuối, ứng dụng cuối hiện trọn trong thẻ, và "Khi đang gõ" vẫn nằm trong sheet.
  - Ô tìm nối với danh sách: chuỗi không khớp thì không còn hàng nào, và xoá chuỗi thì số hàng trở lại như lúc ổn định (cách lọc nằm ở `AddAppRuleSheetTests`).
  - "Thêm" tắt khi chưa chọn và bật khi đã chọn. Nếu chọn một hàng rồi gõ tìm làm ẩn hàng đó, "Thêm" tắt, và xoá ô tìm thì nút vẫn tắt.
  - "Huỷ" đóng sheet.
  - Vị trí và cỡ các phần trong sheet không được đo trên cửa sổ thật.

### 15. Tìm ở sidebar không khớp mục nào

- **Lỗi:** sidebar trống, nhưng trang cũ vẫn hiện như chưa tìm.
- **Cách kiểm:** trên trang `sidebar-search` (màn hình chính), xem các hàng "rows without a match", "empty state", "toolbar height" (hoặc "toolbar height (close button y)") và "rows after clearing"; và chạy `swift test` "Sidebar search".
- **Đạt khi:**
  - Ô tìm nhận tiêu điểm rồi được đặt một chuỗi không khớp (không có tiêu điểm thì SwiftUI không đọc giá trị). Khi đó sidebar không còn hàng nào và hiện trạng thái trống của hệ thống, có nêu chuỗi tìm (`ContentUnavailableView.search`), còn thanh công cụ không đổi.
  - Xoá ô tìm thì mọi mục hiện lại đủ (`Reference.sections`).
  - Mỗi chữ nhìn thấy trong một mục đều tìm ra mục đó, không phân biệt hoa thường, dấu, "đ"/"d" (`swift test`).
  - Có ảnh `real/sidebar-search-empty-<2x|1x>.png` (theo hệ số của màn hình chính).

### 16. Thanh công cụ co, tiêu đề vẽ tay

- **Lỗi:** thanh công cụ co lại chỉ còn thanh tiêu đề nhỏ, và tiêu đề vẽ tay lệch tiêu đề hệ thống (D9).
- **Cách kiểm:**
  - Trên trang `launch`, xem hàng "page at launch".
  - Xem mục 2.
  - Chạy `swift test` "Settings window shell" ("AppKit's Show/Hide Sidebar action stays off").
- **Đạt khi:**
  - Cửa sổ mở ở mục Gõ phím. Thanh công cụ cao như System Settings ở mọi mục (mục 2), kể cả mục không có nút nào trên thanh công cụ.
  - Hành động ẩn/hiện sidebar của AppKit luôn tắt (D9; `swift test`).
  - Bước nhảy của ô tìm sidebar đúng như test (`swift test` "Sidebar search").

### 17. Sidebar kéo thu lại được

- **Lỗi:** sidebar kéo thu lại được và kéo bị giật, trong khi System Settings không cho kéo (D9).
- **Cách kiểm:** trên trang `sidebar-fixed`, xem các hàng "sidebar width at the start", "sidebar width at the widest window" và "sidebar width at the narrowest window"; và chạy `swift test` "Settings window shell" (sidebar cố định, đường chia không có vùng chuột).
- **Đạt khi:**
  - Sidebar giữ đúng độ rộng cột của System Settings khi đổi cỡ cửa sổ.
  - Split view không cho thu sidebar, và độ rộng tối thiểu bằng độ rộng tối đa.
  - Đường chia không có vùng chuột: không kéo được và con trỏ không đổi thành con trỏ đổi cỡ (`swift test`).

### 18. Mở cửa sổ mà danh sách sidebar không có tiêu điểm

- **Lỗi:** hàng đang chọn được vẽ màu xám (không nhấn) thay vì màu nhấn như trên canvas.
- **Cách kiểm:**
  - Trên trang `launch-focus`, xem các hàng "sidebar list has the focus at launch", "search field without focus at launch" và "selected row drawn with the accent selection (`light|dark`)".
  - Trên trang `search-keyboard`, xem các hàng "Tab from the list reaches the search field", "Edit › Find › Find… before ⌘F" (tên mục đọc từ chuỗi hệ thống, phím tắt, bật hay tắt) và "⌘F from the list focuses the search field".
  - Chạy `swift test` "Settings window shell".
  - Xem ảnh `real/launch-focus.png` và `always-<light|dark>/launch-focus.png`.
- **Đạt khi:**
  - Lúc mở, trước mọi thao tác, danh sách sidebar có tiêu điểm còn ô tìm thì không.
  - Nền của hàng đang chọn gần màu nhấn của hệ thống hơn màu chọn xám, ở cả hai giao diện.
  - Từ danh sách, Tab (hoặc Shift-Tab) và ⌘F đưa tiêu điểm vào ô tìm.

## Chạy

1. Build bản Debug:

   ```
   DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project Dau.xcodeproj -scheme Dau -configuration Debug -destination 'generic/platform=macOS' -derivedDataPath build/DerivedData.noindex build
   ```

2. Kiểm trên cửa sổ thật bằng `scripts/selftest/settings-window/run.sh <thư-mục-ra>`.
   - **Chiếm màn hình:** lệnh này do phiên chính chạy, theo chế độ quyền của Claude Code (CLAUDE.md, mục "Điều phối").
   - Terminal cần quyền Trợ năng và Ghi màn hình. Lệnh không đổi cài đặt hệ thống nào.
   - Các lần mở app, mỗi lần kiểm gì, cách chờ và cách thử lại được ghi trong chú thích đầu [`run.sh`](../scripts/selftest/settings-window/run.sh), [`AXCheck.swift`](../scripts/selftest/settings-window/AXCheck.swift) và [`Check.swift`](../scripts/selftest/settings-window/Check.swift).
   - Lượt nhanh chỉ kiểm tiêu điểm và ô tìm sidebar (mục 15, 18) bằng `run.sh --focus <thư-mục-ra>`; lượt này vẫn chiếm màn hình.

3. So với mockup. Bước này chỉ đối chiếu nội dung (D9) và không có tiêu chí đạt; số đo lấy từ `real.txt`. Hãy đặt bản chụp artboard trong `docs/canvas/` cạnh ảnh cửa sổ thật mà lệnh ở bước 2 chụp: `real/`, `always-<light|dark>/`, `onboarding/`, `report/` (so với artboard "Report") và `updates-release/` (so với artboard "SettingsAbout" ở hai giá trị `stage`). Danh sách artboard nằm ở [`docs/canvas/README.md`](canvas/README.md). Không có artboard tối, nên app ở chế độ tối được so với mockup sáng.

4. Chạy test:

   ```
   DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path Apps/Dau/Tests
   ```

   Bộ test gồm ví dụ do engine tính, phím tắt, ô tìm sidebar, ô tìm và việc chọn trong sheet thêm quy tắc, vỏ cửa sổ, và banner "Dấu chưa được bật".

Bước 1 và bước 4 cần `DEVELOPER_DIR`, vì Command Line Tools không có plugin macro của SwiftUI.

## Đọc bảng kết quả

- Mỗi lần mở app ghi một bảng `<thư-mục>.txt` (`real.txt`, `always.txt`, `always-<light|dark>.txt`). Phần kiểm điểm ảnh ghi vào `check.txt`.
- Toạ độ tính bằng pt, với gốc ở góc trên bên trái cửa sổ. Nếu màn hình chính là 1x, bảng ghi rõ điều đó (vị trí dò trong `Reference.swift` được đặt trên màn 2x).
- "Như System Settings" nghĩa là khớp số trong `Reference.swift`, trong sai số của số đó. "Mặc định hệ thống" là chỗ không có số để so.
- "Mỗi mục" nghĩa là có một hàng cho từng mục và từng màn hình.
- Các kiểm được đánh dấu bằng chữ cái như sau:
  - (a) Trong `always*.txt`, thẻ đầu phải đúng x và mục đầu phải đúng y. Ở trang không có thanh cuộn, thẻ rộng đủ cột trừ lề Form. Ở trang có thanh cuộn, thanh rộng đúng bằng thanh cuộn Always của hệ thống, và thẻ rộng đủ cột hoặc hụt đúng một thanh.
  - (b) Trong `check.txt`, màu nền trang kéo tới mép phải (hoặc tới thanh cuộn nằm ở đó), thanh cuộn chạm mép cửa sổ, và dải thanh công cụ có một màu từ giữa tới mép phải (trừ trang Ứng dụng, nơi có "+" và ô tìm).
  - (c) Trong `check.txt`, lề phải của Form không có điểm nào khác màu nền. Kiểm này áp cho mọi ảnh When scrolling, và cho ảnh Always chỉ ở trang không có thanh cuộn.
  - (d) Trong `always*.txt`, mục bị tràn có thanh cuộn, cuộn được bằng thanh cuộn, và thanh nằm trong làn lề phải, dưới thanh công cụ. Trong `check.txt`, vùng thanh công cụ bên phải tiêu đề gần như không đổi so với lúc chưa cuộn.
  - (e) Trong `check.txt`, nút "+" của trang Ứng dụng được vẽ tròn. Khung trợ năng của nút là khung của mục thanh công cụ, nên hình vẽ được đo bằng điểm ảnh.
  - (f) Trong `check.txt`, ở onboarding, cửa sổ không hiện chữ tiêu đề. Tên app, tiêu đề, thẻ và cụm nút nằm ở chỗ của mockup ở mọi bước, trong cả hai giao diện. Thẻ rộng đủ cột, hoặc chỉ hụt đúng một thanh cuộn Always khi nội dung cuộn. Một view vắng mặt trong một ảnh là `FAIL`.
  - (g) Trong `check.txt`, mọi ảnh gỡ cài đặt (mỗi alert và mỗi sheet "Bỏ Dấu khỏi nguồn đầu vào", ở cả hai giao diện) không bị cắt.
  - (h) Trong `check.txt`, sheet "Báo ứng dụng gõ lỗi" (`report/`, với nội dung mẫu của artboard, ở cả hai giao diện) rộng như sheet của System Settings, và mục "Gửi kèm" nằm trọn trong sheet.
  - (i) Trong `check.txt`, trang Cập nhật & hỗ trợ được chụp như bản phát hành hiện nó (`updates-release/`, `--capture-updates`), ở hai giai đoạn của artboard "SettingsAbout" (chưa có bản chính thức; đã có, và người dùng ở Beta), trong cả hai giao diện. Các điều kiện như sau:
    - Dòng phiên bản là số mẫu "Dấu 0.1.0 (6520)", và không có dòng bộ gõ đã cài (dòng đó thuộc bản phát triển).
    - Thẻ đầu rộng như ở (a).
    - Hàng "Kênh phát hành" nằm trong thẻ, và control nằm trong ô của hàng, tức là giữa hàng trên và đáy hàng. Form canh control theo dòng đầu của nhãn, nên control nhô lên trên khung nhãn vài điểm. Control cao như control của System Settings, và mép phải thẳng hàng với mép phải công tắc "Tự động kiểm tra bản mới".
    - Beta được chọn. Chính thức bị tắt khi chưa có bản chính thức, và được bật khi đã có.
    - Ảnh này dùng trình cập nhật giả. Vì vậy nó không kiểm Sparkle (kênh thật, appcast và cập nhật thuộc bước 2 của M7), và biểu tượng là của bản phát triển (bản Debug không có biểu tượng chuẩn, D25).
    - Như các ảnh chụp trong app khác, app không được kích hoạt, vì macOS 14 trở lên kích hoạt theo kiểu hợp tác, và kích hoạt sẽ lấy tiêu điểm của người dùng. Do đó đèn giao thông và đoạn được chọn có màu xám; màu được so trên artboard.
    - Khung được lấy từ các điểm đo bố cục trong app (đo hàng, không đo thẻ), như ở (f) và (h).

## Quy tắc thanh cuộn

Hệ thống quyết định cách hiện thanh cuộn.

- **When scrolling:** thanh cuộn không chiếm chỗ.
- **Always** (`Always`, hoặc `Automatic` khi có chuột):
  - Chỉ mục thực sự cần cuộn mới có rãnh thanh cuộn ở mép phải.
  - Mục đó hẹp hơn đúng bằng độ rộng thanh cuộn của hệ thống.
  - Vị trí x, y của mọi thứ giữ nguyên.
- Giao diện không chừa sẵn khoảng trống cho thanh cuộn, vì cách đó sinh ra lỗi 11.
