# So sánh Dấu với các bộ gõ khác (kế hoạch đo)

## Hiện trạng (09/11/2026)

- **Mới là kế hoạch, chưa đo gì.** Không có kết luận nào trong file này. Kết quả chưa đo không được đưa lên giao diện hay website (N5).
- Mục đích: trả lời bằng số đo ba câu hỏi về vị thế của Dấu: (1) gõ tiếng Việt có đúng hơn không; (2) từ tiếng Anh và tên trong mã có bị phá ít hơn không; (3) lỗi thay chữ tại chỗ khi phím dồn dưới 10 ms (D13, `docs/COMPATIBILITY.md` mục 6.2) có xảy ra khi người thật gõ không.
- Nằm trong M6 (ROADMAP: "So với gõ bằng U.S. và với OpenKey", mở rộng thêm bộ gõ của Apple và Gõ Nhanh) và là nguồn số liệu cho trang so sánh của M10.
- Chờ người dùng duyệt: danh sách bộ gõ, cài các bộ gõ khác lên máy, giờ chạy các phần chiếm màn hình (mục 6).

## 1. Bộ gõ được so sánh

Mỗi bộ gõ dùng **cài đặt mặc định** khi mới cài, tức thứ người dùng mới nhận được. Ghi phiên bản (hoặc commit) và bản macOS vào kết quả. Mỗi lần chỉ một bộ gõ chạy: thoát các bộ gõ chặn phím khác, bỏ chọn các nguồn tiếng Việt khác.

| Bộ gõ | Cách nhận phím | Lấy ở đâu | Ghi chú |
|---|---|---|---|
| Dấu | IMK, thay chữ tại chỗ (D11) | bản Release đã cài | mặc định theo D15, gạch chân tắt (D13) |
| Bộ gõ tiếng Việt của macOS | IMK (của Apple) | có sẵn, người dùng thêm bằng "+" | ID nguồn đọc bằng TIS lúc chạy, không ghi từ trí nhớ |
| OpenKey | chặn phím (event tap) và gửi Backspace giả | bản phát hành trên GitHub của dự án | cần quyền Accessibility, người dùng tự cấp |
| Gõ Nhanh | chặn phím (event tap, `platforms/macos/RustBridge.swift`) | bản phát hành trên GitHub của dự án | cần quyền Accessibility, người dùng tự cấp |

Có thể thêm sau: XKey (có cả chế độ IMK và chế độ chặn phím, thư mục `XKeyIM`), EVKey. Không đưa vào lượt đầu để giữ thời gian chiếm màn hình ngắn.

## 2. Bộ dữ liệu gõ

Mọi chuỗi phím là Telex (kiểu gõ mặc định của cả bốn). VNI để lượt sau.

- **C1. Tiếng Việt.** (a) Khoảng 2.000 từ lấy mẫu đều từ tập âm tiết hợp lệ mà test engine đang dùng (`SpellingTests`), gõ theo thứ tự chuẩn (dấu thanh ở cuối). (b) Cùng các từ đó gõ theo thứ tự tự do (dấu thanh giữa từ, ví dụ "thuowngr"). (c) Khoảng 200 câu văn xuôi và thơ thuộc phạm vi công cộng (ví dụ Truyện Kiều), chuyển sang phím Telex bằng script. Đúng nghĩa là: ra đúng chữ gốc.
- **C2. Tiếng Anh và mã.** (a) Khoảng 1.000 từ tiếng Anh thông dụng từ một danh sách có giấy phép dùng được (ví dụ SCOWL); ghi giấy phép như `external-test-inputs/NOTICE.md`. (b) Từ khoá và tên hay gặp trong Swift, JavaScript, Python, lệnh terminal (`git`, `brew`, `npm`…). (c) Câu trộn Việt–Anh. Đúng nghĩa là: giữ nguyên chữ gõ. Từ vừa là tiếng Anh vừa là âm tiết tiếng Việt hợp lệ ("car", "as") đếm riêng thành một nhóm, không tính đúng/sai, vì đây là lựa chọn thiết kế (D4).
- **C3. Sửa chữ.** Khoảng 100 ca chọn tay: Backspace giữa từ, thêm dấu cho từ đã gõ (D20), chữ hoa, gõ đúp phím dấu để giữ chữ gốc. Không chấm điểm, chỉ ghi lại mỗi bộ gõ cho ra gì, làm ví dụ cho M10.

