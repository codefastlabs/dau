# Lịch sử các tài liệu nghiên cứu

Ghi lại quá khứ: kế hoạch đã bỏ hay đã xong, các vòng thử theo giờ, danh sách đã duyệt và các bước chốt quyết định, chuyển khỏi ba tài liệu nghiên cứu khi chúng được viết lại chỉ còn hiện trạng (11/11/2026). Chép nguyên văn từ bản ngay trước đó (commit `01bce82`), chỉ hạ một bậc tiêu đề; số mục dẫn trong từng phần là số mục **cũ** của file gốc, đọc bản cũ bằng `git show 01bce82:<đường dẫn>`. Kết luận còn đúng nằm ở tài liệu hiện hành, không ở đây.

## 1. `docs/research/INPUT-METHOD-INSTALL.md`

Bảng đổi số mục cũ sang mục mới nằm ở cuối phần này.

### 1.1 Hai đợt đọc mã nguồn tham khảo

Bản sao mã nguồn tham khảo (ngoài repo, không chép mã nào vào Dấu), hai đợt đọc:
- 30/10: Squirrel 46962d2, McBopomofo 18e2060, vChewing 7c82f5f, macSKK 539cce3, fcitx5-macos 3466612, Gureum 46c62e5, XKey 398e78e, goxkey b197c57, OpenKey 89c2fd3.
- 02/11 (`/tmp/dau-research/`): Squirrel d220b92, McBopomofo 257da53, vChewing-macOS 8c1bb72, macSKK c812585, Gureum 46c62e5, fcitx5-macos 3466612, XKey 398e78e.

### 1.2 Mục 4.1 cũ: xếp hạng các hướng, kế hoạch đo và kết quả (04/11/2026)

**Đề xuất xếp hạng** (của người nghiên cứu, 03/11/2026; không còn cần sau khi D37 (Cài đặt bộ gõ) chốt cách bật không đăng xuất):
1. Hướng dẫn người dùng bấm "–" làm đường chính của "Gỡ cài đặt".
2. Cài lại rồi bấm "–" làm đường cứu khi bundle đã bị xoá trước ("cài lại Dấu rồi gỡ bằng nút trong app"); phép hồi sinh mục ẩn đã đạt (kết quả cuối mục).
3. Không làm tám hướng còn lại (từ tắt bằng `TISDisableInputSource` tới Full Disk Access: mọi hướng trong bảng trừ hai hướng trên). Full Disk Access chỉ đo khi cần trả lời trọn câu hỏi đọc được thì có xoá được không, không đưa vào sản phẩm.

**Kế hoạch đo** (cho phiên chính hỏi người dùng rồi chạy; công cụ `scripts/probe/` nhắc dưới đây đã xoá ngày 09/11/2026, lấy lại bằng `git show` như mục 0, điểm 17). Mục tiêu là **mục ẩn của `DauProbeC1`** (bundle đã bỏ; `build/probe.noindex/C/DauProbeC1.app` còn trong thư mục build). Không đụng mục của Dấu thật.
Hai phép đã chạy (xem xét Full Disk Access của Terminal, hồi sinh mục ẩn); các phép còn lại chưa chạy.
Tên file và khoá giả trong lệnh giữ nguyên chữ K1, K2 của kế hoạch gốc (K1 là phép hồi sinh mục ẩn, K2 là phép chẩn đoán Full Disk Access).

- **Phép xem Full Disk Access của Terminal** (một phút, không ghi gì): người dùng xem System Settings › Privacy & Security › Full Disk Access có bật cho Terminal không. Nếu Terminal đã có Full Disk Access khi `defaults import` bị từ chối ngày 02/11 thì Full Disk Access không mở khoá miền này: đóng hướng Full Disk Access, bỏ phép chẩn đoán bằng khoá giả.
- **Phép hồi sinh mục ẩn, rồi bỏ bằng "–"** (khoảng 3 phút, chiếm màn hình; cũng là cách dọn `DauProbeC1` khỏi máy):
  1. Sao lưu để đối chiếu (chỉ đọc): `defaults export com.apple.inputsources ~/Desktop/dau-K1-before.plist`; `scripts/probe/cleanup.sh` (không tham số) để liệt kê.
  2. Chép lại: `ditto build/probe.noindex/C/DauProbeC1.app ~/Library/Input\ Methods/DauProbeC1.app` (`step.sh` từ chối ID đã dùng nên chép tay).
  3. `build/probe.noindex/bin/tis-act register ~/Library/Input\ Methods/DauProbeC1.app`; xoá `$(getconf DARWIN_USER_CACHE_DIR)/com.apple.Keyboard-Settings.extension/com.apple.IntlDataCache.le*`; `open "x-apple.systempreferences:com.apple.Keyboard-Settings.extension"` (như lần thử chỉ xoá bộ đệm, mục 8.1b).
  4. Ghi lại: "Dấu thử C1" có ở danh sách bên trái của Edit… và menu nhập liệu không (người dùng xem); `pgrep -fl DauProbeC1` (tiến trình có chạy không); `build/probe.noindex/bin/tis-probe`.
  5. Người dùng chọn "Dấu thử C1", bấm "–". Đọc `defaults export com.apple.inputsources -`: cả mục cha và mục mode `….DauProbeC1.vi` còn không (để ý mục mode mồ côi như msime).
  6. `scripts/probe/cleanup.sh --yes` (script tự dừng nếu mục còn trong khi bundle còn cài). Có thể dọn luôn `DauProbeC2` cùng lượt: bấm "–" cho "Dấu thử C2" trước bước này.
  - Đọc kết quả: `DauProbeC1` hiện lại và "–" bỏ được cả hai mục khi tiến trình không chạy → hướng cài lại rồi "–" dùng được, và "–" không cần tiến trình bộ gõ đang chạy. `DauProbeC1` không hiện → mục ẩn chỉ hết khi có cách khác (chưa biết); ghi lại, không thử thêm.
  - Trả lại: nếu không bỏ được thì `cleanup.sh --yes` đưa máy về đúng trạng thái trước phép này (mục ẩn, không bundle). Không `defaults import` bản sao lưu (miền này từ chối ghi; bản sao lưu chỉ để so).
- **Phép chẩn đoán Full Disk Access** (chỉ khi phép xem cho thấy Terminal chưa có Full Disk Access và người dùng muốn; đổi một cài đặt bảo mật trong vài phút). Dùng một **khoá giả**, không đụng danh sách nguồn: chính sách chặn theo cả miền (`user-preference-write com.apple.inputsources`), nên một khoá giả kiểm đúng quyền đó.
  1. Sao lưu: `cp -p ~/Library/Preferences/com.apple.inputsources.plist ~/Desktop/dau-K2-backup.plist`.
  2. Đối chứng, Terminal chưa có Full Disk Access: `defaults write com.apple.inputsources DauK2Probe -bool YES; echo $?`, rồi `defaults read com.apple.inputsources DauK2Probe` (tiến trình mới) và `/usr/bin/log show --last 2m --predicate 'eventMessage CONTAINS "inputsources"'`. Mong đợi: từ chối như 02/11.
  3. Người dùng bật Full Disk Access cho Terminal, mở lại Terminal, lặp bước 2.
  4. Nếu ghi được: `defaults delete com.apple.inputsources DauK2Probe`; so `defaults export com.apple.inputsources -` với bản sao lưu (chỉ khác khoá giả, đã xoá).
  5. Người dùng tắt lại Full Disk Access cho Terminal.
  - Biến thể (tuỳ chọn, hỏi mật khẩu quản trị): đường của qingjian, `osascript -e 'do shell script "launchctl asuser <uid> sudo -u <user> defaults write com.apple.inputsources DauK2Probe -bool YES" with administrator privileges'`, rồi đọc và xoá như trên.
  - Đọc kết quả: chỉ có Full Disk Access mới ghi được → giải thích ml-ime, hướng Full Disk Access vẫn không đưa vào Dấu. Ghi được cả khi không có Full Disk Access → máy đã khác 02/11, phải đo lại hướng ghi bằng `defaults` trước khi kết luận gì.
- **Ghi thẳng file**: không khuyến nghị trên tài khoản này (file chứa mục thật của Dấu; cfprefsd có thể ghi đè). Nếu cần, chỉ trên tài khoản thử của kế hoạch thử trên máy sạch (mục 7.2), cũng với khoá giả, sao lưu như phép chẩn đoán Full Disk Access.

**Kết quả (04/11/2026)** [Máy/bản thử]:
- **Phép xem Full Disk Access của Terminal:** Full Disk Access của Terminal.app **bật**; Ghostty.app có trong danh sách, **tắt** (ảnh chụp màn hình). Không biết `clean-dau.sh --yes` ngày 02/11 chạy trong ứng dụng nào, và `log show` không còn dòng từ chối của ngày đó, nên hướng Full Disk Access chưa đóng được bằng phép này.
- **Phép hồi sinh mục ẩn** (bỏ bước sao lưu 1 và phần nhìn menu của bước 4):
  - 13:58:12 chép lại `DauProbeC1`, `register` (0), xoá bộ đệm, mở Keyboard.
  - TIS tiến trình mới báo ngay cha và mode `enabled`, mode chọn được (mục ẩn làm `DauProbeC1` "đang bật" lại, không có hộp thoại xin phép); không có tiến trình `DauProbeC1`.
  - Người dùng bấm "–" ở "Dấu thử C1": `com.apple.inputsources` ghi lúc 14:02, không còn mục nào của `DauProbeC1` (cả cha và mode). → **hướng cài lại rồi "–" dùng được**, và "–" không cần tiến trình bộ gõ đang chạy.
  - Sau đó người dùng bỏ `DauProbeC2` bằng "–", `scripts/probe/cleanup.sh --yes` dọn mọi bản thử (A2–A4, B1, B2, C1, C2) khỏi `~/Library/Input Methods`, bộ đệm xoá; `cleanup.sh` báo "Không còn biến thể nào", miền chỉ còn mục của Dấu.
- Hệ quả: mục ẩn để lại vẫn dọn được về sau bằng cài lại cùng ID rồi "–"; cài lại cùng ID khi còn mục ẩn thì nguồn được bật ngay, không hỏi.
- **Đọc lại sau lần đăng xuất kế tiếp** (không tốn gì): nếu phép hồi sinh chưa chạy trước lần đăng xuất tự nhiên kế tiếp, sau khi đăng nhập lại đọc `defaults export com.apple.inputsources -` xem mục `DauProbeC1` còn không (msime và Shanjie cho thấy mục không tự mất, chưa đo trên máy này). Phép hồi sinh đã chạy và dọn `DauProbeC1`, nên phép này chỉ làm được nếu tạo lại một mục ẩn (mục 10.8).

### 1.3 Mục 6.2 cũ: tình trạng các đề xuất cho DECISIONS (đọc 03/11/2026)

- App chủ không sandbox: đã vào **D37**.
- N4 cho D14 bước 2 (chép/đăng ký là phần cài đặt; bật chỉ khi người dùng bấm, có Hoàn tác; đọc lại trạng thái): **N4** đã sửa 30/10/2026.
  - Câu "không tự chọn nguồn" của đề xuất cũ **không** nằm trong N4 (xem mục 6.1 điểm 3).
  - Phương án thay thế giống msime (bỏ nút bật, chỉ hướng dẫn) còn mở.
- Danh sách định danh không đổi giữa các bản (mục 3): đã vào **D37**.
- Cask chỉ có `app` (mục 1.4): đã vào **D37** (cask chỉ khai `app`); `DECISIONS.md` không ghi bước `uninstall`/`zap` của cask.
- Trình tự gỡ ở mục 4: đã vào **D16 (Bảo trì và gỡ cài đặt)** (người dùng bấm "–", app không tự chuyển bàn phím).
- **Chưa thấy trong `DECISIONS.md`:**
  - D14 bước 1 chỉ coi bộ gõ chặn phím đang chạy là xung đột, bộ gõ IMK tiếng Việt khác chỉ nhắc nhẹ (mục 5);
  - D7 thay bộ gõ bằng chép tạm rồi đổi chỗ cả khối, dừng bằng thông báo Darwin, không đụng `imklaunchagent` và bộ đệm hệ thống, chấp nhận biểu tượng cũ còn tới khi đăng xuất (mục 3);
  - Cần người dùng chốt.
- Hướng dẫn trên giao diện (N5): câu về đăng xuất, hộp thoại "Cho phép", và "Bàn phím đang dùng trước đó được giữ nguyên" để dạng ô trống cho tới khi kiểm xong bằng Dấu thật (lần thử trên máy sạch ở mục 7 đã bỏ).

### 7. Kế hoạch thử lại bằng Dấu thật trên máy sạch (một lần đăng xuất)

**Hiện trạng (04/11/2026): bỏ, người dùng chốt không làm lần thử trên máy sạch này.** Phần còn giá trị của mục này đã được trả lời bằng Dấu thật trên tài khoản đang dùng (mục 9.9–9.11). Phần dưới giữ làm tham khảo.

Mục đích: trả lời câu hỏi mở về lần cài đầu có phải đăng xuất để "+" thấy ID mới (mục 10.1), bằng Dấu thật, **nhìn danh sách "+" bằng mắt**. Cần người dùng vì đổi nguồn nhập liệu, chiếm màn hình, đăng xuất.

