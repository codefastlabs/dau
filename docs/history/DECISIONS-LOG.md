# Nhật ký sổ quyết định

Lưu trữ cách từng nguyên tắc và quyết định trong `docs/DECISIONS.md` đã thay đổi: ngày, ai chốt, bản trước, cách nói cũ và các lần đo dẫn tới thay đổi. Tài liệu này ghi lại quá khứ, không sửa cho khớp hiện trạng; luật hiện hành chỉ đọc ở `docs/DECISIONS.md`. Các mục chuyển nguyên văn từ sổ quyết định khi sổ được viết lại theo dạng tên – luật – vì sao (09/11/2026), nên còn giữ mã nội bộ của thời đó (E1–E9 là câu hỏi trong `docs/research/EXTERNAL-TEST-INPUTS.md` mục 9.8; câu hỏi A/B, cách A/B là hỏi vị trí con trỏ ở mỗi phím hay tự cộng dồn vị trí; K1, T4, vòng E, vòng U là bước đo trong `docs/research/M5-INSTALL.md`). Lần đổi sau: thêm một dòng có ngày dưới đúng mục.

## Đầu sổ

- Lời dẫn đầu sổ trước 09/11/2026: "Muốn đổi một quyết định: sửa ở đây, ghi lý do và ngày, trong cùng commit với thay đổi mã."
- 09/11/2026: viết lại sổ theo dạng tên – luật – vì sao, người dùng duyệt; ngày, người quyết và bản trước chuyển sang file này. Nghĩa của mọi nguyên tắc và quyết định giữ nguyên.

## Nguyên tắc

### N3. Ít lời gọi vào ứng dụng đích

- Tên cũ: "Tối thiểu lời gọi vào ứng dụng đích khi đang gõ."
- 29/10/2026: "Sửa 29/10/2026 theo số đo M2, xem câu hỏi A/B; bản trước: 'Không hỏi ngược ứng dụng đích khi đang gõ liên tục'."
- 30/10/2026: bổ sung ngoại lệ của "Thêm dấu cho từ đã gõ" (D20) ở phím dấu/biến đổi đầu tiên khi bộ đệm trống ("bổ sung 30/10/2026").
- 02/11/2026: bổ sung ngoại lệ đọc chữ trước con trỏ khi lệch vị trí ở phím có thay chữ và ở phím dấu/biến đổi đầu tiên trong một từ đã hết hợp lệ (D11) ("bổ sung 02/11/2026").
- 05/11/2026: bổ sung phím chữ cái vào ngoại lệ của D20 ("bổ sung 05/11/2026, E8").
- 10/11/2026: ngoại lệ đọc chữ khi lệch vị trí nay tính cả lần thay đầu của một từ, so với vị trí Dấu tự theo dõi (D11), người dùng duyệt; số lời gọi tối đa mỗi phím không đổi.

- 11/11/2026: thêm ngoại lệ của D43: một lần đọc chữ trước con trỏ khi sắp nhận ra ô, tối đa một lần mỗi lần kích hoạt (rà soát bảo mật, người dùng duyệt).

### N4. Không tự đổi cài đặt hệ thống

- Tên cũ: "Không tự ý đổi cài đặt hệ thống của người dùng."
- 30/10/2026: "Sửa 30/10/2026, M5; bản trước: 'Chỉ hướng dẫn hoặc mở đúng màn hình Cài đặt'."
- 04/11/2026: nút "Bật Dấu"/"Bật lại" được xoá bộ đệm danh sách nguồn nhập liệu và thoát System Settings ("người dùng chốt 04/11/2026; thêm bộ đệm của từng app cùng ngày").

## Quyết định

### D2. Chuyển Việt/Anh

- 30/10/2026: "Sửa 30/10/2026; bản trước: hai input mode 'Tiếng Việt'/'Tiếng Anh' trong Dấu. Lý do: chế độ Anh chỉ cho phím đi thẳng, trùng bàn phím tiếng Anh của macOS (N1); nằm ở nhóm 'Tiếng Anh' trong danh sách thêm nguồn nên người dùng không tìm thấy; làm mất các tiện ích chỉ nguồn của macOS có, như dùng Caps Lock để chuyển sang/về bàn phím tiếng Anh. Từ tiếng Anh lẫn trong câu Việt đã có D4 lo."

### D4. Từ nước ngoài

