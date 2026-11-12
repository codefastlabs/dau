# Cửa sổ Cài đặt: API Apple cho sidebar, thanh công cụ, tiêu đề

Cửa sổ Cài đặt của app chủ dựng theo System Settings (D9 (Giao diện)). File này ghi API Apple nào làm việc gì cho sidebar, thanh công cụ, tiêu đề và Lùi/Tiến, có nguồn, và vì sao Dấu dựng cửa sổ như hiện nay. Mã: `SettingsWindow` (`Apps/Dau/Sources/SettingsWindow.swift`), `SettingsHistoryButtons` và `SettingsHistoryCommands` (`Apps/Dau/Sources/SettingsHistory.swift`). Số đo giao diện ở [`docs/research/SystemSettingsReference.md`](SystemSettingsReference.md).

## Hiện trạng (11/11/2026)

- **Sidebar cố định bằng split view của chính app** (mục 1): scene SwiftUI chứa `NSSplitViewController` do app tạo (`SettingsSplitViewController`), mục sidebar không thu được, độ dày tối thiểu bằng tối đa. Sidebar và trang vẫn là view SwiftUI trong `NSHostingController`. Không với vào view nào SwiftUI dựng.
- **SwiftUI không có API khoá sidebar của `NavigationSplitView`** (mục 2). Độ rộng chỉ là "ưu tiên", `columnVisibility` chỉ là "điều khiển bằng mã"; tra chỉ mục tài liệu SwiftUI và `SwiftUI.swiftinterface` không thấy API nào khác.
- **Lùi/Tiến là `ControlGroup` kiểu `.navigation` ở `ToolbarItemPlacement.navigation`**, lịch sử do app tự giữ (SwiftUI không có), kèm lệnh trong menu View (mục 3, 5). Dấu đã bỏ cụm này ngày 13/11/2026 (D9: bốn trang không cần); kết quả nghiên cứu giữ để tham khảo.
- **Tiêu đề trang là `navigationTitle` của hệ thống**, nằm ngay sau cụm Lùi/Tiến như System Settings; macOS không có placement nào để thay tiêu đề bằng view tự vẽ (mục 3).
- **Ô tìm sidebar là `NSSearchField` cỡ lớn**, vì `searchable(placement: .sidebar)` cần sidebar của `NavigationSplitView` (mục 4).
- Phiên bản macOS ghi trong file là phiên bản Apple ghi trên trang tài liệu. D1 (Nền tảng) đặt tối thiểu macOS 14, nên API cần macOS 15 trở lên phải có `if #available`.

Nhãn nguồn: **[Tài liệu]** trang tài liệu API của Apple; **[HIG]** Human Interface Guidelines; **[WWDC]** bản ghi lời phiên WWDC; **[SDK]** đọc từ `SwiftUI.swiftinterface` (macOS SDK 27.2), chỉ chứng minh API có hay không; **[Đo trên app thử]** app thử ném đi (`build/probe-fixed-sidebar/`, ID riêng), không phải Dấu; **[Đo của Dấu]** đo trên Dấu; **[Suy luận, cần kiểm chứng]** Apple không viết thẳng.

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

Chiều cao thanh công cụ:
- Không có trang tài liệu, mục HIG hay phiên WWDC nào tả chiều cao thanh khi không còn mục nào.
- [Đo của Dấu] Không còn mục nào thì thanh co lại và tiêu đề thành chữ tiêu đề cửa sổ nhỏ; có cụm Lùi/Tiến ở `.navigation` thì thanh và tiêu đề đúng chuẩn System Settings (số ở `SystemSettingsReference.md`).
- [Đo của Dấu] Gắn `.toolbar` của cụm lên trang trong cột chi tiết thì đổi trang làm mục dựng lại, và AXPress trên Lùi/Tiến trả lỗi -25205 dù vẫn chạy. Dấu gắn cụm quanh trang, ở `SettingsDetailChrome`, không đổi theo trang; System Settings trả 0.

Kiểu thanh công cụ và cửa sổ (tham khảo):
- [Tài liệu] `windowToolbarStyle(_:)`: `.unified`, `.unified(showsTitle:)`, `.unifiedCompact`, `.expanded`. https://developer.apple.com/documentation/swiftui/windowtoolbarstyle
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

Chỉ nguồn chính thức: tài liệu developer.apple.com (đọc qua dạng JSON `https://developer.apple.com/tutorials/data/documentation/…json`), HIG, bản ghi lời phiên WWDC, và `SwiftUI.swiftinterface` của macOS SDK 27.2 trong Xcode. Link nằm cạnh từng câu ở các mục trên. Thêm:
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
