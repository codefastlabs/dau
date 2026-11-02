# M5 — Cài lần đầu có tránh được đăng xuất không (nghiên cứu)

Ngày 02/11/2026. Máy đọc: macOS 27.2, Xcode 27.1. Mọi thí nghiệm trên máy này **chỉ đọc** (`defaults read`, `ps`, `launchctl print`, `strings`, `ls`). Không đăng ký, bật, chọn hay dừng gì. Bản sao mã nguồn tham khảo nằm ở `/tmp/dau-research/` (ngoài repo, không chép mã vào Dấu): squirrel d220b92, McBopomofo 257da53, vChewing-macOS 8c1bb72, macSKK c812585, gureum 46c62e5, fcitx5-macos 3466612, xkey 398e78e. Bối cảnh: `docs/research/M5-INSTALL.md` (nghiên cứu T1), D37, dòng "M5 T4 lần 1" trong `docs/PROGRESS.md`.

Mức tin cậy ghi sau mỗi khẳng định, cùng quy ước với `M5-INSTALL.md`:
- **[Đã kiểm]**: đọc trực tiếp mã, header SDK, hoặc đo trên máy này.
- **[Nguồn ngoài]**: dự án khác hoặc diễn đàn báo lại, Dấu chưa tự đo.
- **[Suy luận, cần kiểm chứng]**: chưa ai đo; phải thử ở vòng thử ở mục 5.

## 0. Tóm tắt

1. **Không có bộ gõ mã nguồn mở nào chứng minh được cài lần đầu (ID mới) không cần đăng xuất trên macOS 27.** Squirrel, macSKK, Gureum, fcitx5-macos, XKey đều ghi rõ phải đăng xuất. Apple DTS (6/2026) xác nhận không biết cách nào tránh. McBopomofo và vChewing có mã "không cần đăng xuất" nhưng không có số đo nào trên máy sạch macOS 27; msime đo đúng trường hợp đó trên macOS 27.0 và thấy vẫn phải đăng xuất.
2. **Có hai bằng chứng mâu thuẫn nhau cần phân xử bằng thí nghiệm**: msime (27.0): ID mới thì mọi cách làm mới đều vô tác dụng, phải đăng xuất. marinaMoji (máy ảo sạch macOS 27.0.1, cài vào `/Library/Input Methods` bằng `.pkg`): ngay sau khi đăng ký, nguồn **hiện ngay trong "+"** của Cài đặt, không đăng xuất. Dấu (cài vào `~/Library/Input Methods` từ app chủ): không hiện trong "+". Khác biệt có thể do thư mục cài, do tiến trình gọi, hoặc do thời điểm; chưa ai tách riêng được.
3. **Đính chính một chứng cứ cũ của Dấu**: nơi lưu trạng thái "đã bật" của bộ gõ bên thứ ba là `com.apple.inputsources` › `AppleEnabledThirdPartyInputSources`, **không phải** `com.apple.HIToolbox` › `AppleEnabledInputSources`. Câu "`AppleEnabledInputSources` không có Dấu" (đề bài lần này, `M5-INSTALL.md` mục 2.2) đọc nhầm miền, nên không chứng minh gì. Trên máy này, miền đúng có đủ hai mục của Dấu (mục cha và mode `….Dau.vi`), còn miền HIToolbox chỉ có nguồn của Apple, dù Dấu đang chạy bình thường. Đây là bằng chứng mạnh rằng `TISEnableInputSource` **đã ghi đúng** và việc "đã bật" là thật; thứ còn thiếu là phía giao diện.
4. **Giả thuyết thống nhất** (mục 3, [Suy luận, cần kiểm chứng]): có hai tầng. Tầng trạng thái (tuỳ chọn người dùng) ghi được ngay. Tầng danh mục nguồn mà menu nhập liệu và Cài đặt dùng để hiển thị là ảnh chụp lúc đăng nhập; ID chưa có trong ảnh chụp thì không bao giờ hiện trong phiên đó.
5. **Cách chắc chắn duy nhất vẫn là đăng xuất một lần.** Mọi cách khác (mục 4) là thử nghiệm; vài cách phải đụng tiến trình hệ thống, trái tinh thần `M5-INSTALL.md` mục 3 ("Không làm") và phải qua quyết định của người dùng.

## 1. Bảng các dự án

"Cần đăng xuất" là kết luận của chính dự án đó cho lần cài đầu với ID mới.

