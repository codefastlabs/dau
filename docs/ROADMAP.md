# Lộ trình

Các mốc từ khung dự án tới bản phát hành, tiêu chí xong của từng mốc, và việc tồn đọng chưa gắn mốc. Mốc đang làm, kế hoạch chi tiết và số đo: [`docs/PROGRESS.md`](PROGRESS.md).

## Tiêu chí đóng mốc

Mỗi mốc đóng khi:
- test xanh;
- đã tự rà soát với [`docs/DECISIONS.md`](DECISIONS.md);
- kiểm toán ĐẠT;
- có tóm tắt ngắn (đã làm, số đo, câu hỏi còn mở);
- nhật ký của mốc đã chuyển sang `docs/history/`.

## Mốc đã đóng

| Mốc | Mục tiêu | Nhật ký |
|---|---|---|
| M0 Khung dự án | repo, `project.yml` với hai target app và hai package, build universal | [`docs/history/LOG-M0-M4.md`](history/LOG-M0-M4.md) |
| M1 Engine | `VietEngine` cho Telex, VNI, Telex đơn giản, kèm bộ test và số đo mỗi phím | [`docs/history/LOG-M0-M4.md`](history/LOG-M0-M4.md) |
| M2 Bộ gõ tối thiểu | bộ gõ IMK thay chữ tại chỗ, chốt cách lấy vị trí thay chữ | [`docs/history/LOG-M0-M4.md`](history/LOG-M0-M4.md), [`docs/history/M2-TESTING.md`](history/M2-TESTING.md) |
| M3 Độ tin cậy | reset khi lệch ngữ cảnh, phòng thủ IMK, gạch chân theo danh sách tương thích, quy tắc theo ứng dụng, ma trận tương thích | [`docs/history/LOG-M0-M4.md`](history/LOG-M0-M4.md) |
| M4 App Cài đặt | cửa sổ Cài đặt theo `docs/UI.md`, cài đặt chung qua App Group | [`docs/history/LOG-M0-M4.md`](history/LOG-M0-M4.md) |
| M5 Onboarding, cài, gỡ | onboarding, phát hiện bộ gõ cũ, cài và gỡ bộ gõ | [`docs/history/LOG-M5.md`](history/LOG-M5.md) |

Kế hoạch của các mốc này: [`docs/history/PLANS.md`](history/PLANS.md). Phần nền của M9 (Đa ngôn ngữ) làm xong giữa M5 và M6: [`docs/history/LOG-BETWEEN-M5-M6.md`](history/LOG-BETWEEN-M5-M6.md).

## M6 — Hiệu năng dưới tải

- Tự gửi phím 20 phím/giây vào trang thử trong Safari, Chrome và VS Code trong khi CPU đầy và `memory_pressure` đang chạy (`scripts/selftest/load/heavy.sh`).
  - Không gõ vào Telegram: script sẽ gõ vào một cuộc trò chuyện thật.
  - Không dùng TextEdit: nó tự lưu tài liệu thử lên iCloud Drive ([`docs/TROUBLESHOOTING.md`](TROUBLESHOOTING.md)).
  - Chrome và VS Code là hai app áp phím bất đồng bộ (D11 (Kiểm tra ngữ cảnh), ý "App trả lời chậm").
- Chỉ số và ngưỡng: D42 (Ngưỡng hiệu năng). Ngưỡng bộ nhớ chưa chốt.
- Đối chứng là bộ gõ Telex có sẵn của macOS trong cùng điều kiện: chữ của nó dưới tải so với chữ của chính nó lúc rảnh.
  - Không so với bàn phím U.S.: nó ra nguyên chuỗi phím và không có log từng phím, nên không cho số nào để so.
  - Không so với OpenKey ở mốc này: phải cài phần mềm ngoài và người dùng phải cấp quyền Accessibility.
