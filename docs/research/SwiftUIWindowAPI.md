# Cửa sổ Cài đặt: API Apple cho sidebar, thanh công cụ, tiêu đề

Cửa sổ Cài đặt của app chủ dựng theo System Settings (D9 (Giao diện)). File này ghi API Apple nào làm việc gì cho sidebar, thanh công cụ, tiêu đề và Lùi/Tiến (cụm này đã bỏ 13/11/2026), có nguồn, và vì sao Dấu dựng cửa sổ như hiện nay. Mã: `SettingsWindow` (`Apps/Dau/Sources/SettingsWindow.swift`). Số đo giao diện ở [`docs/research/SystemSettingsReference.md`](SystemSettingsReference.md).

## Hiện trạng (13/11/2026)

- **Sidebar cố định bằng split view của chính app** (mục 1): scene SwiftUI chứa `NSSplitViewController` do app tạo (`SettingsSplitViewController`), mục sidebar không thu được, độ dày tối thiểu bằng tối đa. Sidebar và trang vẫn là view SwiftUI trong `NSHostingController`. Không với vào view nào SwiftUI dựng.
- **SwiftUI không có API khoá sidebar của `NavigationSplitView`** (mục 2). Độ rộng chỉ là "ưu tiên", `columnVisibility` chỉ là "điều khiển bằng mã"; tra chỉ mục tài liệu SwiftUI và `SwiftUI.swiftinterface` không thấy API nào khác.
- **Lùi/Tiến là `ControlGroup` kiểu `.navigation` ở `ToolbarItemPlacement.navigation`**, lịch sử do app tự giữ (SwiftUI không có), kèm lệnh trong menu View (mục 3, 5). Dấu đã bỏ cụm này ngày 13/11/2026 (D9: bốn trang không cần); kết quả nghiên cứu giữ để tham khảo.
- **Tiêu đề trang là `navigationTitle` của hệ thống**, ở mép trái thanh công cụ, như System Settings (trước 13/11/2026 nằm sau cụm Lùi/Tiến); macOS không có placement nào để thay tiêu đề bằng view tự vẽ (mục 3).
- **Trang không có mục nào trên thanh thì cửa sổ mất thanh công cụ** (đo 13/11/2026: Gõ phím, Thông minh, Cập nhật & hỗ trợ). Apple không có API đặt chiều cao thanh hay giữ thanh khi không còn mục; thanh cao 52 với tiêu đề cùng hàng chỉ có khi cửa sổ có thanh công cụ (mục 3, "Chiều cao thanh công cụ"). Ứng viên đáng đo, chưa đo: `toolbar(.visible, for: .windowToolbar)` (API có thiết kế, chỉ là gợi ý), rồi `ToolbarSpacer` ở trang không có mục (cách vá, macOS 26+). Không có mục thật, hữu ích nào cho mọi trang.
- **Ô tìm sidebar là `NSSearchField` cỡ lớn**, vì `searchable(placement: .sidebar)` cần sidebar của `NavigationSplitView` (mục 4).
- Phiên bản macOS ghi trong file là phiên bản Apple ghi trên trang tài liệu. D1 (Nền tảng) đặt tối thiểu macOS 14, nên API cần macOS 15 trở lên phải có `if #available`.

Nhãn nguồn: **[Tài liệu]** trang tài liệu API của Apple; **[HIG]** Human Interface Guidelines; **[WWDC]** bản ghi lời phiên WWDC; **[SDK]** đọc từ `SwiftUI.swiftinterface` và header AppKit (macOS SDK 27.2), chỉ chứng minh API có hay không và comment trong header; **[Đo trên app thử]** app thử ném đi (`build/probe-fixed-sidebar/`, ID riêng), không phải Dấu; **[Đo của Dấu]** đo trên Dấu; **[Suy luận, cần kiểm chứng]** Apple không viết thẳng.

## 1. Sidebar cố định: `NSSplitViewController` của app

