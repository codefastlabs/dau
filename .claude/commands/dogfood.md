---
description: Phiên chính tự gõ tiếng Việt bằng Dấu như người dùng thật trong app thật, tìm chỗ khó chịu khi gõ
disable-model-invocation: true
---
Lượt "gõ như người thật" (dogfood). Phạm vi tuỳ chọn: $ARGUMENTS (app, chủ đề, thời lượng). Không có thì chọn theo mục "Chọn app" bên dưới.

## Mục đích

Các lượt đo trong `scripts/selftest/` trả lời câu hỏi đã biết trước (một chuỗi phím, một đáp án, ✓/✗). Lượt này đi tìm câu hỏi: dùng Dấu để viết văn bản thật trong app thật, theo nhịp và thói quen của người gõ, rồi ghi lại mọi chỗ vấp. Đầu ra là danh sách quan sát, không phải kết luận; quan sát nào đáng theo thì biến thành ca tái hiện được (mục "Sau lượt gõ").

Không thay thế test: lỗi tìm được ở đây phải kết thúc bằng một test đơn vị hoặc một lệnh `scripts/selftest/typing/run.sh --keys … --expect …`.

## Hai chế độ gõ

Mỗi ô gõ thử cả hai chế độ, cùng đoạn văn, cùng chuỗi phím, để so cặp:
- **thay tại chỗ** (mặc định, D13 (Gạch chân là đường lui cuối cùng));
- **gạch chân**, bật như người dùng bật: quy tắc riêng cho app đó trong cửa sổ Cài đặt của Dấu (D5 (Quy tắc theo ứng dụng)). Ghi lại danh sách quy tắc trước khi đổi và trả về đúng như cũ khi xong. Cách bật đó vướng gì cũng là một quan sát.

Ở chế độ gạch chân, chỗ cần tìm là lúc người dùng làm việc khác trong khi chữ gạch chân còn đang chờ chốt. Ở chế độ này dồn thời gian vào các thao tác trong mục "Cách gõ" diễn ra giữa một từ chưa chốt:
- ←/→, ↑/↓, Home/End, nhấp chuột chỗ khác, chọn chữ bằng ⇧←;
- ⌫ lùi qua ranh giới giữa chữ gạch chân và chữ đã chốt, ⌫ hết chữ gạch chân;
- quay lại thêm hay đổi dấu cho từ đã chốt;
- phím tắt khi còn gạch chân: ⌘Z, ⌘A, ⌘C/⌘V, ⌘S, ⌘F, Esc, Tab;
- Return, dấu câu ngay sau từ (`.` `,` `?` `)`), số, chữ hoa giữa từ;
- gợi ý tự động hay sửa chính tả của app hiện ra khi còn gạch chân;
- chuyển app, chuyển cửa sổ, chuyển nguồn nhập liệu khi còn gạch chân, rồi quay lại.

Ở chế độ thay tại chỗ, các thao tác này cũng phải gõ, vì đó là chỗ thay tại chỗ dựa vào vị trí con trỏ do app báo. Hàng nào hai chế độ cho kết quả khác nhau là hàng đáng ghi.

## Trước khi chạy (không chiếm màn hình)

1. `scripts/dev/dau-version.sh`: biết bộ gõ đã cài là bản nào. Mặc định gõ bằng bản ổn định người dùng dùng hằng ngày (tag `stable`, CLAUDE.md "Dọn sau mỗi lần chạy"). Lượt này cần bản khác (commit mới nhất, bản Debug) thì việc cài nó cũng cần người dùng đồng ý: gộp vào cùng lượt chạy, và cài lại bản ổn định khi dọn.
2. Soạn sẵn văn bản sẽ gõ (mục "Văn bản") và kế hoạch app, ghi vào `build/dogfood/<ngày>/plan.md`. Mỗi đoạn có: chữ muốn ra, chuỗi phím Telex sẽ gõ (kể cả lỗi cố ý và chỗ sửa), app và ô gõ.
3. Báo người dùng: "sẵn sàng, khoảng N phút, dùng các app …", chờ đồng ý (CLAUDE.md, "Điểm dừng bắt buộc"). Một lần đồng ý cho một lượt.

