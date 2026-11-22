# Xử lý sự cố

Tài liệu này ghi các sự cố đã gặp khi dùng và khi phát triển Dấu, nguyên nhân đã xác định và cách xử lý. `scripts/dev/doctor.sh` tự kiểm phần lớn các mục dưới đây.

## Khi dùng

### "Dấu – Tiếng Việt" bị xám trong menu nguồn đầu vào, máy tự về U.S.

- **Nguyên nhân:** một app đang bật Secure Keyboard Entry, thường là vì một ô mật khẩu đang được chọn (đã gặp với Google Chrome). Khi đó macOS tắt mọi bộ gõ, không riêng Dấu.
- **Kiểm:** chạy `ioreg -l -w 0 | grep kCGSSessionSecureInputPID`, rồi `ps -p <pid>` để biết đó là app nào. `doctor.sh` cũng in ra app đó.
- **Xử lý:** rời khỏi ô mật khẩu hoặc thoát app đó. Đây không phải lỗi của Dấu.

### "Cài đặt Dấu…" trong menu bộ gõ không mở gì

Bộ gõ chỉ mở một bản Dấu.app đạt kiểm chữ ký. Bộ gõ chọn bản theo thứ tự sau (`HostApp.choose`). Trước hết là bản đang chạy, rồi bản chứa chính bộ gõ, rồi bản có cùng phiên bản với bộ gõ; với bản cùng phiên bản, bộ gõ ưu tiên thư mục Applications và nếu LaunchServices chưa biết bản đó thì tìm thẳng trong `/Applications`. Tiếp theo là bản trong `~/Applications`, khi `/Applications` không có bản nào đạt. Cuối cùng là bản duy nhất LaunchServices biết. Mỗi bản đều phải qua bước kiểm chữ ký. Nhật ký xem bằng `log show --last 5m --predicate 'subsystem == "com.codefastlabs.dau.inputmethod.Dau"' | grep host-app`.

- **Không có bản cùng phiên bản** (nhật ký có `host-app-not-found`): bộ gõ đã cài khác phiên bản với Dấu.app trong `/Applications`. Tình trạng này thường gặp khi Dấu.app chép vào `/Applications` mà chưa mở lần nào hoặc khi bước thay bộ gõ của `scripts/dev/install-app.sh` báo lỗi. Bản trong thư mục build hay DerivedData chỉ được chọn khi nó đang chạy (bước đầu); nếu không, nó bị bỏ qua, vì sandbox của bộ gõ không đọc được các bản đó.
- **Xử lý:** mở Dấu.app trong `/Applications` một lần. App sẽ thay bộ gõ đã cài bằng bản nằm trong nó (D37 (Cài bộ gõ)). Cách khác là chạy lại `scripts/dev/install-app.sh`. `scripts/dev/dau-version.sh` cho biết hai bản đã khớp nhau chưa.
- **Bản tìm được không đạt kiểm chữ ký** (nhật ký có `host-app-signature-invalid`): chữ ký hỏng, không do Apple cấp, khác Team ID với bộ gõ hoặc khác bundle ID của app chủ. Bộ gõ bỏ qua bản đó.
- **Xử lý:** dựng và cài lại Dấu.app bằng `scripts/dev/install-app.sh`, với cùng Team đã ký bộ gõ.

## Khi phát triển

### Thử gõ bằng TextEdit để lại file trên iCloud Drive

- **Nguyên nhân:** TextEdit tự lưu mọi tài liệu "Untitled" vào `~/Library/Mobile Documents/com~apple~TextEdit/Documents/`. Đóng tài liệu mà không lưu vẫn để lại file. File đó đồng bộ sang mọi thiết bị của người dùng.
- **Xử lý:** thử gõ bằng trang thử trong trình duyệt (`scripts/selftest/typing/run.sh safari chrome`) hoặc bằng một app thử riêng. Không dùng TextEdit hay app nào tự lưu lên iCloud.

### `swift test` hoặc `xcodebuild` báo không thấy SDK

- **Nguyên nhân:** `xcode-select -p` đang trỏ tới Command Line Tools.
- **Xử lý:** chọn Xcode một lần bằng `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`. Script và lệnh gõ tay đều dùng bản Xcode mà `xcode-select` chọn. `scripts/dev/doctor.sh` báo khi lựa chọn này chưa đúng.

### App Group không chạy, cài đặt không sang được bộ gõ

- **Nguyên nhân:** bản dựng ký ad-hoc (không có Team ID). macOS từ chối App Group mà không hiện hộp thoại nào.
- **Xử lý:** ký bằng một Team thật; Personal Team miễn phí là đủ ([`CONTRIBUTING.md`](../CONTRIBUTING.md)). `doctor.sh` kiểm xem chứng chỉ có khớp Team không. Team lấy từ `Config/Local.xcconfig` hoặc từ `Config/Signing.xcconfig` nếu không có file đó.

### Chữ ký bị thu hồi khi dùng một Apple ID trên hai máy Mac

- **Nguyên nhân:** mỗi máy tạo một chứng chỉ "Apple Development" riêng. Tạo chứng chỉ ở máy này có thể làm chứng chỉ ở máy kia bị thu hồi. Khi đó bản đã cài báo `CSSMERR_TP_CERT_REVOKED` lúc kiểm chữ ký.
- **Xử lý:** dùng chung một chứng chỉ. Ở máy đang có chứng chỉ hợp lệ, mở Keychain Access › login › My Certificates, xuất "Apple Development: …" (kèm khoá riêng) ra file `.p12`, rồi nhập file đó ở máy kia.

### Cửa sổ thử mở sai kích thước ở lần chạy sau

- **Nguyên nhân:** app thử bị dừng bằng `kill`, nên macOS khôi phục cửa sổ cũ ở lần mở sau của cùng bundle ID.
- **Xử lý:** thoát app thử bình thường (`NSRunningApplication.terminate`), như `scripts/selftest/settings-window/run.sh` đang làm. Chỉ cần một lần thoát bình thường là hết lỗi.
