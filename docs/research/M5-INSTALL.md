# M5 — Cài, bật, nâng cấp, gỡ bộ gõ; phát hiện bộ gõ cũ (nghiên cứu hợp nhất)

Hợp nhất ngày 03/11/2026 từ ba nghiên cứu: T1 (30/10, cài/nâng cấp/gỡ), lần cài đầu có tránh được đăng xuất không (02/11), và đăng ký/bật/gỡ trên macOS 26–27 chỉ ghi điều có nguồn (03/11). Mỗi sự kiện chỉ ghi ở một chỗ; mục 0 là bản tóm tắt hiện trạng, chi tiết nằm ở các mục sau. Mã nguồn dẫn tới mục này theo số mục (mục 1 đến 5).

Máy đọc: macOS 27.2 (build 26B123), Xcode 27.2 (SDK `MacOSX27.2.sdk`). Mọi việc đọc hệ thống ở đây **chỉ đọc** (`strings`, `nm`, `otool`, `dyld_info`, `codesign -d`, `defaults read`, `log show`, `ps`, `launchctl print`, `ls`, `gh`, `curl`). Các phép đo chủ động (Dấu thật, bản thử) mang nhãn riêng.

## Nhãn nguồn

Mỗi khẳng định mang một nhãn. Chỗ không có nguồn ghi đúng "không tìm thấy nguồn", không điền bằng suy luận.

| Nhãn | Nghĩa |
|---|---|
| **[Apple]** | tài liệu, header SDK, ghi chú phát hành hoặc bài diễn đàn của Apple (kể cả DTS) |
| **[Ngoài]** | dự án hoặc diễn đàn khác: báo cáo, PR, README, hoặc mã nguồn của dự án đó (ghi "mã" nếu là mã) |
| **[Máy/hệ thống]** | đọc file hệ thống hoặc nhật ký trên máy này; ghi lệnh hoặc ngày |
| **[Máy/Dấu]** | đo bằng Dấu thật (nhật ký của `docs/PROGRESS.md`, dẫn theo ngày) |
| **[Máy/bản thử]** | đo bằng bản thử, **không phải Dấu**; chỉ nằm ở mục 8, không rút kết luận |
| **[Diễn giải mã máy]** | người nghiên cứu đọc mã máy hoặc mã nguồn dự án khác và tự diễn giải; không có tài liệu Apple xác nhận |
| **[Suy luận, cần kiểm chứng]** | chưa ai đo |

Bản sao mã nguồn tham khảo (ngoài repo, không chép mã nào vào Dấu), hai đợt đọc: 30/10: Squirrel 46962d2, McBopomofo 18e2060, vChewing 7c82f5f, macSKK 539cce3, fcitx5-macos 3466612, Gureum 46c62e5, XKey 398e78e, goxkey b197c57, OpenKey 89c2fd3. 02/11 (`/tmp/dau-research/`): Squirrel d220b92, McBopomofo 257da53, vChewing-macOS 8c1bb72, macSKK c812585, Gureum 46c62e5, fcitx5-macos 3466612, XKey 398e78e.

## 0. Hiện trạng hiểu biết (03/11/2026, macOS 27.2)

### (a) Có nguồn Apple, nguồn ngoài, hoặc file hệ thống

1. **Apple DTS (06/2026, FB23026482):** "without the user logging off the system, System Settings doesn't pick up a new input source any more. I don't see anything that can avoid the logoff." Không nêu hàm TIS, hộp thoại hay cách thay thế. [Apple, diễn đàn 775526] Mục 2.3.
2. **Header `TextInputSources.h` (SDK 27.2)** nói `TISRegisterInputSource` cho phép lấy ngay `TISInputSourceRef`, không nhắc đăng xuất; `TISEnableInputSource` trả `paramErr` nếu không bật được, "else noErr", không nhắc hộp thoại xin phép. `TISEnableInputSourceWithOptions` có trong `HIToolbox.tbd` nhưng không có trong header. [Apple] Mục 2.1.
3. **Không có tài liệu công khai cho hành vi này:** ghi chú phát hành macOS 26, 26.1–26.6, 27, 27.2 không nhắc nhập liệu/bộ gõ/`TISEnableInputSource` (27.1 chưa đọc được); không có trang web tài liệu TIS; không có bài WWDC; không có bài diễn đàn Apple về hộp thoại hay luật `.inputmethod.`. Mọi hành vi có thể đổi theo từng bản macOS. [Apple, đọc 03/11] Mục 2.1.
4. **Cài đặt hệ thống có sẵn hộp thoại "Allow “%1$@” to enable “%2$@”?"**; chú thích của Apple: tham số thứ nhất là tên app hoặc chương trình, tham số thứ hai là tên bộ gõ. [Máy/hệ thống, macOS 27.2, 03/11] Mục 2.2.
5. **Nơi lưu trạng thái "đã bật" của nguồn bên thứ ba** là `com.apple.inputsources` › `AppleEnabledThirdPartyInputSources`; `com.apple.HIToolbox` › `AppleEnabledInputSources` chỉ có nguồn của Apple. Bộ đệm `IntlDataCache` của Cài đặt Bàn phím có giờ ghi trùng giờ đăng nhập. [Máy/hệ thống, 02/11] Mục 2.6.
6. **Lần cài đầu có phải đăng xuất:** Squirrel, macSKK, Gureum, fcitx5-macos, XKey, AquaSKK báo phải đăng xuất; msime (macOS 27.0, ID mới) đo thấy phải đăng xuất; marinaMoji (máy ảo sạch macOS 27.0.1, `.pkg` ở `/Library/Input Methods`) báo nguồn hiện ngay trong "+". [Ngoài] Mục 2.3, 2.4; câu hỏi mở d1.
7. **Gọi `TISEnableInputSource` từ bên thứ ba có thể trả noErr mà không bật:** msime (27.0, mode `TISTypeKeyboardInputMode`); marinaMoji (27.0.1, cha `enabled=0` sau ba lần gọi, `TISSelectInputSource` trả -50). [Ngoài] Mục 2.2.
8. **App sandbox:** file app tạo ra luôn bị quarantine và app không gỡ được (Apple DTS, 2022 và 2026); `NSRunningApplication.terminate()` không dùng được trên app khác. [Apple, diễn đàn và tài liệu] Mục 1.2. Đã dẫn tới D37.

### (b) Quan sát bằng Dấu thật (macOS 27.2 trừ khi ghi khác)

1. **30/10:** cài đè cùng đường dẫn `~/Library/Input Methods/DauInputMethod.app` với bundle ID khác làm bộ đệm TIS lệch (ID nguồn mới nhưng `kTISPropertyBundleID` vẫn là ID cũ; báo enabled trong khi miền HIToolbox không có); thêm nguồn không kích hoạt được; đăng xuất rồi đăng nhập thì đúng ID mới. Đây là đổi ID tại chỗ, **không phải** cài lần đầu trên máy sạch. [Máy/Dấu] Mục 3.
2. **30/10:** từ bộ gõ có sandbox, `TISSelectInputSource` đổi được nguồn nhưng bước báo cho app đang gõ bị chặn (`deny mach-lookup com.apple.tsm.portname`). [Máy/Dấu] Mục 1.2.
3. **30/10:** `scripts/selftest-app-group.sh` đạt với app chủ không sandbox. [Máy/Dấu] Mục 1.3.
4. **Máy không sạch từ 30/10:** hai mục Dấu (cha và mode `….Dau.vi`) trong `com.apple.inputsources` có từ ngày 30/10 (file sửa lần cuối 30/10 16:18, trùng ngày người dùng đăng xuất/đăng nhập và bật lại nguồn "Dấu – Tiếng Việt"), không phải do lần "Bật Dấu" 02/11; macOS từ chối mọi tiến trình khác ghi miền này. Vì vậy ở T4 lần 1 (02/11) việc Dấu "tự có sẵn" sau đăng nhập không chứng minh điều gì về `TISEnableInputSource`. [Máy/Dấu, 02/11] Mục 2.6.
5. **T4 lần 1 (02/11, Release 22948d9):** sau khi dọn tay và đăng xuất, "Bật Dấu" chép, đăng ký (`status=0`), bật mục cha (`status=0`); danh sách "+" và menu **không** có Dấu. Sau đăng xuất/đăng nhập Dấu có sẵn, đang được chọn, bộ gõ chạy. [Máy/Dấu] Mục 2.3.
6. **02/11 16:41:23:** Cài đặt ghi lỗi "Invalid value on inputSourceToBeEnabled" 0,8 s sau khi Dấu ghi `event=enable … status=0`; theo mã thì khi đó không dựng hộp thoại. Cài đặt có hiện lên màn hình hay không: không ghi lại. [Máy/Dấu + Máy/hệ thống] Mục 2.2.
7. **02/11:** `TISDisableInputSource` từ app trả 0 cho mục con và mục cha, nhưng System Policy chặn ghi `com.apple.inputsources` (`Dau deny(1) user-preference-write com.apple.inputsources`; cfprefsd "rejecting write"), hai mục Dấu còn nguyên, TIS tiến trình mới vẫn báo `enabled=true`. Chỉ nút "–" trong Cài đặt gỡ được (file ghi lúc 18:07, mục rỗng). [Máy/Dấu] Mục 4.
8. **Chưa có phép đo trên tài khoản macOS mới, nhìn danh sách "+" bằng mắt, với Dấu thật.** Mục 7.

### (c) Diễn giải mã/binary (của người nghiên cứu)

1. `TISEnableInputSource` với nguồn không thuộc hệ thống không bật mà gửi Apple event tới Cài đặt, rồi trả 0. [Diễn giải mã máy] Mục 2.2.
2. `handleOpenParameter(aeDesc:)` của `KeyboardSettings` ghi "Invalid value on inputSourceToBeEnabled" khi không dựng lại được nguồn từ dữ liệu nhận được; hộp thoại chỉ dựng khi dựng lại được. [Diễn giải mã máy] Mục 2.2.
3. Giả thuyết "danh mục nguồn mà menu và Cài đặt đọc là ảnh chụp lúc đăng nhập" khớp giờ ghi `IntlDataCache`; bản trước của giả thuyết còn nói `TISEnableInputSource` ghi được tuỳ chọn, điều này **không còn đứng** (xem 2.2, 2.6). [Suy luận, cần kiểm chứng] Mục 2.3.

### (d) Câu hỏi mở

1. **Lần cài đầu có phải đăng xuất để danh sách "+" thấy ID mới không.** Apple DTS nói cần; marinaMoji nói không; chưa ai tách được nguyên nhân khác biệt (thư mục cài, tiến trình gọi, thời điểm). Trả lời bằng Dấu thật trên tài khoản sạch, nhìn "+" bằng mắt (mục 7). D37 ghi "có thể". Mục 2.3.
2. **Vì sao Cài đặt không dựng lại được nguồn** ("Invalid value"), kể cả với Dấu thật. Không tìm thấy nguồn. Mục 2.2.
3. **Hộp thoại "Allow … to enable …?" có hiện thật trên macOS 26/27 khi nào**, và bản ký Developer ID đã notarize có khác không. Chưa ai thấy hộp thoại trên máy này. Mục 2.2.
4. **Luật `.inputmethod.` trong bundle ID có do Apple quy định không.** Không tìm thấy nguồn Apple. Mục 2.7.
5. **Bộ gõ đã notarize nhưng mang quarantine** (chép từ app sandbox) có chạy không, có bị translocate không; chỉ thử được ở M7. Mục 1.2. Chỉ liên quan tới các phương án sandbox (A đến C ở 1.3); D37 chọn D.
6. **Ghi chú phát hành macOS 27.1 và ghi chú bản beta** chưa đọc được; tracker fcitx5-macos và aquaskk không rà được. Mục 2.1.
7. **`TISDisableInputSource` lên mode đang được chọn:** hệ thống đổi sang nguồn nào khi Dấu bị tắt (đo ở T4). Mục 4.

