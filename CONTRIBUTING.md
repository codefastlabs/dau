# Đóng góp cho Dấu

Cảm ơn bạn muốn góp sức. Dấu là phần mềm tự do theo giấy phép GPLv3 ([LICENSE](LICENSE)); mọi đóng góp gửi vào repo cũng theo giấy phép này.

## Trước khi bắt đầu

- Đọc [`docs/Decisions.md`](docs/Decisions.md). Đây là sổ quyết định, nguồn chuẩn duy nhất của dự án. Thay đổi trái với một nguyên tắc (N) hay quyết định (D) sẽ không được nhận; muốn đổi một quyết định thì mở issue nêu lý do trước khi viết mã.
- Việc lớn (tính năng mới, đổi hành vi gõ, đổi giao diện): mở issue trước để thống nhất. Sửa lỗi nhỏ thì gửi PR thẳng.
- Kiến trúc và luồng một phím: [`docs/Architecture.md`](docs/Architecture.md). Lộ trình: [`docs/Roadmap.md`](docs/Roadmap.md).

## Chuẩn bị máy

- Cần Xcode (đã thử với Xcode 27.2 và Swift 6.4) và XcodeGen (`brew install xcodegen`). Command Line Tools không đủ: `swift test` hỏng khi build sạch vì thiếu plugin `TestingMacros`.
- Nếu `xcode-select -p` trỏ tới Command Line Tools, đặt `export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` trước các lệnh dưới đây. Các script trong `scripts/` tự chọn Xcode.
- Chạy `scripts/dev/doctor.sh` trước. Lệnh này không cài hay đổi gì trên hệ thống (chỉ ghi vào `build/` và `.build/`). Nó liệt kê máy bạn còn thiếu gì (Xcode, XcodeGen, chứng chỉ ký khớp Team, bản đã cài, nguồn đầu vào) và lệnh sửa từng mục.

## Chạy test

Các lệnh `swift test` dưới đây cần Xcode được chọn (`xcode-select` hay `DEVELOPER_DIR`, xem "Chuẩn bị máy"): với Command Line Tools, build hỏng.

| Phần | Cần Apple ID? | Lệnh |
|---|---|---|
| Engine: quy tắc gõ, đặt dấu, chính tả, khôi phục từ (`Packages/DauEngine`) | Không | `swift test --package-path Packages/DauEngine` |
| Phần dùng chung (`Packages/DauShared`) | Không | `swift test --package-path Packages/DauShared` |
| Bộ gõ (`Apps/DauInputMethod`): logic thuần, không cần cài | Chưa thử khi không có Team | `xcodegen generate`, rồi `xcodebuild test -project Dau.xcodeproj -scheme DauInputMethod -destination 'platform=macOS'` |
| App chủ (`Apps/Dau`), kiểm bằng snapshot | Không | `swift test --package-path scripts/snapshot-settings` |

Khẳng định về hiệu năng của engine cần số đo. Test hiệu năng chạy trong mọi `swift test` (ngưỡng lỏng); số đo lấy từ bản Release: `swift test -c release --package-path Packages/DauEngine --filter Performance` (`docs/Architecture.md`).

## Build và cài bằng Team của bạn

Bộ gõ và app chủ dùng chung cài đặt qua một App Group. macOS chỉ chấp nhận App Group khi bản dựng được ký bằng một Team ID thật; bản ký ad-hoc không chạy được phần này. Vì vậy bạn cần một Team, nhưng Personal Team miễn phí là đủ, không cần chương trình Apple Developer trả phí và không cần provisioning profile.

1. Mở Xcode, vào Settings › Accounts, đăng nhập Apple ID của bạn. Xcode tạo Personal Team và chứng chỉ "Apple Development" khi cần.
2. Chép file mẫu và điền Team ID của bạn (xem ở Settings › Accounts, hoặc trường `OU=` của chứng chỉ "Apple Development" trong Keychain Access):

   ```sh
   cp Config/Local.xcconfig.example Config/Local.xcconfig
   ```

   `Config/Local.xcconfig` bị git bỏ qua, nên Team của bạn không lọt vào commit. Không sửa Team trong `project.yml` hay `Config/Signing.xcconfig`.
3. Build và cài Dấu.app vào `/Applications`:

   ```sh
   scripts/dev/install-app.sh
   ```

   Script sinh project, build bản Release của Dấu.app (bộ gõ nằm trong app), kiểm bản build rồi đặt app vào `/Applications`; bản Dấu.app cũ ở đó vào Thùng rác. Chỉ bản Dấu.app trong thư mục Applications cài và thay bộ gõ (D37 (Cài đặt bộ gõ)): bản mở từ thư mục build không cài được.
