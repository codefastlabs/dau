# Giao diện

Hành vi, trạng thái và quy tắc của giao diện app Dấu: những gì hình vẽ và mã không tự nói ra. Trang web ở [`docs/Website.md`](Website.md).

## Nguồn của từng phần

- **Trông như thế nào:** canvas mockup https://claude.ai/artifact/B2xhNxL3voGwTkXkFV72Ln, trang "Thiết kế" (mục, thứ tự, icon, trạng thái). Thứ tự sửa: canvas trước, mã sau (D9 (Giao diện)).
  - Bản chụp chỉ đọc trong repo: [`docs/canvas/README.md`](canvas/README.md) (mục lục), `docs/canvas/<Tên>.png` (ảnh), `docs/canvas/src/<Tên>.dc.html` (nguồn artboard, agent đọc file này); sinh lại bằng `scripts/design/render-canvas.sh`.
- **Bố cục, khoảng cách, control:** System Settings của macOS hiện hành (D9). Số đo ở [`docs/research/SystemSettingsReference.md`](research/SystemSettingsReference.md), mức đạt ở [`scripts/selftest/settings-window/Reference.swift`](../scripts/selftest/settings-window/Reference.swift), cách kiểm ở [`docs/UIChecks.md`](UIChecks.md).
- **Chữ:** String Catalog trong mã (`Localizable.xcstrings`), theo D41 (Ngôn ngữ giao diện). Canvas viết tiếng Việt; câu mới giao cho mã kèm câu tiếng Anh làm khoá.
  - Tên giao diện của macOS (System Settings, Keyboard, Input Sources, Allow, Log Out, Applications, Thùng rác, tên bàn phím…) theo D38 (Chữ trên giao diện): đúng như macOS của người dùng đang hiện (`SystemUINames`, `LayoutNames` trong [`docs/Architecture.md`](Architecture.md)).
  - Câu tiếng Việt không dùng chữ "app", nói "ứng dụng".
- **File này** không liệt kê chữ hay bố cục của phần đã có mã; tên nút, nhãn được nêu chỉ để tả hành vi. Phần chưa có mã (cuối file) tạm mô tả nội dung tới khi dựng. Lịch sử duyệt: [`docs/history/DocsLog.md`](history/DocsLog.md).

Khi các nguồn lệch nhau, `Decisions.md` quyết định; sửa bên sai cho khớp.

## Menu nguồn đầu vào

Artboard: [Menu nguồn đầu vào](canvas/Main.png).

- Hệ thống vẽ menu; Dấu không có status item riêng, có một input mode (D2 (Chuyển Việt/Anh)).
- Bộ gõ chỉ bổ sung qua `menu()` của IMK:
  - ba kiểu gõ (Telex, VNI, Telex đơn giản) và "Cài đặt Dấu…";
  - nằm dưới tiêu đề nhóm "Dấu" của hệ thống, không có tiêu đề riêng;
  - không có mục mở Cài đặt Bàn phím vì hệ thống đã có "Open Keyboard Settings…" (N1 (Không làm lại việc hệ thống đã có)).

## Onboarding

Ba bước theo D14 (Onboarding).

### Khung chung

- Thanh bước bên trái có trạng thái xong / đang làm / chưa. Cuối thanh bước chỉ có dòng "Dấu không cần quyền điều khiển máy Mac." (không viết tên mục "Trợ năng" của macOS).
- Mọi bước dùng chung một khung: tiêu đề, mô tả và nội dung cuộn được; hàng nút cố định ở đáy, có đường kẻ phía trên khi nội dung bị che. Nội dung dài không tràn ra ngoài cửa sổ.
- Phím tắt chuyển nguồn ở mọi câu:
  - đọc từ cài đặt hệ thống, không viết cứng (N5 (Chỉ hứa điều đã kiểm chứng));
  - vẽ bằng keycap như trang Gõ phím, mỗi phím một keycap; câu gợi ý ở bước 3 dùng keycap nhỏ theo cỡ chữ gợi ý;
  - không có dòng phụ nào nói phím tắt "hiện đúng trên máy";
  - VoiceOver đọc cả câu, phím tắt viết bằng chữ.
- Không hứa macOS hỏi mấy lần, vì "Thử lại" sau Don't Allow làm hộp thoại hiện lại (N5).

### Trước bước 1: chuyển Dấu vào Applications

Artboard: [OnboardingMoveToApplications](canvas/OnboardingMoveToApplications.png).

