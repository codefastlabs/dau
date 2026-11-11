# Cài, bật, nâng cấp, gỡ bộ gõ; phát hiện bộ gõ cũ

Nghiên cứu cho M5 (Onboarding, cài đặt, gỡ cài đặt) và D37 (Cài đặt bộ gõ): macOS làm gì khi một app cài, bật, thay và gỡ một bộ gõ InputMethodKit bên thứ ba. Mã làm theo kết luận ở đây: `SystemInputMethodInstaller` (`Apps/Dau/Sources/InputMethodInstaller.swift`), `InputMethodLifecycle` (`Packages/DauShared`). Các vòng thử theo giờ, kế hoạch đã bỏ và bản trước của file này: `docs/history/RESEARCH-LOG.md` mục 1.

## Hiện trạng (11/11/2026, macOS 27.2)

Apple không có tài liệu công khai cho các hành vi dưới đây, nên mọi kết luận có thể đổi theo bản macOS. Đo trên máy phát triển, macOS 27.2 (26B123), tài khoản đã từng cài Dấu; chưa đo macOS 14–26, bản ký Developer ID, tài khoản macOS mới.

- **Bật lần đầu không cần đăng xuất** nếu làm theo D37: xoá bộ đệm danh sách nguồn của mọi app ngay trước khi đăng ký, thoát System Settings, bật mục cha, người dùng bấm "Allow" (Dấu thật, 04/11/2026; mục 1). Apple DTS (06/2026) nói không tránh được đăng xuất; điều đó đúng khi không xoá bộ đệm.
- **Hộp thoại `Allow “Dấu” to enable “Dấu”?`** hiện khi System Settings phải dựng mới trang Keyboard và đọc được Dấu trong bộ đệm của nó. Trang Keyboard đang mở sẵn thì yêu cầu bị bỏ qua im lặng, và `TISEnableInputSource` vẫn trả 0 (mục 2).
- **Mỗi app có sandbox giữ bộ đệm danh sách nguồn riêng** và dùng mãi, kể cả khi mở lại app. Bộ đệm dựng trước khi có Dấu làm app đó không chọn được Dấu (Telegram). Xoá trước khi đăng ký sửa được khi app đang chạy; đăng xuất rồi đăng nhập cũng sửa được (mục 3).
- **"Đã bật"** là có mục trong `com.apple.inputsources` › `AppleEnabledThirdPartyInputSources`; cờ enabled của TIS không đáng tin (mục 4).
- **Gỡ:** app không tự tắt được Dấu (macOS chặn ghi `com.apple.inputsources` với mọi tiến trình trừ System Settings). Chỉ nút "–" của System Settings gỡ được; nút này bấm được cả khi Dấu đang được chọn, và macOS tự chuyển sang U.S. Xoá bộ gõ trước khi bấm "–" để lại mục ẩn; cài lại cùng ID rồi bấm "–" thì dọn được (bản thử) (mục 5).
- **Nâng cấp:** app chủ thay bộ gõ cùng ID bằng một lần đổi chỗ, nhờ bộ gõ cũ tự thoát; không đụng tiến trình hay bộ đệm hệ thống (mục 6).
- **App chủ không sandbox** (D37): app có sandbox không gỡ được quarantine khỏi file nó chép và không dừng được app khác (mục 7).
- Bộ gõ tiếng Việt cũ cần phát hiện ở bước 1 của onboarding: mục 8. Bộ gõ khác cài và bật thế nào: mục 9.
- **Còn mở** (mục 10): các bản macOS khác và bản Developer ID; vì sao System Settings có lúc không dựng lại được nguồn; luật `.inputmethod.` trong bundle ID; bộ gõ notarize mang quarantine; mục ẩn sau đăng xuất; vì sao một dự án khác ghi được `com.apple.inputsources`; bộ đệm riêng của app sau khởi động lại máy, trong thư mục được bảo vệ và sau khi gỡ.

### Nhãn nguồn

Mỗi khẳng định ở thân bài mang một nhãn. Chỗ không có nguồn ghi "không tìm thấy nguồn".

| Nhãn | Nghĩa |
|---|---|
| **[Apple]** | tài liệu, header SDK, ghi chú phát hành, diễn đàn Apple (kể cả DTS) |
| **[Ngoài]** | dự án hoặc diễn đàn khác: báo cáo, PR, README, mã nguồn |
| **[Máy/hệ thống]** | đọc file hệ thống hoặc nhật ký trên máy phát triển |
| **[Máy/Dấu]** | đo bằng Dấu thật |
| **[Máy/bản thử]** | đo bằng bản thử (bản sao bộ gõ của Dấu đổi bundle ID, tên `DauProbe…`), **không phải Dấu**; chỉ dùng khi chưa có phép đo bằng Dấu, không rút kết luận riêng về Dấu |
| **[Diễn giải mã máy]** | người nghiên cứu đọc mã máy và tự diễn giải; không có tài liệu Apple xác nhận |
| **[Suy luận, cần kiểm chứng]** | chưa ai đo |

Mọi việc đọc hệ thống ở đây chỉ đọc (`strings`, `nm`, `otool`, `dyld_info`, `codesign -d`, `defaults read`, `/usr/bin/log show`, `launchctl print`). Công cụ của vòng thử bằng bản thử đã xoá khỏi repo ngày 09/11/2026; lấy lại bằng `git show 7877c92:scripts/probe/<file>`.

## 1. Bật lần đầu không đăng xuất

### 1.1 Kết quả

Trên macOS 27.2, nút "Bật Dấu" làm "+" của System Settings, menu nhập liệu và các app thấy Dấu mà không cần đăng xuất. [Máy/Dấu, 04/11/2026]

Cách app làm (`SystemInputMethodInstaller.enable()`, theo D37):
1. Xoá `com.apple.IntlDataCache.le*` trong mọi thư mục con của `$(getconf DARWIN_USER_CACHE_DIR)` (bộ đệm của System Settings và của từng app; mục 3), ngay trước khi đăng ký. Thư mục nào hệ thống không cho đọc thì bỏ qua.
2. `TISRegisterInputSource` cho bộ gõ đã chép (luôn gọi; vô hại).
3. Nếu `com.apple.inputsources` đã có Dấu thì xong. Nếu chưa: thoát System Settings (yêu cầu thoát, không ép), rồi `TISEnableInputSource` cho **mục cha** `com.codefastlabs.dau.inputmethod.Dau` (chỉ mục cha; macOS ghi cả mục cha lẫn mode `….Dau.vi`).
4. Chờ mục của Dấu xuất hiện trong `com.apple.inputsources` (người dùng cần thời gian đọc hộp thoại và bấm "Allow"). Mã trả về của `TISEnableInputSource` không chứng minh gì (N5 (Chỉ hứa điều đã kiểm chứng)).
5. Đã bật thì quét lại một lượt: bộ đệm nào vẫn không có `DauInputMethod.app` (app dựng lại trong khoảng giữa lúc xoá và lúc đăng ký) thì xoá rồi đăng ký lại một lần.

