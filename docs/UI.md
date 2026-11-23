# Giao diện

Tài liệu này ghi hành vi, trạng thái và quy tắc của giao diện app Dấu, tức là những điều mà hình vẽ và mã không tự nói ra. Trang web tả ở [`docs/Website.md`](Website.md).

## Nguồn của từng phần

- **Trông như thế nào:** hình dáng của giao diện nằm trên canvas mockup https://claude.ai/artifact/B2xhNxL3voGwTkXkFV72Ln, trang "Thiết kế", gồm mục, thứ tự, icon và trạng thái. Khi sửa, sửa canvas trước, mã sau (D9 (Giao diện)).
  - Repo giữ một bản chụp chỉ đọc của canvas. Mục lục nằm ở [`docs/canvas/README.md`](canvas/README.md), ảnh nằm ở `docs/canvas/<Tên>.png` và nguồn artboard nằm ở `docs/canvas/src/<Tên>.dc.html`; agent đọc file nguồn này. Bản chụp sinh lại bằng `scripts/design/render-canvas.sh`.
- **Bố cục, khoảng cách, control:** phần này theo System Settings của macOS hiện hành (D9). Số đo nằm ở [`docs/research/SystemSettingsReference.md`](research/SystemSettingsReference.md), mức đạt nằm ở [`scripts/selftest/settings-window/Reference.swift`](../scripts/selftest/settings-window/Reference.swift). Cách kiểm nằm ở [`docs/UIChecks.md`](UIChecks.md).
- **Chữ:** chữ nằm trong String Catalog của mã (`Localizable.xcstrings`) và theo D41 (Ngôn ngữ giao diện). Canvas viết bằng tiếng Việt; câu mới giao cho mã kèm câu tiếng Anh làm khoá.
  - Tên giao diện của macOS (System Settings, Keyboard, Input Sources, Allow, Log Out, Applications, Thùng rác, tên bàn phím…) theo D38 (Chữ trên giao diện). Dấu ghi đúng như macOS của người dùng đang hiện, qua `SystemUINames` và `LayoutNames` (xem [`docs/Architecture.md`](Architecture.md)).
  - Câu tiếng Việt không dùng chữ "app" mà nói "ứng dụng".
- **File này:** file không liệt kê chữ hay bố cục của phần đã có mã. Tên nút và nhãn nêu ra chỉ để tả hành vi. Phần chưa có mã, nếu có, nằm ở cuối file và tạm mô tả nội dung cho tới khi dựng xong. Lịch sử duyệt nằm ở [`docs/history/DocsLog.md`](history/DocsLog.md).

Khi các nguồn lệch nhau, `Decisions.md` quyết định. Người viết sửa bên sai cho khớp.

## Menu nguồn đầu vào

Artboard: [Menu nguồn đầu vào](canvas/Main.png).

- Hệ thống vẽ menu này. Dấu không có status item riêng và chỉ có một input mode (D2 (Chuyển Việt/Anh)).
- Bộ gõ chỉ thêm mục vào menu qua `menu()` của IMK:
  - Các mục thêm vào là ba kiểu gõ (Telex, VNI, Telex đơn giản) và "Cài đặt Dấu…".
  - Các mục này nằm dưới tiêu đề nhóm "Dấu" của hệ thống và không có tiêu đề riêng.
  - Menu không có mục mở Cài đặt Bàn phím, vì hệ thống đã có "Open Keyboard Settings…" (N1 (Không làm lại việc hệ thống đã có)).

## Onboarding

Onboarding có ba bước theo D14 (Onboarding).

### Khung chung

- Thanh bước bên trái cho biết mỗi bước đã xong, đang làm hay chưa làm. Cuối thanh bước chỉ có dòng "Dấu không cần quyền điều khiển máy Mac." và không viết tên mục "Trợ năng" của macOS.
- Mọi bước dùng chung một khung. Tiêu đề, mô tả và nội dung cuộn được; hàng nút cố định ở đáy và có đường kẻ phía trên khi nội dung bị che. Nội dung dài không tràn ra ngoài cửa sổ.
- Phím tắt chuyển nguồn xuất hiện trong nhiều câu. Ở mọi câu nó theo các luật sau:
  - Phím tắt đọc từ cài đặt hệ thống, không viết cứng (N5 (Chỉ hứa điều đã kiểm chứng)).
  - Phím tắt vẽ bằng keycap như ở trang Gõ phím, mỗi phím một keycap. Câu gợi ý ở bước 3 dùng keycap nhỏ theo cỡ chữ gợi ý.
  - Không có dòng phụ nào nói phím tắt "hiện đúng trên máy".
  - VoiceOver đọc cả câu. Phím tắt viết bằng chữ cho VoiceOver.