API AppKit dùng:
- [Tài liệu] `NSSplitViewItem(sidebarWithViewController:)` (macOS 10.11+): sidebar có sẵn "the ability to collapse and expand on split view size changes", `canCollapse` mặc định `true`. https://developer.apple.com/documentation/appkit/nssplitviewitem/init(sidebarwithviewcontroller:)
- [Tài liệu] `canCollapse` (macOS 10.10+): "determines whether a **user interaction** can collapse the child view controller". `canCollapseFromWindowResize` (macOS 10.14+) riêng cho thu gọn do co cửa sổ; "Setting `canCollapse` for sidebars resets this value to that new value", nên đặt sau. `minimumThickness`/`maximumThickness` (macOS 10.11+). https://developer.apple.com/documentation/appkit/nssplitviewitem/cancollapse
- [Tài liệu] `NSSplitViewController.toggleSidebar(_:)` (macOS 10.11+): thu/mở sidebar đầu tiên. Dấu giữ hành động này luôn tắt. https://developer.apple.com/documentation/appkit/nssplitviewcontroller/togglesidebar(_:)
- [Tài liệu] `NSHostingController.sceneBridgingOptions` (macOS 14+): phần nào của cửa sổ do hosting controller quản lý; trang đặt `[.toolbars, .title]`, sidebar đặt rỗng.
- [WWDC] WWDC22 "Use SwiftUI with AppKit": Shortcuts dùng `NSSplitViewController` của AppKit, sidebar viết bằng SwiftUI trong `NSHostingController`. https://developer.apple.com/videos/play/wwdc2022/10075/

[Đo trên app thử] 06/11/2026, macOS 27.2, đo qua Accessibility với `scripts/selftest/settings-window/Reference.swift` làm chuẩn:

| Cấu hình | Sidebar giữ 232 (kéo, bấm đúp, `AXSplitter`, đổi cỡ) | Thanh công cụ, tiêu đề, Lùi/Tiến so với chuẩn | ⌘[ ⌘] trong menu View | Ô tìm sidebar |
|---|---|---|---|---|
| Scene `Window` SwiftUI + `NSViewControllerRepresentable` bọc split view, `.searchable(placement: .sidebar)` | có | khớp | chạy | lên thanh công cụ |
| Như trên + `NSSearchField` `controlSize = .large` (lề 10) | có | khớp | chạy | lệch chuẩn 1–2 pt; gõ "upd" lọc còn một mục |
| `NSWindow` do app tạo | có | khớp | **không chạy** (`focusedSceneValue` không tới cửa sổ AppKit); menu View thêm "Show Tab Bar", "Show All Tabs" | lên thanh công cụ |
| `NSWindow` do app tạo + `NSToolbar` AppKit (`sidebarTrackingSeparator`, nhóm `isNavigational`) | có | Lùi/Tiến lệch | không chạy | lên thanh công cụ |
| `NSWindow` do app tạo, đường chia để AppKit tự quản | có | khớp | không chạy | con trỏ đổi cỡ hiện ở đường chia |

- Dấu dùng cấu hình thứ hai. Con trỏ ở đường chia là mũi tên thường nhờ `splitView(_:effectiveRect:forDrawnRect:ofDividerAt:)` trả `.zero`.
- 20 lần đổi cỡ cửa sổ 740 ↔ 976 trên app thử: trung vị 9,7 ms, tối đa 22,2 ms mỗi lần; sidebar không lệch lần nào. Không có số so sánh với `NavigationSplitView`.
- [Đo của Dấu] Sidebar cố định đã kiểm trên cửa sổ thật bằng `scripts/selftest/settings-window/run.sh` (trang `sidebar-fixed`, [`docs/UIChecks.md`](../UIChecks.md)).

## 2. Vì sao không dùng `NavigationSplitView`