#### 7.1 Các hướng có thể làm hiện nguồn không cần đăng xuất (ước lượng, chưa đo)

Xếp hạng là ước lượng của người nghiên cứu từ bằng chứng ở mục 2, **chưa đo**. "Khả năng" là khả năng làm Dấu hiện ra không cần đăng xuất.
- Ba hướng đầu (cài vào `/Library/Input Methods`, làm mới tiến trình và bộ đệm giao diện, dựng lại ảnh chụp trong tiến trình) nằm trong vòng thử bằng bản thử (mục 8.2).
- Hướng chọn nguồn bằng TIS để chẩn đoán.
- Hướng dừng tiến trình hệ thống hoặc sửa tay không bao giờ vào Dấu.

| Hướng | Khả năng | Bằng chứng | Va chạm sổ quyết định |
|---|---|---|---|
| **Cài vào `/Library/Input Methods`** (cần quyền quản trị: `.pkg` hoặc `osascript … with administrator privileges`) rồi đăng ký | Trung bình (đáng thử nhất vì có một bằng chứng dương duy nhất) | marinaMoji (mục 2.3); nhưng Squirrel, macSKK, fcitx5, Gureum cũng cài ở đó mà vẫn bảo đăng xuất. Rủi ro: hộp thoại mật khẩu quản trị, gỡ cũng cần quản trị, Homebrew/Sparkle phải xử lý quyền | **D16** (`~/Library/Input Methods`), **D6** (DMG, không `.pkg`), **D37**; cần người dùng chốt nếu thành công |
| **Làm mới tiến trình/bộ đệm giao diện** sau khi đăng ký và bật: dừng `TextInputMenuAgent` (chờ 0,5 s), `TextInputSwitcher`, `CursorUIViewService`, thoát Cài đặt, dừng extension Bàn phím, xoá `com.apple.IntlDataCache.le*` | Thấp tới trung bình cho **menu**; thấp cho "+" với ID mới | vChewing (mã, không số đo); msime đo trên 27.0/27.0.1: không giúp ID mới, giúp mode mới của ID đã biết. LaunchAgent tự dựng lại tiến trình bị dừng. Đụng tiến trình và bộ đệm hệ thống, thoát Cài đặt có thể làm mất trạng thái đang mở, không có API chính thức, có thể vỡ ở bản macOS sau | **N4** (chỉ chạy khi người dùng bấm một nút rõ ràng, "Làm mới danh sách", có xác nhận); mục 3 ("Không làm") và D37 tránh việc này (đọc 03/11/2026; từ 04/11/2026 D37 xoá bộ đệm của System Settings khi "Bật Dấu", mục 9.9) |
| **Dựng lại ảnh chụp trong tiến trình**: sau `Register`, tra bằng tiến trình con mới (kiểu Squirrel: mỗi lệnh một tiến trình) và thăm dò đến 20 giây (kiểu tabulador); bật cha, đợi mode xuất hiện, bật mode, đọc lại bằng tiến trình mới | Thấp để làm hiện giao diện, nhưng nên làm để đọc đúng trạng thái | tabulador sửa lỗi tương tự bằng thử lại; Squirrel mỗi lệnh một tiến trình. Không đụng hệ thống | Không |
| **"Đã bật, chờ đăng xuất" làm đường chính** (đề xuất 03/11/2026, không chọn; D37 chốt cách bật không đăng xuất): ghi nhớ trạng thái; mở lại Dấu sau đăng nhập; nút hoặc hướng dẫn đăng xuất | Đúng nếu Apple DTS đúng; không tránh được đăng xuất (câu hỏi mở về đăng xuất còn mở lúc đó, D37 ghi "có thể") | Mục 2.3 | **N4**; artboard `OnboardingLogout` (trên canvas, không có trong `docs/UI.md`) chờ duyệt, vẽ theo kết luận "bắt buộc đăng xuất" đã bỏ |
| **Chọn nguồn bằng TIS** (`TISSelectInputSource`) sau khi bật, để `imklaunchagent` dựng tiến trình bộ gõ | Rất thấp | marinaMoji: `-50` (paramErr) dù mode đã bật | **N4** không có câu cấm riêng việc chọn nguồn (mục 6.1 điểm 3); chọn Dấu sau khi bật không gắn với nút nào hiện có, nên chỉ đo như chẩn đoán |
| **Dừng tiến trình hệ thống, sửa tay**: dừng `imklaunchagent` hoặc `keyboardservicesd`, `killall cfprefsd`, sửa tay `AppleEnabledThirdPartyInputSources` hay `com.apple.HIToolbox` | Rất thấp | msime: không giúp. vChewing: dừng `imklaunchagent` làm app đang gõ mất kết nối. logcg (blog, Mojave): sửa plist rồi dừng `cfprefsd` "thường không được". Nguy hiểm | **N4** vi phạm rõ; **không làm** |

Thứ tự **đề xuất** (của người nghiên cứu, 03/11/2026; đã thay bằng D37):
- Làm hướng dựng lại ảnh chụp và hướng "đã bật, chờ đăng xuất" vì rẻ và không va chạm quyết định nào; đề xuất đưa vào M5.
  - Hướng chờ đăng xuất chỉ nên thành đường chính nếu lần thử trên máy sạch cho thấy phải đăng xuất (D37 ghi "có thể", mục 6.1 điểm 4).
- Chạy vòng thử bằng bản thử ở mục 8.2 trước (người dùng chốt 04/11/2026: mục tiêu là tránh đăng xuất) để xem hướng nào trong ba hướng đầu có tác dụng, rồi thử lại bằng Dấu thật trên máy sạch (mục này).
- Nếu hướng cài vào `/Library/Input Methods` cho kết quả "hiện ngay, không đăng xuất", đó là thay đổi D16/D6/D37 và phải qua người dùng.
- Nếu hướng làm mới tiến trình/bộ đệm làm menu hiện ra mà không cần "+", cân nhắc nút "Làm mới danh sách" (vẫn trong N4), kèm ghi chú phát hành cho từng bản macOS.

Các bước của lần thử đã bỏ (mục 7.2–7.5 cũ: chuẩn bị, các bước, bảng kiểm, cách đọc kết quả) nằm ở `docs/history/PLANS.md`.

#### 7.6 Việc còn lại ngoài vòng thử
- Gỡ bản Debug rồi chép lại, **cùng ID** và giữa phiên: TIS có thấy ngay không? Chưa đo.
- (M7) Bản ký Developer ID đã notarize có quarantine: bộ gõ có chạy không, có bị translocate không; và hộp thoại "Cho phép … bật …?" có hiện với bản đó không.
- `TISDisableInputSource` lên mode đang được chọn: hệ thống chuyển sang nguồn nào (mục 4, bước 1).
- Lần thử trên máy sạch (tài khoản macOS mới): đã bỏ, không đo (D37). Vòng thử bằng bản thử (mục 8.2) đã chạy thay.

### 8. Quan sát bằng bản thử (không phải Dấu, không kết luận)

Mọi quan sát ở mục này đo bằng bản thử, **không phải Dấu**: không rút kết luận về Dấu từ đây; kết luận về Dấu dựa vào mục 9, còn mục 0 chỉ nhắc quan sát của mục này ở điểm nào gắn nhãn [Máy/bản thử]. Công cụ thử đã xoá khỏi repo (mục 0, dòng "Công cụ thử").

#### 8.1 Quan sát (03/11/2026)

Bản thử là bản sao `DauInputMethod.app` Release, đổi bundle ID, ID mode, tên kết nối và tên hiển thị, ký Apple Development. Chưa kiểm bản thử có tái hiện đúng hành vi của Dấu không.
Trạng thái đọc bằng `TISCreateInputSourceList` trong một tiến trình dòng lệnh mới (cách đọc từng sai, mục 2.6), trừ chỗ ghi "người dùng xem".
Ngày 03/11/2026, macOS 27.2, mỗi biến thể một bản ở `/Library/Input Methods` và một bản ở `~/Library/Input Methods`. Đã gỡ hết bản thử khỏi máy. [Máy/bản thử]

- ID không chứa `.inputmethod.` (`com.codefastlabs.dau.probe.…`): TIS không liệt kê, trước và sau một lần đăng nhập; danh sách "+" không có (người dùng xem).
- ID `com.codefastlabs.dau.inputmethod.Probe…`: TIS liệt kê ngay sau `TISRegisterInputSource`. Danh sách "+" chưa xem.
- `TISEnableInputSource` cho bản thử trả 0, mục cha vẫn tắt, `com.apple.inputsources` không đổi.
  - Gọi từ công cụ dòng lệnh hay từ một app thử có bundle (không sandbox) đều không có hộp thoại xin phép; với app thử, Cài đặt hệ thống tự mở mục Bàn phím (người dùng xem).
- Nhật ký `KeyboardSettings` (cùng truy vấn `/usr/bin/log show` ở mục 2.2):
  - 03/11 08:42:17.603 "Invalid value on inputSourceToBeEnabled" sau lệnh `probe-tis enable` lúc 08:42:16;
  - 08:44:56.610 cùng lỗi sau lần app thử có bundle gọi bật lúc 08:44:55;
  - cùng truy vấn còn thấy hai lần `handleOpenParameter` không kèm lỗi (03/11 08:43:23 và 08:46:12), chưa phân biệt nguồn.

#### 8.1b Các vòng thử cài, bật, gỡ (04/11/2026, `scripts/probe/`, tài khoản đang dùng, không đăng xuất)

Mỗi bản thử có tên `DauProbe<chữ><số>` (hiển thị "Dấu thử <chữ><số>"); chữ chỉ vòng thử dựng ra nó, số là thứ tự trong vòng.
Các vòng thử:
- **Vòng cài, đăng ký, bật và làm mới bộ đệm của System Settings:** `DauProbeA1`–`A4`.
- **Vòng tách từng thao tác làm mới bộ đệm:** `DauProbeB1`–`B3`.
- **Vòng bật ngay sau khi xoá bộ đệm:** `DauProbeC1`, `C2`.
- **Vòng gỡ:** bản `A1`, `B3`, `C1` ở trên.
- **Vòng từ chối hộp thoại rồi thử lại:** `DauProbeD1`.
- **Vòng bộ đệm riêng của app có sandbox:** bản thử `E1`–`E4` và một app thử có sandbox.

**Vòng cài, đăng ký, bật và làm mới bộ đệm.**
Bản thử `DauProbeA1`–`A4` dựng từ bản Release `22948d9` (Dấu ngày 02/11), đổi ID theo mục 8.2, ký Apple Development; chép vào `~/Library/Input Methods`.
Trạng thái đọc bằng `tis-probe` (tiến trình mới); "+" là người dùng xem (System Settings › Keyboard › Input Sources › Edit… › "+" › Vietnamese).
Nhật ký từng lệnh: `build/probe.noindex/logs/A-steps.log` (không vào repo). [Máy/bản thử]

| Lần thử | Bản | Lời gọi (mã trả về) | TIS tiến trình mới | `com.apple.inputsources` | "+" |
|---|---|---|---|---|---|
| 09:41, chỉ đăng ký | A1 | `Register` (0) | cha và mode có, liệt kê ngay | rỗng | không có (người dùng xem) |
| 09:46, đăng ký rồi bật cha và mode trong một tiến trình | A2 | `Register`, cha liệt kê ở lần hỏi đầu, `Enable` cha (0), mode (0); 0,3 s | có | rỗng | không có A1, A2 |
| 09:46, ba tiến trình | A3 | ba tiến trình: `Register` (0), `Enable` cha (0), mode (0); `KeyboardSettings` ghi "Invalid value on inputSourceToBeEnabled" 1,5 s sau | có | rỗng | không có A1–A3 |
| 10:14, làm mới bộ đệm của System Settings | A4 | `Register` (0), `Enable` cha (0); thoát System Settings; xoá `IntlDataCache.le*` (giờ ghi trước đó 08:47); `pkill` extension (lúc đó chỉ `KeyboardSettingsIntents` chạy); mở lại Keyboard. Bộ đệm được dựng lại 10:14:38.969 | có | rỗng | **có A1, A2, A3, A4** (ảnh của người dùng) |
| 10:20, bật từ app có tên ngay sau lần làm mới | A4 | `Enable` cha từ `TisAct.app` (tên "Dấu thử") (0); `KeyboardSettings` ghi `handleOpenParameter`, `TCCAccessLaunchDisclosurePromptIfNeeded`, **không** có "Invalid value"; hộp thoại xin phép hiện, người dùng bấm "Allow" | cha và mode `enabled` | **có cả hai mục A4** (cha và mode `….A4.vi`) | — |

**Vòng tách từng thao tác làm mới bộ đệm** (04/11/2026): tách lần làm mới 10:14 của vòng trên thành từng thao tác (các lần thử của `scripts/probe/step.sh`, mỗi lần một ID mới, System Settings đang mở ở Keyboard trước mỗi lần):