- Chỉ hiện khi bản Dấu đang chạy không phải bản chủ và bộ gõ chưa cài (D37 (Cài đặt bộ gõ)). Bộ gõ đã cài thì bản không phải bản chủ mở như thường.
- Thanh bước chưa có bước nào bắt đầu: bản này sẽ được thoát, nên không yêu cầu tắt bộ gõ cũ ở đây.
- Chỉ hướng dẫn, Dấu không tự chuyển mình: một nút mở thư mục Applications trong Finder, một nút thoát Dấu.

### Bước 1: tắt bộ gõ cũ

Artboard: [OnboardingConflict](canvas/OnboardingConflict.png).

- Chỉ hiện khi phát hiện bộ gõ chặn phím đang chạy (bundle ID trong [`docs/research/InputMethodInstall.md`](research/InputMethodInstall.md) mục 8). Lúc mở không có bộ gõ nào chạy thì bỏ qua bước này.
- Hướng dẫn tắt chỉ ghi tên menu đã kiểm chứng. App chưa kiểm thì ghi chung "Thoát `<tên>`" và đường dẫn Mục đăng nhập (N5).
- Tự kiểm tra lại khi cửa sổ được kích hoạt. Cho phép bỏ qua.
- Onboarding không có nút "Quay lại": các bước chỉ đi tới.

### Bước 2: bật Dấu

- Chép bộ gõ vào `~/Library/Input Methods` và đăng ký; chỉ bật nguồn đầu vào khi người dùng bấm "Bật Dấu" (N4 (Không tự đổi cài đặt hệ thống), D37).
- macOS hỏi người dùng có cho Dấu bật không (hộp thoại Allow), nên bước có nhiều màn, mỗi màn một mục dưới đây.
- Kết quả đọc lại từ hệ thống, không báo thành công khi chưa thấy bật (N5).
- Không có Hoàn tác: app không tự tắt được Dấu (macOS chặn), chỉ người dùng bỏ Dấu trong System Settings.

#### Trước khi bấm

Artboard: [OnboardingEnable](canvas/OnboardingEnable.png), [có nguồn tiếng Việt khác, không đọc được phím tắt](canvas/OnboardingEnableNotes.png).

- Thẻ "Sau khi bật, bạn sẽ thấy".
- Thẻ nói trước điều sắp xảy ra (System Settings đóng rồi mở lại, hộp thoại hỏi), kèm hình thu nhỏ hộp thoại của macOS (minh hoạ, ẩn với VoiceOver).
- Phím tắt không đọc được thì hàng phím tắt là một dòng nói vậy kèm nút mở System Settings, không có keycap rỗng.
- Nhắc nhẹ (biểu tượng thông tin) khi có nguồn tiếng Việt kiểu IMK khác đang bật (D14), không chặn.

#### Đang chờ

Artboard: [OnboardingEnableWaiting](canvas/OnboardingEnableWaiting.png).

- Trong lúc `enable()` chờ mục lưu của Dấu: thẻ trạng thái có vòng xoay.
- "Thử lại" huỷ lần chờ đang chạy rồi bật lại (macOS hỏi lại).
- Màn tự chuyển sang "Đã bật" khi macOS ghi mục.

#### Đã bật

Artboard: [OnboardingEnableDone](canvas/OnboardingEnableDone.png), [chưa đặt phím tắt](canvas/OnboardingEnableDoneNoShortcut.png).

- Nút duy nhất "Tiếp tục".
- Câu chọn Dấu nêu phím tắt thật. Chưa đặt phím tắt thì nói vậy và có nút đặt phím tắt trong System Settings. Không đọc được phím tắt thì chỉ nói chọn trong menu nhập liệu, không khẳng định gì về phím tắt, kèm cùng nút.
- Dưới thẻ có một dòng gợi ý: một ứng dụng chưa chọn được Dấu thì đăng xuất (menu Apple › Log Out) rồi đăng nhập lại một lần (D37).

#### Chưa bật được

Artboard: [OnboardingEnableFailed](canvas/OnboardingEnableFailed.png).

- Hết hạn chờ, hoặc macOS không liệt kê Dấu.
- Ba cách theo thứ tự: Thử lại; tự thêm trong System Settings; đăng xuất một lần.
- Không tự mở System Settings, có nút "Mở System Settings".
- Nếu sau đó Dấu xuất hiện (người dùng tự thêm), cửa sổ nhận ra và sang "Đã bật".

#### Lỗi cài

Artboard: [OnboardingEnableError](canvas/OnboardingEnableError.png).

