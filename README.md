<p align="center">
  <img src="Resources/Brand/AppIcon.svg" width="128" alt="Biểu tượng Dấu">
</p>

<h1 align="center">Dấu</h1>

<p align="center"><strong>Gõ tiếng Việt trên Mac, dấu nào vào đúng chỗ nấy.</strong></p>

<p align="center">Miễn phí trọn vẹn · Mã nguồn mở · macOS 14 trở lên</p>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/canvas/SettingsDark.png">
    <img src="docs/canvas/SettingsTyping.png" width="720" alt="Cửa sổ Cài đặt của Dấu, trang Gõ phím: xem trước &quot;hoaf binhf, tieengs Vieetj&quot; thành &quot;hoà bình, tiếng Việt&quot;">
  </picture>
</p>

---

### Gõ tiếng Việt, đúng từng dấu.

Telex, VNI hay Telex đơn giản. Dấu thanh tự vào đúng nguyên âm theo chính tả, kiểu mới (hoà, thuý) hay kiểu cũ (hòa, thúy) tuỳ bạn chọn. Từ đã sai chính tả thì Dấu thôi biến đổi, không đoán thay bạn.[^1]

### Dấu đặt ở đâu cũng được.

Phím dấu không cần đứng sát chữ. `tuongw` ra tương, `hoaf` ra hoà, và dấu tự dời về đúng chỗ khi bạn gõ thêm nguyên âm.

### Quên dấu? Quay lại thêm.

Đặt con trỏ sau một từ đã gõ không dấu, gõ phím dấu: `viet` thêm `ej` thành việt. Bấm ⌫ thì Dấu bỏ chữ cuối và đặt lại dấu theo vần còn lại: hoà thành hò.

### Câu có chữ tiếng Anh? Cứ gõ.

"Sếp vừa gửi email về buổi meeting chiều nay." Gõ một mạch, không phải chuyển bàn phím: từ nào không thành tiếng Việt, Dấu trả lại đúng các phím bạn đã gõ, không cần từ điển.[^2] Muốn giữ chữ gốc ngay giữa từ thì gõ đúp phím dấu: `carr` ra car.


### Là một phần của macOS.

Dấu là một nguồn đầu vào như mọi bàn phím khác trên Mac. Chuyển Việt/Anh bằng chính phím tắt và menu nguồn đầu vào của macOS, không xin quyền Trợ năng.[^3] Chữ được thay ngay tại chỗ qua API nhập liệu của Apple, không giả lập phím Backspace.

### Những gì bạn gõ ở lại trên máy bạn.

Bộ gõ không có quyền kết nối mạng. Không telemetry. Bản phát hành không ghi lại phím nào bạn gõ, kể cả thời điểm gõ hay ứng dụng đang gõ.[^4]

### Ít hơn, có chủ đích.

Việc macOS đã làm tốt, Dấu không làm lại: gõ tắt văn bản đã có Thay thế văn bản, chuyển Việt/Anh đã có phím tắt nguồn đầu vào. Không bảng mã cũ, không quảng cáo, không bản trả phí. Mọi quy tắc gõ đều được viết ra, kèm lý do, trong [`docs/DECISIONS.md`](docs/DECISIONS.md).

---

## Sắp ra mắt

Dấu chưa có bản tải về. Đang ở đâu: [`docs/PROGRESS.md`](docs/PROGRESS.md). Các mốc tới khi phát hành: [`docs/ROADMAP.md`](docs/ROADMAP.md). Những ứng dụng đã thử và giới hạn còn lại: [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md).

## Dành cho nhà phát triển

**Yêu cầu:** macOS 14 trở lên, Xcode, [XcodeGen](https://github.com/yonaskolb/XcodeGen), một Apple ID (Personal Team miễn phí là đủ).

**Build và cài trên máy bạn:**

```sh
brew install xcodegen
cp Config/Local.xcconfig.example Config/Local.xcconfig   # điền Team ID của bạn
scripts/dev/install-app.sh
```

Rồi mở Dấu trong `/Applications` và bấm "Bật Dấu". Máy thiếu gì thì `scripts/dev/doctor.sh` chỉ ra kèm lệnh sửa. Chi tiết từng bước: [CONTRIBUTING.md](CONTRIBUTING.md).

**Chạy test engine** (không cần Apple ID):

```sh
swift test --package-path Packages/DauEngine
```

**Cấu trúc:**

| | |
|---|---|
| `Packages/DauEngine` | Mọi quy tắc gõ. Swift thuần, không Foundation, không AppKit. |
| `Apps/DauInputMethod` | Bộ gõ, dựng trên InputMethodKit. Sandbox, không có quyền mạng. |
| `Apps/Dau` | App SwiftUI: Cài đặt, bật, cập nhật, gỡ bộ gõ. |
| `Packages/DauShared` | Phần dùng chung giữa app và bộ gõ. |

Kiến trúc và luồng một phím: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md). Thiết kế mọi màn hình: [`docs/canvas/README.md`](docs/canvas/README.md). Mục lục tài liệu: [`docs/README.md`](docs/README.md). Làm việc cùng Claude Code: [CLAUDE.md](CLAUDE.md).

**Báo lỗi gõ:** mở issue, kèm tên ứng dụng, Telex hay VNI, và chuỗi phím đã gõ. Đừng dán nội dung riêng tư.

## Giấy phép

GPLv3. Xem [LICENSE](LICENSE).
[^1]: D15 (Cài đặt mặc định), D30 (Kiểm tra chính tả). Trên 678 từ trong các câu tiếng Việt, gõ trong Safari và Chrome trên macOS 27.2, Dấu ra đúng 677 từ; từ còn lại là "taxi" thành "tãi", vì đó là âm tiết tiếng Việt hợp lệ. Điều kiện đo: [`docs/research/COMPETITOR-COMPARISON.md`](https://github.com/codefastlabs/dau/blob/main/docs/research/COMPETITOR-COMPARISON.md).
[^2]: D4 (Từ nước ngoài). Cùng lượt đo: trong câu trộn Việt–Anh, Dấu ra đúng 184/188 từ; với 105 từ tiếng Anh và từ trong mã có chứa phím dấu Telex, Dấu giữ nguyên 88 từ, 7 từ ra sai, 10 từ trùng với một từ tiếng Việt. Ở ứng dụng bật tự sửa chính tả, macOS có thể sửa từ vừa gõ sau dấu cách, với mọi bộ gõ; hoàn tác bằng ⌘Z.
[^3]: D2 (Chuyển Việt/Anh). Đã thử không cần quyền Trợ năng trong Chrome, VS Code và Terminal: mục "Câu hỏi đã trả lời" của `docs/DECISIONS.md`.
[^4]: N2 (Bộ gõ không có quyền mạng), D8 (Không telemetry).
