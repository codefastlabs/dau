# Trang web

Tài liệu này ghi nội dung và quy tắc của trang web Dấu. Trang web gồm trang tải về (M8 (Website)) và trang so sánh cách gõ (M10 (Học cách gõ)). Mốc và tiêu chí xong nằm ở [`docs/Roadmap.md`](Roadmap.md), nhận diện ở [`docs/Brand.md`](Brand.md), giao diện app ở [`docs/UI.md`](UI.md).

Công nghệ, chỗ đặt mã và ngôn ngữ của trang theo D45 (Trang web). Cấu hình và nguồn dữ liệu nằm ở [`docs/research/WebsiteStack.md`](research/WebsiteStack.md).

Mọi trang theo các quy tắc chung sau:

- Trang chỉ hứa điều đã kiểm chứng (N5 (Chỉ hứa điều đã kiểm chứng)). Ô số liệu để trống dạng `[Kết quả bài test tải nặng]` cho tới khi có kết quả test thật. Trang không ghi "chạy tốt trong mọi app" và không đặt danh sách logo ứng dụng khi chưa có số đo ([`docs/Compatibility.md`](Compatibility.md)).
- Trang không gọi tên sản phẩm khác.
- Nút tải không dùng logo Apple, vì đó là nhãn hiệu của Apple; nút dùng biểu tượng mũi tên tải xuống.
- Mỗi trang có bản tiếng Việt và bản tiếng Anh với cùng nội dung và cùng mã mục. Tên giao diện macOS trong bản tiếng Việt ghi bằng tiếng Việt của Apple, kèm tiếng Anh trong ngoặc, vì trang không biết macOS của người đọc dùng ngôn ngữ nào. Bản tiếng Anh chỉ ghi tên tiếng Anh của Apple (D38 (Chữ trên giao diện)).
- Trang không có ảnh chụp app. Các mô hình minh hoạ thay cho ảnh chụp, vì ảnh chụp phải chụp lại mỗi khi giao diện đổi và phải có bản cho từng ngôn ngữ.
- Hướng dẫn cài và bật Dấu nằm trong mục Hỏi đáp và trong onboarding của app, không có trang riêng.
- Trang lỗi 404 hiện cùng lúc tiếng Việt và tiếng Anh, vì một đường dẫn lạ không cho biết người đọc muốn bản nào.

## Trang tải về (M8)

Artboard của trang có hai bản: [máy tính](canvas/Landing.png) và [điện thoại](canvas/LandingMobile.png). Artboard tiếng Anh của hai bản này chưa có và phải có trước khi viết mã.

- Trang dùng phông Be Vietnam Pro, nền Giấy và màu nhấn Mực (D25 (Nhận diện)).
- Một mã nguồn responsive phục vụ cả máy tính lẫn điện thoại.
- Các mô hình minh hoạ cách Dấu làm việc nằm ở trang "Trang web" của canvas, cạnh artboard trang tải về. Mỗi mục dưới đây dẫn tới mô hình của nó. Mọi ví dụ chữ trong mô hình lấy từ một test của engine. Hoạt ảnh trong mô hình là CSS dựng sẵn và chỉ hiện khung cuối khi người dùng bật giảm chuyển động (`prefers-reduced-motion`).

Các mục xếp theo thứ tự sau. Trang mở bằng một ý: Dấu thay chữ ngay tại chỗ bạn gõ, không gạch chân và không phím giả. Các mục giữa là bằng chứng cho ý đó. Trang khép bằng nút tải trước phần góp sức. Mã mục ghi trong ngoặc sau tên mục, giống nhau ở hai bản; app và tài liệu dẫn tới mục bằng mã này.

1. **Thanh điều hướng** có logo, các liên kết Tính năng, Bảng gõ, Hỏi đáp, GitHub (ẩn trên điện thoại) và nút chính.
2. **Hero:**
   - Một dòng chữ nhỏ chứa cụm "Bộ gõ tiếng Việt cho macOS" để máy tìm kiếm nhận ra trang. Trên điện thoại, dòng này chỉ có đúng cụm đó.
   - Tiêu đề là câu "Gõ tiếng Việt trên Mac, tự nhiên như vốn có." Trên máy tính, tiêu đề nằm trong hai đến ba dòng.
   - Phụ đề là câu "Dấu thay chữ ngay tại chỗ bạn gõ: không gạch chân, không phím xoá giả. Gõ Telex hay VNI như bạn vẫn quen." Câu này đúng với mặc định của D13 (Gạch chân là đường lui cuối cùng) và cách làm của N3 (Ít lời gọi vào ứng dụng đích).
   - Bên dưới phụ đề có nút chính, nút "Xem mã nguồn" và một dòng yêu cầu hệ thống.
   - Bên phải là hoạt ảnh phát lại chuỗi phím thành chữ có dấu. Hoạt ảnh chỉ hiện phím vừa gõ, không hiện sẵn cả chuỗi và có một từ gõ dấu giữa chừng (`hofa` ra "hoà") theo mô hình [Gõ phím dấu ở đâu cũng được](canvas/ModelTonePlacement.png) (D28 (Đặt dấu tự do), D15 (Cài đặt mặc định)). Hoạt ảnh dựng sẵn bằng CSS, không phải engine chạy trên web. Khi người dùng bật giảm chuyển động (`prefers-reduced-motion`), hoạt ảnh đứng ở câu đã gõ xong.