- Onboarding không hứa macOS sẽ hỏi bao nhiêu lần, vì bấm "Thử lại" sau Don't Allow làm hộp thoại hiện lại (N5).

### Trước bước 1: chuyển Dấu vào Applications

Artboard: [OnboardingMoveToApplications](canvas/OnboardingMoveToApplications.png).

- Màn này chỉ hiện khi bản Dấu đang chạy không phải bản chủ và bộ gõ chưa được cài (D37 (Cài bộ gõ)). Nếu bộ gõ đã được cài thì bản không phải bản chủ vẫn mở như thường.
- Trên thanh bước, chưa bước nào bắt đầu. Bản đang chạy sẽ được thoát, nên màn này không yêu cầu tắt bộ gõ cũ.
- Màn này chỉ hướng dẫn. Dấu không tự chuyển chính nó. Màn có một nút mở thư mục Applications trong Finder và một nút thoát Dấu.

### Bước 1: tắt bộ gõ cũ

Artboard: [OnboardingConflict](canvas/OnboardingConflict.png).

- Bước này chỉ hiện khi Dấu phát hiện một bộ gõ chặn phím đang chạy (danh sách bundle ID nằm ở [`docs/research/InputMethodInstall.md`](research/InputMethodInstall.md), mục 8). Nếu lúc mở không có bộ gõ nào như vậy đang chạy thì onboarding bỏ qua bước này.
- Hướng dẫn tắt chỉ ghi tên menu đã kiểm chứng. Với app chưa kiểm, hướng dẫn ghi chung "Thoát `<tên>`" kèm đường dẫn tới Mục đăng nhập (N5).
- Bước này tự kiểm tra lại mỗi khi cửa sổ được kích hoạt. Người dùng có thể bỏ qua bước này.
- Onboarding không có nút "Quay lại", vì các bước chỉ đi tới.

### Bước 2: bật Dấu

- Dấu chép bộ gõ vào `~/Library/Input Methods` và đăng ký nó. Dấu chỉ bật nguồn đầu vào khi người dùng bấm "Bật Dấu" (N4 (Không tự đổi cài đặt hệ thống), D37).
- macOS hỏi người dùng có cho Dấu bật hay không (hộp thoại Allow), nên bước này có nhiều màn. Mỗi màn tả ở một mục dưới đây.
- Kết quả đọc lại từ hệ thống. Bước này không báo thành công khi chưa thấy Dấu đã bật (N5).
- Bước này không có Hoàn tác. App không tự tắt được Dấu vì macOS chặn việc đó; chỉ người dùng mới bỏ được Dấu khỏi nguồn đầu vào trong System Settings.

#### Trước khi bấm

Artboard: [OnboardingEnable](canvas/OnboardingEnable.png), [có nguồn tiếng Việt khác, không đọc được phím tắt](canvas/OnboardingEnableNotes.png).

- Màn này có thẻ "Sau khi bật, bạn sẽ thấy".
- Một thẻ nói trước điều sắp xảy ra: System Settings đóng rồi mở lại và một hộp thoại hỏi người dùng. Thẻ kèm hình thu nhỏ hộp thoại của macOS; hình này chỉ để minh hoạ và ẩn với VoiceOver.
- Nếu không đọc được phím tắt, hàng phím tắt là một dòng nói điều đó kèm nút mở System Settings và không có keycap rỗng.
- Khi có một nguồn tiếng Việt kiểu IMK khác đang bật, màn này nhắc nhẹ bằng biểu tượng thông tin (D14) và không chặn người dùng.

#### Đang chờ