## 1. App chủ có sandbox có chép được bộ gõ vào `~/Library/Input Methods` không?

### 1.1 Entitlement
- `com.apple.security.temporary-exception.files.home-relative-path.read-write`, giá trị là mảng đường dẫn tính từ `~`, bắt đầu bằng `/`, và **kết thúc bằng `/` nếu là thư mục**. Với Dấu sẽ là `/Library/Input Methods/`. Apple gọi đây là ngoại lệ "tạm" và khuyên gửi báo lỗi; hướng dẫn kê khai trong App Store Connect chỉ áp dụng cho App Store. [Apple, Entitlement Key Reference, mục App Sandbox Temporary Exception Entitlements]
- **Notarize: được.** Apple viết: "Notarization of macOS software is not App Review. The Apple notary service is an automated system…" Yêu cầu chỉ gồm ký Developer ID, Hardened Runtime, secure timestamp, không có `get-task-allow`. [Apple, trang "Notarizing macOS software before distribution"] Dịch vụ notarize không xét entitlement sandbox: đây là suy luận từ danh sách yêu cầu đó, chưa thấy câu nào của Apple nói thẳng. [Suy luận, cần kiểm chứng ở M7]

### 1.2 Vướng mắc thật sự: quarantine và dừng tiến trình
- **Sandbox luôn gắn quarantine lên file app tạo ra.** Một lệnh `move` cũng tính là tạo file mới. App trong sandbox **không** gỡ được nhãn này (Quinn, Apple DTS, 1/2026). Một tiến trình sandbox "không thể tạo file thực thi không bị quarantine" (Quinn, 3/2022). [Apple, Developer Forums 811450, 701687]
  - Hệ quả: bản bộ gõ được chép sẽ mang quarantine. Lần đầu hệ thống chạy nó, Gatekeeper sẽ kiểm tra, và bộ gõ có thể bị **App Translocation** (chạy từ một đường dẫn ngẫu nhiên, chỉ đọc). Bằng chứng gián tiếp: trình cài McBopomofo có mã riêng để chờ hết translocation của bộ gõ cũ (`BundleTranslocate.m`), còn vChewing gỡ quarantine bằng `xattr -drs com.apple.quarantine` sau khi chép. [Ngoài, mã hai dự án] Bộ gõ đã notarize thì có chạy được không, có hiện hộp thoại "tải từ Internet" cho một tiến trình nền không, có bị translocate không: [Suy luận, cần kiểm chứng]. Chỉ thử được với bản ký Developer ID đã notarize (M7). Bản Personal Team chưa notarize nên khi bị quarantine nhiều khả năng bị chặn hẳn.
- **App sandbox không dừng được app khác.** Tài liệu `NSRunningApplication.terminate()` và `forceTerminate()` ghi rõ: "Sandboxed applications can't use this method to terminate other applications". [Apple] `kill()` sang tiến trình khác cũng bị sandbox chặn: [Suy luận, cần kiểm chứng]. D7 cần dừng tiến trình bộ gõ cũ sau khi cập nhật.
- `TISRegisterInputSource`/`TISEnableInputSource` gọi từ **app chủ** có sandbox: chưa ai đo. Với **bộ gõ** có sandbox (30/10/2026), `TISSelectInputSource` đổi được nguồn nhưng bước báo cho app đang gõ bị chặn. [Máy/Dấu]

### 1.3 Các phương án

| Phương án | Được | Vướng |
|---|---|---|
| A. App chủ sandbox + temporary exception `/Library/Input Methods/` | Giữ sandbox | Bản chép mang quarantine, không gỡ được; không dừng được tiến trình cũ; chỉ kiểm được ở M7 |
| B. Người dùng tự chọn thư mục bằng `NSOpenPanel` (powerbox) + bookmark | Không cần ngoại lệ | `~/Library` bị ẩn, người dùng phải tìm đúng thư mục; file tạo ra vẫn bị quarantine (Quinn: `user-selected.executable` chỉ có tác dụng với vị trí chọn qua bảng *lưu*); vẫn không dừng được tiến trình |
| C. App chủ sandbox + XPC service không sandbox lo việc cài | Giữ sandbox cho phần có mạng | Thêm một tiến trình, giao thức XPC, ký riêng. Sparkle làm đúng kiểu này để "cài bản cập nhật bên ngoài sandbox của app" |
| D. App chủ **không** sandbox (bộ gõ vẫn sandbox, không mạng) | Đơn giản nhất: chép, kiểm chữ ký, gỡ quarantine, dừng tiến trình, gỡ cài đặt (kể cả tự chuyển app vào Thùng rác) đều làm trực tiếp; Sparkle không cần cấu hình XPC | Mất lớp sandbox ở app có kết nối mạng (Sparkle, danh sách tương thích) |
| E. Gói `.pkg` | Squirrel, macSKK, Gureum, fcitx5 dùng cách này (cài vào `/Library/Input Methods`, cần mật khẩu quản trị; Squirrel đặt `RequireLogout`) | Trái D6 (DMG) và D16 (`~/Library/Input Methods`); Sparkle cài `.pkg` phải xin quyền quản trị |
| F. Cask `input_method` | Homebrew chuyển bundle vào `~/Library/Input Methods` | Bộ gõ nằm trong `Dấu.app`; rút nó ra làm hỏng chữ ký của app chủ [Suy luận]; trùng việc với app chủ và Sparkle (`auto_updates true`) |

Các bộ gõ khác: XKey (tiếng Việt) có app chủ **không sandbox** tự chép `XKeyIM.app` vào `~/Library/Input Methods`; khi chép lỗi, XKey chuyển sang hướng dẫn kéo-thả tay. Trình cài của McBopomofo và vChewing cũng không sandbox. **Không thấy dự án nào dùng phương án A.** [Ngoài, entitlements và mã nguồn]

**Quyết định:** D37 chọn phương án D (app chủ không sandbox, Hardened Runtime, ký Developer ID, notarize); bộ gõ giữ sandbox, App Group, không mạng (N2). `scripts/selftest-app-group.sh` đạt với app chủ không sandbox (30/10/2026) [Máy/Dấu]. Phương án dự phòng nếu sau này muốn app chủ sandbox: C, không phải A.

### 1.4 Homebrew
- `input_method`: "Relative path to an Input Method that should be moved into the `~/Library/Input Methods` folder on installation". `uninstall quit:` gửi Apple Event thoát. `signal:` chỉ dùng khi `quit` không có tác dụng. `zap` chỉ chạy khi gõ `--zap`. [Ngoài, Homebrew Cask Cookbook]
- Cask đề xuất (tên cask chọn sau, D24): chỉ `app "Dấu.app"` và `auto_updates true`. `uninstall` gọi lệnh gỡ của chính app (ví dụ cờ `--uninstall-input-method`: tắt nguồn, dừng bộ gõ) rồi `trash "~/Library/Input Methods/DauInputMethod.app"`. `zap` xoá Group Container `M58DANM3ZP.com.codefastlabs.dau.shared` (sẽ đổi theo Team ID của bản phát hành), các container, và các tuỳ chọn. Không dùng stanza `input_method`.

## 2. `TISRegisterInputSource` / `TISEnableInputSource` / `TISSelectInputSource`

### 2.1 Tài liệu Apple và header
Apple không có trang tài liệu web cho họ hàm TIS (các URL đoán `documentation/carbon/tisenableinputsource(_:)`, `…/tisregisterinputsource(_:)`, `…/text_input_sources` trả 404 ngày 03/11/2026). Nguồn chính thức duy nhất là header.

`…/HIToolbox.framework/Headers/TextInputSources.h` trong SDK Xcode 27 (file nén, đọc bằng `grep -a`; header ký 2006–2008, file ngày 22/02/2026) [Apple]:
- `TISRegisterInputSource` chỉ đăng ký được bundle nằm trong `/Library/Input Methods/` hoặc `~/Library/Input Methods/`, nghĩa là **phải chép vào đó trước**. Header ghi code gọi hàm này "is part of an application or service that has already been validated in some way (e.g. by the user)". Đăng ký "so that a TISInputSourceRef can immediately be obtained for each of the new input source(s)"; hệ thống "perform any necessary cache rebuilds so that the installer can immediately call `TISCreateInputSourceList`". Không nhắc đăng xuất và không bảo đảm giao diện hiện nguồn.
- `TISEnableInputSource` "is mainly intended for input methods, or for applications that supply their own input sources"; nguồn phải `IsEnableCapable`; muốn bật input mode thì **input method cha phải được bật trước**; trả `paramErr` nếu không bật được, "else noErr". **Không nhắc hộp thoại xin phép.**
- `TISSelectInputSource` cần nguồn đã bật và chọn được (select-capable); với mode thì cha cũng phải đang bật.
- `TISDisableInputSource` gỡ nguồn khỏi giao diện hệ thống.
- Danh sách ASCII-capable là "a snapshot ... at the time the call was made"; thay đổi bật/tắt phát thông báo phân tán `kTISNotifyEnabledKeyboardInputSourcesChanged`. Đây là ảnh chụp theo từng lần gọi của một tiến trình.
- `grep -a -n "WithOptions\|FromSystem"` trên header: không có dòng nào. Nhưng `HIToolbox.tbd` của cùng SDK xuất ký hiệu `_TISEnableInputSourceWithOptions`: hàm có tuỳ chọn tồn tại, không được tài liệu hoá trong header.
- Header **không có** API làm mới giao diện hay báo hệ thống quét lại thư mục.

Các nguồn Apple khác đã tra:
- **Ghi chú phát hành macOS:** tải `https://developer.apple.com/documentation/macos-release-notes/<tên>.md` hoặc bản `.json` dưới `https://developer.apple.com/tutorials/data/documentation/macos-release-notes/`, rồi `grep -i "input method\|input source\|InputMethodKit\|TISEnable"`: macOS 26, 26.1 đến 26.6, 27, 27.2 đều **0 dòng khớp** (03/11/2026). macOS 27.1: trang trả khung HTML, chưa đọc được. Ghi chú bản beta riêng: không tìm thấy nguồn.
- **Trang `InputMethodKit`** (`https://developer.apple.com/tutorials/data/documentation/inputmethodkit.json`, 03/11/2026): chỉ có tóm tắt "Develop input methods and manage communication with client applications" cùng các lớp `IMKServer`, `IMKInputController`…; không có bài về cài đặt, bật, gỡ.
- **QA1810:** bundle chép vào `~/Library/Input Methods` không hiện trong Nguồn nhập liệu nếu là kiểu palette (từ Mavericks). Dấu là bộ gõ bàn phím nên không thuộc trường hợp này; ghi để loại trừ. [Apple, chưa đọc toàn văn; tóm tắt qua tìm kiếm]
- **Hướng dẫn người dùng macOS 26** "Add or remove input sources" (`support.apple.com/en-kz/guide/mac-help/mchl84525d76/26/mac/26`): chỉ thấy qua tóm tắt tìm kiếm, nói không nhắc hộp thoại xin phép; chưa đọc toàn văn.
- **WWDC 2025/2026:** một lượt tìm, không có phiên nào về cài hay bật bộ gõ bên thứ ba. Không tìm thấy nguồn.
- **Diễn đàn:** thread 775526 (mục 2.3). Bài diễn đàn Apple về hộp thoại "Allow … to enable …", về luật `.inputmethod.`, về nguồn hiện trong "+" không cần đăng xuất: không tìm thấy nguồn (ba lượt tìm web 03/11; công cụ tìm không lập chỉ mục sâu diễn đàn, nên là "không thấy", không phải "không có").

### 2.2 Hộp thoại xác nhận

