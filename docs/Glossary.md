# Bảng thuật ngữ Anh–Việt

Bảng này ghi thuật ngữ dùng trong chuỗi giao diện của Dấu (String Catalog, D41 (Ngôn ngữ giao diện)), để câu tiếng Anh và câu tiếng Việt gọi một thứ bằng cùng một từ ở mọi màn. Câu tiếng Anh theo thuật ngữ Apple tiếng Anh, còn câu tiếng Việt theo thuật ngữ Apple tiếng Việt (D38 (Chữ trên giao diện)). Từ mới phải được thêm vào đây trước khi viết câu dùng nó. Mục "Từ dễ hiểu hai nghĩa" áp dụng cả cho tài liệu. Lệnh `scripts/check-l10n/check.sh` kiểm mọi khoá có đủ bản `en` và `vi`.

## Không dịch

- **Dấu** giữ nguyên ở mọi ngôn ngữ (D24 (Tên và định danh)).
- **Tên giao diện của macOS** gồm mọi case của enum `SystemUIName`. Danh sách đủ nằm ở `docs/Architecture.md`, mục "Tên giao diện của macOS trong chữ của Dấu". Các tên này không được viết thẳng trong câu. Chúng luôn là `%@` lấy từ chuỗi của hệ thống (`SystemUINames`, `LayoutNames`; D38).
- **Nhãn trong app của người khác** (OpenKey "Bảng điều khiển…", "Khởi động cùng macOS", "Thoát"; XKey "Thoát XKey"; Gõ Nhanh "Launch at login") được chép đúng chữ mà app đó hiện, kể cả trong câu tiếng Anh.
- **Ví dụ gõ** (`hoaf binhf`, `hoà`, `thúy`…) là dữ liệu, không dịch.

## Thuật ngữ

| Tiếng Anh | Tiếng Việt | Ghi chú |
|---|---|---|
| input source | nguồn đầu vào | Đây là khái niệm của macOS; cách gọi theo D38. |
| Input menu | menu nguồn đầu vào | Đây là menu nguồn đầu vào trên thanh menu. |
| input method | bộ gõ | Đây là phần mềm gõ (Dấu, OpenKey…). Cụm "bộ gõ Dấu" chỉ tiến trình bộ gõ, khác với app Dấu. |
| official build | bản phát hành | Đây là bản do CI dựng, ký Developer ID và công bố. Từ này thuộc trục "ai dựng và ký" của D7 (Cập nhật và loại bản dựng) và D25 (Nhận diện). |
| development build | bản phát triển | Đây là mọi bản không do CI ký: Debug, Release tự dựng và bản fork (D7). |
| Debug / Release | bản Debug / bản Release | Đây là cấu hình build của Xcode. Tên giữ nguyên (D7). |
| Beta channel / Stable channel | kênh Beta / kênh Chính thức | Người dùng chọn kênh ở trang Cập nhật & hỗ trợ (D7). |
| beta / stable release | bản beta / bản chính thức | Bản chính thức là tệp của beta cuối (D7). |
| Dấu – Vietnamese | Dấu – Tiếng Việt | Đây là tên nguồn đầu vào. macOS chọn tên theo ngôn ngữ hệ thống (D41), nên trong câu tên này luôn là `%@` (`SystemUINames.dauInputSource`), không viết cứng. |
| typing method | kiểu gõ | Các kiểu gõ là Telex, VNI và Simple Telex. |
| Simple Telex | Telex đơn giản | Xem D29 (Telex đơn giản). |
| tone mark placement | vị trí dấu thanh | Modern / Classic dịch là kiểu mới / kiểu cũ. |
| mark key | phím dấu | Từ này mang nghĩa rộng, gồm cả phím biến đổi (mục "Từ dễ hiểu hai nghĩa"). |
| free mark placement | đặt dấu tự do | Xem D28 (Đặt dấu tự do). |
| restore non-Vietnamese words | tự khôi phục từ không phải tiếng Việt | Xem D4 (Từ nước ngoài). |
| add marks to typed words | thêm dấu cho từ đã gõ | Xem D20 (Thêm dấu cho từ đã gõ). |
| consonant shortcuts | gõ tắt phụ âm | Xem D21 (Gõ tắt phụ âm). |
| Smart Typing | Thông minh | Đây là một mục trong sidebar. |
| underline | gạch chân | Từ này dùng cho quy tắc theo app: Underline / No Underline dịch là Có gạch chân / Không gạch chân (D5 (Quy tắc theo ứng dụng), D13 (Gạch chân là đường lui cuối cùng)). |
| app rules | quy tắc riêng | |
| Suggested | Đề xuất | Đây là mục và nhãn cho app mà Dấu đề xuất bật gạch chân, vì số đo cho thấy thay tại chỗ còn sai ở app đó (danh sách tương thích, D13). |
| Dấu Settings | Cài đặt Dấu | Đây là tên cửa sổ Cài đặt. Trong menu bộ gõ, mục này là "Dấu Settings…" / "Cài đặt Dấu…". |
| Set Up Dấu, Setup Guide… | Thiết lập Dấu, Hướng dẫn thiết lập… | Đây là cửa sổ onboarding và mục trong menu Help. |
| turn on / turn off | bật / tắt | |
| Try Again | Thử lại | |
| Reinstall | Cài lại | |
| Uninstall… | Gỡ cài đặt… | Cụm "remove from input sources" dịch là "bỏ khỏi nguồn đầu vào". |
| Check for Updates… | Kiểm tra bản mới… | Nút này nằm ở trang Cập nhật & hỗ trợ (D7 (Cập nhật và loại bản dựng)). |
| Report a Problem… | Báo lỗi… | Nút này mở sheet báo lỗi (D8 (Không telemetry)). |
| Included | Gửi kèm | Đây là phần thông tin máy và thông tin Dấu trong sheet báo lỗi. |

