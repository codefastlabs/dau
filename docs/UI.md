# Giao diện

Mỗi phần của giao diện có một nguồn:

- **Trông như thế nào:** canvas mockup https://claude.ai/artifact/B2xhNxL3voGwTkXkFV72Ln (mục, thứ tự, icon, trạng thái), sửa trước mỗi thay đổi giao diện, người dùng duyệt rồi mới sửa mã (D9). Canvas có hai trang: "Thiết kế" là nơi sửa; "Lưu trữ 06/11 (không sửa)" giữ mockup gốc trước khi cập nhật theo giao diện đã dựng, chỉ để đối chiếu (artboard tên `Archive-…`).
- **Bố cục, khoảng cách, control:** System Settings của macOS hiện hành (D9). Số đo ở `docs/research/SYSTEM-SETTINGS-REFERENCE.md`, mức đạt ở `scripts/selftest/settings-window/Reference.swift`.
- **Chữ:** String Catalog trong mã (`Localizable.xcstrings`), khoá là câu tiếng Anh, có bản tiếng Việt; ngôn ngữ hiện ra theo D41. Canvas viết tiếng Việt; câu mới giao cho mã kèm câu tiếng Anh làm khoá.
- **File này:** chỉ ghi hành vi, trạng thái, quy tắc và lý do — những gì hình vẽ và mã không tự nói ra. Không liệt kê chữ hay bố cục của phần đã có mã. Phần chưa có mã (cuối file) tạm mô tả nội dung cho tới khi dựng.

Khi các nguồn lệch nhau, `DECISIONS.md` quyết định; sửa bên sai cho khớp.

## Menu nguồn nhập liệu (hệ thống vẽ)
- Không có status item riêng. Dấu có một input mode (D2); gõ tiếng Anh bằng nguồn U.S. (hoặc nguồn tiếng Anh khác) của người dùng.
- Bộ gõ chỉ bổ sung qua `menu()` của IMK: ba kiểu gõ (Telex, VNI, Telex đơn giản) và "Cài đặt Dấu…", nằm dưới tiêu đề nhóm "Dấu" của hệ thống; không có tiêu đề riêng, không có mục mở Cài đặt Bàn phím vì hệ thống đã có "Open Keyboard Settings…" (N1).

## Onboarding
- Mọi tên giao diện của macOS trong chữ của Dấu (System Settings, Keyboard, Input Sources, Edit…, Allow…) hiện đúng như macOS của người dùng, theo ngôn ngữ hệ thống (D38; `docs/ARCHITECTURE.md`, `SystemUINames`); câu tiếng Việt nói "nguồn đầu vào", không nói "nguồn nhập liệu", và không dùng chữ "app".
- Tên bàn phím nào Dấu nêu (bàn phím tiếng Anh ở dòng phím tắt, bàn phím đã chuyển sang khi gỡ) viết như thanh menu của macOS, theo ngôn ngữ hệ thống chứ không theo ngôn ngữ giao diện của Dấu; không có bản dịch thì dùng tên hệ thống trả về (`docs/ARCHITECTURE.md`, `LayoutNames`).
- Ba bước, thanh bước bên trái có trạng thái xong / đang làm / chưa. Cuối thanh bước chỉ có dòng "Dấu không cần quyền Trợ năng." (đã đo 30/10/2026); không hứa macOS hỏi mấy lần, vì "Thử lại" sau Don't Allow làm hộp thoại hiện lại (N5; người dùng chốt 05/11/2026, canvas phiên bản 125).
- **Bước 1, tắt bộ gõ cũ:** chỉ hiện khi phát hiện bộ gõ chặn phím đang chạy (bundle ID trong `docs/research/M5-INSTALL.md` mục 5); lúc mở không có bộ gõ nào chạy thì bỏ qua bước này. Hướng dẫn tắt chỉ ghi tên menu đã kiểm chứng; app chưa kiểm thì ghi chung "Thoát <tên>" và đường dẫn Mục đăng nhập (N5). Tự kiểm tra lại khi cửa sổ được kích hoạt; cho phép bỏ qua.
  - **Đã tắt bộ gõ cũ** (artboard `OnboardingConflictDone`): màn bước 1 khi người dùng bấm "Quay lại" ở bước 2 mà không còn bộ gõ cũ nào chạy. Thẻ liệt kê các bộ gõ cũ đã phát hiện trong lượt onboarding này, mỗi bộ gõ có nhãn xanh "Đã tắt"; nút duy nhất "Tiếp tục" sang bước 2; thanh bước vẫn ở bước 1. Có bộ gõ cũ chạy lại (kiểm tra lại khi cửa sổ được kích hoạt) thì hiện lại màn tắt bộ gõ cũ.
