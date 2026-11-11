# Sửa chữ khi gõ: người gõ sửa thế nào, Dấu hỏng ở đâu và vì sao

Người gõ tiếng Việt sửa chữ theo nhiều cách: đổi dấu trong từ đang gõ, ⌫ về từ vừa gõ để thêm dấu, dùng mũi tên vào giữa một từ cũ, xoá cả từ gõ lại. File này lập ma trận các cách sửa đó thành chuỗi phím có đáp án, ghi Dấu hôm nay ra gì (mô phỏng offline), gom các chỗ hỏng theo nguyên nhân, và nêu các hướng sửa cùng xung đột của từng hướng. Không chọn thiết kế; quyết định thuộc [`docs/Decisions.md`](../Decisions.md).

## Hiện trạng (11/11/2026)

- **Trong từ đang gõ, Dấu sửa tốt.** Đổi dấu, bỏ dấu, đặt dấu ở cuối hay giữa từ (D28 (Bỏ dấu tự do)), gõ nhầm chữ rồi ⌫, chữ thừa làm sai chính tả rồi ⌫ trước dấu cách: đúng ở 15/21 ca. Sáu ca hỏng do ba luật: khoá gõ đúp còn sau ⌫ (D26 (Gõ đúp phím dấu)), từ quá 7 chữ không quay lại (D33 (Độ dài từ)), và mốc khôi phục sau ⌫ là chữ đang hiện (D32 (Backspace)).
- **Lỗi lớn nhất: từ đã bị khôi phục thì không sửa lại được (nguyên nhân K1, 12 ca).** Khi kết thúc từ, D4 (Từ nước ngoài) trả từ không hợp lệ về đúng phím đã gõ ("ddungsg"); từ đó mọi cách sửa đọc chữ đó như chữ cái (D20 (Thêm dấu cho từ đã gõ)), nên phím dấu đi thẳng ("ddungss"). Nhóm hay gặp nhất với người mới: **từ vần tắc quên dấu thanh** ("đep", "viêt", "tôt", "đươc") không hợp lệ theo D31 (Âm tiết tiếng Việt hợp lệ), bị khôi phục thành "ddep", "vieet", rồi ⌫ thêm `j` ra "ddepj".
- **Từ tiếng Anh gõ nhầm một chữ rồi ⌫ trong từ bị hỏng (K3).** D32 đặt mốc khôi phục là chữ đang hiện, mà chữ đang hiện của từ tiếng Anh là chữ Telex dở ("ưindows"). Đo trên 381 từ tiếng Anh mà Dấu giữ nguyên khi gõ thẳng: thêm một chữ thừa rồi ⌫ thì 93 từ hỏng ("with" → "ưith", "deep" → "dêp", "server" → "sẻver"). Trái mục tiêu "từ tiếng Anh vẫn phải sống" của D4 và chưa ghi trong hệ quả của D32.
- **Chế độ gạch chân không có cách sửa nào sau khi từ đã chốt (K7).** Trong từ, gạch chân sửa như thay tại chỗ (bỏ dấu tự do vẫn chạy). Mọi cách sửa sau dấu cách hay sau mũi tên mà thay tại chỗ làm được (31 ca) đều hỏng ở gạch chân, vì D20 không chạy ở chế độ đó (D13 (Gạch chân là đường lui cuối cùng)). Telex của Apple cũng vậy (đã đo ở Sublime Text và Notes). Đây là điều người dùng gạch chân gặp khi nói "không bỏ dấu tự do được".
- **Hướng hứa hẹn nhất** (mục 4):
  - H1, nhớ phím của từ vừa khôi phục. Sửa 9 ca K1; kết quả luôn bằng kết quả gõ liền chuỗi phím đã sửa, nên không từ tiếng Anh nào ra tệ hơn khi gõ thẳng. Phải đổi ý "không giữ lịch sử từ" của D20.
  - H4, mốc khôi phục sau ⌫ theo phím thay vì theo chữ đang hiện. Sửa K3 (93/381 từ tiếng Anh). Phải đổi D32.
  - H3, đọc chữ như chuỗi phím khi đọc như chữ cái không hợp lệ. Sửa cả sau mũi tên và click, nhưng làm đổi 90 cặp từ tiếng Anh và phá ví dụ "carr → car, rồi s → cars" của D20.
- **Cần đo thật:** chọn cả từ rồi gõ lại; vị trí con trỏ sau khi thay cả từ quanh con trỏ (H7); và nhịp ⌫ rồi phím dấu của người gõ nhanh so với ngưỡng 50 ms của D20 (mục 5).

## 1. Hồ sơ người gõ

Bốn hồ sơ dùng để gắn nhãn kịch bản và cho mô phỏng sau. Số đo lấy từ Dhakal và cộng sự, "Observations on Typing from 136 Million Keystrokes", CHI 2018 (bảng 3; DOI 10.1145/3173574.3174220): 168.000 người gõ chép câu tiếng Anh trong trình duyệt. Tỉ lệ thay, bỏ sót, thừa chữ tính trên mẫu 783 người. Bài báo đo người gõ tiếng Anh, không có Telex; chỗ nào nói về Telex là giả định.

