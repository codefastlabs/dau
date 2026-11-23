<p align="center">
  <img src="Resources/Brand/AppIcon.svg" width="128" alt="Biểu tượng Dấu">
</p>

<h1 align="center">Dấu</h1>

<p align="center"><strong>Bộ gõ tiếng Việt tự nhiên và chuẩn xác cho macOS.</strong></p>

<p align="center">Hoàn toàn miễn phí · Mã nguồn mở · Thiết kế riêng cho macOS</p>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/canvas/SettingsDark.png">
    <img src="docs/canvas/SettingsTyping.png" width="720" alt="Cửa sổ Cài đặt của Dấu, trang Gõ phím: xem trước &quot;hoaf binhf, tieengs Vieetj&quot; thành &quot;hoà bình, tiếng Việt&quot;">
  </picture>
</p>

---

### Không phải đánh đổi khi gõ tiếng Việt

Người gõ tiếng Việt trên Mac thường phải chọn một trong hai đường. Đường thứ nhất là dùng bộ gõ có sẵn của macOS và chịu những chỗ bộ gõ này gõ chưa đúng. Đường thứ hai là cài một bộ gõ của bên thứ ba. Khi đó người dùng phải cấp cho bộ gõ quyền can thiệp vào hệ thống và để bộ gõ xoá rồi gõ lại chữ bằng phím giả. Dấu ra đời để người gõ không phải chọn như vậy. Dấu đặt dấu đúng chính tả và cài vào macOS như một bàn phím, giống mọi bàn phím có sẵn của máy.

### Đúng chính tả, theo kiểu đặt dấu mới hay cũ

Dấu có ba kiểu gõ là Telex, VNI và Telex đơn giản. Dấu thanh luôn tự vào đúng nguyên âm theo chính tả. Bạn chọn được kiểu đặt dấu mới (hoà, thuý) hoặc kiểu cũ (hòa, thúy). Khi một từ đã sai chính tả, Dấu ngừng biến đổi từ đó chứ không đoán thay bạn.[^1] Trong một lượt gõ thử 60 câu văn xuôi tiếng Việt hiện đại trên Safari và Chrome, Dấu gõ đúng 677 trên 678 từ.[^2]

### Gõ phím dấu ở đâu trong từ cũng được

Bạn không cần gõ phím dấu ngay sau chữ cái mang dấu. Chuỗi `tuongw` ra "tương", còn chuỗi `hoaf` ra "hoà". Khi bạn gõ thêm nguyên âm, dấu thanh tự dời về đúng chỗ.[^3]

### Thêm dấu cho từ đã gõ

Bạn có thể đặt con trỏ ngay sau một từ đã gõ không dấu rồi gõ phím dấu. Dấu sẽ thêm dấu vào từ đó, ví dụ gõ thêm `ej` sau `viet` sẽ ra "việt". Khi bạn bấm ⌫, Dấu xoá chữ cái cuối và đặt lại dấu theo phần vần còn lại, ví dụ "hoà" thành "hò".[^4]

### Gõ câu xen tiếng Anh mà không chuyển bàn phím

Bạn có thể gõ một câu xen tiếng Anh như "Sếp vừa gửi email về buổi meeting chiều nay" mà không phải chuyển bàn phím. Khi một từ kết thúc mà không phải âm tiết tiếng Việt hợp lệ, Dấu trả lại đúng các phím bạn đã gõ. Dấu làm được điều đó mà không cần từ điển. Muốn giữ chữ gốc ngay giữa từ thì bạn gõ đúp phím dấu, ví dụ gõ `carr` để được "car".[^5]

### Cài vào macOS như một bàn phím

