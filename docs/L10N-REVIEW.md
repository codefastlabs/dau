# Duyệt câu chữ tiếng Anh (M9)

Bản làm việc tạm, soạn ngày 08/11/2026 cho việc "Người dùng duyệt câu chữ tiếng Anh" của M9 (`docs/ROADMAP.md`, D41). Duyệt xong và đã sửa catalog thì xoá file này; quyết định mới (nếu có) ghi vào `DECISIONS.md`, thuật ngữ mới vào `docs/GLOSSARY.md`.

Cách duyệt: ở mỗi dòng của phần A–D, ghi vào cột "Chốt" một trong ba lựa chọn: **đồng ý** đề xuất, **giữ** câu hiện tại, hoặc viết câu khác. Phần E là toàn bộ câu chữ để đọc lướt; câu nào muốn sửa thì chép lên phần D.

Nguồn đề xuất: kiểm toán phần nền ngày 06/11 (phần A), danh sách câu app-ui-dev chưa chắc khi đổi khoá (phần B), phiên chính rà lại cả 209 câu ngày 08/11 (phần C). Chưa sửa câu nào trong catalog.

Ghi chú chung:
- Đổi câu tiếng Anh tức là đổi khoá. Cần sửa cả chỗ gọi trong mã, rồi chạy `scripts/check-l10n/check.sh` kèm thư mục build. Bản `vi` giữ nguyên trừ khi dòng đó ghi rõ là sửa cả `vi`.
- Kiểu chữ hoa theo `docs/GLOSSARY.md`: Title Case cho nút, mục menu, tiêu đề cửa sổ và sheet; sentence case cho tên hàng, mô tả, câu gợi ý.

## A. Kiểm toán đề xuất (06/11)

| # | Hiện tại | Bản `vi` | Đề xuất | Lý do | Chốt |
|---|---|---|---|---|---|
| A1 | Search Applications | Tìm trong Ứng dụng | Search apps / Tìm ứng dụng (sửa cả `vi`) | "Applications" là tên thư mục của macOS mà viết cứng, trái D38; lệch với "Search apps" ở trang Ứng dụng. Ô tìm này tìm trong danh sách app nên không cần nhắc tên thư mục. Sau khi sửa, hai khoá thành một. | |
| A2 | Apps labeled “Suggested” may type wrong text when you type very fast. Choose “Underline” only if an app garbles text as you type. | Ứng dụng có nhãn “Đề xuất” có thể gõ sai… | Text may come out wrong in apps labeled “Suggested” when you type very fast. Choose “Underline” only if an app garbles text as you type. | Nói "app types text" (app gõ chữ) nghe gượng, vì người gõ là người dùng. | |
| A3 | May type wrong text when you type very fast | Có thể sai chữ khi gõ rất nhanh | Text may come out wrong when you type very fast | Như A2. | |
| A4 | Typing goes wrong in an app? | Gặp ứng dụng gõ bị lỗi? | Problems typing in an app? | Tự nhiên hơn. Câu gợi ý của hàng này vẫn đang hoãn sang M7. | |
| A5 | Turn On (nút trên banner) | Bật lại | Turn On Again | Giữ nghĩa "lại" của bản `vi`. | |
| A6 | Current (VoiceOver) | Đang làm | In progress | Khớp nghĩa của bản `vi`. | |
| A7 | Done (VoiceOver) | Đã xong | Completed | Tránh trùng chữ với nút Done của macOS (nút đó lấy tên từ hệ thống, D38). | |
| A8 | Remove Dấu from Input Sources | Bỏ Dấu khỏi nguồn đầu vào | Remove Dấu from Your Input Sources | Viết hoa "Input Sources" trông như tên ô Input Sources của System Settings bị viết cứng. Câu này nói khái niệm chung, như bản `vi`. | |

## B. app-ui-dev chưa chắc (06/11)

Các câu này chưa có đề xuất khác. Không thấy câu nào tốt hơn rõ rệt thì giữ.

| # | Hiện tại | Bản `vi` | Ghi chú | Chốt |
|---|---|---|---|---|
| B1 | Smart Typing | Thông minh | Tên mục sidebar. Bản tiếng Anh dài hơn bản `vi` vì "Smart" đứng một mình không rõ nghĩa. | |
| B2 | Free mark placement | Bỏ dấu tự do | Đã có trong GLOSSARY. Có câu phụ giải thích ("Type mark keys anywhere after the vowel"). | |
| B3 | Running now: %@. When two input methods run at the same time, marks are added twice and the text comes out wrong. | %@ đang chạy. Khi hai bộ gõ cùng chạy… | `%@` có thể là nhiều tên ("OpenKey and XKey"), nên không viết "%@ is running" được. | |
| B4 | Turn Off Other Input Methods | Tắt bộ gõ đang chạy | Tiêu đề bước 1. | |
| B5 | App rules | Quy tắc riêng | Đã có trong GLOSSARY. | |
| B6 | Remove Rule | Xoá quy tắc | Mục menu ngữ cảnh. | |
| B7 | Uninstall (nút trong alert) | Tiếp tục gỡ | Xem C1: alert có tiêu đề "Remove Dấu from this Mac?" mà nút lại là "Uninstall". | |
| B8 | Go Back | Quay lại | Đặt khác "Back" (Lùi) của thanh công cụ để không trùng khoá. | |
| B9 | Try: %@ | Gợi ý: %@ | Đề xuất khác: "Example: %@" hoặc "Try typing: %@". | |
| B10 | Input menu | menu nguồn đầu vào | Thuật ngữ Apple tiếng Anh, đã có trong GLOSSARY. Giữ. | |