- 29/10/2026: "Sửa ngày 29/10/2026; bản trước dùng danh sách từ tiếng Anh nhúng sẵn."
- 29/10/2026: "Bổ sung 29/10/2026: ARCHITECTURE.md ghi 'Space/dấu câu' trong khi D4 chỉ ghi Space; thống nhất theo cách này." (Ranh giới từ.)
- 29/10/2026: "Mốc khôi phục" thêm vào D4.
- 30/10/2026: "Cũng chỉ reset, không khôi phục (bổ sung 30/10/2026, khớp mã M2): đổi cài đặt, đổi nguồn nhập liệu, đổi ô nhập hoặc ứng dụng giữa chừng một từ."
- 30/10/2026: "Giới hạn đã biết — tự sửa chính tả của macOS" ghi ngày 30/10/2026, kèm việc cần làm: "Ghi vào ma trận tương thích ở M3."

- 11/11/2026: "Vì sao" của việc chỉ reset viết lại. Bản trước: "Mũi tên, Esc, click và tổ hợp phím chỉ reset vì lúc đó con trỏ có thể đã đi chỗ khác, ghi lại chữ dễ thay sai vùng." Câu đó trái với D20, nơi phím sau reset vẫn sửa chữ trước con trỏ; nay nói rõ lý do là không khôi phục theo chuỗi phím cũ, và D20 chỉ sửa chữ đọc lại được (rà soát bảo mật, người dùng duyệt).

### D5. Quy tắc theo ứng dụng

- 30/10/2026: "Sửa 30/10/2026 cùng D2; bản trước: quy tắc có 'chế độ khi mở app' và tuỳ chọn nhớ chế độ theo app. Lý do: khi bỏ chế độ Anh, đổi sang U.S. phải gọi `TISSelectInputSource` từ bộ gõ; đo 30/10/2026: lệnh đổi được nguồn nhưng bước macOS báo cho app đang gõ bị sandbox chặn (`deny mach-lookup com.apple.tsm.portname`, per-pid), thêm temporary-exception không gỡ được; còn khi U.S. đang bật thì Dấu không nhận sự kiện nào để đổi lại. Thêm một tiến trình chạy nền chỉ để đổi nguồn là không đáng."

### D7. Cập nhật và loại bản dựng

- Tên cũ: "Cập nhật".
- 05/11/2026: "Loại bản dựng (người dùng chốt 05/11/2026)."
- 09/11/2026: câu "`dau-version.sh` cũng trả lời được" (cấu hình build và commit) sửa thành "cho biết commit của từng bản đã cài": script không in cấu hình build; luật không đổi.

### D8. Không telemetry

- 02/11/2026: nhật ký từng phím chỉ ở bản Debug, bật bằng `DauPerfLog` ("người dùng chốt 02/11/2026").

- 11/11/2026: thêm ý log bộ gõ ở bản phát hành không ghi app đích hay thời điểm theo từng lần kích hoạt (hai dòng log Release từng ghi bundle ID ở mức công khai; rà soát bảo mật, người dùng duyệt).

### D9. Giao diện

- 29/10/2026: bản trước của chuẩn đối chiếu: "Bố cục, chữ, khoảng cách theo mockup; riêng hình dáng control do macOS vẽ", chốt 29/10/2026.
- 29/10/2026: "Màu (chốt 29/10/2026)".
- 02/11/2026: "Chuẩn đối chiếu (sửa 02/11/2026)"; canvas trước, người dùng duyệt, rồi mới sửa mã ("người dùng chốt 02/11/2026"). "Lý do: app dựng bằng UI thuần nhưng lại chỉnh thông số cho khớp mockup (ví dụ lề hàng sidebar), vừa trái N1 vừa dễ vỡ khi macOS đổi; người dùng chốt 02/11/2026."
- 02/11/2026: nút mở/thu "Nâng cao": "đo macOS 27.2, 02/11/2026; lý do cũ 'thụt lề sai bố cục' không còn đúng".
- 05/11/2026: "Vỏ cửa sổ Cài đặt (người dùng chốt 05/11/2026; `docs/research/SWIFTUI-WINDOW-API.md`, đo bằng app thử)".
- 05/11/2026: ngoại lệ "theo HIG" cho sidebar (sidebar kéo thu được); cách đã loại cùng ngày: "duyệt cây view tìm `NSSplitView` mà `NavigationSplitView` dựng, phủ view lên đường chia".
- 06/11/2026: "Sidebar cố định như System Settings (người dùng chốt 06/11/2026, thay ngoại lệ 'theo HIG' ngày 05/11/2026: kéo thu sidebar bị giật và System Settings không cho thu)."