- Một màn "Chưa cài được Dấu" cho hai trường hợp: lỗi chép, kiểm chữ ký hay đăng ký; và bộ gõ đã cài bị thay (chữ ký không hợp lệ, không do Apple cấp, khác Team ID với app hoặc sai định danh bộ gõ, D37). Hai cách xử lý.
- Trường hợp bộ gõ bị thay: màn này thay cho "Trước khi bấm" khi bản đang chạy là bản chủ và bộ gõ đã cài nhưng chưa bật. Bản không phải bản chủ không kiểm chữ ký. Dấu đã bật thì bước 2 vẫn là "Đã bật", banner của cửa sổ Cài đặt lo. Kiểm lại khi cửa sổ được kích hoạt; đang chờ Allow mà phát hiện thì huỷ lần chờ.
- Dòng "Chi tiết" là mô tả thật của lỗi (chọn được để chép).
- "Cài lại" cài bản nhúng của app, không bật: cài xong và chữ ký đúng thì hiện "Trước khi bấm"; còn lỗi thì vẫn màn này.

### Bước 3: chọn kiểu gõ và gõ thử

Artboard: [Onboarding](canvas/Onboarding.png), [Dấu chưa là nguồn đang dùng](canvas/OnboardingNotSelected.png).

- Ví dụ gõ thử phải đúng quy tắc của kiểu gõ đang chọn.
- Dấu chưa phải nguồn đang dùng thì có câu gợi ý cách chọn Dấu, kèm phím tắt thật bằng keycap nếu đọc được (N5).

## Cửa sổ Cài đặt

### Vỏ cửa sổ

Artboard: [tìm không khớp](canvas/SettingsSearchEmpty.png).

- Vỏ cửa sổ và sidebar theo D9: không có cụm Lùi/Tiến, tiêu đề hệ thống, sidebar cố định, menu View không có mục ẩn/hiện sidebar.
- Edit › Find › Find… (⌘F) đưa con trỏ vào ô tìm của sidebar, như System Settings.
- Ô tìm của sidebar khớp tên mục và mọi chữ nhìn thấy trong mục (tiêu đề hàng, tiêu đề nhóm, lựa chọn, nút), không phân biệt hoa thường, dấu, "đ"/"d". Không mục nào khớp thì sidebar hiện trạng thái trống của hệ thống, trang đang mở giữ nguyên.
- Mô tả của một nhóm nằm dưới tiêu đề nhóm, trên thẻ (như System Settings).

### Gõ phím

Artboard: [Gõ phím](canvas/SettingsTyping.png).

- Thẻ xem trước tính bằng engine thật, cập nhật ngay theo kiểu gõ và vị trí dấu.
- Chuyển Việt ↔ Anh là chuyển nguồn đầu vào (D2): hàng phím tắt hiện phím tắt hệ thống hiện tại, nút "Đổi…" mở Cài đặt Bàn phím (N4).

### Thông minh

Artboard: [Thông minh](canvas/SettingsSmart.png), [mở "Nâng cao"](canvas/SettingsSmartAdvanced.png).

- Tự khôi phục từ không phải tiếng Việt (D4 (Từ nước ngoài)): ví dụ trong ghi chú phải khớp hành vi engine (từ trùng thì tiếng Việt thắng, gõ đúp phím dấu để giữ chữ gốc).
- Thêm dấu cho từ đã gõ (D20 (Thêm dấu cho từ đã gõ)): ghi chú nêu phạm vi (không áp dụng ở ứng dụng có quy tắc gạch chân); độ ổn định trên web editor để ô trống cho tới khi đo (N5).
- "Nâng cao" thu gọn, tóm tắt số tuỳ chọn và trạng thái.
  - "Gõ tắt phụ âm" và "Cho phép phụ âm z, f, w, j" loại trừ nhau, bật mục này tắt mục kia (D22 (Gõ tắt loại trừ z, f, w, j)).
  - Với Telex, w đầu từ luôn thành ư nên mục thứ hai chỉ tác dụng với z, f, j (D23 (w → qu chỉ ở VNI)).
  - Cả hai mặc định tắt (D15 (Cài đặt mặc định)).

### Ứng dụng

Artboard: [Ứng dụng](canvas/SettingsApps.png), [chưa có quy tắc riêng](canvas/SettingsAppsEmpty.png).

- "Quy tắc riêng": chỉ các quy tắc đã lưu. Đặt về "Không gạch chân" vẫn giữ quy tắc. Xoá quy tắc (menu chuột phải hoặc Delete) thì ứng dụng đó trở lại mục "Đề xuất".
- "Đề xuất": chỉ hiện khi có ứng dụng trong danh sách tương thích (cờ `suggestUnderline`) đã cài mà chưa có quy tắc.
  - Bấm "Bật gạch chân" mới lưu quy tắc (nguồn đề xuất, giữ nhãn "Đề xuất"); trước đó không lưu gì (D13 (Gạch chân là đường lui cuối cùng)).
  - Dòng phụ giống nhau ở mọi hàng. Ghi chú trong danh sách tương thích là cho người bảo trì, không hiện (N5).
  - Ghi chú của mục chỉ nói khi nào nên chọn gạch chân, không hứa sửa được.