| Dự án | Chuỗi gọi (theo thứ tự) | Cần đăng xuất lần đầu | Nguồn |
|---|---|---|---|
| **Squirrel** (rime) | `.pkg` cài vào `/Library/Input Methods`. `postinstall`: dừng tiến trình cũ; chạy chính app với `--register-input-source` (gọi `TISRegisterInputSource`, **chỉ khi chưa có mode nào đang bật**); dựng dữ liệu; rồi **bằng tiến trình mới, dưới tên người dùng** `--enable-input-source` (`TISEnableInputSource` cho **mode** `Hans`, chỉ khi cờ enabled đang false) và `--select-input-source` (`TISSelectInputSource`, chỉ khi đã enabled, chọn được, chưa chọn). Mỗi lệnh là một tiến trình riêng nên mỗi lần liệt kê `TISCreateInputSourceList(nil, true)` là mới. Không dừng tiến trình hệ thống, không chờ thông báo. | **Có**: `onConclusion="RequireLogout"`; trang kết thúc: "log out and log back in to complete installation"; README: "初次安裝，如果在部份應用程序中打不出字，請註銷並重新登錄" | [Đã kiểm] `package/Distribution`, `package/conclusion.html`, `scripts/postinstall`, `sources/InputSource.swift`, `README.md` |
| **McBopomofo** | Trình cài riêng: Thùng rác bản cũ, `killall -9`, `cp -R` vào `~/Library/Input Methods`. Nếu `TISCreateInputSourceList` chưa thấy ID thì `TISRegisterInputSource`, liệt kê lại (không thấy: báo "Fatal Error"). Rồi **luôn** `TISEnableInputSource` cho **mục cha** (từ macOS 12, vì cờ enabled có thể báo sai). Không `Select`, không đụng tiến trình hệ thống. Ghi chú trong mã: "System Settings now asks the user whether to activate the IME", tự đóng trình cài sau một lúc. | **Không nói**: màn hình cuối là "Installation Successful – ready to use". Chỉ cảnh báo đăng xuất khi **nâng cấp** mà bản cũ chưa thoát hẳn (translocation). README: nếu kill tiến trình quá nhiều lần trong một phiên thì phải đăng xuất. Không có số đo trên máy sạch. | [Đã kiểm] `Source/Installer/AppDelegate.swift`, `Packages/InputSourceHelper`, `README.markdown` |
| **vChewing** | `.pkg` (và trình cài app): chép, bỏ quarantine (`xattr -drs`), dừng tiến trình cũ sau khi chép, rồi **`killall TextInputMenuAgent`, chờ 0,5 s**, rồi chạy chính IME với `install` bằng tên người dùng: nếu chưa có thì `TISRegisterInputSource`, rồi `TISEnableInputSource` cho **từng mode** (cha không gọi riêng). Không `Select`. Không có mode nào bật thì hiện cảnh báo. Chú thích trong mã: dừng `TextInputMenuAgent` để "bộ gõ mới hiện trong menu mà không phải đăng xuất"; **không** dừng `imklaunchagent` (app đang gõ mất kết nối tới khi mở lại). | **Không** (theo lời mã). **Chưa ai đo** trên máy sạch; msime đo thấy cách này vô tác dụng với ID mới trên macOS 27.0 | [Đã kiểm] `ValueAdd/PKGInstallerAssets/pkgPostInstall.sh`, `Packages/vChewing_InstallerAssembly4Darwin/…/InstallerVMProtocol.swift`, `…/vChewing_IMKUtils/…/TISInputSourceExtension.swift` (lịch sử: các commit 9ba4c4f, 9f9259d tháng 10/2026 bàn về dừng tiến trình cũ, không bàn về chuyện đăng xuất) |
| **macSKK** | `.pkg`; `postinstall` chỉ thoát app cũ bằng `osascript`. Không gọi TIS. Người dùng tự thêm trong Cài đặt. | **Có** (khi "không hiện ngay sau cài hoặc sau cập nhật không đổi": đăng xuất rồi đăng nhập) | [Đã kiểm] `script/scripts/postinstall`, `docs/guide/install.md` |
| **Gureum** (Hàn) | Không có script gọi TIS; README hướng dẫn cài rồi đăng xuất/đăng nhập, sau đó chọn trong Nguồn nhập liệu | **Có** | [Đã kiểm] `README.md` |
| **fcitx5-macos** | `cmake --install` vào `/Library/Input Methods`; không gọi TIS lúc cài | **Có** ("After the first time you execute `cmake --install`, you need to logout and login, then add Fcitx5…"); các lần sau chỉ cần "Restart" trong menu | [Đã kiểm] `README.md` |
| **XKey** (tiếng Việt, IMK) | Chép `XKeyIM.app` vào `~/Library/Input Methods`, `TISRegisterInputSource`, **không enable**, mở Cài đặt › Bàn phím để người dùng tự thêm | **Có** (README: "Cần logout/login sau khi install lần đầu để macOS nhận diện") | [Đã kiểm] `XKey/Utilities/IMKitHelper.swift`, `XKeyIM/README.md` |
| **msime** (Metasequoia IME) | Cách làm cuối: không gọi enable cho mode (vô tác dụng); chỉ hướng dẫn. Đo trên macOS 27.0 (26A428, 27/9/2026) và 27.0.1: ID chưa có ở đầu phiên thì `TISRegisterInputSource` trả noErr nhưng `TISCreateInputSourceList` **không thấy** tới lần đăng nhập sau; khởi động lại `imklaunchagent`, `TextInputMenuAgent`, `TextInputSwitcher`, `keyboardservicesd`, `lsregister -f` và `lsregister -r -domain user` đều không giúp. Sau cài/cập nhật họ dọn bộ đệm `IntlDataCache` của Cài đặt, thoát Cài đặt, dừng extension Bàn phím, `CursorUIViewService`, `TextInputSwitcher`; cách này chỉ sửa chuyện **mode mới của ID đã biết**, và họ vẫn giữ thông báo đăng xuất cho ID mới. | **Có**, cho ID mới (nêu rõ là hạn chế ở mức sổ đăng ký, không đổi theo cách ký hay nội dung plist) | [Nguồn ngoài] `platforms/macos/README.md`, `docs/macos-parity.md`; PR #3738 https://github.com/metasequoiaime/msime/pull/3738 ; PR #2492 https://github.com/metasequoiaime/msime/pull/2492 |
| **marinaMoji** (Mozc) | `.pkg` vào `/Library/Input Methods`; `postinstall` chạy dưới tên người dùng: `TISRegisterInputSource` → 0; `TISEnableInputSource` các mode → 0 (mode bật được); `TISSelectInputSource` mode gốc → **-50**; `TISEnableInputSource` mục cha → 0 **nhưng cha vẫn `enabled=0`** (thử lại 3 lần, cũng vậy). | **Không**: máy ảo sạch macOS 27.0.1, nguồn **hiện ngay trong "+"**, người dùng tự thêm, dùng được; không cần đăng xuất. Bản v0.0.14 (có plugin kích hoạt) cho kết quả y hệt. Chỉ thử macOS 27. | [Nguồn ngoài] https://github.com/marinaMoji/marinaMoji/issues/66 (có đính chính: lúc đầu đọc nhầm miền `HIToolbox`, giống Dấu) |
| **tabulador / Tab** | Đăng ký, rồi tra `TISCreateInputSourceList` ngay trong tiến trình app chạy lâu: **trả NULL**; sửa bằng thử lại tối đa 20 lần cách nhau 0,5 s. macOS mới không bật ngầm; bản thân bundle đặt `ComponentInvisibleInSystemUI = true` làm nó biến mất khỏi hộp thoại "+" (đổi thành false). Không nói tới đăng xuất. | Không nói | [Nguồn ngoài] https://github.com/glrodasz/tabulador/pull/9 |