## C. Phiên chính rà thêm (08/11)

| # | Hiện tại | Bản `vi` | Đề xuất | Lý do | Chốt |
|---|---|---|---|---|---|
| C1 | Remove Dấu from this Mac? (tiêu đề alert) · nút Uninstall | Gỡ Dấu khỏi máy? · Tiếp tục gỡ | Uninstall Dấu? · nút Uninstall | HIG của Apple (mục Alerts) khuyên nút dùng động từ khớp với nội dung alert. Hàng ở trang Hỗ trợ ("Remove Dấu from this Mac", nút "Uninstall…") có thể giữ nguyên. Cách khác: giữ tiêu đề và đổi nút thành "Remove". | |
| C2 | Choose Typing Method (tên bước 3 ở sidebar) | Chọn kiểu gõ | Choose a Typing Method | Khớp với tiêu đề bước 3 "Choose a Typing Method and Try It". | |
| C3 | %@ will close, reopen and ask whether to turn on Dấu. Click **%@**. | %@ sẽ đóng rồi mở lại… | %@ will quit, reopen, and ask whether to turn on Dấu. Click **%@**. | Apple dùng "quit" cho app, và có dấu phẩy trước "and" trong danh sách (serial comma). | |
| C4 | Bốn câu có "the %@" với %@ = Trash: "…moved to the %@." (2 câu), "…drag Dấu from the %@ folder to the %@.", "You’ll remove Dấu from %@ in %@; then Dấu is moved to the %@." | — | Bỏ "the" trước Trash: "moved to %@" (như mục "Move to Trash" của Finder) | Trên máy để tiếng Việt, %@ là "Thùng rác", nên câu hiện ra "moved to the Thùng rác" (kiểm toán đã ghi). Bỏ "the" thì đọc được với cả hai tên. | |
| C5 | You’ll remove Dấu from %@ in %@; then Dấu is moved to the %@. | …sau đó Dấu được chuyển vào %@. | You’ll remove Dấu from %@ in %@. Then the input method is moved to %@. | Thứ được chuyển vào Thùng rác là bộ gõ, không phải app Dấu (câu "Once Dấu is gone from the list, the input method is moved to the %@." đã nói đúng). Nếu đồng ý thì sửa cả `vi`: "…sau đó bộ gõ được chuyển vào %@." | |

## D. Cần quyết định trước khi sửa (không chỉ là câu chữ)

| # | Vấn đề | Lựa chọn | Chốt |
|---|---|---|---|
| D1 | Kiểu chữ hoa của tiêu đề alert và banner không đồng đều. "Couldn’t Remove Dấu", "Dấu Is On", "Couldn’t Turn On Dấu" viết Title Case vì dùng chung khoá với tiêu đề onboarding. "Dấu’s input method was removed", "Dấu isn’t turned on in your input sources" viết sentence case. | (a) Thêm vào GLOSSARY: tiêu đề ngắn dạng cụm từ viết Title Case, tiêu đề là câu đầy đủ viết sentence case, rồi giữ như hiện tại. (b) Tách khoá để mọi banner cùng một kiểu. | |
| D2 | "Accessibility" (Trợ năng) trong câu "Dấu doesn’t need Accessibility access." là tên mục của System Settings mà viết cứng ở cả hai thứ tiếng. Trái D38. | (a) Đọc tên từ chuỗi của hệ thống, như `SystemUINames`. (b) Viết lại không nhắc tên mục: "Dấu doesn’t need permission to control your Mac." | |
| D3 | "Apple menu" trong câu "If Dấu isn’t in that list, log out and log back in once (Apple menu › **%@**)…" viết cứng, trong khi câu "If an app can’t select Dấu yet, log out (%@ › %@)…" lại dùng ký hiệu  qua `%@`. | Dùng chung cách của câu thứ hai (ký hiệu , không có chữ). | |
| D4 | Câu có chèn tên app khác ("Gõ Nhanh", nhãn của OpenKey/XKey/PHTV) vẫn còn chữ tiếng Việt khi chạy bằng tiếng Anh. GLOSSARY đã cho phép, nhưng "Gõ Nhanh" chưa có trong danh sách "Không dịch" (kiểm toán ghi). | Thêm "Gõ Nhanh" vào mục "Không dịch" của GLOSSARY. | |

## E. Toàn bộ câu chữ (đọc lướt)

Sinh từ `Apps/Dau/Resources/Localizable.xcstrings` và catalog của bộ gõ ngày 08/11/2026, chia nhóm theo comment của từng khoá (chia gần đúng). Bỏ hai khoá tên bundle "Dấu".

### Onboarding (65)

