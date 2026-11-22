# Văn tiếng Việt: thói quen câu tiếng Anh và dấu câu

Tài liệu này tìm nguồn cho các thói quen câu tiếng Anh ("văn dịch") đang có trong văn tiếng Việt của repo, đo mức phổ biến của từng thói quen và xếp chúng theo mức chắc chắn. Phiên chính dùng kết quả này để soạn luật viết theo D44 (Văn xuôi tiếng Việt).

## Hiện trạng

Cập nhật ngày 22/11/2026.

- **Lỗi rõ nhất là dấu phẩy trước "và", "hoặc", "hay".** Hướng dẫn bản địa hoá tiếng Việt của Microsoft cấm dấu phẩy trước "và" và "hoặc". Hướng dẫn của Proton cũng cấm, còn *Ngữ pháp tiếng Việt* (2002) nói khi đã có kết từ thì thường bỏ dấu phẩy giữa các thành phần ngang hàng. Tài liệu chính của repo có 426 chỗ dấu phẩy đứng trước ba từ này. Riêng `docs/Decisions.md` có 126 chỗ.
- **Không phải chỗ nào cũng sai như nhau.** Dấu phẩy trong chuỗi liệt kê từ ba mục trở lên ("A, B, và C") là lỗi chắc chắn. Dấu phẩy trước "và" nối hai vị ngữ chung một chủ ngữ cũng là lỗi; ví dụ người dùng đã chỉ ra ("Dấu tự đặt dấu vào đúng chỗ theo chính tả, và dời dấu khi từ dài thêm") thuộc loại này. Dấu phẩy trước "và" nối hai vế có chủ ngữ riêng thì *Ngữ pháp tiếng Việt* cho phép, nên chỉ sửa khi câu dài hoặc hai vế là hai ý ngang hàng theo D44.
- **Thói quen phổ biến thứ hai là bị động thừa.** Kiểu câu "X được đặt là…", "Nhật ký đã được chuyển…" có khoảng 335 chỗ trong tài liệu chính. Khoảng 7 trên 10 mẫu bỏ được "được" mà câu vẫn đủ nghĩa. Cơ sở là tiếng Việt thiên về cấu trúc đề–thuyết (Cao Xuân Hạo), nên tân ngữ có thể đứng đầu câu làm đề mà không cần dấu hiệu bị động. Mozilla và Gengo cũng khuyên đổi câu bị động tiếng Anh thành câu chủ động.
- **Nhiều thói quen trong danh sách ứng viên gần như không có trong repo.** Repo không có "được/bị … bởi" (trừ một chỗ trong `docs/history/`), "một cách" + tính từ, "tiến hành", "bởi vì… nên", thì chồng ("đã đang"), cũng không có tiêu đề viết hoa kiểu Title Case. Luật vẫn nên ghi các mục này để chúng không xuất hiện về sau.
- **Ba chỗ chưa có nguồn chính thức.** Đó là "một cách", "của" chồng nhiều tầng và "là một" thừa. Các mục này chỉ dựa trên đối chiếu ngữ pháp, nên được xếp vào mức (c).
- **Hai mâu thuẫn cần phiên chính xử lý trước khi giao việc sửa.** [`docs/README.md`](../README.md) nói `docs/history/` giữ "đúng như lúc chúng được ghi", trong khi D44 nói luật viết áp cho cả `docs/history/`. Ngoài ra, sửa văn của `docs/Decisions.md` là thay đổi sổ quyết định, nên cần hỏi người dùng theo mục "Điều phối" của [`CLAUDE.md`](../../CLAUDE.md), trừ khi D44 đã được coi là lời giao việc đó.

## 1. Nguồn đã dùng

Bảng dưới ghi điều mỗi nguồn nói. Các mục ở phần 3 dẫn nguồn theo mã ở cột đầu.

