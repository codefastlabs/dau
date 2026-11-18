# Tiến độ

Nhật ký điều phối, để phiên sau (hoặc sau khi ngữ cảnh bị nén) tiếp tục đúng chỗ. Phiên chính cập nhật "Trạng thái hiện tại" và kế hoạch mốc sau mỗi bước; nhật ký chỉ ghi theo luật ở [`CLAUDE.md`](../CLAUDE.md), mục "Nguồn chuẩn".

## Trạng thái hiện tại

M6 (Hiệu năng dưới tải) đóng 16/11/2026, kiểm toán ĐẠT. M7 (Phát hành) đang làm từ 17/11/2026, theo mục "Kế hoạch M7" bên dưới.

Chờ người dùng:
- Bước 0 của kế hoạch M7: đăng ký Apple Developer Program trước tiên (việc lâu nhất).

Việc tiếp theo:
- Bước 2 của kế hoạch M7, khi bước 0 xong (bước 1 xong 17/11).
- Không chờ bước 0: tìm cách sửa Google Docs và chẩn đoán bốn lỗi gõ sai chữ còn lại ở Việc mở (WebStorm, Safari, Cursor, trang bận khi phím dồn), chuẩn bị offline rồi gộp vào một lượt chạy chiếm màn hình, xin giờ một lần; nhãn trợ năng của sheet thêm quy tắc sửa offline.

Việc mở, xếp theo ảnh hưởng tới chữ gõ ra (sai chữ, rồi chưa rõ ảnh hưởng, chưa kiểm, giao diện, để sau):
1. Google Docs (Chrome, Safari): Dấu sai cả chữ gõ liền và không thêm dấu được cho từ đã gõ (D20), 3/3 lượt, trong khi Telex của Apple gõ đúng chữ gõ liền. Nguyên nhân đo được: Google Docs trả vị trí con trỏ luôn là `(1, 0)` ở cả Chrome và Safari, nên Dấu chỉ thay được một ký tự (`docs/Compatibility.md` mục 5.10). Không có đường nào chỉ dùng API chính thức để thay quá một ký tự; sửa nhiều bước trong cửa sổ một ký tự đã đo, không được (`docs/research/WebEditorInput.md` mục 10). Bước kế: chọn hướng với người dùng; còn một phép đo: chế độ hỗ trợ chữ nổi của Google Docs (⌘⌥H, cài đặt trong tài khoản Google của người dùng, cần họ đồng ý; kể cả khi được, đó là cách vòng cho người dùng tự bật, chưa phải cách sửa trong Dấu).
2. Trình soạn thảo WebStorm mất khôi phục D4 ở mọi nhịp gõ, vì Dấu bị reset sau mỗi phím đi thẳng (`docs/Compatibility.md` mục 5.9). Bước kế: ghi log ở `commitComposition` và `deactivateServer`, chạy lại ô `webstorm` một lượt (`docs/research/JetBrainsInput.md` mục 5).
3. Safari ở lần thay đầu của tài liệu mới: Safari trả vị trí chậm, từ đầu hỏng (5 ms, 1/3 lượt sai; `docs/Compatibility.md` mục 5.1, 7). Cần chẩn đoán theo CLAUDE.md (nhiều giả thuyết, đối chứng, ít nhất ba lượt).
4. Trình soạn thảo Cursor 3.30.14 có lúc trả vị trí từ đầu từ, khi đó chuỗi `edit` gõ cách nhau 5 ms sai vài từ (`docs/Compatibility.md` mục 5.4). Bước kế: tìm điều kiện làm trình soạn thảo đổi kiểu vị trí (buổi sáng tính từ đầu văn bản, buổi chiều từ đầu từ), rồi chọn hướng sửa ở `docs/research/LateAnswerFixes.md` kịch bản B.
5. Chrome và Safari khi trang bận: thay tại chỗ sai, ở nhịp 5–20 ms 18/18 và ở nhịp người gõ nhanh (40 ± 20 ms, nghỉ 150 ms sau mỗi từ) 4/6, trong khi Telex của Apple đúng (`docs/Compatibility.md` mục 5.1, 5.2). Ở 100 ± 30 ms thì đúng (M6). Chrome: sửa phần lớn ở `d171ab9` (ở nhịp người gõ nhanh còn sai 2/6 lượt, trước là 4/6; `docs/research/LateAnswerFixes.md` mục 3.3). Còn lại: phép chứng minh không qua ở từ có chuỗi thay phức tạp ("được") dù app chỉ chậm một thao tác; Safari: chưa rõ (phím dồn, vị trí vượt); kiểu dồn phím này tái hiện được ở trang rảnh khi gửi cả chuỗi một lần (Dấu thay tại chỗ sai 3/3, Dấu gạch chân và Telex của Apple đúng chữ; `docs/Compatibility.md` mục 5.1), một ô rẻ hơn trang bận để chẩn đoán.
6. Sau khi cài lại bộ gõ, app đang có ô nhập không gửi `activateServer` cho tiến trình bộ gõ mới: phím vẫn được xử lý nhưng bộ gõ không biết app (`app=?` trong log), nên quy tắc theo app (D5) và log theo app không áp tới lần kích hoạt sau (17/11, 2/2 lần ngay sau `scripts/dev/install-app.sh`, Safari và Chrome). Ảnh hưởng khi Sparkle cập nhật: chưa đo.
7. Bộ đệm nguồn đầu vào của các app: tiến trình trong thư mục cache được hệ thống bảo vệ (WebKit, Shortcuts) không xoá được, ảnh hưởng chưa đo; gỡ cài đặt chưa xoá bộ đệm của các app (`docs/research/InputMethodInstall.md` mục 10.7).
8. Chưa chạy qua script: nhánh "đã trùng sẵn" và các nhánh lỗi của việc thay bộ gõ. `scripts/selftest/app-group.sh --install` chưa chạy lại kể từ khi gộp script cài 10/11. Chưa kiểm: VoiceOver, cờ `--tampered` trên cửa sổ thật.
9. Chưa có artboard: tên các nguồn tiếng Việt khác trong ghi chú của D14 (Onboarding) vẫn theo tiếng Việt của app (`LayoutNames` chỉ có bàn phím).
10. Sheet thêm quy tắc: ba nút cuối không có nhãn trợ năng (/dogfood 11/11; chưa kiểm bằng VoiceOver).
10. Ma trận tương thích còn lại, làm sau beta đầu tiên: `docs/Roadmap.md` mục "Tồn đọng chưa gắn mốc", danh sách ở `docs/Compatibility.md` mục 7.