| Hồ sơ | Số đo từ bài báo | Thói quen sửa giả định cho tiếng Việt |
|---|---|---|
| **M** — người mới học gõ | Nhóm chậm (10% chậm nhất, dưới khoảng 26 WPM): 20,9 WPM; khoảng cách giữa hai phím trung bình 481 ms; phím xoá chiếm 9,05% số phím; gõ thay chữ 3,72%, bỏ sót 1,29%, thừa 0,80%; gõ chồng phím 7,6%. | Giả định: hay quên dấu thanh hay mũ/móc rồi sửa sau dấu cách hoặc sau cả câu; kỳ vọng ⌫ bỏ dấu chứ không bỏ chữ; ít dùng bỏ dấu tự do. |
| **T** — người gõ thường | Toàn bộ: 51,6 WPM; 239 ms; phím xoá 6,31%; lỗi để lại 1,17%; 1,17 phím mỗi ký tự; gõ chồng phím 25%. | Giả định: sửa ngay trong từ hoặc ⌫ qua dấu cách; đôi khi mũi tên hay click để sửa từ cũ. |
| **Đ** — người gõ điêu luyện | Không có nhóm tương ứng. Gần nhất là người đã học gõ: 54,4 WPM, 224 ms, phím xoá 5,90%. | Giả định: bỏ dấu tự do (dấu cuối từ, đổi dấu bằng phím dấu khác), sửa ngay bằng ⌫, gõ đúp phím dấu để giữ chữ gốc. |
| **N** — người gõ rất nhanh | Nhóm nhanh (10% nhanh nhất, trên khoảng 78 WPM): 89,6 WPM; 122 ms (độ lệch chuẩn 12 ms); phím xoá 3,40%; lỗi để lại 0,71%; thay chữ 0,84%, bỏ sót 0,49%, thừa 0,50%; gõ chồng phím 49,9% (phần lớn 40–70%), hai phím chồng nhau trung bình 30 ms, tới 100 ms. Cận dưới khoảng cách giữa hai phím của mọi người: khoảng 60 ms. | Giả định: ⌫ và phím sửa đi liền nhau; đôi khi phím nảy (gõ đúp vô ý). |

- **Ngược với giả định ban đầu:** bài báo cho thấy người gõ nhanh có **ít** lỗi thừa và bỏ sót chữ hơn người gõ chậm, tính theo ký tự. Số lỗi mỗi phút không có trong bài.
- **Không có trong bài:** tỉ lệ cặp phím cách nhau dưới 10 ms. Cách đo trong trình duyệt chỉ chính xác khoảng 10–15 ms ([`docs/research/CompetitorComparison.md`](CompetitorComparison.md) mục 3). Khoảng cách từ ⌫ tới phím kế tiếp cũng không có. Hai số này là giả định.
- **Phím xoá là phím thường dùng:** 3–9% số phím tuỳ nhóm. Bài báo ghi thêm rằng người gõ có thể chọn bằng chuột hay mũi tên để xoá nhiều chữ một lần, và nhật ký không cho biết điều đó xảy ra bao nhiêu.

## 2. Ma trận kịch bản

Cấu hình mặc định D15 (Cài đặt mặc định): Telex, kiểu mới, bỏ dấu tự do, tự khôi phục, thêm dấu cho từ đã gõ.

Ký hiệu:
- `␣` dấu cách, `⌫` xoá lùi, `←` `→` mũi tên (con trỏ dời một chữ), `⌥⌫` xoá cả từ, `⏎` Return. Phím cách nhau 200 ms trừ khi ghi khác.
- `‸` là vị trí con trỏ khi nó không ở cuối.
- Cột "Gạch chân" là chữ sau khi từ được chốt.
- Hồ sơ: M, T, Đ, N theo mục 1.
- Nguyên nhân: mã K ở mục 3; ✓ là đúng mong muốn.

### A. Trong từ đang gõ

| Mã | Phím | Mong muốn | Dấu hôm nay | Gạch chân | Hồ sơ | Nguyên nhân |
|---|---|---|---|---|---|---|
| A1 | `tooisf␣` | tồi | tồi | tồi | T Đ | ✓ đổi dấu |
| A2 | `bansf␣` | bàn | bàn | bàn | T Đ | ✓ |
| A3 | `masz␣` | ma | ma | ma | T Đ | ✓ bỏ dấu |
| A4 | `toosiz␣` | tôi | tôi | tôi | Đ | ✓ |
| A5 | `ddusng␣` | đúng | đúng | đúng | Đ | ✓ dấu giữa từ (D28) |
| A6 | `tiengse␣`, `tisenge␣` | tiếng | tiếng | tiếng | Đ | ✓ mũ sau dấu |
| A7 | `truongwf␣` | trường | trường | trường | Đ | ✓ |
| A8 | `nhaq⌫f␣` | nhà | nhà | nhà | M T N | ✓ gõ nhầm chữ rồi ⌫ |
| A9 | `ddeo⌫pj␣` | đẹp | đẹp | đẹp | M T N | ✓ |
| A10 | `vieetk⌫j␣` | việt | việt | việt | M T N | ✓ |
| A11 | `ddungsg⌫␣` | đúng | đúng | đúng | T N | ✓ chữ thừa, ⌫ trước dấu cách (D30 (Kiểm tra chính tả) tính lại) |
| A12 | `nhuwngg⌫x␣` | những | những | những | T N | ✓ |
| A13 | `ddooiwf␣` | đời | đời | đời | Đ | ✓ đổi mũ thành móc (D28) |
| A14 | `tieeng⌫⌫⌫eengs␣` | tiếng | tiếng | tiếng | M T | ✓ |
| A15 | `tooisf␣`, phím cách nhau 8 ms | tồi | tồi | tồi | N | ✓ |
| A16 | `nhaamff⌫f␣` (phím f nảy) | nhầm | nhâmf | nhâmf | N M | K4 |
| A17 | `bass⌫s␣` (phím s nảy) | bá | bas | bas | N M | K4 |
| A18 | `nghieengg⌫␣` | nghiêng | nghieeng | nghieeng | T N | K5 |
| A19 | `bans⌫f␣` (tưởng ⌫ bỏ dấu) | bàn | bà | bà | M | K6 |
| A20 | `windoes⌫⌫ws␣` | windows | ưindows | ưindows | T N | K3 |
| A21 | `Sunrisr⌫e␣` | Sunrise | Sủnise | Sủnise | T N | K3 |

