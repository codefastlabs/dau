# Tiến độ

Nhật ký điều phối, để phiên sau (hoặc sau khi ngữ cảnh bị nén) tiếp tục đúng chỗ. Phiên chính cập nhật file này sau mỗi bước.

## Trạng thái hiện tại

M6 (Hiệu năng dưới tải) đóng 16/11/2026, kiểm toán ĐẠT. Mốc kế: M7 (Phát hành), chưa bắt đầu.

Chờ người dùng:
- Không có.

Việc tiếp theo:
- M7: lập kế hoạch theo `docs/Roadmap.md` mục M7.

Việc mở:
- Ma trận tương thích còn lại, làm sau bản thử đầu: `docs/Roadmap.md` mục "Tồn đọng chưa gắn mốc", danh sách ở `docs/Compatibility.md` mục 7.
- `smartAdvancedExpanded` (khoá môi trường mở sẵn "Nâng cao" ở trang Thông minh) không còn chỗ nào đặt thành true từ khi bỏ công cụ chụp `SnapshotSettings` (16/11); đường truyền qua `SettingsWindow` là mã chết, bỏ được (kiểm toán M6).
- Bộ đệm nguồn đầu vào của các app: tiến trình trong thư mục cache được hệ thống bảo vệ (WebKit, Shortcuts) không xoá được, ảnh hưởng chưa đo; gỡ cài đặt chưa xoá bộ đệm của các app (`docs/research/InputMethodInstall.md` mục 10.7).
- Chưa có artboard: tên các nguồn tiếng Việt khác trong ghi chú của D14 (Onboarding) vẫn theo tiếng Việt của app (`LayoutNames` chỉ có bàn phím).
- Chưa chạy qua script: nhánh "đã trùng sẵn" và các nhánh lỗi của việc thay bộ gõ. `scripts/selftest/app-group.sh --install` chưa chạy lại kể từ khi gộp script cài 10/11. Chưa kiểm: VoiceOver, cờ `--tampered` trên cửa sổ thật.
- Sheet thêm quy tắc: ba nút cuối không có nhãn trợ năng (/dogfood 11/11; chưa kiểm bằng VoiceOver).

## Mốc

| Mốc | Trạng thái | Kiểm toán |
|---|---|---|
| M0 Khung dự án | xong | ĐẠT (29/10) |
| M1 Engine | xong | ĐẠT (29/10, lần 2) |
| M2 Bộ gõ tối thiểu | xong | ĐẠT (30/10, lần 3) |
| M3 Độ tin cậy | xong | ĐẠT (30/10, lần 3) |
| M4 App Cài đặt | xong | ĐẠT (30/10, lần 3) |
| M5 Onboarding, cài, gỡ | xong | ĐẠT (05/11) |
| M6 Hiệu năng dưới tải | xong | ĐẠT (16/11) |
| M7 Phát hành | chưa | — |
| M8 Website | chưa | — |
| M9 Đa ngôn ngữ | phần nền (D41 (Ngôn ngữ giao diện)) và câu chữ tiếng Anh xong 06–09/11 | — |
| M10 Học cách gõ | chưa | — |

## Nhật ký
Nhật ký M0–M4 ở `docs/history/LogM0ToM4.md` (kèm bảng số đo M1–M3), M5 ở `docs/history/LogM5.md`, 05–08/11 (giữa M5 và M6) ở `docs/history/LogBetweenM5AndM6.md`, M6 ở `docs/history/LogM6.md`.

(ngày — việc — agent — kết quả — commit)

- 17/11 — chẩn đoán lỗi người dùng báo: gõ từ chưa dấu, dấu cách, ⌫, phím dấu, dấu không vào từ mà đứng sau nó ("hocj"), lúc có lúc không — phiên phụ, không agent — client giả dựng lại ba cơ chế cùng ra "hocj"; gõ lại phím dấu chậm ngay sau đó phân biệt được chúng: (1) từ ⌫ tới phím dấu dưới 50 ms (D20, `settleInterval`): gõ lại chậm thì được; (2) một lần đọc trước đó trong cùng lần kích hoạt nhận `NSNotFound` hay `nil`: `readUnavailable` tắt mọi lần đọc D20 tới lần kích hoạt sau (D20, D18), gõ lại vẫn hỏng, đổi app rồi quay lại thì được; (3) app trả chậm hơn `lateLimit` (mô hình bộ đệm Chromium, chậm 3–4 thao tác): chỉ hỏng phím đó. Đọc mã không thấy cơ chế khác (D20 "Từ hệ thống vừa sửa", mô hình Cursor, reset bằng mũi tên đều đúng). Ca người dùng gặp, ở app Claude: "khuyeens" ra "khuyến", "cao␣⌫s" ra "caos", ⌫⌫ ra "ca", "s" ra "cas". Ở 150 ms giữa các phím, chỉ cơ chế 2 ra đủ chuỗi đó: mô hình chậm 3 thao tác ra "caos" rồi "cá", chậm 4 làm hỏng cả "khuyến"; cơ chế 1 phải xảy ra hai lần liền. Chưa rõ lần đọc hỏng trước đó là lần nào (bản Release không ghi log theo phím, D8). Sửa (người dùng duyệt đổi D20): một lần đọc không nhận được gì chỉ mất lần đọc của phím đó; hai lần liền nhau mới thôi đọc tới lần kích hoạt sau, một lần đọc được ở giữa thì đếm lại (`InPlaceComposer.failedReadLimit`). Test: `BackspaceThenMarkTests` (gồm đúng chuỗi phím đã báo), `failedReadsStartOver`; `LateBackspaceMarkTests` giữ known issue (chậm 3–4 thao tác, chưa sửa). Bộ gõ 209 test đạt, 11 known issue. Chưa kiểm trong app Claude thật: lần đọc hỏng chưa tái hiện được ngoài đời, chỉ xác nhận được khi dùng hằng ngày bản mới mà không gặp lại Đã cài bản Release của commit này bằng `scripts/dev/install-app.sh` (`dau-version.sh`: bộ gõ và Dấu.app đều đúng commit); tag `stable` chưa chuyển, chờ dùng thử — commit "fix(input-method): one failed read no longer stops D20 until activation".

