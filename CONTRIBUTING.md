# Đóng góp cho Dấu

Cảm ơn bạn muốn góp sức cho Dấu. Dấu là phần mềm tự do theo giấy phép GPLv3 ([LICENSE](LICENSE)). Mọi đóng góp gửi vào repo cũng theo giấy phép này.

## Trước khi bắt đầu

- Bạn hãy đọc [`docs/Decisions.md`](docs/Decisions.md) trước. Đây là sổ quyết định và là nguồn chuẩn duy nhất của dự án. Thay đổi nào trái với một nguyên tắc (N) hay một quyết định (D) sẽ không được nhận. Nếu muốn đổi một quyết định, bạn hãy mở issue nêu lý do trước khi viết mã.
- Với việc lớn, như thêm tính năng mới, đổi hành vi gõ hay đổi giao diện, bạn hãy mở issue trước để thống nhất hướng làm. Với lỗi nhỏ, bạn có thể gửi PR thẳng.
- Kiến trúc và đường đi của một phím tả ở [`docs/Architecture.md`](docs/Architecture.md). Lộ trình của dự án nằm ở [`docs/Roadmap.md`](docs/Roadmap.md).

## Chuẩn bị máy

- Bạn cần Xcode đúng bản ghi trong [`.xcode-version`](.xcode-version) và XcodeGen (cài bằng `brew install xcodegen`). CI cũng build và test bằng bản Xcode này. Chỉ có Command Line Tools thì không đủ, vì `swift test` hỏng khi build sạch do thiếu plugin `TestingMacros`.
- Mọi lệnh và script trong repo dùng bản Xcode mà `xcode-select` chọn. Nếu `xcode-select -p` đang trỏ tới Command Line Tools, bạn hãy chọn Xcode một lần bằng `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`.
- Bạn nên chạy `scripts/dev/doctor.sh` trước tiên. Lệnh này không cài hay đổi gì trên hệ thống; nó chỉ ghi vào `build/` và `.build/`. Lệnh này liệt kê những gì máy bạn còn thiếu (Xcode, XcodeGen, chứng chỉ ký khớp Team, bản đã cài, nguồn đầu vào) và in lệnh sửa cho từng mục.

## Chạy test

Các lệnh `swift test` dưới đây cần `xcode-select` trỏ tới Xcode (xem mục "Chuẩn bị máy"). Nếu chỉ có Command Line Tools thì bước build sẽ hỏng.

| Phần | Cần Apple ID? | Lệnh |
|---|---|---|
| Engine: quy tắc gõ, đặt dấu, chính tả, khôi phục từ (`Packages/DauEngine`) | Không | `swift test --package-path Packages/DauEngine` |
| Phần dùng chung (`Packages/DauShared`) | Không | `swift test --package-path Packages/DauShared` |
| Bộ gõ (`Apps/DauInputMethod`): logic thuần, không cần cài | Không. Test ký tạm và không cần Team, giống CI; cách này đã chạy ngày 17/11. | `xcodegen generate`, rồi `xcodebuild test -project Dau.xcodeproj -scheme DauInputMethod -destination 'platform=macOS' CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM=` |
| App chủ (`Apps/Dau`): cài bộ gõ, onboarding, cửa sổ Cài đặt dựng trong test (không hiện lên màn hình) | Không | `swift test --package-path Apps/Dau/Tests` |

Mọi khẳng định về hiệu năng của engine đều cần số đo. Test hiệu năng chạy trong mọi lần `swift test` với ngưỡng lỏng. Số đo thì lấy từ bản Release bằng lệnh `swift test -c release --package-path Packages/DauEngine --filter Performance` (xem `docs/Architecture.md`).

## Build và cài bằng Team của bạn

Bộ gõ và app chủ dùng chung phần cài đặt qua một App Group. macOS chỉ chấp nhận App Group khi bản dựng được ký bằng một Team ID thật, nên bản ký ad-hoc không chạy được phần này. Vì vậy bạn cần một Team. Personal Team miễn phí là đủ: bạn không cần chương trình Apple Developer trả phí và không cần provisioning profile.

1. Bạn mở Xcode, vào Settings › Accounts và đăng nhập Apple ID của mình. Xcode tạo Personal Team và chứng chỉ "Apple Development" khi cần.
2. Bạn chép file mẫu rồi điền Team ID của mình vào. Team ID có ở Settings › Accounts hoặc ở trường `OU=` của chứng chỉ "Apple Development" trong Keychain Access.

   ```sh
   cp Config/Local.xcconfig.example Config/Local.xcconfig
   ```

   Git bỏ qua `Config/Local.xcconfig`, nên Team của bạn không lọt vào commit. Bạn đừng sửa Team trong `project.yml` hay `Config/Signing.xcconfig`.
3. Bạn build và cài Dấu.app vào `/Applications` bằng lệnh:

   ```sh
   scripts/dev/install-app.sh
   ```

   Script sinh project, build bản Release của Dấu.app (bộ gõ nằm trong app), kiểm bản build rồi đặt app vào `/Applications`. Bản Dấu.app cũ ở đó chuyển vào Thùng rác. Chỉ bản Dấu.app trong thư mục Applications mới cài và thay bộ gõ (D37 (Cài bộ gõ)), nên bản mở từ thư mục build không cài được.
