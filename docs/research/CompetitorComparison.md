# So sánh Dấu với các bộ gõ khác

Nghiên cứu cho M10 (Học cách gõ), trang "Dấu khác các bộ gõ khác thế nào". Không thuộc M6 (Hiệu năng dưới tải) và không chặn phát hành.

## Hiện trạng (12/11/2026)

- **Trong ứng dụng thật, so với Telex của macOS (mục 1): đo xong 09/11/2026; số của Apple đã kiểm mẫu lại 12/11/2026.**
  - Tiếng Việt: hai bộ gõ ngang nhau. Từ tiếng Anh và câu trộn Việt–Anh: Dấu giữ nguyên nhiều từ hơn, vì chỉ Dấu khôi phục từ không phải tiếng Việt (D4 (Từ nước ngoài)). Số đo ở mục 1.1.
  - Số của Dấu đứng được: chữ trong hai app trùng từng byte với engine chạy offline.
  - Số của Apple: khớp ở 9 từ đã kiểm mẫu (Chrome, 12/11/2026, `scripts/selftest/typing/run.sh` hiện hành); các ô khác (Safari, các số 677/678, 169/188) chưa kiểm lại (mục 1.2).
- **Ở mức engine, so với 10 bộ gõ khác (mục 2): xong, dùng số đã có.**
- **Nhịp gõ thật, hai phím cách nhau dưới 10 ms (mục 3): dừng.** Dữ liệu công khai không đủ độ chính xác. Câu hỏi gốc của D13 (Gạch chân là đường lui cuối cùng) được đo ở M6 bằng bài test tải nặng (mục 3).

## 1. Trong ứng dụng thật: Dấu và Telex của macOS

Câu hỏi: khi gõ thật trong ứng dụng, tiếng Việt thông dụng và từ tiếng Anh ra sao, so với bộ gõ tiếng Việt có sẵn của macOS.

### 1.1 Kết quả (09/11/2026)

Một lượt `scripts/research/compare-ims/run.sh`, 22 phút 29 giây, khoảng 5.700 phím mỗi app. Máy phát triển, macOS 27.2; Dấu bản Release 24e61ec, mặc định theo D15 (Cài đặt mặc định); Telex của Apple (`com.apple.inputmethod.VietnameseIM.VietnameseTelex`) với cài đặt sẵn có trên máy. Chữ đọc lại và bảng điểm ở `build/compare-ims/20261109-122753/` (không commit).

| Nhóm | Số từ | Dấu | Telex của Apple |
|---|---|---|---|
| Câu tiếng Việt | 678 | 677 | 677 |
| Câu trộn Việt–Anh | 188 | 184 | 169 |
| Từ tiếng Anh và từ trong mã | 105 | 88 | 53 |

- Safari và Chrome cho đúng cùng một chữ, với cả hai bộ gõ. Chữ của Dấu trong hai app trùng từng byte với engine chạy offline.
- **Tiếng Việt:** từ sai duy nhất của cả hai là "taxi" ra "tãi" (âm tiết hợp lệ, tiếng Việt thắng theo D4).
- **Từ Dấu không giữ nguyên (17), Apple cũng ra y như vậy:**
  - 7 từ sai thật, có chữ cái đôi trùng phím dấu nên mất một chữ: password, coffee, office, assert, offset, session, error (D26 (Gõ đúp phím dấu); hệ quả đã chấp nhận).
  - 10 từ trùng Anh–Việt, không chấm đúng sai (tiếng Việt thắng theo D4) nhưng bảng điểm vẫn tính là không giữ nguyên: seems → sếm, see → sê, door → dổ, moon → môn, soon → sôn, horse → hoé, mix → mĩ, box → bõ, max → mã, major → mảo.
  - Trong câu trộn thêm reset → rết, test → tét.
- **Từ chỉ Apple sai (35 từ đơn, 15 từ trong câu trộn):** từ không phải âm tiết tiếng Việt vẫn bị biến đổi, vì Apple không khôi phục: windows → ưindows, good → gôd, book → bôk, google → gôgle, software → sờtare, work → ửok, push → púh, website → ưebsite, design → déign…

### 1.2 Giới hạn

