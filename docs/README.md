# Tài liệu

Tài liệu này là mục lục tra cứu toàn bộ các tài liệu kỹ thuật nằm trong thư mục `docs/`. Quy ước ghi nhận thông tin (mỗi sự kiện chỉ ghi tại một nơi duy nhất, quy định thời điểm cập nhật từng tệp) được hướng dẫn tại [CLAUDE.md](../CLAUDE.md), mục "Nguồn chuẩn" và [`docs/CLAUDE.md`](CLAUDE.md) (quy tắc viết tài liệu). Trong các bảng danh mục dưới đây, mỗi mục tóm tắt ngắn gọn nội dung cốt lõi của từng tài liệu; trạng thái hiện tại và ngày cập nhật cụ thể được ghi nhận ở phần đầu của mỗi tệp.

## Đọc khi bắt đầu một phiên làm việc

Khi bắt đầu một phiên làm việc mới, bạn nên đọc tài liệu theo thứ tự ưu tiên đã quy định trong [CLAUDE.md](../CLAUDE.md): trước hết là `Progress.md`, tiếp theo là các phần liên quan trong `Decisions.md`; bốn tài liệu còn lại sẽ được đọc khi công việc thực tế chạm tới phạm vi tương ứng.

| Tệp tài liệu | Nội dung tóm tắt |
|---|---|
| [`docs/Progress.md`](Progress.md) | Ghi nhận tiến độ mốc đang thực hiện, các công việc đang chờ, kế hoạch chi tiết, cùng nhật ký đo đạc và chẩn đoán lỗi. |
| [`docs/Decisions.md`](Decisions.md) | Ghi nhận các nguyên tắc (N) và quyết định (D) làm nguồn chân lý chuẩn xác duy nhất của dự án, đi kèm danh sách câu hỏi mở. |
| [`docs/Architecture.md`](Architecture.md) | Mô tả các thành phần hệ thống, cấu trúc thư mục, quy trình biên dịch và luồng xử lý chi tiết của từng phím gõ. |
| [`docs/Roadmap.md`](Roadmap.md) | Tổng hợp các mốc phát triển, tiêu chí hoàn thành của từng mốc và các hạng mục tồn đọng chưa gắn mốc. |
| [`docs/UI.md`](UI.md) | Mô tả chi tiết nội dung, bố cục và logic hiển thị của từng màn hình giao diện (thiết kế gốc nằm trên canvas). |
| [`docs/Brand.md`](Brand.md) | Quy định hệ thống nhận diện thương hiệu gồm biểu tượng, màu sắc, phông chữ và danh sách tệp đồ họa cần xuất bản. |

## Tra cứu khi cần

Các tài liệu dưới đây được sử dụng để tra cứu chuyên sâu khi công việc phát triển yêu cầu:

| Tệp tài liệu | Nội dung tóm tắt |
|---|---|
| [`docs/canvas/README.md`](canvas/README.md) | Lưu trữ bản chụp hình ảnh và tệp mã nguồn HTML của toàn bộ các artboard thiết kế đã được phê duyệt. |
| [`docs/UIChecks.md`](UIChecks.md) | Bảng danh mục các tiêu chí kiểm tra giao diện người dùng kèm theo các câu lệnh kiểm thử tự động. |
| [`docs/Website.md`](Website.md) | Quy định nội dung, cấu trúc và tiêu chuẩn kỹ thuật của trang web tải về cùng trang so sánh tính năng bộ gõ. |
| [`docs/Compatibility.md`](Compatibility.md) | Ma trận tương thích ứng dụng ghi nhận phương pháp kiểm thử, kết quả đo đạc thực tế và các giới hạn kỹ thuật đã biết. |
| [`docs/Glossary.md`](Glossary.md) | Bảng thuật ngữ song ngữ Anh – Việt chuẩn hóa cho các chuỗi giao diện và hướng dẫn đặt câu tiếng Anh. |
| [`docs/Releasing.md`](Releasing.md) | Hướng dẫn toàn diện quy trình phát hành: sơ đồ luồng công việc, chuẩn bị tài khoản và secret, quy trình gắn tag, cùng hướng dẫn xử lý chứng chỉ. |
| [`docs/Troubleshooting.md`](Troubleshooting.md) | Tổng hợp các sự cố thường gặp trong quá trình sử dụng và phát triển ứng dụng kèm theo hướng dẫn khắc phục cụ thể. |
| [`scripts/README.md`](../scripts/README.md) | Hướng dẫn sử dụng các script tự động hóa trong thư mục `scripts/`, tác động phụ của từng script và quy ước viết mã. |