## Từ dễ hiểu hai nghĩa

Các luật dưới đây áp dụng cho chuỗi giao diện, tài liệu, comment và script.

- **"dấu", "phím dấu"** luôn mang nghĩa rộng: dấu thanh, mũ, móc, trăng và đ, cùng mọi phím tạo ra chúng. Khi cần nghĩa hẹp thì dùng các từ sau:
  - "dấu thanh" và "phím dấu thanh" chỉ sắc, huyền, hỏi, ngã, nặng (Telex s f r x j; VNI 1–5);
  - "phím biến đổi" chỉ mũ, móc, trăng và đ (Telex aa ee oo w dd; VNI 6–9).
- **Động từ đi với dấu** là "đặt dấu" (thêm dấu vào chữ), "đổi dấu", "xoá dấu" và "viết không dấu". Không dùng "bỏ dấu", vì có người hiểu từ này là đặt dấu, có người hiểu là xoá dấu.
- **"cài đặt"** là danh từ và chỉ phần Cài đặt (Settings). Động từ install viết là "cài" ("cài lại", "chưa cài được"). "Gỡ cài đặt" là cụm cố định cho Uninstall.
- **"nguồn đầu vào"** là cách viết đúng; không viết "nguồn nhập liệu" (D38).
- **"chính thức"** chỉ dùng để đối lập với beta: bản chính thức, kênh Chính thức (D7). Bản do CI ký là "bản phát hành", còn cấu hình build thì viết "bản Debug", "bản Release". Không viết "bản ổn định", "bản release" hay "bản thử đầu"; thay vào đó viết "beta đầu tiên".
- **Tên Dấu và chữ "dấu":** câu nói về dấu không mở đầu bằng chữ "dấu" trần, vì khi viết hoa ở đầu câu, chữ đó sẽ được đọc thành tên app. Hãy viết "dấu thanh…" hoặc đảo câu. Khi nói tới bỏ app khỏi danh sách nguồn, luôn viết đủ là "bỏ Dấu khỏi nguồn đầu vào".

## Cách viết câu tiếng Anh

- Nút, mục menu, tiêu đề cửa sổ, sheet, mục sidebar và lựa chọn của menu chọn viết hoa đầu mỗi từ (title case). Tên hàng, tiêu đề nhóm, mô tả và câu gợi ý chỉ viết hoa chữ đầu câu (sentence case).
- Tiêu đề ngắn dạng cụm từ (alert, banner) viết Title Case; tiêu đề là một câu đầy đủ thì viết sentence case.
- Câu tiếng Anh dùng dấu nháy cong “ ” và ’. Dấu ba chấm là một ký tự (…), như chuỗi của macOS.
- Phím Enter của bàn phím Mac được gọi là Return.