| Tiếng Anh | Tiếng Việt | Ở đâu |
|---|---|---|
| %@ or 🌐 | %@ hoặc 🌐 | Shortcut in running text. %@ = key combination, e.g. ⌃Space; 🌐 = the Globe key. |
| A V icon in the menu bar while you type Vietnamese | Biểu tượng V trên thanh menu khi đang gõ tiếng Việt | Onboarding step 2: the input mode icon. |
| Add to input sources | Thêm vào nguồn đầu vào | Onboarding step 2 hint (sidebar). |
| Check Again | Kiểm tra lại | Onboarding step 1 button. |
| Check Other Input Methods | Kiểm tra bộ gõ cũ | Onboarding step 1 name (sidebar). |
| Choose a Typing Method and Try It | Chọn kiểu gõ và gõ thử | Onboarding step 3 title. |
| Choose Dấu from the Input menu, or press %@ to switch between Dấu and an English keyboard. | Chọn Dấu trên menu nguồn đầu vào, hoặc nhấn %@ để chuyển giữa Dấu và bàn phím tiếng Anh. | %@ = the shortcut, e.g. ⌃Space. |
| Choose Dấu from the Input menu, or press %@ to switch between Dấu and “%@”. | Chọn Dấu trên menu nguồn đầu vào, hoặc nhấn %@ để chuyển giữa Dấu và “%@”. | First %@ = the shortcut, e.g. ⌃Space; second %@ = the English keyboard layout's name as macOS shows it, e.g. U.S. |
| Choose Dấu from the Input menu. macOS has no shortcut yet to switch quickly between Dấu and an English keyboard. | Chọn Dấu trên menu nguồn đầu vào. macOS chưa có phím tắt để chuyển nhanh giữa Dấu và bàn phím tiếng Anh. | Onboarding: no input source shortcut is set. |
| Choose Dấu to type Vietnamese | Chọn Dấu để gõ tiếng Việt | Onboarding step 2 card heading. |
| Choose Typing Method | Chọn kiểu gõ | Onboarding step 3 name (sidebar). |
| Choose “Thoát XKey” from XKey’s menu | Chọn “Thoát XKey” trong menu của XKey | Step to quit XKey. The quoted name is XKey's own label: keep it. |
| Click **Try Again**. | Bấm **Thử lại**. | Install error step. “Try Again” = the button. |
| Click the OpenKey icon in the menu bar, then choose “Thoát” | Bấm biểu tượng OpenKey trên thanh menu, chọn “Thoát” | Step to quit OpenKey. “Thoát” is OpenKey's own menu label: keep it. |
| Continue | Tiếp tục | Onboarding button. |
| Couldn’t Install Dấu | Chưa cài được Dấu | Onboarding step 2 title after an install error. |
| Couldn’t read the input source shortcut. | Không đọc được phím tắt chuyển nguồn đầu vào. | Onboarding: the shortcut setting cannot be read. |
| Couldn’t Turn On Dấu | Chưa bật được Dấu | Banner and onboarding title: macOS kept Dấu off. |
| Current | Đang làm | VoiceOver value of the current onboarding step. |
| Current shortcut | Phím tắt hiện tại | VoiceOver label of the shortcut key caps. |
| Done | Đã xong | VoiceOver value of a finished onboarding step. |
| Dấu checks again when you come back to this window. | Dấu tự kiểm tra lại khi bạn quay về cửa sổ này. | Onboarding step 1 hint. |
| Dấu couldn’t copy its input method to this Mac, so it can’t be turned on yet. | Dấu không chép được bộ gõ vào máy, nên chưa bật được. | Onboarding step 2 subtitle after an install error. |
| Dấu doesn’t need Accessibility access. | Dấu không cần quyền Trợ năng. | Onboarding sidebar note. |
| Dấu Is On | Đã bật Dấu | Banner and onboarding title after Dấu was turned on. |
| Dấu isn’t the current input source: choose “%@” from the Input menu or press %@, then try typing. | Dấu chưa phải nguồn đầu vào đang dùng: chọn “%@” trên menu nguồn đầu vào hoặc nhấn %@ rồi gõ thử. | Onboarding typing step. First %@ = the input source name as macOS shows it, in the system's language (D41, SystemUINames.dauInputSource); second %@ = the shortcut, e.g. ⌃Space. |
| Dấu isn’t the current input source: choose “%@” from the Input menu, then try typing. | Dấu chưa phải nguồn đầu vào đang dùng: chọn “%@” trên menu nguồn đầu vào rồi gõ thử. | Onboarding typing step. %@ = the input source name as macOS shows it, in the system's language (D41, SystemUINames.dauInputSource). |
| Dấu will be added to your macOS input sources, next to the keyboard you use now. | Dấu sẽ được thêm vào nguồn đầu vào của macOS, cạnh bàn phím bạn đang dùng. | Onboarding step 2 subtitle. |
| Go Back | Quay lại | Onboarding button: previous step. |
| In Gõ Nhanh’s settings, turn off “Launch at login” | Trong cài đặt của Gõ Nhanh, tắt “Launch at login” | Step to stop Gõ Nhanh. The quoted name is Gõ Nhanh's own label: keep it. |
| In OpenKey’s “Bảng điều khiển…”, turn off “Khởi động cùng macOS” | Trong “Bảng điều khiển…” của OpenKey, tắt “Khởi động cùng macOS” | Step to stop OpenKey. Quoted names are OpenKey's own Vietnamese labels: keep them as they are. |
| In PHTV’s settings, turn off “Khởi động cùng macOS” | Trong cài đặt của PHTV, tắt “Khởi động cùng macOS” | Step to stop PHTV. The quoted name is PHTV's own label: keep it. |
| In XKey’s settings, turn off “Khởi động cùng hệ thống” | Trong cài đặt của XKey, tắt “Khởi động cùng hệ thống” | Step to stop XKey. The quoted name is XKey's own label: keep it. |
| macOS asks because an input method receives every key you type. Dấu’s input method has no network access. | macOS hỏi vì bộ gõ nhận mọi phím bạn gõ. Bộ gõ Dấu không có quyền dùng mạng. | Onboarding step 2 note. |
| macOS hasn’t added Dấu to your input sources. The dialog may not have appeared, or the request was declined. | macOS chưa thêm Dấu vào nguồn đầu vào. Có thể hộp thoại không hiện, hoặc yêu cầu đã bị từ chối. | Onboarding step 2 subtitle when Dấu is still off. |
| No other Vietnamese input method is running, so marks won’t be typed twice. | Không còn bộ gõ tiếng Việt nào khác đang chạy, nên dấu không bị gõ hai lần. | Onboarding step 1 subtitle after Go Back, when no other input method is running any more. |
| Not started | Chưa làm | VoiceOver value of a later onboarding step. |
| Once it’s on, you’ll see | Sau khi bật, bạn sẽ thấy | Onboarding step 2 card heading. |
| or | hoặc | Between the shortcut key caps and the Globe key. |
| Other Input Methods Turned Off | Đã tắt bộ gõ cũ | Onboarding step 1 title after Go Back, when no other input method is running any more. |
| Quit %@ | Thoát %@ | Step to quit another input method. %@ = app name. |
| Quit Gõ Nhanh | Thoát Gõ Nhanh | Step to quit Gõ Nhanh. |
| Quit PHTV | Thoát PHTV | Step to quit PHTV. |
| Running now: %@. When two input methods run at the same time, marks are added twice and the text comes out wrong. | %@ đang chạy. Khi hai bộ gõ cùng chạy, dấu bị thêm hai lần và chữ gõ ra bị sai. | Onboarding step 1 subtitle. %@ = list of app names, e.g. “OpenKey and XKey”. |
| Set Up Dấu | Thiết lập Dấu | Onboarding window title (not drawn; Window menu and VoiceOver). |
| Setup Guide… | Hướng dẫn thiết lập… | Help menu item that opens the setup (onboarding) window. |
| Setup steps | Các bước thiết lập | VoiceOver name of the onboarding step list. |
| Skip | Bỏ qua | Onboarding step 1 button. |
| So marks aren’t typed twice | Để dấu không bị gõ hai lần | Onboarding step 1 hint (sidebar). |
| Start Typing | Bắt đầu gõ | Onboarding final button: closes the window. |
| Step %lld: %@ | Bước %lld: %@ | VoiceOver label of an onboarding step. %lld = step number, %@ = step name. |
| The macOS shortcut to switch to an English keyboard | Phím tắt của macOS để chuyển sang bàn phím tiếng Anh | Next to the shortcut key caps. |
| The macOS shortcut to switch to “%@” for typing English | Phím tắt của macOS để chuyển sang “%@” khi gõ tiếng Anh | %@ = the English keyboard layout's name as macOS shows it, e.g. U.S. |
| There’s no shortcut yet to switch quickly to an English keyboard. | Chưa có phím tắt để chuyển nhanh sang bàn phím tiếng Anh. | Onboarding: no input source shortcut is set. |
| Try it right away | Gõ thử ngay | Onboarding step 3 hint (sidebar). |
| Try typing | Gõ thử | Onboarding step 3 card heading and the test field's name. |
| Try: %@ | Gợi ý: %@ | Hint under the test field. %@ = keys to type, e.g. tooi yeeu tieengs Vieetj. |
| Turn Off Other Input Methods | Tắt bộ gõ đang chạy | Onboarding step 1 title: another Vietnamese input method is running. |
| Turn On Dấu | Bật Dấu | Onboarding step 2 name, title and button. |
| Turned Off | Đã tắt | Chip on another input method that the user has quit (onboarding step 1). |
| Type here | Gõ ở đây | Placeholder of the test field. |
| Waiting for you to click %@ | Đang chờ bạn bấm %@ | Banner title and onboarding status. %@ = macOS's own Allow button name (D38). |
| When you click “Turn On Dấu” | Khi bạn bấm “Bật Dấu” | Onboarding step 2 card heading. “Turn On Dấu” = the button. |
| You can change this anytime in Dấu Settings. | Bạn có thể đổi bất cứ lúc nào trong Cài đặt Dấu. | Onboarding step 3 subtitle. “Dấu Settings” = the Settings window's name. |
| “%@” is now in your macOS input sources. | “%@” đã có trong nguồn đầu vào của macOS. | Onboarding step 2 subtitle. %@ = the input source name as macOS shows it, in the system's language (D41, SystemUINames.dauInputSource). |