## Mốc

| Mốc | Trạng thái | Kiểm toán |
|---|---|---|
| M0 Khung dự án | xong | ĐẠT (29/10) |
| M1 Engine | xong | ĐẠT (29/10, lần 2) |
| M2 Bộ gõ tối thiểu | xong | ĐẠT (30/10, lần 3) |
| M3 Độ tin cậy | xong | ĐẠT (30/10, lần 3) |
| M4 App Cài đặt | xong | ĐẠT (30/10, lần 3) |
| M5 Onboarding, cài, gỡ | xong | ĐẠT (05/11) |
| M6 Hiệu năng dưới tải | xong | ĐẠT (16/11) |
| M7 Phát hành | đang làm | — |
| M8 Website | chưa | — |
| M9 Đa ngôn ngữ | phần nền (D41 (Ngôn ngữ giao diện)) và câu chữ tiếng Anh xong 06–09/11 | — |
| M10 Học cách gõ | chưa | — |

## Kế hoạch M7

Việc cần người dùng gom vào bước 0 (tài khoản, khoá, duyệt artboard) và bước 3 (một lượt chạy chiếm màn hình); phần còn lại phiên chính và subagent làm. Thứ tự: bước 1 bắt đầu ngay, không chờ gì; bước 2 chờ bước 0 (mục 1–3), 1a và bước 1f; bước 3 chờ bước 2 và 1b–1d; bước 4 chờ bước 3.

### Bước 0 — Người dùng (làm một lần, song song với bước 1)

