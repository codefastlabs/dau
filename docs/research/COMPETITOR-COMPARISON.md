# So sánh Dấu với các bộ gõ khác (kế hoạch đo)

## Hiện trạng (09/11/2026)

- **Mới là kế hoạch, chưa đo gì.** File này chưa có kết luận nào. Kết quả chưa đo không được đưa lên giao diện hay website (N5).
- Đây là việc nghiên cứu cho M10 (trang "Dấu khác các bộ gõ khác thế nào"), **không thuộc M6 và không chặn phát hành**. Riêng phần A trả lời một câu hỏi của D13 nên làm trước.
- Ba câu hỏi: (A) khi người thật gõ, có hai phím cách nhau dưới 10 ms mà phím sau phải thay chữ không (D13, `docs/COMPATIBILITY.md` mục 6.2); (B) gõ tiếng Việt thông dụng có đúng như các bộ gõ cùng kiến trúc IMK không; (C) từ tiếng Anh và tên trong mã bị đổi nhiều hay ít.
- Chờ người dùng duyệt từng phần (mục 4).

## Phần A. Nhịp gõ thật (làm trước, không chiếm màn hình)

- **Cách đo:** dùng bản Debug của Dấu với `DauPerfLog` (D8) trong một ngày làm việc. Nhật ký có giờ, loại phím và app, **không có chữ**. Người dùng gõ như bình thường.
- **Kết quả cần có:** `scripts/perf/perf-report.sh` thêm bảng phân bố khoảng cách giữa hai phím theo app, và số phím có thay chữ đến dưới 10 ms sau phím trước, tính riêng cho Chrome, VS Code, Terminal.
- **Không dùng số này để đếm số lần lệch vị trí hay xoá bộ đệm (D11):** bản Debug hỏi thêm vị trí sau mỗi lần thay chữ để chẩn đoán (`ReplaceDiag.swift`, không có ở bản Release), nên hai con số đó có thể khác bản Release. Khoảng cách giữa hai phím thì không bị ảnh hưởng.
- Đây là số đo của một người, ghi rõ như vậy, không suy rộng. Nếu không có phím thay chữ nào dưới 10 ms thì giữ D13; nếu có thì đưa số đo cho người dùng xem lại D13.
- Xong thì cài lại bản Release.

## Phần B và C. So sánh trong ứng dụng (chiếm màn hình)

### Bộ gõ

Chỉ so với các bộ gõ cùng kiến trúc IMK, vì đó là phép so sánh sát nhất với Dấu:

| Bộ gõ | Ghi chú |
|---|---|
| Dấu | bản Release đã cài; cài đặt mặc định theo D15 |
| Bộ gõ tiếng Việt của macOS | có sẵn, thêm bằng "+"; ID nguồn đọc bằng TIS lúc chạy, không ghi từ trí nhớ |
| XKey ở chế độ IMK | thư mục `XKeyIM` của dự án; cài theo README của XKey |

Để sau: các bộ gõ chặn phím (OpenKey, Gõ Nhanh). Chúng cần quyền Accessibility và gửi Backspace giả, nên muốn đo công bằng thì cần cách đo khác.

### Môi trường

- Chạy trên một **tài khoản macOS riêng** do người dùng tạo, không phải tài khoản làm việc chính, để không cài bộ gõ của người khác vào máy đang dùng.
- Mỗi lần chỉ chọn một nguồn tiếng Việt. Ghi phiên bản của từng bộ gõ và bản macOS.

### Dữ liệu

Chỉ gõ Telex, chỉ dùng phần mà cả ba bộ gõ đều hỗ trợ: thứ tự chuẩn (dấu thanh ở cuối từ), không bỏ dấu tự do, không gõ tắt.

- **B. Tiếng Việt thông dụng:** khoảng 300 câu văn xuôi hiện đại (tin nhắn, email, ghi chú), từ một nguồn có giấy phép dùng được hoặc tự viết. Chuyển sang phím Telex bằng script, để tần suất từ giống văn bản thật.
- **C. Tiếng Anh và mã:** khoảng 300 từ tiếng Anh thông dụng (danh sách có giấy phép, ví dụ SCOWL; ghi giấy phép như `external-test-inputs/NOTICE.md`), từ khoá Swift, JavaScript, Python, lệnh terminal, và câu trộn Việt–Anh.

### Cách chấm

- **B đúng khi:** chữ ra đúng chữ gốc sau chuẩn hoá NFC, chấp nhận cả hai kiểu đặt dấu (hoà/hòa, thuý/thúy).
- **C đúng khi:** chữ ra giữ nguyên chữ đã gõ. Từ vừa là tiếng Anh vừa là âm tiết tiếng Việt hợp lệ ("car", "as") tính riêng một nhóm, không chấm đúng sai (D4 là lựa chọn thiết kế).
- Đáp án lấy từ chữ gốc, không từ kết quả của bộ gõ nào (D10).

### Ứng dụng và tốc độ

- Một app thử riêng (NSTextView; không dùng TextEdit vì nó tự lưu tài liệu lên iCloud) và Chrome.
- Khoảng cách giữa hai phím: 120 ms (gần gõ thường) và 30 ms. Nếu phần A tìm thấy khoảng cách dưới 10 ms thì thêm đúng khoảng cách đó.
- Gõ bằng `scripts/selftest/typing/run.sh` mở rộng thêm tuỳ chọn chọn nguồn theo ID; khi đo bộ gõ khác thì bỏ phần nhật ký riêng của Dấu.
- Ước lượng chưa tới 30 phút chiếm màn hình cho cả ba bộ gõ.
- Lưu mọi ca sai (chuỗi phím và chữ ra) trong `build/`, không commit.

## Thứ tự làm và điểm dừng

1. **Phần A:** người dùng đồng ý dùng bản Debug một ngày; mở rộng `perf-report.sh`; đọc kết quả; cài lại bản Release.
2. Sinh dữ liệu B, C và đáp án; mở rộng script gõ. Không chiếm màn hình.
3. **Người dùng** tạo tài khoản macOS riêng, thêm bộ gõ của Apple, cài XKey.
4. Chạy B, C trong tài khoản đó. **Hỏi giờ chạy.**
5. Dọn: gỡ XKey, bỏ các nguồn đã thêm; người dùng tự quyết có xoá tài khoản thử không.
6. Ghi kết quả vào mục Hiện trạng và thân bài file này. Quyết định nào đáng xem lại (D13, D4) thì nêu kèm số đo; đổi quyết định là việc của người dùng.
