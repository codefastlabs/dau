# Tiến độ

Nhật ký điều phối, để phiên sau (hoặc sau khi ngữ cảnh bị nén) tiếp tục đúng chỗ. Phiên chính cập nhật file này sau mỗi bước.

## Trạng thái hiện tại

M6 (Hiệu năng dưới tải) đóng 16/11/2026, kiểm toán ĐẠT. M7 (Phát hành) đang làm từ 17/11/2026, theo mục "Kế hoạch M7" bên dưới.

Chờ người dùng:
- Bước 0 của kế hoạch M7: đăng ký Apple Developer Program trước tiên (việc lâu nhất).

Việc tiếp theo:
- Bước 2 của kế hoạch M7, khi bước 0 xong (bước 1 xong 17/11).

Việc mở:
- Trình soạn thảo WebStorm mất khôi phục D4 vì Dấu bị reset sau mỗi phím đi thẳng (`docs/Compatibility.md` mục 5.9). Bước kế: ghi log ở `commitComposition` và `deactivateServer`, chạy lại ô `webstorm` một lượt (`docs/research/JetBrainsInput.md` mục 5).
- Ma trận tương thích còn lại, làm sau bản thử đầu: `docs/Roadmap.md` mục "Tồn đọng chưa gắn mốc", danh sách ở `docs/Compatibility.md` mục 7.
- `smartAdvancedExpanded` (khoá môi trường mở sẵn "Nâng cao" ở trang Thông minh) không còn chỗ nào đặt thành true từ khi bỏ công cụ chụp `SnapshotSettings` (16/11); đường truyền qua `SettingsWindow` là mã chết, bỏ được (kiểm toán M6).
- Bộ đệm nguồn đầu vào của các app: tiến trình trong thư mục cache được hệ thống bảo vệ (WebKit, Shortcuts) không xoá được, ảnh hưởng chưa đo; gỡ cài đặt chưa xoá bộ đệm của các app (`docs/research/InputMethodInstall.md` mục 10.7).
- Chưa có artboard: tên các nguồn tiếng Việt khác trong ghi chú của D14 (Onboarding) vẫn theo tiếng Việt của app (`LayoutNames` chỉ có bàn phím).
- Chưa chạy qua script: nhánh "đã trùng sẵn" và các nhánh lỗi của việc thay bộ gõ. `scripts/selftest/app-group.sh --install` chưa chạy lại kể từ khi gộp script cài 10/11. Chưa kiểm: VoiceOver, cờ `--tampered` trên cửa sổ thật.
- Sheet thêm quy tắc: ba nút cuối không có nhãn trợ năng (/dogfood 11/11; chưa kiểm bằng VoiceOver).

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

Việc cần người dùng gom vào bước 0 (tài khoản, khoá, duyệt artboard) và bước 3 (một lượt chạy chiếm màn hình); phần còn lại phiên chính và subagent làm. Thứ tự: bước 1 bắt đầu ngay, không chờ gì; bước 2 chờ bước 0 (mục 1–3) và 1a; bước 3 chờ bước 2 và 1b–1d; bước 4 chờ bước 3.

### Bước 0 — Người dùng (làm một lần, song song với bước 1)

1. Đăng ký Apple Developer Program (99 USD/năm). Đăng ký tổ chức nếu codefastlabs là pháp nhân (cần mã D-U-N-S, có thể mất vài ngày): Gatekeeper hiện "codefastlabs", khớp D7. Không phải pháp nhân thì đăng ký cá nhân, và phiên chính sửa câu "của codefastlabs" ở D7. Báo Team ID khi có.
2. Khi có tài khoản: làm theo `docs/Releasing.md` (release-eng viết ở 1a): tạo chứng chỉ Developer ID Application và khoá App Store Connect API cho notarize, sinh khoá EdDSA của Sparkle bằng một lệnh, nạp cả ba vào secret của GitHub Actions. Phiên chính không cầm khoá.
3. Vercel: nối repo với project của `dau.codefastlabs.com`, thư mục gốc theo `docs/Releasing.md` (tới M8 chỉ có `appcast.xml`).
4. Duyệt artboard (1e): xong 17/11.

### Bước 1 — Không cần ký: xong 17/11

Sparkle (chỉ bản chính thức kiểm tra cập nhật), trang Cập nhật & hỗ trợ và báo lỗi, biểu tượng Icon Composer, nền DMG, script phát hành chạy được ở chế độ không ký, GitHub Actions, `docs/Releasing.md`; entitlement của bộ gõ giữ nguyên. Chi tiết: nhật ký 17/11.

