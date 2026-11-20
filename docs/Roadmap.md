# Lộ trình

Tài liệu này tổng hợp toàn bộ các mốc phát triển từ giai đoạn khởi tạo khung dự án cho đến bản phát hành chính thức, tiêu chí hoàn thành của từng mốc, và danh sách các hạng mục tồn đọng chưa gắn mốc. Bạn có thể theo dõi mốc đang thực hiện, kế hoạch chi tiết cùng các số liệu đo đạc thực tế tại [`docs/Progress.md`](Progress.md).

## Tiêu chí đóng mốc

Một mốc phát triển chỉ được coi là hoàn thành và đóng lại khi thỏa mãn toàn bộ các điều kiện sau:
- Toàn bộ các bài kiểm thử liên quan đều vượt qua thành công (pass 100%).
- Toàn bộ mã nguồn, giao diện và tài liệu đã được tự rà soát kỹ lưỡng, đảm bảo không có điểm nào mâu thuẫn với sổ quyết định [`docs/Decisions.md`](Decisions.md).
- Báo cáo kiểm toán độc lập của mốc đạt kết quả ĐẠT.
- Phiên làm việc đã lập bản tóm tắt ngắn gọn ghi nhận những việc đã làm, số liệu đo đạc thực tế và các câu hỏi kỹ thuật còn mở.
- Toàn bộ nhật ký chi tiết của mốc đã được chuyển sang lưu trữ an toàn trong thư mục [`docs/history/`](history/).

## Mốc đã đóng

| Mốc | Mục tiêu hoàn thành | Nhật ký phát triển |
|---|---|---|
| M0 Khung dự án | Khởi tạo kho mã nguồn, cấu hình `project.yml` với hai target ứng dụng và hai package thư viện, hỗ trợ biên dịch universal. | [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md) |
| M1 Engine | Xây dựng thư viện `VietEngine` độc lập cho các kiểu gõ Telex, VNI và Telex đơn giản, đi kèm bộ kiểm thử đầy đủ và số đo vi mô cho từng phím gõ. | [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md) |
| M2 Bộ gõ tối thiểu | Hoàn thiện bộ gõ IMK có khả năng thay chữ tại chỗ, đồng thời chốt phương thức xác định vị trí con trỏ thay chữ trên hệ thống. | [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md), [`docs/history/M2Testing.md`](history/M2Testing.md) |
| M3 Độ tin cậy | Xây dựng cơ chế reset khi lệch ngữ cảnh, phòng thủ lỗi bất thường từ IMK, áp dụng gạch chân theo danh sách tương thích và thiết lập ma trận tương thích. | [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md) |
| M4 App Cài đặt | Xây dựng cửa sổ ứng dụng Cài đặt theo thiết kế tại `docs/UI.md`, đồng bộ cấu hình qua App Group bằng thông báo Darwin. | [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md) |
| M5 Onboarding, cài, gỡ | Hoàn thiện quy trình onboarding ba bước, phát hiện bộ gõ cũ, cùng script cài đặt và gỡ bỏ bộ gõ sạch sẽ trên máy người dùng. | [`docs/history/LogM5.md`](history/LogM5.md) |
| M6 Hiệu năng dưới tải | Đảm bảo bộ gõ xử lý chính xác khi ứng dụng đích bị bận và khi toàn hệ thống chịu tải nặng (`scripts/selftest/load/heavy.sh`, theo ngưỡng D42), đối chứng đạt chuẩn với Telex của Apple. | [`docs/history/LogM6.md`](history/LogM6.md) |

Kế hoạch chi tiết ban đầu của các mốc trên được lưu trữ tại [`docs/history/Plans.md`](history/Plans.md). Phần nền tảng cho mốc M9 (Đa ngôn ngữ) đã được hoàn thành trong giai đoạn chuyển tiếp giữa mốc M5 và M6, xem chi tiết tại [`docs/history/LogBetweenM5AndM6.md`](history/LogBetweenM5AndM6.md).

## M7 — Phát hành