Dấu cài vào macOS như một bàn phím, giống bàn phím ABC hay bộ gõ tiếng Việt có sẵn của máy. macOS gọi chung các bàn phím và bộ gõ này là nguồn đầu vào. Danh sách của chúng nằm ở Cài đặt hệ thống › Bàn phím › Nguồn đầu vào. Dấu không phải một ứng dụng chạy riêng bên ngoài để chặn phím bạn gõ. Bạn chuyển giữa tiếng Việt và tiếng Anh như chuyển giữa các bàn phím khác, bằng phím tắt của macOS hoặc bằng menu nguồn đầu vào. Menu này mở ra khi bạn bấm vào biểu tượng của bàn phím đang dùng ở góc phải thanh menu. Bạn cũng không phải cấp quyền Trợ năng (Accessibility).[^6] Dấu thay chữ tại chỗ qua API nhập liệu của Apple, không giả lập phím Backspace.

### Chữ bạn gõ không rời khỏi máy

Bộ gõ nào cũng thấy mọi chữ bạn gõ, từ tin nhắn riêng tới tài liệu công việc. Vì vậy Dấu được dựng để không mang được chữ đó đi đâu. Phần gõ chữ của Dấu chạy trong vùng cách ly của macOS (sandbox) và không được phép kết nối mạng, nên tự nó không mở được kết nối nào ra ngoài. Dấu không gửi dữ liệu sử dụng nào đi. Bản cài chính thức không ghi lại phím bạn bấm, thời điểm bạn gõ hay ứng dụng bạn đang dùng.[^7]

### Không làm lại việc macOS đã làm

Việc nào macOS đã làm thì Dấu để macOS làm. Muốn gõ tắt cả cụm từ thì macOS đã có mục Thay thế văn bản (Text Replacement). Muốn chuyển ngôn ngữ thì macOS đã có phím tắt nguồn đầu vào. Dấu không có bảng mã cũ, không có quảng cáo và không có bản trả phí. Mọi quy tắc gõ cùng lý do của từng quy tắc ghi trong [`docs/Decisions.md`](docs/Decisions.md).

---

## Sắp ra mắt

Dấu chưa có bản cài để tải về. Dấu nhắm tới macOS 14 trở lên, nhưng tới nay mới chạy thử trên macOS 27.2 với máy Apple silicon và macOS 15.8.1 với máy Intel. Bản beta đầu tiên chỉ hứa những điều đã kiểm chứng.[^8] Các mốc phát triển ghi ở [`docs/Roadmap.md`](docs/Roadmap.md). Các ứng dụng đã thử và các giới hạn còn lại ghi ở [`docs/Compatibility.md`](docs/Compatibility.md).

## Dành cho nhà phát triển

Cách build, cách cài bộ gõ bằng Apple ID cá nhân và cách chạy các bộ test ghi ở [CONTRIBUTING.md](CONTRIBUTING.md). Riêng test của engine thì bạn chạy được mà không cần Apple ID, bằng lệnh sau:

```sh
swift test --package-path Packages/DauEngine
```

Các tài liệu sau giúp bạn tìm hiểu thêm về dự án:
- Kiến trúc, cấu trúc thư mục và luồng xử lý một phím mô tả ở [`docs/Architecture.md`](docs/Architecture.md).
- Bản thiết kế của mọi màn hình nằm ở [`docs/canvas/README.md`](docs/canvas/README.md).
- Mục lục mọi tài liệu kỹ thuật và nghiên cứu nằm ở [`docs/README.md`](docs/README.md).
- Luật làm việc cho công cụ phát triển (Claude Code) nằm ở [CLAUDE.md](CLAUDE.md).

Để báo lỗi gõ, bạn mở một issue trên GitHub và ghi tên ứng dụng bị lỗi, kiểu gõ đang dùng (Telex, VNI hay Telex đơn giản) và chuỗi phím đã gõ. Đừng dán thông tin hay nội dung riêng tư vào phần mô tả lỗi.

## Giấy phép

Dấu phát hành theo giấy phép GNU General Public License v3.0 (GPLv3). Toàn văn giấy phép nằm trong file [LICENSE](LICENSE).