- **Bước 2, bật Dấu:** chép bộ gõ vào `~/Library/Input Methods` và đăng ký; chỉ bật nguồn nhập liệu khi người dùng bấm "Bật Dấu" (N4, D37). macOS hỏi người dùng có cho Dấu bật không (hộp thoại "Allow"), nên bước có nhiều màn (artboard `OnboardingEnable`, `OnboardingEnableNotes`, `OnboardingEnableWaiting`, `OnboardingEnableDone`, `OnboardingEnableDoneNoShortcut`, `OnboardingEnableFailed`, `OnboardingEnableError`). Mọi bước dùng chung một khung: tiêu đề, mô tả và nội dung cuộn được, hàng nút cố định ở đáy (có đường kẻ phía trên khi nội dung bị che), nên nội dung dài không tràn ra ngoài cửa sổ. Tên màn hình của macOS viết tiếng Anh như trên máy người dùng (System Settings › Keyboard › Input Sources). Kết quả đọc lại từ hệ thống, không báo thành công khi chưa thấy bật (N5). Không có Hoàn tác: app không tự tắt được Dấu (macOS chặn), chỉ người dùng bỏ Dấu trong System Settings.
  - **Quay lại** (D14; nút phụ kiểu hệ thống bên trái nút chính, D9): có trên các màn trước khi Dấu được bật (trước khi bấm, đang chờ, lỗi cài), và chỉ khi bước 1 đã hiện trong lượt onboarding này; bước 1 không hiện (không có bộ gõ cũ) thì không có nút, để nút không dẫn tới một màn trống. Bấm thì huỷ lần chờ đang chạy (cùng cách "Thử lại" huỷ), bỏ lỗi vừa gặp, về bước 1; bước 1 kiểm tra lại bộ gõ cũ: còn chạy thì hiện màn tắt bộ gõ cũ, không còn thì hiện "Đã tắt bộ gõ cũ". Màn "đã bật" và "chưa bật được" giữ nút riêng như artboard, không có "Quay lại".
  - **Phím tắt chuyển nguồn** ở mọi câu của onboarding vẽ bằng keycap như trang Gõ phím, mỗi phím một keycap, đọc từ cài đặt hệ thống (N5); không có dòng phụ nào nói phím tắt "hiện đúng trên máy". Câu gợi ý ở bước 3 dùng keycap nhỏ theo cỡ chữ gợi ý (artboard `OnboardingNotSelected`). VoiceOver đọc cả câu, phím tắt viết bằng chữ.
  - **Trước khi bấm:** thẻ "Sau khi bật, bạn sẽ thấy", rồi thẻ nói trước điều sắp xảy ra (System Settings đóng rồi mở lại, hộp thoại hỏi) kèm hình thu nhỏ hộp thoại của macOS (minh hoạ, ẩn với VoiceOver). Phím tắt không đọc được thì hàng phím tắt là một dòng nói vậy kèm nút mở System Settings, không có keycap rỗng. Nhắc nhẹ (biểu tượng thông tin) khi có nguồn tiếng Việt kiểu IMK khác đang bật (D14), không chặn.
  - **Đang chờ:** trong lúc `enable()` chờ mục lưu của Dấu. Thẻ trạng thái có vòng xoay; nút "Thử lại" huỷ lần chờ đang chạy rồi bật lại (macOS hỏi lại); "Quay lại" (nếu có, xem trên) cũng huỷ, không để lần chờ nào chạy tiếp. Màn tự chuyển sang "đã bật" khi macOS ghi mục.
  - **Đã bật:** nút duy nhất "Tiếp tục". Câu chọn Dấu nêu **phím tắt thật** đọc từ cài đặt hệ thống, không viết cứng (N5), vẽ bằng keycap; chưa đặt thì nói vậy và có nút đặt phím tắt trong System Settings (`OnboardingEnableDoneNoShortcut`); không đọc được thì chỉ nói chọn trong menu nhập liệu, không khẳng định gì về phím tắt, kèm cùng nút. Dưới thẻ có một dòng gợi ý: một ứng dụng chưa chọn được Dấu thì đăng xuất ( › Log Out) rồi đăng nhập lại một lần (D37).
  - **Chưa bật được** (hết hạn chờ, hoặc macOS không liệt kê Dấu): ba cách theo thứ tự (Thử lại; tự thêm trong System Settings; đăng xuất một lần). Không tự mở Cài đặt, có nút "Mở System Settings". Nếu sau đó Dấu xuất hiện (người dùng tự thêm), cửa sổ nhận ra và sang "đã bật".
  - **Lỗi cài** (chép, kiểm chữ ký, đăng ký): màn riêng "Chưa cài được Dấu", hai cách xử lý, dòng "Chi tiết" là mô tả thật của lỗi (chọn được để chép), nút "Thử lại" bật lại từ đầu.