### Banner (10)

| Tiếng Anh | Tiếng Việt | Ở đâu |
|---|---|---|
| Click Try Again, then %@, or add it yourself: %@ › %@ › + › %@ › Dấu. | Bấm Thử lại rồi %@, hoặc tự thêm: %@ › %@ › + › %@ › Dấu. | Banner subtitle. %@ in order: Allow; System Settings › Keyboard › Input Sources; Edit…; Vietnamese — all macOS's own names (D38). “Try Again” = the button. |
| Couldn’t reinstall. Uninstall Dấu, then install it again from a fresh download. | Chưa cài lại được. Hãy gỡ cài đặt Dấu rồi cài lại từ bản tải về. | Banner subtitle after Reinstall failed. |
| Dấu isn’t turned on in your input sources | Dấu chưa được bật trong nguồn đầu vào | Banner title: Dấu is not among the enabled input sources. |
| Dấu’s input method on this Mac has been changed | Bộ gõ Dấu trên máy đã bị thay đổi | Banner title: the installed input method is not the copy this app installs. |
| Hide | Ẩn | Banner button: hides the confirmation. |
| Reinstall | Cài lại | Banner button: installs the app's own copy of the input method. |
| The dialog is in the %@ window. Click %@ to turn on Dấu. | Hộp thoại nằm trong cửa sổ %@. Bấm %@ để bật Dấu. | Banner subtitle. First %@ = System Settings, second %@ = Allow, both macOS's own names (D38). |
| The input method was replaced or modified after it was installed. Reinstall to type with Dấu’s own copy. | Tệp bộ gõ đã bị thay hoặc sửa sau khi cài. Cài lại để gõ bằng đúng bản của Dấu. | Banner subtitle. |
| Turn On | Bật lại | Banner button: turns Dấu on again (macOS asks the user). |
| You can still change settings, but you can’t type Vietnamese yet. | Bạn vẫn chỉnh được cài đặt, nhưng chưa gõ được tiếng Việt. | Banner subtitle. |

