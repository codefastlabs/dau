# Dấu — bộ gõ tiếng Việt cho macOS

Dấu là input method tiếng Việt **chỉ dành cho macOS**, dựng trên InputMethodKit (IMK). Nó thay chữ tại chỗ bằng `insertText(_:replacementRange:)` thay vì giả lập phím Backspace như OpenKey. Tên chính thức: **Dấu** (đã chốt). Quy tắc dùng tên và định danh kỹ thuật: xem D24.

Đọc theo thứ tự trước khi làm bất cứ việc gì:
1. `docs/DECISIONS.md` — sổ quyết định (nguồn chuẩn duy nhất).
2. `docs/ARCHITECTURE.md` — kiến trúc, target, luồng xử lý phím.
3. `docs/ROADMAP.md` — các mốc, tiêu chí hoàn thành.
4. `docs/UI.md` — mô tả màn hình (mockup gốc nằm trên canvas, xem link trong file).
5. `docs/BRAND.md` — biểu tượng, màu, chữ, danh sách file nhận diện cần xuất.
6. `docs/PROGRESS.md` — đang ở đâu, việc đang chờ, số đo. **Đọc đầu tiên khi bắt đầu một phiên mới.**

Mục lục mọi tài liệu khác (tra cứu, nghiên cứu, lưu trữ): `docs/README.md`.

## Điều phối

Phiên chính là **người điều phối**: lập kế hoạch, giao việc cho subagent trong `.claude/agents/`, kiểm chứng kết quả, commit, cập nhật `docs/PROGRESS.md`. Phiên chính hạn chế tự viết mã lớn để giữ ngữ cảnh gọn.

| Agent | Phụ trách |
|---|---|
| `researcher` | đọc OpenKey, test của các bộ gõ khác, tài liệu Apple; viết `docs/OPENKEY-NOTES.md` và `docs/research/` |
| `engine-dev` | `Packages/DauEngine` và test |
| `imk-dev` | `Apps/DauInputMethod` |
| `app-ui-dev` | `Apps/Dau` (SwiftUI) |
| `release-eng` | XcodeGen, CI, ký, notarize, Sparkle, Homebrew, xuất file nhận diện, triển khai trang web |
| `web-dev` | mã trang web: trang tải về (M8), trang so sánh cách gõ (M10) |
| `auditor` | kiểm tra độc lập, chỉ đọc; phải ĐẠT trước khi đóng mốc |

- Lệnh `/milestone M#` chạy trọn một mốc; `/audit` kiểm tra toàn repo.
- Subagent không thừa hưởng ngữ cảnh của phiên chính: mỗi lần giao việc phải nêu phạm vi, file được sửa, tiêu chí xong.
- Giao song song các việc độc lập (ví dụ M1 engine song song với M0 khung dự án; M4 giao diện song song M3 khi model cài đặt chung đã xong).
- Mỗi việc xong → kiểm chứng lại bằng lệnh thật → `scripts/check-docs/check.sh` (đổi chuỗi giao diện thì thêm `scripts/check-l10n/check.sh`) → commit nhỏ (Conventional Commits, tiếng Anh). Không commit khi test hoặc kiểm tra tài liệu đỏ.
- **Điểm dừng bắt buộc — hỏi người dùng:** Bundle ID / Team ID / tên cask / tên miền; mọi thao tác cần tài khoản Apple Developer hay chứng chỉ; bật nguồn nhập liệu, đăng xuất, cấp quyền, gõ thử trong ứng dụng thật (không thao tác được giao diện macOS); mọi thay đổi `DECISIONS.md`; **mọi lần chạy kiểm tra chiếm màn hình** (`scripts/selftest/settings-window/run.sh`, mở app thật, gõ thử tự động; tác dụng phụ của từng script: `scripts/README.md`): hỏi người dùng giờ chạy trước, vì họ đang dùng máy. Hook `.claude/hooks/guard-scripts.sh` chặn các script này; người dùng đồng ý trong chat rồi mới chạy lại với tiền tố `DAU_USER_APPROVED=1`. Trong lúc chờ, tiếp tục các việc không bị chặn.
- **Giao diện làm theo thứ tự: canvas trước, mã sau.** Sửa artboard trên canvas, cho người dùng xem và duyệt, rồi mới giao sửa mã; mã xong thì đối chiếu lại với artboard. Không sửa giao diện mà artboard chưa có.
- Ngữ cảnh dài: trước khi ngữ cảnh đầy, ghi trạng thái vào `docs/PROGRESS.md` để có thể tiếp tục ở phiên sau.