Đo thêm cho K3 trên 381 từ tiếng Anh mà Dấu giữ nguyên khi gõ thẳng (danh sách ở phụ lục):
- Gõ thêm một chữ thừa rồi ⌫ trong từ: 93 từ hỏng.
- Gõ sai chữ cuối, ⌫, gõ lại chữ đúng: 91 từ hỏng.
- Ví dụ: "with" → "ưith", "good" → "gôd", "keep" → "kêp", "text" → "tẽt", "server" → "sẻver", "where" → "ưhere".
- `keyboarf⌫d␣` đúng ("keyboard"), vì từ quá 7 chữ đi theo D33, không qua D32.

### B. Ngay sau khi kết thúc từ, ⌫ quay lại

| Mã | Phím | Mong muốn | Dấu hôm nay | Gạch chân | Hồ sơ | Nguyên nhân |
|---|---|---|---|---|---|---|
| B1 | `ban␣⌫f␣` | bàn | bàn | banf | M T | ✓ / K7 |
| B2 | `bans␣⌫f␣` | bàn | bàn | bánf | M T | ✓ / K7 |
| B3 | `bans␣⌫z␣` | ban | ban | bánz | M T | ✓ / K7 |
| B4 | `Ban␣⌫f␣` | Bàn | Bàn | Banf | M T | ✓ / K7 |
| B5 | `ban.⌫f.` | bàn. | bàn. | banf. | M T | ✓ / K7 |
| B6 | `ban⏎⌫f` | bàn | bàn | banf | M T | ✓ / K7 |
| B7 | `viet␣⌫ej␣` | việt | việt | vietẹ | M T | ✓ / K7 |
| B8 | `cow␣⌫o␣` | cô | cô | cơo | M T | ✓ / K7 |
| B9 | `nguoi␣⌫wf␣` | người | người | nguoiừ | M | ✓ / K7 |
| B10 | `duong␣⌫w␣` | dương | dương | duongư | M | ✓ / K7 |
| B11 | `thuongw␣⌫f␣` | thường | thường | thươngf | M T | ✓ / K7 |
| B12 | `vieejt␣⌫s␣` | viết | viết | việts | T | ✓ / K7 |
| B13 | `khoongf␣⌫z␣` | không | không | khồngz | T | ✓ / K7 |
| B14 | `chaos␣⌫f␣` | chào | chào | cháof | T | ✓ / K7 |
| B15 | `nhaamff␣⌫⌫f␣` | nhầm | nhầm | nhâmf | N | ✓ / K7 |
| B16 | `duow␣⌫cj␣` | dược | dược | duơcj | M | ✓ / K7 |
| B17 | `hoc␣⌫j␣` | học | học | hocj | M T | ✓ / K7 |
| B18 | `hocf␣⌫⌫j␣` | học | học | hocj | M | ✓ / K7 |
| B19 | `muoon␣⌫s␣` | muốn | muốn | muôns | M | ✓ / K7 |
| B20 | `cach␣⌫s␣` | cách | cách | cachs | M | ✓ / K7 |
| B21 | `nhanf␣⌫⌫␣` | nhà | nhà | nhà | T N | ✓ |
| B22 | `toi␣di␣hoc␣⌫j␣` | học | học | hocj | M | ✓ / K7 |
| B23 | `viet␣⌫j␣` | việt | vietj | vietj | M | K8 |
| B24 | `ddep␣⌫j␣` | đẹp | ddepj | ddepj | M | K1 (quên dấu, vần tắc) |
| B25 | `vieet␣⌫j␣` | việt | vieetj | vieetj | M | K1 |
| B26 | `toot␣⌫s␣` | tốt | toots | toots | M | K1 |
| B27 | `dduwowc␣⌫j␣` | được | dduwowcj | dduwowcj | M | K1 |
| B28 | `hocf␣⌫j␣` | học | hocfj | hocfj | M | K1 (đổi dấu trên từ đã khôi phục) |
| B29 | `ddungsg␣⌫⌫␣` | đúng | ddungs | ddungs | T N | K1 (chữ thừa) |
| B30 | `ddungsg␣⌫⌫s␣` | đúng | ddungss | ddungss | T N | K1 (ca người dùng báo) |
| B31 | `ddungsg␣⌫⌫⌫s␣` | đúng | ddungs | ddungs | T N | K1 |
| B32 | `nghieengg␣⌫⌫␣` | nghiêng | nghieeng | nghieeng | T N | K5, K1 |
| B33 | `ban␣⌫f␣`, phím cách nhau 30 ms | bàn | banf | banf | N | K9 |
| B34 | `ban␣⌫` nghỉ 1,2 s rồi `f␣`, phím 30 ms | bàn | bàn | banf | N | ✓ / K7 |
| B35 | `hoc␣`, hệ thống sửa thành "học", `⌫j␣` | học | học | — | M T | ✓ (D20 "Từ hệ thống vừa sửa") |
| B36 | `cat␣`, hệ thống sửa thành "cắt", `⌫s␣` | cát | căts | — | M T | K10 |