Ghi chú:
- Dấu **không** đặt `ComponentInvisibleInSystemUI` (đã grep `Apps/DauInputMethod/Info.plist`), nên không dính lỗi của tabulador.
- Squirrel chỉ bật **mode**, vChewing chỉ bật **mode**, McBopomofo bật **mục cha**; Dấu bật cha rồi mode.
- Không dự án nào dùng `kTISNotifyEnabledKeyboardInputSourcesChanged` để chờ khi cài, và không dự án nào dừng `imklaunchagent` (vChewing nêu rõ lý do). Chỉ vChewing dừng `TextInputMenuAgent`; msime dừng `CursorUIViewService` và `TextInputSwitcher` sau cài.

## 2. Nguồn của Apple

- **Apple Developer Forums, thread 775526** "Avoiding logoff when installing new/modified InputMethodKit input source" [Nguồn ngoài, đã đọc]: người hỏi (2/2025) báo trên các macOS gần đây, thêm hoặc sửa nguồn trong `Library/Input Methods` thì phải đăng xuất rồi đăng nhập, Cài đặt và menu nhập liệu mới thấy. Apple DTS (Ziqiao Chen, 6/2026): đúng là không đăng xuất thì Cài đặt không nhận nguồn mới, "không thấy cách nào tránh được", mời gửi Feedback (FB23026482). **Không có cách làm thay thế nào được nêu.** https://developer.apple.com/forums/thread/775526
- **`TextInputSources.h`** (SDK Xcode 27.1, `/Applications/Xcode.app/…/HIToolbox.framework/Versions/A/Headers/TextInputSources.h`) [Đã kiểm]:
  - `TISRegisterInputSource`: "Registers the new input source(s) … so that a `TISInputSourceRef` can immediately be obtained for each of the new input source(s)"; hệ thống "perform any necessary cache rebuilds so that the installer can immediately call `TISCreateInputSourceList`". Header viết từ 2006–2008, **không nói gì về đăng xuất** và không đảm bảo giao diện hiện nguồn. Quan sát của Dấu (cha liệt kê được trong tiến trình gọi, mode chưa) và của msime/tabulador (tra không thấy một lúc) lệch với câu "immediately" này.
  - `TISEnableInputSource`: nguồn phải `IsEnableCapable`; mode cần cha đã bật. Không nói gì về hộp thoại xác nhận.
  - Danh sách ASCII-capable: "a snapshot ... at the time the call was made"; thay đổi bật/tắt phát thông báo phân tán `kTISNotifyEnabledKeyboardInputSourcesChanged`. Đây là **ảnh chụp theo từng lần gọi** của một tiến trình.
  - Header **không có** API làm mới giao diện hay báo hệ thống quét lại thư mục.
- **QA1810** (Apple, Technical Q&A) nói bundle chép vào `~/Library/Input Methods` không hiện trong Nguồn nhập liệu **nếu là kiểu palette** (từ Mavericks). Dấu là bộ gõ bàn phím, không thuộc trường hợp này; chỉ ghi để loại trừ. https://developer.apple.com/library/archive/qa/qa1810/_index.html [Nguồn ngoài, chưa đọc toàn văn; tóm tắt qua tìm kiếm]
- Không tìm thấy trang tài liệu web của Apple cho họ hàm TIS, không thấy bài WWDC nào nói về cài lần đầu. Các báo cáo về macOS 14–27 đều từ dự án bên thứ ba (mục 1), thấp nhất là macOS 12 (hộp thoại xác nhận, từ vChewing/McBopomofo) và 15.0.1 (low-talker, đã nêu ở `M5-INSTALL.md`).

## 3. Vì sao tiến trình mới thấy "đã bật" mà hệ thống không có Dấu

Đây là suy luận từ các điều đo được; **chưa có tài liệu nào của Apple** xác nhận, và `M5-INSTALL.md` mục 2.2 viết kết luận theo miền sai.

