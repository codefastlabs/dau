# Giao diện

Luật cho mọi thay đổi giao diện: app chủ (`Apps/Dau`), trang web (`site/`), canvas (`docs/canvas/`).

- Canvas trước, mã sau. Sửa artboard trên canvas, cho người dùng xem và duyệt, rồi mới giao sửa mã; mã xong thì đối chiếu lại với artboard. Không sửa giao diện mà artboard chưa có.
- Người dùng duyệt artboard xong thì lưu các file canvas bằng công cụ Artifact (`read` với `paths`; ảnh upload mà artboard dùng thì `read` với `path` là id của ảnh, lưu vào `<thư mục>/_blob/`) rồi chạy `scripts/design/render-canvas.sh <thư mục đã lưu>` để cập nhật bản chụp trong `docs/canvas/`, cùng commit với thay đổi. Script chụp artboard dạng trang (`"expand": "fill"`) theo chiều cao thật của nội dung. Khi chiều cao đó khác khung trên canvas, script ghi chiều cao mới vào `canvas.json` của thư mục đã lưu; phiên chính publish file đó lên canvas ngay trong lượt, trước khi commit.
- Giao việc giao diện thì đưa file nguồn artboard (`docs/canvas/src/`); artboard thắng bản giao việc. Artboard cỡ cố định đo chiều cao từ bản dựng, đệm đáy 40 px như đệm đầu, không ước; artboard dạng trang thì script chụp tự đo. Canvas cắt mọi artboard cao quá 8.000 px, nên trang dài tách thành artboard phần trên và phần dưới, chia ở ranh giới một mục.
- Trước khi cho người dùng xem bản build giao diện, chạy ma trận cửa sổ thật và [`docs/UIChecks.md`](../../docs/UIChecks.md), tự xem ảnh.
