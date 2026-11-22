# Lộ trình

Tài liệu này liệt kê các mốc từ khung dự án tới bản phát hành, tiêu chí xong của từng mốc và những việc tồn đọng chưa gắn mốc. Mốc đang làm, kế hoạch chi tiết và số đo nằm ở [`docs/Progress.md`](Progress.md).

## Tiêu chí đóng mốc

Một mốc được đóng khi đủ các điều kiện sau:
- Mọi test đều xanh.
- Phiên làm việc đã tự rà soát mốc với [`docs/Decisions.md`](Decisions.md).
- Kiểm toán của mốc ĐẠT.
- Mốc có một bản tóm tắt ngắn ghi việc đã làm, số đo và các câu hỏi còn mở.
- Nhật ký của mốc đã được chuyển sang `docs/history/`.

## Mốc đã đóng

| Mốc | Mục tiêu | Nhật ký |
|---|---|---|
| M0 Khung dự án | Dựng repo và `project.yml` với hai target app, hai package, build universal. | [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md) |
| M1 Engine | Viết `VietEngine` cho Telex, VNI và Telex đơn giản, kèm bộ test và số đo cho mỗi phím. | [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md) |
| M2 Bộ gõ tối thiểu | Làm bộ gõ IMK thay chữ tại chỗ và chốt cách lấy vị trí thay chữ. | [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md), [`docs/history/M2Testing.md`](history/M2Testing.md) |
| M3 Độ tin cậy | Làm phần reset khi lệch ngữ cảnh, phòng thủ IMK, gạch chân theo danh sách tương thích, quy tắc theo ứng dụng và ma trận tương thích. | [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md) |
| M4 App Cài đặt | Làm cửa sổ Cài đặt theo `docs/UI.md` và phần cài đặt dùng chung qua App Group. | [`docs/history/LogM0ToM4.md`](history/LogM0ToM4.md) |
| M5 Onboarding, cài, gỡ | Làm onboarding, phần phát hiện bộ gõ cũ, cùng việc cài và gỡ bộ gõ. | [`docs/history/LogM5.md`](history/LogM5.md) |
| M6 Hiệu năng dưới tải | Bảo đảm Dấu gõ đúng khi app bận và khi cả máy dưới tải (`scripts/selftest/load/heavy.sh`, ngưỡng D42), có đối chứng với Telex của Apple. | [`docs/history/LogM6.md`](history/LogM6.md) |

Kế hoạch của các mốc này nằm ở [`docs/history/Plans.md`](history/Plans.md). Phần nền của M9 (Đa ngôn ngữ) đã làm xong giữa M5 và M6; nhật ký của phần đó nằm ở [`docs/history/LogBetweenM5AndM6.md`](history/LogBetweenM5AndM6.md).

## M7 — Phát hành

Mục tiêu của M7 là đưa beta đầu tiên (tag `v0.1.0-beta.1`, D7 (Cập nhật và loại bản dựng)) tới tay người dùng qua DMG, Sparkle và Homebrew. Kế hoạch theo từng bước và việc của từng bên nằm ở [`docs/Progress.md`](Progress.md), mục "Kế hoạch M7". Phần đã xong và phần còn lại cũng ghi ở mục đó, nên danh sách dưới đây không đánh dấu từng dòng.

- Trước khi phát hành, phiên làm việc chạy bài đo của D42. Trong cùng lượt đó, phiên ghi bộ nhớ (RSS) của tiến trình bộ gõ bản Release cạnh số của bản Debug, vì D42 ghi chênh lệch này là chưa đo.
- Bản phát hành được ký Developer ID, notarize và đóng thành DMG.
- Sparkle 2 dùng chữ ký EdDSA, appcast và loại bản theo D7. Có hai kênh, Beta và Chính thức:
  - Công tắc chọn kênh nằm ở trang Cập nhật & hỗ trợ, và artboard phải có trước.
  - Kênh mặc định theo giai đoạn lúc cài.
  - Mục beta trong appcast gắn kênh `beta`; quảng bá một bản là bỏ thẻ kênh của nó.
  - Cài bản mới xong, app gọi `SystemInputMethodInstaller.reconcile` để bộ gõ đã cài được thay bằng bản nhúng trong Dấu.app mới.