### D11. Kiểm tra ngữ cảnh

- 30/10/2026: "Sửa 30/10/2026 theo chốt A/B; bản trước: 'chỉ đọc lại khi có dấu hiệu lệch', vị trí tuyệt đối để ngỏ." Bản viết lúc đó: "hỏi `selectedRange` một lần để lấy vị trí tuyệt đối (cách A, N3)".
- 02/11/2026: gợi ý tự hoàn thành ("người dùng chốt 02/11/2026; trước đó mọi vùng bôi đen đều tính là lệch, 'gox' trong thanh địa chỉ Chrome").
- 02/11/2026: dựng lại khi lệch ("người dùng chốt 02/11/2026: bấm chuột vào thanh địa chỉ Chrome không được báo cho bộ gõ, 'tieemf' thành 'tieemf'").
- 02/11/2026: từ đã hết hợp lệ ("người dùng chốt 02/11/2026: ⌘A trong thanh địa chỉ Chrome là phím tắt menu, không tới bộ gõ, 'tốt', ⌘A, 'toots' ra 'toots' và hỏng tới dấu cách").
- 10/11/2026: thêm ý "App trả lời chậm" (thay ở vị trí Dấu tự theo dõi khi `selectedRange` lùi tối đa 2 chữ), người dùng duyệt. Bản trước: "Vị trí khác dự đoán (app tự sửa chữ, con trỏ đã đi chỗ khác) thì reset bộ đệm, không thay chữ." Câu trong "Câu hỏi đã trả lời" (vị trí thay chữ) trước đó: "Tự cộng dồn vị trí cũng không cứu được (vị trí gốc cũng là ảnh chụp cũ; VS Code đổi gốc toạ độ). Hướng cho app bất đồng bộ: gạch chân theo D13".
- 10/11/2026: ý "App trả lời chậm" viết lại theo mã (50b67ec và bản sửa ca đầu văn bản), người dùng duyệt: chạy ở mọi tốc độ gõ; giới hạn chậm là 2 thao tác cộng số thao tác của loạt phím dồn; vùng thay luôn kết thúc ở vị trí Dấu theo dõi; ở đầu văn bản, trong cùng loạt phím dồn, không cần chữ của app để so. Bản trước: "Khi kiểm: `selectedRange` lùi sau vị trí đó tối đa 2 chữ và phím trước cách ít nhất 50 ms"; "Phím dồn dưới 50 ms: chưa áp dụng (M6)". Câu trong "Câu hỏi đã trả lời" (vị trí thay chữ) trước đó: "App chậm mà phím cách từ 50 ms: Dấu dùng vị trí tự theo dõi, kiểm bằng chữ đọc được (D11, M6). Phím dồn dưới 50 ms: chưa có cách, đang làm ở M6".
- 10/11/2026 (rà soát tài liệu, người dùng duyệt): bỏ dòng "Chỉ đọc chữ từ ứng dụng (`attributedSubstring`) cho tính năng \"Thêm dấu cho từ đã gõ\" (D20)", trái với ba chỗ đọc chữ khác của chính D11. "Vì sao": "Telex của Apple cùng điều kiện ra chữ 2/3 lượt" thành 2 ô đo hợp lệ, ô thứ ba là đo hỏng do cách script chuyển nguồn; số đo phím dồn chỉ còn ghi ở D13.

### D12. Ưu tiên tiến trình

- 10/11/2026: thêm ý "Số đo" từ bài tải nặng của M6, người dùng duyệt. Lời quyết định không đổi.
- 10/11/2026 (rà soát tài liệu, người dùng duyệt): ý "Số đo" ghi ô cao hơn lúc rảnh (p99 của Chrome) và cách đo; câu "Chưa có dấu hiệu App Nap hay bị xếp vào nhân tiết kiệm điện" thành "chưa đo trực tiếp". Lời quyết định không đổi.

### D13. Gạch chân là đường lui cuối cùng