**Điều đã đo trên máy này** [Đã kiểm, 02/11/2026]:
1. `defaults read com.apple.inputsources` có `AppleEnabledThirdPartyInputSources` với hai mục của Dấu: `Keyboard Input Method` (cha) và `Input Mode` `….Dau.vi`.
2. `defaults read com.apple.HIToolbox` có `AppleEnabledInputSources` chỉ gồm nguồn của Apple (U.S., Telex của Apple, `CharacterPaletteIM`, …) và không có Dấu; còn `AppleInputSourceHistory`, `AppleSelectedInputSources` có Dấu. Cùng một Dấu đang dùng bình thường: vậy nguồn bên thứ ba **không** nằm ở `AppleEnabledInputSources`.
3. `$(getconf DARWIN_USER_CACHE_DIR)/com.apple.Keyboard-Settings.extension/com.apple.IntlDataCache.le.kbdx` có mtime 16:54:04, tức **17 giây sau khi `TextInputMenuAgent` khởi động (16:53:47)**, và `AppleInputSourceUpdateTime` là 16:54:30 (giờ +07), tức cũng lúc đăng nhập. Hai thông tin này khớp lời msime: bộ đệm danh mục của Cài đặt ghi lúc đăng nhập. Ngoài ra `TextInputMenuAgent` có các ký hiệu `managerWithAllInputSources`, `fInputSources`, `handleEnabledInputSourcesChange` (đọc bằng `strings`): nó giữ một danh sách "tất cả nguồn" và lọc theo tuỳ chọn khi có thông báo bật/tắt. `TextInputMenuAgent`, `TextInputSwitcher`, `imklaunchagent` đều là LaunchAgent của phiên đăng nhập (`launchctl print gui/501/…`, `runs = 1`).

**Giải thích khớp các quan sát** [Suy luận, cần kiểm chứng]:
- `TISEnableInputSource` ghi **tuỳ chọn** của người dùng vào `com.apple.inputsources`. `TISCreateInputSourceList` trong một tiến trình mới ghép (a) sổ nguồn đã đăng ký (có Dấu, vì `TISRegisterInputSource` đã chạy) với (b) tuỳ chọn đó, nên báo cả cha và mode là enabled. Chuyện sau đăng xuất Dấu hiện "có sẵn, không làm thêm gì" khớp với việc tuỳ chọn đã được ghi từ trước. (Mode `….Dau.vi` có `tsInputModeDefaultStateKey = true` nên có thể được bật theo cha, vì vậy tuỳ chọn có cả hai mục dù app chưa gọi enable cho mode; chưa kiểm.)
- Menu nhập liệu, "+" và công tắc ⌃Space không đọc tuỳ chọn trực tiếp mà đọc **danh mục nguồn chụp lúc đăng nhập** (ở `TextInputMenuAgent`, bộ đệm `IntlDataCache` của Cài đặt, và có thể ở một tầng sâu hơn trong dịch vụ nhập liệu của phiên). ID chưa có trong danh mục thì tuỳ chọn "enabled" không có chỗ để hiện. Đây là mô tả "mức sổ đăng ký" mà msime nêu.
- Chuyện "mode `….Dau.vi` chưa có trong `TISCreateInputSourceList` của **chính app chủ**" có thể là ảnh chụp riêng trong tiến trình app chủ chưa cập nhật (tabulador thấy đúng điều này; msime thấy cửa sổ "phút" tra không thấy rồi tự khỏi). Tiến trình mới thấy được vì nó chụp lại. Hệ quả cho code: `enable()` của Dấu bỏ qua mode vì `known` lấy từ ảnh chụp trong tiến trình app chủ; kết quả "enable mode" của app chủ **không phản ánh trạng thái hệ thống**.

**Cách đọc trạng thái thật**: không có một con số duy nhất; có ba tầng và cần đọc cả ba, với "tầng 3" là thứ người dùng quan tâm:
1. **Tuỳ chọn**: `defaults export com.apple.inputsources -` (mục `AppleEnabledThirdPartyInputSources`; đọc cả `com.apple.HIToolbox` cho nguồn của Apple). Cho biết hệ thống đã nhận lệnh bật hay chưa.
2. **TIS trong tiến trình mới** (không dùng lại tiến trình đã gọi `Register`), kèm vài lần đọc cách nhau 1–3 s: `kTISPropertyInputSourceIsEnabled`, `IsEnableCapable`, `IsSelectCapable`, `IsSelected`. Cờ enabled không đáng tin tuyệt đối (McBopomofo/vChewing, từ macOS 12).
3. **Giao diện thật**: menu nhập liệu, "+" và danh sách bên trái trong Cài đặt, ⌃Space; hoặc gián tiếp bằng tiến trình `DauInputMethod` có chạy khi nguồn được chọn. Không có API công khai đọc tầng này; chỉ nhìn bằng mắt (hoặc chụp ảnh màn hình có sự đồng ý của người dùng).

Cho app chủ: khi "tầng 1 và 2 báo bật nhưng người dùng không thấy" (đúng ca đã gặp), điều đó **không** phải là "chưa bật được" mà là "đã bật, chưa hiện". Câu hướng dẫn nên khác: đăng xuất, không phải "tự thêm trong Cài đặt".

## 4. Các hướng cho Dấu, xếp theo khả năng

Xếp hạng là ước lượng của người nghiên cứu từ bằng chứng ở mục 1–3, **chưa đo**. "Khả năng" là khả năng làm Dấu hiện ra **không cần đăng xuất**.

