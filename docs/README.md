# Tài liệu

Đây là mục lục các tài liệu trong thư mục `docs/`. Luật ghi thông tin nằm ở [CLAUDE.md](../CLAUDE.md), mục "Nguồn chuẩn". Luật đó quy định mỗi sự kiện chỉ ghi ở một chỗ và file nào cập nhật lúc nào. Luật viết tài liệu nằm ở [`docs/CLAUDE.md`](CLAUDE.md). Mỗi dòng trong các bảng dưới đây tóm tắt một tài liệu. Hiện trạng và ngày cập nhật ghi ở đầu từng file.

## Đọc khi bắt đầu một phiên làm việc

Một phiên làm việc mới đọc tài liệu theo thứ tự ghi trong [CLAUDE.md](../CLAUDE.md): trước hết là `Progress.md`, rồi các phần liên quan trong `Decisions.md`. Bốn tài liệu còn lại chỉ đọc khi việc đang làm chạm tới chúng.

| Tệp tài liệu | Nội dung tóm tắt |
|---|---|
| [`docs/Progress.md`](Progress.md) | Tài liệu ghi tiến độ của mốc đang làm, các việc đang chờ, kế hoạch mốc và nhật ký các lượt đo, chẩn đoán. |
| [`docs/Decisions.md`](Decisions.md) | Sổ ghi các nguyên tắc (N) và quyết định (D). Đây là nguồn chuẩn duy nhất cho quyết định của dự án; cuối sổ có danh sách câu hỏi mở. |
| [`docs/Architecture.md`](Architecture.md) | Tài liệu tả các thành phần, cấu trúc thư mục, cách build và luồng xử lý một phím. |
| [`docs/Roadmap.md`](Roadmap.md) | Tài liệu ghi các mốc, tiêu chí hoàn thành của từng mốc và các việc tồn đọng chưa gắn mốc. |
| [`docs/UI.md`](UI.md) | Tài liệu tả nội dung, bố cục và cách hiển thị của từng màn hình; bản thiết kế gốc nằm trên canvas. |
| [`docs/Brand.md`](Brand.md) | Tài liệu ghi biểu tượng, màu, phông chữ và danh sách file nhận diện cần xuất. |

## Tra cứu khi cần

Các tài liệu dưới đây dùng để tra cứu khi việc đang làm cần tới.

| Tệp tài liệu | Nội dung tóm tắt |
|---|---|
| [`docs/canvas/README.md`](canvas/README.md) | Thư mục giữ bản chụp và nguồn HTML của mọi artboard đã được duyệt. |
| [`docs/UIChecks.md`](UIChecks.md) | Bảng các tiêu chí kiểm giao diện, kèm lệnh kiểm tự động. |
| [`docs/Website.md`](Website.md) | Tài liệu ghi nội dung và quy tắc của trang tải về và trang so sánh cách gõ. |
| [`docs/Compatibility.md`](Compatibility.md) | Tài liệu ghi Dấu gõ đúng hay sai trong từng ứng dụng, cách thử, số đo và các giới hạn đã biết. |
| [`docs/Glossary.md`](Glossary.md) | Bảng thuật ngữ Anh – Việt cho chuỗi giao diện, kèm cách đặt câu tiếng Anh. |
| [`docs/Releasing.md`](Releasing.md) | Tài liệu ghi cách phát hành: sơ đồ các bước, tài khoản và secret cần chuẩn bị, cách gắn tag và cách xử lý chứng chỉ. |
| [`docs/Troubleshooting.md`](Troubleshooting.md) | Tài liệu ghi các sự cố thường gặp khi dùng và khi phát triển Dấu, kèm cách khắc phục. |
| [`scripts/README.md`](../scripts/README.md) | Tài liệu ghi cách dùng các script trong `scripts/`, tác dụng phụ của từng script và quy ước viết script. |

## Tài liệu nghiên cứu