### Gỡ cài đặt (18)

| Tiếng Anh | Tiếng Việt | Ở đâu |
|---|---|---|
| Also delete settings and app rules | Xoá cả cài đặt và quy tắc ứng dụng | Checkbox in the uninstall confirmation alert. |
| Cancel Uninstall | Huỷ gỡ cài đặt | Uninstall sheet cancel button. |
| Couldn’t Remove Dấu | Chưa gỡ được Dấu | Alert title when the uninstall failed. |
| Dấu’s input method was removed | Đã gỡ bộ gõ Dấu | Alert title after the uninstall. |
| macOS still lists Dấu among the input sources; you can remove it in %@. | macOS vẫn báo Dấu trong nguồn đầu vào; bạn có thể bỏ nó trong %@. | Uninstall result. %@ = System Settings › Keyboard › Input Sources (D38). |
| Once Dấu is gone from the list, the input method is moved to the %@. | Khi Dấu không còn trong danh sách, bộ gõ sẽ được chuyển vào %@. | Uninstall sheet status. %@ = Trash, macOS's own name (D38). |
| Only you can remove an input source from macOS. %@ has the %@ list open for you. | Chỉ bạn mới bỏ được một nguồn đầu vào khỏi macOS. %@ đã mở sẵn danh sách %@. | Uninstall sheet. First %@ = System Settings, second %@ = Input Sources (D38). |
| Quit Dấu | Thoát Dấu | Button of the uninstall result alert. |
| Remove Dấu from Input Sources | Bỏ Dấu khỏi nguồn đầu vào | Title of the uninstall sheet: the user removes Dấu in System Settings. |
| Remove Dấu from this Mac? | Gỡ Dấu khỏi máy? | Uninstall confirmation alert title. |
| Select **%@** in the list on the left, click **–**, then **%@**. | Chọn **%@** ở danh sách bên trái, bấm **–**, rồi **%@**. | Uninstall sheet step. First %@ = the input source name as macOS shows it, in the system's language (D41, SystemUINames.dauInputSource); second %@ = macOS's Done button (D38). |
| Settings and app rules were deleted. | Đã xoá cài đặt và quy tắc ứng dụng. | Uninstall result. |
| The input method was moved to the %@. | Bộ gõ đã được chuyển vào %@. | Uninstall result. %@ = Trash, macOS's own name (D38). |
| To remove the app too, drag Dấu from the %@ folder to the %@. | Muốn xoá cả ứng dụng, kéo Dấu trong thư mục %@ vào %@. | Uninstall result. First %@ = Applications, second %@ = Trash (D38). |
| Uninstall | Tiếp tục gỡ | Destructive button of the uninstall confirmation alert. |
| Uninstall… | Gỡ cài đặt… | Support button: starts the uninstall (D16). |
| You can remove “%@” in %@, then try again. | Bạn có thể bỏ “%@” trong %@, rồi thử lại. | Uninstall failed. First %@ = the input source name as macOS shows it, in the system's language (D41, SystemUINames.dauInputSource); second %@ = System Settings › Keyboard › Input Sources (D38). |
| You’re using Dấu. If the – button is dimmed, first choose another keyboard from the Input menu. | Bạn đang dùng Dấu. Nếu nút – bị mờ, chọn bàn phím khác trên menu nguồn đầu vào trước. | Uninstall sheet hint while Dấu is the selected input source. |

### Trang Gõ phím (15)

| Tiếng Anh | Tiếng Việt | Ở đâu |
|---|---|---|
| Classic | Kiểu cũ | Tone mark placement option: classic style (hòa, thúy). |
| Editing typed words | Sửa từ đã gõ | Smart Typing page section header. |
| Foreign words | Gõ lẫn từ nước ngoài | Smart Typing page section header: typing foreign words among Vietnamese. |
| Free mark placement | Bỏ dấu tự do | Typing page toggle: the mark keys can be typed anywhere after the vowel. |
| Input source shortcut | Phím tắt chuyển nguồn đầu vào | Typing page row label: macOS's shortcut to switch input sources. |
| Modern | Kiểu mới | Tone mark placement option: modern style (hoà, thuý). |
| Modern: hoà, thuý · Classic: hòa, thúy | Kiểu mới: hoà, thuý · Kiểu cũ: hòa, thúy | Subtitle of the tone mark placement row. Keep the Vietnamese example words as they are. |
| Preview | Xem trước | Typing page: heading of the card showing keys typed and the result. |
| Simple Telex | Telex đơn giản | Typing method name (D29): Telex without w as a vowel key. |
| Switch Vietnamese ↔ English | Chuyển tiếng Việt ↔ tiếng Anh | Typing page section header: the macOS shortcut that switches input sources. |
| Telex | Telex | Typing method name. |
| Tone mark placement | Vị trí dấu thanh | Typing page row label: where the tone mark goes in a syllable. |
| Type mark keys anywhere after the vowel | Gõ phím dấu ở bất kỳ đâu sau nguyên âm | Subtitle of the free mark placement toggle. |
| Typing method | Kiểu gõ | Typing page section header and label of the Telex / VNI / Simple Telex control. |
| VNI | VNI | Typing method name. |

