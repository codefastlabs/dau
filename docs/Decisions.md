# Sổ quyết định

Nguồn chuẩn duy nhất cho mọi nguyên tắc (N) và quyết định (D) đang có hiệu lực. Mỗi mục có số và tên ngắn; tài liệu khác dẫn dạng "D4 (Từ nước ngoài)", lần dẫn đầu trong mỗi file kèm tên.

- **Cách đọc:** tra số ở mục lục. Mỗi quyết định gồm luật, hệ quả đã chấp nhận (nếu có), **Vì sao** và **Xem thêm**. Sổ chỉ ghi luật và lý do: cách mã làm ở [`docs/Architecture.md`](Architecture.md), số đo theo ngày ở nhật ký.
- **Cách đổi:** sửa luật và lý do ở đây; ghi ngày, bản cũ và số đo dẫn tới thay đổi vào [`docs/history/DecisionsLog.md`](history/DecisionsLog.md); cùng commit với thay đổi mã.

## Mục lục

| Số | Tên | Luật |
|---|---|---|
| [N1](#n1-không-làm-lại-việc-hệ-thống-đã-có) | Không làm lại việc hệ thống đã có | Hệ thống đã có thì Dấu không làm lại, trừ khi có lý do đo được. |
| [N2](#n2-bộ-gõ-không-có-quyền-mạng) | Bộ gõ không có quyền mạng | Mọi kết nối nằm ở app chủ. |
| [N3](#n3-ít-lời-gọi-vào-ứng-dụng-đích) | Ít lời gọi vào ứng dụng đích | Mỗi phím tối đa một `insertText`; hỏi vị trí và đọc chữ chỉ ở các trường hợp được nêu. |
| [N4](#n4-không-tự-đổi-cài-đặt-hệ-thống) | Không tự đổi cài đặt hệ thống | Chỉ đổi khi người dùng bấm đúng nút làm việc đó. |
| [N5](#n5-chỉ-hứa-điều-đã-kiểm-chứng) | Chỉ hứa điều đã kiểm chứng | Chữ hiển thị cho người dùng là lời hứa đã kiểm chứng. |
| [D1](#d1-nền-tảng) | Nền tảng | Chỉ macOS 14 trở lên, universal, Swift. |
| [D2](#d2-chuyển-việtanh) | Chuyển Việt/Anh | Một input mode "Tiếng Việt"; gõ tiếng Anh bằng nguồn tiếng Anh của macOS. |
| [D3](#d3-không-macro-chỉ-unicode-dựng-sẵn) | Không macro, chỉ Unicode dựng sẵn | Không macro, bảng mã cũ, chuyển mã; chỉ xuất NFC. |
| [D4](#d4-từ-nước-ngoài) | Từ nước ngoài | Từ không phải âm tiết hợp lệ được khôi phục khi kết thúc từ; không từ điển. |
| [D5](#d5-quy-tắc-theo-ứng-dụng) | Quy tắc theo ứng dụng | Quy tắc riêng của app chỉ là có/không gạch chân. |
| [D6](#d6-phát-hành) | Phát hành | GPLv3, DMG ký và notarize, Homebrew cask; không App Store. |
| [D7](#d7-cập-nhật-và-loại-bản-dựng) | Cập nhật và loại bản dựng | Sparkle 2; bản chính thức và bản phát triển; kênh Ổn định/Beta. |
| [D8](#d8-không-telemetry) | Không telemetry | Không gửi gì; bản phát hành không ghi gì theo từng phím. |
| [D9](#d9-giao-diện) | Giao diện | Control hệ thống, theo System Settings; chỉ màu hệ thống. |
| [D10](#d10-engine-tự-viết) | Engine tự viết | Swift thuần; OpenKey chỉ để tham khảo. |
| [D11](#d11-kiểm-tra-ngữ-cảnh) | Kiểm tra ngữ cảnh | Hỏi vị trí ở phím có thay chữ; lệch thì dựng lại, chứng minh app chậm hoặc reset. |
| [D12](#d12-ưu-tiên-tiến-trình) | Ưu tiên tiến trình | Không bật ưu tiên tiến trình khi chưa đo thấy cần. |
| [D13](#d13-gạch-chân-là-đường-lui-cuối-cùng) | Gạch chân là đường lui cuối cùng | Thay tại chỗ; gạch chân chỉ do người dùng bật; nhãn "Đề xuất" theo số đo. |
| [D14](#d14-onboarding) | Onboarding | Ba bước; bước 1 chỉ khi bộ gõ chặn phím đang chạy. |
| [D15](#d15-cài-đặt-mặc-định) | Cài đặt mặc định | Telex, kiểu mới, bỏ dấu tự do, tự khôi phục, thêm dấu cho từ đã gõ. |
| [D16](#d16-bảo-trì-và-gỡ-cài-đặt) | Bảo trì và gỡ cài đặt | Gỡ chỉ chạy sau khi người dùng bỏ Dấu bằng "–". |
| [D17](#d17-trợ-năng) | Trợ năng | VoiceOver đọc tên nguồn do hệ thống; Dấu không thông báo thêm. |
| [D18](#d18-phòng-thủ-với-imk) | Phòng thủ với IMK | Mọi đầu vào có thể bất thường; không crash. |
| [D19](#d19-quay-về-bản-trước) | Quay về bản trước | Tạm tắt tự cập nhật tới khi có bản mới hơn bản lỗi. |
| [D20](#d20-thêm-dấu-cho-từ-đã-gõ) | Thêm dấu cho từ đã gõ | Phím dấu áp lên chữ đang hiện trước con trỏ nếu ra âm tiết hợp lệ. |
| [D21](#d21-gõ-tắt-phụ-âm) | Gõ tắt phụ âm | Tuỳ chọn Nâng cao; chỉ khi kết thúc từ và kết quả hợp lệ. |
| [D22](#d22-gõ-tắt-loại-trừ-z-f-w-j) | Gõ tắt loại trừ z, f, w, j | Hai tuỳ chọn loại trừ nhau. |
| [D23](#d23-w--qu-chỉ-ở-vni) | w → qu chỉ ở VNI | Telex: w đầu từ luôn là ư. |
| [D24](#d24-tên-và-định-danh) | Tên và định danh | "Dấu" luôn có dấu trước người dùng; định danh theo tên miền đảo. |
| [D25](#d25-nhận-diện) | Nhận diện | Biểu tượng chuẩn chỉ ở bản chính thức. |
| [D26](#d26-gõ-đúp-phím-dấu) | Gõ đúp phím dấu | Gõ đúp bỏ dấu và khoá phím dấu tới hết từ, hoặc tới khi ⌫ xoá chữ của phím gõ đúp. |
| [D27](#d27-không-có-phím-gõ-nhanh-ơ-ư) | Không có phím gõ nhanh ơ, ư | `[` và `]` luôn là dấu câu. |
| [D28](#d28-bỏ-dấu-tự-do) | Bỏ dấu tự do | Phím dấu gõ ở đâu cũng được, dấu tự vào đúng chỗ. |
| [D29](#d29-telex-đơn-giản) | Telex đơn giản | Telex trừ w thành ư, `[ ]` và w → qu. |
| [D30](#d30-kiểm-tra-chính-tả) | Kiểm tra chính tả | Từ hết là tiền tố hợp lệ thì ngừng biến đổi. |
| [D31](#d31-âm-tiết-tiếng-việt-hợp-lệ) | Âm tiết tiếng Việt hợp lệ | Định nghĩa theo chính tả chuẩn, nới cho địa danh. |
| [D32](#d32-backspace) | Backspace | Bỏ chữ cuối đang hiện và đặt lại dấu. |
| [D33](#d33-độ-dài-từ) | Độ dài từ | Dài hơn 7 chữ cái thì khôi phục ngay và đi thẳng. |
| [D34](#d34-chữ-hoa-với-phím-biến-đổi) | Chữ hoa với phím biến đổi | Hoa/thường theo chữ cái gõ đầu tiên. |
| [D35](#d35-uơ-và-ươ) | "uơ" và "ươ" | "uơ" ở cuối từ, thành "ươ" khi gõ thêm. |
| [D36](#d36-vni-chữ-số-thành-dấu) | VNI: chữ số thành dấu | Chữ số sau âm tiết hợp lệ thành dấu. |
| [D37](#d37-cài-đặt-bộ-gõ) | Cài đặt bộ gõ | App chủ không sandbox; bản chủ giữ bộ gõ đã cài trùng bản nhúng; kiểm chữ ký. |
| [D38](#d38-chữ-trên-giao-diện) | Chữ trên giao diện | Tên giao diện của macOS hiện đúng như macOS của người dùng. |
| [D39](#d39-ủng-hộ-dự-án) | Ủng hộ dự án | Ủng hộ tự nguyện; Dấu miễn phí trọn vẹn. |
| [D40](#d40-chữ-dựng-sẵn-và-phím-z) | Chữ dựng sẵn và phím z | Chữ dựng sẵn là chữ cái của từ; z không bỏ mũ/móc. |
| [D41](#d41-ngôn-ngữ-giao-diện) | Ngôn ngữ giao diện | Tiếng Việt và tiếng Anh, theo ngôn ngữ ưu tiên của macOS. |
| [D42](#d42-ngưỡng-hiệu-năng) | Ngưỡng hiệu năng | Chạy bài tải nặng trước mỗi bản phát hành; vượt ngưỡng thì không phát hành. |
| [D43](#d43-ô-bỏ-qua-vùng-thay-chữ) | Ô bỏ qua vùng thay chữ | Ô bỏ qua vùng thay nhận ký tự xoá rồi chữ mới. |

Cuối sổ: [Đã biết nhưng không làm](#đã-biết-nhưng-không-làm), [Đã cân nhắc và loại bỏ](#đã-cân-nhắc-và-loại-bỏ), [Câu hỏi mở](#câu-hỏi-mở).

## Nguyên tắc

### N1. Không làm lại việc hệ thống đã có

Hệ thống đã có thì Dấu không tự làm lại. Ngoại lệ phải có lý do đo được (ví dụ D4 (Từ nước ngoài)).

### N2. Bộ gõ không có quyền mạng

Tiến trình bộ gõ không có quyền mạng. Mọi kết nối nằm ở app chủ (cập nhật, danh sách tương thích).

### N3. Ít lời gọi vào ứng dụng đích

Tối thiểu lời gọi vào ứng dụng đích khi đang gõ.

- Mỗi phím tối đa một lần gọi `insertText`.
- Hỏi vị trí con trỏ (`selectedRange`) ở mỗi phím có thay chữ, không tự cộng dồn vị trí từ một vị trí gốc. Phím đi thẳng không hỏi, trừ lần đọc của D20 (Thêm dấu cho từ đã gõ).
- Đọc chữ trước con trỏ chỉ ở các trường hợp một quyết định cho phép, mỗi trường hợp một lần đọc: lệch vị trí và từ đã hết hợp lệ (D11 (Kiểm tra ngữ cảnh)), phím đầu khi chưa biết chữ trước con trỏ (D20), nhận ra ô bỏ qua vùng thay (D43 (Ô bỏ qua vùng thay chữ)).

**Vì sao:** `insertText(_:replacementRange:)` cần vị trí tuyệt đối của từ đang gõ. Tự cộng dồn không cứu được app áp phím bất đồng bộ: vị trí gốc cũng là ảnh chụp cũ, và VS Code đổi gốc toạ độ.

**Xem thêm:** bảng phím nào hỏi gì ở [`docs/Architecture.md`](Architecture.md) mục "Vị trí thay chữ"; chi phí đo được của `selectedRange` ở [`docs/history/DecisionsLog.md`](history/DecisionsLog.md) mục "Vị trí thay chữ".

### N4. Không tự đổi cài đặt hệ thống

Không tự ý đổi cài đặt hệ thống của người dùng.

- Dấu chỉ đổi cài đặt hệ thống khi người dùng bấm đúng nút làm việc đó ("Bật Dấu", "Gỡ cài đặt"), luôn có Hoàn tác hoặc xác nhận, và không bao giờ tự làm. Việc bật vẫn do người dùng xác nhận trong hộp thoại của macOS.
- Mọi thứ khác chỉ hướng dẫn hoặc mở đúng màn hình Cài đặt.
- Sau khi bật phải đọc lại trạng thái thật trước khi báo thành công (N5 (Chỉ hứa điều đã kiểm chứng)).
- Việc đi kèm hai nút đó do quyết định nêu: "Bật Dấu"/"Bật lại" xoá bộ đệm danh sách nguồn và thoát System Settings (D37 (Cài đặt bộ gõ)); "Gỡ cài đặt" xoá bộ đệm của System Settings sau khi người dùng đã bỏ Dấu bằng "–" (D16 (Bảo trì và gỡ cài đặt)).
- Dấu không xin quyền Trợ năng (Accessibility): thay tại chỗ không cần quyền đó, kể cả ở Chrome, VS Code, Terminal.

### N5. Chỉ hứa điều đã kiểm chứng

Chữ hiển thị cho người dùng phải là lời hứa đã kiểm chứng được.

## Quyết định

### D1. Nền tảng

Chỉ macOS, tối thiểu macOS 14, binary universal (Apple silicon + Intel). Swift, Xcode. Không làm Windows/Linux/web.

### D2. Chuyển Việt/Anh

- Dấu chỉ có **một** input mode, "Tiếng Việt".
- Gõ tiếng Anh dùng nguồn nhập liệu tiếng Anh sẵn có của macOS (U.S. — bàn phím mặc định —, ABC…), chuyển bằng phím tắt nguồn nhập liệu của macOS.
- Chỉ báo dưới con trỏ do hệ thống hiển thị (N1 (Không làm lại việc hệ thống đã có)).
- Không có phím chuyển riêng, không thông báo nổi, không âm thanh.
- Từ tiếng Anh lẫn trong câu Việt do D4 lo.

**Vì sao:** một chế độ tiếng Anh trong Dấu chỉ cho phím đi thẳng, trùng bàn phím tiếng Anh của macOS (N1); nó nằm ở nhóm "Tiếng Anh" trong danh sách thêm nguồn nên người dùng không tìm thấy; và nó làm mất các tiện ích chỉ nguồn của macOS có, như dùng Caps Lock để chuyển sang/về bàn phím tiếng Anh.

### D3. Không macro, chỉ Unicode dựng sẵn

Không làm macro (macOS có Thay thế văn bản), viết hoa đầu câu, bảng mã cũ (TCVN3, VNI-Windows…), công cụ chuyển mã (N1). Chỉ xuất Unicode dựng sẵn (NFC).

### D4. Từ nước ngoài

Một quy tắc duy nhất:

- Khi kết thúc từ, từ không phải âm tiết tiếng Việt hợp lệ (D31 (Âm tiết tiếng Việt hợp lệ)) được khôi phục đúng như phím đã gõ (windows, Sunrise).
- Từ vừa là tiếng Anh vừa là tiếng Việt hợp lệ thì tiếng Việt thắng (car → cả, sex → sẽ, as → á). Muốn giữ chữ gốc thì gõ đúp phím dấu theo chuẩn Telex (carr → car).
- Không dùng từ điển tiếng Anh.
- **Ranh giới từ:** mọi ký tự kết thúc từ có in ra (Space, Enter, Tab và **mọi** dấu câu, ký hiệu, kể cả `! ? ( ) "`) kích hoạt kiểm tra và khôi phục như nhau ("windows," → "windows,", "Sunrise!" → "Sunrise!").
- Chỉ reset bộ đệm, **không** khôi phục: mũi tên, Esc, click chuột và tổ hợp có ⌘/⌃/⌥; đổi cài đặt, đổi nguồn nhập liệu, đổi ô nhập hoặc ứng dụng giữa chừng một từ.
- **Mốc khôi phục:** "đúng như phím đã gõ" tính từ mốc gần nhất. Mặc định là đầu từ; sau gõ đúp (D26 (Gõ đúp phím dấu)), sau Backspace (D32 (Backspace)) hoặc khi từ được đọc từ ứng dụng (D20) thì mốc là chữ đang hiển thị lúc đó, cộng các phím gõ sau ("carr␣" → "car␣", "tesst␣" → "test␣", "nha" + f + k␣ → "nhafk␣").

**Giới hạn đã biết — tự sửa chính tả của macOS:** từ macOS 27.2, ở app bật tự sửa chính tả, hệ thống có thể sửa chữ vừa gõ sau dấu cách, với mọi bộ gõ, kể cả chữ Dấu đã trả đúng ("carr" → "car" rồi thành "cả") và chữ cái đứng một mình. Dấu không tắt tự sửa (N4 (Không tự đổi cài đặt hệ thống)) và không chặn hệ thống thêm dấu cho từ gõ không dấu. Người gõ quay lại thêm dấu thì tính trên chữ đang hiện (D20, ý "Từ hệ thống vừa sửa"); Dấu không đoán từ người gõ định viết. Người dùng hoàn tác bằng ⌘Z hoặc bấm vào chữ bị sửa.

**Vì sao:** từ điển tiếng Anh chỉ có tác dụng ở đúng nhóm từ trùng, và ở đó nó làm hỏng các từ tiếng Việt rất phổ biến như "cả", "sẽ". Mũi tên, Esc, click và tổ hợp phím không khôi phục vì lúc đó con trỏ có thể đã đi chỗ khác: chuỗi phím trong bộ đệm không còn ứng với chữ ở vị trí mới, khôi phục theo nó dễ thay sai vùng. Vì vậy bộ đệm bị xoá; phím sau đó chỉ sửa chữ ngay trước con trỏ khi đọc lại được chính chữ đó từ app (D20).

**Xem thêm:** các ca tự sửa đã thấy ở [`docs/Compatibility.md`](Compatibility.md) mục 6.1.

### D5. Quy tắc theo ứng dụng

- Quy tắc riêng của một app chỉ có một nội dung: có/không gạch chân khi gõ trong app đó (D13 (Gạch chân là đường lui cuối cùng)), luôn áp dụng.
- Dấu **không** tự đổi Việt/Anh theo app và không có "Nhớ chế độ theo từng ứng dụng".
- Nhớ nguồn nhập liệu theo từng cửa sổ là việc của tuỳ chọn macOS "Tự động chuyển sang nguồn đầu vào của tài liệu" (Cài đặt Bàn phím › Nguồn đầu vào, N1); trang Ứng dụng chỉ dẫn tới tuỳ chọn đó.

**Vì sao:** Dấu chỉ có một input mode (D2 (Chuyển Việt/Anh)), nên đổi sang U.S. phải gọi `TISSelectInputSource` từ bộ gõ. Đo được: lệnh đổi được nguồn nhưng bước macOS báo cho app đang gõ bị sandbox chặn (`deny mach-lookup com.apple.tsm.portname`, per-pid), thêm temporary-exception không gỡ được; còn khi U.S. đang bật thì Dấu không nhận sự kiện nào để đổi lại. Thêm một tiến trình chạy nền chỉ để đổi nguồn là không đáng.

### D6. Phát hành

GPLv3. DMG ký Developer ID + notarize trên GitHub Releases, Homebrew cask (khai báo `auto_updates true`). Không có Mac App Store.

**Vì sao:** Apple không hỗ trợ phân phối input method qua Mac App Store.

### D7. Cập nhật và loại bản dựng

- Sparkle 2 nằm trong app chủ, appcast ký EdDSA, kênh Ổn định/Beta, có phát hành theo đợt.
- Danh sách ứng dụng tương thích là file JSON có chữ ký, cập nhật riêng (N2 (Bộ gõ không có quyền mạng)).
- Cài bản mới lúc người dùng không gõ, sau đó dừng tiến trình bộ gõ cũ để hệ thống nạp bản mới; cách thay bộ gõ đã cài ở D37, ý "Thay bộ gõ đã cài".
- **Loại bản dựng:** ba trục độc lập, không có loại thứ tư.
  - Cấu hình build: Debug hoặc Release (D8 (Không telemetry) nói khác nhau ở đâu).
  - Người ký: **bản chính thức** là bản ký Developer ID của codefastlabs, đã notarize, và chỉ dựng bằng quy trình phát hành trên CI; mọi bản khác (ký Personal Team, bản người khác tự build hay bản fork) là **bản phát triển**.
  - Kênh: Ổn định hoặc Beta, chỉ có ở bản chính thức.
- Phát hành theo đợt và quay về bản trước (D19 (Quay về bản trước)) dùng lại bản ổn định.
- **Số phiên bản:** `CFBundleVersion` là số build tăng dần, Sparkle so sánh bằng số này; số hiển thị dạng "1.3.0 beta 2", tag git dạng `v1.3.0-beta.2`; bản ổn định dựng lại từ cùng commit với bản beta cuối, số hiển thị không có chữ beta.
- Bản dựng theo từng commit (Nightly), nếu làm, là bản phát triển: CI dựng, chỉ phát qua GitHub, không qua Sparkle.
- Tính năng mới có thể nằm sau công tắc "Thử nghiệm" ngay trong bản ổn định (cài đặt cục bộ), kiểm chéo với các tính năng cùng tác động lên một đầu vào như mọi tính năng khác.
- Không phát hành dần theo số liệu và không có cờ tính năng điều khiển từ xa. Không dùng TestFlight.
- Nhận diện từng loại bản: D25 (Nhận diện).

**Vì sao:** phát hành dần theo số liệu và cờ tính năng điều khiển từ xa đều cần số liệu từ máy người dùng (D8), nên Dấu dựa vào người dùng Beta và báo lỗi. TestFlight chỉ dành cho app phân phối qua App Store (D6 (Phát hành)).

### D8. Không telemetry

- Không telemetry. Báo lỗi qua GitHub issue điền sẵn hoặc "Sao chép nội dung" để gửi email.
- Không bao giờ gửi nội dung người dùng đã gõ.
- Log chẩn đoán dùng `os.Logger`, nằm trên máy.
- Bản phát hành không ghi gì theo từng phím, kể cả không có chữ.
- Nhật ký từng phím chỉ có ở bản Debug và chỉ bật bằng khoá `DauPerfLog`.
- Log của bộ gõ ở bản phát hành cũng không ghi app nào đang gõ hay lúc nào: không có bundle ID của app đích, kể cả theo từng lần kích hoạt; đường dẫn ghi ở mức riêng tư. Log chỉ ghi sự kiện của chính Dấu (khởi chạy, thoát, nạp cài đặt, mở app chủ).

**Vì sao:** giờ và app của từng phím là siêu dữ liệu về cách gõ, và ai chạy được lệnh dưới tài khoản người dùng có thể bật rồi đọc mà không cần quyền Theo dõi đầu vào. Lý do đó áp cho cả app và giờ của từng lần kích hoạt (lúc người dùng đưa focus vào app nào), không chỉ từng phím.

### D9. Giao diện

- Theo macOS hiện hành (mockup vẽ theo macOS 27), dùng control hệ thống qua SwiftUI, cửa sổ Cài đặt có sidebar, không tự vẽ control (N1).
- **Chuẩn đối chiếu:** dùng thành phần của macOS với thông số mặc định. Khi mockup và macOS khác nhau về bố cục, khoảng cách, cỡ chữ hay hình dáng control thì theo **System Settings của macOS hiện hành**.
- Mockup quy định nội dung: có mục nào, chữ gì, thứ tự, icon, màu hệ thống.
- Không chỉnh thông số của thành phần hệ thống để khớp pixel mockup.
- Mọi thay đổi giao diện sửa artboard trên canvas trước, người dùng duyệt, rồi mới sửa mã; mã xong thì đối chiếu lại với artboard.
- **Màu:** chỉ dùng màu hệ thống, không mã hex, không ngoại lệ. Ô icon sidebar dùng `systemBlue/systemPurple/systemOrange/systemGreen` (glyph nét theo mockup), nhãn "Mới" nền `accentColor`, banner "Dấu chưa được bật" dùng cam hệ thống như mockup.
- Nút mở/thu "Nâng cao" ghép từ nút hệ thống + chevron được chấp nhận.
- **Vỏ cửa sổ Cài đặt:** thanh công cụ có cụm Lùi/Tiến như System Settings (lịch sử các mục đã xem); tiêu đề trang là `navigationTitle` của hệ thống; không tự vẽ tiêu đề, không ẩn tiêu đề cửa sổ bằng cách với vào `NSWindow`.
- **Sidebar cố định như System Settings:** độ rộng cố định, không kéo rộng hẹp, không thu gọn, con trỏ ở đường chia là mũi tên thường, không có lệnh "Show/Hide Sidebar" (⌃⌘S). Dựng bằng `NSSplitViewController` của chính app, chỉ dùng thuộc tính có tài liệu Apple; không với vào cấu trúc bên trong của SwiftUI.

**Hệ quả đã chấp nhận:** ô tìm sidebar dùng lề chuẩn của sidebar nên ô tìm và hàng đầu lệch System Settings 1–2 pt; không chỉnh lề cho khớp pixel.

**Vì sao:**

- Chỉnh thông số cho khớp mockup (ví dụ lề hàng sidebar) trong khi app dựng bằng UI thuần vừa trái N1 vừa dễ vỡ khi macOS đổi.
- Nút "Nâng cao": System Settings không có hàng mở/thu nào, còn `DisclosureGroup` trong Form không có vạch ngăn dưới hàng mở và không có AXPress cho trợ năng (đo trên macOS 27.2).
- Sidebar cố định: kéo thu sidebar bị giật và System Settings không cho thu. SwiftUI không có API khoá sidebar của `NavigationSplitView`, nên dùng `NSSplitViewController` của chính app. Đã loại: duyệt cây view tìm `NSSplitView` mà `NavigationSplitView` dựng, phủ view lên đường chia.

**Xem thêm:** số đo của System Settings ở [`docs/research/SystemSettingsReference.md`](research/SystemSettingsReference.md) và `scripts/selftest/settings-window/Reference.swift`; API cửa sổ ở [`docs/research/SwiftUIWindowAPI.md`](research/SwiftUIWindowAPI.md) (số đo trên app thử: mục 1); cách dựng ở [`docs/Architecture.md`](Architecture.md) mục "Cửa sổ Cài đặt".

### D10. Engine tự viết

Engine tự viết bằng Swift thuần (struct, hàm thuần, không Foundation).

- OpenKey chỉ là tài liệu tham khảo: đọc mã nguồn để hiểu tính năng và ca biên, ghi vào `docs/research/OpenKeyNotes.md`; không nhúng mã, không dùng kết quả chạy OpenKey làm đáp án test.
- UniKey không dùng.

### D11. Kiểm tra ngữ cảnh

- Engine tự theo dõi trạng thái trong bộ nhớ. Ở mỗi phím có thay chữ, hỏi `selectedRange` một lần để lấy vị trí tuyệt đối (N3 (Ít lời gọi vào ứng dụng đích)).
- Vị trí khác dự đoán (app tự sửa chữ, con trỏ đã đi chỗ khác) thì reset bộ đệm, không thay chữ, trừ các trường hợp dưới.
- **Gợi ý tự hoàn thành:** vùng bôi đen bắt đầu đúng chỗ con trỏ khi Dấu đang giữ một từ là gợi ý tự hoàn thành của app (thanh địa chỉ trình duyệt, Spotlight): thay cả từ lẫn phần gợi ý, như phím thường gõ đè vùng chọn.
- **Dựng lại khi lệch:** khi lệch, nếu phím trước cách ít nhất 50 ms (như D20 (Thêm dấu cho từ đã gõ)) và app cho đọc chữ, Dấu đọc từ ngay trước con trỏ, dựng lại bộ đệm từ chữ thật rồi xử lý phím đó; không đọc được hoặc không có từ thì reset.
- **App trả lời chậm:** Dấu tự theo dõi vị trí con trỏ qua các từ, cùng các thao tác và các chữ chính nó vừa gõ. Ở phím có thay chữ mà `selectedRange` khác vị trí đó, ở mọi tốc độ gõ, Dấu đọc chữ trước con trỏ một lần. Chữ đọc được chứng minh app chỉ chưa áp vài thao tác vừa gõ (số thao tác được chậm có giới hạn) thì thay ở vị trí Dấu theo dõi. Bất biến:
  - Vùng thay luôn kết thúc ở vị trí Dấu theo dõi.
  - Vị trí app trả mà có thể là vị trí cũ thì không ghi đè vị trí Dấu theo dõi.
  - Không chứng minh được, ở giữa từ: như "Dựng lại khi lệch". Ở lần thay đầu của một từ, khi app chậm trong giới hạn và trước vị trí app trả không có đủ cả từ: vẫn thay ở vị trí Dấu theo dõi.
  - Ở đầu văn bản: khi mọi chữ trước con trỏ là chữ Dấu vừa gõ và phím đang xử lý thuộc cùng loạt phím dồn, coi là app chậm mà không cần chữ của app để so. Sau một quãng nghỉ thì không áp dụng.
- **Ô bỏ qua vùng thay chữ** (vị trí app báo không theo chữ đã gõ, như terminal): D43 (Ô bỏ qua vùng thay chữ).
- **Từ đã hết hợp lệ:** từ trong bộ đệm đã hết hợp lệ (D30 (Kiểm tra chính tả), không tính D33 (Độ dài từ)) mà người dùng gõ phím dấu/biến đổi thì đọc chữ trước con trỏ một lần cho từ đó; khác bộ đệm thì dựng lại từ chữ thật rồi xử lý phím (cùng điều kiện 50 ms). Tối đa một lần đọc cho mỗi từ không phải tiếng Việt.

**Vì sao:**

- Gợi ý tự hoàn thành: mọi cách người dùng tự chọn chữ (chuột, ⇧ + mũi tên, ⌘A) đều đã reset bộ đệm trước đó, nên vùng bôi đen như vậy chỉ có thể là gợi ý của app.
- Dựng lại khi lệch: bấm chuột vào thanh địa chỉ Chrome không được báo cho bộ gõ, nên "tieemf" từng ra "tieemf".
- Từ đã hết hợp lệ: ⌘A trong thanh địa chỉ Chrome là phím tắt menu, không tới bộ gõ; "tốt", ⌘A, "toots" từng ra "toots" và hỏng tới dấu cách.
- App trả lời chậm: Chrome khi trang bận trả vị trí và chữ từ bộ đệm của trình duyệt, thường thiếu phím vừa gõ. Thay theo vị trí đó thì sai, thay theo vị trí Dấu tự theo dõi thì đúng; Telex của Apple cùng điều kiện ra đúng.
- Vùng thay kết thúc ở vị trí Dấu theo dõi: theo mã nguồn, VS Code (EditContext) và Firefox đưa con trỏ về cuối vùng vừa thay, nên vùng kết thúc trước con trỏ làm phím sau rơi vào giữa từ.
- Đầu văn bản: ở từ đầu tiên của tài liệu mới trong VS Code, "Chieeuf" từng ra "êhieuf" khi VS Code chưa báo phím nào của loạt phím dồn.

**Xem thêm:** cơ chế và giới hạn ở [`docs/Architecture.md`](Architecture.md) mục "App trả lời chậm"; số lượt đo ở [`docs/history/DecisionsLog.md`](history/DecisionsLog.md) mục D11.

### D12. Ưu tiên tiến trình

Không bật `.latencyCritical` hay `beginActivity` mặc định. Chỉ thêm khi bài test tải nặng chứng minh có App Nap hoặc bị xếp vào nhân tiết kiệm điện.

**Vì sao:** dưới tải nặng ở M6, Dấu đúng chữ ở Safari, Chrome, VS Code và thời gian mỗi phím gần như không đổi so với lúc rảnh; số đo đó không cho thấy cần bật gì. App Nap và việc bị xếp vào nhân tiết kiệm điện chưa đo trực tiếp.

**Xem thêm:** số đo ở [`docs/history/DecisionsLog.md`](history/DecisionsLog.md) mục D12.

### D13. Gạch chân là đường lui cuối cùng

- Thay tại chỗ là cách gõ của Dấu. Gõ sai ở một app là lỗi của Dấu và phải sửa, không giải quyết bằng gạch chân: gạch chân (marked text) là cách bộ gõ mặc định của macOS hiện chữ, thứ Dấu muốn làm tốt hơn.
- Gạch chân chỉ còn là đường lui cho app mà thay tại chỗ chưa sửa được, người dùng tự bật theo từng app (D5 (Quy tắc theo ứng dụng)). **Mặc định mọi app không gạch chân.**
- Nhãn "Đề xuất" trong danh sách tương thích chỉ gắn cho app mà số đo cho thấy thay tại chỗ còn sai ở tốc độ gõ thật; sửa được ở app nào thì bỏ nhãn của app đó. Không gắn nhãn theo công nghệ giao diện khi chưa đo.
- Gửi cả chuỗi một lần (0 ms) không phải tốc độ gõ thật, không là tiêu chí.
- Hiện chỉ Cursor có nhãn. Terminal không đề xuất.

**Vì sao:**

- Cursor: trình soạn thảo còn sai ở nhịp danh nghĩa 5 ms và ở một ca gõ dồn 20 ms; gạch chân đúng.
- Chrome, Edge, Firefox và VS Code: sau các lần sửa ở M6 (D11 (Kiểm tra ngữ cảnh), ý "App trả lời chậm"), đúng ở nhịp danh nghĩa 5, 10, 20 ms (khoảng cách phím thật phần lớn 10–20 ms).
- Brave, Arc và các app Electron khác từng mang nhãn chỉ vì công nghệ giao diện, chưa đo. Nhãn chỉ gắn khi số đo cho thấy sai (luật trên), và kết quả đo ở app này không suy ra cho app kia (Cursor cũng là Electron mà còn sai), nên các app đó không có nhãn cho tới khi đo.
- Terminal: gạch chân cũng không sửa được lỗi khi phím dồn ở đó (còn vẽ marked text cũ).

**Xem thêm:** [`docs/Compatibility.md`](Compatibility.md) mục 6.2; số lượt đo theo app ở [`docs/history/DecisionsLog.md`](history/DecisionsLog.md) mục D13.

### D14. Onboarding

- **Bước 1** chỉ hiện khi một bộ gõ chặn phím (OpenKey, EVKey, GoTiengViet…) đang chạy trong phiên người dùng, phát hiện qua `NSWorkspace` theo bundle ID; hướng dẫn tắt, không tự thoát app đó (N4 (Không tự đổi cài đặt hệ thống)). Bộ gõ đó đã cài mà không chạy thì không chặn bước nào.
- Nguồn tiếng Việt kiểu IMK khác đang bật (Telex/VNI của Apple, XKeyIM) không phải xung đột: chỉ được nhắc nhẹ ở bước 2, không chặn bước nào.
- **Bước 2** bật Dấu (một nguồn nhập liệu duy nhất, D2 (Chuyển Việt/Anh)). Bộ gõ đã cài có chữ ký sai thì bước này yêu cầu cài lại trước (D37 (Cài đặt bộ gõ)).
- **Bước 3** chọn kiểu gõ và gõ thử.
- Bản không phải bản chủ mà bộ gõ chưa cài thì thay ba bước bằng màn hướng dẫn chuyển Dấu vào thư mục Applications (D37).

**Vì sao:** bộ gõ chặn phím bằng event tap biến đổi phím bất kể nguồn nào đang chọn, nên gõ chồng với Dấu. Bộ gõ IMK chỉ xử lý phím khi chính nó đang được chọn, nên không gõ chồng.

**Xem thêm:** danh sách bộ gõ và cách tắt ở [`docs/research/InputMethodInstall.md`](research/InputMethodInstall.md) mục 8; mã ở [`docs/Architecture.md`](Architecture.md) mục "Danh sách tương thích, bộ gõ cũ".

### D15. Cài đặt mặc định

Telex, đặt dấu kiểu mới (hoà, thuý), bỏ dấu tự do bật, tự khôi phục từ không phải tiếng Việt bật, "Thêm dấu cho từ đã gõ" bật, nhóm Nâng cao (gõ tắt phụ âm, cho phép z/f/w/j) tắt.

### D16. Bảo trì và gỡ cài đặt

- App có "Quay về bản trước" và "Gỡ cài đặt" (bộ gõ nằm trong `~/Library/Input Methods`, không gỡ được bằng cách kéo vào Thùng rác).
- **Gỡ cài đặt cần người dùng bấm "–":**
  - Sau khi xác nhận, app mở thẳng danh sách Input Sources của System Settings và hướng dẫn bỏ "Dấu – Tiếng Việt" bằng "–".
  - App không tự chuyển bàn phím. Nếu Dấu đang được chọn, sheet nhắc chọn bàn phím khác khi nút "–" bị mờ, phòng bản macOS khác chưa đo.
  - App tự nhận ra khi Dấu ra khỏi `com.apple.inputsources` rồi mới chuyển bộ gõ vào Thùng rác, dừng nó và xoá bộ đệm danh sách nguồn của System Settings (để "+" không còn dòng không tên).
  - Người dùng không bấm "–" thì không gỡ gì.
- **Dấu đã cài nhưng không có trong nguồn đầu vào:** không có mục nào để bỏ, nên sau alert xác nhận thì gỡ luôn; không mở System Settings, không hiện sheet bấm "–".
- Huỷ hoặc lỗi không xoá gì và không đổi nguồn nhập liệu nào.
- Không đụng container riêng của bộ gõ (`~/Library/Containers/com.codefastlabs.dau.inputmethod.Dau`).
- App không tự xoá chính nó, chỉ hướng dẫn rồi thoát.

**Vì sao:**

- Chỉ System Settings ghi được danh sách nguồn đang bật, app không tự bỏ được.
- App không tự chuyển bàn phím vì trên macOS 27.2 nút "–" bấm được cả khi Dấu đang được chọn và macOS tự chuyển sang nguồn khác (đo bằng Dấu thật).
- Container riêng của bộ gõ: app khác đụng container có thể làm macOS hỏi quyền.
- Đã cân nhắc và loại gỡ tự động không cần "–" (xoá bộ gõ và bộ đệm, đo bằng bản thử): mọi chỗ người dùng thấy đều sạch nhưng mục "đã bật" của Dấu còn ẩn trong `com.apple.inputsources`, và cài lại thì macOS bật Dấu ngay không hỏi. Dấu chọn máy sạch và việc gỡ do chính người dùng xác nhận bằng "–".

**Xem thêm:** [`docs/research/InputMethodInstall.md`](research/InputMethodInstall.md) mục 5.

### D17. Trợ năng

- Chuyển Việt/Anh là chuyển nguồn nhập liệu của hệ thống, VoiceOver tự đọc tên nguồn (N1 (Không làm lại việc hệ thống đã có)); Dấu không tự thông báo thêm.
- Đã kiểm bằng VoiceOver: hệ thống có đọc khi chuyển nguồn (`docs/history/LogM0ToM4.md`). Đọc đúng tên "Dấu – Tiếng Việt" hay không: câu hỏi mở.
- Nếu hệ thống không đọc thì xét lại.

**Vì sao:** tránh đọc hai lần.

### D18. Phòng thủ với IMK

Coi mọi tham số từ IMK là có thể nil hoặc bất thường (ví dụ bảng Emoji từng truyền NSEvent rỗng); không bao giờ crash vì đầu vào.

- Số do app trả (`selectedRange` và các vùng khác) được kiểm biên ở một chỗ trước khi dùng: âm, `NSNotFound` hay vượt trần thì coi như app không cho dùng vị trí, không thay chữ theo nó.
- Lời gọi từ IMK hay từ app đến trong lúc Dấu đang xử lý một phím hoặc đang chốt chữ được hoãn tới khi xong, không chạy lồng.
- Thông báo từ tiến trình khác (đổi nguồn, đổi cài đặt, yêu cầu thoát) chỉ là gợi ý để đọc lại trạng thái thật, không tự nó làm reset hay đổi hành vi.
- **Kiểm bằng fuzz:** engine có test fuzz với seed cố định trong `swift test` (mọi cấu hình, đầu vào thù địch); sửa engine hay đường xử lý đầu vào thì giữ test đó xanh và thêm loại đầu vào mới vào nó.

**Vì sao:** một lần rà soát tìm ra hai đường crash vì tràn số (vị trí rất lớn từ app, số đếm rất lớn ở engine) mà test theo ca không chạm tới; fuzz trên engine và đồ giả tái hiện được cả hai.

### D19. Quay về bản trước

Quay về bản trước tạm tắt tự động cập nhật cho tới khi có bản mới hơn bản lỗi. Cài đặt và quy tắc ứng dụng được giữ nguyên.

- Bản cũ được đặt vào chỗ bản chủ, nên bộ gõ lùi theo ở lần mở kế tiếp (D37 (Cài đặt bộ gõ)).

**Vì sao:** để Sparkle không cài lại bản vừa gặp lỗi.

### D20. Thêm dấu cho từ đã gõ

Tính năng "Thêm dấu cho từ đã gõ" đọc chữ đang hiển thị như chữ cái, không như chuỗi phím đã gõ, và chỉ áp dụng khi kết quả là âm tiết tiếng Việt hợp lệ; nếu không thì phím đi thẳng.

- Nhờ vậy không xung đột với D4 (Từ nước ngoài): "car" giữ bằng "carr", sau đó quay lại gõ thêm "s" vẫn ra "cars"; gõ liền trong cùng từ thì do D26 (Gõ đúp phím dấu).
- Áp dụng cho cả phím dấu thanh lẫn phím biến đổi (aa, ee, oo, w, dd…) theo luật bình thường trên chữ đang hiển thị.
- Không tự thêm biến đổi khác để từ thành hợp lệ ("viet" + j → "vietj" vì "viẹt" không hợp lệ; "viet" + e + j → "việt").
- "Hợp lệ" ở đây xét theo mức tiền tố của D30 (Kiểm tra chính tả), như lúc đang gõ ("viet" + e → "viêt"), với một khác biệt: nguyên âm phải giữ đúng dấu phụ đang hiển thị, vì không tự thêm biến đổi khác (nên "viet" + j → "vietj", không chờ mũ như lúc gõ "viẹt"). Hệ quả: "hoc" + f hiện "hòc", kết thúc từ thì D31 (Âm tiết tiếng Việt hợp lệ) khôi phục thành "hocf".
- Gõ đúp trên từ đọc lại vẫn là bỏ dấu theo D26 ("cả" + r → "car").
- Không giữ "lịch sử từ" để Backspace quay lại sửa như OpenKey: lùi về sau từ rồi gõ phím dấu đã được D20 phủ.
- **Khi nào đọc:** ở phím chữ cái hoặc dấu/biến đổi đầu tiên khi bộ đệm trống mà chưa biết chữ trước con trỏ (sau reset, click, ⌫, Return/Tab), kể cả khi trước con trỏ không có chữ hoặc phím đó cuối cùng đi thẳng: một `selectedRange` và một lần đọc chữ trước con trỏ (N3 (Ít lời gọi vào ứng dụng đích)). Gõ liền qua dấu cách không đọc.
- **Phạm vi:**
  - Không áp dụng ở app đang bật gạch chân (D13 (Gạch chân là đường lui cuối cùng)), vì chế độ đó không hỏi vị trí con trỏ.
  - Không áp dụng ở ô bỏ qua vùng thay chữ (D43 (Ô bỏ qua vùng thay chữ)), vì ô đó không cho đọc chữ.
  - Chỉ đọc lại chữ khi phím trước đó trên cùng ô nhập cách ít nhất 50 ms (biên an toàn khi gõ dồn).
  - Chỉ xét phần chữ ngay trước con trỏ ("hoc|tap" + j → "họctap").
- **Chữ cái gõ sát chữ có sẵn:** phím đầu tiên là chữ cái thường cũng đọc từ ngay trước con trỏ. Chữ đó nối vào từ chỉ khi từ ghép vẫn là tiền tố hợp lệ theo D30, ngược lại chữ đó bắt đầu từ mới ("q" có sẵn + "uer" → "quẻ", "g" + "ias" → "giá", "tiê" + "ngs" → "tiếng"; "tôi" + "laf" → "tôilà", "sắc" + "mauf" → "sắcmàu").
  - Hệ quả: chữ cái sau ⌫ qua dấu cách nối lại từ trước khi hợp lệ ("ba␣⌫nj" → "bạn"; "duow␣⌫c" giữa từ hiện "dươc", kết thúc từ D31 khôi phục "duơc" vì "ươc" cần sắc hoặc nặng).
- **Ba ngoại lệ:**
  - (a) Chữ cuối của từ có sẵn là chữ thường mà phím là chữ hoa thì bắt đầu từ mới, vì tiếng Việt không có chữ hoa giữa âm tiết ("#Hà" + "Nooij" → "#HàNội"; "VI" + "EEJT" → "VIỆT" và "V" + "ieejt" → "Việt" vẫn nối). Trừ khi phím đó đặt dấu thanh hoặc biến đổi lên từ có sẵn, vì khi đó phím không thêm chữ nào ("hoc" + "J" → "học").
  - (b) Từ có sẵn không phải tiếng Việt (không là tiền tố hợp lệ theo D30, dài hơn 7 chữ cái như D33 (Độ dài từ), hoặc có chữ cái engine không biết) thì chữ gõ tiếp, kể cả phím dấu, thuộc về từ đó và đi thẳng tới hết từ, như khi gõ liền ("foo" + "bar" → "foobar", "keyboard" + "bar" → "keyboardbar").
  - (b) thắng (a), vì chữ hoa giữa một từ nước ngoài là kiểu viết camelCase ("foo" + "Bar" → "fooBar", như gõ liền). Đánh đổi: từ tiếng Việt gõ dính sau từ nước ngoài cũng đi thẳng ("iPhone" + "mowis" → "iPhonemowis", như gõ liền).
  - (c) Phím đầu tiên là phím dấu/biến đổi mà không áp dụng được lên từ tiếng Việt có sẵn (từ ghép hết hợp lệ) thì bắt đầu từ mới như chữ cái ("anh" + "emx" → "anhẽm", "tôi" + "ddi" → "tôiđi"). Gõ đúp bỏ dấu theo D26 vẫn là áp dụng ("cả" + "r" → "car").
- **Từ hệ thống vừa sửa:** tự sửa chính tả của macOS (D4) có thể đổi từ Dấu vừa trả ngay sau dấu cách. Khi người gõ ⌫ qua dấu cách hoặc dấu câu vừa kết thúc từ (không tính Return, Tab) rồi gõ phím dấu, và kết quả D20 trên từ Dấu đã trả trùng với chữ đang hiện (không phân biệt hoa thường), Dấu giữ nguyên chữ: kết quả như khi hệ thống không sửa ("Tôi hoc␣⌫j bài" → "Tôi học bài", không thành "hocj"). Hệ thống sửa thành chữ khác kết quả đó ("cat" → "cắt", ⌫ s) thì D20 tính trên chữ đang hiện như cũ.
  - Không áp dụng khi từ Dấu đã trả kết thúc lúc còn hiện chữ của phím gõ đúp (D26) hoặc là từ D4 đã khôi phục: người gõ đã chọn chữ không dấu ("carr" → "car", hệ thống sửa thành "cả", ⌫ r vẫn ra "car"). Từ mà Backspace đã xoá chữ của phím gõ đúp thì tính như mọi từ ("carr" ⌫ r → "cả").
  - Dấu chỉ nhớ đúng từ vừa trả, quên khi có click, mũi tên, phím tắt, đổi nguồn hay ⌫ thứ hai; đây không phải "lịch sử từ" ở trên.
- **Sau sự kiện reset của D4:** sự kiện reset của D4 (mũi tên, click, đổi nguồn, ⌘/⌃/⌥) chỉ xoá bộ đệm, không chặn D20. Phím dấu kế tiếp có thể đặt dấu vào chữ ngay trước con trỏ ("tooi" rồi ← thì con trỏ ở "tô|i"; gõ "s": phần trước con trỏ "tô" thành "tố", chữ "i" sau con trỏ giữ nguyên, cả từ là "tối"; "to" đổi nguồn rồi về, "o" → "tô"). Muốn không có hành vi này thì tắt công tắc D20.

**Hệ quả đã chấp nhận:**

- Từ mới viết thường, hoặc viết hoa như từ có sẵn, gõ dính sau từ tiếng Việt mà vài chữ đầu ghép lại vẫn hợp lệ thì vẫn nối ("#hà" + "nooij" → "#hànooij", "ba" + "nawm" → "banawm"). Giữ song song hai cách hiểu thì sửa được, nhưng phải viết lại cả chữ có sẵn trong app.
- Từ hệ thống vừa sửa: muốn bỏ dấu hệ thống vừa thêm bằng cách gõ lại phím dấu thì lần gõ đầu không đổi gì; bỏ bằng z hay ⌘Z vẫn chạy.

**Vì sao:**

- Ngưỡng 50 ms: app áp phím bất đồng bộ trả vị trí và chữ từ ảnh chụp cũ khi phím dồn, và chữ đọc từ ảnh chụp cũ có thể bị thay sai chỗ. Ở các app đã thử, không chờ cũng chưa hỏng chữ (`docs/history/LogM0ToM4.md`, bảng "Số đo (M1–M3)", dòng "D20 không chờ"); vẫn giữ biên vì người quay lại sửa từ không gõ nhanh như vậy.
- Chữ cái gõ sát chữ có sẵn: chọn bằng mô phỏng engine trên 10.303 ca ngoài và các tình huống sửa chữ, so với chỉ đọc ở phím dấu và với luôn nối (luôn nối làm hỏng 34 ca gõ từ mới sát từ cũ).
- Ba ngoại lệ: trên cùng 10.303 ca, (a) không đổi ca nào, (b) đổi 2, (c) đổi 24, không bất biến nào hỏng.
- Từ hệ thống vừa sửa: ở app bật tự sửa, hệ thống đổi "hoc" thành "học" trước phím j, và gõ lại phím dấu là bỏ dấu (D26), nên "Tôi hoc␣⌫j bài" từng ra "hocj".

**Xem thêm:** mô phỏng ở [`docs/research/external-test-inputs/README.md`](research/external-test-inputs/README.md) mục 3.4; chi phí mỗi lần đọc và số đo "Từ hệ thống vừa sửa" ở [`docs/history/DecisionsLog.md`](history/DecisionsLog.md) mục D20; cơ chế ở [`docs/Architecture.md`](Architecture.md) mục "Thêm dấu cho từ đã gõ".

### D21. Gõ tắt phụ âm

Thuộc nhóm Nâng cao, mặc định tắt.

- Chỉ áp dụng khi kết thúc từ (ranh giới theo D4 (Từ nước ngoài)) và chỉ khi kết quả là âm tiết tiếng Việt hợp lệ; nếu không thì D4 khôi phục. Khác OpenKey, nơi gõ tắt chạy trước và chặn luôn bước khôi phục ("big" thành "bing" dù không hợp lệ).
- Từ trùng như "bag" → "bang", "fix" → "phĩ" vẫn xảy ra vì người dùng đã chủ động bật; ghi rõ trong test.
- Trong lúc gõ (trước khi kết thúc từ), khi tuỳ chọn bật thì f, j ở đầu từ và g, h, k ở cuối từ được coi là phụ âm tạm hợp lệ để phím dấu vẫn có tác dụng ("fanf" hiện "fàn", kết thúc từ ra "phàn").
- Không làm Quick Telex (cc → ch, nn → ng…).

**Vì sao:** Quick Telex kích hoạt cả giữa từ nên phá từ tiếng Anh có phụ âm đôi ("connect" → "congect"), và trùng mục đích với gõ tắt phụ âm.

**Xem thêm:** cách OpenKey làm ở [`docs/research/OpenKeyNotes.md`](research/OpenKeyNotes.md) (B9).

### D22. Gõ tắt loại trừ z, f, w, j

Gõ tắt phụ âm và "Cho phép z, f, w, j" loại trừ nhau.

- Bật mục này thì tắt mục kia, ghi rõ trong giao diện.
- Với Telex, w đầu từ luôn thành ư (D23 (w → qu chỉ ở VNI)) nên "cho phép w" không có tác dụng; giao diện ghi chú điều này khi đang dùng Telex.

**Vì sao:** hai tuỳ chọn cùng tác động lên f, j, w ở đầu từ.

### D23. w → qu chỉ ở VNI

Gõ tắt w → qu chỉ có ở VNI. Với Telex, w ở đầu từ luôn là ư ("wa" → "ưa").

**Vì sao:** trong OpenKey quy tắc w → qu không bao giờ kích hoạt ở Telex nên không đưa vào Telex.

### D24. Tên và định danh

- "Dấu" là tên thương hiệu, như "Phở" hay "Mì Quảng": ở mọi ngôn ngữ vẫn viết "Dấu", không dịch, không bỏ dấu (`scripts/check-l10n/check.sh` chặn "Dau" trong chuỗi giao diện).
- Luôn viết có dấu ở mọi chỗ người dùng nhìn thấy: tên app, tên nguồn nhập liệu ("Dấu – Tiếng Việt"; trên macOS tiếng Anh "Dấu – Vietnamese", D41 (Ngôn ngữ giao diện)), website, logo.
- Bản không dấu "dau" chỉ dùng cho định danh kỹ thuật (bundle ID, tên target, repo, cask) và không bao giờ đứng một mình trước người dùng.
- Tên miền: `dau.codefastlabs.com`.
- Định danh kỹ thuật theo tên miền đảo: bundle ID app `com.codefastlabs.dau`, bộ gõ `com.codefastlabs.dau.inputmethod.Dau`, input mode `com.codefastlabs.dau.inputmethod.Dau.vi`, App Group `<Team ID>.com.codefastlabs.dau.shared`.
- Mọi bản phải ký bằng một Team ID, vì App Group cần Team ID. Bản phát triển dùng Personal Team `M58DANM3ZP`; bản chính thức ký Developer ID (D7 (Cập nhật và loại bản dựng)).
- Tên cask Homebrew: chưa chọn (câu hỏi mở "Tên Dấu").

**Vì sao:** "dau" đứng một mình dễ đọc thành "đau"/"dầu". Bản ký ad-hoc (không Team ID) bị macOS 27 từ chối App Group mà không báo gì; bản có Team ID, kể cả Personal Team miễn phí, dùng được App Group không cần hồ sơ cấp phép và không có hộp thoại.

### D25. Nhận diện

- Biểu tượng "ấ" màu Giấy trên nền Mực, riêng dấu sắc màu Son; logo chữ "Dấu" Be Vietnam Pro một màu; Son chỉ dùng trong biểu tượng; app vẫn dùng phông và màu hệ thống (D9 (Giao diện)).
- **Biểu tượng theo loại bản** (các loại bản ở D7 (Cập nhật và loại bản dựng)):
  - Biểu tượng chuẩn chỉ có ở bản chính thức, chọn bằng một cờ build mà chỉ quy trình phát hành trên CI đặt. Mặc định, tức mọi bản phát triển (Debug, Release tự dựng, bản người khác build), dùng biểu tượng **bản phát triển**.
  - Biểu tượng bản phát triển giữ chữ "ấ", khác nền và có thêm một dấu hiệu bằng hình để vẫn nhận ra khi macOS bỏ màu (kiểu Trong suốt, Phủ màu của Icon Composer): **nền Chì, dải chéo màu Hổ phách ở góc dưới phải**. Không có chữ, không dùng Son cho dải, không đảo màu.
  - Kênh Beta dùng biểu tượng chuẩn, phân biệt bằng số phiên bản ("1.3.0 beta 2") ở trang Cập nhật & hỗ trợ và trong báo lỗi điền sẵn (D8 (Không telemetry)).
  - Debug và Release không có hai biểu tượng. Theo cách Apple ghi bản build (bảng About chuẩn của AppKit, `orderFrontStandardAboutPanel`, ghi mã build trong ngoặc sau số phiên bản), bản phát triển ghi "Bản phát triển" dưới tên và phiên bản ở trang Cập nhật & hỗ trợ; chỉ bản Debug ghi thêm "Debug" trong ngoặc cùng commit ("Dấu 1.0.0 (a1b2c3d, Debug)"), cả cho bộ gõ đã cài; bản Release không ghi cấu hình. `scripts/dev/dau-version.sh` in commit và cấu hình (Debug/Release) của từng bản đã cài.
  - Bundle ID không đổi theo loại bản (D37 (Cài đặt bộ gõ)).
  - Biểu tượng "V" trên thanh menu giống nhau ở mọi bản (ảnh template, D9).

**Vì sao:**

- Biểu tượng chỉ trả lời câu "đây có phải bản chính thức không"; bằng chứng là chữ ký Developer ID, app chủ kiểm chữ ký của bộ gõ (D37).
- Dải góc thay vì nền sọc: nền sọc mất ở 16–32 pt và ở kiểu Trong suốt. Không có chữ vì 16–32 pt không đọc được. Không đảo màu vì dễ nhầm với kiểu Tối của biểu tượng chuẩn.
- Kênh Beta dùng biểu tượng chuẩn: người dùng Beta là người dùng thật, đổi biểu tượng mỗi lần đổi kênh chỉ gây rối.
- Không ghi "Release": đặt cạnh "Bản phát triển" thì đọc thành hai từ đối nhau (phát triển / phát hành). Release là trạng thái bình thường; Debug là ngoại lệ (log mỗi phím, `get-task-allow`, D8) nên mới cần ghi.

**Xem thêm:** màu và artboard ở [`docs/Brand.md`](Brand.md).

### D26. Gõ đúp phím dấu

Sau khi gõ đúp phím dấu để giữ chữ gốc (chuẩn Telex, D4 (Từ nước ngoài)), các phím dấu tiếp theo trong cùng từ đi thẳng như chữ cái cho tới khi kết thúc từ (ranh giới theo D4), hoặc tới khi Backspace xoá chữ của phím gõ đúp: "carr" → "car", "carrs" → "cars". Khớp với ví dụ ở D20 (Thêm dấu cho từ đã gõ).

- Cùng luật cho gõ đúp phím biến đổi ("aaa" → "aa", "ddd" → "dd", "ww" → "w") và cho VNI ("a11" → "a1").
- **Backspace:** khi chữ của phím gõ đúp còn trên màn hình, khoá giữ nguyên ("tesst" ⌫ s → "tess"). Backspace xoá chữ đó thì mở khoá, phím sau lại đặt dấu và biến đổi như thường ("carr" ⌫ r → "cả", "nhaamff" ⌫ f → "nhầm", "aaa" ⌫ a → "â", VNI "a11" ⌫ 1 → "á"). Chính Backspace đó cho kết quả như khi còn khoá.
- Khoá không sang từ sau ("tesst" ⌫ s, dấu cách, "cas" → "tess cá").
- Ngoại lệ "ooo": "ooo" → "oo" nhưng **không** khoá phím dấu sau đó, để gõ được "xoong", "boong", "xoòng" ("xooongf" → "xoòng").
- "ww" trên "ưa" cũng bỏ móc như mọi nguyên âm khác ("huaww" → "huaw").
- Ngoại lệ chữ ư từ một phím w đứng riêng (D23 (w → qu chỉ ở VNI)): khi sau chữ ư đó đã có nguyên âm khác, nó không bị phím w sau bỏ móc ("ww" → "w" vẫn theo D26); phím w đó là chữ cái, kết thúc từ thì D4 khôi phục ("Warwick", "waxwing" giữ nguyên).

**Hệ quả đã chấp nhận:**

- Từ tiếng Anh có chữ cái lặp trùng phím dấu mất một chữ nếu gõ bình thường ("password" → "pasword", "coffee" → "cofee"); muốn giữ thì gõ chữ đó 3 lần ("passsword", "cofffee").
- Từ tiếng Anh có chữ cái lặp trùng phím dấu hoặc phím biến đổi mất cả dấu lẫn một chữ ("worry" → "ưory", "express" → "êps", "versus" → "veus"). Giữ nguyên hành vi; gõ tiếng Anh bằng U.S. (D2 (Chuyển Việt/Anh)).
- Backspace lùi qua chữ của phím gõ đúp rồi gõ lại thì từ thành chữ Việt: "tesst" ⌫⌫ "st" → "tét", "passs" ⌫⌫ "ssword" → "pasword". Muốn giữ chữ gốc thì gõ đúp lại ("tesst" ⌫⌫ "sst" → "test").
- "carr" ⌫ r ⌫ r → "cr": Backspace trên "cả" bỏ cả chữ "ả" (D32 (Backspace)).

**Vì sao:**

- Đã cân nhắc khôi phục theo phím gốc thay vì chữ hiển thị: gõ "password" tự nhiên được, nhưng các từ vừa là tiếng Anh vừa là âm tiết hợp lệ có phím dấu giữa từ (test, best, list, most, post) không còn cách nào gõ ở chế độ Tiếng Việt. Loại, vì mọi từ phải gõ được.
- Ngoại lệ chữ ư: đã loại cách áp D26 ở đây, vì "Warwick" → "Waick", "waxwing" → "waing", mất chữ không khôi phục được.
- Backspace mở khoá: khoá là dấu hiệu người gõ chọn chữ gốc, và dấu hiệu đó là chữ của phím gõ đúp trên màn hình. Xoá chữ đó thì không còn dấu hiệu, nên "tiếng Việt thắng" của D4 áp dụng lại. Người lỡ gõ đúp phím dấu thường xoá đúng chữ thừa rồi gõ lại dấu; khi khoá còn giữ qua Backspace, cách sửa đó không ra chữ muốn. OpenKey, XKey, bamboo-core và gonhanh cũng mở khoá như vậy.

**Xem thêm:** ca thử của bộ gõ khác ở [`docs/research/external-test-inputs/README.md`](research/external-test-inputs/README.md) mục 1; mô phỏng người gõ sửa chữ ở [`docs/research/EditingTypedText.md`](research/EditingTypedText.md) mục 4.

### D27. Không có phím gõ nhanh ơ, ư

Không có phím gõ nhanh `[` → ơ, `]` → ư trong Telex. `[` và `]` luôn là dấu câu, kết thúc từ.

### D28. Bỏ dấu tự do

Mặc định bật (D15 (Cài đặt mặc định)).

- **Khi bật:** phím dấu thanh gõ ở bất kỳ đâu sau nguyên âm đầu, kể cả sau phụ âm cuối; dấu tự vào đúng nguyên âm và tự dời khi gõ thêm nguyên âm ("hof" + a → "hoà" kiểu mới).
  - Phím d sau nguyên âm vẫn biến d đầu từ thành đ ("did" → "đi"; từ trùng thì tiếng Việt thắng theo D4 (Từ nước ngoài)).
  - Phím biến đổi (aa, ee, oo, w, dd; VNI 6, 7, 8, 9) và phím dấu tác dụng lên nguyên âm/phụ âm phù hợp trong từ, không cần đứng sát ("tuongw" → "tương"; VNI "duo7c59" → "được").
- **Khi tắt:** phím dấu chỉ có tác dụng khi gõ ngay sau nguyên âm (dấu đã đặt vẫn tự dời khi gõ thêm nguyên âm: "hof" + a → "hoà"); phím biến đổi nguyên âm (w, aa, ee, oo; VNI 6, 7, 8) vẫn tác dụng từ xa ("tuongw" → "tương"), và d → đ chỉ khi hai d liền nhau ("did" giữ "did").
- **Phím biến đổi khác loại:** gõ lên nguyên âm đã có dấu phụ khác thì đổi sang dấu mới, kể cả trên cụm hai nguyên âm: "aaw" → "ă", "owo" → "ô", "ươ" + o → "uô" ("cuoiwo" → "cuôi").

### D29. Telex đơn giản

Telex đơn giản là Telex trừ các điểm sau:

- w chỉ biến đổi khi trong từ có a, o, u để nhận dấu trăng/móc (theo D28 (Bỏ dấu tự do), không cần đứng sát: "tuongw" → "tương"); nếu không có thì w là chữ w, không thành ư ("web", "www" gõ thoải mái).
- Không có `[ ]` (như D27 (Không có phím gõ nhanh ơ, ư)).
- Không có gõ tắt w → qu (D23 (w → qu chỉ ở VNI)).

**Xem thêm:** Simple Telex 1 của OpenKey ở [`docs/research/OpenKeyNotes.md`](research/OpenKeyNotes.md) mục 2.5.

### D30. Kiểm tra chính tả

Kiểm tra chính tả luôn chạy trong engine, không có công tắc riêng: khi từ đã sai chính tả thì ngừng biến đổi phím tiếp theo.

- Trong lúc gõ chỉ xét từ có còn là **tiền tố** của một âm tiết hợp lệ hay không ("viêt", "hoc", "tră" vẫn biến đổi tiếp: "vieetj" → "việt", "hocj" → "học", "trawngf" → "trằng"); quy tắc đầy đủ của D31 (Âm tiết tiếng Việt hợp lệ) chỉ áp khi kết thúc từ.
- Sau Backspace (D32 (Backspace)), trạng thái sai chính tả được tính lại từ chữ còn hiển thị.
- Công tắc "Tự khôi phục từ không phải tiếng Việt" chỉ điều khiển việc khôi phục khi kết thúc từ.
- **Dấu thanh trên vần tắc:** "tiền tố hợp lệ" xét chữ cái của âm tiết; dấu thanh chỉ kiểm theo D31 khi kết thúc từ. Vì vậy huyền, hỏi, ngã trên vần có âm cuối p, t, c, ch vẫn được nhận giữa từ ("hoc" + f hiện "hòc"); kết thúc từ thì D4 (Từ nước ngoài) khôi phục ("metric", "catr" giữ nguyên).

**Hệ quả đã chấp nhận:** giữa từ tiếng Anh có thể nháy chữ có dấu ("mẻt…"); khi tắt tự khôi phục, chữ sai chính tả ở lại.

**Vì sao:** nhận dấu thanh trên vần tắc giữa từ để sửa dấu bằng phím dấu khác ("hocfj" → "học", "matfs" → "mát") và bỏ dấu tự do (D28 (Bỏ dấu tự do): "cafts" → "cát") vẫn chạy. Đã loại phương án cho phím đó đi thẳng như chữ cái: hỏng cả ba cách gõ trên.

### D31. Âm tiết tiếng Việt hợp lệ

Định nghĩa dùng cho D4 (Từ nước ngoài), D20 (Thêm dấu cho từ đã gõ), D21 (Gõ tắt phụ âm), D30 (Kiểm tra chính tả), theo chính tả chuẩn:

- Phụ âm đầu thuộc danh sách chuẩn, có thêm "p" (pin, pa-tê).
- Quy tắc phân bố c/k/q, g/gh, ng/ngh: gh, ngh chỉ đứng trước i, e, ê; c, g, ng không đứng trước i, e, ê, y; k đứng trước i, e, ê, y và — nới cho địa danh, xem bên dưới — trước mọi nguyên âm; c không đứng trước oa, oă, oe, uy, uê, uâ vì chính tả viết qu; q luôn đi với u.
- iê không đứng đầu âm tiết (viết yê: yên, yêu); yê sau phụ âm chỉ trong uyê (khuyên, tuyết).
- Vần thuộc bảng vần hợp lệ do Dấu tự lập theo chính tả (không chép bảng OpenKey). Bảng vần có "oao" (ngoao, ngoáo) và "uêu" (nguều).
- Vần kết thúc bằng p, t, c, ch chỉ mang sắc hoặc nặng; không dấu thanh là không hợp lệ (vì vậy "bak" với gõ tắt phụ âm giữ nguyên "bak").
- ă, â không đứng cuối âm tiết ("traw" khôi phục thành "traw").
- **Chữ cái đứng một mình:** một từ chỉ gồm đúng một chữ ă hoặc â (có hoặc không có dấu thanh) hoặc đ được giữ khi kết thúc từ, hoa hay thường như nhau (`aw` → "ă", `aa` → "â", `dd` → "đ", `aas` → "ấ", `AA` → "Â", `DD/c` → "Đ/c"). Muốn giữ chữ gốc thì gõ đúp phím (D26 (Gõ đúp phím dấu): `aaa` → "aa", `ddd` → "dd"). Từ dài hơn một chữ không đổi. Với D20: chữ "a" hoặc "d" có sẵn sát con trỏ rồi gõ `a`, `w` hoặc `d` cũng là từ một chữ, nên ra "â", "ă", "đ".
- Phím dấu gõ ngay sau "qu" được nhận như sau "gi" ("qusa" → "quá"); "qui" vẫn không hợp lệ, chỉ "quy" theo chính tả chuẩn.
- b, m, p, v đi với âm đệm o, u hợp lệ (buýt, boa, voan; "more" → "moẻ" theo D4, gõ đúp để giữ chữ gốc).
- **Nới cho địa danh:** k đứng trước mọi nguyên âm (Kon Tum, Bắc Kạn, Kơ Tu), phụ âm đầu "kr" (Krông Pắc), và âm cuối k **chỉ sau ă**, cùng ràng buộc dấu như c (Đắk Lắk). Không dùng danh sách ngoại lệ (cùng tinh thần D4).
  - Vần "ăk" chỉ nhận khi ă đã có trước k ("Lawks" → "Lắk"); gõ phím biến đổi sau k ("lakws") không biến đổi.

**Hệ quả đã chấp nhận:**

- Chữ cái đứng một mình: "AA", "DD", "aw", "dd" gõ hai phím ra "Â", "Đ", "ă", "đ"; muốn chữ gốc thì gõ đúp.
- Nới cho địa danh: trên 428 từ tiếng Anh, 6 từ đổi (karma → kẩm, Kansas → Kâns, Kris → Krí, hawks → hắk, gawks → gắk, awkward → akward).

**Vì sao:**

- Chữ cái đứng một mình: người viết bảng chữ cái hay dạy tiếng Việt gõ từng mặt chữ ("a, ă, â… d, đ"), và chữ viết tắt "Đ/c", "Đ." bắt đầu bằng một chữ đ đứng riêng; trước đó ba chữ này bị D4 trả về phím gốc, không có cách gõ nào ngoài tắt tự khôi phục. Telex của Apple giữ các chữ này, kể cả chữ hoa.
- Nới cho địa danh: đã loại phương án cho âm cuối k ở mọi vần: hỏng 19 từ (ask → ák, task, desk, mask…).
- "ăk" chỉ khi ă có trước k: cho "ak" là tiền tố hợp lệ sẽ làm "asks", "tasks", "masks" mất một chữ s (D26).
- "qui": đã loại cho "qui" hợp lệ, vì khi đó "quits" → "quít", "quips" → "quíp".

**Xem thêm:** ba điểm "qu", âm đệm sau b, m, p, v và hai vần "oao", "uêu" đến từ ca thử của bộ gõ khác ([`docs/research/external-test-inputs/README.md`](research/external-test-inputs/README.md) mục 2.2).

### D32. Backspace

Backspace bỏ chữ cuối đang hiển thị khỏi bộ đệm và đặt lại dấu theo vần còn lại ("hoà" ⌫ → "hò").

- Từ đó mốc khôi phục của từ là chữ đang hiển thị (không giữ chuỗi phím gốc cũ).
- Còn lại chỉ "qu" thì không còn vần để đặt dấu: "quá" ⌫ → "qu".

**Vì sao:** tránh lệch hai bộ đệm như OpenKey.

### D33. Độ dài từ

Từ dài hơn âm tiết dài nhất (7 chữ cái, như "nghiêng") thì khôi phục ngay về chuỗi phím đã gõ (nếu đã biến đổi, không chờ kết thúc từ) và để mọi phím còn lại đi thẳng tới hết từ.

- Khi tắt công tắc "Tự khôi phục từ không phải tiếng Việt" thì chỉ ngừng biến đổi, không khôi phục (cùng ý nghĩa công tắc ở D30 (Kiểm tra chính tả)).
- Xoá hết từ bằng Backspace thì hết trạng thái đi thẳng: "permission" + 10 ⌫ + "vieetj" → "việt".

**Vì sao:** nhờ vậy bộ đệm có dung lượng cố định, không cấp phát thêm, không mất chữ.

### D34. Chữ hoa với phím biến đổi

Phím biến đổi và phím dấu không đổi kiểu hoa của chữ; chữ hoa/thường theo chữ cái gõ đầu tiên ("dD" → "đ", "Dd" → "Đ", "aA" → "â").

### D35. "uơ" và "ươ"

Móc trên cặp u-o (Telex "uow"/"uwo", VNI "uo7") cho "uơ" khi cặp đứng cuối từ ("huơ", "thuở") và tự thành "ươ" khi gõ thêm chữ sau ("uown" → "ươn", "nguwowif" → "người").

- **Thứ tự u + móc + o:** Telex "uwo" và VNI "u7o" theo cùng luật ("uwo␣" → "uơ␣", "thuwor" → "thuở", VNI "thu7o3" → "thuở"; "nguwoif" → "người").
- Phím móc gõ thêm trên cặp đó thêm móc cho u ("nguwowif", VNI "ngu7o72i" → "người"), không bỏ móc theo D26 (Gõ đúp phím dấu).

**Hệ quả đã chấp nhận:** "thu7o73␣", "thuwowr␣" giữa từ thành "thưở", không phải vần hợp lệ, nên kết thúc từ D4 (Từ nước ngoài) khôi phục phím đã gõ.

### D36. VNI: chữ số thành dấu

Với VNI, chữ số sau âm tiết hợp lệ thành dấu ("U23" → "Ủ", "A4" → "Ã", "lan2" → "làn"), cùng luật tiếng Việt thắng (D4 (Từ nước ngoài)).

- Muốn giữ chữ số thì gõ đúp ("U223" → "U23", D26 (Gõ đúp phím dấu)).
- Chữ số khi bộ đệm rỗng đi thẳng ("2024").
- Ghi rõ trong bảng gõ VNI và phần hỏi đáp của website.

### D37. Cài đặt bộ gõ

- **App chủ không chạy sandbox.** Bộ gõ vẫn chạy sandbox và không có quyền mạng (N2 (Bộ gõ không có quyền mạng)); App Group giữ nguyên.
- **Không đổi giữa các bản:** bundle ID, ID mode `….Dau.vi`, tên kết nối, tên file và tên tiến trình bộ gõ, ngôn ngữ của nguồn; nên giữ cả tên hiển thị và biểu tượng nguồn.
- **Bật lần đầu:** khi người dùng bấm "Bật Dấu", app chép bộ gõ; ngay trước khi đăng ký, xoá bộ đệm danh sách nguồn nhập liệu của System Settings và của từng app (thư mục nào không có quyền thì bỏ qua và ghi nhật ký); thoát System Settings nếu đang chạy; rồi xin macOS bật mục cha (macOS mở System Settings và hỏi "Allow “Dấu” to enable “…”?"). Trên macOS 27.2, ở tài khoản đã từng cài Dấu, các bước này cho bật mà không cần đăng xuất.
- Chỉ tính là bật khi `com.apple.inputsources` › `AppleEnabledThirdPartyInputSources` có mục của Dấu (không tin cờ enabled của TIS).
- Sau khi đã bật, app quét lại một lượt: bộ đệm nào vẫn không có bộ gõ của Dấu (dựng lại trong khoảng giữa lúc xoá và lúc đăng ký) thì xoá rồi đăng ký lại một lần.
- Gỡ cài đặt chỉ xoá bộ đệm của System Settings (D16 (Bảo trì và gỡ cài đặt)); bộ đệm riêng của từng app vẫn nhớ bộ gõ đã gỡ, chưa đo hậu quả.
- **Đường lui:** hành vi bộ đệm của System Settings và của từng app không có tài liệu Apple, bản macOS sau có thể khác. Đọc lại không thấy mục của Dấu thì hướng dẫn tự thêm bằng "+", và nếu "+" không có Dấu thì đăng xuất một lần (Apple DTS).
- **Một app vẫn không chọn được Dấu** (bộ đệm riêng không xoá được, như các thư mục được hệ thống bảo vệ): hướng dẫn đăng xuất rồi đăng nhập lại một lần, ở màn "Đã bật" của onboarding, sheet Báo lỗi và Hỏi đáp của trang tải về.
- Homebrew cask chỉ khai `app`.
- **Bản chủ:** Dấu.app nằm trực tiếp trong `/Applications` là bản chủ của bộ gõ đã cài; `/Applications` không có Dấu.app thì bản nằm trực tiếp trong `~/Applications` là bản chủ. Một bản Dấu đang chạy là bản chủ khi mã băm chữ ký (cdhash) của nó trùng với bản đó; không xét đường dẫn nó đang chạy. Thư mục đó có hơn một bản Dấu.app thì trùng với bản nào trong số đó cũng là bản chủ.
- **Chỉ bản chủ cài và thay bộ gõ:** bản không phải bản chủ (chạy từ ảnh đĩa, Downloads, thư mục build) không chép, không thay, không cài lại và không kiểm chữ ký bộ gõ đã cài. Khi bộ gõ chưa cài, nó hướng dẫn chuyển Dấu vào thư mục Applications rồi mở lại. Cài đặt, bật lại và gỡ cài đặt vẫn dùng được.
- **Bộ gõ đã cài là bản nhúng của bản chủ:** mỗi lần mở, bản chủ so mã băm chữ ký của bộ gõ đã cài với bản nhúng, ở mọi kiến trúc; khác nhau thì thay bằng bản nhúng, không đổi trạng thái bật hay chọn. Không so số phiên bản. Chưa cài thì không làm gì: lần cài đầu do người dùng bấm.
- **Thay bộ gõ đã cài** (cài lại, nâng cấp, lùi bản):
  - Chép bản nhúng vào một thư mục tạm ẩn ngay trong thư mục đích, gỡ cờ quarantine, kiểm chữ ký bản tạm, rồi đổi chỗ cả khối trong một bước. Không ghi đè từng file lên bundle đang chạy.
  - Dừng bộ gõ cũ bằng một thông báo Darwin: bộ gõ chốt từ đang gõ rồi tự thoát, và chỉ thoát khi bundle trên đĩa không còn là bản nó đã chạy. Quá hạn mà còn chạy thì app chủ dừng đúng tiến trình bộ gõ của Dấu. macOS chạy bản mới ở phím kế tiếp.
  - Không dừng tiến trình hệ thống nào (`imklaunchagent`, `TextInputMenuAgent`…). Đăng ký lại bộ gõ; không đổi trạng thái bật hay chọn.
  - Lúc thay: khi bản chủ vừa mở, nên người dùng không gõ ở app khác (D7 (Cập nhật và loại bản dựng)).
- **Kiểm chữ ký:** mỗi lần mở app và mỗi lần app được đưa lên trước, app kiểm chữ ký của bộ gõ đã cài theo một yêu cầu mã (code requirement): chữ ký hợp lệ ở mọi kiến trúc, chứng chỉ do Apple cấp, chứng chỉ lá thuộc Team ID của app chủ, định danh là bundle ID của bộ gõ; app chủ không có Team ID thì không bản nào đạt. Không đạt thì hiện banner "Cài lại". Bản tạm lúc cài và thay cũng kiểm theo yêu cầu đó.
  - Mục "Cài đặt Dấu…" của bộ gõ cũng kiểm app chủ trước khi mở (bundle ID app chủ, cùng Team ID với bộ gõ); bản nào đọc được mà không đạt thì không mở.
  - **Giới hạn:** kiểm chữ ký chỉ phát hiện, không chặn. Mọi tiến trình của người dùng ghi được `~/Library/Input Methods`; bản thay thế giữ trạng thái đã bật của Dấu nên macOS không hỏi lại, và nhận phím tới lúc người dùng mở app chủ. Cách chặn là cài bộ gõ vào thư mục chỉ quản trị viên ghi được (câu hỏi mở "Cài cho riêng mình hay cho cả máy").
- **Chữ ký sai thì không tự thay:** bộ gõ đã cài có chữ ký sai hoặc khác Team ID thì app không tự thay, kể cả khi nó khác bản nhúng; banner "Cài lại" hiện và người dùng bấm. Trong onboarding (D14 (Onboarding)), bước 2 hiện thông báo đó và nút "Cài lại" thay cho "Bật Dấu": cài lại xong mới bật. Bản chủ không bật một bộ gõ có chữ ký sai (bản không phải bản chủ không kiểm chữ ký).

**Hệ quả đã chấp nhận:** nếu một bản đổi biểu tượng, macOS còn hiện biểu tượng cũ tới khi đăng xuất, vì Dấu không dừng tiến trình hệ thống giữ ảnh đó (đã đo, `docs/research/InputMethodInstall.md` mục 6); tên nguồn chưa đo (câu hỏi mở "Loại bản dựng"). Nên giữ cả hai không đổi.

**Vì sao:**

- Không sandbox: app phải chép bộ gõ vào `~/Library/Input Methods`, nâng cấp tại chỗ và dừng tiến trình bộ gõ cũ. App có sandbox thì file chép ra luôn bị gắn cờ quarantine mà app không gỡ được, và không dừng được app khác (Apple DTS; không bộ gõ tham khảo nào làm vậy).
- Không đổi giữa các bản: đổi thì bộ đệm TIS lệch, phải đăng xuất.
- Bật không cần đăng xuất (đo bằng bản thử rồi bằng Dấu thật): danh sách "+" và việc dựng hộp thoại đọc bộ đệm của System Settings; bộ đệm không làm mới khi có nguồn mới đăng ký (không xoá thì chỉ đăng xuất mới làm mới); yêu cầu bật gửi lúc trang Keyboard đang mở sẵn bị bỏ qua im lặng.
- Mỗi app có sandbox cũng giữ bộ đệm riêng, dùng nguyên bộ đệm có sẵn kể cả khi mở lại app: Telegram dựng bộ đệm lúc chưa có Dấu thì không chọn được Dấu, gõ vẫn ra bộ gõ khác. Xoá bộ đệm trước khi đăng ký thì app đang chạy dựng lại ở lần đăng ký và dùng được nguồn mới, không cần mở lại (bản thử).
- Đăng xuất là đường lui cho app còn lại (đo bằng Dấu thật): sau một lần đăng nhập mới, mỗi app có sandbox dựng lại bộ đệm của nó ở lần đầu đọc nguồn đầu vào; thoát rồi mở lại app thì không.
- Thay cả khối, không ghi đè từng file: tiến trình cũ còn đang ánh xạ mã của nó. Không dừng `imklaunchagent`: dừng nó làm app đang gõ mất kết nối với mọi bộ gõ cho tới khi mở lại app đó. Bộ gõ chỉ thoát khi bundle đã đổi: ai cũng phát được thông báo Darwin, nên một yêu cầu không kèm thay đổi không được làm đứt từ đang gõ (D18 (Phòng thủ với IMK)).
- Kiểm chữ ký: thư mục `~/Library/Input Methods` tài khoản người dùng ghi được, nên bundle có thể bị thay; macOS có chặn bundle bị thay hay vẫn đưa phím cho nó thì chưa đo.
- Yêu cầu mã thay cho so hai Team ID: hai bản ký ad-hoc đều không có Team ID nên từng "khớp" nhau, và mã khác của cùng team từng đạt. Bộ gõ đã cài bằng bản phát triển (Personal Team) đạt yêu cầu mới (`codesign -R`); chứng chỉ Developer ID của cùng team cũng thoả `anchor apple generic` và Team ID.
- Chữ ký sai không tự thay: bộ gõ nhận mọi phím gõ, tự thay sẽ che dấu hiệu bundle bị can thiệp. Người chuyển từ bản phát triển sang bản chính thức (khác Team ID) thấy banner một lần. Onboarding theo cùng luật: nếu "Bật Dấu" bật luôn bộ gõ đã cài thì Dấu tự tay bật một bundle nó biết là không phải của mình.
- Hơn một bản trong cùng thư mục: mỗi bản đều do người dùng đặt vào Applications, nên mở bản nào thì bộ gõ theo bản đó; không thêm màn yêu cầu xoá bớt.
- Bản chủ: khi bản Dấu.app nào cũng cài và thay được bộ gõ, và chỉ thay khi số build của bản nhúng lớn hơn, thì mở một bản mới hơn từ ảnh đĩa làm bộ gõ khác bản app đã cài, quay về bản trước (D19 (Quay về bản trước)) không lùi được bộ gõ, và bản phát triển cùng số build không bao giờ được thay.
- So mã băm với bản trong Applications, không xét đường dẫn đang chạy: macOS có thể chạy app từ một đường dẫn ngẫu nhiên (App Translocation); điều kiện không được Apple công bố và không có cách được hỗ trợ để nhận biết hay lấy đường dẫn gốc (Apple DTS, Developer Forums 724969).

**Xem thêm:** [`docs/research/InputMethodInstall.md`](research/InputMethodInstall.md) (mục 6 nâng cấp; mục 1 và 3 số đo khi bật); cách mã làm ở [`docs/Architecture.md`](Architecture.md) mục "Cài, bật, thay, gỡ bộ gõ".

### D38. Chữ trên giao diện

- Chữ của Dấu theo ngôn ngữ giao diện của Dấu (D41 (Ngôn ngữ giao diện)).
- Mọi tên giao diện của macOS (System Settings, Keyboard, Input Sources, Allow, tên bàn phím…) hiện **đúng như macOS của người dùng đang hiện**, theo ngôn ngữ của macOS chứ không theo ngôn ngữ của app; lấy chữ từ chính chuỗi của hệ thống, không tự dịch (máy tiếng Anh: "System Settings › Keyboard › Input Sources"; máy tiếng Việt: "Cài đặt hệ thống › Bàn phím › Nguồn đầu vào"). Cùng tinh thần với tên bàn phím.
- Tên "Thùng rác" (Trash) trong các thông báo gỡ cài đặt cũng đọc từ chuỗi của macOS, không viết cứng; không đọc được thì dùng tên tiếng Anh.
- Khi nói về khái niệm chung trong câu tiếng Việt, dùng thuật ngữ Apple tiếng Việt ("nguồn đầu vào", không phải "nguồn nhập liệu"); câu tiếng Anh dùng thuật ngữ Apple tiếng Anh ("input source").
- Phạm vi D38: chữ người dùng thấy; tài liệu nội bộ có thể còn "nguồn nhập liệu".

**Vì sao:** hướng dẫn chỉ đúng khi tên khớp với thứ người dùng thấy; macOS tiếng Việt gọi Input Sources là "Nguồn đầu vào" (đọc từ chuỗi của System Settings 27.2).

### D39. Ủng hộ dự án

- Nhận ủng hộ tự nguyện qua GitHub Sponsors, và chuyển khoản trong nước bằng mã VietQR cho người không có thẻ thanh toán quốc tế.
- Không đổi việc Dấu miễn phí trọn vẹn (D6 (Phát hành)): không có bản trả phí, không khoá tính năng, không quảng cáo.
- Trang tải về có liên kết "Ủng hộ dự án" ở chân trang.
- Tài khoản Sponsors của tổ chức `codefastlabs` và tài khoản ngân hàng nhận chuyển khoản do người dùng mở và lo phần thuế, pháp lý (việc cần tài khoản).

### D40. Chữ dựng sẵn và phím z

- Chữ tiếng Việt dựng sẵn đến như một phím (bàn phím khác, dán từng chữ) được coi là một chữ cái của từ đang gõ ("chuýên" → "chuyến").
- Ký tự không thuộc bảng chữ (ß…) kết thúc từ.
- Phím z (Telex) khi từ chưa có dấu thanh là chữ z, không bỏ mũ/móc ("kongoz" → "kongoz").

**Xem thêm:** ca thử của bộ gõ khác ở [`docs/research/external-test-inputs/README.md`](research/external-test-inputs/README.md) mục 1.

### D41. Ngôn ngữ giao diện

App chủ và bộ gõ có tiếng Việt và tiếng Anh.

- **Chọn ngôn ngữ:** theo danh sách ngôn ngữ ưu tiên của macOS, lấy ngôn ngữ đầu tiên Dấu có bản dịch; không có ngôn ngữ nào thì tiếng Anh. Ngôn ngữ khác chỉ thêm khi có người nói thạo duyệt bản dịch (N5 (Chỉ hứa điều đã kiểm chứng)).
- **String Catalog:** ngôn ngữ gốc là tiếng Anh (`developmentLanguage: en`), khoá là câu tiếng Anh, tiếng Việt là bản dịch và phải đủ mọi chuỗi (thiếu thì người dùng Việt thấy tiếng Anh).
- **Tên nguồn đầu vào:** "Dấu – Tiếng Việt" trên macOS tiếng Việt, "Dấu – Vietnamese" trên macOS tiếng Anh (như "Vietnamese Telex" của Apple); macOS chọn tên theo ngôn ngữ của hệ thống, Dấu không đổi được; ID input mode không đổi (D24 (Tên và định danh), D37 (Cài đặt bộ gõ)).
  - Câu chữ của Dấu nhắc tên nguồn thì dùng đúng tên macOS đang hiện, theo ngôn ngữ của hệ thống chứ không theo ngôn ngữ của app, như tên giao diện ở D38 (Chữ trên giao diện).
  - "Dấu" giữ nguyên ở mọi ngôn ngữ (D24).
- **Đặt ngôn ngữ riêng cho Dấu:** dùng mục ngôn ngữ riêng từng ứng dụng của macOS (System Settings › General › Language & Region › Applications), Dấu không làm ô chọn riêng (N1 (Không làm lại việc hệ thống đã có)).
  - Cài đặt có một hàng "Ngôn ngữ" chỉ đọc: hiện ngôn ngữ Dấu đang dùng và nút "Đổi…" mở trang Language & Region, cùng kiểu hàng "Nhớ nguồn đầu vào theo từng cửa sổ" (tên mục của macOS theo D38).
  - Đổi ngôn ngữ mà chưa mở lại Dấu thì hàng ghi ngôn ngữ của lần mở sau và có nút "Mở lại Dấu" (Dấu tự thoát rồi mở lại, không ghi cài đặt).
  - Menu bộ gõ theo ngôn ngữ hệ thống (câu hỏi mở "Bộ gõ trong mục ngôn ngữ riêng từng ứng dụng").

**Vì sao:**

- Hai ngôn ngữ: người Việt dùng rộng rãi và người nước ngoài học tiếng Việt.
- Khoá tiếng Anh: macOS tự lùi về ngôn ngữ gốc nên không cần cấu hình riêng; sửa câu tiếng Việt không đổi khoá; người dịch ngôn ngữ khác dịch từ tiếng Anh. Đã loại: khoá là câu tiếng Việt (phải đặt vùng phát triển khác ngôn ngữ gốc để lùi về tiếng Anh); khoá theo ngữ nghĩa (`onboarding.title`; Xcode không tự lấy chuỗi từ `Text("…")`, đọc mã không thấy chữ hiện ra).
- Mục ngôn ngữ của macOS thay cho ô chọn riêng: đã loại ô chọn ngôn ngữ trong Cài đặt ghi khoá `AppleLanguages` ("Theo hệ thống", Tiếng Việt, English), vì làm lại việc macOS đã có; điều người dùng thiếu chỉ là biết chỗ đổi. Đo trên Dấu thật (macOS 27.2): danh sách "+" của mục đó có Dấu.app; chọn tiếng Việt thì Dấu hiện tiếng Việt trên máy tiếng Anh (macOS ghi `AppleLanguages` vào miền cài đặt `com.codefastlabs.dau`); đổi xong, macOS hỏi có mở lại app ngay không và không tự mở lại, nên cần nút "Mở lại Dấu".

### D42. Ngưỡng hiệu năng

Trước mỗi bản phát hành, chạy `scripts/selftest/load/heavy.sh` với bộ gõ bản Debug, 20 phím mỗi giây, ở Safari, Chrome, VS Code, lúc rảnh và dưới tải.

- Chữ gõ ra khớp đáp án ở mọi ô.
- Phím có thay chữ: thời gian xử lý phía bộ gõ p50 không quá 3 ms, p99 không quá 20 ms.
- Đối chứng: chữ của Telex của Apple dưới tải giống chữ của chính nó lúc rảnh; khác thì lượt đo không hợp lệ.
- Vượt ngưỡng thì không phát hành cho tới khi rõ nguyên nhân.
- Chưa có ngưỡng bộ nhớ (câu hỏi mở).

**Vì sao:** ngưỡng cao hơn mức đã đo ở M6 (p50 tới 1,92 ms, p99 tới 13,2 ms) khoảng 1,5 lần, để một lượt đo xấu không báo động giả. Đo trên bản Debug vì bản Release không ghi gì theo từng phím (D8 (Không telemetry)); bản Debug có thêm một lời gọi chẩn đoán sau mỗi lần thay chữ nên số của nó cao hơn bản phát hành.

**Xem thêm:** số đo M6 ở [`docs/history/DecisionsLog.md`](history/DecisionsLog.md) mục D42.

### D43. Ô bỏ qua vùng thay chữ

Có những ô nhập nhận chữ của `insertText(_:replacementRange:)` nhưng bỏ qua vùng thay: chữ mới được thêm vào sau thay vì thay chữ cũ (đã đo: Ghostty, và terminal dựng bằng xterm.js). Ở ô kiểu Ghostty, Dấu vẫn thay chữ tại chỗ bằng cách gửi ký tự xoá (DEL, U+007F) cho từng chữ cần xoá rồi tới chữ mới, trong một lần `insertText` tại con trỏ; chương trình trong terminal xoá rồi in lại.

- **Nhận ra ô:** dựa vào vị trí con trỏ app báo ở các phím có thay chữ (Dấu vốn đã hỏi ở các phím này, N3 (Ít lời gọi vào ứng dụng đích)), cộng một bằng chứng dương. Kết quả giữ tới hết lần kích hoạt; chỉ xét lại khi IMK kích hoạt lại bộ gõ hoặc đổi client, còn click hay đổi ô trong cùng app mà IMK không báo thì giữ.
- **Bằng chứng dương:** ở phím mà vị trí vừa đủ để nhận ra ô, Dấu đọc chữ trước con trỏ một lần. Ô loại này không cho đọc chữ đã gõ: app không trả chữ, hoặc trả chữ không chứa chữ Dấu vừa gõ ở đó. App trả về đúng chữ Dấu vừa gõ thì ô đó gõ được bình thường, chỉ báo vị trí sai: không nhận ra, thay tại chỗ như cũ trong lần kích hoạt đó. Vị trí nhỏ một mình không đủ, vì ô tự vẽ báo vị trí hằng số và app đứng hình ở đầu văn bản trống cũng trả vị trí 0.
- **Yêu cầu với ngưỡng nhận ra** (ngưỡng nằm ở mã và test): không nhận nhầm ô gõ thường nào trong các lượt đo đã có, kể cả Chrome khi trang bận và đầu văn bản (vị trí 0 là vị trí thật); nhận ra Ghostty càng sớm càng tốt trong từ đầu tiên.
- **Lúc gửi:** chỉ ô nhận ra theo kiểu Ghostty (vị trí luôn 0) gửi ký tự xoá: để phím tới app như thường, rồi gửi phần sửa ngay sau khi app xử lý xong phím, xoá luôn cả việc phím vừa làm. Ô nhận ra theo kiểu xterm.js (vị trí dao động 0–2) vẫn thay tại chỗ như ô thường, chỉ ghi log.
- **Sau khi nhận ra:** không hỏi vị trí con trỏ, không đọc chữ; mỗi phím vẫn tối đa một lần `insertText`.
- **Khác "event tap + Backspace giả" đã loại:** không event tap, không giả lập phím, không xin quyền Trợ năng (N4 (Không tự đổi cài đặt hệ thống)). Ký tự xoá là chữ gửi qua API của InputMethodKit, chỉ tới ô đã nhận ra là bỏ qua vùng thay.
- **Gạch chân không phải cách sửa** cho những ô này: D13 (Gạch chân là đường lui cuối cùng) giữ nguyên, gạch chân vẫn chỉ do người dùng tự bật.

**Hệ quả đã chấp nhận:**

- D20 (Thêm dấu cho từ đã gõ) và lần dựng lại của D11 (Kiểm tra ngữ cảnh) không chạy, vì không đọc được chữ.
- Return hay Tab kết thúc một từ cần khôi phục (D4 (Từ nước ngoài)) ở Ghostty: Return chạy dòng lệnh trước khi phần sửa tới, nên từ giữ như đang hiện.
- Chương trình không coi DEL là lệnh xoá (vim ở chế độ lệnh, less) nhận ký tự đó như phím thường.
- Trước khi nhận ra, các phím đầu ra như ô thường (ở xterm.js có thể sai ở từ đầu tiên).
- Chữ có thể chớp một khung hình ở cách gửi sau phím: chưa đo.
- Ô vừa báo vị trí hằng số 0 vừa không cho đọc chữ mà không phải terminal (nếu có) vẫn bị nhận ra và nhận ký tự xoá như chữ thường; chưa gặp app nào như vậy.
- Lần đọc chỉ bác được khi app trả chữ Dấu vừa gõ ở chỗ Dấu tự theo dõi (tính từ lúc kích hoạt). Ô báo vị trí hằng số 0 mà lúc kích hoạt đã có chữ trước con trỏ, hoặc đã click trong cùng lần kích hoạt, và app đứng hình tới mức chưa có chữ nào của Dấu trong vùng đọc, vẫn bị nhận ra như khi không có bằng chứng dương. Mới thấy trên client giả, chưa gặp trên app thật.

**Vì sao:**

- Thay tại chỗ thường hỏng ở các ô này: Ghostty `dd` ra "dđ", `vieetj` ra "vieetj"; xterm.js `toois vieetj dd ` ra "toôoiís vieêetj dđd ". Telex của Apple ra đúng ở cả hai.
- Bản thử ký tự xoá ra đúng ở xterm.js (gửi trong phím) và ở Ghostty (gửi sau phím; zsh, vim), thời gian xử lý mỗi phím ngang thay tại chỗ thường.
- Ghostty phải gửi sau phím: Ghostty bỏ chữ bộ gõ bắt đầu bằng ký tự điều khiển trong lúc xử lý phím. Kiểu xterm.js chưa gửi ký tự xoá vì gửi trong phím từng làm chữ dồn khi gõ thử, chưa rõ nguyên nhân.
- Độ dài văn bản app báo (`length()`) là 0 ở mọi app đã thử, nên không dùng để nhận ra ô.
- Bằng chứng dương: trên client giả luôn báo `{0,0}` (ô gõ thường), cách nhận ra chỉ theo vị trí đã gửi ký tự xoá từ từ thứ hai và để chúng lại trong chữ. Theo mã nguồn, Ghostty trả chữ đang bôi đen hoặc không trả gì khi được hỏi chữ, nên lần đọc thêm không làm mất việc nhận ra Ghostty.

**Xem thêm:** cơ chế đọc từ mã ở [`docs/research/TerminalAndUnderline.md`](research/TerminalAndUnderline.md); [`docs/Compatibility.md`](Compatibility.md) mục 6.8; cách nhận ra ở [`docs/Architecture.md`](Architecture.md) mục "Ô bỏ qua vùng thay chữ"; số đo ở [`docs/history/DecisionsLog.md`](history/DecisionsLog.md) mục D43.

## Đã biết nhưng không làm

Tính năng người dùng có thể đã quen ở bộ gõ khác. Dấu biết và cố ý không làm; lý do nằm ở quyết định được dẫn. Muốn làm một mục thì sửa quyết định đó trước. Cột "Bộ gõ khác có" ghi bộ gõ đã đối chiếu: OpenKey theo `docs/research/OpenKeyNotes.md`, uvie-rs theo ca thử ở `docs/research/external-test-inputs/README.md`; "—" là chưa đối chiếu.

| Tính năng | Bộ gõ khác có | Vì sao Dấu không làm |
|---|---|---|
| Macro, gõ tắt văn bản | OpenKey | D3, N1 |
| Viết hoa chữ đầu câu | OpenKey | D3 |
| Bảng mã cũ (TCVN3, VNI-Windows, CP1258, Unicode tổ hợp), nhớ bảng mã theo ứng dụng | OpenKey | D3 |
| Công cụ chuyển mã, kể cả chuẩn hoá Unicode cho chữ dán vào | OpenKey | D3, N1 |
| Tự đổi Việt/Anh theo ứng dụng | OpenKey | D5, D2 |
| Từ điển tiếng Anh để giữ từ tiếng Anh | — | D4 |
| Quick Telex (cc → ch, nn → ng…) | OpenKey | D21 |
| Phím chuyển Việt/Anh riêng (nhấn-nhả ⌃ hoặc ⇧), tiếng bíp khi chuyển | OpenKey | D2 |
| Tạm tắt bộ gõ hoặc kiểm tra chính tả bằng nhấn-nhả ⌃/⌘ | OpenKey | D2, D30 |
| Biểu tượng riêng trên thanh menu, mục "Thoát" | — | D2, N1 |
| Thông báo nổi và âm thanh khi chuyển Việt/Anh | — | D2, N1 |
| Thống kê gõ phím, telemetry | — | D8 |
| Phát hành trên Mac App Store | — | D6, D37 |
| Tự thêm mũ/móc còn thiếu để từ thành hợp lệ ("thuocs" → "thuốc"), tự tách âm tiết giữa từ ("neeboo" → "nê" + "bô") | uvie-rs | D20, D30 |

## Đã cân nhắc và loại bỏ

Cách làm (không phải tính năng; tính năng ở mục trên): Rust/WASM và đa nền tảng; thử gõ trên trang web; event tap + Backspace giả (cách của OpenKey; khác cách xoá bằng ký tự DEL qua InputMethodKit của D43); `NSSpellChecker` trong đường nóng; nhúng engine UniKey qua C++ interop; chạy engine OpenKey làm đáp án cho test (oracle); MIT/MPL tách riêng cho engine.

## Câu hỏi mở

Chỉ giữ câu chưa có trả lời. Câu đã trả lời thì luật vào quyết định liên quan, diễn biến vào [`docs/history/DecisionsLog.md`](history/DecisionsLog.md).

- **Hộp thoại và đăng xuất khi bật bộ gõ** (D37): trên macOS 27.2 có hộp thoại xin phép và không cần đăng xuất. Chưa biết trên macOS 14–26, với bản ký Developer ID (kể cả bản mang quarantine) và trên tài khoản macOS mới. Nguồn trái nhau: Apple DTS nói cần đăng xuất, một dự án khác nói không (`docs/research/InputMethodInstall.md` mục Hiện trạng, 1, 2, 10.4).
- **Cài cho riêng mình hay cho cả máy** (D37, ý "Kiểm chữ ký"; cách duy nhất chặn việc thay bundle bộ gõ): cho người dùng chọn cài bộ gõ vào `~/Library/Input Methods` hoặc `/Library/Input Methods` để mọi tài khoản dùng được. Chưa thiết kế; khi làm phải sửa D16, D37, có thể cả D6 (`.pkg` hay app chủ xin quyền quản trị) và D7 (nâng cấp bản cả máy cần quyền quản trị). Cần trả lời: mỗi tài khoản vẫn phải tự bật bằng "+" không; bản ở hai thư mục cùng bundle ID thì macOS chạy bản nào; gỡ bản cả máy khi tài khoản khác còn bật; tài khoản đăng nhập sau khi cài có thấy nguồn ngay không (`docs/history/ResearchLog.md` mục 1, kế hoạch vòng thử 8.2 cũ).
- **Bản chủ trong `~/Applications`** (D37): sandbox của bộ gõ không đọc được bản trong thư mục nhà, nên mục "Cài đặt Dấu…" không kiểm được chữ ký của nó và chỉ mở nó khi `/Applications` không có bản nào đạt. Mở được thật từ sandbox hay không thì chưa đo (bản chủ trong `/Applications`: mở được, kiểm chữ ký chạy trong sandbox).
- **Hộp thoại App Group với bản ký Developer ID** (D24): bản có Team ID Personal Team không có hộp thoại; bản Developer ID chưa kiểm.
- **Bộ gõ trong mục ngôn ngữ riêng từng ứng dụng** (D41): danh sách "+" của System Settings › General › Language & Region › Applications có chọn được bộ gõ Dấu (`~/Library/Input Methods`) không, và chọn rồi thì menu bộ gõ ("Cài đặt Dấu…", tên kiểu gõ) có đổi theo không. Không được thì hàng "Ngôn ngữ" trong Cài đặt nói rõ menu bộ gõ theo ngôn ngữ hệ thống, nếu cần.
- **VoiceOver đọc tên nguồn** (D17): VoiceOver có đọc đúng tên "Dấu – Tiếng Việt" khi chuyển nguồn không.
- **Độ ổn định của "Thêm dấu cho từ đã gõ"** (D20) trên các web editor (Google Docs, Notion…).
- **Ngưỡng bộ nhớ** (D42): mới đo trong một lượt ngắn, chưa đủ để đặt ngưỡng.
- **Loại bản dựng** (D7, D25): kênh Beta có cần cask Homebrew riêng (`dau@beta`) không, hay chỉ bật trong app (đang nghiêng về chỉ bật trong app); tên app của bản phát triển có thêm chữ để phân biệt không; bản phát triển có kiểm tra và cài bản chính thức qua Sparkle không (cài thì bản đang thử bị thay bằng bản khác Team ID; artboard "Cập nhật & hỗ trợ (bản phát triển)" hiện vẫn vẽ phần Cập nhật như bản chính thức). Tên nguồn "Dấu – Tiếng Việt" giữ nguyên ở mọi bản cho tới khi đo được bộ đệm TIS có giữ tên cũ khi đổi tên giữa hai lần cài không (D37).
- **Liên kết ủng hộ trong app** (D39): có đặt liên kết "Ủng hộ dự án" trong app hay không (canvas trước).
- **Tên "Dấu"** (D24): tra nhãn hiệu (Cục Sở hữu trí tuệ VN), tên miền (cân nhắc tên miền tiếng Việt có dấu "dấu.vn" bên cạnh một bản không dấu), tên cask Homebrew và tên tổ chức GitHub.
