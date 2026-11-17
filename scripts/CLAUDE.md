# Script và đo độ đúng khi gõ

Viết script: [`scripts/README.md`](README.md) (mục "Ngôn ngữ", "Đầu ra", tác dụng phụ). Ai được chạy script nào: [`CLAUDE.md`](../CLAUDE.md) gốc, mục "Điều phối".

## Đo độ đúng khi gõ

Áp cho mọi lượt gõ thử (`scripts/selftest/typing/run.sh`, `scripts/research/`, `/dogfood`) và cho câu thử trong test.

- Đối chứng là bộ gõ tiếng Việt khác trong cùng điều kiện (Telex của Apple), không phải bàn phím U.S.
- Câu thử là câu tiếng Việt có nghĩa, mang ý tích cực, mà vẫn chứa đúng ca cần đo; không dùng từ vô nghĩa hay chuỗi ghép cho đủ ca.
- Đáp án là chữ người gõ muốn ra, khớp từng phím đã gõ (soát chuỗi phím trước khi chạy).
- Chuỗi thử gõ như người dùng thật: đặt dấu tự do, đổi và xoá dấu, ⌫ giữa từ, thêm dấu cho từ đã gõ, từ tiếng Anh; không chỉ Telex thứ tự chuẩn.
- Biết chắc phím vào ô nào, và bộ gõ nào đang xử lý phím trong ô đó, trước khi tin "đạt". Nguồn do macOS báo hay biểu tượng trên thanh menu chưa đủ. Bộ gõ đối chứng chuyển bằng phím tắt chuyển nguồn của hệ thống khi ô gõ đã có focus, không bằng API từ tiến trình của script (cách làm ở đầu `scripts/selftest/typing/run.sh`). Ô đối chứng ra nguyên chuỗi phím là đo hỏng, không phải kết quả.
- Bước kiểm tự nó cũng là phép đo: phím gửi dồn, chữ gạch chân chưa chốt, hay một từ thử không phải tiếng Việt đều cho kết quả sai về bộ gõ.
- Chạy thẳng ô phân biệt được các giả thuyết, kèm đối chứng, thay vì cả ma trận.
- Mọi thứ cần để dựng lại một lượt đo (chuỗi phím, đáp án, lệnh) nằm trong repo, không trong thư mục tạm. Log của lượt đo thì không (`CLAUDE.md` gốc, ý "Repo là công khai").