- Ô tìm của trang lọc cả hai mục.

#### Sheet thêm quy tắc (nút +)

Artboard: [thêm quy tắc](canvas/SettingsAppsAdd.png), [chưa chọn](canvas/SettingsAppsAddEmpty.png).

- Danh sách: ứng dụng chưa có quy tắc đã lưu. Ứng dụng trong danh sách tương thích mang nhãn "Đề xuất" và giữ nhãn khi thêm.
- "Thêm" chỉ bật khi ứng dụng đang chọn còn trong danh sách đang lọc. Gõ tìm làm ẩn ứng dụng đang chọn thì bỏ chọn.

### Cập nhật & hỗ trợ

Artboard: [Cập nhật & hỗ trợ](canvas/SettingsAbout.png).

- Tới khi có Sparkle (M7), trang chỉ có thẻ phiên bản, mục "Hỗ trợ" với nút gỡ cài đặt và chú thích quyền riêng tư; không vẽ nút chưa chạy. Phần cập nhật (mục "Chưa có mã") và báo lỗi thêm lại khi chúng chạy được.
- Nút gỡ cài đặt dùng dạng `role: .destructive` của hệ thống (D9); luồng gỡ ở mục "Gỡ cài đặt".
- Chú thích quyền riêng tư giữ đúng nội dung D8 (Không telemetry) và N2 (Bộ gõ không có quyền mạng).

#### Bản phát triển

Artboard: [bản phát triển](canvas/SettingsAboutDev.png).

- Biểu tượng và dòng phiên bản theo D25 (Nhận diện) (loại bản: D7 (Cập nhật và loại bản dựng)): thẻ đầu trang dùng biểu tượng bản phát triển; dòng phiên bản cuối sidebar giống tên và phiên bản ở thẻ đầu trang.
- Dòng tiếp theo là bản của bộ gõ đã cài, thứ thật sự xử lý phím; nó có thể khác bản app đang mở (D37).
  - Commit và chữ ký đọc từ bundle trong `~/Library/Input Methods`, như `scripts/dev/dau-version.sh`.
  - Không có chữ ký thì không ghi "Debug"; không có commit lẫn "Debug" thì ghi số phiên bản của bundle, không có thì "–" (N5); chưa cài thì "Chưa cài bộ gõ".
  - Dòng chỉ hiện sau khi đọc xong.

### Banner

Hiện ở đầu mọi mục Cài đặt.

#### Dấu chưa được bật

Artboard: [SettingsNotEnabled](canvas/SettingsNotEnabled.png), [SettingsBannerStates](canvas/SettingsBannerStates.png).

- Người dùng đã bỏ Dấu khỏi nguồn đầu vào. "Bật lại" bật Dấu rồi đọc lại trạng thái (N4).
- Đang chờ người dùng bấm Allow: banner có vòng xoay; "Thử lại" huỷ lần chờ rồi bật lại.
- Bật được: banner xác nhận nêu phím tắt thật (như onboarding; không đọc được thì không nêu); nút "Ẩn" ẩn banner trong phiên này; không có Hoàn tác.
- macOS vẫn để tắt hoặc lỗi: banner nói chưa bật được, kèm cách tự thêm trong System Settings và "Thử lại" (không tự mở System Settings).
- Chưa cài hoặc macOS chưa liệt kê Dấu: mở cửa sổ thiết lập.

#### Bộ gõ trên máy đã bị thay

Artboard: [SettingsTampered](canvas/SettingsTampered.png).

- Điều kiện như trường hợp bộ gõ bị thay ở màn "Lỗi cài" của onboarding; kiểm lúc mở app và mỗi lần app được đưa lên trước.
- Banner đỏ, nút "Cài lại" chép bản gốc trong app (đã kiểm chữ ký) đè lên.
- Cài lại không được thì banner nói vậy và hướng dẫn gỡ rồi cài lại từ bản tải về.

## Gỡ cài đặt

Artboard: [ConfirmDialogs](canvas/ConfirmDialogs.png), [UninstallRemoveSource](canvas/UninstallRemoveSource.png).

Luồng theo D16 (Bảo trì và gỡ cài đặt): macOS chỉ cho người dùng tự bỏ một nguồn đầu vào, nên gỡ có ba bước. Dấu không có trong nguồn đầu vào thì sau alert xác nhận gỡ luôn, không mở System Settings, không hiện sheet.