- **Bước 3, chọn kiểu gõ và gõ thử.** Ví dụ gõ thử phải đúng quy tắc của kiểu gõ đang chọn. Dấu chưa phải nguồn đang dùng thì có câu gợi ý cách chọn Dấu, kèm phím tắt thật bằng keycap nếu đọc được (N5).

## Cửa sổ Cài đặt
- Thanh công cụ có cụm Lùi/Tiến trước tiêu đề trang (như System Settings; lịch sử các mục đã xem; mở cửa sổ thì cả hai tắt), tiêu đề là tiêu đề hệ thống (D9). Sidebar cố định như System Settings: không kéo rộng hẹp, không thu gọn, menu View không có mục ẩn/hiện sidebar (D9). Artboard: các artboard "Cài đặt – …", canvas phiên bản 127.
- Edit › Find › Find… (⌘F) đưa con trỏ vào ô tìm của sidebar (D9).
- Ô tìm của sidebar khớp tên mục và mọi chữ nhìn thấy trong mục (tiêu đề hàng, tiêu đề nhóm, lựa chọn, nút), không phân biệt hoa thường, dấu, "đ"/"d". Không mục nào khớp thì sidebar hiện trạng thái trống của hệ thống, trang đang mở giữ nguyên.
- Mô tả của một nhóm nằm dưới tiêu đề nhóm, trên thẻ (như System Settings).

**Gõ phím**
- Thẻ xem trước tính bằng engine thật, cập nhật ngay theo kiểu gõ và vị trí dấu.
- Chuyển Việt ↔ Anh là chuyển nguồn nhập liệu; hàng phím tắt hiện phím tắt hệ thống hiện tại, nút "Đổi…" mở Cài đặt Bàn phím (N4). Không có phím chuyển riêng (D2).

**Thông minh**
- Tự khôi phục từ không phải tiếng Việt (D4); ví dụ trong ghi chú phải khớp hành vi engine (từ trùng thì tiếng Việt thắng, gõ đúp phím dấu để giữ chữ gốc).
- Thêm dấu cho từ đã gõ (D20): ghi chú nêu phạm vi (không áp dụng ở app có quy tắc gạch chân). Độ ổn định trên web editor để ô trống cho tới khi đo (N5).
- "Nâng cao" thu gọn, tóm tắt số tuỳ chọn và trạng thái. "Gõ tắt phụ âm" và "Cho phép phụ âm z, f, w, j" loại trừ nhau, bật mục này tắt mục kia (D22); với Telex, w đầu từ luôn thành ư nên mục thứ hai chỉ tác dụng với z, f, j (D23). Cả hai mặc định tắt.

