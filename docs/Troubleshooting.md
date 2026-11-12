# Xử lý sự cố

Các sự cố đã gặp khi dùng và khi phát triển Dấu, nguyên nhân đã xác định và cách xử lý. `scripts/dev/doctor.sh` tự kiểm phần lớn các mục dưới đây.

## Khi dùng

### "Dấu – Tiếng Việt" bị xám trong menu nguồn đầu vào, máy tự về U.S.

- **Nguyên nhân:** một app đang bật Secure Keyboard Entry, thường là ô mật khẩu đang được chọn (đã gặp với Google Chrome). Khi đó macOS tắt mọi bộ gõ, không riêng Dấu.
- **Kiểm:** `ioreg -l -w 0 | grep kCGSSessionSecureInputPID`, rồi `ps -p <pid>` để biết app nào. `doctor.sh` in ra app đó.
- **Xử lý:** rời khỏi ô mật khẩu hoặc thoát app đó. Không phải lỗi của Dấu.

### "Cài đặt Dấu…" trong menu bộ gõ không mở gì

Bộ gõ chỉ mở một bản Dấu.app đạt kiểm chữ ký. Thứ tự chọn (`HostApp.choose`): bản đang chạy, bản chứa chính bộ gõ, bản có cùng phiên bản với bộ gõ (ưu tiên thư mục Applications; nếu LaunchServices chưa biết thì tìm thẳng trong `/Applications`), bản trong `~/Applications` khi `/Applications` không có bản nào đạt, cuối cùng bản duy nhất LaunchServices biết. Mỗi bản phải qua kiểm chữ ký. Nhật ký: `log show --last 5m --predicate 'subsystem == "com.codefastlabs.dau.inputmethod.Dau"' | grep host-app`.

- **Không có bản cùng phiên bản** (nhật ký có `host-app-not-found`): bộ gõ đã cài khác phiên bản với Dấu.app trong `/Applications`. Thường gặp khi Dấu.app được chép vào `/Applications` mà chưa mở lần nào, hoặc bước thay bộ gõ của `scripts/dev/install-app.sh` báo lỗi. Bản trong thư mục build hay DerivedData chỉ được chọn khi đang chạy (bước đầu); không thì bị bỏ, vì sandbox của bộ gõ không đọc được chúng.
- **Xử lý:** mở Dấu.app trong `/Applications` một lần; app thay bộ gõ đã cài bằng bản nằm trong nó (D37 (Cài đặt bộ gõ)). Hoặc chạy lại `scripts/dev/install-app.sh`. `scripts/dev/dau-version.sh` cho biết hai bản đã khớp chưa.
- **Bản tìm được không đạt kiểm chữ ký** (nhật ký có `host-app-signature-invalid`): chữ ký hỏng, không do Apple cấp, khác Team ID với bộ gõ, hoặc khác bundle ID của app chủ. Bộ gõ bỏ qua bản đó.
- **Xử lý:** dựng và cài lại Dấu.app bằng `scripts/dev/install-app.sh`, với cùng Team đã ký bộ gõ.

## Khi phát triển

### Thử gõ bằng TextEdit để lại file trên iCloud Drive

- **Nguyên nhân:** TextEdit tự lưu mọi tài liệu "Untitled" vào `~/Library/Mobile Documents/com~apple~TextEdit/Documents/`; đóng mà không lưu vẫn để lại file, và file đó đồng bộ sang mọi thiết bị của người dùng.
- **Xử lý:** thử gõ bằng trang thử trong trình duyệt (`scripts/selftest/typing/run.sh safari chrome`) hoặc một app thử riêng. Không dùng TextEdit hay app nào tự lưu lên iCloud.

### `swift test` hoặc `xcodebuild` báo không thấy SDK

- **Nguyên nhân:** `xcode-select -p` trỏ tới Command Line Tools.
- **Xử lý:** không cần đổi `xcode-select`. Các script tự chọn Xcode (`scripts/lib/xcode.sh`); lệnh gõ tay thì thêm `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`.

### App Group không chạy, cài đặt không sang được bộ gõ

- **Nguyên nhân:** bản dựng ký ad-hoc (không có Team ID): macOS từ chối App Group mà không hiện hộp thoại nào.
- **Xử lý:** ký bằng một Team thật; Personal Team miễn phí là đủ ([`CONTRIBUTING.md`](../CONTRIBUTING.md)). `doctor.sh` kiểm chứng chỉ có khớp Team không: Team lấy từ `Config/Local.xcconfig`, không có file đó thì từ `Config/Signing.xcconfig`.

### Chữ ký bị thu hồi khi dùng một Apple ID trên hai máy Mac

- **Nguyên nhân:** mỗi máy tạo một chứng chỉ "Apple Development" riêng, và tạo chứng chỉ ở máy này có thể làm chứng chỉ ở máy kia bị thu hồi. Bản đã cài báo `CSSMERR_TP_CERT_REVOKED` khi kiểm chữ ký.
- **Xử lý:** dùng chung một chứng chỉ. Ở máy đang có chứng chỉ hợp lệ, mở Keychain Access › login › My Certificates, xuất "Apple Development: …" (kèm khoá riêng) ra file `.p12`, rồi nhập file đó ở máy kia.

### Cửa sổ thử mở sai kích thước ở lần chạy sau

- **Nguyên nhân:** app thử bị dừng bằng `kill`, nên macOS khôi phục cửa sổ cũ ở lần mở sau của cùng bundle ID.
- **Xử lý:** thoát app thử bình thường (`NSRunningApplication.terminate`), như `scripts/selftest/settings-window/run.sh` đang làm. Một lần thoát bình thường là hết.
