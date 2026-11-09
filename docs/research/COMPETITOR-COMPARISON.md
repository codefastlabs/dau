# So sánh Dấu với các bộ gõ khác (kế hoạch đo)

## Hiện trạng (09/11/2026)

- **Mới là kế hoạch, chưa đo gì.** File này chưa có kết luận nào. Kết quả chưa đo không được đưa lên giao diện hay website (N5).
- Đây là việc nghiên cứu cho M10 (trang "Dấu khác các bộ gõ khác thế nào"), **không thuộc M6 và không chặn phát hành**. Phần A trả lời một câu hỏi của D13.
- Phiên chính và subagent tự làm mọi bước. Người dùng không phải cài gì, cấp quyền gì hay gõ gì. Việc duy nhất của người dùng là chọn giờ cho một lượt chiếm màn hình khoảng 20 phút (phần C), như CLAUDE.md quy định.
- Ba câu hỏi: (A) gõ tay thật có tạo ra hai phím cách nhau dưới 10 ms không (D13, `docs/COMPATIBILITY.md` mục 6.2); (B) so với các bộ gõ khác thì Dấu khác ở đâu, ở mức engine; (C) so với bộ gõ tiếng Việt có sẵn của macOS thì tiếng Việt thông dụng và từ tiếng Anh ra sao trong ứng dụng thật.

## Phần A. Nhịp gõ thật: dùng dữ liệu công khai, không đo trên người dùng

- Tìm bộ dữ liệu nhịp gõ công khai của nhiều người gõ thật (ví dụ bộ dữ liệu 136 triệu lần gõ phím của Đại học Aalto, CHI 2018). Kiểm giấy phép trước khi dùng, chỉ tải về `build/` (không commit), ghi nguồn.
- **Kết quả:** phân bố khoảng cách giữa hai phím liên tiếp; tỉ lệ cặp phím cách nhau dưới 10 ms, theo tốc độ gõ của người gõ.
- **Giới hạn:** người trong dữ liệu gõ tiếng Anh. Telex có cặp phím riêng ("ee", "ow", phím dấu ở cuối từ), nên chỉ ước lượng được, ghi rõ như vậy. Đổi D13 hay không là việc của người dùng, dựa trên số này.
- Không tìm được dữ liệu có giấy phép phù hợp thì ghi lại và dừng phần A. Không thay bằng việc ghi nhật ký trên máy người dùng.

## Phần B. Khác biệt ở mức engine: dùng lại số đã có

- `docs/research/EXTERNAL-TEST-INPUTS.md` mục 9 đã so 10.303 ca với đáp án test của 10 bộ gõ khác (có Gõ Nhanh và XKey; XKey có engine chuyển từ OpenKey). Không đo lại.
- **Việc cần làm:** gom các ca khác nhau thành bảng theo chủ đề (từ tiếng Anh, đặt dấu, uơ/ươ, Backspace…), mỗi chủ đề vài ví dụ kèm số D, làm nguồn cho trang M10. Chạy offline bằng `scripts/research/external-tests/compare.sh`, không chiếm màn hình.
- **Giới hạn:** đáp án test của họ cho biết hành vi engine theo cấu hình test, không phải hành vi trong ứng dụng thật với cài đặt mặc định. Ghi rõ như vậy.

## Phần C. So với bộ gõ có sẵn của macOS trong ứng dụng thật

Bộ gõ của Apple chỉ đo được bằng cách gõ thật, vì không có engine để chạy riêng. Trên máy này `com.apple.inputmethod.VietnameseIM.VietnameseTelex` đã được bật sẵn (đọc bằng TIS 09/11/2026), nên không phải đổi cài đặt hệ thống.

- **Bộ gõ:** Dấu (bản Release đã cài, mặc định theo D15) và Apple Telex.
- **Dữ liệu** (chỉ dùng phần cả hai cùng hỗ trợ: Telex thứ tự chuẩn, không bỏ dấu tự do, không gõ tắt):
  - khoảng 150 câu văn xuôi hiện đại, tự viết hoặc lấy từ nguồn có giấy phép, chuyển sang phím Telex bằng script;
  - khoảng 150 từ tiếng Anh thông dụng và từ trong mã (từ khoá Swift, JavaScript, Python, lệnh terminal), cùng câu trộn Việt–Anh.
- **Cách chấm:**
  - Tiếng Việt đúng khi ra đúng chữ gốc sau chuẩn hoá NFC, chấp nhận cả hai kiểu đặt dấu (hoà/hòa).
  - Tiếng Anh đúng khi giữ nguyên chữ đã gõ. Từ vừa là tiếng Anh vừa là âm tiết tiếng Việt hợp lệ ("car", "as") tính riêng một nhóm, không chấm đúng sai (D4).
  - Đáp án lấy từ chữ gốc, không từ kết quả của bộ gõ nào (D10).
- **Ứng dụng:** một app thử riêng (NSTextView; không dùng TextEdit) và Chrome. Khoảng cách giữa hai phím 120 ms và 30 ms.
- **Cách chạy:** `scripts/selftest/typing/run.sh` thêm tuỳ chọn chọn nguồn theo ID. Mọi thứ build xong trước, rồi báo người dùng "sẵn sàng, khoảng 20 phút", chạy một lượt khi được đồng ý, báo lúc bắt đầu và lúc xong. Sau đó chọn lại nguồn đầu vào như trước khi chạy.
- Lưu mọi ca sai (chuỗi phím và chữ ra) trong `build/`, không commit.

## Để sau

Các bộ gõ chặn phím (OpenKey, Gõ Nhanh, chế độ chặn phím của XKey) trong ứng dụng thật: chúng cần cài phần mềm bên ngoài và cấp quyền Accessibility. Chỉ làm khi phần B và C cho thấy cần, và theo cách không cần người dùng làm gì thêm.

## Thứ tự

1. Phần A và B (offline, không chiếm màn hình).
2. Chuẩn bị phần C: dữ liệu, đáp án, script, build.
3. Hỏi giờ, chạy phần C một lượt.
4. Ghi kết quả vào mục Hiện trạng và thân bài file này. Quyết định nào đáng xem lại (D13, D4) thì nêu kèm số đo.
