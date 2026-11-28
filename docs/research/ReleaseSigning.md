# Ký bản phát hành khi chưa notarize: Sparkle, Homebrew, Gatekeeper và App Group

Nghiên cứu cho D6 (Phát hành), D7 (Cập nhật và loại bản dựng) ý "Chuyển danh tính ký", D24 (Tên và định danh) và D37 (Cài bộ gõ). Bốn câu hỏi được trả lời ở đây. Câu thứ nhất là Sparkle có nhận bản cập nhật ký Developer ID của một Team ID khác khi bản đang cài ký Apple Development của Personal Team không. Câu thứ hai là Homebrew làm gì với cask có app ký mà không notarize. Câu thứ ba là Gatekeeper chặn lần mở đầu thế nào và hiện chữ gì. Câu thứ tư là app không sandbox đọc thư mục App Group của team khác có làm macOS hỏi người dùng không.

Mỗi khẳng định mang một nhãn nguồn:
- **[Mã Sparkle]** là mã của tag `2.10.1` (commit `ab7d712`), đúng bản `project.yml` ghim.
- **[Tài liệu Sparkle]** là trang [sparkle-project.org/documentation](https://sparkle-project.org/documentation/).
- **[Mã Homebrew]** là mã của Homebrew 7.0.16 trên máy phát triển (`$(brew --repository)`), cùng tài liệu đi kèm trong thư mục `docs/` của repo đó.
- **[Apple]** là tài liệu, trang hỗ trợ hay phiên WWDC của Apple. **[Apple DTS]** là câu trả lời của kỹ sư Apple trên Developer Forums.
- **[Đọc từ tệp, chưa thấy trên màn hình]** là chuỗi đọc từ tệp `.loctable` của macOS 27.2.1 (26B131) trên máy phát triển, chưa thấy trong hộp thoại thật.
- **[Suy luận, cần kiểm chứng]** là kết luận rút từ mã hay tài liệu mà chưa có lần chạy thật nào xác nhận.

## Hiện trạng (28/11/2026, Sparkle 2.10.1, Homebrew 7.0.16, macOS 27.2.1)

- **Sparkle nhận bản ký Developer ID của team khác** khi chữ ký EdDSA của tệp tải về hợp lệ theo khoá công khai của bản đang cài, bản mới vẫn mang khoá EdDSA và bản mới có chữ ký mã hợp lệ. Sparkle không so Team ID hay danh tính ký trong trường hợp này. Sparkle chỉ đòi danh tính ký khớp khi chữ ký EdDSA không đạt. Sparkle cho đổi một trong hai thứ mỗi lần, chữ ký mã hoặc khoá EdDSA, nên kế hoạch của D7 (đổi danh tính ký, giữ khoá) nằm trong luật đó [Mã Sparkle; Tài liệu Sparkle]. Chưa chạy thật (mục 1.5).
- **Sparkle không đòi notarize** và không kiểm notarize. Sparkle gỡ quarantine khỏi bản mới trước khi đặt vào chỗ. Bản Dấu tải bằng Sparkle cũng không mang quarantine, vì app chủ không sandbox và không khai `LSFileQuarantineEnabled`. Vì vậy Gatekeeper không chặn lần mở lại sau cập nhật [Mã Sparkle; Apple; suy luận, cần kiểm chứng ở lượt cập nhật giữa hai bản thử].
- **Khi Team ID đổi, Sparkle tự đổi cách thay bundle.** Trình cài của Sparkle chạy từ bản đang cài, nên mang Team ID cũ. Khi trình cài và bản mới khác Team ID, Sparkle bỏ lần đổi chỗ nguyên tử và bỏ bước quét Gatekeeper (`gktool scan`), để macOS không hỏi quyền App Management [Mã Sparkle].
- **Homebrew 7.0.16 luôn gắn quarantine** lên tệp cask tải về và lên mọi tệp giải nén từ đó. Tuỳ chọn `--no-quarantine` không còn: Homebrew 5.0.0 bỏ dùng nó, 5.1.0 tắt nó và 6.0.0 xoá nó. Lúc cài, `brew` không kiểm Gatekeeper, không từ chối và không cảnh báo app chưa notarize. Chỉ lệnh `brew audit` của tap chính thức mới kiểm Gatekeeper [Mã Homebrew].
- **Chính sách Gatekeeper của Homebrew chỉ áp cho `homebrew/cask`.** Từ tháng 9/2026, cask của tap đó không qua Gatekeeper sẽ bị tắt. Tap riêng `codefastlabs/homebrew-tap` không chịu luật này. Khi cask chuyển vào `homebrew/cask` (D6), app phải ký Developer ID và notarize [Mã Homebrew; brew.sh].
- **Cask nên báo bước Gatekeeper bằng `caveats` dạng chuỗi.** Homebrew không có caveat dựng sẵn cho trường hợp này. Không dùng `deprecate!` hay `disable!` với lý do `:fails_gatekeeper_check`, vì hai stanza đó dành cho việc ngừng phát một cask [Mã Homebrew].
- **Gatekeeper từ macOS 15:** người dùng không còn mở được app chưa notarize bằng Control-click rồi chọn Open. Họ phải mở app một lần, vào System Settings › Privacy & Security, bấm "Open Anyway" trong vòng khoảng một giờ, xác nhận rồi nhập mật khẩu [Apple]. Chuỗi tiếng Anh và tiếng Việt của từng bước nằm ở mục 3.2 [đọc từ tệp]; bản tiếng Anh của các hộp thoại đã thấy trên màn hình ở mục 3.3. DMG ký mà không notarize bị chặn ngay lúc mở, nên đường Personal Team không ký DMG.
- **macOS có riêng một bộ chuỗi cho app ký bằng tài khoản miễn phí** ("… is for personal testing purposes by …", tức "dùng cho các mục đích thử nghiệm cá nhân"). Bản Personal Team của Dấu sẽ hiện bộ chuỗi này hay bộ chuỗi chung "“Dấu” Not Opened" thì phải thấy trên màn hình mới biết [suy luận, cần kiểm chứng].
- **Bảo vệ thư mục App Group (macOS 15 trở lên):** app đọc thư mục group của một team khác làm macOS hỏi người dùng, kể cả khi app không sandbox. Không có cách nào tránh câu hỏi đó. Quyền người dùng cho chỉ giữ tới khi tiến trình thoát [Apple DTS]. Vì vậy bản ký Developer ID (team mới) không nên đọc `~/Library/Group Containers/M58DANM3ZP.com.codefastlabs.dau.shared`. Thiết kế chép cài đặt sang defaults riêng của app chủ khi còn ký Personal Team, rồi bản mới đọc từ đó, tránh được câu hỏi này.
- **Rủi ro mới cho D37:** từ macOS 13, macOS chặn một app sửa app của team khác nếu app bị sửa không khai `NSUpdateSecurityPolicy` cho phép [Apple]. Sau khi chuyển, app chủ ký Developer ID thay bộ gõ ký Personal Team trong `~/Library/Input Methods`. Apple nói về luật này cho app đã notarize, còn bộ gõ Personal Team thì không notarize. Lần thay đó có bị chặn hay hỏi quyền App Management không thì chưa rõ [suy luận, cần kiểm chứng] (mục 5).

## 1. Sparkle 2.10.1

### 1.1 Luật nhận bản cập nhật

Dấu không khai `SUVerifyUpdateBeforeExtraction` và không khai `SURequireSignedFeed` (`Apps/Dau/Info.plist`, `project.yml`). Bản cập nhật là một DMG chứa app. Với cấu hình đó, Sparkle kiểm bản cập nhật sau khi giải nén, trong `-[SUUpdateValidator validateUpdateForHost:downloadedToPath:newBundleURL:signatures:error:]` [Mã Sparkle]. Các bước kiểm như sau:

1. Bản mới phải còn khoá EdDSA nếu bản cũ có khoá. Bản mới phải có chữ ký mã nếu bản cũ có chữ ký mã. Sparkle gọi đây là luật "chỉ cho xoay, không cho bỏ" (`passesBasicUpdatePolicyWithHostIsCodeSigned:…`).
2. Sparkle kiểm chữ ký EdDSA của tệp tải về bằng khoá công khai của **bản cũ**. Mã ghi rõ việc kiểm bằng khoá cũ, không bằng khoá mới, là phần quyết định an ninh.
3. Sparkle kiểm bản mới có thoả yêu cầu chỉ định (designated requirement) của bản cũ không. Yêu cầu chỉ định của app ký Apple Development hay Developer ID chứa Team ID, nên bản team A và bản team B không khớp nhau ở bước này.
4. Nếu bước 2 không đạt mà bản mới có khoá EdDSA, chữ ký phải hợp lệ theo khoá mới, nếu không Sparkle từ chối.
5. Nếu bước 2 đạt, bản mới có chữ ký mã mà bước 3 không đạt, chữ ký mã của bản mới vẫn phải hợp lệ tự thân (`SecStaticCodeCheckValidityWithErrors` ở mọi kiến trúc, không kèm yêu cầu nào và không kiểm mã lồng bên trong).
6. Sparkle nhận bản cập nhật khi bước 2 hoặc bước 3 đạt. Comment của Sparkle giải thích cho phép một trong hai hỏng để xoay khoá mà không đứt chuỗi tin cậy.

Áp vào D7: bản team A (Personal Team) cập nhật lên bản team B (Developer ID) cùng khoá EdDSA thì đạt bước 2, trượt bước 3 và đạt bước 5. Sparkle nhận bản đó. Sparkle không so anchor, loại chứng chỉ hay Team ID ở đường này, nên chứng chỉ Apple Development hay Developer ID đều được. Sparkle vẫn chặn bản có số build (`CFBundleVersion`) nhỏ hơn bản đang cài (`-[SUPlainInstaller performInitialInstallation:]`).

Tài liệu Sparkle, mục "Rotating signing keys", nói cùng luật: với bản cập nhật dạng app có cả chữ ký mã lẫn EdDSA, Sparkle cho đổi chứng chỉ ký mã hoặc khoá EdDSA trong một bản, nhưng không cho đổi cả hai. Tài liệu khuyên chỉ xoay khi cần, ví dụ khi phải đổi chứng chỉ Developer ID [Tài liệu Sparkle].

Đường dự phòng "Developer ID cùng Team ID" (`+[SUCodeSigningVerifier codeSignatureIsValidAtDownloadURL:andMatchesDeveloperIDTeamFromOldBundleURL:error:]`) chỉ chạy khi app khai `SUVerifyUpdateBeforeExtraction`. Đường này dùng khi mất khoá EdDSA và đòi cùng Team ID với bản cũ, nên không giúp được Dấu khi đổi team. Dấu giữ khoá EdDSA (`docs/Releasing.md`, mục "Chuyển sang Developer ID"), nên không cần đường này [Mã Sparkle].

### 1.2 Kết nối XPC giữa các tiến trình của Sparkle

Trình cài (`Autoupdate`), tác tử tiến trình (`Updater.app`) và các dịch vụ XPC của Sparkle kiểm tiến trình nối vào bằng yêu cầu `anchor apple generic and certificate leaf[subject.OU] = "<Team ID của chính nó>"` (`+[SUCodeSigningVerifier validateConnection:error:]`). Chứng chỉ Apple Development thoả `anchor apple generic`, vì Apple cấp nó. App chủ không sandbox chạy trình cài và tác tử lấy từ Sparkle.framework của **bản đang cài** (`SUInstallerLauncher`), nên trong lần chuyển, cả hai phía của kết nối đều mang Team ID cũ [Mã Sparkle]. Không tiến trình team B nào nối vào trình cài trong lần đó [suy luận, cần kiểm chứng].

### 1.3 Notarize và chữ ký Apple Development

Trong mã Sparkle 2.10.1 không có bước nào kiểm notarize, gọi `spctl` hay đòi chứng chỉ Developer ID cho bản cập nhật [Mã Sparkle]. Tài liệu Sparkle khuyên ký Developer ID và notarize "nếu có thể". Tài liệu cũng nói app bật Library Validation phải ký bằng chứng chỉ Apple Development khi phát triển để nạp được Sparkle.framework [Tài liệu Sparkle]. Tài liệu không cấm phát hành bản ký Apple Development. Mục "Test Sparkle out" có lưu ý rằng một số luật ký mã có thể không có hiệu lực hay không thử được khi cập nhật từ bản chưa notarize hay sang bản chưa notarize. Lưu ý đó là một lý do để lượt chạy chuyển sang Developer ID (mục 1.5) chạy trên máy thật.

### 1.4 Quarantine, Gatekeeper và cách thay bundle

- **Gỡ quarantine:** trước khi đặt bản mới vào chỗ, `-[SUPlainInstaller _performInitialInstallationWithFileManager:…]` gỡ `com.apple.quarantine` khỏi mọi tệp của bản mới. Lỗi ở bước này chỉ ghi log, không dừng việc cài. Sparkle cũng gỡ quarantine khỏi `Updater.app` trước khi chạy nó [Mã Sparkle].
- **Tệp tải về:** Sparkle tải bằng `NSURLSession` trong tiến trình app chủ. Theo Apple, khoá `LSFileQuarantineEnabled` quyết định tệp do app tạo ra có mang quarantine theo mặc định không. App chủ của Dấu không khai khoá đó và không sandbox (D37), nên DMG tải về không mang quarantine [Apple; suy luận, cần kiểm chứng].
- **Mở lại sau khi cài:** app không mang quarantine thì Gatekeeper không hỏi ở lần mở đầu. Apple tả Gatekeeper là bước xin người dùng cho phép trước lần đầu mở phần mềm tải về [Apple]. Số đo đã có khớp với điều này: trên một máy Intel chạy macOS 15.8.1, bản Release ký Apple Development cài từ DMG không mang quarantine mở và chạy được ([`docs/research/InputMethodInstall.md`](InputMethodInstall.md) mục 1.2).
- **Quét Gatekeeper trước:** khi trình cài và bản mới cùng Team ID, Sparkle chạy `/usr/bin/gktool scan` trên bản mới (từ macOS 14.4) để bỏ hộp thoại "Verifying…" lúc mở. Lỗi của `gktool` chỉ ghi log [Mã Sparkle]. Với bản Personal Team chưa notarize, `gktool scan` trả gì và có để lại dấu nào làm Gatekeeper chặn lần mở sau không thì chưa biết [suy luận, cần kiểm chứng].
- **Khi Team ID đổi:** từ macOS 13, nếu trình cài (Team ID cũ) và bản mới khác Team ID, Sparkle bỏ lần đổi chỗ nguyên tử và bỏ `gktool scan`. Comment của Sparkle nói lý do: macOS có thể hiện câu hỏi Privacy & Security vì tưởng Sparkle đang sửa bản mới. Bản mới khai `NSUpdateSecurityPolicy` thì Sparkle cũng bỏ đổi chỗ nguyên tử. Dấu không khai khoá này [Mã Sparkle].
- **Chạy từ chỗ ngẫu nhiên:** app đang chạy theo App Translocation (đường dẫn có `/AppTranslocation/`) thì Sparkle từ chối cập nhật và nhắc chuyển app vào Applications (`-[SUHost isRunningTranslocated]`) [Mã Sparkle].

### 1.5 Cần chạy thật

- Lượt cập nhật giữa hai bản thử cùng Personal Team (kế hoạch M7 bước 4, ý 2) cho biết ba điều. Thứ nhất là DMG Sparkle tải về có mang quarantine không. Thứ hai là bản mới có mở lại mà không qua Gatekeeper không. Thứ ba là `gktool scan` ghi gì trong log của Sparkle.
- Beta chuyển sang Developer ID (`docs/Roadmap.md`, mục "Chuyển sang Developer ID") cho biết hai điều: Sparkle có nhận bản team B như mục 1.1 suy ra không và macOS có hỏi quyền App Management không.

## 2. Homebrew 7.0.16

### 2.1 Quarantine khi cài

- Sau khi tải, `Cask::Download` gọi `Quarantine.cask!`. Bản macOS của hàm này (`extend/os/mac/cask/quarantine.rb`) gắn thuộc tính quarantine qua LaunchServices, với tên tác tử "Homebrew Cask", URL tải và trang chủ của cask. Tệp nào đã mang quarantine thì giữ nguyên [Mã Homebrew].
- Khi giải nén, `Quarantine.propagate` chép quarantine của tệp tải về lên mọi tệp giải nén ra. Hàm này bật thêm bit 0x0100 để macOS không chạy app theo App Translocation. Khi chuyển app vào `/Applications`, Homebrew chép cả thuộc tính mở rộng (`cask/artifact/moved.rb`) [Mã Homebrew].
- Vậy Dấu.app cài bằng `brew` mang quarantine, kể cả bộ gõ nhúng bên trong. App chủ đã gỡ quarantine khỏi bộ gõ trước khi đặt vào `~/Library/Input Methods` (D37), nên phần đó không đổi.
- Tài liệu Homebrew nói Homebrew gắn quarantine lên tệp cask tải về để Gatekeeper làm phần kiểm của nó thay vì Homebrew đi vòng qua (`docs/Homebrew-Security-and-Supply-Chain.md`) [Mã Homebrew].

### 2.2 `--no-quarantine`

Lịch sử git của Homebrew cho thấy bốn bước. Bản 4.6.19 (27/10/2025) ẩn tuỳ chọn khỏi trợ giúp. Bản 5.0.0 (12/11/2025) đánh dấu bỏ dùng (`odeprecated`). Bản 5.1.0 (11/03/2026) tắt nó (`odisabled`). Bản 6.0.0 (11/06/2026), commit `bc44e3d019` "Homebrew 6 deprecations", xoá hẳn `--[no-]quarantine` khỏi `brew install`. Commit `ba25213c81` (30/07/2026) xoá phần mã còn sót. `brew install --help` của bản 7.0.16 không còn chữ "quarantine" [Mã Homebrew]. Thông báo của bản 5.0.0 nói Homebrew không muốn cho cách dễ để đi vòng qua bảo mật của macOS [brew.sh].

Vì vậy hướng dẫn cho người dùng không được nhắc `--no-quarantine`. Người dùng cũng không nên được hướng dẫn tự gỡ quarantine bằng `xattr`, vì đó là đi vòng qua Gatekeeper.

### 2.3 Kiểm Gatekeeper và chính sách

- Lúc `brew install` hay `brew upgrade`, Homebrew không gọi `spctl`, `gktool` hay `codesign`. Homebrew không từ chối hay cảnh báo app chưa notarize [Mã Homebrew].
- Phép kiểm Gatekeeper duy nhất nằm trong `brew audit` (`Cask::Audit#audit_signing`, dùng `gktool scan` và `codesign --check-notarization`). Phép kiểm này bỏ qua tap không chính thức, trừ khi gọi `brew audit --signing` [Mã Homebrew].
- Thông báo Homebrew 5.0.0 nói cask không có chữ ký đã bị bỏ dùng và mọi cask của `Homebrew/homebrew-cask` không qua Gatekeeper sẽ bị tắt vào tháng 9/2026. Thông báo 6.0.0 nhắc lại mốc đó. Cả hai chỉ nói về `homebrew/cask` [brew.sh]. Tài liệu `docs/Acceptable-Casks.md` và `docs/FAQ.md` của Homebrew cũng chỉ áp luật Gatekeeper cho cask chính thức [Mã Homebrew].
- Hệ quả cho D6: tap riêng nhận được cask của bản Personal Team. Muốn vào `homebrew/cask` thì cask phải qua Gatekeeper, tức bản phát hành đã ký Developer ID và notarize.
- Với `brew upgrade --greedy` (cask khai `auto_updates true` nên `brew upgrade` thường không nâng), Homebrew coi app cũ là đã được phép mở khi app đó không mang quarantine (chẳng hạn vì Sparkle đã thay nó) hoặc khi người dùng đã cho phép nó. Khi đó Homebrew so yêu cầu chỉ định của app cũ với app mới. Khớp thì Homebrew chép dấu "người dùng đã cho phép" sang app mới. Không khớp, chẳng hạn khi Personal Team đổi sang Developer ID, thì Homebrew in "dau's signer changed so macOS may prompt at next launch." và app mới giữ quarantine (`Cask::Upgrade.quarantine_release_decision`) [Mã Homebrew].

### 2.4 Cask nên khai gì

- Giữ stanza `app` là artifact duy nhất (D37) và `auto_updates true` (D6).
- Thêm `caveats` dạng chuỗi tả bước Gatekeeper lần đầu, kèm liên kết tới trang tải về. Homebrew in caveats sau khi cài xong và trong `brew info`. Danh sách caveat dựng sẵn (`kext`, `unsigned_accessibility`, `requires_rosetta`, `logout`…) không có mục nào cho Gatekeeper (`cask/dsl/caveats.rb`) [Mã Homebrew]. Nhãn trong caveats phải là nhãn đã thấy trên màn hình (D38 (Chữ trên giao diện), N5 (Chỉ hứa điều đã kiểm chứng)). Khi bản phát hành đã notarize, bỏ caveats này.
- Không dùng `deprecate!` hay `disable!` với `because: :fails_gatekeeper_check`. `deprecate!` in cảnh báo mỗi lần cài, còn `disable!` làm lệnh cài báo lỗi (`cask/dsl.rb`) [Mã Homebrew].

## 3. Gatekeeper trên macOS 15 trở lên

### 3.1 Luồng chính thức

- Thông báo của Apple ngày 6/8/2024: trên macOS Sequoia, người dùng không còn Control-click để vượt Gatekeeper khi mở phần mềm ký sai hay chưa notarize. Họ phải vào System Settings › Privacy & Security để xem thông tin bảo mật rồi mới cho phép chạy [Apple].
- Trang hỗ trợ "Safely open apps on your Mac" tả các bước như sau. Người dùng thử mở app trước. Sau đó họ mở System Settings, chọn Privacy & Security, cuộn xuống và bấm "Open Anyway". Hộp thoại cảnh báo hiện lại. Nếu chắc chắn, họ bấm Open [Apple].
- Trang mh40616 của Hướng dẫn sử dụng Mac (trang đang chọn macOS 27) thêm hai ý. Mã trang này trùng với khoá `Q_HELP_ANCHOR_UNIDENTIFIED` trong tệp chuỗi của Gatekeeper (mục 3.2). Nút "Open Anyway" chỉ có trong khoảng một giờ sau lần thử mở. Bước cuối là nhập mật khẩu đăng nhập rồi bấm OK. Sau đó app được ghi thành ngoại lệ và mở bằng nhấp đúp như thường [Apple].
- Gatekeeper mặc định chỉ cho mở phần mềm của App Store, hoặc phần mềm mà nhà phát triển đăng ký với Apple đã ký và Apple đã notarize (Apple Platform Security). Chứng chỉ Apple Development không phải Developer ID, nên bản Personal Team rơi vào nhánh bị chặn [Apple].

### 3.2 Chuỗi trên máy này

Mọi chuỗi dưới đây **đọc từ tệp**; chuỗi nào đã thấy trên màn hình ghi ở mục 3.3. Máy chạy macOS 27.2.1 (26B131). Các tệp `.loctable` là plist nhị phân chứa mọi ngôn ngữ; lệnh đọc là `plutil -convert json -o - <tệp>`, rồi lấy khoá trong `.en` và `.vi`. `%@` thứ nhất là tên app, `%@` thứ hai (nếu có) là tên trên chứng chỉ.

Hộp thoại chặn lần mở đầu nằm ở `/System/Library/CoreServices/CoreServicesUIAgent.app/Contents/Resources/`. Tệp không cho biết hộp thoại ghép khoá nào với khoá nào, nên dưới đây là hai bộ ứng viên.

Bộ chung cho app chưa notarize:

| Tệp | Khoá | Tiếng Anh | Tiếng Việt |
|---|---|---|---|
| `QuarantineHeadlines.loctable` | `Q_HEADLINE_SUNFISH_NOT_VERIFIED` | “%@” Not Opened | “%@” chưa được mở |
| `Quarantine.loctable` | `Q_DETAIL_CASPIAN_UNVERIFIED` | Apple could not verify “%@” is free of malware that may harm your Mac or compromise your privacy. | Apple không thể xác minh rằng “%@” không chứa phần mềm độc hại có thể gây hại cho máy Mac hoặc xâm phạm quyền riêng tư của bạn. |
| `Quarantine.loctable` | `Q_BUTTON_DONE` | Done | Xong |
| `Quarantine.loctable` | `Q_BUTTON_MOVE_TO_TRASH` | Move to Trash | Chuyển vào Thùng rác |

Bộ riêng cho app ký bằng tài khoản phát triển miễn phí. "FREE_DEV" trong tên khoá là cách hiểu của nghiên cứu này, Apple không có tài liệu:

| Tệp | Khoá | Tiếng Anh | Tiếng Việt |
|---|---|---|---|
| `QuarantineHeadlines.loctable` | `Q_HEADLINE_SUNFISH_UNTRUSTED_FREE_DEV` | “%@” is for personal testing purposes by “%@”. | “%@” dùng cho các mục đích thử nghiệm cá nhân bởi “%@”. |
| `Quarantine.loctable` | `Q_DETAIL_SUNFISH_UNTRUSTED_FREE_DEV` | This app is for personal testing only. If you want to enable this app, open Privacy & Security settings. | Ứng dụng này chỉ dành cho mục đích thử nghiệm cá nhân. Nếu bạn muốn bật ứng dụng này, hãy mở cài đặt Quyền riêng tư & Bảo mật. |
| `Quarantine.loctable` | `Q_DETAIL_SUNFISH_UNTRUSTED_FREE_DEV_ALT` | This app is for personal testing purposes and should only be used if you are the author. macOS cannot verify that this app is free from malware. | Ứng dụng này được dùng cho các mục đích thử nghiệm cá nhân và chỉ nên được sử dụng nếu bạn là tác giả. macOS không thể xác minh rằng ứng dụng này không bị nhiễm phần mềm độc hại. |

Cùng tệp có hai bộ tương tự cho bản thử ad hoc (`…_ADHOC_DEV`) và bản phân phối nội bộ doanh nghiệp (`…_ENTERPRISE_DEV`). Khoá `Q_HEADLINE_CASPIAN_WHITELISTED` ("“%@” is from an unidentified developer. Are you sure you want to open it?") thuộc luồng Control-click trước macOS 15.

Trang Privacy & Security nằm ở `/System/Library/ExtensionKit/Extensions/SecurityPrivacyExtension.appex/Contents/Resources/`. Tên trang lấy từ `InfoPlist.loctable`, còn mọi chuỗi khác lấy từ `Localizable.loctable`. Khoá của tệp này chính là câu tiếng Anh:

| Khoá | Tiếng Anh | Tiếng Việt |
|---|---|---|
| `CFBundleDisplayName` (`InfoPlist.loctable`) | Privacy & Security | Quyền riêng tư & Bảo mật |
| `Security` | Security | Bảo mật |
| `Allow applications from` | Allow applications from | Cho phép các ứng dụng từ |
| `App Store & Known Developers` | App Store & Known Developers | App Store & Nhà phát triển đã biết |
| `“%@” was blocked to protect your Mac.` | “%@” was blocked to protect your Mac. | “%@” đã bị chặn để bảo vệ máy Mac của bạn. |
| `Open Anyway` | Open Anyway | Vẫn mở |

Bảng chỉ có các chuỗi của trang Privacy & Security mà người dùng nhìn qua. Trang hỗ trợ của Apple gọi lựa chọn mặc định là "App Store and identified developers", còn tệp của macOS 27.2.1 có "App Store & Known Developers". Trang hướng dẫn cho người dùng phải theo nhãn đã thấy trên màn hình (D38).

Hộp thoại xác nhận sau khi bấm "Open Anyway" và lời xin mật khẩu cũng nằm trong `CoreServicesUIAgent.app`:

| Tệp | Khoá | Tiếng Anh | Tiếng Việt |
|---|---|---|---|
| `QuarantineHeadlines.loctable` | `Q_HEADLINE_SUNFISH_NOT_VERIFIED_ALLOW` | Open “%@”? | Mở “%@”? |
| `Quarantine.loctable` | `Q_DETAIL_CASPIAN_ALLOW_UNVERIFIED` | Apple is not able to verify that it is free from malware that could harm your Mac or compromise your privacy. Don’t open this unless you are certain it is from a trustworthy source. | Apple không thể xác minh rằng mục này không chứa phần mềm độc hại có thể gây hại cho máy Mac hoặc xâm phạm quyền riêng tư của bạn. Không mở mục này trừ khi bạn chắc chắn rằng mục này đến từ một nguồn đáng tin cậy. |
| `CodeEvaluation.loctable` | `OPEN_ANYWAY_BUTTON` | Open Anyway | Vẫn mở |
| `Quarantine.loctable` | `Q_BUTTON_OPEN` | Open | Mở |
| `CodeEvaluation.loctable` | `DONE_BUTTON` | Done | Xong |
| `Quarantine.loctable` | `Q_OVERRIDE_AUTH_NAME` | Privacy & Security | Quyền riêng tư & Bảo mật |
| `Quarantine.loctable` | `Q_OVERRIDE_AUTH_EXPLANATION` | You are attempting to open an app that may cause harm to your Mac or compromise your privacy | Bạn đang cố gắng mở một ứng dụng có thể gây hại cho máy Mac hoặc xâm phạm quyền riêng tư của bạn |

Nút xác nhận là "Open Anyway" hay "Open" thì tệp không cho biết. Trang hỗ trợ của Apple viết "click Open".

### 3.3 Đã thấy trên màn hình (28/11/2026, macOS 27.2.1, máy M3 Max, macOS để tiếng Anh)

Lượt chạy ở bước 4 của kế hoạch M7 cài bản thử `v0.0.1-beta.1` từ DMG tải bằng Safari (quarantine `0083;…;Safari;…`).

- **DMG ký Apple Development mà không notarize bị chặn ngay lúc mở ổ đĩa.** Hộp thoại là bộ chung: "“Dau-0.0.1-beta.1.dmg” Not Opened", "Apple could not verify “Dau-0.0.1-beta.1.dmg” is free of malware that may harm your Mac or compromise your privacy.", nút "Move to Trash" và "Done". Cùng ảnh đĩa chuyển sang dạng không ký (`hdiutil convert -format ULFO`), mang cùng quarantine, mở ngay không hộp thoại nào. Vì vậy đường Personal Team không ký DMG (`docs/Releasing.md`).
- **Mở Dấu.app lần đầu:** hộp thoại dùng bộ chung, không dùng bộ `…_UNTRUSTED_FREE_DEV`: "“Dấu” Not Opened", "Apple could not verify “Dấu” is free of malware that may harm your Mac or compromise your privacy.", nút "Move to Trash" và "Done".
- **Hộp thoại xác nhận** sau khi bấm "Open Anyway" trong Privacy & Security: "Open “Dấu”?", câu trong bảng trên (`Q_DETAIL_CASPIAN_ALLOW_UNVERIFIED`), ba nút "Move to Trash", "Open Anyway" và "Done".
- **Xác thực:** "You are attempting to open an app that may cause harm to your Mac or compromise your privacy", "Touch ID or enter an administrator’s name and password to continue with Privacy & Security.", nút "Use Password…" và "Cancel". Touch ID dùng được.
- Câu báo chặn và nút trong trang Privacy & Security chưa chụp được; bảng trên là chuỗi đọc từ tệp. Bản tiếng Việt của mọi hộp thoại chưa thấy trên màn hình; chuỗi tiếng Việt trong bảng là của chính macOS.
- **App Translocation:** chép Dấu.app từ ổ DMG sang Applications bằng lệnh `duplicate` của Finder qua AppleScript thì app vẫn chạy qua App Translocation, và Sparkle từ chối cập nhật ("Không thể cập nhật Dấu nếu ứng dụng đang chạy từ vị trí mà nó đã được tải xuống…"). Kéo thả bằng tay trong Finder thì app chạy thẳng từ `/Applications` và Sparkle cập nhật được. Script tự động cài từ DMG phải kéo thả thật hoặc gỡ quarantine, không dùng `duplicate`.
- **Sparkle sau khi cập nhật:** bản mới chạy từ `/Applications`, không còn quarantine, không có hộp thoại Gatekeeper nào (mục 1.4 đúng với lượt chạy này).
- Chưa thử cài bằng `brew install --cask`; việc này ở bước 8 của kế hoạch M7.

## 4. Bảo vệ thư mục App Group (macOS 15 trở lên)

- macOS 15 thêm cơ chế bảo vệ thư mục App Group. Theo bài của Apple DTS "App Groups: macOS vs iOS: Working Towards Harmony" (cập nhật 12/8/2025), app truy cập thư mục group mà không cần người dùng can thiệp khi đủ hai điều kiện. Điều kiện thứ nhất là app khai ID group trong entitlement App Groups và tìm thư mục bằng `containerURL(forSecurityApplicationGroupIdentifier:)`. Điều kiện thứ hai là app thoả một trong bốn tiêu chí: app phát qua Mac App Store, app phát qua TestFlight trên macOS 15.1 trở lên, ID group bắt đầu bằng Team ID của chính app, hoặc provisioning profile nhúng trong app cho phép group đó. Không thoả thì hệ thống hỏi người dùng. Quyền họ cho chỉ giữ trong lần chạy đó của app [Apple DTS].
- Cùng bài đó nói code không sandbox về kỹ thuật không cần khai group trong entitlement. Tuy vậy, từ macOS 15, truy cập thư mục group vẫn cần entitlement vì cơ chế bảo vệ này [Apple DTS].
- Trả lời một câu hỏi tháng 10/2024, Apple DTS nói trước macOS 15 không có gì ngăn một app không sandbox đọc tệp trong bất kỳ thư mục group nào. Câu đó cho thấy cơ chế bảo vệ áp cả cho app không sandbox [Apple DTS, thread 766275].
- Trả lời tháng 1/2026, Quinn (Apple DTS) nói không có câu hỏi này khi mọi app truy cập group cùng một team. Khi app truy cập group của team khác thì không có cách tránh. Quyền người dùng cho chỉ giữ tới hết tiến trình gọi, không cho vĩnh viễn được [Apple DTS, thread 808923].
- Câu hỏi đó là dịch vụ TCC `kTCCServiceSystemPolicyAppData`. Trong `/System/Library/PrivateFrameworks/TCC.framework/Resources/Localizable.loctable`, khoá `REQUEST_ACCESS_SERVICE_kTCCServiceSystemPolicyAppData` là "“%@” would like to access data from other apps." (tiếng Việt: "“%@” muốn truy cập vào dữ liệu từ các ứng dụng khác.") [đọc từ tệp, chưa thấy trên màn hình].

Áp vào D24 và D7: bản Personal Team dùng group `M58DANM3ZP.com.codefastlabs.dau.shared`, bắt đầu bằng Team ID của chính nó, nên không có câu hỏi. Số đo của D24 khớp với điều này. Bản ký Developer ID (team mới) đọc group `M58DANM3ZP.…` thì trượt cả bốn tiêu chí, nên macOS sẽ hỏi mỗi lần app chạy. Câu hỏi đó trái ý "Không cài ngầm" của D7, vì người dùng thấy một hộp thoại về dữ liệu của "app khác" ngay sau bản cập nhật. Thiết kế tránh được câu hỏi như sau. Bản còn ký Personal Team chép cài đặt vào defaults riêng của app chủ (miền `com.codefastlabs.dau`, theo bundle ID, không theo Team ID). Bản ký Developer ID đọc từ defaults đó rồi ghi vào group mới. Thiết kế này dựa trên nguồn, chưa đo việc macOS hỏi khi đọc group của team khác [suy luận, cần kiểm chứng].

## 5. Hệ quả cho đường chuyển sang Developer ID

- **App chủ:** Sparkle xử lý việc đổi Team ID (mục 1.1, 1.4). Trình cài team cũ thay bundle team cũ, nên luật "cùng team được sửa nhau" của macOS không bị vi phạm. Các bản cập nhật sau đó do trình cài team mới thay bundle team mới [Mã Sparkle; Apple].
- **Bộ gõ đã cài (D37, ý "Danh tính phát hành trước"):** tại phiên WWDC22 "What's new in privacy", Apple nói từ macOS Ventura, Gatekeeper ngăn app bị sửa theo một số cách. Các app mà cùng một team đã ký hợp lệ vẫn cập nhật được cho nhau. Việc sửa từ code của team khác mà `NSUpdateSecurityPolicy` của app bị sửa không cho phép thì bị chặn. Khi đó macOS báo người dùng rằng một app muốn quản lý app khác. Phiên đó nói về app đã notarize [Apple]. Sau khi chuyển, app chủ team mới đổi chỗ bundle `DauInputMethod.app` ký Personal Team. Bộ gõ đó chưa notarize. D37 thay cả khối bằng một lần đổi tên chứ không ghi vào bên trong bundle. Lần thay có bị chặn hay hỏi quyền không thì chưa rõ [suy luận, cần kiểm chứng].
- **Cách phòng nếu bị chặn:** bản Personal Team cuối cùng trước khi chuyển có thể nhúng bộ gõ khai `NSUpdateSecurityPolicy` › `AllowProcesses`, ánh xạ Team ID mới tới bundle ID `com.codefastlabs.dau`. Cách này cần biết Team ID mới trước beta đó. Đây là đề xuất, chưa phải quyết định.
- **Homebrew:** người cài bằng `brew` lúc còn Personal Team nhận bản Developer ID qua Sparkle, nên không gặp lại Gatekeeper. Người chạy `brew upgrade --greedy` gặp cảnh báo đổi người ký của Homebrew. Lần mở đầu của bản đó đi qua Gatekeeper, nhưng lúc đó bản phát hành đã notarize (mục 2.3).

## Nguồn

- Sparkle, tag `2.10.1` (commit `ab7d71291238df6e0492143b120c9b696a35f603`): `Sparkle/SUUpdateValidator.m`, `Autoupdate/SUCodeSigningVerifier.m`, `Autoupdate/SUPlainInstaller.m`, `Autoupdate/AppInstaller.m`, `Autoupdate/AgentConnection.m`, `InstallerLauncher/SUInstallerLauncher.m`, `Sparkle/SUFileManager.m`, `Sparkle/SPUUpdater.m`, `Sparkle/SPUInstallerDriver.m`, `Sparkle/SUHost.m`, `Documentation/Security.md`, `CHANGELOG`: https://github.com/sparkle-project/Sparkle/tree/2.10.1
- Sparkle, Documentation (mục "Segue for security concerns", "Rotating signing keys", "Test Sparkle out"): https://sparkle-project.org/documentation/
- Homebrew 7.0.16, mã trong `Library/Homebrew/`: `cask/quarantine.rb`, `extend/os/mac/cask/quarantine.rb`, `cask/download.rb`, `cask/artifact/moved.rb`, `cask/upgrade.rb`, `cask/audit.rb`, `cask/dsl.rb`, `cask/dsl/caveats.rb`, `deprecate_disable.rb`; tài liệu trong `docs/`: `Homebrew-Security-and-Supply-Chain.md`, `Acceptable-Casks.md`, `FAQ.md`, `Deprecating-Disabling-and-Removing.md`. Lịch sử của `--no-quarantine`: commit `bc44e3d019`, `ba25213c81`, các tag 4.6.19, 5.0.0, 5.1.0, 6.0.0. Mã nguồn: https://github.com/Homebrew/brew/tree/7.0.16
- Homebrew 5.0.0: https://brew.sh/2025/11/12/homebrew-5.0.0
- Homebrew 6.0.0: https://brew.sh/2026/06/11/homebrew-6.0.0/
- Apple, Updates to runtime protection in macOS Sequoia (6/8/2024): https://developer.apple.com/news/?id=saqachfa
- Apple Support, Safely open apps on your Mac: https://support.apple.com/en-us/102445
- Apple, Mac User Guide, Open a Mac app from an unknown developer: https://support.apple.com/guide/mac-help/open-a-mac-app-from-an-unknown-developer-mh40616/mac
- Apple Platform Security, Gatekeeper and runtime protection in macOS: https://support.apple.com/guide/security/gatekeeper-and-runtime-protection-sec5599b66df/web
- Apple, WWDC22 "What's new in privacy" (phần Gatekeeper và `NSUpdateSecurityPolicy`): https://developer.apple.com/videos/play/wwdc2022/10096/
- Apple, `NSUpdateSecurityPolicy`: https://developer.apple.com/documentation/bundleresources/information-property-list/nsupdatesecuritypolicy
- Apple, `LSFileQuarantineEnabled`: https://developer.apple.com/documentation/bundleresources/information-property-list/lsfilequarantineenabled
- Apple, `containerURL(forSecurityApplicationGroupIdentifier:)`: https://developer.apple.com/documentation/foundation/filemanager/containerurl(forsecurityapplicationgroupidentifier:)
- Apple DTS, App Groups: macOS vs iOS: Working Towards Harmony: https://developer.apple.com/forums/thread/721701
- Apple DTS, File access popups with shared containers on Sequoia: https://developer.apple.com/forums/thread/766275
- Apple DTS, câu hỏi về "would like to access data from other apps" mỗi lần mở: https://developer.apple.com/forums/thread/808923
- macOS 27.2.1 (26B131), tệp chuỗi trên máy phát triển: `/System/Library/CoreServices/CoreServicesUIAgent.app/Contents/Resources/{Quarantine,QuarantineHeadlines,CodeEvaluation}.loctable`, `/System/Library/ExtensionKit/Extensions/SecurityPrivacyExtension.appex/Contents/Resources/{Localizable,InfoPlist}.loctable`, `/System/Library/PrivateFrameworks/TCC.framework/Resources/Localizable.loctable`.