### C. Quay xa hơn: nhiều ⌫, mũi tên, click

Click và mũi tên đi cùng một đường trong bộ gõ (reset, D4), nên một dòng mũi tên đại diện cho cả click ở cùng chỗ.

| Mã | Phím | Mong muốn | Dấu hôm nay | Gạch chân | Hồ sơ | Nguyên nhân |
|---|---|---|---|---|---|---|
| C1 | `ban␣awn␣⌫⌫⌫⌫f␣awn␣` | bàn ăn | bàn ăn | banf ăn | M T | ✓ / K7 |
| C2 | `ban␣awn←←←←f` | bàn ăn | bàn ăn | bafn ăn | M T | ✓ / K7 |
| C3 | `tooi←s` | tối | tố‸i | tôsi | T | ✓ / K7 |
| C4 | `tooif←s` | tối | tố‸i | tồsi | T | ✓ / K7 |
| C5 | `tieng←←e→→s` | tiếng | tiếng | tieengs | M | ✓ / K7 |
| C6 | `muon←os` | muốn | muố‸n | muoón | M | ✓ / K7 |
| C7 | `hoan←s` | hoán | hoá‸n | hoasn | M | ✓ / K7 |
| C8 | `nguoi←wf` | người | nguờ‸i | nguoừi | M | K11 / K7 |
| C9 | `duong←←w` | dương | duơ‸ng | duoưng | M | K11 / K7 |
| C10 | `ddungsg␣laf←←←⌫` | đúng là | ddungs‸ là | ddungs là | T N | K1 |
| C11 | `ddungsg␣laf←←←⌫s` | đúng là | ddungss‸ là | ddungss là | T N | K1 |
| C12 | `tooi←s`, phím cách nhau 30 ms | tối | tôs‸i | tôsi | N | K9 (ít gặp: mũi tên rồi phím dấu dưới 50 ms) |

### D. Xoá cả từ rồi gõ lại (mốc phải giữ đúng)

| Mã | Phím | Mong muốn | Dấu hôm nay | Gạch chân | Hồ sơ | Nguyên nhân |
|---|---|---|---|---|---|---|
| D1 | `ddungsg␣⌥⌫ddungs␣` | đúng | đúng | đúng (theo mã) | mọi hồ sơ | ✓ |
| D2 | `toi␣ddungsg⌥⌫ddungs␣` | toi đúng | toi đúng | toi đúng (theo mã) | mọi hồ sơ | ✓ |
| D3 | `ddungsg␣` rồi 8 lần ⌫, `ddungs␣` | đúng | đúng | đúng | M T | ✓ |
| D4 | `ddungsg␣` rồi 6 lần ⌫ (còn "dd"), `ungs␣` | đúng | ddungs | ddúng | M T | K1 ("dd" đọc như chữ cái) |
| D5 | Bấm đúp chọn từ, gõ lại | từ mới | cần đo thật | cần đo thật | mọi hồ sơ | — |

D5: theo mã, D20 không gieo khi có vùng chọn và phím đầu bắt đầu từ mới, nên dự đoán là đúng. Đồ giả hiện có không mô phỏng được app thay vùng chọn bằng phím đi thẳng.

### E. Gạch chân và ô bỏ qua vùng thay chữ

- **Gạch chân (D13):**
  - Cột "Gạch chân" ở các bảng trên. Trong từ (nhóm A), kết quả trùng thay tại chỗ, vì `MarkedComposer` áp cùng `Action` của engine.
  - Sau khi từ đã chốt: mọi ca thay tại chỗ sửa được ở nhóm B, C đều hỏng (K7).
  - Telex của Apple cũng hỏng ở đây. Đã đo `tooisf ba ⌫j tooi←s`: Dấu thay tại chỗ ra "tồi bạ tối", Dấu gạch chân và Telex của Apple ra "tồi baj tôsi"; Notes `tieeng←→s` ra "tiêngs" ([`docs/research/TerminalAndUnderline.md`](TerminalAndUnderline.md) mục 3, nhật ký [`docs/Progress.md`](../Progress.md) 11/11).
- **Ô bỏ qua vùng thay chữ (D43 (Ô bỏ qua vùng thay chữ)):**
  - Theo D43, sau khi nhận ra ô, D20 và lần dựng lại của D11 (Kiểm tra ngữ cảnh) không chạy. Vì vậy nhóm A như thay tại chỗ, còn nhóm B, C hỏng như gạch chân (suy luận từ mã, chưa chạy đồ giả cho từng ca).
  - Trước khi nhận ra ô, từ đầu tiên có thể sai.
  - Terminal của Apple không chuyển phím ⌫ cho bộ gõ, nên ⌫ trong từ không qua D32 ([`docs/Architecture.md`](../Architecture.md) mục "Thêm dấu cho từ đã gõ").

### F. Từ tiếng Anh và mã (kiểm hướng sửa không làm hỏng)

