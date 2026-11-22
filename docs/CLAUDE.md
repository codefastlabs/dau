# Viết tài liệu

Luật cho mọi tài liệu của repo: `docs/`, README và CONTRIBUTING ở gốc, `.claude/`. Hai luật áp cho mọi thay đổi (đổi mã thì sửa tài liệu trong cùng commit; tự soát trước khi commit) nằm ở [`CLAUDE.md`](../CLAUDE.md) gốc, mục "Viết tài liệu"; mỗi sự kiện ghi ở đâu: mục "Nguồn chuẩn".

Tài liệu mục nhanh hơn mã, vì không có test nào đỏ khi nó sai. Các luật dưới đây giữ cho nó ít, đúng và theo kịp mã.

- **Chỉ ghi điều mã không tự nói.** Quyết định và lý do (`Decisions.md`), cấu trúc và luồng giữa các thành phần (`Architecture.md`), cách dùng (README, CONTRIBUTING), kết luận nghiên cứu. Chi tiết đổi theo mã (giá trị hằng số, các bước bên trong một hàm, tuỳ chọn của script) nằm trong comment của mã hay đầu script; tài liệu dẫn tên kiểu, hàm, script.
- **Ghi hiện trạng, không ghi nhật ký.** File tra cứu chỉ giữ điều đang đúng. Việc xong thì xoá kế hoạch và danh sách bước của nó, kết quả thay vào chỗ câu hỏi; diễn biến theo lượt, theo ngày vào nhật ký `Progress.md` (rồi `docs/history/`), không vào file tra cứu.
- **Thứ tự theo người đọc.** Mở đầu bằng mục đích và kết luận. Kết quả nằm cạnh câu hỏi nó trả lời. Phần quan trọng viết trước. Phần đã dừng, hoặc để sau, viết ở cuối.
- **Câu đủ ý** (D44 (Văn xuôi tiếng Việt)). Mọi tài liệu viết bằng câu tiếng Việt tự nhiên, rõ ràng, chính xác, nói trọn một việc và có đầy đủ chủ ngữ cùng vị ngữ. Nhiều ý ngang hàng thì mỗi ý viết thành một câu riêng. Gạch đầu dòng khi các ý đó ngang hàng; mỗi gạch là một câu đủ ý, không phải cụm danh từ cộc lốc. Các câu nối tiếp nhau thì viết thành đoạn văn. Không rút câu đến mức người đọc phải tự điền động từ hoặc tự nối các vế. Khi viết lại hoặc viết mới, giữ tối đa ý nghĩa gốc: không thêm bớt sự kiện, không đổi số đo, không đổi thuật ngữ trong `Glossary.md`.
- **Văn tiếng Việt, không văn dịch** (D44). Câu viết theo cú pháp tiếng Việt, không dịch khuôn câu tiếng Anh. Luật áp cho tài liệu lẫn chuỗi giao diện tiếng Việt. Nguồn, số đo và cặp ví dụ trước/sau nằm ở [`docs/research/VietnameseProse.md`](research/VietnameseProse.md).
  - *Luôn sửa.*
    1. Chuỗi liệt kê không có dấu phẩy trước "và", "hoặc", "hay". Viết "A, B và C", không viết "A, B, và C".
    2. Hai vế chung một chủ ngữ thì không đặt dấu phẩy trước "và", "hoặc". Ví dụ: "Dấu tự đặt dấu vào đúng chỗ và dời dấu khi từ dài thêm."
    3. Hai vế có chủ ngữ riêng thì tách thành hai câu. Dấu phẩy trước "và" chỉ giữ ở chỗ bỏ nó đi làm câu đọc nhầm.
    4. Không viết "được … bởi X" hay "bị … bởi X". Câu viết ở dạng chủ động, X làm chủ ngữ.
    5. Tiêu đề và nhãn chỉ viết hoa chữ đầu và tên riêng, không viết hoa mọi chữ kiểu tiếng Anh.
    6. Không chồng thì như "đã đang", "sẽ đang".
  - *Thường sửa, đọc cả câu rồi mới sửa.*
    7. Bỏ "được" thừa. Viết "Nhật ký chuyển sang `docs/history/`", không viết "Nhật ký đã được chuyển sang `docs/history/`". "Được" chỉ giữ khi nó mang nghĩa "có thể" hay "được phép", hoặc khi bỏ nó làm câu mơ hồ.
    8. Dùng thẳng động từ, không danh hoá bằng "việc", "sự", "tiến hành", "thực hiện".
    9. Không mở câu bằng "Nó" hay "Điều này" để chỉ cả câu trước. Câu nêu lại chủ ngữ thật.
    10. Ý phụ dài viết thành câu riêng, không chen giữa câu trong ngoặc đơn.
    11. Mỗi câu có nhiều nhất một dấu hai chấm.
    12. Không dùng "đến từ" để chỉ nguồn gốc.
  - *Chỉ sửa khi câu nặng nề.* Các lối này gồm "là một", "các", "những", "một" thừa trước danh từ; "của" chồng nhiều tầng; "Với X," ở đầu câu; "trong khi" dịch từ "while"; "của bạn" lặp lại; từ tiếng Anh chêm vào khi đã có từ Việt thông dụng. Thuật ngữ trong `Glossary.md` giữ nguyên.
  - *Vẫn đúng, không sửa.* Câu "Nếu …," không có "thì" vẫn đúng, dấu phẩy trước "nhưng" và "rồi" cũng vậy.
- **Tài liệu nghiên cứu (`docs/research/`) có mục "Hiện trạng" ở đầu, ghi ngày.** Kết luận đổi thì sửa thẳng vào mục đó và vào thân bài, không viết thêm mục "Đính chính" ở cuối.
- **Tên file theo cách các repo của Apple đặt.** File chuẩn ở gốc repo và `README.md`, `CLAUDE.md` của từng thư mục viết hoa toàn bộ (`README.md`, `CONTRIBUTING.md`, `LICENSE`); mọi tài liệu khác viết PascalCase, từ viết tắt giữ hoa (`docs/Decisions.md`, `docs/UIChecks.md`, `docs/research/SwiftUIWindowAPI.md`). Đổi tên file thì sửa mọi chỗ dẫn trong cùng commit, kể cả trong `docs/history/`.
- **Viết cho GitHub.** Tài liệu công khai trên GitHub: file trong repo dẫn bằng liên kết bấm được (``[`docs/Decisions.md`](docs/Decisions.md)``); chú thích cuối trang dùng URL đầy đủ (GitHub không đổi liên kết tương đối ở đó); thoát `|` trong bảng; chuỗi `<…>` để trong backtick.