| Mã | Nguồn | Điều nguồn nói |
|---|---|---|
| NPTV | Trung tâm KHXH&NV Quốc gia, *Ngữ pháp tiếng Việt*, Nxb Khoa học Xã hội, 2002, tr. 282–287, mục "Dấu phẩy", bản trích trên [ngonngu.net](https://ngonngu.net/cv_daucau_khxh_03/92) | Mục 5.2: giữa các yếu tố của liên hợp song song, khi đã dùng kết từ thì thường lược bớt dấu phẩy. Mục 5.3: trong câu ghép, khi có kết từ thì có thể lược bớt dấu phẩy giữa các vế. Mục 5.4: thường không đặt dấu phẩy giữa đề và thuyết, trừ khi phần đề dài. |
| MS | Microsoft, *Vietnamese Localization Style Guide*, bản PDF sửa ngày 04/09/2024, [download.microsoft.com](https://download.microsoft.com/download/b/f/e/bfecb1b4-21ab-48fd-a48c-c2471b026f8f/vie-vnm-StyleGuide.pdf) | Mục 4.1.14: tiếng Anh hay đặt dấu phẩy trước "and", "or", còn tiếng Việt không áp quy tắc này, nên không dùng dấu phẩy trước "và" và "hoặc". Mục 4.1.5: tiếng Việt chỉ viết hoa chữ đầu, ví dụ "Chọn tất cả" chứ không phải "Chọn Tất Cả". Mục 4.1.4: mạo từ "a/an/the" không cần dịch, trừ khi "a" mang nghĩa "một". Mục 4.1.13: chủ ngữ giả "It" không dịch thành "Nó" ("Khó làm…", "Trời đang mưa"). Mục 4.1.17: danh động từ tiếng Anh dịch thẳng thành động từ, không cần thêm "việc" ("Đọc cuốn sách này là bắt buộc"). Mục 2.1.3: tránh dịch từng chữ, ví dụ "Không lưu được hình ảnh" thay cho "Lưu hình ảnh thất bại". Mục 4.1.7 có ví dụ bỏ "bởi vì… nên" và bỏ "được" khi viết lại câu. |
| MOZ | Mozilla, hướng dẫn văn phong tiếng Việt, [mozilla-l10n.github.io](https://mozilla-l10n.github.io/styleguides/vi/) | Cố đổi câu bị động tiếng Anh thành câu chủ động. Tránh viết hoa kiểu Title Case ("Thiết lập hệ thống", không phải "Thiết Lập Hệ Thống"). Cẩn thận với số nhiều: "Settings" là "Thiết lập", không phải "Các thiết lập". |
| PRO | Proton, "Guidance for Vietnamese", 28/10/2025, [localize.proton.me](https://localize.proton.me/t/guidance-for-vietnamese/3345) | Không đặt dấu phẩy trước "và", "hoặc" khi nối các thành phần liên quan ("người dùng hoặc nhóm", không phải "người dùng, hoặc nhóm"). Tiếng Việt cần ít lặp hơn tiếng Anh, nên bớt đại từ và sở hữu ("danh sách liên hệ" thay cho "danh sách liên hệ của bạn"). Tránh lạm dụng từ tiếng Anh. |
| GEN | Gengo, hướng dẫn văn phong tiếng Việt, [gengo.com](https://gengo.com/vi/?p=85205), không ghi ngày | Tránh câu bị động: "Không tìm thấy tập tin %s" thay cho "Tập tin %s không được tìm thấy". Tránh dịch từng chữ. Ví dụ liệt kê không có dấu phẩy trước "và" ("văn bản, hình ảnh và chuông đa âm điệu"). |
| CXH | Nguyễn Văn Hiệp, "Vài nét về lịch sử nghiên cứu cú pháp tiếng Việt: Từ 1990 đến nay", 24/11/2006, [ngonngu.net](https://ngonngu.net/cuphap_lichsu05/156), giới thiệu Cao Xuân Hạo, *Tiếng Việt – Sơ thảo ngữ pháp chức năng*, Quyển 1, 1991 | Cao Xuân Hạo phản đối việc áp khuôn ngữ pháp châu Âu ("Dĩ Âu vi trung") lên câu tiếng Việt. Câu tiếng Việt có cấu trúc đề–thuyết. Ranh giới đề–thuyết được đánh dấu bằng khả năng thêm "thì", "là", "mà". |
| CXH2 | Nguyễn Tiến Hải, bài về câu bị động tiếng Việt, 29/05/2011, [blog](https://nguyentienhai.blogspot.com/2011/05/vietnamese-passive-sentences-from.html), nguồn thứ cấp | Bài dẫn Cao Xuân Hạo (2001, "Hai phép cộng và trừ trong ngôn ngữ", *Ngôn ngữ* số 10): tiếng Việt không có dạng bị động. Ông coi "được", "bị" là động từ mang nghĩa riêng chứ không phải dấu hiệu bị động. Tác giả bài viết không đồng ý với quan điểm này. |
| VNE | Tường Minh, "Lạm dụng tiếng Anh", VnExpress, 18/10/2021, [vnexpress.net](https://vnexpress.net/lam-dung-tieng-anh-4373194.html) | Chêm từ tiếng Anh khi đã có từ Việt thông dụng là lạm dụng. Cụm "đến từ" (ví dụ "Ông A… đến từ trường ĐH Bách khoa") là cấu trúc tiếng Anh, bỏ đi thì câu tự nhiên hơn. Thuật ngữ công nghệ khó dịch thì chêm được. |
| APL | Apple Style Guide, trang giới thiệu, [support.apple.com](https://support.apple.com/guide/applestyleguide/apsg1eef9171/web) | Văn phong của hướng dẫn này theo quy ước tiếng Anh Mỹ. Với nội dung đã bản địa hoá, người viết tra nguồn riêng của ngôn ngữ đó. Apple không công bố hướng dẫn văn phong tiếng Việt. |

Các nguồn đã tìm mà không đọc được bản số hoá có nội dung liên quan: sách của Diệp Quang Ban và Nguyễn Đức Dân, cuốn *Tiếng Việt, văn Việt, người Việt* của Cao Xuân Hạo và bài trên Tạp chí Khoa học ĐHQGHN về dịch câu bị động tiếng Anh (bản quét không có lớp chữ). Tài liệu này không dẫn các nguồn đó.

## 2. Danh mục

Cột "Tài liệu chính" đếm số chỗ khớp biểu thức tìm trong `README.md`, `CONTRIBUTING.md` và `docs/*.md` (không gồm `docs/CLAUDE.md`). Cột "Đúng" ghi số mẫu thật sự là lỗi trên mười mẫu xem tay. Số theo các nhóm tài liệu khác nằm ở phần 4.

| Mục | Mức | Tài liệu chính | Đúng | Nguồn |
|---|---|---|---|---|
| A1. Dấu phẩy trong chuỗi liệt kê ("A, B, và C") | a | 42 | 6/10 | MS, PRO, GEN, NPTV |
| A2. Dấu phẩy trước "và/hoặc" nối hai vị ngữ chung chủ ngữ hoặc hai bổ ngữ | a | 94 | 4/10 | NPTV, MS, PRO |
| A3. "được/bị V bởi X" | a | 0 | — | NPTV (trật tự từ), CXH |
| A4. Tiêu đề viết hoa kiểu Title Case | a | 0 | — | MS, MOZ |
| A5. Thì chồng ("đã đang", "sẽ đã") | a | 0 | — | chưa có nguồn riêng |
| B1. Bị động thừa "được + V" không nêu ai làm | b | 335 | 7/10 | MOZ, GEN, CXH |
| B2. Danh hoá bằng "việc", "sự", "tiến hành" | b | 44 | 5/10 | MS |
| B3. "Nó", "Điều này", "Điều đó" mở câu | b | 24 | 7/10 | MS |
| B4. Ngoặc đơn dài chen giữa câu | b | 179 | 6/10 | D44 |
| B5. Nhiều dấu hai chấm trong một câu | b | 7 | 7/10 | D44 |
| B6. "đến từ" theo nghĩa "do", "lấy từ" | b | 2 | 8/10 | VNE |
| C1. Dấu phẩy trước "và/hoặc" nối hai vế có chủ ngữ riêng | c | khoảng 290 | — | NPTV |
| C2. "là một" với "một" thừa | c | 31 | 2/10 | MS (mạo từ) |
| C3. "của" chồng nhiều tầng | c | 14 | 2/10 | chưa có nguồn |
| C4. "Với X," mở câu | c | 55 | 3/10 | chưa có nguồn |
| C5. "sẽ được" | c | 8 | 4/10 | MOZ |
| C6. "Nếu…," không có "thì" | c | 106 | — | CXH (giữ "thì") |
| C7. Từ tiếng Anh chêm khi có từ Việt | c | 48 | 2/10 | VNE, PRO, `docs/Glossary.md` |
| C8. "các/những" thừa | c | 2 | — | MOZ |
| C9. "của bạn" và đại từ thừa | c | 3 | 2/10 | PRO |
| C10. "thất bại" trong câu báo lỗi | c | 1 | 2/10 | MS |
| C11. "trong khi", "khi mà" | c | 4 | 1/10 | MS |
| C12. "một cách" + tính từ, "bởi vì… nên" | c | 0 | — | MS (bởi vì… nên) |

## 3. Từng mục

Mỗi mục ghi lý do, ngoại lệ, cách sửa và một cặp trước/sau lấy từ repo. Câu "sau" chỉ minh hoạ cách sửa. Người sửa thật vẫn giữ nguyên nghĩa và số liệu theo D44.

### Mức (a): chắc chắn sai, sửa theo khuôn và soát từng chỗ

**A1. Dấu phẩy trong chuỗi liệt kê.** Tiếng Anh Mỹ đặt dấu phẩy trước "and" ở cuối chuỗi (Oxford comma). MS nói rõ tiếng Việt không áp quy tắc này. PRO và GEN cũng không đặt dấu phẩy ở đó. NPTV mục 5.2 nói khi đã có kết từ thì thường lược dấu phẩy. Luật áp cho mọi chuỗi từ ba mục trở lên, kể cả khi mỗi mục là một vế câu ngắn.

- Ngoại lệ: khi một mục trong chuỗi đã chứa "và", bỏ dấu phẩy có thể làm người đọc nhầm ranh giới. Khi đó nên đổi cấu trúc (đặt mục có "và" cuối chuỗi, dùng gạch đầu dòng hoặc tách câu) thay vì giữ dấu phẩy. Cách này dựa trên đối chiếu ngữ pháp, chưa có nguồn riêng.
- Cách sửa: bỏ dấu phẩy ngay trước "và", "hoặc", "hay" cuối chuỗi.
- Trước (`docs/Decisions.md`, mục lục, D11): "Khi vị trí lệch, Dấu dựng lại bộ đệm, chứng minh app chậm, hoặc reset."
- Sau: "Khi vị trí lệch, Dấu dựng lại bộ đệm, chứng minh app chậm hoặc reset."

**A2. Dấu phẩy trước "và/hoặc" nối hai thành phần không phải hai vế câu.** Hai vị ngữ chung một chủ ngữ, hay hai bổ ngữ của một động từ, là một liên hợp. NPTV mục 5.2 nói khi đã có kết từ thì thường lược dấu phẩy, còn MS cấm hẳn. Chuỗi giao diện của repo cũng có lỗi này: `Localizable.xcstrings` có "Không thấy hộp thoại, hoặc đã chọn %@?", chép dấu phẩy của câu tiếng Anh "Don’t see the dialog, or chose %@?".

- Cách nhận ra: sau "và" không có chủ ngữ mới. Chủ ngữ của vế sau chính là chủ ngữ của vế trước.
- Ngoại lệ: vế sau rất dài hoặc có ngoặc, trạng ngữ chen giữa. Khi đó nên tách câu hơn là giữ dấu phẩy.
- Trước (`docs/canvas/src/ModelTonePlacement.dc.html`): "Dấu tự đặt dấu vào đúng chỗ theo chính tả, và dời dấu khi từ dài thêm."
- Sau: "Dấu tự đặt dấu vào đúng chỗ theo chính tả và dời dấu khi từ dài thêm."
- Trước (`CONTRIBUTING.md`): "Bạn hãy sửa `project.yml`, và không sửa hay commit `.xcodeproj`."
- Sau: "Bạn hãy sửa `project.yml` và không sửa hay commit `.xcodeproj`."

**A3. "được/bị V bởi X".** Tiếng Việt đặt tác thể ngay sau "được/bị" và trước động từ ("bị mẹ mắng"), không đẩy nó ra sau bằng "bởi" như "by" của tiếng Anh. CXH cho thấy khuôn này là áp ngữ pháp châu Âu lên câu tiếng Việt. Không có nguồn nào trong phần 1 nêu riêng chữ "bởi", nên lý do chính là trật tự từ.

- Cách sửa: chuyển tác thể lên ngay sau "được/bị" hoặc viết câu chủ động.
- Trước (`docs/history/LogM6.md`): "`known` không còn bị ghi đè bởi một `selectedRange` cũ"
- Sau: "một `selectedRange` cũ không còn ghi đè `known`"

**A4. Tiêu đề viết hoa kiểu Title Case.** MS và MOZ cùng nói tiếng Việt chỉ viết hoa chữ đầu và tên riêng. Repo hiện không có tiêu đề nào vi phạm, kể cả chuỗi giao diện tiếng Việt ("Gõ Nhanh" là tên app). Luật này giữ cho tiêu đề mới không chép cách viết hoa của bản tiếng Anh, vì [`docs/Glossary.md`](../Glossary.md) đòi Title Case cho nút và tiêu đề tiếng Anh.

**A5. Thì chồng.** Tiếng Việt chỉ dùng một trong "đã", "đang", "sẽ" và thường bỏ cả ba khi ngữ cảnh đã rõ thời gian (MS mục 4.1.17). Ghép hai từ chỉ thời ("đã đang", "sẽ đã") là dịch máy móc từ thì hoàn thành hay tiếp diễn của tiếng Anh. Repo không có chỗ nào như vậy. Điểm "không ghép" dựa trên đối chiếu ngữ pháp, MS không nói riêng.

### Mức (b): sai trong đa số trường hợp, cần đọc cả câu

**B1. Bị động thừa.** Câu tiếng Anh hay dùng bị động khi không cần nêu ai làm. Tiếng Việt thiên về đề–thuyết (CXH), nên đối tượng đứng đầu câu làm đề là đủ: "Nhà này xây năm 1990" là câu tự nhiên, không cần "được". MOZ và GEN khuyên đổi bị động thành chủ động. Ngoài ra, CXH2 dẫn Cao Xuân Hạo coi "được" và "bị" là động từ có nghĩa riêng (được là có lợi, bị là chịu thiệt). Vì vậy dùng "được" cho việc trung tính, nhất là việc bất lợi, nghe như văn dịch. Phần nghĩa lợi, hại này là suy luận từ CXH2, cần kiểm chứng với bản gốc.

- Khi vẫn đúng: "được" mang nghĩa "có thể" ("gõ được", "không đọc được"), "được" chỉ việc có lợi cho chủ ngữ hoặc câu cần nhấn mạnh rằng một việc do người khác làm.
- Cách sửa: bỏ "được" và để đối tượng làm đề. Khi biết ai làm và việc ai làm là thông tin quan trọng thì viết câu chủ động.
- Trước (`docs/Roadmap.md`): "Nhật ký của mốc đã được chuyển sang `docs/history/`."
- Sau: "Nhật ký của mốc đã chuyển sang `docs/history/`."
- Trước (`docs/Compatibility.md`): "Vì vậy hạn chờ được đặt là 20 ms (ngưỡng p99 của D42)"
- Sau: "Vì vậy hạn chờ là 20 ms (ngưỡng p99 của D42)"
- Trước (`docs/Glossary.md`): "Từ mới phải được thêm vào đây trước khi viết câu dùng nó."
- Sau: "Phải thêm từ mới vào đây trước khi viết câu dùng từ đó."

**B2. Danh hoá.** Tiếng Anh biến động từ thành danh từ ("the removal of", "-ing") để làm chủ ngữ. Tiếng Việt dùng thẳng động từ làm chủ ngữ hay bổ ngữ. MS mục 4.1.17 nói không cần thêm "việc". Repo không có "tiến hành" hay "thực hiện việc".

- Khi vẫn đúng: "việc" là danh từ chỉ công việc ("Việc này cần xong trước bản chính thức", "việc đang chờ"). Mẫu đếm đã loại phần lớn các chỗ này, nhưng còn khoảng một nửa số chỗ khớp là nghĩa "công việc".
- Cách sửa: bỏ "việc", "sự" hoặc viết lại để động từ làm vị ngữ.
- Trước (`docs/Glossary.md`): "Việc bỏ app khỏi danh sách nguồn luôn được viết đủ là "bỏ Dấu khỏi nguồn đầu vào"."
- Sau: "Khi nói tới bỏ app khỏi danh sách nguồn, luôn viết đủ là "bỏ Dấu khỏi nguồn đầu vào"."

**B3. "Nó", "Điều này", "Điều đó" mở câu.** MS mục 4.1.13 nói chủ ngữ giả "It" của tiếng Anh không dịch thành "Nó". Trong văn viết, câu tiếng Việt thường nhắc lại danh từ kèm "này" thay cho "nó" chỉ vật. "Điều này" mở câu là bản dịch của "This". Nhiều khi chủ ngữ thật của câu là một sự việc cụ thể hơn. Phần về văn viết là đối chiếu ngữ pháp, MS chỉ nói về chủ ngữ giả.

- Khi vẫn đúng: câu ngắn ngay sau câu có danh từ đó, khi nhắc lại danh từ làm câu nặng hơn.
- Trước (`docs/Releasing.md`): "Đường quảng bá (`promote-release.sh`) cũng chưa chạy thật. Nó cần một bản beta đã công bố trên GitHub…"
- Sau: "Đường quảng bá (`promote-release.sh`) cũng chưa chạy thật. Script này cần một bản beta đã công bố trên GitHub…"
- Trước (`docs/Compatibility.md`): "Điều này được phát hiện ở lượt đo D20 ngày 30/10/2026"
- Sau: "Lượt đo D20 ngày 30/10/2026 phát hiện lỗi này"

**B4. Ngoặc đơn dài chen giữa câu.** D44 cấm nhồi ý bằng ngoặc đơn chỉ để lấy ngắn. MS mục 4.1.14 nói phần trong ngoặc là lời chú thích, bỏ đi thì nghĩa không đổi. Một ngoặc dài hơn khoảng 50 ký tự thường chứa một ý riêng, nên nó nên thành câu riêng. Biểu thức đếm đã bỏ ngoặc chỉ chứa số D/N, mã hay đường dẫn.

- Khi vẫn đúng: ngoặc ghi điều kiện đo ngắn (máy, ngày, commit) đứng sát số đo hoặc ghi tên mã.
- Trước (`docs/README.md`): "Luật ghi thông tin (mỗi sự kiện chỉ ghi ở một chỗ, file nào cập nhật lúc nào) nằm ở…"
- Sau: "Luật ghi thông tin nằm ở… Luật đó quy định mỗi sự kiện chỉ ghi ở một chỗ và file nào cập nhật lúc nào."

**B5. Nhiều dấu hai chấm trong một câu.** D44 cấm nối các vế bằng dấu hai chấm. MS mục 4.1.14 chỉ dùng dấu hai chấm để mở một danh sách hay một lời dẫn. Khuôn "Nhãn: nội dung; nhãn: nội dung" là cách ghi chú của tài liệu tiếng Anh. Biểu thức đếm chặt nên chỉ bắt 7 chỗ trong tài liệu chính, còn `docs/history/` có 194 chỗ.

- Trước (`docs/research/OpenKeyNotes.md`): "Kiểu cũ: mặc định nguyên âm đầu; cụm ba nguyên âm hoặc cụm có phụ âm cuối hợp lệ: chữ thứ hai; cụm có ê, ơ: chữ đó."
- Sau: "Với kiểu cũ, dấu mặc định đặt ở nguyên âm đầu. Cụm ba nguyên âm và cụm có phụ âm cuối hợp lệ đặt dấu ở chữ thứ hai. Cụm có ê hay ơ đặt dấu ở chính chữ đó."

**B6. "đến từ".** VNE coi "đến từ" là cấu trúc tiếng Anh ("comes from"). Trong tài liệu kỹ thuật, cụm này thường thay cho "do… gây ra" hay "lấy từ".

- Trước (`docs/research/JetBrainsInput.md`): "lỗi D4 ở WebStorm đến từ JBR hay từ chỗ khác"
- Sau: "lỗi D4 ở WebStorm do JBR hay do chỗ khác gây ra"

### Mức (c): tuỳ ngữ cảnh, chỉ sửa khi câu nặng nề

**C1. Dấu phẩy trước "và/hoặc" nối hai vế có chủ ngữ riêng.** NPTV mục 5.3 cho phép giữ hay bỏ dấu phẩy giữa các vế câu ghép có kết từ. MS cấm dấu phẩy trước "và" mà không phân biệt, nhưng các ví dụ của MS đều là chuỗi liệt kê. Đây là phần lớn trong 426 chỗ của tài liệu chính. Mật độ cao cho thấy thói quen nối hai câu bằng ", và" của tiếng Anh. Theo D44, hai ý ngang hàng nên viết thành hai câu.

- Cách sửa đề xuất: vế nào là một ý riêng thì tách thành câu riêng. Hai vế ngắn và gắn chặt thì bỏ dấu phẩy. Chỉ giữ dấu phẩy khi bỏ nó làm người đọc ghép nhầm chủ ngữ của vế sau vào vế trước.
- Trước (`CONTRIBUTING.md`): "Dấu là phần mềm tự do theo giấy phép GPLv3 ([LICENSE](LICENSE)), và mọi đóng góp gửi vào repo cũng theo giấy phép này."
- Sau: "Dấu là phần mềm tự do theo giấy phép GPLv3 ([LICENSE](LICENSE)). Mọi đóng góp gửi vào repo cũng theo giấy phép này."

**C2. "là một".** MS mục 4.1.4 nói mạo từ "a" chỉ dịch khi nó mang nghĩa "một". Câu phân loại "X là một Y" vẫn tự nhiên trong tiếng Việt, nên phần lớn chỗ khớp không cần sửa. Chỉ bỏ "một" khi nó không thêm nghĩa và câu đã dài. Ví dụ "`advanced` là một enum" (`docs/Architecture.md`) đọc được cả hai cách.

**C3. "của" chồng nhiều tầng.** Câu như "bộ đệm của app thử và của Telegram" là tiếng Việt bình thường. Chỉ khi ba tầng "của" nối liền ("phần còn lại của việc đo lại của…") mới nên viết lại bằng định ngữ ghép hoặc tách câu. Mục này chưa có nguồn.

**C4. "Với X," mở câu.** "Với" có thể là bản dịch của "With" hay "For", nhưng "Với trình duyệt, …" vẫn là cách nêu đề quen thuộc của tiếng Việt. Chỉ đổi thành "Khi…", "Ở…" khi "Với" làm câu mơ hồ. Ví dụ trong `docs/Compatibility.md`, "Với hạn 20 ms, mỗi lần chờ…" rõ hơn khi viết "Khi hạn là 20 ms, mỗi lần chờ…". Mục này chưa có nguồn.

**C5. "sẽ được".** Đây thường là bị động tương lai dịch từ "will be". Chuỗi giao diện "Dấu sẽ được thêm vào nguồn đầu vào của macOS" đúng ngữ pháp. Muốn sửa thì sửa theo B1. Chuỗi giao diện sửa qua String Catalog và canvas theo D41 (Ngôn ngữ giao diện).

**C6. "Nếu…," không có "thì".** Cả hai dạng đều đúng. CXH cho thấy "thì" là dấu ranh giới đề–thuyết của tiếng Việt, nên người sửa không coi "thì", "là", "mà" là từ thừa và không xoá chúng hàng loạt.

**C7. Từ tiếng Anh chêm vào câu.** VNE và PRO khuyên dùng từ Việt khi đã có từ thông dụng, nhưng chấp nhận thuật ngữ công nghệ. Trong repo, thuật ngữ đã chốt ở [`docs/Glossary.md`](../Glossary.md) và tên giao diện của macOS (D38 (Chữ trên giao diện)) đứng trên mọi luật ở đây. Phần lớn chỗ khớp là nhãn tiếng Anh trích nguyên văn hoặc thuật ngữ ("GitHub issue", "input mode"), nên chỉ sửa từ chêm không có lý do, ví dụ "user" khi có "người dùng".

**C8. "các/những" thừa.** MOZ nói "Settings" là "Thiết lập", không phải "Các thiết lập". Tiêu đề như "Các hướng không chọn" (`docs/research/`) vẫn đọc được, nên chỉ bỏ "các" khi danh từ đã đủ nghĩa số nhiều.

**C9. "của bạn" và đại từ thừa.** PRO nói tiếng Việt cần ít đại từ, sở hữu hơn tiếng Anh. Repo chỉ có vài chỗ, phần lớn trong lời giao việc cho agent ("ngữ cảnh của bạn"), nơi đại từ có lý do.

**C10. "thất bại" trong câu báo lỗi.** MS mục 2.1.3 nói câu báo lỗi viết "Không lưu được hình ảnh" thay cho "Lưu hình ảnh thất bại". Trong văn kỹ thuật, "làm `enable()` thất bại" vẫn đúng nghĩa. Luật này nên áp chủ yếu cho chuỗi giao diện.

**C11. "trong khi", "khi mà".** MS mục 4.1.9 dùng "trong khi" cho "while" và "during". Repo dùng "trong khi" để đối lập hai việc ("…, trong khi Telex của Apple gõ đúng các từ đó"), một cách nói tự nhiên. Repo không có "khi mà".

**C12. "một cách" + tính từ, "bởi vì… nên".** Repo không có hai mẫu này. "Một cách" ghép trước tính từ để dịch đuôi "-ly" chưa có nguồn chính thức. Tiếng Việt đặt thẳng tính từ sau động từ ("chạy nhanh", "đọc kỹ"). Ví dụ của MS mục 4.1.7 viết lại câu "Bởi vì… nên…" thành "Nhờ… nên…".

## 4. Số đo theo nhóm tài liệu

Số đếm chạy ngày 22/11/2026 trên commit `970e581`. Bảng đếm số chỗ khớp, không phải số lỗi. Muốn ước số lỗi thì nhân với tỉ lệ "Đúng" ở phần 2.

| Mục | Tài liệu chính | `docs/research/` | `docs/history/` | Canvas | Chuỗi giao diện tiếng Việt | `.claude/` | Các `CLAUDE.md` |
|---|---|---|---|---|---|---|---|
| Mọi dấu phẩy trước "và/hoặc/hay" | 426 | 132 | 105 | 20 | 7 | 19 | 16 |
| A1. Chuỗi liệt kê | 42 | 10 | 4 | 1 | 0 | 2 | 1 |
| A2. Hai vị ngữ hoặc bổ ngữ | 94 | 17 | 21 | 7 | 4 | 2 | 7 |
| A3. "được/bị … bởi" | 0 | 0 | 1 | 0 | 0 | 0 | 0 |
| B1. "được + V" | 335 | 183 | 130 | 32 | 7 | 42 | 10 |
| B2. "việc", "sự" danh hoá | 44 | 16 | 13 | 0 | 0 | 3 | 7 |
| B3. "Nó", "Điều này" mở câu | 24 | 8 | 0 | 0 | 0 | 0 | 2 |
| B4. Ngoặc dài | 179 | 209 | 498 | 0 | 1 | 17 | 24 |
| B5. Nhiều dấu hai chấm | 7 | 57 | 194 | 19 | 2 | 1 | 0 |
| B6. "đến từ" | 2 | 5 | 3 | 0 | 0 | 0 | 0 |
| C2. "là một" | 31 | 16 | 4 | 2 | 0 | 1 | 1 |
| C3. "của" chồng | 14 | 9 | 11 | 1 | 0 | 1 | 1 |
| C4. "Với X," mở câu | 55 | 12 | 4 | 3 | 1 | 0 | 2 |
| C5. "sẽ được" | 8 | 0 | 0 | 4 | 2 | 0 | 0 |
| C6. "Nếu…," không "thì" | 106 | 24 | 16 | 6 | 3 | 7 | 0 |
| C7. Từ tiếng Anh chêm | 48 | 82 | 119 | 19 | 14 | 3 | 2 |
| C11. "trong khi" | 4 | 10 | 11 | 0 | 0 | 1 | 1 |

Các mẫu có số 0 ở mọi nhóm không nằm trong bảng: "tiến hành", "thực hiện việc", "một cách" + tính từ, "bởi vì", thì chồng, "là được/là bị/là sẽ" (một chỗ khớp trong `docs/history/` là "biết là bị từ chối", câu đúng) và tiêu đề Title Case.

Trong tài liệu chính, `docs/Decisions.md` có 126 chỗ dấu phẩy trước "và/hoặc/hay", nhiều nhất các file. Tiếp theo là `docs/Architecture.md` với 72 chỗ và `docs/Compatibility.md` với 48 chỗ.

### Cách đo lại

Lệnh dưới tạo một file văn bản cho mỗi nhóm, bỏ tiền tố tên file và số dòng, rồi đếm từng biểu thức. Canvas chỉ lấy dòng có chữ tiếng Việt sau khi bỏ thẻ HTML. Chuỗi giao diện chỉ lấy giá trị tiếng Việt trong String Catalog. Cần `rg` có PCRE2 và `jq`.

```zsh
D=$(mktemp -d); cd /path/to/dau
rg -N --no-filename . README.md CONTRIBUTING.md docs/*.md --glob '!docs/CLAUDE.md' > $D/main
rg -N --no-filename . docs/research -g '*.md' > $D/research
rg -N --no-filename . docs/history -g '*.md' > $D/history
for f in docs/canvas/src/*.dc.html; do sed -E 's/<[^>]*>/ /g' $f; done | rg '[à-ỹđ]' > $D/canvas
jq -r '.strings[] | .localizations.vi.stringUnit.value // empty' Apps/Dau/Resources/Localizable.xcstrings > $D/xcs
rg -N --no-filename . .claude -g '*.md' > $D/claude
cat CLAUDE.md docs/CLAUDE.md scripts/CLAUDE.md Apps/Dau/CLAUDE.md > $D/claudemd
# Đếm một biểu thức P trên một nhóm G:
rg --pcre2 -o -- "$P" $D/$G | wc -l
```

Các biểu thức, mỗi dòng gồm mã mục, một dấu tab và biểu thức:

```text
comma_all	,\s+(và|hoặc|hay)\s
A1	(?:^|[.;:(]\s|-\s|\*\*\s)([^,.;:\n]{1,40}),\s([^,.;:\n]{1,40}),\s(?:[^,.;:\n]{1,40},\s){0,4}(và|hoặc|hay)\s[^,.;:\n]{1,40}?(?=[.;:)\n]|$)
A2	,\s+(và|hoặc|hay)\s+(không|chưa|chỉ|có thể|cũng|vẫn|đã|sẽ|đang|mới|luôn|được|bị|là|có|gọi|ghi|đặt|dời|hiện|mở|chạy|thêm|bỏ|xoá|giữ|dùng|đọc|chờ|trả|đổi|khớp|cần|phải|tự|làm|cài|gõ|kiểm|đo|sửa|thay)\b
A3	\b(được|bị)\s[^.,;:\n]{1,40}\sbởi\b
A5	\b(đã đang|đã sẽ|sẽ đang|sẽ đã)\b
B1	(?<!không |chưa |gõ |làm |đọc |dùng |thay |sửa |cài |bật |chạy |ra |xoá |đo |giữ |đổi |mở |lấy |thấy |hiện |nhận |đúng |có |thì |là |nào |nên |phải |ai |sẽ |vẫn |cũng |đã )\bđược (?!không|nữa|rồi|$|\.|,)\p{Ll}+
B2	(?:\b(?:cho|thay cho|về|để|nhờ|vì|bằng|của|với|là|tránh|chấp nhận|cho phép) việc\b|(?:^|[.!?]\s|-\s|\*\*\s?)Việc \p{Ll})|\bsự (?!cố|kiện|thật|việc|khác|thể)\p{Ll}+|\b(tiến hành|thực hiện việc)\b
B3	(?:^|[.!?]\s|-\s|\*\*\s?)(Nó|Điều này|Điều đó)\b
B4	\((?![DN]\d|`|http)[^)\n]{50,}\)
B5	^(?!\s*[|#])(?:[^:`\n]*:\s){2,}
B6	\bđến từ\b
C2	\blà một (?!lần|số|phần|trong|cách|chỗ)\p{Ll}+
C3	\bcủa\s[^.,;:()\n]{1,25}\scủa\b
C4	(?:^|[.!?]\s|-\s|\*\*\s?)Với [^,\n]{1,40},
C5	\bsẽ được\b
C6	\b[Nn]ếu\b(?:(?!\bthì\b)[^.;:\n])*,
C7	(?<![`\w/.-])(?i:user|feature|default|fix|support|issue|workaround|fallback|edge case|use case|setting|check|update|flow|step|output|input)(?![`\w/.-])
C11	\btrong khi\b
C12	\bmột cách (?!khác|để|gõ|làm|sửa|duy nhất|nào|vá)\p{Ll}+|\bbởi vì\b
```

Tỉ lệ "Đúng" ở phần 2 đến từ việc xem tay mười mẫu hoặc toàn bộ số mẫu khi có ít hơn mười, lấy rải đều trong tài liệu chính và `docs/research/`. Mục A1 xem 30 mẫu, đúng 19. Mục A2 xem 16 mẫu, đúng 6. Mục B1 xem 13 mẫu, đúng 9.

## 5. Giới hạn

- Biểu thức tìm chỉ là bộ lọc thô. Mẫu A2 không phân biệt được chủ ngữ mới bắt đầu bằng động từ tồn tại ("và không có lệnh…") với vị ngữ chung chủ ngữ, nên mỗi chỗ cần người đọc. Số "khoảng 290" của C1 là phép trừ, không phải số đếm trực tiếp.
- Canvas đếm theo dòng sau khi bỏ thẻ, nên một câu trải trên nhiều thẻ có thể bị tách hoặc bị bỏ sót.
- Mục B1 dựa trên lập luận đề–thuyết của Cao Xuân Hạo qua hai nguồn thứ cấp. Ý "được là có lợi, bị là chịu thiệt" là suy luận, cần kiểm chứng với bản gốc. Chính MS vẫn dùng bị động trong ví dụ tiếng Việt ("Địa chỉ website sẽ được gửi cho Microsoft"), nên B1 không phải luật cấm tuyệt đối.
- Các mục C3, C4, C12 ("một cách") và quy tắc đổi cấu trúc ở ngoại lệ của A1 chưa có nguồn chính thức. Chúng chỉ dựa trên đối chiếu ngữ pháp.
