# Scripts

Mỗi script có dòng `# Side effects:` ở đầu file (ngay sau dòng chú thích đầu tiên), dùng đúng các từ trong bảng chú giải dưới đây. `scripts/check-docs/check.sh` kiểm: script nào thiếu dòng này, hoặc chưa có trong bảng, hoặc đường dẫn trong bảng không tồn tại thì báo lỗi. Hook `.claude/hooks/guard-scripts.sh` đọc chính dòng này (kể cả các vế `unless`/`with` theo cờ) để chặn agent chạy script có tác dụng phụ làm phiền người dùng (chiếm màn hình, dừng tiến trình, đổi nguồn nhập liệu, cài, xoá, đổi cài đặt), nên vế điều kiện phải viết đúng dạng `unless --cờ: …` / `with --cờ: …`.


Thư mục theo mục đích:

| Thư mục | Chứa |
|---|---|
| `scripts/build/` | bước build do `project.yml` gọi |
| `scripts/dev/` | cài, dọn, xem bản bộ gõ trên máy |
| `scripts/perf/` | đọc số đo từ nhật ký |
| `scripts/assets/` | sinh biểu tượng tạm |
| `scripts/selftest/` | thử trên app thật (chiếm màn hình hoặc đổi nguồn nhập liệu) |
| `scripts/check-docs/` | kiểm tài liệu |
| `scripts/check-l10n/` | kiểm String Catalog |
| `scripts/lib/` | công cụ dùng chung giữa các script |
| `scripts/probe/` | công cụ thử ném đi: làm nguồn nhập liệu mới hiện trong "+" không cần đăng xuất (`docs/research/M5-INSTALL.md` mục 8.2); không thuộc bản phát hành |
| `scripts/snapshot-settings/` | test đơn vị app chủ và công cụ chụp Cài đặt |
| `scripts/research/` | công cụ cho tài liệu nghiên cứu: trích dữ liệu từ dự án khác (chỉ đọc file, không chạy mã của họ) |

