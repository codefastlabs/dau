# Đóng góp cho Dấu

Cảm ơn bạn đã quan tâm và muốn đóng góp cho dự án. Dấu là phần mềm tự do được phát hành theo giấy phép GNU General Public License v3.0 ([LICENSE](LICENSE)); mọi đóng góp gửi vào kho mã nguồn này cũng phải tuân thủ giấy phép đó.

## Trước khi bắt đầu

- Bạn vui lòng đọc kỹ tài liệu [`docs/Decisions.md`](docs/Decisions.md). Đây là sổ quyết định và là nguồn chân lý chuẩn xác duy nhất của dự án. Mọi thay đổi đi ngược lại các nguyên tắc (N) hoặc quyết định (D) đã ban hành sẽ không được tiếp nhận; nếu bạn muốn đề xuất thay đổi một quyết định có sẵn, hãy mở một issue trên GitHub để thảo luận lý do trước khi bắt tay vào viết mã.
- Đối với những thay đổi lớn như thêm tính năng mới, thay đổi hành vi xử lý phím hay thiết kế lại giao diện, bạn nên mở issue trước để thảo luận và thống nhất định hướng. Với các lỗi nhỏ, bạn có thể gửi thẳng Pull Request (PR).
- Bạn có thể tìm hiểu cấu trúc hệ thống và luồng xử lý phím tại [`docs/Architecture.md`](docs/Architecture.md), cũng như theo dõi các mốc phát triển tại [`docs/Roadmap.md`](docs/Roadmap.md).

## Chuẩn bị môi trường phát triển

- Bạn cần cài đặt Xcode đầy đủ (dự án đã được kiểm thử với Xcode 27.2 và Swift 6.4) cùng công cụ XcodeGen (cài đặt qua lệnh `brew install xcodegen`). Chỉ cài gói Command Line Tools là không đủ, vì lệnh `swift test` sẽ thất bại khi biên dịch sạch do thiếu plugin macro kiểm thử `TestingMacros`.
- Nếu lệnh `xcode-select -p` đang trỏ tới Command Line Tools, bạn hãy chạy lệnh `export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` trước khi thực thi các lệnh bên dưới. Các tệp script trong thư mục `scripts/` sẽ tự động tìm và sử dụng Xcode này.
- Bạn nên chạy script `scripts/dev/doctor.sh` trước tiên để kiểm tra môi trường. Script này hoàn toàn không cài đặt hay thay đổi cấu hình hệ thống (chỉ ghi dữ liệu tạm vào các thư mục `build/` và `.build/`). Script sẽ liệt kê đầy đủ những thành phần máy bạn còn thiếu (như Xcode, XcodeGen, chứng chỉ ký khớp Team, bản ứng dụng đã cài đặt, nguồn đầu vào) và hướng dẫn câu lệnh cụ thể để khắc phục từng mục.

## Chạy kiểm thử

Các câu lệnh `swift test` dưới đây đều yêu cầu môi trường Xcode đầy đủ (thông qua `xcode-select` hoặc biến môi trường `DEVELOPER_DIR` như đã nêu ở mục trên); nếu chỉ dùng Command Line Tools thì quá trình biên dịch sẽ thất bại.

| Hạng mục kiểm thử | Yêu cầu Apple ID | Câu lệnh thực thi |
|---|---|---|
| Engine: kiểm tra quy tắc gõ, vị trí đặt dấu, chính tả và khôi phục từ (`Packages/DauEngine`) | Không yêu cầu | `swift test --package-path Packages/DauEngine` |
| Thư viện dùng chung (`Packages/DauShared`) | Không yêu cầu | `swift test --package-path Packages/DauShared` |
| Bộ gõ (`Apps/DauInputMethod`): kiểm tra logic thuần mà không cần cài đặt vào hệ thống | Không yêu cầu (sử dụng chữ ký tạm không cần Team, tương tự quy trình CI) | `xcodegen generate`, sau đó chạy: `xcodebuild test -project Dau.xcodeproj -scheme DauInputMethod -destination 'platform=macOS' CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM=` |
| Ứng dụng chủ (`Apps/Dau`): kiểm tra quy trình cài đặt bộ gõ, onboarding và dựng cửa sổ Cài đặt ngầm trong bộ test | Không yêu cầu | `swift test --package-path Apps/Dau/Tests` |

