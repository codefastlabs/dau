# Sửa chữ khi gõ: người gõ sửa thế nào, Dấu hỏng ở đâu và vì sao

Người gõ tiếng Việt sửa chữ theo nhiều cách: đổi dấu trong từ đang gõ, ⌫ về từ vừa gõ để thêm dấu, dùng mũi tên vào giữa một từ cũ, xoá cả từ gõ lại. File này lập ma trận các cách sửa đó thành chuỗi phím có đáp án, ghi Dấu hôm nay ra gì (mô phỏng offline), gom các chỗ hỏng theo nguyên nhân, rồi đo các phương án sửa trong mô phỏng người gõ. Quyết định thuộc [`docs/Decisions.md`](../Decisions.md); mục 4.4 chỉ là đề xuất.

## Hiện trạng (11/11/2026)

- **Trong từ đang gõ, Dấu sửa tốt.** Đổi dấu, bỏ dấu, đặt dấu ở cuối hay giữa từ (D28 (Bỏ dấu tự do)), gõ nhầm chữ rồi ⌫, chữ thừa làm sai chính tả rồi ⌫ trước dấu cách: đúng ở 15/21 ca. Sáu ca hỏng do ba luật: khoá gõ đúp còn sau ⌫ (D26 (Gõ đúp phím dấu)), từ quá 7 chữ không quay lại (D33 (Độ dài từ)), và mốc khôi phục sau ⌫ là chữ đang hiện (D32 (Backspace)).
- **Nguyên nhân ngõ cụt lớn nhất trong mô phỏng: khoá gõ đúp còn sau ⌫ (K4).** Người gõ lỡ gõ đúp phím dấu ("carr" ra "car"), ⌫ chữ thừa rồi gõ lại dấu: vẫn ra "car", không ra "cả". Chiếm 60% số ngõ cụt ở cấu hình gốc, đứng đầu ở 42/45 cấu hình (đổi từng số giả định ×0,5 và ×2, cộng các cấu hình cực đoan; mục 4.3). Độ lớn phụ thuộc tỉ lệ lỡ gõ đúp, là số giả định: không có lỗi đó thì K4 còn 4%.
- **Thứ hai: từ đã bị khôi phục thì không sửa lại được (K1).** Khi kết thúc từ, D4 (Từ nước ngoài) trả từ không hợp lệ về đúng phím đã gõ ("ddungsg"); mọi cách sửa sau đó đọc chữ đó như chữ cái (D20 (Thêm dấu cho từ đã gõ)), nên phím dấu đi thẳng ("ddungss"). Hay gặp nhất là **từ vần tắc quên dấu thanh** ("đep", "viêt", "tôt", "đươc"): D31 (Âm tiết tiếng Việt hợp lệ) cho là không hợp lệ, D4 khôi phục thành "ddep", rồi ⌫ thêm `j` ra "ddepj". Chiếm 21% số ngõ cụt; đứng đầu khi mọi lỗi được sửa sau dấu cách.
  - Ma trận và mô phỏng không mâu thuẫn: sửa sau dấu cách **theo chữ trên màn hình** (xoá tới chỗ còn đúng rồi gõ tiếp) đúng ngay lần đầu 1116/1117 lần; sửa **theo phím đã nhớ** (⌫ qua dấu cách rồi gõ phím dấu còn thiếu, như ma trận) đúng 913/1086 (Telex). Bản mô phỏng trước chỉ có cách thứ nhất nên ra 99,4–100%.
- **Từ tiếng Anh gõ nhầm một chữ rồi ⌫ trong từ bị hỏng (K3).** D32 đặt mốc khôi phục là chữ đang hiện, mà chữ đang hiện của từ tiếng Anh là chữ Telex dở ("ưindows"). Đo trên 380 từ tiếng Anh mà Dấu giữ nguyên khi gõ thẳng: thêm một chữ thừa cuối từ rồi ⌫ thì 93 từ hỏng ("with" → "ưith", "deep" → "dêp", "server" → "sẻver"). Hệ quả này chưa ghi ở D32. D4 không hứa giữ từ tiếng Anh (tiếng Việt thắng, và D26 đã chấp nhận làm hỏng một số từ), nên đây là chỗ cần chọn, không phải lỗi so với sổ. Trong mô phỏng, K3 không quá 3% số ngõ cụt.
- **Chế độ gạch chân không có cách sửa nào sau khi từ đã chốt (K7).** Trong từ, gạch chân sửa như thay tại chỗ (bỏ dấu tự do vẫn chạy). Mọi cách sửa sau dấu cách hay sau mũi tên mà thay tại chỗ làm được (31 ca) đều hỏng ở gạch chân, vì D20 không chạy ở chế độ đó (D13 (Gạch chân là đường lui cuối cùng)). Telex của Apple cũng vậy (đã đo ở Sublime Text và Notes). Đây là điều người dùng gạch chân gặp khi nói "không bỏ dấu tự do được".
- **Phương án đo được** (mục 4.2, ngõ cụt mỗi 1000 từ của người mới gõ Telex: hôm nay 7,50):
  - (d) ⌫ xoá chữ của phím đúp thì mở khoá D26: 2,03. Không thêm lời gọi vào app; đổi D26 và 5 test engine.
  - (b) nhớ phím của từ D4 vừa khôi phục, chỉ dùng trong lần đọc D20 sẵn có: 6,89. Không thêm lời gọi; đổi D20 ("không giữ lịch sử từ") và D4 (mốc khôi phục). Đánh đổi: 11/100 từ tiếng Anh vừa khôi phục, ⌫ rồi thêm s, ra chữ Việt ("boot␣⌫s" → "bốt").
  - b+d: 1,41. (c) mốc sau ⌫ theo phím ở phần đuôi đi thẳng chỉ sửa từ tiếng Anh (93 → 1 từ hỏng), gần như không đổi số ngõ cụt.
