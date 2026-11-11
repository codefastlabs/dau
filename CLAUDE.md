# Dấu — bộ gõ tiếng Việt cho macOS

Dấu là input method tiếng Việt **chỉ dành cho macOS**, dựng trên InputMethodKit (IMK). Nó thay chữ tại chỗ bằng `insertText(_:replacementRange:)` thay vì giả lập phím Backspace như OpenKey. Tên chính thức: **Dấu** (đã chốt). Quy tắc dùng tên và định danh kỹ thuật: xem D24 (Tên và định danh).

Phiên mới đọc `docs/PROGRESS.md` trước (đang ở đâu, việc đang chờ), rồi đọc theo thứ tự:
1. `docs/DECISIONS.md` — sổ quyết định (nguồn chuẩn duy nhất).
2. `docs/ARCHITECTURE.md` — kiến trúc, target, luồng xử lý phím.
3. `docs/ROADMAP.md` — các mốc, tiêu chí hoàn thành.
4. `docs/UI.md` — mô tả màn hình (mockup gốc nằm trên canvas, xem link trong file).
5. `docs/BRAND.md` — biểu tượng, màu, chữ, danh sách file nhận diện cần xuất.
6. `docs/PROGRESS.md` — kế hoạch mốc đang làm, số đo, nhật ký theo ngày.

Mục lục mọi tài liệu khác (tra cứu, nghiên cứu, lưu trữ): `docs/README.md`.

## Điều phối

Phiên chính là **người điều phối**: lập kế hoạch, giao việc cho subagent trong `.claude/agents/`, kiểm chứng kết quả, commit, cập nhật `docs/PROGRESS.md`. Phiên chính hạn chế tự viết mã lớn để giữ ngữ cảnh gọn.

| Agent | Phụ trách |
|---|---|
| `researcher` | đọc OpenKey, test của các bộ gõ khác, tài liệu Apple; viết `docs/research/` (ghi chú OpenKey: `docs/research/OPENKEY-NOTES.md`) |
| `engine-dev` | `Packages/DauEngine` và test |
| `imk-dev` | `Apps/DauInputMethod` |
| `app-ui-dev` | `Apps/Dau` (SwiftUI) |
| `release-eng` | XcodeGen, CI, ký, notarize, Sparkle, Homebrew, xuất file nhận diện, triển khai trang web |
| `web-dev` | mã trang web: trang tải về (M8), trang so sánh cách gõ (M10) |
| `auditor` | kiểm tra độc lập, chỉ đọc; phải ĐẠT trước khi đóng mốc |

- Lệnh `/milestone M#` chạy trọn một mốc; `/audit` kiểm tra toàn repo; `/dogfood` phiên chính tự gõ như người dùng thật để tìm chỗ vấp (chiếm màn hình, hỏi giờ chạy trước).
- Subagent không thừa hưởng ngữ cảnh của phiên chính: mỗi lần giao việc phải nêu phạm vi, file được sửa, tiêu chí xong.
- Giao song song các việc độc lập (ví dụ M1 engine song song với M0 khung dự án; M4 giao diện song song M3 khi model cài đặt chung đã xong).
- Mỗi việc xong → kiểm chứng lại bằng lệnh thật → `scripts/check-docs/check.sh` (đổi chuỗi giao diện thì thêm `scripts/check-l10n/check.sh`) → commit nhỏ (Conventional Commits, tiếng Anh). Không commit khi test hoặc kiểm tra tài liệu đỏ.
- **Điểm dừng bắt buộc — hỏi người dùng:** Bundle ID / Team ID / tên cask / tên miền; mọi thao tác cần tài khoản Apple Developer hay chứng chỉ; bật nguồn nhập liệu, đăng xuất, cấp quyền, gõ thử trong ứng dụng thật (không thao tác được giao diện macOS); mọi thay đổi `DECISIONS.md`; **mọi lần chạy kiểm tra chiếm màn hình** (`scripts/selftest/settings-window/run.sh`, mở app thật, gõ thử tự động; tác dụng phụ của từng script: `scripts/README.md`): hỏi người dùng giờ chạy trước, vì họ đang dùng máy. Hook `.claude/hooks/guard-scripts.sh` chặn các script này; người dùng đồng ý trong chat rồi mới chạy lại với tiền tố `DAU_USER_APPROVED=1`. Trong lúc chờ, tiếp tục các việc không bị chặn.
- **Giao diện làm theo thứ tự: canvas trước, mã sau.** Sửa artboard trên canvas, cho người dùng xem và duyệt, rồi mới giao sửa mã; mã xong thì đối chiếu lại với artboard. Không sửa giao diện mà artboard chưa có. Người dùng duyệt artboard xong thì lưu các file canvas bằng công cụ Artifact (`read` với `paths`) rồi chạy `scripts/design/render-canvas.sh <thư mục đã lưu>` để cập nhật bản chụp trong `docs/canvas/`, cùng commit với thay đổi.
- Ngữ cảnh dài: trước khi ngữ cảnh đầy, ghi trạng thái vào `docs/PROGRESS.md` để có thể tiếp tục ở phiên sau.

