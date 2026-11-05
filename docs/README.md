# Tài liệu

Mục lục mọi tài liệu trong `docs/`. Cách ghi (mỗi sự kiện ở một chỗ, khi nào sửa file nào) xem mục "Nguồn chuẩn" trong `CLAUDE.md`.

## Đang dùng

Đọc khi bắt đầu một phiên (thứ tự trong `CLAUDE.md`):

| File | Chứa gì |
|---|---|
| `docs/DECISIONS.md` | nguyên tắc N và quyết định D (nguồn chuẩn duy nhất), câu hỏi mở |
| `docs/ARCHITECTURE.md` | thành phần, build, luồng một phím |
| `docs/ROADMAP.md` | các mốc và tiêu chí hoàn thành |
| `docs/UI.md` | nội dung từng màn hình (mockup trên canvas) |
| `docs/BRAND.md` | biểu tượng, màu, chữ, file nhận diện cần xuất |
| `docs/PROGRESS.md` | trạng thái hiện tại, bảng mốc, kế hoạch mốc đang làm, số đo, nhật ký theo ngày |

Tra khi cần:

| File | Chứa gì |
|---|---|
| `docs/UI-CHECKS.md` | danh sách kiểm giao diện và lệnh chạy |
| `docs/COMPATIBILITY.md` | ma trận ứng dụng: cách thử, kết quả, giới hạn đã biết |
| `docs/OPENKEY-NOTES.md` | đọc mã OpenKey: tính năng, ca biên, Dấu làm hay không |

## Nghiên cứu

Mỗi chủ đề một file; kết luận hiện hành ở đầu file, mỗi khẳng định có nguồn.

| File | Chủ đề |
|---|---|
| `docs/research/M5-INSTALL.md` | cài, bật, nâng cấp, gỡ bộ gõ; lần cài đầu; bộ gõ cũ cần phát hiện |
| `docs/research/SYSTEM-SETTINGS-REFERENCE.md` | số đo giao diện của System Settings dùng làm chuẩn (script kiểm đọc theo) |
| `docs/research/EXTERNAL-TEST-INPUTS.md` | ca thử (chuỗi phím, không đáp án) gom từ bộ test của 10 bộ gõ tiếng Việt khác, để viết đáp án mù cho engine; ghi công ở `docs/research/external-test-inputs/NOTICE.md` |

## Lưu trữ

Ghi lại quá khứ, không sửa theo hiện trạng.

| File | Chứa gì |
|---|---|
| `docs/history/PLANS.md` | kế hoạch của các mốc đã đóng |
| `docs/history/M2-TESTING.md` | gõ thử M2 trên máy thật và kết quả (cách thử hiện hành: `docs/COMPATIBILITY.md` mục 4) |
| `docs/history/M4-TESTING.md` | cách thử M4 trên máy thật |
| `docs/history/LOG-M0-M4.md` | nhật ký M0–M4 (29–30/10/2026), chuyển từ `PROGRESS.md` khi đóng M4 |
| `docs/history/LOG-M5.md` | nhật ký M5 (30/10–05/11/2026), chuyển từ `PROGRESS.md` khi đóng M5 |
| `docs/history/COMMIT-MAP.md` | mã commit cũ → mới sau khi viết lại lịch sử (02/11/2026) |
| `docs/history/KICKOFF.md` | brief khởi động M0–M8 lúc bắt đầu dự án |
