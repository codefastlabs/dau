<p align="center">
  <img src="Resources/Brand/AppIcon.svg" width="128" alt="Biểu tượng Dấu">
</p>

<h1 align="center">Dấu</h1>

<p align="center"><strong>Gõ tiếng Việt trên Mac, dấu nào vào đúng chỗ nấy.</strong></p>

<p align="center">Miễn phí trọn vẹn · Mã nguồn mở · cho macOS</p>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/canvas/SettingsDark.png">
    <img src="docs/canvas/SettingsTyping.png" width="720" alt="Cửa sổ Cài đặt của Dấu, trang Gõ phím: xem trước &quot;hoaf binhf, tieengs Vieetj&quot; thành &quot;hoà bình, tiếng Việt&quot;">
  </picture>
</p>

---

### Gõ tiếng Việt, đúng từng dấu.

Dấu hỗ trợ đầy đủ các kiểu gõ phổ biến gồm Telex, VNI và Telex đơn giản. Dấu thanh luôn tự động đặt vào đúng nguyên âm theo quy tắc chính tả, đồng thời bạn có thể tùy chọn giữa kiểu đặt dấu mới (hoà, thuý) hoặc kiểu cũ (hòa, thúy). Khi một từ đã sai quy tắc chính tả, Dấu sẽ dừng biến đổi chứ không tự ý phỏng đoán thay bạn.[^1] Trong bài kiểm thử thực tế với 60 câu tiếng Việt thông dụng trên Safari và Chrome, Dấu cho kết quả chính xác 677 trên tổng số 678 từ.[^2]

### Dấu đặt ở đâu cũng được.

Bạn không cần phải gõ phím dấu ngay sát nguyên âm. Ví dụ, chuỗi `tuongw` sẽ cho ra chữ "tương" và `hoaf` sẽ cho ra chữ "hoà". Khi bạn gõ tiếp các nguyên âm sau đó, dấu thanh sẽ tự động dời về đúng vị trí chuẩn xác.[^3]

### Quên dấu? Quay lại thêm.

Bạn có thể đặt con trỏ chuột ngay sau một từ đã gõ không dấu rồi bấm phím dấu để bổ sung, chẳng hạn như gõ thêm `ej` sau chữ `viet` để tạo thành "việt". Khi bạn nhấn phím ⌫, Dấu sẽ xoá ký tự cuối cùng và tự động sắp xếp lại dấu thanh theo đúng vần còn lại, như chuyển "hoà" thành "hò".[^4]

### Câu có chữ tiếng Anh? Cứ gõ.

Bạn có thể gõ liền mạch một câu xen lẫn tiếng Anh như "Sếp vừa gửi email về buổi meeting chiều nay" mà không cần phải chuyển đổi bàn phím. Nếu từ đang gõ không tạo thành một âm tiết tiếng Việt hợp lệ, Dấu sẽ tự động khôi phục lại chính xác các ký tự phím bạn đã gõ mà không cần dùng đến từ điển.[^5] Trong trường hợp muốn giữ nguyên ký tự gốc ngay giữa từ, bạn chỉ cần gõ đúp phím dấu, ví dụ gõ `carr` sẽ cho ra chữ "car".

### Là một phần của macOS.

Dấu hoạt động như một nguồn đầu vào gốc tương tự các bàn phím mặc định khác trên hệ điều hành. Bạn có thể chuyển đổi giữa tiếng Việt và tiếng Anh bằng chính phím tắt cùng menu nguồn đầu vào của macOS mà không cần cấp quyền Trợ năng (Accessibility).[^6] Toàn bộ thao tác thay chữ được thực hiện trực tiếp tại chỗ thông qua API nhập liệu chính thức của Apple, hoàn toàn không giả lập phím Backspace.

### Những gì bạn gõ ở lại trên máy bạn.

Bộ gõ hoàn toàn không có quyền kết nối mạng và không chứa bất kỳ cơ chế thu thập dữ liệu (telemetry) nào. Bản phát hành chính thức (Release) không ghi lại bất kỳ phím bấm nào của bạn, đồng thời không lưu trữ thời điểm gõ hay ứng dụng mà bạn đang làm việc.[^7]

### Ít hơn, có chủ đích.

Dấu không làm lại những tính năng mà hệ điều hành macOS đã giải quyết hiệu quả. Chẳng hạn, tính năng gõ tắt đã có sẵn mục Thay thế văn bản (Text Replacement) của hệ thống, còn việc chuyển đổi ngôn ngữ đã có phím tắt nguồn đầu vào chuyên dụng. Ứng dụng không hỗ trợ các bảng mã cũ, không chứa quảng cáo và không có các phiên bản trả phí. Toàn bộ các quy tắc gõ cùng lý do đằng sau đều được ghi nhận chi tiết và minh bạch trong [`docs/Decisions.md`](docs/Decisions.md).

---

## Sắp ra mắt

Hiện tại Dấu chưa phát hành bản cài đặt tải về công khai. Ứng dụng được thiết kế cho macOS 14 trở lên (theo quyết định D1 (Nền tảng)), nhưng đến nay mới được thử nghiệm kỹ lưỡng trên macOS 27.2 và kiến trúc Apple silicon; bản beta đầu tiên chỉ cam kết những điều đã được kiểm chứng thực tế.[^8] Bạn có thể theo dõi lộ trình phát triển chi tiết tại [`docs/Roadmap.md`](docs/Roadmap.md), cũng như xem danh sách các ứng dụng đã thử nghiệm và các giới hạn kỹ thuật còn lại tại [`docs/Compatibility.md`](docs/Compatibility.md).

## Dành cho nhà phát triển