## Chọn app

Ưu tiên app người dùng gõ hằng ngày và ô gõ đa dạng, mỗi lượt 2–3 ô (mỗi ô gõ hai chế độ), không cả ma trận:
- ô gõ AppKit dài: Notes (ghi chú mới, xoá khi xong), Mail (thư mới, không điền người nhận, không bao giờ gửi);
- trình duyệt: ô văn bản và ô contenteditable của trang thử cục bộ (như `typing/run.sh`), thanh địa chỉ Chrome (gõ rồi Esc, không Return);
- trình soạn thảo mã: VS Code tài liệu chưa lưu (comment, chuỗi, commit message), có gợi ý tự động bật;
- terminal: Ghostty, dòng lệnh không bao giờ Return;
- ô ngắn: ô tìm kiếm Finder hoặc ô tìm (⌘F) trong app.

Không dùng: TextEdit (`docs/TROUBLESHOOTING.md`), ô mật khẩu, trang hay app đã đăng nhập tài khoản thật, bất kỳ ô nào mà Return hay ⌘↩ gửi đi (Messages, Slack, ô chat).

## Văn bản

Tự soạn tại chỗ, mỗi lượt chủ đề khác, như một người viết thật: một thư công việc, một ghi chú họp, một đoạn kể chuyện, một comment trong mã, một câu tìm kiếm. Trong đó có:
- câu dài, viết hoa đầu câu, tên riêng (Hà Nội, Nguyễn Thị Thuỷ), số, ngày giờ, dấu câu, ngoặc kép, gạch đầu dòng;
- từ tiếng Anh và tên sản phẩm lẫn trong câu (email, deadline, GitHub, iPhone), viết tắt (HN, ok, k), URL hay tên file;
- từ dễ vấp: uơ, ươ, gi/qu (giường, quyển, quốc), từ không dấu chen giữa từ có dấu.

Mỗi câu có nghĩa và mang ý tích cực, kể cả câu dựng riêng cho một ca (CLAUDE.md, "Đo độ đúng khi gõ"). Trước khi gõ, soát từng chuỗi phím ra đúng chữ muốn ra.

## Cách gõ

Gõ như người, không như máy:
- nhịp như người: trong một từ 50–110 ms một phím, nghỉ sau mỗi từ (như `typing/run.sh --delay 80 --jitter 30 --word-pause 250`), nghỉ 0,5–3 giây giữa câu; nhịp đều từng phím không phải cách người gõ;
- bỏ dấu tự do: dấu ở cuối từ (`tieengs`), giữa từ (`tiesng`), đổi dấu (`as` rồi `f`), xoá dấu (`z`), gõ nhầm rồi ⌫ vài phím, ⌫ cả từ rồi gõ lại;
- quay lại sửa: ← về giữa từ đã gõ thêm hay đổi dấu, nhấp đúp chọn một từ rồi gõ đè, ⌥⌫ xoá một từ, ⌘Z rồi gõ tiếp;
- lẫn thao tác khác: dán một đoạn rồi gõ tiếp ngay sau, Return xuống dòng giữa đoạn, Tab nhận gợi ý tự động (VS Code), chuyển sang app khác rồi quay lại gõ tiếp giữa câu, sang U.S. bằng phím tắt chuyển nguồn của hệ thống để gõ một từ tiếng Anh rồi chuyển lại, như D2 (Chuyển Việt/Anh) hướng dẫn.

Công cụ: phím gửi bằng `osascript` (System Events `keystroke`, `key code`), từng chùm ngắn, không gửi cả đoạn một lần. Trước mỗi chùm kiểm app đích đang ở trước (như "Safety" ở đầu `typing/run.sh`); app khác ra trước thì dừng hẳn, không gửi tiếp. Chuỗi phím đã gửi (kể cả nhịp) ghi nối vào `build/dogfood/<ngày>/keys.log` để dựng lại được.

## Quan sát