| Đường dẫn | Làm gì | Tác dụng phụ | Ai chạy | Gọi từ |
|---|---|---|---|---|
| `scripts/check-docs/check.sh` | Kiểm tài liệu lệch (đường dẫn, số D/N, cách nói đã bị thay, mã commit, ghi chú nghiên cứu, danh sách script). | none | agent | CLAUDE.md, `.claude/commands/milestone.md`, `.claude/agents/auditor.md` |
| `scripts/check-l10n/check.sh` | Kiểm mọi `.xcstrings` trong `Apps/` (D41): ngôn ngữ gốc `en`; mọi khoá (trừ `shouldTranslate` false) có bản `en` và `vi` ở trạng thái đã dịch, kể cả từng dạng số nhiều; mỗi bản có đủ `%@`/`%lld` như khoá, cùng thứ tự đối số; không có khoá "stale"; khoá và bản `en` không có chữ tiếng Việt ngoài `allowed-vietnamese.txt`; không có "Dau" không dấu đứng riêng (D24). Truyền thư mục DerivedData của một lần build xong thì so thêm các khoá trình biên dịch trích từ mã (`*.stringsdata`) với catalog của từng target. | none | agent | CLAUDE.md, docs/ARCHITECTURE.md, docs/GLOSSARY.md, `.claude/agents/auditor.md`, `.claude/commands/milestone.md` |
| `scripts/dev/dau-version.sh` | Bản bộ gõ đã cài và đang chạy có đúng commit mới nhất không. | none | agent | CLAUDE.md, docs/ARCHITECTURE.md |
| `scripts/perf/perf-report.sh` | Đọc nhật ký hệ thống, in p50/p99 từng thao tác của bộ gõ theo app. | none | agent | docs/COMPATIBILITY.md, `scripts/selftest/typing/run.sh` |
| `scripts/build/stamp-build-commit.sh` | Ghi mã commit vào `build/generated/BuildCommit.txt` cho bản build. | builds | agent | `project.yml` (preGenCommand và build phase) |
| `scripts/assets/make-app-icon.sh` | Sinh lại biểu tượng app tạm (SVG và iconset). | writes repo files | agent | chạy tay; `project.yml` (chú thích) |
| `scripts/assets/make-mode-icons.sh` | Sinh lại biểu tượng chế độ gõ "V" tạm của bộ gõ. | writes repo files | agent | chạy tay; `Apps/DauInputMethod/Info.plist` (chú thích) |
| `scripts/lib/build.sh` | Bước build dùng chung (nạp bằng `source`, không chạy riêng): dừng sớm khi keychain không có chứng chỉ "Apple Development" dùng được và in hai cách sửa; `xcodegen` rồi `xcodebuild` universal vào `build/DerivedData.noindex`. Không bao giờ truyền `-allowProvisioningUpdates` (có thể thu hồi chứng chỉ của máy Mac khác), chỉ in lệnh để người dùng tự chạy. Bước kiểm bản build ở lại script gọi. | builds | agent | `scripts/dev/install-input-method.sh`, `scripts/dev/install-app.sh`, `scripts/selftest/app-group.sh`; `scripts/probe/build-tools.sh` và `scripts/probe/make-variants.sh` (chỉ `dau_signing_identities`) |
| `scripts/dev/install-input-method.sh` | Build và cài bộ gõ vào `~/Library/Input Methods`, dừng tiến trình cũ. Với `--build-only` chỉ build (tác dụng phụ: builds, agent chạy được). | builds, installs input method, kills processes | người dùng, hỏi giờ trước | CLAUDE.md, README.md, CONTRIBUTING.md, docs/COMPATIBILITY.md, `scripts/dev/install-app.sh` (`--with-input-method`), `scripts/selftest/app-group.sh` (`--install`), `scripts/probe/make-variants.sh` (`--build-only --release`) |
| `scripts/dev/install-app.sh` | Build Dấu.app (Release, hoặc `--debug`) và cài vào `/Applications`: bản cũ vào Thùng rác qua Finder, chép bằng `ditto`, đăng ký với LaunchServices; Dấu.app đang chạy thì thoát bình thường rồi mở lại. `--with-input-method` chạy thêm `install-input-method.sh` cùng cấu hình. | builds, installs app, kills processes, deletes data | người dùng, hỏi giờ trước | CLAUDE.md |
| `scripts/selftest/app-group.sh` | Thử không cần gõ: cài đặt app chủ lưu có tới được bộ gõ qua App Group không. Chỉ có `--install` mới cài bộ gõ và dừng tiến trình. | builds, changes input source, changes user settings (và với `--install`: installs input method, kills processes) | người dùng, hỏi giờ trước | docs/ARCHITECTURE.md, docs/research/M5-INSTALL.md |
| `scripts/selftest/typing/run.sh` | Gõ một câu vào app thật bằng bộ gõ Dấu rồi đọc lại chữ ra. | builds, takes the screen, changes input source, changes user settings | người dùng, hỏi giờ trước | docs/ARCHITECTURE.md, docs/COMPATIBILITY.md |
| `scripts/selftest/settings-window/run.sh` | Kiểm giao diện (`docs/UI-CHECKS.md`): các lần mở app lần lượt (danh sách ở đầu `run.sh`); `--focus` chỉ mở app thật hai lần (tiêu điểm lúc mở, Tab/⌘F, ô tìm sidebar). Các lần chụp trong app (onboarding, alert gỡ cài đặt, banner; cửa sổ hiện giữa màn hình chính) và các lần mở app thật (`open -n`) để đo qua Accessibility và chụp riêng cửa sổ: di chuyển, đổi cỡ cửa sổ qua trợ năng, lăn chuột thật trên sheet thêm quy tắc, kéo và bấm đúp đường chia sidebar, gửi phím ⌘[ ⌘], mở menu View (con trỏ bị dời). Trạng thái chia cột đã lưu của Dấu (bản cũ để lại) cũng được cất và trả lại. Kiểu thanh cuộn và giao diện là đối số của từng lần mở, không đổi cài đặt hệ thống. Trước mỗi lần mở app thật xoá khung cửa sổ đã lưu của Dấu, trả lại khi xong. | builds, takes the screen, kills processes, changes user settings | người dùng, hỏi giờ trước | CLAUDE.md, docs/UI-CHECKS.md, `.claude/agents/app-ui-dev.md` |
| `scripts/dev/clean-dau.sh` | Liệt kê mọi dấu vết của Dấu trên tài khoản; với `--yes` thì xoá những gì xoá được. Không tham số thì chỉ đọc (tác dụng phụ: none, agent chạy được). | kills processes, deletes data, changes user settings, changes input source (chỉ với `--yes`) | người dùng, hỏi giờ trước | CLAUDE.md, docs/research/M5-INSTALL.md |
| `scripts/probe/make-variants.sh` | Dựng biến thể `DauProbe<vòng><N>` (ID, mode, kết nối, tên hiển thị, entitlement đổi theo; ký lại) từ bản Release của `DauInputMethod.app` vào `build/probe.noindex/<vòng>/`, không chép vào thư mục cài; từ chối ID đã dùng. | builds | agent | docs/research/M5-INSTALL.md (mục 8.2) |
| `scripts/probe/build-tools.sh` | Biên dịch `tis-probe`, `tis-act` và đóng gói `TisAct.app` ("Dấu thử", ký, không sandbox) vào `build/probe.noindex/`. | builds | agent | `scripts/probe/step.sh` |
| `scripts/probe/step.sh` | Chạy một bước P0–P7/P3b của vòng thử trên một biến thể (chép, register, enable, select, dừng tiến trình giao diện, đọc lại 3 lần), ghi giờ từng lệnh. `--dry-run` chỉ in chuỗi lệnh (tác dụng phụ none, agent chạy được). | installs input method, changes input source, kills processes, needs admin password (P6) | người dùng, hỏi giờ trước | docs/research/M5-INSTALL.md (mục 8.2) |
| `scripts/probe/cleanup.sh` | Liệt kê biến thể `DauProbe` đã cài, đăng ký LaunchServices, mục trong `com.apple.inputsources`, tiến trình, và thư mục macOS tạo cho các app thử có sandbox (container, Application Scripts, thư mục cache); với `--yes` thì gỡ (dừng nếu mục còn trong `com.apple.inputsources`), container vào Thùng rác qua Finder; với `--trash` thì xoá hẳn khỏi Thùng rác chỉ các bản thử (hỏi lại, cần Full Disk Access). Không tham số thì chỉ đọc (none, agent chạy được). | kills processes, deletes data, needs admin password (chỉ với `--yes`); deletes data (`--trash`) | người dùng, hỏi giờ trước | docs/research/M5-INSTALL.md (mục 8.2) |
| `scripts/research/external-tests/extract.sh` | Lấy 10 bộ gõ khác ở commit đã ghim (mạng, vào `/tmp/ext-ime/`), đọc file test của họ bằng các helper Python cùng thư mục (`python3 -I`), ghi lại các TSV chuỗi phím trong `docs/research/external-test-inputs/` (ra đúng từng byte bản đã commit), đáp án của họ vào `build/external-answers/` và số đếm vào `build/external-tests-stats/`. Không build hay chạy gì của các bản clone. Helper `answer_stats.py` (chạy riêng, chỉ đọc) in số đếm cho mục 6 của tài liệu. | writes repo files | agent | docs/research/EXTERNAL-TEST-INPUTS.md, `docs/research/external-test-inputs/NOTICE.md` |
| `scripts/research/external-tests/compare.sh` | So đầu ra của Dấu (`build/external-dau-output/`, do `ExternalCasesTests` của engine ghi) với đáp án của họ (`build/external-answers/`) theo từng ca của `docs/research/external-test-inputs/`: ghép theo `id`, chuẩn hoá theo `their_note`, so ở dạng NFC, ghi `build/external-review/<nguồn>.tsv` và in hai bảng đếm của mục 9.2 tài liệu. Ca khác nhau giữ lớp A–E, X của lần xét trước nếu phím, đầu ra và đáp án không đổi, còn lại ghi `unreviewed`; `--set FILE` áp lớp xếp tay. Helper `compare.py` cùng thư mục (`python3 -I`). Chỉ ghi vào `build/` (git bỏ qua), không biên dịch gì. | builds | agent | docs/research/EXTERNAL-TEST-INPUTS.md |