Mọi tuyên bố hay khẳng định về hiệu năng của engine đều bắt buộc phải đi kèm số liệu đo đạc thực tế. Các bài kiểm thử hiệu năng được tích hợp sẵn trong lệnh `swift test` thông thường với ngưỡng nới lỏng; để lấy số đo chuẩn xác cho bản chính thức, bạn cần chạy bài test trên cấu hình Release: `swift test -c release --package-path Packages/DauEngine --filter Performance` (chi tiết xem tại [`docs/Architecture.md`](docs/Architecture.md)).

## Biên dịch và cài đặt bằng Apple Team cá nhân

Bộ gõ và ứng dụng chủ chia sẻ dữ liệu cài đặt với nhau thông qua một App Group của macOS. Hệ điều hành chỉ cho phép App Group hoạt động khi bản dựng được ký bằng một Team ID thật sự; các bản dựng ký danh nghĩa (ad-hoc) không thể kích hoạt được tính năng này. Do đó, bạn cần có một Apple Team, nhưng tài khoản Personal Team miễn phí là hoàn toàn đủ đáp ứng; bạn không cần phải đăng ký gói Apple Developer Program trả phí và cũng không cần tạo hồ sơ cấp phép (provisioning profile).

1. Bạn mở ứng dụng Xcode, điều hướng đến mục Settings › Accounts và đăng nhập tài khoản Apple ID cá nhân. Xcode sẽ tự động tạo một Personal Team cùng chứng chỉ "Apple Development" khi cần thiết.
2. Bạn sao chép tệp cấu hình mẫu và điền Team ID của mình (bạn có thể tìm thấy mã này trong mục Settings › Accounts của Xcode, hoặc tại trường `OU=` của chứng chỉ "Apple Development" trong ứng dụng Keychain Access):

   ```sh
   cp Config/Local.xcconfig.example Config/Local.xcconfig
   ```

   Tệp `Config/Local.xcconfig` đã được cấu hình trong `.gitignore` để tránh bị đưa vào commit mã nguồn, nhờ đó thông tin Team cá nhân của bạn sẽ luôn được giữ an toàn. Bạn lưu ý không sửa Team trực tiếp trong `project.yml` hoặc `Config/Signing.xcconfig`.

3. Bạn thực hiện biên dịch và cài đặt ứng dụng Dấu.app vào thư mục `/Applications` bằng lệnh:

   ```sh
   scripts/dev/install-app.sh
   ```

   Script này sẽ tự động sinh tệp dự án Xcode, biên dịch bản Release của Dấu.app (bên trong đã nhúng sẵn bộ gõ), kiểm tra tính toàn vẹn của gói cài đặt rồi đưa ứng dụng vào thư mục `/Applications`; nếu tại đó đã có sẵn bản Dấu.app cũ thì bản cũ sẽ được chuyển an toàn vào Thùng rác. Chỉ bản Dấu.app nằm trong thư mục `/Applications` mới có quyền cài đặt và cập nhật bộ gõ vào hệ thống (theo quyết định D37 (Cài bộ gõ)); các bản dựng chạy trực tiếp từ thư mục `build/` sẽ không thể cài đặt được.

4. Khi cài đặt lần đầu tiên trên máy: Bạn mở ứng dụng Dấu trong thư mục `/Applications`, bấm nút "Bật Dấu", sau đó chọn "Allow" trong hộp thoại xác nhận của hệ điều hành macOS. Bạn không cần phải đăng xuất tài khoản; nếu gặp sự cố chưa bật được, bạn hãy làm theo các bước hướng dẫn trên màn hình "Chưa bật được Dấu" của ứng dụng. Bản thân script tuyệt đối không tự ý cài đặt bộ gõ hay tự bật nguồn đầu vào của bạn (tuân thủ nguyên tắc N4 (Không tự đổi cài đặt hệ thống)).