- [Tài liệu] `navigationSplitViewColumnWidth(_:)`: "Sets a **fixed, preferred** width"; bản `min:ideal:max:` là "flexible, preferred". Cả hai: "Only some platforms enable resizing columns. If you specify a width that the current presentation environment doesn't support, SwiftUI may use a different width". Trang `NavigationSplitView`: "does its best to accommodate the preferences that you specify, but might make adjustments". https://developer.apple.com/documentation/swiftui/view/navigationsplitviewcolumnwidth(_:), https://developer.apple.com/documentation/swiftui/navigationsplitview
- [Tài liệu] `init(columnVisibility:sidebar:detail:)`: "enables **programmatic control** of the sidebar's visibility"; `NavigationSplitViewVisibility`: "Some platforms don't respect every option". Không câu nào nói binding chặn người dùng thu gọn. https://developer.apple.com/documentation/swiftui/navigationsplitviewvisibility
- [Tài liệu] `navigationSplitViewStyle` (`.balanced`, `.prominentDetail`) chỉ đổi cách cột chi tiết co giãn khi sidebar ẩn/hiện. https://developer.apple.com/documentation/swiftui/navigationsplitviewstyle
- [SDK] Không có API nào khác để khoá sidebar.
- [Đo của Dấu] Bản dùng `NavigationSplitView` (trước 06/11/2026): đường chia vẫn kéo được dù độ rộng cố định, kéo có thể thu gọn sidebar mà không có cách mở lại.
- [HIG] Sidebars và Split views khuyên cân nhắc cho ẩn sidebar, và nếu cho thì "Provide multiple ways to reveal hidden panes". System Settings không cho thu gọn sidebar (số đo ở `SystemSettingsReference.md`), nên Dấu theo System Settings và không cần lệnh mở lại. https://developer.apple.com/design/human-interface-guidelines/sidebars, https://developer.apple.com/design/human-interface-guidelines/split-views
- Khoá sidebar của `NavigationSplitView` bằng cách tìm `NSSplitView` mà nó dựng thì dựa trên cấu trúc bên trong SwiftUI không công bố; D9 đã loại cách này. Chặn thu gọn bằng `columnVisibility` không có tài liệu ủng hộ; hướng này đã bỏ, không đo.
- [WWDC] Apple nói System Settings dựng bằng SwiftUI, "built using the navigation split view and stacks" (WWDC22 "What's new in SwiftUI"), nhưng không nói sidebar của nó cố định bằng cách nào. https://developer.apple.com/videos/play/wwdc2022/10052/

## 3. Thanh công cụ, tiêu đề, Lùi/Tiến

### Chiều cao thanh công cụ

Câu hỏi: không có cụm Lùi/Tiến (D9), làm sao để trang không có mục nào trên thanh (Gõ phím, Thông minh, Cập nhật & hỗ trợ) vẫn giữ thanh 52 với tiêu đề lớn ở mép trái, như trang Ứng dụng và System Settings (số ở `SystemSettingsReference.md`).

Hiện trạng đo:
- [Đo của Dấu] 13/11/2026, macOS 27.2, máy M1: ba trang đó không còn thanh công cụ (ax-check "toolbar: missing"), nút đóng ở 8,8 thay vì 18,18, tiêu đề thành chữ tiêu đề cửa sổ nhỏ (tâm y 15,3 thay vì 26); trang Ứng dụng ("+" và ô tìm) giữ thanh đầy đủ, nên đổi trang làm khung cửa sổ đổi chiều cao. Số đo cũ trên app thử `NavigationSplitView` cùng kết quả (`SystemSettingsReference.md`, mục "Hành vi SwiftUI khác hệ thống", ý "Nút sidebar").

Kết luận từ tài liệu (13/11/2026):
- **Thanh cao với tiêu đề cùng hàng là của cửa sổ có thanh công cụ.** Apple tả hai loại cửa sổ: có thanh công cụ và chỉ có thanh tiêu đề.
  - [SDK] `NSWindow.h`, `toolbarStyle`: "Specifies how the titlebar area of the window should appear **when the window displays an NSToolbar**"; `NSWindowToolbarStyleUnified`: "The window title will appear inline with the toolbar when visible". https://developer.apple.com/documentation/appkit/nswindow/toolbarstyle-swift.property
  - [WWDC] WWDC25 "Build an AppKit app with the new design": "Windows with toolbars now use a larger radius … Titlebar-only windows retain a smaller corner radius, wrapping compactly around the window controls." https://developer.apple.com/videos/play/wwdc2025/310/