| Lần thử | Bản | Làm mới | Bộ đệm `IntlDataCache.le*` | "+" |
|---|---|---|---|---|
| 10:24, chỉ thoát System Settings | B1 | `Register` (0); chỉ thoát System Settings, mở lại Keyboard sau 1,5 s | không dựng lại (giờ ghi giữ 10:14:38) | không có B1 |
| 10:27, chỉ xoá bộ đệm | B2 | `Register` (0); chỉ xoá bộ đệm, System Settings vẫn mở; mở lại Keyboard | dựng lại 10:27:13, `.kbdx` 139.252 → 142.540 byte | **có B1, B2** |
| 10:29, chuỗi cài thử trọn vẹn | B3 | `Register` (0); xoá bộ đệm; mở Keyboard; 3 s sau `Enable` cha từ `TisAct.app` (0) | dựng lại 10:29:25 | **có B3** |

Lần thử chuỗi cài trọn vẹn, phần bật:
- Lần gửi đầu (10:29:28, 3 s sau khi mở lại Keyboard) không để lại dòng `handleOpenParameter` nào trong nhật ký `KeyboardSettings`, không có hộp thoại, `com.apple.inputsources` không có B3 sau 25 s, dù mã trả về 0.
- Gửi lại từ `TisAct.app` lúc 10:31:45 (chạy lại bước gửi yêu cầu bật của `step.sh` cho bản B3): `handleOpenParameter` 10:31:46, hộp thoại xin phép hiện, người dùng bấm "Allow", `com.apple.inputsources` có B3 lúc 10:32:03.
- Một dòng `handleOpenParameter` lúc 10:31:02 không do script gửi, chưa rõ nguồn.
- Chưa ghi câu chữ đúng của hộp thoại.

**Vòng bật ngay sau khi xoá bộ đệm** (04/11/2026): `Register`, xoá bộ đệm, rồi `Enable` cha từ `TisAct.app` ngay, không tự mở System Settings trước (`TISEnableInputSource` tự mở System Settings kèm yêu cầu, mục 2.2):

| Giờ | Bản | System Settings trước lệnh bật | Nhật ký `KeyboardSettings` | `com.apple.inputsources` |
|---|---|---|---|---|
| 10:36:59 | C2 | đang mở ở Keyboard, có sheet Edit/"+" đang mở | không có `handleOpenParameter` | không có C2 |
| 10:39:30 | C2 (gửi lại) | đang mở ở Keyboard, đã đóng sheet | không có `handleOpenParameter` | không có C2 |
| 10:40:34 | C2 (gửi lại) | đã thoát (`osascript … quit`) | extension mới pid 32724: `TCCAccessLaunchDisclosurePromptIfNeeded` 10:40:35.086, `handleOpenParameter` 10:40:35.392; hộp thoại hiện (ảnh của người dùng), bấm "Allow" | có C2 lúc 10:40:51 |
| 10:41:02 | C1 (ID mới) | đã thoát | extension mới pid 32891: `handleOpenParameter` 10:41:03.852; hộp thoại hiện, bấm "Allow" | có C1 lúc 10:41:19 |

Hộp thoại (ảnh của người dùng, macOS 27.2, giao diện tiếng Anh):
- Tiêu đề `Allow “Dấu thử” to enable “Dấu thử C2”?` (tên app gọi, rồi tên bộ gõ), thân "The developer of the input source will be able to access anything you type with this input source…", hai nút "Don't Allow" và "Allow"; hiện giữa cửa sổ System Settings ở trang Keyboard.
- Hình dạng (đo 04/11/2026 18:59 bằng bản thử F1, trợ năng và ảnh chụp, macOS 27.2, giao diện tối) [Máy/hệ thống]:
  - sheet rộng 260 pt, cao 234 pt, nằm giữa cửa sổ System Settings;
  - không có biểu tượng; tiêu đề đậm, canh trái, xuống dòng khi dài;
  - thân bài canh trái, hiện đủ (6 dòng ở bề rộng này, không cắt);
  - hai nút hình viên thuốc rộng bằng nhau (112 × 30 pt) nằm ngang ở đáy, "Don’t Allow" xám bên trái, "Allow" xanh (nút mặc định) bên phải.

Quan sát xuyên các vòng:
- Mọi lần System Settings xử lý yêu cầu bật (`handleOpenParameter`, 10:20:51, 10:31:46, 10:40:35, 10:41:03) đều đi cùng một tiến trình extension `KeyboardSettings` có pid mới và dòng `TCCAccessLaunchDisclosurePromptIfNeeded` cùng lúc.
- Mọi lần lệnh bật trả 0 mà không có dòng nào (lần gửi đầu của chuỗi cài trọn vẹn 10:29:28, và vòng bật ngay lúc 10:36:59 và 10:39:30) đều là lúc trang Keyboard đang mở sẵn.
- Chưa thử: System Settings mở ở trang khác Keyboard.

**Vòng gỡ** (04/11/2026): bỏ bundle khỏi `~/Library/Input Methods` (`lsregister -u` trước, rồi chuyển ra ngoài), có hoặc không có "–", rồi xoá `IntlDataCache.le*`; System Settings đang mở; "+" và các danh sách là người dùng xem, sheet đóng rồi mở lại.

| Lần thử | Bản | Trước khi bỏ bundle | Ngay sau khi bỏ bundle | Sau khi xoá bộ đệm |
|---|---|---|---|---|
| 12:41, bỏ bundle khi chưa bật | A1 | đã cài, chưa bật | TIS tiến trình mới vẫn liệt kê A1; "+" › Vietnamese có một dòng không tên (ảnh của người dùng) | TIS không còn A1; bộ đệm dựng lại 12:43 khi mở "+", `.kbdx` 144.712 → 144.164 byte; dòng không tên mất |
| 12:44, bỏ bằng "–" rồi bỏ bundle | B3 | đang bật; người dùng bỏ bằng "–" (`com.apple.inputsources` không còn B3) | TIS vẫn liệt kê B3 | vài giây sau TIS không còn B3; "+" và danh sách bên trái của Edit… sạch |
| 12:50, bỏ bundle khi đang bật, không bấm "–" | C1 | đang bật, **không** bấm "–" | — | TIS không còn C1; `com.apple.inputsources` **vẫn còn** hai mục của C1 (không ai ghi được miền này ngoài System Settings); menu nhập liệu, danh sách bên trái của Edit…, "+" › Vietnamese và ⌃Space đều không có C1 hay dòng trống |

- Tìm trong binary `KeyboardSettings` (macOS 27.2): chỉ có `inputSourceToBeEnabled`, không có đường nhận yêu cầu tắt/bỏ nguồn; `TISDisableInputSource` chỉ nhảy sang `TSMDisableInputSource`, cùng đường ghi bị chặn (mục 4.1).
- Chưa đo sau lần thử bản C1: mục ẩn của C1 có ảnh hưởng gì ở lần đăng nhập sau (phép đọc lại sau đăng xuất, mục 4.1 và 10.8).
- Cài lại cùng ID thì macOS bật lại ngay không hỏi: đã đo bằng phép hồi sinh mục ẩn (mục 4.1, kết quả).

**Vòng từ chối hộp thoại rồi thử lại** (04/11/2026): phiên chính tự bấm qua trợ năng (`scripts/probe/settings-ax.swift`), không cần người dùng:

| Giờ | Bước | Kết quả |
|---|---|---|
| 14:47:34 | gửi yêu cầu bật lần đầu: `Register`, xoá bộ đệm, System Settings đã thoát, `Enable` cha từ `TisAct.app` (bản `DauProbeD1`) | hộp thoại `Allow “Dấu thử” to enable “Dấu thử D1”?` hiện (đọc qua trợ năng) |
| 14:47:52 | bấm "Don’t Allow" | `com.apple.inputsources` không có `DauProbeD1`; nhật ký `KeyboardSettings` không có dòng nào báo từ chối (chỉ có dòng `handleOpenParameter` lúc nhận yêu cầu) → app không biết người dùng đã từ chối, chỉ thấy "chưa bật" |
| 14:48:16 | thoát System Settings, gửi lại yêu cầu (như "Thử lại") | hộp thoại hiện lại sau 4 s (macOS không nhớ lần từ chối) |
| 14:48:21 | bấm "Allow" | `DauProbeD1` vào `com.apple.inputsources` ngay (cả hai mục) |
| 14:48:41 | System Settings đang mở sheet Input Sources, gọi `NSRunningApplication.terminate()` như app | System Settings thoát trong < 5 s dù sheet đang mở |
| 14:48:51 | mở `?InputSources`, chọn `DauProbeD1`, bấm "–", Done (qua trợ năng) | `DauProbeD1` ra khỏi danh sách; dọn bằng `cleanup.sh --yes` |

**Vòng bộ đệm riêng của app có sandbox** (04/11/2026, 16:58–17:08). Mục đích: kiểm tra ca Telegram (mục 9.10) với một nguồn mới, đo khi nào app thấy nguồn đó.

Cách đo:
- Công cụ: một app thử (ký ad-hoc, có sandbox, mỗi lần một bundle ID mới), in danh sách nguồn TIS mà nó thấy và giờ ghi bộ đệm `com.apple.IntlDataCache.le.kbdx` của nó. Có ba chế độ: in một lần, theo dõi khi đang chạy (đọc lại khi có thông báo TIS và mỗi 2 s), mở cửa sổ có ô nhập.
- Bộ đệm của app có sandbox nằm ở `$(getconf DARWIN_USER_CACHE_DIR)<bundle ID>/`. Tiến trình không sandbox dùng bộ đệm chung ở gốc thư mục đó.
- Bản thử E1–E4 bật theo cách của vòng bật ngay sau khi xoá bộ đệm (Allow bấm qua trợ năng), trừ khi ghi khác. Bỏ bằng "–" qua trợ năng rồi `cleanup.sh --yes`.

| Giờ | Bước | Kết quả |
|---|---|---|
| 16:59:19 | E1 bật theo cách trên, Allow | app đang chạy (bộ đệm 16:59:10) nhận `EnabledKeyboardInputSourcesChanged` nhưng **không thấy E1**; app mở lại có bộ đệm cũ (16:58:54) **không thấy E1**; app mới thấy E1; tiến trình không sandbox thấy E1 (bộ đệm chung tự dựng lại lúc 16:59:29) |
| 17:00:03 | xoá bộ đệm của app đang chạy (E1 đã bật xong), rồi đổi nguồn đang chọn hai lần | app vẫn không thấy E1, không dựng lại bộ đệm (`cache=none`) |
| 17:00:11 | xoá bộ đệm của app đã thoát, mở lại | thấy E1 |
| 17:03:00 | app mới chạy với bộ đệm cũ chép từ app khác (không có E3, E3 đã cài) | dùng bộ đệm đó, không thấy E3: bộ đệm có sẵn thì được dùng, không bị kiểm tra lại |
| 17:03:29 → 17:03:36 | xoá bộ đệm của app đó khi đang chạy; 7 s sau gọi `TISRegisterInputSource` cho một nguồn đã cài | sau khi xoá: không đọc lại. Sau khi đăng ký: dựng lại bộ đệm từ đĩa, **thấy E3 khi vẫn đang chạy** |
| 17:04:24 | hai app có ô nhập, cùng bộ đệm cũ, cùng đang chạy; chép E4, xoá bộ đệm của **một** app, đăng ký E4, bật E4, Allow | app bị xoá bộ đệm: bộ đệm mới (17:04:27) có E4, chọn "Dấu thử E4" từ menu nhập liệu được, gõ từng phím ra đúng "việt". App giữ bộ đệm: chọn E4 từ menu không đổi (vẫn U.S.), gõ ra "vieetj", như Telegram ở mục 9.10 |

Thêm:
- **E2:** lượt đầu không hiện hộp thoại vì System Settings còn mở từ E1 (cách bật của vòng bật ngay không thoát nó). Thoát rồi gửi lại thì hiện.
- **Sai sót thiết kế ở lượt E3:** app thử tự đọc TIS mỗi 2 s nên dựng lại bộ đệm (vẫn cũ) ngay sau khi bị xoá, trước khi E3 được cài. Một app thật gọi TIS vào lúc bất kỳ, nên khoảng giữa lúc xoá bộ đệm và lúc đăng ký cần ngắn nhất có thể.
- **Thông báo đổi nguồn lạ:** lúc 17:03:21 và 17:03:26 có hai thông báo đổi nguồn đang chọn không do lệnh nào của vòng thử.
- **Bấm "–" qua trợ năng:** trong một lần mở trang Input Sources, chỉ lần "–" đầu tiên được ghi vào `com.apple.inputsources`. Các lần sau làm dòng biến mất nhưng không ghi. Mở lại System Settings cho từng mục thì ghi đủ. Chưa biết có xảy ra khi người dùng tự bấm hay không.
- **Gõ nhanh khi chưa ổn định:** lần gõ nhanh đầu tiên ở app có ô nhập (chuỗi System Events) ra ô trống; gõ từng phím thì đúng.

Chưa chạy: lần thử chỉ dừng extension của System Settings (lần chỉ xoá bộ đệm đã đủ và nhẹ hơn).
Chưa ghi:
- Người dùng có thoát hẳn System Settings khi xem "+" ở ba lần thử đầu (09:41, 09:46 hai lần) hay không;
- câu chữ đúng của hộp thoại ở vòng đầu;
- menu nhập liệu có A4 không;
- gõ được không.

Lỗi bộ thử đã sửa sau lần làm mới bộ đệm 10:14: `pkill -f KeyboardSettings` dừng nhầm cả `log stream` (bộ lọc chứa chữ đó), nên nhật ký liên tục của lần đó dừng ở 10:14:37.