Hướng dẫn biên dịch, cài đặt bộ gõ bằng tài khoản Apple ID cá nhân và quy trình chạy các bộ kiểm thử được ghi chi tiết tại tài liệu [CONTRIBUTING.md](CONTRIBUTING.md). Bạn có thể kiểm thử riêng thư viện engine mà không cần tài khoản Apple ID bằng lệnh sau:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path Packages/DauEngine
```

Để tìm hiểu sâu hơn về dự án, bạn có thể tham khảo các tài liệu kỹ thuật sau:
- Tổng quan kiến trúc, cấu trúc thư mục và luồng xử lý phím được mô tả tại [`docs/Architecture.md`](docs/Architecture.md).
- Bản vẽ thiết kế của toàn bộ các màn hình giao diện được lưu trữ tại [`docs/canvas/README.md`](docs/canvas/README.md).
- Mục lục toàn bộ tài liệu kỹ thuật và nghiên cứu của dự án nằm tại [`docs/README.md`](docs/README.md).
- Hướng dẫn phối hợp cùng công cụ phát triển nằm tại [CLAUDE.md](CLAUDE.md).

Khi báo lỗi gõ phím, bạn vui lòng mở một issue mới trên GitHub, nêu rõ tên ứng dụng gặp lỗi, kiểu gõ đang dùng (Telex hay VNI) cùng chuỗi phím bấm cụ thể đã gõ. Bạn lưu ý không dán các thông tin hoặc nội dung riêng tư vào phần mô tả lỗi.

## Giấy phép

Dự án được phát hành dưới giấy phép mã nguồn mở GNU General Public License v3.0 (GPLv3). Bạn có thể xem toàn văn giấy phép tại tệp [LICENSE](LICENSE).

[^1]: Quy tắc được quy định tại các quyết định D15 (Cài đặt mặc định), D29 (Telex đơn giản) và D30 (Kiểm tra chính tả). Hành vi này được kiểm chứng thông qua các bài kiểm thử của engine (`TonePlacementTests`, `VNITests`, `SpellingTests`) tại [`Packages/DauEngine/Tests`](https://github.com/codefastlabs/dau/tree/main/Packages/DauEngine/Tests).
[^2]: Kết quả từ một lượt đo thực hiện vào ngày 09/11/2026 trên một máy chạy macOS 27.2: gõ Telex theo thứ tự chuẩn với khoảng cách giữa các phím là 30 ms. Từ sai duy nhất là "taxi" bị biến đổi thành "tãi" do đây là một âm tiết tiếng Việt hợp lệ (theo quyết định D4 (Từ nước ngoài)). Phương pháp chấm điểm không xét vị trí dấu thanh. Bạn có thể xem chi tiết điều kiện đo và giới hạn tại [`docs/research/CompetitorComparison.md`](https://github.com/codefastlabs/dau/blob/main/docs/research/CompetitorComparison.md), mục 1.
[^3]: Quy tắc được quy định tại quyết định D28 (Đặt dấu tự do). Hành vi này được kiểm chứng qua các bài kiểm thử của engine (`TonePlacementTests`) tại [`Packages/DauEngine/Tests`](https://github.com/codefastlabs/dau/tree/main/Packages/DauEngine/Tests).
[^4]: Quy tắc được quy định tại quyết định D20 (Thêm dấu cho từ đã gõ) và D32 (Backspace). Tính năng thêm dấu cho từ đã gõ không áp dụng trên các ứng dụng đang bật chế độ gạch chân (theo quyết định D13 (Gạch chân là đường lui cuối cùng)), ví dụ như trình giả lập dòng lệnh Ghostty (theo quyết định D43 (Ô bỏ qua vùng thay chữ)).
[^5]: Quy tắc được quy định tại quyết định D4 (Từ nước ngoài). Trong cùng lượt đo với chú thích [^2], ở các câu trộn lẫn tiếng Việt và tiếng Anh, Dấu xử lý chính xác 184 trên 188 từ. Với danh sách 105 từ tiếng Anh và từ khóa lập trình có chứa các phím dấu Telex, Dấu giữ nguyên được 88 từ, xử lý sai 7 từ và có 10 từ trùng với một âm tiết tiếng Việt hợp lệ. Trên các ứng dụng bật tính năng tự động sửa chính tả của macOS, hệ thống có thể tự điều chỉnh từ vừa gõ sau khi bấm dấu cách đối với mọi bộ gõ; người dùng có thể hoàn tác bằng tổ hợp phím ⌘Z. Nguồn số liệu nằm tại [`docs/research/CompetitorComparison.md`](https://github.com/codefastlabs/dau/blob/main/docs/research/CompetitorComparison.md), mục 1.
[^6]: Quy tắc được quy định tại quyết định D2 (Chuyển Việt/Anh). Dấu đã được kiểm nghiệm thực tế và hoạt động bình thường mà không cần cấp quyền Trợ năng trên Chrome, VS Code và Terminal. Nguồn dữ liệu nằm tại [`docs/Decisions.md`](https://github.com/codefastlabs/dau/blob/main/docs/Decisions.md), nguyên tắc N4 (Không tự đổi cài đặt hệ thống).
[^7]: Quy tắc được quy định tại các nguyên tắc N2 (Bộ gõ không có quyền mạng) và D8 (Không telemetry). Nguồn dữ liệu nằm tại [`docs/Decisions.md`](https://github.com/codefastlabs/dau/blob/main/docs/Decisions.md).
[^8]: Quy tắc được quy định tại quyết định D1 (Nền tảng). Nguồn dữ liệu nằm tại [`docs/Decisions.md`](https://github.com/codefastlabs/dau/blob/main/docs/Decisions.md); các mốc phát triển đã thử nghiệm được ghi nhận tại [`docs/Roadmap.md`](https://github.com/codefastlabs/dau/blob/main/docs/Roadmap.md), mốc M7.