1. Đăng ký Apple Developer Program (99 USD/năm). Đăng ký tổ chức nếu codefastlabs là pháp nhân (cần mã D-U-N-S, có thể mất vài ngày): Gatekeeper hiện "codefastlabs", khớp D7. Không phải pháp nhân thì đăng ký cá nhân, và phiên chính sửa câu "của codefastlabs" ở D7. Báo Team ID khi có.
2. Khi có tài khoản: làm theo `docs/Releasing.md` (release-eng viết ở 1a): tạo chứng chỉ Developer ID Application và khoá App Store Connect API cho notarize, sinh khoá EdDSA của Sparkle bằng một lệnh, nạp cả ba vào secret của GitHub Actions. Phiên chính không cầm khoá.
3. Vercel: nối repo với project của `dau.codefastlabs.com`, thư mục gốc theo `docs/Releasing.md` (tới M8 chỉ có `appcast.xml`).
4. Duyệt artboard (1e): xong 17/11.

### Bước 1 — Không cần ký: xong 17/11

Sparkle (chỉ bản phát hành kiểm tra cập nhật), trang Cập nhật & hỗ trợ và báo lỗi, biểu tượng Icon Composer, nền DMG, script phát hành chạy được ở chế độ không ký, GitHub Actions, `docs/Releasing.md`; entitlement của bộ gõ giữ nguyên (`docs/research/IMKAPINotes.md`). Chi tiết: commit message ngày 17/11, `docs/Releasing.md`, `docs/history/LogM7.md`.

### Bước 1f — Hai kênh Beta và Chính thức (không cần ký): xong 18/11, trừ phần chạy thật ở bước 2

Theo D7, ý "Kênh"; vòng phát hành: `docs/Releasing.md` mục "Kịch bản phát hành". Không chờ bước 0.

1. Artboard trang Cập nhật & hỗ trợ: chọn kênh Beta / Chính thức, số build trong dòng phiên bản trên mọi artboard Cài đặt và báo lỗi, bỏ dòng "Bản phát triển" (D25); Chính thức tắt kèm dòng giải thích khi appcast chưa có bản chính thức; `docs/UI.md`. Người dùng duyệt artboard trước khi viết mã.
2. App chủ (app-ui-dev): đọc tài liệu Sparkle 2.10.1 trước (delegate có đọc được các mục của appcast đã tải không, thứ tự gọi so với lúc hỏi kênh); lưu kênh, ghi kênh mặc định ở lần tải appcast thành công đầu tiên, trả kênh cho Sparkle qua delegate; chuỗi trong String Catalog (D41); test với appcast giả cho cả hai giai đoạn và cho việc đổi kênh. Cùng lượt: dòng phiên bản của bản phát hành ghi số build, báo lỗi điền sẵn ghi số build và commit (D25), sửa test của `AppVersion`. Bỏ dòng "Development build" ở trang Cập nhật & hỗ trợ của bản phát triển (D25) và chuỗi của nó trong String Catalog.
3. Script phát hành (release-eng, song song với 2): mục beta mới gắn `<sparkle:channel>beta</sparkle:channel>`; quảng bá bỏ thẻ đó khỏi mục của beta cuối; kiểm cả hai trong `check-appcast.sh` hay `check-build.sh`; `docs/Releasing.md`.

Xong khi: test và `scripts/check-l10n/check.sh` đạt; chạy thật ở bước 2 (hai tag thử: bản thứ hai cập nhật được ở kênh Beta).

### Bước 2 — Bản thử trên CI (sau bước 0)

- Workflow Test: xong 17/11, chạy trên runner `xcode-27` ở mỗi lần push lên `main`, đạt.
- Tag thử `v0.0.1-beta.1` rồi `v0.0.1-beta.2` (số hiển thị "0.0.1", nhỏ hơn beta đầu tiên; tag thứ hai trên commit sau commit appcast của bản thứ nhất) dựng hai bản phát hành số build khác nhau và công bố lên appcast (chưa có người dùng nên không ảnh hưởng ai): việc công bố cần người dùng đồng ý ở bước này, trước khi đẩy tag; beta đầu tiên thì người dùng đồng ý ở bước 4. Kiểm DMG không cần màn hình: `codesign`, `spctl`, `stapler`, biểu tượng, `nm`, dSYM (`scripts/release/check-build.sh`). Những phần chưa chạy thật lần nào: `docs/Releasing.md` mục "Còn phải thấy chạy thật".