- Tên cũ: "Ứng dụng không hỗ trợ thay chữ tại chỗ".
- 30/10/2026: mặc định mọi app không gạch chân, danh sách chỉ gắn nhãn "Đề xuất" ("chốt 30/10/2026").
- 30/10/2026: Firefox vào danh sách đề xuất ban đầu ("thêm theo số đo: thay tại chỗ sai ở 0 và 5 ms, gạch chân đúng ở 0 ms; người dùng duyệt 30/10/2026").
- 09/11/2026: câu "từ 10 ms đều đúng" trong lý do viết lại cho khớp số đo: VS Code ở 10 ms sai một lần ở lượt M2 với câu mẫu cũ; luật không đổi.
- 10/11/2026: đổi tên thành "Gạch chân là đường lui cuối cùng", người dùng duyệt. Thay tại chỗ là cách gõ của Dấu, gõ sai ở một app là lỗi phải sửa; nhãn "Đề xuất" chỉ giữ cho app mà thay tại chỗ còn sai ở tốc độ gõ thật. Bản trước: "Gạch chân (marked text) là đường lui, bật theo quy tắc riêng của từng app"; "Danh sách đề xuất ban đầu: VS Code, các app Electron/Chromium và Firefox". Do M6 bước 1: Chrome trang bận sai 3/3 khi thay theo vị trí của app, đúng 3/3 khi thay theo vị trí Dấu tự theo dõi.
- 10/11/2026: Chrome, Firefox và VS Code bỏ nhãn "Đề xuất", người dùng duyệt: đo ở nhịp 5, 10, 20 ms sau các lần sửa ở M6 (`docs/PROGRESS.md`, nhật ký 10/11). Bản trước: "Hiện còn nhãn: VS Code, các app Electron/Chromium và Firefox (sai khi phím dồn, M3)".
- 10/11/2026 (rà soát tài liệu, người dùng duyệt): danh sách còn nhãn ghi số đo lại của Edge và thêm Cursor; bản trước: "Edge, Brave, Arc và các app Electron khác (sai khi phím dồn ở M3 hoặc xếp theo công nghệ giao diện; chưa đo lại sau lần sửa ở M6)". "Vì sao (nhãn đã bỏ)" ghi nhịp 5, 10, 20 ms là nhịp danh nghĩa và số lượt mỗi app.
- 10/11/2026: Edge bỏ nhãn "Đề xuất" (người dùng duyệt), theo số đo lại cùng ngày; hàng mẫu Edge trên các artboard SettingsApps* đổi thành Cursor (canvas phiên bản 148). Bản trước: "Hiện còn nhãn: Edge (đo lại 10/11/2026 …; bỏ nhãn sau khi đổi hàng mẫu trên artboard), Cursor…".

### D16. Bảo trì và gỡ cài đặt

- Tên cũ: "Bảo trì".
- 04/11/2026: "Gỡ cài đặt cần người dùng bấm '–' (người dùng chốt 04/11/2026)".
- 04/11/2026: app không tự chuyển bàn phím ("người dùng chốt 04/11/2026: trên macOS 27.2 nút '–' bấm được cả khi Dấu đang được chọn và macOS tự chuyển sang nguồn khác, đo bằng Dấu thật").
- 04/11/2026: gỡ tự động không cần "–" bị loại: "đo bằng bản thử ở mục 8.1b vòng U … cài lại thì macOS bật Dấu ngay không hỏi (K1); người dùng chọn máy sạch và việc gỡ do chính họ xác nhận bằng '–'."
- 05/11/2026: "Dấu đã cài nhưng không có trong nguồn đầu vào (người dùng chốt 05/11/2026, từ kiểm toán M5) … (trước đây sheet nháy lên rồi gỡ ngay)."

### D17. Trợ năng

- 30/10/2026: "Sửa 30/10/2026 cùng D2; bản trước: Dấu thông báo khi đổi chế độ Việt/Anh của mình."
- 30/10/2026: hệ thống có đọc khi chuyển nguồn, đo ở M3 (`docs/history/LOG-M0-M4.md` ngày 30/10/2026).

### D18. Phòng thủ với IMK

- 11/11/2026: thêm kiểm biên số do app trả, hoãn lời gọi lồng, thông báo từ tiến trình khác chỉ là gợi ý, và test fuzz bắt buộc (rà soát bảo mật tìm ra hai đường crash vì tràn số; người dùng duyệt).

### D20. Thêm dấu cho từ đã gõ