4. Lần đầu trên một máy, bạn mở Dấu trong `/Applications`, bấm "Bật Dấu", rồi bấm Allow trong hộp thoại của macOS. Bạn không cần đăng xuất. Nếu không bật được, bạn hãy làm theo màn "Chưa bật được Dấu" của app. Script không cài bộ gõ lần đầu và không bật gì (N4 (Không tự đổi cài đặt hệ thống)).
5. Những lần sau, bạn chỉ cần chạy lại `scripts/dev/install-app.sh`. Dấu.app vừa cài tự thay bộ gõ đã cài bằng bản nằm trong nó và không đổi danh sách nguồn đầu vào bạn đã bật.

Để gõ hằng ngày, bạn hãy dùng bản Release. Lệnh `scripts/dev/install-app.sh --debug` cài bản Debug. Đây là bản duy nhất ghi nhật ký theo từng phím để đo (D8 (Không telemetry)); cách đo nằm ở [`docs/Compatibility.md`](docs/Compatibility.md), mục 4.

Bản bạn tự dựng là **bản phát triển** (D7 (Cập nhật và loại bản dựng)), không phải bản phát hành. Bản phát hành chỉ do quy trình phát hành tạo ra và ký bằng Developer ID. Quy trình đó nằm ở `scripts/release/` và `.github/workflows/release.yml`, nhưng chưa chạy với chữ ký thật (xem `docs/Releasing.md`).

Nếu gặp lỗi ký, lỗi App Group hay chứng chỉ bị thu hồi, bạn hãy xem [`docs/Troubleshooting.md`](docs/Troubleshooting.md).

## Gỡ và quay về bản phát hành

- **Bản của bạn thay bản Dấu đang cài.** Bản phát triển có Bundle ID giống bản phát hành, và Bundle ID này không đổi giữa các bản (D37), nên trên một máy chỉ có một bản Dấu. Khi đã có bản phát hành, bạn muốn quay lại thì cài lại từ bản đó.
- **Gỡ bản bạn dựng:** bạn dùng "Gỡ cài đặt" trong Dấu (D16 (Bảo trì và gỡ cài đặt)).
- **Liệt kê mọi dấu vết của Dấu trên máy:** bạn chạy `scripts/dev/clean-dau.sh`; không có tham số thì script chỉ đọc. Phần đầu script ghi cách đưa tài khoản về như chưa từng cài Dấu: trước hết bỏ Dấu bằng nút "–" trong System Settings, rồi đăng xuất.

## Quy ước

Quy ước đầy đủ nằm trong [CLAUDE.md](CLAUDE.md) và trong `CLAUDE.md` của một số thư mục. Các quy ước này áp dụng cho cả người lẫn Claude Code.

- Quy ước mã nguồn nằm ở [CLAUDE.md](CLAUDE.md), mục "Quy ước mã nguồn". Mục đó nói về Swift 6, Swift Testing, việc dùng tiếng Anh trong mã và commit, String Catalog, cùng quan hệ giữa engine và OpenKey: không chép mã từ OpenKey hay UniKey, và đáp án test viết theo chính tả và `Decisions.md`.
- Luật viết tài liệu nằm ở [`docs/CLAUDE.md`](docs/CLAUDE.md), theo D44 (Văn xuôi tiếng Việt).
- Cách đo độ đúng khi gõ (đối chứng, câu thử, đáp án) nằm ở [`scripts/CLAUDE.md`](scripts/CLAUDE.md).
- Cách viết script trong `scripts/` nằm ở [`scripts/README.md`](scripts/README.md).
- Cách phát hành (tag, DMG, ký, appcast, secret của CI) nằm ở [`docs/Releasing.md`](docs/Releasing.md).

Người đóng góp cần nhớ thêm mấy điều sau:

- Commit viết theo [Conventional Commits](https://www.conventionalcommits.org/), ví dụ `feat:`, `fix:`, `docs:`.
- `Dau.xcodeproj` được sinh từ `project.yml`. Bạn hãy sửa `project.yml` và không sửa hay commit `.xcodeproj`.
- Giao diện dùng thành phần của macOS và bố cục theo System Settings (D9 (Giao diện)). Nội dung từng màn hình nằm ở [`docs/UI.md`](docs/UI.md). Nếu muốn đổi giao diện, bạn hãy mở issue kèm ảnh chụp hoặc bản phác thảo trước khi viết mã.
- Chuỗi giao diện có khoá là câu tiếng Anh và có bản tiếng Việt (D41 (Ngôn ngữ giao diện)). Thuật ngữ nằm ở [`docs/Glossary.md`](docs/Glossary.md). Chuỗi giao diện không được ghi lời hứa chưa kiểm chứng (N5 (Chỉ hứa điều đã kiểm chứng)). Bạn kiểm các chuỗi này bằng `scripts/check-l10n/check.sh`.
- Khi sửa tài liệu, bạn hãy đọc lại phần đã sửa và grep `docs/` để tìm đường dẫn, tên hay số mục mà thay đổi làm lỗi thời (CLAUDE.md, mục "Viết tài liệu").

## Gửi PR

- Mọi test liên quan phải xanh.
- Phần mô tả PR nói bạn đã thử gì và thử ở đâu: ứng dụng nào, phiên bản macOS nào, Telex hay VNI.

## Báo lỗi gõ

Bạn hãy mở issue và ghi tên ứng dụng, phiên bản macOS, kiểu gõ Telex hay VNI, cùng chuỗi phím đã gõ. Bạn đừng dán nội dung riêng tư vào issue.