## Nguồn chuẩn

- `docs/DECISIONS.md` là nguồn chuẩn **duy nhất** cho quyết định. Canvas mockup có một ghi chú tóm tắt sổ quyết định, và lịch sử trò chuyện trên claude.ai có nhiều đề xuất đã bị thay thế (Rust/WASM, nhúng UniKey, từ điển tiếng Anh, `NSSpellChecker`, phím chuyển nhấn-nhả ⇧, chạy OpenKey làm đáp án test…). Gặp thông tin trái với `DECISIONS.md` ở bất kỳ đâu thì theo `DECISIONS.md`, và sửa hoặc báo chỗ lệch.
- Khi một quyết định thay đổi: sửa `DECISIONS.md` trước, thêm cách nói cũ vào `scripts/check-docs/superseded.txt`, rồi cập nhật ghi chú trên canvas và các tài liệu khác cho khớp trong cùng lượt làm việc (chạy `check.sh` để tìm chỗ còn sót).
- **Mỗi sự kiện chỉ ghi ở một chỗ.** Quyết định ở `DECISIONS.md` (nơi khác dẫn số D/N, không chép lại nội dung); số đo giao diện ở `docs/research/SYSTEM-SETTINGS-REFERENCE.md` và script kiểm; số test và số đo theo ngày ở nhật ký `PROGRESS.md` (mốc đã đóng: trong `docs/history/`); kiến trúc ở `ARCHITECTURE.md` tả cấu trúc, không chép số. Dẫn mã bằng tên kiểu/hàm, không bằng số dòng. File agent trong `.claude/agents/` chỉ nêu vai trò và nơi đọc, không chép sự kiện.
- **Đóng mốc nào thì chuyển nhật ký và ghi nhớ của mốc đó sang `docs/history/`.** Mọi phiên đều đọc `PROGRESS.md`, nên nó chỉ giữ việc của mốc đang làm.
- **Tài liệu nghiên cứu (`docs/research/`) có mục "Hiện trạng" ở đầu, ghi ngày.** Kết luận đổi thì sửa thẳng vào mục đó và vào thân bài, không viết thêm mục "Đính chính" ở cuối.
- **Chỉ ghi kết luận khi đã đo trên Dấu thật hoặc có nguồn.** Quan sát trên bản thử (bundle đổi ID, app thử) ghi riêng một mục có nhãn, không rút kết luận; trạng thái đọc ở đúng chỗ người dùng thấy (danh sách "+", menu), không chỉ qua TIS từ một tiến trình mới.

## Quy tắc làm việc

- **Đối chiếu sổ quyết định trước mọi đề xuất hay thay đổi.** Nếu một thay đổi mâu thuẫn với một nguyên tắc (N1–N5) hoặc quyết định (D1–D…) thì dừng lại và nêu mâu thuẫn, không tự ý làm. Nếu một quyết định cần đổi, cập nhật `docs/DECISIONS.md` trong cùng commit, ghi lý do.
- **Sau mỗi mốc, tự rà soát cơ học:** `scripts/check-docs/check.sh`, rồi grep code và chuỗi giao diện tìm chỗ trái với sổ quyết định (ví dụ: lời hứa về mạng, tính năng đã bỏ, phím tắt riêng).
- **Kiểm tra chéo các tính năng cùng tác động lên một đầu vào.** Với mỗi cặp tính năng như vậy, liệt kê các đầu vào mà chúng cho kết quả trái nhau và quyết định bên nào thắng, ghi vào `DECISIONS.md` (bài học từ D4).
- **Đo trước khi tối ưu.** Mọi khẳng định về hiệu năng phải có số đo (os_signpost / Instruments / test hiệu năng).
- **Không ghi lời hứa chưa kiểm chứng vào giao diện** (N5). Dùng ô trống dạng `[Kết quả bài test tải nặng]`.
- Làm theo mốc trong `docs/ROADMAP.md`, mỗi mốc kết thúc bằng test xanh và một bản tóm tắt ngắn: đã làm gì, đã đo được gì, còn mở gì.
- Những việc cần tài khoản Apple Developer, chứng chỉ ký, hoặc thao tác trong Cài đặt hệ thống: chuẩn bị sẵn và dừng lại hỏi người dùng.