- 29/10/2026: phần "Chi tiết (29/10/2026)": áp dụng cho cả phím dấu thanh lẫn phím biến đổi; không tự thêm biến đổi khác; "hợp lệ" theo mức tiền tố của D30; gõ đúp trên từ đọc lại; không giữ "lịch sử từ".
- 30/10/2026: "Phạm vi (chốt 30/10/2026, M3)".
- 30/10/2026: "D4 × D20 (chốt 30/10/2026)": sự kiện reset của D4 chỉ xoá bộ đệm, không chặn D20.
- Trước 05/11/2026, D20 chỉ đọc chữ trước con trỏ ở phím dấu/biến đổi; chữ cái thường gõ sau reset hay sau Backspace bắt đầu từ mới ("q" có sẵn + "uer" → "qủe").
- 05/11/2026: "Chữ cái gõ sát chữ có sẵn (chốt 05/11/2026, câu hỏi E8)", "ngược lại chữ đó bắt đầu từ mới như trước". Chọn giữa ba phương án bằng mô phỏng: chỉ đọc ở phím dấu ("cách cũ"), luôn nối, và chỉ nối khi từ ghép còn là tiền tố hợp lệ (`docs/research/EXTERNAL-TEST-INPUTS.md` mục 9.8).
- 05/11/2026: "Ba ngoại lệ (chốt 05/11/2026, sau mô phỏng)". Ở ngoại lệ (a), "hoc" + "J" → "học" ghi "như trước".

### D22. Gõ tắt loại trừ z, f, w, j

- Tên cũ: "Gõ tắt phụ âm và 'Cho phép z, f, w, j' loại trừ nhau".

### D23. w → qu chỉ ở VNI

- 29/10/2026: "sửa câu chữ 29/10/2026, bản trước ghi 'ư/ơ'".

### D24. Tên và định danh

- Tên cũ: "Tên".
- 29/10/2026: tên "Dấu" chốt 29/10/2026.
- 30/10/2026: tên miền `dau.codefastlabs.com` ("người dùng chốt 30/10/2026").
- 06/11/2026: "Dấu" là tên thương hiệu, không dịch, không bỏ dấu ở mọi ngôn ngữ ("người dùng nhấn mạnh 06/11/2026").

### D25. Nhận diện

- 05/11/2026: "Biểu tượng theo loại bản (người dùng chốt 05/11/2026, các loại bản ở D7)".
- 05/11/2026: dải chéo Hổ phách ở góc dưới phải ("người dùng chọn 05/11/2026 giữa dải góc và nền sọc; nền sọc mất ở 16–32 pt và ở kiểu Trong suốt").

### D26. Gõ đúp phím dấu

- Tên cũ: "Sau khi gõ đúp phím dấu".
- 29/10/2026: luật gốc, ngoại lệ "ooo" ("(29/10/2026)"); "Hệ quả đã chấp nhận (29/10/2026)": "password" → "pasword".
- 05/11/2026: "Giới hạn đã biết (người dùng chốt 05/11/2026, từ so sánh với ca thử của bộ gõ khác, `docs/research/EXTERNAL-TEST-INPUTS.md` mục 9)".
- 05/11/2026: ngoại lệ chữ ư từ một phím w đứng riêng ("05/11/2026, người dùng giao phiên chính chọn sau khi phản biện").

### D27. Không có phím gõ nhanh ơ, ư

- 29/10/2026: quyết định ghi ngày 29/10/2026.

### D28. Bỏ dấu tự do

- 29/10/2026: luật khi bật và khi tắt ("(29/10/2026)").
- 05/11/2026: "Phím biến đổi khác loại (người dùng chốt 05/11/2026, từ so sánh với ca thử của bộ gõ khác, `docs/research/EXTERNAL-TEST-INPUTS.md` mục 9)".

### D29. Telex đơn giản

- 29/10/2026: "(29/10/2026, theo Simple Telex 1 của OpenKey — xem `docs/OPENKEY-NOTES.md` 3.5)".

### D30. Kiểm tra chính tả

- 29/10/2026: luật gốc ("(29/10/2026)").
- 05/11/2026: "Dấu thanh trên vần tắc (05/11/2026, người dùng giao phiên chính chọn sau khi phản biện; `docs/research/EXTERNAL-TEST-INPUTS.md` mục 9)".

### D31. Âm tiết tiếng Việt hợp lệ

- 29/10/2026: định nghĩa gốc ("(29/10/2026)").
- 29/10/2026: "Nới cho địa danh (29/10/2026, phương án d)"; đo trên 428 từ tiếng Anh; vần "ăk" chỉ nhận khi ă đã có trước k ("(29/10/2026)").
- 05/11/2026: "Bổ sung (người dùng chốt 05/11/2026, từ so sánh với ca thử của bộ gõ khác, `docs/research/EXTERNAL-TEST-INPUTS.md` mục 9)": phím dấu sau "qu", "qui" không hợp lệ, b, m, p, v với âm đệm o, u, vần "oao" và "uêu".
- 10/11/2026: chữ ă, â (có hoặc không có dấu thanh) và đ đứng một mình được giữ khi kết thúc từ, hoa hay thường như nhau, người dùng duyệt; tham chiếu Telex của Apple. Bản trước: "ă, â không đứng cuối âm tiết (\"aw\" khôi phục thành \"aw\")"; chữ đ đứng một mình cũng bị trả về "dd".