4. Lần đầu trên máy: mở Dấu trong `/Applications`, bấm "Bật Dấu", rồi Allow trong hộp thoại của macOS. Không cần đăng xuất; không bật được thì làm theo màn "Chưa bật được Dấu" của app. Script không cài bộ gõ lần đầu và không bật gì (N4 (Không tự đổi cài đặt hệ thống)).
5. Các lần sau: chạy lại `scripts/dev/install-app.sh`. Dấu.app vừa cài tự thay bộ gõ đã cài bằng bản nằm trong nó và không đổi danh sách nguồn đầu vào đã bật.

Gõ hằng ngày dùng bản Release. `scripts/dev/install-app.sh --debug` cài bản Debug, bản duy nhất ghi nhật ký theo từng phím để đo (D8 (Không telemetry); cách đo: [`docs/Compatibility.md`](docs/Compatibility.md) mục 4).

Bản bạn dựng là **bản phát triển** (D7 (Cập nhật và loại bản dựng)), không phải bản chính thức. Bản chính thức chỉ do quy trình phát hành ký Developer ID tạo ra; quy trình đó chưa có.

Gặp lỗi ký, App Group hay chứng chỉ bị thu hồi: [`docs/Troubleshooting.md`](docs/Troubleshooting.md).

## Gỡ và quay về bản chính thức

- **Bản của bạn thay bản Dấu đang cài.** Bundle ID giống bản chính thức và không đổi giữa các bản (D37), nên trên một máy chỉ có một bản Dấu. Khi có bản phát hành, muốn quay lại bản chính thức thì cài lại từ bản đó.
- **Gỡ bản bạn dựng:** dùng "Gỡ cài đặt" trong Dấu (D16 (Bảo trì và gỡ cài đặt)).
- **Liệt kê mọi dấu vết của Dấu trên máy:** `scripts/dev/clean-dau.sh` (không tham số thì chỉ đọc). Phần đầu script ghi cách đưa tài khoản về như chưa từng cài (bỏ Dấu bằng "–" trong System Settings trước, rồi đăng xuất).

## Quy ước

Quy ước đầy đủ nằm trong [CLAUDE.md](CLAUDE.md), áp dụng cho cả người lẫn Claude Code:

- Mã nguồn (Swift 6, Swift Testing, tiếng Anh trong mã và commit, String Catalog): mục "Quy ước mã nguồn".
- Engine và OpenKey (không chép mã từ OpenKey hay UniKey; đáp án test theo chính tả và `Decisions.md`): mục "OpenKey là tài liệu tham khảo, không phải đáp án".
- Viết tài liệu: mục "Viết tài liệu".
- Script trong `scripts/`: [`scripts/README.md`](scripts/README.md).

Thêm cho người đóng góp:

- Commit theo [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`…).
- `Dau.xcodeproj` được sinh từ `project.yml`: sửa `project.yml`, không sửa và không commit `.xcodeproj`.
- Giao diện: dùng thành phần của macOS, bố cục theo System Settings (D9 (Giao diện)); nội dung từng màn hình ở [`docs/UI.md`](docs/UI.md). Muốn đổi giao diện thì mở issue kèm ảnh chụp hoặc phác thảo trước khi viết mã.
- Chuỗi giao diện: khoá là câu tiếng Anh, có bản tiếng Việt (D41 (Ngôn ngữ giao diện)); thuật ngữ ở [`docs/Glossary.md`](docs/Glossary.md); không ghi lời hứa chưa kiểm chứng (N5 (Chỉ hứa điều đã kiểm chứng)). Kiểm bằng `scripts/check-l10n/check.sh`.
- Sửa tài liệu thì đọc lại phần đã sửa và grep `docs/` tìm đường dẫn, tên, số mục mà thay đổi làm lỗi thời (CLAUDE.md, mục "Viết tài liệu").

## Gửi PR

- Mọi test liên quan xanh.
- Mô tả đã thử gì và thử ở đâu: ứng dụng nào, phiên bản macOS, Telex hay VNI.

## Báo lỗi gõ

Mở issue, kèm tên ứng dụng, phiên bản macOS, Telex hay VNI, và chuỗi phím đã gõ. Đừng dán nội dung riêng tư.