### Trang Thông minh (16)

| Tiếng Anh | Tiếng Việt | Ở đâu |
|---|---|---|
| 2 options, 1 on | 2 tuỳ chọn, 1 đang bật | Summary of the collapsed Advanced group: one of the two options is on. |
| 2 options, both off | 2 tuỳ chọn, đang tắt | Summary of the collapsed Advanced group: both options are off. |
| A word that is also Vietnamese stays Vietnamese: “%@” gives “%@”. To keep the letters you typed, press the mark key twice: “%@” gives “%@”. | Từ trùng với tiếng Việt thì tiếng Việt được ưu tiên: “%@” ra “%@”. Muốn giữ chữ gốc, gõ đúp phím dấu: “%@” ra “%@”. | Smart Typing note. Each pair: keys typed, then the result (computed by the engine). |
| Add marks to typed words | Thêm dấu cho từ đã gõ | Smart Typing toggle (D20). |
| Advanced | Nâng cao | Smart Typing: collapsible group of advanced options. |
| Allow consonants z, f, w, j | Cho phép phụ âm z, f, w, j | Advanced toggle (D22, D23). |
| Collapse | Thu gọn | VoiceOver hint of the Advanced button while expanded. |
| Consonant shortcuts | Gõ tắt phụ âm | Advanced toggle (D21). |
| Expand | Mở rộng | VoiceOver hint of the Advanced button while collapsed. |
| For loanwords and names. Turning this on turns off Consonant shortcuts. | Dành cho từ mượn và tên riêng. Bật mục này sẽ tắt Gõ tắt phụ âm. | Subtitle of Allow consonants z, f, w, j (VNI, Simple Telex). |
| For loanwords and names. Turning this on turns off Consonant shortcuts. In Telex, w at the start of a word always becomes ư, so this only affects z, f, j. | Dành cho từ mượn và tên riêng. Bật mục này sẽ tắt Gõ tắt phụ âm. Với Telex, w ở đầu từ luôn thành ư nên mục này chỉ có tác dụng với z, f, j. | Subtitle of Allow consonants z, f, w, j while Telex is selected. |
| Put the cursor right after a word, then type a mark key. Not available in apps with an “Underline” rule. [Test results on Google Docs, Notion…] | Đặt con trỏ ngay sau từ rồi gõ phím dấu. Không áp dụng ở ứng dụng có quy tắc “Có gạch chân”. [Kết quả kiểm chứng trên Google Docs, Notion…] | Subtitle of the add-marks toggle. “Underline” = the app rule option of that name. The bracketed part is a placeholder until measured (N5). |
| Restore non-Vietnamese words | Tự khôi phục từ không phải tiếng Việt | Smart Typing toggle: words that are not Vietnamese go back to the keys typed (D4). |
| Smart Typing | Thông minh | Settings sidebar section and page title: automatic restore of foreign words, marks on typed words, advanced options. |
| When you finish a word (Space, punctuation, Return), a word that isn’t Vietnamese stays as you typed it | Khi gõ xong một từ (Space, dấu câu, Enter), từ không phải tiếng Việt được giữ nguyên như bạn gõ | Subtitle of the restore toggle. |
| Word start: f → ph, j → gi (VNI also w → qu) · Word end: g → ng, h → nh, k → ch. Applied when you finish a word, only if the result is a valid Vietnamese word. Turning this on turns off Allow consonants z, f, w, j. | Đầu từ: f → ph, j → gi (VNI thêm w → qu) · Cuối từ: g → ng, h → nh, k → ch. Áp dụng khi gõ xong từ, chỉ khi ra từ tiếng Việt hợp lệ. Bật mục này sẽ tắt Cho phép phụ âm z, f, w, j. | Subtitle of Consonant shortcuts. “Allow consonants z, f, w, j” = the other advanced toggle (D22). |

### Trang Ứng dụng (29)