Script sinh dữ liệu và đáp án nằm trong `scripts/research/compare-ims/`. Đáp án viết theo chính tả tiếng Việt (C1) hoặc chữ gõ (C2), không lấy từ kết quả của bộ gõ nào (D10).

## 3. Đo trong ứng dụng thật (chiếm màn hình)

- **Cách gõ:** một công cụ nhỏ bằng Swift gửi phím bằng `CGEvent` vào vị trí HID, để cả bộ gõ IMK lẫn bộ gõ chặn phím đều nhận như phím thật, với khoảng cách giữa hai phím đặt trước. Mở rộng từ `scripts/selftest/typing/run.sh` (thêm chọn nguồn bất kỳ theo ID, bỏ phần nhật ký riêng của Dấu khi đo bộ gõ khác), không viết bộ gõ phím mới từ đầu.
- **Ứng dụng:** một app thử riêng (NSTextView, không dùng TextEdit vì nó tự lưu tài liệu lên iCloud), Chrome, VS Code, Terminal.
- **Khoảng cách giữa hai phím:** 120 ms (gần gõ thường), 30 ms, 10 ms, 0 ms.
- **Khối lượng:** toàn bộ C1 và C2 ở app thử với 30 ms; ở Chrome, VS Code và Terminal chỉ một mẫu khoảng 300 ca lấy đều theo nhóm, chạy cả bốn khoảng cách. Ước lượng khoảng 2 giờ chiếm màn hình cho cả bốn bộ gõ, chia thành nhiều lượt.
- **Số ghi lại:** tỉ lệ từ đúng theo nhóm, theo app và theo khoảng cách; mọi ca sai kèm chuỗi phím và chữ ra (lưu trong `build/`, không commit).

## 4. Nhịp gõ của người thật

Câu hỏi: gõ tay có tạo ra hai phím cách nhau dưới 10 ms mà phím sau phải thay chữ không, và bao nhiêu lần trong một ngày.

- Dùng bản Debug của Dấu với `DauPerfLog` (D8): nhật ký có giờ, loại phím và app, **không có chữ**. Người dùng gõ bình thường trong một ngày làm việc.
- `scripts/perf/perf-report.sh` thêm bảng: phân bố khoảng cách giữa hai phím theo app; số phím có thay chữ đến sau phím trước dưới 10 ms; số lần Dấu phát hiện lệch vị trí rồi xoá bộ đệm (D11).
- Đây là số đo của một người. Ghi rõ như vậy, không suy rộng.

## 5. So sánh không cần gõ

Đọc thật trên máy khi cài từng bộ gõ, ghi thành bảng, không chấm điểm:

- Các bước cài và gỡ; quyền phải cấp (Accessibility, Input Monitoring); có phải đăng xuất không.
- Cách chuyển Việt/Anh: phím nào, bao nhiêu thao tác, có tự đổi theo app không.
- Các tính năng trong mục "Đã biết nhưng không làm" của `docs/DECISIONS.md`: bộ gõ nào có.

## 6. Thứ tự làm và điểm dừng

1. Sinh bộ dữ liệu và đáp án; mở rộng script gõ phím. Không chiếm màn hình.
2. Chạy thử trên Dấu với một mẫu nhỏ để kiểm script. **Hỏi giờ chạy.**
3. Phần nhịp gõ (mục 4): **người dùng đồng ý** cài bản Debug trong một ngày rồi cài lại bản Release.
4. Cài bộ gõ của Apple, OpenKey, Gõ Nhanh. **Người dùng** tải về (hoặc duyệt lệnh tải), cấp quyền Accessibility và thêm nguồn bằng "+".
5. Chạy mục 3 cho từng bộ gõ. **Hỏi giờ chạy cho từng lượt.**
6. Dọn máy: gỡ các bộ gõ khác, thu hồi quyền đã cấp, chọn lại Dấu, xoá các khoá `defaults` đã đặt.
7. Ghi kết quả vào mục Hiện trạng và thân bài file này; liệt kê các quyết định đáng xem lại (D2, D4, D13) kèm số đo. Đổi quyết định nào là việc của người dùng.
