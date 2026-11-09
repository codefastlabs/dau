# Lộ trình

Mỗi mốc kết thúc khi: test xanh, đã tự rà soát với `DECISIONS.md`, và có tóm tắt ngắn (đã làm, số đo, câu hỏi còn mở).

## M0 — Khung dự án
- `git init`, `.gitignore`, `LICENSE` (GPLv3), `README.md` ngắn.
- `project.yml` (XcodeGen) với 2 target app (`Dau`, `DauInputMethod`) + 2 package local (`DauEngine`, `DauShared`). Bundle ID và Team ID để placeholder, hỏi người dùng.
- Xong khi: `xcodegen generate` và build Debug thành công cho cả hai target, universal.

## M1 — Engine
- Trước khi viết engine: đọc mã nguồn OpenKey (clone ngoài repo) và lập `docs/OPENKEY-NOTES.md` — danh sách đầy đủ tính năng của engine, hành vi từng tính năng, ca biên, lỗi tìm thấy, và Dấu làm hay không làm (dẫn D-số). Đối chiếu với `DECISIONS.md`; mâu thuẫn mới thì nêu ra trước khi code.
- `VietEngine` cho Telex (trước), rồi VNI và Telex đơn giản; đặt dấu mới/cũ; bỏ dấu tự do; chính tả âm tiết; tự khôi phục từ không phải tiếng Việt; gõ đúp phím dấu để giữ chữ gốc.
- Bộ test: (1) ca viết tay cho các quy tắc khó (ươ, uyê, gi/qu, đ, dấu trên nguyên âm đôi) và nhóm từ trùng Anh–Việt (car/cả, sex/sẽ, has/há, test/tét, as/á) kèm cách gõ đúp; tương tác gõ tắt phụ âm với khôi phục (fan → phan, big → big, bag → bang, wa → ưa); (2) ca biên rút ra từ `OPENKEY-NOTES.md`, kết quả mong đợi viết theo quy tắc chính tả và `DECISIONS.md`; (3) test hiệu năng.
- Xong khi: toàn bộ test xanh; số đo thời gian `handle` mỗi phím được ghi lại.

## M2 — Bộ gõ tối thiểu
- `DauInputMethod` với Telex, một input mode Tiếng Việt (D2; tiếng Anh gõ bằng U.S. của macOS), thay chữ tại chỗ.
- Script cài bản Debug vào `~/Library/Input Methods` và hướng dẫn người dùng bật thử.
- **Giải quyết câu hỏi A/B** (đã chốt cách A, D11) (vị trí thay chữ): đo chi phí `selectedRange` trên TextEdit, Safari, Chrome, Telegram (thay Slack, 30/10/2026), VS Code, Terminal; cập nhật `DECISIONS.md`.
- Xong khi: người dùng gõ được tiếng Việt trong TextEdit và Safari không gạch chân.

## M3 — Độ tin cậy
- Reset khi lệch ngữ cảnh, phòng thủ đầu vào IMK (D18), fallback marked text theo danh sách tương thích (D13), quy tắc theo ứng dụng (D5), kiểm chứng bằng VoiceOver rằng hệ thống tự đọc tên nguồn nhập liệu khi chuyển (D17).
- Ma trận tương thích: bảng app × kết quả, lưu trong `docs/COMPATIBILITY.md`.
- Reset khi nguồn nhập liệu đổi mà bộ gõ không nhận `activateServer` — xong (6c1c055). Đo 30/10/2026 lúc M2: chọn lại Dấu bằng `TISSelectInputSource` từ tiến trình khác thì từ đang gõ dở không được reset. Kịch bản đo cũ (`to` → U.S. → Dấu → `o` ra "tô") nay không còn là lỗi: "tô" là hành vi của D20 sau sự kiện reset (D4 × D20). Bản sửa được kiểm bằng `to⇄cj␣` → "tocj" (tắt bộ nghe để đối chứng: "tọc").
- Ghi tự sửa chính tả của macOS (D4, giới hạn đã biết) vào ma trận tương thích.