### Bước 2 — Bản thử trên CI (sau bước 0)

- Lần đẩy mã đầu (cần người dùng đồng ý push): workflow Test chạy trên runner `xcode-27`.
- Tag thử dựng hai bản chính thức số build khác nhau, công bố lên appcast (chưa có người dùng nên không ảnh hưởng ai). Kiểm DMG không cần màn hình: `codesign`, `spctl`, `stapler`, biểu tượng, `nm`, dSYM (`scripts/release/check-build.sh`). Những phần chưa chạy thật lần nào: `docs/Releasing.md` mục "Còn phải thấy chạy thật".

### Bước 3 — Một lượt chạy chiếm màn hình (khoảng 70 phút, xin giờ một lần; người dùng ngồi cùng khoảng 15 phút ở mục 4)

1. D42: `scripts/selftest/load/heavy.sh` với bản Debug; RSS tiến trình bộ gõ bản Release cạnh bản Debug.
2. Cài bản thử thứ nhất từ DMG (mang quarantine): Gatekeeper, hộp thoại App Group và hộp thoại bật bộ gõ với bản Developer ID (hai câu hỏi mở), onboarding, gõ thử bằng `scripts/selftest/typing/run.sh`.
3. Sparkle cập nhật lên bản thử thứ hai: kiểm câu dưới công tắc "Tự động kiểm tra bản mới" (kiểm tra khi mở Dấu, hỏi trước khi cài, D7); cài xong Sparkle mở lại Dấu và bộ gõ đã cài được thay (`scripts/dev/dau-version.sh`).
4. Kiểm cần người: VoiceOver và Tab qua cửa sổ Cài đặt, VoiceOver đọc tên nguồn, máy để tiếng Anh hẳn (người dùng đổi ngôn ngữ hệ thống). Phiên chính chụp và xem: biểu tượng thanh menu trên nền sáng và tối, các sheet ở chế độ tối, danh sách "+" của System Settings, nhãn biểu tượng trong cửa sổ DMG ở chế độ tối (theo báo cáo trên diễn đàn, Finder vẽ nhãn kiểu sáng khi thư mục có ảnh nền; chưa đo) và vị trí biểu tượng so với mũi tên nền.
5. Báo lỗi và trang Cập nhật & hỗ trợ (bản Debug, ma trận `scripts/selftest/settings-window/run.sh` và `docs/UIChecks.md`): hàng báo lỗi, sheet báo lỗi (độ rộng control bốn lựa chọn, Tab, Esc/Return, VoiceOver đọc ô gợi ý, chế độ tối); mở Dấu bằng "Cài đặt Dấu…" khi đang ở Chrome thì ô "Ứng dụng" chọn Chrome; "Mở trên GitHub" ra form điền sẵn (cần mẫu issue đã lên nhánh mặc định).
6. Đo lại các ô đã đo trước khi script chuyển nguồn bằng phím tắt hệ thống (`0bf8d3f`, 10/11), theo kiểm toán ngày 17/11, khoảng 8 phút. Bản Debug, chuyển nguồn bằng phím tắt và xác nhận trong ô gõ:
   - VS Code ở 5 ms, xen kẽ ô Telex của Apple và ô Dấu, vài lượt. Cũng là đối chứng Apple còn thiếu ở VS Code và Firefox phím dồn (`docs/Compatibility.md` mục 7).
   - Một ô Telex của Apple ở Chrome, trang rảnh và trang bận (câu về Apple ở D11).
   - Đếm dòng `activate` và `source-changed-reset` khi chuyển nguồn bằng phím tắt, bằng menu và bằng `⇄`. Đo thêm khi bật "Automatically switch to a document's input source" rồi đổi cửa sổ. Kết quả cho biết bộ nghe `InputSourceChange` có đường chuyển thật nào cần đến không.
