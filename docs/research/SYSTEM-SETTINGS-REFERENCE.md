# Số đo System Settings làm chuẩn cho cửa sổ Cài đặt

Khi mockup và macOS khác nhau về bố cục, khoảng cách, cỡ chữ hay hình dáng control thì cửa sổ Cài đặt của Dấu theo System Settings; mockup chỉ quy định nội dung (D9 (Giao diện)). File này giữ số đo của System Settings, chỗ SwiftUI mặc định khác số đó, và chỗ Dấu cố ý khác. Số mà `scripts/selftest/settings-window/run.sh` kiểm trên cửa sổ thật nằm trong [`scripts/selftest/settings-window/Reference.swift`](../../scripts/selftest/settings-window/Reference.swift).

## Hiện trạng (11/11/2026)

- **Chuẩn:** System Settings trên macOS 27.2 (26B123), đo 02/11/2026; thanh công cụ và sidebar đo thêm 05/11, cỡ cửa sổ 09/11.
- **SwiftUI mặc định cho đúng phần lớn số đo**; chỗ khác ở mục "Hành vi SwiftUI khác hệ thống": sidebar 144 thay vì 232, lề trên form 20 thay vì 12, thẻ form tối đa 704, hàng chỉ có `Text` cao 36, nút trong hàng chỉ có nút căn trái.
- **Cửa sổ System Settings rộng cố định 740, chỉ đổi được chiều cao**; sidebar 232 không kéo, không thu được. Cửa sổ Cài đặt của Dấu làm theo cả hai.
- **Dấu cố ý khác chuẩn ở vài chỗ**, mỗi chỗ có lý do trong D9: lề trên form 20, ô tìm sidebar lệch 1–2 pt, nút mở/thu "Nâng cao", tiêu đề trong sheet (mục "Dấu so với chuẩn").
- Apple không công bố các số này (mục "Nguồn API"); chúng là số đo trên máy và có thể đổi theo phiên bản macOS.

## Cách đo

- System Settings mở bằng URL `x-apple.systempreferences:`, không bấm gì, không đổi cài đặt nào. Pane đã đo: Bàn phím, Giao diện, Âm thanh, Màn hình khoá, Desktop & Dock, Ngày & Giờ, Thông báo, Màn hình, Cài đặt chung, Bàn di chuột.
- Khung phần tử đọc bằng Accessibility API (role, x, y, w, h). Mép, màu, bán kính góc đọc theo pixel trên ảnh `screencapture -l`.
- Cỡ chữ suy ra bằng cách so độ rộng nét chữ đo được với độ rộng tính bằng `NSFont.systemFont` ở các cỡ và độ đậm; "≈" khi hai mức sát nhau.
- Số SwiftUI mặc định đo trên một app thử ngoài repo: `NavigationSplitView`, `List` sidebar 4 hàng (ô icon 20 màu, chữ), `Form { Section … }.formStyle(.grouped)`, `.navigationTitle`, không `listRowInsets`, không padding; chạy ở 820 × 600, 740 × 560 và rộng 1000–1400.
- Giao diện Tối, màn Retina 2x (trừ chỗ ghi màn 1x). Đơn vị pt, gốc toạ độ ở góc trên trái cửa sổ (sheet: góc trên trái sheet).
- Máy đo hiện thanh cuộn kiểu cũ (luôn hiện), nên hàng sidebar của System Settings rộng 215 thay vì 232.

## Số đo System Settings

### Cửa sổ và thanh công cụ

| Thông số | System Settings |
|---|---|
| Kích thước cửa sổ | 740 × 560 ở mọi pane lúc đo 02/11; rộng cố định, cao đổi được (mục dưới) |
| Thanh tiêu đề và công cụ | cao 52 |
| Nút đèn giao thông | x 18 / 41 / 64, y 18, 16 × 16 |
| Cụm Lùi/Tiến | Lùi x 240, y 8, 36 × 36; Tiến x 276, y 8, 37 × 36; vạch ngăn x 276 (05/11) |
| Tiêu đề trang | 15, đậm (bold ≈ semibold), màu chữ chính; nét chữ từ x ≈ 324, chữ hoa từ y 20 đến 31 |

#### Cửa sổ có đổi rộng được không

Đo 09/11/2026 (System Settings ở pane mặc định, cửa sổ 740 × 765): đặt kích thước qua `AXSize` của System Events rồi đọc lại.
- Đặt rộng 940 hay 590: đọc lại 740. Độ rộng **cố định ở 740**.
- Đặt cao 915: đọc lại 876 (cao hơn 765, thấp hơn giá trị đặt, có lẽ do giới hạn màn hình). Chiều cao **đổi được**.
- Trả lại kích thước và vị trí cũ, rồi thoát System Settings.