### D32. Backspace

- 29/10/2026: luật gốc ("(29/10/2026)").
- 05/11/2026: "quá" ⌫ → "qu" ("(05/11/2026)").

### D33. Độ dài từ

- 29/10/2026: luật gốc ("(29/10/2026)").
- 05/11/2026: xoá hết từ bằng Backspace thì hết trạng thái đi thẳng ("người dùng chốt 05/11/2026, E9 của `docs/research/EXTERNAL-TEST-INPUTS.md`").

### D34. Chữ hoa với phím biến đổi

- 29/10/2026: quyết định ghi ngày 29/10/2026.

### D35. "uơ" và "ươ"

- 29/10/2026: luật gốc ("(29/10/2026)").
- 05/11/2026: "Thứ tự u + móc + o (05/11/2026, người dùng giao phiên chính chọn sau khi phản biện) … trước đây VNI 'thu7o3' bị khôi phục thành phím gốc."

### D36. VNI: chữ số thành dấu

- 29/10/2026: quyết định ghi ngày 29/10/2026.

### D37. Cài đặt bộ gõ

- Tên cũ: "Cài đặt bộ gõ (M5, 30/10/2026)".
- 30/10/2026: app chủ không chạy sandbox; định danh không đổi giữa các bản; bản trước về đăng xuất: "Lần cài đầu có thể phải đăng xuất một lần để nguồn nhập liệu xuất hiện: onboarding phát hiện và hướng dẫn."
- 02/11/2026: kiểm chữ ký và Team ID của bộ gõ, banner "Cài lại" ("người dùng duyệt 02/11/2026").
- 04/11/2026: "Bật lần đầu không cần đăng xuất (người dùng chốt 04/11/2026)". "Lý do (đo bằng bản thử rồi bằng Dấu thật 04/11/2026, macOS 27.2, tài khoản đã từng cài Dấu; `docs/research/M5-INSTALL.md` mục 0 (b)9, (b)10 và 8.1b vòng E): danh sách '+' và việc dựng hộp thoại đọc bộ đệm của System Settings, bộ đệm không làm mới khi có nguồn mới đăng ký (trước đây chỉ đăng xuất mới làm mới) …"
- 05/11/2026: một app vẫn không chọn được Dấu thì hướng dẫn đăng xuất rồi đăng nhập lại ("người dùng chốt 05/11/2026"). "Lý do (đo bằng Dấu thật 05/11/2026, `docs/research/M5-INSTALL.md` (b)12)".
- 05/11/2026: "Nâng cấp lúc mở app × kiểm chữ ký (người dùng chốt 05/11/2026, từ kiểm toán M5)".
- 09/11/2026: câu "Chưa làm cho gỡ cài đặt: bộ đệm còn nhớ bộ gõ đã gỡ" viết rõ là gỡ cài đặt chỉ xoá bộ đệm của System Settings (D16), bộ đệm của từng app thì chưa; luật không đổi.
- 10/11/2026: thêm "bản chủ" (bản trong Applications, nhận ra bằng mã băm chữ ký), chỉ bản chủ cài và thay bộ gõ, bộ gõ đã cài là bản nhúng của bản chủ; người dùng duyệt 10/11/2026. Bản trước: bản Dấu.app nào cũng cài được, và lúc mở app chỉ thay khi `CFBundleVersion` của bản nhúng lớn hơn. Cùng ngày, ý 05/11 đổi thành "Chữ ký sai thì không tự thay"; bản trước, nguyên văn: "Nâng cấp trước, kiểm chữ ký sau: khi bộ gõ đã cài vừa cũ hơn vừa có chữ ký sai, app nâng cấp trước; kiểm chữ ký và Team ID chạy sau khi nâng cấp xong, nên banner 'Cài lại' chỉ hiện khi bản đã cài sau đó vẫn sai." D19 thêm câu bộ gõ lùi theo bản chủ.
- 10/11/2026 (sau kiểm toán, người dùng chọn): trong onboarding, bộ gõ đã cài có chữ ký sai thì bước 2 yêu cầu "Cài lại" trước khi bật (trước đó "Bật Dấu" bật luôn bộ gõ đã cài, không kiểm chữ ký); hơn một bản Dấu.app trong cùng thư mục Applications thì trùng bản nào cũng là bản chủ (trước đó sổ không quy định).