- **Không có API đặt chiều cao thanh, hay giữ thanh khi không còn mục.** Tra `SwiftUI.swiftinterface`, header AppKit, tài liệu, HIG và các phiên WWDC dẫn trong mục này: không có. SwiftUI dựng thanh từ các mục: `toolbar(content:)` "Populates the toolbar or navigation bar with the specified items"; Apple không ghi SwiftUI làm gì khi không còn mục nào. https://developer.apple.com/documentation/swiftui/view/toolbar(content:)
- **API duy nhất nói về sự có mặt của cả thanh là `toolbar(_:for:)` với `.windowToolbar`**, và giá trị `.visible` chỉ là gợi ý (ứng viên 1 dưới đây).
- **Không có mục thật, hữu ích nào cho mọi trang** (mục "Mục thật cho mọi trang" dưới đây). Mục thật duy nhất System Settings dùng là cụm Lùi/Tiến, D9 đã bỏ.
- [Suy luận, cần kiểm chứng] Theo câu WWDC25 ở trên, trên macOS 26 trở lên, đổi giữa trang Ứng dụng và trang không có mục còn làm đổi bán kính góc cửa sổ, ngoài chiều cao khung. Chưa đọc trên ảnh chụp.

Ứng viên, xếp theo thứ tự nên thử. "Dự đoán" là suy luận, chưa đo; "đạt" nghĩa là ba trang ra như trang Ứng dụng hiện nay: có thanh, nút đóng 18,18, tâm y tiêu đề 26, đổi trang không đổi khung.