| # | Hướng | Khả năng | Bằng chứng | Rủi ro, chi phí | Va chạm sổ quyết định |
|---|---|---|---|---|---|
| **A** | **Cài vào `/Library/Input Methods`** (cần quyền quản trị: `.pkg` hoặc `osascript … with administrator privileges`) rồi đăng ký | Trung bình (đáng thử nhất, vì có một bằng chứng dương duy nhất) | marinaMoji: máy ảo sạch macOS 27.0.1, `.pkg` ở `/Library/Input Methods`, nguồn hiện trong "+" ngay, không đăng xuất. Nhưng bốn dự án khác (Squirrel, macSKK, fcitx5, Gureum) cũng cài ở thư mục đó mà vẫn bảo đăng xuất; khác biệt có thể nằm chỗ khác (thời điểm Cài đặt được mở lần đầu, tên ID) | Hộp thoại mật khẩu quản trị; bộ gõ chạy với quyền người dùng nhưng nằm trong thư mục hệ thống nên gỡ cũng cần quản trị; Homebrew/Sparkle phải xử lý quyền | **D16** ("bộ gõ nằm trong `~/Library/Input Methods`"), **D6** (DMG, không `.pkg`), **D37** (app chủ chép trực tiếp); cần người dùng chốt nếu thành công |
| **B** | **Làm mới các tiến trình/bộ đệm giao diện** sau khi đăng ký và bật: dừng `TextInputMenuAgent` (chờ 0,5 s), `TextInputSwitcher`, `CursorUIViewService`, thoát Cài đặt, dừng extension Bàn phím, xoá `com.apple.IntlDataCache.le*` | Thấp tới trung bình cho **menu**; thấp cho "+" với ID mới | vChewing (mã, không số đo); msime đo trên 27.0/27.0.1: không giúp ID mới, giúp mode mới của ID đã biết. LaunchAgent tự dựng lại tiến trình bị dừng | Đụng tiến trình và bộ đệm của hệ thống; thoát Cài đặt có thể làm mất trạng thái đang mở của người dùng; không có API chính thức; có thể vỡ ở bản macOS sau. Chỉ nên chạy khi người dùng bấm một nút rõ ràng ("Làm mới danh sách") | **N4** (đổi trạng thái hệ thống phải có nút do người dùng bấm, có xác nhận); `M5-INSTALL.md` mục 3 ("Không làm") và D37 (nhắc N4) hiện tránh việc này |
| **C** | **Dựng lại ảnh chụp trong tiến trình**: sau khi `Register`, tra bằng tiến trình con mới (kiểu Squirrel: mỗi lệnh một tiến trình) và thăm dò đến 20 giây (kiểu tabulador); bật cha, đợi mode xuất hiện, bật mode, rồi đọc lại bằng tiến trình mới | Thấp để làm **hiện giao diện** (nhưng rất nên làm để đọc trạng thái đúng) | Giải thích ở mục 3: tiến trình mới thấy; tabulador sửa lỗi tương tự bằng thử lại | Không đụng hệ thống. Chi phí nhỏ. Sửa được câu "chưa bật được… tự thêm" sai của T4 lần 1 | Không |
| **D** | **Thêm gợi ý "đã bật, chờ đăng xuất" làm đường chính**, tối ưu trải nghiệm: nhận biết ca (tuỳ chọn có, giao diện chưa) bằng mục 3; ghi nhớ trạng thái; mở lại Dấu sau đăng nhập (macOS có tuỳ chọn "Reopen windows when logging back in" khi đăng xuất, [Suy luận, cần kiểm chứng] app đang mở sẽ được mở lại); có nút "Đăng xuất…" mở hộp thoại đăng xuất chuẩn của hệ thống nếu cách đó làm được mà không cần quyền Tự động hoá | Chắc chắn đúng (Apple DTS xác nhận); không tránh được đăng xuất | `TISEnableInputSource` đã ghi tuỳ chọn trước khi đăng xuất nên sau đăng nhập Dấu **tự có sẵn** (đã gặp ở T4 lần 1) | Nút "Đăng xuất…" cần cách gọi hộp thoại đăng xuất (AppleScript tới System Events cần quyền Tự động hoá: chưa kiểm, có thể chỉ hướng dẫn "menu Apple › Đăng xuất…") | **N4** (nút do người dùng bấm, hộp thoại hệ thống xác nhận); `docs/UI.md` artboard `OnboardingLogout` đã chờ duyệt |
| **E** | **Chọn nguồn bằng TIS** (`TISSelectInputSource`) sau khi bật, để `imklaunchagent` dựng tiến trình bộ gõ | Rất thấp để làm hiện giao diện | marinaMoji: `-50` (paramErr) dù mode đã bật. Đề bài lần này cũng: tiến trình bộ gõ chưa từng chạy | Không đáng làm | **N4** ("không tự chọn nguồn"); chỉ đo như chẩn đoán |
| **F** | Dừng `imklaunchagent` hoặc `keyboardservicesd`, `killall cfprefsd`, sửa tay `AppleEnabledThirdPartyInputSources` hay `com.apple.HIToolbox` | Rất thấp | msime: không giúp. vChewing: dừng `imklaunchagent` làm app đang gõ mất kết nối. logcg (blog, Mojave): sửa plist rồi dừng `cfprefsd` "thường không được" | Nguy hiểm: mất kết nối bộ gõ ở mọi app; ghi tay vào miền tuỳ chọn của hệ thống | **N4** vi phạm rõ; **không làm** |