- 11/11/2026: "Kiểm chữ ký" đổi từ so Team ID của bộ gõ với app chủ sang yêu cầu mã (chứng chỉ Apple, Team ID, định danh); thêm việc kiểm app chủ ở mục "Cài đặt Dấu…" và ý "Giới hạn" (chỉ phát hiện, không chặn). Bản trước: "app kiểm chữ ký và Team ID của bộ gõ đã cài; không khớp thì hiện banner 'Cài lại'." (rà soát bảo mật, người dùng duyệt).

### D38. Chữ trên giao diện

- 04/11/2026: quyết định "người dùng chốt 04/11/2026"; bản đầu: chữ của Dấu chỉ tiếng Việt.
- 05/11/2026: tên "Thùng rác" đọc từ chuỗi của macOS ("người dùng chốt 05/11/2026, từ kiểm toán M5").
- 06/11/2026: chữ của Dấu theo ngôn ngữ giao diện của Dấu ("D41; sửa 06/11/2026, bản trước: chỉ tiếng Việt").

### D39. Ủng hộ dự án

- 04/11/2026: GitHub Sponsors ("người dùng chốt 04/11/2026"); chuyển khoản VietQR "thêm cùng ngày".

### D40. Chữ dựng sẵn và phím z

- Tên cũ: "Phím ra chữ có dấu dựng sẵn và phím z".
- 05/11/2026: "người dùng chốt 05/11/2026, từ so sánh với ca thử của bộ gõ khác, `docs/research/EXTERNAL-TEST-INPUTS.md` mục 9".

### D41. Ngôn ngữ giao diện

- 04/11/2026: nhu cầu được nêu: người Việt dùng rộng rãi và người nước ngoài học tiếng Việt ("nêu 04/11/2026").
- 06/11/2026: hai ngôn ngữ, String Catalog gốc tiếng Anh ("người dùng chốt 06/11/2026"); tên nguồn trong câu chữ theo ngôn ngữ hệ thống ("người dùng chốt 06/11/2026").
- 06/11/2026: ô chọn ngôn ngữ trong Cài đặt ghi khoá `AppleLanguages` ("Theo hệ thống", Tiếng Việt, English; 06/11/2026), sau bị loại.
- 08/11/2026: "sửa 08/11/2026": dùng mục ngôn ngữ riêng từng ứng dụng của macOS ("N1; người dùng chốt 08/11/2026"). "Đo 08/11/2026 trên Dấu thật (macOS 27.2)": danh sách "+" có Dấu.app; macOS hỏi mở lại app và không tự mở lại ("đo 08/11/2026"). Nút "Mở lại Dấu" ("người dùng chốt 08/11/2026, canvas phiên bản 137").

### D42. Ngưỡng hiệu năng

- 10/11/2026: quyết định mới, người dùng duyệt, từ số đo bài tải nặng của M6. Thay câu hỏi mở "Ngưỡng hiệu năng (độ trễ p99, bộ nhớ): chốt sau khi đo, so với gõ bằng U.S."; bàn phím U.S. không dùng làm mốc vì không có log từng phím, đối chứng là Telex của Apple.
- 10/11/2026 (rà soát tài liệu, người dùng duyệt): thêm dòng `heavy.sh` chưa chạy trọn lượt nào. Ngưỡng không đổi.

### D43. Ô bỏ qua vùng thay chữ

- 11/11/2026 (chốt cùng ngày): bản đầu nhận ra ô chỉ theo vị trí, "đổi ô hoặc kích hoạt lại thì xét lại từ đầu", và gửi trong phím cho kiểu xterm.js. Sau rà soát bảo mật (người dùng duyệt): thêm bằng chứng dương (một lần đọc chữ), kết quả chỉ xét lại khi kích hoạt lại hay đổi client (đúng với mã), kiểu xterm.js ghi là vẫn thay tại chỗ tới khi chẩn đoán xong.

## Đã biết nhưng không làm

- 04/11/2026: "Tách thành mục riêng ngày 04/11/2026, người dùng chốt".
- 05/11/2026: dòng "Tự thêm mũ/móc còn thiếu … tự tách âm tiết giữa từ" (uvie-rs), lý do "D20 (không tự thêm biến đổi khác), D30 (người dùng chốt 05/11/2026)".