Artboard: [OnboardingEnableWaiting](canvas/OnboardingEnableWaiting.png).

- Trong lúc `enable()` chờ mục lưu của Dấu, thẻ trạng thái có vòng xoay.
- "Thử lại" huỷ lần chờ đang chạy rồi bật lại. macOS hỏi lại.
- Màn tự chuyển sang "Đã bật" khi macOS ghi mục lưu.

#### Đã bật

Artboard: [OnboardingEnableDone](canvas/OnboardingEnableDone.png), [chưa đặt phím tắt](canvas/OnboardingEnableDoneNoShortcut.png).

- Màn này chỉ có một nút là "Tiếp tục".
- Câu hướng dẫn chọn Dấu nêu phím tắt thật. Nếu người dùng chưa đặt phím tắt, câu nói điều đó và có nút đặt phím tắt trong System Settings. Nếu không đọc được phím tắt, câu chỉ nói chọn Dấu trong menu nhập liệu, không khẳng định gì về phím tắt và vẫn có cùng nút đó.
- Dưới thẻ có một dòng gợi ý: nếu một ứng dụng chưa chọn được Dấu, người dùng đăng xuất (menu Apple › Log Out) rồi đăng nhập lại một lần (D37).

#### Chưa bật được

Artboard: [OnboardingEnableFailed](canvas/OnboardingEnableFailed.png).

- Màn này hiện khi hết hạn chờ hoặc khi macOS không liệt kê Dấu.
- Màn đưa ba cách theo thứ tự: bấm Thử lại, tự thêm Dấu trong System Settings và đăng xuất một lần.
- Dấu không tự mở System Settings, mà có nút "Mở System Settings".
- Nếu sau đó Dấu xuất hiện vì người dùng tự thêm, cửa sổ nhận ra điều đó và chuyển sang "Đã bật".

#### Lỗi cài

Artboard: [OnboardingEnableError](canvas/OnboardingEnableError.png).

- Một màn "Chưa cài được Dấu" dùng cho hai trường hợp, với hai cách xử lý. Trường hợp thứ nhất là lỗi khi chép, khi kiểm chữ ký hay khi đăng ký. Trường hợp thứ hai là bộ gõ đã cài bị thay: chữ ký không hợp lệ, không do Apple cấp, khác Team ID với app hoặc sai định danh bộ gõ (D37).
- Với trường hợp bộ gõ bị thay, màn này thay cho màn "Trước khi bấm" khi bản đang chạy là bản chủ và bộ gõ đã cài nhưng chưa bật. Bản không phải bản chủ không kiểm chữ ký. Nếu Dấu đã bật thì bước 2 vẫn là "Đã bật". Banner của cửa sổ Cài đặt lo việc này. Dấu kiểm lại mỗi khi cửa sổ được kích hoạt; nếu phát hiện trong lúc đang chờ Allow thì Dấu huỷ lần chờ.
- Dòng "Chi tiết" là mô tả thật của lỗi. Người dùng chọn được để chép.
- "Cài lại" làm cùng một việc cho mọi nguyên nhân (chép lỗi, đăng ký lỗi, bộ gõ bị thay): nó chép lại bản nhúng của app rồi đăng ký, nhưng không bật. Nếu cài xong và chữ ký đúng, màn "Trước khi bấm" hiện ra. Dấu chỉ bật khi người dùng bấm "Bật Dấu". Nếu vẫn còn lỗi thì màn này vẫn hiện, với "Chi tiết" mới. Bản không phải bản chủ không chép (D37), nên với bản đó "Cài lại" chỉ đăng ký và bật lại bộ gõ đã cài.

### Bước 3: chọn kiểu gõ và gõ thử

Artboard: [Onboarding](canvas/Onboarding.png), [Dấu chưa là nguồn đang dùng](canvas/OnboardingNotSelected.png).

- Ví dụ gõ thử phải đúng quy tắc của kiểu gõ đang chọn.
- Nếu Dấu chưa phải nguồn đang dùng, màn có câu gợi ý cách chọn Dấu, kèm phím tắt thật bằng keycap nếu đọc được (N5).

## Cửa sổ Cài đặt

### Vỏ cửa sổ