App không chọn Dấu làm nguồn hiện hành; người dùng chuyển bằng phím tắt của hệ thống. Không có Hoàn tác vì app không tự tắt được Dấu (mục 5).

### 1.2 Giới hạn

- Chỉ đo trên macOS 27.2, bản Debug, tài khoản đã từng cài Dấu. Chưa đo macOS 14–26, bản ký Developer ID đã notarize. Lần thử trên tài khoản macOS mới đã bỏ (04/11/2026).
- Hành vi bộ đệm không có tài liệu Apple. Đường lui (D37): đọc lại không thấy Dấu thì hướng dẫn tự thêm bằng "+", và nếu "+" không có Dấu thì đăng xuất một lần.

### 1.3 Bằng chứng bằng Dấu thật [Máy/Dấu]

- **04/11/2026, bản đầu của luồng D37** (Debug `83baa29`, `com.apple.inputsources` không có mục nào của Dấu): chép, đăng ký (0), xoá hai file `IntlDataCache.le*` của System Settings, thoát System Settings, bật mục cha (0). System Settings nhận yêu cầu sau 1,2 s; hộp thoại `Allow “Dấu” to enable “Dấu”?` hiện, người dùng bấm "Allow"; macOS ghi mục cha và mode sau 4 s. Bộ gõ chạy, menu nhập liệu có "Dấu – Tiếng Việt", gõ "vieetj" ra "việt". Không đăng xuất.
- **04/11/2026, luồng hiện hành** (xoá bộ đệm của mọi app trước khi đăng ký, quét lại sau khi bật; ca Telegram ở mục 3): hộp thoại hiện, macOS ghi mục sau 3 s, lượt quét lại không thấy bộ đệm nào thiếu Dấu.
- **02/11/2026, trước D37** (Release `22948d9`, không xoá bộ đệm): "Bật Dấu" chép, đăng ký (0), bật mục cha (0); "+" và menu không có Dấu; System Settings ghi "Invalid value on inputSourceToBeEnabled" 0,8 s sau lệnh bật (mục 2.2). Sau một lần đăng xuất, Dấu có sẵn. Máy lúc đó còn hai mục Dấu từ 30/10 trong `com.apple.inputsources`, nên lần này chỉ phù hợp với "phải đăng xuất khi không xoá bộ đệm", không phải phép đo trên máy sạch.

### 1.4 Bằng chứng bằng bản thử [Máy/bản thử, 04/11/2026]

Mỗi bản thử một bundle ID mới, chép vào `~/Library/Input Methods`, trạng thái đọc bằng TIS từ một tiến trình mới, "+" do người dùng xem.
- Chỉ đăng ký, hoặc đăng ký rồi bật (trong một tiến trình hay ba tiến trình như Squirrel): TIS liệt kê ngay, nhưng "+" không có và `com.apple.inputsources` rỗng.
- Thoát System Settings mà không xoá bộ đệm: bộ đệm không được dựng lại, "+" không có.
- Xoá `IntlDataCache.le*` của System Settings (System Settings đang mở hay không): mở lại Keyboard thì bộ đệm dựng lại và "+" có mọi bản thử đã đăng ký.
- Xoá bộ đệm rồi bật mục cha từ một app có tên: hộp thoại hiện, bấm "Allow" thì `com.apple.inputsources` có cả mục cha và mode.

### 1.5 Nguồn ngoài