## Nguồn chuẩn

- `docs/DECISIONS.md` là nguồn chuẩn **duy nhất** cho quyết định. Canvas không chép sổ quyết định. Lịch sử trò chuyện trên claude.ai có nhiều đề xuất đã bị thay thế (Rust/WASM, nhúng UniKey, từ điển tiếng Anh, `NSSpellChecker`, phím chuyển nhấn-nhả ⇧, chạy OpenKey làm đáp án test…). Gặp thông tin trái với `DECISIONS.md` ở bất kỳ đâu thì theo `DECISIONS.md`, và sửa hoặc báo chỗ lệch.
- Khi một quyết định thay đổi: sửa `DECISIONS.md` trước, thêm cách nói cũ vào `scripts/check-docs/superseded.txt`, rồi cập nhật artboard và các tài liệu khác cho khớp trong cùng lượt làm việc (chạy `check.sh` để tìm chỗ còn sót).
- **Mỗi sự kiện chỉ ghi ở một chỗ.** Quyết định ở `DECISIONS.md` (nơi khác dẫn số D/N, không chép lại nội dung); số đo giao diện ở `docs/research/SYSTEM-SETTINGS-REFERENCE.md` và script kiểm; số test và số đo theo ngày ở nhật ký `PROGRESS.md` (mốc đã đóng: trong `docs/history/`); kiến trúc ở `ARCHITECTURE.md` tả cấu trúc, không chép số. Dẫn mã bằng tên kiểu/hàm, không bằng số dòng. File agent trong `.claude/agents/` chỉ nêu vai trò và nơi đọc, không chép sự kiện.
- **Đóng mốc nào thì chuyển nhật ký và ghi nhớ của mốc đó sang `docs/history/`.** Mọi phiên đều đọc `PROGRESS.md`, nên nó chỉ giữ việc của mốc đang làm.
- **Tài liệu nghiên cứu (`docs/research/`) có mục "Hiện trạng" ở đầu, ghi ngày.** Kết luận đổi thì sửa thẳng vào mục đó và vào thân bài, không viết thêm mục "Đính chính" ở cuối.
- **Chỉ ghi kết luận khi đã đo trên Dấu thật hoặc có nguồn.** Quan sát trên bản thử (bundle đổi ID, app thử) ghi riêng một mục có nhãn, không rút kết luận; trạng thái đọc ở đúng chỗ người dùng thấy (danh sách "+", menu), không chỉ qua TIS từ một tiến trình mới.

## Viết tài liệu

Tài liệu mục nhanh hơn mã, vì không có test nào đỏ khi nó sai. Các luật dưới đây giữ cho nó ít, đúng và theo kịp mã.