- Trước khi notarize, phiên làm việc rà entitlement của bộ gõ và giữ `temporary-exception.mach-register.global-name`. Lần rà gần nhất là ngày 17/11/2026, ghi ở [`docs/research/IMKAPINotes.md`](research/IMKAPINotes.md), mục "Kết nối của IMKServer và sandbox".
- GitHub Actions chạy test ở mỗi lần đẩy mã, build bản phát hành từ tag, và chạy cả test hiệu năng của engine (`PerformanceTests`).
- Homebrew cask `dau` có `auto_updates true` và nằm trong tap riêng `codefastlabs/homebrew-tap` (D6 (Phát hành)).
- Báo lỗi dùng URL issue điền sẵn (D8 (Không telemetry)). Hàng "Ứng dụng gõ sai chữ" trong `UpdatesSupportView` làm theo artboard "Cập nhật & hỗ trợ".
- Loại bản dựng theo D7 và D25 (Nhận diện):
  - Một cờ build chọn biểu tượng chuẩn, và chỉ quy trình phát hành trên CI đặt cờ này. Bản build phát hành truyền `DAU_OFFICIAL=YES` cho `xcodebuild` (`project.yml`), rồi kiểm bản build: `CFBundleIconName` của Dấu.app và của bộ gõ phải là `AppIcon`, không phải `AppIconDev`.
  - Cũng bước kiểm đó xác nhận binary của Dấu.app và của bộ gõ đã lược ký hiệu cục bộ (kiểm bằng `nm`; archive có lược, còn `xcodebuild build` thì không). dSYM của mỗi bản phát hành được lưu lại để đọc được báo lỗi crash.
  - Số build tăng dần. Số hiển thị gồm ba số và không có chữ beta. Bản chính thức là tệp của beta cuối, không dựng lại.
- `.gitignore` và `project.yml` được sửa như sau. `project.yml` ghim phiên bản Sparkle chính xác, vì `Package.resolved` bị git bỏ qua. `.gitignore` thêm `*.p8`, `*.pem`, `*.key`, `*.p12`, `*.xcarchive`.
- Biểu tượng thật được dựng bằng Icon Composer để thay biểu tượng tạm ([`docs/Brand.md`](Brand.md), mục "Hiện trạng").
- Phiên làm việc xuất các file nhận diện mà beta đầu tiên cần theo [`docs/Brand.md`](Brand.md): biểu tượng app, biểu tượng bản phát triển, ảnh template thanh menu, ảnh xem trước GitHub và nền DMG. Favicon, ảnh Open Graph và thẻ meta đi cùng website (M8).
- M7 trả lời hai câu hỏi mở của [`docs/Decisions.md`](Decisions.md). Câu thứ nhất là hộp thoại App Group với bản ký Developer ID. Câu thứ hai là hộp thoại và việc đăng xuất khi bật bộ gõ với bản ký Developer ID mang quarantine.
- Trước khi phát hành, một người phải kiểm các điều sau:
  - VoiceOver và Tab ("Điều hướng bàn phím") đi được qua cửa sổ Cài đặt.
  - VoiceOver đọc đúng tên "Dấu – Tiếng Việt" khi chuyển nguồn. Theo D17 (Trợ năng), hệ thống có đọc, nhưng tên đọc ra chưa được xác nhận.
  - Biểu tượng "V" trên thanh menu đơn sắc và đổi màu theo nền sáng hay tối.
  - Khi máy để tiếng Anh hẳn, menu app và tên "Dấu" trong Finder hiện đúng.
  - Các sheet hiện đúng ở chế độ tối.
  - Danh sách "+" của System Settings có Dấu; điều này kiểm bằng mắt.
- M7 xong khi bản `v0.1.0-beta.1` có trên GitHub Releases, cài được từ DMG và bằng `brew install --cask codefastlabs/tap/dau`, Sparkle cập nhật được từ một bản phát hành trước đó và chọn được kênh, và kiểm toán ĐẠT.

### Sau beta đầu tiên

Các việc dưới đây không chặn việc đóng M7 và sẽ làm khi đã có người dùng:
- Dấu cần một quy trình sửa gấp bản chính thức từ một nhánh khi `main` đã có việc dở. Trong quy trình đó, `check-release-gate.sh` và workflow Test nhận nhánh phát hành, còn script phát hành từ chối số build đã phát ([`docs/Releasing.md`](Releasing.md), mục "Kịch bản phát hành"). Việc này cần xong trước bản chính thức đầu tiên.
- Phiên làm việc kiểm `generate_appcast` có ghi `sparkle:minimumSystemVersion` không, và thêm nếu thiếu. Việc này cần xong trước lần nâng bản macOS tối thiểu.
- Dấu sẽ có phát hành theo đợt (D7) và quay về bản trước (D19 (Quay về bản trước)).
- CI sẽ có artifact attestation và phép đếm cấp phát (`malloc_logger`).
- Phiên làm việc cài, bật và gõ thử trên macOS 14–26 và trên máy Intel. Theo D1 (Nền tảng), tới lúc đó Dấu chỉ nói đã kiểm trên macOS 27 và Apple silicon. Câu hỏi mở "Hộp thoại và đăng xuất khi bật bộ gõ" trên các bản macOS đó cũng cần lượt thử này.
- Cask sẽ được gửi vào `homebrew/cask` khi repo đạt ngưỡng (D6).