## Chú giải tác dụng phụ

| Từ | Nghĩa |
|---|---|
| `none` | chỉ đọc; không ghi gì ngoài file tạm |
| `builds` | chạy xcodegen, xcodebuild hoặc swiftc; ghi vào `build/` hoặc thư mục tạm, không đổi file được theo dõi bởi git |
| `writes repo files` | ghi đè file được theo dõi bởi git trong repo (xem bằng `git diff`) |
| `installs input method` | chép bộ gõ vào `~/Library/Input Methods` |
| `installs app` | chép Dấu.app vào `/Applications` và đăng ký với LaunchServices |
| `kills processes` | dừng tiến trình đang chạy (bộ gõ, Dấu.app, app do script tự mở) |
| `takes the screen` | mở app, gõ phím hoặc bấm chuột tự động: người dùng không dùng máy được trong lúc chạy |
| `changes input source` | chọn lại nguồn nhập liệu, hoặc bỏ Dấu khỏi danh sách nguồn |
| `changes user settings` | ghi `defaults` hoặc cài đặt App Group của người dùng (script tự trả lại khi xong, trừ khi ghi khác) |
| `deletes data` | xoá hoặc chuyển vào Thùng rác dữ liệu, bộ cài của Dấu |
| `needs admin password` | cần mật khẩu quản trị (chưa script nào cần) |

