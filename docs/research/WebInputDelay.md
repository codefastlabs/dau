# Luồng chính của trang web bận bao lâu khi người dùng gõ

## Hiện trạng (11/11/2026)

- **Đây là bối cảnh, không phải lỗi đang mở.** Câu hỏi đặt ra ngày 09/11/2026: khi luồng chính của trang bận lâu hơn khoảng cách giữa hai phím, Chrome trả `selectedRange` cũ và thay tại chỗ sai (gạch chân, D13 (Gạch chân là đường lui cuối cùng), không bị). Lỗi đó đã sửa ngày 10/11/2026: Dấu tự theo dõi vị trí con trỏ (D11 (Kiểm tra ngữ cảnh), mục "Vì sao", ý "App trả lời chậm"), và đúng 3/3 lượt khi trang bận ở Chrome, Edge và Firefox (`docs/Compatibility.md`, mục "Hiện trạng"). Các số dưới đây chỉ cho biết trang web bận tới mức nào.
- **Dữ liệu:** số đo thật từ người dùng Chrome (CrUX), tháng 09/2026, bản desktop, theo origin, đọc qua trang công khai của Treo. Không cần tài khoản, không đo trên máy ai.
- **17 origin có dữ liệu** (mục 1): p75 INP từ 25 ms (vnexpress.net) đến 350 ms (chatgpt.com); tỉ lệ lượt truy cập có INP trên 200 ms từ 2,7% (vnexpress.net) đến 45,6% (app.slack.com). chat.zalo.me không có dữ liệu.
- **Trang đọc và tìm kiếm ít lượt chậm** (vnexpress.net, github.com, www.google.com: 2,7–7,1% lượt trên 200 ms). **Ứng dụng chat, mạng xã hội, mua sắm nhiều lượt chậm** (Slack, ChatGPT, Shopee, X, Telegram, Discord, LinkedIn, YouTube, Facebook: 27–46%). Ngay ở origin có p75 tốt (www.notion.so, claude.ai, mail.google.com) vẫn có 15,8–16,7% lượt như vậy.
- **Toàn web (Web Almanac 2025, tháng 7/2025):** desktop 97% origin có INP tốt, 2% cần cải thiện, dưới 1% kém; điện thoại 77% / 21% / 3%. Số này tính theo origin (p75), nên không thấy các lượt chậm trong một origin có p75 tốt.
- **Không suy ra được bao nhiêu chữ sẽ sai** từ các số này (mục 2).

## 1. Bảng theo origin (CrUX 09/2026, desktop, qua Treo)

Ngưỡng của CrUX: tốt ≤ 200 ms, cần cải thiện 200–500 ms, kém > 500 ms. Ba cột đó là tỉ lệ **lượt xem trang** rơi vào mỗi nhóm (mục 3). "Trên 200 ms" = 100% trừ tỉ lệ tốt; các tỉ lệ làm tròn đến 0,1 nên có thể lệch 0,1.

| Origin | p75 INP (ms) | Tốt | Cần cải thiện | Kém | Trên 200 ms |
|---|---|---|---|---|---|
| vnexpress.net | 25 | 97,3% | 1,8% | 0,9% | 2,7% |
| github.com | 50 | 95,6% | 3,2% | 1,2% | 4,4% |
| www.google.com | 75 | 92,9% | 5,3% | 1,8% | 7,1% |
| www.notion.so | 125 | 84,2% | 10,5% | 5,3% | 15,8% |
| claude.ai | 125 | 84,0% | 11,9% | 4,1% | 16,0% |
| mail.google.com | 125 | 83,3% | 11,1% | 5,6% | 16,7% |
| docs.google.com | 175 | 78,5% | 15,0% | 6,5% | 21,5% |
| www.messenger.com | 175 | 77,4% | 14,4% | 8,2% | 22,6% |
| www.facebook.com | 200 | 72,5% | 17,4% | 10,1% | 27,5% |
| www.linkedin.com | 225 | 68,9% | 20,9% | 10,2% | 31,1% |
| www.youtube.com | 225 | 70,2% | 18,7% | 11,1% | 29,8% |
| discord.com | 250 | 69,4% | 18,1% | 12,5% | 30,6% |
| web.telegram.org | 250 | 68,0% | 21,6% | 10,4% | 32,0% |
| x.com | 250 | 63,1% | 30,1% | 6,8% | 36,9% |
| shopee.vn | 300 | 60,9% | 26,7% | 12,4% | 39,1% |
| app.slack.com | 325 | 54,4% | 33,5% | 12,1% | 45,6% |
| chatgpt.com | 350 | 56,8% | 25,7% | 17,5% | 43,2% |
| chat.zalo.me | không có dữ liệu (origin chưa đủ lượt truy cập hoặc chưa được liệt kê) | | | | |

Đọc bảng:
- Mọi p75 đều là bội của 25 ms; nhiều khả năng Treo làm tròn. Số chính xác của CrUX không lấy được.
- Một origin là mọi trang của nó, không riêng ô soạn thảo hay ô chat (www.google.com gồm cả trang kết quả; docs.google.com gồm cả bảng tính và trình chiếu).
- Số "kém" của chatgpt.com (17,5%) cao hơn Slack (12,1%) dù p75 của Slack cao hơn: p75 và tỉ lệ nhóm đo hai chỗ khác nhau của phân phối, không mâu thuẫn.
- Bộ lọc "desktop" gồm Windows, macOS, ChromeOS, Linux; không tách riêng macOS.