| Mã | Phím | Mong muốn | Dấu hôm nay | Gạch chân | Hồ sơ | Nguyên nhân |
|---|---|---|---|---|---|---|
| F1 | `test␣` | tét (D4: tiếng Việt thắng) | tét | tét | T | ✓ theo D4 |
| F2 | `tesst␣` | test | test | test | T Đ | ✓ |
| F3 | `test␣⌫⌫st␣` | test | test | tést | T | ✓ / K7 |
| F4 | `windoes␣⌫⌫⌫ws␣` | windows | windows | windoứ | T | ✓ / K7 |
| F5 | `carr␣⌫s␣` | cars | cars | cars | Đ | ✓ (ví dụ của D20) |
| F6 | `windows␣⌫⌫␣` | window | window | window | T | ✓ |
| F7 | `bosss␣⌫y␣` | bossy | bossy | bossy | Đ | ✓ |
| F8 | `teh␣⌫⌫⌫he␣` | the | the | the | T N | ✓ |
| F9 | `functon←←i` | function | functi‸on | function | T | ✓ |
| F10 | `taxxi␣` | taxi | taxi | taxi | Đ | ✓ (`taxi␣` ra "tãi" theo D4) |

Số ca theo kết quả, thay tại chỗ, không tính D5:
- Đúng 59, hỏng 24 (A: 6, B: 12, C: 5, D: 1). Riêng K3 có thêm số đo 93/381 từ tiếng Anh.
- Gạch chân thêm 31 ca hỏng (K7).

## 3. Nguyên nhân

| Mã | Nguyên nhân | Quyết định | Số ca hỏng | Ca |
|---|---|---|---|---|
| K1 | Từ đã bị D4 khôi phục (hay chữ đang hiện dạng phím Telex) không đọc lại được như phím: D20 đọc chữ cái, mà chữ cái đó không hợp lệ nên vào ngoại lệ (b), phím đi thẳng. Gồm từ vần tắc quên dấu thanh (D31 cho là không hợp lệ, nên D4 khôi phục "đep" thành "ddep") và từ có chữ thừa. | D4 (mốc khôi phục), D20 (đọc chữ cái; không giữ lịch sử từ; ngoại lệ (b)), D31, D30 | 12 | B24–B32, C10, C11, D4 |
| K3 | Sau ⌫ trong từ, mốc khôi phục là chữ đang hiện. Với từ tiếng Anh đã khoá chính tả, chữ đó là chữ Telex dở, nên kết thúc từ "khôi phục" về chữ dở. | D32, D4 (mốc) | 2 ca + 93/381 từ | A20, A21 |
| K4 | Khoá gõ đúp còn tới hết từ, kể cả khi ⌫ đã xoá chữ của phím đúp. | D26 | 2 | A16, A17 |
| K5 | Quá 7 chữ thì khôi phục ngay và đi thẳng; ⌫ về 7 chữ không trở lại. | D33 | 2 | A18, B32 |
| K6 | ⌫ xoá chữ cuối, không xoá dấu thanh (người mới có thể chờ ⌫ bỏ dấu; kỳ vọng này là giả định). | D32 | 1 | A19 |
| K7 | Gạch chân không có D20: không hỏi vị trí con trỏ nên không thay được chữ đã chốt. | D13, D20 (phạm vi), N3 (Ít lời gọi vào ứng dụng đích) | 31 | các ô "/ K7" |
| K8 | D20 không tự thêm mũ/móc để từ thành hợp lệ. | D20, "Đã biết nhưng không làm" | 1 | B23 |
| K9 | D20 chỉ đọc khi phím trước cách ít nhất 50 ms. | D20, D11 | 2 | B33, C12 |
| K10 | Tự sửa chính tả của macOS đổi từ thành chữ khác kết quả của phím. | D4 (giới hạn đã biết), D20 | 1 | B36 |
| K11 | D20 chỉ đọc phần trước con trỏ; dấu móc hay vị trí dấu cần cả từ ("nguo‸i" + w, "duo‸ng" + w ra "uơ" của D35 ("uơ" và "ươ")). | D20 (phạm vi), D35 | 2 | C8, C9 |

Không có ca nào hỏng vì reset khi dời con trỏ hay vì ⌫ qua nhiều từ (C1–C7 đúng). Ở nhóm C, chỉ có K1 (từ đã khôi phục) và K11 làm hỏng.

## 4. Hướng sửa và xung đột

Mỗi hướng ghi số ca nó sửa trong ma trận, và các đầu vào mà nó và một luật đang có cho kết quả trái nhau (bảng kiểm chéo theo [`CLAUDE.md`](../../CLAUDE.md) mục "Quy tắc làm việc"). Số từ tiếng Anh đo trên danh sách ở phụ lục bằng engine thật (mục 6). Chưa chọn hướng nào.

### H1. Nhớ phím của từ vừa khôi phục (K1)

Khi D4 khôi phục một từ, bộ gõ nhớ chuỗi phím của từ đó, cùng loại với `produced` của D20 "Từ hệ thống vừa sửa". ⌫ qua ranh giới từ rồi vào trong từ thì sửa trên chuỗi phím. Khi chuỗi phím đã sửa cho ra âm tiết hợp lệ, từ được viết lại theo cách đọc tiếng Việt, ngay ở phím ⌫ hay phím dấu đó; không thì giữ chữ đang hiện. Trước khi viết lại, so chữ đọc được với chữ đã trả, như "Từ hệ thống vừa sửa".