### Sidebar

| Thông số | System Settings |
|---|---|
| Độ rộng cột | 232 (đường chia 0,5 ở x 231,5); kéo đường chia 200 pt sang hai bên hay bấm đúp không đổi, không thu được, con trỏ là mũi tên (05/11) |
| Ô tìm | x 10, y 61, 212 × 28, dạng viên thuốc; danh sách bắt đầu ở y 98 (không có ô tìm: y 52) |
| Hàng | cao 32 |
| Vùng chọn | x 10, rộng = cột − 20 (đo được x 10..205 vì thanh cuộn; không có thanh cuộn thì suy ra 10..222, cần kiểm chứng), góc ≈ 7, màu nhấn khi danh sách giữ tiêu điểm bàn phím |
| Ô icon | 20 × 20, x 19, giữa hàng |
| Chữ | 13, thường, trắng hoàn toàn (255) ở giao diện Tối; nét chữ từ x ≈ 46 (cách mép ô icon ≈ 7) |
| Khoảng giữa hai nhóm | 13 |
| Vùng đáy sidebar | không có |
| Nền sidebar / nền pane | ≈ (51, 51, 49) / (45, 45, 44) ở giao diện Tối; phụ thuộc hình nền và giao diện |

### Form dạng nhóm

| Thông số | System Settings |
|---|---|
| Lề thẻ trái / phải | 20 / 20 (thẻ 252..720 trong pane 232..740); thanh cuộn nằm trong lề phải |
| Lề trên (thanh công cụ → thẻ đầu hay tiêu đề nhóm đầu) | 12 (y 64) |
| Bán kính góc thẻ | ≈ 11 |
| Màu thẻ / nền pane | (54, 54, 53) / (45, 45, 44) ở giao diện Tối |
| Hai thẻ không tiêu đề | cách 10 |
| Thẻ trước → tiêu đề nhóm sau | 30 |
| Tiêu đề nhóm | 13, semibold ≈, màu chữ chính, cao 17,5; x = mép thẻ + 10, cách thẻ 10 |
| Mô tả nhóm | dưới tiêu đề, trên thẻ (pane Thông báo): 11, thường, màu chữ phụ, x = mép thẻ + 10, cách thẻ 10 |
| Chú thích dưới thẻ | không gặp ở pane nào |
| Nút dưới form | căn phải, cách thẻ cuối 20, cao 24; nút "?" 24 × 24 ở mép phải ("Phím tắt bàn phím…", "Tuỳ chọn trợ năng…") |
| Độ rộng nội dung tối đa | không đo được: cửa sổ rộng 740 ở mọi pane, thẻ 468 |

### Hàng trong thẻ

| Thông số | System Settings |
|---|---|
| Lề trái / phải trong hàng | 10 / 10 |
| Nhãn + giá trị chữ, nhãn + công tắc, nhãn + pop-up | cao 37,5 (không gặp hàng chỉ có nhãn) |
| Nhãn + thanh trượt | 37,5 (Bàn phím) đến 38,5 (Âm thanh) |
| Nhãn + dòng phụ một dòng (+ control) | 55,5 (10 + 17,5 + 2 + 16 + 10); dòng phụ hai dòng 71,5 |
| Nhãn + nút | 40 (Ngày & Giờ, Màn hình khoá); 44 ở pane Bàn phím ("Nguồn đầu vào") |
| Hàng chỉ có nút | 44, nút căn phải ("Phím tắt bàn phím…") |
| Hàng segmented | thanh tab "Đầu ra / Đầu vào" (Âm thanh) không có nhãn, rộng hết hàng |
| Chữ | nhãn 13 thường màu chữ chính, khung cao 17,5; dòng phụ 11 màu chữ phụ; giá trị bên phải 13 màu chữ phụ |
| Đường phân cách | dày 1 (2 px), thụt 10 hai bên, giữa hai hàng, màu ≈ (66, 66, 65) |
| Công tắc | 36 × 16 |
| Pop-up | cao 24, không viền: chữ giá trị + nút tròn mũi tên lên/xuống |
| Nút bấm | cao 24, nền phẳng, góc ≈ 5, không viền ("Đặt…" 55 × 24) |
| Segmented | cao 24, góc ≈ 5, ô chọn nền màu nhấn |