Các quan sát này không trả lời câu hỏi lần cài đầu có phải đăng xuất không; việc đó trả lời bằng Dấu thật (mục 9.9), xem cả danh sách "+". Kế hoạch thử trên máy sạch ở mục 7 đã bỏ.

#### 8.2 Kế hoạch vòng thử bằng bản thử (tìm cách không phải đăng xuất)

Công cụ `scripts/probe/` nhắc trong mục này đã xoá ngày 09/11/2026 khi vòng thử xong; lấy lại bằng `git show` như mục 0, điểm 17.

Không thuộc lần thử trên máy sạch (mục 7) và chạy **trước** nó (người dùng chốt 04/11/2026: mục tiêu là tìm cách để lần cài đầu không phải đăng xuất; ba hướng đầu và hướng chọn nguồn bằng TIS ở mục 7.1).
Chạy trên tài khoản đang dùng, vì mỗi bước dùng một ID mới (nguyên lý dưới).
Kết quả là quan sát về bản thử, không phải về Dấu; hướng nào có vẻ được thì phải thử lại bằng Dấu thật trên tài khoản mới (mục 7) trước khi đưa vào sản phẩm.
Các bước chỉ đăng ký, thăm dò, kiểu Squirrel, làm mới bộ đệm và bật từ app có tên có kết quả ở vòng đầu (mục 8.1b); các bước còn lại không có kết quả trong file này.

Nguyên lý:
- Điều kiện đáng đo là "**ID chưa từng có trong danh mục đăng nhập của phiên**".
  - Mỗi ID chỉ dùng được **một lần** cho mỗi tài khoản: sau khi đăng xuất và đăng nhập, ID đó đã "bị cháy". Dấu thật là một ID.
  - Để thử thêm hướng nào trong **cùng** phiên đăng nhập, mỗi hướng dùng **một biến thể bộ gõ có ID riêng**.
- Mỗi vòng dựng một bộ biến thể mới từ bản Release của `DauInputMethod.app`.
  - Mỗi biến thể đổi: tên file `.app`, `CFBundleIdentifier`, `TISInputSourceID` ở mức bundle, khoá mode và `TISInputSourceID` của mode (`….DauProbeA1.vi`), `InputMethodConnectionName`, tên hiển thị (để phân biệt trong menu), và `mach-register` trong entitlement, rồi ký lại bằng cùng danh tính Apple Development như bản Release (như bản thử 03/11, mục 8.1).
  - ID giữ dạng của Dấu, `com.codefastlabs.dau.inputmethod.<Tên>`, để chỉ đổi một biến số (luật `.inputmethod.` còn mở, mục 2.7).
  - Script ném đi trong `scripts/probe/` (không đưa vào bản phát hành), không sửa mã app; nó ghi lại mọi ID đã tạo và từ chối dùng lại.
- Cần một **công cụ đọc** `tis-probe` (`scripts/probe/tis-probe.swift`, chạy bằng tiến trình mới mỗi lần):
  - in một dòng JSON gồm giờ, danh sách mọi nguồn có `TISInputSourceID` chứa `dau.inputmethod` (id, bundle, loại, enabled, enableCapable, selectCapable, selected), kết quả `defaults export com.apple.inputsources -` và `com.apple.HIToolbox` (`AppleEnabledInputSources`, `AppleInputSourceUpdateTime`), và `pgrep -fl DauProbe`;
  - có thêm chế độ `--watch` đăng ký `kTISNotifyEnabledKeyboardInputSourcesChanged` và in mỗi lần nhận;
  - công cụ dòng lệnh `probe-tis` đã dùng ở 02–03/11 nằm ngoài repo; chưa kiểm có trùng không.
- **Thứ tự: từ ít xâm lấn đến nhiều**, và **chép biến thể vào `~/Library/Input Methods` ngay trước khi thử nó, không chép trước**.
  - Các bước sau có thể làm tiến trình giao diện nạp lại danh mục và vô tình làm hiện cả biến thể trước đó (và Dấu thật).
  - Vì vậy sau **mỗi** bước phải chạy lại `tis-probe` và nhìn giao diện cho **mọi ID đã cài**, không chỉ ID đang thử. Nếu một ID cũ bỗng hiện ra sau bước N, bước N là thủ phạm (ghi lại).

Các bước (bảng kiểm như mục 7.4 cũ, nay ở `docs/history/PLANS.md`, thêm: một công cụ đọc `tis-probe` chạy bằng tiến trình mới: ID nào có, enabled / enableCapable / selectCapable / selected, ba lần cách nhau 3 s; `pgrep -fl DauProbe`; thông báo `kTISNotifyEnabledKeyboardInputSourcesChanged` qua `tis-probe --watch`).
- Cần mật khẩu quản trị ở bước cài vào `/Library/Input Methods` (người dùng tự gõ).
- Dừng tiến trình của phiên ở ba bước làm mới (LaunchAgent, macOS tự chạy lại), người dùng cho phép lúc chạy.
- Bước trần trên chỉ trên tài khoản thử.
- Công cụ, script biến thể và script chạy từng bước nằm trong `scripts/probe/`, không gắn vào bản phát hành.
- Biến thể đặt tên `DauProbe<chữ vòng><số>` (vòng đầu: `DauProbeA1`…), tên hiển thị "Dấu thử A1"…:

| Bước | Chuỗi gọi | Mục đích | Mức xâm lấn |
|---|---|---|---|
| **Chỉ đăng ký** | Chép vào `~/Library/Input Methods`, `Register` từ một tiến trình, không gì thêm; nhìn "+". (03/11 bản thử có `.inputmethod.` được TIS liệt kê ngay sau `Register` nhưng chưa ai xem "+", mục 8.1) | Mốc: có cần làm gì thêm sau `Register` không | Không |
| **Đăng ký rồi thăm dò** | `Register` rồi **thăm dò** `TISCreateInputSourceList` mỗi 0,5 s đến 20 s cho đến khi thấy cha; bật cha; thăm dò đến 20 s cho đến khi thấy mode; bật mode; đọc lại bằng tiến trình mới | Hướng dựng lại ảnh chụp trong tiến trình (chờ) | Không |
| **Kiểu Squirrel** | Tiến trình 1 chỉ `Register` rồi thoát; tiến trình 2 mới bật cha rồi thoát; tiến trình 3 mới liệt kê và bật mode rồi thoát | Hướng dựng lại ảnh chụp trong tiến trình (mỗi lệnh một tiến trình) | Không |
| **Làm mới bộ đệm của System Settings** | `Register`, bật cha, rồi **chỉ** thoát Cài đặt, xoá `$(getconf DARWIN_USER_CACHE_DIR)/com.apple.Keyboard-Settings.extension/com.apple.IntlDataCache.le*`, dừng extension Bàn phím (tên tiến trình: tra bằng `pgrep -fl Keyboard` lúc Cài đặt đang mở), mở lại Cài đặt › Bàn phím › Nguồn nhập liệu. **Không** dừng gì khác | Hướng làm mới tiến trình/bộ đệm giao diện, phần "+" (msime) | Nhẹ: bộ đệm của chính tài khoản này |
| **Bật từ app có tên sau khi làm mới** | Ngay sau bước làm mới, cùng biến thể: gọi bật mục cha từ một app có tên (`TisAct.app`, không phải công cụ dòng lệnh); xem hộp thoại "Allow “…” to enable “…”?" có hiện không, bấm "Allow" thì có bật thật không (đọc `com.apple.inputsources`) | Giả thuyết mục 2.2: Cài đặt báo "Invalid value" vì danh sách nguồn của nó chưa có ID; bước làm mới làm nó thấy ID thì có thể dựng được hộp thoại. Nếu được: bật một chạm, không đăng xuất | Như bước làm mới |
| **Kiểu vChewing** | Dừng `TextInputMenuAgent`, chờ 0,5 s, sau đó `Register`, bật mode (rồi cha nếu cần), đọc lại. Rồi một lần thử thứ hai: đã `Register` xong, dừng `TextInputMenuAgent` lần nữa và nhìn menu | Hướng làm mới tiến trình/bộ đệm giao diện, phần menu | Vừa: LaunchAgent của phiên, tự dựng lại |
| **Dừng ba tiến trình giao diện cùng lúc** | `Register`, bật cha, rồi dừng **cùng lúc** `TextInputSwitcher`, `CursorUIViewService`, `TextInputMenuAgent` (ba lần cách nhau 0,5 s) | Làm mới tối đa, không đụng `imklaunchagent` | Vừa |
| **Cài vào `/Library/Input Methods`** | `sudo` chép vào **`/Library/Input Methods/`** (chủ sở hữu root), `Register` từ tiến trình người dùng, bật cha, bật mode. Đo thêm cho câu hỏi mở "cài cho riêng mình hay cho cả máy" (`docs/DECISIONS.md`): có tài khoản thứ hai thì đăng nhập vào đó xem "+" có biến thể này ngay không; nếu người dùng thêm biến thể này bằng "+" rồi chép thêm cùng biến thể vào `~/Library/Input Methods`, tiến trình chạy từ đường dẫn nào | Hướng cài vào `/Library/Input Methods`; cài cho cả máy | Cần mật khẩu quản trị (người dùng tự gõ); bản ở `/Library` gỡ cũng cần mật khẩu |
| **Chọn nguồn bằng TIS** | Như bước đối chứng ở mục 7.3 cũ (`docs/history/PLANS.md`) rồi, **sau cùng**, `TISSelectInputSource` cho mode: ghi mã trả về, xem biến thể có chạy không (`pgrep`), `TISCopyCurrentKeyboardInputSource` đổi không | Hướng chọn nguồn bằng TIS, chẩn đoán | Nhẹ; chỉ để đo, không đưa vào Dấu (N4) |
| **Trần trên** (không có biến thể riêng) | **Chỉ chẩn đoán, không bao giờ vào Dấu**: sau khi mọi bước trên đã đo, dừng `imklaunchagent` và `keyboardservicesd` rồi nhìn lại mọi ID | Biết có cách làm hiện mà không đăng xuất hay không, và xem tiến trình nào là chủ | Cao: có thể làm hỏng gõ phím trong tài khoản thử; làm cuối cùng |

Cách đọc:
- **Bước chỉ đăng ký mà HIỆN:** `Register` là đủ trên bản macOS đó; các bước sau chỉ còn để xem bật có được không. Ca 03/11 (app không gọi `Register`, `docs/PROGRESS.md`) khi đó là lỗi của app, không phải giới hạn của macOS.
- **Bước bật từ app có tên có hộp thoại và bấm "Allow" thì bật thật:** đường tốt nhất cho onboarding (một nút, một lần xác nhận, không đăng xuất), nhưng bước làm mới trước nó xoá bộ đệm và dừng extension của hệ thống: cần người dùng quyết theo N4.
- **Bước cài vào `/Library/Input Methods` HIỆN, các bước còn lại KHÔNG:** hướng cài vào thư mục của cả máy đáng cân nhắc; mở câu hỏi D16/D6/D37 cho người dùng.
- **Bước làm mới bộ đệm làm "+" HIỆN mà menu thì không:** có thể hướng dẫn thêm thủ công (đúng chữ N4) và vẫn không cần đăng xuất; menu sẽ sau.
- **Bước kiểu vChewing hoặc dừng ba tiến trình làm menu HIỆN:** cân nhắc nút "Làm mới danh sách" với xác nhận.
- **Một ID cũ bỗng HIỆN sau một bước sau:** ghi bước nào, rồi lặp lại bước đó riêng trên ID mới ở vòng sau (mỗi vòng dùng bộ ID mới `DauProbeB1…`).

### 9. Quan sát bằng Dấu thật (macOS 27.2 trừ khi ghi khác)

Mục này gom các phép đo và quan sát bằng Dấu thật. Nhãn nguồn [Máy/Dấu] (và [Máy/hệ thống] khi đọc nhật ký).

Tên cũ của các tiểu mục: trước khi viết lại (09/11/2026) chúng nằm ở mục 0 dưới nhãn (b)1 đến (b)12; tiểu mục 9.N là (b)N. Các tài liệu và chú thích trong mã dẫn "(b)N" thì đọc là mục 9.N.

#### 9.1 30/10: cài đè cùng đường dẫn với bundle ID khác
- Cài đè cùng đường dẫn `~/Library/Input Methods/DauInputMethod.app` với bundle ID khác làm bộ đệm TIS lệch.
  - ID nguồn mới nhưng `kTISPropertyBundleID` vẫn là ID cũ; lần đối chiếu với miền `HIToolbox` ngày đó đọc nhầm miền (mục 2.6).
  - Thêm nguồn không kích hoạt được; đăng xuất rồi đăng nhập thì đúng ID mới.
- Đây là đổi ID tại chỗ, **không phải** cài lần đầu trên máy sạch. [Máy/Dấu] Mục 3.

#### 9.2 30/10: bộ gõ có sandbox gọi `TISSelectInputSource`
- Từ bộ gõ có sandbox, `TISSelectInputSource` đổi được nguồn nhưng bước báo cho app đang gõ bị chặn (`deny mach-lookup com.apple.tsm.portname`). [Máy/Dấu] Mục 1.2.

#### 9.3 30/10: App Group với app chủ không sandbox
- `scripts/selftest/app-group.sh` đạt với app chủ không sandbox. [Máy/Dấu] Mục 1.3.