- **Cần đo thật:** chọn cả từ rồi gõ lại; vị trí con trỏ sau khi thay cả từ quanh con trỏ (H7); nhịp ⌫ rồi phím dấu của người gõ nhanh so với ngưỡng 50 ms của D20; và, để biết mọi con số trên lớn cỡ nào, tỉ lệ lỡ gõ đúp phím dấu và tỉ lệ sửa theo phím (mục 5).

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
- **Số trong mô phỏng (mục 4) đều là giả định:** tỉ lệ lỗi, loại lỗi, cách phản ứng, thói quen sửa của từng hồ sơ nằm ở `SimProfile` (`Packages/DauEngine/Tests/DauEngineTests/TypistSim/SimProfiles.swift`), không lấy từ bài báo, vì bài báo không đo Telex hay cách sửa. Mục 4.3 đo xem kết luận nào đứng vững khi các số đó đổi.

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

Đo thêm cho K3 trên 380 từ tiếng Anh mà Dấu giữ nguyên khi gõ thẳng (danh sách ở phụ lục):
- Gõ thêm "q" cuối từ rồi ⌫: 93 từ hỏng; "q" giữa từ rồi ⌫: 36.
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
- Đúng 59, hỏng 24 (A: 6, B: 12, C: 5, D: 1). Riêng K3 có thêm số đo 93/380 từ tiếng Anh.
- Gạch chân thêm 31 ca hỏng (K7).

## 3. Nguyên nhân

| Mã | Nguyên nhân | Quyết định | Số ca hỏng | Ca |
|---|---|---|---|---|
| K1 | Từ đã bị D4 khôi phục (hay chữ đang hiện dạng phím Telex) không đọc lại được như phím: D20 đọc chữ cái, mà chữ cái đó không hợp lệ nên vào ngoại lệ (b), phím đi thẳng. Gồm từ vần tắc quên dấu thanh (D31 cho là không hợp lệ, nên D4 khôi phục "đep" thành "ddep") và từ có chữ thừa. | D4 (mốc khôi phục), D20 (đọc chữ cái; không giữ lịch sử từ; ngoại lệ (b)), D31, D30 | 12 | B24–B32, C10, C11, D4 |
| K3 | Sau ⌫ trong từ, mốc khôi phục là chữ đang hiện. Với từ tiếng Anh đã khoá chính tả, chữ đó là chữ Telex dở, nên kết thúc từ "khôi phục" về chữ dở. | D32, D4 (mốc) | 2 ca + 93/380 từ | A20, A21 |
| K4 | Khoá gõ đúp còn tới hết từ, kể cả khi ⌫ đã xoá chữ của phím đúp. | D26 | 2 | A16, A17 |
| K5 | Quá 7 chữ thì khôi phục ngay và đi thẳng; ⌫ về 7 chữ không trở lại. | D33 | 2 | A18, B32 |
| K6 | ⌫ xoá chữ cuối, không xoá dấu thanh (người mới có thể chờ ⌫ bỏ dấu; kỳ vọng này là giả định). | D32 | 1 | A19 |
| K7 | Gạch chân không có D20: không hỏi vị trí con trỏ nên không thay được chữ đã chốt. | D13, D20 (phạm vi), N3 (Ít lời gọi vào ứng dụng đích) | 31 | các ô "/ K7" |
| K8 | D20 không tự thêm mũ/móc để từ thành hợp lệ. | D20, "Đã biết nhưng không làm" | 1 | B23 |
| K9 | D20 chỉ đọc khi phím trước cách ít nhất 50 ms. | D20, D11 | 2 | B33, C12 |
| K10 | Tự sửa chính tả của macOS đổi từ thành chữ khác kết quả của phím. | D4 (giới hạn đã biết), D20 | 1 | B36 |
| K11 | D20 chỉ đọc phần trước con trỏ; dấu móc hay vị trí dấu cần cả từ ("nguo‸i" + w, "duo‸ng" + w ra "uơ" của D35 ("uơ" và "ươ")). | D20 (phạm vi), D35 | 2 | C8, C9 |

Không có ca nào hỏng vì reset khi dời con trỏ hay vì ⌫ qua nhiều từ (C1–C7 đúng). Ở nhóm C, chỉ có K1 (từ đã khôi phục) và K11 làm hỏng.