## Tài liệu nghiên cứu

Mỗi tài liệu nghiên cứu tập trung vào một chủ đề kỹ thuật cụ thể; kết luận hiện hành và thời điểm cập nhật được ghi tại mục "Hiện trạng" ở đầu tệp, và mọi khẳng định đều có nguồn dẫn chứng xác thực:

| Tệp tài liệu | Nội dung nghiên cứu |
|---|---|
| [`docs/research/OpenKeyNotes.md`](research/OpenKeyNotes.md) | Phân tích mã nguồn OpenKey: tổng hợp tính năng, các trường hợp biên, quyết định Dấu làm hay không làm, và các điểm Dấu cố ý khác biệt. |
| [`docs/research/IMKAPINotes.md`](research/IMKAPINotes.md) | Tài liệu kỹ thuật và tệp header của Apple về các API trong InputMethodKit mà bộ gõ đang trực tiếp sử dụng. |
| [`docs/research/IMKCapabilities.md`](research/IMKCapabilities.md) | Kiểm toán toàn diện API của InputMethodKit so với hiện trạng Dấu đang gọi, tìm kiếm API phù hợp cho từng việc mở và đề xuất phép đo rẻ nhất. |
| [`docs/research/InputMethodInstall.md`](research/InputMethodInstall.md) | Nghiên cứu cơ chế cài đặt, kích hoạt, nâng cấp và gỡ bỏ bộ gõ trên macOS, cùng giải pháp phát hiện xung đột với các bộ gõ cũ. |
| [`docs/research/SystemSettingsReference.md`](research/SystemSettingsReference.md) | Tổng hợp số đo khoảng cách và bố cục giao diện của ứng dụng System Settings để làm chuẩn thiết kế cho Dấu. |
| [`docs/research/SwiftUIWindowAPI.md`](research/SwiftUIWindowAPI.md) | Nghiên cứu API của Apple dành cho thanh bên (sidebar), thanh công cụ, thanh tiêu đề và ô tìm kiếm của cửa sổ Cài đặt. |
| [`docs/research/external-test-inputs/README.md`](research/external-test-inputs/README.md) | Tập hợp các chuỗi phím thử nghiệm biên thu thập từ bộ test của các bộ gõ tiếng Việt khác (ghi công tại [`docs/research/external-test-inputs/NOTICE.md`](research/external-test-inputs/NOTICE.md)). |
| [`docs/research/CompetitorComparison.md`](research/CompetitorComparison.md) | Báo cáo so sánh Dấu với các bộ gõ khác: đối chiếu với Telex mặc định của macOS trên ứng dụng thật và so sánh ở cấp độ engine. |
| [`docs/research/TerminalAndUnderline.md`](research/TerminalAndUnderline.md) | Phân tích cơ chế gõ phím trong terminal Ghostty và terminal xterm.js (nhóm ô nhập bỏ qua vùng thay chữ), cùng giải pháp sửa chữ ở chế độ gạch chân. |
| [`docs/research/JetBrainsInput.md`](research/JetBrainsInput.md) | Nghiên cứu đường truyền ký tự vào terminal và trình soạn thảo của WebStorm (JetBrains Runtime), kết hợp dự đoán từ mã nguồn và số đo thực tế. |
| [`docs/research/WebInputDelay.md`](research/WebInputDelay.md) | Đo lường thời gian bận của luồng chính trên trang web khi gõ phím và đánh giá giới hạn rủi ro đối với cơ chế thay chữ tại chỗ. |
| [`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md) | Phân tích cơ chế và đề xuất hướng xử lý cho bốn kịch bản ứng dụng trả lời chậm (chậm sau ⌫, tính vị trí theo từ, trang bận qua chỗ ngắt từ, và WebKit dồn phím). |
| [`docs/research/EditingTypedText.md`](research/EditingTypedText.md) | Khảo sát các hành vi chỉnh sửa văn bản của người dùng khi đang gõ, phân tích nguyên nhân lỗi của Dấu và đề xuất hướng khắc phục. |
| [`docs/research/WebEditorInput.md`](research/WebEditorInput.md) | Khảo sát cách các bộ gõ trên macOS nhập liệu vào Google Docs, phân tích dữ liệu Chrome gửi cho bộ gõ và cơ chế hỗ trợ tiếp cận của Google Docs. |

## Tài liệu lưu trữ lịch sử

Thư mục này lưu trữ các bản ghi lịch sử của dự án nhằm phản ánh đúng nguyên trạng quá khứ. Tên tệp và đường dẫn liên kết vẫn được cập nhật khi có sự thay đổi để đảm bảo các liên kết tra cứu và tìm kiếm luôn hoạt động chính xác:

| Tệp tài liệu | Nội dung lưu trữ |
|---|---|
| [`docs/history/Plans.md`](history/Plans.md) | Kế hoạch ban đầu của các mốc phát triển đã đóng, cùng các bước thử nghiệm cài đặt trên máy sạch đã bị loại bỏ. |
| [`docs/history/M2Testing.md`](history/M2Testing.md) | Báo cáo chi tiết các đợt gõ thử nghiệm mốc M2 trên máy thật và kết quả đo đạc tương ứng. |
| [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md) | Nhật ký phát triển các mốc M0–M4; bảng "Số đo (M1–M3)" là nguồn dữ liệu gốc cho các số đo thời kỳ đầu được các tài liệu khác dẫn chiếu. |
| [`docs/history/LogM5.md`](history/LogM5.md) | Nhật ký phát triển và kiểm toán chi tiết của mốc M5. |
| [`docs/history/LogBetweenM5AndM6.md`](history/LogBetweenM5AndM6.md) | Nhật ký công việc kỹ thuật được thực hiện trong giai đoạn chuyển tiếp giữa mốc M5 và M6. |
| [`docs/history/LogM6.md`](history/LogM6.md) | Nhật ký phát triển mốc M6, đi kèm danh sách hạng mục cắt giảm ngày 13/11 và bảng thống nhất thuật ngữ ngày 16/11. |
| [`docs/history/LogM7.md`](history/LogM7.md) | Nhật ký phát triển mốc M7 đang thực hiện: lưu trữ các phần việc đã hoàn thành được chuyển từ `docs/Progress.md`. |
| [`docs/history/DecisionsLog.md`](history/DecisionsLog.md) | Lịch sử ban hành và điều chỉnh của từng nguyên tắc và quyết định: ngày chốt, người quyết định, nội dung cũ và lý do thay đổi. |
| [`docs/history/ResearchLog.md`](history/ResearchLog.md) | Phần nhật ký lịch sử được tách khỏi các tài liệu nghiên cứu: kế hoạch thử nghiệm, các vòng kiểm tra theo giờ và bảng theo dõi đổi mục. |
| [`docs/history/CompatibilityFixed.md`](history/CompatibilityFixed.md) | Ghi nhận chi tiết các lỗi tương thích ứng dụng đã được khắc phục kèm kết quả chẩn đoán và lượt chạy ma trận ngày 30/10/2026. |
| [`docs/history/DocsLog.md`](history/DocsLog.md) | Phần nhật ký lịch sử được tách khỏi các tài liệu khi chúng chuyển đổi sang mô hình chỉ ghi nhận hiện trạng. |
| [`docs/history/CommitMap.md`](history/CommitMap.md) | Bảng tra cứu đối chiếu mã băm commit cũ và commit mới sau khi viết lại lịch sử kho mã nguồn. |