Artboard: [tìm không khớp](canvas/SettingsSearchEmpty.png).

- Vỏ cửa sổ và sidebar theo D9. Cửa sổ không có cụm nút Lùi/Tiến và không có tiêu đề hệ thống, sidebar cố định và menu View không có mục ẩn hay hiện sidebar.
- Edit › Find › Find… (⌘F) đưa con trỏ vào ô tìm của sidebar, như System Settings.
- Ô tìm của sidebar khớp tên mục và mọi chữ nhìn thấy trong mục (tiêu đề hàng, tiêu đề nhóm, lựa chọn, nút). Phép tìm không phân biệt chữ hoa với chữ thường, không phân biệt có dấu hay không và coi "đ" như "d". Khi không mục nào khớp, sidebar hiện trạng thái trống của hệ thống và trang đang mở giữ nguyên.
- Mô tả của một nhóm nằm dưới tiêu đề nhóm và trên thẻ, như System Settings.

### Gõ phím

Artboard: [Gõ phím](canvas/SettingsTyping.png).

- Thẻ xem trước tính bằng engine thật và cập nhật ngay khi kiểu gõ hay vị trí dấu thay đổi.
- Chuyển Việt ↔ Anh là chuyển nguồn đầu vào (D2). Vì vậy hàng phím tắt hiện phím tắt hiện tại của hệ thống. Nút "Đổi…" mở Cài đặt Bàn phím (N4).

### Thông minh

Artboard: [Thông minh](canvas/SettingsSmart.png), [mở "Nâng cao"](canvas/SettingsSmartAdvanced.png).

- Với "Tự khôi phục từ không phải tiếng Việt" (D4 (Từ nước ngoài)), ví dụ trong ghi chú phải khớp hành vi của engine: khi từ trùng nhau thì tiếng Việt thắng và gõ đúp phím dấu để giữ chữ gốc.
- Với "Thêm dấu cho từ đã gõ" (D20 (Thêm dấu cho từ đã gõ)), ghi chú nêu phạm vi: tính năng không áp dụng ở ứng dụng có quy tắc gạch chân. Độ ổn định trên web editor để ô trống cho tới khi đo (N5).
- Nhóm "Nâng cao" thu gọn và tóm tắt số tuỳ chọn cùng trạng thái của chúng.
  - "Gõ tắt phụ âm" và "Cho phép phụ âm z, f, w, j" loại trừ nhau: bật mục này thì mục kia tắt (D22 (Gõ tắt loại trừ z, f, w, j)).
  - Với Telex, w ở đầu từ luôn thành ư, nên mục thứ hai chỉ có tác dụng với z, f, j (D23 (w → qu chỉ ở VNI)).
  - Cả hai mục mặc định tắt (D15 (Cài đặt mặc định)).

### Ứng dụng

Artboard: [Ứng dụng](canvas/SettingsApps.png), [chưa có quy tắc riêng](canvas/SettingsAppsEmpty.png).

- Mục "Quy tắc riêng" chỉ chứa các quy tắc đã lưu. Đặt một quy tắc về "Không gạch chân" vẫn giữ quy tắc đó. Khi người dùng xoá quy tắc (bằng menu chuột phải hoặc phím Delete), ứng dụng đó trở lại mục "Đề xuất".
- Mục "Đề xuất" chỉ hiện khi có ứng dụng trong danh sách tương thích (cờ `suggestUnderline`) đã được cài mà chưa có quy tắc.
  - Quy tắc chỉ lưu khi người dùng bấm "Bật gạch chân"; quy tắc đó có nguồn là đề xuất và giữ nhãn "Đề xuất". Trước khi bấm, Dấu không lưu gì (D13 (Gạch chân là đường lui cuối cùng)).
  - Dòng phụ giống nhau ở mọi hàng. Ghi chú trong danh sách tương thích dành cho người bảo trì và không hiện lên giao diện (N5).
  - Ghi chú của mục chỉ nói khi nào nên chọn gạch chân và không hứa sửa được lỗi.
- Ô tìm của trang lọc cả hai mục.

#### Sheet thêm quy tắc (nút +)

Artboard: [thêm quy tắc](canvas/SettingsAppsAdd.png), [chưa chọn](canvas/SettingsAppsAddEmpty.png).

