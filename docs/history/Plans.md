# Kế hoạch của các mốc đã đóng

Chép nguyên từ `docs/Progress.md` khi sắp xếp lại tài liệu (03/11/2026). Kết quả từng việc nằm ở nhật ký `Progress.md`.

## M0 + M1
| Việc | Agent | Song song |
|---|---|---|
| M0: git init, .gitignore, LICENSE, README, project.yml, khung 2 app + 2 package, build Debug universal | release-eng | với M1-nghiên cứu |
| M1a: clone OpenKey ra /tmp, viết `docs/research/OpenKeyNotes.md` | researcher | với M0 |
| M1b: engine Telex + test (sau M1a, đối chiếu mâu thuẫn trước) | engine-dev | sau M1a |
| M1c: VNI, Telex đơn giản, gõ tắt phụ âm, test hiệu năng | engine-dev | sau M1b |
| Kiểm toán M0, M1 | auditor | cuối mỗi mốc |

## M3 (30/10/2026)
| # | Việc | Agent | Song song |
|---|---|---|---|
| T1 | Chế độ gạch chân D13 (`setMarkedText`, chốt chữ khi kết thúc từ/reset), bật theo quy tắc người dùng; đo thử ở Chrome, VS Code, Terminal với phím dồn (0/5/10 ms) | imk-dev | cùng T5 |
| T5 | Khung `docs/Compatibility.md`: danh sách app cần thử (app phổ biến ở VN, app đã cài trên máy), cột kết quả, cách thử | researcher | cùng T1 |
| T2 | D20 "Thêm dấu cho từ đã gõ" ở bộ gõ (đọc chữ trước con trỏ bằng `attributedSubstring` khi bộ đệm rỗng, `seed`); reset khi đổi nguồn không qua `activateServer`; rà D18 | imk-dev | sau T1 (cùng file controller) |
| T3 | Danh sách tương thích có sẵn trong bản build (D7, D13): model ở DauShared, bộ gõ đọc, app hiện "Đề xuất"; nội dung theo kết quả T1 | imk-dev + app-ui-dev | sau T1 |
| T4 | Mở lại giao diện đã làm xong (lựa chọn gạch chân, công tắc D20), bỏ ô trống M3 tương ứng | app-ui-dev | sau T2, T3 |
| T6 | Chạy ma trận tương thích trên máy, ghi tự sửa chính tả (D4) | phiên chính + agent GUI | sau T4 |
| T7 | VoiceOver đọc tên nguồn (D17), biểu tượng V | người dùng | bất kỳ lúc nào |
| T8 | Kiểm toán M3 | auditor | cuối |

## M5 (30/10/2026)
| # | Việc | Agent | Song song |
|---|---|---|---|
| T1 | Trả lời câu hỏi mở: `TISRegisterInputSource`/`TISEnableInputSource` từ app chủ có cần người dùng xác nhận, có phải đăng xuất lần đầu không; app chủ có sandbox chép được bộ gõ vào `~/Library/Input Methods` không (temporary-exception); cách các bộ gõ mở cài/gỡ; danh sách bundle ID bộ gõ tiếng Việt cũ | researcher | cùng T2 |
| T2 | Giao diện onboarding 3 bước theo artboard (OnboardingConflict, OnboardingEnable, Onboarding), dịch vụ cài/bật/phát hiện để giao diện gọi qua protocol, hiện đúng phím tắt hệ thống | app-ui-dev | cùng T1 |
| T3 | Dịch vụ cài đặt thật: chép bộ gõ nhúng sẵn, đăng ký, bật (người dùng bấm, N4) có Hoàn tác, nâng cấp bản mới (dừng tiến trình cũ), gỡ cài đặt (D16, sheet xác nhận) | imk-dev (+ app-ui-dev nối giao diện) | sau T1 |
| T4 | ~~Thử trên máy: gỡ bản Debug hiện tại rồi chạy onboarding từ đầu~~ — bỏ (người dùng chốt 04/11/2026). Phần gỡ qua app rồi chạy onboarding từ đầu đã làm 04/11 với bản Release (nhật ký 04/11); không thử trên tài khoản macOS mới | — | — |
| T5 | Kiểm toán M5 | auditor | cuối |

## Lần thử cài Dấu thật trên máy sạch (kế hoạch 03/11/2026, bỏ 04/11/2026)

Chuyển từ mục 7.2–7.5 của `docs/research/InputMethodInstall.md` ngày 10/11/2026. Lần thử này không chạy; số mục dẫn trong phần dưới là số mục của file đó.

### 7.2 Chuẩn bị (một lần)
1. Tạo tài khoản macOS mới (chưa từng cài Dấu hay biến thể nào; `docs/Progress.md` 02/11/2026: chỉ dịch vụ nguồn nhập liệu ghi được `com.apple.inputsources`, nên muốn máy sạch thật thì dùng tài khoản mới, mục 2.6), đăng nhập, chờ khoảng một phút cho phiên ổn định. Không cài gì vào `~/Library/Input Methods` trước.
2. Chạy `scripts/dev/clean-dau.sh` (không tham số, chỉ liệt kê) làm mốc "không có Dấu".
3. Mở Terminal thứ hai chạy nhật ký liên tục, ghi vào file có giờ:
   `/usr/bin/log stream --info --debug --style compact --predicate 'process IN {"imklaunchagent","TextInputMenuAgent","TextInputSwitcher","keyboardservicesd","CursorUIViewService","cfprefsd","KeyboardSettings"} OR eventMessage CONTAINS[c] "inputsource" OR eventMessage CONTAINS[c] "codefastlabs.dau"' > ~/dau-t4-log.txt`
   - Tên tiến trình và bộ lọc [Suy luận, cần kiểm chứng]: chỉnh khi chạy; dữ liệu `<private>` bị che nếu không cài hồ sơ ghi nhật ký.
   - `KeyboardSettings` thêm vào để bắt dòng "Invalid value on inputSourceToBeEnabled", mục 2.2.
   - Tên file `~/dau-t4-log.txt` giữ nguyên như kế hoạch gốc ("t4" là tên cũ của lần thử trên máy sạch này).
