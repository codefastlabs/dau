# Ghi chú API InputMethodKit

Những gì tài liệu và header chính thức của Apple nói về các API mà bộ gõ của Dấu dùng (`Apps/DauInputMethod`), và hệ quả cho các quyết định. Chỉ ghi điều có nguồn; chỗ suy luận ghi rõ.

## Hiện trạng (17/11/2026)

- Header đọc trong Xcode 27.1, SDK `MacOSX27.0.sdk`, lúc làm M2 (Bộ gõ tối thiểu) và M3 (Độ tin cậy); chưa đọc lại trên SDK mới hơn. Chuyển nguyên từ `docs/research/OpenKeyNotes.md` ngày 11/11/2026 vì không thuộc OpenKey.
- Hệ quả chính:
  - Tham số của IMK có thể nil, và `NSEvent.characters` ném ngoại lệ trên sự kiện không phải phím: cơ sở của D18 (Phòng thủ với IMK).
  - Ứng dụng không hỗ trợ TSMDocumentAccess bỏ qua `replacementRange` và trả `NSNotFound` cho `selectedRange()`: ở đó thay chữ tại chỗ không thể đúng, cần marked text (D13 (Gạch chân là đường lui cuối cùng)).
  - Phạm vi tính theo UTF-16; chữ đọc từ ứng dụng ở dạng NFD được tính đúng khi thay.
  - Bộ gõ có sandbox mà không có ngoại lệ `temporary-exception.mach-register.global-name` thì không đăng ký được tên kết nối (`InputMethodConnectionName`), nhưng vẫn đưa endpoint XPC cho `imklaunchagent`; trên macOS 27.2 app nối vào Dấu qua endpoint đó. Dấu giữ ngoại lệ: bỏ nó không giúp notarize, và gõ được hay không khi bỏ thì chưa kiểm, nhất là trên macOS 14–26 (mục "Kết nối của IMKServer và sandbox").
- Chưa đo: `overrideKeyboard(withKeyboardNamed:)` và bố cục không phải QWERTY.

## API

- `IMKServerInput.handle(_:client:)`: tham số `NSEvent!` và `Any!` (kiểu tự mở có thể nil).
  - Trả `true` nếu đã xử lý sự kiện, `false` để hệ thống xử lý.
  - Phương thức nhận cả sự kiện phím xuống lẫn chuột, nên chuột là tín hiệu reset (D11 (Kiểm tra ngữ cảnh)).
  - Tham số có thể nil cũng là cơ sở cho D18 (Phòng thủ với IMK).
  - https://developer.apple.com/documentation/objectivec/nsobject-swift.class/handle(_:client:) và https://developer.apple.com/documentation/inputmethodkit/imkserverinput
- `NSEvent.characters` **ném `NSInternalInconsistencyException`** nếu đọc trên sự kiện không phải phím.
  - Với phím chết (dead key, ví dụ ⌥e) nó là chuỗi rỗng.
  - Phải kiểm tra loại sự kiện trước khi đọc (D18).
  - https://developer.apple.com/documentation/appkit/nsevent/characters
- `NSEvent.keyCode` là mã phím ảo, không phụ thuộc phần cứng. Còn `characters` được suy ra từ bảng ánh xạ bàn phím. Dấu dùng ký tự thay cho mã phím để tránh lỗi B17 của OpenKey ([`docs/research/OpenKeyNotes.md`](OpenKeyNotes.md) mục 3). https://developer.apple.com/documentation/appkit/nsevent/keycode
- `IMKTextInput` (header `HIToolbox.framework/Headers/IMKInputSession.h`; trang tài liệu web của protocol này trả 404 khi tra):
  - `insertText(_:replacementRange:)`: `replacementRange` tính từ đầu tài liệu của client. Truyền `NSNotFound` thì chèn tại vùng chọn hiện tại.
    - **Nếu client không hỗ trợ TSMDocumentAccess thì `replacementRange` bị bỏ qua.**
    - Đây là dữ kiện trực tiếp cho câu hỏi vị trí thay chữ (hỏi con trỏ ở mỗi phím hay tự cộng dồn vị trí; đã chốt hỏi ở mỗi phím, D11) và cho D13: ở các ứng dụng như vậy, thay chữ tại chỗ không thể đúng, cần marked text.
  - `selectedRange()` trả `{NSNotFound, NSNotFound}` nếu client không hỗ trợ TSMDocumentAccess.
  - `attributedSubstring(from:)` có thể trả chuỗi dài hơn hoặc ngắn hơn phạm vi yêu cầu khi phạm vi cắt ngang một cặp surrogate. "Thêm dấu cho từ đã gõ" (D20 (Thêm dấu cho từ đã gõ)) phải kiểm tra độ dài.
  - `setMarkedText(_:selectionRange:replacementRange:)`: chuỗi thường sẽ có gạch chân mặc định (D13).
  - `overrideKeyboard(withKeyboardNamed:)`: input method có thể chỉ định bố cục bàn phím dùng để dịch phím, và "nên gọi mỗi lần được kích hoạt".
    - Chưa đo: nếu không gọi thì ký tự Dấu nhận được theo bố cục nào, và người dùng Dvorak gõ Telex ra sao.