**Đề xuất thứ tự**: làm **C** và **D** vì chắc chắn, rẻ và không va chạm quyết định nào (đưa vào M5 bất kể kết quả), đồng thời chạy vòng thử ở mục 5 để quyết định có đáng theo **A** hoặc **B** hay không. Nếu A cho kết quả "hiện ngay, không đăng xuất", đó là thay đổi D16/D6/D37 và phải qua người dùng. Nếu B làm menu hiện ra mà không cần "+", cân nhắc nút bấm "Làm mới danh sách" (vẫn trong N4), kèm ghi chú phát hành cho từng bản macOS.

## 5. Vòng thử trên một máy sạch (một lần đăng xuất)

### 5.1 Nguyên lý

- Điều kiện đáng đo là "**ID chưa từng có trong danh mục đăng nhập của phiên**". Mỗi ID chỉ dùng được **một lần** cho mỗi tài khoản: sau khi đăng xuất và đăng nhập, ID đó đã "bị cháy". Để thử nhiều hướng trong **một** phiên đăng nhập, mỗi hướng dùng **một biến thể bộ gõ có ID riêng**.
- Dựng 8 biến thể từ bản Release của `DauInputMethod.app`, đặt tên `DauProbe1` … `DauProbe8`. Mỗi biến thể đổi: tên file `.app`, `CFBundleIdentifier`, `TISInputSourceID` ở mức bundle, khoá mode và `TISInputSourceID` của mode (`….DauProbeN.vi`), `InputMethodConnectionName`, tên hiển thị (để phân biệt trong menu), và `mach-register` trong entitlement (rồi ký lại ad hoc). **Việc dựng nằm ngoài phạm vi tài liệu này**: nên giao `imk-dev` hoặc `release-eng` làm một script ném đi (không đưa vào bản phát hành), không sửa mã app. Chưa kiểm chứng rằng biến thể ký ad hoc vẫn nạp được trong sandbox; nếu không, bỏ sandbox cho biến thể (không ảnh hưởng điều cần đo, [Suy luận, cần kiểm chứng]).
- Cần một **công cụ đọc** `tis-probe` (script Swift một file, chạy bằng tiến trình mới mỗi lần): in một dòng JSON gồm giờ, danh sách mọi nguồn có `TISInputSourceID` chứa `dau.inputmethod` (id, bundle, loại, enabled, enableCapable, selectCapable, selected), kết quả `defaults export com.apple.inputsources -` và `com.apple.HIToolbox` (`AppleEnabledInputSources`, `AppleInputSourceUpdateTime`), và `pgrep -fl DauProbe`. Có thêm chế độ `--watch` đăng ký `kTISNotifyEnabledKeyboardInputSourcesChanged` và in mỗi lần nhận.
- **Thứ tự: từ ít xâm lấn đến nhiều**, và **chép biến thể vào `~/Library/Input Methods` ngay trước khi thử nó, không chép trước**. Các bước sau có thể làm tiến trình giao diện nạp lại danh mục và vô tình làm hiện cả biến thể trước đó; vì vậy sau **mỗi** bước phải chạy lại `tis-probe` và nhìn giao diện cho **mọi biến thể đã cài**, không chỉ biến thể đang thử. Nếu một biến thể cũ bỗng hiện ra sau bước N, bước N là thủ phạm (ghi lại).

### 5.2 Chuẩn bị (một lần)

1. Tạo tài khoản macOS mới (chưa từng cài Dấu hay biến thể nào), đăng nhập, chờ khoảng một phút cho phiên ổn định. Không cài gì vào `~/Library/Input Methods` trước.
2. Chạy `tis-probe` một lần làm mốc "không có Dấu".
3. Mở Terminal thứ hai chạy nhật ký liên tục, ghi vào file có giờ:
   `log stream --info --debug --style compact --predicate 'process IN {"imklaunchagent","TextInputMenuAgent","TextInputSwitcher","keyboardservicesd","CursorUIViewService","cfprefsd"} OR eventMessage CONTAINS[c] "inputsource" OR eventMessage CONTAINS[c] "DauProbe"' > ~/dau-probe-log.txt`
   (tên tiến trình và bộ lọc là [Suy luận, cần kiểm chứng]; chỉnh khi chạy; dữ liệu `<private>` sẽ bị che nếu không cài hồ sơ ghi nhật ký). Terminal thứ ba chạy `tis-probe --watch`.
4. Ghi giờ đồng hồ vào một file ghi chú mỗi khi bắt đầu một biến thể, để đối chiếu với nhật ký.

### 5.3 Các bước thử

Mỗi bước: cài biến thể, làm đúng chuỗi, chờ 10 giây, rồi chạy bảng kiểm 5.4. Đặt "kết quả" là `HIỆN` (xuất hiện trong menu/“+”/danh sách bên trái) hoặc `KHÔNG`.