Mục tiêu chính của mốc là đưa bản beta đầu tiên (gắn thẻ phiên bản `v0.1.0-beta.1`, theo quyết định D7 (Cập nhật và loại bản dựng)) đến tay người dùng thông qua tệp DMG, cơ chế tự cập nhật Sparkle và trình quản lý gói Homebrew. Kế hoạch thực hiện theo từng bước cùng phân công nhiệm vụ được ghi nhận chi tiết tại [`docs/Progress.md`](Progress.md), mục "Kế hoạch M7". Các hạng mục cụ thể bao gồm:

- Trước khi phát hành, dự án sẽ chạy lại bài đo tải nặng theo quyết định D42, đồng thời ghi nhận mức tiêu thụ bộ nhớ (RSS) của tiến trình bộ gõ bản Release đặt cạnh số đo của bản Debug trong cùng một lượt chạy.
- Thực hiện ký số bằng chứng chỉ Developer ID, công chứng (notarize) với Apple và đóng gói tệp cài đặt DMG.
- Tích hợp Sparkle 2 sử dụng chữ ký EdDSA, phát hành tệp appcast và phân định loại bản dựng theo quyết định D7. Hệ thống chia làm hai kênh Beta và Chính thức, có công tắc chuyển đổi kênh trong trang Cài đặt; sau khi cài đặt phiên bản mới, ứng dụng sẽ gọi `SystemInputMethodInstaller.reconcile` để cập nhật bộ gõ nhúng vào hệ thống.
- Rà soát lại toàn bộ quyền entitlement của bộ gõ trước khi notarize, duy trì quyền `temporary-exception.mach-register.global-name` đã được đối soát vào ngày 17/11/2026 (chi tiết xem tại [`docs/research/IMKAPINotes.md`](research/IMKAPINotes.md)).
- Cấu hình GitHub Actions để tự động chạy kiểm thử trên mỗi lần đẩy mã nguồn, tự động build bản phát hành khi có tag mới, và kích hoạt cả bài kiểm thử hiệu năng chuyên sâu của engine (`PerformanceTests`).
- Thiết lập Homebrew cask `dau` có hỗ trợ `auto_updates true` trong tap riêng `codefastlabs/homebrew-tap` (theo quyết định D6 (Phát hành)).
- Xây dựng luồng báo lỗi gõ phím trực tiếp bằng đường dẫn tạo issue điền sẵn thông tin (theo quyết định D8 (Không telemetry)), đi kèm hàng "Ứng dụng gõ sai chữ" trong giao diện `UpdatesSupportView`.
- Chuẩn hóa loại bản dựng theo các quyết định D7 và D25 (Nhận diện):
  - Bản build phát hành chính thức trên CI sẽ truyền cờ `DAU_OFFICIAL=YES` cho `xcodebuild` (`project.yml`) và sử dụng biểu tượng `AppIcon`, phân biệt với `AppIconDev` của bản phát triển.
  - Tệp nhị phân của bản phát hành được lược bỏ các ký hiệu nội bộ (strip symbols) và tệp dSYM được lưu trữ riêng để hỗ trợ giải mã báo cáo sự cố (crash report).
  - Số hiệu bản build tăng dần liên tục, số phiên bản hiển thị gồm ba chữ số sạch sẽ; bản phát hành chính thức sẽ sử dụng trực tiếp tệp nhị phân của bản beta cuối cùng chứ không biên dịch lại.
- Cập nhật `.gitignore` và cố định phiên bản chính xác của Sparkle trong `project.yml`.
- Thiết kế biểu tượng chính thức bằng công cụ Icon Composer để thay thế cho biểu tượng tạm thời (xem tại [`docs/Brand.md`](Brand.md)).
- Xuất toàn bộ các tệp nhận diện cần thiết cho bản beta đầu tiên theo danh mục tại [`docs/Brand.md`](Brand.md).
- Giải đáp thực tế các câu hỏi mở còn lại trong sổ quyết định [`docs/Decisions.md`](Decisions.md), bao gồm việc kiểm tra hộp thoại App Group và thao tác kích hoạt bộ gõ khi mang cờ kiểm dịch (quarantine).
- Thực hiện kiểm tra thủ công trước khi phát hành với người dùng thật:
  - Kiểm tra khả năng điều hướng bằng VoiceOver và phím Tab qua toàn bộ cửa sổ Cài đặt.
  - Xác nhận VoiceOver đọc đúng tên nguồn đầu vào "Dấu – Tiếng Việt" khi chuyển đổi bàn phím (theo quyết định D17 (Trợ năng)).
  - Kiểm tra biểu tượng "V" trên thanh menu là đồ họa đơn sắc và tự động thích ứng theo giao diện sáng/tối.
  - Kiểm tra giao diện khi hệ điều hành chuyển hoàn toàn sang tiếng Anh.
  - Kiểm tra hiển thị của các sheet giao diện ở chế độ nền tối (Dark Mode).
  - Xác nhận Dấu xuất hiện chính xác trong danh sách bàn phím "+" của mục System Settings.