3. **Vì sao có Dấu** (`#why`) so ba loại bộ gõ trên cùng bốn phím h, o, a, f, theo mô hình [Ba cách gõ “hoà”](canvas/ModelThreeWays.png) (N3, D13). Mục chỉ tả cách mỗi loại làm việc.
   - Bộ gõ có sẵn của macOS dùng gạch chân.
   - Bộ gõ giả lập phím xoá chữ cũ rồi gõ lại bằng phím giả. Dấu không đo các bộ gõ này, nên mục không đặt số đo nào cho chúng (N5).
   - Dấu thay đúng phần chữ cần đổi trong một lần. Chỉ cột của Dấu có ô số đo khi máy bận, lấy từ bài tải nặng của D42 (Ngưỡng hiệu năng). Mục kèm danh sách ứng dụng đã kiểm chứng gõ đúng; danh sách chỉ gồm ứng dụng không mang nhãn "Đề xuất" trong `docs/Compatibility.md`.
   - Mục không có tên API. Mô hình [Đường đi của một phím](canvas/ModelKeyFlow.png) thuộc trang M10, không thuộc trang này.
4. **Tính năng** (`#features`) gồm bốn thẻ. Mỗi thẻ đặt phần hoạt ảnh (ô gõ và phím) của mô hình tương ứng, không đặt tiêu đề hay đoạn dẫn của mô hình:
   - [Giữ nguyên từ nước ngoài](canvas/ModelForeignWords.png) (D4, D26).
   - [Thêm dấu cho từ đã gõ](canvas/ModelAddMarks.png) (D20, D32, D13). Thẻ nói rõ tính năng không áp ở ứng dụng đang bật gạch chân.
   - [Theo từng ứng dụng](canvas/ModelPerApp.png) (D5, D13, D43). Ứng dụng mang nhãn "Đề xuất" chỉ lấy từ `docs/Compatibility.md`.
   - [Như một phần của macOS](canvas/ModelPartOfMacOS.png) (D2, N1, N4).
5. **Bảng gõ Telex và VNI** (`#typing-table`) là một bảng thật (`<table>`). Cột "Tên" ẩn trên điện thoại. Cạnh bảng là ba ô gõ của mô hình [VNI: chữ số sau âm tiết thành dấu](canvas/ModelVNI.png) (D36, D26); mô hình này cũng dùng cho câu hỏi đáp về VNI.
6. **Quyền riêng tư** (`#privacy`) nằm trên nền Mực, theo mô hình [Những gì bạn gõ ở lại trên máy bạn](canvas/ModelPrivacy.png): hai phần chạy riêng của Dấu. Bộ gõ chạy trong sandbox, không có quyền mạng và bản phát hành không ghi gì theo từng phím; chỉ app Dấu kết nối mạng, để kiểm tra và tải bản cập nhật. Danh sách tương thích đi kèm app, không tải riêng (D7). Dưới hai phần đó có một dòng nói mã nguồn công khai trên GitHub theo GPLv3 (D6 (Phát hành)). Mục có thêm một dòng nói đúng cách trang đếm lượt xem: không cookie, không định danh người đọc, số liệu nằm ở Vercel, nơi đặt trang (D45). Nội dung giữ đúng D8 (Không telemetry) và N2 (Bộ gõ không có quyền mạng).
7. **Đo được** (`#measured`). Mục này chỉ hiện khi đã có số đo của bản đang cho tải về; trước đó trang ẩn cả mục, để trang không mở ra với một loạt ô trống. Câu dẫn nói đúng hai nhịp đo: test engine chạy trên mỗi commit, còn bài tải nặng chạy trước mỗi bản phát hành. Mỗi số ghi đúng thứ đã đo và ghi điều kiện đo ngay cạnh nó (N5).
   - Ô lớn duy nhất là số ứng dụng đã đo. Ô nói rõ danh sách gồm cả chỗ Dấu còn gõ sai và dẫn tới `docs/Compatibility.md`.
   - Bên dưới là một hàng nhỏ gồm ba số (trên điện thoại là danh sách ba dòng): số ca test engine; p99 thời gian bộ gõ xử lý một phím có thay chữ dưới tải nặng, kèm ngưỡng 20 ms, bản Debug, máy đo và ngày đo (D42); bộ nhớ (RSS) của tiến trình bộ gõ trong bài tải nặng, kèm ngưỡng 96 MB, bản đo, máy đo và ngày đo (D42). Số p99 không được gọi là độ trễ, vì nó không gồm thời gian của ứng dụng.
   - Một dòng nói bản nào vượt ngưỡng p99 hay bộ nhớ thì không được phát hành. Điều kiện này có bước tương ứng trong `docs/Releasing.md`. Mục không đặt tỷ lệ chữ đúng thành một số, vì D42 buộc chữ đúng ở mọi ô của bài tải nặng thì mới phát hành, nên tỷ lệ đó luôn trọn vẹn.
