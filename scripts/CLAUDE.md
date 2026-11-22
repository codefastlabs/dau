# Script và đo độ đúng khi gõ

Viết script: [`scripts/README.md`](README.md) (mục "Ngôn ngữ", "Đầu ra", tác dụng phụ). Ai được chạy script nào: [`CLAUDE.md`](../CLAUDE.md) gốc, mục "Điều phối".

## Đo độ đúng khi gõ

Áp cho mọi lượt gõ thử (`scripts/selftest/typing/run.sh`, `scripts/research/`, `/dogfood`) và cho câu thử trong test.

- Đối chứng là bộ gõ tiếng Việt khác trong cùng điều kiện (Telex của Apple), không phải bàn phím U.S.
  - Telex của Apple trả lời hai câu: ô đo có hợp lệ không và một lỗi có xảy ra với một bộ gõ IMK khác ở tính năng mà nó cũng có không. Telex của Apple không có D20 (Thêm dấu cho từ đã gõ) và không khôi phục từ (D4); chữ nó ra ở các phím đó không phải chuẩn để so với Dấu.
  - Với tính năng Telex của Apple không có, đối chứng là chính Dấu ở cùng ô mà không có điều kiện đang thử (trang rảnh thay cho trang bận, nhịp chậm thay cho phím dồn). Không viết "giống Telex của Apple" để giảm nhẹ một lỗi của Dấu ở tính năng đó.
- Câu thử là câu tiếng Việt có nghĩa, mang ý tích cực, mà vẫn chứa đúng ca cần đo; không dùng từ vô nghĩa hay chuỗi ghép cho đủ ca.
- Đáp án là chữ người gõ muốn ra, khớp từng phím đã gõ (soát chuỗi phím trước khi chạy).
- Chuỗi thử gõ như người dùng thật: đặt dấu tự do, đổi và xoá dấu, ⌫ giữa từ, thêm dấu cho từ đã gõ, từ tiếng Anh; không chỉ Telex thứ tự chuẩn.
- Biết chắc phím vào ô nào và bộ gõ nào đang xử lý phím trong ô đó trước khi tin "đạt". Nguồn do macOS báo hay biểu tượng trên thanh menu chưa đủ. Bộ gõ đối chứng chuyển bằng phím tắt chuyển nguồn của hệ thống khi ô gõ đã có focus, không bằng API từ tiến trình của script (cách làm ở đầu `scripts/selftest/typing/run.sh`). Ô đối chứng ra nguyên chuỗi phím là đo hỏng, không phải kết quả.
- Bước kiểm tự nó cũng là phép đo: phím gửi dồn, chữ gạch chân chưa chốt hay một từ thử không phải tiếng Việt đều cho kết quả sai về bộ gõ.
- Chạy thẳng ô phân biệt được các giả thuyết, kèm đối chứng, thay vì cả ma trận.
- Chạy trọn một app (mọi nhịp, mọi lượt, đối chứng) rồi mới sang app khác, để app sai được xử lý ngay ở ô đó. Trong một app, các điều kiện đem so với nhau (tải, chế độ) vẫn xen kẽ qua các lượt. Ngoại lệ: `load/heavy.sh` gõ mọi app trong mỗi pha tải, vì mỗi pha phải chờ tải tăng lên và các pha theo thứ tự rảnh, tải, tải, rảnh. Ghi giờ chạy từng app cạnh số đo; một app sai trong khi app chạy trước nó đúng thì chạy lại ngay một lượt ở app vừa đúng, cùng điều kiện, để loại trừ máy đổi tải giữa chừng.
- Mọi thứ cần để dựng lại một lượt đo (chuỗi phím, đáp án, lệnh) nằm trong repo, không trong thư mục tạm. Log của lượt đo thì không (`CLAUDE.md` gốc, ý "Repo là công khai").