## Câu hỏi mở

### Bộ gõ trong mục ngôn ngữ riêng từng ứng dụng

- 08/11/2026: câu hỏi nêu ("nêu 08/11/2026").

### Hộp thoại và đăng xuất khi bật bộ gõ

- 02/11/2026 (hiện trạng trước 04/11/2026, nguyên văn): "Đo bằng Dấu thật (macOS 27.2, 02/11/2026): 'Bật Dấu' trả 0 nhưng macOS không ghi danh sách nguồn đang bật; Cài đặt nhận yêu cầu bật rồi báo lỗi 'Invalid value on inputSourceToBeEnabled', theo mã thì khi đó không dựng hộp thoại 'Cho phép … bật …?' (chuỗi này có trong Cài đặt nhưng chưa ai thấy hiện). Vì vậy: sau 'Bật Dấu' đọc lại trạng thái từ `com.apple.inputsources`, không tin TIS của chính tiến trình; chưa bật thì mở Cài đặt › Bàn phím và hướng dẫn bấm '+' (N4, D37). Đăng xuất: Apple DTS nói cần, một dự án khác nói không; trả lời bằng Dấu thật ở M5 T4."
- 04/11/2026: "Trên macOS 27.2 (04/11/2026, bản thử rồi Dấu thật): có hộp thoại xin phép, và không cần đăng xuất nếu làm theo D37; còn phải đo trên macOS 14–26 và bản ký Developer ID; không đo trên tài khoản macOS mới (T4 bỏ, người dùng chốt 04/11/2026)."

### Cài cho riêng mình hay cho cả máy

- 11/11/2026: chuyển từ "làm sau M5" sang "làm trước M7", vì là cách duy nhất chặn việc thay bundle bộ gõ (D37 ý "Giới hạn"; rà soát bảo mật, người dùng duyệt).
- 04/11/2026: câu hỏi nêu ("người dùng nêu 04/11/2026, làm sau M5"). Bước đo một phần trong `docs/research/M5-INSTALL.md` mục 8.2 là bước P6.

### Hộp thoại App Group

- 30/10/2026: "Bản có Team ID: không có hộp thoại (30/10/2026)".

### Loại bản dựng

- 05/11/2026: câu hỏi nêu ("nêu 05/11/2026, chốt ở M7").

### Tên "Dấu"

- 30/10/2026: bundle ID và tên miền chính chốt ở D24 ("đã chốt ở D24, 30/10/2026").

## Câu hỏi đã trả lời

### Vị trí thay chữ (câu hỏi A/B)

- 29/10/2026: "Đã chốt (29/10/2026): cách A." Số đo M2 lúc đó ghi pointer `docs/PROGRESS.md` (nay ở `docs/history/LOG-M0-M4.md`). "Slack không đo: người dùng chọn Telegram thay cho Slack (30/10/2026); số đo Telegram ghi trong `docs/PROGRESS.md`." Hướng lúc đó: "Hướng cho app bất đồng bộ: M3 thử gạch chân (D13) theo bundle ID, đo ở 0 ms rồi chốt. Máy tải nặng: đo ở M6."
- 10/11/2026 (rà soát tài liệu): số đo phím dồn sau khi sửa không chép ở đây nữa, dẫn sang D13.

### App Group với bản ký ad-hoc

- 29/10/2026: bản ký ad-hoc bị từ chối im lặng, cần Team ID ("29/10/2026, `scripts/selftest/app-group.sh`").
- 30/10/2026: bản có Team ID (Personal Team miễn phí, ký "Apple Development", 30/10/2026) chạy được.

### App chủ có sandbox được không

- 30/10/2026: "Đã chốt: không sandbox (D37)."

### Chrome/Terminal có cần quyền Accessibility không

- Trước M2 (nguyên văn): "Mốc M2 phải kiểm chứng `insertText(_:replacementRange:)` trên các app này. Mặc định nếu không được: dùng gạch chân cho các app đó (D13), không xin quyền Accessibility (N4, bảo mật). Mọi câu trên giao diện và website về gạch chân hay quyền truy cập để ô trống cho tới khi có kết quả (N5)."
- 30/10/2026: "Trả lời (30/10/2026): không cần. … Lỗi khi phím đến dồn là do các app này áp phím bất đồng bộ, không phải do thiếu quyền: M3 thử gạch chân (D13), xem câu hỏi A/B."