| # | Ứng viên | Tài liệu nói | Có từ | Loại | Dự đoán (chưa đo) | Đo? |
|---|---|---|---|---|---|---|
| 1 | `.toolbar(.visible, for: .windowToolbar)` trên trang (`SettingsDetail`, trong host có `.toolbars`) và trên gốc scene (`SettingsWindow`) | "Specifies the visibility of a bar managed by SwiftUI"; `.windowToolbar`: "The placement for the containing window's toolbar"; "Depending on the specified bars, the requested visibility may not be able to be fulfilled"; `Visibility.visible`: "The element may be visible … a hint or preference, rather than a mandatory assertion". Ví dụ của Apple chỉ có `.hidden`. https://developer.apple.com/documentation/swiftui/view/toolbar(_:for:), https://developer.apple.com/documentation/swiftui/toolbarplacement/windowtoolbar, https://developer.apple.com/documentation/swiftui/visibility/visible | macOS 13; macOS 15 đổi tên thành `toolbarVisibility(_:for:)`, tên cũ chỉ đánh dấu đổi tên, không hạn bỏ ([SDK]); không cần `if #available` | API có thiết kế | Khả năng cao không đổi gì: `.visible` là gợi ý và tài liệu chỉ tả việc ẩn. Nếu SwiftUI giữ một `NSToolbar` không có mục thì có thể đạt, nhưng thanh không có mục có cao 52 không thì AppKit cũng không ghi | có |
| 1b | Như 1, thêm `.windowToolbarStyle(.unified(showsTitle: true))` cho scene `Window` | "A window toolbar style which displays its toolbar and title bar inline". https://developer.apple.com/documentation/swiftui/unifiedwindowtoolbarstyle | macOS 11 | API có thiết kế | Riêng nó không đổi gì: kiểu thanh chỉ áp khi cửa sổ có `NSToolbar` (header ở trên), và trang Ứng dụng cho thấy `.automatic` đã ra kiểu unified có tiêu đề cùng hàng | gộp với 1, không đo riêng |
| 2 | `ToolbarSpacer(.flexible)` ở trang không có mục (nhánh không có ô tìm của `PageSearch`), trong `if #available(macOS 26, *)` | "A standard space item in toolbars. A space item creates visual breaks in the toolbar between items." https://developer.apple.com/documentation/swiftui/toolbarspacer | macOS 26 | Cách vá: mục giữ chỗ, dù là mục chuẩn của hệ thống (không control, không nền kính); trang Ứng dụng đã dùng nó để đẩy "+" và ô tìm sang phải | Đạt: cửa sổ có thanh với một mục khoảng trống, như trang Ứng dụng. macOS 14–25 không có `ToolbarSpacer`, thanh vẫn co ở đó (Dấu mới thử trên macOS 27.2) | có |
| 3 | Mục tự làm rỗng, ví dụ `ToolbarItem { Color.clear.frame(width: 1, height: 1) }` | Không có tài liệu cho mục rỗng. macOS 26 đặt nền kính chung sau mục, bỏ bằng `sharedBackgroundVisibility(.hidden)`. https://developer.apple.com/documentation/swiftui/toolbarcontent/sharedbackgroundvisibility(_:) | macOS 11 (bỏ nền: macOS 26) | Cách vá, kém hơn 2: view tự làm, có thể hiện với trợ năng như một mục trống | có thể đạt cả trên macOS 14–25 | không, trừ khi cần cho macOS 14–25 |
| 4 | `NSToolbar` của AppKit gắn vào cửa sổ (`view.window` của `SettingsSplitViewController`), trang chỉ bắc cầu `.title`; "+" và ô tìm của trang Ứng dụng viết lại bằng `NSToolbarItem`, `NSSearchToolbarItem` | `NSHostingSceneBridgingOptions.toolbars`: "Toolbars populated in this manner **overwrite any toolbar set on the window using AppKit**." https://developer.apple.com/documentation/swiftui/nshostingscenebridgingoptions/toolbars. Host gốc mà scene `Window` tạo có bắc cầu thanh không thì Apple không ghi | macOS 11 | API có thiết kế nhưng hai bên cùng đặt thanh, không có kết quả trong tài liệu; viết lại trang Ứng dụng; cửa sổ AppKit có `NSToolbar` đã cho Lùi/Tiến lệch trên app thử (mục 1) | Không đoán được: SwiftUI có thể ghi đè thanh của app | không, chỉ xét khi 1 và 2 đều không đạt |
| 5 | `.unifiedCompact` | "similar to unified, but with a more compact vertical sizing". https://developer.apple.com/documentation/swiftui/unifiedcompactwindowtoolbarstyle | macOS 11 | API có thiết kế, sai việc | Trang Ứng dụng cũng thấp đi, lệch 52 của System Settings; trang không có mục vẫn không có thanh | loại |
| 6 | `.expanded` | "displays its title bar area above the toolbar". https://developer.apple.com/documentation/swiftui/expandedwindowtoolbarstyle | macOS 11 | sai việc | Tiêu đề lên hàng riêng, khác System Settings | loại |
| 7 | `toolbarBackground(.visible, for: .windowToolbar)` (macOS 13), `toolbarBackgroundVisibility` (macOS 15) | "Specifies the preferred visibility of backgrounds on a bar managed by SwiftUI". https://developer.apple.com/documentation/swiftui/view/toolbarbackgroundvisibility(_:for:) | macOS 13 / 15 | sai việc: nền của một thanh đã có | không đổi | loại |
| 8 | `toolbar(removing:)`, `ToolbarDefaultItemKind` | "Remove a toolbar item present by default"; chỉ có `.sidebarToggle` (macOS 14), `.title` (macOS 15), `.search` (macOS 26). Không có API thêm mục mặc định. https://developer.apple.com/documentation/swiftui/view/toolbar(removing:), https://developer.apple.com/documentation/swiftui/toolbardefaultitemkind | macOS 14 | sai việc | không đổi | loại |
| 9 | `navigationSubtitle` (`NSWindow.subtitle`) | "A secondary line of text that appears in the title bar of the window". https://developer.apple.com/documentation/appkit/nswindow/subtitle | macOS 11 | thêm nội dung, không phải mục thanh | Không có tài liệu nói phụ đề làm thanh cao lên; System Settings không có phụ đề; cần artboard | loại |
| 10 | `NSTitlebarAccessoryViewController` | "manages a custom view … in the title bar–toolbar area of a window". https://developer.apple.com/documentation/appkit/nstitlebaraccessoryviewcontroller | macOS 10.10 | cách vá, cần với vào `NSWindow` | Thêm một dải dưới thanh tiêu đề; tiêu đề vẫn nhỏ, nút đóng vẫn 8,8 | loại |
| 11 | `titlebarSeparatorStyle`, `NSToolbar.displayMode`, `windowToolbarFullScreenVisibility`, `windowToolbarLabelStyle` | Vạch ngăn dưới thanh; cách hiện nhãn mục; thanh khi toàn màn hình; kiểu nhãn mục. https://developer.apple.com/documentation/appkit/nswindow/titlebarseparatorstyle, https://developer.apple.com/documentation/appkit/nstoolbar/displaymode-swift.property, https://developer.apple.com/documentation/swiftui/windowtoolbarfullscreenvisibility | macOS 11 / 15 | sai việc | không đổi | loại |
| 12 | Tiêu đề tự vẽ (`PageTitle`, `.principal`) | `ToolbarItemPlacement.title`, `.largeTitle` không có trên macOS (ý "Tiêu đề" dưới đây) | — | D9 cấm tự vẽ tiêu đề | — | loại |