Phía "phải đăng xuất":
- Apple DTS (06/2026, FB23026482): "without the user logging off the system, System Settings doesn't pick up a new input source any more. I don't see anything that can avoid the logoff." Thread không nêu hàm TIS, hộp thoại hay cách thay thế. [Apple, diễn đàn 775526]
- msime (macOS 27.0, 27.0.1): ID chưa có lúc bắt đầu phiên đăng nhập thì không vào danh sách trong phiên đó; khởi động lại `imklaunchagent`, `TextInputMenuAgent`, `TextInputSwitcher`, `keyboardservicesd` hay `lsregister` không giúp. Xoá bộ đệm `IntlDataCache` của System Settings chỉ giúp **mode mới của ID đã biết**; họ giữ thông báo đăng xuất cho ID mới. [Ngoài; PR #2492, #3738]
- low-talker (macOS 15.0.1): bundle chép giữa phiên đăng ký được nhưng chỉ bật được sau lần đăng nhập sau. [Ngoài]
- README hoặc trình cài của Squirrel (`RequireLogout`), macSKK, Gureum, fcitx5-macos (lần cài đầu), XKey, AquaSKK bảo đăng xuất. Tracker Squirrel (macOS 15.6–26.2) và XKey (macOS 26.1, #75): người bảo trì bảo thêm tay bằng "+" hoặc đăng xuất. [Ngoài]

Phía "hiện ngay":
- marinaMoji (máy ảo sạch macOS 27.0.1, `.pkg` vào `/Library/Input Methods`): `TISRegisterInputSource` 0, `TISEnableInputSource` 0 nhưng cha vẫn `enabled=0`; nguồn **hiện ngay trong "+"**, người dùng tự thêm, không đăng xuất. [Ngoài, issue #66]
- Header: đăng ký "so that a TISInputSourceRef can immediately be obtained" (tài liệu 2006–2008). [Apple]
- McBopomofo không đòi đăng xuất ở lần cài đầu; vChewing dừng `TextInputMenuAgent` rồi chờ 0,5 s để khỏi đăng xuất. Cả hai không có số đo trên macOS 27; msime đo thấy cách của vChewing không giúp ID mới trên 27.0. [Ngoài, mã]

Chưa tách được vì sao marinaMoji hiện ngay trong khi Squirrel, macSKK, fcitx5, Gureum cùng cài ở `/Library/Input Methods` vẫn bảo đăng xuất. [Suy luận, cần kiểm chứng]

### 1.6 Cơ chế (giả thuyết)

- "+" và việc dựng hộp thoại đọc danh sách nguồn từ bộ đệm `IntlDataCache` của System Settings; bộ đệm không làm mới khi có nguồn mới đăng ký, chỉ khi đăng nhập hoặc khi file bị xoá. Lời của DTS phù hợp với điều này. [Suy luận, cần kiểm chứng]
- Quan sát phù hợp, 02/11/2026: bộ đệm của System Settings có giờ ghi 17 s sau khi `TextInputMenuAgent` khởi động lúc đăng nhập; `TextInputMenuAgent`, `TextInputSwitcher`, `imklaunchagent` là LaunchAgent của phiên. [Máy/hệ thống]
- `HIToolbox` có nhật ký "InputSourceFSEventCallback -> TISUpdateIntlFileCache" và danh sách thư mục được theo dõi (`~/Library/Input Methods/`, `/Library/Input Methods/`…): thư viện tự dựng lại danh mục khi các thư mục này đổi. Việc đó có tới tiến trình System Settings không: không tìm thấy nguồn (DTS nói không). [Diễn giải mã máy]

### 1.7 Header và tài liệu Apple

Apple không có trang web cho họ hàm TIS (các URL đoán trả 404 ngày 03/11/2026). Nguồn chính thức duy nhất là `TextInputSources.h` trong SDK Xcode 27 [Apple]:
- `TISRegisterInputSource` chỉ đăng ký bundle trong `/Library/Input Methods/` hoặc `~/Library/Input Methods/`; hệ thống "perform any necessary cache rebuilds so that the installer can immediately call `TISCreateInputSourceList`". Không nhắc đăng xuất, không bảo đảm giao diện hiện nguồn.
- `TISEnableInputSource` "is mainly intended for input methods, or for applications that supply their own input sources". Nguồn phải `IsEnableCapable`; bật mode thì cha phải bật trước; trả `paramErr` nếu không bật được. Không nhắc hộp thoại.
- `TISSelectInputSource` cần nguồn đã bật và chọn được. `TISDisableInputSource` gỡ nguồn khỏi giao diện hệ thống.
- Danh sách nguồn là "a snapshot ... at the time the call was made"; bật/tắt phát thông báo `kTISNotifyEnabledKeyboardInputSourcesChanged`.
- Header không có API làm mới giao diện hay báo hệ thống quét lại thư mục. `HIToolbox.tbd` xuất `_TISEnableInputSourceWithOptions`, không có trong header.

Đã tra, không có gì về cài, bật, gỡ bộ gõ (03/11/2026): ghi chú phát hành macOS 26, 26.1–26.6, 27, 27.2 (macOS 27.1 chưa đọc được); trang InputMethodKit; WWDC 2025–2026. QA1810 chỉ nói về bộ gõ kiểu palette, không áp cho Dấu. Hướng dẫn người dùng macOS 26 "Add or remove input sources" mới đọc qua tóm tắt tìm kiếm.

## 2. Hộp thoại "Allow … to enable …?"

### 2.1 Kết quả

- `TISEnableInputSource` với nguồn không thuộc hệ thống không bật trực tiếp: nó gửi Apple event mở System Settings kèm yêu cầu, rồi trả 0. [Diễn giải mã máy]
- System Settings hiện hộp thoại `Allow “%1$@” to enable “%2$@”?` (tiếng Việt: "Cho phép “%1$@” bật “%2$@”?"); %1 là tên app gọi, %2 là tên mục cha ("Dấu", không phải "Dấu – Tiếng Việt"). Thân: "The developer of the input source will be able to access anything you type with this input source…". Hai nút "Don’t Allow" và "Allow". [Máy/hệ thống; Máy/Dấu]
- Yêu cầu chỉ được xử lý khi System Settings dựng mới extension Keyboard. Khi trang Keyboard đang mở sẵn, yêu cầu không để lại dòng nhật ký nào, không có hộp thoại. Vì vậy D37 thoát System Settings trước khi bật. [Máy/bản thử, 04/11/2026: bốn lần thành công đều đi cùng một tiến trình extension mới; ba lần bị bỏ qua đều lúc trang Keyboard đang mở]
- Bấm "Don’t Allow" không để lại dấu vết nào: app chỉ thấy "chưa bật". Gửi lại yêu cầu (sau khi thoát System Settings) thì hộp thoại hiện lại; macOS không nhớ lần từ chối. [Máy/bản thử, 04/11/2026]
- `NSRunningApplication.terminate()` thoát được System Settings cả khi sheet Input Sources đang mở. [Máy/bản thử]
- Hình dạng hộp thoại (đo để vẽ artboard onboarding): `docs/research/SYSTEM-SETTINGS-REFERENCE.md`.

### 2.2 Phía gọi và phía nhận [Diễn giải mã máy]

Phía gọi (`HIToolbox` trong dyld cache 27.2, `dyld_info -disassemble`):
- `TISEnableInputSource` gọi `TSMEnableInputSourceWithOptions(nguồn, 0)`. Nếu tuỳ chọn có bit giá trị 2, hoặc nguồn có `kTISPropertyInputSourceIsFromSystem`, nó bật thật (`_TSMSetInputSourceEnabled`).
- Ngược lại nó dựng từ điển `tabID` (`com.apple.IntlKeyboard`), `inputSourceToBeEnabled` (nguồn đã "flatten"), `localizedSenderName` (tên app gọi), mở System Settings qua LaunchServices kèm sự kiện, rồi trả 0.
- `IsFromSystem` có thể nghĩa "đường dẫn bundle bắt đầu bằng `/System/`". [Suy luận, cần kiểm chứng]

Phía nhận (`KeyboardSettings.appex`, `com.apple.Keyboard-Settings.extension`, hàm `handleOpenParameter(aeDesc:)`):
1. Giải plist của sự kiện. Có `inputSourceToBeEnabled` thì dựng lại nguồn từ danh sách nguồn **của chính System Settings**; không thấy thì ghi "Invalid value on inputSourceToBeEnabled" và dừng, không hộp thoại.
2. Có nguồn thì ghép tiêu đề từ tên nguồn và `localizedSenderName`.
3. Một hàm của lớp này gọi `TISEnableInputSourceWithOptions(nguồn, 2)`; gần như chắc là nút "Allow". [Suy luận, cần kiểm chứng]
- Extension chỉ nhận khoá `inputSourceToBeEnabled`: không có đường nhận yêu cầu tắt hay bỏ nguồn.
- Entitlement của extension: `com.apple.private.security.storage.inputsources`, sandbox, `shared-preference.read-write` gồm `com.apple.inputsources`, `com.apple.HIToolbox`.

Lệnh đọc nhật ký: `/usr/bin/log show --predicate 'process == "KeyboardSettings" AND eventMessage CONTAINS "inputSourceToBeEnabled"'`.

### 2.3 Dự án khác [Ngoài]

- McBopomofo (11/2025): "System Settings now asks the user whether to activate the IME"; vChewing (macOS 12) cũng thấy hộp thoại.
- low-talker (macOS 15.0.1, PR #96): hộp thoại hiện lại sau khi bấm "Không".
- Shanjie (máy ảo macOS 26.6.2): thấy hộp thoại `Allow "<caller>" to enable "Shanjie"?`.
- msime (macOS 27.0): với mode, `TISEnableInputSource` trả noErr mà mode vẫn tắt; họ bỏ nút "Bật". marinaMoji (27.0.1): mục cha trả 0 ba lần, vẫn `enabled=0`. Cả hai phù hợp với việc yêu cầu bị System Settings bỏ qua khi nó không dựng lại được nguồn.

## 3. Bộ đệm `IntlDataCache` của từng app

### 3.1 Kết quả

- Mỗi app có sandbox (kể cả extension Keyboard của System Settings) giữ `com.apple.IntlDataCache.le*` trong `$(getconf DARWIN_USER_CACHE_DIR)<bundle ID>/` và dùng nguyên bộ đệm có sẵn, không kiểm lại. Mở lại app hay thông báo đổi nguồn đều không làm nó dựng lại. Tiến trình không sandbox dùng bộ đệm chung ở gốc thư mục đó, và bộ đệm chung tự dựng lại. [Máy/bản thử, 04/11/2026]
- Bộ đệm bị xoá thì app dựng lại: app đã thoát thì ở lần mở sau; app đang chạy thì ở lần `TISRegisterInputSource` kế tiếp. Vì vậy thứ tự "xoá bộ đệm của mọi app → đăng ký → bật" làm app đang chạy dùng được nguồn mới không cần mở lại. [Máy/bản thử; Máy/Dấu]
- Sau một lần đăng nhập mới, mỗi app có sandbox dựng lại bộ đệm ở lần đầu đọc nguồn đầu vào, kể cả khi bộ đệm cũ không có Dấu. Đăng xuất không xoá các file đó. [Máy/Dấu, 05/11/2026]
- D37 dựa vào hai điều này: xoá trước khi đăng ký là đường chính, đăng xuất là đường lui cho app còn lại.

### 3.2 Bằng chứng bằng Dấu thật [Máy/Dấu]

- **Triệu chứng (04/11/2026):** Telegram 13.1 (sandbox) không chọn được "Dấu – Tiếng Việt" từ menu nhập liệu, vòng ⌃⌥Space bỏ qua Dấu, chọn bằng TIS từ tiến trình khác thì phím vẫn tới Telex. Thoát rồi mở lại Telegram không đổi gì. Bộ đệm riêng của Telegram dựng lúc `~/Library/Input Methods` chỉ có bản thử, không có `DauInputMethod.app`. Chuyển hai file đó đi rồi mở lại Telegram thì Dấu chạy. Đã loại: sandbox nói chung, Secure Event Input, `allowedInputSourceLocales`.
- **Luồng D37 (04/11/2026):** đặt lại cho Telegram bộ đệm cũ, để Telegram chạy suốt, bấm "Bật Dấu". App xoá 107 file bộ đệm; năm thư mục không liệt kê được (ba của WebKit, hai của Shortcuts; nhật ký kernel ghi `System Policy: Dau deny file-read-metadata`, không có yêu cầu TCC hay hộp thoại). Bộ đệm của Telegram dựng lại có Dấu; chọn Dấu từ menu được, gõ ra "việt".
- **Đăng xuất (05/11/2026):** một app thử có sandbox dùng bộ đệm cũ không có Dấu. Sau đăng xuất và đăng nhập, bộ đệm chung và của 12 tiến trình chạy lúc đăng nhập được ghi mới; bộ đệm của app thử và của Telegram (chưa chạy) còn nguyên. Mở lên thì cả hai dựng lại bộ đệm ngay và thấy Dấu. Máy chưa khởi động lại từ 29/10.

### 3.3 Bằng chứng bằng bản thử [Máy/bản thử, 04/11/2026]

| Thao tác | Kết quả |
|---|---|
| Bật bản thử mới khi app thử có sandbox đang chạy | app nhận thông báo đổi nguồn nhưng không thấy nguồn mới; mở lại vẫn không thấy; app mới chạy lần đầu thì thấy |
| Xoá bộ đệm của app đang chạy (nguồn đã bật) | không dựng lại, vẫn không thấy |
| Xoá bộ đệm của app đã thoát rồi mở lại | thấy |
| App mới chạy với bộ đệm cũ chép từ app khác | dùng bộ đệm đó, không thấy nguồn đã cài |
| Xoá bộ đệm của app đang chạy, rồi `TISRegisterInputSource` | dựng lại từ đĩa, thấy nguồn khi vẫn đang chạy |
| Hai app có ô nhập, chỉ xoá bộ đệm của một app, rồi đăng ký và bật | app bị xoá chọn được nguồn và gõ ra "việt"; app giữ bộ đệm cũ không chọn được, gõ ra "vieetj" như Telegram |

Thêm: một app gọi TIS lúc bất kỳ có thể dựng lại bộ đệm (vẫn cũ) giữa lúc xoá và lúc đăng ký, nên khoảng đó phải ngắn nhất có thể; D37 thêm lượt quét lại sau khi bật vì vậy.

## 4. Trạng thái "đã bật"

- Nguồn bên thứ ba đã bật nằm ở `com.apple.inputsources` › `AppleEnabledThirdPartyInputSources` (Dấu có hai mục: cha và mode `….Dau.vi`). `com.apple.HIToolbox` › `AppleEnabledInputSources` chỉ có nguồn của Apple. [Máy/hệ thống, 02/11/2026]
- Mọi tiến trình đọc được miền này; chỉ System Settings ghi được (mục 5.2).
- Cờ `kTISPropertyInputSourceIsEnabled` không đáng tin:
  - ngay sau `TISRegisterInputSource`, TIS báo mode đã bật trong khi danh sách lưu còn rỗng [Máy/bản thử];
  - sau khi System Settings gỡ Dấu bằng "–", TIS trong tiến trình mới vẫn báo `enabled=true` [Máy/Dấu, 02/11/2026];
  - mode Telex của Apple báo enabled=1 trong khi mục cha báo 0 [Máy/hệ thống, 30/10/2026];
  - McBopomofo, vChewing (từ macOS 12) và marinaMoji ghi cờ này có thể báo sai; msime thấy danh sách TIS không ổn định vài phút sau khi thay bundle. [Ngoài]
- Vì vậy app tính "đã bật" bằng mục lưu trong `com.apple.inputsources` (D37), "đang chọn" bằng nguồn hiện hành của TIS. `scripts/lib/input-source.swift` của các script thử cũng đọc theo cách này.

## 5. Gỡ

### 5.1 Kết quả và cách app làm

Theo D16 (Bảo trì và gỡ cài đặt), `SystemInputMethodInstaller`:
1. Sau khi người dùng xác nhận, mở thẳng danh sách Input Sources của System Settings (`prepareUninstall()`); không tự chuyển bàn phím, không gọi `TISDisableInputSource`.
2. Chờ tới khi `com.apple.inputsources` không còn mục nào của Dấu (`waitUntilRemovedFromInputSources()`): người dùng bỏ "Dấu – Tiếng Việt" bằng "–".
3. Rồi (`finishUninstall`) chuyển `~/Library/Input Methods/DauInputMethod.app` vào Thùng rác, yêu cầu bộ gõ thoát (bộ gõ chỉ thoát khi bundle của nó đã rời chỗ cũ, `InputMethodLifecycle`), xoá bộ đệm `IntlDataCache.le*` của System Settings (để "+" không còn dòng không tên), xoá dữ liệu App Group nếu người dùng chọn.
4. Dấu đã cài mà không có trong nguồn đầu vào thì gỡ luôn, không mở System Settings.

Cơ sở:
- Nút "–" bấm được cả khi Dấu đang được chọn; sau khi bỏ, macOS tự chuyển sang U.S. [Máy/Dấu, 04/11/2026, qua trợ năng] Vì vậy app không chọn trước một bàn phím khác; sheet chỉ nhắc chọn bàn phím khác khi nút "–" bị mờ, phòng bản macOS chưa đo (D16).
- Bundle phải còn tới khi mục cha hết khỏi `com.apple.inputsources`. Xoá bundle trước thì mục thành ẩn: không hiện ở menu, "+", danh sách bên trái hay ⌃Space, nên người dùng không bỏ được. [Máy/bản thử, 04/11/2026]
- Mục ẩn dọn được: cài lại đúng bundle ID thì nguồn được bật ngay, không hỏi; bấm "–" thì cả mục cha và mode biến mất, không cần tiến trình bộ gõ đang chạy. [Máy/bản thử, 04/11/2026] msime thấy "–" không có tác dụng khi tiến trình bộ gõ bị chặn khởi động (PR #3775). [Ngoài]
- Bỏ bundle rồi xoá bộ đệm của System Settings thì TIS thôi liệt kê và "+" sạch; chỉ bỏ bundle thì "+" còn một dòng không tên. [Máy/bản thử, 04/11/2026] Ở lần gỡ 02/11/2026 bằng Dấu thật (trước D37), "+" còn một dòng trống tới lần đăng xuất. [Máy/Dấu]
- Bộ đệm riêng của các app khác vẫn nhớ bộ gõ đã gỡ; hậu quả chưa đo (mục 10.7).
- Đã cân nhắc và loại gỡ tự động không cần "–": mọi chỗ người dùng thấy đều sạch nhưng mục "đã bật" còn ẩn, và cài lại thì macOS bật Dấu ngay không hỏi (D16).

### 5.2 Vì sao app không tự bỏ được mục

- `TISDisableInputSource` từ Dấu trả 0 cho mode và mục cha, nhưng nhật ký ghi `System Policy: Dau deny(1) user-preference-write com.apple.inputsources`, cfprefsd từ chối ghi; hai mục còn nguyên. [Máy/Dấu, 02/11/2026] `defaults import` từ một script cũng bị từ chối dù trả 0.
- Câu nhật ký cfprefsd: ghi miền này cần "user-preference-write or file-write-data sandbox access". Chính sách sandbox nền tảng chặn cả tiến trình không sandbox. Quyền Unix của file cho người dùng ghi; chỗ chặn là chính sách, không phải quyền file. [Máy/hệ thống]
- Trên máy phát triển, chỉ `KeyboardSettings.appex` có entitlement `com.apple.private.security.storage.inputsources` (quét `/System`, `/usr`, cryptex OS, 04/11/2026); luật của System Policy biên dịch trong kernel nên không loại trừ được tiến trình hệ thống khác. Bên thứ ba không xin được entitlement `com.apple.private.*` (Quinn, DTS, thread 756747; TN3125). [Máy/hệ thống; Apple]
- `TISDisableInputSource` và `TSMDisableInputSource` là một đường, ghi thẳng qua CFPreferences trong tiến trình; không có nhánh nhờ System Settings như Enable. [Diễn giải mã máy]
- Dự án khác đo thấy như vậy: Arion (macOS 26.6.2) và msime (macOS 27) chuyển sang bắt người dùng bấm "–" trước khi xoá bundle; Shanjie (26.6.2) thấy mục còn sau khi xoá bundle. Cask Homebrew của các bộ gõ (squirrel-app, macskk, mcbopomofo, gureumkim, aquaskk, xkey, keyman…) không cask nào đụng `com.apple.inputsources`. [Ngoài]

Các hướng đã xét (04/11/2026, chỉ đọc):

| Hướng | Trên 27.2 | Vì sao không dùng |
|---|---|---|
| `TISDisableInputSource`/`TSMDisableInputSource` từ app, tiến trình con hay chính bộ gõ | không có tác dụng | trả 0 mà không làm gì (Dấu; Arion; msime) |
| `defaults`/CFPreferences, kể cả chạy root | bị từ chối với tài khoản người dùng; root chưa đo | N4 (Không tự đổi cài đặt hệ thống); Dấu không xin quyền quản trị (D6 (Phát hành), D37) |
| Sửa thẳng file plist | nhiều khả năng bị chặn | cfprefsd có thể ghi đè; hỏng file là mất cả danh sách nguồn |
| Nhờ System Settings (Apple event, URL, AppleScript, App Intents) | không có | chỉ có đường xin **bật** |
| Dịch vụ XPC `com.apple.hiservices-xpcservice` | không thử | API riêng không tài liệu, vượt một lớp bảo vệ |
| Hồ sơ cấu hình | không | phải cài trong System Settings, nhiều bước hơn "–"; không có khoá nguồn nhập liệu |
| Tự động bấm "–" bằng trợ năng | làm được | cần quyền Accessibility (Dấu không xin, N4), vỡ theo bản macOS |
| Full Disk Access | chưa biết | quá tay cho việc dọn một mục (mục 10.6) |
| **Người dùng bấm "–"** rồi app mới xoá bundle | **có** | đường hiện hành (D16) |
| Mục đã ẩn: cài lại cùng ID, bấm "–", rồi xoá | **có** (bản thử) | đường cứu khi bundle đã bị xoá trước |

## 6. Nâng cấp

Cách app làm (D7 (Cập nhật và loại bản dựng), D37; `SystemInputMethodInstaller.reconcile()`):
- Mỗi lần mở, bản chủ so mã băm chữ ký bộ gõ đã cài với bản nhúng; khác thì thay. Không so số phiên bản.
- Bản mới được chép vào chỗ tạm trong cùng thư mục, gỡ quarantine, kiểm chữ ký, rồi đổi chỗ bằng một lần đổi tên. Không ghi đè từng file lên bundle đang chạy: tiến trình cũ còn ánh xạ mã của nó. [Suy luận, cần kiểm chứng; vChewing cũng chép tạm rồi đổi chỗ]
- Bộ gõ cũ được yêu cầu thoát bằng thông báo Darwin (`InputMethodLifecycle`); macOS chạy bản mới ở phím kế tiếp. Quá hạn thì app dừng tiến trình bộ gõ của chính Dấu, không đụng tiến trình nào khác.
- Gọi lại `TISRegisterInputSource` (vô hại); không đổi trạng thái bật hay chọn: ID giữ nguyên thì lựa chọn của người dùng còn nguyên.
- Các định danh không được đổi giữa các bản: D37. Đổi bundle ID tại chỗ (30/10/2026, Dấu thật) làm bộ đệm TIS lệch: ID nguồn mới nhưng `kTISPropertyBundleID` vẫn cũ, thêm nguồn không kích hoạt được tới khi đăng xuất. [Máy/Dấu]

Không làm:
- Không dừng `imklaunchagent`: dừng nó làm app đang gõ mất kết nối với mọi bộ gõ tới khi mở lại app (ghi chú trong mã vChewing). [Ngoài]
- Không dừng `TextInputMenuAgent`, `CursorUIViewService`, `TextInputSwitcher` (msime và vChewing làm). Hai tiến trình đầu giữ ảnh biểu tượng cũ tới khi khởi động lại hoặc đăng xuất [Máy/Dấu, 30/10/2026], nên biểu tượng và tên giữ nguyên giữa các bản; bản nào đổi thì ghi chú phát hành nói "đăng xuất để thấy biểu tượng mới".

## 7. Vì sao app chủ không sandbox

D37 chọn app chủ không sandbox; bộ gõ vẫn sandbox, không mạng (N2 (Bộ gõ không có quyền mạng)), App Group giữ nguyên (`scripts/selftest/app-group.sh` đạt với app chủ không sandbox, 30/10/2026).

- **Quarantine:** sandbox luôn gắn quarantine lên file app tạo ra (kể cả `move`), và app có sandbox không gỡ được; một tiến trình sandbox "không thể tạo file thực thi không bị quarantine" (Quinn, DTS, thread 811450, 701687). Bộ gõ được chép sẽ mang quarantine và có thể bị App Translocation. Trình cài McBopomofo có mã chờ hết translocation, vChewing gỡ quarantine sau khi chép. [Apple; Ngoài]
- **Dừng app khác:** `NSRunningApplication.terminate()` và `forceTerminate()`: "Sandboxed applications can't use this method to terminate other applications". [Apple]
- Ngoại lệ thư mục `com.apple.security.temporary-exception.files.home-relative-path.read-write` cho `/Library/Input Methods/` vẫn để lại hai vướng trên. Notarize không phải App Review (yêu cầu: Developer ID, Hardened Runtime, secure timestamp, không `get-task-allow`). [Apple]
- Bộ gõ có sandbox gọi `TISSelectInputSource` thì đổi được nguồn nhưng bước báo cho app đang gõ bị chặn (`deny mach-lookup com.apple.tsm.portname`). [Máy/Dấu, 30/10/2026]

| Phương án | Vướng |
|---|---|
| App chủ sandbox + ngoại lệ thư mục | quarantine không gỡ được; không dừng được tiến trình cũ |
| Người dùng chọn thư mục bằng `NSOpenPanel` | `~/Library` bị ẩn; vẫn quarantine; vẫn không dừng được tiến trình |
| App chủ sandbox + XPC service không sandbox lo cài (như Sparkle) | thêm tiến trình, giao thức, ký riêng; phương án dự phòng nếu sau này muốn app chủ sandbox |
| **App chủ không sandbox** (D37) | mất lớp sandbox ở app có mạng (Sparkle, danh sách tương thích) |
| `.pkg` (Squirrel, macSKK, Gureum, fcitx5) | cần mật khẩu quản trị; trái D6 và D16 |
| Cask `input_method` | bộ gõ nằm trong `Dấu.app`, rút ra làm hỏng chữ ký app chủ [Suy luận]; trùng việc với Sparkle |

XKey, McBopomofo, vChewing đều có trình cài không sandbox; không thấy dự án nào dùng app chủ sandbox kèm ngoại lệ thư mục. [Ngoài]

**Homebrew:** cask chỉ khai `app` (D37), không dùng stanza `input_method`; `zap` xoá Group Container, các container và tuỳ chọn. Stanza `uninstall quit:` gửi Apple event thoát; `zap` chỉ chạy với `--zap`. [Ngoài, Homebrew Cask Cookbook]

## 8. Bộ gõ tiếng Việt cũ cần phát hiện

Cho bước 1 của D14 (Onboarding). Bundle ID lấy từ `Info.plist` của bản phát hành tải từ URL trong cask Homebrew, chỉ giải nén hoặc mount chỉ đọc, không chạy. [Ngoài, 30/10/2026]

| Bộ gõ | Bundle ID app chính | Tiến trình | Bản | Thoát | Tự chạy khi đăng nhập |
|---|---|---|---|---|---|
| OpenKey | `com.tuyenmai.openkey` | `OpenKey` | 2.0.5 | biểu tượng trên thanh menu › "Thoát" (⌘Q) | tuỳ chọn "Khởi động cùng macOS" trong "Bảng điều khiển…"; helper `com.tuyenmai.OpenKeyHelper`, thêm `com.tuyenmai.OpenKeyUpdate` |
| EVKey | `com.lamquangminh.evkey` (file `EVKeyMac.app`) | `EVKey` | 3.3.10 | có chuỗi "Quit EVKey" | helper `com.lamquangminh.evkeyhelper` |
| GoTiengViet | `com.trankynam.GoTiengViet` | `GoTiengViet` | 2.4 (có sandbox) | có chuỗi "Quit GoTiengViet" | chưa rõ |
| XKey | `com.codetay.XKey`; kèm bộ gõ IMK `com.codetay.inputmethod.XKey` (tiến trình `XKeyIM`) | `XKey` | 1.2.25 | "Thoát XKey" | tuỳ chọn "Khởi động cùng hệ thống" |
| PHTV | `com.phamhungtien.phtv` | `PHTV` | 3.7.1 | có chuỗi "Quit PHTV" | tuỳ chọn "Khởi động cùng macOS" (`SMAppService`) |
| Gõ Nhanh | `org.gonhanh.GoNhanh` | `GoNhanh` | 1.0.165 | chưa rõ nhãn | có "Launch at login" |
| GoKey (goxkey) | `com.goxkey.app` (theo `Cargo.toml`, chưa kiểm bản build) | — | 0.3.1 | — | — |
| Bộ gõ tiếng Việt của Apple | `com.apple.inputmethod.VietnameseIM`; mode `….VietnameseTelex`, `….VietnameseSimpleTelex`, `….VietnameseVNI`, `….VietnameseVIQR`; bàn phím `com.apple.keylayout.Vietnamese` | nguồn nhập liệu, không chạy nền | — | — | — |

- UniKey không có app macOS (engine của nó nằm trong bộ gõ tiếng Việt của macOS, unikey.org). VietKey không có bản macOS; Laban Key chỉ có Android, iOS, ChromeOS. Cask `openkey` và `evkey` đã disabled trên Homebrew nhưng người dùng cũ còn cài.
- Bộ gõ chặn phím bằng event tap (mọi bộ gõ trong bảng trừ của Apple) biến đổi phím bất kể nguồn nào đang chọn, nên gõ chồng với Dấu: tìm bằng `NSWorkspace.shared.runningApplications`, so `bundleIdentifier` (không so tên tiến trình), chỉ tiến trình của người dùng hiện tại.
- Bộ gõ IMK khác (Telex của Apple, `XKeyIM`) chỉ xử lý phím khi chính nó được chọn, nên không gõ chồng: tìm bằng TIS (nguồn đang bật có ngôn ngữ `vi`, khác Dấu), chỉ nhắc nhẹ.
- Mục đăng nhập của app khác không có API công khai để đọc. Hướng dẫn tắt (N4): tắt "Khởi động cùng macOS" trong app đó trước (helper sẽ mở lại app), rồi "Thoát"; còn tự chạy thì tắt trong General › Login Items & Extensions. App không tự thoát app khác.

## 9. Bộ gõ khác làm gì [Ngoài, mã nguồn]

| Dự án | Cách cài và bật |
|---|---|
| Squirrel | `.pkg` vào `/Library/Input Methods`; `postinstall` dừng bản cũ, đăng ký (khi chưa mode nào bật), rồi bằng tiến trình mới dưới tên người dùng bật **mode** và chọn nó; `RequireLogout` |
| McBopomofo | trình cài chép vào `~/Library/Input Methods`, đăng ký nếu TIS chưa thấy, **luôn** bật **mục cha**; không chọn |
| vChewing | chép, gỡ quarantine, dừng bản cũ, dừng `TextInputMenuAgent` và chờ 0,5 s, đăng ký, bật **từng mode**; không dừng `imklaunchagent` |
| XKey (tiếng Việt, IMK) | chép `XKeyIM.app`, đăng ký, **không bật**, mở System Settings › Keyboard để người dùng tự thêm |
| macSKK, Gureum, fcitx5-macos | cài, không gọi TIS lúc cài; người dùng tự thêm |
| msime | từng có nút "Bật"; bỏ vì không có tác dụng trên macOS 27; hướng dẫn, mở System Settings, kiểm lại định kỳ |
| marinaMoji (Mozc) | `.pkg` vào `/Library/Input Methods`, `postinstall` dưới tên người dùng (mục 1.5) |
| tabulador | đăng ký rồi tra `TISCreateInputSourceList` ngay trong tiến trình chạy lâu thì nhận NULL; sửa bằng thử lại; khoá `ComponentInvisibleInSystemUI = true` làm nguồn biến khỏi "+" (Dấu không đặt khoá này) |

- Không dự án nào chờ `kTISNotifyEnabledKeyboardInputSourcesChanged` khi cài hay dừng `imklaunchagent`.
- Dấu chỉ bật khi người dùng bấm "Bật Dấu" (N4), không chọn Dấu sau khi bật; thận trọng hơn Squirrel, McBopomofo, vChewing, ngang XKey và msime.

**Mở đúng màn hình System Settings:** `x-apple.systempreferences:com.apple.Keyboard-Settings.extension` (thêm `?InputSources` để mở thẳng danh sách) và `…:com.apple.LoginItems-Settings.extension`. `KeyboardSettings.appex` trên 27.2 khai báo `allowsXAppleSystemPreferencesURLScheme = true`; Apple không công bố danh sách URL nên phải thử lại trên từng bản macOS. [Máy/hệ thống; Suy luận]

## 10. Câu hỏi còn mở

### 10.1 Các bản macOS khác và bản ký Developer ID
Bật không đăng xuất và hộp thoại "Allow" mới đo trên macOS 27.2 với bản Debug. Cần đo macOS 14–26 và bản ký Developer ID đã notarize (M7 (Phát hành)).

### 10.2 Vì sao System Settings không dựng lại được nguồn
Nhật ký "Invalid value on inputSourceToBeEnabled" (Dấu 02/11/2026 trước D37, bản thử 03/11/2026) phù hợp với giả thuyết bộ đệm của System Settings chưa có nguồn (mục 1.6); không tìm thấy nguồn Apple.

### 10.3 Luật `.inputmethod.` trong bundle ID
Bản thử có ID không chứa `.inputmethod.` không được TIS liệt kê, trước và sau một lần đăng nhập; ID có chuỗi đó thì được liệt kê ngay. [Máy/bản thử, 03/11/2026] Chuỗi có trong `HIToolbox` cạnh nhật ký `TISFileInterrogator`, nhưng không xác định được chỗ dùng. Mẫu IMKit của ensan-hcl dặn đặt ID có `.inputmethod.`; mọi ID IMK đã gặp đều có. Không tìm thấy nguồn Apple. Dấu giữ `com.codefastlabs.dau.inputmethod.Dau` (D24 (Tên và định danh)).

### 10.4 Bộ gõ notarize mang quarantine
Bộ gõ đã notarize mà mang quarantine có chạy không, có bị translocate không. Chỉ liên quan tới phương án app chủ sandbox (mục 7); app chủ của Dấu gỡ quarantine trước khi đặt bộ gõ vào chỗ.

### 10.5 Mục ẩn sau đăng xuất
Mục ẩn (bundle đã xoá, mục còn trong `com.apple.inputsources`) có hiện lại ở đâu sau một lần đăng nhập không. msime và Shanjie cho thấy mục không tự mất; cần tạo một mục ẩn mới để đo.

### 10.6 Vì sao ml-ime ghi được `com.apple.inputsources`
ml-ime (macOS 26.5.2, 26.6.2) ghi miền này bằng `defaults write` trong khi Arion (26.6.2) và máy phát triển (27.2) bị chặn. Có thể Terminal của họ có Full Disk Access, hoặc lệnh chặn mới có ở 27 [Suy luận, cần kiểm chứng]. Full Disk Access của Terminal trên máy phát triển đang bật (04/11/2026) nhưng không biết lần `defaults import` bị từ chối chạy trong app nào, nên chưa đóng được hướng này. Chỉ để chẩn đoán, không vào sản phẩm.

### 10.7 Bộ đệm riêng của từng app: phần chưa đo
- Khởi động lại máy có làm như đăng xuất không.
- Tiến trình dùng năm thư mục được bảo vệ (WebKit, Shortcuts) có giữ bộ đệm cũ không, có ô nhập chữ nào bị ảnh hưởng không.
- Sau khi gỡ, bộ đệm của các app còn nhắc `DauInputMethod.app` có hậu quả gì.

### 10.8 Ghi chú phát hành và tracker chưa đọc được
Ghi chú phát hành macOS 27.1 và ghi chú bản beta; tracker của fcitx5-macos và AquaSKK.

## Nguồn

Mã nguồn tham khảo đọc ngoài repo (không chép mã nào vào Dấu); commit của hai đợt đọc 30/10 và 02/11/2026: `docs/history/RESEARCH-LOG.md` mục 1.1.

**Apple**
- Header SDK: `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/TextInputSources.h` và `HIToolbox.tbd` cùng SDK.
- Apple Developer Forums, thread 775526 "Avoiding logoff when installing new/modified InputMethodKit input source" (DTS, 06/2026): https://developer.apple.com/forums/thread/775526
- Apple Developer Forums, sandbox và quarantine (Quinn): https://developer.apple.com/forums/thread/811450 , https://developer.apple.com/forums/thread/701687
- Apple, App Sandbox Temporary Exception Entitlements: https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/EntitlementKeyReference/Chapters/AppSandboxTemporaryExceptionEntitlements.html
- Apple, Notarizing macOS software before distribution: https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution
- Apple, `NSRunningApplication.terminate()` / `forceTerminate()`: https://developer.apple.com/documentation/appkit/nsrunningapplication/terminate() ; https://developer.apple.com/documentation/appkit/nsrunningapplication/forceterminate()
- Apple, `NSWorkspace.runningApplications`: https://developer.apple.com/documentation/appkit/nsworkspace/runningapplications
- Apple, `LSFileQuarantineEnabled`: https://developer.apple.com/documentation/bundleresources/information-property-list/lsfilequarantineenabled
- Ghi chú phát hành macOS: https://developer.apple.com/documentation/macos-release-notes/macos-27-release-notes ; `…/macos-27_2-release-notes` ; `…/macos-26-release-notes` ; `…/macos-26_1-release-notes` đến `…/macos-26_6-release-notes` (bản `.json` dưới `https://developer.apple.com/tutorials/data/documentation/macos-release-notes/`)
- Apple, trang InputMethodKit: https://developer.apple.com/documentation/inputmethodkit
- Apple, QA1810: https://developer.apple.com/library/archive/qa/qa1810/_index.html
- Apple, hướng dẫn macOS 26 về nguồn nhập liệu (chỉ qua tóm tắt tìm kiếm): https://support.apple.com/en-kz/guide/mac-help/mchl84525d76/26/mac/26
- Apple Developer Forums, entitlement riêng của Apple (Quinn, DTS, 06/2024): https://developer.apple.com/forums/thread/756747 ; TN3125: https://developer.apple.com/documentation/technotes/tn3125-inside-code-signing-provisioning-profiles
- Apple, Apple Events Entitlement: https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.automation.apple-events ; `NSAppleEventsUsageDescription`: https://developer.apple.com/documentation/bundleresources/information-property-list/nsappleeventsusagedescription ; `AXIsProcessTrustedWithOptions(_:)`: https://developer.apple.com/documentation/applicationservices/1459186-axisprocesstrustedwithoptions
- Apple Support, Accessibility: https://support.apple.com/guide/mac-help/allow-accessibility-apps-to-access-your-mac-mh43185/mac ; hồ sơ cấu hình: https://support.apple.com/guide/mac-help/mh35561/mac ; `man profiles` (macOS 27.2)
- Apple, device-management, khai báo Keyboard Settings: https://github.com/apple/device-management/blob/release/declarative/declarations/configurations/keyboard.settings.yaml
- Apple Developer Forums (người dùng, 2020), GUI scripting nhạy với thay đổi giao diện: https://developer.apple.com/forums/thread/131014

**Hệ thống macOS 27.2 (đọc trên máy)**
- `/System/Library/ExtensionKit/Extensions/KeyboardSettings.appex` (`Localizable.loctable`, binary, entitlement); `LoginItems.appex`, `GeneralSettings.appex` (`.loctable`).
- `HIToolbox` trong dyld cache `/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e*`.
- `com.apple.hiservices-xpcservice.xpc` trong `HIServices.framework`; `/System/Library/CoreServices/UAUPlugins/TextInputSourceUAU.bundle`; `/System/Applications/System Settings.app/Contents/Resources/SettingsAppleScript.sdef`; nhật ký cfprefsd 02/11/2026.

**Ngoài**
- Homebrew Cask Cookbook: https://docs.brew.sh/Cask-Cookbook ; cask JSON: https://formulae.brew.sh/api/cask/{openkey,evkey,gotiengviet,xkey,phtv,gonhanh}.json ; https://formulae.brew.sh/api/cask/{squirrel-app,macskk,mcbopomofo,gureumkim,aquaskk,xkey,keyman,google-japanese-ime,sogouinput,wetype,openkey,evkey}.json (04/11/2026)
- Sparkle, Sandboxing: https://sparkle-project.org/documentation/sandboxing/
- Squirrel: https://github.com/rime/squirrel ; issue #1083, #1082, #1169
- McBopomofo: https://github.com/openvanilla/McBopomofo
- vChewing: https://github.com/vChewing/vChewing-macOS
- macSKK: https://github.com/mtgto/macSKK
- fcitx5-macos: https://github.com/fcitx-contrib/fcitx5-macos
- Gureum: https://github.com/gureum/gureum
- XKey: https://github.com/xmannv/xkey ; issue #75 https://github.com/xmannv/xkey/issues/75
- AquaSKK: https://github.com/codefirst/aquaskk
- msime: https://github.com/metasequoiaime/msime — PR #2492, #2481, #3738, #3765, #3775
- marinaMoji, issue #66: https://github.com/marinaMoji/marinaMoji/issues/66
- tabulador, PR #9: https://github.com/glrodasz/tabulador/pull/9
- low-talker, PR #96: https://github.com/brandon-fryslie/low-talker/pull/96
- Mẫu IMKit của ensan-hcl: https://github.com/ensan-hcl/macOS_IMKitSample_2021
- logcg (Mojave): https://www.logcg.com/en/archives/3263.html
- OpenKey: https://github.com/tuyenvm/OpenKey ; goxkey: https://github.com/huytd/goxkey
- UniKey trên macOS: https://www.unikey.org/en/apple.html
- Arion: https://github.com/AstraFoundry/Arion
- ml-ime, PR #90: https://github.com/lexoliu/ml-ime/pull/90
- qingjian, issue #209: https://github.com/qingjian-team/qingjian/issues/209
- tisutil (Divvun): https://github.com/divvun/tisutil
- Shanjie: https://github.com/Nanako0129/shanjie
- Late Night Software, AppleScript và System Settings trên Ventura: https://forum.latenightsw.com/t/applescripts-not-working-on-new-system-settings-on-macos-ventura/3986