## 4. Phương án sửa, đo trong mô phỏng

### 4.1 Mô phỏng và độ tin

- **Mô phỏng người gõ** (`TypistSimTests`, `TypistSimOptionsTests`): bốn hồ sơ gõ kho câu tiếng Việt có lẫn từ tiếng Anh, bằng Telex và VNI, theo thứ tự phím riêng, gây lỗi rồi sửa như người nhìn màn hình. Mọi tỉ lệ là giả định (mục 1).
- **Bộ gõ trong mô phỏng là bản chép** (`ImkField`): engine thật, cộng lần đọc D20 chép từ `InPlaceComposer` (`ExternalCasesTests.d20Seed`), trên ô nhập đồng bộ, con trỏ luôn ở cuối. Test `matrixRows` chạy lại 54 dòng của ma trận mục 2 (đo bằng `InPlaceComposer` thật) và 7 đầu vào ở bảng 4.2: ra đúng cả 61.
  - Còn gần đúng: ngưỡng 50 ms của D20 (mọi lần đọc coi như đủ chậm), app trả lời chậm hay không cho đọc, lần dựng lại của D11 (Kiểm tra ngữ cảnh) khi lệch vị trí, tự sửa chính tả ("Từ hệ thống vừa sửa"), gạch chân, ô D43 (Ô bỏ qua vùng thay chữ), mũi tên và click giữa từ.
- **Hai thói quen sửa**, chia theo `byKeysPercent` (giả định 50%):
  - Theo màn hình: xoá tới chỗ chữ trên màn hình còn đúng, rồi gõ tiếp.
  - Theo phím đã nhớ: sau dấu cách thì ⌫ qua nó rồi gõ đúng cách sửa sẽ làm trong từ ("ddep␣⌫j"); trong từ tiếng Anh (chữ đang hiện là Telex dở, "ưith") thì ⌫ một lần cho mỗi phím từ chỗ sai rồi gõ lại phím đúng.
  - Bản mô phỏng trước chỉ có thói quen thứ nhất. Thói quen đó không bao giờ gõ phím dấu lên từ đã khôi phục, nên không chạm K1: 99,4–100% sửa sau dấu cách thành công. Đo lại (Telex, 3000 câu mỗi hồ sơ): theo màn hình đúng ngay lần đầu 1116/1117, theo phím 913/1086; VNI 1133/1133 và 957/1130.
- **Hai loại số, đừng gộp:** số ca ở mục 2 và cột "ca ma trận" dưới đây đếm dòng của ma trận, mỗi kịch bản một lần, không theo tần suất. "Ngõ cụt mỗi 1000 từ" đếm trong mô phỏng, theo tần suất giả định.
- **Ngõ cụt:** cách sửa tự nhiên của người gõ không ra chữ muốn. Người gõ sau đó thường xoá cả từ gõ lại, nên số từ sai cuối cùng gần như không đổi giữa các phương án (Telex 21,2 → 20,2–21,2 mỗi 1000 từ); ngõ cụt tốn phím và làm người gõ khựng, không để lại nhiều chữ sai.

### 4.2 Bảng phương án

Phương án (chỉ có trong test, `SimVariant`; không đổi mã của Dấu):

- **a** — giữ nguyên.
- **b** — nhớ phím của từ vừa khôi phục, bản hẹp: khi một ký tự kết thúc từ làm D4 khôi phục từ, nhớ chữ Dấu đã trả (chính là chuỗi phím). Nhớ qua ký tự đó và tối đa một ký tự kết thúc nữa (". "), qua các ⌫ xoá chúng, qua ⌫ trong từ (mỗi ⌫ bỏ phím cuối). Quên ở mọi phím khác, mũi tên, click, từ mới. Ở phím chữ cái hay phím dấu đầu tiên, trong lần đọc D20 sẵn có: nếu chữ đọc được đúng bằng chữ đã nhớ, gõ lại chuỗi phím đã nhớ cộng phím này vào một engine mới; ra tiền tố hợp lệ (D30 (Kiểm tra chính tả)) khác chữ đang hiện thì thay cả từ bằng kết quả đó (lần `insertText` D20 vốn có) và engine đi tiếp từ chuỗi phím đó. Không thì D20 như hôm nay. Không chạy ở gạch chân, ô D43, phím dồn.
- **b′** — b, cộng viết lại ngay ở ⌫ khi chuỗi phím còn lại là âm tiết đủ (D31): "ddungsg␣⌫⌫" hiện "đúng".
- **c** — mốc khôi phục sau ⌫ theo phím, chỉ cho phần đuôi đi thẳng: ⌫ xoá một chữ đã đi thẳng sau khi từ bị khoá chính tả thì chỉ bỏ phím cuối (engine về đúng trạng thái trước phím đó). ⌫ khác: D32 như cũ.
- **d** — ⌫ xoá chữ do phím đúp thêm vào thì mở khoá D26 ("carr⌫r" → "cả"; "tesst⌫s" vẫn "tess" vì ⌫ xoá "t").