- Danh sách trong sheet gồm các ứng dụng chưa có quy tắc đã lưu. Ứng dụng nằm trong danh sách tương thích mang nhãn "Đề xuất" và giữ nhãn đó khi thêm.
- Nút "Thêm" chỉ bật khi ứng dụng đang chọn còn nằm trong danh sách đang lọc. Nếu gõ tìm làm ẩn ứng dụng đang chọn, sheet bỏ chọn ứng dụng đó.

### Cập nhật & hỗ trợ

Artboard: [Cập nhật & hỗ trợ](canvas/SettingsAbout.png).

- **Phần cập nhật chỉ có ở bản phát hành**, tức bản có URL appcast và khoá công khai (D7 (Cập nhật và loại bản dựng)). Phần này gồm bốn thứ: dòng kiểm tra lần cuối và nút kiểm tra trong thẻ phiên bản, hàng công tắc tự động kiểm tra và hàng "Kênh phát hành". Bản phát triển không có thứ nào trong bốn thứ đó.
  - Thông báo, tải và cài bản mới dùng cửa sổ của Sparkle (D7). Trang không vẽ trạng thái tải hay cài.
  - Nút kiểm tra bị tắt trong lúc Sparkle đang kiểm tra hoặc đang có một phiên cập nhật.
  - Nếu chưa kiểm lần nào, dòng kiểm tra lần cuối nói điều đó và không hiện giờ (N5).
  - Công tắc đọc và ghi lựa chọn của chính Sparkle (`automaticallyChecksForUpdates`, mặc định bật theo Info.plist); Dấu không có khoá riêng cho nó.
  - Câu dưới công tắc ("khi bạn mở Dấu, tối đa mỗi ngày một lần", "hỏi bạn trước khi cài") chưa được kiểm trên bản phát hành. Lượt chạy Sparkle cập nhật của M7 sẽ kiểm câu này (N5).
  - Hàng "Kênh phát hành" (D7, ý "Kênh") là một nút chia đoạn Beta / Chính thức. Khi appcast chưa có bản chính thức, lựa chọn Chính thức vẫn hiện nhưng bị tắt. Dòng phụ nói chưa có bản chính thức nào. Khi appcast đã có, dòng phụ nói rằng chuyển sang Chính thức thì Dấu giữ bản đang dùng cho tới khi có bản chính thức mới hơn. Hàng này chỉ hiện sau lần tải appcast thành công đầu tiên, vì trước đó Dấu chưa biết đã có bản chính thức hay chưa (N5). Lúc hàng chưa hiện không có artboard riêng: trang giống artboard, chỉ thiếu hàng này.
- Dòng phiên bản ở thẻ đầu trang và ở cuối sidebar theo D25. Bản phát hành ghi số build trong ngoặc ("Dấu 0.1.0 (6520)"), còn bản phát triển ghi commit.
- Nút "Báo lỗi…" mở sheet "Báo ứng dụng gõ lỗi" ở mọi loại bản (xem mục con bên dưới).
- Nút gỡ cài đặt dùng kiểu `role: .destructive` của hệ thống (D9). Luồng gỡ tả ở mục "Gỡ cài đặt".
- Chú thích về quyền riêng tư giữ đúng nội dung của D8 (Không telemetry) và N2 (Bộ gõ không có quyền mạng).
- Cuối trang là mục "Người ủng hộ" (D39 (Ủng hộ dự án)); artboard [cuộn xuống](canvas/SettingsAboutSupporters.png) vẽ mục này.
  - Mục liệt kê tên người ủng hộ. Danh sách đi kèm bản Dấu đang chạy, nên app không tải gì qua mạng; chỉ người đã đồng ý mới được nêu tên.
  - Mục không hiện số tiền và không xếp thứ tự theo số tiền.
  - Hàng "Ủng hộ dự án" có nút "Ủng hộ…" mở mục Góp sức của trang web trong trình duyệt.

#### Báo ứng dụng gõ lỗi

Artboard: [Báo ứng dụng gõ lỗi](canvas/Report.png).