- **Chỉ ghi điều mã không tự nói.** Quyết định và lý do (`DECISIONS.md`), cấu trúc và luồng giữa các thành phần (`ARCHITECTURE.md`), cách dùng (README, CONTRIBUTING), kết luận nghiên cứu. Chi tiết đổi theo mã (giá trị hằng số, các bước bên trong một hàm, tuỳ chọn của script) nằm trong comment của mã hay đầu script; tài liệu dẫn tên kiểu, hàm, script.
- **Ghi hiện trạng, không ghi nhật ký.** File tra cứu chỉ giữ điều đang đúng. Việc xong thì xoá kế hoạch và danh sách bước của nó, kết quả thay vào chỗ câu hỏi; diễn biến theo lượt, theo ngày vào nhật ký `PROGRESS.md` (rồi `docs/history/`), không vào file tra cứu.
- **Thứ tự theo người đọc.** Mở đầu bằng mục đích và kết luận; kết quả nằm cạnh câu hỏi nó trả lời; phần quan trọng trước, phần đã dừng hay để sau ở cuối. Câu ngắn; gạch đầu dòng cho các ý ngang hàng, không cho một đoạn văn.
- **Đổi mã thì sửa tài liệu trong cùng commit.** Đổi hành vi, tên kiểu, tên script hay tuỳ chọn: grep tên và cách nói cũ trong `docs/`, CLAUDE.md, CONTRIBUTING, README rồi sửa; cách nói cũ có thể quay lại thì thêm vào `scripts/check-docs/superseded.txt`.
- **Viết cho GitHub.** Tài liệu công khai trên GitHub: file trong repo dẫn bằng liên kết bấm được (``[`docs/DECISIONS.md`](docs/DECISIONS.md)``); chú thích cuối trang dùng URL đầy đủ (GitHub không đổi liên kết tương đối ở đó); thoát `|` trong bảng; chuỗi `<…>` để trong backtick.
- **Lỗi tài liệu tìm được bằng máy thì thêm vào `check.sh`**, như mọi lỗi kiểm tĩnh bắt được.

## Quy tắc làm việc

- **Đối chiếu sổ quyết định trước mọi đề xuất hay thay đổi.** Nếu một thay đổi mâu thuẫn với một nguyên tắc (N1–N5) hoặc quyết định (D1–D…) thì dừng lại và nêu mâu thuẫn, không tự ý làm. Nếu một quyết định cần đổi, cập nhật `docs/DECISIONS.md` trong cùng commit, ghi lý do.
- **Sau mỗi mốc, tự rà soát cơ học:** `scripts/check-docs/check.sh`, rồi grep code và chuỗi giao diện tìm chỗ trái với sổ quyết định (ví dụ: lời hứa về mạng, tính năng đã bỏ, phím tắt riêng).
- **Kiểm tra chéo các tính năng cùng tác động lên một đầu vào.** Với mỗi cặp tính năng như vậy, liệt kê các đầu vào mà chúng cho kết quả trái nhau và quyết định bên nào thắng, ghi vào `DECISIONS.md` (bài học từ D4 (Từ nước ngoài)).
- **Đo trước khi tối ưu.** Mọi khẳng định về hiệu năng phải có số đo (os_signpost / Instruments / test hiệu năng).
- **Không ghi lời hứa chưa kiểm chứng vào giao diện** (N5 (Chỉ hứa điều đã kiểm chứng)). Dùng ô trống dạng `[Kết quả bài test tải nặng]`.
- Làm theo mốc trong `docs/ROADMAP.md`, mỗi mốc kết thúc bằng test xanh và một bản tóm tắt ngắn: đã làm gì, đã đo được gì, còn mở gì.
- Những việc cần tài khoản Apple Developer, chứng chỉ ký, hoặc thao tác trong Cài đặt hệ thống: chuẩn bị sẵn và dừng lại hỏi người dùng.

## Quy ước mã nguồn (đề xuất, người dùng có thể đổi)