**Ứng dụng**
- "Nhớ nguồn nhập liệu theo từng cửa sổ" là tuỳ chọn của macOS: Dấu chỉ đọc trạng thái, không ghi; không đọc được thì không hiện chữ (N5); nút "Đổi…" mở Cài đặt Bàn phím (D5, N4).
- "Quy tắc riêng": chỉ các quy tắc đã lưu. Đặt về "Không gạch chân" vẫn giữ quy tắc; xoá quy tắc (menu chuột phải hoặc Delete) thì app đề xuất trở lại "Đề xuất".
- "Đề xuất": chỉ hiện khi có app trong danh sách tương thích (cờ `suggestUnderline`) đã cài mà chưa có quy tắc. Bấm "Bật gạch chân" mới lưu quy tắc (nguồn đề xuất, giữ nhãn "Đề xuất"); trước đó không lưu gì (D13). Dòng phụ giống nhau ở mọi hàng; ghi chú trong danh sách tương thích là cho người bảo trì, không hiện (N5). Ghi chú của mục chỉ nói khi nào nên chọn gạch chân, không hứa sửa được (số đo: D13).
- Ô tìm của trang lọc cả hai mục.

**Cập nhật & hỗ trợ**
- Hàng "Ngôn ngữ" (D41; artboard "Cài đặt – hàng Ngôn ngữ (theo macOS)" và "(Dấu đặt riêng English, macOS tiếng Việt)", canvas phiên bản 136, người dùng duyệt 08/11/2026): thẻ riêng ngay dưới thẻ phiên bản; Dấu chỉ đọc, không ghi. Giá trị là ngôn ngữ Dấu đang hiện, viết bằng chính ngôn ngữ đó. Câu phụ có hai dạng: theo macOS (miền cài đặt của app không có khoá `AppleLanguages`) thì hướng dẫn bấm "Đổi…" rồi + ở mục Applications; đặt riêng thì nói là đặt riêng cho Dấu và cách đổi hoặc bỏ. "Đổi…" mở trang Language & Region. Chờ mở lại (artboard "Cài đặt – hàng Ngôn ngữ (đã đổi sang English, chưa mở lại Dấu)", canvas phiên bản 137): khi ngôn ngữ của lần mở sau (tính từ khoá của app, không có thì từ danh sách của macOS) khác ngôn ngữ đang hiện, giá trị là ngôn ngữ của lần mở sau, câu phụ giữ phần đầu ("Đặt riêng cho Dấu." hoặc "Theo macOS.") rồi nói Dấu dùng ngôn ngữ đó sau khi mở lại, và có thêm nút "Mở lại Dấu" trước "Đổi…". Tên mục của macOS theo D38. Không nhắc menu bộ gõ khi chưa đo (câu hỏi mở về bộ gõ, N5).
- Trạng thái kiểm tra cập nhật và cách cài bản mới để ô trống cho tới M7 (N5).
- Bản phát triển (D7, D25; artboard "Cài đặt – Cập nhật & hỗ trợ (bản phát triển)"): thẻ đầu trang dùng biểu tượng bản phát triển và thêm dòng "Bản phát triển · Debug" (hoặc "· Release"); dòng phiên bản cuối sidebar thêm "· Debug"/"· Release". Bản chính thức không có dòng này; Beta hiện số phiên bản dạng "1.3 beta 2".
- Nút gỡ cài đặt dùng dạng `role: .destructive` của hệ thống (người dùng chốt 02/11/2026, D9).
- Chú thích quyền riêng tư giữ đúng nội dung D8/N2.

**Sheet thêm quy tắc** (nút +)
- Danh sách: ứng dụng chưa có quy tắc đã lưu; app trong danh sách tương thích mang nhãn "Đề xuất" và giữ nhãn khi thêm.
- "Thêm" chỉ bật khi ứng dụng đang chọn còn trong danh sách đang lọc; gõ tìm làm ẩn ứng dụng đang chọn thì bỏ chọn.

## Trạng thái bổ sung
- **Dấu chưa được bật** (người dùng gỡ khỏi nguồn đầu vào): banner đầu mọi mục Cài đặt. "Bật lại" bật Dấu rồi đọc lại trạng thái (N4), artboard `SettingsBannerStates`:
  - đang chờ người dùng bấm Allow → banner có vòng xoay; "Thử lại" huỷ lần chờ rồi bật lại;
  - bật được → banner xác nhận nêu phím tắt thật (như onboarding, N5; không đọc được thì không nêu), nút "Ẩn" ẩn banner trong phiên này; không có Hoàn tác (app không tự tắt được Dấu);
  - macOS vẫn để tắt hoặc lỗi → banner nói chưa bật được, kèm cách tự thêm trong System Settings và "Thử lại" (không tự mở System Settings);
  - chưa cài hoặc macOS chưa liệt kê Dấu → mở cửa sổ thiết lập.