### Bước 3 — Một lượt chạy chiếm màn hình (người dùng ngồi cùng ở mục 4)

Thời lượng: mục 1, 5, 6, 8 khoảng 15–20 phút, cộng từng mục từ số đã đo (`heavy.sh --dry-run`; các lần chạy `settings-window/run.sh`, `typing/run.sh`, `install-app.sh --ref` trong `docs/history/LogM6.md`). Mục 2, 3, 4 và phần Notion của mục 7 chưa có số đo; mỗi ô `gdocs`, `wordweb` mất 22–39 giây (17/11).

1. D42: `scripts/selftest/load/heavy.sh` với bản Debug; RSS tiến trình bộ gõ bản Release cạnh bản Debug.
2. Cài bản thử thứ nhất từ DMG (mang quarantine): Gatekeeper, hộp thoại App Group và hộp thoại bật bộ gõ với bản Developer ID (hai câu hỏi mở), onboarding, gõ thử bằng `scripts/selftest/typing/run.sh`.
3. Sparkle cập nhật lên bản thử thứ hai: kiểm câu dưới công tắc "Tự động kiểm tra bản mới" (kiểm tra khi mở Dấu, hỏi trước khi cài, D7); cài xong Sparkle mở lại Dấu và bộ gõ đã cài được thay (`scripts/dev/dau-version.sh`); gõ ngay ở một app đang mở để đo Việc mở 6 khi Sparkle cập nhật (`app=?` trong log hay không).
4. Kiểm cần người: VoiceOver và Tab qua cửa sổ Cài đặt, VoiceOver đọc tên nguồn, máy để tiếng Anh hẳn (người dùng đổi ngôn ngữ hệ thống). Phiên chính chụp và xem: biểu tượng thanh menu trên nền sáng và tối, các sheet ở chế độ tối, danh sách "+" của System Settings, nhãn biểu tượng trong cửa sổ DMG ở chế độ tối (theo báo cáo trên diễn đàn, Finder vẽ nhãn kiểu sáng khi thư mục có ảnh nền; chưa đo) và vị trí biểu tượng so với mũi tên nền.
5. Báo lỗi và trang Cập nhật & hỗ trợ (bản Debug, ma trận `scripts/selftest/settings-window/run.sh` và `docs/UIChecks.md`): hàng báo lỗi, sheet báo lỗi (độ rộng control bốn lựa chọn, Tab, Esc/Return, VoiceOver đọc ô gợi ý, chế độ tối); mở Dấu bằng "Cài đặt Dấu…" khi đang ở Chrome thì ô "Ứng dụng" chọn Chrome; "Mở trên GitHub" ra form điền sẵn (cần mẫu issue đã lên nhánh mặc định).
6. Phần còn lại của việc đo lại các ô đã đo trước khi script chuyển nguồn bằng phím tắt hệ thống (`0bf8d3f`, 10/11), theo kiểm toán ngày 17/11; Edge, Firefox, VS Code, Safari, Terminal đã đo lại 17/11 (`docs/history/LogM7.md`). Khoảng 3–4 phút (7–10 giây mỗi ô `typing/run.sh`), bản Debug, chuyển nguồn bằng phím tắt và xác nhận trong ô gõ:
   - Một ô Telex của Apple ở Chrome, trang rảnh và trang bận (câu về Apple ở D11).
   - Đếm dòng `activate` và `source-changed-reset` khi chuyển nguồn bằng phím tắt, bằng menu và bằng `⇄`. Đo thêm khi bật "Automatically switch to a document's input source" rồi đổi cửa sổ. Kết quả cho biết bộ nghe `InputSourceChange` có đường chuyển thật nào cần đến không.