## Quy ước mã nguồn (đề xuất, người dùng có thể đổi)

- Swift 6, strict concurrency. Engine là Swift package thuần, **không import Foundation/AppKit**.
- Dự án Xcode sinh từ `project.yml` bằng XcodeGen, không commit thủ công thay đổi trong `.xcodeproj`.
- Test bằng Swift Testing. Tên định danh, comment và commit message bằng tiếng Anh; chuỗi giao diện trong String Catalog, khoá là câu tiếng Anh, có bản tiếng Việt (D41; thuật ngữ ở `docs/GLOSSARY.md`).
- Script trong `scripts/` viết bằng zsh, dòng đầu `#!/bin/zsh` (bash có sẵn trên macOS là bản 3.2); in ra terminal bằng tiếng Việt qua `scripts/lib/log.sh` (`scripts/README.md` mục "Đầu ra").
- Giấy phép GPLv3 cho toàn bộ repo. Engine là của Dấu, viết từ đầu bằng Swift. Không chép mã từ OpenKey hay UniKey.

## OpenKey là tài liệu tham khảo, không phải đáp án

- Khi cần hiểu tường tận một tính năng (quy tắc đặt dấu, chính tả, khôi phục, gõ tắt…), clone OpenKey **ra ngoài repo** (ví dụ `/tmp/OpenKey`) và đọc mã nguồn, chủ yếu `Sources/OpenKey/engine/`.
- Ghi lại hiểu biết **bằng lời của mình** vào `docs/OPENKEY-NOTES.md`: tính năng, hành vi, ca biên, lỗi phát hiện được, và Dấu làm hay không làm (dẫn số quyết định).
- Kết quả mong đợi trong test viết theo quy tắc chính tả tiếng Việt và `DECISIONS.md`, không lấy từ kết quả chạy OpenKey. Chỗ nào Dấu cố ý khác OpenKey thì ghi rõ trong `OPENKEY-NOTES.md`.

## Lệnh thường dùng (cập nhật khi dự án có thật)

- `brew install xcodegen && xcodegen generate` — sinh `Dau.xcodeproj`.
- `scripts/dev/doctor.sh` — máy mới thiếu gì để build, test, chạy Dấu (Xcode, xcodegen, ký, bản đã cài, nguồn nhập liệu, secure input), kèm lệnh sửa; chỉ đọc, `--tests` để chạy cả test engine.
- `scripts/dev/dau-version.sh` — bản bộ gõ đã cài và đang chạy có đúng commit mới nhất không.
- `scripts/dev/clean-dau.sh` — không tham số: liệt kê mọi dấu vết của Dấu trên tài khoản (chỉ đọc); `--yes` (người dùng tự chạy) xoá những gì xoá được để thử cài từ máy sạch — các mục trong `com.apple.inputsources` phải bỏ bằng "–" trong Cài đặt hệ thống › Bàn phím › Nguồn đầu vào — rồi đăng xuất.
- `scripts/dev/install-input-method.sh` — build và cài bộ gõ bản Debug vào `~/Library/Input Methods`; `--release` cho bản Release.
- `scripts/dev/install-app.sh` — build và cài Dấu.app bản Release vào `/Applications` (đăng ký LaunchServices, thoát rồi mở lại app đang chạy); `--with-input-method` cài cả bộ gõ.
- `swift test --package-path Packages/DauEngine` — test engine.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path scripts/snapshot-settings` — test của app chủ (giao diện dựng từ `Apps/Dau/Sources`).
- `scripts/check-docs/check.sh` — kiểm tài liệu lệch (đường dẫn, số dòng, số D/N, cách nói đã bị thay).
- `scripts/check-l10n/check.sh` — kiểm String Catalog: ngôn ngữ gốc `en`, mọi khoá có bản `en` và `vi` (D41); truyền thư mục build để so khoá trong mã với catalog.