- **Số của Apple (53/105, 169/188, 677/678):** lượt đo chọn nguồn của Apple bằng API từ tiến trình của script (`--source`), không bằng phím tắt hệ thống kèm bước xác nhận trong ô gõ. Ngày 10/11/2026 đã xác định cách chọn đó có thể để ô gõ không dùng bộ gõ của Apple (các ô "ra nguyên chuỗi phím" là đo hỏng, `docs/Progress.md` nhật ký 10/11). Chữ Apple ra ở lượt này là chữ kiểu Telex chứ không phải nguyên chuỗi phím. Lượt kiểm mẫu bằng script hiện hành (chuyển nguồn đã sửa) khớp ở 9 từ đã kiểm mẫu (Chrome, 12/11/2026); các ô khác (Safari, các số 677/678, 169/188) chưa kiểm lại.
- **Focus:** script tự gõ lúc đó chưa kiểm focus (sửa 09/11/2026, `docs/Compatibility.md` mục Hiện trạng), nên chưa loại được việc một số lượt gõ vào thanh địa chỉ thay vì ô của trang. Chữ của Dấu vẫn trùng engine nên kết quả về chữ đứng được; chỉ chưa chắc là ô nào.
- Một máy, một lượt, chỉ 30 ms giữa hai phím, chỉ Telex thứ tự chuẩn.
- Dữ liệu do Dấu tự viết. Danh sách từ tiếng Anh cố ý chọn từ có phím dấu hoặc phím biến đổi của Telex (từ không có các phím đó thì bộ gõ nào cũng để nguyên), nên 88/105 và 53/105 không phải tỉ lệ trên tiếng Anh nói chung.
- Cách chấm bỏ qua vị trí dấu thanh (hoà/hòa coi như nhau), nên không bắt được dấu đặt sai nguyên âm.
- Không đo bỏ dấu tự do, kiểu đặt dấu, Backspace, D20 (Thêm dấu cho từ đã gõ): chỉ phần cả hai bộ gõ cùng hỗ trợ.
- Đưa lên website (M10) chỉ kèm các giới hạn ở mục này (N5).

### 1.3 Cách đo

Bộ gõ của Apple chỉ đo được bằng cách gõ thật, vì không có engine để chạy riêng. Trên máy đo, nguồn Telex của Apple đã bật sẵn (đọc bằng TIS 09/11/2026), nên không phải đổi cài đặt hệ thống.

- **Bộ gõ:** Dấu (bản Release đã cài, mặc định theo D15) và Telex của Apple.
- **Dữ liệu** (chỉ phần cả hai cùng hỗ trợ: Telex thứ tự chuẩn, không bỏ dấu tự do, không gõ tắt), trong `scripts/research/compare-ims/`:
  - 60 câu văn xuôi hiện đại tự viết (`vi-sentences.txt`);
  - 20 câu trộn Việt–Anh (`mixed-sentences.txt`);
  - khoảng 100 từ tiếng Anh và từ trong mã, hầu hết có phím dấu hoặc phím biến đổi của Telex (`en-words.txt`);
  - `cases.swift` chuyển sang phím Telex thứ tự chuẩn, tổng khoảng 5.700 phím. Kiểm offline bằng engine của Dấu trước khi gõ thật (09/11/2026): 677/678 từ tiếng Việt đúng, từ còn lại là "taxi", nên bộ chuyển phím đúng.
- **Cách chấm:**
  - Tiếng Việt đúng khi ra đúng chữ gốc sau chuẩn hoá NFC, chấp nhận cả hai kiểu đặt dấu (hoà/hòa).
  - Tiếng Anh đúng khi giữ nguyên chữ đã gõ. Từ vừa là tiếng Anh vừa là âm tiết tiếng Việt hợp lệ ("car", "as") tính riêng, không chấm đúng sai (D4); bảng điểm vẫn đếm chúng là từ không giữ nguyên, nên mục 1.1 tách số từ sai thật và số từ trùng.
  - Đáp án lấy từ chữ gốc, không từ kết quả của bộ gõ nào (D10 (Engine tự viết)).
