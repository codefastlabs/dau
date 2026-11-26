# Sổ quyết định

Sổ này là nguồn chuẩn duy nhất cho mọi nguyên tắc (N) và quyết định (D) đang có hiệu lực. Mỗi mục có số và tên ngắn. Tài liệu khác dẫn tới mục theo dạng "D4 (Từ nước ngoài)". Lần dẫn đầu tiên trong mỗi file kèm tên.

- **Cách đọc:** tra số ở mục lục. Mỗi quyết định gồm luật, hệ quả đã chấp nhận (nếu có), **Vì sao** và **Xem thêm**. Sổ chỉ ghi luật và lý do. Cách mã làm nằm ở [`docs/Architecture.md`](Architecture.md), còn số đo theo ngày nằm ở nhật ký.
- **Cách đổi:** sửa luật và lý do ở đây. Ngày, bản cũ và số đo dẫn tới thay đổi ghi vào [`docs/history/DecisionsLog.md`](history/DecisionsLog.md). Thay đổi trong sổ nằm cùng commit với thay đổi mã.

## Mục lục

| Số | Tên | Luật |
|---|---|---|
| [N1](#n1-không-làm-lại-việc-hệ-thống-đã-có) | Không làm lại việc hệ thống đã có | Hệ thống đã có thì Dấu không làm lại, trừ khi có lý do đo được. |
| [N2](#n2-bộ-gõ-không-có-quyền-mạng) | Bộ gõ không có quyền mạng | Tiến trình bộ gõ không có quyền mạng. Mọi kết nối nằm ở app chủ. |
| [N3](#n3-ít-lời-gọi-vào-ứng-dụng-đích) | Ít lời gọi vào ứng dụng đích | Mỗi phím gọi `insertText` tối đa một lần. Dấu chỉ hỏi vị trí hay đọc chữ trong các trường hợp được nêu. |
| [N4](#n4-không-tự-đổi-cài-đặt-hệ-thống) | Không tự đổi cài đặt hệ thống | Dấu chỉ đổi cài đặt hệ thống khi người dùng bấm đúng nút làm việc đó. |
| [N5](#n5-chỉ-hứa-điều-đã-kiểm-chứng) | Chỉ hứa điều đã kiểm chứng | Mọi chữ hiển thị cho người dùng phải là lời hứa đã kiểm chứng. |
| [D1](#d1-nền-tảng) | Nền tảng | Dấu chỉ chạy trên macOS 14 trở lên, là binary universal và viết bằng Swift. |
| [D2](#d2-chuyển-việtanh) | Chuyển Việt/Anh | Dấu có một input mode "Tiếng Việt", còn tiếng Anh gõ bằng nguồn tiếng Anh của macOS. |
| [D3](#d3-không-macro-chỉ-unicode-dựng-sẵn) | Không macro, chỉ Unicode dựng sẵn | Dấu không làm macro, bảng mã cũ hay công cụ chuyển mã và chỉ xuất NFC. |
| [D4](#d4-từ-nước-ngoài) | Từ nước ngoài | Từ không phải âm tiết hợp lệ được khôi phục khi kết thúc từ. Dấu không dùng từ điển. |
| [D5](#d5-quy-tắc-theo-ứng-dụng) | Quy tắc theo ứng dụng | Quy tắc riêng của một app chỉ quy định có gạch chân hay không. |
| [D6](#d6-phát-hành) | Phát hành | Dấu phát hành theo GPLv3 dưới dạng DMG đã ký và notarize. Homebrew cask nằm trong tap riêng từ beta đầu tiên. Dấu không lên App Store. |
| [D7](#d7-cập-nhật-và-loại-bản-dựng) | Cập nhật và loại bản dựng | Sparkle 2 cập nhật qua kênh Beta và kênh Chính thức, kênh mặc định theo giai đoạn lúc cài. Bản dựng chia thành bản phát hành và bản phát triển. |
| [D8](#d8-không-telemetry) | Không telemetry | Dấu không gửi gì đi. Bản Release không ghi gì theo từng phím. |
| [D9](#d9-giao-diện) | Giao diện | Giao diện dùng control hệ thống, theo System Settings và chỉ dùng màu hệ thống. |
| [D10](#d10-engine-tự-viết) | Engine tự viết | Engine viết bằng Swift thuần. OpenKey chỉ là tài liệu tham khảo. |
| [D11](#d11-kiểm-tra-ngữ-cảnh) | Kiểm tra ngữ cảnh | Dấu hỏi vị trí con trỏ ở mỗi phím có thay chữ. Khi vị trí lệch, Dấu dựng lại bộ đệm, chứng minh app chậm hoặc reset. |
| [D12](#d12-ưu-tiên-tiến-trình) | Ưu tiên tiến trình | Dấu không bật ưu tiên tiến trình khi chưa đo thấy cần. |
| [D13](#d13-gạch-chân-là-đường-lui-cuối-cùng) | Gạch chân là đường lui cuối cùng | Dấu thay chữ tại chỗ. Gạch chân chỉ có khi người dùng tự bật. Nhãn "Đề xuất" gắn theo số đo. |
| [D14](#d14-onboarding) | Onboarding | Onboarding có ba bước. Bước 1 chỉ hiện khi một bộ gõ chặn phím đang chạy. |
| [D15](#d15-cài-đặt-mặc-định) | Cài đặt mặc định | Mặc định là Telex và đặt dấu kiểu mới, với đặt dấu tự do, tự khôi phục và thêm dấu cho từ đã gõ đều bật. |
| [D16](#d16-bảo-trì-và-gỡ-cài-đặt) | Bảo trì và gỡ cài đặt | App chỉ gỡ bộ gõ sau khi người dùng bỏ Dấu khỏi nguồn đầu vào bằng nút "–", rồi tự chuyển chính nó vào Thùng rác. |
| [D17](#d17-trợ-năng) | Trợ năng | Hệ thống để VoiceOver đọc tên nguồn. Dấu không thông báo thêm. |
| [D18](#d18-phòng-thủ-với-imk) | Phòng thủ với IMK | Dấu coi mọi đầu vào là có thể bất thường và không crash vì chúng. |
| [D19](#d19-quay-về-bản-trước) | Quay về bản trước | Khi quay về bản trước, tự cập nhật tạm tắt tới khi có bản mới hơn bản lỗi. |
| [D20](#d20-thêm-dấu-cho-từ-đã-gõ) | Thêm dấu cho từ đã gõ | Phím dấu áp lên chữ đang hiện trước con trỏ khi kết quả là âm tiết hợp lệ. |
| [D21](#d21-gõ-tắt-phụ-âm) | Gõ tắt phụ âm | Gõ tắt phụ âm là tuỳ chọn Nâng cao, chỉ chạy khi kết thúc từ và khi kết quả hợp lệ. |
| [D22](#d22-gõ-tắt-loại-trừ-z-f-w-j) | Gõ tắt loại trừ z, f, w, j | Hai tuỳ chọn gõ tắt phụ âm và cho phép z, f, w, j loại trừ nhau. |
| [D23](#d23-w--qu-chỉ-ở-vni) | w → qu chỉ ở VNI | Với Telex, w đầu từ luôn là ư. |
| [D24](#d24-tên-và-định-danh) | Tên và định danh | Trước người dùng, "Dấu" luôn viết có dấu, còn định danh kỹ thuật theo tên miền đảo. |
| [D25](#d25-nhận-diện) | Nhận diện | Chỉ bản phát hành mang biểu tượng chuẩn. |
| [D26](#d26-gõ-đúp-phím-dấu) | Gõ đúp phím dấu | Gõ đúp phím dấu xoá dấu và khoá phím dấu tới hết từ hoặc tới khi ⌫ xoá chữ của phím gõ đúp. |
| [D27](#d27-không-có-phím-gõ-nhanh-ơ-ư) | Không có phím gõ nhanh ơ, ư | `[` và `]` luôn là dấu câu. |
| [D28](#d28-đặt-dấu-tự-do) | Đặt dấu tự do | Phím dấu gõ ở đâu trong từ cũng được. Dấu tự vào đúng chỗ. |
| [D29](#d29-telex-đơn-giản) | Telex đơn giản | Telex đơn giản là Telex, trừ w thành ư, `[ ]` và w → qu. |
| [D30](#d30-kiểm-tra-chính-tả) | Kiểm tra chính tả | Khi từ không còn là tiền tố hợp lệ thì engine ngừng biến đổi. |
| [D31](#d31-âm-tiết-tiếng-việt-hợp-lệ) | Âm tiết tiếng Việt hợp lệ | Âm tiết hợp lệ định nghĩa theo chính tả chuẩn, có nới cho địa danh. |
| [D32](#d32-backspace) | Backspace | Backspace bỏ chữ cuối đang hiện và đặt lại dấu. |
| [D33](#d33-độ-dài-từ) | Độ dài từ | Từ dài hơn 7 chữ cái được khôi phục ngay. Phần còn lại của từ để nguyên. |
| [D34](#d34-chữ-hoa-với-phím-biến-đổi) | Chữ hoa với phím biến đổi | Chữ hoa hay thường theo chữ cái gõ đầu tiên. |
| [D35](#d35-uơ-và-ươ) | "uơ" và "ươ" | Cặp u-o có móc là "uơ" ở cuối từ và thành "ươ" khi gõ thêm. |
| [D36](#d36-vni-chữ-số-thành-dấu) | VNI: chữ số thành dấu | Với VNI, chữ số sau âm tiết hợp lệ thành dấu. |
| [D37](#d37-cài-bộ-gõ) | Cài bộ gõ | App chủ không chạy sandbox, bản chủ giữ bộ gõ đã cài trùng với bản nhúng và app kiểm chữ ký bộ gõ. |
| [D38](#d38-chữ-trên-giao-diện) | Chữ trên giao diện | Tên giao diện của macOS hiện đúng như macOS của người dùng đang hiện. |
| [D39](#d39-ủng-hộ-dự-án) | Ủng hộ dự án | Dấu nhận ủng hộ tự nguyện, vẫn miễn phí trọn vẹn và ghi công người ủng hộ khi họ đồng ý. |
| [D40](#d40-chữ-dựng-sẵn-và-phím-z) | Chữ dựng sẵn và phím z | Chữ dựng sẵn là chữ cái của từ. Phím z không bỏ mũ hay móc. |
| [D41](#d41-ngôn-ngữ-giao-diện) | Ngôn ngữ giao diện | Giao diện có tiếng Việt và tiếng Anh, chọn theo ngôn ngữ ưu tiên của macOS. |
| [D42](#d42-ngưỡng-hiệu-năng) | Ngưỡng hiệu năng | Trước mỗi bản phát hành phải chạy bài tải nặng. Vượt ngưỡng thì không phát hành. |
| [D43](#d43-ô-bỏ-qua-vùng-thay-chữ) | Ô bỏ qua vùng thay chữ | Dấu không xử lý riêng ô bỏ qua vùng thay chữ. Người dùng tự bật gạch chân để gõ đúng ở đó. Ghostty mang nhãn "Đề xuất". |
| [D44](#d44-văn-xuôi-tiếng-việt) | Văn xuôi tiếng Việt | Tài liệu viết thành câu tiếng Việt tự nhiên, rõ ràng, đủ ý và giữ tối đa ý nghĩa gốc, không theo khuôn câu tiếng Anh. |
| [D45](#d45-trang-web) | Trang web | Trang web là trang tĩnh dựng bằng TanStack Start bản React, nằm trong repo của Dấu ở `site/`, có tiếng Việt ở `/` và tiếng Anh ở `/en`, chỉ đếm lượt xem và sự kiện không cookie, không định danh. |

Cuối sổ: [Đã biết nhưng không làm](#đã-biết-nhưng-không-làm), [Đã cân nhắc và loại bỏ](#đã-cân-nhắc-và-loại-bỏ), [Câu hỏi mở](#câu-hỏi-mở).

## Nguyên tắc

### N1. Không làm lại việc hệ thống đã có

Hệ thống đã có thì Dấu không tự làm lại. Ngoại lệ phải có lý do đo được (ví dụ D4 (Từ nước ngoài)).

### N2. Bộ gõ không có quyền mạng

Tiến trình bộ gõ không có quyền mạng. Mọi kết nối mạng nằm ở app chủ, cụ thể là phần cập nhật.

### N3. Ít lời gọi vào ứng dụng đích

Khi đang gõ, Dấu gọi vào ứng dụng đích ít nhất có thể.

- Mỗi phím gọi `insertText` tối đa một lần.
- Ở mọi app, ký tự mà engine để nguyên (chữ, số, dấu câu, dấu cách, phím không kèm ⌘, ⌃, ⌥) do Dấu chèn bằng `insertText` tại con trỏ (`NSNotFound`), không để phím đi thẳng. Nhờ vậy mọi thao tác chữ tới app qua cùng một đường. Phím đi thẳng chỉ còn ⌫ (D32 (Backspace)), Return, Tab, Esc, mũi tên, phím chức năng và phím có ⌘, ⌃, ⌥, cùng phím gõ đè vùng chọn (ý "Ngoại lệ gõ đè vùng chọn" bên dưới). Ba loại phím khác cũng đi thẳng. Phím chết là phím không cho ký tự, như dấu ´ của bàn phím quốc tế. Phím chết không có ký tự nào để Dấu chèn, nên app tự ghép nó với phím sau. Sự kiện mang nhiều ký tự một lúc đi thẳng vì engine chỉ nhận một ký tự mỗi phím. Phím đến trong lúc Dấu còn đang xử lý phím trước đi thẳng vì engine đang bận. Từ đang gõ kết thúc khi phím trước xong (D18 (Phòng thủ với IMK)). Không có ngoại lệ theo app (D5 (Quy tắc theo ứng dụng)).
- Dấu hỏi vị trí con trỏ (`selectedRange`) ở mỗi phím có thay chữ, không tự cộng dồn vị trí từ một vị trí gốc. Ở ô chỉ giữ từ trước con trỏ (D11, ý "Ô chỉ giữ từ trước con trỏ"), Dấu tự tính vị trí trong từ đó từ chữ chính nó đã gửi và dùng câu trả lời để kiểm vị trí đó. Chế độ gạch chân là ngoại lệ (D13 (Gạch chân là đường lui cuối cùng)). Phím Dấu tự chèn và phím đi thẳng không hỏi, trừ lần đọc của D20 (Thêm dấu cho từ đã gõ) và lần đọc của D11 (Kiểm tra ngữ cảnh) ở từ đã hết hợp lệ.
- Dấu chỉ đọc chữ trước con trỏ trong các trường hợp một quyết định cho phép. Mỗi trường hợp đọc một lần. Các trường hợp đó là lệch vị trí và từ đã hết hợp lệ (D11 (Kiểm tra ngữ cảnh)), cùng phím đầu khi chưa biết chữ trước con trỏ (D20).
- **Ngoại lệ sau ⌫ chưa áp:** phím đến trong hạn chờ ngay sau một ⌫ đi thẳng mà Dấu biết chữ bị xoá thì hỏi `selectedRange`. Trong trường hợp này, phím Dấu tự chèn cũng hỏi một lần. Nếu `selectedRange` đầu tiên trả đúng vị trí của con trỏ trước khi ⌫ áp, theo hệ vị trí đang dùng (D11), nghĩa là app chưa áp ⌫, thì Dấu hỏi lại `selectedRange` tới khi app áp xong ⌫ hoặc hết một hạn chờ. Sau đó Dấu xử lý phím như thường, kể cả một lần đọc chữ lại nếu đường đó cần. Hết hạn thì Dấu xử lý như khi không chờ. Không có ngoại lệ theo app.
- **Ngoại lệ gõ đè vùng chọn:** khi lần hỏi `selectedRange` của D20 cho thấy ô đang có vùng chọn (độ dài lớn hơn 0) và engine để nguyên phím, phím đó đi thẳng để app tự thay vùng chọn. Nếu phím kế tiếp đến trong hạn chờ, nó hỏi `selectedRange` và chờ app áp phím đó, như ở ngoại lệ sau ⌫ chưa áp. Mọi phím khác vẫn như trên. Không có ngoại lệ theo app.

**Vì sao:** `insertText(_:replacementRange:)` cần vị trí của từ đang gõ trong chữ mà ô nhận đang giữ (tài liệu Apple của `NSTextInputClient`). Chỉ cộng dồn từ một vị trí gốc thì không biết lúc app tự sửa chữ hay con trỏ đi chỗ khác. VS Code đổi gốc toạ độ. Vị trí Dấu tự theo dõi chỉ dùng khi câu trả lời trùng nó hoặc khi chữ đọc được chứng minh app trả lời chậm (D11, ý "App trả lời chậm"). Ở ô chỉ giữ từ trước con trỏ, chữ ô giữ đổi ở mỗi từ, nên câu trả lời cũ tính trong một từ đã không còn. Chỉ vị trí Dấu tự tính từ chữ nó đã gửi mới đúng lúc app áp lời gọi (trình soạn thảo Cursor 3.31.15, [`docs/research/MonacoInput.md`](research/MonacoInput.md)).

**Vì sao Dấu tự chèn ký tự:** Safari (WebKit) giữ phím bộ gõ để đi thẳng trong một hàng riêng, chỉ gửi trang phím sau khi trang xử lý xong phím trước, còn mọi lời gọi của bộ gõ tới trang ngay (đọc mã WebKit). Khi trang bận hay phím dồn, lần thay chữ của Dấu tới trang trước các phím đang chờ và chữ bị xáo (Safari 27.2 trang bận, nhịp người gõ nhanh, sai 3/3 lượt; 18/11/2026). Mọi lời gọi của bộ gõ đi cùng một đường theo đúng thứ tự gọi, nên khi mọi ký tự đều do bộ gõ gửi thì thứ tự đúng ở mọi app mà không cần biết app là gì. IMK không có API nào khác giữ được thứ tự này. ⌫ vẫn đi thẳng: ứng dụng Chromium tự chạy lệnh xoá cho ⌫ dù bộ gõ đã nhận phím (D32), còn Safari thì không, nên tự xoá cho mọi app sẽ xoá hai lần ở Chromium.

**Vì sao ngoại lệ sau ⌫ chưa áp:** WebKit giữ cả ⌫ đi thẳng trong hàng phím, nên khi trang bận, phím dấu hay phím tự chèn ngay sau ⌫ có thể tới trước lúc trang áp ⌫ (Safari 27.2, máy M3 Max, 22/11/2026, trước ngoại lệ: "Hoc ⌫j" ra "Hocj" 1/3 lượt ở nhịp người gõ nhanh, "khoong⌫g" ra "khôngg kó" hay "khôngg khó" 2/3 ở trang bận 10 ms). Không có vùng thay nào đúng cho cả hai app. Chrome với bộ đệm cũ đã đúng nhờ phép chứng minh app chậm của D11, còn Safari cần ⌫ đã áp. Ở Safari, lần hỏi `selectedRange` đầu chặn tới khi trang rảnh, rồi ⌫ áp trong khoảng 3 ms (5 lần chờ, đều áp). Ở Chrome, câu trả lời không đổi trong lúc bộ gõ chặn, vì bộ đệm không cập nhật. Với hạn 0,3 s, mọi lần chờ hết hạn sau 402–414 ms. Chữ sai ở từ khác do các phím dồn sau lúc đứng. Vì vậy hạn chờ là 20 ms (ngưỡng p99 của D42). Với hạn đó, mỗi lần chờ hết hạn sau 21–22 ms và chữ không đổi. Với ngoại lệ, Safari trang bận đúng 3/3 ở cả hai ô trên. Số đo: [`docs/Compatibility.md`](Compatibility.md) mục 5.1.

**Vì sao ngoại lệ gõ đè vùng chọn:** Google Docs trên Safari áp sai `insertText(…, NSNotFound)` của bộ gõ khi đang có vùng chọn: ký tự vào tài liệu nhưng vẫn ở trạng thái được chọn, nên phím sau gõ đè lên nó. Dấu mất ký tự đầu 4/4 lượt, còn Telex của Apple đúng 3/3. Chèn với vùng thay là chính vùng chọn vẫn sai 3/3; cho phím đó đi thẳng thì đúng 3/3 (Safari 27.2, máy M3 Max, 22/11/2026). Phím đi thẳng nằm trong hàng phím của WebKit, nên phím kế tiếp chờ nó áp như sau ⌫, để thứ tự đúng khi trang bận. Với ngoại lệ, Google Docs trên Safari giữ ký tự đầu 3/3 lượt, Safari trang bận đúng 3/3 lượt có vùng chọn, Word trên web đúng 3/3, còn Google Docs trên Chrome cho cùng chữ như khi không có vùng chọn (máy M1 Pro, 26/11/2026). Khi tắt D20, Dấu không hỏi nên không biết có vùng chọn; phím đầu mà engine đổi chữ (Telex "w" thành "ư") vẫn do Dấu chèn. Số đo: [`docs/Compatibility.md`](Compatibility.md) mục 5.10.

**Xem thêm:** bảng phím nào hỏi gì ở [`docs/Architecture.md`](Architecture.md) mục "Vị trí thay chữ"; chi phí đo được của `selectedRange` ở [`docs/history/DecisionsLog.md`](history/DecisionsLog.md) mục "Vị trí thay chữ".

### N4. Không tự đổi cài đặt hệ thống

Dấu không tự ý đổi cài đặt hệ thống của người dùng.

- Dấu chỉ đổi cài đặt hệ thống khi người dùng bấm đúng nút làm việc đó ("Bật Dấu", "Gỡ cài đặt"). Việc đổi luôn có Hoàn tác hoặc xác nhận. Dấu không bao giờ tự làm. Việc bật vẫn do người dùng xác nhận trong hộp thoại của macOS.
- Với mọi thứ khác, Dấu chỉ hướng dẫn hoặc mở đúng màn hình Cài đặt.
- Sau khi bật, Dấu phải đọc lại trạng thái thật trước khi báo thành công (N5 (Chỉ hứa điều đã kiểm chứng)).
- Các việc đi kèm hai nút đó do quyết định nêu. "Bật Dấu" và "Bật lại" xoá bộ đệm danh sách nguồn và thoát System Settings (D37 (Cài bộ gõ)). "Gỡ cài đặt" xoá bộ đệm của System Settings sau khi người dùng đã bỏ Dấu khỏi nguồn đầu vào bằng "–" (D16 (Bảo trì và gỡ cài đặt)).
- Dấu không xin quyền Trợ năng (Accessibility), vì thay tại chỗ không cần quyền đó, kể cả ở Chrome, VS Code, Terminal.

### N5. Chỉ hứa điều đã kiểm chứng

Chữ hiển thị cho người dùng phải là lời hứa đã kiểm chứng được.

## Quyết định

### D1. Nền tảng

Dấu chỉ chạy trên macOS, tối thiểu macOS 14 và là binary universal (Apple silicon và Intel). Dấu viết bằng Swift trong Xcode. Dấu không làm bản cho Windows, Linux hay web.

- Dấu mới được kiểm trên macOS 27 với máy Apple silicon và trên macOS 15 với máy Intel. Trên máy Intel, phép kiểm gồm cài từ DMG, bật và gõ thử. Beta đầu tiên nói rõ điều đó và không hứa macOS 14 hay macOS 26 tới khi kiểm (N5 (Chỉ hứa điều đã kiểm chứng)).

### D2. Chuyển Việt/Anh

- Dấu chỉ có **một** input mode, "Tiếng Việt".
- Người dùng gõ tiếng Anh bằng nguồn đầu vào tiếng Anh sẵn có của macOS, như U.S. (bàn phím mặc định) hay ABC và chuyển nguồn bằng phím tắt nguồn đầu vào của macOS.
- Chỉ báo dưới con trỏ do hệ thống hiển thị (N1 (Không làm lại việc hệ thống đã có)).
- Dấu không có phím chuyển riêng, không có thông báo nổi và không phát âm thanh.
- Từ tiếng Anh lẫn trong câu tiếng Việt do D4 xử lý.

**Vì sao:** một chế độ tiếng Anh trong Dấu chỉ cho phím đi thẳng, nên trùng với bàn phím tiếng Anh của macOS (N1). Chế độ đó nằm ở nhóm "Tiếng Anh" trong danh sách thêm nguồn, nên người dùng không tìm thấy. Chế độ này còn làm mất các tiện ích mà chỉ nguồn của macOS có, như dùng Caps Lock để chuyển sang hoặc về bàn phím tiếng Anh.

### D3. Không macro, chỉ Unicode dựng sẵn

Dấu không làm macro (macOS đã có Thay thế văn bản), viết hoa đầu câu, bảng mã cũ (TCVN3, VNI-Windows…) hay công cụ chuyển mã (N1). Dấu chỉ xuất Unicode dựng sẵn (NFC).

### D4. Từ nước ngoài

Dấu dùng một quy tắc duy nhất cho từ nước ngoài.

- Khi kết thúc từ, từ không phải âm tiết tiếng Việt hợp lệ (D31 (Âm tiết tiếng Việt hợp lệ)) được khôi phục đúng như phím đã gõ (windows, Sunrise).
- Từ vừa là tiếng Anh vừa là tiếng Việt hợp lệ thì tiếng Việt thắng (car → cả, sex → sẽ, as → á). Muốn giữ chữ gốc thì gõ đúp phím dấu theo chuẩn Telex (carr → car).
- Dấu không dùng từ điển tiếng Anh.
- **Ranh giới từ:** mọi ký tự kết thúc từ có in ra (Space, Enter, Tab và **mọi** dấu câu, ký hiệu, kể cả `! ? ( ) "`) kích hoạt kiểm tra và khôi phục như nhau ("windows," → "windows,", "Sunrise!" → "Sunrise!").
- Một số sự kiện chỉ reset bộ đệm mà **không** khôi phục. Đó là mũi tên, Esc, click chuột và tổ hợp có ⌘, ⌃ hoặc ⌥, cùng việc đổi cài đặt, đổi nguồn đầu vào, đổi ô nhập hoặc đổi ứng dụng giữa chừng một từ.
- **Mốc khôi phục:** "đúng như phím đã gõ" tính từ mốc gần nhất. Mặc định mốc là đầu từ. Sau gõ đúp (D26 (Gõ đúp phím dấu)), sau Backspace (D32 (Backspace)) hoặc khi từ được đọc từ ứng dụng (D20), mốc là chữ đang hiển thị lúc đó, cộng các phím gõ sau ("carr␣" → "car␣", "tesst␣" → "test␣", "nha" + f + k␣ → "nhafk␣").

**Giới hạn đã biết — tự sửa chính tả của macOS:** trên macOS 27.2 (bản đã đo), ở app bật tự sửa chính tả, hệ thống có thể sửa chữ vừa gõ sau dấu cách, với mọi bộ gõ, kể cả chữ Dấu đã trả đúng ("carr" → "car" rồi thành "cả") và chữ cái đứng một mình. Dấu không tắt tự sửa (N4 (Không tự đổi cài đặt hệ thống)) và không chặn hệ thống thêm dấu cho từ gõ không dấu. Người gõ quay lại thêm dấu thì tính trên chữ đang hiện (D20, ý "Từ hệ thống vừa sửa"); Dấu không đoán từ người gõ định viết. Người dùng hoàn tác bằng ⌘Z hoặc bấm vào chữ bị sửa.

**Vì sao:** từ điển tiếng Anh chỉ có tác dụng ở đúng nhóm từ trùng. Ở đó từ điển làm hỏng các từ tiếng Việt rất phổ biến như "cả", "sẽ". Mũi tên, Esc, click và tổ hợp phím không khôi phục vì lúc đó con trỏ có thể đã đi chỗ khác. Chuỗi phím trong bộ đệm khi ấy không còn ứng với chữ ở vị trí mới. Khôi phục theo chuỗi đó dễ thay sai vùng. Vì vậy bộ đệm bị xoá. Phím sau đó chỉ sửa chữ ngay trước con trỏ khi đọc lại được chính chữ đó từ app (D20).

**Xem thêm:** các ca tự sửa đã thấy ở [`docs/Compatibility.md`](Compatibility.md) mục 6.1.

### D5. Quy tắc theo ứng dụng

- Quy tắc riêng của một app chỉ có một nội dung: có hay không gạch chân khi gõ trong app đó (D13 (Gạch chân là đường lui cuối cùng)). Quy tắc này luôn áp dụng.
- Dấu **không** tự đổi Việt/Anh theo app và không có "Nhớ chế độ theo từng ứng dụng".
- Nhớ nguồn đầu vào theo từng cửa sổ thuộc về tuỳ chọn "Tự động chuyển sang nguồn đầu vào của tài liệu" của macOS (Cài đặt Bàn phím › Nguồn đầu vào, N1). Cài đặt của Dấu không hiện tuỳ chọn đó.

**Vì sao:** Dấu chỉ có một input mode (D2 (Chuyển Việt/Anh)), nên muốn đổi sang U.S. thì bộ gõ phải gọi `TISSelectInputSource`. Lượt đo cho thấy TIS báo nguồn đã đổi. Lượt đó không kiểm ô gõ có đổi bộ gõ hay không; khi gọi từ tiến trình khác thì ô gõ giữ bộ gõ cũ (`0bf8d3f`). Nhật ký sandbox có `deny mach-lookup com.apple.tsm.portname` (per-pid). Thêm temporary-exception không gỡ được lời từ chối đó, nhưng chưa chứng minh nó là nguyên nhân. Ngoài ra, khi U.S. đang bật thì Dấu không nhận sự kiện nào để đổi lại. Thêm một tiến trình chạy nền chỉ để đổi nguồn là không đáng.

### D6. Phát hành

Dấu phát hành theo giấy phép GPLv3. Bản phát hành là DMG ký Developer ID và notarize, đăng trên GitHub Releases. Dấu không có trên Mac App Store.

- **Homebrew:** từ beta đầu tiên, cask `dau` (khai báo `auto_updates true`) nằm trong tap riêng `codefastlabs/homebrew-tap`. Lệnh cài là `brew install --cask codefastlabs/tap/dau`.
- **Cask và nút "Tải về" theo bản nào:** cả hai theo giai đoạn, như kênh mặc định (D7 (Cập nhật và loại bản dựng)). Khi chưa có bản chính thức, cask và nút "Tải về" trên trang web trỏ vào beta mới nhất đã công bố. Khi đã có, chúng chỉ trỏ vào bản chính thức. Cask chỉ quyết định bản cài lần đầu: vì có `auto_updates true` nên `brew upgrade` không nâng bản, mà Sparkle nâng.
- Khi repo đạt ngưỡng nổi bật của Homebrew, cask được gửi vào `homebrew/cask` và giữ tên `dau`. Tap riêng khi đó xoá cask và khai nó trong `tap_migrations.json`, theo [cách Homebrew chuyển gói giữa các tap](https://docs.brew.sh/Migrating-A-Formula-To-A-Tap).

**Vì sao:** Apple không hỗ trợ phân phối input method qua Mac App Store. `homebrew/cask` chỉ nhận repo đạt [ngưỡng nổi bật](https://docs.brew.sh/Package-Acceptance-Policy#notability); khi chủ repo tự gửi, ngưỡng là 225 sao, 90 fork hoặc 90 người theo dõi. Repo có 0 sao (17/11/2026), nên lúc phát hành beta đầu tiên chỉ tap riêng làm được. Tap nằm trong tổ chức `codefastlabs` nên không ai giành được tên. Lệnh cài ghi đủ tên tap vì từ Homebrew 6.0 tap không chính thức phải được [tin rõ ràng](https://docs.brew.sh/Tap-Trust). Cài bằng tên đủ thì chỉ tin đúng cask đó. Tên repo `homebrew-tap` để lệnh cài không lặp chữ và để công cụ khác của codefastlabs dùng chung tap. Cask và nút "Tải về" theo giai đoạn để khớp kênh mặc định: người cài bằng `brew` hay từ trang web nhận đúng bản của kênh mà app sẽ ghi cho họ.

### D7. Cập nhật và loại bản dựng

- Sparkle 2 nằm trong app chủ, appcast ký EdDSA và có hai kênh là Beta và Chính thức. Phát hành theo đợt để sau beta đầu tiên.
- Appcast nằm ở `https://dau.codefastlabs.com/appcast.xml`. Chỉ bản phát hành có URL appcast và khoá công khai EdDSA, nên chỉ bản phát hành kiểm tra và cài bản mới. Bản phát triển không bao giờ bị Sparkle thay bằng một bản khác Team ID.
- **Kênh:** người dùng chọn kênh ở trang Cập nhật & hỗ trợ, có từ beta đầu tiên. Không có cask Homebrew riêng cho Beta (D6 (Phát hành)).
  - Kênh mặc định theo giai đoạn lúc cài. Khi appcast chưa có bản chính thức thì kênh mặc định là Beta, khi đã có thì là Chính thức. App ghi kênh này ở lần tải appcast thành công đầu tiên. Sau đó chỉ người dùng đổi được kênh. Bản chính thức ra đời không chuyển kênh của ai.
  - Khi appcast chưa có bản chính thức, lựa chọn Chính thức hiện nhưng bị tắt, kèm dòng giải thích. App biết đã có bản chính thức bằng cách đọc appcast lúc chạy, không bằng cờ build, vì bản chính thức là tệp của beta cuối (ý "Số phiên bản"), dựng lúc chưa có bản chính thức nào.
  - Trong appcast, mục beta gắn kênh `beta` của Sparkle. Mục không gắn kênh là bản chính thức. Kênh nào cũng thấy. Quảng bá beta cuối thành bản chính thức nghĩa là bỏ thẻ kênh khỏi mục của nó.
  - Người rời kênh Beta giữ bản đang chạy tới khi có bản chính thức với số build cao hơn, vì Sparkle không hạ bản.
- Danh sách ứng dụng tương thích đi kèm app và đổi theo bản cập nhật app. Danh sách không tải riêng.
- **Cửa sổ của Sparkle:** việc thông báo, tải và cài bản mới dùng cửa sổ chuẩn của Sparkle, vốn có tiếng Việt và tiếng Anh (D41 (Ngôn ngữ giao diện)). Trang Cập nhật & hỗ trợ chỉ có nút "Kiểm tra bản mới…", giờ kiểm tra lần cuối và công tắc "Tự động kiểm tra bản mới".
- **Khi nào kiểm tra:** Dấu.app thoát khi đóng cửa sổ cuối, nên app chỉ kiểm tra lúc Dấu đang mở, cụ thể là khi mở Dấu, tối đa mỗi ngày một lần. Kiểm tra cả khi Dấu không mở để sau beta đầu tiên.
- **Không cài ngầm:** app luôn hỏi người dùng trước khi cài. Cài xong, Sparkle mở lại Dấu. Bản chủ vừa mở thay bộ gõ đã cài. Lúc đó người dùng đang ở Dấu chứ không gõ ở app khác (D37, ý "Thay bộ gõ đã cài").
- **Loại bản dựng:** bản dựng phân loại theo ba trục độc lập và không có loại thứ tư.
  - Theo cấu hình build, bản dựng là **bản Debug** hoặc **bản Release** (D8 (Không telemetry) nói hai bản khác nhau ở đâu). Bản Debug chỉ có trên máy người dựng từ mã nguồn.
  - Theo người ký, **bản phát hành** là bản ký Developer ID của codefastlabs, đã notarize và chỉ dựng bằng quy trình phát hành trên CI. Mọi bản khác (ký Personal Team, bản người khác tự build hay bản fork) là **bản phát triển**.
  - Theo giai đoạn, **bản beta** chỉ tới kênh Beta, còn **bản chính thức** tới cả hai kênh. Chỉ bản phát hành có kênh.
- Quay về bản trước (D19 (Quay về bản trước)) để sau beta đầu tiên.
- **Số phiên bản** theo cách Apple đánh số:
  - Số hiển thị (`CFBundleShortVersionString`) luôn gồm ba số nguyên như "1.3.0", không có chữ beta. Mọi beta của một phiên bản và bản chính thức của nó có cùng một số hiển thị.
  - `CFBundleVersion` là số build tăng dần, mỗi bản dựng một số. Sparkle so sánh bản bằng số này.
  - Chữ "beta" chỉ nằm ngoài tệp nhị phân, ở tag git `v1.3.0-beta.2`, bản pre-release trên GitHub và appcast. Trong app và cửa sổ của Sparkle, các beta phân biệt bằng số build trong ngoặc sau số hiển thị (D25 (Nhận diện)).
  - **Bản chính thức là tệp nhị phân của bản beta cuối, giữ nguyên, không dựng lại.** Tag `v1.3.0` đặt vào đúng commit của beta cuối. Muốn sửa gì sau beta cuối thì phát thêm một beta.
  - Beta đầu tiên là tag `v0.1.0-beta.1`, với số hiển thị "0.1.0".
- Bản dựng theo từng commit (Nightly), nếu làm, là bản phát triển. CI dựng bản đó và chỉ phát qua GitHub, không qua Sparkle.
- Tính năng mới có thể nằm sau công tắc "Thử nghiệm" ngay trong bản chính thức, như một cài đặt cục bộ. Tính năng đó được kiểm chéo với các tính năng cùng tác động lên một đầu vào như mọi tính năng khác.
- Dấu không phát hành dần theo số liệu và không có cờ tính năng điều khiển từ xa. Dấu không dùng TestFlight.
- Cách nhận diện từng loại bản nằm ở D25 (Nhận diện).

**Hệ quả đã chấp nhận:** nếu người dùng đã chọn cài rồi thoát Dấu (⌘Q) trước khi cài xong, Sparkle cài lúc thoát mà không mở lại Dấu (`SPUUserDriver.h`, Sparkle 2.10.1). Bộ gõ cũ chạy tiếp tới lần mở Dấu sau. Lúc đó bản chủ thay nó (D37). Dấu không thêm mã cho trường hợp này.

**Vì sao:** phát hành dần theo số liệu và cờ tính năng điều khiển từ xa đều cần số liệu từ máy người dùng (D8), nên Dấu dựa vào người dùng Beta và báo lỗi. Có hai kênh từ beta đầu tiên để người dùng tự chọn giữa bản mới nhất và bản đã chín. Kênh mặc định theo giai đoạn lúc cài, nên người cài để dùng thử vẫn ở Beta khi bản chính thức ra đời, còn người cài sau đó nhận bản chính thức. Danh sách tương thích đi kèm app vì beta đầu tiên cần tới tay người dùng sớm, còn phát theo đợt và file danh sách ký riêng là hạ tầng cho lúc đã có nhiều người dùng. Cửa sổ của Sparkle thay cho thẻ trạng thái và thông báo tự vẽ, vì Sparkle đã có bản tiếng Việt và tự kiểm chữ ký trước khi cài. Bản tự vẽ cần một user driver riêng và từng hứa điều chưa có, như quay về bản trước hay chữ ký "đã xác minh" trước khi tải (N5). Dấu không cài ngầm vì Sparkle cài ngầm lúc app thoát mà không mở lại app, nên bộ gõ cũ chạy tiếp tới lần mở Dấu sau. TestFlight chỉ dành cho app phân phối qua App Store (D6 (Phát hành)). Số phiên bản theo Apple: tài liệu `CFBundleShortVersionString` quy định ba số nguyên ngăn bằng dấu chấm. Apple đánh dấu bản beta bằng số build và kênh, không bằng số hiển thị. Phát nguyên bản beta cuối làm bản chính thức (như bản RC của Apple) thì bản tới tay mọi người là tệp người dùng Beta đã chạy, còn dựng lại từ cùng commit chưa chắc ra cùng tệp (máy CI, Xcode, gói phụ thuộc có thể đã khác) và người dùng Beta không phải tải lại một bản không đổi gì. Bản sửa gấp dựng từ nhánh cũ hơn `main` có số build nhỏ hơn beta đang chạy, nên không kéo người dùng Beta về bản cũ.

### D8. Không telemetry

- Dấu không có telemetry. Báo lỗi chỉ đi qua GitHub issue điền sẵn. Người dùng xem lại trước khi gửi. Không có đường email, vì Dấu chưa có địa chỉ nhận báo lỗi.
- Dấu không bao giờ gửi nội dung người dùng đã gõ.
- Log chẩn đoán dùng `os.Logger` và nằm trên máy.
- Bản Release không ghi gì theo từng phím, kể cả bản ghi không có chữ.
- Nhật ký từng phím chỉ có ở bản Debug và chỉ bật bằng khoá `DauPerfLog`.
- Log của bộ gõ ở bản Release cũng không ghi app nào đang gõ hay gõ lúc nào. Log không có bundle ID của app đích, kể cả theo từng lần kích hoạt. Đường dẫn ghi ở mức riêng tư. Log chỉ ghi sự kiện của chính Dấu (khởi chạy, thoát, nạp cài đặt, mở app chủ).

**Vì sao:** giờ và app của từng phím là siêu dữ liệu về cách gõ. Ai chạy được lệnh dưới tài khoản người dùng có thể bật rồi đọc mà không cần quyền Theo dõi đầu vào. Lý do đó áp cho cả app và giờ của từng lần kích hoạt (lúc người dùng đưa focus vào app nào), không chỉ từng phím.

### D9. Giao diện

- Giao diện theo macOS hiện hành (mockup vẽ theo macOS 27). App dùng control hệ thống qua SwiftUI, cửa sổ Cài đặt có sidebar và không tự vẽ control (N1).
- **Chuẩn đối chiếu:** app dùng thành phần của macOS với thông số mặc định. Khi mockup và macOS khác nhau về bố cục, khoảng cách, cỡ chữ hay hình dáng control thì theo **System Settings của macOS hiện hành**.
- Mockup quy định nội dung, gồm có mục nào, chữ gì, thứ tự, icon và màu hệ thống.
- App không chỉnh thông số của thành phần hệ thống để khớp pixel mockup.
- Mọi thay đổi giao diện sửa artboard trên canvas trước. Người dùng duyệt artboard rồi mới sửa mã. Mã xong thì đối chiếu lại với artboard.
- **Màu:** app chỉ dùng màu hệ thống, không dùng mã hex, không có ngoại lệ. Ô icon sidebar dùng `systemBlue/systemPurple/systemOrange/systemGreen`, glyph trắng đặc theo mockup. Nhãn "Mới" có nền `accentColor`. Banner "Dấu chưa được bật" dùng cam hệ thống như mockup.
- Nút mở/thu "Nâng cao" được phép ghép từ nút hệ thống và chevron.
- **Vỏ cửa sổ Cài đặt:** cửa sổ không có cụm Lùi/Tiến, vì chỉ có bốn trang và sidebar luôn hiện. Thanh công cụ cao như nhau trên mọi trang, kể cả trang không có nút, để cửa sổ không đổi dáng khi chuyển trang. Tiêu đề trang là `navigationTitle` của hệ thống. App không tự vẽ tiêu đề và không ẩn tiêu đề cửa sổ bằng cách với vào `NSWindow`.
- **Sidebar cố định như System Settings:** sidebar có độ rộng cố định, không kéo rộng hẹp và không thu gọn được. Con trỏ ở đường chia là mũi tên thường. Không có lệnh "Show/Hide Sidebar" (⌃⌘S). Sidebar dựng bằng `NSSplitViewController` của chính app, chỉ dùng thuộc tính có tài liệu Apple và không với vào cấu trúc bên trong của SwiftUI.

**Hệ quả đã chấp nhận:**

- Ô tìm sidebar dùng lề chuẩn của sidebar, nên ô tìm và hàng đầu lệch System Settings 1–2 pt. App không chỉnh lề cho khớp pixel.
- Trang không có nút giữ chiều cao thanh công cụ bằng mục khoảng trống của hệ thống, mà mục này chỉ có từ macOS 26. Trên macOS 14–25, thanh co lại ở các trang đó (chưa kiểm, D1). App không thêm view giả để che các bản đó.

**Vì sao:**

- Chỉnh thông số cho khớp mockup (ví dụ lề hàng sidebar) trong khi app dựng bằng UI thuần vừa trái N1 vừa dễ vỡ khi macOS đổi.
- Nút "Nâng cao" tự ghép vì System Settings không có hàng mở/thu nào, còn `DisclosureGroup` trong Form không có vạch ngăn dưới hàng mở và không có AXPress cho trợ năng (đo trên macOS 27.2).
- Sidebar cố định vì kéo thu sidebar bị giật và System Settings không cho thu. SwiftUI không có API khoá sidebar của `NavigationSplitView`, nên app dùng `NSSplitViewController` của chính nó. Hai cách đã loại là duyệt cây view tìm `NSSplitView` mà `NavigationSplitView` dựng và phủ view lên đường chia.
- Glyph sidebar đặc vì glyph nét mảnh khoảng 1 pt trong ô 20 trông nhỏ và nhẹ hơn hẳn icon của System Settings, mà glyph trắng chiếm 12–15 pt của ô và phần lớn là hình đặc (số đo ở `docs/research/SystemSettingsReference.md`).

**Xem thêm:** số đo của System Settings ở [`docs/research/SystemSettingsReference.md`](research/SystemSettingsReference.md) và `scripts/selftest/settings-window/Reference.swift`; API cửa sổ ở [`docs/research/SwiftUIWindowAPI.md`](research/SwiftUIWindowAPI.md) (số đo trên app thử ở mục 1); cách dựng ở [`docs/Architecture.md`](Architecture.md) mục "Cửa sổ Cài đặt".

### D10. Engine tự viết

Engine do Dấu tự viết bằng Swift thuần (struct, hàm thuần, không Foundation).

- OpenKey chỉ là tài liệu tham khảo. Người phát triển đọc mã nguồn OpenKey để hiểu tính năng và ca biên, rồi ghi vào `docs/research/OpenKeyNotes.md`. Dấu không nhúng mã OpenKey và không dùng kết quả chạy OpenKey làm đáp án test.
- Dấu không dùng UniKey.

### D11. Kiểm tra ngữ cảnh

- Engine tự theo dõi trạng thái trong bộ nhớ. Ở mỗi phím có thay chữ, Dấu hỏi `selectedRange` một lần để lấy vị trí con trỏ trong chữ mà ô nhận đang giữ (N3 (Ít lời gọi vào ứng dụng đích)). Ở hầu hết app, vị trí đó tính từ đầu văn bản hay đầu dòng.
- Khi vị trí khác dự đoán (app tự sửa chữ hoặc con trỏ đã đi chỗ khác), Dấu reset bộ đệm và không thay chữ, trừ các trường hợp dưới đây.
- **Gợi ý tự hoàn thành:** khi Dấu đang giữ một từ, vùng bôi đen bắt đầu đúng chỗ con trỏ là gợi ý tự hoàn thành của app (thanh địa chỉ trình duyệt, Spotlight). Dấu thay cả từ lẫn phần gợi ý, như phím thường gõ đè vùng chọn.
- **Dựng lại khi lệch:** khi lệch, nếu phím trước cách ít nhất 50 ms và app cho đọc chữ, Dấu đọc từ ngay trước con trỏ, dựng lại bộ đệm từ chữ thật rồi xử lý phím đó. Mốc 50 ms là biên an toàn khi gõ dồn, vì app áp phím bất đồng bộ có thể trả chữ từ ảnh chụp cũ. Không đọc được hoặc không có từ thì Dấu reset.
- **App trả lời chậm:** Dấu tự theo dõi vị trí con trỏ qua các từ, cùng các thao tác và các chữ chính nó vừa gõ. Ở phím có thay chữ mà `selectedRange` khác vị trí đó, ở mọi tốc độ gõ, Dấu đọc chữ trước con trỏ một lần. Nếu chữ đọc được chứng minh app chỉ chưa áp vài thao tác vừa gõ (số thao tác được chậm có giới hạn), Dấu thay ở vị trí nó theo dõi. Lần đọc chữ của D20 (Thêm dấu cho từ đã gõ) và của ý "Từ đã hết hợp lệ" bên dưới dùng cùng phép chứng minh này. Chứng minh được app chậm thì Dấu dùng vị trí nó theo dõi, thay vì tin chữ cũ app trả (Chrome trang bận, "Hoc␣⌫j" ra "Học", không ra "Hocj"). Các bất biến như sau:
  - Vùng thay luôn kết thúc ở vị trí Dấu theo dõi, tính theo hệ vị trí đang dùng.
  - Vị trí app trả mà có thể là vị trí cũ thì không ghi đè vị trí Dấu theo dõi.
  - Khi không chứng minh được và đang ở giữa từ, Dấu làm như "Dựng lại khi lệch". Ở lần thay đầu của một từ, khi app chậm trong giới hạn và trước vị trí app trả không có đủ cả từ, Dấu vẫn thay ở vị trí nó theo dõi.
  - Ở đầu văn bản, khi mọi chữ trước con trỏ là chữ Dấu vừa gõ và phím đang xử lý thuộc cùng loạt phím dồn, Dấu coi là app chậm mà không cần chữ của app để so. Sau một quãng nghỉ thì luật này không áp dụng.
- **Ô chỉ giữ từ trước con trỏ:** có ô chỉ đưa bộ gõ từ ngay trước con trỏ, hoặc một ký tự khi không có từ, và áp vùng thay trong chữ đó lúc nhận lời gọi. Trình soạn thảo Cursor khi chế độ hỗ trợ trình đọc màn hình của Monaco tắt là loại ô này. Dấu nhận ra loại ô này từ câu trả lời, không theo tên app (D5 (Quy tắc theo ứng dụng)).
  - Dấu chỉ xét ở lần đọc chữ vốn có của ý "App trả lời chậm" và của D20, khi phép chứng minh app chậm không qua. Câu trả lời phải cho thấy toàn bộ chữ app giữ và khớp chữ ô giữ ở một trạng thái gần đây, tính từ chữ Dấu đã gửi, kể cả dạng bộ đệm (trạng thái đó cộng ký tự Dấu chèn sau nó). Câu trả lời chỉ một đơn vị chỉ được tính khi đó là một chữ cái, khớp một trạng thái của từ đang gõ đã chậm ít nhất một thao tác và không khớp trạng thái hiện tại. Câu trả lời không trùng trạng thái nào của văn bản Dấu theo dõi tính từ đầu văn bản.
  - Ở loại ô này, Dấu tự tính chữ ô giữ sau mọi thao tác nó đã gửi, theo luật ngăn từ của Monaco, và thay k đơn vị cuối của chữ đó. Câu trả lời chỉ dùng để kiểm. Trùng vị trí Dấu tính thì app đúng giờ. Khớp chữ ô giữ ở một trạng thái gần đây thì app chậm. Không khớp thì Dấu xử lý như lệch.
  - Câu trả lời cho thấy chữ ngoài từ trước con trỏ thì Dấu về cách tính từ đầu văn bản. Đổi client thì Dấu bắt đầu lại từ cách tính từ đầu văn bản.
- **Ô bỏ qua vùng thay chữ** (như terminal): Dấu không xử lý riêng, theo D43 (Ô bỏ qua vùng thay chữ).
- **Từ đã hết hợp lệ:** khi từ trong bộ đệm đã hết hợp lệ (D30 (Kiểm tra chính tả), không tính D33 (Độ dài từ)) mà người dùng gõ phím dấu thanh hoặc phím biến đổi, Dấu đọc chữ trước con trỏ một lần cho từ đó. Nếu chữ đó khác bộ đệm, Dấu dựng lại từ chữ thật rồi xử lý phím, với cùng điều kiện 50 ms. Mỗi từ không phải tiếng Việt được đọc tối đa một lần.

**Vì sao:**

- Gợi ý tự hoàn thành: mọi cách người dùng tự chọn chữ (chuột, ⇧ + mũi tên, ⌘A) đều đã reset bộ đệm trước đó, nên vùng bôi đen như vậy chỉ có thể là gợi ý của app.
- Dựng lại khi lệch: bấm chuột vào thanh địa chỉ Chrome không được báo cho bộ gõ, nên "tieemf" từng ra "tieemf".
- Từ đã hết hợp lệ: ⌘A trong thanh địa chỉ Chrome là phím tắt menu và không tới bộ gõ. Chuỗi "tốt", ⌘A, "toots" từng ra "toots" và hỏng tới dấu cách.
- App trả lời chậm: khi trang bận, Chrome trả vị trí và chữ từ bộ đệm của trình duyệt, thường thiếu phím vừa gõ. Thay theo vị trí đó thì sai, còn thay theo vị trí Dấu tự theo dõi thì đúng. Telex của Apple khi trang bận ra cùng chữ như khi trang rảnh (trang rảnh 1/1; trang bận 2 ô hợp lệ trên 3, ô còn lại ra nguyên chuỗi phím nên là đo hỏng).
- Vùng thay kết thúc ở vị trí Dấu theo dõi vì, theo mã nguồn, VS Code (EditContext) và Firefox đưa con trỏ về cuối vùng vừa thay. Vùng kết thúc trước con trỏ sẽ làm phím sau rơi vào giữa từ. Log VS Code ngày 10/11/2026 khớp hơn với mô hình giữ con trỏ sau chữ. Luật này đúng với cả hai mô hình.
- Phép chứng minh app chậm coi app áp mọi thao tác theo thứ tự Dấu gửi. Giả định đó đúng với Chromium và Firefox theo mã nguồn. Ở Safari, giả định đó chỉ đúng khi mọi ký tự đều do Dấu chèn, hoặc phím sau chờ phím đi thẳng áp xong (N3 (Ít lời gọi vào ứng dụng đích), ý "Vì sao Dấu tự chèn ký tự" và ý "Ngoại lệ gõ đè vùng chọn"), vì WebKit cho lời gọi của bộ gõ vượt các phím đi thẳng đang chờ.
- Đầu văn bản: ở từ đầu tiên của tài liệu mới trong VS Code, "Chieeuf" từng ra "êhieuf" khi VS Code chưa báo phím nào của loạt phím dồn.
- Ô chỉ giữ từ trước con trỏ: ô textarea ẩn của Monaco được viết lại sau mỗi chữ, còn Chromium trả lời bộ gõ từ một bản sao cập nhật chậm. Câu trả lời cũ vì vậy tính trong một từ đã không còn, và vùng thay theo câu trả lời đó bị bỏ hoặc rơi lệch chỗ ("Hocj", "dđược", "meting"). Với cùng câu `edit` 10 ms, Cursor 3.31.15 sai 2/2 lượt khi chế độ đó tắt và đúng 2/2 khi bật hay khi dùng EditContext (máy M1 Pro, 23/11/2026). Trang áp lời gọi theo thứ tự Dấu gửi, nên chữ ô giữ lúc đó tính được từ chữ Dấu đã gửi. Google Docs luôn trả một ký tự, là ký tự ngay trước con trỏ (`docs/Compatibility.md` mục 5.10), nên luật cho câu trả lời một đơn vị loại ký tự trùng trạng thái hiện tại, dấu cách và chữ cái của một từ đã qua ranh giới. Google Docs chỉ còn bị nhận nhầm khi chữ cái cuối của từ trùng chữ cái đầu của chính từ đó, và ca này chưa đo. Khi phím dồn, câu trả lời đầu tiên của Cursor khác vị trí theo dõi thường là chữ ô giữ một đơn vị: dấu cách cộng chữ cái Dấu vừa chèn, hoặc chữ cái đầu của từ. Với câu `edit` 5 ms, Cursor 3.31.15 đúng 13/20 lượt khi Dấu chỉ nhận trạng thái dài ít nhất hai đơn vị, và đúng 9/10 khi nhận cả hai loại câu trả lời này (máy M1 Pro, 23/11/2026). Điều kiện "không trùng trạng thái tính từ đầu văn bản" loại câu trả lời chậm của app tính từ đầu văn bản ở đầu tài liệu.

**Xem thêm:** cơ chế và giới hạn ở [`docs/Architecture.md`](Architecture.md) mục "App trả lời chậm"; số lượt đo ở [`docs/history/DecisionsLog.md`](history/DecisionsLog.md) mục D11; ô chỉ giữ từ trước con trỏ ở [`docs/research/MonacoInput.md`](research/MonacoInput.md) mục 6.

### D12. Ưu tiên tiến trình

Dấu không bật `.latencyCritical` hay `beginActivity` theo mặc định. Dấu chỉ thêm chúng khi bài test tải nặng chứng minh có App Nap hoặc bộ gõ bị xếp vào nhân tiết kiệm điện.

**Vì sao:** dưới tải nặng ở M6, Dấu đúng chữ ở Safari, Chrome, VS Code và thời gian mỗi phím gần như không đổi so với lúc rảnh; số đo đó không cho thấy cần bật gì. App Nap và việc bị xếp vào nhân tiết kiệm điện chưa đo trực tiếp.

**Xem thêm:** số đo ở [`docs/history/DecisionsLog.md`](history/DecisionsLog.md) mục D12.

### D13. Gạch chân là đường lui cuối cùng

- Thay tại chỗ là cách gõ của Dấu. Gõ sai ở một app là lỗi của Dấu và phải sửa, không giải quyết bằng gạch chân. Gạch chân (marked text) là cách bộ gõ mặc định của macOS hiện chữ. Dấu muốn làm tốt hơn cách đó. Ngoại lệ là ô bỏ qua vùng thay chữ (terminal như Ghostty, xterm.js): ở đó gạch chân là cách gõ đúng. Dấu không xử lý riêng (D43 (Ô bỏ qua vùng thay chữ)).
- Gạch chân chỉ còn là đường lui cho app mà thay tại chỗ chưa sửa được. Người dùng tự bật theo từng app (D5 (Quy tắc theo ứng dụng)). **Mặc định mọi app không gạch chân.**
- Nhãn "Đề xuất" trong danh sách tương thích chỉ gắn cho app mà số đo cho thấy thay tại chỗ còn sai ở tốc độ gõ thật. Sửa được ở app nào thì bỏ nhãn của app đó. Dấu không gắn nhãn theo công nghệ giao diện khi chưa đo.
- Gửi cả chuỗi một lần (0 ms) không phải tốc độ gõ thật, nên không dùng làm tiêu chí.
- Ở chế độ gạch chân, ký tự chốt chữ (dấu cách, dấu câu) gửi cùng chữ chốt trong một `insertText`, không đi thẳng, cùng lý do với N3 (Ít lời gọi vào ứng dụng đích). Khi phím dồn, Safari từng dời dấu cách sang sau chữ kế.
- Ghostty và Terminal của macOS là các app có nhãn.

**Vì sao:**

- Cursor 3.30.14 (17/11/2026) thay tại chỗ đúng ở trình soạn thảo, khung agent và ô nhập Agents, nên không có nhãn.
- Ở Ghostty, thay tại chỗ sai ở mọi nhịp vì app bỏ qua vùng thay (D43), còn gạch chân thì đúng.
- Chrome, Edge, Firefox và VS Code đúng ở nhịp danh nghĩa 5, 10, 20 ms (khoảng cách phím thật phần lớn 10–20 ms).
- Brave, Arc và các app Electron khác chưa đo, nên không có nhãn. Nhãn chỉ gắn khi số đo cho thấy sai (luật trên). Kết quả đo ở app này không suy ra cho app kia.
- Ở Terminal của macOS, thay tại chỗ sai khi phím dồn dưới 30 ms (5 ms 0/2, 10 và 20 ms 1/2) và đúng từ 30 ms, còn gạch chân đúng ở 5, 10, 20 ms (17/11/2026).

**Xem thêm:** [`docs/Compatibility.md`](Compatibility.md) mục 6.2; số lượt đo theo app ở [`docs/history/DecisionsLog.md`](history/DecisionsLog.md) mục D13.

### D14. Onboarding

- **Bước 1** chỉ hiện khi một bộ gõ chặn phím (OpenKey, EVKey, GoTiengViet…) đang chạy trong phiên người dùng. App phát hiện bộ gõ đó qua `NSWorkspace` theo bundle ID, hướng dẫn tắt nó và không tự thoát app đó (N4 (Không tự đổi cài đặt hệ thống)). Bộ gõ đó đã cài mà không chạy thì không chặn bước nào.
- Một nguồn tiếng Việt kiểu IMK khác đang bật (Telex hay VNI của Apple, XKeyIM) không phải xung đột. App chỉ nhắc nhẹ về nó ở bước 2 và không chặn bước nào.
- **Bước 2** bật Dấu, một nguồn đầu vào duy nhất (D2 (Chuyển Việt/Anh)). Nếu bộ gõ đã cài có chữ ký sai, bước này yêu cầu cài lại trước (D37 (Cài bộ gõ)).
- **Bước 3** cho chọn kiểu gõ và gõ thử.
- Ở bản không phải bản chủ mà bộ gõ chưa cài, ba bước thay bằng màn hướng dẫn chuyển Dấu vào thư mục Applications (D37).

**Vì sao:** bộ gõ chặn phím bằng event tap biến đổi phím bất kể nguồn nào đang chọn, nên gõ chồng với Dấu. Bộ gõ IMK chỉ xử lý phím khi chính nó đang được chọn, nên không gõ chồng.

**Xem thêm:** danh sách bộ gõ và cách tắt ở [`docs/research/InputMethodInstall.md`](research/InputMethodInstall.md) mục 8; mã ở [`docs/Architecture.md`](Architecture.md) mục "Danh sách tương thích, bộ gõ cũ".

### D15. Cài đặt mặc định

Kiểu gõ mặc định là Telex. Vị trí dấu thanh mặc định là kiểu mới (hoà, thuý). Đặt dấu tự do, tự khôi phục từ không phải tiếng Việt và "Thêm dấu cho từ đã gõ" mặc định bật. Nhóm Nâng cao (gõ tắt phụ âm, cho phép z, f, w, j) mặc định tắt.

### D16. Bảo trì và gỡ cài đặt

- App có nút "Gỡ cài đặt", vì bộ gõ nằm trong `~/Library/Input Methods` và không gỡ được bằng cách kéo vào Thùng rác. "Quay về bản trước" (D19) để sau beta đầu tiên (D7).
- **Gỡ cài đặt cần người dùng bấm "–":**
  - Sau khi người dùng xác nhận, app mở thẳng danh sách Input Sources của System Settings và hướng dẫn bỏ "Dấu – Tiếng Việt" bằng "–".
  - App không tự chuyển bàn phím. Nếu Dấu đang được chọn, sheet nhắc chọn bàn phím khác khi nút "–" bị mờ, để phòng các bản macOS khác chưa đo.
  - App tự nhận ra khi Dấu ra khỏi `com.apple.inputsources`. Chỉ khi đó app mới chuyển bộ gõ vào Thùng rác, dừng nó và xoá bộ đệm danh sách nguồn của System Settings, để "+" không còn dòng không tên.
  - Người dùng không bấm "–" thì app không gỡ gì.
- **Dấu đã cài nhưng không có trong nguồn đầu vào:** khi đó không có mục nào để bỏ, nên app gỡ luôn sau alert xác nhận. App không mở System Settings và không hiện sheet bấm "–".
- Huỷ hoặc lỗi thì app không xoá gì và không đổi nguồn đầu vào nào.
- App không đụng container riêng của bộ gõ (`~/Library/Containers/com.codefastlabs.dau.inputmethod.Dau`).
- **Gỡ trọn cả app:** sau khi bộ gõ đã ra khỏi máy, app chuyển chính nó (bản đang chạy) vào Thùng rác rồi thoát. Nếu app không chuyển được chính nó, chẳng hạn khi thiếu quyền ghi hay khi chạy từ ảnh đĩa, alert cuối có nút "Hiển thị trong Finder". Nút này mở Finder, chọn sẵn app để người dùng tự kéo vào Thùng rác, rồi app thoát.

**Vì sao:**

- Chỉ System Settings ghi được danh sách nguồn đang bật, nên app không tự bỏ được.
- App không tự chuyển bàn phím vì trên macOS 27.2 nút "–" bấm được cả khi Dấu đang được chọn. Khi đó macOS tự chuyển sang nguồn khác (đo bằng Dấu thật).
- App không đụng container riêng của bộ gõ vì một app khác đụng vào container có thể làm macOS hỏi quyền.
- Phương án gỡ tự động không cần "–" (xoá bộ gõ và bộ đệm, đo bằng bản thử) đã được cân nhắc và loại. Với phương án đó, mọi chỗ người dùng thấy đều sạch, nhưng mục "đã bật" của Dấu còn ẩn trong `com.apple.inputsources`. Khi cài lại thì macOS bật Dấu ngay mà không hỏi. Dấu chọn để máy sạch và để việc gỡ do chính người dùng xác nhận bằng "–".
- App tự chuyển chính nó vào Thùng rác vì alert xác nhận hỏi "Gỡ Dấu khỏi máy?". Người bấm "Gỡ cài đặt" chờ Dấu biến khỏi máy, không chờ phải tự tìm app trong Finder sau đó. Đồ trong Thùng rác vẫn lấy lại được, nên bấm nhầm không làm mất gì.

**Xem thêm:** [`docs/research/InputMethodInstall.md`](research/InputMethodInstall.md) mục 5.

### D17. Trợ năng

- Chuyển Việt/Anh là chuyển nguồn đầu vào của hệ thống, nên VoiceOver tự đọc tên nguồn (N1 (Không làm lại việc hệ thống đã có)). Dấu không tự thông báo thêm.
- Lượt kiểm bằng VoiceOver cho thấy hệ thống có đọc khi chuyển nguồn (`docs/history/LogM0ToM4.md`). VoiceOver có đọc đúng tên "Dấu – Tiếng Việt" hay không vẫn là câu hỏi mở.
- Nếu hệ thống không đọc thì quyết định này được xét lại.

**Vì sao:** để VoiceOver không đọc hai lần.

### D18. Phòng thủ với IMK

Dấu coi mọi tham số từ IMK là có thể nil hoặc bất thường (ví dụ bảng Emoji từng truyền NSEvent rỗng). Dấu không bao giờ crash vì đầu vào.

- Số do app trả (`selectedRange` và các vùng khác) kiểm biên ở một chỗ trước khi dùng. Số âm, `NSNotFound` hay vượt trần thì coi như app không cho dùng vị trí. Dấu không thay chữ theo nó.
- Lời gọi từ IMK hay từ app đến trong lúc Dấu đang xử lý một phím hoặc đang chốt chữ hoãn tới khi xong, không chạy lồng.
- Thông báo từ tiến trình khác (đổi nguồn, đổi cài đặt, yêu cầu thoát) chỉ là gợi ý để đọc lại trạng thái thật. Bản thân thông báo đó không làm reset hay đổi hành vi.
- **Kiểm bằng fuzz:** engine có test fuzz với seed cố định trong `swift test`, chạy mọi cấu hình với đầu vào thù địch. Khi sửa engine hay đường xử lý đầu vào, người sửa giữ test đó xanh và thêm loại đầu vào mới vào nó.

**Vì sao:** một lần rà soát tìm ra hai đường crash vì tràn số (vị trí rất lớn từ app, số đếm rất lớn ở engine) mà test theo ca không chạm tới; fuzz trên engine và đồ giả tái hiện được cả hai.

### D19. Quay về bản trước

Quay về bản trước tạm tắt tự động cập nhật cho tới khi có bản mới hơn bản lỗi. Cài đặt và quy tắc ứng dụng giữ nguyên.

- Tính năng này chưa làm ở beta đầu tiên (D7 (Cập nhật và loại bản dựng)).
- Bản cũ đặt vào chỗ bản chủ, nên bộ gõ lùi theo ở lần mở kế tiếp (D37 (Cài bộ gõ)).

**Vì sao:** để Sparkle không cài lại bản vừa gặp lỗi.

### D20. Thêm dấu cho từ đã gõ

Tính năng "Thêm dấu cho từ đã gõ" đọc chữ đang hiển thị như chữ cái, không như chuỗi phím đã gõ. Tính năng chỉ áp dụng khi kết quả là âm tiết tiếng Việt hợp lệ; nếu không, Dấu chèn nguyên phím đó như chữ cái.

- Nhờ vậy tính năng không xung đột với D4 (Từ nước ngoài). Chữ "car" giữ được bằng "carr". Quay lại gõ thêm "s" sau đó vẫn ra "cars". Trường hợp gõ liền trong cùng từ thì do D26 (Gõ đúp phím dấu) quy định.
- Áp dụng cho cả phím dấu thanh lẫn phím biến đổi (aa, ee, oo, w, dd…) theo luật bình thường trên chữ đang hiển thị.
- Không tự thêm biến đổi khác để từ thành hợp lệ ("viet" + j → "vietj" vì "viẹt" không hợp lệ; "viet" + e + j → "việt").
- "Hợp lệ" ở đây xét theo mức tiền tố của D30 (Kiểm tra chính tả), như lúc đang gõ ("viet" + e → "viêt"), với một khác biệt. Nguyên âm phải giữ đúng dấu phụ đang hiển thị, vì Dấu không tự thêm biến đổi khác. Vì vậy "viet" + j → "vietj", không chờ mũ như lúc gõ "viẹt". Hệ quả là "hoc" + f hiện "hòc". Khi kết thúc từ thì D31 (Âm tiết tiếng Việt hợp lệ) khôi phục thành "hocf".
- Gõ đúp trên từ đọc lại vẫn là xoá dấu theo D26 ("cả" + r → "car").
- Dấu không giữ "lịch sử từ" để Backspace quay lại sửa như OpenKey, vì trường hợp lùi về sau từ rồi gõ phím dấu đã được D20 phủ.
- **Khi nào đọc:** Dấu đọc ở phím chữ cái, phím dấu thanh hoặc phím biến đổi đầu tiên khi bộ đệm trống mà chưa biết chữ trước con trỏ (sau reset, click, ⌫, Return hoặc Tab). Luật này áp dụng cả khi trước con trỏ không có chữ hoặc khi phím đó cuối cùng được chèn nguyên. Mỗi lần như vậy gồm một `selectedRange` và một lần đọc chữ trước con trỏ (N3 (Ít lời gọi vào ứng dụng đích)). Gõ liền qua dấu cách thì không đọc.
- **Phạm vi:**
  - Tính năng không áp dụng ở app đang bật gạch chân (D13 (Gạch chân là đường lui cuối cùng)), vì từ đã chốt nằm ngoài vùng gạch chân và chế độ đó không thay chữ đã chốt.
  - Nếu app không trả vị trí hay chữ cho một lần đọc, phím đó đi như phím đầu của từ mới. Nếu hai lần đọc liền nhau đều không nhận được gì, Dấu không đọc lại tới lần kích hoạt sau (N3 (Ít lời gọi vào ứng dụng đích)). Một lần đọc được ở giữa thì bộ đếm bắt đầu lại.
  - Dấu đọc ở mọi nhịp gõ, kể cả khi phím dồn ("Hoc␣⌫j" gõ nhanh vẫn ra "Học"). Chữ đọc được kiểm như ở D11 (Kiểm tra ngữ cảnh), ý "App trả lời chậm". Nếu không tin được chữ đó, phím đó không đặt dấu vào chữ đã có.
  - Dấu chỉ xét phần chữ ngay trước con trỏ ("hoc|tap" + j → "họctap").
- **Chữ cái gõ sát chữ có sẵn:** khi phím đầu tiên là chữ cái thường, Dấu cũng đọc từ ngay trước con trỏ. Chữ đó chỉ nối vào từ khi từ ghép vẫn là tiền tố hợp lệ theo D30; ngược lại, chữ đó bắt đầu từ mới ("q" có sẵn + "uer" → "quẻ", "g" + "ias" → "giá", "tiê" + "ngs" → "tiếng"; "tôi" + "laf" → "tôilà", "sắc" + "mauf" → "sắcmàu").
  - Hệ quả là chữ cái gõ sau khi ⌫ qua dấu cách sẽ nối lại vào từ trước nếu kết quả hợp lệ ("ba␣⌫nj" → "bạn"). Ví dụ "duow␣⌫c" giữa từ hiện "dươc". Khi kết thúc từ thì D31 khôi phục "duơc", vì "ươc" cần sắc hoặc nặng.
- **Ba ngoại lệ:**
  - (a) Nếu chữ cuối của từ có sẵn là chữ thường mà phím là chữ hoa, phím đó bắt đầu từ mới, vì tiếng Việt không có chữ hoa giữa âm tiết ("#Hà" + "Nooij" → "#HàNội"; "VI" + "EEJT" → "VIỆT" và "V" + "ieejt" → "Việt" vẫn nối). Luật này không áp dụng khi phím đó đặt dấu thanh hoặc biến đổi lên từ có sẵn, vì khi đó phím không thêm chữ nào ("hoc" + "J" → "học").
  - (b) Nếu từ có sẵn không phải tiếng Việt, chữ gõ tiếp, kể cả phím dấu, thuộc về từ đó và được chèn nguyên tới hết từ, như khi gõ liền ("foo" + "bar" → "foobar", "keyboard" + "bar" → "keyboardbar"). Từ có sẵn không phải tiếng Việt khi nó không là tiền tố hợp lệ theo D30, dài hơn 7 chữ cái như D33 (Độ dài từ) hoặc có chữ cái engine không biết.
  - (b) thắng (a), vì chữ hoa giữa một từ nước ngoài là kiểu viết camelCase ("foo" + "Bar" → "fooBar", như gõ liền). Cái giá phải trả là từ tiếng Việt gõ dính sau từ nước ngoài cũng được chèn nguyên ("iPhone" + "mowis" → "iPhonemowis", như gõ liền).
  - (c) Nếu phím đầu tiên là phím dấu thanh hoặc phím biến đổi mà không áp dụng được lên từ tiếng Việt có sẵn (từ ghép hết hợp lệ), phím đó bắt đầu từ mới như chữ cái ("anh" + "emx" → "anhẽm", "tôi" + "ddi" → "tôiđi"). Gõ đúp để xoá dấu theo D26 vẫn tính là áp dụng được ("cả" + "r" → "car").
- **Từ hệ thống vừa sửa:** tự sửa chính tả của macOS (D4) có thể đổi từ Dấu vừa trả ngay sau dấu cách. Giả sử người gõ ⌫ qua dấu cách hoặc dấu câu vừa kết thúc từ (không tính Return, Tab) rồi gõ phím dấu và kết quả D20 trên từ Dấu đã trả trùng với chữ đang hiện (không phân biệt hoa thường). Khi đó Dấu giữ nguyên chữ, cho kết quả như khi hệ thống không sửa ("Tôi hoc␣⌫j bài" → "Tôi học bài", không thành "hocj"). Nếu hệ thống sửa thành chữ khác kết quả đó ("cat" → "cắt", ⌫ s), D20 tính trên chữ đang hiện như cũ.
  - Luật này không áp dụng khi từ Dấu đã trả kết thúc lúc còn hiện chữ của phím gõ đúp (D26) hoặc khi đó là từ D4 đã khôi phục, vì người gõ đã chọn chữ không dấu ("carr" → "car", hệ thống sửa thành "cả", ⌫ r vẫn ra "car"). Từ mà Backspace đã xoá chữ của phím gõ đúp thì tính như mọi từ ("carr" ⌫ r → "cả").
  - Dấu chỉ nhớ đúng từ vừa trả và quên nó khi có click, mũi tên, phím tắt, đổi nguồn hay ⌫ thứ hai. Đây không phải "lịch sử từ" nói ở trên.
- **Sau sự kiện reset của D4:** sự kiện reset của D4 (mũi tên, click, đổi nguồn, ⌘, ⌃, ⌥) chỉ xoá bộ đệm, không chặn D20. Phím dấu kế tiếp có thể đặt dấu vào chữ ngay trước con trỏ. Ví dụ gõ "tooi" rồi ← thì con trỏ ở "tô|i"; gõ tiếp "s" thì phần trước con trỏ "tô" thành "tố", chữ "i" sau con trỏ giữ nguyên và cả từ là "tối". Gõ "to", đổi nguồn rồi đổi về, gõ "o" thì ra "tô". Muốn không có hành vi này thì tắt công tắc D20.

**Hệ quả đã chấp nhận:**

- Từ mới viết thường hoặc viết hoa như từ có sẵn, gõ dính sau từ tiếng Việt mà vài chữ đầu ghép lại vẫn hợp lệ thì vẫn nối ("#hà" + "nooij" → "#hànooij", "ba" + "nawm" → "banawm"). Giữ song song hai cách hiểu thì sửa được, nhưng phải viết lại cả chữ có sẵn trong app.
- Với từ hệ thống vừa sửa, nếu người gõ muốn xoá dấu hệ thống vừa thêm bằng cách gõ lại phím dấu, lần gõ đầu không đổi gì. Xoá bằng z hay ⌘Z vẫn chạy.

**Vì sao:**

- Ngưỡng là hai lần đọc hỏng liền nhau, không phải một. Ở app Claude, "cao␣⌫s" từng ra "caos". Gõ lại ⌫⌫s vẫn ra "cas". Trên đồ giả, chỉ việc thôi đọc sau một lần đọc hỏng trước đó mới tái hiện được đủ chuỗi đó. Lần đọc hỏng ấy chưa bắt được ngoài đời. Với ngưỡng hai lần, app không bao giờ cho đọc chỉ tốn thêm một lần đọc mỗi lần kích hoạt.
- Dấu không chờ khi phím dồn. App áp phím bất đồng bộ có thể trả vị trí và chữ từ ảnh chụp cũ. Chữ đó có thể bị thay sai chỗ; phép kiểm "App trả lời chậm" của D11 chặn việc đó cho lần đọc này. Khi chờ 50 ms sau phím trước, "Hoc␣⌫j" gõ cách nhau 5 hay 30 ms ra "Hocj" ở Safari, Chrome, VS Code; khi không chờ thì ra "Học" (đo 17/11/2026, máy M1 Pro). Khi không chờ, mô phỏng Chrome, VS Code, Firefox ở 0–20 ms không hỏng chữ nào. App thật cũng chưa hỏng chữ (`docs/history/LogM0ToM4.md`, bảng "Số đo (M1–M3)", dòng "D20 không chờ").
- Cách xử lý chữ cái gõ sát chữ có sẵn chọn bằng mô phỏng engine trên 10.303 ca ngoài và các tình huống sửa chữ. Hai phương án đem so là chỉ đọc ở phím dấu và luôn nối; luôn nối làm hỏng 34 ca gõ từ mới sát từ cũ.
- Với ba ngoại lệ, trên cùng 10.303 ca, (a) không đổi ca nào, (b) đổi 2 ca, (c) đổi 24 ca và không bất biến nào hỏng.
- Luật "Từ hệ thống vừa sửa" có vì ở app bật tự sửa, hệ thống đổi "hoc" thành "học" trước phím j và gõ lại phím dấu là xoá dấu (D26), nên "Tôi hoc␣⌫j bài" từng ra "hocj".

**Xem thêm:** mô phỏng ở [`docs/research/external-test-inputs/README.md`](research/external-test-inputs/README.md) mục 3.4; chi phí mỗi lần đọc và số đo "Từ hệ thống vừa sửa" ở [`docs/history/DecisionsLog.md`](history/DecisionsLog.md) mục D20; cơ chế ở [`docs/Architecture.md`](Architecture.md) mục "Thêm dấu cho từ đã gõ".

### D21. Gõ tắt phụ âm

Gõ tắt phụ âm thuộc nhóm Nâng cao và mặc định tắt.

- Gõ tắt chỉ áp dụng khi kết thúc từ (ranh giới theo D4 (Từ nước ngoài)) và chỉ khi kết quả là âm tiết tiếng Việt hợp lệ; nếu không thì D4 khôi phục. Cách này khác OpenKey, nơi gõ tắt chạy trước và chặn luôn bước khôi phục ("big" thành "bing" dù không hợp lệ).
- Từ trùng như "bag" → "bang", "fix" → "phĩ" vẫn xảy ra vì người dùng đã chủ động bật tuỳ chọn. Test ghi rõ các ca này.
- Trong lúc gõ, trước khi kết thúc từ, nếu tuỳ chọn bật thì f, j (VNI thêm w) ở đầu từ và g, h, k ở cuối từ được coi là phụ âm tạm hợp lệ, để phím dấu vẫn có tác dụng ("fanf" hiện "fàn", kết thúc từ ra "phàn").
- Dấu không làm Quick Telex (cc → ch, nn → ng…).

**Vì sao:** Quick Telex kích hoạt cả giữa từ nên phá từ tiếng Anh có phụ âm đôi ("connect" → "congect") và trùng mục đích với gõ tắt phụ âm.

**Xem thêm:** cách OpenKey làm ở [`docs/research/OpenKeyNotes.md`](research/OpenKeyNotes.md) (B9).

### D22. Gõ tắt loại trừ z, f, w, j

Gõ tắt phụ âm và "Cho phép phụ âm z, f, w, j" loại trừ nhau.

- Bật mục này thì mục kia tắt. Giao diện ghi rõ điều đó.
- Với Telex, w đầu từ luôn thành ư (D23 (w → qu chỉ ở VNI)), nên "cho phép w" không có tác dụng. Giao diện ghi chú điều này khi người dùng đang dùng Telex.

**Vì sao:** hai tuỳ chọn cùng tác động lên f, j, w ở đầu từ.

### D23. w → qu chỉ ở VNI

Gõ tắt w → qu chỉ có ở VNI. Với Telex, w ở đầu từ luôn là ư ("wa" → "ưa").

**Vì sao:** trong OpenKey, quy tắc w → qu không bao giờ kích hoạt ở Telex, nên Dấu không đưa nó vào Telex.

### D24. Tên và định danh

- "Dấu" là tên thương hiệu, như "Phở" hay "Mì Quảng". Ở mọi ngôn ngữ, tên vẫn viết là "Dấu", không dịch và không viết không dấu (`scripts/check-l10n/check.sh` chặn "Dau" trong chuỗi giao diện).
- Tên luôn viết có dấu ở mọi chỗ người dùng nhìn thấy: tên app, tên nguồn đầu vào ("Dấu – Tiếng Việt"; trên macOS tiếng Anh là "Dấu – Vietnamese", D41 (Ngôn ngữ giao diện)), website và logo.
- Bản không dấu "dau" chỉ dùng cho định danh kỹ thuật (bundle ID, tên target, repo, cask) và không bao giờ đứng một mình trước người dùng.
- Tên miền là `dau.codefastlabs.com`.
- Định danh kỹ thuật theo tên miền đảo. Bundle ID của app là `com.codefastlabs.dau`, của bộ gõ là `com.codefastlabs.dau.inputmethod.Dau`. ID của input mode là `com.codefastlabs.dau.inputmethod.Dau.vi`. App Group là `<Team ID>.com.codefastlabs.dau.shared`.
- Mọi bản phải ký bằng một Team ID, vì App Group cần Team ID. Bản phát triển dùng Personal Team `M58DANM3ZP`, còn bản phát hành ký Developer ID (D7 (Cập nhật và loại bản dựng)).
- Tên cask Homebrew là `dau`, nằm trong tap `codefastlabs/homebrew-tap` (D6 (Phát hành)).

**Vì sao:** "dau" đứng một mình dễ bị đọc thành "đau" hay "dầu". Bản ký ad-hoc (không Team ID) bị macOS 27 từ chối App Group mà không báo gì; bản có Team ID, kể cả Personal Team miễn phí, dùng được App Group không cần hồ sơ cấp phép và không có hộp thoại.

### D25. Nhận diện

- Biểu tượng là chữ "ấ" màu Giấy trên nền Mực, riêng dấu sắc màu Son. Logo chữ "Dấu" dùng phông Be Vietnam Pro, một màu. Màu Son chỉ dùng trong biểu tượng, còn app vẫn dùng phông và màu hệ thống (D9 (Giao diện)).
- **Biểu tượng theo loại bản** (các loại bản ở D7 (Cập nhật và loại bản dựng)):
  - Biểu tượng chuẩn chỉ có ở bản phát hành, chọn bằng một cờ build mà chỉ quy trình phát hành trên CI đặt. Mặc định, tức mọi bản phát triển (Debug, Release tự dựng, bản người khác build), dùng biểu tượng **bản phát triển**.
  - Biểu tượng bản phát triển giữ chữ "ấ", đổi nền và có thêm một dấu hiệu bằng hình, để vẫn nhận ra khi macOS bỏ màu (kiểu Trong suốt, Phủ màu của Icon Composer). Biểu tượng đó có **nền Chì, dải chéo màu Hổ phách ở góc dưới phải**. Biểu tượng không có chữ, không dùng Son cho dải và không đảo màu.
  - Kênh Beta dùng biểu tượng chuẩn. Số hiển thị không có chữ beta (D7). Bản phát hành ghi số build (`CFBundleVersion`) trong ngoặc ("Dấu 1.3.0 (6520)") ở trang Cập nhật & hỗ trợ và thanh bên, như bảng About chuẩn của AppKit (`orderFrontStandardAboutPanel`) và khớp cách cửa sổ của Sparkle ghi khi hai bản cùng số hiển thị. Hàng "Kênh phát hành" cho biết bản là beta hay chính thức; điều đó không ghi cạnh số phiên bản.
  - Báo lỗi điền sẵn (D8 (Không telemetry)) ghi cả số build và commit ("Dấu 1.3.0 (6520, a1b2c3d)"), vì từ số build không biết được bản dựng từ commit nào.
  - Debug và Release không có hai biểu tượng riêng. Bản phát triển ghi commit thay cho số build ("Dấu 1.0.0 (a1b2c3d)"), vì người đọc là người phát triển. Trang Cập nhật & hỗ trợ không có dòng ghi loại bản. Chỉ bản Debug ghi thêm "Debug" trong ngoặc cùng commit ("Dấu 1.0.0 (a1b2c3d, Debug)"), cả cho bộ gõ đã cài; bản Release không ghi cấu hình. `scripts/dev/dau-version.sh` in commit và cấu hình (Debug hay Release) của từng bản đã cài.
  - Bundle ID không đổi theo loại bản (D37 (Cài bộ gõ)).
  - Tên cũng không đổi: bản phát triển vẫn là "Dấu" (tên app, tên nguồn "Dấu – Tiếng Việt"). Biểu tượng và commit trong ngoặc đã đủ phân biệt. Đổi tên nguồn giữa hai lần cài có thể vướng bộ đệm TIS (D37).
  - Biểu tượng "V" trên thanh menu giống nhau ở mọi bản (ảnh template, D9).

**Vì sao:**

- Biểu tượng chỉ trả lời câu "đây có phải bản phát hành không". Bằng chứng là chữ ký Developer ID. App chủ kiểm chữ ký của bộ gõ (D37).
- Dấu hiệu là dải góc chứ không phải nền sọc, vì nền sọc mất ở 16–32 pt và ở kiểu Trong suốt. Biểu tượng không có chữ vì ở 16–32 pt chữ không đọc được. Biểu tượng không đảo màu vì dễ nhầm với kiểu Tối của biểu tượng chuẩn.
- Kênh Beta dùng biểu tượng chuẩn vì người dùng Beta là người dùng thật. Đổi biểu tượng mỗi lần đổi kênh chỉ gây rối.
- Bản phát hành ghi số build trong ngoặc vì người dùng không đọc được commit. Số build tăng dần nên so được bản nào mới hơn và trùng chữ với cửa sổ cập nhật: khi bản mới và bản đang chạy cùng số hiển thị, Sparkle tự ghi số build sau cả hai (`SPUStandardVersionDisplay`, Sparkle 2.10.1). Bản phát triển giữ commit vì người đọc cần biết bản dựng từ đâu.
- Không có dòng "Bản phát triển", vì người thấy bản phát triển là người phát triển. Biểu tượng cùng commit trong ngoặc đã cho biết loại bản. Bản Release không ghi "Release" vì đó là trạng thái bình thường. Debug là ngoại lệ (log mỗi phím, `get-task-allow`, D8) nên mới cần ghi.

**Xem thêm:** màu và artboard ở [`docs/Brand.md`](Brand.md).

### D26. Gõ đúp phím dấu

Sau khi người gõ gõ đúp phím dấu để giữ chữ gốc (chuẩn Telex, D4 (Từ nước ngoài)), các phím dấu tiếp theo trong cùng từ được chèn nguyên như chữ cái. Khoá này kéo dài tới khi kết thúc từ (ranh giới theo D4) hoặc tới khi Backspace xoá chữ của phím gõ đúp ("carr" → "car", "carrs" → "cars"). Luật này khớp với ví dụ ở D20 (Thêm dấu cho từ đã gõ).

- Gõ đúp phím biến đổi ("aaa" → "aa", "ddd" → "dd", "ww" → "w") và gõ đúp ở VNI ("a11" → "a1") theo cùng luật.
- **Backspace:** khi chữ của phím gõ đúp còn trên màn hình, khoá giữ nguyên ("tesst" ⌫ s → "tess"). Khi Backspace xoá chữ đó, khoá mở và phím sau lại đặt dấu và biến đổi như thường ("carr" ⌫ r → "cả", "nhaamff" ⌫ f → "nhầm", "aaa" ⌫ a → "â", VNI "a11" ⌫ 1 → "á"). Chính lần Backspace đó cho kết quả như khi còn khoá.
- Khoá không sang từ sau ("tesst" ⌫ s, dấu cách, "cas" → "tess cá").
- "ooo" là ngoại lệ: "ooo" → "oo" nhưng **không** khoá phím dấu sau đó, để gõ được "xoong", "boong", "xoòng" ("xooongf" → "xoòng").
- "ww" trên "ưa" cũng bỏ móc như mọi nguyên âm khác ("huaww" → "huaw").
- Chữ ư từ một phím w đứng riêng (D23 (w → qu chỉ ở VNI)) là một ngoại lệ khác. Khi sau chữ ư đó đã có nguyên âm khác, phím w sau không bỏ móc của nó ("ww" → "w" vẫn theo D26). Phím w đó là chữ cái. Khi kết thúc từ thì D4 khôi phục ("Warwick", "waxwing" giữ nguyên).

**Hệ quả đã chấp nhận:**

- Từ tiếng Anh có chữ cái lặp trùng phím dấu thanh mất một chữ nếu gõ bình thường ("password" → "pasword", "coffee" → "cofee"). Muốn giữ thì gõ chữ đó 3 lần ("passsword", "cofffee").
- Từ tiếng Anh có chữ cái lặp trùng phím dấu thanh hoặc phím biến đổi mất cả dấu lẫn một chữ ("worry" → "ưory", "express" → "êps", "versus" → "veus"). Dấu giữ nguyên hành vi này; người dùng gõ tiếng Anh bằng U.S. (D2 (Chuyển Việt/Anh)).
- Khi Backspace lùi qua chữ của phím gõ đúp rồi gõ lại, từ thành chữ Việt ("tesst" ⌫⌫ "st" → "tét", "passs" ⌫⌫ "ssword" → "pasword"). Muốn giữ chữ gốc thì gõ đúp lại ("tesst" ⌫⌫ "sst" → "test").
- "carr" ⌫ r ⌫ r ra "cr", vì Backspace trên "cả" bỏ cả chữ "ả" (D32 (Backspace)).

**Vì sao:**

- Phương án khôi phục theo phím gốc thay vì chữ hiển thị đã được cân nhắc. Với phương án đó, gõ "password" tự nhiên được, nhưng các từ vừa là tiếng Anh vừa là âm tiết hợp lệ có phím dấu thanh giữa từ (test, best, list, most, post) không còn cách nào gõ ở chế độ Tiếng Việt. Phương án bị loại vì mọi từ phải gõ được.
- Với chữ ư, cách áp D26 đã bị loại, vì "Warwick" → "Waick", "waxwing" → "waing" và chữ mất không khôi phục được.
- Backspace mở khoá vì khoá là dấu hiệu người gõ chọn chữ gốc. Dấu hiệu đó là chữ của phím gõ đúp trên màn hình. Xoá chữ đó thì không còn dấu hiệu, nên "tiếng Việt thắng" của D4 áp dụng lại. Người lỡ gõ đúp phím dấu thường xoá đúng chữ thừa rồi gõ lại dấu; khi khoá còn giữ qua Backspace, cách sửa đó không ra chữ muốn. OpenKey, XKey, bamboo-core và gonhanh cũng mở khoá như vậy.

**Xem thêm:** ca thử của bộ gõ khác ở [`docs/research/external-test-inputs/README.md`](research/external-test-inputs/README.md) mục 1; mô phỏng người gõ sửa chữ ở [`docs/research/EditingTypedText.md`](research/EditingTypedText.md) mục 4.

### D27. Không có phím gõ nhanh ơ, ư

Telex của Dấu không có phím gõ nhanh `[` → ơ, `]` → ư. `[` và `]` luôn là dấu câu và kết thúc từ.

### D28. Đặt dấu tự do

Đặt dấu tự do mặc định bật (D15 (Cài đặt mặc định)).

- **Khi bật:** phím dấu thanh gõ ở bất kỳ đâu sau nguyên âm đầu cũng được, kể cả sau phụ âm cuối. Dấu thanh tự vào đúng nguyên âm và tự dời khi gõ thêm nguyên âm ("hof" + a → "hoà" kiểu mới).
  - Phím d sau nguyên âm vẫn biến d đầu từ thành đ ("did" → "đi"); với từ trùng thì tiếng Việt thắng theo D4 (Từ nước ngoài).
  - Phím biến đổi (aa, ee, oo, w, dd; VNI 6, 7, 8, 9) và phím dấu thanh tác dụng lên nguyên âm hay phụ âm phù hợp trong từ, không cần đứng sát ("tuongw" → "tương"; VNI "duo7c59" → "được").
- **Khi tắt:** phím dấu thanh chỉ có tác dụng khi gõ ngay sau nguyên âm. Dấu đã đặt vẫn tự dời khi gõ thêm nguyên âm ("hof" + a → "hoà"). Phím biến đổi nguyên âm (w, aa, ee, oo; VNI 6, 7, 8) vẫn tác dụng từ xa ("tuongw" → "tương"). d chỉ thành đ khi hai d liền nhau ("did" giữ "did").
- **Phím biến đổi khác loại:** gõ phím biến đổi lên nguyên âm đã có dấu phụ khác thì đổi sang dấu mới, kể cả trên cụm hai nguyên âm ("aaw" → "ă", "owo" → "ô", "ươ" + o → "uô", "cuoiwo" → "cuôi").

### D29. Telex đơn giản

Telex đơn giản là Telex, trừ các điểm sau.

- w chỉ biến đổi khi trong từ có a, o, u để nhận dấu trăng hoặc móc. Theo D28 (Đặt dấu tự do), w không cần đứng sát ("tuongw" → "tương"). Nếu trong từ không có các nguyên âm đó thì w là chữ w và không thành ư, nên "web", "www" gõ thoải mái.
- Telex đơn giản không có `[ ]` (như D27 (Không có phím gõ nhanh ơ, ư)).
- Telex đơn giản không có gõ tắt w → qu (D23 (w → qu chỉ ở VNI)).

**Xem thêm:** Simple Telex 1 của OpenKey ở [`docs/research/OpenKeyNotes.md`](research/OpenKeyNotes.md) mục 2.5.

### D30. Kiểm tra chính tả

Kiểm tra chính tả luôn chạy trong engine và không có công tắc riêng. Khi từ đã sai chính tả, engine ngừng biến đổi các phím tiếp theo.

- Trong lúc gõ, engine chỉ xét từ có còn là **tiền tố** của một âm tiết hợp lệ hay không. Vì vậy "viêt", "hoc", "tră" vẫn biến đổi tiếp ("vieetj" → "việt", "hocj" → "học", "trawngf" → "trằng"). Quy tắc đầy đủ của D31 (Âm tiết tiếng Việt hợp lệ) chỉ áp khi kết thúc từ.
- Sau Backspace (D32 (Backspace)), trạng thái sai chính tả tính lại từ chữ còn hiển thị.
- Công tắc "Tự khôi phục từ không phải tiếng Việt" chỉ điều khiển việc khôi phục, cả khi kết thúc từ lẫn giữa từ khi từ quá dài (D33).
- **Dấu thanh trên vần tắc:** "tiền tố hợp lệ" chỉ xét chữ cái của âm tiết, còn dấu thanh chỉ được kiểm theo D31 khi kết thúc từ. Vì vậy huyền, hỏi, ngã trên vần có âm cuối p, t, c, ch vẫn được nhận giữa từ ("hoc" + f hiện "hòc"). Khi kết thúc từ, D4 (Từ nước ngoài) khôi phục từ đó ("metric", "catr" giữ nguyên).

**Hệ quả đã chấp nhận:** giữa từ tiếng Anh có thể nháy chữ có dấu ("mẻt…"). Khi tắt tự khôi phục, chữ sai chính tả ở lại.

**Vì sao:** engine nhận dấu thanh trên vần tắc giữa từ để người gõ vẫn sửa được dấu bằng phím dấu thanh khác ("hocfj" → "học", "matfs" → "mát") và vẫn đặt dấu tự do được (D28 (Đặt dấu tự do), "cafts" → "cát"). Phương án chèn nguyên phím đó như chữ cái đã bị loại, vì nó làm hỏng cả ba cách gõ trên.

### D31. Âm tiết tiếng Việt hợp lệ

Định nghĩa này dùng cho D4 (Từ nước ngoài), D20 (Thêm dấu cho từ đã gõ), D21 (Gõ tắt phụ âm) và D30 (Kiểm tra chính tả), theo chính tả chuẩn.

- Phụ âm đầu thuộc danh sách chuẩn, có thêm "p" (pin, pa-tê).
- Các chữ c, k, q, g, gh, ng, ngh phân bố theo các quy tắc sau.
  - gh và ngh chỉ đứng trước i, e, ê.
  - c, g, ng không đứng trước i, e, ê, y.
  - k đứng trước i, e, ê, y. Theo luật nới cho địa danh bên dưới thì k đứng trước mọi nguyên âm.
  - c không đứng trước oa, oă, oe, uy, uê, uâ, vì chính tả viết qu.
  - q luôn đi với u.
- iê không đứng đầu âm tiết, mà viết là yê (yên, yêu). yê sau phụ âm chỉ có trong uyê (khuyên, tuyết).
- Vần phải thuộc bảng vần hợp lệ do Dấu tự lập theo chính tả, không chép bảng của OpenKey. Bảng vần có "oao" (ngoao, ngoáo) và "uêu" (nguều).
- Vần kết thúc bằng p, t, c, ch chỉ mang sắc hoặc nặng. Vần đó không có dấu thanh là không hợp lệ. Vì vậy "bak" với gõ tắt phụ âm vẫn giữ nguyên "bak".
- ă, â không đứng cuối âm tiết ("traw" khôi phục thành "traw").
- **Chữ cái đứng một mình:** một từ chỉ gồm đúng một chữ ă hoặc â (có hoặc không có dấu thanh) hoặc một chữ đ, được giữ khi kết thúc từ, hoa hay thường như nhau (`aw` → "ă", `aa` → "â", `dd` → "đ", `aas` → "ấ", `AA` → "Â", `DD/c` → "Đ/c"). Muốn giữ chữ gốc thì gõ đúp phím (D26 (Gõ đúp phím dấu): `aaa` → "aa", `ddd` → "dd"). Từ dài hơn một chữ không đổi. Với D20, chữ "a" hoặc "d" có sẵn sát con trỏ rồi gõ `a`, `w` hoặc `d` cũng là từ một chữ, nên ra "â", "ă", "đ".
- Phím dấu gõ ngay sau "qu" được nhận như sau "gi" ("qusa" → "quá"). "qui" vẫn không hợp lệ; theo chính tả chuẩn chỉ có "quy".
- b, m, p, v đi với âm đệm o, u là hợp lệ (buýt, boa, voan). Vì vậy "more" → "moẻ" theo D4. Người gõ gõ đúp để giữ chữ gốc.
- **Nới cho địa danh:** k được đứng trước mọi nguyên âm (Kon Tum, Bắc Kạn, Kơ Tu), "kr" được làm phụ âm đầu (Krông Pắc) và k được làm âm cuối **chỉ sau ă**, với cùng ràng buộc dấu như c (Đắk Lắk). Dấu không dùng danh sách ngoại lệ, cùng tinh thần với D4.
  - Vần "ăk" chỉ được nhận khi ă đã có trước k ("Lawks" → "Lắk"). Phím biến đổi gõ sau k ("lakws") không biến đổi.

**Hệ quả đã chấp nhận:**

- Với chữ cái đứng một mình, "AA", "DD", "aw", "dd" gõ hai phím ra "Â", "Đ", "ă", "đ". Muốn chữ gốc thì gõ đúp.
- Với luật nới cho địa danh, trên 428 từ tiếng Anh có 6 từ đổi (karma → kẩm, Kansas → Kâns, Kris → Krí, hawks → hắk, gawks → gắk, awkward → akward).

**Vì sao:**

- Chữ cái đứng một mình được giữ vì người viết bảng chữ cái hay người dạy tiếng Việt gõ từng mặt chữ ("a, ă, â… d, đ") và chữ viết tắt "Đ/c", "Đ." bắt đầu bằng một chữ đ đứng riêng. Trước đó ba chữ này bị D4 trả về phím gốc. Không có cách gõ nào ngoài việc tắt tự khôi phục. Telex của Apple giữ các chữ này, kể cả chữ hoa.
- Với địa danh, phương án cho k làm âm cuối ở mọi vần đã bị loại, vì nó làm hỏng 19 từ (ask → ák, task, desk, mask…).
- "ăk" chỉ được nhận khi ă có trước k, vì cho "ak" là tiền tố hợp lệ sẽ làm "asks", "tasks", "masks" mất một chữ s (D26).
- Phương án cho "qui" là hợp lệ đã bị loại, vì khi đó "quits" → "quít", "quips" → "quíp".

**Xem thêm:** ba điểm "qu", âm đệm sau b, m, p, v và hai vần "oao", "uêu" lấy từ ca thử của bộ gõ khác ([`docs/research/external-test-inputs/README.md`](research/external-test-inputs/README.md) mục 2.2).

### D32. Backspace

Backspace bỏ chữ cuối đang hiển thị khỏi bộ đệm và đặt lại dấu theo vần còn lại ("hoà" ⌫ → "hò").

- Từ lúc đó, mốc khôi phục của từ là chữ đang hiển thị; Dấu không giữ chuỗi phím gốc cũ.
- Khi chỉ còn lại "qu" thì không còn vần để đặt dấu ("quá" ⌫ → "qu").

**Vì sao:** để tránh hai bộ đệm lệch nhau như ở OpenKey.

### D33. Độ dài từ

Từ dài hơn âm tiết dài nhất (7 chữ cái, như "nghiêng") được khôi phục ngay về chuỗi phím đã gõ nếu đã biến đổi, không chờ kết thúc từ. Dấu chèn nguyên mọi phím còn lại tới hết từ.

- Khi công tắc "Tự khôi phục từ không phải tiếng Việt" tắt, engine chỉ ngừng biến đổi mà không khôi phục, đúng với ý nghĩa của công tắc ở D30 (Kiểm tra chính tả).
- Xoá hết từ bằng Backspace thì trạng thái chèn nguyên chấm dứt ("permission" + 10 ⌫ + "vieetj" → "việt").

**Vì sao:** nhờ vậy bộ đệm có dung lượng cố định, không cấp phát thêm và không mất chữ.

### D34. Chữ hoa với phím biến đổi

Phím biến đổi và phím dấu thanh không đổi kiểu hoa của chữ. Chữ viết hoa hay thường theo chữ cái gõ đầu tiên ("dD" → "đ", "Dd" → "Đ", "aA" → "â").

### D35. "uơ" và "ươ"

Móc trên cặp u-o (Telex "uow"/"uwo", VNI "uo7") cho "uơ" khi cặp đứng cuối từ ("huơ", "thuở") và tự thành "ươ" khi gõ thêm chữ sau ("uown" → "ươn", "nguwowif" → "người").

- **Thứ tự u + móc + o:** Telex "uwo" và VNI "u7o" theo cùng luật ("uwo␣" → "uơ␣", "thuwor" → "thuở", VNI "thu7o3" → "thuở"; "nguwoif" → "người").
- Phím móc gõ thêm trên cặp đó thêm móc cho u ("nguwowif", VNI "ngu7o72i" → "người"), chứ không bỏ móc theo D26 (Gõ đúp phím dấu).

**Hệ quả đã chấp nhận:** "thu7o73␣" và "thuwowr␣" giữa từ thành "thưở", không phải vần hợp lệ, nên khi kết thúc từ D4 (Từ nước ngoài) khôi phục phím đã gõ.

### D36. VNI: chữ số thành dấu

Với VNI, chữ số sau âm tiết hợp lệ thành dấu ("U23" → "Ủ", "A4" → "Ã", "lan2" → "làn"), cùng luật tiếng Việt thắng (D4 (Từ nước ngoài)).

- Muốn giữ chữ số thì gõ đúp ("U223" → "U23", D26 (Gõ đúp phím dấu)).
- Dấu chèn nguyên chữ số gõ khi bộ đệm rỗng ("2024").
- Bảng gõ VNI và phần hỏi đáp của website ghi rõ luật này.

### D37. Cài bộ gõ

- **App chủ không chạy sandbox.** Bộ gõ vẫn chạy sandbox và không có quyền mạng (N2 (Bộ gõ không có quyền mạng)). App Group giữ nguyên.
- **Không đổi giữa các bản:** bundle ID, ID mode `….Dau.vi`, tên kết nối, tên file, tên tiến trình bộ gõ và ngôn ngữ của nguồn không đổi giữa các bản. Tên hiển thị và biểu tượng nguồn cũng nên giữ nguyên.
- **Bật lần đầu:** khi người dùng bấm "Bật Dấu", app chép bộ gõ. Ngay trước khi đăng ký, app xoá bộ đệm danh sách nguồn đầu vào của System Settings và của từng app; thư mục nào không có quyền thì app bỏ qua và ghi nhật ký. App thoát System Settings nếu đang chạy, rồi xin macOS bật mục cha. Khi đó macOS mở System Settings và hỏi "Allow “Dấu” to enable “…”?". Trên macOS 27.2, ở tài khoản đã từng cài Dấu, các bước này cho bật mà không cần đăng xuất.
- App chỉ tính là đã bật khi `com.apple.inputsources` › `AppleEnabledThirdPartyInputSources` có mục của Dấu, chứ không tin cờ enabled của TIS.
- Sau khi đã bật, app quét lại một lượt. Bộ đệm nào vẫn không có bộ gõ của Dấu, vì dựng lại trong khoảng giữa lúc xoá và lúc đăng ký, thì app xoá rồi đăng ký lại một lần.
- Gỡ cài đặt chỉ xoá bộ đệm của System Settings (D16 (Bảo trì và gỡ cài đặt)). Bộ đệm riêng của từng app vẫn nhớ bộ gõ đã gỡ. Hậu quả của việc đó chưa đo.
- **Đường lui:** hành vi bộ đệm của System Settings và của từng app không có tài liệu Apple. Bản macOS sau có thể khác. Nếu đọc lại không thấy mục của Dấu, app hướng dẫn người dùng tự thêm bằng "+". Nếu "+" không có Dấu thì người dùng đăng xuất một lần (Apple DTS).
- **Một app vẫn không chọn được Dấu** khi bộ đệm riêng của nó không xoá được, như ở các thư mục hệ thống bảo vệ. Khi đó Dấu hướng dẫn đăng xuất rồi đăng nhập lại một lần, ở màn "Đã bật" của onboarding, ở sheet Báo lỗi và ở phần Hỏi đáp của trang tải về.
- Homebrew cask chỉ khai `app`.
- **Bản chủ:** Dấu.app nằm trực tiếp trong `/Applications` là bản chủ của bộ gõ đã cài. Dấu.app ở đây là bản app mang bundle ID của Dấu, tìm theo bundle ID chứ không theo tên file. Liên kết tượng trưng không tính. Nếu `/Applications` không có Dấu.app thì bản nằm trực tiếp trong `~/Applications` là bản chủ. Một bản Dấu đang chạy là bản chủ khi mã băm chữ ký (cdhash) của nó trùng với bản đó, bất kể nó đang chạy từ đường dẫn nào. Nếu thư mục đó có hơn một bản Dấu.app thì trùng với bản nào trong số đó cũng là bản chủ.
- **Chỉ bản chủ cài và thay bộ gõ:** bản không phải bản chủ (chạy từ ảnh đĩa, Downloads, thư mục build) không chép, không thay, không cài lại và không kiểm chữ ký bộ gõ đã cài. Khi bộ gõ chưa cài, bản đó hướng dẫn chuyển Dấu vào thư mục Applications rồi mở lại. Cài đặt, bật lại và gỡ cài đặt vẫn dùng được.
- **Bộ gõ đã cài là bản nhúng của bản chủ:** mỗi lần mở, bản chủ so mã băm chữ ký của bộ gõ đã cài với bản nhúng, ở mọi kiến trúc. Nếu khác nhau, bản chủ thay bộ gõ bằng bản nhúng mà không đổi trạng thái bật hay chọn. Bản chủ không so số phiên bản. Nếu bộ gõ chưa cài thì bản chủ không làm gì, vì lần cài đầu do người dùng bấm.
- **Thay bộ gõ đã cài** (cài lại, nâng cấp, lùi bản):
  - App chép bản nhúng vào một thư mục tạm ẩn ngay trong thư mục đích, gỡ cờ quarantine, kiểm chữ ký bản tạm, rồi đổi chỗ cả khối trong một bước. App không ghi đè từng file lên bundle đang chạy.
  - App dừng bộ gõ cũ bằng một thông báo Darwin. Bộ gõ chốt từ đang gõ rồi tự thoát và chỉ thoát khi bundle trên đĩa không còn là bản nó đã chạy. Nếu quá hạn mà bộ gõ còn chạy, app chủ dừng đúng tiến trình bộ gõ của Dấu. macOS chạy bản mới ở phím kế tiếp.
  - App không dừng tiến trình hệ thống nào (`imklaunchagent`, `TextInputMenuAgent`…). App đăng ký lại bộ gõ và không đổi trạng thái bật hay chọn.
  - Lần thay diễn ra khi bản chủ vừa mở, nên lúc đó người dùng không gõ ở app khác (D7 (Cập nhật và loại bản dựng)).
- **Kiểm chữ ký:** mỗi lần mở app và mỗi lần app lên trước, app kiểm chữ ký của bộ gõ đã cài theo một yêu cầu mã (code requirement). Yêu cầu đó gồm chữ ký hợp lệ ở mọi kiến trúc, chứng chỉ do Apple cấp, chứng chỉ lá thuộc Team ID của app chủ và định danh là bundle ID của bộ gõ. App chủ không có Team ID thì không bản nào đạt. Không đạt thì app hiện banner "Cài lại". Bản tạm lúc cài và thay cũng được kiểm theo yêu cầu đó.
  - Mục "Cài đặt Dấu…" của bộ gõ cũng kiểm app chủ trước khi mở, theo bundle ID app chủ và cùng Team ID với bộ gõ. Bản nào đọc được mà không đạt thì không được mở.
  - **Giới hạn:** kiểm chữ ký chỉ phát hiện, không chặn. Mọi tiến trình của người dùng ghi được `~/Library/Input Methods`. Bản thay thế giữ trạng thái đã bật của Dấu nên macOS không hỏi lại. Bản thay thế nhận phím tới lúc người dùng mở app chủ. Cách chặn là cài bộ gõ vào thư mục chỉ quản trị viên ghi được. Dấu chỉ cài cho từng tài khoản (`~/Library/Input Methods`) nên chấp nhận giới hạn này; việc cài cho cả máy để sau, khi có người dùng cần.
- **Chữ ký sai thì không tự thay:** khi bộ gõ đã cài có chữ ký sai hoặc khác Team ID, app không tự thay, kể cả khi nó khác bản nhúng. Banner "Cài lại" hiện ra và người dùng bấm. Trong onboarding (D14 (Onboarding)), bước 2 hiện màn lỗi cài với nút "Cài lại" thay cho "Bật Dấu". Cài lại xong mới bật. Bản chủ không bật một bộ gõ có chữ ký sai (bản không phải bản chủ không kiểm chữ ký).

**Hệ quả đã chấp nhận:** nếu một bản đổi biểu tượng, macOS còn hiện biểu tượng cũ tới khi đăng xuất, vì Dấu không dừng tiến trình hệ thống giữ ảnh đó (đã đo, `docs/research/InputMethodInstall.md` mục 6). Tên nguồn chưa đo, nên mọi bản giữ cùng tên (D25). Nên giữ cả biểu tượng lẫn tên không đổi.

**Vì sao:**

- App chủ không chạy sandbox vì app phải chép bộ gõ vào `~/Library/Input Methods`, nâng cấp tại chỗ và dừng tiến trình bộ gõ cũ. App có sandbox thì file chép ra luôn bị gắn cờ quarantine mà app không gỡ được. App không dừng được app khác (Apple DTS; không bộ gõ tham khảo nào làm vậy).
- Các định danh không đổi giữa các bản vì đổi thì bộ đệm TIS lệch và người dùng phải đăng xuất.
- Bật không cần đăng xuất nhờ xoá bộ đệm (đo bằng bản thử rồi bằng Dấu thật). Danh sách "+" và việc dựng hộp thoại đều đọc bộ đệm của System Settings. Bộ đệm không làm mới khi có nguồn mới đăng ký; nếu không xoá thì chỉ đăng xuất mới làm mới nó. Yêu cầu bật gửi lúc trang Keyboard đang mở sẵn bị bỏ qua mà không báo gì.
- Mỗi app có sandbox cũng giữ bộ đệm riêng và dùng nguyên bộ đệm có sẵn kể cả khi mở lại app. Telegram dựng bộ đệm lúc chưa có Dấu thì không chọn được Dấu từ menu nhập liệu. Vòng ⌃⌥Space bỏ qua Dấu. Khi xoá bộ đệm trước khi đăng ký, app đang chạy dựng lại bộ đệm ở lần đăng ký và dùng được nguồn mới mà không cần mở lại (bản thử).
- Đăng xuất là đường lui cho các app còn lại (đo bằng Dấu thật). Sau một lần đăng nhập mới, mỗi app có sandbox dựng lại bộ đệm của nó ở lần đầu đọc nguồn đầu vào; thoát rồi mở lại app thì không.
- App thay cả khối chứ không ghi đè từng file, vì tiến trình cũ còn đang ánh xạ mã của nó. App không dừng `imklaunchagent`, vì dừng nó làm app đang gõ mất kết nối với mọi bộ gõ cho tới khi mở lại app đó. Bộ gõ chỉ thoát khi bundle đã đổi, vì ai cũng phát được thông báo Darwin và một yêu cầu không kèm thay đổi không được làm đứt từ đang gõ (D18 (Phòng thủ với IMK)).
- App kiểm chữ ký vì tài khoản người dùng ghi được thư mục `~/Library/Input Methods`, nên bundle có thể bị thay. macOS có chặn bundle bị thay hay vẫn đưa phím cho nó thì chưa đo.
- Yêu cầu mã thay cho việc so hai Team ID, vì hai bản ký ad-hoc đều không có Team ID nên từng "khớp" nhau. Mã khác của cùng team cũng từng đạt. Bộ gõ đã cài bằng bản phát triển (Personal Team) đạt yêu cầu mới (`codesign -R`). Chứng chỉ Developer ID của cùng team cũng thoả `anchor apple generic` và Team ID.
- Chữ ký sai thì không tự thay, vì bộ gõ nhận mọi phím gõ và tự thay sẽ che dấu hiệu bundle bị can thiệp. Người chuyển từ bản phát triển sang bản phát hành (khác Team ID) thấy banner một lần. Onboarding theo cùng luật, vì nếu "Bật Dấu" bật luôn bộ gõ đã cài thì Dấu tự tay bật một bundle mà nó biết không phải của mình.
- Khi có hơn một bản trong cùng thư mục, mỗi bản đều do người dùng đặt vào Applications, nên mở bản nào thì bộ gõ theo bản đó. App không thêm màn yêu cầu xoá bớt.
- Cần có bản chủ vì nếu bản Dấu.app nào cũng cài và thay được bộ gõ và chỉ thay khi số build của bản nhúng lớn hơn, thì ba điều xảy ra. Mở một bản mới hơn từ ảnh đĩa sẽ làm bộ gõ khác bản app đã cài. Quay về bản trước (D19 (Quay về bản trước)) không lùi được bộ gõ. Bản phát triển cùng số build không bao giờ được thay.
- Bản chủ so mã băm với bản trong Applications, không xét đường dẫn đang chạy, vì macOS có thể chạy app từ một đường dẫn ngẫu nhiên (App Translocation). Điều kiện của việc đó không được Apple công bố. Không có cách được hỗ trợ để nhận biết hay lấy đường dẫn gốc (Apple DTS, Developer Forums 724969).

**Xem thêm:** [`docs/research/InputMethodInstall.md`](research/InputMethodInstall.md) (mục 6 nâng cấp; mục 1 và 3 số đo khi bật); cách mã làm ở [`docs/Architecture.md`](Architecture.md) mục "Cài, bật, thay, gỡ bộ gõ".

### D38. Chữ trên giao diện

- Chữ của Dấu theo ngôn ngữ giao diện của Dấu (D41 (Ngôn ngữ giao diện)).
- Mọi tên giao diện của macOS (System Settings, Keyboard, Input Sources, Allow, tên bàn phím…) hiện **đúng như macOS của người dùng đang hiện**, theo ngôn ngữ của macOS chứ không theo ngôn ngữ của app. Dấu lấy chữ từ chính chuỗi của hệ thống và không tự dịch. Trên máy tiếng Anh, đường dẫn hiện là "System Settings › Keyboard › Input Sources"; trên máy tiếng Việt là "Cài đặt hệ thống › Bàn phím › Nguồn đầu vào". Tên bàn phím theo cùng tinh thần đó.
- Tên "Thùng rác" (Trash) trong các thông báo gỡ cài đặt cũng đọc từ chuỗi của macOS, không viết cứng. Nếu không đọc được thì Dấu dùng tên tiếng Anh.
- Khi nói về khái niệm chung, câu tiếng Việt dùng thuật ngữ Apple tiếng Việt ("nguồn đầu vào", không phải "nguồn nhập liệu"), còn câu tiếng Anh dùng thuật ngữ Apple tiếng Anh ("input source").
- D38 áp cho chữ người dùng thấy. Tài liệu nội bộ có thể còn "nguồn nhập liệu".

**Vì sao:** hướng dẫn chỉ đúng khi tên khớp với thứ người dùng thấy. macOS tiếng Việt gọi Input Sources là "Nguồn đầu vào" (đọc từ chuỗi của System Settings 27.2).

### D39. Ủng hộ dự án

- Dấu nhận ủng hộ tự nguyện qua GitHub Sponsors và qua chuyển khoản trong nước bằng mã VietQR cho người không có thẻ thanh toán quốc tế.
- Ủng hộ không làm đổi chuyện Dấu miễn phí trọn vẹn (D6 (Phát hành)). Dấu không có bản trả phí, không khoá tính năng và không có quảng cáo.
- Trang tải về có liên kết "Ủng hộ dự án" ở chân trang.
- Trang Cập nhật & hỗ trợ của app có hàng "Ủng hộ dự án" với nút "Ủng hộ…" mở mục Góp sức của trang web trong trình duyệt.
- Người dùng mở tài khoản Sponsors của tổ chức `codefastlabs` và tài khoản ngân hàng nhận chuyển khoản. Người dùng lo phần thuế, pháp lý, vì đây là việc cần tài khoản.
- **Ghi nhận người ủng hộ.** Dấu ghi công người ủng hộ ở bốn chỗ:
  - Trang Cập nhật & hỗ trợ của app có mục "Người ủng hộ" liệt kê tên. Danh sách đi kèm bản phát hành, như danh sách tương thích (D7 (Cập nhật và loại bản dựng)); app không tải danh sách qua mạng.
  - Mục Góp sức của trang web có phần Cảm ơn hiện cùng danh sách đó.
  - Ghi chú phát hành của mỗi bản nêu những người ủng hộ trong khoảng thời gian làm ra bản đó.
  - Mục Góp sức của trang web ghi tiền ủng hộ đã dùng vào việc gì. Mục này chỉ ghi khoản đã chi thật (N5 (Chỉ hứa điều đã kiểm chứng)).
- Danh sách tên nằm ở một file trong repo. App, trang web và ghi chú phát hành cùng lấy tên từ file đó.
- Dấu chỉ nêu tên khi người ủng hộ đồng ý. Người ủng hộ qua GitHub Sponsors để chế độ công khai thì được tính là đồng ý. Người chuyển khoản VietQR muốn được nêu tên thì ghi tên muốn hiện vào nội dung chuyển khoản; Dấu không bao giờ nêu tên chủ tài khoản ngân hàng.
- Dấu không hiện số tiền, không xếp hạng người ủng hộ và không có huy hiệu hay đặc quyền nào trong app.

**Vì sao ghi công như vậy:** người ủng hộ cần thấy tên mình ở chỗ họ dùng hằng ngày và thấy tiền của họ đã làm ra việc gì. Dấu không biết ai đã ủng hộ, vì Dấu không có tài khoản người dùng và không gửi dữ liệu đi (D8 (Không telemetry), N2 (Bộ gõ không có quyền mạng)), nên cách ghi nhận là ghi công công khai có sự đồng ý, không phải đặc quyền cần xác minh qua mạng. Số tiền và bảng xếp hạng bị loại vì chúng lộ thông tin riêng và tạo áp lực. Người dùng chốt ngày 22/11/2026.

### D40. Chữ dựng sẵn và phím z

- Chữ tiếng Việt dựng sẵn đến như một phím (từ bàn phím khác hay khi dán từng chữ) được coi là một chữ cái của từ đang gõ ("chuýên" → "chuyến").
- Ký tự không thuộc bảng chữ (ß…) kết thúc từ.
- Trong Telex, phím z gõ khi từ chưa có dấu thanh là chữ z, không bỏ mũ hay móc ("kongoz" → "kongoz").

**Xem thêm:** ca thử của bộ gõ khác ở [`docs/research/external-test-inputs/README.md`](research/external-test-inputs/README.md) mục 1.

### D41. Ngôn ngữ giao diện

App chủ và bộ gõ có tiếng Việt và tiếng Anh.

- **Chọn ngôn ngữ:** Dấu đi theo danh sách ngôn ngữ ưu tiên của macOS và lấy ngôn ngữ đầu tiên mà Dấu có bản dịch. Nếu không có ngôn ngữ nào như vậy thì Dấu dùng tiếng Anh. Ngôn ngữ khác chỉ được thêm khi có người nói thạo duyệt bản dịch (N5 (Chỉ hứa điều đã kiểm chứng)).
- **String Catalog:** ngôn ngữ gốc là tiếng Anh (`developmentLanguage: en`). Khoá là câu tiếng Anh. Tiếng Việt là bản dịch và phải đủ mọi chuỗi; thiếu chuỗi nào thì người dùng Việt thấy tiếng Anh ở chuỗi đó.
- **Tên nguồn đầu vào:** tên là "Dấu – Tiếng Việt" trên macOS tiếng Việt và "Dấu – Vietnamese" trên macOS tiếng Anh (như "Vietnamese Telex" của Apple). macOS chọn tên theo ngôn ngữ của hệ thống. Dấu không đổi được điều đó. ID input mode không đổi (D24 (Tên và định danh), D37 (Cài bộ gõ)).
  - Khi câu chữ của Dấu nhắc tên nguồn, câu đó dùng đúng tên macOS đang hiện, theo ngôn ngữ của hệ thống chứ không theo ngôn ngữ của app, như tên giao diện ở D38 (Chữ trên giao diện).
  - "Dấu" giữ nguyên ở mọi ngôn ngữ (D24).
- **Đặt ngôn ngữ riêng cho Dấu:** người dùng dùng mục ngôn ngữ riêng từng ứng dụng của macOS (System Settings › General › Language & Region › Applications). Dấu không làm ô chọn riêng. Cài đặt không có hàng "Ngôn ngữ" (N1 (Không làm lại việc hệ thống đã có)).
  - Menu bộ gõ theo ngôn ngữ hệ thống (câu hỏi mở "Bộ gõ trong mục ngôn ngữ riêng từng ứng dụng").

**Vì sao:**

- Dấu có hai ngôn ngữ vì có hai nhóm người dùng: người Việt (nhóm dùng rộng rãi) và người nước ngoài học tiếng Việt.
- Khoá là câu tiếng Anh vì macOS tự lùi về ngôn ngữ gốc nên không cần cấu hình riêng, sửa câu tiếng Việt không đổi khoá. Người dịch ngôn ngữ khác dịch từ tiếng Anh. Hai phương án đã loại là khoá bằng câu tiếng Việt, vì phải đặt vùng phát triển khác ngôn ngữ gốc để lùi về tiếng Anh, và khoá theo ngữ nghĩa (`onboarding.title`), vì Xcode không tự lấy chuỗi từ `Text("…")` và đọc mã không thấy chữ hiện ra.
- Mục ngôn ngữ của macOS thay cho ô chọn riêng. Ô chọn ngôn ngữ trong Cài đặt ghi khoá `AppleLanguages` ("Theo hệ thống", Tiếng Việt, English) đã bị loại vì làm lại việc macOS đã có; điều người dùng thiếu chỉ là biết chỗ đổi. Đo trên Dấu thật (macOS 27.2) cho thấy danh sách "+" của mục đó có Dấu.app. Chọn tiếng Việt thì Dấu hiện tiếng Việt trên máy tiếng Anh. Khi đó macOS ghi `AppleLanguages` vào miền cài đặt `com.codefastlabs.dau`. Đổi xong thì macOS hỏi có mở lại app ngay không. Hàng "Ngôn ngữ" chỉ đọc và nút "Mở lại Dấu" đã bỏ, vì chúng chỉ nhắc lại việc macOS đã làm.

### D42. Ngưỡng hiệu năng

Trước mỗi bản phát hành, chạy `scripts/selftest/load/heavy.sh` với bộ gõ bản Debug, 20 phím mỗi giây, ở Safari, Chrome, VS Code, lúc rảnh và dưới tải.

- Chữ gõ ra phải khớp đáp án ở mọi ô.
- Với phím có thay chữ, thời gian xử lý phía bộ gõ có p50 không quá 3 ms và p99 không quá 20 ms.
- Đối chứng là Telex của Apple: chữ nó gõ ra dưới tải phải giống chữ của chính nó lúc rảnh. Nếu khác thì lượt đo không hợp lệ.
- Bộ nhớ của tiến trình bộ gõ (RSS, đo trước và sau mỗi nhóm) không quá 96 MB.
- Vượt ngưỡng thì không phát hành cho tới khi rõ nguyên nhân.

**Vì sao:** ngưỡng cao hơn mức cao nhất đã đo ở M6 khoảng 1,4–1,6 lần (p50 1,92 ms, p99 14,2 ms; bộ nhớ 44–64 MB ở bản Debug), để một lượt đo xấu không gây báo động giả. Đo trên bản Debug vì bản Release không ghi gì theo từng phím (D8 (Không telemetry)). Lời gọi chẩn đoán sau mỗi lần thay chữ của bản Debug nằm ngoài thời gian đo; chênh lệch giữa Debug và Release chưa đo.

**Xem thêm:** số đo M6 ở [`docs/history/DecisionsLog.md`](history/DecisionsLog.md) mục D42.

### D43. Ô bỏ qua vùng thay chữ

Có những ô nhận chữ của `insertText(_:replacementRange:)` nhưng bỏ qua vùng thay, nên chữ mới thêm vào sau thay vì thay chữ cũ. Các ô đã đo gồm Ghostty, terminal dựng bằng xterm.js và terminal Reworked của WebStorm (đo 17/11/2026, [`docs/Compatibility.md`](Compatibility.md) mục 5.9). Terminal xterm.js đã đo là terminal tích hợp của VS Code. Cursor và terminal trong app Claude cùng cơ chế nhưng chưa đo. **Dấu không xử lý riêng các ô này.** Dấu thay tại chỗ như ở mọi ô, nên chữ ở đó ra sai. Cách gõ đúng là gạch chân, do người dùng tự bật theo app (D13 (Gạch chân là đường lui cuối cùng)).

- **Ghostty mang nhãn "Đề xuất"** (D13), vì cả app là terminal, nên bật gạch chân không làm hại ô nào khác.
- **App mà terminal chỉ là một ô** (VS Code, Cursor, app Claude, WebStorm) không được gắn nhãn vì terminal. Bật gạch chân cho cả app thì mọi ô của app đó mất D20 (Thêm dấu cho từ đã gõ), chỉ để chữa một ô.

**Hệ quả đã chấp nhận:**

- Nếu không bật gạch chân, chữ trong các ô này sai từ đầu tới cuối. Ở Ghostty, `toois` ra "toôis"; ở xterm.js, `toois vieetj dd ` ra "toôoiís vieêetj dđd ".
- Ở Ghostty có gạch chân, Return nhấn ngay sau từ đang gạch chân bị nuốt. Người dùng phải nhấn lại. Đây là lỗi của Ghostty. Telex của Apple cũng bị ([`docs/Compatibility.md`](Compatibility.md) mục 6.8).
- Gạch chân không có D20 (D13).

**Vì sao:**

- Gạch chân đo ra đúng ở cả hai loại ô: Ghostty (zsh, vim) và terminal tích hợp của VS Code, kể cả trình soạn thảo cùng cửa sổ khi chuyển ô. Telex của Apple (cũng là gạch chân) ra đúng ở cả hai.
- Cách sửa tại chỗ đã thử (gửi ký tự xoá DEL qua InputMethodKit, nhận ra ô theo vị trí con trỏ, đọc gói app để tránh app có nhân web) tốn khoảng 2 600 dòng mã và test mà vẫn không đạt.
  - Ở Ghostty, một hai từ đầu sai sau mỗi lần chuyển vào app. Lệnh thật thường ngắn và gõ ngay sau khi chuyển vào, nên trong shell dùng hằng ngày, chữ gần như luôn sai.
  - Ở xterm.js, cách sửa không bật được, vì ký tự xoá lọt vào trình soạn thảo cùng view.
- Mỗi nhánh riêng trong đường xử lý phím là thêm một chỗ có thể sinh lỗi. Mã đơn giản đáng giá hơn một cách sửa chỉ đúng một phần.

**Xem thêm:** cơ chế và số đo ở [`docs/research/TerminalAndUnderline.md`](research/TerminalAndUnderline.md); [`docs/Compatibility.md`](Compatibility.md) mục 5.6, 6.8; cách làm cũ và lý do bỏ ở [`docs/history/DecisionsLog.md`](history/DecisionsLog.md) mục D43.

### D44. Văn xuôi tiếng Việt

Tài liệu tiếng Việt trong dự án viết thành câu đủ ý, tự nhiên, rõ ràng và chính xác, theo cách một người viết tiếng Việt viết cho người khác đọc. Câu nào rút gọn đến mức người đọc phải tự điền chủ ngữ và vị ngữ hoặc tự đoán mối liên hệ giữa các vế thì câu đó chưa viết xong.

- Mỗi câu nói trọn một việc hoặc một ý, có đủ chủ ngữ và vị ngữ.
- Khi có nhiều ý ngang hàng thì mỗi ý viết thành một câu riêng. Các ý đó xuống dòng hoặc đứng sau gạch đầu dòng. Mỗi gạch đầu dòng là một câu đủ ý, không phải một cụm danh từ cộc.
- Các câu nối tiếp nhau viết thành đoạn văn. Không nhồi nhiều việc vào một câu bằng dấu hai chấm, dấu gạch chéo hay ngoặc đơn chỉ để lấy ngắn.
- Khi viết lại hoặc viết mới, người viết giữ tối đa ý nghĩa gốc. Không thêm sự kiện, không bỏ số đo, không làm lệch dữ liệu kiểm chứng và không đổi các thuật ngữ đã chốt trong [`docs/Glossary.md`](Glossary.md). Số N/D, mã lệnh và đường dẫn giữ nguyên.
- Luật này áp cho mọi tài liệu markdown, kể cả sổ quyết định và tài liệu trong [`docs/history/`](history/), để người đọc không bị vấp khi tra cứu. Tài liệu trong `docs/history/` được viết lại câu chữ nhưng giữ nguyên sự kiện, số đo và ngày như lúc ghi. Tài liệu hiện có được viết lại từng bước, có đối chiếu với bản cũ.
- **Văn tiếng Việt, không văn dịch.** Câu theo cú pháp tiếng Việt, không theo khuôn câu tiếng Anh. Luật này áp cho cả tài liệu lẫn chuỗi giao diện tiếng Việt. Danh mục các thói quen câu tiếng Anh phải tránh, kèm cách sửa, nằm ở [`docs/CLAUDE.md`](CLAUDE.md) mục "Văn tiếng Việt, không văn dịch". Nguồn và số đo nằm ở [`docs/research/VietnameseProse.md`](research/VietnameseProse.md).
- Tiêu đề mục và cột nhãn (như cột "Tên" trong bảng mục lục) được dùng cụm danh từ rõ nghĩa, không viết tắt khó hiểu. Phần diễn giải, tóm tắt luật (như cột "Luật") và ghi chú phân tích là văn xuôi và phải viết thành câu đủ ý.
- Chuỗi giao diện theo quy chuẩn thiết kế của macOS về độ dài và cách gọi tên, nhưng dấu câu và cú pháp theo luật "Văn tiếng Việt, không văn dịch". Phần mô tả và hướng dẫn đi kèm trong tài liệu phải là câu văn xuôi đủ ý.

**Vì sao:** quy định cũ về viết câu ngắn ở [`docs/CLAUDE.md`](CLAUDE.md) từng bị hiểu máy móc thành bỏ động từ và nối các vế bằng dấu câu, làm câu cụt và buộc người đọc tự dịch lại trong đầu. Miễn trừ cho một số tài liệu (như giữ văn phong cũ trong tài liệu lịch sử hay sổ quyết định) không có lý do chính đáng, vì người đọc các tài liệu đó vẫn vấp như vậy. Tài liệu cần vừa giữ đúng chi tiết kỹ thuật, vừa đọc tự nhiên. Người dùng giao phiên chính chốt ngày 20/11/2026.

**Vì sao có luật văn dịch:** các lượt viết lại đầu tiên theo D44 vẫn mang thói quen câu tiếng Anh, rõ nhất là dấu phẩy trước "và" (426 chỗ trong tài liệu chính, đếm ngày 22/11/2026). Người dùng chỉ ra lỗi này và duyệt danh mục luật cùng ngày.

**Hệ quả đã chấp nhận:** phần diễn giải sẽ dài hơn. Tài liệu hiện có được rà và viết lại từng bước mà không đổi số đo hay dữ kiện thực nghiệm.

**Xem thêm:** quy tắc viết tài liệu ở [`docs/CLAUDE.md`](CLAUDE.md), mục "Thứ tự theo người đọc" và "Câu đủ ý".

### D45. Trang web

- **Công nghệ:** trang web dựng bằng TanStack Start bản React và Tailwind CSS. Mọi trang prerender thành HTML tĩnh lúc build. Trang không có server lúc chạy, không dùng Nitro và không dùng API mà TanStack ghi là thử nghiệm. Vercel phục vụ thư mục đầu ra như file tĩnh.
- **Chỗ đặt:** mã trang nằm trong repo của Dấu, ở `site/`. `site/appcast.xml` giữ nguyên chỗ. Bản build chép nó nguyên byte vào đầu ra. Trang đọc lúc build đúng các file dữ liệu mà app dùng, như danh sách tương thích và danh sách người ủng hộ (D39 (Ủng hộ dự án)).
- **Ngôn ngữ:** trang có tiếng Việt ở `/` và tiếng Anh ở `/en`, từ M8. `x-default` trỏ về `/en`, theo cách D41 (Ngôn ngữ giao diện) lùi về tiếng Anh. Trang không tự chuyển theo ngôn ngữ trình duyệt. Khi app mở trang web, app chọn bản theo ngôn ngữ app đang hiện (D41).
- **Đo lượt xem:** trang đếm lượt xem bằng Vercel Web Analytics, không cookie và không định danh người đọc. Sự kiện trên trang (bấm tải về, sao chép lệnh Homebrew, đổi ngôn ngữ) đi qua `@codefast/tracking`, chỉ ở làn không cần đồng ý (`consentRequirement: "exempt"`): không định danh ẩn danh, không banner xin đồng ý, không Google Analytics hay mạng quảng cáo. Vercel chỉ nhận sự kiện tuỳ chỉnh ở gói Pro trở lên. Ở gói Hobby, trang vẫn gửi sự kiện qua `@codefast/tracking` nhưng Vercel chỉ ghi lượt xem; mã giữ sẵn để khi lên Pro thì có số sự kiện ngay, đổi lại 2,9 KB JS chưa có tác dụng. Trang không gọi bên thứ ba; script và điểm nhận số liệu của Vercel nằm trên cùng tên miền. Phông tự phục vụ trên cùng tên miền.

**Vì sao:**

- Người dùng chọn họ TanStack bản React, Tailwind CSS và hai ngôn ngữ ngay từ M8. Trang tĩnh đủ cho nội dung của `docs/Website.md`. Đo trên trang thử đầy đủ, Lighthouse đạt 100 ở cả bốn hạng mục trên điện thoại và máy tính ([`docs/research/WebsiteStack.md`](research/WebsiteStack.md)).
- Nitro chỉ cần khi trang render lúc chạy. Preset tĩnh của Nitro làm được cùng việc với `vercel.json` nhưng còn là bản RC và thay prerender của TanStack Start. API thử nghiệm (Deferred Hydration, Server Components) chỉ bớt vài KB JS khi hiệu năng đã là 100, đổi lại có lỗi mở làm mất HTML dựng sẵn.
- Repo chung giữ appcast và dữ liệu dùng chung trên một đường: địa chỉ feed nằm trong mọi bản app đã phát hành nên không đổi được. Script phát hành đọc `site/appcast.xml` trên `main`. Repo riêng chỉ bớt CI và pull request lẫn lộn, đổi lại appcast và dữ liệu phải đi qua hai repo.
- Người dùng chọn đo trang để cải thiện nó. Mức đo giới hạn ở đếm không cookie, không định danh để giữ tinh thần D8 (Không telemetry): đếm như vậy không cần banner xin đồng ý, không gửi gì tới Google hay mạng quảng cáo. Mục Quyền riêng tư của trang nói đúng điều trang làm. Dùng đủ `@codefast/tracking` (banner, định danh ẩn danh, phần server hỏi vùng) bị loại vì cần server lúc chạy, trái với trang tĩnh.
- Người dùng chốt ngày 24/11/2026.

**Xem thêm:** nội dung trang ở [`docs/Website.md`](Website.md), cấu hình và số đo ở [`docs/research/WebsiteStack.md`](research/WebsiteStack.md).

## Đã biết nhưng không làm

Mục này liệt kê các tính năng người dùng có thể đã quen ở bộ gõ khác. Dấu biết các tính năng này và cố ý không làm; lý do nằm ở quyết định được dẫn. Muốn làm một mục thì phải sửa quyết định đó trước. Cột "Bộ gõ khác có" ghi bộ gõ đã đối chiếu: OpenKey theo `docs/research/OpenKeyNotes.md`, uvie-rs theo ca thử ở `docs/research/external-test-inputs/README.md`. Ký hiệu "—" nghĩa là chưa đối chiếu.

| Tính năng | Bộ gõ khác có | Vì sao Dấu không làm |
|---|---|---|
| Macro, gõ tắt văn bản | OpenKey | D3, N1 |
| Viết hoa chữ đầu câu | OpenKey | D3 |
| Bảng mã cũ (TCVN3, VNI-Windows, CP1258, Unicode tổ hợp), nhớ bảng mã theo ứng dụng | OpenKey | D3 |
| Công cụ chuyển mã, kể cả chuẩn hoá Unicode cho chữ dán vào | OpenKey | D3, N1 |
| Tự đổi Việt/Anh theo ứng dụng | OpenKey | D5, D2 |
| Từ điển tiếng Anh để giữ từ tiếng Anh | — | D4 |
| Quick Telex (cc → ch, nn → ng…) | OpenKey | D21 |
| `[ ]` thành ơ ư | OpenKey | D27 |
| Phím chuyển Việt/Anh riêng (nhấn-nhả ⌃ hoặc ⇧), tiếng bíp khi chuyển | OpenKey | D2 |
| Tạm tắt bộ gõ hoặc kiểm tra chính tả bằng nhấn-nhả ⌃/⌘ | OpenKey | D2, D30 |
| Biểu tượng riêng trên thanh menu, mục "Thoát" | — | D2, N1 |
| Thông báo nổi và âm thanh khi chuyển Việt/Anh | — | D2, N1 |
| Thống kê gõ phím, telemetry | — | D8 |
| Phát hành trên Mac App Store | — | D6, D37 |
| Tự thêm mũ/móc còn thiếu để từ thành hợp lệ ("thuocs" → "thuốc"), tự tách âm tiết giữa từ ("neeboo" → "nê" + "bô") | uvie-rs | D20, D30 |

## Đã cân nhắc và loại bỏ

Mục này ghi các cách làm đã bị loại; các tính năng không làm nằm ở mục trên.

- Rust/WASM và đa nền tảng.
- Thử gõ trên trang web.
- Event tap kèm Backspace giả (cách của OpenKey).
- Gửi ký tự xoá DEL qua InputMethodKit cho terminal (D43). Cách này bị bỏ ngày 12/11/2026 vì không đạt và tốn mã.
- Dùng `NSSpellChecker` trong đường nóng.
- Nhúng engine UniKey qua C++ interop.
- Chạy engine OpenKey làm đáp án cho test (oracle).
- Tách engine ra giấy phép MIT hay MPL riêng.
- Các cách cho Google Docs gõ được, bị loại ngày 26/11/2026. Google Docs vẫn sai khi thay tại chỗ và là giới hạn đã biết ([`docs/Compatibility.md`](Compatibility.md) mục 5.10). Nguyên nhân Google Docs sai chữ ở [`docs/research/WebEditorInput.md`](research/WebEditorInput.md).
  - Danh sách trang theo URL: Dấu phải đọc URL qua Accessibility, nên cần quyền Trợ năng (N4).
  - Input mode "Tiếng Việt (gạch chân)" thứ hai: người dùng phải tự bật mode và tự chọn mode ở từng tab mới, và D2 chỉ cho một input mode.
  - Quy tắc theo app ba trạng thái (Tự động, Thay tại chỗ, Gạch chân): một quy tắc theo app không tách được Google Docs với các tab khác trong cùng trình duyệt, và người dùng phải hiểu thêm một lựa chọn.
  - Sửa thay tại chỗ ngay trong Google Docs: mọi đường trong tầm bộ gõ đã thử và không được (mục 10.5 và 10.6 của file trên).
  - Gạch chân cho mọi app như Telex của Apple: mọi app mất D20.
  - Dấu tự nhận ra ô giấu chữ (app báo con trỏ nằm trong chính từ vừa gõ) và tự gạch chân riêng ô đó: Dấu đổi cách gõ mà người dùng không chọn, không thấy được vì sao, và không tắt được ở riêng ô đó, nên không minh bạch. Bản thật đo được Google Docs gõ đúng sau một hai từ đầu của mỗi tab và không nhận nhầm app nào (số đo ở [`docs/Compatibility.md`](Compatibility.md) mục 5.10); đã gỡ ngày 26/11/2026.
  - Cài đặt trợ năng trong Google Docs (chữ nổi, hỗ trợ trình đọc màn hình) và dùng Telex của Apple cho tab Google Docs: đều là cách vòng người dùng phải tự làm ([`docs/research/WebEditorInput.md`](research/WebEditorInput.md) mục 10.6 B).
  - Gạch chân vô hình (chữ đánh dấu kèm thuộc tính để trình duyệt không vẽ gạch chân): Google Docs tự vẽ gạch chân cho chữ đang soạn, với mọi bộ thuộc tính đã thử trên Chrome và Safari (mục 10.7 của file trên).

## Câu hỏi mở

Mục này chỉ giữ câu chưa có trả lời. Khi một câu đã được trả lời, luật chuyển vào quyết định liên quan, còn diễn biến ghi vào [`docs/history/DecisionsLog.md`](history/DecisionsLog.md).

- **Hộp thoại và đăng xuất khi bật bộ gõ** (D37): trên macOS 27.2 và macOS 15.8.1, việc bật có hộp thoại xin phép và không cần đăng xuất. Chưa biết điều đó có đúng trên macOS 14 và macOS 26, với bản ký Developer ID (kể cả bản mang quarantine) và trên tài khoản macOS mới hay không. Các nguồn nói trái nhau: Apple DTS nói cần đăng xuất, còn một dự án khác nói không (`docs/research/InputMethodInstall.md` mục Hiện trạng, 1, 2, 10.4).
- **Bản chủ trong `~/Applications`** (D37): sandbox của bộ gõ không đọc được bản trong thư mục nhà, nên mục "Cài đặt Dấu…" không kiểm được chữ ký của bản đó và chỉ mở nó khi `/Applications` không có bản nào đạt. Việc mở nó từ sandbox có chạy thật không thì chưa đo. Với bản chủ trong `/Applications`, việc mở chạy được và kiểm chữ ký chạy trong sandbox.
- **Hộp thoại App Group với bản ký Developer ID** (D24): bản có Team ID Personal Team không có hộp thoại, còn bản Developer ID chưa kiểm.
- **Bộ gõ trong mục ngôn ngữ riêng từng ứng dụng** (D41): chưa biết danh sách "+" của System Settings › General › Language & Region › Applications có chọn được bộ gõ Dấu (`~/Library/Input Methods`) không, và chọn rồi thì menu bộ gõ ("Cài đặt Dấu…", tên kiểu gõ) có đổi theo không.
- **VoiceOver đọc tên nguồn** (D17): chưa biết VoiceOver có đọc đúng tên "Dấu – Tiếng Việt" khi chuyển nguồn không.
- **Độ ổn định của "Thêm dấu cho từ đã gõ"** (D20) trên các web editor (Google Docs, Notion…) chưa được biết.
- **Từ tiếng Anh gõ nhầm rồi ⌫ trong từ** (D32 (Backspace), D4): sau ⌫, mốc khôi phục là chữ đang hiện, mà chữ đang hiện của từ tiếng Anh là chữ Telex dở, nên từ đó có thể không được khôi phục ("with" gõ thừa một chữ rồi ⌫ ra "ưith"; 93/380 từ trong danh sách đo). Câu hỏi là giữ D32 như hiện nay hay đổi mốc khôi phục sau ⌫ cho phần chữ đã chèn nguyên (phương án c); xem [`docs/research/EditingTypedText.md`](research/EditingTypedText.md), K3 và mục 4.2.
- **Tên "Dấu"** (D24): việc tra nhãn hiệu (Cục Sở hữu trí tuệ VN) chưa làm. Một bộ gõ macOS khác có tên gần giống là DauKey (`emizuki/daukey`, GPLv3, repo tạo 23/10/2026, chưa có cask). Định danh không trùng, chỉ tên đọc lên gần nhau.