#### 9.4 Máy không sạch từ 30/10
- Hai mục Dấu (cha và mode `….Dau.vi`) trong `com.apple.inputsources` có từ ngày 30/10.
  - File sửa lần cuối 30/10 16:18, trùng ngày người dùng đăng xuất/đăng nhập và bật lại nguồn "Dấu – Tiếng Việt"; không phải do lần "Bật Dấu" 02/11.
  - macOS từ chối `defaults import` của script ghi miền này (và `TISDisableInputSource` của Dấu, mục 4).
- Vì vậy ở lần thử cài đầu 02/11 (mục 9.5), việc Dấu "tự có sẵn" sau đăng nhập không chứng minh điều gì về `TISEnableInputSource`. [Máy/Dấu, 02/11] Mục 2.6.

#### 9.5 02/11: lần thử cài đầu của người dùng (Release 22948d9)
- Sau khi dọn tay và đăng xuất, "Bật Dấu" chép, đăng ký (`status=0`), bật mục cha (`status=0`); danh sách "+" và menu **không** có Dấu.
- Sau đăng xuất/đăng nhập Dấu có sẵn, đang được chọn, bộ gõ chạy. [Máy/Dấu] Mục 2.3.

#### 9.6 02/11 16:41:23: Cài đặt ghi lỗi sau "Bật Dấu"
- Cài đặt ghi lỗi "Invalid value on inputSourceToBeEnabled" 0,8 s sau khi Dấu ghi `event=enable … status=0`; theo mã thì khi đó không dựng hộp thoại.
- Cài đặt có hiện lên màn hình hay không: không ghi lại. [Máy/Dấu + Máy/hệ thống] Mục 2.2.

#### 9.7 02/11: `TISDisableInputSource` từ app
- `TISDisableInputSource` từ app trả 0 cho mục con và mục cha, nhưng System Policy chặn ghi `com.apple.inputsources` (`Dau deny(1) user-preference-write com.apple.inputsources`; cfprefsd "rejecting write").
- Hai mục Dấu còn nguyên, TIS tiến trình mới vẫn báo `enabled=true`.
- Chỉ nút "–" trong Cài đặt gỡ được (file ghi lúc 18:07, mục rỗng). [Máy/Dấu] Mục 4.

#### 9.8 Chưa có phép đo trên tài khoản macOS mới
- Chưa có phép đo trên tài khoản macOS mới, nhìn danh sách "+" bằng mắt, với Dấu thật. Mục 7.

#### 9.9 04/11: "Bật Dấu" theo D37 mới, không đăng xuất
Bản Debug (mã `83baa29`), tài khoản đã từng cài Dấu nhưng lúc đó không cài Dấu và `com.apple.inputsources` không có mục nào của Dấu. [Máy/Dấu] Mục 8.1b (cùng cách, đo trước bằng bản thử).
1. Chép, đăng ký (0), xoá 2 file `IntlDataCache.le*`, System Settings thoát, bật mục cha (0) lúc 10:49:57.214.
2. `KeyboardSettings` `handleOpenParameter` 10:49:58.364.
3. Hộp thoại `Allow “Dấu” to enable “Dấu”?` (ảnh của người dùng); tên thứ hai là tên của mục cha, không phải "Dấu – Tiếng Việt". Người dùng bấm "Allow".
4. `com.apple.inputsources` có mục cha và mode `….Dau.vi` lúc 10:50:02 (`event=enable-stored waited=4s`).
5. Tiến trình bộ gõ chạy; menu nhập liệu có "Dấu – Tiếng Việt", gõ "vieetj" ra "việt" (người dùng xem). Không đăng xuất.

#### 9.10 04/11: Telegram không dùng được Dấu dù Dấu đã bật
Telegram: `ru.keepcoder.Telegram` 13.1, có sandbox.
- **Triệu chứng:**
  - Chọn "Dấu – Tiếng Việt" từ menu nhập liệu trong Telegram không đổi được nguồn. U.S. và Telex thì đổi được.
  - Vòng ⌃⌥Space trong Telegram chỉ có Telex và U.S. TextEdit, Finder và Sublime Text đi đủ ba nguồn.
  - Chọn Dấu bằng TIS từ một tiến trình khác thì TIS báo Dấu, nhưng Dấu không nhận phím nào (signpost `handle` bằng 0), phím vẫn tới Telex.
  - Thoát rồi mở lại Telegram không đổi gì.
- **Nguyên nhân:** bộ đệm riêng của Telegram, `$(getconf DARWIN_USER_CACHE_DIR)ru.keepcoder.Telegram/com.apple.IntlDataCache.le*`, ghi lúc 10:16:41.
  - Lúc đó `~/Library/Input Methods` chỉ có các bản thử `DauProbeA1–A4` của vòng đầu ở mục 8.1b, nên bộ đệm liệt kê các bản thử mà không có `DauInputMethod.app`.
  - Lần mở lại lúc 16:36 không ghi lại bộ đệm này.
  - Bộ đệm của TextEdit và của một app thử có sandbox, dựng sau khi cài Dấu, thì có `DauInputMethod.app`.
- **Đã sửa được:** thoát Telegram, chuyển hai file đó ra chỗ khác, mở lại. Bộ đệm mới có `DauInputMethod.app`; chọn Dấu bằng menu và bằng ⌃⌥Space đều được; Dấu nhận 11/11 phím.
- Ngày 30/10, Dấu gõ đúng trong Telegram (nhật ký 30/10).
- **Đã đo để loại trừ:**
  - Sandbox nói chung: app thử có sandbox, ký ad-hoc, có và không có hardened runtime, đều để Dấu nhận phím.
  - Secure Event Input: không tiến trình nào giữ.
  - Telegram không gọi `allowedInputSourceLocales` hay `TISSelectInputSource`.

[Máy/Dấu] Mục 10.10.

#### 9.11 04/11, 17:35–17:38: luồng bật theo D37 đã sửa, ca Telegram
Dựng lại đúng ca lỗi của mục 9.10, và lần này luồng bật sửa được (bản Debug).
- **Chuẩn bị:**
  - Bỏ Dấu bằng "–" qua trợ năng.
  - Đặt lại cho Telegram bộ đệm cũ lúc 10:16 (không có `DauInputMethod.app`), mở Telegram. Telegram chạy suốt, không mở lại (cùng pid).
- **Bật:** mở Dấu.app, cửa sổ thiết lập ở bước 2, bấm "Bật Dấu".
  - App xoá 107 file bộ đệm. 5 thư mục được hệ thống bảo vệ không liệt kê được: ba thư mục WebKit, hai thư mục bộ đệm của Shortcuts. Nhật ký kernel ghi `System Policy: Dau deny file-read-metadata`, không có yêu cầu nào tới TCC, không có hộp thoại xin quyền.
  - Sau đó đăng ký (0) và bật mục cha (0).
  - Hộp thoại `Allow “Dấu” to enable “Dấu”?` hiện; bấm Allow. macOS ghi mục sau 3 s.
  - Lượt quét lại đọc 20 bộ đệm đã dựng lại, không bộ đệm nào thiếu Dấu.
- **Kết quả ở Telegram (vẫn chạy suốt):**
  - Bộ đệm của Telegram được dựng lại lúc 17:37:47 và có `DauInputMethod.app`.
  - Chọn "Dấu – Tiếng Việt" từ menu nhập liệu được.
  - Dấu nhận 6/6 phím ở ô tìm kiếm, ra "việt".
  - ⌃⌥Space đi qua cả Dấu.
- Quét lại toàn bộ thư mục cache: không còn bộ đệm riêng nào lệch so với bộ đệm chung.

[Máy/Dấu] Mục 10.10.

#### 9.12 05/11, 09:44–09:48: đăng xuất rồi đăng nhập có làm mới bộ đệm riêng của từng app không
Dấu thật đã bật; app thử có sandbox `local.probe.cacheL1`, ký ad-hoc, dựng trong `build/probe.noindex/L/`; máy chạy liên tục từ 29/10, không khởi động lại.
- **Trước khi đăng xuất:**
  - Thay bộ đệm của app thử bằng một bộ đệm cũ (04/11 08:47, không có `DauInputMethod.app`). Chạy app thử: nó dùng bộ đệm đó, giờ ghi giữ nguyên, **không thấy Dấu** (09:45:08).
  - Chụp 26 bộ đệm (bộ đệm chung và từng app; giờ ghi, inode, có Dấu không): 25 có Dấu, chỉ bộ đệm của app thử không có. Bộ đệm của Telegram ghi lúc 04/11 17:56:37. Telegram đang chạy.
- **Người dùng đăng xuất và đăng nhập lại (09:46).** Chụp lại lúc 09:47:26, trước khi mở app nào:
  - Bộ đệm chung và bộ đệm của 12 tiến trình chạy lúc đăng nhập (MenuBarAgent, notificationcenterui, PressAndHold…) được ghi mới (09:46:41–09:46:52, inode mới), đều có Dấu.
  - Bộ đệm của app thử và của Telegram (chưa chạy) **còn nguyên**: cùng inode, cùng giờ ghi. Đăng xuất không xoá bộ đệm.
- **Mở app sau khi đăng nhập:**
  - App thử: lần chạy đầu (09:47:35) dựng lại bộ đệm (inode mới) và **thấy Dấu**. Lần chạy sau (09:48:12) dùng lại bộ đệm 09:47:35.
  - Telegram (mở ở chế độ nền, 09:47:49): bộ đệm cũng được dựng lại ngay khi mở (inode mới), có Dấu.
- **Tóm lại:** sau một lần đăng nhập mới, mỗi app có sandbox dựng lại bộ đệm của nó ở lần đầu đọc nguồn đầu vào, kể cả khi bộ đệm cũ không có Dấu.
  - Trước đăng xuất, mở lại app không làm điều này (mục 9.10, vòng bộ đệm riêng ở mục 8.1b).
  - Vì vậy đăng xuất rồi đăng nhập sửa được ca Telegram của mục 9.10 mà không cần xoá bộ đệm bằng tay.
  - Chưa đo: khởi động lại máy, macOS 14–26.
  - Vì sao hệ thống coi bộ đệm cũ là hết hạn sau khi đăng nhập thì chưa biết: trước đăng xuất, bộ đệm chung cũng mới hơn bộ đệm của app thử mà app thử vẫn dùng bộ đệm cũ.

[Máy/Dấu] Mục 10.10.

### Bảng đổi số mục (11/11/2026)

Tài liệu cũ, chú thích trong mã và nhật ký dẫn số mục cũ; "(b)N" là mục 9.N cũ, "(d)N" là mục 10.N cũ.

| Mục cũ | Mục mới của `docs/research/INPUT-METHOD-INSTALL.md` |
|---|---|
| 0 | Hiện trạng |
| 1.1–1.3, 1.4 | 7 |
| 2.1 | 1.7 |
| 2.2 | 2 |
| 2.3 | 1.5, 1.6 |
| 2.4, 2.5 | 9 |
| 2.6 | 4 |
| 2.7 | 10.3 |
| 3 | 6 |
| 4 | 5.1 |
| 4.1 | 5.2 (kế hoạch đo và kết quả: mục 1.2 ở đây) |
| 5 | 8 |
| 6.1 | Hiện trạng, 1.1, 5.1 |
| 6.2, 7, 8.2 | chỉ ở đây |
| 8.1, 8.1b | 1.4, 2.1, 3.3, 5.1 (tóm tắt); bảng theo giờ ở đây; hình dạng hộp thoại: `docs/research/SYSTEM-SETTINGS-REFERENCE.md` |
| 9.1 | 6 |
| 9.2, 9.3 | 7 |
| 9.4, 9.5, 9.6, 9.8, 9.9 | 1.2, 1.3 |
| 9.7 | 5.2 |
| 9.10, 9.12 | 3.2 |
| 9.11 | 1.3, 3.2 |
| 10.1, 10.3 | 10.1 |
| 10.2 | 10.2 |
| 10.4 | 10.3 |
| 10.5 | 10.4 |
| 10.6 | 10.8 |
| 10.7 | 5.1 (đã trả lời) |
| 10.8 | 10.5 |
| 10.9 | 10.6 |
| 10.10 | 3, 10.7 |

## 2. `docs/research/OPENKEY-NOTES.md`

Mục 6 và 7 cũ. Ca nào Dấu cố ý khác OpenKey vẫn nằm ở mục 5 của tài liệu hiện hành, kèm tên test; mọi ca khác của mục 6 cũ có trong test của engine (`Packages/DauEngine/Tests/DauEngineTests`), kiểm bằng grep ngày 11/11/2026.

Đổi số mục: 1, 2 giữ số; 3.N thành 2.N; 4 (B1–B19) thành 3; 5 chuyển sang `docs/research/IMK-API-NOTES.md`; 6 thành 5 (chỉ ca Dấu cố ý khác) và phần dưới đây; 7 chỉ ở đây; 8 (XKey) thành 4.

### 6. Ca biên đề xuất cho bộ test

Kết quả mong đợi viết theo chính tả tiếng Việt và DECISIONS.md, **không** lấy từ OpenKey (D10).
Cấu hình mặc định theo D15: Telex, kiểu mới, bỏ dấu tự do bật, tự khôi phục bật, nâng cao tắt. Dòng nào khác cấu hình mặc định thì ghi rõ.