Ngõ cụt mỗi 1000 từ, theo hồ sơ M / T / Đ / N (mục 1; trong `SimProfile` là người mới, bình thường, thạo, rất nhanh); 3000 câu mỗi hồ sơ và kiểu gõ, seed 20261111:

| Phương án | Telex | VNI | Từ được sửa / mới hỏng so với hôm nay (Việt; Anh) | Ca ma trận sửa được | Test engine đỏ | Phải đổi | N3 (Ít lời gọi vào ứng dụng đích) |
|---|---|---|---|---|---|---|---|
| a | 7,50 / 3,72 / 1,29 / 4,21 | 7,44 / 2,86 / 1,51 / 3,54 | — | — | — | — | — |
| b | 6,89 / 3,14 / 0,89 / 3,29 | 6,18 / 2,09 / 1,14 / 2,64 | 48 / 0; 0 | 7: B24–B28, B31, D4 | 0 | D20 "Không giữ lịch sử từ", D4 "Mốc khôi phục" | không thêm lời gọi |
| b′ | 6,36 / 2,92 / 0,83 / 3,07 | 5,78 / 1,97 / 1,08 / 2,40 | 68 / 1; 0 | 6: B24–B29; làm hỏng B31 ("đuns"), D4 ("úng") | 0 | như b, cộng N3 và D32 | ⌫ đó thêm một `selectedRange`, một lần đọc, một `insertText` |
| c | 7,41 / 3,60 / 1,29 / 4,12 | không đổi | 3 / 0; 0 | 2: A20, A21 | 1: `Hasak⌫i␣` ra "Hasai" thay vì "Hấi" | D32, D4 "Mốc khôi phục" | không thêm; ⌫ đó đi thẳng |
| d | 2,03 / 1,72 / 0,74 / 2,21 | 2,15 / 1,20 / 0,55 / 1,88 | 155 / 0; 1 | 2: A16, A17 | 5: `carr⌫r`, `carr⌫⌫as`, `aaa⌫a␣`, `ddd⌫d␣`, `a11⌫1` | D26 "kể cả sau Backspace" | không thêm |
| b+c | 6,79 / 3,01 / 0,89 / 3,20 | 6,18 / 2,09 / 1,14 / 2,64 | 51 / 0; 0 | 9 | 1 | b và c | không thêm |
| b+d | 1,41 / 1,14 / 0,34 / 1,29 | 0,89 / 0,43 / 0,18 / 0,98 | 203 / 0; 1 | 9 | 5 | b và d | không thêm |
| b+c+d | 1,32 / 1,01 / 0,34 / 1,20 | 0,89 / 0,43 / 0,18 / 0,98 | 206 / 0; 1 | 11 | 6 | b, c và d | không thêm |
| b′+c+d | 0,80 / 0,80 / 0,28 / 0,98 | 0,49 / 0,31 / 0,12 / 0,74 | 226 / 1; 1 | 10, làm hỏng 2 | 6 | b′, c và d | như b′ |

- "Từ được sửa / mới hỏng" đếm trên khoảng 260.000 từ (hai kiểu gõ, bốn hồ sơ): từ cuối cùng sai hôm nay mà đúng với phương án, và ngược lại. Từ Việt mới hỏng ở b′: "Owng␣⌫⌫…" (muốn "Ông"), ⌫ thứ hai viết lại thành "Ơn" ngay dưới tay người gõ. Từ Anh mới hỏng ở d: một lần "office" (từ D26 vốn làm mất một chữ "f"): hôm nay cách sửa của người gõ tình cờ ra đúng, với d thì không; chưa tách chuỗi phím.
- Test engine đỏ: chạy mọi `Case` và `expectTyped` có ⌫ trong test engine (54 ca) qua engine có phương án. Test bộ gõ: theo grep, không test nào gõ từ D4 vừa khôi phục rồi ⌫ rồi phím, nên b không làm đỏ test nào; b cần test mới.

Danh sách từ (Telex; [`TypistSimOptionsTests`](../../Packages/DauEngine/Tests/DauEngineTests/TypistSimOptionsTests.swift) `wordLists`), số từ ra đúng:

| Dạng | Số từ | a | b | c | d | b+d | b+c+d |
|---|---|---|---|---|---|---|---|
| Từ Anh Dấu giữ nguyên, thêm "q" cuối từ rồi ⌫ | 380 | 287 | 287 | 379 | 287 | 287 | 379 |
| Như trên, "q" giữa từ | 380 | 344 | 344 | 378 | 344 | 344 | 378 |
| Từ Anh, sai chữ cuối, ⌫, gõ lại | 380 | 289 | 289 | 378 | 289 | 289 | 378 |
| Từ Anh D4 khôi phục, ⌫ qua dấu cách, thêm "s" (muốn số nhiều) | 100 | 100 | 89 | 100 | 100 | 89 | 89 |
| 10 từ (đẹp, việt, tốt, được, nước, việc, đất, nhất, phát, tiếp): quên dấu, ⌫ qua dấu cách, gõ dấu | 10 | 1 | 10 | 1 | 1 | 10 | 10 |
| 10 từ: thừa "q" rồi ⌫ trong từ, quên dấu, sửa sau dấu cách (`ddeq⌫p␣⌫j␣`) | 10 | 10 | 10 | 1 | 10 | 10 | 10 |
| 10 từ: lỡ gõ đúp dấu, ⌫, gõ lại dấu (`ddepjj⌫j␣`) | 10 | 0 | 0 | 0 | 10 | 10 | 10 |
| 339 từ có dấu thanh của kho câu: quên dấu, sửa sau dấu cách | 339 | 291 | 335 | 291 | 291 | 335 | 335 |
| 339 từ: thừa "q", ⌫, quên dấu, sửa sau dấu cách | 339 | 335 | 335 | 291 | 335 | 335 | 335 |
| 339 từ: lỡ gõ đúp dấu, ⌫, gõ lại dấu | 339 | 0 | 0 | 0 | 335 | 335 | 335 |

- Đánh đổi hẹp của b: 11/100 từ Anh vừa khôi phục, ⌫ qua dấu cách rồi thêm "s", ra chữ Việt như khi gõ liền ("boot␣⌫s" → "bốt", "root" → "rốt", "meet" → "mết", "keep" → "kếp"). Đúng ý "tiếng Việt thắng" của D4, nhưng người muốn số nhiều phải gõ lại cả từ. ⌫ qua dấu cách, ⌫ chữ cuối rồi gõ lại nó thì 100/100 vẫn đúng ở mọi phương án.
- c, như mọi cách đặt mốc sau ⌫ theo phím, làm hỏng từ Việt hôm nay sửa được: `ddeq⌫p␣` ra "ddep" thay vì "đep" (phím "q" đi thẳng sau khi khoá), rồi ⌫j ra "ddepj" (dòng thứ sáu và thứ chín: 10 → 1, 335 → 291). Đi cùng b thì hết.

Kiểm chéo: các đầu vào mà phương án và luật đang có cho kết quả khác nhau.

| Đầu vào | Hôm nay | Phương án | Bên nên thắng |
|---|---|---|---|
| `ddep␣⌫j␣` | ddepj | b: đẹp | b (tiếng Việt thắng, D4) |
| `ddungsg␣⌫⌫⌫⌫⌫⌫ungs␣` (D4 ở mục 2) | ddungs | b: đúng; b′: úng | b |
| `ddungsg␣⌫⌫␣` (B29) | ddungs | b: ddungs; b′: đúng | b′ thắng ca này nhưng làm hỏng B31 và D4 |
| `ddungsg␣⌫⌫s␣` (B30) | ddungss | b: ddungss; b′: đungs | chưa phương án nào ra "đúng" |
| `boot␣⌫s␣` | boots | b: bốt | theo D4 là b; chưa quyết |
| `carr⌫r` | car | d: cả | d: người gõ xoá đúng chữ phím đúp vừa thêm để gõ lại dấu |
| `tesst⌫s` | tess | d: tess | như nhau (ví dụ của D26 giữ) |
| `aaa⌫a␣`, `ddd⌫d␣`, `a11⌫1` | aa, dd, a1 | d: â, đ, á | chưa quyết; test hiện có ghi khoá sống qua ⌫ |
| `withq⌫␣` | ưith | c: with | c |
| `ddeq⌫p␣⌫j␣` | đẹp | c: ddepj; b+c: đẹp | c chỉ đi cùng b |
| `Hasak⌫i␣` | Hấi | c: Hasai | chưa quyết (test `backspaceMovesRestoreBaseline` ghi "Hấi") |

Tự phản biện, mỗi phương án: kết quả nào chứng tỏ nó sai.

- **b:** lợi ích chỉ đến từ người sửa theo phím sau dấu cách (giả định 50%); ai cũng sửa theo màn hình thì b không đổi ngõ cụt nào (mục 4.3, K1 = 0%). Sai nếu nhật ký phím thật cho thấy ⌫ qua dấu cách rồi phím dấu trên từ vừa khôi phục hiếm, hoặc phần lớn là từ Anh muốn thêm "s". App tự sửa từ vừa khôi phục thì chữ đọc khác chữ đã nhớ, b lùi về D20 như hôm nay.
- **b′:** sửa B29 nhưng làm hỏng B31 và D4 ở mục 2, vì chữ đổi ngay dưới tay người đang đếm ⌫; thêm lời gọi ở ⌫. Đo đã nói nó sai ở đúng những ca đó.
- **c:** trong mô phỏng gần như không đổi gì (3 từ), vì cần từ Anh gõ ở chế độ tiếng Việt, gõ nhầm trong từ, rồi ⌫ theo phím. Vô ích nếu người dùng gõ tiếng Anh bằng U.S. như D2 (Chuyển Việt/Anh) gợi ý; đứng riêng thì làm hỏng `ddeq⌫p␣⌫j␣`.
- **d:** lợi ích dựa vào tỉ lệ lỡ gõ đúp phím dấu (giả định 5–10% số lỗi, không có nguồn). Sai nếu nhật ký phím cho thấy lỡ gõ đúp hiếm, hoặc sau phím đúp rồi ⌫ người gõ thường muốn chữ gốc ("aa", "dd") hơn chữ có dấu.

