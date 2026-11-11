---
description: Điều phối trọn một mốc trong docs/Roadmap.md bằng các subagent, có kiểm toán trước khi đóng mốc
argument-hint: <M0..M10>
disable-model-invocation: true
---
Điều phối mốc **$ARGUMENTS** theo mục "Điều phối" trong `CLAUDE.md`:

1. Đọc `docs/Progress.md`, `docs/Decisions.md`, mục $ARGUMENTS trong `docs/Roadmap.md`. Nếu mốc trước chưa ĐẠT thì dừng và báo.
2. Chia mốc thành việc nhỏ, ghi kế hoạch vào `docs/Progress.md` (việc, agent phụ trách, việc nào chạy song song được).
3. Việc nhỏ và vừa phiên chính tự làm; việc lớn giao subagent phù hợp, việc độc lập thì giao song song. Giao từ 3 agent trở lên trong một lượt thì báo người dùng số agent và mức nặng. Mỗi lần giao: nêu rõ phạm vi, file được sửa, tiêu chí xong.
4. Sau mỗi kết quả: đọc 5 mục báo cáo, chạy lại lệnh kiểm chứng (đổi chuỗi giao diện thì thêm `scripts/check-l10n/check.sh`), đọc lại tài liệu đã sửa và grep chỗ dẫn tới thứ đã đổi, commit nếu xanh. Mâu thuẫn hoặc câu hỏi mở thì ghi vào `docs/Progress.md`.
5. Gọi `auditor` một lần khi mốc xong, rà cả **nội dung** `docs/` và `scripts/` (mâu thuẫn giữa các file, giả thiết ghi như sự thật, nhật ký có kết luận đã bị bác mà chưa đánh dấu, đường dẫn và số mục được dẫn). CHƯA ĐẠT thì giao sửa các mục "chặn", rồi kiểm toán lại chỉ trên danh sách đó; mục "ghi chú" vào `docs/Progress.md`.
6. Đóng mốc: cập nhật `docs/Progress.md` (đã làm, số đo, câu hỏi mở), chuyển nhật ký và ghi nhớ của mốc sang `docs/history/` (thêm vào mục lục `docs/README.md`), tóm tắt cho người dùng, liệt kê việc người dùng cần làm. Chỉ chuyển mốc tiếp khi không còn việc chờ người dùng chặn đường.
