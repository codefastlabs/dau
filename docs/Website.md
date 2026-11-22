# Trang web

Tài liệu này ghi nội dung và quy tắc của trang web Dấu. Trang web gồm trang tải về (M8 (Website)) và trang so sánh cách gõ (M10 (Học cách gõ)). Mốc và tiêu chí xong nằm ở [`docs/Roadmap.md`](Roadmap.md), nhận diện ở [`docs/Brand.md`](Brand.md), giao diện app ở [`docs/UI.md`](UI.md).

Mọi trang theo ba quy tắc chung:

- Trang chỉ hứa điều đã kiểm chứng (N5 (Chỉ hứa điều đã kiểm chứng)). Ô số liệu để trống dạng `[Kết quả bài test tải nặng]` cho tới khi có kết quả test thật. Trang không ghi "chạy tốt trong mọi app" và không đặt danh sách logo ứng dụng khi chưa có số đo ([`docs/Compatibility.md`](Compatibility.md)).
- Trang không gọi tên sản phẩm khác.
- Nút tải không dùng logo Apple, vì đó là nhãn hiệu của Apple; nút dùng biểu tượng mũi tên tải xuống.

## Trang tải về (M8)

Artboard của trang có hai bản: [máy tính](canvas/Landing.png) và [điện thoại](canvas/LandingMobile.png).

- Trang dùng phông Be Vietnam Pro, nền Giấy và màu nhấn Mực (D25 (Nhận diện)).
- Một mã nguồn responsive phục vụ cả máy tính lẫn điện thoại.
- Các mô hình minh hoạ cách Dấu làm việc nằm ở nhóm "Mô hình minh hoạ cho website" trên canvas. Mỗi mục dưới đây dẫn tới mô hình của nó. Mọi ví dụ chữ trong mô hình lấy từ một test của engine. Hoạt ảnh trong mô hình là CSS dựng sẵn và chỉ hiện khung cuối khi người dùng bật giảm chuyển động (`prefers-reduced-motion`).

Các mục xếp theo thứ tự sau:

1. **Thanh điều hướng** có logo, các liên kết Tính năng, Bảng gõ, Hỏi đáp, GitHub (ẩn trên điện thoại) và nút "Tải về".
2. **Hero:**
   - Một dòng chữ nhỏ chứa cụm "Bộ gõ tiếng Việt cho macOS" để máy tìm kiếm nhận ra trang.
   - Tiêu đề là câu "Gõ tiếng Việt trên Mac, tự nhiên như vốn có."
   - Bên dưới tiêu đề có nút "Tải về", nút "Xem mã nguồn" và một dòng yêu cầu hệ thống.
   - Bên phải là hoạt ảnh phát lại chuỗi phím thành chữ có dấu, kèm phím vừa gõ. Hoạt ảnh này dựng sẵn bằng CSS, không phải engine chạy trên web. Hoạt ảnh tắt khi người dùng bật giảm chuyển động (`prefers-reduced-motion`). Nội dung hoạt ảnh theo mô hình [Gõ phím dấu ở đâu cũng được](canvas/ModelTonePlacement.png) (D28 (Đặt dấu tự do), D15 (Cài đặt mặc định)).
3. **Vì sao có Dấu** so sánh các loại bộ gõ và chỉ mô tả cách mỗi loại làm việc.
   - Bộ gõ có sẵn của macOS dùng gạch chân.
   - Bộ gõ giả lập phím xoá chữ cũ rồi gõ lại bằng phím giả. Ảnh hưởng của cách này khi máy bận lấy từ số đo dưới tải ở `docs/Compatibility.md`; ô số liệu chỉ điền từ số đo (N5).
   - Dấu thay chữ tại chỗ. Mục này kèm danh sách ứng dụng đã kiểm chứng.
   - Mô hình [Ba cách gõ “hoà”](canvas/ModelThreeWays.png) so ba loại bộ gõ trên cùng bốn phím (N3, D13). Mô hình [Đường đi của một phím](canvas/ModelKeyFlow.png) tả phím đi từ macOS qua bộ gõ tới ứng dụng (N3, N2).