## M8 — Website

- Người dùng chốt công nghệ của trang web. Thư mục đã chốt ngày 17/11/2026 là `site/`, thư mục gốc của project Vercel, nơi `appcast.xml` đã nằm ([`docs/Releasing.md`](Releasing.md)).
- Trang tải về được dựng theo [`docs/Website.md`](Website.md) (mục "Trang tải về (M8)") và [`docs/Brand.md`](Brand.md). Trang là trang tĩnh, responsive, có thẻ meta, ảnh Open Graph và favicon.
- Các ô số liệu và lời hứa chỉ được điền từ kết quả đã đo (N5 (Chỉ hứa điều đã kiểm chứng)).
- M8 xong khi Lighthouse đạt từ 95 trở lên ở cả bốn hạng mục trên điện thoại và kiểm toán ĐẠT.

## M9 — Đa ngôn ngữ (phần còn lại)

Mục đích của M9 là để người Việt có thể dùng Dấu rộng rãi, và để người nước ngoài học tiếng Việt cũng muốn dùng nó. Quy tắc ngôn ngữ, khoá chuỗi, tên nguồn và cách đặt ngôn ngữ riêng cho Dấu theo D41 (Ngôn ngữ giao diện). Một ngôn ngữ khác chỉ được thêm khi có người nói thạo ngôn ngữ đó duyệt.

- Câu hỏi mở "Bộ gõ trong mục ngôn ngữ riêng từng ứng dụng" (`docs/Decisions.md`) cần được trả lời bằng phép đo: bộ gõ có đặt được ngôn ngữ riêng hay không.
- Mục "Open Dấu Settings…" của hệ thống, mục cuối của menu nhập liệu, chỉ có khi bộ gõ khai báo được trang cài đặt riêng. Việc này cần một lượt nghiên cứu riêng trước khi làm.
- Canvas cần bản tiếng Anh cho các màn chính.
- Bộ kiểm cửa sổ thật (`scripts/selftest/settings-window/run.sh`) cần chạy theo từng ngôn ngữ, vì độ dài chữ làm đổi bố cục. Hiện nay mọi lần mở đều ép tiếng Việt (`-AppleLanguages (vi)`).
- Trang tải về (M8) cần có bản tiếng Anh.
- M9 xong khi một máy để tiếng Anh hẳn thấy toàn bộ app, bộ gõ, onboarding và hộp thoại bằng tiếng Anh, `run.sh` đạt ở cả hai ngôn ngữ, và kiểm toán ĐẠT.

## M10 — Học cách gõ

Mục đích của M10 là để người dùng biết và học được cách gõ, và biết các bộ gõ khác nhau thế nào về cách gõ.

- Phần trong app gồm các việc sau:
  - Một ô gõ thử giải thích từng bước, ví dụ `vieetj` → vi → viê → việt, và phím nào làm gì.
  - Một bảng tra cho Telex, Telex đơn giản và VNI.
  - Phần này theo D9 (Giao diện), tức là gọn như System Settings.
  - Phần này không lưu gì về chữ đã gõ (D8 (Không telemetry)).
- Phần trên trang web là trang "Dấu khác các bộ gõ khác thế nào":
  - Trang chỉ ghi những khác biệt đã đo được (N5).
  - Nguồn là [`docs/research/CompetitorComparison.md`](research/CompetitorComparison.md), [`docs/research/OpenKeyNotes.md`](research/OpenKeyNotes.md) và bộ dữ liệu kiểm thử (đặt dấu kiểu mới hay kiểu cũ, đặt dấu tự do, khôi phục từ nước ngoài, uơ và ươ…).
  - Trang dẫn tới mục "Đã biết nhưng không làm" của `docs/Decisions.md`.
- Nội dung có bản tiếng Việt và tiếng Anh nếu M9 đã xong.
- M10 xong khi người dùng duyệt nội dung trên canvas, mọi ví dụ trong phần học có test engine tương ứng, và kiểm toán ĐẠT.

## Tồn đọng chưa gắn mốc

- Làm phần ghi nhận người ủng hộ theo D39 (Ủng hộ dự án): file danh sách tên trong repo, mục "Người ủng hộ" ở trang Cập nhật & hỗ trợ (`docs/UI.md`), và dòng cảm ơn trong ghi chú phát hành (thêm vào `docs/Releasing.md` khi làm). Phần trên trang web thuộc M8 (`docs/Website.md`, mục Góp sức).
- Phần ma trận tương thích còn lại ([`docs/Compatibility.md`](Compatibility.md), mục 7: các app chưa đo, bài click hay bấm mũi tên rồi gõ tiếp, và tự sửa chính tả của macOS) làm sau beta đầu tiên. Người thử báo lỗi thay cho việc đo trước; người dùng chọn cách này ngày 13/11/2026.