- Swift 6, strict concurrency. Engine là Swift package thuần, **không import Foundation/AppKit**.
- Dự án Xcode sinh từ `project.yml` bằng XcodeGen, không commit thủ công thay đổi trong `.xcodeproj`.
- Test bằng Swift Testing. Tên định danh, comment và commit message bằng tiếng Anh; chuỗi giao diện trong String Catalog, khoá là câu tiếng Anh, có bản tiếng Việt (D41 (Ngôn ngữ giao diện); thuật ngữ ở `docs/GLOSSARY.md`).
- Script trong `scripts/` viết bằng zsh, dòng đầu `#!/bin/zsh` (bash có sẵn trên macOS là bản 3.2); phần cần API Apple hay logic đáng kể viết bằng Swift biên dịch một lần, không dùng Python hay Perl (`scripts/README.md` mục "Ngôn ngữ"); in ra terminal bằng tiếng Việt qua `scripts/lib/log.sh` (`scripts/README.md` mục "Đầu ra").
- Giấy phép GPLv3 cho toàn bộ repo. Engine là của Dấu, viết từ đầu bằng Swift. Không chép mã từ OpenKey hay UniKey.

## OpenKey là tài liệu tham khảo, không phải đáp án

- Khi cần hiểu tường tận một tính năng (quy tắc đặt dấu, chính tả, khôi phục, gõ tắt…), clone OpenKey **ra ngoài repo** (ví dụ `/tmp/OpenKey`) và đọc mã nguồn, chủ yếu `Sources/OpenKey/engine/`.
- Ghi lại hiểu biết **bằng lời của mình** vào `docs/research/OPENKEY-NOTES.md`: tính năng, hành vi, ca biên, lỗi phát hiện được, và Dấu làm hay không làm (dẫn số quyết định).
- Kết quả mong đợi trong test viết theo quy tắc chính tả tiếng Việt và `DECISIONS.md`, không lấy từ kết quả chạy OpenKey. Chỗ nào Dấu cố ý khác OpenKey thì ghi rõ trong `OPENKEY-NOTES.md`.

## Cách làm việc đã rút ra

Các luật dưới đây rút từ những lần làm sai trước đây. Chúng nằm trong repo để có hiệu lực ở mọi máy và mọi phiên.

- **Người dùng chỉ làm việc thật sự cần họ:** quyết định, duyệt, chọn giờ cho lượt chạy chiếm màn hình. Mọi việc thử, bấm giao diện (script Accessibility, `screencapture`), cài và dọn do phiên chính làm. Trước khi đưa một bước nào cho người dùng, tìm cách khác (dữ liệu công khai, kết quả đã có, thứ đã bật sẵn trên máy) hoặc bỏ phần đó.
- **Lượt chạy chiếm màn hình:** build xong mọi thứ trước, báo "sẵn sàng, khoảng N phút", chạy ngay khi người dùng đồng ý, ở tiền cảnh, báo lúc bắt đầu và lúc xong. Một lần đồng ý chỉ có hiệu lực cho lần chạy đó. Không giao lượt chạy chiếm màn hình cho subagent chạy nền.
- **Dọn sau mỗi lần chạy, kể cả khi dừng giữa chừng:** tiến trình đã mở, tab và server localhost, clipboard, khoá `defaults` có chữ `Dau`, file trong `build/`, bản đã cài (lượt nào cài bản khác, Debug để đo hay bản build thử, thì cài lại bản ổn định ngay trong lượt đó: `scripts/dev/install-app.sh --ref stable`; `stable` là tag git cục bộ chỉ vào commit người dùng dùng hằng ngày, chỉ chuyển khi người dùng đồng ý, không push). Thoát app bình thường, không Force Quit. Báo đã dọn gì. Không dùng TextEdit để thử gõ (`docs/TROUBLESHOOTING.md`).
- **Tính offline trước:** câu hỏi nào trả lời được bằng mô phỏng, test đơn vị hay số đã có thì không chạy app thật. Chạy app thật chỉ cho phần không mô phỏng được, ít ca, một lượt. Mỗi bài test phải đáng với cái giá của nó; hỏi điều này trước khi xây công cụ để làm một bài test qua.
  - Kiểm từ rẻ tới đắt: kiểm tĩnh (`scripts/check-docs/check.sh`, cú pháp), rồi test với đồ giả, rồi một lượt chạy thật gộp mọi ô cần đo, xin người dùng một lần.
  - Một loại lỗi chỉ lộ ra khi chạy thật mà kiểm tĩnh bắt được thì thêm phép kiểm đó vào `check.sh` ngay trong lượt sửa.