### 4.3 Độ nhạy

Đổi từng số giả định của cả bốn hồ sơ (×0,5 và ×2 cho tỉ lệ lỗi, từng loại lỗi, từng cách phản ứng, các thói quen), cộng các cấu hình cực đoan; 800 câu mỗi hồ sơ và kiểu gõ. Mỗi ngõ cụt của hôm nay được gán nguyên nhân bằng cách gõ lại đúng chuỗi phím đó với từng phương án: d sửa được thì là K4, không thì b′ sửa được là K1, không thì c sửa được là K3, còn lại là "khác".

| Cấu hình | Ngõ cụt / 1000 từ (Telex; VNI) | K4 | K1 | K3 | Khác |
|---|---|---|---|---|---|
| Gốc | 4,21; 3,46 | 60% | 21% | 0% | 18% |
| Tỉ lệ lỗi ×0,5 / ×2 | 2,16; 1,79 / 8,19; 7,12 | 58% / 60% | 23% / 22% | 0% / 2% | 19% / 16% |
| Lỡ gõ đúp phím dấu ×0,5 / ×2 | 3,63; 2,77 / 6,20; 5,16 | 47% / 75% | 32% / 13% | 2% / 1% | 19% / 10% |
| Sửa sau dấu cách ×0,5 / ×2 | 3,75; 4,30 / 4,55; 3,98 | 69% / 43% | 15% / 39% | 0% | 16% / 17% |
| Sửa ngay trong từ ×0,5 / ×2 | 3,69; 3,55 / 4,44; 4,38 | 43% / 69% | 39% / 17% | 0% | 18% / 14% |
| Luôn sửa theo màn hình / luôn theo phím | 2,74; 2,54 / 6,05; 4,67 | 87% / 43% | 0% / 35% | 0% / 2% | 13% / 20% |
| Chỉ sửa sau dấu cách | 5,88; 5,94 | 0% | 77% | 0% | 23% |
| Không ai lỡ gõ đúp phím dấu | 2,34; 1,50 | 4% | 55% | 3% | 38% |

- **K4 đứng đầu ở 42/45 cấu hình**, ở cả Telex lẫn VNI, kể cả khi mọi người gõ một thứ tự phím. K1 đứng đầu ở 2: chỉ sửa sau dấu cách, và không ai lỡ gõ đúp. Một cấu hình (chỉ xoá cả từ gõ lại) không có ngõ cụt.
- **Thứ hạng không phải do số giả định, độ lớn thì có.** Mọi số đổi trong ×0,5…×2 vẫn giữ K4 rồi K1. Ngoài hai cấu hình K1 đứng đầu, phần của K4 đi từ 43% tới 87%, và gần như toàn bộ nằm ở một số chưa có nguồn: tỉ lệ lỡ gõ đúp. Con số 80–90% nói trước đây chỉ tính ngõ cụt trong từ, với người gõ chỉ sửa theo màn hình.
- K3 không quá 3% ở cấu hình nào: kho câu ít từ Anh, và lỗi K3 cần gõ nhầm trong từ Anh rồi sửa theo phím.

### 4.4 Đề xuất (chưa quyết) và tự phản biện

Đề xuất b+d, làm d trước:

- d một mình bỏ 73% ngõ cụt ở người mới và 54% ở người gõ thường (Telex 7,50 → 2,03; 3,72 → 1,72), chỉ đổi engine, không thêm lời gọi vào app, giữ ví dụ "tesst⌫s → tess" của D26. Cần đổi câu "kể cả sau Backspace" của D26 và 5 test.
- b thêm phần K1 (b+d: 1,41 và 1,14), không thêm lời gọi, không từ Việt nào mới hỏng; đánh đổi đã đo là 11/100 từ Anh vừa khôi phục cộng "s". Cần đổi D20 và D4, như "Từ hệ thống vừa sửa" đã nhớ đúng một từ.
- c để riêng: chỉ lợi cho từ Anh gõ ở chế độ tiếng Việt, gần như không đổi ngõ cụt, đổi một test đang ghi rõ ý ("Hasak⌫i␣" → "Hấi"). b′ không đề xuất: hỏng hai ca ma trận và thêm lời gọi.

Tự phản biện:

- Cả hai phần lợi đến từ hai số không có nguồn: tỉ lệ lỡ gõ đúp (cho d) và tỉ lệ sửa theo phím (cho b). Nếu cả hai gần 0, b+d gần như không đổi gì; khi đó cũng không hỏng gì ngoài các ca ở bảng kiểm chéo.
- d đảo một câu D26 viết có chủ ý. Câu đó không ghi lý do riêng cho ⌫; lý do của D26 là giữ được chữ gốc, và d vẫn giữ khi ⌫ không xoá chữ của phím đúp. Nếu có người gõ "aaa⌫a" để được "aa", d làm hỏng họ.
- Mô phỏng là ô đồng bộ. b thay chữ ở đúng lần đọc mà D20 đang chịu ngưỡng 50 ms và kiểm tra D11, nên rủi ro app trả lời chậm như D20 hôm nay; chưa đo trên app thật.
- Kết quả chứng tỏ đề xuất sai: nhật ký phím (bản Debug, khoá `DauPerfLog`, người dùng tự bật, D8 (Không telemetry)) cho thấy sau một phím đúp rồi ⌫, phím kế tiếp hiếm khi là chính phím đó; hoặc ⌫ qua dấu cách rồi "s" trên từ vừa khôi phục chủ yếu là số nhiều tiếng Anh.

### 4.5 Hướng chưa đo trong mô phỏng

- **H2**, không khôi phục từ vần tắc chỉ thiếu dấu thanh: sửa B24–B27 nhưng 13 từ Anh đang giữ nguyên ra chữ Việt dở ("boot" → "bôt"); phải đổi D4, D31. b sửa các ca đó mà không hỏng từ nào.
- **H3**, D20 đọc chữ như chuỗi phím khi đọc như chữ cái không hợp lệ: sửa cả sau click, nhưng đổi 90 cặp từ Anh và phá ví dụ "carr → car, rồi s → cars" của D20. Giới hạn vào từ Dấu vừa khôi phục thì thành b.
- **H6**, ⌫ về 7 chữ thì trở lại biến đổi (K5): sửa A18, B32 (B32 cần thêm b); phải đổi D33.
- **H7**, D20 xét cả từ quanh con trỏ (K11): sửa C8, C9; cần đo con trỏ về đâu sau khi thay (mục 5); phải đổi D20.
- **H8**, sửa sau khi chốt ở gạch chân (K7): cần `selectedRange` ở chế độ không được hỏi (D13, N3). Theo D13, hướng đúng là làm thay tại chỗ chạy được ở app người dùng đang bật gạch chân.
- **H9**, bớt ngưỡng 50 ms sau ⌫ (K9): sửa B33, C12; rủi ro đúng loại lỗi D11 chặn. Câu "người quay lại sửa từ không gõ nhanh như vậy" của D20 chưa có số đo.

## 5. Giới hạn và phần cần đo thật

- **Mô phỏng:**
  - Mọi cột "Dấu hôm nay" và "Gạch chân" ở mục 2 chạy bằng `InPlaceComposer` và `MarkedComposer` thật, với ô nhập giả đồng bộ (vị trí và chữ luôn mới, áp phím ngay). Mô phỏng người gõ ở mục 4 dùng bản chép `ImkField`; phần còn gần đúng ở mục 4.1.
  - App trả lời chậm, tự sửa chính tả (trừ B35, B36 mô phỏng bằng hàm sửa từ), gợi ý tự hoàn thành: không phủ.
  - Click mô phỏng bằng sự kiện reset như mũi tên, đúng đường mã của `DauInputController`.
- **Danh sách từ tiếng Anh** (phụ lục): 507 từ thường gặp và từ khoá lập trình, tự lập, không phải mẫu đại diện. Số ở mục 2–4 chỉ nói "có loại hỏng này và nhiều cỡ nào trên danh sách đó".
- **Hồ sơ người gõ:** số từ một nghiên cứu gõ tiếng Anh; gắn hồ sơ cho từng kịch bản là giả định. Mọi tỉ lệ của mô phỏng là giả định; hai số quyết định độ lớn của mục 4 là tỉ lệ lỡ gõ đúp phím dấu và tỉ lệ sửa theo phím.
- **Kho câu của mô phỏng** (`SimCorpus`): câu tiếng Việt có nghĩa, một phần lẫn từ Anh và mã; không phải mẫu đại diện cho văn bản người dùng.
- **Cần đo thật, gộp được một lượt ngắn** (chiếm màn hình, phiên chính xin giờ; mỗi ô kèm Telex của Apple làm đối chứng):
  - D5: bấm đúp chọn từ rồi gõ lại, ở Notes và Chrome.
  - H7: thay một vùng có cả phần sau con trỏ thì con trỏ về đâu, ở Notes, Chrome, VS Code. Chỉ cần nếu chọn H7.
  - Telex của Apple ở các ca chữ thừa (B29–B31, `ddungsg␣⌫⌫`), để có đối chứng cho nhóm K1. Telex của Apple không khôi phục từ, nên dự đoán nó giữ "đúngg"; chưa đo.
- **Không đo được bằng lượt chạy ngắn:** khoảng cách từ ⌫ tới phím dấu khi gõ thật (K9, H9), tỉ lệ lỡ gõ đúp phím dấu, và người gõ sửa theo phím hay theo màn hình (mục 4.4). Cần nhật ký phím của người gõ thật; D8 (Không telemetry) chỉ cho ở bản Debug với khoá `DauPerfLog`, trên máy người dùng tự bật.
- **Ngoài phạm vi:** phím dấu không ăn khi gõ nhanh trong trình soạn thảo web (đo riêng ở TipTap/ProseMirror). Mọi ca nhóm A ở đây đúng cả khi phím cách nhau 8 ms trong ô giả.