| Bước | Biến thể | Chuỗi gọi | Mục đích | Mức xâm lấn |
|---|---|---|---|---|
| T0 | Probe1 | **Đối chứng**: đúng như app chủ hiện tại: chép bằng đổi tên nguyên khối, `Register`, đợi 1 s, bật cha, đọc lại (cùng tiến trình) | Tái hiện lỗi đã gặp. Quan trọng nhất: so `defaults export` **trước và sau** lệnh bật để chứng minh giả thuyết mục 3 (tuỳ chọn đã ghi, giao diện chưa hiện) | Không |
| T1 | Probe2 | `Register` rồi **thăm dò** `TISCreateInputSourceList` mỗi 0,5 s đến 20 s cho đến khi thấy cha; bật cha; thăm dò đến 20 s cho đến khi thấy mode; bật mode; đọc lại bằng tiến trình mới | Hướng C (chờ, ảnh chụp trong tiến trình) | Không |
| T2 | Probe3 | Kiểu Squirrel: tiến trình 1 chỉ `Register` rồi thoát; tiến trình 2 mới bật cha rồi thoát; tiến trình 3 mới liệt kê và bật mode rồi thoát | Hướng C (mỗi lệnh một tiến trình) | Không |
| T3 | Probe4 | `Register`, bật cha, rồi **chỉ** thoát Cài đặt, xoá `$(getconf DARWIN_USER_CACHE_DIR)/com.apple.Keyboard-Settings.extension/com.apple.IntlDataCache.le*`, dừng extension Bàn phím (tên tiến trình: tra bằng `pgrep -fl Keyboard` lúc Cài đặt đang mở), mở lại Cài đặt › Bàn phím › Nguồn nhập liệu. **Không** dừng gì khác | Hướng B, phần "+" (msime) | Nhẹ: bộ đệm của chính tài khoản này |
| T4 | Probe5 | Kiểu vChewing: dừng `TextInputMenuAgent`, chờ 0,5 s, sau đó `Register`, bật mode (rồi cha nếu cần), đọc lại. Rồi một lần thử thứ hai: đã `Register` xong, dừng `TextInputMenuAgent` lần nữa và nhìn menu | Hướng B, phần menu | Vừa: LaunchAgent của phiên, tự dựng lại |
| T5 | Probe6 | `Register`, bật cha, rồi dừng **cùng lúc** `TextInputSwitcher`, `CursorUIViewService`, `TextInputMenuAgent` (ba lần cách nhau 0,5 s) | Hướng B tối đa, không đụng `imklaunchagent` | Vừa |
| T6 | Probe7 | `sudo` chép vào **`/Library/Input Methods/`** (chủ sở hữu root), `Register` từ tiến trình người dùng, bật cha, bật mode | Hướng A | Cần mật khẩu quản trị; chỉ trên tài khoản thử |
| T7 | Probe8 | Như T0 rồi, **sau cùng**, `TISSelectInputSource` cho mode: ghi mã trả về, xem `DauProbe8` có chạy không (`pgrep`), `TISCopyCurrentKeyboardInputSource` đổi không | Hướng E, chẩn đoán | Nhẹ; chỉ để đo, không đưa vào Dấu (N4) |
| T8 | (không) | **Trần trên, chỉ chẩn đoán, không bao giờ vào Dấu**: sau khi mọi bước trên đã đo, dừng `imklaunchagent` và `keyboardservicesd` rồi nhìn lại mọi biến thể | Biết có cách làm hiện mà không đăng xuất hay không, và xem tiến trình nào là chủ | Cao: có thể làm hỏng gõ phím trong tài khoản thử; làm cuối cùng |
| T9 | (tất cả) | **Đăng xuất, đăng nhập lại (lần duy nhất).** Chạy `tis-probe` ngay khi vào, rồi nhìn giao diện | Xác nhận đối chứng: biến thể nào hiện sau đăng nhập, biến thể nào đã được bật sẵn (kỳ vọng: tất cả, như Dấu ở T4 lần 1) | Không |

### 5.4 Bảng kiểm sau mỗi bước (và cho **mọi** biến thể đã cài)

1. `tis-probe`: ID nào có trong danh sách, enabled / enableCapable / selectCapable / selected. Chạy **ba lần**, cách nhau 3 s.
2. `defaults export com.apple.inputsources -`: `AppleEnabledThirdPartyInputSources` có mục của biến thể không (cha và/hoặc mode). Chụp lại `AppleInputSourceUpdateTime`.
3. Menu nhập liệu trên thanh menu: có mục của biến thể không (chụp ảnh).
4. Cài đặt › Bàn phím › Nguồn nhập liệu › Sửa…: danh sách bên trái, và hộp thoại "+" (tìm theo tên biến thể ở nhóm tiếng Việt và ô tìm kiếm) (chụp ảnh).
5. Công tắc ⌃Space (hoặc phím chuyển nguồn): có biến thể không.
6. `pgrep -fl DauProbe`: tiến trình biến thể có chạy không (đúng khi nguồn được chọn).
7. Nhật ký `log stream` trong khoảng giờ của bước; ghi các dòng của `imklaunchagent`, `TextInputMenuAgent`, `TextInputSwitcher`, `cfprefsd` có nhắc tên biến thể.
8. Thông báo `kTISNotifyEnabledKeyboardInputSourcesChanged` có nhận được sau lệnh bật không (từ `tis-probe --watch`).
9. Có hộp thoại "Cho phép … bật …?" của hệ thống hiện không; hiện ở đâu; bấm gì (ghi lại cả khi không hiện).

Mẫu ghi một dòng cho mỗi bước: `bước | biến thể | mã trả về Register/Enable | tuỳ chọn có (Y/N) | TIS mới thấy (cha/mode) | menu | "+" | trái | ⌃Space | tiến trình | ghi chú`.

### 5.5 Cách đọc kết quả