### Sheet

Sheet mở bằng AXPress trên nút của pane, đóng bằng "Xong"/"Huỷ".

| Thông số | Màn hình › Nâng cao… | Bàn phím › Nguồn đầu vào › Sửa… | Bàn phím › Sửa… › + (AppKit cũ) |
|---|---|---|---|
| Kích thước | 470 × 454 | 640 × 468 (sidebar 200 + Form) | 564 × 392 |
| Thẻ của Form | x 20, rộng = sheet − 40, cách mép trên 20, thẻ cách thẻ 10, tiêu đề nhóm → thẻ 10 | như cột trái, cách mép cột 20 | bảng có viền |
| Thanh nút | vạch ngăn dưới Form; "Xong" 64 × 24 nền màu nhấn, cách mép phải và mép dưới 20, cách đáy Form 21 | như cột trái | "Huỷ", "Thêm" 72 × 26 (kiểu cũ), cách mép 19–20 |
| Ô tìm | không có | không có | dưới trái, 226 × 26 (kiểu cũ) |
| Tiêu đề | không có | không có | một dòng chữ 13 ở trên trái |

### Icon ứng dụng trong hàng

Đo trên màn 1x (số làm tròn tới 1 pt). Icon ứng dụng không phải phần tử trợ năng nên đo theo pixel: khung bao các điểm khác màu nền thẻ ("nét vẽ"). Icon ứng dụng macOS chỉ vẽ ≈ 80% khung (lưới 824/1024; icon của Dấu cũng vậy, 412/512), nên khung = nét vẽ ÷ 0,805.

| Pane (URL) | Loại hàng | Cao hàng | Nét vẽ icon | Khung suy ra | Chữ bắt đầu |
|---|---|---|---|---|---|
| Cài đặt chung › Mục đăng nhập & tiện ích mở rộng › Hoạt động nền (`com.apple.LoginItems-Settings.extension`) | icon, tên + dòng phụ, công tắc | 57 | 26 × 26 từ x 265 | **32**, từ x 262 (mép thẻ + 10) | x 304 |
| Thông báo › Thông báo của ứng dụng (`com.apple.Notifications-Settings.extension`) | icon, tên + dòng phụ, chevron | 56 | 26 × 26 từ x 264 | **32** | x 302 |
| Quyền riêng tư & Bảo mật › Trợ năng (`com.apple.preference.security?Privacy_Accessibility`; tiêu đề trên máy đo: "Device Control and Data Access") | danh sách trong thẻ có +/−: icon, tên một dòng, công tắc | 42 | 20 × 20 từ x 263 (một app 22) | **24**, từ x 261 | x 294 |
| Mục đăng nhập › Mở khi đăng nhập (cùng pane) | bảng có cột "Item / Kind" | 26 | 14 × 14 | 16 | — |
| Thẻ đầu pane: Thông báo, Siri (`com.apple.Siri-Settings.extension`) | icon pane, tên + mô tả | thẻ 72 | 26 × 26 từ x 264 | icon pane vẽ kín khung: 26 | x 302 |

Không gặp hàng nào hiện icon ứng dụng 28 hay 48.

### Không có hàng mở/thu

Rà bằng Accessibility API ở các pane Wi-Fi, Mạng, Bàn phím, Bàn di chuột, Chia sẻ, Desktop & Dock, Thanh menu, Màn hình khoá, Màn hình, Spotlight, Trợ năng, Âm thanh, Pin: không pane nào có hàng mở/thu (`AXDisclosureTriangle` hay nút chevron xoay). Tuỳ chọn nâng cao nằm ở một trong ba chỗ:
- nhóm riêng có tiêu đề (Chia sẻ › "Advanced");
- sau nút mở sheet ("Nâng cao…" ở Màn hình, "Chi tiết…" ở Wi-Fi);
- nút "Show Detail" (i) ở cuối hàng.

### Hộp thoại xin phép bật bộ gõ

Quan sát trên bản thử (bundle đổi ID, không phải Dấu), dùng để vẽ artboard onboarding, không rút kết luận về hành vi: đo 04/11/2026, đọc qua trợ năng và ảnh chụp, macOS 27.2, giao diện tối. Hộp thoại là `Allow “…” to enable “…”?` ([`docs/research/INPUT-METHOD-INSTALL.md`](INPUT-METHOD-INSTALL.md) mục 2).