7. Nếu hướng 2A của [`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md) đã vào mã: lượt hồi quy ở mục 4 của tài liệu đó (Chrome trang bận, VS Code 5 ms), khoảng 5 phút.
8. Dọn: gỡ bản thử, cài lại `stable`.

### Bước 4 — Phát hành và đóng mốc

- Tag `v0.1.0-beta.1`; CI dựng bản nháp. Người dùng đồng ý một lần cho cả ba việc công bố: phát hành trên GitHub, cập nhật appcast, tạo repo `codefastlabs/homebrew-tap` với cask `dau`.
- Kiểm `brew install --cask codefastlabs/tap/dau` trên máy, rồi cài lại `stable`.
- Kiểm toán, tóm tắt, chuyển nhật ký và kế hoạch M7 sang `docs/history/`.

## Nhật ký
Nhật ký M0–M4 ở `docs/history/LogM0ToM4.md` (kèm bảng số đo M1–M3), M5 ở `docs/history/LogM5.md`, 05–08/11 (giữa M5 và M6) ở `docs/history/LogBetweenM5AndM6.md`, M6 ở `docs/history/LogM6.md`.

(ngày — việc — agent — kết quả — commit)

- 17/11 — đo Cursor 3.30.14 (bản Debug fa5ce8f+, máy M1, ba ô: trình soạn thảo, khung agent ⌘L, ô nhập Agents; chuyển nguồn bằng phím tắt hệ thống): thay tại chỗ đúng ở cả ba ô (số đo: `docs/Compatibility.md` mục 5.4). Vị trí tính từ đầu văn bản, không còn từ đầu từ như 3.29.15. Bỏ nhãn "Đề xuất" của Cursor (`CompatibilityList.json` version 7), sửa `Compatibility.md`, `Architecture.md`, `research/LateAnswerFixes.md` (nhóm 1, 3, 4 thành giới hạn của app tính theo từ, hướng 1B bỏ; nhóm 2 giữ 2A), comment test. D13 sửa câu hiện trạng nhãn (luật không đổi). Chuỗi `edit` ở 5 ms ra "Hocj" ở cả ba ô: đúng D20 (`settleInterval` 50 ms), ở 100 ± 30 ms thì đúng. `typing/run.sh` thêm ô `cursorchat`. Dọn: Cursor đã thoát, không có hộp thoại lưu; cài lại `stable` — commit "test(selftest): type in the agent panel of Cursor's IDE window", "fix(compatibility): Cursor 3.30.14 types right in place; drop its underline label".
- 17/11 — chẩn đoán lỗi người dùng báo: gõ từ chưa dấu, dấu cách, ⌫, phím dấu, dấu không vào từ mà đứng sau nó ("hocj"), lúc có lúc không — phiên phụ, không agent — client giả dựng lại ba cơ chế cùng ra "hocj"; gõ lại phím dấu chậm ngay sau đó phân biệt được chúng: (1) từ ⌫ tới phím dấu dưới 50 ms (D20, `settleInterval`): gõ lại chậm thì được; (2) một lần đọc trước đó trong cùng lần kích hoạt nhận `NSNotFound` hay `nil`: `readUnavailable` tắt mọi lần đọc D20 tới lần kích hoạt sau (D20, D18), gõ lại vẫn hỏng, đổi app rồi quay lại thì được; (3) app trả chậm hơn `lateLimit` (mô hình bộ đệm Chromium, chậm 3–4 thao tác): chỉ hỏng phím đó. Đọc mã không thấy cơ chế khác (D20 "Từ hệ thống vừa sửa", mô hình Cursor, reset bằng mũi tên đều đúng). Ca người dùng gặp, ở app Claude: "khuyeens" ra "khuyến", "cao␣⌫s" ra "caos", ⌫⌫ ra "ca", "s" ra "cas". Ở 150 ms giữa các phím, chỉ cơ chế 2 ra đủ chuỗi đó: mô hình chậm 3 thao tác ra "caos" rồi "cá", chậm 4 làm hỏng cả "khuyến"; cơ chế 1 phải xảy ra hai lần liền. Chưa rõ lần đọc hỏng trước đó là lần nào (bản Release không ghi log theo phím, D8). Sửa (người dùng duyệt đổi D20): một lần đọc không nhận được gì chỉ mất lần đọc của phím đó; hai lần liền nhau mới thôi đọc tới lần kích hoạt sau, một lần đọc được ở giữa thì đếm lại (`InPlaceComposer.failedReadLimit`). Test: `BackspaceThenMarkTests` (gồm đúng chuỗi phím đã báo), `failedReadsStartOver`; `LateBackspaceMarkTests` giữ known issue (chậm 3–4 thao tác, chưa sửa). Bộ gõ 209 test đạt, 11 known issue. Chưa kiểm trong app Claude thật: lần đọc hỏng chưa tái hiện được ngoài đời, chỉ xác nhận được khi dùng hằng ngày bản mới mà không gặp lại. Đã cài bản Release của commit này bằng `scripts/dev/install-app.sh` (`dau-version.sh`: bộ gõ và Dấu.app đều đúng commit); tag `stable` chưa chuyển, chờ dùng thử — commit "fix(input-method): one failed read no longer stops D20 until activation".

- 17/11 — người dùng chọn dùng hằng ngày commit mới nhất: tag `stable` chuyển sang 6fc7fd3, cài bản Release bằng `scripts/dev/install-app.sh --ref stable` — phiên chính — `dau-version.sh`: bộ gõ và Dấu.app đều 6fc7fd3 · Release — không commit.
- 17/11 — /dogfood VS Code 1.146.0, máy M1 (M1 Pro), macOS 27.2, bản Debug của 6fc7fd3 (`DauPerfLog` bật), thay tại chỗ, nhịp 85 ± 30 ms một phím, nghỉ 260 ms sau mỗi từ — phiên chính, không agent — một lượt chạy liền 201 giây gồm trình soạn thảo (Markdown, văn bản thường, Python), Find, Command Palette. Chuỗi phím soát trước bằng engine. Không thử gạch chân (VS Code không mang nhãn, D43), ô commit, Settings, Search, Quick Open, chuột. **Quan sát khi gõ tự nhiên** (chưa là kết luận):
  - 14/14 ô có đáp án ra đúng: câu dài đặt dấu tự do; ⌫ giữa từ; ⌫ qua dấu cách rồi phím dấu (`hoan ⌫f`); ← 12 lần về sau "tren" rồi `e`; ⇧⌥← chọn từ rồi gõ đè; đổi sang U.S. giữa câu rồi về; ⌘Tab sang app khác giữa từ (`Tieen`, về, `gs` → "Tiếng"); câu có từ lặp ở file văn bản thường; comment Python; VS Code tự đóng `"` `)` (`print("Camr own banj ddax mua hangf!")` → `print("Cảm ơn bạn đã mua hàng!")`); Find (`khasch hangf`). ⌘Z sau khi gõ "Mai gặp khách" bỏ chữ "khách", gõ tiếp ra "Mai gặp nhé." (không có đáp án).
  - Log theo phím: 105 lần thay chữ, không lần nào `mismatch` hay `unsupported`; 5 lần VS Code trả vị trí con trỏ ngay sau `insertText` còn ở chỗ cũ (trước khi áp chữ vừa chèn), phím sau vẫn đúng. Xử lý một phím: trung vị 0,18 ms, p95 1,8 ms, lớn nhất 15 ms (phím đầu có đọc chữ D20).
  - Command Palette, gõ `toggle word wrap` (không gõ dấu cách cuối): ô hiện "toggle word ửap", dòng đứng đầu danh sách là "Delete Word". Đúng D4 (từ chưa kết thúc thì chưa khôi phục). Mức: nhấn Return trước khi kết thúc từ có thể chạy nhầm lệnh. Không đo thêm: hành vi theo D4; gõ lệnh tiếng Anh thì chuyển sang U.S. (D2).
  - Python khi chưa chuyển sang U.S.: `def` ra "dè" (D4, tiếng Việt thắng). Engine offline với 117 từ khoá và từ hay gặp khi viết mã, các từ bị đổi: if→ì, is→í, as→á, or→ỏ, var→vả, this→thí, defer→dể, list→lít, post→pót, test→tét, dir→dỉ, docs→dóc, max→mã, res→ré (D4); pass→pas, diff→dif, err→er (D26: phím dấu thứ hai xoá dấu, nên chữ ra không phải từ gõ). Mức: phải sửa tay.
  - File văn bản thường: VS Code không gợi ý "Khách" cho tiền tố "Kha" nên ô ⇥ nhận gợi ý không đo được gì (hành vi của VS Code).
  - Công cụ: `install-app.sh` mở lại Dấu.app (đang chạy trước khi cài) ở tiền cảnh, cửa sổ Cài đặt lấy mất focus của app đang thử; bước kiểm cửa sổ của script gõ chặn lại trước khi gõ.
  — không commit mã.
- 17/11 — `install-app.sh` mở lại Dấu.app (khi đang chạy trước lúc cài) bằng `open -g`, không đưa app lên trước — phiên chính — đo: Dấu.app đang chạy, Claude ở trước, cài từ thư mục làm việc: sau khi cài Claude vẫn ở trước, Dấu.app chạy lại và không ở trước (script cũ: Dấu.app lên trước). `--ref` chạy script của chính commit đó, nên `--ref stable` dùng bản sửa khi `stable` ở commit có nó.
- 17/11 — đo Dấu trong WebStorm 2026.3 (trình soạn thảo và terminal Reworked), máy M1 (M1 Pro), macOS 27.2, bản Debug của 2990a91, 80 ± 30 ms một phím, nghỉ 250 ms sau mỗi từ, một lượt mỗi ô, đối chứng Telex của Apple — imk-dev (thêm ô `webstorm`, `webstormterm` vào `scripts/selftest/typing/run.sh`), researcher (`docs/research/JetBrainsInput.md`), phiên chính chạy lượt đo — kết quả:
  - Trình soạn thảo, thay tại chỗ: chữ tiếng Việt đúng, mất khôi phục D4 ("ưindows", "Sủnise"); Dấu bị reset sau mỗi phím đi thẳng, ai gây reset chưa rõ. Terminal: ô bỏ qua vùng thay (D43). Gạch chân đúng cả hai ô. Số đo: `docs/Compatibility.md` mục 5.9.
  - Dọn: cài lại `stable` (2990a91 Release); WebStorm của người dùng đang chạy nên script không trả được tệp cài đặt, phiên chính xoá 2 mục dự án tạm trong `recentProjects.xml` và `trusted-paths.xml` sau khi WebStorm thoát.
- 17/11 — tra tên trước M7: cask và formula `dau` còn trống trong Homebrew; repo 0 sao, dưới ngưỡng nhận gói của `homebrew/cask`. Người dùng chốt tap riêng `codefastlabs/homebrew-tap` (D6, D24) và giữ `dau.codefastlabs.com`, không cần "dấu.vn"; bộ gõ DauKey (tên gần giống) ghi ở câu hỏi mở "Tên Dấu". Hai artboard trang tải về điền lệnh `brew install --cask codefastlabs/tap/dau`, chụp lại bằng `render-canvas.sh`; trên bản điện thoại lệnh dài hơn khung, cuộn ngang trong khung (`overflow-x: auto` có sẵn) — phiên chính — commit "docs(decisions): ship the Homebrew cask from our own tap".
- 17/11 — lập kế hoạch M7 (mục "Kế hoạch M7") — phiên chính — người dùng chốt: chưa có Apple Developer Program (đăng ký là việc đầu của bước 0); appcast ở `dau.codefastlabs.com`; bản thử đầu "0.1.0 beta 1"; trả lời câu hỏi mở "Loại bản dựng" (D7, D25). GitHub Actions có ảnh macOS 27 với Xcode 27.2 (bản xem trước), cùng mã build 27B52 với máy phát triển, nên CI dựng được. Roadmap M7 thêm "Xong khi"; việc sau bản thử đầu tách thành mục riêng, không chặn đóng mốc — commit "docs: plan M7 and settle build-type questions".
- 17/11 — M7 bước 1e: artboard mới "Cửa sổ ảnh đĩa DMG" (nền Giấy, không có chữ trên nền vì ảnh nền không dịch được, D41); "Cập nhật & hỗ trợ" thêm phần cập nhật (bản chính thức) và hàng "Ứng dụng gõ sai chữ" (mọi bản); sheet báo lỗi sửa câu "Không gửi nội dung bạn đã gõ" (sai N5: ô "Ví dụ đã gõ" có gửi) — phiên chính — người dùng duyệt một lần và chọn: cửa sổ chuẩn của Sparkle thay cho thẻ trạng thái và thông báo tự vẽ (bỏ hai artboard đó; bản tự vẽ từng hứa quay về bản trước và chữ ký đã xác minh trước khi tải), chỉ kiểm tra lúc Dấu mở, không cài ngầm (D7); bỏ đường email của báo lỗi (D8). Chụp lại bằng `render-canvas.sh` — commit "docs(decisions): use Sparkle's own update windows; GitHub-only bug reports".
- 17/11 — M7 bước 1a–1d — release-eng (Sparkle, script phát hành, CI, biểu tượng, nền DMG), app-ui-dev (trang Cập nhật & hỗ trợ, báo lỗi), imk-dev (entitlement), phiên chính kiểm và commit — kết quả:
  - Sparkle 2.10.1 ghim chính xác, chỉ app chủ link. `SUFeedURL`/`SUPublicEDKey` do một build phase ghi vào bản `DAU_OFFICIAL=YES` (thiếu khoá công khai thì build lỗi), xoá ở mọi bản khác; `SUEnableSystemProfiling` tắt, kiểm tra mỗi ngày tối đa một lần, không cài ngầm (D7, D8). Phiên chính build lại: bản chính thức có đủ khoá và biểu tượng `AppIcon`, bản Debug không có feed, biểu tượng `AppIconDev`.
  - Trang Cập nhật & hỗ trợ: bản có feed và khoá mới khởi động `SPUStandardUpdaterController` (cửa sổ chuẩn của Sparkle); dòng kiểm tra lần cuối, nút "Kiểm tra bản mới…", công tắc. Mọi bản: hàng và sheet báo lỗi mở form issue điền sẵn (`.github/ISSUE_TEMPLATE/typing-problem.yml`), URL chỉ mang những gì sheet hiện. App chủ 174 test đạt, `check-l10n` đạt. Sau khi cài, Sparkle mở lại Dấu và `reconcileAtLaunch` thay bộ gõ (đọc mã); ngoại lệ: người dùng chọn cài rồi ⌘Q trước khi xong thì Sparkle cài lúc thoát mà không mở lại, bộ gõ cũ chạy tới lần mở Dấu sau (`SPUUserDriver.h`).
  - Biểu tượng: `AppIcon.icon`, `AppIconDev.icon` sinh bằng `scripts/assets/make-app-icon.swift` từ hình học artboard; actool sinh cả `.icns` cho macOS 14–15. Xem bằng `ictool` ở sáu kiểu × 16–1024 px: khớp artboard, dải Hổ phách còn thấy cả khi bỏ màu; ở 16 pt dấu mũ và dấu sắc chỉ còn vài điểm ảnh. Ảnh xem trước GitHub và nền DMG (640×400, @2x) xuất vào `Resources/Brand/`.
  - Entitlement bộ gõ: bỏ `temporary-exception.mach-register.global-name` thì build và test offline vẫn đạt (bộ gõ 209 test, 11 known issue), và trên macOS 27.2 app nối vào bộ gõ qua endpoint XPC chứ không qua tên kết nối; nhưng bỏ không giúp notarize và không kiểm được trên macOS 14–26, nên giữ (`docs/research/IMKAPINotes.md`).
  - Script phát hành `scripts/release/build-release.sh` chế độ không ký chạy trọn tới DMG trong 49 giây (số hiển thị "0.1.0 beta 1", số build 6030 = số commit × 10; tag ổn định cộng 1 để bản ổn định dựng lại từ commit của beta cuối vẫn lớn hơn). `layout-dmg.sh` mở Finder nên chỉ chạy trên CI; hook chặn nó ở máy. Workflow Test và Release (runner `xcode-27`, Xcode 27.2), secret chỉ ở hai bước dùng chúng. `docs/Releasing.md`: việc của người dùng ở bước 0 và tên 8 secret.
  - Ma trận cửa sổ thật: cờ `--capture-report` (bản Debug) mở sẵn sheet báo lỗi với nội dung mẫu, kiểm (h) trong `docs/UIChecks.md`; chạy lần đầu ở bước 3.
  - Canvas: chín artboard đặt `@import` phông sau luật CSS khác nên trình duyệt bỏ qua; chuyển lên đầu, chụp lại.
  — commit "feat(brand): build the app icons from Icon Composer documents", "feat(updates): add Sparkle 2 to the host app, official builds only", "docs(research): keep the input method's mach-register exception", "docs(canvas): load Be Vietnam Pro in the brand and landing artboards", "feat(brand): draw the DMG window background", "feat(app): check for updates and report typing problems", "build(release): add the release script, CI workflows and appcast folder", "test(settings-window): capture the bug-report sheet".
- 17/11 — người dùng đồng ý ba đề xuất sau bước 1 — phiên chính — biểu tượng giữ một bộ nét cho mọi cỡ (`docs/Brand.md`, chữ chú thích của artboard "Nhận diện – biểu tượng ứng dụng" sửa theo, chụp lại); D7 thêm hệ quả đã chấp nhận: ⌘Q giữa lúc cài thì Sparkle cài lúc thoát mà không mở lại Dấu; thư mục trang web và gốc Vercel là `site/` (Roadmap M8) — commit "docs(decisions): accept the quit-during-install case; settle site/ and icon strokes".