- **Bộ gõ trên máy đã bị thay** (chữ ký của bộ gõ trong `~/Library/Input Methods` không hợp lệ hoặc không cùng Team ID với app; kiểm lúc mở app và mỗi lần app được đưa lên trước): banner đỏ đầu mọi mục Cài đặt, nút "Cài lại" chép bản gốc trong app (đã kiểm chữ ký) đè lên; cài lại không được thì banner nói vậy và hướng dẫn gỡ rồi cài lại từ bản tải về.
- **Chế độ tối:** Cài đặt và onboarding đều có (màu hệ thống).
- **Gỡ cài đặt** (D16): macOS chỉ cho người dùng tự bỏ một nguồn đầu vào, nên gỡ có ba bước (artboard `ConfirmDialogs`, `UninstallRemoveSource`). Dấu không có trong nguồn đầu vào (chưa bật, hoặc người dùng đã tự bỏ) thì sau alert xác nhận gỡ luôn, không mở System Settings, không hiện sheet (D16). Tên Thùng rác trong alert và sheet theo ngôn ngữ macOS (D38):
  - Alert xác nhận (hệ thống), có tuỳ chọn xoá cả cài đặt và quy tắc; nút xác nhận là "Tiếp tục gỡ", chưa xoá gì; nội dung chỉ nói người dùng bỏ Dấu trong System Settings rồi Dấu được chuyển vào Thùng rác.
  - Sheet "Bỏ Dấu khỏi nguồn đầu vào" trên cửa sổ Cài đặt: app không chuyển nguồn đầu vào nào (người dùng chọn). App mở thẳng danh sách Input Sources của System Settings (đã mở sẵn sheet Edit…), sheet nêu một bước (chọn Dấu, bấm "–", Done) và chờ mục lưu của Dấu biến mất, không hết hạn. Câu nhắc "nếu nút – bị mờ, chọn bàn phím khác" chỉ hiện khi Dấu đang là nguồn được chọn, đọc lại khi sheet hiện, khi cửa sổ thành key lại và khi nguồn đang chọn đổi, nên biến mất khi người dùng chuyển bàn phím. "Huỷ gỡ cài đặt" (hoặc Esc, đóng sheet, hoặc gỡ lỗi giữa chừng) đóng sheet và không xoá hay đổi gì; "Mở System Settings" chỉ mở trang.
  - Mục lưu biến mất → dừng bộ gõ, chuyển vào Thùng rác, xoá dữ liệu nếu đã tick, rồi alert nêu những gì đã làm (đọc lại từ hệ thống). App không tự xoá chính nó, chỉ hướng dẫn kéo vào Thùng rác. Bộ gõ không bao giờ bị xoá khi mục lưu còn: bundle mất trước thì mục còn lại không gỡ được.
- **Xác nhận quay về bản trước:** D19.
- **Khi gõ trong ứng dụng:** không gạch chân (mặc định), có gạch chân (từ đang gõ được gạch, chốt khi kết thúc từ), gõ tiếng Anh bằng U.S. (chỉ báo của hệ thống), thêm dấu cho từ đã gõ.

## Chưa có mã (mô tả nội dung tới khi dựng)

### Thẻ cập nhật (M7)
Sáu trạng thái: đã mới nhất; đang kiểm tra; đang tải (thanh tiến trình, "Bạn vẫn gõ bình thường", nút Huỷ); chờ cài ("Sẽ cài khi bạn ngừng gõ", nút Cài ngay); không có mạng (nút Thử lại, "Dấu vẫn gõ bình thường"); chữ ký không hợp lệ ("Đã huỷ bản cập nhật", nút Báo lỗi…). Mọi câu hứa ở đây phải kiểm chứng ở M7 (N5).

### Thông báo cập nhật (M7)
Icon app, "Đã có Dấu x.y.z", mô tả, "Có gì mới", dòng "Đã xác minh chữ ký số của bản cập nhật", checkbox "Tự động cài các bản sau", nút: Cài đặt / Nhắc sau / Bỏ qua bản này.