7. "Thêm dấu cho từ đã gõ" (D20) trên web editor trong Chrome, bằng `scripts/selftest/typing/d20-docs.sh` (tài liệu trống của người dùng, đã đăng nhập sẵn). Word trên web và Google Docs: xong 17/11 (`docs/Compatibility.md` mục 5.10; Google Docs sai, ở Việc mở). Còn Notion: script chưa có ô cho Notion. Kết quả thay ô chờ "[Kết quả kiểm chứng trên Google Docs, Notion…]" trong câu gợi ý của D20 (N5).
8. Dọn: gỡ bản thử, cài lại bản dùng hằng ngày (`scripts/dev/install-app.sh --ref main`).

Sau lượt chạy, một lần duyệt canvas: câu gợi ý của D20 theo số đo ở mục 7, và các ô trên artboard trang tải về đang hứa quá số đo (ô "đo ở M6", ô "kiểm chứng ở M7", câu "đã kiểm chứng ở…" trong mục Hỏi đáp). Ảnh chụp `docs/canvas/` của các artboard đã sửa ở bước 1f (kênh, số build, từ ngữ) sinh lại khi người dùng duyệt. Rồi sửa mã và chụp lại `docs/canvas/`.

### Bước 4 — Phát hành và đóng mốc

- Tag `v0.1.0-beta.1`; CI dựng bản nháp. Người dùng đồng ý một lần cho cả ba việc công bố: phát hành trên GitHub, cập nhật appcast, tạo repo `codefastlabs/homebrew-tap` với cask `dau`.
- Kiểm `brew install --cask codefastlabs/tap/dau` trên máy, rồi cài lại bản dùng hằng ngày (`scripts/dev/install-app.sh --ref main`).
- Gỡ hai bản thử 0.0.1 (chỉ máy này từng cài): xoá mục của chúng khỏi `site/appcast.xml` trước, rồi xoá hai bản phát hành và tag trên GitHub; cùng lần đồng ý công bố ở trên.
- Kiểm toán, tóm tắt, chuyển nhật ký và kế hoạch M7 sang `docs/history/`.

## Nhật ký
Nhật ký M0–M4 ở `docs/history/LogM0ToM4.md` (kèm bảng số đo M1–M3), M5 ở `docs/history/LogM5.md`, 05–08/11 (giữa M5 và M6) ở `docs/history/LogBetweenM5AndM6.md`, M6 ở `docs/history/LogM6.md`. M7: phần trước ngày áp luật nhật ký (17/11) ở `docs/history/LogM7.md`; đóng M7 thì nối phần dưới vào cuối file đó.

(ngày — việc — kết quả — nơi chứa số, commit; điều gì được ghi: [`CLAUDE.md`](../CLAUDE.md), mục "Nguồn chuẩn")