- **Sửa:** B24–B31, D4 (9 ca). C10, C11 chỉ khi bộ nhớ sống qua mũi tên; theo D4 hiện tại thì không.
- **Tiếng Anh:** kết quả luôn bằng kết quả gõ liền chuỗi phím đã sửa, nên không từ nào ra tệ hơn khi gõ thẳng. Đo: "windows␣⌫⌫␣" vẫn ra "window". Không chép mốc theo chữ hiện của D32: 93 từ ở K3 hỏng chính vì điều đó.
- **N3:** viết lại ở ⌫ cần một `selectedRange` và một `insertText`, như ⌫ của D32 đã có. Lần đọc để so là lần đọc D20 sẵn có.

| Đầu vào | Hôm nay | H1 | Bên nên thắng |
|---|---|---|---|
| `ddep␣⌫j␣` | ddepj | đẹp | H1 (tiếng Việt thắng, D4) |
| `ddungsg␣⌫⌫` | ddungs | đúng (hiện ngay khi xoá g) | H1 |
| `boot␣⌫s␣` | boots | bốt (như gõ liền `boots`) | theo D4 là H1; người gõ muốn "boots" phải gõ đúp như mọi từ trùng |
| `carr␣⌫s␣` | cars | cars (chuỗi phím `carrs`) | như nhau |
| `ddungsg␣⌫⌫s␣` | ddungss | đungs (gõ đúp bỏ dấu, D26) | không rõ: người gõ thấy "đúng" từ ⌫ thứ hai nên ít khi gõ s |

- **Phải đổi:** D20 "Không giữ lịch sử từ" (nhớ đúng một từ, như "Từ hệ thống vừa sửa"); D4 mốc khôi phục; tuỳ phạm vi, D4 "mũi tên, click chỉ reset".

### H2. Không khôi phục từ vần tắc chỉ thiếu dấu thanh (một phần K1)

Kết thúc từ mà từ là tiền tố hợp lệ, chỉ thiếu sắc hay nặng trên vần tắc ("đep"), thì giữ chữ đang hiện.

- **Sửa:** B24–B27 (4 ca).
- **Tiếng Anh:** tới 13/381 từ đang giữ nguyên sẽ ra chữ tiếng Việt dở ("boot" → "bôt", "meet" → "mêt", "keep" → "kêp", "deep" → "dêp", "text" → "tẽt", "next" → "nẽt").
- **Phải đổi:** D4, D31 (chữ ra không phải âm tiết hợp lệ). Không đề xuất: hỏng tiếng Anh nhiều mà sửa ít hơn H1.

### H3. D20 đọc chữ như chuỗi phím khi đọc như chữ cái không hợp lệ (K1, không cần nhớ)

Từ đọc được toàn chữ ASCII mà không là tiền tố hợp lệ: thử đọc nó như chuỗi phím Telex; ra tiền tố hợp lệ thì dùng cách đọc đó.

- **Sửa:** B24–B28, B31, D4 (7 ca), cả sau mũi tên và click. Không sửa B29 (không có phím nào kích hoạt lần đọc), B30 và C11 (đọc "ddungs" như phím ra "đúng", phím s sau đó là gõ đúp bỏ dấu).
- **Tiếng Anh:** chữ tiếng Anh có sẵn (gõ bằng U.S., dán vào, hay từ gõ đúp) cộng một phím dấu thì đổi. Trên 507 từ, 90 cặp "từ thiếu chữ cuối + phím cuối" ra chữ khác từ gốc ("boot" + s → "bốt", "set" + s → "sét").
- **Phá ví dụ của D20:** "car" (từ `carr`) rồi click về, gõ s, ra "cá" thay vì "cars".
- **Phải đổi:** D20 (đọc chữ cái, không như chuỗi phím). Giới hạn H3 vào từ Dấu vừa khôi phục thì thành H1.

### H4. Mốc khôi phục sau ⌫ theo phím (K3)

⌫ bỏ chữ cuối đang hiện như D32. Mốc khôi phục thì bỏ phím chữ cái cuối ứng với chữ đó, thay vì lấy chữ đang hiện làm mốc. Mốc chỉ dùng khi từ không hợp lệ lúc kết thúc, nên từ tiếng Việt hợp lệ không đổi.

- **Sửa:** A20, A21 và 93/381 từ tiếng Anh ("with", "good", "server"…).
- **Rủi ro:** lý do của D32 là tránh lệch hai bộ đệm như OpenKey (B12 trong [`docs/research/OpenKeyNotes.md`](OpenKeyNotes.md)). Cần một ánh xạ chữ → phím, và test fuzz D18 (Phòng thủ với IMK) phải phủ ánh xạ đó.
- **Phải đổi:** D32 ("mốc là chữ đang hiển thị"), D4 (mốc sau Backspace).

| Đầu vào | Hôm nay | H4 | Bên nên thắng |
|---|---|---|---|
| `withq⌫␣` | ưith | with | H4 |
| `tesst⌫s␣` | tess (khoá D26) | tess | như nhau |
| `ddungsg⌫␣` | đúng | đúng | như nhau (từ hợp lệ, không khôi phục) |

### H5. ⌫ xoá chữ của phím đúp thì mở khoá D26 (K4)

- **Sửa:** A16, A17 (2 ca), phím nảy ở người gõ nhanh.
- **Xung đột:** D26 ghi rõ khoá giữ cả sau Backspace ("tesst" ⌫ s → "tess"); H5 cho "tes" + s → "tés"; OpenKey làm như H5 (bảng mục 4 của [`docs/research/OpenKeyNotes.md`](OpenKeyNotes.md)).
- **Phải đổi:** D26.