Mục thật cho mọi trang (lựa chọn sản phẩm, không phải mục giữ chỗ):
- System Settings: mọi pane đã đo chỉ có cụm Lùi/Tiến và tiêu đề trên thanh (`SystemSettingsReference.md`). Nó giữ thanh nhờ Lùi/Tiến.
- Nút trợ giúp: [HIG] Buttons, "Use a help button within a view, not in the window frame. For example, avoid placing a help button in a toolbar". Dấu cũng không có sách trợ giúp (menu Help chỉ có "Setup Guide…"). Loại. https://developer.apple.com/design/human-interface-guidelines/buttons
- Ô tìm trên thanh ở mọi trang: trùng ô tìm sidebar, và trang Ứng dụng có ô tìm riêng của nó. Loại.
- Mục trạng thái: [Tài liệu] `ToolbarItemPlacement.status` (macOS 11), "Status items are informational in nature … In macOS …, the system places status items in the center of the toolbar". https://developer.apple.com/documentation/swiftui/toolbaritemplacement/status. Nội dung có thể có là Dấu đang bật hay không, nhưng banner "Dấu chưa được bật" trong trang đã làm việc này (D9), và System Settings không có mục như vậy. Đổi nội dung nên cần artboard và người dùng chọn; không đề xuất.
- Ba trang chỉ có toggle, picker và nút gắn với một hàng ("Change…", "Uninstall…"), không có hành động cấp trang nào để đưa lên thanh.
- [HIG] Settings: "use a noncustomizable toolbar that remains visible" (viết cho cửa sổ cài đặt có thanh nút chuyển pane): ủng hộ thanh ổn định giữa các trang, không nói cách làm. https://developer.apple.com/design/human-interface-guidelines/settings

Đo gì: một lượt `scripts/selftest/settings-window/run.sh`, mỗi ứng viên một cờ Debug của Dấu (ví dụ `--toolbar-variant visible | visible-unified | spacer`), mỗi biến thể một lần mở cửa sổ. Mỗi lần đọc trên bốn trang: có thanh không (AX), khung nút đóng, tâm y và x của tiêu đề, khung cửa sổ trước và sau khi đổi trang, ảnh chụp (cả góc cửa sổ); với `spacer` thêm: thanh không có phần tử nào bấm được hay đọc được ngoài tiêu đề. Chọn theo thứ tự: 1 đạt thì dùng 1 (API có thiết kế); không thì 2, ghi lý do "tài liệu không có API giữ thanh khi không có mục" cạnh mã; 2 cũng không đạt thì người dùng chọn giữa chấp nhận thanh co (ghi vào "Hệ quả đã chấp nhận" của D9, vì lệch chuẩn System Settings) và ứng viên 4.

### Tiêu đề và chỗ đặt nút

Tiêu đề:
- [Tài liệu] `navigationTitle`: "on macOS, the primary destination's title is used as the window title in the titlebar, Windows menu and Mission Control." https://developer.apple.com/documentation/swiftui/view/navigationtitle(_:)
- [WWDC] WWDC20 "Adopt the new look of macOS": kiểu unified "supports the new inline title, which is placed at the leading edge of the toolbar, next to the sidebar". https://developer.apple.com/videos/play/wwdc2020/10104/
- [HIG] Settings: "Update the window's title to reflect the currently visible pane." https://developer.apple.com/design/human-interface-guidelines/settings
- [Tài liệu] Trên macOS không có chỗ hợp lệ cho tiêu đề tự vẽ: `ToolbarItemPlacement.title`, `.largeTitle` chỉ có iOS/iPadOS/Mac Catalyst; `toolbarTitleDisplayMode(_:)` "has no effect on macOS". https://developer.apple.com/documentation/swiftui/toolbaritemplacement/title, https://developer.apple.com/documentation/swiftui/view/toolbartitledisplaymode(_:)
- [Tài liệu] `toolbarRole`: trên macOS `.automatic` là `.editor`; `.browser`, `.navigationStack` không có macOS. https://developer.apple.com/documentation/swiftui/toolbarrole