| Tiếng Anh | Tiếng Việt | Ở đâu |
|---|---|---|
| Add | Thêm | Add-rule sheet confirm button. |
| Add App | Thêm ứng dụng | Apps page toolbar + button (label and tooltip). |
| Add App Rule | Thêm quy tắc cho ứng dụng | Title of the add-rule sheet. |
| App rules | Quy tắc riêng | Apps page section header: rules stored for single apps. |
| Apps | Ứng dụng | Settings sidebar section and page title; also the VoiceOver name of the app list in the add-rule sheet. |
| Apps labeled “Suggested” may type wrong text when you type very fast. Choose “Underline” only if an app garbles text as you type. | Ứng dụng có nhãn “Đề xuất” có thể gõ sai khi bạn gõ rất nhanh. Chỉ chọn “Có gạch chân” khi một ứng dụng bị lỗi chữ lúc gõ. | Description of the Suggested section. “Suggested” and “Underline” = the chip and the rule option of those names. |
| Change the option that remembers the input source for each window | Đổi tuỳ chọn nhớ nguồn đầu vào theo từng cửa sổ | VoiceOver label of the Change… button on the Apps page. |
| Change… | Đổi… | Button that opens System Settings to change a macOS option. |
| Choose | Chọn | Open panel confirm button when picking an app. |
| Choose an app that needs its own rule | Chọn ứng dụng cần quy tắc riêng | Open panel message when picking an app. |
| Choose Another App… | Chọn ứng dụng khác… | Add-rule sheet button: opens the open panel to pick an app. |
| Input source per window | Nguồn đầu vào theo cửa sổ | Apps page section header. |
| macOS option “%@” | Tuỳ chọn “%@” của macOS | Subtitle of that row. %@ = the macOS option's own name, in the system language (D38). |
| May type wrong text when you type very fast | Có thể sai chữ khi gõ rất nhanh | Subtitle of a suggested app. |
| No app rules yet. Click + to add one. | Chưa có quy tắc riêng. Bấm + để thêm. | Apps page: empty rule list. |
| No matching apps. | Không có ứng dụng nào khớp. | Apps page: the search matches no rule. |
| No Underline | Không gạch chân | App rule option: type in place, no underline (D5). |
| Off | Đang tắt | Value of a macOS option that is off. |
| On | Đang bật | Value of a macOS option that is on. |
| Remember the input source for each window | Nhớ nguồn đầu vào theo từng cửa sổ | Apps page row label: a macOS option shown read-only. |
| Remove Rule | Xoá quy tắc | Context menu item and VoiceOver action on an app rule. |
| Search Applications | Tìm trong Ứng dụng | Placeholder of the add-rule sheet's search field: searches the installed apps. |
| Search apps | Tìm ứng dụng | Placeholder of the Apps page toolbar search field. |
| Suggested | Đề xuất | Apps page section header and the chip on apps from the compatibility list (D13). |
| Turn On Underline | Bật gạch chân | Button on a suggested app: stores an underline rule (D13). |
| Turn on underline for %@ | Bật gạch chân cho %@ | VoiceOver label of Turn On Underline. %@ = app name. |
| Underline | Có gạch chân | App rule option: underline the word being typed (D13). |
| Underline while typing in %@ | Gạch chân khi gõ trong %@ | VoiceOver label of an app rule's menu. %@ = app name. |
| While typing | Khi đang gõ | Add-rule sheet: label of the underline choice. |

### Trang Cập nhật & hỗ trợ (17)

| Tiếng Anh | Tiếng Việt | Ở đâu |
|---|---|---|
| [Update check status] | [Trạng thái kiểm tra cập nhật] | Placeholder until updates exist (M7, N5). |
| Automatically check for updates | Tự động kiểm tra bản mới | Updates toggle (disabled until M7). |
| Automatically download and install | Tự động tải và cài | Updates toggle (disabled until M7). |
| Beta | Beta | Release channel option. |
| Check Now | Kiểm tra ngay | Updates: check for a new version (disabled until M7). |
| Go back to the previous version | Quay về bản trước | Support row label (disabled until M7). |
| Release channel | Kênh phát hành | Updates: Stable or Beta. |
| Remove Dấu from this Mac | Gỡ Dấu khỏi máy | Support row label (D16). |
| Report a Problem… | Báo lỗi… | Support button (disabled until M7). |
| Roll Back… | Quay về… | Support button (disabled until M7). |
| Send us a description so we can look into it | Gửi mô tả lỗi để chúng tôi kiểm tra | Subtitle of that row. |
| Stable | Ổn định | Release channel option. |
| Support | Hỗ trợ | Updates & Support page section header. |
| Typing goes wrong in an app? | Gặp ứng dụng gõ bị lỗi? | Support row label. |
| Updates | Cập nhật | Updates & Support page section header. |
| Use this when a new version causes problems | Dùng khi bản mới gây lỗi | Subtitle of that row. |
| Version | Phiên bản | Sidebar search keyword: the app version shown on Updates & Support. |

### Cửa sổ, menu, tìm kiếm (10)

| Tiếng Anh | Tiếng Việt | Ở đâu |
|---|---|---|
| Back | Lùi | Settings toolbar button and View menu item: previous page (⌘[). |
| Dấu never sends what you type off your Mac. The input method has no network access; only the updater connects, to download new versions and the app compatibility list. Open source under the GPLv3 license. | Dấu không gửi chữ bạn gõ ra khỏi máy. Bộ gõ không có quyền truy cập mạng; chỉ phần cập nhật kết nối để tải bản mới và danh sách ứng dụng tương thích. Mã nguồn mở theo giấy phép GPLv3. | Privacy note at the bottom of the page. Wording fixed by docs/UI.md (D8, N2): translate without adding or removing promises. |
| Dấu Settings | Cài đặt Dấu | Settings window title (Window menu, Mission Control). |
| Forward | Tiến | Settings toolbar button and View menu item: next page (⌘]). |
| Navigation | Điều hướng | VoiceOver name of the Back/Forward button group in the Settings toolbar. |
| Privacy | Quyền riêng tư | Sidebar search keyword for the privacy note. |
| Search | Tìm kiếm | Placeholder of the Settings sidebar search field. |
| Settings… | Cài đặt… | App menu item that opens the Settings window (⌘,). |
| Typing | Gõ phím | Settings sidebar section and page title. |
| Updates & Support | Cập nhật & hỗ trợ | Settings sidebar section and page title. |

### Lỗi (7)

| Tiếng Anh | Tiếng Việt | Ở đâu |
|---|---|---|
| Details | Chi tiết | Heading above the error text. |
| Dấu is still in the input sources. | Dấu vẫn còn trong nguồn đầu vào. | Error detail. |
| macOS reported an error while copying or registering the input method. | macOS báo lỗi khi chép hoặc đăng ký bộ gõ. | Error detail. |
| Something went wrong while copying or registering the input method. | Có lỗi khi chép hoặc đăng ký bộ gõ. | Error detail for any other error. |
| The input method hasn’t been copied to this Mac. | Bộ gõ chưa được chép vào máy. | Error detail. |
| The input method wasn’t found inside the Dấu app. | Không tìm thấy bộ gõ trong ứng dụng Dấu. | Error detail. |
| The input method’s signature isn’t valid, or it isn’t from the same developer as the app. | Chữ ký của bộ gõ không hợp lệ, hoặc không cùng nhà phát triển với ứng dụng. | Error detail. |