- Người dùng chỉ báo lỗi qua GitHub issue điền sẵn (D8). Nút "Mở trên GitHub" mở trang issue mới của repo trong trình duyệt; người dùng đọc lại rồi tự gửi ở đó. Dấu không tự gửi gì (N2) và không có đường báo lỗi qua email.
- URL chỉ mang những gì sheet hiện: bốn trường và các mục "Gửi kèm". Mẫu issue nằm ở `.github/ISSUE_TEMPLATE/typing-problem.yml`. Mỗi trường điền theo `id` của nó.
- Trường "Ứng dụng" tự chọn ứng dụng người dùng vừa dùng ngay trước Dấu. Danh sách gồm các ứng dụng đang chạy, cộng với ứng dụng vừa dùng nếu nó đã thoát. Dấu chỉ giữ ứng dụng đó trong bộ nhớ cho sheet, không lưu và không ghi nhật ký (D8).
- Trường "Trang web" không bắt buộc, vì Dấu không đọc được trang đang mở trong trình duyệt nếu không xin quyền (N4).
- Mục "Gửi kèm" gồm phiên bản macOS, dòng phiên bản kèm commit (D25: "Dấu 0.1.0 (6520, a1b2c3d)"), kiểu gõ, quy tắc gạch chân của ứng dụng đã chọn (D5, D13) và phiên bản của ứng dụng đó; nếu không đọc được phiên bản thì bỏ mục này (N5). Ô "Ví dụ đã gõ" có được gửi, nên sheet không hứa "không gửi chữ đã gõ".
- Ô gợi ý ở đầu sheet là đường lui của D37 cho ứng dụng không chọn được Dấu: người dùng đăng xuất một lần. Tên mục menu trong ô là tên của macOS (D38).

#### Bản phát triển

Artboard: [bản phát triển](canvas/SettingsAboutDev.png).

- Biểu tượng và dòng phiên bản theo D25 (Nhận diện); các loại bản theo D7 (Cập nhật và loại bản dựng). Thẻ đầu trang dùng biểu tượng bản phát triển. Dòng phiên bản ở cuối sidebar giống tên và phiên bản ở thẻ đầu trang. Trang không có dòng ghi loại bản.
- Dòng tiếp theo ghi bản của bộ gõ đã cài, là thứ thật sự xử lý phím. Bản này có thể khác bản app đang mở (D37).
  - Commit và chữ ký đọc từ bundle trong `~/Library/Input Methods`, giống `scripts/dev/dau-version.sh`.
  - Nếu không có chữ ký thì dòng không ghi "Debug". Nếu không có cả commit lẫn "Debug" thì dòng ghi số phiên bản của bundle; nếu cũng không có số đó thì ghi "–" (N5). Nếu bộ gõ chưa được cài thì dòng ghi "Chưa cài bộ gõ".
  - Dòng này chỉ hiện sau khi Dấu đọc xong.

### Banner

Banner hiện ở đầu mọi mục Cài đặt.

#### Dấu chưa được bật

Artboard: [SettingsNotEnabled](canvas/SettingsNotEnabled.png), [SettingsBannerStates](canvas/SettingsBannerStates.png).

- Banner này hiện khi người dùng đã bỏ Dấu khỏi nguồn đầu vào. Nút "Bật lại" bật Dấu rồi đọc lại trạng thái (N4).
- Trong lúc chờ người dùng bấm Allow, banner có vòng xoay. "Thử lại" huỷ lần chờ rồi bật lại.
- Khi bật được, banner xác nhận và nêu phím tắt thật, như onboarding; nếu không đọc được phím tắt thì banner không nêu. Nút "Ẩn" ẩn banner trong phiên này. Banner không có Hoàn tác.
- Nếu macOS vẫn để Dấu tắt hoặc gặp lỗi, banner nói chưa bật được, kèm cách tự thêm Dấu trong System Settings và nút "Thử lại". Dấu không tự mở System Settings.
- Khi Dấu chưa được cài hoặc macOS chưa liệt kê Dấu, nút "Bật lại" mở cửa sổ thiết lập.

#### Bộ gõ trên máy đã bị thay

Artboard: [SettingsTampered](canvas/SettingsTampered.png).