Chỗ đặt nút:
- [Tài liệu] `ToolbarItemPlacement.navigation`: "the forward and back buttons of a web browser are navigation actions. In macOS …, the system places navigation items in the leading edge of the toolbar **ahead of the inline title if that is present**." https://developer.apple.com/documentation/swiftui/toolbaritemplacement/navigation
- [WWDC] WWDC20: "back and forward … belong to the leading edge of the window … they can't be moved out of this title-leading position."
- [HIG] Toolbars: "Elements that let people return to the previous document and show or hide a sidebar appear at the far leading edge, followed by the view title"; "Make every toolbar item available as a command in the menu bar." https://developer.apple.com/design/human-interface-guidelines/toolbars
- [Tài liệu] `ControlGroup` (macOS 12+): "displays semantically-related controls in a visually-appropriate manner for the context". https://developer.apple.com/documentation/swiftui/controlgroup

Lùi/Tiến:
- [SDK] SwiftUI không có API lịch sử Lùi/Tiến cho split view; `NavigationStack` chỉ có Lùi, xoá khỏi ngăn xếp là mất. https://developer.apple.com/documentation/swiftui/navigationstack
- Apple không ghi System Settings làm Lùi/Tiến thế nào. Dấu từng tự giữ lịch sử (`SectionHistory`, đã bỏ cùng cụm Lùi/Tiến 13/11/2026).
- [Đo của Dấu] Khi cụm còn: có cụm ở `.navigation` thì thanh và tiêu đề đúng chuẩn System Settings. Gắn `.toolbar` của cụm lên trang trong cột chi tiết thì đổi trang làm mục dựng lại, và AXPress trên Lùi/Tiến trả lỗi -25205 dù vẫn chạy (System Settings trả 0); Dấu khi đó gắn cụm quanh trang, không đổi theo trang. Mục gắn theo trang (như ứng viên 2 ở "Chiều cao thanh công cụ") cũng dựng lại khi đổi trang.

Kiểu cửa sổ (tham khảo):
- [Tài liệu] `ToolbarDefaultItemKind.title` (macOS 15+) với `toolbar(removing:)` ẩn tiêu đề mà cửa sổ vẫn giữ tên ("it will be used by accessibility", WWDC24 "Tailor macOS windows with SwiftUI"). Không cần khi dùng tiêu đề hệ thống. https://developer.apple.com/documentation/swiftui/toolbardefaultitemkind/title, https://developer.apple.com/videos/play/wwdc2024/10148/
- [Tài liệu] `WindowResizability.automatic`: "`Settings` windows use the `contentSize` strategy, while all others use `contentMinSize`." Dấu dùng scene `Window` với `.windowResizability(.contentSize)`. https://developer.apple.com/documentation/swiftui/windowresizability
- [HIG] Settings khuyên "Restore the most recently viewed pane". Cửa sổ Cài đặt chỉ có bốn mục và mở ở mục Gõ phím mỗi lần; không làm.

## 4. Ô tìm ở sidebar: `NSSearchField` thay `searchable`

- [Tài liệu] `SearchFieldPlacement.sidebar` (macOS 12+): "In macOS the search field appears as a sticky header in the sidebar, attached to the toolbar. If a sidebar isn't available … SwiftUI uses automatic placement instead." https://developer.apple.com/documentation/swiftui/searchfieldplacement/sidebar
- [Đo trên app thử] Không có `NavigationSplitView` thì ô tìm này lên thanh công cụ (mục 1).
- Dấu dùng `NSSearchField` (`SidebarSearchField`) trong `safeAreaInset` ở đầu sidebar, lề chuẩn 10, cỡ `.large` đặt cả phía AppKit (`controlSize`) lẫn phía SwiftUI (`.controlSize(.large)`).
- [Đo trên app thử] Chiều cao `NSSearchField` theo `controlSize` (`intrinsicContentSize`): mini 16, small 20, regular 24, large 28, extraLarge 36.
- Lúc mở cửa sổ, tiêu điểm đặt vào danh sách bằng `focused(_:)` khi danh sách hiện ra (`defaultFocus` không có tác dụng trong hosting controller này); Edit › Find (⌘F) đưa tiêu điểm vào ô tìm bằng `makeFirstResponder(_:)`. https://developer.apple.com/documentation/swiftui/view/focused(_:), https://developer.apple.com/documentation/appkit/nswindow/makefirstresponder(_:)

## 5. Lệnh menu View