**Chuỗi giao diện** [Máy/hệ thống, 27.2, 03/11]: đối tượng là `/System/Library/ExtensionKit/Extensions/KeyboardSettings.appex` (CFBundleIdentifier `com.apple.Keyboard-Settings.extension`, CFBundleVersion 148.1.5, điểm mở rộng `com.apple.Settings.extension.ui`, `allowsXAppleSystemPreferencesURLScheme = true`). Lệnh: `plutil -convert json -o - …/Contents/Resources/Localizable.loctable` rồi lọc, và `strings -a …/Contents/MacOS/KeyboardSettings`.
- Khoá `en`: `Allow “%@” to enable “%@”?` → `Allow “%1$@” to enable “%2$@”?` (tiếng Việt: "Cho phép “%1$@” bật “%2$@”?"), hai nút "Cho phép"/"Không cho phép", và câu "The developer of the input source will be able to access anything you type with this input source…" (tiếng Việt: "Nhà phát triển của nguồn đầu vào sẽ có thể truy cập mọi thứ bạn nhập với nguồn đầu vào này…").
- Chú thích của Apple kèm chuỗi " to enable ": "The first parameter is an app or program name. The second parameter is an input method name." Nhãn "Installed Input Source" có chú thích "Headline for warning texts about third-party input methods."
- Ký hiệu: `handleOpenParameter(aeDesc:)`, `inputSourceToBeEnabled`, `localizedSenderName`, `_showingThirdPartyPrompt`, `_thirdPartyPromptTitle`, `thirdPartyInputSource`; nhập khẩu `_TISEnableInputSourceWithOptions` và `__CreateUnflattenedInputSource` (`dyld_info -imports`).
- Entitlement (`codesign -d --entitlements - …`): `com.apple.private.security.storage.inputsources`, `com.apple.security.app-sandbox`, sbpl `(allow user-preference* (preference-domain-regex #"^.*"))`, và `shared-preference.read-write` gồm `com.apple.inputsources`, `com.apple.HIToolbox`. Phù hợp với việc chỉ Cài đặt ghi được miền `com.apple.inputsources` (mục 2.6) [Diễn giải mã máy].

**Phía gọi** [Diễn giải mã máy]. Lệnh: `dyld_info -arch arm64e -disassemble …/HIToolbox.framework/Versions/A/HIToolbox`; chuỗi: `strings -a -t x` trên `/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e.03`. Chuỗi trong thư viện: `TSMEnableInputSource %@ `, `/System/Applications/System Settings.app`, `tabID`, `inputSourceToBeEnabled`, `localizedSenderName`, `com.apple.IntlKeyboard`.
- `TISEnableInputSource` nạp tuỳ chọn **0** rồi nhảy vào `TSMEnableInputSourceWithOptions(nguồn, tuỳ chọn)`; `TISEnableInputSourceWithOptions` truyền tuỳ chọn của người gọi.
- Hàm đọc thuộc tính `kTISPropertyInputSourceIsFromSystem` (tên do `dyld_info` gắn). Nếu **bit 1 của tuỳ chọn (giá trị 2)** hoặc thuộc tính này đúng, gọi thẳng `_TSMSetInputSourceEnabled` (bật thật).
- Ngược lại: lấy tên app đang gọi (`GetCurrentAppNameAsCFString`), dựng từ điển ba khoá `tabID` (`com.apple.IntlKeyboard`), `inputSourceToBeEnabled` (nguồn đã "flatten" bằng `_CreateFlattenedInputSource`), `localizedSenderName`; tuần tự hoá thành plist XML; mở `System Settings.app` qua LaunchServices kèm sự kiện; **rồi kết thúc với giá trị trả 0**. Hệ quả khớp việc lệnh trả `noErr` mà không bật.
- `IsFromSystem` có thể nghĩa "đường dẫn bundle bắt đầu bằng `/System/`" (hàm `islcCacheElemIsFromSystem` so 8 byte với một chuỗi mà `dyld_info` liệt kê là `/System/`). [Suy luận, cần kiểm chứng; `dyld_info` liệt kê địa chỉ chuỗi lệch.]
- Cũng trong `HIToolbox`: chuỗi nhật ký "InputSourceFSEventCallback -> TISUpdateIntlFileCache" cùng danh sách thư mục theo dõi (`~/Library/Input Methods/`, `/Library/Input Methods/`, `~/Library/Keyboard Layouts/`…); thư viện tự dựng lại danh mục khi các thư mục này đổi. Việc này có tới được tiến trình Cài đặt không: không tìm thấy nguồn (DTS nói không).

**Phía nhận** (`handleOpenParameter(aeDesc:)`, arm64e, `otool -tV`) [Diễn giải mã máy]:
1. Đọc dữ liệu của sự kiện (`AEGetDescData`), giải plist thành từ điển.
2. Nếu có khoá `inputSourceToBeEnabled`: gọi `ksCreateUnflattenedInputSource` (bao `_CreateUnflattenedInputSource`). Trả NULL thì ghi lỗi "Invalid value on inputSourceToBeEnabled" và kết thúc nhánh.
3. Có nguồn thì lấy `kTISPropertyLocalizedName` ("Can't get localized name" nếu thiếu) và `localizedSenderName` ("Can't get localizedSenderName" nếu thiếu), ghép tiêu đề hộp thoại.
4. Một hàm nhỏ của lớp này gọi `TISEnableInputSourceWithOptions(nguồn, 2)` (`mov w1, #0x2` ngay trước nhánh tới ký hiệu); tên hàm bị lược; gần như chắc là hành động "Cho phép" [Suy luận, cần kiểm chứng].
- `_CreateUnflattenedInputSource` gọi `islGetInputSourceDictFromPrefsDescriptor` rồi `islGetInputSourceList`: nó tìm nguồn trong danh sách nguồn **của tiến trình gọi** (ở đây là Cài đặt); không thấy thì trả NULL.
- Kết hợp với 2.3: hộp thoại chỉ có thể hiện khi Cài đặt nhận sự kiện có `inputSourceToBeEnabled` hợp lệ **và** dựng lại được nguồn; %1 là tên app gọi (`localizedSenderName`), %2 là tên bộ gõ.

**Nhật ký Cài đặt khi Dấu thật bấm "Bật Dấu"** [Máy/Dấu + Máy/hệ thống]. Lệnh: `/usr/bin/log show --last 7d --style compact --predicate 'process == "KeyboardSettings" AND eventMessage CONTAINS "inputSourceToBeEnabled"'`.
- 02/11/2026 16:41:23.957: `KeyboardSettings[73671] … KeyboardSettings.swift handleOpenParameter(aeDesc:) Invalid value on inputSourceToBeEnabled`, nằm sau một dòng mức mặc định `handleOpenParameter(aeDesc:)` của `SettingsViewScene.swift` cùng giây.
- Cùng giây, `Dau[73640]` ghi `event=installed`, `event=register status=0`, `event=enable id=com.codefastlabs.dau.inputmethod.Dau status=0` lúc 16:41:23.091–.140 (`log show --predicate 'subsystem == "com.codefastlabs.dau"'`): tức nút "Bật Dấu" của T4 lần 1; 0,8 s sau Cài đặt báo dòng lỗi. Máy lúc đó còn mục Dấu cũ từ 30/10 (mục 0 (b)4).
- Nghĩa: Cài đặt nhận yêu cầu "bật nguồn" mà không dựng được nguồn, nên theo mã không có hộp thoại. Vì sao dựng lại không được: không tìm thấy nguồn. Giả thuyết hợp với mã: nguồn chưa nằm trong danh sách nguồn của tiến trình Cài đặt lúc đó, liên quan tới chuyện DTS nói Cài đặt "không nhận nguồn mới" cho tới khi đăng xuất. [Suy luận, cần kiểm chứng]
- Truy vấn này cho thêm hai dòng lỗi cùng loại ngày 03/11 từ bản thử, ghi ở mục 8.

**Báo cáo từ dự án khác** [Ngoài]:
- McBopomofo (11/2025) ghi trong mã: "System Settings now asks the user whether to activate the IME", rồi cho trình cài tự đóng sau 60 giây (commit a21ba98; bản sao 257da53 vẫn còn dòng này). vChewing (macOS 12) cũng nói hộp thoại có hiện.
- low-talker (đo trên macOS 15.0.1, 9/2026): hộp thoại Allow hiện lại sau khi người dùng bấm "Không". PR #96.
- msime (macOS 27.0, 26A428, 27/09/2026): với nguồn kiểu `TISTypeKeyboardInputMode`, `TISEnableInputSource` **trả noErr nhưng mode vẫn tắt**; mode `SCIM.Shuangpin` của chính Apple cũng vậy, còn bàn phím `com.apple.keylayout.US` thì bật được. Họ đã bỏ nút "Bật", chỉ còn hướng dẫn mở Cài đặt. PR #2492, `platforms/macos/README.md`.
- marinaMoji (27.0.1): `TISEnableInputSource` mục cha trả 0 ba lần nhưng cha vẫn `enabled=0`; kết luận của họ: "adding a third-party input method is something macOS only lets the user do". Issue #66.
- Các báo cáo này mâu thuẫn bề ngoài (có hộp thoại, không có hộp thoại). **Chưa phân xử**; chưa ai thấy hộp thoại trên máy này (câu hỏi mở d3).

### 2.3 Lần cài đầu có phải đăng xuất không: **câu hỏi mở**