- Phần còn lại của ma trận tương thích [`docs/COMPATIBILITY.md`](COMPATIBILITY.md):
  - app: Zalo, Discord, Messages, Pages, Numbers, Ghostty, Zed, Xcode, WebStorm;
  - kiểm lại Terminal không gửi ⌫ cho bộ gõ;
  - hai bài kiểm cho phần lớn app: click chuột rồi gõ tiếp (gõ `tooi`, click chỗ khác, gõ `s`: chỉ thêm "s" ở chỗ mới) và mũi tên rồi gõ tiếp (gõ `tooi`, nhấn ←, gõ `s`: ra "tối", vì ← chỉ xoá bộ đệm còn D20 (Thêm dấu cho từ đã gõ) vẫn đặt dấu vào chữ trước con trỏ);
  - ghi app nào có tự sửa chính tả của macOS (giới hạn đã biết của D4 (Từ nước ngoài)).
- Xong khi:
  - `heavy.sh` chạy trọn một lượt, đạt ngưỡng D42 ở mọi ô, đối chứng hợp lệ;
  - ma trận tương thích có đủ các app ở trên;
  - kiểm toán ĐẠT.

## M7 — Phát hành

- Trước khi phát hành: chạy bài đo của D42.
- Ký Developer ID, notarize, DMG.
- Sparkle 2: EdDSA, 2 kênh, phát hành theo đợt.
- JSON tương thích có chữ ký.
- GitHub Actions build từ tag, kèm artifact attestation; chạy cả test hiệu năng của engine và phép đếm cấp phát (`malloc_logger`).
- Homebrew cask với `auto_updates true`; tên cask chọn sau khi tra (D24 (Tên và định danh)).
- Báo lỗi (URL issue điền sẵn), Quay về bản trước, Gỡ cài đặt.
- Loại bản dựng (D7 (Cập nhật và loại bản dựng), D25 (Nhận diện)):
  - cờ build chọn biểu tượng chuẩn, chỉ quy trình phát hành trên CI đặt: bản build phát hành truyền `DAU_OFFICIAL=YES` cho `xcodebuild` (`project.yml`), rồi kiểm bản build: `CFBundleIconName` của Dấu.app và bộ gõ là `AppIcon`, không phải `AppIconDev`;
  - mặc định là biểu tượng bản phát triển;
  - số build tăng dần, số hiển thị có chữ beta;
  - trang Cập nhật & hỗ trợ của bản phát triển ghi "Bản phát triển" và commit, bản Debug thêm "Debug" (D25).
- Biểu tượng thật dựng bằng Icon Composer, thay biểu tượng tạm ([`docs/BRAND.md`](BRAND.md), mục "Hiện trạng").
- Xuất bộ file nhận diện theo [`docs/BRAND.md`](BRAND.md) và gắn thẻ meta cho website. Bộ file gồm: biểu tượng app, biểu tượng bản phát triển, ảnh template thanh menu, favicon, ảnh Open Graph, ảnh xem trước GitHub, nền DMG.
- Các câu hỏi mở của [`docs/DECISIONS.md`](DECISIONS.md) gắn với M7: cài cho riêng mình hay cho cả máy (làm trước M7), loại bản dựng, hộp thoại App Group với bản ký Developer ID.
- Kiểm tra trước phát hành (cần người):
  - VoiceOver và Tab ("Điều hướng bàn phím") qua cửa sổ Cài đặt, cả hàng "Ngôn ngữ";
  - VoiceOver đọc đúng tên "Dấu – Tiếng Việt" khi chuyển nguồn (D17 (Trợ năng): hệ thống có đọc, tên chưa xác nhận);
  - biểu tượng "V" trên thanh menu đơn sắc, đổi màu theo nền sáng/tối;
  - máy để tiếng Anh hẳn (menu app, tên "Dấu" trong Finder);
  - các sheet ở chế độ tối;
  - danh sách "+" của System Settings có Dấu (nhìn bằng mắt);
  - cài, bật và gõ thử trên macOS 14–26 và trên máy Intel: D1 (Nền tảng) hứa macOS 14 trở lên và binary universal, mọi lượt đo tới nay trên macOS 27.2 và Apple silicon; câu hỏi mở "Hộp thoại và đăng xuất khi bật bộ gõ" trong `docs/DECISIONS.md` cần cùng lượt này.

## M8 — Website