- 17/11 — đo engine bản Release (`swift test -c release --filter Performance`, máy M3 Max): Telex 0,13 µs mỗi phím, VNI 0,12 µs. Một lần gọi `selectedRange` vào app tốn 230–622 µs p50 (số đo 29–30/10, `docs/Compatibility.md` mục 5), nên thời gian mỗi phím nằm ở số lời gọi vào app (N3), không ở engine; không thêm cổng tốc độ cho engine trên CI.
- 17/11 — D20 trên web editor (máy M3 Max, Chrome 157.0.8103.79, bộ gõ Release `0b1a42d`): `scripts/selftest/typing/d20-docs.sh --gdocs <link> --wordweb <link>`, tài liệu trống của người dùng — Word trên web đúng 6/6, Google Docs sai 3/3 cả chữ gõ liền; số và chữ đọc lại ở `docs/Compatibility.md` mục 5.10.
- 17/11 — chẩn đoán Google Docs (bộ gõ Debug `34644a3`, cài bằng `scripts/dev/install-app.sh --debug`, rồi cài lại bản trước bằng `--ref 0b1a42d`): `scripts/selftest/typing/run.sh --delay 80 --jitter 30 --word-pause 250 --keys … --expect … --doc-url <link> --save <dir> gdocs`, một lượt câu của `d20-docs.sh` và một lượt câu không có ⌫ — Google Docs trả vị trí `(1, 0)` ở mọi phím, Dấu chỉ thay được một ký tự; số và giả thuyết ở `docs/Compatibility.md` mục 5.10.
- 17/11 — Google Docs trên Safari 27.2 (bộ gõ Debug `34644a3`, rồi cài lại `0b1a42d`): `scripts/selftest/typing/run.sh --delay 80 --jitter 30 --word-pause 250 --keys … --expect … --doc-url <link> --save <dir> gdocssafari`, hai câu như lượt Chrome — cũng `(1, 0)` ở mọi phím; `docs/Compatibility.md` mục 5.10.
- 17/11 — thí nghiệm sửa nhiều bước qua cửa sổ một ký tự của Google Docs (bộ gõ Debug có thêm mã thí nghiệm, không giữ lại; ô `gdocs` và `gdocssafari` của `typing/run.sh`, câu không có ⌫; cài lại `0b1a42d` sau đó) — không được ở Chrome và Safari; số và cách làm ở `docs/research/WebEditorInput.md` mục 10.6 A.
- 18/11 — ngưỡng 50 ms của D11 (`InPlaceComposer.settleInterval`): A/B trên máy M3 Max, bản Debug của `f0a9102` có ngưỡng và cùng bản bỏ ngưỡng ở hai lần đọc của D11 (bản thử, không commit), `typing/run.sh --delay 5|10|20 --keys "$(scripts/selftest/load/run.sh --text edit --print keys)" --expect "$(… --print expect)"`, 3 lượt mỗi ô. Trang rảnh (Chrome, VS Code, Safari): đúng 27/27 ở cả hai bản, không lần lệch nào. Trang bận (`--busy 300:1000`, Chrome, Safari): sai 18/18 ở cả hai bản; tổng khoảng cách chỉnh sửa tới chữ mong đợi 176 có ngưỡng, 240 không ngưỡng. Kết luận: giữ ngưỡng (bỏ không giúp ô nào, làm hỏng nhiều hơn khi trang bận). Telex của Apple khi trang bận (`--source`, 5–20 ms): ra đúng chữ của nó lúc trang rảnh, 6/6.
- 18/11 — chẩn đoán trang bận khi phím dồn (máy M3 Max, bản Debug của `f0a9102`, rồi cài lại `0b1a42d`): `typing/run.sh --busy 300:1000 --delay 10 --keys "$(scripts/selftest/load/run.sh --text edit --print keys)" --expect … --save <dir> chrome|safari`, 3 lượt mỗi app, cộng 1 lượt Chrome `--delay 100 --jitter 30` làm đối chứng (đúng) — Chrome và Safari sai 6/6; nguyên nhân Chrome và các quan sát Safari ở `docs/Compatibility.md` mục 5.1, 5.2.
- 18/11 — trang bận, tiếp theo chẩn đoán (máy M3 Max; bản Debug thử nghiệm, không commit; cài lại `0b1a42d` sau đó): (1) bản thử "phím dồn thì tin vị trí Dấu theo dõi ở lần thay đầu của từ", ma trận như lượt A/B: trang bận tổng khoảng cách chỉnh sửa 129 (bản đang dùng 176), trang rảnh 27/27, nhánh mới 0 lần; (2) log có các con số của phép chứng minh, `typing/run.sh --busy 300:1000 --delay 10 … --save <dir> chrome|safari`, 3 lượt mỗi app; (3) nhịp người gõ nhanh với `0b1a42d`: `typing/run.sh --busy 300:1000 --delay 40 --jitter 20 --word-pause 150 …`, 3 lượt mỗi app, cộng đối chứng Telex của Apple (`--source`) mỗi app một lượt — kết quả ở `docs/Compatibility.md` mục 5.1, 5.2 và `docs/research/LateAnswerFixes.md` mục 3.
- 18/11 — sửa trang bận ở Chrome (máy M3 Max): bản Debug của mã `d171ab9` rồi cài lại `0b1a42d`; `typing/run.sh --busy 300:1000 --delay 40 --jitter 20 --word-pause 150 …` 6 lượt mỗi bản, `--delay 10 …` 3 lượt, `--delay 5` trang rảnh Chrome, VS Code, Safari mỗi app một lượt — số ở `docs/research/LateAnswerFixes.md` mục 3.3.
- 18/11 — lượt kiểm cửa sổ Cài đặt hỏng chập chờn (máy M1 Pro, macOS 27.2.1): sau một lượt `run.sh` bị cắt giữa chừng, lần chụp gỡ cài đặt và báo lỗi không ra sheet 3/3 lượt vì bản sao ký ad hoc mở lại cửa sổ onboarding còn mở từ lần trước; chạy riêng `--capture-report` không có / có `-ApplePersistenceIgnoreState YES`: hỏng 3/3, đạt 3/3. Loại trừ: công cụ ghi vị trí cửa sổ chạy song song (lượt không có nó cũng hỏng), khung cửa sổ đã lưu (xoá `NSWindow Frame settings` vẫn hỏng). Dấu cài trong `/Applications` mở đúng cửa sổ Cài đặt (1 lần). Không tìm thấy tệp trạng thái đã lưu. Sửa: `run.sh` truyền cờ đó cho mọi lần mở app. Cửa sổ 395×553 ở toạ độ âm trong lượt đó là menu Sửa › Tìm do phép kiểm ⌘F mở, phần nhô ra là viền bóng đổ.
- 18/11 — thời gian dựng danh sách ứng dụng của sheet "Thêm quy tắc" (máy M1 Pro, 107 hàng): 136–155 ms lần đầu trong tiến trình (vẽ biểu tượng khoảng 55%), 36–39 ms các lần sau; `DAU_MEASURE_APP_LIST=1 swift test --package-path Apps/Dau/Tests --filter AppListTiming`. Khoảng 5 giây đứng ở sheet trong `run.sh` là của phép kiểm "app list settles" (11 lần đọc cây trợ năng cách 0,2 s), không phải của app.
- 18/11 — bỏ chờ cố định trong lượt kiểm cửa sổ Cài đặt (máy M1 Pro, Debug): `scripts/selftest/settings-window/run.sh` 3 lượt liền nhau 59, 54, 71 s, mọi hàng đạt; bốn lượt trước đó cùng ngày 104–118 s. Ảnh chụp trong app giống nhau từng điểm ảnh giữa 3 lượt, trừ `onboarding/onboarding-0-move-light.png` ở lượt 1 rộng 1440 px thay vì 1444 px (nội dung và các hàng kiểm như nhau); nguyên nhân chưa rõ, chưa biết có từ trước không.
- 18/11 — tốc độ gõ cao nhất khi máy và trang rảnh (máy M1 Pro, CPU rảnh khoảng 75%; bản Debug của `3aad4e2` cài bằng `scripts/dev/install-app.sh --debug`, rồi cài lại `--ref main`): `typing/run.sh --delay 20|10|5|0 --keys "$(scripts/selftest/load/run.sh --text edit --print keys)" --expect … safari chrome vscode`, 3 lượt mỗi nhịp, cộng `--text std --delay 0` (cả chuỗi một lần) 3 lượt và đối chứng Telex của Apple ở Safari 3 lượt — Dấu đúng ở mọi nhịp gửi từng phím (tới khoảng 8,5 ms một phím, giới hạn của System Events); gửi cả chuỗi một lần Chrome, VS Code đúng, Safari sai 3/3; số ở `docs/Compatibility.md` mục 5.1.
- 18/11 — cùng ô Safari gửi cả chuỗi một lần, Dấu ở chế độ gạch chân (bản Debug của `555ee2f`, rồi cài lại `--ref main`): `typing/run.sh --underline --delay 0 --keys "$(scripts/selftest/load/run.sh --text std --print keys)" --expect … safari`, 3 lượt — chữ đúng 3/3, dấu cách dời chỗ 2/3; `docs/Compatibility.md` mục 5.1.