- Sheet rộng 260 pt, cao 234 pt, nằm giữa cửa sổ System Settings.
- Không có biểu tượng. Tiêu đề đậm, canh trái, xuống dòng khi dài.
- Thân bài canh trái, hiện đủ 6 dòng ở bề rộng này, không cắt.
- Hai nút hình viên thuốc 112 × 30 pt nằm ngang ở đáy: "Don’t Allow" xám bên trái, "Allow" xanh (nút mặc định) bên phải.

## Hành vi SwiftUI khác hệ thống

Mọi số ở mục trên mà không có trong danh sách này thì SwiftUI mặc định cho đúng (app thử, 02/11/2026): thanh công cụ 52 và tiêu đề 15 đậm, hàng và vùng chọn sidebar, lề và màu thẻ, tiêu đề nhóm, chiều cao các hàng có control, control và cỡ chữ. Chưa đo trên SwiftUI: khoảng giữa hai thẻ không tiêu đề (app thử luôn có tiêu đề nhóm), hàng nhãn + thanh trượt. `footer:` của `Section` cho chú thích dưới thẻ 11, thường, màu chữ phụ, x = mép thẻ + 10, cách thẻ 10.

- **Độ rộng sidebar của `NavigationSplitView`:** 144, làm cụt chữ "Cập nhật & hỗ trợ". Đặt `navigationSplitViewColumnWidth(232)` thì mọi số sidebar và lề form trùng System Settings.
- **Ô tìm sidebar:** không có sẵn; `.searchable(placement: .sidebar)` trên `NavigationSplitView` cho đúng khung của System Settings. Không có `NavigationSplitView` thì ô tìm này lên thanh công cụ ([`docs/research/SWIFTUI-WINDOW-API.md`](SWIFTUI-WINDOW-API.md)).
- **Nút sidebar:** `NavigationSplitView` thêm nút ẩn/hiện sidebar (44 × 52 ở mép phải cột sidebar). Gỡ bằng `.toolbar(removing: .sidebarToggle)` mà thanh không còn mục nào thì thanh co còn 32 và tiêu đề thành chữ tiêu đề cửa sổ nhỏ (màn 1x). Có một mục ở `.navigation` (cụm Lùi/Tiến) thì thanh giữ 52 và tiêu đề 15 đậm.
- **Lề trên form:** 20 (y 72) thay vì 12. `.contentMargins(.top, …, for: .scrollContent)` cộng thêm vào 20 chứ không thay (đặt 12 ra 32), nên không giảm được bằng API công khai.
- **Thẻ của `Form(.grouped)` tối đa 704**, đặt giữa pane. Pane ≤ 744 thì thẻ = pane − 40; pane 856 → thẻ 704 (lề 76); pane 1256 → thẻ 704 (lề 276). `.frame(maxWidth: .infinity)` và `.contentMargins(.horizontal, 20, for: .scrollContent)` không gỡ được. Cửa sổ 740 cho thẻ 468, trùng System Settings.
- **Hàng chỉ có `Text`:** cao 36 (chữ cao 16 thay vì 17,5); hàng nhãn cạnh control vẫn 37,5. System Settings không có hàng nhãn trơn để so.
- **Hàng chỉ có nút:** cao 44 như hệ thống, nhưng nút căn trái.
- **Nhãn + segmented:** hàng ≈ 40, segmented căn phải, các ô bằng nhau (màn 1x); System Settings không có hàng segmented có nhãn để so.
- **Vùng chọn sidebar xám** khi danh sách không giữ tiêu điểm (bản không có ô tìm); phụ thuộc tiêu điểm, không phải thông số.
- **Sheet** (`Form(.grouped)`, `searchable`, `toolbar` trong sheet):
  - `ToolbarItem(.cancellationAction / .confirmationAction)` cho đúng thanh nút của System Settings (vạch ngăn, nút tối thiểu 64 × 24, cách mép phải và dưới 20, cách đáy Form 21, hai nút cách nhau 8); `.automatic` đặt ở đầu trái thanh nút (x 20). Thẻ của Form đúng lề và khoảng cách.
  - `searchable` luôn tạo thanh riêng ở đầu sheet: ô tìm trên phải 183 × 24, cách mép trên và phải 20; Form bắt đầu dưới thanh tìm (y 44).
  - `navigationTitle` không hiện (không có NavigationStack); có NavigationStack thì tiêu đề nằm hàng riêng dưới ô tìm. `ToolbarItem(.navigation / .principal)` không hiện trong sheet.
  - `List` đặt trong `Form(.grouped)` bị tắt cuộn: không thanh cuộn, lăn chuột không đổi hàng; `scrollDisabled(false)` và `\.isScrollEnabled` không bật lại.