## M4 — App Cài đặt
- Dựng 4 mục theo `docs/UI.md`, App Group chia sẻ cài đặt, bộ gõ áp dụng thay đổi ngay.

## M5 — Onboarding, cài đặt, gỡ cài đặt
- 3 bước theo `docs/UI.md`; phát hiện bộ gõ cũ; cài/gỡ bộ gõ; xác minh câu hỏi mở về `TISEnableInputSource` và sandbox của app chủ.

## M6 — Hiệu năng dưới tải
- App test tự gửi phím 20 phím/giây vào TextEdit, Safari, Telegram trong khi CPU đầy và `memory_pressure` đang chạy.
- Chỉ số: văn bản cuối khớp 100%; độ trễ p50/p99 phía bộ gõ; bộ nhớ ổn định theo thời gian. So với gõ bằng U.S. và với các bộ gõ khác (kế hoạch đo: `docs/research/COMPETITOR-COMPARISON.md`).
- Chốt ngưỡng vào `DECISIONS.md`; quyết định về D12 dựa trên số đo.
- Chạy tiếp ma trận tương thích `docs/COMPATIBILITY.md` (người dùng chốt 30/10/2026): Zalo, Discord, Messages, Pages, Numbers, Ghostty, Zed, Xcode, WebStorm; kiểm lại Terminal không gửi ⌫ cho bộ gõ; K5, K6 cho phần lớn app (K6 theo D4 × D20).

## M7 — Phát hành
- Làm trước: phần nền đa ngôn ngữ (mục M9, D41).
- Ký Developer ID, notarize, DMG; Sparkle 2 (EdDSA, 2 kênh, phát hành theo đợt); JSON tương thích có chữ ký; GitHub Actions build từ tag + artifact attestation; Homebrew cask với `auto_updates true`.
- Báo lỗi (URL issue điền sẵn), Quay về bản trước, Gỡ cài đặt.
- Loại bản dựng (D7, D25): cờ build chọn biểu tượng chuẩn, chỉ quy trình phát hành trên CI đặt; mặc định là biểu tượng bản phát triển; số build tăng dần và số hiển thị có chữ beta; trang Cập nhật & hỗ trợ của bản phát triển ghi cấu hình build và commit (vẽ trên canvas trước).
- Xuất bộ file nhận diện theo `docs/BRAND.md` (biểu tượng app, biểu tượng bản phát triển, ảnh template thanh menu, favicon, ảnh Open Graph, ảnh xem trước GitHub, nền DMG) và gắn thẻ meta cho website.
- Việc cần tài khoản Apple Developer: chuẩn bị sẵn, dừng lại để người dùng thực hiện.
- Kiểm tra trước phát hành (cần người, hoãn từ M4): VoiceOver và Tab ("Điều hướng bàn phím") qua cửa sổ Cài đặt; VoiceOver đọc đúng tên "Dấu – Tiếng Việt" khi chuyển nguồn (M3 mới xác nhận là hệ thống có đọc, D17); biểu tượng "V" trên thanh menu đơn sắc, đổi màu theo nền sáng/tối (hoãn từ M2/M3, người dùng chốt 30/10/2026); máy để tiếng Anh hẳn (menu app, tên "Dấu" trong Finder); các sheet ở chế độ tối.

## M8 — Website
- Dựng trang tải về theo `docs/UI.md` (mục "Trang tải về") và `docs/BRAND.md`: trang tĩnh, responsive, thẻ meta và ảnh Open Graph, favicon. Công nghệ chọn ở đầu mốc và hỏi người dùng.
- Các ô số liệu và lời hứa chỉ điền từ kết quả M2/M6 (N5).
- Xong khi: Lighthouse ≥ 95 ở cả bốn hạng mục trên điện thoại; kiểm toán ĐẠT.

## M9 — Đa ngôn ngữ
Người dùng nêu 04/11/2026: Dấu có thể thành bộ gõ được người Việt dùng rộng rãi, và người nước ngoài học tiếng Việt cũng muốn dùng.
Quy tắc ngôn ngữ, khoá chuỗi, tên nguồn và cách đặt ngôn ngữ riêng cho Dấu: D41.

