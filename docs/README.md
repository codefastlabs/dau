# Tài liệu

Mục lục mọi tài liệu trong `docs/`. Cách ghi (mỗi sự kiện ở một chỗ, khi nào sửa file nào): [CLAUDE.md](../CLAUDE.md), mục "Nguồn chuẩn" và "Viết tài liệu". Mỗi dòng chỉ nói file chứa gì; trạng thái và ngày nằm ở đầu từng file.

## Đọc khi bắt đầu một phiên

Theo thứ tự trong [CLAUDE.md](../CLAUDE.md):

| File | Chứa gì |
|---|---|
| [`docs/PROGRESS.md`](PROGRESS.md) | mốc đang làm, việc đang chờ, số đo, nhật ký theo ngày |
| [`docs/DECISIONS.md`](DECISIONS.md) | nguyên tắc N và quyết định D (nguồn chuẩn duy nhất), câu hỏi mở |
| [`docs/ARCHITECTURE.md`](ARCHITECTURE.md) | thành phần, cấu trúc thư mục, build, luồng một phím |
| [`docs/ROADMAP.md`](ROADMAP.md) | các mốc, tiêu chí hoàn thành, việc tồn đọng |
| [`docs/UI.md`](UI.md) | nội dung từng màn hình (mockup trên canvas) |
| [`docs/BRAND.md`](BRAND.md) | biểu tượng, màu, chữ, file nhận diện cần xuất |

## Tra khi cần

| File | Chứa gì |
|---|---|
| [`docs/canvas/README.md`](canvas/README.md) | bản chụp canvas thiết kế: ảnh và nguồn từng artboard đã duyệt |
| [`docs/UI-CHECKS.md`](UI-CHECKS.md) | danh sách kiểm giao diện và lệnh chạy |
| [`docs/WEBSITE.md`](WEBSITE.md) | nội dung và quy tắc của trang tải về và trang so sánh cách gõ |
| [`docs/COMPATIBILITY.md`](COMPATIBILITY.md) | ma trận ứng dụng: cách thử, kết quả, giới hạn đã biết |
| [`docs/GLOSSARY.md`](GLOSSARY.md) | thuật ngữ Anh–Việt của chuỗi giao diện và cách viết câu tiếng Anh |
| [`docs/TROUBLESHOOTING.md`](TROUBLESHOOTING.md) | sự cố đã gặp khi dùng và khi phát triển, cách xử lý |
| [`scripts/README.md`](../scripts/README.md) | thư mục script, tác dụng phụ, quy ước viết script |

## Nghiên cứu

Mỗi chủ đề một file; kết luận hiện hành và ngày ở mục "Hiện trạng" đầu file, mỗi khẳng định có nguồn.

| File | Chủ đề |
|---|---|
| [`docs/research/OPENKEY-NOTES.md`](research/OPENKEY-NOTES.md) | đọc mã OpenKey: tính năng, ca biên, Dấu làm hay không; chỗ Dấu cố ý khác OpenKey |
| [`docs/research/IMK-API-NOTES.md`](research/IMK-API-NOTES.md) | tài liệu và header của Apple về các API InputMethodKit mà bộ gõ dùng |
| [`docs/research/INPUT-METHOD-INSTALL.md`](research/INPUT-METHOD-INSTALL.md) | cài, bật, nâng cấp, gỡ bộ gõ; lần cài đầu; bộ gõ cũ cần phát hiện |
| [`docs/research/SYSTEM-SETTINGS-REFERENCE.md`](research/SYSTEM-SETTINGS-REFERENCE.md) | số đo giao diện của System Settings dùng làm chuẩn |
| [`docs/research/SWIFTUI-WINDOW-API.md`](research/SWIFTUI-WINDOW-API.md) | API của Apple cho sidebar, thanh công cụ, tiêu đề, ô tìm của cửa sổ Cài đặt; cách vá đã gỡ |
| [`docs/research/external-test-inputs/README.md`](research/external-test-inputs/README.md) | ca thử (chuỗi phím, không đáp án) gom từ bộ test của các bộ gõ tiếng Việt khác; ghi công ở [`docs/research/external-test-inputs/NOTICE.md`](research/external-test-inputs/NOTICE.md) |
| [`docs/research/COMPETITOR-COMPARISON.md`](research/COMPETITOR-COMPARISON.md) | so sánh Dấu với bộ gõ khác: Telex của macOS trong ứng dụng thật, các bộ gõ khác ở mức engine |
| [`docs/research/TERMINAL-AND-UNDERLINE.md`](research/TERMINAL-AND-UNDERLINE.md) | gõ trong Ghostty và terminal dựng bằng xterm.js (ô bỏ qua vùng thay chữ); sửa chữ ở chế độ gạch chân |
| [`docs/research/WEB-INPUT-DELAY.md`](research/WEB-INPUT-DELAY.md) | luồng chính của trang web bận bao lâu khi gõ, và giới hạn khi suy ra rủi ro cho thay chữ tại chỗ |

## Lưu trữ

Ghi lại quá khứ, không sửa theo hiện trạng.

| File | Chứa gì |
|---|---|
| [`docs/history/PLANS.md`](history/PLANS.md) | kế hoạch của các mốc đã đóng; các bước của lần thử cài trên máy sạch đã bỏ |
| [`docs/history/M2-TESTING.md`](history/M2-TESTING.md) | gõ thử M2 trên máy thật và kết quả |
| [`docs/history/LOG-M0-M4.md`](history/LOG-M0-M4.md) | nhật ký M0–M4; bảng "Số đo (M1–M3)" là nguồn của các số đo M1–M3 mà tài liệu khác dẫn |
| [`docs/history/LOG-M5.md`](history/LOG-M5.md) | nhật ký M5 |
| [`docs/history/LOG-BETWEEN-M5-M6.md`](history/LOG-BETWEEN-M5-M6.md) | nhật ký giữa M5 và M6 |
| [`docs/history/DECISIONS-LOG.md`](history/DECISIONS-LOG.md) | lịch sử từng nguyên tắc và quyết định: ngày, ai chốt, bản trước, cách nói cũ |
| [`docs/history/RESEARCH-LOG.md`](history/RESEARCH-LOG.md) | phần lịch sử tách khỏi các tài liệu nghiên cứu: kế hoạch, vòng thử theo giờ, bảng đổi số mục |
| [`docs/history/COMPATIBILITY-FIXED.md`](history/COMPATIBILITY-FIXED.md) | lỗi tương thích đã sửa kèm chẩn đoán; lượt chạy ma trận 30/10/2026 |
| [`docs/history/DOCS-LOG.md`](history/DOCS-LOG.md) | phần lịch sử tách khỏi các tài liệu khi chúng chuyển sang chỉ ghi hiện trạng |
| [`docs/history/COMMIT-MAP.md`](history/COMMIT-MAP.md) | mã commit cũ → mới sau khi viết lại lịch sử |