Cột "So với OpenKey" có hai giá trị:
- **Khác (cố ý)**: Dấu cố ý khác OpenKey.
- Bỏ trống: kết quả được dự đoán là giống OpenKey.

Không còn ca nào chờ chốt (`dD` theo D34, `duo7c59` theo D28, chốt 29/10/2026). Ca do phiên chính thêm theo các quyết định mới gom ở 6.9 (đã duyệt 29/10/2026).

Cột "Ghi chú" dẫn số quyết định khi kết quả do quyết định đó định ra.

#### 6.1 Nhóm từ trùng Anh–Việt và khôi phục (D4)

| Chuỗi phím | Mong đợi | Ghi chú | So với OpenKey |
|---|---|---|---|
| `car␣` | `cả␣` | tiếng Việt thắng | |
| `carr␣` | `car␣` | gõ đúp giữ chữ gốc | |
| `carrs␣` | `cars␣` | sau gõ đúp, phần còn lại của từ là chữ thường (D26) | |
| `sex␣` | `sẽ␣` | | |
| `sexx␣` | `sex␣` | | |
| `has␣` | `há␣` | | |
| `as␣` | `á␣` | | |
| `ass␣` | `as␣` | | |
| `test␣` | `tét␣` | "tét" hợp lệ (t cuối + sắc) | |
| `tesst␣` | `test␣` | | |
| `windows␣` | `windows␣` | không hợp lệ → khôi phục | |
| `Sunrise␣` | `Sunrise␣` | giữ chữ hoa như đã gõ | |
| `Sunrise,` | `Sunrise,` | | |
| `Sunrise!` | `Sunrise!` | mọi dấu câu là ranh giới từ (D4) | **Khác (cố ý)**. OpenKey giữ chữ đã biến đổi, không khôi phục (B10) |
| `vieetj␣` | `việt␣` | | |
| `did␣` (bỏ dấu tự do bật) | `đi␣` | d sau nguyên âm biến d đầu từ thành đ; "đi" hợp lệ nên tiếng Việt thắng (D28, D4) | |
| `pdd␣` | `pdd␣` | "pđ" không hợp lệ → khôi phục | Khác (cố ý), B7, B19 |

#### 6.2 Phím biến đổi Telex và gõ đúp

| Chuỗi phím | Mong đợi | Ghi chú | So với OpenKey |
|---|---|---|---|
| `dd` | `đ` | | |
| `ddd` | `dd` | D26 | |
| `ddi` / `did` | `đi` | (`did`: xem 6.1) | |
| `aa` / `aaa` | `â` / `aa` | | |
| `ee`, `oo` | `ê`, `ô` | | |
| `aw`, `ow`, `uw` | `ă`, `ơ`, `ư` | | |
| `aww` | `aw` | | |
| `w` | `ư` | w đứng riêng | |
| `ww` | `w` | D26 | |
| `wa` | `ưa` | Telex (D23), kể cả khi bật gõ tắt phụ âm | |
| `tw` / `trw` | `tư` / `trư` | | |
| `aaw` | `ă` | w thay mũ bằng trăng | |
| `asz` | `a` | z xoá dấu | |
| `az` | `az` | không có dấu để xoá | |
| `asf` | `à` | đổi dấu | |
| `xooong␣` | `xoong␣` | ooo → oo, vẫn gõ dấu được (`xooongf` → `xoòng`) (D26) | |
| `uow` | `uơ` | D35: cặp đứng cuối từ ("huơ", "thuở"); gõ tiếp thì thành ươ (`uown` → `ươn`) | |
| `tuwongf` | `tường` | ưo + phụ âm cuối → ươ | |
| `thuowr` | `thuở` | | |
| `THUOWR` | `THUỞ` | | Khác (cố ý), B4 |
| `huow` | `huơ` | | Khác (cố ý), B4 |
| `huowu` | `hươu` | | |
| `nguoiwf` | `người` | | |
| `nguwowif` | `người` | | |
| `dduowcj` | `được` | | |
| `truwowngf` | `trường` | | |

#### 6.3 Đặt dấu

| Chuỗi phím | Mới | Cũ | Ghi chú |
|---|---|---|---|
| `hoaf` | `hoà` | `hòa` | D15 |
| `hoef` | `hoè` | `hòe` | |
| `khoer` | `khoẻ` | `khỏe` | |
| `thuys` | `thuý` | `thúy` | |
| `quys` | `quý` | `quý` | u sau q không tính là nguyên âm |
| `hoangf` | `hoàng` | `hoàng` | có phụ âm cuối thì hai kiểu như nhau |
| `thuyeenf` | `thuyền` | `thuyền` | |
| `quyeets` | `quyết` | `quyết` | |
| `gias` | `giá` | `giá` | |
| `gif` | `gì` | `gì` | |
| `ginf` | `gìn` | `gìn` | |
| `giuwax` | `giữa` | `giữa` | |
| `muaf` | `mùa` | `mùa` | |
| `cuwar` | `cửa` | `cửa` | |
| `quas` | `quá` | `quá` | |
| `kiaf` | `kìa` | `kìa` | |
| `hoaif` | `hoài` | `hoài` | |
| `khuyur` | `khuỷu` | `khuỷu` | cụm ba nguyên âm uyu: dấu ở giữa (y) |
| `ho` `f` `a` (gõ dấu trước khi đủ nguyên âm) | `hoà` | `hòa` | dấu tự đặt lại (bỏ dấu tự do) |
| `vieejt` | `việt` | `việt` | dấu gõ trước phụ âm cuối |

#### 6.4 Chữ hoa, chữ số, từ dài

| Chuỗi phím | Mong đợi | So với OpenKey |
|---|---|---|
| `VIEETJ` | `VIỆT` | |
| `Vieetj` | `Việt` | |
| `Dd` / `DD` | `Đ` | |
| `dD` | `đ` (phím biến đổi không đổi kiểu hoa) | D34 |
| `W` | `Ư` | |
| `a1␣` (Telex) | `a1␣` | |
| `2024␣` (VNI) | `2024␣` | |
| `a1` (VNI) | `á` | |
| `a11` (VNI) | `a1` (D26) | |
| `a71␣` (VNI) | `a71␣` | Khác (cố ý), B13 |
| `toi6` (VNI) | `tôi` | |
| `d9uo7c5` (VNI) | `được` | |
| `duo7c59` (VNI, 9 gõ sau cùng) | `được` | D28 (VNI 9 không cần đứng sát) |
| `supercalifragilistic␣` | giữ nguyên | |
| từ 40 chữ cái bất kỳ + `␣` | giữ nguyên, không mất chữ (D33) | Khác (cố ý), B15 |

#### 6.5 Gõ tắt phụ âm (bật Nâng cao → Gõ tắt phụ âm)

| Chuỗi phím | Mong đợi | Ghi chú | So với OpenKey |
|---|---|---|---|
| `fan␣` | `phan␣` | | |
| `Fan␣` / `FAN␣` | `Phan␣` / `PHAN␣` | | |
| `fanf␣` | `phàn␣` | trước khi nhấn Space hiện `fàn` (D21) | |
| `big␣` | `big␣` | "bing" không hợp lệ → khôi phục | **Khác (cố ý)**, D21. OpenKey: "bing" |
| `bag␣` | `bang␣` | từ trùng, chấp nhận (D21) | |
| `vih␣` | `vinh␣` | | |
| `jas␣` | `giá␣` | | |
| `baks␣` | `bách␣` | | |
| `bak␣` | `bak␣` | "bach" không dấu thanh không hợp lệ (D31) → khôi phục | **Khác (cố ý)**. OpenKey: "bach" |
| `fix␣` | `phĩ␣` | từ tiếng Anh bị đổi vì "phĩ" hợp lệ, chấp nhận (D21) | |
| `wa␣` (Telex) | `ưa␣` | D23 | |
| `wen␣` (VNI) | `quen␣` | D23 | |
| `fan,` | `phan,` | dấu phẩy là ranh giới từ (D4, D21) | |

#### 6.6 Cho phép z, f, w, j (bật; gõ tắt phụ âm tắt theo D22)

| Chuỗi phím | Mong đợi |
|---|---|
| `fanf␣` | `fàn␣` |
| `zas␣` | `zá␣` |
| `wa␣` (Telex) | `ưa␣` (w đầu từ vẫn là ư, D23) |

#### 6.7 Ràng buộc chính tả (D31, D30)

| Chuỗi phím | Mong đợi | Lý do | So với OpenKey |
|---|---|---|---|
| `tatf␣` | `tatf␣` | vần t không mang huyền | |
| `capf␣` | `capf␣` | vần p không mang huyền | **Khác (cố ý)**. OpenKey: "càp" |
| `cacr␣` | `cacr␣` | vần c không mang hỏi | |
| `kas␣` | `ká␣` | D31 nới cho địa danh: k đứng trước mọi nguyên âm | Giống OpenKey (sau khi nới) |
| `DDawks Lawks␣`, `Bawsc Kajn␣`, `Kroong Pawsc␣`, `Kow Tu␣` | `Đắk Lắk␣`, `Bắc Kạn␣`, `Krông Pắc␣`, `Kơ Tu␣` | D31 phương án d (âm cuối k chỉ sau ă, phụ âm đầu kr) | |
| `ask␣`, `task␣`, `desk␣`, `hawk␣` | giữ nguyên | D31: âm cuối k không nhận sau a/e; "ăk" không dấu không hợp lệ | |
| `karma␣`, `hawks␣`, `awkward␣` | `kẩm␣`, `hắk␣`, `akward␣` | hệ quả đã chấp nhận của D31 phương án d | |
| `ghus␣` | `ghus␣` | gh chỉ đứng trước i, e, ê | **Khác (cố ý)** |
| `aw␣` | `ă␣` | chữ ă đứng một mình được giữ (D31 (Âm tiết tiếng Việt hợp lệ), ý "Chữ cái đứng một mình"); `traw␣` vẫn khôi phục vì ă không đứng cuối âm tiết | Giống OpenKey |
| `pin␣` / `pins␣` | `pin␣` / `pín␣` | "p" đơn là phụ âm đầu hợp lệ (D31) | |

#### 6.8 "Thêm dấu cho từ đã gõ" (D20; bộ đệm rỗng, chữ đọc từ ứng dụng)

| Chữ có sẵn + phím | Mong đợi | Ghi chú |
|---|---|---|
| `hoc` + `j` | `học` | |
| `dep` + `j` | `dẹp` | không phải "đẹp" (UI.md) |
| `car` + `s` | `cars` | "cár" không hợp lệ → phím đi thẳng (D20) |
| `viet` + `j` | `vietj` | "viẹt" không hợp lệ; không tự thêm mũ (D20) |
| `viet` + `e` + `j` | `việt` | phím biến đổi cũng áp dụng (D20) |
| `nha` + `f` (ra `nhà`), rồi `k␣` | `nhafk␣` | Mốc khôi phục = chữ hiển thị trước khi sửa + các phím gõ sau đó (D4 mốc khôi phục; bài học B12) |

#### 6.9 Ca thêm theo quyết định mới (đã duyệt 29/10/2026)

Người dùng đã duyệt câu chữ DECISIONS cho các ca này (D4 mốc khôi phục, D26, D28, D29, D30, D33). Dùng làm tiêu chí đóng mốc.

| Chuỗi phím | Mong đợi | Căn cứ | Ghi chú |
|---|---|---|---|
| `vieetj␣` | `việt␣` | D30 (tiền tố), D28 | |
| `hocj␣` | `học␣` | D30 (tiền tố) | |
| `trawngf␣` | `trằng␣` | D30 (tiền tố), D31 | |
| `aw␣` | `ă␣` | D31 (chữ cái đứng một mình) | trùng 6.7 |
| `carr␣` | `car␣` | D4, D26 | trùng 6.1 |
| `tesst␣` | `test␣` | D4, D26 | trùng 6.1 |
| `tesst` ⌫ `s` | `tess` | D26 (khoá giữ sau ⌫), D32 | "test" ⌫ → "tes"; "tes" không hợp lệ (s không là phụ âm cuối) nên `s` đi thẳng |
| `tuongw` (Telex) | `tương` | D29 cho Telex | |
| `tuongw` (Telex đơn giản) | `tương` | D29 | |
| `did␣` (bỏ dấu tự do **tắt**) | `did␣` | D28 | |
| từ vượt 7 chữ cái (ví dụ `windowsx`) | khôi phục ngay về đúng phím đã gõ | D33 | |
| `nha` + `f` + `k␣` (D20) | `nhafk␣` | D4 mốc khôi phục | mốc là chữ đọc từ ứng dụng |
| `dD` | `đ` | D34 | |
| `password␣` / `passsword␣` | `pasword␣` / `password␣` | D26 (chữ lặp trùng phím dấu gõ 3 lần) | |
| `cofffee␣`, `errror␣` | `coffee␣`, `error␣` | D26 | |
| seed `cả` + `r` | `car` | D20 + D26 | |
| `uown`, `nguwowif` | `ươn`, `người` | D35 | |

### 7. Mâu thuẫn và điểm mơ hồ với DECISIONS.md