**Phần nền — làm trước M7** (D41, người dùng chốt 06/11/2026):
- Đổi String Catalog của app chủ và bộ gõ sang ngôn ngữ gốc tiếng Anh: khoá là câu tiếng Anh, viết đủ tiếng Anh cho mọi chuỗi, tiếng Việt thành bản dịch giữ nguyên câu chữ hiện có. Tên nguồn "Dấu – Vietnamese", menu bộ gõ hết lẫn hai thứ tiếng trên máy tiếng Anh ("Dấu Settings…" cạnh "Open Keyboard Settings…").
- Dạng số nhiều cho bản tiếng Anh ở các chuỗi có số.
- Bỏ việc ghim `vi` khi app chủ khởi động; vẫn nhận tham số `-AppleLanguages` để chạy kiểm theo ngôn ngữ.
- Script kiểm (vào `check.sh` hoặc script riêng): mọi khoá có bản `vi` và `en` đã dịch, không còn chuỗi "new"/"needs review".
- Test: `snapshot-settings` nạp catalog để so chữ đúng ngôn ngữ; bộ kiểm cửa sổ thật chạy ở `vi`.
- Bảng thuật ngữ tiếng Anh theo Apple (input source, Simple Telex, underline…), đặt ở một chỗ.
- Xong khi: test xanh; máy tiếng Việt thấy mọi chữ như trước; chạy với `-AppleLanguages (en)` không còn chữ tiếng Việt ngoài tên "Dấu", tên giao diện macOS theo D38, nhãn của app khác chép nguyên và ví dụ gõ (`docs/GLOSSARY.md`); kiểm toán ĐẠT.

**Phần còn lại — M9:**
- Người dùng duyệt câu chữ tiếng Anh; ngôn ngữ khác chỉ thêm khi có người nói thạo duyệt (D41).
- Hàng "Ngôn ngữ" trong Cài đặt chỉ sang mục ngôn ngữ riêng từng ứng dụng của macOS (D41): canvas trước mã; đo xem bộ gõ có đặt riêng được không (câu hỏi mở).
- Không tự giải quyết được: mục "Open Dấu Settings…" của hệ thống (mục cuối menu nhập liệu) chỉ có khi bộ gõ khai báo được trang cài đặt riêng; nghiên cứu riêng trước M9.
- Canvas: bản tiếng Anh cho các màn chính trước khi sửa mã. Bộ kiểm cửa sổ thật (`run.sh`) chạy theo từng ngôn ngữ vì độ dài chữ đổi bố cục. Trang tải về (M8) có bản tiếng Anh.
- Xong khi: máy để tiếng Anh hẳn thấy toàn bộ app, bộ gõ, onboarding, hộp thoại bằng tiếng Anh; `run.sh` đạt ở cả hai ngôn ngữ; kiểm toán ĐẠT.

## M10 — Học cách gõ
Người dùng nêu 04/11/2026: người dùng biết và học được cách gõ, và khác biệt về cách gõ giữa các bộ gõ.
- Trong app: ô gõ thử giải thích từng bước (`vieetj` → vi → viê → việt, phím nào làm gì); bảng tra Telex, Telex đơn giản, VNI. Theo D9 (giao diện gọn như System Settings); không lưu gì về chữ đã gõ (D8).
- Trên trang web: trang "Dấu khác các bộ gõ khác thế nào", chỉ ghi khác biệt đã đo được (N5), lấy từ `docs/OPENKEY-NOTES.md` và bộ dữ liệu kiểm thử (đặt dấu kiểu mới/cũ, bỏ dấu tự do, khôi phục từ nước ngoài, uơ/ươ…); dẫn mục "Đã biết nhưng không làm" của `docs/DECISIONS.md`.
- Canvas trước, mã sau. Nội dung có bản tiếng Việt và tiếng Anh nếu M9 đã xong.
- Xong khi: người dùng duyệt nội dung trên canvas; mọi ví dụ trong phần học có test engine tương ứng; kiểm toán ĐẠT.
