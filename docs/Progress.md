# Tiến độ

Nhật ký điều phối, để phiên sau (hoặc sau khi ngữ cảnh bị nén) tiếp tục đúng chỗ. Phiên chính cập nhật file này sau mỗi bước.

## Trạng thái hiện tại

M6 (Hiệu năng dưới tải) đóng 16/11/2026, kiểm toán ĐẠT. Mốc kế: M7 (Phát hành), chưa bắt đầu.

Chờ người dùng:
- Không có.

Việc tiếp theo:
- M7: lập kế hoạch theo `docs/Roadmap.md` mục M7.

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
| M7 Phát hành | chưa | — |
| M8 Website | chưa | — |
| M9 Đa ngôn ngữ | phần nền (D41 (Ngôn ngữ giao diện)) và câu chữ tiếng Anh xong 06–09/11 | — |
| M10 Học cách gõ | chưa | — |

## Nhật ký
Nhật ký M0–M4 ở `docs/history/LogM0ToM4.md` (kèm bảng số đo M1–M3), M5 ở `docs/history/LogM5.md`, 05–08/11 (giữa M5 và M6) ở `docs/history/LogBetweenM5AndM6.md`, M6 ở `docs/history/LogM6.md`.

(ngày — việc — agent — kết quả — commit)

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