- [Tài liệu] `CommandGroupPlacement.sidebar`: "By default, this group includes the following commands in macOS: Show/Hide Sidebar, Enter/Exit Full Screen." https://developer.apple.com/documentation/swiftui/commandgroupplacement/sidebar
- [Tài liệu] `SidebarCommands`: "These commands are optional and can be explicitly requested". https://developer.apple.com/documentation/swiftui/sidebarcommands
- [Tài liệu] `CommandGroup(replacing:)` thay toàn bộ nhóm, nên thay nhóm `.sidebar` sẽ bỏ cả mục toàn màn hình. https://developer.apple.com/documentation/swiftui/commandgroup/init(replacing:addition:)
- [HIG] Menu View: "Show/Hide Sidebar — In a window that includes a sidebar, toggles the sidebar's visibility." https://developer.apple.com/design/human-interface-guidelines/the-menu-bar
- Dấu (tới 13/11/2026, khi cụm Lùi/Tiến còn): `SettingsHistoryCommands` thêm Lùi ⌘[ và Tiến ⌘] **trước** nhóm `.sidebar` (`CommandGroup(before:)`), không dùng `SidebarCommands`. Menu View còn mục toàn màn hình, không có Show/Hide Sidebar; `SettingsSplitViewController` giữ `toggleSidebar(_:)` luôn tắt. Kiểm bằng `swift test` ("Settings window shell", [`docs/UIChecks.md`](../UIChecks.md)); chưa đọc riêng menu View trên cửa sổ thật.

## Nguồn Apple đã tra

Chỉ nguồn chính thức: tài liệu developer.apple.com (đọc qua dạng JSON `https://developer.apple.com/tutorials/data/documentation/…json`), HIG, bản ghi lời phiên WWDC, và `SwiftUI.swiftinterface` cùng header AppKit (`NSWindow.h`, `NSToolbar.h`) của macOS SDK 27.2 trong Xcode. Link nằm cạnh từng câu ở các mục trên. Thêm:
- [WWDC] Platforms State of the Union (WWDC22): System Settings "was built using [SwiftUI]". https://developer.apple.com/videos/play/wwdc2022/102/
- [WWDC] "The SwiftUI cookbook for navigation" (WWDC22): "NavigationStack represents a push-pop interface like you see in … the new System Settings app". https://developer.apple.com/videos/play/wwdc2022/10054/
- [Tài liệu] `NSTrackingSeparatorToolbarItem` (macOS 11+): vạch ngăn thanh công cụ đi theo đường chia split view. https://developer.apple.com/documentation/appkit/nstrackingseparatortoolbaritem
- [Tài liệu] `NSWindow.toolbarStyle`, `NSWindow.titleVisibility`. https://developer.apple.com/documentation/appkit/nswindow/toolbarstyle-swift.property, https://developer.apple.com/documentation/appkit/nswindow/titlevisibility-swift.property

## Phụ lục: cách vá đã gỡ và API thay thế

Bản cửa sổ trước 05–06/11/2026 có các cách vá dưới đây; tất cả đã gỡ.

| Cách vá đã gỡ | Vì sao từng có | Thay bằng |
|---|---|---|
| `PageTitle`: tiêu đề 15 đậm tự vẽ, đặt ở `ToolbarItem(.navigation)` | thanh không còn mục nào thì tiêu đề hệ thống co lại | `navigationTitle` + cụm Lùi/Tiến ở `.navigation` (05/11) |
| `HiddenWindowTitle`: đặt `NSWindow.titleVisibility = .hidden` qua `NSViewRepresentable` | không cho tiêu đề hệ thống hiện cùng `PageTitle` | không cần khi dùng tiêu đề hệ thống (05/11) |
| `RemoveToolbarTitle`: `toolbar(removing: .title)` từ macOS 15 | không cho tiêu đề vẽ hai lần | không cần (05/11) |
| `FixedSidebar`: tìm `NSSplitView` mà `NavigationSplitView` dựng, đặt `canCollapse = false`, phủ view chặn chuột lên đường chia, xoá khoá autosave | sidebar kéo thu được mà không mở lại được | `NSSplitViewController` của chính app (06/11, mục 1) |
| `CommandGroup(replacing: .sidebar) {}` | bỏ Show/Hide Sidebar | `CommandGroup(before: .sidebar)` không dùng `SidebarCommands` (mục 5) |