### H6. ⌫ về 7 chữ thì trở lại biến đổi (K5)

Chỉ khi chuỗi phím còn lại là tiền tố hợp lệ, nên "keyboar" vẫn đi thẳng.

- **Sửa:** A18, B32 (2 ca, B32 cần thêm H1).
- **Rủi ro tiếng Anh:** thấp; cần từ tiếng Anh dài hơn 7 chữ mà 7 chữ đầu là tiếng Việt hợp lệ.
- **Phải đổi:** D33.

### H7. D20 xét cả từ quanh con trỏ (K11)

Trong cùng một lần đọc, lấy cả phần chữ cái ngay sau con trỏ. Phím áp lên cả từ cho ra từ hợp lệ thì thay cả từ; không thì như hiện nay (chỉ phần trước, "hoc‸tap" + j → "họctap").

- **Sửa:** C8, C9 (2 ca).
- **N3:** vẫn một lần đọc, một `insertText`.
- **Cần đo thật:** sau khi thay vùng có cả phần sau con trỏ, app đặt con trỏ ở cuối vùng hay giữ chỗ cũ (mục 5).
- **Phải đổi:** D20 "Chỉ xét phần chữ ngay trước con trỏ".

### H8. Sửa sau khi chốt ở chế độ gạch chân (K7)

Ở ⌫ ngay sau một từ vừa chốt, mở lại từ đó thành chữ gạch chân. Muốn vậy phải thay chữ đã chốt, nên cần vị trí tuyệt đối: một `selectedRange` ở phím đó.

- **Sửa:** tới 31 ca, nếu phủ cả mũi tên và click như D20.
- **Xung đột:** D13 và bảng của N3 ("Mọi phím ở chế độ gạch chân: không hỏi"). Gạch chân tồn tại cho app trả vị trí sai, chính là lúc H8 cần vị trí.
- Theo D13, gạch chân là đường lui. Hướng đúng theo sổ là làm thay tại chỗ chạy được ở app mà người dùng đang bật gạch chân. Cần biết đó là app nào.

### H9. Bớt điều kiện 50 ms ở lần đọc sau ⌫ (K9)

Sau ⌫ đi thẳng, `CursorTracker` đã biết chữ bị xoá. Dùng phép chứng minh app chậm của D11 thay cho chờ 50 ms.

- **Sửa:** B33, C12.
- **Rủi ro:** app trả chữ cũ khi phím dồn, đúng loại lỗi D11 đang chặn.
- Gắn với việc đo phím dấu không ăn trong trình soạn thảo TipTap/ProseMirror, đang làm riêng.
- **Phải đổi:** D20 (ngưỡng). Câu "người quay lại sửa từ không gõ nhanh như vậy" trong lý do của D20 chưa có số đo: bài báo ở mục 1 không công bố khoảng cách từ ⌫ tới phím kế tiếp.

### Xếp hạng

Xếp theo số ca người gõ thật sửa được, rồi theo rủi ro.

| Hạng | Hướng | Ca sửa được | Rủi ro tiếng Anh | N3 | D43 | App trả lời chậm |
|---|---|---|---|---|---|---|
| 1 | H1 | 9 (K1), hồ sơ M, T, N | không tệ hơn gõ thẳng | thêm `selectedRange` + `insertText` ở ⌫, đã có loại lời gọi này | không chạy (không đọc được chữ) | lần đọc chịu cùng ràng buộc D11 |
| 2 | H4 | 2 ca + 93/381 từ tiếng Anh | sửa tiếng Anh | không thêm lời gọi | không đổi | không đổi |
| 3 | H3 | 7, cả sau click | 90 cặp đổi; phá ví dụ "cars" của D20 | không thêm | không chạy | như D20 |
| 4 | H8 | tới 31, chỉ người dùng gạch chân | không | thêm `selectedRange` ở chế độ không được hỏi | — | rủi ro cao |
| 5 | H6, H7, H5 | mỗi hướng 2 | thấp, thấp, đổi "tesst⌫s" | H7 đọc rộng hơn | — | H7 cần đo |
| 6 | H9 | 1 | không | không | — | rủi ro |
| 7 | H2 | 4 | 13/381 từ hỏng | không | — | — |

H1 và H4 sửa hai nguyên nhân khác nhau và không loại trừ nhau. Cả hai cùng thay ý "mốc khôi phục là chữ đang hiện" bằng mốc theo phím.

## 5. Giới hạn và phần cần đo thật

- **Mô phỏng:**
  - Mọi cột "Dấu hôm nay" và "Gạch chân" chạy bằng `InPlaceComposer` và `MarkedComposer` thật, với ô nhập giả đồng bộ (vị trí và chữ luôn mới, áp phím ngay).
  - App trả lời chậm, tự sửa chính tả (trừ B35, B36 mô phỏng bằng hàm sửa từ), gợi ý tự hoàn thành: không phủ.
  - Click mô phỏng bằng sự kiện reset như mũi tên, đúng đường mã của `DauInputController`.