- Alert xác nhận (hệ thống):
  - có tuỳ chọn xoá cả cài đặt và quy tắc;
  - nút xác nhận là "Tiếp tục gỡ", chưa xoá gì;
  - nội dung chỉ nói người dùng bỏ Dấu trong System Settings rồi Dấu được chuyển vào Thùng rác.
- Sheet "Bỏ Dấu khỏi nguồn đầu vào" trên cửa sổ Cài đặt:
  - app mở thẳng danh sách Input Sources của System Settings (đã mở sẵn sheet Edit…), không chuyển nguồn đầu vào nào;
  - sheet nêu một bước (chọn Dấu, bấm "–", Done) và chờ mục lưu của Dấu biến mất, không hết hạn;
  - câu nhắc "nếu nút – bị mờ, chọn bàn phím khác" chỉ hiện khi Dấu đang là nguồn được chọn; đọc lại khi sheet hiện, khi cửa sổ thành key lại và khi nguồn đang chọn đổi, nên biến mất khi người dùng chuyển bàn phím;
  - "Huỷ gỡ cài đặt" (hoặc Esc, đóng sheet, hoặc gỡ lỗi giữa chừng) đóng sheet và không xoá hay đổi gì;
  - "Mở System Settings" chỉ mở trang.
- Mục lưu biến mất thì: dừng bộ gõ, chuyển vào Thùng rác, xoá dữ liệu nếu đã tick, rồi alert nêu những gì đã làm (đọc lại từ hệ thống).
- Bộ gõ không bao giờ bị xoá khi mục lưu còn: bundle mất trước thì mục còn lại không gỡ được.
- App không tự xoá chính nó, chỉ hướng dẫn kéo vào Thùng rác.

Quay về bản trước: D19 (Quay về bản trước), chưa có ở bản thử đầu.

## Khi gõ trong ứng dụng

Artboard: [TypingStates](canvas/TypingStates.png).

- Không gạch chân (mặc định).
- Có gạch chân: từ đang gõ được gạch, chốt khi kết thúc từ (D13).
- Gõ tiếng Anh bằng U.S.: chỉ báo của hệ thống (D2).
- Thêm dấu cho từ đã gõ (D20).

## Chế độ tối

Artboard: [SettingsDark](canvas/SettingsDark.png).

Cài đặt và onboarding đều có, bằng màu hệ thống (D9).

## Chưa có mã (M7)

Mô tả nội dung tới khi dựng. Mọi câu hứa ở đây phải kiểm chứng ở M7 (N5).

### Thẻ cập nhật

Artboard: [Trạng thái thẻ cập nhật](canvas/UpdateStates.png).

Sáu trạng thái:

- đã mới nhất;
- đang kiểm tra;
- đang tải (thanh tiến trình, "Bạn vẫn gõ bình thường", nút Huỷ);
- chờ cài ("Sẽ cài khi bạn ngừng gõ", nút Cài ngay);
- không có mạng (nút Thử lại, "Dấu vẫn gõ bình thường");
- chữ ký không hợp lệ ("Đã huỷ bản cập nhật", nút Báo lỗi…).

### Thông báo cập nhật

Artboard: [Thông báo cập nhật](canvas/Update.png).

- Icon app, "Đã có Dấu x.y.z", mô tả, "Có gì mới".
- Dòng "Đã xác minh chữ ký số của bản cập nhật".
- Checkbox "Tự động cài các bản sau".
- Nút: Cài đặt / Nhắc sau / Bỏ qua bản này.

### Báo ứng dụng gõ lỗi

Artboard: [Báo ứng dụng gõ lỗi](canvas/Report.png).

- Đầu sheet có ô gợi ý "Ứng dụng không chọn được Dấu?": đăng xuất rồi đăng nhập lại một lần; thoát rồi mở lại ứng dụng thì chưa đủ; vẫn lỗi thì gửi báo lỗi (D37).
- Các trường: Ứng dụng (tự điền), Trang web (không bắt buộc), Loại lỗi (Mất chữ, Lặp chữ, Sai dấu, Khác), Ví dụ đã gõ.
- Mục "Gửi kèm" liệt kê phiên bản macOS, phiên bản Dấu, kiểu gõ, phiên bản của ứng dụng gõ lỗi, và câu "Không gửi nội dung bạn đã gõ."
- Ghi rõ issue GitHub là công khai.
- Nút: Huỷ / Sao chép nội dung / Mở trên GitHub (issue điền sẵn, D8).