- `IMKStateSetting.recognizedEvents(_:)` quyết định loại sự kiện bộ gõ nhận được. Nếu cần biết Shift/Caps riêng thì phải xét mask này (suy luận). https://developer.apple.com/documentation/inputmethodkit/imkstatesetting
- `NSTextInputClient.insertText(_:replacementRange:)` (phía ứng dụng): "chỉ phù hợp cho văn bản do người dùng gõ" và yêu cầu view cho phép sửa. https://developer.apple.com/documentation/appkit/nstextinputclient/inserttext(_:replacementrange:)
- Phạm vi `NSRange` tính theo đơn vị UTF-16.
  - Chữ Việt dựng sẵn (NFC) đều nằm trong BMP nên một chữ = một đơn vị.
  - Nhưng nếu ứng dụng lưu chữ ở dạng tổ hợp (NFD) thì số đơn vị khác số chữ, và `deleteCount` của engine phải đổi cho đúng. Đã xử lý: chữ đọc từ ứng dụng ở dạng NFD được tính đúng khi thay (test `SeedTests`).

## Kết nối của IMKServer và sandbox

Câu hỏi (M7 bước 1c): bộ gõ có sandbox có cần ngoại lệ `com.apple.security.temporary-exception.mach-register.global-name` cho tên trong `InputMethodConnectionName` không. Đo ngày 17/11/2026 trên máy M1 (M1 Pro), macOS 27.2.

**Kết luận:**

- Không có ngoại lệ thì `IMKServer` không đăng ký được tên kết nối: ngoại lệ là đường duy nhất sandbox cho phép tên `<bundle ID>_Connection` (mục 1, 2 bên dưới).
- Trên macOS 27.2, app không nối vào Dấu qua tên đó mà qua endpoint XPC mà `IMKServer` gửi cho `imklaunchagent` (mục 5), và `IMKServer` vẫn gửi endpoint khi đăng ký tên hỏng (mục 4). Vì vậy bỏ ngoại lệ có thể vẫn gõ được trên 27.2. [Suy luận]
- Chưa biết: hệ thống còn tra tên ở bước nào khác không (lúc chạy bộ gõ, lúc nối lại sau khi bộ gõ thoát), và macOS 14–26 (D1 (Nền tảng)) có đi đường XPC không. Chỉ gõ thật trả lời được: trên 27.2 ở bước 3 của kế hoạch M7; các bản cũ hơn khi có máy.
- Không tìm thấy tài liệu Apple nói IMK cần hay không cần ngoại lệ này. Trang Temporary Exception Entitlements chỉ nói: với App Sandbox, đăng ký động một dịch vụ Mach toàn cục thất bại trừ khi khai ngoại lệ này; trang không nhắc bộ gõ, và chỉ App Store đòi giải trình ngoại lệ (notarize không xét, [`docs/research/InputMethodInstall.md`](InputMethodInstall.md) mục 7). [Apple]
- Bỏ ngoại lệ không giúp notarize; nó chỉ bớt một tên Mach mà bộ gõ được đăng ký. Đổi lại, mỗi lần bộ gõ khởi chạy có một lần sandbox từ chối và một dòng log "*Failed* to register NSConnection name" của IMK.
- **Dấu giữ ngoại lệ** (phiên chính chốt 17/11/2026): bỏ không được gì, còn rủi ro trên các bản macOS chưa kiểm được thì có; mọi bộ gõ mã nguồn mở có sandbox gặp được đều giữ.

**Bằng chứng:**

1. Luật sandbox của hệ thống [Máy/hệ thống]: `/System/Library/Sandbox/Profiles/application.sb` cho app có sandbox đăng ký tên Mach toàn cục khi tên đúng bằng bundle ID hoặc `<bundle ID>.ServiceProvider`, khi tên bắt đầu bằng `<App Group>.`, khi là app của Apple (`com.apple.`), hoặc khi tên nằm trong ngoại lệ. `<bundle ID>_Connection` chỉ thuộc trường hợp cuối. Cũng profile đó cho mọi app có sandbox tra `com.apple.inputmethodkit.setxpcendpoint` và `com.apple.inputmethodkit.getxpcendpoint`.
2. Hỏi sandbox của bộ gõ Dấu đang chạy (bản Release, có ngoại lệ) bằng `sandbox_check`, một hàm chỉ hỏi kernel, không tác động lên tiến trình [Máy/Dấu]:
   - `mach-register`: `…inputmethod.Dau_Connection` được (nhờ ngoại lệ); `…inputmethod.Dau` và `…inputmethod.Dau.ServiceProvider` được; một tên dưới App Group được; `…inputmethod.Dau_Probe1c` và tên lạ bị chặn.
   - `mach-lookup`: `com.apple.inputmethodkit.setxpcendpoint` được; `com.apple.tsm.portname` bị chặn, khớp lần đo 30/10/2026 ([`docs/research/InputMethodInstall.md`](InputMethodInstall.md) mục 7).
   - Tra từ tiến trình không sandbox: tên `…inputmethod.Dau_Connection` đang được đăng ký.