8. **Hỏi đáp** (`#faq`) có chín câu, mỗi câu là một khối `<details>`.
   - Chín câu hỏi về: Dấu có miễn phí không; Dấu có thu thập dữ liệu không; cần cấp quyền gì; Dấu khác bộ gõ có sẵn thế nào; chuyển từ bộ gõ khác sang ra sao; vì sao không có gõ tắt, viết hoa đầu câu hay chuyển mã; VNI gõ chữ số ra dấu và cách giữ chữ số bằng cách gõ đúp (D36 (VNI: chữ số thành dấu)); làm gì khi một ứng dụng không chọn được Dấu (D37 (Cài bộ gõ)); cách gỡ cài đặt.
   - Câu "Dấu khác bộ gõ có sẵn thế nào" trả lời bằng một câu dẫn lên mục 3, kèm danh sách ứng dụng đã kiểm chứng như ở mục 3.
9. **Tải về** (`#download`):
   - Mục này ghi phiên bản, ngày phát hành, dung lượng và yêu cầu hệ thống.
   - Mục có nút "Tải về (.dmg)" và nút "Lịch sử phiên bản". Nút "Lịch sử phiên bản" mở trang Releases của repo trên GitHub.
   - Lệnh Homebrew xuất hiện khi đã có cask, tức sau bản beta đầu tiên; lệnh ghi ở D6 (Phát hành). Lệnh xuống dòng được và có nút "Sao chép".
   - Mục ghi mã SHA-256 của file tải về, cạnh cam kết "Bản tải về kiểm chứng được".
   - Khi người đọc không dùng Mac, nút chính ở thanh điều hướng, hero và mục này đổi thành "Sao chép liên kết", kèm câu "Dấu chỉ chạy trên Mac. Mở lại trang này trên máy Mac để tải về." Trong mục này, câu đó lên đầu và "Tải về (.dmg)" thành nút phụ. Artboard điện thoại vẽ trạng thái này. Trang là trang tĩnh nên không gửi email.
10. **Góp sức** (`#contribute`):
   - Người đọc có thể góp công: báo lỗi, dùng thử bản mới khi có kênh Beta, góp mã nguồn, giới thiệu Dấu cho người khác.
   - Người đọc có thể ủng hộ qua VietQR và GitHub Sponsors (D39 (Ủng hộ dự án)).
   - Phần Cảm ơn liệt kê tên người ủng hộ, cùng danh sách với mục "Người ủng hộ" trong app và giải thích cách đồng ý được nêu tên (D39). Phần này chỉ nêu tên một người khi người đó đồng ý và không ghi số tiền. Khi chưa có người ủng hộ nào, trang ẩn phần tên và chỉ giữ câu cảm ơn cùng cách đồng ý.
   - Phần "Tiền ủng hộ đã dùng vào việc gì" là một bảng gồm ngày, khoản chi và số tiền. Bảng chỉ ghi khoản đã chi thật (D39, N5).
11. **Chân trang** nằm trên nền Than, có logo có viền và các liên kết tới mã nguồn, báo lỗi, lịch sử phiên bản, hướng dẫn gỡ và ủng hộ.

## Trang "Dấu khác các bộ gõ khác thế nào" (M10)

Trang này chưa có artboard. Mô hình [Đường đi của một phím](canvas/ModelKeyFlow.png) (N3, N2) thuộc trang này. Nội dung và nguồn nằm ở [`docs/Roadmap.md`](Roadmap.md), mục M10. Artboard phải có trước khi viết mã ([`Apps/Dau/CLAUDE.md`](../Apps/Dau/CLAUDE.md)).