[^1]: Theo các quyết định D15 (Cài đặt mặc định), D29 (Telex đơn giản) và D30 (Kiểm tra chính tả). Các test `TonePlacementTests`, `VNITests` và `SpellingTests` của engine kiểm hành vi này. Các test nằm ở [`Packages/DauEngine/Tests`](https://github.com/codefastlabs/dau/tree/main/Packages/DauEngine/Tests).
[^2]: Số này lấy từ một lượt đo ngày 09/11/2026 trên một máy chạy macOS 27.2, gõ Telex theo thứ tự chuẩn, mỗi phím cách nhau 30 ms. Từ sai duy nhất là "taxi" ra "tãi", vì "tãi" là âm tiết tiếng Việt hợp lệ và quyết định D4 (Từ nước ngoài) cho tiếng Việt thắng. Cách chấm không xét vị trí dấu thanh. Điều kiện đo và giới hạn của lượt đo nằm ở [`docs/research/CompetitorComparison.md`](https://github.com/codefastlabs/dau/blob/main/docs/research/CompetitorComparison.md), mục 1.
[^3]: Theo quyết định D28 (Đặt dấu tự do). Test `TonePlacementTests` của engine kiểm hành vi này. Các test nằm ở [`Packages/DauEngine/Tests`](https://github.com/codefastlabs/dau/tree/main/Packages/DauEngine/Tests).
[^4]: Theo các quyết định D20 (Thêm dấu cho từ đã gõ) và D32 (Backspace). Thêm dấu cho từ đã gõ không áp dụng ở ứng dụng mà người dùng bật gạch chân, theo quyết định D13 (Gạch chân là đường lui cuối cùng). Ghostty là một ví dụ, vì Dấu đề xuất bật gạch chân cho trình giả lập dòng lệnh này theo quyết định D43 (Ô bỏ qua vùng thay chữ). Các quyết định nằm ở [`docs/Decisions.md`](https://github.com/codefastlabs/dau/blob/main/docs/Decisions.md).
[^5]: Theo các quyết định D4 (Từ nước ngoài) và D26 (Gõ đúp phím dấu). Trong cùng lượt đo với chú thích [^2], Dấu xử lý đúng 184 trên 188 từ ở các câu trộn tiếng Việt và tiếng Anh. Với danh sách 105 từ tiếng Anh và từ khoá lập trình có chứa phím dấu của Telex, Dấu giữ nguyên 88 từ, xử lý sai 7 từ và có 10 từ trùng với một âm tiết tiếng Việt hợp lệ. Ở các ứng dụng bật tự sửa chính tả của macOS, hệ thống có thể sửa từ vừa gõ sau khi bạn bấm phím cách. Hệ thống làm vậy với mọi bộ gõ. Bạn hoàn tác được bằng ⌘Z. Số liệu nằm ở [`docs/research/CompetitorComparison.md`](https://github.com/codefastlabs/dau/blob/main/docs/research/CompetitorComparison.md), mục 1.
[^6]: Theo quyết định D2 (Chuyển Việt/Anh) và nguyên tắc N4 (Không tự đổi cài đặt hệ thống). Dấu không xin quyền Trợ năng, vì thay chữ tại chỗ không cần quyền đó, kể cả ở Chrome, VS Code và Terminal. Nguồn nằm ở [`docs/Decisions.md`](https://github.com/codefastlabs/dau/blob/main/docs/Decisions.md), mục N4.
[^7]: Theo nguyên tắc N2 (Bộ gõ không có quyền mạng) và quyết định D8 (Không telemetry). Hai mục này nằm ở [`docs/Decisions.md`](https://github.com/codefastlabs/dau/blob/main/docs/Decisions.md).
[^8]: Theo quyết định D1 (Nền tảng) và nguyên tắc N5 (Chỉ hứa điều đã kiểm chứng). Hai mục này nằm ở [`docs/Decisions.md`](https://github.com/codefastlabs/dau/blob/main/docs/Decisions.md). Bản beta đầu tiên thuộc mốc M7 (Phát hành) trong [`docs/Roadmap.md`](https://github.com/codefastlabs/dau/blob/main/docs/Roadmap.md).