4. Ghi giờ đồng hồ vào một file ghi chú mỗi khi bắt đầu một bước, để đối chiếu với nhật ký.

### 7.3 Các bước thử
Mục 7 có hai bước (đối chứng bằng Dấu thật, và đăng xuất); các bước của vòng thử bằng bản thử có bảng riêng ở mục 8.2.
Mỗi bước: cài, làm đúng chuỗi, chờ 10 giây, rồi chạy bảng kiểm 7.4. Đặt kết quả là `HIỆN` (xuất hiện trong menu/"+"/danh sách bên trái) hoặc `KHÔNG`.

| Bước | ID | Chuỗi gọi | Mục đích | Mức xâm lấn |
|---|---|---|---|---|
| Đối chứng | **Dấu thật** | **Đối chứng**: đúng luồng "Bật Dấu" của app hiện tại (chép bằng đổi tên nguyên khối, `Register`, đợi 1 s, bật cha, đọc lại cùng tiến trình). **Nhìn "+" bằng mắt**, cả menu, danh sách trái, ⌃Space. Chụp `defaults export com.apple.inputsources -` trước và sau lệnh bật | Tái hiện lần thử cài đầu 02/11 (mục 9.5) trên máy sạch; trả lời câu hỏi mở về đăng xuất (mục 10.1) cho Dấu | Không |
| Đăng xuất | (tất cả) | **Đăng xuất, đăng nhập lại (lần duy nhất).** Chạy `scripts/dev/clean-dau.sh` (không tham số) ngay khi vào, rồi nhìn giao diện | Xác nhận đối chứng: ID nào hiện sau đăng nhập, ID nào đã được bật sẵn | Không |

### 7.4 Bảng kiểm sau mỗi bước
1. Cài đặt › Bàn phím › Nguồn nhập liệu › Sửa…: danh sách bên trái, và hộp thoại "+" (tìm "Dấu" ở nhóm tiếng Việt và ô tìm kiếm) (chụp ảnh). **Nhìn bằng mắt.**
2. Menu nhập liệu trên thanh menu, và công tắc ⌃Space (hoặc phím chuyển nguồn): có "Dấu" không (chụp ảnh).
3. Có hộp thoại "Cho phép … bật …?" của hệ thống hiện không; Cài đặt có tự mở không; hiện ở đâu; bấm gì (ghi lại cả khi không hiện).
4. `scripts/dev/clean-dau.sh` (không tham số): mục Dấu trong `com.apple.inputsources`, tiến trình, bundle, đăng ký LaunchServices. Ghi thêm `AppleInputSourceUpdateTime` từ `defaults export com.apple.inputsources -`.
5. Nhật ký `/usr/bin/log stream` trong khoảng giờ của bước: các dòng của `imklaunchagent`, `TextInputMenuAgent`, `cfprefsd`, `KeyboardSettings` (nhất là "Invalid value on inputSourceToBeEnabled") và nhật ký `com.codefastlabs.dau` của app (`event=register`, `event=enable`).

Mẫu ghi một dòng cho mỗi bước: `bước | mã trả về Register/Enable | "+" | menu | ⌃Space | hộp thoại / Cài đặt tự mở | tuỳ chọn có (Y/N) | ghi chú`.

### 7.5 Cách đọc kết quả
- **Đối chứng đã HIỆN ngay (không đăng xuất):** câu trả lời cho Dấu là "không cần" trên bản macOS đó; ghi bản macOS.
- **Chỉ bước đăng xuất làm hiện:** xác nhận kết luận của Apple DTS cho Dấu; đề xuất làm hướng dựng lại ảnh chụp và hướng "đã bật, chờ đăng xuất" (mục 7.1, chờ người dùng quyết) và đóng việc này.
- **Đối chứng hiện trong "+" nhưng nguồn vẫn không bật được** (bật từ app trả 0, mục cha còn `enabled=0`, hoặc người dùng thêm bằng "+" rồi vẫn không dùng được): đây là hành vi của Enable ở mục 2.2, không phải câu trả lời cho câu hỏi về đăng xuất.
  - Ghi riêng hai kết quả ("có hiện trong '+'" và "bật được"), và nút "Bật Dấu" vẫn không được hứa bật được (mục 6.1 điểm 1).
- **Máy vẫn còn mục Dấu cũ** (`scripts/dev/clean-dau.sh` không tham số báo `AppleEnabledThirdPartyInputSources` còn mục Dấu, hoặc Dấu "tự có sẵn" ngay sau đăng nhập): kết quả không dùng được để trả lời câu hỏi về đăng xuất, vì chỉ tài khoản macOS mới là sạch thật (mục 7.2, 2.6); làm lại trên tài khoản mới.