- Chụp cửa sổ app (`screencapture -l <window id>`) sau mỗi câu và ngay sau mỗi thao tác sửa, xem ảnh bằng Read: chữ có đúng không, gạch chân có hiện không, con trỏ ở đâu, gợi ý tự động hay sửa chính tả của macOS có chen vào không.
- Bong bóng gợi ý sửa của macOS (chữ đề xuất kèm ×) hiện dưới từ khi người gõ dừng sau từ; dấu cách chấp nhận gợi ý. Người thật nhìn thấy nó, script thì không: chụp màn hình trước dấu cách ở chỗ dừng sau từ, ghi gợi ý như một quan sát, và soạn bước tiếp theo như người đã thấy nó (gõ tiếp, bấm ×, hay chấp nhận rồi sửa).
- Cuối mỗi ô đọc lại toàn bộ chữ (⌘A ⌘C, khôi phục clipboard như `typing/run.sh`) và so từng từ với chữ muốn ra.
- Ghi cả chỗ "đúng nhưng khó chịu": phải gõ lại, phải nghĩ cách gõ, gạch chân ở chỗ không cần, chữ nhảy, chậm thấy được, hành vi khác Telex của Apple mà người quen Telex của Apple sẽ bất ngờ.
- Chỗ nghi ngờ: gõ lại đúng đoạn đó một lần nữa bằng Dấu (có lặp lại không), rồi bằng Telex của Apple trong cùng ô, chuyển bằng phím tắt chuyển nguồn của hệ thống khi ô đã có focus (CLAUDE.md, "Đo độ đúng khi gõ"). Telex của Apple ra cùng kết quả thì ghi là hành vi của app hay macOS, không phải lỗi Dấu. Telex của Apple cũng hiện chữ bằng gạch chân, nên nó là đối chứng sát nhất cho chế độ gạch chân của Dấu.

Biết giới hạn của cách làm: phím từ System Events không hẳn là phím từ bàn phím; ảnh chụp không thấy chữ nháy giữa hai lần chụp. Ghi các giới hạn này cạnh quan sát liên quan.

## Dọn

Như CLAUDE.md, "Dọn sau mỗi lần chạy": xoá chữ đã gõ, đóng cửa sổ không lưu (Notes: xoá ghi chú; Mail: "Don't Save"), khôi phục clipboard và nguồn nhập liệu, trả danh sách quy tắc theo app của Dấu về như trước lượt, xoá `build/dogfood/` sau khi đã chép phần cần giữ, và cài lại bản ổn định (`scripts/dev/install-app.sh --ref stable`) nếu lượt này đã cài bản khác. Báo người dùng lúc bắt đầu, lúc xong và đã dọn gì.

## Sau lượt gõ

1. Bảng quan sát, mỗi hàng: app và ô; chế độ (thay tại chỗ, gạch chân); đang làm gì; phím đã gõ; muốn ra; ra gì; lặp lại được không; Telex của Apple ra gì; mức độ (sai chữ, phải sửa tay, chỉ khó chịu).
2. Ghi bảng vào nhật ký `docs/PROGRESS.md` dưới mục có nhãn "Quan sát khi gõ tự nhiên", không rút kết luận (CLAUDE.md, "Bản thử không phải kết luận"). Chuỗi phím của các hàng đáng theo chép vào repo cùng hàng đó.
3. Hàng lặp lại được và Telex của Apple ra đúng: tái hiện offline trước (test engine với chuỗi phím đó), không được thì một lệnh `typing/run.sh --keys … --expect …`; rồi đề xuất cách sửa (CLAUDE.md, "Sửa lỗi trước, đường lui sau"), đối chiếu `docs/DECISIONS.md`.
4. Hàng là hành vi đúng theo một quyết định nhưng vẫn khó chịu: nêu quyết định đó và đề xuất cho người dùng; không tự sửa `DECISIONS.md`.
5. Thao tác gõ nào xuất hiện nhiều lần mà `typing/run.sh --keys` chưa diễn tả được (nhấp đúp, ⌥⌫, ⌘Z, dán, chuyển app) thì ghi vào đề xuất, chưa xây công cụ khi chưa có lỗi cần nó.