- Tiêu chí hoàn thành mốc: Bản phát hành `v0.1.0-beta.1` được tải lên GitHub Releases, người dùng có thể cài đặt dễ dàng qua tệp DMG hoặc lệnh `brew install --cask codefastlabs/tap/dau`, cơ chế tự cập nhật Sparkle hoạt động ổn định và báo cáo kiểm toán của mốc đạt kết quả ĐẠT.

### Kế hoạch sau bản beta đầu tiên

Các hạng mục dưới đây không chặn việc hoàn thành mốc M7 và sẽ được triển khai khi có phản hồi từ người dùng thực tế:
- Xây dựng quy trình sửa lỗi khẩn cấp cho bản chính thức từ nhánh riêng biệt khi nhánh `main` đang phát triển dở dang (chi tiết xem tại [`docs/Releasing.md`](Releasing.md)).
- Kiểm tra và bổ sung thuộc tính `sparkle:minimumSystemVersion` vào công cụ sinh appcast trước khi nâng mức yêu cầu hệ điều hành tối thiểu.
- Hoàn thiện cơ chế phát hành theo từng đợt (staged rollout) theo quyết định D7 và khả năng quay về phiên bản trước theo quyết định D19 (Quay về bản trước).
- Tích hợp cơ chế chứng thực nguồn gốc phần mềm (artifact attestation) và bài đếm cấp phát bộ nhớ (`malloc_logger`) trên CI.
- Mở rộng kiểm thử và trải nghiệm gõ thực tế trên các phiên bản macOS từ 14 đến 26 cùng các dòng máy Mac sử dụng chip Intel (theo quyết định D1 (Nền tảng)).
- Đệ trình cask chính thức vào kho lưu trữ cộng đồng `homebrew/cask` khi dự án đạt đủ độ phổ biến theo quy định (theo quyết định D6).

## M8 — Website giới thiệu

- Chốt công nghệ xây dựng trang web chính thức. Thư mục mã nguồn của trang web đã được thống nhất đặt tại `site/`, tương ứng với thư mục gốc trên nền tảng Vercel nơi tệp `appcast.xml` đang lưu trữ.
- Xây dựng trang web tải về theo tài liệu [`docs/Website.md`](Website.md) và bộ nhận diện [`docs/Brand.md`](Brand.md), đảm bảo tính chất trang tĩnh, giao diện tương thích tốt trên mọi kích thước màn hình, có đầy đủ thẻ meta, ảnh Open Graph và favicon.
- Toàn bộ các thông số kỹ thuật và cam kết hiển thị trên trang web bắt buộc phải lấy từ dữ liệu đo đạc thực tế (tuân thủ nguyên tắc N5 (Chỉ hứa điều đã kiểm chứng)).
- Tiêu chí hoàn thành mốc: Trang web đạt điểm số Google Lighthouse từ 95 điểm trở lên trên cả bốn hạng mục đo đạc trên thiết bị di động, và báo cáo kiểm toán đạt kết quả ĐẠT.

## M9 — Đa ngôn ngữ (Phần còn lại)

Mục đích của mốc là giúp Dấu có thể được cộng đồng người Việt sử dụng rộng rãi, đồng thời hỗ trợ người nước ngoài đang học tập và làm việc bằng tiếng Việt. Các quy tắc ngôn ngữ, hệ thống khóa chuỗi, tên nguồn đầu vào và cơ chế chọn ngôn ngữ riêng cho ứng dụng tuân thủ quyết định D41 (Ngôn ngữ giao diện). Các ngôn ngữ mới chỉ được bổ sung khi có người bản ngữ sử dụng thành thạo tham gia duyệt bản dịch.

