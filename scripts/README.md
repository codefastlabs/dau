# Scripts

Mỗi script có dòng `# Side effects:` ở đầu file (ngay sau dòng chú thích đầu tiên), dùng đúng các từ trong bảng chú giải dưới đây. `scripts/check-docs/check.sh` kiểm: script nào thiếu dòng này, hoặc chưa có trong bảng, hoặc đường dẫn trong bảng không tồn tại thì báo lỗi.

| Đường dẫn | Làm gì | Tác dụng phụ | Ai chạy | Gọi từ |
|---|---|---|---|---|
| `scripts/check-docs/check.sh` | Kiểm tài liệu lệch (đường dẫn, số D/N, cách nói đã bị thay, cỡ file, ghi chú nghiên cứu, danh sách script). | none | agent | CLAUDE.md, `.claude/commands/milestone.md`, `.claude/agents/auditor.md` |
| `scripts/dau-version.sh` | Bản bộ gõ đã cài và đang chạy có đúng commit mới nhất không. | none | agent | CLAUDE.md, docs/ARCHITECTURE.md |
| `scripts/perf-report.sh` | Đọc nhật ký hệ thống, in p50/p99 từng thao tác của bộ gõ theo app. | none | agent | docs/COMPATIBILITY.md, `scripts/selftest-typing/run.sh` |
| `scripts/stamp-build-commit.sh` | Ghi mã commit vào `build/generated/BuildCommit.txt` cho bản build. | builds | agent | `project.yml` (preGenCommand và build phase) |
| `scripts/make-app-icon.sh` | Sinh lại biểu tượng app tạm (SVG và iconset). | writes repo files | agent | chạy tay; `project.yml` (chú thích) |
| `scripts/make-mode-icons.sh` | Sinh lại biểu tượng chế độ gõ "V" tạm của bộ gõ. | writes repo files | agent | chạy tay; `Apps/DauInputMethod/Info.plist` (chú thích) |
| `scripts/install-debug.sh` | Build và cài bộ gõ vào `~/Library/Input Methods`, dừng tiến trình cũ. Với `--build-only` chỉ build (tác dụng phụ: builds, agent chạy được). | builds, installs input method, kills processes | người dùng, hỏi giờ trước | README.md, docs/COMPATIBILITY.md, `scripts/selftest-app-group.sh` (`--install`) |
| `scripts/selftest-app-group.sh` | Thử không cần gõ: cài đặt app chủ lưu có tới được bộ gõ qua App Group không. Chỉ có `--install` mới cài bộ gõ và dừng tiến trình. | builds, changes input source, changes user settings (và với `--install`: installs input method, kills processes) | người dùng, hỏi giờ trước | docs/ARCHITECTURE.md, docs/research/M5-INSTALL.md |
| `scripts/selftest-typing/run.sh` | Gõ một câu vào app thật bằng bộ gõ Dấu rồi đọc lại chữ ra. | builds, takes the screen, changes input source, changes user settings | người dùng, hỏi giờ trước | docs/ARCHITECTURE.md, docs/COMPATIBILITY.md |
| `scripts/check-settings-window/run.sh` | Kiểm cửa sổ Cài đặt thật: chụp ngoài màn hình, mở app thật, đọc khung qua Accessibility. | builds, takes the screen, kills processes | người dùng, hỏi giờ trước | CLAUDE.md, docs/UI-CHECKS.md, `.claude/agents/app-ui-dev.md` |
| `scripts/clean-dau.sh` | Liệt kê mọi dấu vết của Dấu trên tài khoản; với `--yes` thì xoá những gì xoá được. Không tham số thì chỉ đọc (tác dụng phụ: none, agent chạy được). | kills processes, deletes data, changes user settings, changes input source (chỉ với `--yes`) | người dùng, hỏi giờ trước | CLAUDE.md, docs/research/M5-INSTALL.md |

## Chú giải tác dụng phụ

| Từ | Nghĩa |
|---|---|
| `none` | chỉ đọc; không ghi gì ngoài file tạm |
| `builds` | chạy xcodegen, xcodebuild hoặc swiftc; ghi vào `build/` hoặc thư mục tạm, không đổi file được theo dõi bởi git |
| `writes repo files` | ghi đè file được theo dõi bởi git trong repo (xem bằng `git diff`) |
| `installs input method` | chép bộ gõ vào `~/Library/Input Methods` |
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

- `scripts/lib/input-source.swift`: công cụ dòng lệnh nhỏ (đọc, chọn nguồn nhập liệu) mà `selftest-app-group.sh` và `selftest-typing/run.sh` tự biên dịch; hưởng tác dụng phụ của script gọi nó.
- Các file `.swift` trong `scripts/make-*.swift`, `scripts/check-settings-window/`, `scripts/selftest-typing/clipboard.swift` do script `.sh` tương ứng biên dịch và chạy; hưởng tác dụng phụ của script đó.
- `scripts/check-docs/superseded.txt`: danh sách cách nói đã bị thay, do `check.sh` đọc.