- **T0 cho "tuỳ chọn có, giao diện KHÔNG"**: giả thuyết mục 3 đúng; đường chính là D (hướng dẫn đăng xuất). Nếu T0 cho "tuỳ chọn không có", giả thuyết sai và phải xem lại (khi đó `TISEnableInputSource` trong app chủ không ghi được, và "sau đăng xuất Dấu tự có" cần giải thích khác).
- **T6 (hệ thống) HIỆN, các bước còn lại KHÔNG**: hướng A đáng cân nhắc; mở câu hỏi D16/D6/D37 cho người dùng.
- **T3 làm "+" HIỆN mà menu thì không**: có thể hướng dẫn thêm thủ công (đúng chữ N4) và vẫn không cần đăng xuất; menu sẽ sau.
- **T4/T5 làm menu HIỆN**: cân nhắc nút "Làm mới danh sách" với xác nhận.
- **Một biến thể cũ bỗng HIỆN sau một bước sau**: ghi bước nào, rồi lặp lại bước đó riêng trên ID mới ở vòng sau (mỗi vòng dùng bộ ID mới `DauProbeB1…`).
- **Chỉ T9 làm hiện**: xác nhận kết luận của Apple DTS cho Dấu; làm C + D và đóng việc này.

## 6. Việc cần người dùng chốt

1. Cho phép làm vòng thử mục 5 (tạo tài khoản sạch, chiếm màn hình, một lần đăng xuất; có bước cần mật khẩu quản trị ở T6; có bước dừng tiến trình hệ thống ở T3–T5 và T8, chỉ trong tài khoản thử).
2. Giao ai dựng `tis-probe` và script biến thể (đề xuất `imk-dev`, một lần, bỏ vào `scripts/` không gắn vào bản phát hành, hoặc để ngoài repo).
3. Nếu hướng A (thư mục hệ thống) cho kết quả tốt: có chấp nhận đổi D16, D6, D37 không.

## 7. Đính chính cần ghi lại ở chỗ khác (chưa sửa; không thuộc phạm vi tài liệu này)

- `docs/research/M5-INSTALL.md` mục 2.2 và dòng "M5 T4 lần 1" trong `docs/PROGRESS.md` nêu "`AppleEnabledInputSources` không có Dấu" làm bằng chứng. Miền đúng là `com.apple.inputsources` › `AppleEnabledThirdPartyInputSources` (mục 3 ở đây); kết luận "không tin cờ enabled" trong mục 2.2 vẫn cần xét lại theo ba tầng.
- `D37` ghi "Lần cài đầu **có thể** phải đăng xuất"; T4 lần 1 và các nguồn mục 1 cho thấy gần như chắc chắn là **phải**. Việc sửa chữ là của phiên chính.
- Câu hướng dẫn hiện tại ("Chưa bật được… tự thêm") sai trong ca đã gặp (mục 3); đã có artboard `OnboardingLogout` chờ duyệt.

## Nguồn

- Apple Developer Forums, thread 775526: https://developer.apple.com/forums/thread/775526
- Header SDK `TextInputSources.h` (xem đường dẫn ở mục 2).
- Apple QA1810: https://developer.apple.com/library/archive/qa/qa1810/_index.html
- Squirrel: https://github.com/rime/squirrel (`package/Distribution`, `package/conclusion.html`, `scripts/postinstall`, `sources/InputSource.swift`, `README.md`)
- McBopomofo: https://github.com/openvanilla/McBopomofo (`Source/Installer/AppDelegate.swift`, `Packages/InputSourceHelper`, `README.markdown`)
- vChewing: https://github.com/vChewing/vChewing-macOS (`ValueAdd/PKGInstallerAssets/pkgPostInstall.sh`, `Packages/vChewing_InstallerAssembly4Darwin/…/InstallerVMProtocol.swift`, `Packages/vChewing_IMKUtils/…/TISInputSourceExtension.swift`)
- macSKK: https://github.com/mtgto/macSKK (`script/scripts/postinstall`, `docs/guide/install.md`)
- Gureum: https://github.com/gureum/gureum (`README.md`)
- fcitx5-macos: https://github.com/fcitx-contrib/fcitx5-macos (`README.md`)
- XKey: https://github.com/xmannv/xkey (`XKey/Utilities/IMKitHelper.swift`, `XKeyIM/README.md`)
- msime: https://github.com/metasequoiaime/msime — PR #2492 (https://github.com/metasequoiaime/msime/pull/2492), PR #3738 (https://github.com/metasequoiaime/msime/pull/3738), PR #2481 (https://github.com/metasequoiaime/msime/pull/2481), `platforms/macos/README.md`, `docs/macos-parity.md`
- marinaMoji, issue #66: https://github.com/marinaMoji/marinaMoji/issues/66
- tabulador, PR #9: https://github.com/glrodasz/tabulador/pull/9
- logcg, kích hoạt bộ gõ không cần khởi động lại (Mojave): https://www.logcg.com/en/archives/3263.html
- vChewing, commit "Fix IME activation issues on macOS 12" (bản sao): https://testgitea.trustie.net/floraachy/vChewing-macOS/commit/883dc6144662b19f11ca0838a37ba258af5114d1 (không đọc được nội dung vì trang yêu cầu đăng nhập; chỉ dùng tóm tắt từ kết quả tìm kiếm cho ý "cờ enabled có thể báo sai trên macOS 12", đã có mã tương ứng trong McBopomofo)
