# Giao diện

Mỗi phần của giao diện có một nguồn:

- **Trông như thế nào:** canvas mockup https://claude.ai/artifact/B2xhNxL3voGwTkXkFV72Ln (mục, thứ tự, icon, trạng thái), sửa trước mỗi thay đổi giao diện, người dùng duyệt rồi mới sửa mã (D9).
- **Bố cục, khoảng cách, control:** System Settings của macOS hiện hành (D9). Số đo ở `docs/research/SYSTEM-SETTINGS-REFERENCE.md`, mức đạt ở `scripts/selftest/settings-window/Reference.swift`.
- **Chữ:** String Catalog trong mã (`Localizable.xcstrings`), tiếng Việt.
- **File này:** chỉ ghi hành vi, trạng thái, quy tắc và lý do — những gì hình vẽ và mã không tự nói ra. Không liệt kê chữ hay bố cục của phần đã có mã. Phần chưa có mã (cuối file) tạm mô tả nội dung cho tới khi dựng.

Khi các nguồn lệch nhau, `DECISIONS.md` quyết định; sửa bên sai cho khớp.

## Menu nguồn nhập liệu (hệ thống vẽ)
- Không có status item riêng. Dấu có một input mode (D2); gõ tiếng Anh bằng nguồn ABC/U.S. của người dùng.
- Bộ gõ chỉ bổ sung qua `menu()` của IMK: đổi kiểu gõ, mở Cài đặt Dấu, mở Cài đặt Bàn phím.

## Onboarding
> Ghi chú (03/11/2026): phần này mô tả mã hiện tại và sẽ được thiết kế lại sau M5 T4 (xem `docs/PROGRESS.md` "Trạng thái hiện tại" và `docs/research/M5-INSTALL.md` mục 0). Câu về đăng xuất, đường "tự thêm" và "Hoàn tác" chưa kiểm chứng trên macOS 27.2 (N5).

- Ba bước, thanh bước bên trái có trạng thái xong / đang làm / chưa. Dòng về quyền cần cấp để ô trống cho tới khi kiểm chứng (N5).
- **Bước 1, tắt bộ gõ cũ:** chỉ hiện khi phát hiện bộ gõ chặn phím đang chạy (bundle ID trong `docs/research/M5-INSTALL.md` mục 5). Hướng dẫn tắt chỉ ghi tên menu đã kiểm chứng; app chưa kiểm thì ghi chung "Thoát <tên>" và đường dẫn Mục đăng nhập (N5). Tự kiểm tra lại khi cửa sổ được kích hoạt; cho phép bỏ qua.
- **Bước 2, bật Dấu:** chép bộ gõ vào `~/Library/Input Methods` và đăng ký; chỉ bật nguồn nhập liệu khi người dùng bấm "Bật Dấu", có Hoàn tác (N4, D37). Kết quả đọc lại từ hệ thống, không báo thành công khi chưa thấy bật (N5):
  - macOS vẫn để tắt → mở Cài đặt Bàn phím, hiện các bước tự thêm;
  - macOS chưa liệt kê Dấu (lần cài đầu) → hướng dẫn đăng xuất, đăng nhập lại một lần;
  - có nguồn tiếng Việt kiểu IMK khác đang bật → chỉ nhắc nhẹ, không chặn (D14).
  - Phím tắt chuyển nguồn hiện **phím tắt thật** đọc từ cài đặt hệ thống, không viết cứng (N5); chưa đặt thì nói vậy và có nút mở Cài đặt Bàn phím; không đọc được thì keycap trống kèm nút đó.
  - Chỗ dành cho hướng dẫn nếu macOS hỏi xác nhận ("Cho phép … bật …?"), điền sau M5 T4.
- **Bước 3, chọn kiểu gõ và gõ thử.** Ví dụ gõ thử phải đúng quy tắc của kiểu gõ đang chọn.

## Cửa sổ Cài đặt
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
- Trạng thái kiểm tra cập nhật và cách cài bản mới để ô trống cho tới M7 (N5).
- Nút gỡ cài đặt dùng dạng `role: .destructive` của hệ thống (người dùng chốt 02/11/2026, D9).
- Chú thích quyền riêng tư giữ đúng nội dung D8/N2.

**Sheet thêm quy tắc** (nút +)
- Danh sách: ứng dụng chưa có quy tắc đã lưu; app trong danh sách tương thích mang nhãn "Đề xuất" và giữ nhãn khi thêm.
- "Thêm" chỉ bật khi ứng dụng đang chọn còn trong danh sách đang lọc; gõ tìm làm ẩn ứng dụng đang chọn thì bỏ chọn.

## Trạng thái bổ sung
> Ghi chú (03/11/2026): các mô tả "Dấu chưa được bật" và "Xác nhận gỡ cài đặt" dưới đây là của mã hiện tại và sẽ được thiết kế lại sau M5 T4 (xem `docs/PROGRESS.md` "Trạng thái hiện tại" và `docs/research/M5-INSTALL.md` mục 0). Câu về đăng xuất, đường "tự thêm" và "Hoàn tác" chưa kiểm chứng trên macOS 27.2 (N5).

- **Dấu chưa được bật** (người dùng gỡ khỏi Nguồn nhập liệu): banner đầu mọi mục Cài đặt. "Bật lại" bật Dấu rồi đọc lại trạng thái (N4):
  - bật được → banner xác nhận kèm "Hoàn tác";
  - macOS vẫn để tắt → mở Cài đặt Bàn phím, banner hiện các bước tự thêm;
  - chưa cài hoặc macOS chưa liệt kê Dấu → mở cửa sổ thiết lập.
