# Giao diện

Luật cho mọi thay đổi giao diện: app chủ (`Apps/Dau`), trang web (`site/`), canvas (`docs/canvas/`).

- Canvas trước, mã sau. Sửa artboard trên canvas, cho người dùng xem và duyệt, rồi mới giao sửa mã; mã xong thì đối chiếu lại với artboard. Không sửa giao diện mà artboard chưa có.
- Người dùng duyệt artboard xong thì lưu các file canvas bằng công cụ Artifact (`read` với `paths`) rồi chạy `scripts/design/render-canvas.sh <thư mục đã lưu>` để cập nhật bản chụp trong `docs/canvas/`, cùng commit với thay đổi.
- Giao việc giao diện thì đưa file nguồn artboard (`docs/canvas/src/`); artboard thắng bản giao việc. Chiều cao artboard đo từ bản dựng, đệm đáy 40 px như đệm đầu, không ước.
- Trước khi cho người dùng xem bản build giao diện, chạy ma trận cửa sổ thật và [`docs/UIChecks.md`](../../docs/UIChecks.md), tự xem ảnh.