- **Ứng dụng:** trang thử trong Safari (WebKit, đúng ở mọi tốc độ từ M2 (Bộ gõ tối thiểu); dùng thay app thử riêng vì script đã có sẵn) và Chrome. Khoảng cách giữa hai phím 30 ms; không chạy 120 ms, vì ở 30 ms Dấu đã đúng trong cả hai app (M3, Độ tin cậy) và lượt chạy sẽ dài gấp bốn.
- **Lệnh:** `scripts/research/compare-ims/run.sh` gọi `scripts/selftest/typing/run.sh` với `--source` (chọn nguồn theo ID) và `--save` (lưu chữ đọc lại). Mọi ca sai (chuỗi phím và chữ ra) lưu trong `build/`, không commit.

## 2. Ở mức engine: Dấu và 10 bộ gõ khác

Câu hỏi: hành vi engine của Dấu khác các bộ gõ tiếng Việt khác ở đâu.

- **Kết quả:** dùng lại phép so ở [`docs/research/external-test-inputs/README.md`](external-test-inputs/README.md): so từng ca với đáp án test của 10 bộ gõ khác (có Gõ Nhanh và XKey; XKey có engine chuyển từ OpenKey), xếp theo lớp. Số ca theo lớp và nghĩa các lớp nằm ở mục Hiện trạng của file đó, không chép ở đây.
- Bảng khác biệt theo chủ đề (từ tiếng Anh, đặt dấu, uơ/ươ, Backspace…), mỗi chủ đề có ví dụ và số D, nằm ở phần kết quả so sánh của file đó; trang M10 dùng bảng đó, không dựng bảng mới.
- Chạy lại offline, không chiếm màn hình: `scripts/research/external-tests/compare.sh`.
- **Giới hạn:** đáp án test của họ cho biết hành vi engine theo cấu hình test, không phải hành vi trong ứng dụng thật với cài đặt mặc định.

## 3. Nhịp gõ thật: hai phím cách nhau dưới 10 ms

Câu hỏi: gõ tay thật có tạo ra hai phím cách nhau dưới 10 ms không (D13, `docs/Compatibility.md` mục 6.2). Kết quả cần có là phân bố khoảng cách giữa hai phím liên tiếp và tỉ lệ cặp dưới 10 ms theo tốc độ gõ, từ dữ liệu công khai của nhiều người gõ thật; không ghi nhật ký trên máy người dùng thay thế.

- **Dừng (09/11/2026): dữ liệu công khai không trả lời được.**
  - Bộ dữ liệu duy nhất tải được công khai, có dấu thời gian từng phím của nhiều người, là bộ 136 triệu lần gõ phím của Đại học Aalto (Dhakal và cộng sự, CHI 2018, https://userinterfaces.aalto.fi/136Mkeystrokes/). Bộ này đo bằng trình duyệt, và chính bài báo ghi độ chính xác của cách đo khoảng 10–15 ms, nên không phân biệt được hai phím cách nhau dưới 10 ms.
  - Bài báo không công bố tỉ lệ cặp phím dưới 10 ms; chỉ số "rollover" trong bài (phím trước còn đang giữ khi nhấn phím sau) là chỉ số khác.
  - Giấy phép ghi "nghiên cứu, phi thương mại, ghi nguồn", chưa rõ có cho công bố số phái sinh không.
  - Bộ Buffalo phải xin qua email; KeyRecs chỉ có độ trễ theo cặp chữ, gõ câu cố định.
  - Kể cả có dữ liệu thì người trong đó gõ tiếng Anh; Telex có cặp phím riêng ("ee", "ow", phím dấu ở cuối từ), nên chỉ ước lượng được.
- **Câu hỏi đặt sai chỗ (đo ở M6, 09/11/2026, `docs/Progress.md` nhật ký): app bận không dồn phím; lỗi khi Chrome bận là vị trí con trỏ cũ, ở nhịp gõ bình thường.** Giả thuyết ban đầu là phím dồn dưới 10 ms không do người gõ nhanh mà do app đích bận (Chrome đang tải trang, VS Code đang lập chỉ mục) rồi chuyển một loạt phím đã xếp hàng cùng lúc; nếu vậy thì bài test tải nặng của M6 mới là chỗ trả lời câu hỏi của D13.

## Để sau

Các bộ gõ chặn phím (OpenKey, Gõ Nhanh, chế độ chặn phím của XKey) trong ứng dụng thật: chúng cần cài phần mềm bên ngoài và cấp quyền Accessibility. Chỉ làm khi mục 1 và mục 2 cho thấy cần, và theo cách không cần người dùng làm gì thêm.