"Ai chạy": `agent` chạy được khi tác dụng phụ chỉ gồm `none`, `builds`, `writes repo files`. Còn lại do người dùng chạy, và phải hỏi giờ trước (CLAUDE.md: mọi lần chạy chiếm màn hình, đổi nguồn nhập liệu hay đổi cài đặt đều hỏi trước).

## `scripts/snapshot-settings`

Gói Swift chứa bộ test đơn vị của app chủ (`InputMethodInstallerTests`, `OnboardingFlowTests`, …) và công cụ chụp cửa sổ Cài đặt (`SnapshotSettings`) để đối chiếu với artboard. Không phải script chạy một lệnh nên không nằm trong bảng. Chạy test:

```
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path scripts/snapshot-settings
```

## Thư mục khác

- `scripts/lib/input-source.swift`: công cụ dòng lệnh nhỏ (đọc, chọn nguồn nhập liệu) mà `scripts/selftest/app-group.sh` và `scripts/selftest/typing/run.sh` tự biên dịch; hưởng tác dụng phụ của script gọi nó.
- Các file `.swift` trong `scripts/assets/make-*.swift`, `scripts/selftest/settings-window/`, `scripts/selftest/typing/clipboard.swift` do script `.sh` tương ứng biên dịch và chạy; hưởng tác dụng phụ của script đó.
- `scripts/probe/tis-probe.swift` (chỉ đọc: một dòng JSON về các nguồn `dau.inputmethod`, `--watch` nghe thông báo) và `scripts/probe/tis-act.swift` (register, enable, select, wait-listed, p1: đổi nguồn nhập liệu) do `scripts/probe/build-tools.sh` biên dịch; `tis-act` chỉ chạy qua `step.sh`. `scripts/probe/settings-ax.swift` (cũng do `build-tools.sh` biên dịch) bấm nút và chọn dòng trong System Settings qua trợ năng (hộp thoại "Allow", sheet Input Sources, "–"), để phiên chính tự chạy các ca thử thay vì người dùng bấm; chiếm màn hình. Tác dụng phụ của từng file ghi ở dòng đầu file.
- `scripts/check-docs/superseded.txt`: danh sách cách nói đã bị thay, do `check.sh` đọc.