- Chốt công nghệ và thư mục của trang web (người dùng chốt).
- Dựng trang tải về theo [`docs/UI.md`](UI.md) (mục "Trang tải về") và [`docs/BRAND.md`](BRAND.md): trang tĩnh, responsive, thẻ meta và ảnh Open Graph, favicon.
- Các ô số liệu và lời hứa chỉ điền từ kết quả đã đo (N5 (Chỉ hứa điều đã kiểm chứng)).
- Xong khi: Lighthouse ≥ 95 ở cả bốn hạng mục trên điện thoại; kiểm toán ĐẠT.

## M9 — Đa ngôn ngữ (phần còn lại)

Mục đích: Dấu có thể được người Việt dùng rộng rãi, và người nước ngoài học tiếng Việt cũng muốn dùng. Quy tắc ngôn ngữ, khoá chuỗi, tên nguồn và cách đặt ngôn ngữ riêng cho Dấu: D41 (Ngôn ngữ giao diện). Ngôn ngữ khác chỉ thêm khi có người nói thạo duyệt.

- Câu hỏi mở "Bộ gõ trong mục ngôn ngữ riêng từng ứng dụng" (`docs/DECISIONS.md`): đo xem bộ gõ có đặt ngôn ngữ riêng được không.
- Mục "Open Dấu Settings…" của hệ thống (mục cuối menu nhập liệu) chỉ có khi bộ gõ khai báo được trang cài đặt riêng. Nghiên cứu riêng trước khi làm.
- Canvas: bản tiếng Anh cho các màn chính.
- Bộ kiểm cửa sổ thật (`scripts/selftest/settings-window/run.sh`) chạy theo từng ngôn ngữ, vì độ dài chữ đổi bố cục. Hiện mọi lần mở đều ép tiếng Việt (`-AppleLanguages (vi)`).
- Trang tải về (M8) có bản tiếng Anh.
- Xong khi: máy để tiếng Anh hẳn thấy toàn bộ app, bộ gõ, onboarding, hộp thoại bằng tiếng Anh; `run.sh` đạt ở cả hai ngôn ngữ; kiểm toán ĐẠT.

## M10 — Học cách gõ

Mục đích: người dùng biết và học được cách gõ, và biết khác biệt về cách gõ giữa các bộ gõ.

- Trong app:
  - ô gõ thử giải thích từng bước (`vieetj` → vi → viê → việt, phím nào làm gì);
  - bảng tra Telex, Telex đơn giản, VNI;
  - theo D9 (Giao diện) (gọn như System Settings);
  - không lưu gì về chữ đã gõ (D8 (Không telemetry)).
- Trên trang web: trang "Dấu khác các bộ gõ khác thế nào".
  - Chỉ ghi khác biệt đã đo được (N5).
  - Nguồn: [`docs/research/COMPETITOR-COMPARISON.md`](research/COMPETITOR-COMPARISON.md), [`docs/research/OPENKEY-NOTES.md`](research/OPENKEY-NOTES.md) và bộ dữ liệu kiểm thử (đặt dấu kiểu mới/cũ, bỏ dấu tự do, khôi phục từ nước ngoài, uơ/ươ…).
  - Dẫn mục "Đã biết nhưng không làm" của `docs/DECISIONS.md`.
- Nội dung có bản tiếng Việt và tiếng Anh nếu M9 đã xong.
- Xong khi: người dùng duyệt nội dung trên canvas; mọi ví dụ trong phần học có test engine tương ứng; kiểm toán ĐẠT.

## Tồn đọng chưa gắn mốc

- D39 (Ủng hộ dự án): có đặt liên kết ủng hộ trong app hay không; vẽ trên canvas trước.
- Xem lại gợi ý "Báo lại để bản sau xử lý đúng cho ứng dụng đó" (hàng "Gặp ứng dụng gõ bị lỗi?", `UpdatesSupportView`) theo N5 khi làm báo lỗi.
- `.gitignore` bỏ qua `Package.resolved`: ghim phiên bản Sparkle chính xác trong `project.yml`.
- Thử bỏ `temporary-exception.mach-register.global-name` của bộ gõ khi rà entitlement trước notarize (xem [`docs/ARCHITECTURE.md`](ARCHITECTURE.md)).
- Thêm `*.p8`, `*.pem`, `*.key`, `*.xcarchive` vào `.gitignore`.