4. **Tính năng** gồm bốn thẻ có minh hoạ: giữ nguyên từ nước ngoài, thêm dấu cho từ đã gõ, theo từng ứng dụng, và như một phần của macOS. Mỗi thẻ có một mô hình:
   - [Giữ nguyên từ nước ngoài](canvas/ModelForeignWords.png) (D4, D26).
   - [Thêm dấu cho từ đã gõ](canvas/ModelAddMarks.png) (D20, D32, D13).
   - [Theo từng ứng dụng](canvas/ModelPerApp.png) (D5, D13, D43). Ứng dụng mang nhãn "Đề xuất" trong mô hình chỉ lấy từ `docs/Compatibility.md`.
   - [Như một phần của macOS](canvas/ModelPartOfMacOS.png) (D2, N1, N4).
5. **Bảng gõ Telex và VNI** là một bảng thật (`<table>`). Cột "Tên" ẩn trên điện thoại. Mô hình [VNI: chữ số sau âm tiết thành dấu](canvas/ModelVNI.png) đứng cạnh bảng và cũng dùng cho câu hỏi đáp về VNI (D36, D26).
6. **Quyền riêng tư** nằm trên nền Mực và nêu ba cam kết. Nội dung giữ đúng D8 (Không telemetry) và N2 (Bộ gõ không có quyền mạng). Mô hình [Những gì bạn gõ ở lại trên máy bạn](canvas/ModelPrivacy.png) tả hai phần chạy riêng của Dấu.
7. **Đo được** có bốn ô số liệu để trống. Các ô chỉ điền từ kết quả test thật.
8. **Tải về:**
   - Mục này ghi phiên bản, ngày phát hành, dung lượng và yêu cầu hệ thống.
   - Mục có nút "Tải về (.dmg)" và nút "Lịch sử phiên bản".
   - Lệnh Homebrew xuất hiện khi đã có cask, tức sau bản beta đầu tiên; lệnh ghi ở D6 (Phát hành).
   - Mục ghi mã SHA-256 của file tải về.
   - Khi người đọc không dùng Mac, nút chính đổi thành "Sao chép liên kết" kèm câu "Dấu chỉ chạy trên Mac". Trang là trang tĩnh nên không gửi email.
9. **Góp sức:**
   - Người đọc có thể góp công: báo lỗi, dùng thử bản mới khi có kênh Beta, góp mã nguồn, giới thiệu Dấu cho người khác.
   - Người đọc có thể ủng hộ qua VietQR và GitHub Sponsors (D39 (Ủng hộ dự án)).
   - Phần Cảm ơn liệt kê tên người ủng hộ, cùng danh sách với mục "Người ủng hộ" trong app, và giải thích cách đồng ý được nêu tên (D39). Phần này chỉ nêu tên một người khi người đó đồng ý, và không ghi số tiền.
   - Phần "Tiền ủng hộ đã dùng vào việc gì" là một bảng gồm ngày, khoản chi và số tiền. Bảng chỉ ghi khoản đã chi thật (D39, N5).
10. **Hỏi đáp** có chín câu, mỗi câu là một khối `<details>`.
    - Chín câu hỏi về: Dấu có miễn phí không; Dấu có thu thập dữ liệu không; cần cấp quyền gì; Dấu khác bộ gõ có sẵn thế nào; chuyển từ bộ gõ khác sang ra sao; vì sao không có gõ tắt, viết hoa đầu câu hay chuyển mã; VNI gõ chữ số ra dấu và cách giữ chữ số bằng cách gõ đúp (D36 (VNI: chữ số thành dấu)); làm gì khi một ứng dụng không chọn được Dấu (D37 (Cài bộ gõ)); cách gỡ cài đặt.
    - Trang web không biết macOS của người đọc dùng ngôn ngữ nào, nên tên giao diện macOS ghi bằng tiếng Việt của Apple, kèm tiếng Anh trong ngoặc.
11. **Chân trang** nằm trên nền Than, có logo có viền và các liên kết tới mã nguồn, báo lỗi, lịch sử phiên bản, hướng dẫn gỡ và ủng hộ.

## Trang "Dấu khác các bộ gõ khác thế nào" (M10)

Trang này chưa có artboard. Nội dung và nguồn nằm ở [`docs/Roadmap.md`](Roadmap.md), mục M10. Artboard phải có trước khi viết mã ([`Apps/Dau/CLAUDE.md`](../Apps/Dau/CLAUDE.md)).
