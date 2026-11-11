# Trang web

Nội dung và quy tắc của trang web Dấu: trang tải về (M8 (Website)) và trang so sánh cách gõ (M10 (Học cách gõ)). Mốc, tiêu chí xong: [`docs/ROADMAP.md`](ROADMAP.md). Nhận diện: [`docs/BRAND.md`](BRAND.md). Giao diện app: [`docs/UI.md`](UI.md).

Chung cho mọi trang:

- Chỉ hứa điều đã kiểm chứng (N5 (Chỉ hứa điều đã kiểm chứng)): ô số liệu để trống dạng `[Kết quả bài test tải nặng]` tới khi có kết quả test thật; không ghi "chạy tốt trong mọi app" hay danh sách logo ứng dụng trước khi có số đo ([`docs/COMPATIBILITY.md`](COMPATIBILITY.md)).
- Không gọi tên sản phẩm khác.
- Không dùng logo Apple trên nút tải (nhãn hiệu của Apple); dùng biểu tượng mũi tên tải xuống.

## Trang tải về (M8)

Artboard: [máy tính](canvas/Landing.png), [điện thoại](canvas/LandingMobile.png).

- Phông Be Vietnam Pro, nền Giấy, màu nhấn Mực (D25 (Nhận diện)).
- Một mã nguồn responsive cho máy tính và điện thoại.

Thứ tự mục:

1. **Thanh điều hướng:** logo, Tính năng / Bảng gõ / Hỏi đáp / GitHub (ẩn trên điện thoại), nút "Tải về".
2. **Hero:**
   - Dòng nhỏ chứa cụm "Bộ gõ tiếng Việt cho macOS" (cho tìm kiếm).
   - Tiêu đề "Gõ tiếng Việt trên Mac, tự nhiên như vốn có."
   - Nút "Tải về" + "Xem mã nguồn", dòng yêu cầu hệ thống.
   - Bên phải: hoạt ảnh phát lại chuỗi phím ra chữ có dấu kèm phím vừa gõ. Là hoạt ảnh CSS dựng sẵn, không phải engine chạy trên web; tắt khi người dùng bật giảm chuyển động (`prefers-reduced-motion`).
3. **Vì sao có Dấu:** so sánh theo loại bộ gõ, chỉ mô tả cách làm.
   - Có sẵn: gạch chân.
   - Giả lập phím: xoá rồi gõ lại bằng phím giả; ảnh hưởng khi máy bận để ô trống tới khi có số đo của M6 (Hiệu năng dưới tải).
   - Dấu: thay chữ tại chỗ, kèm danh sách ứng dụng đã kiểm chứng.
4. **Tính năng:** bốn thẻ có minh hoạ: giữ nguyên từ nước ngoài, thêm dấu cho từ đã gõ, theo từng ứng dụng, như một phần của macOS.
5. **Bảng gõ Telex/VNI:** bảng thật (`<table>`), cột "Tên" ẩn trên điện thoại.
6. **Quyền riêng tư:** nền Mực, ba cam kết, giữ đúng nội dung D8 (Không telemetry) và N2 (Bộ gõ không có quyền mạng).
7. **Đo được:** bốn ô số liệu để trống, chỉ điền từ kết quả test thật.
8. **Tải về:**
   - phiên bản, ngày, dung lượng, yêu cầu hệ thống;
   - nút "Tải về (.dmg)", "Lịch sử phiên bản";
   - lệnh Homebrew (tên cask chưa chốt, D24 (Tên và định danh));
   - SHA-256;
   - không phải Mac thì nút chính thành "Sao chép liên kết" kèm câu "Dấu chỉ chạy trên Mac" (trang tĩnh, không gửi email).
9. **Góp sức:**
   - góp công (báo lỗi, dùng thử Beta, góp mã nguồn, giới thiệu);
   - ủng hộ qua VietQR và GitHub Sponsors (D39 (Ủng hộ dự án));
   - mục Cảm ơn (chỉ nêu tên khi người đó đồng ý).
10. **Hỏi đáp:** tám câu dạng `<details>`.
    - Các câu: miễn phí, thu thập dữ liệu, quyền cần cấp, khác bộ gõ có sẵn, chuyển từ bộ gõ khác, vì sao không có gõ tắt/viết hoa đầu câu/chuyển mã, một ứng dụng không chọn được Dấu (D37 (Cài đặt bộ gõ)), gỡ cài đặt.
    - Trang web không biết ngôn ngữ macOS của người đọc, nên tên giao diện macOS ghi tiếng Việt của Apple kèm tiếng Anh trong ngoặc.
11. **Chân trang:** nền Than, logo có viền, liên kết mã nguồn, báo lỗi, lịch sử phiên bản, hướng dẫn gỡ, ủng hộ.

## Trang "Dấu khác các bộ gõ khác thế nào" (M10)

Chưa có artboard. Nội dung và nguồn: [`docs/ROADMAP.md`](ROADMAP.md) mục M10; canvas trước, mã sau.