## 6. Phương pháp

- **Cách chạy, mục 2:** hai file test tạm, đã xoá, không commit.
  - Một file trong `Apps/DauInputMethod/Tests` dựng lại ô nhập giả theo kiểu `InPlaceComposerTests` và `MarkedComposerTests`, thêm mũi tên dời con trỏ, ⌥⌫ xoá từ, sửa từ kiểu tự sửa chính tả. Chạy bằng `xcodebuild test -scheme DauInputMethod -only-testing:…`.
  - Một file trong `Packages/DauEngine/Tests` dùng `typed` của `Typist` cho các số đo trên danh sách từ tiếng Anh. Chạy bằng `swift test --package-path Packages/DauEngine --filter …`.
- **Cách chạy, mục 4** (Swift Testing; in bảng ra stdout):
  - `DAU_SIM=1 swift test --package-path Packages/DauEngine --filter TypistSimOptions`: `matrixRows` (cũng chạy trong mọi `swift test`), `wordLists`, `existingCases`, `optionsRun`.
  - `DAU_SIM_SENS=1 swift test --package-path Packages/DauEngine --filter TypistSimOptionsTests/sensitivity`: mục 4.3.
  - `DAU_SIM_SENTENCES`, `DAU_SIM_SEED` đổi số câu và seed. Phương án nằm ở `SimVariant`, hồ sơ ở `SimProfile`.
- **Mã nguồn đã đọc:** `VietEngine` (`backspace`, `seed(displayed:)`, `finishWord`, `startOverflow`), `InPlaceComposer` (`handleKey`, `addMarks`, `seedWord`, `checkLockedWord`, `continueForeignWord`), `MarkedComposer.handle`.
- **Mỗi số ở mục 2–4 lấy lại được** bằng chuỗi phím trong bảng, cấu hình D15 (Cài đặt mặc định), danh sách ở phụ lục, và các lệnh trên với seed 20261111.
- **Các phép đo trên danh sách:**
  - "Giữ nguyên khi gõ thẳng": kết quả của `W␣` là `W␣`.
  - K3: `W` + `q⌫` + `␣`, `W` có `q⌫` chèn giữa, và `W` bỏ chữ cuối + `q⌫` + chữ cuối + `␣`.
  - H2: từ giữ nguyên mà chữ giữa từ khác `W` và thêm s hay j cho chữ khác.
  - H3: từ có chữ cuối là phím dấu/biến đổi mà gõ thẳng `W␣` không ra `W`.
- **Nguồn ngoài:** V. Dhakal, A. M. Feit, P. O. Kristensson, A. Oulasvirta. Observations on Typing from 136 Million Keystrokes. CHI 2018. https://www.pokristensson.com/pubs/DhakalEtAlCHI2018.pdf ; trang dữ liệu https://userinterfaces.aalto.fi/136Mkeystrokes/

## Phụ lục: danh sách từ tiếng Anh dùng để đo

the be to of and a in that have it for not on with he as you do at this but his by from they we say her she or an will my one all would there their what so up out if about who get which go me when make can like time no just him know take people into year your good some could them see other than then now look only come its over think also back after use two how our work first well way even new want because any these give day most us is was are has had did does said made went got test tests best list post cost lost fast last past rest west east must trust boot boots root roots foot feet meet meets seat seats sheet street keep deep sleep need seed feed food goods cook book took hook door poor floor moon soon noon room cool pool tool fool school books cars car card cards carr star start part party art arts bar bars far jar war wars saw raw law draw shaw show snow how wow cow row bow low slow flow window windows sunrise sun run fun gun bus plus thus focus set sets net let bet yet wet met pet jet vet hot lot pot dot shot spot top stop shop drop hop cop tap map cap lap gap rap trap wrap sap app apps apple happy sorry worry carry marry error errors terror mirror coffee toffee office officer offer differ different difference effect effort affair staff stuff cliff off ask task mask desk risk disk dish fish wish rush push bush cash crash flash hash dash wash mesh fresh text next taxi tax box boxes fox mix fix six sex wax max relax index tex vex hex flex complex express press dress less mess guess pass mass class glass grass bass boss loss moss toss cross across process access success password assess possess mission session passion fashion lesson message massage passage bossy fussy messy jazz fuzz buzz quiz size zone zero lazy crazy easy busy quite quit quick quiet query quote equal sequence keyboard key keys kid kind king kiss kit kitchen kick knife known keen kept karma kansas hawk hawks tasks masks desks asks asked function return string struct enum var func self super init deinit import public private static final void int char bool true false null nil none data date type user users name names value values item items array map dict json html css java swift rust python ruby perl php sql api url http https www com org dev web site page code file files debug build release main master branch merge commit pull fetch clone diff log status reset revert rebase stash tag tags note notes view views model models controller service server client request response event events state states store props render hooks route router query mutation schema table column rows join where order group limit offset select insert update delete create alter grant begin