- Banner này hiện theo cùng điều kiện với trường hợp bộ gõ bị thay ở màn "Lỗi cài" của onboarding. Dấu kiểm lúc mở app và mỗi lần app lên trước.
- Banner có màu đỏ. Nút "Cài lại" chép bản gốc trong app, đã được kiểm chữ ký, đè lên bộ gõ trên máy.
- Nếu cài lại không được, banner nói điều đó và hướng dẫn gỡ Dấu rồi cài lại từ một bản tải mới.

## Gỡ cài đặt

Artboard: [ConfirmDialogs](canvas/ConfirmDialogs.png), [UninstallRemoveSource](canvas/UninstallRemoveSource.png), [UninstallDone](canvas/UninstallDone.png).

Luồng gỡ theo D16 (Bảo trì và gỡ cài đặt). macOS chỉ cho người dùng tự bỏ một nguồn đầu vào, nên việc gỡ có ba bước. Nếu Dấu không có trong nguồn đầu vào, app gỡ luôn sau alert xác nhận, không mở System Settings và không hiện sheet.

- Bước đầu là alert xác nhận của hệ thống:
  - Alert có tuỳ chọn xoá cả cài đặt và quy tắc.
  - Nút xác nhận là "Tiếp tục gỡ". Bấm nút này chưa xoá gì.
  - Nội dung alert chỉ nói rằng người dùng bỏ Dấu khỏi nguồn đầu vào trong System Settings, rồi bộ gõ và ứng dụng Dấu chuyển vào Thùng rác.
- Bước tiếp theo là sheet "Bỏ Dấu khỏi nguồn đầu vào" trên cửa sổ Cài đặt:
  - App mở thẳng danh sách Input Sources của System Settings, với sheet Edit… đã mở sẵn và không chuyển nguồn đầu vào nào.
  - Sheet nêu một bước (chọn Dấu, bấm "–", bấm Done) và chờ mục lưu của Dấu biến mất, không có hạn chờ.
  - Câu nhắc "nếu nút – bị mờ, chọn bàn phím khác" chỉ hiện khi Dấu đang là nguồn được chọn. Sheet đọc lại điều này khi sheet hiện, khi cửa sổ thành key lại và khi nguồn đang chọn đổi, nên câu nhắc biến mất khi người dùng chuyển bàn phím.
  - "Huỷ gỡ cài đặt" (hoặc phím Esc, đóng sheet hay một lỗi gỡ giữa chừng) đóng sheet mà không xoá hay đổi gì.
  - Nút "Mở System Settings" chỉ mở trang đó.
- Khi mục lưu biến mất, app dừng bộ gõ, chuyển nó vào Thùng rác, xoá dữ liệu nếu người dùng đã tick, rồi chuyển chính nó vào Thùng rác. Sau đó app hiện alert nêu những gì đã làm; nội dung alert đọc lại từ hệ thống.
  - Khi chuyển được cả app, alert có tiêu đề "Đã gỡ Dấu" và một nút "Thoát Dấu".
  - Khi không chuyển được app, alert có tiêu đề "Đã gỡ bộ gõ Dấu" và một nút "Hiển thị trong Finder". Nút này mở Finder, chọn sẵn app để người dùng kéo vào Thùng rác, rồi app thoát.
- Bộ gõ không bao giờ bị xoá khi mục lưu còn, vì nếu bundle mất trước thì mục còn lại không gỡ được.

Quay về bản trước theo D19 (Quay về bản trước) và chưa có ở beta đầu tiên.

## Khi gõ trong ứng dụng

Artboard: [TypingStates](canvas/TypingStates.png).

Artboard này tả các trạng thái sau:

- Trạng thái mặc định là không gạch chân.
- Khi có gạch chân, từ đang gõ có gạch chân và chốt khi kết thúc từ (D13).
- Khi gõ tiếng Anh bằng bàn phím U.S., chỉ có chỉ báo của hệ thống (D2).
- Trạng thái thêm dấu cho từ đã gõ theo D20.

## Chế độ tối

Artboard: [SettingsDark](canvas/SettingsDark.png).

Cửa sổ Cài đặt và onboarding đều có chế độ tối, dùng màu hệ thống (D9).