Ban đầu mục này chỉ liệt kê. Đến 29/10/2026 (commit `22f3e4d`) mọi điểm đều đã được chốt, trừ điểm "Ví dụ trong D20 dễ đọc nhầm" và điểm cuối (không có vi phạm) là ghi chú.
Mỗi mục giữ nội dung gốc để truy vết, kèm dòng "Đã chốt".

- **Ranh giới từ kích hoạt khôi phục và gõ tắt phụ âm.**
  - D4 và D21 ghi "khi nhấn Space", còn ARCHITECTURE (luồng một phím, bước 4) ghi "Space/dấu câu".
  - OpenKey: Space cùng một tập dấu câu và Enter/Tab/Esc/mũi tên, nhưng không có ! ( ) (3.16, B10).
  - Đề xuất ở 3.16: mọi phím kết thúc từ có in ra ký tự, gồm Space, Return, Tab và mọi dấu câu; không khôi phục khi mũi tên, Esc, chuột hoặc tổ hợp phím.
  - Cần sửa D4/D21 hoặc ARCHITECTURE cho khớp.
  - **Đã chốt: D4 (phần "Ranh giới từ") và D21.** Mọi ký tự kết thúc từ có in ra (Space, Enter, Tab, mọi dấu câu) kích hoạt khôi phục và gõ tắt; mũi tên, Esc, chuột, tổ hợp phím chỉ reset.
- **"Bỏ dấu tự do" chưa được định nghĩa** (D15 chỉ ghi mặc định bật). Có hai cách hiểu:
  - (a) cho phép gõ phím dấu và phím biến đổi ở bất kỳ đâu trong từ, kể cả sau phụ âm cuối, và dấu tự vào đúng chỗ. Khi tắt thì phím dấu phải gõ ngay sau nguyên âm.
  - (b) theo nghĩa của biến engine OpenKey: không tự dời dấu khi gõ thêm nguyên âm.

  Đề xuất (a). Cần chốt thêm: dd (đ) đặt sau nguyên âm ("did" → "đi") có thuộc phạm vi này không, vì nó làm "did" → "đi".
  - **Đã chốt: D28.** Theo nghĩa (a); "did" → "đi" khi bật; tắt thì phím dấu chỉ có tác dụng ngay sau nguyên âm.
- **"Telex đơn giản" chưa được định nghĩa.**
  - OpenKey có hai biến thể (3.5).
  - Đề xuất: Telex bỏ w đứng riêng và bỏ `[ ]`.
  - Cần chốt thêm: D23 có áp dụng cho Telex đơn giản không. Với định nghĩa đề xuất, w đầu từ là chữ w, nên câu hỏi là có cho gõ tắt w → qu hay không.
  - **Đã chốt: D29.** Simple Telex 1, không `[ ]`, không w → qu.
- **Không có công tắc "kiểm tra chính tả" riêng.**
  - Khi người dùng tắt "Tự khôi phục từ không phải tiếng Việt": engine có còn ngừng biến đổi sau khi từ đã sai chính tả không ("Sunrise" dừng ở "Sủnise" hay phím dấu sau đó vẫn biến đổi tiếp…)?
  - Đề xuất: luôn kiểm tra chính tả bên trong, công tắc chỉ điều khiển việc khôi phục khi kết thúc từ.
  - **Đã chốt: D30.** Kiểm tra chính tả luôn chạy; công tắc chỉ điều khiển khôi phục.
- **"Âm tiết tiếng Việt hợp lệ" chưa được định nghĩa**, trong khi D4, D20 và D21 đều dựa vào nó. Cần chốt:
  - (a) có áp phân bố c/k/q, g/gh, ng/ngh không;
  - (b) vần tắc p, t, c, ch: chỉ cho sắc/nặng, và có chấp nhận khi chưa có dấu thanh không (ảnh hưởng `bak␣` → `bach␣`);
  - (c) ă/â có bắt buộc phụ âm cuối không (`aw␣`);
  - (d) phụ âm đầu "p" đơn (pin, pa-tê) có hợp lệ không;
  - (e) danh sách vần hợp lệ. Đề xuất engine-dev lập bảng vần riêng theo chính tả, không chép bảng OpenKey (bảng đó có mục lạ như "ôô", "uao").
  - **Đã chốt: D31.** Có "p"; áp phân bố c/k/q, g/gh, ng/ngh; bảng vần tự lập; vần tắc chỉ sắc/nặng, không dấu là sai; ă, â không đứng cuối (trừ chữ đứng một mình, quyết định sau đó).
- **Phạm vi "gõ đúp".** D4 nói "gõ đúp phím dấu theo chuẩn Telex". Chưa nói:
  - (a) ở VNI thì gõ đúp số có tương đương không (đề xuất có);
  - (b) sau khi gõ đúp, phần còn lại của từ có là chữ thường không ("carrs" → "cars");
  - (c) gõ đúp phím mũ/móc/d (aaa, ww, ddd) có cùng luật không.

  Đề xuất có cho cả ba.
  - **Đã chốt: D26.** Cả ba: VNI có, phần còn lại của từ đi thẳng, cùng luật cho phím biến đổi; ngoại lệ "ooo".
- **Ví dụ trong D20 dễ đọc nhầm.**
  - "car giữ bằng carr, sau đó gõ thêm s vẫn ra cars" có thể hiểu là trong cùng một từ, khi đó do luật gõ đúp (nay là D26) chứ không phải D20.
  - Hoặc hiểu là sau khi rời từ rồi quay lại, khi đó mới đúng là D20.
  - Hai cách hiểu cho cùng kết quả, nên ghi rõ cả hai trong test.
  - (D20 nay đã ghi rõ: "quay lại gõ thêm" là D20, "gõ liền trong cùng từ" là D26.)
- **D21 với từ tiếng Anh mở rộng ra âm tiết hợp lệ.**
  - "fix" → "phĩ". D21 chấp nhận "bag → bang", nên đây là hệ quả cùng loại, nhưng nên ghi vào giao diện/test để không bị coi là lỗi.
  - Ngoài ra D21 không nói gì về **trạng thái trong lúc gõ**: khi bật gõ tắt, f/j/(w ở VNI) đầu từ và g/h/k cuối từ phải được coi là phụ âm tạm hợp lệ, thì phím dấu gõ sau đó mới có tác dụng ("fanf" hiện "fàn" trước khi nhấn Space). Đề xuất ghi rõ.
  - **Đã chốt: D21.** "fix" → "phĩ" chấp nhận, ghi trong test; f, j đầu và g, h, k cuối là phụ âm tạm hợp lệ trong lúc gõ.
- **Câu chữ của D23.**
  - D23 viết "w ở đầu từ luôn là ư/ơ". Nhưng w đứng riêng chỉ cho ra "ư"; "ơ" chỉ có từ "ow", hoặc từ `[` ở OpenKey.
  - Đề xuất sửa thành "luôn là ư".
  - **Đã chốt: D23 (sửa câu chữ thành "luôn là ư").**
- **"Cho phép w" không có tác dụng ở Telex.**
  - Do D23, w đầu từ luôn thành ư (3.12).
  - Giao diện "Cho phép phụ âm z, f, w, j" có thể gây hiểu nhầm ở Telex (N5 (Chỉ hứa điều đã kiểm chứng)).
  - Đề xuất ghi chú hoặc chỉ hiện "w" khi dùng VNI/Telex đơn giản.
  - **Đã chốt: D22.** Giao diện ghi chú "cho phép w" không có tác dụng khi dùng Telex.
- **Phím mũi tên.**
  - ARCHITECTURE: mũi tên chỉ reset; OpenKey: mũi tên còn khôi phục.
  - Đề xuất giữ như ARCHITECTURE (điểm "Ranh giới từ" ở trên).
  - **Đã chốt: D4 (phần "Ranh giới từ").** Mũi tên chỉ reset, không khôi phục.
- **Backspace chưa được đặc tả.**
  - ARCHITECTURE không nói Backspace tác động lên bộ đệm và phím gốc thế nào.
  - Đề xuất: Backspace bỏ chữ cuối hiển thị, đặt lại dấu, và đổi mốc khôi phục của từ thành "chữ đang hiển thị". Tránh lệch kiểu OpenKey (3.17, B12).
  - **Đã chốt: D32.** Backspace bỏ chữ cuối, đặt lại dấu, mốc khôi phục là chữ đang hiển thị.
- **"Thêm dấu cho từ đã gõ" (D20) cần chốt chi tiết:**
  - (a) chỉ phím dấu thanh, hay cả phím biến đổi (aa, w, dd);
  - (b) "viet" + `j`: "viẹt" không hợp lệ nên phím đi thẳng ("vietj"), hay engine được tự thêm mũ thành "việt";
  - (c) mốc khôi phục khi từ trở nên không hợp lệ (đề xuất: chữ hiển thị + phím mới);
  - (d) có làm "lịch sử từ" qua Backspace như OpenKey không (3.17). Nếu có thì tránh B12.
  - **Đã chốt: D20 (chi tiết 29/10/2026).** (a) cả phím dấu thanh và phím biến đổi; (b) không tự thêm biến đổi, "viet" + j → "vietj"; (d) không làm lịch sử từ. (c) mốc khôi phục chưa ghi trực tiếp, suy ra từ D32 (xem 6.8).
- **Độ dài từ tối đa.** Chưa có quyết định (3.15).
  - **Đã chốt: D33.** Dài hơn 7 chữ cái thì khôi phục ngay về chuỗi phím đã gõ, phím còn lại đi thẳng (tắt công tắc tự khôi phục thì chỉ ngừng biến đổi); bộ đệm cố định.
- **Quick Telex (cc → ch…)** không có trong DECISIONS. Đề xuất ghi vào "Đã cân nhắc và loại bỏ": phá từ tiếng Anh có phụ âm đôi, trùng mục đích với gõ tắt phụ âm.
  - **Đã chốt: mục "Đã cân nhắc và loại bỏ" (Quick Telex); từ 04/11/2026 nằm ở mục "Đã biết nhưng không làm".**
- **Phím `[` `]` ở Telex** không có trong DECISIONS. Đề xuất không làm hoặc chốt rõ: xung đột với gõ code/markdown, và "Telex đơn giản" theo đề xuất đã bỏ chúng.
  - **Đã chốt: D27.** `[ ]` luôn là dấu câu.
- **Tạm tắt chính tả/bộ gõ bằng nhấn-nhả ⌃/⌘** (OpenKey). Đề xuất ghi vào "Đã cân nhắc và loại bỏ" cho rõ, cùng tinh thần D2 (không phím riêng; mục loại bỏ đã có "phím chuyển nhấn-nhả ⌃ hoặc ⇧").
  - **Đã chốt: mục "Đã cân nhắc và loại bỏ" (tạm tắt bằng nhấn-nhả ⌃/⌘), cùng D30; từ 04/11/2026 nằm ở mục "Đã biết nhưng không làm".**
- **Chưa phát hiện vi phạm N1, N2 (Bộ gõ không có quyền mạng), N3, N4 (Không tự đổi cài đặt hệ thống) hay N5 trong bản thân DECISIONS.** Chỉ lưu ý: ví dụ giao diện "vieetj → việt" ở mục Thông minh đúng theo luật, còn "car → cả" và "carr → car" khớp D4.

## 3. `docs/research/external-test-inputs/README.md`

Quy trình dự kiến, các lần sửa `extract.sh`, đếm sơ bộ, diễn biến số ca và các bước chốt D20 của bản trước.

Đổi số mục: 1 thành 3.1 và phần dưới; 2.1, 2.2, 3 thành 4.1, 4.2, 4.3; 4 và 5.N thành 5 và 5.N; 6 thành 3.5 và phần dưới; 7, 8 thành 6; 9.1 thành 3.2, 3.3; 9.2 thành 1; 9.3, 9.4, 9.5, 9.6 thành 1.1, 1.2, 1.3, 1.4; 9.7 thành 2.1; 9.8 thành 2.2, 3.4 và phần dưới. Định nghĩa các lớp A–X (trước ở Hiện trạng): 3.3.

### Hiện trạng cũ: lần sửa `extract.sh` (05/11/2026)

  - `extract.sh` đã sửa cho 43 ca trích sai lúc đầu (mục 9.6):
    - bỏ 14 ca của test chỉ in kết quả;
    - ghi đủ số ⌫ của vòng lặp và hàm phụ;
    - đọc đúng tuỳ chọn của hàm tạo engine ở gonhanh;
    - tách nhánh `if` ở XKey;
    - đọc lại hàng đợi commit của fcitx5-unikey.
  - So với bản trước:
    - gonhanh bỏ 3 ca (test macro, D3 (Không macro, chỉ Unicode dựng sẵn)), đổi 12;
    - uvie-rs bỏ 14, đổi 38;
    - XKey đổi 6 ca;
    - fcitx5-unikey đổi ghi chú 1 ca;
    - sáu nguồn còn lại ra đúng từng byte như trước.

### 1. Quy trình mù