### Báo ứng dụng gõ lỗi (M7)
Đầu sheet có ô gợi ý "Ứng dụng không chọn được Dấu?": đăng xuất rồi đăng nhập lại một lần, thoát rồi mở lại ứng dụng thì chưa đủ, vẫn lỗi thì gửi báo lỗi (D37). Ứng dụng (tự điền), Trang web (không bắt buộc), Loại lỗi (Mất chữ | Lặp chữ | Sai dấu | Khác), Ví dụ đã gõ; mục "Gửi kèm" liệt kê phiên bản macOS, Dấu, kiểu gõ, phiên bản app, và câu "Không gửi nội dung bạn đã gõ." Ghi rõ issue GitHub là công khai. Nút: Huỷ / Sao chép nội dung / Mở trên GitHub (URL issue điền sẵn, không có backend, D8).

### Trang tải về (M8)
Phông Be Vietnam Pro, nền Giấy, màu nhấn Mực (D25, `docs/BRAND.md`). Một mã nguồn responsive cho máy tính và điện thoại. Thứ tự mục:
1. **Thanh điều hướng:** logo, Tính năng / Bảng gõ / Hỏi đáp / GitHub (ẩn trên điện thoại), nút "Tải về".
2. **Hero:** dòng nhỏ chứa cụm "Bộ gõ tiếng Việt cho macOS" (cho tìm kiếm), tiêu đề "Gõ tiếng Việt trên Mac, tự nhiên như vốn có.", nút "Tải về" + "Xem mã nguồn", dòng yêu cầu hệ thống. Bên phải: **hoạt ảnh phát lại** chuỗi phím ra chữ có dấu kèm phím vừa gõ — hoạt ảnh CSS dựng sẵn, không phải engine chạy trên web. Tắt khi người dùng bật giảm chuyển động (`prefers-reduced-motion`).
3. **Vì sao có Dấu:** so sánh theo **loại** bộ gõ, chỉ mô tả cách làm (có sẵn: gạch chân; giả lập phím: xoá rồi gõ lại bằng phím giả, ảnh hưởng khi máy bận để ô trống tới khi đo ở M6; Dấu: thay chữ tại chỗ, kèm danh sách ứng dụng đã kiểm chứng). Không gọi tên sản phẩm khác (N5).
4. **Tính năng:** 4 thẻ có minh hoạ — giữ nguyên từ nước ngoài, thêm dấu cho từ đã gõ, theo từng ứng dụng, như một phần của macOS.
5. **Bảng gõ Telex/VNI:** bảng thật (`<table>`), cột "Tên" ẩn trên điện thoại.
6. **Quyền riêng tư:** nền Mực, 3 cam kết (giữ đúng nội dung D8/N2).
7. **Đo được:** 4 ô số liệu để trống, chỉ điền từ kết quả test thật (N5).
8. **Tải về:** phiên bản, ngày, dung lượng, yêu cầu hệ thống, nút "Tải về (.dmg)", "Lịch sử phiên bản", lệnh Homebrew (tên cask chưa chốt, D24), SHA-256. Không phải Mac thì nút chính thành "Sao chép liên kết" kèm câu "Dấu chỉ chạy trên Mac" (không có backend gửi email, D8).
9. **Góp sức:** góp công (báo lỗi, dùng thử Beta, góp mã nguồn, giới thiệu), ủng hộ qua VietQR và GitHub Sponsors (D39), mục Cảm ơn (chỉ nêu tên khi người đó đồng ý).
10. **Hỏi đáp:** 8 câu dạng `<details>` (miễn phí, thu thập dữ liệu, quyền cần cấp, khác bộ gõ có sẵn, chuyển từ bộ gõ khác, vì sao không có gõ tắt/viết hoa đầu câu/chuyển mã, một ứng dụng không chọn được Dấu (D37), gỡ cài đặt). Tên giao diện macOS ghi tiếng Việt của Apple kèm tiếng Anh trong ngoặc.
11. **Chân trang:** nền Than, logo có viền, liên kết mã nguồn, báo lỗi, lịch sử phiên bản, hướng dẫn gỡ, ủng hộ.

Không dùng logo Apple trên nút tải (nhãn hiệu của Apple); dùng biểu tượng mũi tên tải xuống.