- Thực nghiệm để kiểm tra xem macOS có cho phép gán ngôn ngữ hiển thị riêng cho tiến trình bộ gõ trong mục cài đặt của hệ điều hành hay không.
- Nghiên cứu cơ chế hiển thị mục "Open Dấu Settings…" ở cuối menu nhập liệu của hệ thống khi bộ gõ khai báo trang cài đặt riêng.
- Thiết kế phiên bản tiếng Anh cho các màn hình chính trên bản vẽ canvas.
- Cập nhật bộ script kiểm tra cửa sổ thật (`scripts/selftest/settings-window/run.sh`) để kiểm thử bố cục giao diện độc lập trên từng ngôn ngữ khác nhau.
- Xây dựng phiên bản tiếng Anh cho trang web tải về thuộc mốc M8.
- Tiêu chí hoàn thành mốc: Khi hệ thống macOS chuyển sang tiếng Anh, toàn bộ ứng dụng, bộ gõ, màn hình onboarding và các hộp thoại đều hiển thị tiếng Anh chuẩn xác; script `run.sh` chạy thành công trên cả hai ngôn ngữ; và báo cáo kiểm toán đạt kết quả ĐẠT.

## M10 — Học cách gõ

Mục đích của mốc là giúp người dùng dễ dàng làm quen, thực hành các kiểu gõ và hiểu rõ sự khác biệt giữa Dấu với các bộ gõ tiếng Việt khác.

- Các tính năng tích hợp trực tiếp trong ứng dụng:
  - Khung gõ thử tương tác giải thích trực quan từng bước gõ phím (ví dụ minh họa luồng `vieetj` → vi → viê → việt).
  - Bảng tra cứu trực quan và tiện lợi cho các kiểu gõ Telex, Telex đơn giản và VNI.
  - Bố cục giao diện gọn gàng và tương đồng ứng dụng System Settings theo quyết định D9 (Giao diện).
  - Tuyệt đối không lưu trữ bất kỳ dữ liệu nào về nội dung phím người dùng đã gõ thử theo quyết định D8 (Không telemetry).
- Nội dung xây dựng trên trang web giới thiệu:
  - Xây dựng chuyên trang so sánh "Dấu khác các bộ gõ khác thế nào".
  - Toàn bộ các điểm khác biệt nêu ra bắt buộc phải có số liệu và bằng chứng đo đạc thực tế (tuân thủ nguyên tắc N5).
  - Dữ liệu đối chiếu được trích xuất từ các tài liệu [`docs/research/CompetitorComparison.md`](research/CompetitorComparison.md), [`docs/research/OpenKeyNotes.md`](research/OpenKeyNotes.md) và bộ dữ liệu kiểm thử chính tả của dự án.
  - Dẫn chiếu minh bạch tới mục "Đã biết nhưng không làm" trong sổ quyết định `docs/Decisions.md`.
- Toàn bộ nội dung hướng dẫn sẽ có sẵn cả hai phiên bản tiếng Việt và tiếng Anh sau khi mốc M9 hoàn thành.
- Tiêu chí hoàn thành mốc: Bản vẽ thiết kế nội dung được duyệt trên canvas, mọi ví dụ minh họa đều có bài test tương ứng trong engine, và báo cáo kiểm toán đạt kết quả ĐẠT.

## Hạng mục tồn đọng chưa gắn mốc

- Xem xét việc có bổ sung liên kết "Ủng hộ dự án" vào bên trong giao diện ứng dụng hay không (theo quyết định D39 (Ủng hộ dự án)), với điều kiện phải hoàn thiện bản vẽ thiết kế trên canvas trước khi lập trình.
- Hoàn thiện ma trận tương thích cho các ứng dụng còn lại (ghi nhận tại mục 7 của [`docs/Compatibility.md`](Compatibility.md)) sau khi phát hành bản beta đầu tiên, dựa trên phản hồi lỗi thực tế từ người dùng thay vì tự đo đạc trước toàn bộ.