5. Trong những lần cập nhật mã nguồn sau: Bạn chỉ cần chạy lại lệnh `scripts/dev/install-app.sh`. Bản Dấu.app mới được cài đặt sẽ tự động cập nhật bộ gõ hệ thống bằng bản dựng nhúng bên trong nó mà không làm thay đổi danh sách nguồn đầu vào bạn đã kích hoạt trước đó.

Để sử dụng gõ phím hằng ngày, bạn hãy luôn dùng bản Release. Lệnh `scripts/dev/install-app.sh --debug` sẽ cài đặt bản Debug; đây là bản duy nhất có cơ chế ghi nhật ký chi tiết theo từng phím gõ phục vụ cho việc đo đạc hiệu năng và gỡ lỗi (tuân thủ quyết định D8 (Không telemetry); bạn có thể tham khảo phương pháp đo tại [`docs/Compatibility.md`](docs/Compatibility.md), mục 4).

Bản dựng do bạn tự biên dịch được định danh là **bản phát triển** (theo quyết định D7 (Cập nhật và loại bản dựng)), chứ không phải bản phát hành chính thức. Bản phát hành chính thức bắt buộc phải được ký số qua chứng chỉ Developer ID bởi quy trình phát hành tự động; quy trình này nằm tại `scripts/release/` và `.github/workflows/release.yml` (hiện tại chưa áp dụng chữ ký thật, xem thêm tại [`docs/Releasing.md`](docs/Releasing.md)).

Nếu gặp sự cố về chữ ký mã nguồn, kết nối App Group hoặc chứng chỉ bị thu hồi, bạn hãy tham khảo hướng dẫn xử lý tại tài liệu [`docs/Troubleshooting.md`](docs/Troubleshooting.md).

## Gỡ bỏ và quay về bản phát hành chính thức

- **Cơ chế ghi đè ứng dụng:** Bản dựng cá nhân của bạn sẽ thay thế trực tiếp bản Dấu hiện có trên máy. Do định danh Bundle ID của bản phát triển hoàn toàn trùng khớp với bản phát hành chính thức và không đổi qua các phiên bản (theo quyết định D37 (Cài bộ gõ)), trên mỗi máy chỉ tồn tại duy nhất một phiên bản Dấu. Khi dự án phát hành bản chính thức và bạn muốn quay trở lại, bạn chỉ cần tải về và cài đặt đè từ bản phát hành đó.
- **Gỡ bỏ bản dựng cá nhân:** Bạn có thể sử dụng chức năng "Gỡ cài đặt" ngay trong ứng dụng Dấu (theo quyết định D16 (Bảo trì và gỡ cài đặt)).
- **Kiểm tra và dọn sạch dấu vết của Dấu:** Bạn có thể chạy lệnh `scripts/dev/clean-dau.sh` (khi không kèm tham số, script chỉ thực hiện đọc và liệt kê mà không xoá dữ liệu). Phần chú thích ở đầu tệp script này có ghi chi tiết các bước để đưa tài khoản người dùng về trạng thái sạch như chưa từng cài đặt ứng dụng (bao gồm việc xoá Dấu bằng nút "–" trong mục System Settings trước, sau đó đăng xuất tài khoản).

## Quy ước phát triển

Hệ thống quy ước phát triển chi tiết của dự án được ghi nhận trong [CLAUDE.md](CLAUDE.md) cùng các tệp `CLAUDE.md` tại từng thư mục cụ thể, áp dụng đồng nhất cho cả lập trình viên lẫn công cụ hỗ trợ:

- **Quy ước mã nguồn:** Dự án sử dụng Swift 6 (strict concurrency), bộ kiểm thử Swift Testing, ngôn ngữ tiếng Anh cho toàn bộ mã nguồn và thông điệp commit, cùng String Catalog cho việc bản địa hoá. Thư viện engine được viết hoàn toàn độc lập từ đầu, tuyệt đối không sao chép mã từ OpenKey hay UniKey; kết quả kỳ vọng trong các bài test phải dựa trên quy tắc chính tả chuẩn và sổ quyết định (chi tiết xem tại [CLAUDE.md](CLAUDE.md), mục "Quy ước mã nguồn").
- **Quy ước viết tài liệu:** Mọi tài liệu phải tuân thủ hướng dẫn văn xuôi tiếng Việt hoàn chỉnh và mạch lạc tại [`docs/CLAUDE.md`](docs/CLAUDE.md) (theo quyết định D44 (Văn xuôi tiếng Việt)).
- **Phương pháp đo độ chuẩn xác gõ phím:** Quy trình kiểm chứng đối chứng, thiết kế câu thử và tiêu chí chấm điểm được mô tả tại [`scripts/CLAUDE.md`](scripts/CLAUDE.md).
- **Quy chuẩn xây dựng script tự động hoá:** Hướng dẫn viết script và tác động phụ được giải thích tại [`scripts/README.md`](scripts/README.md).
- **Quy trình đóng gói và phát hành:** Các tiêu chuẩn về gắn thẻ phiên bản, tạo tệp DMG, ký mã số, cấu hình tệp appcast và thiết lập secret trên CI được ghi nhận tại [`docs/Releasing.md`](docs/Releasing.md).

Một số lưu ý bắt buộc đối với người đóng góp:

- Thông điệp commit phải tuân thủ chuẩn [Conventional Commits](https://www.conventionalcommits.org/) (ví dụ: `feat:`, `fix:`, `docs:`, `test:`).
- Tệp dự án `Dau.xcodeproj` được sinh tự động từ `project.yml`; do đó bạn chỉ chỉnh sửa tệp `project.yml`, tuyệt đối không chỉnh sửa thủ công và không commit tệp `.xcodeproj`.
- Về mặt giao diện, ứng dụng chỉ sử dụng các thành phần điều khiển gốc của macOS với bố cục tương đồng ứng dụng System Settings (theo quyết định D9 (Giao diện)); thiết kế chi tiết từng màn hình được lưu trữ tại [`docs/UI.md`](docs/UI.md). Nếu bạn muốn thay đổi giao diện, hãy mở một issue kèm theo ảnh chụp màn hình hoặc bản vẽ phác thảo trước khi viết mã.
- Các chuỗi văn bản giao diện sử dụng khóa bằng tiếng Anh kèm bản dịch tiếng Việt (theo quyết định D41 (Ngôn ngữ giao diện)), tuân thủ bảng thuật ngữ chuẩn tại [`docs/Glossary.md`](docs/Glossary.md), và tuyệt đối không đưa ra những lời hứa chưa được kiểm chứng thực tế (tuân thủ nguyên tắc N5 (Chỉ hứa điều đã kiểm chứng)). Bạn có thể kiểm tra tính đồng bộ này bằng script `scripts/check-l10n/check.sh`.
- Khi chỉnh sửa tài liệu, bạn hãy đọc soát lại toàn bộ nội dung đã sửa và tìm kiếm (grep) trong thư mục `docs/` để cập nhật mọi đường dẫn, tên gọi hoặc số hiệu mục mà thay đổi của bạn có thể làm ảnh hưởng.

## Quy trình gửi Pull Request (PR)

- Tất cả các bài kiểm thử liên quan trong dự án đều phải đạt kết quả thành công (pass 100%) trước khi bạn tạo PR.
- Trong phần mô tả của PR, bạn cần nêu rõ mình đã kiểm thử những gì và trên môi trường cụ thể nào: ứng dụng thử nghiệm, phiên bản macOS, cùng kiểu gõ đã dùng (Telex hay VNI).

## Quy trình báo lỗi gõ phím

Khi gặp lỗi nhập liệu, bạn vui lòng mở một issue mới trên GitHub, cung cấp đầy đủ tên ứng dụng gặp lỗi, phiên bản macOS đang dùng, kiểu gõ (Telex hay VNI), và chuỗi phím bấm cụ thể đã gõ để tái hiện lỗi. Bạn lưu ý không dán các thông tin hoặc dữ liệu cá nhân nhạy cảm vào nội dung mô tả lỗi.