**Bên "phải đăng xuất":**
- Apple DTS (06/2026, Ziqiao Chen; FB23026482): "without the user logging off the system, System Settings doesn't pick up a new input source any more. I don't see anything that can avoid the logoff." Người hỏi (gershnik, 02/2025): trên các macOS gần đây thêm hoặc sửa nguồn trong `<domain>/Library/Input Methods` thì "the user needs to logoff and log back in" để Cài đặt và menu nhập liệu thấy; hỏi có thông báo hay API làm mới không. Thread không nêu tên hàm TIS, không nhắc hộp thoại hay `.inputmethod.`, không nêu cách thay thế. [Apple, diễn đàn 775526, đọc 03/11/2026]
- msime (macOS 27.0 và 27.0.1): ID chưa có trong danh sách nguồn lúc bắt đầu phiên đăng nhập thì không vào được danh sách trong phiên đó. `TISRegisterInputSource` trả noErr nhưng `TISCreateInputSourceList` không thấy. Khởi động lại `imklaunchagent`, `TextInputMenuAgent`, `TextInputSwitcher`, `keyboardservicesd`, chạy `lsregister -f` hay `lsregister -r -domain user` đều không giúp. Đăng nhập lại một lần là được, và các bản cập nhật sau giữ ID đó thì không cần. Sau cài/cập nhật họ dọn bộ đệm `IntlDataCache` của Cài đặt, thoát Cài đặt, dừng extension Bàn phím, `CursorUIViewService`, `TextInputSwitcher`: cách này chỉ sửa chuyện **mode mới của ID đã biết**; họ vẫn giữ thông báo đăng xuất cho ID mới, nêu là hạn chế ở mức sổ đăng ký, không đổi theo cách ký hay nội dung plist. [Ngoài; PR #3738, #2492, `platforms/macos/README.md`, `docs/macos-parity.md`]
- low-talker (macOS 15.0.1): bundle chép vào `~/Library/Input Methods` giữa phiên đăng ký được, nhưng chỉ bật được sau lần đăng nhập sau. [Ngoài]
- README hoặc hướng dẫn của Squirrel (`onConclusion="RequireLogout"`, "log out and log back in to complete installation"), macSKK (nếu không hiện ngay sau cài hoặc cập nhật không đổi thì "ログアウト & ログイン"), Gureum, fcitx5-macos ("After the first time you execute `cmake --install`, you need to logout and login"; các lần sau chỉ cần "Restart" trong menu), XKey ("Cần logout/login sau khi install lần đầu để macOS nhận diện"), AquaSKK ("You might need logout/login to start new AquaSKK process", không nêu bản macOS). [Ngoài, README và mã]
- Squirrel trên tracker (macOS 15.6, 26.1, 26.2; 12/2025 đến 01/2026): sau cài và đăng xuất/khởi động lại vẫn không thấy trong danh sách; người bảo trì lotem (18/12/2025) bảo vào Cài đặt thêm tay bằng nút "+" (#1083, #1082). XKey (macOS 26.1, 22/12/2025): bấm "Cài đặt XKeyIM" thì Cài đặt mở Nguồn nhập liệu nhưng không thấy XKey; người bảo trì bảo chép vào thư mục input sources, chưa nhận thì đăng xuất rồi đăng nhập (#75). [Ngoài]
- Bằng chứng gián tiếp: ở T4 lần 1 (02/11) "+" và menu không có Dấu sau "Bật Dấu", và có sau lần đăng xuất/đăng nhập kế tiếp, nhưng máy không sạch (mục 0 (b)4) nên chỉ là một quan sát phù hợp, không phải phép đo. [Máy/Dấu]

**Bên "không cần / hiện ngay":**
- marinaMoji (máy ảo sạch macOS 27.0.1, `.pkg` vào `/Library/Input Methods`; `postinstall` chạy dưới tên người dùng: `TISRegisterInputSource` → 0; `TISEnableInputSource` các mode → 0; `TISSelectInputSource` mode gốc → -50; cha vẫn `enabled=0`): nguồn **hiện ngay trong "+"**, người dùng tự thêm, dùng được, không đăng xuất. Bản v0.0.14 (có plugin kích hoạt) cho kết quả như nhau. Chỉ thử macOS 27. Có đính chính trong issue: lúc đầu đọc nhầm miền `HIToolbox`, giống Dấu. [Ngoài, issue #66, 15/10/2026]
- Header: đăng ký "so that a TISInputSourceRef can immediately be obtained" (mục 2.1). Đây là tài liệu 2006–2008; quan sát của tabulador (dưới) và msime lệch với câu "immediately". [Apple]
- McBopomofo: mã không đòi đăng xuất cho lần cài đầu (màn hình cuối "Installation Successful – ready to use"; chỉ cảnh báo đăng xuất khi **nâng cấp** mà bản cũ chưa thoát hẳn do translocation; README: kill tiến trình quá nhiều lần trong một phiên thì phải đăng xuất). vChewing: mã dừng `TextInputMenuAgent` rồi chờ 0,5 s với chú thích để "bộ gõ mới hiện trong menu mà không phải đăng xuất". **Cả hai không có số đo trên máy sạch macOS 27**; msime đo thấy cách của vChewing vô tác dụng với ID mới trên 27.0. [Ngoài, mã]

**Khác biệt chưa tách được:** marinaMoji cài ở `/Library/Input Methods`, nhưng Squirrel, macSKK, fcitx5 và Gureum cũng cài ở đó mà vẫn bảo đăng xuất; các yếu tố có thể là thư mục, tiến trình gọi, thời điểm mở Cài đặt lần đầu, hay tên ID: [Suy luận, cần kiểm chứng]. Squirrel (26.2) và marinaMoji (27.0.1) cùng nói người dùng thêm bằng "+" trong Cài đặt; nguồn Squirrel không tuyên bố nguồn có hiện trong "+" ngay sau cài hay không.

**Giả thuyết giải thích (chưa có bằng chứng, [Suy luận, cần kiểm chứng]):** có hai tầng: sổ nguồn đã đăng ký cộng tuỳ chọn người dùng mà `TISCreateInputSourceList` trong một tiến trình mới ghép được, và **danh mục nguồn chụp lúc đăng nhập** mà menu nhập liệu, "+" và ⌃Space dùng; ID chưa có trong danh mục thì không hiện trong phiên đó. Quan sát phù hợp [Máy/hệ thống, 02/11]: `$(getconf DARWIN_USER_CACHE_DIR)/com.apple.Keyboard-Settings.extension/com.apple.IntlDataCache.le.kbdx` có mtime 16:54:04, 17 giây sau khi `TextInputMenuAgent` khởi động (16:53:47), và `AppleInputSourceUpdateTime` là 16:54:30 (giờ +07), cùng lúc đăng nhập; `TextInputMenuAgent` có ký hiệu `managerWithAllInputSources`, `fInputSources`, `handleEnabledInputSourcesChange` (`strings`); `TextInputMenuAgent`, `TextInputSwitcher`, `imklaunchagent` đều là LaunchAgent của phiên đăng nhập (`launchctl print gui/501/…`, `runs = 1`). Phần của giả thuyết cũ cho rằng `TISEnableInputSource` từ app đã ghi tuỳ chọn người dùng **không còn đứng**: mã cho thấy Enable của bên thứ ba nhờ Cài đặt (mục 2.2), nhật ký cho thấy bên thứ ba bị chặn ghi miền đó (mục 2.6).

**Các bộ gõ khác nhắc ba chi tiết liên quan:**
- vChewing cho rằng dừng `TextInputMenuAgent` rồi chờ 0,5 s là khỏi đăng xuất. Không dùng cách này (là tiến trình hệ thống, mục 3).
- tabulador / Tab (PR #9): đăng ký rồi tra `TISCreateInputSourceList` ngay trong tiến trình app chạy lâu thì **trả NULL**; sửa bằng thử lại tối đa 20 lần cách nhau 0,5 s. Bundle của họ đặt `ComponentInvisibleInSystemUI = true` làm nó biến mất khỏi "+" (đổi thành false). Dấu **không** đặt khoá này (đã grep `Apps/DauInputMethod/Info.plist`, 02/11). [Ngoài; Máy/Dấu]
- `enable()` của Dấu bỏ qua mode vì danh sách `known` lấy từ ảnh chụp trong tiến trình app chủ, nên kết quả "enable mode" của app chủ không phản ánh trạng thái hệ thống. [Diễn giải mã máy, đọc mã Dấu 02/11; chưa kiểm]

### 2.4 Các bộ gõ khác làm gì ở lần chạy đầu [Ngoài, mã nguồn]

| Dự án | Chuỗi gọi (theo thứ tự) |
|---|---|
| Squirrel | `.pkg` vào `/Library/Input Methods`. `postinstall`: dừng tiến trình cũ; chạy chính app với `--register-input-source` (`TISRegisterInputSource`, **chỉ khi chưa có mode nào đang bật**); dựng dữ liệu; rồi bằng **tiến trình mới, dưới tên người dùng**, `--enable-input-source` (`TISEnableInputSource` cho **mode** `Hans`, chỉ khi cờ enabled đang false) và `--select-input-source` (`TISSelectInputSource`, chỉ khi đã enabled, chọn được, chưa chọn). Mỗi lệnh là một tiến trình riêng nên mỗi lần liệt kê `TISCreateInputSourceList(nil, true)` là mới. Không dừng tiến trình hệ thống, không chờ thông báo. `RequireLogout`. |
| McBopomofo | Trình cài riêng chép vào `~/Library/Input Methods` (Thùng rác bản cũ, `killall -9`, `cp -R`). Nếu `TISCreateInputSourceList` chưa thấy ID thì `TISRegisterInputSource`, liệt kê lại (không thấy: báo "Fatal Error"). Rồi **luôn** `TISEnableInputSource` cho **mục cha** (từ macOS 12, vì cờ enabled có thể báo sai). Không `Select`, không đụng tiến trình hệ thống; macOS hỏi xác nhận (mục 2.2). |
| vChewing | `.pkg` hoặc trình cài app: chép, bỏ quarantine (`xattr -drs`), dừng tiến trình cũ sau khi chép, rồi `killall TextInputMenuAgent`, chờ 0,5 s, rồi chạy chính IME với `install` bằng tên người dùng: nếu chưa có thì `TISRegisterInputSource`, rồi `TISEnableInputSource` cho **từng mode** (cha không gọi riêng). Không `Select`. Không có mode nào bật thì hiện cảnh báo; nếu không chắc thì báo đăng xuất. Không dừng `imklaunchagent` (app đang gõ mất kết nối tới khi mở lại). |
| XKey (tiếng Việt, IMK) | Chép `XKeyIM.app` vào `~/Library/Input Methods`, `TISRegisterInputSource`, **không enable**, mở Cài đặt › Bàn phím để người dùng tự thêm. |
| macSKK | `.pkg`; `postinstall` chỉ thoát app cũ bằng `osascript`; không gọi TIS; người dùng tự thêm trong Cài đặt. |
| Gureum (Hàn) | `.pkg`; không có script gọi TIS; README hướng dẫn tự thêm trong Cài đặt. |
| fcitx5-macos | `cmake --install` vào `/Library/Input Methods`; không gọi TIS lúc cài. |
| msime | Từng có nút "Bật"; đã bỏ vì trên macOS 27 nút này không có tác dụng; nay chỉ hướng dẫn + mở Cài đặt, kiểm lại mỗi 3 s. |
| marinaMoji (Mozc) | `.pkg` vào `/Library/Input Methods`; `postinstall` chạy dưới tên người dùng (mục 2.3). |
| tabulador / Tab | Đăng ký rồi thăm dò danh sách (mục 2.3). |

Ghi chú: Squirrel chỉ bật **mode**, vChewing chỉ bật **mode**, McBopomofo bật **mục cha**; Dấu bật cha rồi mode. Không dự án nào dùng `kTISNotifyEnabledKeyboardInputSourcesChanged` để chờ khi cài, và không dự án nào dừng `imklaunchagent`. Chỉ vChewing dừng `TextInputMenuAgent`; msime dừng `CursorUIViewService` và `TextInputSwitcher` sau cài.

So với các bộ gõ trên, cách của Dấu (chỉ bật khi người dùng bấm "Bật Dấu", có Hoàn tác; N4) **thận trọng hơn** Squirrel, McBopomofo, vChewing (bật, thậm chí chọn luôn, ngay khi cài) và **ngang** XKey, msime (chỉ hướng dẫn).

### 2.5 Mở đúng màn hình Cài đặt
Các dự án dùng URL `x-apple.systempreferences:com.apple.Keyboard-Settings.extension` (Bàn phím) và `x-apple.systempreferences:com.apple.LoginItems-Settings.extension` (Mục đăng nhập). `KeyboardSettings.appex` trên macOS 27.2 khai báo `allowsXAppleSystemPreferencesURLScheme = true`. [Máy/hệ thống] Apple không công bố danh sách URL này, nên phải thử lại trên từng bản macOS [Suy luận]. Tên trên giao diện tiếng Việt, macOS 27.2: "Bàn phím › Nhập văn bản › Nguồn đầu vào › Sửa…"; "Cài đặt chung › Mục đăng nhập & Phần mở rộng › Mở khi đăng nhập". [Máy/hệ thống, `.loctable`]

### 2.6 Trạng thái "đã bật" lưu ở đâu và cách đọc
- **Nơi lưu** [Máy/hệ thống, 02/11, macOS 27.2]: `defaults read com.apple.inputsources` có `AppleEnabledThirdPartyInputSources` (với hai mục `Keyboard Input Method` cha và `Input Mode` `….Dau.vi` khi máy đang có Dấu từ 30/10). `defaults read com.apple.HIToolbox` có `AppleEnabledInputSources` chỉ gồm nguồn của Apple (U.S., Telex của Apple, `CharacterPaletteIM`, …) và không có Dấu; `AppleInputSourceHistory` và `AppleSelectedInputSources` có Dấu. Nguồn bên thứ ba **không** nằm ở `AppleEnabledInputSources`. Các dòng cũ (30/10) đọc `AppleEnabledInputSources` để kết luận "không có Dấu" đã đọc nhầm miền.
- **Ghi:** tiến trình bên thứ ba bị chặn ghi miền này [Máy/Dấu, 02/11]: log `System Policy: defaults deny user-preference-write com.apple.inputsources`, cfprefsd "rejecting write", dù `TISEnableInputSource`/`TISDisableInputSource` vẫn trả 0 (cả `probe-tis`, công cụ dòng lệnh ngoài repo, cũng bị chặn); `defaults import` từ script dọn máy bị từ chối dù lệnh trả 0. Chỉ Cài đặt hệ thống (và dịch vụ nguồn nhập liệu) ghi được (người dùng gỡ bằng nút "–" thì file ghi lúc 18:07, mục rỗng). Đọc thì được.
- **Cờ `kTISPropertyInputSourceIsEnabled` không đáng tin:** McBopomofo và vChewing đều ghi từ macOS 12 là cờ này có thể báo sai [Ngoài, mã]; marinaMoji ghi enabled=1 trong tiến trình cài mà không lưu [Ngoài]; trên máy này (30/10) mode Telex của Apple báo enabled=1 trong khi input method cha báo 0 [Máy/hệ thống]; sau khi Cài đặt gỡ Dấu bằng "–" (02/11), TIS trong tiến trình mới vẫn báo mode `enabled=true` [Máy/Dấu]. msime: sau khi thay bundle có khoảng vài phút danh sách TIS không ổn định [Ngoài].
- **Cách đọc đề xuất** (không có một con số duy nhất; đọc cả ba nơi):
  1. Tuỳ chọn lưu: `defaults export com.apple.inputsources -` (`AppleEnabledThirdPartyInputSources`; đọc thêm `com.apple.HIToolbox` cho nguồn của Apple) cho biết hệ thống đã nhận lệnh bật hay chưa.
  2. TIS trong **tiến trình mới** (không dùng lại tiến trình đã gọi `Register`), vài lần đọc cách nhau 1–3 s: `kTISPropertyInputSourceIsEnabled`, `IsEnableCapable`, `IsSelectCapable`, `IsSelected`.
  3. Giao diện thật: menu nhập liệu, "+" và danh sách bên trái trong Cài đặt, ⌃Space; hoặc gián tiếp bằng việc tiến trình `DauInputMethod` có chạy khi nguồn được chọn. Không có API công khai đọc tầng này; chỉ nhìn bằng mắt (hoặc chụp ảnh màn hình có sự đồng ý của người dùng).
  [Suy luận, cần kiểm chứng]

### 2.7 Luật `.inputmethod.` trong bundle ID
- Chuỗi `.inputmethod.` có trong `HIToolbox`, ngay cạnh các nhật ký của `TISFileInterrogator` (quét bundle để dựng danh mục: "processing NSExtension-based input method", `InputMethodType`, `/Input Methods/`) và bảng nén ID (`sourceIDsubstringToKey`). [Máy/hệ thống; lệnh `strings`/`dyld_info -all_sections`] Không xác định được chỗ nào dùng chuỗi đó (không tìm thấy tham chiếu mã trực tiếp), cũng không xác định được nó là điều kiện để TIS liệt kê một bundle IMK hay chỉ liên quan tới bộ gõ dạng NSExtension/nén ID. Không tìm thấy nguồn Apple cho luật.
- Mẫu IMKit của ensan-hcl (README, ngày đẩy cuối 18/03/2024): "Create a new project with a bundle identifier that contains `.inputmethod.`", và thêm nguồn bằng Cài đặt › Bàn phím › Nguồn nhập liệu. Đây là lời dặn của một dự án mẫu, **không phải** quy định của Apple. [Ngoài]
- Mọi ID IMK đã gặp trong các tài liệu của Dấu đều chứa `.inputmethod.` (Apple, `org.mozc.inputmethod.Japanese`, `com.codetay.inputmethod.XKey`, và Dấu `com.codefastlabs.dau.inputmethod.Dau`): tương quan, không phải bằng chứng cho luật. [Ngoài]
- Quan sát bằng bản thử về ID có/không có chuỗi này: mục 8. Không dùng ở đây.

## 3. Nâng cấp (bộ gõ đang chạy)

Trình tự đề xuất, ráp từ McBopomofo, vChewing, XKey và D7:
1. App chủ khởi động lại sau khi Sparkle cập nhật. Nó so `CFBundleVersion` của bộ gõ nằm trong app với bản đã cài.
2. Chờ lúc người dùng không gõ (D7).
3. Kiểm chữ ký bản trong app: Team ID đúng, chữ ký hợp lệ.
4. Chép vào một thư mục tạm **trên cùng ổ đĩa** (trong `~/Library/Input Methods`, tên tạm không đuôi `.app` để TIS không quét), rồi **đổi chỗ cả khối** (`FileManager.replaceItemAt`, hoặc đổi tên cái cũ rồi đặt cái mới). Không ghi đè từng file lên bundle đang chạy: tiến trình cũ còn đang ánh xạ các trang mã của nó [Suy luận, cần kiểm chứng; vChewing làm đúng kiểu chép tạm rồi move].
5. Gỡ quarantine của bản mới sau khi đã kiểm chữ ký (làm được vì app chủ không sandbox, D37).
6. Dừng tiến trình cũ (`DauInputMethod`). Hệ thống sẽ chạy bản mới ở phím gõ kế tiếp (đã thấy với `scripts/install-debug.sh`). Cách hợp với cả hai phương án sandbox: app chủ phát thông báo Darwin, bộ gõ tự `exit(0)` khi không có từ đang gõ; quá thời hạn thì app chủ (không sandbox) mới `terminate`. macSKK làm tương tự bằng cách gửi "quit" qua `osascript`. Bộ gõ thoát khi nhận thông báo `quitRequested` đã làm ở 30/10/2026 (`docs/PROGRESS.md`).
7. Gọi lại `TISRegisterInputSource(url)` (Squirrel làm mỗi lần cài; vô hại). Không đụng tới trạng thái bật/chọn: ID giữ nguyên thì lựa chọn của người dùng còn nguyên.

**Không làm:**
- Không dừng `imklaunchagent`. vChewing ghi: dừng nó làm app đang gõ mất kết nối với mọi bộ gõ cho tới khi mở lại app đó. [Ngoài, chú thích trong mã vChewing]
- Không dừng `TextInputMenuAgent`, `CursorUIViewService`, `TextInputSwitcher`, không xoá bộ đệm của Cài đặt Bàn phím (`$(getconf DARWIN_USER_CACHE_DIR)/com.apple.Keyboard-Settings.extension/com.apple.IntlDataCache.le.kbdx`; msime xoá file này, macOS 27.0.1). Đó đều là tiến trình và bộ đệm của hệ thống (tinh thần N4). Giữ biểu tượng và tên không đổi thì không cần làm những việc đó. Nếu một bản có đổi biểu tượng/tên thì ghi trong ghi chú phát hành: "đăng xuất để thấy biểu tượng mới". Dấu đã thấy cả hai bộ đệm ảnh (30/10/2026: ảnh cũ trong `TextInputMenuAgent` chỉ đổi sau khi khởi động lại tiến trình đó; `CursorUIViewService` giữ ảnh cũ). [Máy/Dấu]

**Không được đổi giữa các phiên bản** (đổi là phải đăng xuất, và có thể làm lệch bộ đệm TIS như đã gặp ngày 30/10, mục 0 (b)1):
- `CFBundleIdentifier` của bộ gõ `com.codefastlabs.dau.inputmethod.Dau`, `TISInputSourceID`, ID mode `com.codefastlabs.dau.inputmethod.Dau.vi` (khoá trong `tsInputModeListKey`);
- `InputMethodConnectionName` (`…_Connection`, cũng nằm trong entitlement `mach-register`);
- tên file `DauInputMethod.app` và `CFBundleExecutable` `DauInputMethod` (dùng để tìm và dừng tiến trình);
- `TISIntendedLanguage` `vi` (quyết định nhóm ngôn ngữ trong danh sách thêm nguồn);
- nên giữ: tên hiển thị "Dấu – Tiếng Việt", tên file biểu tượng (bộ đệm chỉ làm mới khi đăng xuất).

## 4. Gỡ cài đặt (D16)

Trình tự đề xuất (người dùng bấm "Gỡ cài đặt…" và xác nhận):
1. Nếu Dấu đang được chọn: chọn trước một bàn phím khác. Đích là `TISCopyCurrentASCIICapableKeyboardLayoutInputSource()` (theo header: bàn phím ASCII dùng gần nhất) nếu nó đang bật; không thì lấy nguồn ASCII đang bật đầu tiên. Gureum dặn người dùng tự chuyển sang bàn phím của hệ thống trước khi gỡ. Nếu không chọn trước, hệ thống sẽ tự đổi sang nguồn khác khi Dấu bị tắt, nhưng chưa biết đổi sang nguồn nào [Suy luận, cần kiểm chứng].
2. `TISDisableInputSource` cho mode `….Dau.vi`, rồi cho input method cha `com.codefastlabs.dau.inputmethod.Dau` (fcitx5 tắt cha). **Đã đo trên macOS 27.2 [Máy/Dấu, 02/11]:** hai lệnh trả 0, nhưng System Policy chặn ghi `com.apple.inputsources`, hai mục Dấu vẫn lưu, TIS vẫn báo `enabled=true`; app **không tự tắt được** nguồn. Chỉ tắt bằng nút "–" trong Cài đặt có hiệu lực. App đã đọc trạng thái thật từ `com.apple.inputsources`, thử tắt lại, và báo `stillEnabled` theo mục còn lưu (`docs/PROGRESS.md`, 02/11). Cách onboarding/gỡ xử lý khi không tự tắt được: mục 6.
3. Dừng tiến trình `DauInputMethod` (như mục 3, bước 6). Đã làm: gỡ cài đặt chuyển vào Thùng rác trước rồi mới yêu cầu thoát (02/11/2026).
4. Chuyển `~/Library/Input Methods/DauInputMethod.app` vào Thùng rác (vChewing, McBopomofo dùng Thùng rác, có thể khôi phục).
5. Nếu tick "Xoá cả cài đặt và quy tắc ứng dụng": xoá dữ liệu trong Group Container của App Group. Container riêng của bộ gõ (`~/Library/Containers/com.codefastlabs.dau.inputmethod.Dau`) để bộ gõ tự dọn tuỳ chọn của nó trước khi thoát. App chủ đụng vào container của app khác có thể làm macOS 14+ hỏi quyền truy cập dữ liệu app khác [Suy luận, cần kiểm chứng].
6. Báo người dùng: tên "Dấu" có thể còn trong danh sách Nguồn đầu vào của Cài đặt tới lần đăng xuất sau. Đã thấy: T4 lần 1 (02/11), sau khi gỡ qua app, danh sách "+" còn một dòng trống tới khi đăng xuất [Máy/Dấu]; Squirrel #1169 (macOS 26, 07–13/08/2026): xoá file mà Cài đặt vẫn liệt kê, lotem: "安裝程序要求重新登錄呢吧" (trình cài yêu cầu đăng nhập lại), "如果系統顯示還有，那就是操作系統的 BUG" [Ngoài]. Cho tới khi đăng xuất, đừng hứa là hết. Cuối cùng, chuyển `Dấu.app` vào Thùng rác (làm được vì app chủ không sandbox) hoặc hướng dẫn người dùng tự kéo.

Câu "Bàn phím đang dùng trước đó được giữ nguyên" trong sheet xác nhận (`docs/UI.md`) chỉ đúng khi làm bước 1 trước bước 2. Phải kiểm ở T4 trước khi để câu này trên giao diện (N5).

## 5. Bộ gõ tiếng Việt cũ cần phát hiện (D14 bước 1)

Bundle ID lấy từ `Info.plist` của bản phát hành tải về từ URL trong cask Homebrew. Chỉ giải nén hoặc mount chỉ đọc, không chạy. [Ngoài, Info.plist bản phát hành, 30/10/2026]

| Bộ gõ | Bundle ID app chính | Tiến trình | Bản | Thoát | Tự chạy khi đăng nhập |
|---|---|---|---|---|---|
| OpenKey | `com.tuyenmai.openkey` | `OpenKey` | 2.0.5 | biểu tượng trên thanh menu › "Thoát" (⌘Q) | tuỳ chọn "Khởi động cùng macOS" trong "Bảng điều khiển…"; helper `com.tuyenmai.OpenKeyHelper` (`SMLoginItemSetEnabled`), thêm `com.tuyenmai.OpenKeyUpdate` |
| EVKey | `com.lamquangminh.evkey` (file `EVKeyMac.app`) | `EVKey` | 3.3.10 | có chuỗi "Quit EVKey" | helper `com.lamquangminh.evkeyhelper` trong `Contents/Library/LoginItems` |
| GoTiengViet | `com.trankynam.GoTiengViet` | `GoTiengViet` | 2.4 (có sandbox) | có chuỗi "Quit GoTiengViet" | chưa rõ |
| XKey | `com.codetay.XKey`; kèm bộ gõ IMK `com.codetay.inputmethod.XKey` (tiến trình `XKeyIM`, cài vào `~/Library/Input Methods`) | `XKey` | 1.2.25 | "Thoát XKey" | tuỳ chọn "Khởi động cùng hệ thống" |
| PHTV | `com.phamhungtien.phtv` | `PHTV` | 3.7.1 | có chuỗi "Quit PHTV" | tuỳ chọn "Khởi động cùng macOS" (`SMAppService`) |
| Gõ Nhanh | `org.gonhanh.GoNhanh` | `GoNhanh` | 1.0.165 | chưa rõ nhãn | có "Launch at login" |
| GoKey (goxkey) | `com.goxkey.app` (theo `Cargo.toml`, chưa kiểm bản build) | — | 0.3.1 | — | — |
| Bộ gõ tiếng Việt của Apple | `com.apple.inputmethod.VietnameseIM`; mode `….VietnameseTelex`, `….VietnameseSimpleTelex`, `….VietnameseVNI`, `….VietnameseVIQR`; bàn phím `com.apple.keylayout.Vietnamese` | là nguồn nhập liệu, không phải app chạy nền | — | — | — |

- **UniKey:** không có app macOS. Engine của nó được tặng Apple năm 2006 và nằm trong bộ gõ tiếng Việt có sẵn của macOS [Ngoài, unikey.org/en/apple.html]. **VietKey:** không tìm thấy bản macOS. **Laban Key:** chỉ có Android, iOS và tiện ích ChromeOS [Ngoài, tìm kiếm 30/10/2026]. Không đưa ba cái này vào danh sách.
- Cask `openkey` và `evkey` đang ở trạng thái disabled trên Homebrew, nhưng người dùng cũ vẫn còn cài nên vẫn phải phát hiện.
- OpenKey, EVKey, GoTiengViet không phải IMK mà chặn phím bằng event tap; không đăng ký nguồn nhập liệu nên không có gì để so ở mục 2. Tracker của EVKey, GoTiengViet (mã đóng): không có báo cáo cài/bật/gỡ trên macOS 26/27; tracker OpenKey, vChewing: không thấy trong kết quả tìm. Kawa, InputSourcePro chỉ chuyển nguồn, không cài bộ gõ, không đọc. Không tìm thấy ghi chú cài đặt của MacishType.
- **Cách phát hiện:**
  - Bộ gõ chặn phím bằng event tap (OpenKey, EVKey, GoTiengViet, XKey, PHTV, Gõ Nhanh, GoKey) biến đổi phím **bất kể nguồn nhập liệu nào đang được chọn**, nên gõ chồng với Dấu. Đây là xung đột thật. Tìm bằng `NSWorkspace.shared.runningApplications`, so `bundleIdentifier`, và chỉ tính tiến trình của người dùng hiện tại (OpenKey tự lọc theo uid vì có chế độ chuyển nhanh người dùng). Đối chiếu bằng bundle ID, không bằng tên tiến trình.
  - Bộ gõ IMK khác (Telex của Apple, `XKeyIM`) chỉ xử lý phím khi chính nó đang được chọn, nên không gõ chồng. Tìm bằng TIS: nguồn đang bật có ngôn ngữ `vi`, khác Dấu. Chỉ nên nhắc nhẹ ("có thể bỏ khỏi danh sách cho gọn"), không chặn bước 1. Máy 30/10 đang bật Telex của Apple.
  - Mục đăng nhập của app khác: không có API công khai để đọc. Chỉ hướng dẫn.
- **Hướng dẫn tắt (N4):** (1) trong app đó, tắt "Khởi động cùng macOS/hệ thống" nếu có. Phải làm trước khi thoát, vì helper sẽ bật lại tuỳ chọn và mở lại app ở lần đăng nhập sau. (2) Bấm biểu tượng trên thanh menu › "Thoát". (3) Nếu vẫn tự chạy lại: Cài đặt chung › Mục đăng nhập & Phần mở rộng, tắt app đó. Kiểm tra lại khi cửa sổ onboarding được kích hoạt (`docs/UI.md`). Không tự thoát app của người khác: trái N4, và cũng không làm được nếu app chủ có sandbox.

## 6. Hệ quả cho Dấu và tình trạng các đề xuất cho DECISIONS

### 6.1 Điều onboarding và gỡ cài đặt có thể dựa vào
Chỉ liệt kê điều có nguồn ở trên; nối về D và N chỉ để tra, không đổi quyết định.
1. **Nút "Bật Dấu" không thể hứa là bật được** (N4, N5): `TISEnableInputSource` của bên thứ ba nhờ Cài đặt hỏi và trả 0 (mục 2.2); marinaMoji cha vẫn `enabled=0`; Squirrel (26.2) người dùng thêm bằng "+". Bắt buộc đọc lại trạng thái sau khi bật (mục 2.6), và có đường lui "mở Cài đặt › Bàn phím, bấm '+'" luôn đúng.
2. **Không hứa có hộp thoại "Cho phép"**: chưa ai thấy nó trên máy này; nhật ký cho thấy Cài đặt có thể bỏ qua sự kiện mà không hỏi (mục 2.2).
3. **Không dùng cờ "enabled" từ tiến trình của chính app làm bằng chứng** (mục 2.6). Không tự chọn nguồn (`TISSelectInputSource`); người dùng chuyển bằng phím tắt của hệ thống.
4. **Đăng xuất:** chưa có cách khẳng định lần cài đầu cần hay không (câu hỏi mở d1). Cho tới khi Dấu thật được thử với danh sách "+" nhìn bằng mắt (D37): chữ trên giao diện về đăng xuất để ô trống (N5), và cách an toàn là "nếu không thấy Dấu trong '+', đăng xuất rồi đăng nhập" như phương án chờ. Artboard `OnboardingLogout` (`docs/UI.md`) chờ người dùng duyệt (`docs/PROGRESS.md`, 02/11/2026). App không tự đăng xuất (N4) và phải nhớ đang ở bước 2 để lần mở sau làm tiếp; macOS có tuỳ chọn "Reopen windows when logging back in" nên app đang mở có thể được mở lại [Suy luận, cần kiểm chứng]. Nút "Đăng xuất…" mở hộp thoại hệ thống cần cách gọi mà không đòi quyền Tự động hoá (AppleScript tới System Events cần quyền đó: chưa kiểm); nếu không thì chỉ hướng dẫn "menu Apple › Đăng xuất…".
5. **Gỡ:** tắt từ Cài đặt (nút "–") có hiệu lực; `TISDisableInputSource` từ app bị chặn ghi (mục 4). Tên có thể còn trong Cài đặt sau khi xoá file; đừng hứa là hết.
6. **Không có hợp đồng công khai:** mọi thứ có thể đổi theo bản macOS. Ghi bản macOS đã thử bên cạnh mỗi câu hướng dẫn.
7. **Dựng lại ảnh chụp trong tiến trình** (hướng C ở mục 7.1): sau `Register`, tra bằng tiến trình con mới và thăm dò đến 20 giây (kiểu Squirrel/tabulador) rồi đọc lại bằng tiến trình mới; không đụng hệ thống, chi phí nhỏ, nên đọc đúng trạng thái dù kết quả thử có thế nào. [Suy luận, cần kiểm chứng]

### 6.2 Đề xuất cho DECISIONS từ T1 (30/10), tình trạng đọc ngày 03/11/2026
- App chủ không sandbox: đã vào **D37**.
- N4 cho D14 bước 2 (chép/đăng ký là phần cài đặt; bật chỉ khi người dùng bấm, có Hoàn tác; đọc lại trạng thái; không tự chọn nguồn): **N4** đã sửa 30/10/2026 (bản trước "Chỉ hướng dẫn hoặc mở đúng màn hình Cài đặt"); câu "macOS tự hỏi xác nhận" của đề xuất cũ không còn được nguồn hỗ trợ (mục 2.2). Phương án thay thế giống msime (bỏ nút bật, chỉ hướng dẫn) còn mở.
- Danh sách định danh không đổi giữa các bản (mục 3): đã vào **D37**.
- Cask chỉ có `app`, `uninstall` gọi lệnh gỡ của app, `zap` xoá container (mục 1.4): đã vào **D37** (cask chỉ khai `app`); chi tiết `uninstall`/`zap` chưa thấy trong `DECISIONS.md`.
- **Chưa thấy trong `DECISIONS.md`:** D14 bước 1 chỉ coi bộ gõ chặn phím đang chạy là xung đột, bộ gõ IMK tiếng Việt khác chỉ nhắc nhẹ (mục 5); D7 thay bộ gõ bằng chép tạm rồi đổi chỗ cả khối, dừng bằng thông báo Darwin, không đụng `imklaunchagent` và bộ đệm hệ thống, chấp nhận biểu tượng cũ còn tới khi đăng xuất (mục 3); D16 trình tự gỡ ở mục 4. Cần người dùng chốt.
- Hướng dẫn trên giao diện (N5): câu về đăng xuất, hộp thoại "Cho phép", và "Bàn phím đang dùng trước đó được giữ nguyên" để dạng ô trống cho tới khi T4 kiểm xong.

## 7. Kế hoạch thử lại T4 bằng Dấu thật trên máy sạch (một lần đăng xuất)

Mục đích: trả lời câu hỏi mở d1 (lần cài đầu có phải đăng xuất để "+" thấy ID mới), bằng Dấu thật, **nhìn danh sách "+" bằng mắt**. Cần người dùng vì đổi nguồn nhập liệu, chiếm màn hình, đăng xuất.

### 7.1 Các hướng có thể làm hiện nguồn không cần đăng xuất (ước lượng, chưa đo)

Xếp hạng là ước lượng của người nghiên cứu từ bằng chứng ở mục 2, **chưa đo**. "Khả năng" là khả năng làm Dấu hiện ra không cần đăng xuất. Chỉ hướng A đến C nằm trong vòng thử; E để chẩn đoán; F không bao giờ vào Dấu.

| # | Hướng | Khả năng | Bằng chứng | Va chạm sổ quyết định |
|---|---|---|---|---|
| **A** | Cài vào `/Library/Input Methods` (cần quyền quản trị: `.pkg` hoặc `osascript … with administrator privileges`) rồi đăng ký | Trung bình (đáng thử nhất vì có một bằng chứng dương duy nhất) | marinaMoji (mục 2.3); nhưng Squirrel, macSKK, fcitx5, Gureum cũng cài ở đó mà vẫn bảo đăng xuất. Rủi ro: hộp thoại mật khẩu quản trị, gỡ cũng cần quản trị, Homebrew/Sparkle phải xử lý quyền | **D16** (`~/Library/Input Methods`), **D6** (DMG, không `.pkg`), **D37**; cần người dùng chốt nếu thành công |
| **B** | Làm mới tiến trình/bộ đệm giao diện sau khi đăng ký và bật: dừng `TextInputMenuAgent` (chờ 0,5 s), `TextInputSwitcher`, `CursorUIViewService`, thoát Cài đặt, dừng extension Bàn phím, xoá `com.apple.IntlDataCache.le*` | Thấp tới trung bình cho **menu**; thấp cho "+" với ID mới | vChewing (mã, không số đo); msime đo trên 27.0/27.0.1: không giúp ID mới, giúp mode mới của ID đã biết. LaunchAgent tự dựng lại tiến trình bị dừng. Đụng tiến trình và bộ đệm hệ thống, thoát Cài đặt có thể làm mất trạng thái đang mở, không có API chính thức, có thể vỡ ở bản macOS sau | **N4** (chỉ chạy khi người dùng bấm một nút rõ ràng, "Làm mới danh sách", có xác nhận); mục 3 ("Không làm") và D37 hiện tránh việc này |
| **C** | Dựng lại ảnh chụp trong tiến trình: sau `Register`, tra bằng tiến trình con mới (kiểu Squirrel: mỗi lệnh một tiến trình) và thăm dò đến 20 giây (kiểu tabulador); bật cha, đợi mode xuất hiện, bật mode, đọc lại bằng tiến trình mới | Thấp để làm hiện giao diện, nhưng nên làm để đọc đúng trạng thái | tabulador sửa lỗi tương tự bằng thử lại; Squirrel mỗi lệnh một tiến trình. Không đụng hệ thống | Không |
| **D** | "Đã bật, chờ đăng xuất" làm đường chính: ghi nhớ trạng thái; mở lại Dấu sau đăng nhập; nút hoặc hướng dẫn đăng xuất | Chắc chắn đúng (Apple DTS); không tránh được đăng xuất | Mục 2.3 | **N4**; `docs/UI.md` artboard `OnboardingLogout` chờ duyệt |
| **E** | Chọn nguồn bằng TIS (`TISSelectInputSource`) sau khi bật, để `imklaunchagent` dựng tiến trình bộ gõ | Rất thấp | marinaMoji: `-50` (paramErr) dù mode đã bật | **N4** ("không tự chọn nguồn"); chỉ đo như chẩn đoán |
| **F** | Dừng `imklaunchagent` hoặc `keyboardservicesd`, `killall cfprefsd`, sửa tay `AppleEnabledThirdPartyInputSources` hay `com.apple.HIToolbox` | Rất thấp | msime: không giúp. vChewing: dừng `imklaunchagent` làm app đang gõ mất kết nối. logcg (blog, Mojave): sửa plist rồi dừng `cfprefsd` "thường không được". Nguy hiểm | **N4** vi phạm rõ; **không làm** |

Thứ tự đề xuất: làm **C** và **D** vì rẻ và không va chạm quyết định nào (đưa vào M5 bất kể kết quả); chạy T4 dưới đây; nếu Dấu chỉ hiện sau khi đăng xuất thì vòng thử bằng bản thử ở mục 8.2 giúp xem có đáng theo **A** hoặc **B** không. Nếu A cho kết quả "hiện ngay, không đăng xuất", đó là thay đổi D16/D6/D37 và phải qua người dùng. Nếu B làm menu hiện ra mà không cần "+", cân nhắc nút "Làm mới danh sách" (vẫn trong N4), kèm ghi chú phát hành cho từng bản macOS.

### 7.2 Chuẩn bị (một lần)
1. Tạo tài khoản macOS mới (chưa từng cài Dấu hay biến thể nào; `docs/PROGRESS.md` 02/11/2026: chỉ dịch vụ nguồn nhập liệu ghi được `com.apple.inputsources`, nên muốn máy sạch thật thì dùng tài khoản mới, mục 2.6), đăng nhập, chờ khoảng một phút cho phiên ổn định. Không cài gì vào `~/Library/Input Methods` trước.
2. Chạy `scripts/clean-dau.sh` (không tham số, chỉ liệt kê) làm mốc "không có Dấu".
3. Mở Terminal thứ hai chạy nhật ký liên tục, ghi vào file có giờ:
   `log stream --info --debug --style compact --predicate 'process IN {"imklaunchagent","TextInputMenuAgent","TextInputSwitcher","keyboardservicesd","CursorUIViewService","cfprefsd","KeyboardSettings"} OR eventMessage CONTAINS[c] "inputsource" OR eventMessage CONTAINS[c] "codefastlabs.dau"' > ~/dau-t4-log.txt`
   (tên tiến trình và bộ lọc [Suy luận, cần kiểm chứng]: chỉnh khi chạy; dữ liệu `<private>` bị che nếu không cài hồ sơ ghi nhật ký. `KeyboardSettings` thêm vào để bắt dòng "Invalid value on inputSourceToBeEnabled", mục 2.2).
4. Ghi giờ đồng hồ vào một file ghi chú mỗi khi bắt đầu một bước, để đối chiếu với nhật ký.

### 7.3 Các bước thử
Mỗi bước: cài, làm đúng chuỗi, chờ 10 giây, rồi chạy bảng kiểm 7.4. Đặt kết quả là `HIỆN` (xuất hiện trong menu/"+"/danh sách bên trái) hoặc `KHÔNG`.

| Bước | ID | Chuỗi gọi | Mục đích | Mức xâm lấn |
|---|---|---|---|---|
| T0 | **Dấu thật** | **Đối chứng**: đúng luồng "Bật Dấu" của app hiện tại (chép bằng đổi tên nguyên khối, `Register`, đợi 1 s, bật cha, đọc lại cùng tiến trình). **Nhìn "+" bằng mắt**, cả menu, danh sách trái, ⌃Space. Chụp `defaults export com.apple.inputsources -` trước và sau lệnh bật | Tái hiện ca T4 lần 1 trên máy sạch; trả lời d1 cho Dấu | Không |
| T9 | (tất cả) | **Đăng xuất, đăng nhập lại (lần duy nhất).** Chạy `scripts/clean-dau.sh` (không tham số) ngay khi vào, rồi nhìn giao diện | Xác nhận đối chứng: ID nào hiện sau đăng nhập, ID nào đã được bật sẵn | Không |

### 7.4 Bảng kiểm sau mỗi bước
1. Cài đặt › Bàn phím › Nguồn nhập liệu › Sửa…: danh sách bên trái, và hộp thoại "+" (tìm "Dấu" ở nhóm tiếng Việt và ô tìm kiếm) (chụp ảnh). **Nhìn bằng mắt.**
2. Menu nhập liệu trên thanh menu, và công tắc ⌃Space (hoặc phím chuyển nguồn): có "Dấu" không (chụp ảnh).
3. Có hộp thoại "Cho phép … bật …?" của hệ thống hiện không; Cài đặt có tự mở không; hiện ở đâu; bấm gì (ghi lại cả khi không hiện).
4. `scripts/clean-dau.sh` (không tham số): mục Dấu trong `com.apple.inputsources`, tiến trình, bundle, đăng ký LaunchServices. Ghi thêm `AppleInputSourceUpdateTime` từ `defaults export com.apple.inputsources -`.
5. Nhật ký `log stream` trong khoảng giờ của bước: các dòng của `imklaunchagent`, `TextInputMenuAgent`, `cfprefsd`, `KeyboardSettings` (nhất là "Invalid value on inputSourceToBeEnabled") và nhật ký `com.codefastlabs.dau` của app (`event=register`, `event=enable`).

Mẫu ghi một dòng cho mỗi bước: `bước | mã trả về Register/Enable | "+" | menu | ⌃Space | hộp thoại / Cài đặt tự mở | tuỳ chọn có (Y/N) | ghi chú`.

### 7.5 Cách đọc kết quả
- **T0 đã HIỆN ngay (không đăng xuất):** câu trả lời d1 cho Dấu là "không cần" trên bản macOS đó; ghi bản macOS.
- **Chỉ T9 làm hiện:** xác nhận kết luận của Apple DTS cho Dấu; làm C + D và đóng việc này.

### 7.6 Việc còn lại ngoài vòng thử, và việc cần người dùng chốt
- Gỡ bản Debug rồi chép lại, **cùng ID** và giữa phiên: TIS có thấy ngay không? Chưa đo.
- (M7) Bản ký Developer ID đã notarize có quarantine: bộ gõ có chạy không, có bị translocate không; và hộp thoại "Cho phép … bật …?" có hiện với bản đó không.
- `TISDisableInputSource` lên mode đang được chọn: hệ thống chuyển sang nguồn nào (mục 4, bước 1).
- Cho phép chạy T4: tạo tài khoản sạch, chiếm màn hình, một lần đăng xuất (người dùng chọn giờ). Vòng thử bằng bản thử (mục 8.2) cần chốt riêng, sau T4.

## 8. Quan sát bằng bản thử (không phải Dấu, không kết luận)

### 8.1 Quan sát (03/11/2026)

Bản thử là bản sao `DauInputMethod.app` Release, đổi bundle ID, ID mode, tên kết nối và tên hiển thị, ký Apple Development. Chưa kiểm bản thử có tái hiện đúng hành vi của Dấu không. Trạng thái đọc bằng `TISCreateInputSourceList` trong một tiến trình dòng lệnh mới (cách đọc từng sai, mục 2.6), trừ chỗ ghi "người dùng xem". Ngày 03/11/2026, macOS 27.2, mỗi biến thể một bản ở `/Library/Input Methods` và một bản ở `~/Library/Input Methods`. Đã gỡ hết bản thử khỏi máy. [Máy/bản thử]

- ID không chứa `.inputmethod.` (`com.codefastlabs.dau.probe.…`): TIS không liệt kê, trước và sau một lần đăng nhập; danh sách "+" không có (người dùng xem).
- ID `com.codefastlabs.dau.inputmethod.Probe…`: TIS liệt kê ngay sau `TISRegisterInputSource`. Danh sách "+" chưa xem.
- `TISEnableInputSource` cho bản thử trả 0, mục cha vẫn tắt, `com.apple.inputsources` không đổi. Gọi từ công cụ dòng lệnh hay từ một app thử có bundle (không sandbox) đều không có hộp thoại xin phép; với app thử, Cài đặt hệ thống tự mở mục Bàn phím (người dùng xem).
- Nhật ký `KeyboardSettings` (cùng truy vấn `log show` ở mục 2.2): 03/11 08:42:17.603 "Invalid value on inputSourceToBeEnabled" sau lệnh `probe-tis enable` lúc 08:42:16; 08:44:56.610 cùng lỗi sau lần app thử có bundle gọi bật lúc 08:44:55. Cùng truy vấn còn thấy hai lần `handleOpenParameter` không kèm lỗi (03/11 08:43:23 và 08:46:12), chưa phân biệt nguồn.

Các quan sát này không trả lời câu hỏi lần cài đầu có phải đăng xuất không; việc đó trả lời bằng Dấu thật theo mục 7, xem cả danh sách "+".

### 8.2 Kế hoạch vòng thử bằng bản thử (chỉ khi T4 bằng Dấu cho thấy phải đăng xuất)

Không thuộc T4. Chỉ chạy nếu T4 (mục 7) cho thấy Dấu cần đăng xuất mới hiện, để tìm cách tránh (hướng A–C ở mục 7.1). Kết quả là quan sát về bản thử, không phải về Dấu; hướng nào có vẻ được thì phải thử lại bằng Dấu thật trước khi đưa vào sản phẩm.

Nguyên lý:
- Điều kiện đáng đo là "**ID chưa từng có trong danh mục đăng nhập của phiên**". Mỗi ID chỉ dùng được **một lần** cho mỗi tài khoản: sau khi đăng xuất và đăng nhập, ID đó đã "bị cháy". Dấu thật là một ID. Để thử thêm hướng nào trong **cùng** phiên đăng nhập, mỗi hướng dùng **một biến thể bộ gõ có ID riêng**.
- Dựng 7 biến thể từ bản Release của `DauInputMethod.app`, đặt tên `DauProbe1` … `DauProbe7`. Mỗi biến thể đổi: tên file `.app`, `CFBundleIdentifier`, `TISInputSourceID` ở mức bundle, khoá mode và `TISInputSourceID` của mode (`….DauProbeN.vi`), `InputMethodConnectionName`, tên hiển thị (để phân biệt trong menu), và `mach-register` trong entitlement (rồi ký lại ad hoc). ID giữ dạng của Dấu, `com.codefastlabs.dau.inputmethod.<Tên>`, để chỉ đổi một biến số (luật `.inputmethod.` còn mở, mục 2.7). Việc dựng nằm ngoài phạm vi tài liệu này: nên giao `imk-dev` hoặc `release-eng` làm một script ném đi (không đưa vào bản phát hành), không sửa mã app. Chưa kiểm chứng rằng biến thể ký ad hoc vẫn nạp được trong sandbox; nếu không, bỏ sandbox cho biến thể (không ảnh hưởng điều cần đo) [Suy luận, cần kiểm chứng].
- Cần một **công cụ đọc** `tis-probe` (script Swift một file, chạy bằng tiến trình mới mỗi lần): in một dòng JSON gồm giờ, danh sách mọi nguồn có `TISInputSourceID` chứa `dau.inputmethod` (id, bundle, loại, enabled, enableCapable, selectCapable, selected), kết quả `defaults export com.apple.inputsources -` và `com.apple.HIToolbox` (`AppleEnabledInputSources`, `AppleInputSourceUpdateTime`), và `pgrep -fl DauProbe`. Có thêm chế độ `--watch` đăng ký `kTISNotifyEnabledKeyboardInputSourcesChanged` và in mỗi lần nhận. (Công cụ dòng lệnh `probe-tis` đã dùng ở 02–03/11 nằm ngoài repo; chưa kiểm có trùng không.)
- **Thứ tự: từ ít xâm lấn đến nhiều**, và **chép biến thể vào `~/Library/Input Methods` ngay trước khi thử nó, không chép trước**. Các bước sau có thể làm tiến trình giao diện nạp lại danh mục và vô tình làm hiện cả biến thể trước đó (và Dấu thật); vì vậy sau **mỗi** bước phải chạy lại `tis-probe` và nhìn giao diện cho **mọi ID đã cài**, không chỉ ID đang thử. Nếu một ID cũ bỗng hiện ra sau bước N, bước N là thủ phạm (ghi lại).


Các bước (sau T0, trước T9 của mục 7.3; bảng kiểm như mục 7.4, thêm: một công cụ đọc `tis-probe` chạy bằng tiến trình mới — ID nào có, enabled / enableCapable / selectCapable / selected, ba lần cách nhau 3 s; `pgrep -fl DauProbe`; thông báo `kTISNotifyEnabledKeyboardInputSourcesChanged` qua `tis-probe --watch`). Cần mật khẩu quản trị ở T6; dừng tiến trình hệ thống ở T3–T5 và T8, chỉ trong tài khoản thử; công cụ và script biến thể do `imk-dev` dựng, để trong `scripts/`, không gắn vào bản phát hành:

| Bước | ID | Chuỗi gọi | Mục đích | Mức xâm lấn |
|---|---|---|---|---|
| T1 | Probe1 | `Register` rồi **thăm dò** `TISCreateInputSourceList` mỗi 0,5 s đến 20 s cho đến khi thấy cha; bật cha; thăm dò đến 20 s cho đến khi thấy mode; bật mode; đọc lại bằng tiến trình mới | Hướng C (chờ, ảnh chụp trong tiến trình) | Không |
| T2 | Probe2 | Kiểu Squirrel: tiến trình 1 chỉ `Register` rồi thoát; tiến trình 2 mới bật cha rồi thoát; tiến trình 3 mới liệt kê và bật mode rồi thoát | Hướng C (mỗi lệnh một tiến trình) | Không |
| T3 | Probe3 | `Register`, bật cha, rồi **chỉ** thoát Cài đặt, xoá `$(getconf DARWIN_USER_CACHE_DIR)/com.apple.Keyboard-Settings.extension/com.apple.IntlDataCache.le*`, dừng extension Bàn phím (tên tiến trình: tra bằng `pgrep -fl Keyboard` lúc Cài đặt đang mở), mở lại Cài đặt › Bàn phím › Nguồn nhập liệu. **Không** dừng gì khác | Hướng B, phần "+" (msime) | Nhẹ: bộ đệm của chính tài khoản này |
| T4 | Probe4 | Kiểu vChewing: dừng `TextInputMenuAgent`, chờ 0,5 s, sau đó `Register`, bật mode (rồi cha nếu cần), đọc lại. Rồi một lần thử thứ hai: đã `Register` xong, dừng `TextInputMenuAgent` lần nữa và nhìn menu | Hướng B, phần menu | Vừa: LaunchAgent của phiên, tự dựng lại |
| T5 | Probe5 | `Register`, bật cha, rồi dừng **cùng lúc** `TextInputSwitcher`, `CursorUIViewService`, `TextInputMenuAgent` (ba lần cách nhau 0,5 s) | Hướng B tối đa, không đụng `imklaunchagent` | Vừa |
| T6 | Probe6 | `sudo` chép vào **`/Library/Input Methods/`** (chủ sở hữu root), `Register` từ tiến trình người dùng, bật cha, bật mode | Hướng A | Cần mật khẩu quản trị; chỉ trên tài khoản thử |
| T7 | Probe7 | Như T0 rồi, **sau cùng**, `TISSelectInputSource` cho mode: ghi mã trả về, xem `DauProbe7` có chạy không (`pgrep`), `TISCopyCurrentKeyboardInputSource` đổi không | Hướng E, chẩn đoán | Nhẹ; chỉ để đo, không đưa vào Dấu (N4) |
| T8 | (không) | **Trần trên, chỉ chẩn đoán, không bao giờ vào Dấu**: sau khi mọi bước trên đã đo, dừng `imklaunchagent` và `keyboardservicesd` rồi nhìn lại mọi ID | Biết có cách làm hiện mà không đăng xuất hay không, và xem tiến trình nào là chủ | Cao: có thể làm hỏng gõ phím trong tài khoản thử; làm cuối cùng |

Cách đọc:
- **T6 (hệ thống) HIỆN, các bước còn lại KHÔNG:** hướng A đáng cân nhắc; mở câu hỏi D16/D6/D37 cho người dùng.
- **T3 làm "+" HIỆN mà menu thì không:** có thể hướng dẫn thêm thủ công (đúng chữ N4) và vẫn không cần đăng xuất; menu sẽ sau.
- **T4/T5 làm menu HIỆN:** cân nhắc nút "Làm mới danh sách" với xác nhận.
- **Một ID cũ bỗng HIỆN sau một bước sau:** ghi bước nào, rồi lặp lại bước đó riêng trên ID mới ở vòng sau (mỗi vòng dùng bộ ID mới `DauProbeB1…`).

## Nguồn

**Apple**
- Header SDK: `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/TextInputSources.h` (`TISRegisterInputSource`, `TISEnableInputSource`, `TISDisableInputSource`, `TISSelectInputSource`, `TISCopyCurrentASCIICapableKeyboardLayoutInputSource`) và `HIToolbox.tbd` cùng SDK.
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

**Hệ thống macOS 27.2 (đọc trên máy)**
- `/System/Library/ExtensionKit/Extensions/KeyboardSettings.appex/Contents/Resources/Localizable.loctable`, `…/LoginItems.appex/…`, `…/GeneralSettings.appex/…`; binary `KeyboardSettings`.
- `HIToolbox` trong dyld cache `/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e*`.

**Ngoài**
- Homebrew Cask Cookbook: https://docs.brew.sh/Cask-Cookbook ; cask JSON: https://formulae.brew.sh/api/cask/{openkey,evkey,gotiengviet,xkey,phtv,gonhanh}.json
- Sparkle, Sandboxing: https://sparkle-project.org/documentation/sandboxing/
- Squirrel: https://github.com/rime/squirrel (`sources/InputSource.swift`, `scripts/postinstall`, `package/Distribution`, `package/conclusion.html`, `README.md`); issue #1083 https://github.com/rime/squirrel/issues/1083 , #1082 https://github.com/rime/squirrel/issues/1082 , #1169 https://github.com/rime/squirrel/issues/1169
- McBopomofo: https://github.com/openvanilla/McBopomofo (`Source/Installer/AppDelegate.swift`, `Packages/InputSourceHelper`, `README.markdown`)
- vChewing: https://github.com/vChewing/vChewing-macOS (`Packages/vChewing_InstallerAssembly4Darwin/…/InstallerVMProtocol.swift`, `ValueAdd/PKGInstallerAssets/pkgPostInstall.sh`, `Packages/vChewing_IMKUtils/…/TISInputSourceExtension.swift`). Commit "Fix IME activation issues on macOS 12" (bản sao): https://testgitea.trustie.net/floraachy/vChewing-macOS/commit/883dc6144662b19f11ca0838a37ba258af5114d1 (không đọc được nội dung vì trang yêu cầu đăng nhập; chỉ dùng tóm tắt từ kết quả tìm kiếm cho ý "cờ enabled có thể báo sai trên macOS 12", đã có mã tương ứng trong McBopomofo)
- macSKK: https://github.com/mtgto/macSKK (`docs/guide/install.md`, `docs/guide/uninstall.md`, `script/scripts/postinstall`)
- fcitx5-macos: https://github.com/fcitx-contrib/fcitx5-macos (`src/config/about.swift`, `assets/uninstall.sh`, `README.md`)
- Gureum: https://github.com/gureum/gureum (`README.md`, `OSX/Gureum.entitlements`)
- XKey: https://github.com/xmannv/xkey (`XKey/Utilities/IMKitHelper.swift`, `XKey/App/XKeyIMUpdateManager.swift`, `XKeyIM/README.md`); issue #75 https://github.com/xmannv/xkey/issues/75
- AquaSKK: https://github.com/codefirst/aquaskk (README)
- msime: https://github.com/metasequoiaime/msime — PR #2492 https://github.com/metasequoiaime/msime/pull/2492 , PR #3738 https://github.com/metasequoiaime/msime/pull/3738 , PR #2481 https://github.com/metasequoiaime/msime/pull/2481 , `platforms/macos/README.md`, `docs/macos-parity.md`
- marinaMoji, issue #66: https://github.com/marinaMoji/marinaMoji/issues/66
- tabulador, PR #9: https://github.com/glrodasz/tabulador/pull/9
- low-talker PR #96: https://github.com/brandon-fryslie/low-talker/pull/96
- Mẫu IMKit của ensan-hcl: https://github.com/ensan-hcl/macOS_IMKitSample_2021
- logcg, kích hoạt bộ gõ không cần khởi động lại (Mojave): https://www.logcg.com/en/archives/3263.html
- OpenKey: https://github.com/tuyenvm/OpenKey (`Sources/OpenKey/macOS/ModernKey/AppDelegate.m`, `OpenKeyHelper/AppDelegate.m`); goxkey: https://github.com/huytd/goxkey (`Cargo.toml`)
- UniKey trên macOS: https://www.unikey.org/en/apple.html