- **Bộ gõ trên máy đã bị thay** (chữ ký của bộ gõ trong `~/Library/Input Methods` không hợp lệ hoặc không cùng Team ID với app; kiểm lúc mở app và mỗi lần app được đưa lên trước): banner đỏ đầu mọi mục Cài đặt, nút "Cài lại" chép bản gốc trong app (đã kiểm chữ ký) đè lên; cài lại không được thì banner nói vậy và hướng dẫn gỡ rồi cài lại từ bản tải về.
- **Chế độ tối:** Cài đặt và onboarding đều có (màu hệ thống).
- **Xác nhận gỡ cài đặt:** alert hệ thống, có tuỳ chọn xoá cả cài đặt và quy tắc. Câu về bàn phím trước đó để ô trống cho tới M5 T4 (N5). Gỡ xong: alert nêu những gì đã làm (đọc lại từ hệ thống); app không tự xoá chính nó, chỉ hướng dẫn kéo vào Thùng rác.
- **Xác nhận quay về bản trước:** D19.
- **Khi gõ trong ứng dụng:** không gạch chân (mặc định), có gạch chân (từ đang gõ được gạch, chốt khi kết thúc từ), gõ tiếng Anh bằng ABC (chỉ báo của hệ thống), thêm dấu cho từ đã gõ.

## Chưa có mã (mô tả nội dung tới khi dựng)

### Thẻ cập nhật (M7)
Sáu trạng thái: đã mới nhất; đang kiểm tra; đang tải (thanh tiến trình, "Bạn vẫn gõ bình thường", nút Huỷ); chờ cài ("Sẽ cài khi bạn ngừng gõ", nút Cài ngay); không có mạng (nút Thử lại, "Dấu vẫn gõ bình thường"); chữ ký không hợp lệ ("Đã huỷ bản cập nhật", nút Báo lỗi…). Mọi câu hứa ở đây phải kiểm chứng ở M7 (N5).

### Thông báo cập nhật (M7)
Icon app, "Đã có Dấu x.y.z", mô tả, "Có gì mới", dòng "Đã xác minh chữ ký số của bản cập nhật", checkbox "Tự động cài các bản sau", nút: Cài đặt / Nhắc sau / Bỏ qua bản này.

### Báo ứng dụng gõ lỗi (M7)
Ứng dụng (tự điền), Trang web (không bắt buộc), Loại lỗi (Mất chữ | Lặp chữ | Sai dấu | Khác), Ví dụ đã gõ; mục "Gửi kèm" liệt kê phiên bản macOS, Dấu, kiểu gõ, phiên bản app, và câu "Không gửi nội dung bạn đã gõ." Ghi rõ issue GitHub là công khai. Nút: Huỷ / Sao chép nội dung / Mở trên GitHub (URL issue điền sẵn, không có backend, D8).

### Trang tải về (M8)
Phông Be Vietnam Pro, nền Giấy, màu nhấn Mực (D25, `docs/BRAND.md`). Một mã nguồn responsive cho máy tính và điện thoại. Thứ tự mục:
1. **Thanh điều hướng:** logo, Tính năng / Bảng gõ / Hỏi đáp / GitHub (ẩn trên điện thoại), nút "Tải về".
2. **Hero:** dòng nhỏ chứa cụm "Bộ gõ tiếng Việt cho macOS" (cho tìm kiếm), tiêu đề "Gõ tiếng Việt như thể macOS vốn đã làm vậy.", nút "Tải cho macOS" + "Xem mã nguồn", dòng yêu cầu hệ thống. Bên phải: **hoạt ảnh phát lại** chuỗi phím ra chữ có dấu kèm phím vừa gõ — hoạt ảnh CSS dựng sẵn, không phải engine chạy trên web. Tắt khi người dùng bật giảm chuyển động (`prefers-reduced-motion`).
3. **Vì sao lại thêm một bộ gõ:** so sánh theo **loại** bộ gõ (có sẵn: gạch chân; chặn phím rồi gõ lại: có thể nhảy chữ, thường cần quyền Trợ năng; Dấu: thay chữ tại chỗ). Không gọi tên sản phẩm khác. Phạm vi ứng dụng của Dấu để ô trống tới khi có số đo (N5).
4. **Tính năng:** 4 thẻ có minh hoạ — giữ nguyên từ nước ngoài, thêm dấu cho từ đã gõ, theo từng ứng dụng, như một phần của macOS.
5. **Bảng gõ Telex/VNI:** bảng thật (`<table>`), cột "Tên" ẩn trên điện thoại.
6. **Quyền riêng tư:** nền Mực, 3 cam kết (giữ đúng nội dung D8/N2).
7. **Đo được:** 4 ô số liệu để trống, chỉ điền từ kết quả test thật (N5).
8. **Tải về:** phiên bản, ngày, dung lượng, yêu cầu hệ thống, nút "Tải DMG", "Lịch sử phiên bản", lệnh Homebrew (tên cask chưa chốt, D24), SHA-256. Không phải Mac thì nút chính thành "Sao chép liên kết" kèm câu "Dấu chỉ chạy trên Mac" (không có backend gửi email, D8).
9. **Hỏi đáp:** 6 câu dạng `<details>` (miễn phí, thu thập dữ liệu, quyền cần cấp, khác bộ gõ có sẵn, chuyển từ bộ gõ khác, gỡ cài đặt).
10. **Chân trang:** nền Than, logo có viền, liên kết mã nguồn, báo lỗi, lịch sử phiên bản, hướng dẫn gỡ, ủng hộ.

Không dùng logo Apple trên nút tải (nhãn hiệu của Apple); dùng biểu tượng mũi tên tải xuống.