Mỗi tài liệu nghiên cứu bàn một chủ đề kỹ thuật. Kết luận hiện hành và ngày cập nhật ghi ở mục "Hiện trạng" đầu file. Mỗi khẳng định đều dẫn nguồn.

| Tệp tài liệu | Nội dung nghiên cứu |
|---|---|
| [`docs/research/OpenKeyNotes.md`](research/OpenKeyNotes.md) | Tài liệu đọc mã OpenKey và ghi các tính năng, các trường hợp biên, việc Dấu làm hay không làm và những chỗ Dấu cố ý khác. |
| [`docs/research/IMKAPINotes.md`](research/IMKAPINotes.md) | Tài liệu ghi điều tài liệu và header của Apple nói về các API InputMethodKit mà bộ gõ đang dùng. |
| [`docs/research/IMKCapabilities.md`](research/IMKCapabilities.md) | Tài liệu đối chiếu API của InputMethodKit với những gì Dấu đang gọi, tìm API hợp với từng việc mở và đề xuất phép đo rẻ nhất. |
| [`docs/research/InputMethodInstall.md`](research/InputMethodInstall.md) | Tài liệu nghiên cứu cách macOS cài, bật, nâng cấp và gỡ bộ gõ, cùng cách phát hiện bộ gõ cũ đang xung đột. |
| [`docs/research/SystemSettingsReference.md`](research/SystemSettingsReference.md) | Tài liệu ghi số đo khoảng cách và bố cục của System Settings, dùng làm chuẩn cho giao diện Dấu. |
| [`docs/research/SwiftUIWindowAPI.md`](research/SwiftUIWindowAPI.md) | Tài liệu nghiên cứu API của Apple cho thanh bên (sidebar), thanh công cụ, thanh tiêu đề và ô tìm kiếm của cửa sổ Cài đặt. |
| [`docs/research/external-test-inputs/README.md`](research/external-test-inputs/README.md) | Thư mục gom các chuỗi phím thử trường hợp biên, lấy từ bộ test của các bộ gõ tiếng Việt khác (ghi công tại [`docs/research/external-test-inputs/NOTICE.md`](research/external-test-inputs/NOTICE.md)). |
| [`docs/research/CompetitorComparison.md`](research/CompetitorComparison.md) | Tài liệu so sánh Dấu với Telex có sẵn của macOS trên ứng dụng thật và với các bộ gõ khác ở mức engine. |
| [`docs/research/TerminalAndUnderline.md`](research/TerminalAndUnderline.md) | Tài liệu phân tích cách gõ phím trong terminal Ghostty và terminal xterm.js (nhóm ô nhập bỏ qua vùng thay chữ), cùng giải pháp sửa chữ ở chế độ gạch chân. |
| [`docs/research/JetBrainsInput.md`](research/JetBrainsInput.md) | Tài liệu nghiên cứu đường ký tự đi vào terminal và trình soạn thảo của WebStorm (JetBrains Runtime), từ dự đoán theo mã nguồn và từ số đo. |
| [`docs/research/WebInputDelay.md`](research/WebInputDelay.md) | Tài liệu đo thời gian luồng chính của trang web bận khi gõ phím và giới hạn rủi ro của nó với cách thay chữ tại chỗ. |
| [`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md) | Tài liệu phân tích và đề xuất hướng sửa cho bốn kịch bản ứng dụng trả lời chậm (chậm sau ⌫, tính vị trí theo từ, trang bận qua chỗ ngắt từ và WebKit dồn phím). |
| [`docs/research/MonacoInput.md`](research/MonacoInput.md) | Tài liệu nghiên cứu cách trình soạn thảo Monaco (VS Code, Cursor) đưa chữ cho bộ gõ trên macOS: ô textarea ẩn hay EditContext, ô chứa gì theo chế độ trình đọc màn hình, Chromium trả lời bộ gõ theo toạ độ nào, và các hướng sửa. |
| [`docs/research/EditingTypedText.md`](research/EditingTypedText.md) | Tài liệu khảo sát cách người dùng sửa chữ khi đang gõ, nguyên nhân Dấu sai và hướng sửa. |
| [`docs/research/WebEditorInput.md`](research/WebEditorInput.md) | Tài liệu khảo sát cách các bộ gõ trên macOS nhập chữ vào Google Docs, dữ liệu Chrome gửi cho bộ gõ và chế độ hỗ trợ tiếp cận của Google Docs. |
| [`docs/research/VietnameseProse.md`](research/VietnameseProse.md) | Tài liệu tìm nguồn cho các thói quen câu tiếng Anh trong văn tiếng Việt của repo (dấu phẩy trước "và", bị động thừa, danh hoá…), đo số lần xuất hiện và xếp theo mức chắc chắn. |

## Tài liệu lưu trữ lịch sử

Thư mục `docs/history/` giữ các bản ghi lịch sử của dự án. Sự kiện, số đo và ngày giữ đúng như lúc ghi. Câu chữ viết lại theo D44, còn tên file và liên kết sửa khi file đổi tên để liên kết và tìm kiếm còn đúng.

| Tệp tài liệu | Nội dung lưu trữ |
|---|---|
| [`docs/history/Plans.md`](history/Plans.md) | Kế hoạch ban đầu của các mốc phát triển đã đóng, cùng các bước thử nghiệm cài đặt trên máy sạch đã bị loại bỏ. |
| [`docs/history/M2Testing.md`](history/M2Testing.md) | Báo cáo chi tiết các đợt gõ thử nghiệm mốc M2 trên máy thật và kết quả đo đạc tương ứng. |
| [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md) | Nhật ký phát triển các mốc M0–M4; bảng "Số đo (M1–M3)" là nguồn dữ liệu gốc cho các số đo thời kỳ đầu mà các tài liệu khác dẫn chiếu. |
| [`docs/history/LogM5.md`](history/LogM5.md) | Nhật ký phát triển và kiểm toán chi tiết của mốc M5. |
| [`docs/history/LogBetweenM5AndM6.md`](history/LogBetweenM5AndM6.md) | Nhật ký công việc kỹ thuật làm trong giai đoạn chuyển tiếp giữa mốc M5 và M6. |
| [`docs/history/LogM6.md`](history/LogM6.md) | Nhật ký phát triển mốc M6, đi kèm danh sách hạng mục cắt giảm ngày 13/11 và bảng thống nhất thuật ngữ ngày 16/11. |
| [`docs/history/LogM7.md`](history/LogM7.md) | Nhật ký phát triển mốc M7 đang thực hiện: lưu trữ các phần việc đã hoàn thành, chuyển từ `docs/Progress.md`. |
| [`docs/history/DecisionsLog.md`](history/DecisionsLog.md) | Lịch sử ban hành và điều chỉnh của từng nguyên tắc và quyết định: ngày chốt, người quyết định, nội dung cũ và lý do thay đổi. |
| [`docs/history/ResearchLog.md`](history/ResearchLog.md) | Phần nhật ký lịch sử tách khỏi các tài liệu nghiên cứu: kế hoạch thử nghiệm, các vòng kiểm tra theo giờ và bảng theo dõi đổi mục. |
| [`docs/history/CompatibilityFixed.md`](history/CompatibilityFixed.md) | Ghi nhận chi tiết các lỗi tương thích ứng dụng đã được khắc phục kèm kết quả chẩn đoán và lượt chạy ma trận ngày 30/10/2026. |
| [`docs/history/DocsLog.md`](history/DocsLog.md) | Phần nhật ký lịch sử tách khỏi các tài liệu khi chúng chuyển đổi sang mô hình chỉ ghi nhận hiện trạng. |
| [`docs/history/CommitMap.md`](history/CommitMap.md) | Bảng tra cứu đối chiếu mã băm commit cũ và commit mới sau khi viết lại lịch sử kho mã nguồn. |