- **Mỗi mạch việc một phiên:** xong một mạch việc, hoặc khi ngữ cảnh đã dài, ghi trạng thái vào `docs/PROGRESS.md` rồi đề xuất phiên mới; phiên mới đọc `PROGRESS.md` và tài liệu liên quan, không mang theo ngữ cảnh cũ.
- **Giao việc gọn:** một tính năng một bản giao việc, phủ mọi phần nó chạm tới (cửa sổ, sheet, tài liệu, canvas). Đo một lần rồi dùng lại. Việc nhỏ (vài dòng tài liệu, một artboard) phiên chính tự làm.
  - Model theo loại việc: thiết kế, quyết định, kiểm toán, chẩn đoán dùng model mạnh nhất; script, công cụ đo, chụp canvas, ghi tài liệu từ báo cáo có sẵn, sửa chữ dùng sonnet; tra một chỗ hay đối chiếu cơ học dùng haiku. Model mặc định ghi trong tệp của từng agent; phiên chính đổi theo từng lần giao khi việc khác loại.
  - Bản giao việc nói kết quả ghi vào đâu trong repo (nghiên cứu vào `docs/research/`, số đo vào nhật ký `docs/PROGRESS.md`), để agent và phiên sau đọc thay vì làm lại; không gọi lại một agent chỉ để ghi kết quả của nó.
  - Việc tiếp nối việc của một agent thì gọi lại chính agent đó (còn ngữ cảnh), không tạo agent mới phải đọc lại từ đầu.