3. Mã IMK [Máy/hệ thống: chuỗi trong dyld shared cache và trong `imklaunchagent`; suy luận từ tên hàm và câu log]:
   - Bộ gõ bên thứ ba chạy lớp `_IMKServerLegacy` (bản thử ở mục 4 in ra lớp này).
   - Lúc tạo, nó đăng ký tên kết nối với bootstrap (`NSMachBootstrapServer`). Khi app khởi chạy xong, nó gửi endpoint của một listener XPC ẩn danh cho `imklaunchagent` (`setIMKXPCEndpoint:forBundleIdentifier:`).
   - `imklaunchagent` giữ endpoint theo bundle ID, từ chối bên gửi có signing ID không khớp, và trả endpoint cho app hỏi theo bundle ID (`getIMKXPCEndpointForBundle`).
4. Bản thử [Bản thử, không phải Dấu]: app nhỏ không sandbox, `LSBackgroundOnly`, bundle ID không chứa `.inputmethod.`, không nằm trong thư mục Input Methods; chỉ tạo `IMKServer` như `main.swift` của Dấu rồi chạy `NSApplication` 5 giây.
   - Đối chứng: tên được đăng ký; `imklaunchagent` log "Received setIMKXPCEndpoint:forBundleIdentifier: from InputMethod".
   - Một tiến trình khác giữ tên trước: IMK log "could not register" và "*Failed* to register NSConnection name"; `IMKServer` vẫn trả đối tượng; `imklaunchagent` vẫn nhận endpoint.
   - Chứng minh được: đăng ký tên hỏng không chặn bước gửi endpoint. Không chứng minh được: hỏng vì sandbox chặn đi cùng nhánh với hỏng vì trùng tên (suy luận: cùng một lời gọi đăng ký trả về thất bại); app gõ được qua bộ gõ đó (bản thử không phải nguồn đầu vào).
   - Không chạy bản thử có sandbox: app có sandbox tạo container trong `~/Library/Containers` mà shell không xoá được ([`docs/history/LogM5.md`](../history/LogM5.md)), còn bản thử mang bundle ID của Dấu sẽ đè endpoint của bộ gõ đang chạy.
5. Dấu thật đang chạy (bản Release có ngoại lệ) [Máy/Dấu, log hệ thống, chỉ đọc]: lúc khởi chạy, Dấu gửi endpoint cho `imklaunchagent`. Trong 1 giờ 40 phút sau đó, 54 kết nối từ 15 tiến trình (Claude, VS Code, Chrome, Telegram, Finder, Sublime Text, System Settings, Control Center…) đều vào cùng một listener XPC ẩn danh: listener Dấu tạo đầu tiên, lúc khởi tạo `IMKServer`. Listener đó là endpoint đã gửi cho `imklaunchagent` là suy luận (log không ghi endpoint nào thuộc listener nào).
6. Dự án khác [Ngoài]:
   - Các bộ gõ mã nguồn mở có sandbox gặp khi tìm mã trên GitHub (vChewing, macSKK, azooKey, Jyutping, TypeDuck…) đều khai ngoại lệ với `$(PRODUCT_BUNDLE_IDENTIFIER)_Connection`; không gặp dự án có sandbox nào bỏ nó.
   - Hướng dẫn 2026 của tác giả vChewing: tên kết nối phải là `$(PRODUCT_BUNDLE_IDENTIFIER)_Connection` và khai trong ngoại lệ; sai thì bộ gõ có sandbox có thể không nạp được, Console có log về NSConnection. Bài không nói đã thử bỏ ngoại lệ.
   - Bản thử của OctoDot (`spikes/01-ime-host/sandbox-test.sh`) có đối chứng âm: chỉ sandbox, không ngoại lệ, thì tên không được đăng ký. Không kiểm gõ.

Nguồn:
- Apple, App Sandbox Temporary Exception Entitlements: https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/EntitlementKeyReference/Chapters/AppSandboxTemporaryExceptionEntitlements.html
- vChewing, macOS Input Method Development Guidelines 2026: https://github.com/ShikiSuen/ShikiSuen/blob/main/TechNotes/macOS_Input_Method_Development_Guidelines_2026/macOS_Input_Method_Development_Guidelines_2026-ENU.md
- OctoDot, `sandbox-test.sh`: https://github.com/n19htfall/OctoDot/blob/main/spikes/01-ime-host/sandbox-test.sh
- Log của lượt đo không nằm trong repo (CLAUDE.md, "Repo là công khai"). Cách dựng lại: hỏi sandbox bằng `sandbox_check(pid, "mach-register", SANDBOX_FILTER_GLOBAL_NAME | SANDBOX_CHECK_NO_REPORT, tên)`; tra tên bằng `bootstrap_look_up`; xem endpoint bằng `log stream --predicate 'process == "imklaunchagent"'`.