1. Engine-dev chỉ đọc `docs/research/external-test-inputs/*.tsv` và file này, viết kết quả mong đợi theo chính tả tiếng Việt và `docs/DECISIONS.md` (D10 (Engine tự viết): không lấy kết quả của bộ gõ khác làm đáp án).
2. Chạy engine của Dấu trên các ca đó; ca nào Dấu khác đáp án của chính Dấu là lỗi của Dấu. (Đã làm bằng bất biến thay cho đáp án từng ca, xem Hiện trạng.)
3. Chỉ sau bước 2, người so sánh mới mở `build/external-answers/` và đánh dấu các ca Dấu khác họ.
   - Mỗi ca khác nhau được xét theo DECISIONS.md. Kết quả là một trong ba:
     - Dấu cố ý khác (ghi vào `docs/research/OPENKEY-NOTES.md` hoặc ghi chú test);
     - đáp án của Dấu sai;
     - cần quyết định mới (hỏi người dùng).
   - Đáp án của họ không bao giờ được chép thẳng vào test.

Lưu ý: engine của XKey ghi trong mã là bản chuyển trực tiếp từ engine OpenKey (`XKey/Core/Engine/VNEngine.swift` của họ), nên đáp án của XKey gần với hành vi OpenKey; theo D10 nó chỉ được dùng để tìm ca đáng xem lại, như mọi nguồn khác.

### 6. Đếm sơ bộ trên đáp án của họ (không trích đáp án)

Người trích chạy một bộ kiểm âm tiết tạm (luật D31 rút gọn, viết riêng cho việc đếm này, không dùng trong engine): `scripts/research/external-tests/answer_stats.py`, đọc `build/external-answers/`, chỉ in số đếm.
Chỉ xét ca kết thúc bằng ranh giới từ (hoặc ca ibus-teni, vốn là từ trọn vẹn).
Đây là số đếm heuristic trước khi xem từng ca; kết quả xem từng ca ở mục 9.

| Nguồn | Ca kết thúc từ có đáp án | Đáp án còn một từ có dấu không phải âm tiết hợp lệ | Dấu thanh ở chữ mà cả hai kiểu đều không cho | Kiểu đặt dấu khác tuỳ chọn của chính test |
|---|---|---|---|---|
| fcitx5-unikey | 1.323 | 384 (họ tắt kiểm tra chính tả và khôi phục) | 0 | 0 |
| ibus-teni | 3.049 | 1.579 (từ điển riêng của họ có viết tắt, từ mượn) | 6 (cùng một từ trong từ điển đặc biệt, 6 thứ tự gõ) | 0 |
| gonhanh | 1.819 | 42 | 2 (gi + i, khó phân định) | 0 |
| ibus-telex | 250 | 20 | 0 | 0 |
| uvie-rs | 82 | 2 | 0 | 2 |
| goxkey | 2 | 1 | 0 | 0 |
| bamboo-core, ibus-bamboo, vi-rs, XKey | 0–5 | 0 | 0 | 0 |

Không có ca nào có huyền, hỏi hoặc ngã trên vần kết thúc bằng p, t, c, ch.
Cột thứ ba là nhóm đáng xem lại nhất ở bước 3:

- theo D4 và D31, Dấu khôi phục các từ đó khi kết thúc từ, nên đáp án của Dấu sẽ khác ở hầu hết các ca này;
- một phần là khác biệt có chủ ý (bộ gõ không khôi phục);
- một phần có thể là lỗi chính tả trong đáp án của họ (sai luật phân bố phụ âm đầu hoặc vần không có trong tiếng Việt).

### Mục 9.2 cũ: từ lần xét đầu tới số hiện hành

**Lần xét đầu** (cùng ngày, trước khi sửa engine, khung test và `extract.sh`): 10.320 ca, 240 họ không kiểm chữ, 7.971 khớp, 2.109 khác (A 359, B 1.492, C 73, D 10, E 77, X 98).
Từ đó:

- 10 ca lớp D: 7 khớp, 3 sang A (D26, D35 ("uơ" và "ươ")).
- 77 ca lớp E: 16 khớp (câu hỏi về phím biến đổi khác loại, về dấu ngay sau "qu" và "qui", về vần "uêu"), 61 sang A theo quyết định đã chốt.
- 48 ca X thiếu mô phỏng D20: khớp cả.
- 7 ca X của XKey và bamboo-core mà họ không kiểm chữ trên màn hình: 5 khớp (vòng ⌫ nay ghi đủ), 2 còn X.
- 43 ca trích sai:
  - 6 bị bỏ (test chỉ in);
  - 23 khớp;
  - 11 sang A (D32 10, D31 1);
  - 1 sang B;
  - 1 thành câu hỏi về xoá hết từ dài bằng ⌫ rồi gõ từ mới (mục 9.8);
  - 1 thành X (nhánh `if` không xảy ra ở Dấu).
- 8 ca lần đầu khớp nay khác:
  - 3 X (`←` là `clear()`), 2 A (D20 + D26) và 1 ca chữ cái gõ sát chữ có sẵn (mục 9.8), do khung test nay mô phỏng D20;
  - 2 A do D35 mới ("uwo" → "uơ").

Sau đó, cùng ngày:

- Ca xoá hết từ dài bằng ⌫ khớp sau khi D33 chốt (commit 0a9bb4b).
- Ca chữ cái gõ sát chữ có sẵn và 3 ca A-D20 ("duow␣⌫c") khớp sau khi D20 đọc cả ở chữ cái đầu tiên.
- Với ba ngoại lệ của D20, 26 ca đổi đầu ra (mục 9.8):
  - 2 ca X của chuỗi gonhanh (`←` là `clear()`) nay khớp, ca X thứ ba vẫn X;
  - 2 ca B của uvie-rs ra chữ khác nhau nhưng vẫn B;
  - 22 ca còn lại vẫn khớp.

### Mục 9.6 cũ: đã giải quyết (05/11/2026)

- 43 ca do `extract.sh` trích sai ở lần đầu (xem Hiện trạng và mục 9.2):
  - uvie-rs: hàm phụ `backspace(&mut e, &mut screen)` không được nhận, vòng ⌫ chỉ ghi một lần, test chỉ in kết quả, vòng lặp qua mảng từ;
  - gonhanh: `engine_on()` bị đọc thành `autoRestore=off`;
  - XKey: hai nhánh `if` bị gộp;
  - fcitx5-unikey: hàng đợi commit của `testBasic#2`.
- 48 ca khung test bước 2 chưa mô phỏng D20, nay khớp cả 48 sau commit f39f066.

#### 9.8 Lớp E — cần người dùng quyết định (0; chín câu hỏi của lần xét đầu đã chốt)

Người dùng đã chốt chín câu hỏi ngày 05/11/2026; các ca còn khác nay thuộc lớp A (mục 9.3).
Vòng xét đầu đặt mã E1–E9 cho chín câu hỏi này.
Mã chỉ còn trong cột đầu của bảng dưới, để tra ngược: `docs/history/DECISIONS-LOG.md` (lưu trữ, không sửa) còn dẫn theo "E8" và "E9".

| Mã cũ | Câu hỏi | Ca lần đầu | Quyết định |
|---|---|---|---|
| E1 | Huyền/hỏi/ngã trên vần đã có âm cuối p, t, c, ch | 36 | D30: nhận giữa từ, kết thúc từ D4 khôi phục |
| E2 | Phím biến đổi khác loại trên nguyên âm đã có dấu phụ, kể cả cặp ươ | 10 | D28: đổi sang dấu mới ("ươ" + o → "uô") |
| E3 | Phím dấu ngay sau "qu"; "qui" có hợp lệ không | 10 | D31: nhận dấu ngay sau "qu" ("qusa" → "quá"), "qui" vẫn không hợp lệ; D32: "quá" ⌫ → "qu" |
| E4 | Mốc khôi phục sau gõ đúp làm từ tiếng Anh mất hơn một chữ | 13 | D26: ghi là giới hạn đã biết, giữ hành vi |
| E5 | b, m, p (và v) đi với âm đệm o/u | 5 | D31: hợp lệ ("more" → "moẻ") |
| E6 | z khi từ chưa có dấu thanh | 2 | D40: z là chữ, không bỏ mũ/móc |
| E7 | Vần "uêu" | 1 | D31: thêm "uêu" và "oao" vào bảng vần |
| E8 | Chữ cái thường gõ sát chữ có sẵn sau một lần reset: trước đây D20 chỉ đọc chữ trước con trỏ ở phím dấu/biến đổi, nên chữ cái bắt đầu từ mới ("q" có sẵn + "uer" → "qủe") | 1 | D20 ("Chữ cái gõ sát chữ có sẵn"): chữ cái đầu tiên cũng đọc từ trước con trỏ, chỉ nối khi từ ghép còn là tiền tố hợp lệ (D30) |
| E9 | Từ dài quá 7 chữ (D33) bị xoá hết bằng ⌫ rồi gõ từ mới ngay đó | 1 | D33: xoá hết từ bằng ⌫ thì hết trạng thái đi thẳng |

Hai câu hỏi của lần xét thứ hai (đáp án của họ trích nguyên văn chỉ để mô tả):

| Câu hỏi | Ví dụ (nguồn, id) | Phím | Dấu ra trước | Dấu ra bây giờ | Bộ gõ kia ra |
|---|---|---|---|---|---|
| Chữ cái sát chữ có sẵn (E8) | fcitx5-unikey `testunikey.cpp:testBasic.surrounding#1` (tắt tự khôi phục) | `⟦q⟧uer⏎` | qủe⏎ | quẻ⏎ (khớp) | fcitx5-unikey: commit "uẻ" sau chữ q có sẵn |
| Xoá hết từ dài bằng ⌫ (E9) | uvie-rs `feed_diff_tests.rs:diff_sticky_full_erase_restores_vietnamese#3` | `permission` + 10 ⌫ + `vieetj` | vieetj | việt (khớp) | uvie-rs: việt |

**Cách chọn cho chữ cái sát chữ có sẵn (câu hỏi E8; mô phỏng, 05/11/2026).**

- Ba phương án chạy bằng engine của Dấu trên 10.303 ca và các tình huống sửa chữ, qua bản sao khung test `ExternalCasesTests` (mô hình theo `InPlaceComposer`, chưa chạy trên Dấu thật):
  - chỉ đọc ở phím dấu/biến đổi, như trước (cách cũ);
  - đọc cả ở chữ cái đầu tiên và luôn nối vào từ đọc được (luôn nối);
  - như luôn nối nhưng chữ cái chỉ nối khi từ ghép còn là tiền tố hợp lệ (nối có điều kiện).
- So với cách cũ:
  - luôn nối ra khác ở 38 ca và làm hỏng 34 ca trong đó, vì dính từ mới vào từ trước con trỏ (sau ⌫ qua dấu cách hay sau reset, "ddi␣⌫hocj" ra "đihocj" thay vì "đihọc");
  - nối có điều kiện ra khác ở 4 ca: ca "q" + "uer" và 3 ca "duow␣⌫c" của gonhanh (`bug_reports_test.rs:bug_duow_restore_horn#1`, `bug_duow_double_break_backspace_horn#1`, `bug_dduow_break_backspace_final#1`), giữa từ ra "dươc", "đươc".
- Người dùng chọn nối có điều kiện (D20).
- Sau khi khung test trong repo mô phỏng cách này, `compare.sh` cho đúng 4 ca đó đổi đầu ra, cả 4 khớp với họ.
- Lớp IMK làm ở `InPlaceComposer` (test `InPlaceComposerLetterTests`).

**Ba ngoại lệ của D20 (mô phỏng rồi đo trong repo, 05/11/2026).**

- Người dùng chốt ba ngoại lệ sau mô phỏng cùng cách trên, cho các giới hạn còn lại của cách nối có điều kiện ("#Hà" + "Nooij" ra "#HàNooij", "foo" + "bar" ra "foobả", "anh" + "emx" ra "anhemx"):
  - (a) chữ hoa sau chữ thường bắt đầu từ mới;
  - (b) từ có sẵn không phải tiếng Việt nhận chữ gõ tiếp nguyên văn tới hết từ;
  - (c) phím dấu/biến đổi đầu tiên không áp dụng được lên từ tiếng Việt có sẵn thì bắt đầu từ mới (D20).
- Trên 10.303 ca, mô phỏng cho (a) đổi 0 ca, (b) đổi 2, (c) đổi 24, không bất biến nào hỏng.
- Khung test trong repo làm theo (`ExternalCasesTests.d20Seed`):
  - từ dài hơn 7 chữ đi vào trạng thái đi thẳng của D33 bằng `VietEngine.seedOverflow`;
  - áp (b) cho cả phím dấu lẫn chữ cái và cho (b) thắng (a);
  - (a) không áp cho phím dấu có đặt dấu lên từ (D20);
  - đúng 26 ca đổi đầu ra, như mô phỏng.
- Các ca đổi:
  - (b): uvie-rs `real_api_sim.rs:real_type_good_then_arrow_then_type#3`, `real_type_good_escape#3` ("good←book" ra "gôdbook", trước "gôdbôk"; vẫn lớp B);
  - (c): 24 ca của chuỗi gonhanh `integration_test.rs:complex_mau_sac_continuous_session` (`#3`–`#26`), "sắc" + "ddepj" nay "sắcđẹp", "sắc" + "ddor" nay "sắcđỏ"; `#3` và `#17` chuyển từ X sang khớp.
- `compare.sh`: khớp 8.061 → 8.063, X 6 → 4, A, B, C, D, E không đổi.
- Lớp IMK làm ở `InPlaceComposer` (test `InPlaceComposerExceptionTests`); chưa gõ thử trên Dấu thật.