- **Ngữ cảnh gọn:** đọc file lớn bằng `grep`, `jq` hay theo đoạn, không in nguyên file vào ngữ cảnh. Kiểm toán một lần ở cuối mạch việc, theo phạm vi của diff; lượt kiểm toán lại chỉ xem các mục chặn.
- **Làm quân sư, không làm người chuyển lời:** gặp thứ thừa, vô ích hay sai trong tài liệu (việc "chờ người dùng" về chi tiết vặt, phép đo không ai cần, câu lỗi thời) thì xử lý ngay trong lượt đó: xoá, gộp, hoặc chốt theo nguyên tắc đã có, rồi báo ngắn đã làm gì. Chỉ đưa cho người dùng những quyết định thật sự đổi sản phẩm hoặc cần quyền của họ, kèm đề xuất. Không biến một việc dọn dẹp thành việc mới cho người dùng.
- **Không để lệch, dù nhỏ:** hai bản tiếng Anh và tiếng Việt phải nói cùng một ý; mã, catalog, canvas (cả bản chụp `docs/canvas/`) và tài liệu phải khớp nhau. Thấy lệch thì sửa hết các nơi ngay trong lượt đó, không ghi "lệch nhỏ, giữ nguyên".
- **Phản biện trước khi làm:** với mọi lựa chọn của người dùng, kể cả khi họ bấm nút duyệt đề xuất của phiên chính, nêu ngắn gọn: có cần không, có đúng không (N5), tốn gì, và phương án không đổi gì; thống nhất rồi mới làm. Trước khi đề xuất một luật mới, tự lập bảng các đầu vào và trường hợp nó phải xử lý (cập nhật, quay về bản trước, bản phát triển, bản sao ở nơi khác…) và kiểm luật trên từng hàng, để không phải rút đề xuất sau đó.
- **Câu hỏi không phải quyết định:** tin nhắn cân nhắc giữa các phương án được trả lời bằng đề xuất rồi chờ người dùng chọn. Chưa chọn thì không sửa `DECISIONS.md` hay canvas.
- **Chốt theo số đo đã có:** số máy hay số lượt đo ít không phải lý do hoãn chốt một tính năng hay quyết định, và không ghi quyết định là "tạm" hay "chờ đo thêm" vì lý do đó. Phạm vi phép đo (máy nào, mấy lượt) ghi cạnh con số; đo thêm mà số mới nói khác thì sửa quyết định.
- **Chẩn đoán:** dựng dòng thời gian các lần chạy đạt và không đạt; nêu ít nhất hai, ba giả thuyết và mỗi giả thuyết dự đoán gì cho từng quan sát; thử phân biệt có đối chứng, lặp ít nhất ba lần. Chỉ giả thuyết giải thích được mọi quan sát mới là nguyên nhân, còn lại ghi "chưa rõ". Lỗi chập chờn không bao giờ đổ cho việc người dùng đang dùng máy. Một app hay một bước từng chạy được (tra nhật ký `docs/PROGRESS.md` và `docs/history/`) mà lần này hỏng thì đó là lỗi chập chờn cần chẩn đoán và thử lại ngay trong lượt, không báo là "không dùng được".
- **Bản thử không phải kết luận:** bản thử (bundle đổi ID, app thử) phải tái hiện được một hành vi đã biết của Dấu trước khi tin kết quả của nó. Đọc trạng thái ở chỗ người dùng nhìn thấy (danh sách "+", menu), không chỉ qua TIS từ một tiến trình mới. Nguồn chính thức nói khác quan sát thì nêu cả hai. Commit message và `PROGRESS.md` không khẳng định nhiều hơn điều đã đo.
- **Đo độ đúng khi gõ:** đối chứng là bộ gõ tiếng Việt khác trong cùng điều kiện (Telex của Apple), không phải bàn phím U.S. Câu thử là câu tiếng Việt có nghĩa, mang ý tích cực, mà vẫn chứa đúng ca cần đo; không dùng từ vô nghĩa hay chuỗi ghép cho đủ ca. Đáp án là chữ người gõ muốn ra, khớp từng phím đã gõ (soát chuỗi phím trước khi chạy). Chuỗi thử gõ như người dùng thật: bỏ dấu tự do, đổi và xoá dấu, ⌫ giữa từ, thêm dấu cho từ đã gõ, từ tiếng Anh; không chỉ Telex thứ tự chuẩn. Biết chắc phím vào ô nào trước khi tin "đạt", và biết chắc bộ gõ nào đang xử lý phím trong ô đó: nguồn do macOS báo hay biểu tượng trên thanh menu chưa đủ, bộ gõ đối chứng phải được chuyển bằng phím tắt chuyển nguồn của hệ thống khi ô gõ đã có focus, không bằng API từ tiến trình của script (`typing/run.sh`, `cycle_to_source`), và chỉ chuyển khi nguồn cần gõ chưa phải nguồn hiện tại; ô đối chứng ra nguyên chuỗi phím là đo hỏng, không phải kết quả. Bước kiểm tự nó cũng là phép đo: phím gửi dồn, chữ gạch chân chưa chốt, hay một từ thử không phải tiếng Việt đều cho kết quả sai về bộ gõ. Chạy thẳng ô phân biệt được các giả thuyết, kèm đối chứng, thay vì cả ma trận. Mọi thứ cần để dựng lại một lượt đo (chuỗi phím, đáp án, lệnh) nằm trong repo, không trong thư mục tạm.
- **Sửa lỗi trước, đường lui sau:** gặp lỗi của Dấu thì đề xuất cách sửa trước; đường lui (như gạch chân, D13 (Gạch chân là đường lui cuối cùng)) chỉ bàn khi sửa không đạt.
- **Tự phản biện trước khi giao:** kế hoạch, bản giao việc, bản tóm tắt, commit đều tự soát trước khi đưa người dùng: chỉ tới thứ có thật trong repo, không tự mâu thuẫn, không nói quá số đo, không chép lại điều đã ghi ở nơi khác.
- **Giao diện:** đọc tài liệu Apple và HIG trước, ghi API được thiết kế cho việc đó. Cách vá vòng (duyệt cây view, thử lại có hẹn giờ, số cố định bù bố cục) chỉ dùng khi tài liệu cho thấy không có API, và ghi lý do. Trước khi cho người dùng xem bản build giao diện, chạy ma trận cửa sổ thật và `docs/UI-CHECKS.md`, tự xem ảnh. Giao việc giao diện thì đưa file nguồn artboard (`docs/canvas/src/`); artboard thắng bản giao việc. Chiều cao artboard đo từ bản dựng, đệm đáy 40 px như đệm đầu, không ước.
- **Hướng dẫn bấm cho người dùng:** dùng đúng nhãn macOS đang hiện trên máy họ (đã thấy trên màn hình hoặc ảnh chụp); nhãn nào chưa kiểm thì nói rõ.
- **Repo là công khai:** ghi quyết định và yêu cầu bằng lời trung tính, không trích lời, giọng hay nhận xét của người dùng. Không ghi máy nào ở đâu hay của ai, tên máy, tên tài khoản hay nơi làm việc; các máy phát triển gọi theo chip (máy M1, máy M3 Max). Nhận xét về cách phiên chính làm việc không ghi vào repo. Không đặt giới hạn kích thước hay độ dài cho tài liệu; giữ tài liệu gọn bằng cách sắp xếp nội dung.
- **Sửa commit chưa push thì gộp vào nó** (`git commit --fixup` rồi `git rebase --autosquash`, hoặc `git reset --soft` khi là các commit cuối), không thêm commit "sửa lại"; lịch sử không giữ câu sai đã được sửa trước khi push.
- **Commit khi subagent đang chạy:** dùng `git commit --only <paths>` để không cuốn theo file subagent đã stage; dặn subagent làm như vậy.