- **Danh sách từ tiếng Anh** (phụ lục): 507 từ thường gặp và từ khoá lập trình, tự lập, không phải mẫu đại diện. Số ở mục 2–4 chỉ nói "có loại hỏng này và nhiều cỡ nào trên danh sách đó".
- **Hồ sơ người gõ:** số từ một nghiên cứu gõ tiếng Anh; gắn hồ sơ cho từng kịch bản là giả định.
- **Cần đo thật, gộp được một lượt ngắn** (chiếm màn hình, phiên chính xin giờ; mỗi ô kèm Telex của Apple làm đối chứng):
  - D5: bấm đúp chọn từ rồi gõ lại, ở Notes và Chrome.
  - H7: thay một vùng có cả phần sau con trỏ thì con trỏ về đâu, ở Notes, Chrome, VS Code. Chỉ cần nếu chọn H7.
  - Telex của Apple ở các ca chữ thừa (B29–B31, `ddungsg␣⌫⌫`), để có đối chứng cho nhóm K1. Telex của Apple không khôi phục từ, nên dự đoán nó giữ "đúngg"; chưa đo.
- **Không đo được bằng lượt chạy ngắn:** khoảng cách từ ⌫ tới phím dấu khi gõ thật (K9, H9). Cần nhật ký phím của người gõ thật; D8 (Không telemetry) chỉ cho ở bản Debug với khoá `DauPerfLog`, trên máy người dùng tự bật.
- **Ngoài phạm vi:** phím dấu không ăn khi gõ nhanh trong trình soạn thảo web (đo riêng ở TipTap/ProseMirror). Mọi ca nhóm A ở đây đúng cả khi phím cách nhau 8 ms trong ô giả.

## 6. Phương pháp

- **Cách chạy:** hai file test tạm, đã xoá, không commit.
  - Một file trong `Apps/DauInputMethod/Tests` dựng lại ô nhập giả theo kiểu `InPlaceComposerTests` và `MarkedComposerTests`, thêm mũi tên dời con trỏ, ⌥⌫ xoá từ, sửa từ kiểu tự sửa chính tả. Chạy bằng `xcodebuild test -scheme DauInputMethod -only-testing:…`.
  - Một file trong `Packages/DauEngine/Tests` dùng `typed` của `Typist` cho các số đo trên danh sách từ tiếng Anh. Chạy bằng `swift test --package-path Packages/DauEngine --filter …`.
- **Mã nguồn đã đọc:** `VietEngine` (`backspace`, `seed(displayed:)`, `finishWord`, `startOverflow`), `InPlaceComposer` (`handleKey`, `addMarks`, `seedWord`, `checkLockedWord`, `continueForeignWord`), `MarkedComposer.handle`.
- **Mỗi số ở mục 2–4 lấy lại được** bằng chuỗi phím trong bảng, cấu hình D15, và danh sách ở phụ lục.
- **Các phép đo trên danh sách:**
  - "Giữ nguyên khi gõ thẳng": kết quả của `W␣` là `W␣`.
  - K3: `W` + `q⌫` + `␣`, và `W` bỏ chữ cuối + `q⌫` + chữ cuối + `␣`.
  - H2: từ giữ nguyên mà chữ giữa từ khác `W` và thêm s hay j cho chữ khác.
  - H3: từ có chữ cuối là phím dấu/biến đổi mà gõ thẳng `W␣` không ra `W`.
- **Nguồn ngoài:** V. Dhakal, A. M. Feit, P. O. Kristensson, A. Oulasvirta. Observations on Typing from 136 Million Keystrokes. CHI 2018. https://www.pokristensson.com/pubs/DhakalEtAlCHI2018.pdf ; trang dữ liệu https://userinterfaces.aalto.fi/136Mkeystrokes/

## Phụ lục: danh sách từ tiếng Anh dùng để đo

the be to of and a in that have it for not on with he as you do at this but his by from they we say her she or an will my one all would there their what so up out if about who get which go me when make can like time no just him know take people into year your good some could them see other than then now look only come its over think also back after use two how our work first well way even new want because any these give day most us is was are has had did does said made went got test tests best list post cost lost fast last past rest west east must trust boot boots root roots foot feet meet meets seat seats sheet street keep deep sleep need seed feed food goods cook book took hook door poor floor moon soon noon room cool pool tool fool school books cars car card cards carr star start part party art arts bar bars far jar war wars saw raw law draw shaw show snow how wow cow row bow low slow flow window windows sunrise sun run fun gun bus plus thus focus set sets net let bet yet wet met pet jet vet hot lot pot dot shot spot top stop shop drop hop cop tap map cap lap gap rap trap wrap sap app apps apple happy sorry worry carry marry error errors terror mirror coffee toffee office officer offer differ different difference effect effort affair staff stuff cliff off ask task mask desk risk disk dish fish wish rush push bush cash crash flash hash dash wash mesh fresh text next taxi tax box boxes fox mix fix six sex wax max relax index tex vex hex flex complex express press dress less mess guess pass mass class glass grass bass boss loss moss toss cross across process access success password assess possess mission session passion fashion lesson message massage passage bossy fussy messy jazz fuzz buzz quiz size zone zero lazy crazy easy busy quite quit quick quiet query quote equal sequence keyboard key keys kid kind king kiss kit kitchen kick knife known keen kept karma kansas hawk hawks tasks masks desks asks asked function return string struct enum var func self super init deinit import public private static final void int char bool true false null nil none data date type user users name names value values item items array map dict json html css java swift rust python ruby perl php sql api url http https www com org dev web site page code file files debug build release main master branch merge commit pull fetch clone diff log status reset revert rebase stash tag tags note notes view views model models controller service server client request response event events state states store props render hooks route router query mutation schema table column rows join where order group limit offset select insert update delete create alter grant begin