## 2. Giới hạn (N5 (Chỉ hứa điều đã kiểm chứng))

- INP rộng hơn việc gõ: gồm cả thời gian xử lý và độ trễ hiển thị, mọi loại tương tác (nhiều nhất là nhấp chuột), và chỉ lấy tương tác dài nhất của lượt xem. Một lượt "INP > 200 ms" chỉ nói ít nhất một tương tác chậm.
- INP cũng hẹp hơn: không có mốc dưới 200 ms (CrUX chỉ có ba nhóm và p75), và luồng chính bận mà không có tương tác nào rơi trúng thì không được ghi.
- Chưa rõ Chrome có tính phím đi qua bộ gõ (sự kiện soạn thảo: `keydown` mã 229, `compositionupdate`, `input`) là tương tác cho INP không; chưa tìm được nguồn chính thức (suy luận, cần kiểm chứng).
- Chỉ Chrome. Không có số cho Safari, Firefox, app Electron (dựa trên Chromium nhưng không vào CrUX) hay WebView. Không có phân phối theo tương tác, không có phần phụ của INP theo origin.
- Được nói: ở 9 trong 17 origin có dữ liệu, ít nhất 27% lượt truy cập có một tương tác trên 200 ms, tập trung ở ứng dụng web nặng. Không được nói: "x% chữ sẽ sai", hay "luồng chính bận lâu hơn khoảng cách hai phím ở y% lượt gõ".

## 3. INP đo gì (web.dev, đọc 09/11/2026)

- INP (Interaction to Next Paint) đo độ trễ các tương tác trong cả vòng đời một lượt xem trang. Tương tác gồm nhấp chuột, chạm và **nhấn phím** (`keydown`, `keypress`, `keyup`); cuộn, rê chuột, thu phóng không tính.
- Mỗi tương tác có ba phần: **độ trễ đầu vào** (tới lúc hàm xử lý đầu tiên chạy; dài ra khi luồng chính bận), **thời gian xử lý**, **độ trễ hiển thị** (tới khi khung hình lên màn hình). INP của một tương tác là tổng ba phần.
- **Một lượt xem trang cho một số:** tương tác dài nhất, bỏ ngoại lệ (một tương tác cao nhất cho mỗi 50 tương tác).
- **Số báo cáo cho một origin:** phân vị thứ 75 (p75) của các lượt xem.
- Web.dev nêu: phím gõ dồn trong ô nhập, hàm xử lý phím tốn thời gian (gợi ý tự động, gọi mạng) làm các phím chồng lên nhau; tương tác sau đến trước khi tương tác trước vẽ xong thì bị trễ thêm.
- CrUX chỉ gồm người dùng Chrome bật báo cáo thống kê sử dụng và đồng bộ lịch sử; Chrome trên iOS, WebView, trình duyệt Chromium khác không có. Origin phải đủ phổ biến (ngưỡng không công bố). Tài liệu CrUX không nêu cửa sổ 28 ngày hay cách tính p75.

## 4. Phương pháp

- **Treo, báo cáo tốc độ trang công khai** (`https://treo.sh/sitespeed/<origin>?formFactor=desktop`), đọc 09/11/2026: dữ liệu CrUX theo origin, kỳ 09/2026, bộ lọc desktop. `robots.txt` của Treo cho phép đọc (chỉ chặn `/a/` và `/demo/`). Mỗi origin một lần tải, cách nhau 3 giây; HTML thô lưu ở `build/web-input-delay/` (không commit). Lấy p75 INP và tỉ lệ ba nhóm.
- Kiểm chéo bộ lọc: github.com với mọi thiết bị 91,9% tốt, p75 75 ms; với desktop 95,6% tốt, p75 50 ms. Hai số khác nhau, nên bộ lọc desktop có tác dụng.
- **Không dùng được:** PageSpeed Insights API v5 không khoá (HTTP 429 cho cả 18 origin, hạn mức ngày của dự án dùng chung bằng 0); CrUX API (HTTP 403 khi không có khoá, cần tài khoản Google Cloud).
- **Web Almanac 2025, chương Hiệu năng:** phân bố INP toàn web theo origin, dữ liệu tháng 7/2025; không có phần phụ của INP.
- Không tìm thấy nguồn công khai không cần tài khoản cho phân phối độ trễ đầu vào riêng, phân phối theo tương tác, hay mốc 100 ms.

## 5. Nguồn

- INP: https://web.dev/articles/inp (đọc 09/11/2026)
- Độ trễ đầu vào: https://web.dev/articles/optimize-input-delay (đọc 09/11/2026)
- CrUX: https://developer.chrome.com/docs/crux/methodology (đọc 09/11/2026)
- Web Almanac 2025, Hiệu năng: https://almanac.httparchive.org/en/2025/performance (đọc 09/11/2026)
- Treo, báo cáo theo origin: `https://treo.sh/sitespeed/<origin>?formFactor=desktop` (đọc 09/11/2026, kỳ 09/2026)