- **`DisclosureGroup` trong Form** (thử 02/11/2026, cửa sổ 740 × 560): hàng con không thụt lề, nhưng không có vạch ngăn dưới hàng mở (nhãn hàng con sát 4 pt), và `AXDisclosureTriangle` không có action nào, `AXDisclosing` không ghi được, nên không mở được qua Accessibility API (chưa thử VoiceOver thật).

## Dấu so với chuẩn

Cửa sổ Cài đặt của Dấu dùng số của System Settings ở mọi chỗ trên, trừ các chỗ cố ý khác dưới đây. Cách dựng cửa sổ: [`docs/research/SWIFTUI-WINDOW-API.md`](SWIFTUI-WINDOW-API.md).

| Chỗ | System Settings | Dấu | Lý do |
|---|---|---|---|
| Lề trên form | 12 | 20 (mặc định SwiftUI) | D9: không chỉnh thông số hệ thống; không có API công khai để giảm |
| Ô tìm sidebar | x 10, y 61, 212 × 28; hàng đầu y 98 | `NSSearchField` cỡ lớn, lề 10: y 62, hàng đầu y 100 (app thử) | D9: sidebar cố định không dùng `NavigationSplitView`, nên không có `.searchable(placement: .sidebar)`; không chỉnh lề cho khớp pixel |
| Chiều cao tối thiểu cửa sổ | không đo | 452 (400 dưới thanh công cụ 52) | chọn cho nội dung các trang |
| Hàng "Nâng cao" | không có hàng mở/thu | nút hệ thống + chevron, có AXPress | D9: `DisclosureGroup` thiếu vạch ngăn và không mở được qua trợ năng |
| Khoảng icon ứng dụng → chữ | 9–10 | 8 (`HStack` mặc định) | thông số mặc định |
| Sheet thêm quy tắc (`AddAppRuleSheet`) | không có tiêu đề | hàng đầu: tiêu đề trái, `NSSearchField` phải (183 × 24, cách mép trên và phải 20, cỡ của `searchable` trong sheet); danh sách trong `GroupBox`; `Form(.grouped)` chỉ có thẻ "Khi đang gõ"; thanh nút | mockup có tiêu đề; `searchable` không cho tiêu đề cùng hàng; `List` trong Form không cuộn |
| Chiều cao thẻ danh sách trong sheet | không có số tương ứng | 188, theo mockup | không có số chuẩn để thay |

Chỗ Dấu khớp mà dễ hỏi:
- Cửa sổ mặc định 740 × 560, rộng cố định 740, cao đổi được (`SettingsScene`). Sidebar 232 cố định (`SettingsSplitViewController`).
- Cụm Lùi/Tiến đo trên Dấu (05/11/2026): Lùi x 239,5, Tiến x 275,5, y 8, 36 × 36 và 37 × 36; khung tiêu đề từ x 316,5 (nét chữ của app thử từ x ≈ 326, `Reference.swift`).
- Hàng chỉ có nút căn nút phải như hệ thống.
- Icon ứng dụng: khung 24 cho hàng một dòng kèm control ("Quy tắc riêng", danh sách của sheet thêm quy tắc), như Trợ năng; 32 cho hàng có dòng phụ ("Đề xuất") và thẻ đầu "Cập nhật & hỗ trợ", như Hoạt động nền. Trên cửa sổ thật (màn Retina), nét vẽ icon ở hai chỗ 32 là 26 × 26 từ x 265, trùng System Settings.

## Nguồn API

- `formStyle(.grouped)`: https://developer.apple.com/documentation/swiftui/formstyle/grouped ("A form style with grouped rows", macOS 13+).
- `navigationSplitViewColumnWidth(_:)`: https://developer.apple.com/documentation/swiftui/view/navigationsplitviewcolumnwidth(_:) (macOS 13+).
- `SearchFieldPlacement.sidebar`: https://developer.apple.com/documentation/swiftui/searchfieldplacement/sidebar (macOS 12+).
- `toolbar(removing:)` và `ToolbarDefaultItemKind.sidebarToggle`: https://developer.apple.com/documentation/swiftui/view/toolbar(removing:), https://developer.apple.com/documentation/swiftui/toolbardefaultitemkind/sidebartoggle (macOS 14+, "The sidebar toggle toolbar item a NavigationSplitView adds by default").
- Tài liệu Apple không công bố các số 704, 20, 12, 37,5 hay số nào khác trong file này.