## Lệnh thường dùng

- `brew install xcodegen && xcodegen generate` — sinh `Dau.xcodeproj`.
- `scripts/dev/doctor.sh` — máy mới thiếu gì để build, test, chạy Dấu (Xcode, xcodegen, ký, bản đã cài, nguồn nhập liệu, secure input), kèm lệnh sửa; không đổi gì trên hệ thống (chỉ ghi vào `build/` và `.build/`), `--tests` để chạy cả test engine.
- `scripts/dev/dau-version.sh` — bản bộ gõ đã cài và đang chạy có đúng commit mới nhất không.
- `scripts/dev/clean-dau.sh` — không tham số: liệt kê mọi dấu vết của Dấu trên tài khoản (chỉ đọc); `--yes` (người dùng tự chạy) xoá những gì xoá được để thử cài từ máy sạch — các mục trong `com.apple.inputsources` phải bỏ bằng "–" trong System Settings › Keyboard › "All Input Sources" — rồi đăng xuất.
- `scripts/dev/install-app.sh` — script cài duy nhất: build Dấu.app bản Release, kiểm bản build, đặt vào `/Applications` (đăng ký LaunchServices, thoát rồi mở lại app đang chạy); Dấu.app đó thay bộ gõ đã cài bằng bản nằm trong nó (D37 (Cài đặt bộ gõ)); `--debug` cho bản Debug, `--build-only` chỉ build và kiểm, `--no-build` dùng bản đã build, `--ref stable` cài bản ổn định (bản dùng hằng ngày) từ một worktree sạch.
- `swift test --package-path Packages/DauEngine` — test engine.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path scripts/snapshot-settings` — test của app chủ (giao diện dựng từ `Apps/Dau/Sources`).
- `scripts/check-docs/check.sh` — kiểm tài liệu lệch: đường dẫn (cả `docs/research/`), liên kết tương đối, mục lục `docs/README.md`, tên kiểu trong `ARCHITECTURE.md`, số dòng, số D/N và tên ở lần dẫn đầu, cách nói đã bị thay, số đo giao diện, mã commit, quy ước đầu script, bảng hook, bảng thư mục `scripts/`, tuỳ chọn script được dẫn (danh sách đủ ở đầu script); `.githooks/pre-commit` chạy nó trước mỗi commit khi đã bật bằng `git config core.hooksPath .githooks`.
- `scripts/selftest/typing/run.sh` — gõ thử trong app thật bằng Dấu hoặc nguồn khác (`--source`), chiếm màn hình.
- `scripts/design/render-canvas.sh <thư mục>` — chụp canvas thành bản trong `docs/canvas/` (Chrome chạy ẩn, cần mạng cho phông).
- `scripts/check-l10n/check.sh` — kiểm String Catalog: ngôn ngữ gốc `en`, mọi khoá có bản `en` và `vi` (D41); truyền thư mục build để so khoá trong mã với catalog.