### Bộ gõ (menu nguồn đầu vào) (5)

| Tiếng Anh | Tiếng Việt | Ở đâu |
|---|---|---|
| Dấu Settings… | Cài đặt Dấu… | Input menu: opens the Dấu app (Settings window). |
| Dấu – Vietnamese | Dấu – Tiếng Việt | Input mode name shown in the input source menu (D24, D41). Key = mode ID in Info.plist. |
| Simple Telex | Telex đơn giản | Input menu: typing method name (D29). |
| Telex | Telex | Input menu: typing method name. |
| VNI | VNI | Input menu: typing method name. |

### Dùng ở nhiều màn (25)

| Tiếng Anh | Tiếng Việt | Ở đâu |
|---|---|---|
| %@ becomes %@ | %@ thành %@ | VoiceOver label of a typing example. First %@ = keys typed, second %@ = resulting text. |
| %@ will close, reopen and ask whether to turn on Dấu. Click **%@**. | %@ sẽ đóng rồi mở lại và hỏi bạn có cho Dấu bật không. Bấm **%@**. | First %@ = System Settings, second %@ = Allow, macOS's own names (D38). |
| [How updates install — to be verified in M7] | [Cách cài bản mới — kiểm chứng ở M7] | Placeholder until measured (N5). |
| [System shortcut] | [Phím tắt hệ thống] | Placeholder shown when the system shortcut cannot be read (N5). |
| Cancel | Huỷ | Cancel button. |
| Choose Dấu from the Input menu. | Chọn Dấu trên menu nguồn đầu vào. | How to start typing with Dấu. Input menu = the input source menu in the menu bar. |
| Click **Try Again**, then click **%@** when %@ asks. | Bấm **Thử lại**, rồi bấm **%@** khi %@ hỏi. | First %@ = Allow, second %@ = System Settings (D38). |
| Continue while the other input method is still running | Tiếp tục khi bộ gõ cũ vẫn đang chạy | VoiceOver hint of Skip. |
| Don’t see the dialog, or chose %@? Click Try Again. | Không thấy hộp thoại, hoặc đã chọn %@? Bấm Thử lại. | %@ = macOS's Don’t Allow button (D38). “Try Again” = the button. |
| If an app can’t select Dấu yet, log out (%@ › %@) and log back in once. | Nếu một ứng dụng chưa chọn được Dấu, hãy đăng xuất (%@ › %@) rồi đăng nhập lại một lần. | First %@ = the Apple menu symbol, second %@ = macOS's Log Out item (D38). |
| If Dấu isn’t in that list, log out and log back in once (Apple menu › **%@**), then open Dấu again. | Không thấy Dấu trong danh sách đó: đăng xuất rồi đăng nhập lại một lần (menu Apple › **%@**), rồi mở lại Dấu. | %@ = macOS's Log Out item (D38). |
| If it still fails, download Dấu again, drag it to the **%@** folder, then open it again. | Nếu vẫn lỗi, tải lại Dấu, kéo vào thư mục **%@**, rồi mở lại. | %@ = Applications, macOS's own name (D38). |
| In %@, turn off %@ | Trong %@, tắt %@ | Step. First %@ = System Settings › General › Login Items & Extensions (D38), second %@ = app name. |
| New | Mới | Badge next to a new feature. |
| OK | OK | Alert button. |
| Open %@ | Mở %@ | Button or VoiceOver hint. %@ = macOS's own name of System Settings, in the system language (D38). |
| Or add it yourself: %@ › **%@** › **+** › %@ › **Dấu**, then click **%@**. | Hoặc tự thêm: %@ › **%@** › **+** › %@ › **Dấu**, rồi bấm **%@**. | %@ in order: System Settings › Keyboard › Input Sources; Edit…; Vietnamese; Add — macOS's own names (D38). |
| Other Vietnamese input sources are on: %@. You can remove some in %@ to keep the list short. | Đang bật nguồn đầu vào tiếng Việt khác: %@. Bạn có thể bỏ bớt trong %@ cho gọn danh sách. | First %@ = quoted input source names, second %@ = System Settings › Keyboard › Input Sources (D38). |
| Running | Đang chạy | Chip on another input method that is running. |
| Set a Shortcut in %@ | Đặt phím tắt trong %@ | Button. %@ = System Settings (D38). |
| Step %lld | Bước %lld | VoiceOver label of a numbered step. %lld = step number. |
| The dialog is in the %@ window. Click **%@** and Dấu moves on to the next step. | Hộp thoại nằm trong cửa sổ %@. Bấm **%@**, Dấu tự sang bước tiếp theo. | First %@ = System Settings, second %@ = Allow (D38). |
| Try Again | Thử lại | Button: asks macOS again. |
| Uses the macOS shortcut; change it in %@ | Dùng chung phím tắt của macOS, đổi trong %@ | Subtitle of the shortcut row. %@ = macOS path, e.g. System Settings › Keyboard (D38). |
| You’ll remove Dấu from %@ in %@; then Dấu is moved to the %@. | Bạn sẽ bỏ Dấu khỏi %@ trong %@; sau đó Dấu được chuyển vào %@. | Alert text. %@ in order: Input Sources, System Settings, Trash — macOS's own names (D38). |
