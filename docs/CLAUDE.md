# Viết tài liệu

Luật cho mọi tài liệu của repo: `docs/`, README và CONTRIBUTING ở gốc, `.claude/`. Hai luật áp cho mọi thay đổi (đổi mã thì sửa tài liệu trong cùng commit; tự soát trước khi commit) nằm ở [`CLAUDE.md`](../CLAUDE.md) gốc, mục "Viết tài liệu"; mỗi sự kiện ghi ở đâu: mục "Nguồn chuẩn".

Tài liệu mục nhanh hơn mã, vì không có test nào đỏ khi nó sai. Các luật dưới đây giữ cho nó ít, đúng và theo kịp mã.

- **Chỉ ghi điều mã không tự nói.** Quyết định và lý do (`Decisions.md`), cấu trúc và luồng giữa các thành phần (`Architecture.md`), cách dùng (README, CONTRIBUTING), kết luận nghiên cứu. Chi tiết đổi theo mã (giá trị hằng số, các bước bên trong một hàm, tuỳ chọn của script) nằm trong comment của mã hay đầu script; tài liệu dẫn tên kiểu, hàm, script.
- **Ghi hiện trạng, không ghi nhật ký.** File tra cứu chỉ giữ điều đang đúng. Việc xong thì xoá kế hoạch và danh sách bước của nó, kết quả thay vào chỗ câu hỏi; diễn biến theo lượt, theo ngày vào nhật ký `Progress.md` (rồi `docs/history/`), không vào file tra cứu.
- **Thứ tự theo người đọc.** Mở đầu bằng mục đích và kết luận; kết quả nằm cạnh câu hỏi nó trả lời; phần quan trọng trước, phần đã dừng hay để sau ở cuối. Câu ngắn; gạch đầu dòng cho các ý ngang hàng, không cho một đoạn văn.
- **Tài liệu nghiên cứu (`docs/research/`) có mục "Hiện trạng" ở đầu, ghi ngày.** Kết luận đổi thì sửa thẳng vào mục đó và vào thân bài, không viết thêm mục "Đính chính" ở cuối.
- **Tên file theo cách các repo của Apple đặt.** File chuẩn ở gốc repo và `README.md`, `CLAUDE.md` của từng thư mục viết hoa toàn bộ (`README.md`, `CONTRIBUTING.md`, `LICENSE`); mọi tài liệu khác viết PascalCase, từ viết tắt giữ hoa (`docs/Decisions.md`, `docs/UIChecks.md`, `docs/research/SwiftUIWindowAPI.md`). Đổi tên file thì sửa mọi chỗ dẫn trong cùng commit.
- **Viết cho GitHub.** Tài liệu công khai trên GitHub: file trong repo dẫn bằng liên kết bấm được (``[`docs/Decisions.md`](docs/Decisions.md)``); chú thích cuối trang dùng URL đầy đủ (GitHub không đổi liên kết tương đối ở đó); thoát `|` trong bảng; chuỗi `<…>` để trong backtick.
