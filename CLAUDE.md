# Dấu — bộ gõ tiếng Việt cho macOS

Dấu là input method tiếng Việt **chỉ dành cho macOS**, dựng trên InputMethodKit (IMK). Bộ gõ này thay chữ tại chỗ bằng `insertText(_:replacementRange:)` thay vì giả lập phím Backspace như OpenKey. Tên chính thức: **Dấu** (đã chốt). Quy tắc dùng tên và định danh kỹ thuật: xem D24 (Tên và định danh).

Phiên mới đọc `docs/Progress.md` trước (đang ở đâu, việc đang chờ, kế hoạch mốc đang làm, nhật ký lượt đo và chẩn đoán), rồi `docs/Decisions.md` — sổ quyết định (nguồn chuẩn duy nhất) — theo đoạn: mục lục ở đầu file (một dòng luật cho mỗi mục), các nguyên tắc N1–N5, rồi mọi quyết định liên quan tới việc đang làm. Các file sau đọc khi việc chạm tới, theo đoạn:
1. `docs/Architecture.md` — kiến trúc, target, luồng xử lý phím.
2. `docs/Roadmap.md` — các mốc, tiêu chí hoàn thành.
3. `docs/UI.md` — mô tả màn hình (mockup gốc nằm trên canvas, xem link trong file).
4. `docs/Brand.md` — biểu tượng, màu, chữ, danh sách file nhận diện cần xuất.

Mục lục mọi tài liệu khác (tra cứu, nghiên cứu, lưu trữ): `docs/README.md`.

Luật chỉ dùng cho một loại việc nằm trong `CLAUDE.md` của thư mục đó. Claude Code tự nạp file đó khi đọc file trong thư mục; việc dưới đây chạm tới thư mục khác thì đọc nó trước:
- [`docs/CLAUDE.md`](docs/CLAUDE.md) — viết tài liệu, cả README và CONTRIBUTING ở gốc.
- [`scripts/CLAUDE.md`](scripts/CLAUDE.md) — đo độ đúng khi gõ: mọi lượt gõ thử (script, `/dogfood`) và câu thử trong test.
- [`Apps/Dau/CLAUDE.md`](Apps/Dau/CLAUDE.md) — giao diện (app chủ, trang web, canvas): canvas trước, mã sau.

## Điều phối

Phiên chính là **người điều phối**: lập kế hoạch, giao việc cho subagent trong `.claude/agents/` (vai trò ghi ở phần mô tả của từng file), kiểm chứng kết quả, commit, cập nhật `docs/Progress.md` (mục "Trạng thái hiện tại" và kế hoạch mốc sau mỗi bước; nhật ký theo mục "Nguồn chuẩn"). Phiên chính hạn chế tự viết mã lớn để giữ ngữ cảnh gọn.

- Lệnh `/milestone M#` chạy trọn một mốc; `/audit` kiểm tra toàn repo; `/dogfood` phiên chính tự gõ như người dùng thật để tìm chỗ vấp (chiếm màn hình).
- Subagent không thừa hưởng ngữ cảnh của phiên chính: mỗi lần giao việc phải nêu phạm vi, file được sửa, tiêu chí xong.
- Giao song song các việc độc lập (ví dụ ở M7: `release-eng` dựng script phát hành và CI song song với `app-ui-dev` làm trang Cập nhật & hỗ trợ).
- Mỗi việc xong → kiểm chứng lại bằng lệnh thật (đổi chuỗi giao diện thì thêm `scripts/check-l10n/check.sh`) → tự soát tài liệu (mục "Viết tài liệu") → commit nhỏ (Conventional Commits, tiếng Anh). Không commit khi test đỏ.
- **Điểm dừng bắt buộc — hỏi người dùng:** Bundle ID / Team ID / tên cask / tên miền; mọi thao tác cần tài khoản Apple Developer hay chứng chỉ (chuẩn bị sẵn rồi mới hỏi); bật nguồn đầu vào, đăng xuất, cấp quyền, thao tác khác trong System Settings, gõ thử trong ứng dụng thật (không thao tác được giao diện macOS); mọi thay đổi `Decisions.md`, trừ khi người dùng đã giao quyết định đó cho phiên chính trong chat. Trong lúc chờ, tiếp tục các việc không bị chặn.
- **Chạy script và lượt chiếm màn hình theo chế độ quyền của Claude Code:** phiên chính không hỏi trong chat trước khi chạy (kể cả lượt chiếm màn hình: script trong bảng của hook, mở app thật, gõ thử tự động; tác dụng phụ của từng script: `scripts/README.md`). Người dùng hỏi hay không là do chế độ họ chọn (Manual thì Claude Code hỏi, Bypass permissions thì không); repo không làm lại tính năng đó. Hook `.claude/hooks/guard-scripts.sh` chỉ làm điều Claude Code không có: chặn subagent chạy các script đó.
- **Ai chạy script:** đọc dòng `# Side effects:` ở đầu script (chú giải ở `scripts/README.md`). Subagent chỉ chạy script có tác dụng phụ `none`, `builds`, `writes repo files`. Còn lại phiên chính chạy (ý trên). Riêng `scripts/dev/clean-dau.sh --yes` (gỡ Dấu khỏi máy) do người dùng tự chạy.

## Nguồn chuẩn

- `docs/Decisions.md` là nguồn chuẩn **duy nhất** cho quyết định. Canvas không chép sổ quyết định. Lịch sử trò chuyện trên claude.ai có nhiều đề xuất đã bị thay thế (Rust/WASM, nhúng UniKey, từ điển tiếng Anh, `NSSpellChecker`, phím chuyển nhấn-nhả ⇧, chạy OpenKey làm đáp án test…). Gặp thông tin trái với `Decisions.md` ở bất kỳ đâu thì theo `Decisions.md` và sửa hoặc báo chỗ lệch.
- Khi một quyết định thay đổi (người dùng đã chốt hoặc đã giao quyết định đó trong chat): sửa `Decisions.md` trước, ghi lý do, trong cùng commit với thay đổi; rồi sửa artboard và mọi chỗ còn cách nói cũ cho khớp trong cùng lượt làm việc (cách tìm: mục "Viết tài liệu", ý "Tự soát trước khi commit").
- **Mỗi sự kiện chỉ ghi ở một chỗ.** Quyết định ở `Decisions.md` (nơi khác dẫn số D/N, không chép lại nội dung); số đo giao diện ở `docs/research/SystemSettingsReference.md` và script kiểm; số đo gõ theo từng app ở `docs/Compatibility.md`; số đo và quan sát không thuộc tài liệu nào ở nhật ký `Progress.md` (mốc đã đóng: trong `docs/history/`); diễn biến của một thay đổi (file đã sửa, số test) ở commit message; kiến trúc ở `Architecture.md` tả cấu trúc, không chép số. Dẫn mã bằng tên kiểu/hàm, không bằng số dòng. File agent trong `.claude/agents/` chỉ nêu vai trò và nơi đọc, không chép sự kiện.
- **`Progress.md` chỉ giữ việc của mốc đang làm**, vì mọi phiên đều đọc nó. Đóng mốc theo `docs/Roadmap.md` mục "Tiêu chí đóng mốc", gồm chuyển nhật ký và ghi nhớ của mốc sang `docs/history/`.
- **Nhật ký `Progress.md` chỉ ghi điều phiên sau cần mà chưa có nhà ở chỗ khác.** Mỗi mục: ngày — việc — kết quả — nơi chứa số, commit.
  - Ghi: mỗi lượt đo (điều kiện, lệnh; số nằm ở tài liệu riêng thì chỉ dẫn tới), số đo và quan sát chưa có nhà (engine, D42, `/dogfood`), kết quả chẩn đoán kể cả "chưa rõ".
  - Không ghi: quyết định (`Decisions.md`, `docs/history/DecisionsLog.md`), bước kế hoạch đã xong (ghi "xong ngày…" ở mục kế hoạch), việc đang dở ("Trạng thái hiện tại"), kết quả tra cứu (quyết định hoặc `docs/research/`), cài bản hay chuyển `stable` (trừ bước dọn của một lượt đo), thay đổi `.claude/`, các `CLAUDE.md`, hook, dọn tài liệu, sửa mã không có số đo (commit message).

## Viết tài liệu

Luật viết đầy đủ ở [`docs/CLAUDE.md`](docs/CLAUDE.md). Hai luật dưới đây áp cho mọi thay đổi, kể cả khi chỉ sửa mã:

- **Đổi mã thì sửa tài liệu trong cùng commit.** Đổi hành vi, tên kiểu, tên script hay tuỳ chọn thì tự soát như ý dưới.
- **Tự soát trước khi commit.** Không có script kiểm tài liệu: đọc lại các tài liệu đã sửa, grep `docs/`, các `CLAUDE.md`, CONTRIBUTING, README và `.claude/` tìm tên, cách nói, số mục mà thay đổi làm lỗi thời, sửa hết trong cùng lượt; đổi tiêu đề hay số mục thì grep chỗ dẫn tới nó (cả comment trong mã và script).

## Quy tắc làm việc

- **Đối chiếu sổ quyết định trước mọi đề xuất hay thay đổi.** Nếu một thay đổi mâu thuẫn với một nguyên tắc (N1–N5) hoặc quyết định (D1–D…) thì dừng lại và nêu mâu thuẫn, không tự ý làm. Quyết định cần đổi thì hỏi người dùng (điểm dừng ở mục "Điều phối"), rồi sửa theo mục "Nguồn chuẩn".
- **Sau mỗi mốc, tự rà soát:** grep code, chuỗi giao diện và tài liệu tìm chỗ trái với sổ quyết định (ví dụ: lời hứa về mạng, tính năng đã bỏ, phím tắt riêng).
- **Kiểm tra chéo các tính năng cùng tác động lên một đầu vào.** Với mỗi cặp tính năng như vậy, liệt kê các đầu vào mà chúng cho kết quả trái nhau và quyết định bên nào thắng, ghi vào `Decisions.md` (bài học từ D4 (Từ nước ngoài)).
- **Đo trước khi tối ưu.** Mọi khẳng định về hiệu năng phải có số đo (os_signpost / Instruments / test hiệu năng).
- **Không ghi lời hứa chưa kiểm chứng vào giao diện** (N5 (Chỉ hứa điều đã kiểm chứng)). Dùng ô trống dạng `[Kết quả bài test tải nặng]`.

## Quy ước mã nguồn

- Swift 6, strict concurrency. Engine là Swift package thuần, **không import Foundation/AppKit**.
- Dự án Xcode sinh từ `project.yml` bằng XcodeGen, không commit thủ công thay đổi trong `.xcodeproj`.
- Test bằng Swift Testing. Tên định danh, comment và commit message bằng tiếng Anh; chuỗi giao diện trong String Catalog, khoá là câu tiếng Anh, có bản tiếng Việt (D41 (Ngôn ngữ giao diện); thuật ngữ ở `docs/Glossary.md`).
- **API của Apple trước, vá vòng sau.** Đọc tài liệu Apple và HIG trước, ghi API mà Apple thiết kế cho việc đó. Cách vá vòng (duyệt cây view, thử lại có hẹn giờ, số cố định bù bố cục) chỉ dùng khi tài liệu cho thấy không có API và ghi lý do.
- **Comment tả mã đang có và vì sao, không kể lịch sử.** Phép thử: người lần đầu đọc file, không có lịch sử commit, có hiểu mã tốt hơn nhờ comment không.
  - Không viết bản trước làm gì ("used to", "as before", "old behaviour", "after the fix"); diễn biến ở commit message. Bản trước sai thế nào thì viết thành hệ quả ở hiện tại ("otherwise …").
  - Không mang ngữ cảnh của phiên làm việc: ngày, tên lượt đo, mốc (M#, "step 2"), mã commit, đường dẫn `build/`, "canvas version N", ý kiến của người dùng. Số đo cần nguồn thì dẫn mục tài liệu và ghi phiên bản macOS hay app; ca thật minh hoạ thì giữ một ví dụ chữ.
  - Một lý do ghi một chỗ, ở kiểu hay hàm chủ của nó; nơi khác dẫn tên. Không chép tài liệu vào comment, không ghi "unit tested in …".
  - Không bao biện ("on purpose", "safe because"): ràng buộc thật viết thành câu khẳng định. Dẫn quyết định bằng số D/N; lựa chọn cấp mã chỉ giữ một câu về ràng buộc khiến cách khác không dùng được.
  - Nhãn giao diện trích bằng khoá tiếng Anh của String Catalog, như trong mã.
- Script trong `scripts/` viết bằng zsh, dòng đầu `#!/bin/zsh` (bash có sẵn trên macOS là bản 3.2); phần cần API Apple hay logic đáng kể viết bằng Swift biên dịch một lần, không dùng Python hay Perl (lý do và ngoại lệ duy nhất: `scripts/README.md` mục "Ngôn ngữ"); in ra terminal bằng tiếng Việt qua `scripts/lib/log.sh` (`scripts/README.md` mục "Đầu ra").
- Giấy phép GPLv3 cho toàn bộ repo. Engine là của Dấu, viết từ đầu bằng Swift. Không chép mã từ OpenKey hay UniKey.
- **OpenKey là tài liệu tham khảo, không phải đáp án** (D10). Đọc mã OpenKey thì clone **ra ngoài repo** (ví dụ `/tmp/OpenKey`, chủ yếu `Sources/OpenKey/engine/`) và ghi hiểu biết **bằng lời của mình** vào `docs/research/OpenKeyNotes.md`, kèm Dấu làm hay không làm (dẫn số quyết định). Kết quả mong đợi trong test viết theo chính tả tiếng Việt và `Decisions.md`, không lấy từ kết quả chạy OpenKey; chỗ Dấu cố ý khác OpenKey ghi trong `OpenKeyNotes.md`.

## Cách làm việc đã rút ra

Các luật dưới đây rút từ những lần làm sai trước đây. Chúng nằm trong repo để có hiệu lực ở mọi máy và mọi phiên.

- **Người dùng chỉ làm việc thật sự cần họ:** quyết định, duyệt. Mọi việc thử, bấm giao diện (script Accessibility, `screencapture`), cài và dọn do phiên chính làm. Trước khi đưa một bước nào cho người dùng, tìm cách khác (dữ liệu công khai, kết quả đã có, thứ đã bật sẵn trên máy) hoặc bỏ phần đó.
- **Lượt chạy chiếm màn hình:** build xong mọi thứ trước, báo một dòng (chạy gì, khoảng N phút) rồi gọi lệnh ngay (chế độ quyền quyết định có hỏi không, ý "Chạy script…" ở mục "Điều phối"); chạy ở tiền cảnh, báo lúc bắt đầu và lúc xong. Không giao lượt chạy chiếm màn hình cho subagent chạy nền. Máy bận hay điều kiện chưa lý tưởng thì vẫn chạy và ghi điều kiện cạnh số đo, không bỏ lượt.
- **Không có cửa sổ ẩn:** script, công cụ hay test không mở cửa sổ ở toạ độ ngoài màn hình hay ở chỗ người dùng không thấy; người dùng phải thấy mọi thứ một lần chạy hiện ra. Cửa sổ nào được hiện thì hiện ở chỗ người dùng thấy. Lần chạy đó là lượt chiếm màn hình (mục "Điều phối"). Không hiện gì thì được: test dựng view trong cửa sổ không bao giờ hiện, Chrome headless. Công cụ không có dòng `# Side effects:` thì đọc mã xem nó có hiện cửa sổ không trước khi chạy.
- **Dọn sau mỗi lần chạy, kể cả khi dừng giữa chừng:** tiến trình đã mở, tab và server localhost, clipboard, khoá `defaults` có chữ `Dau`, file trong `build/`, bản đã cài (lượt nào cài bản khác, Debug để đo hay bản build thử, thì cài lại bản dùng hằng ngày ngay trong lượt đó: `scripts/dev/install-app.sh --ref main`, bản Release của commit mới nhất trên `main`, dựng từ đúng commit đó dù cây làm việc đang có thay đổi chưa commit. Dự án phát triển liên tục nên bản dùng hằng ngày luôn là bản mới nhất: bộ gõ đã cài là mới nhất khi `scripts/dev/dau-version.sh` nói vậy, tức các commit sau nó trên `main` không đổi đầu vào build và Xcode không đổi; chỉ đổi tài liệu thì không cài lại). Thoát app bình thường, không Force Quit. Báo đã dọn gì. Không dùng TextEdit để thử gõ (`docs/Troubleshooting.md`).
- **Tính offline trước:** câu hỏi nào trả lời được bằng mô phỏng, test đơn vị hay số đã có thì không chạy app thật. Chạy app thật chỉ cho phần không mô phỏng được, ít ca, một lượt. Mỗi bài test phải đáng với cái giá của nó; hỏi điều này trước khi xây công cụ để làm một bài test qua.
  - Kiểm từ rẻ tới đắt: kiểm tĩnh (cú pháp, `zsh -n`), rồi test đơn vị và test với đồ giả, rồi một lượt chạy thật gộp mọi ô cần đo, xin người dùng một lần.
  - Một loại lỗi chỉ lộ ra khi chạy thật mà test đơn vị hay test với đồ giả bắt được thì thêm test đó ngay trong lượt sửa.
- **Mỗi mạch việc một phiên:** xong một mạch việc hoặc khi ngữ cảnh đã dài, ghi trạng thái vào `docs/Progress.md` rồi đề xuất phiên mới; phiên mới đọc `Progress.md` và tài liệu liên quan, không mang theo ngữ cảnh cũ.
- **Giao việc gọn:** một tính năng một bản giao việc, phủ mọi phần nó chạm tới (cửa sổ, sheet, tài liệu, canvas). Đo một lần rồi dùng lại. Việc nhỏ (vài dòng tài liệu, một artboard) phiên chính tự làm.
  - Model theo loại việc: thiết kế, quyết định, kiểm toán, chẩn đoán dùng model mạnh nhất; script, công cụ đo, chụp canvas, ghi tài liệu từ báo cáo có sẵn, sửa chữ dùng sonnet; tra một chỗ hay đối chiếu cơ học dùng haiku. Model mặc định ghi trong tệp của từng agent; phiên chính đổi theo từng lần giao khi việc khác loại.
  - Bản giao việc nói kết quả ghi vào đâu trong repo (nghiên cứu vào `docs/research/`, số đo theo app vào `docs/Compatibility.md`, số đo khác vào nhật ký `docs/Progress.md`), để agent và phiên sau đọc thay vì làm lại; không gọi lại một agent chỉ để ghi kết quả của nó.
  - Việc tiếp nối việc của một agent thì gọi lại chính agent đó (còn ngữ cảnh), không tạo agent mới phải đọc lại từ đầu.
- **Ngữ cảnh gọn:** đọc file lớn bằng `grep`, `jq` hay theo đoạn, không in nguyên file vào ngữ cảnh. Kiểm toán một lần ở cuối mạch việc, theo phạm vi của diff; lượt kiểm toán lại chỉ xem các mục chặn.
- **Làm quân sư, không làm người chuyển lời:** gặp thứ thừa, vô ích hay sai trong tài liệu (việc "chờ người dùng" về chi tiết vặt, phép đo không ai cần, câu lỗi thời) thì xử lý ngay trong lượt đó: xoá, gộp hoặc chốt theo nguyên tắc đã có, rồi báo ngắn đã làm gì. Chỉ đưa cho người dùng những quyết định thật sự đổi sản phẩm hoặc cần quyền của họ, kèm đề xuất. Không biến một việc dọn dẹp thành việc mới cho người dùng.
- **Không để lệch, dù nhỏ:** hai bản tiếng Anh và tiếng Việt phải nói cùng một ý; mã, catalog, canvas (cả bản chụp `docs/canvas/`) và tài liệu phải khớp nhau. Thấy lệch thì sửa hết các nơi ngay trong lượt đó, không ghi "lệch nhỏ, giữ nguyên".
- **Phản biện trước khi làm:** với mọi lựa chọn của người dùng, kể cả khi họ bấm nút duyệt đề xuất của phiên chính, nêu ngắn gọn: có cần không, có đúng không (N5), tốn gì và phương án không đổi gì; thống nhất rồi mới làm. Trước khi đề xuất một luật mới, tự lập bảng các đầu vào và trường hợp nó phải xử lý (cập nhật, quay về bản trước, bản phát triển, bản sao ở nơi khác…) và kiểm luật trên từng hàng, để không phải rút đề xuất sau đó.
  - Mỗi tiền đề của lời phản biện phải kiểm trong mã, tài liệu hay số đo trước khi nói ra; điều chỉ "có thể làm" không được nói như đã có.
  - Hướng sản phẩm là của người dùng: phản biện nêu cái giá và rủi ro, không thay hướng đó. Đề xuất bỏ hay hoãn vô hạn một ý của người dùng thì nói rõ là thay ý đó, đặt phương án giữ ý họ lên đầu và chỉ sửa khi họ chọn chính phương án thay.
  - Đổi lập trường giữa chừng thì nêu điều mới nào làm đổi; không có điều mới thì giữ lập trường cũ.
  - "Tốn gì" là cái giá cho sản phẩm và người dùng: rủi ro, độ phức tạp phải giữ lâu dài, thời gian chờ của người dùng. Công sức làm (sửa tài liệu, artboard, mã) không phải lý do chống một thay đổi, vì phiên chính và subagent làm phần đó.
- **Câu hỏi không phải quyết định:** trả lời tin nhắn cân nhắc giữa các phương án bằng đề xuất rồi chờ người dùng chọn. Chưa chọn thì không sửa `Decisions.md` hay canvas.
- **Chốt theo số đo đã có:** số máy hay số lượt đo ít không phải lý do hoãn chốt một tính năng hay quyết định và không ghi quyết định là "tạm" hay "chờ đo thêm" vì lý do đó. Phạm vi phép đo (máy nào, mấy lượt) ghi cạnh con số; đo thêm mà số mới nói khác thì sửa quyết định.
- **Chẩn đoán:** dựng dòng thời gian các lần chạy đạt và không đạt; nêu ít nhất hai, ba giả thuyết và mỗi giả thuyết dự đoán gì cho từng quan sát; thử phân biệt có đối chứng, lặp ít nhất ba lần. Chỉ giả thuyết giải thích được mọi quan sát mới là nguyên nhân, còn lại ghi "chưa rõ". Lỗi chập chờn không bao giờ đổ cho chuyện người dùng đang dùng máy. Một app hay một bước từng chạy được (tra nhật ký `docs/Progress.md` và `docs/history/`) mà lần này hỏng thì đó là lỗi chập chờn cần chẩn đoán và thử lại ngay trong lượt, không báo là "không dùng được".
- **Bản thử không phải kết luận:** chỉ ghi kết luận khi đã đo trên Dấu thật hoặc có nguồn. Bản thử (bundle đổi ID, app thử) phải tái hiện được một hành vi đã biết của Dấu trước khi tin kết quả của nó; quan sát trên bản thử ghi riêng một mục có nhãn, không rút kết luận. Đọc trạng thái ở chỗ người dùng nhìn thấy (danh sách "+", menu), không chỉ qua TIS từ một tiến trình mới. Nguồn chính thức nói khác quan sát thì nêu cả hai. Commit message và `Progress.md` không khẳng định nhiều hơn điều đã đo.
- **Đo độ đúng khi gõ:** luật ở [`scripts/CLAUDE.md`](scripts/CLAUDE.md); đọc trước mọi lượt gõ thử và trước khi soạn câu thử cho test.
- **Tái hiện trên mã mới nhất trước khi sửa:** lỗi lấy từ tài liệu hay một lượt đo cũ thì trước khi sửa phải xác nhận nó còn xảy ra với mã mới nhất và phiên bản app hiện tại: chạy lại ô đo đó ở app thật.
- **Chỉ báo lỗi app thật đã cho thấy:** test known issue, giới hạn trong tài liệu, nhãn trong danh sách tương thích chỉ ghi lỗi đã đo ra ở app thật. Kịch bản chỉ có trên mô hình (app giả trong test) không ghi là lỗi hay giới hạn; nó chỉ dùng để thử hướng sửa khi đã có ca thật.
- **Sửa lỗi trước, đường lui sau:** gặp lỗi của Dấu thì đề xuất cách sửa trước; đường lui (như gạch chân, D13 (Gạch chân là đường lui cuối cùng)) chỉ bàn khi sửa không đạt.
- **Xong trọn rồi mới commit:** một việc chỉ commit khi đã kiểm chứng xong trong cùng lượt. Bước kiểm cần chạy thật (lượt chiếm màn hình, cài bộ gõ) thì chạy trong cùng lượt, trước khi commit; không commit trước rồi ghi "chưa thử". Commit message, `Progress.md` và báo cáo không để lại danh sách "chưa đo, chưa thử" như việc treo: mỗi mục hoặc làm ngay trong lượt, hoặc bỏ kèm lý do không đáng làm, hoặc là quyết định của người dùng thì hỏi một lần kèm đề xuất. Chỉ điều không thể kiểm trong một lượt (cần dùng hằng ngày nhiều ngày) mới ghi, kèm cách sẽ biết.
- **Tự phản biện trước khi giao:** kế hoạch, bản giao việc, bản tóm tắt, commit đều tự soát trước khi đưa người dùng: chỉ tới thứ có thật trong repo, không tự mâu thuẫn, không nói quá số đo, không chép lại điều đã ghi ở nơi khác.
- **Giao diện:** canvas trước, mã sau; luật đầy đủ ở [`Apps/Dau/CLAUDE.md`](Apps/Dau/CLAUDE.md), đọc trước mọi thay đổi giao diện, kể cả trang web.
- **Hướng dẫn bấm cho người dùng:** dùng đúng nhãn macOS đang hiện trên máy họ (đã thấy trên màn hình hoặc ảnh chụp); nhãn nào chưa kiểm thì nói rõ.
- **Repo là công khai:** ghi quyết định và yêu cầu bằng lời trung tính, không trích lời, giọng hay nhận xét của người dùng. Không ghi máy nào ở đâu hay của ai, tên máy, tên tài khoản hay nơi làm việc; các máy phát triển gọi theo chip (máy M1, máy M3 Max). Nhận xét về cách phiên chính làm việc không ghi vào repo. Log và bản ghi thô của lượt đo, chẩn đoán hay chạy thử (log perf, byte thô, ảnh chụp, chữ đọc lại) không đưa lên repo, kể cả khi đã lọc hết thông tin cá nhân: chúng ở `build/` (git bỏ qua) và dọn theo luật dọn dẹp; repo chỉ giữ kết luận, số đo đã tổng hợp và lệnh để chạy lại. Không đặt giới hạn kích thước hay độ dài cho tài liệu; giữ tài liệu gọn bằng cách sắp xếp nội dung.
- **Sửa commit chưa push thì gộp vào nó** (`git commit --fixup` rồi `git rebase --autosquash` hoặc `git reset --soft` khi là các commit cuối), không thêm commit "sửa lại"; lịch sử không giữ câu sai đã sửa trước khi push. Trước mỗi lần push, xem `git log origin/main..` và chỉ gộp commit sửa commit khác; các thay đổi khác mục đích giữ riêng. Không bao giờ viết lại `main` đã push (lý do: `docs/Releasing.md`, đoạn "Số build").
- **Commit khi subagent đang chạy:** dùng `git commit --only <paths>` để không cuốn theo file subagent đã stage; dặn subagent làm như vậy.

## Lệnh thường dùng

Mọi script và tác dụng phụ: [`scripts/README.md`](scripts/README.md); tuỳ chọn ghi ở đầu từng script. Mọi bộ test: [CONTRIBUTING.md](CONTRIBUTING.md), mục "Chạy test".

- `brew install xcodegen && xcodegen generate` — sinh `Dau.xcodeproj`.
- `scripts/dev/doctor.sh` — máy thiếu gì để build, test, chạy Dấu, kèm lệnh sửa; không đổi gì trên hệ thống.
- `scripts/dev/dau-version.sh` — bộ gõ đã cài và đang chạy có phải bản mới nhất của `main` không (so đầu vào build và Xcode, không chỉ so commit).
- `scripts/dev/install-app.sh` — script cài duy nhất: build Dấu.app và đặt vào `/Applications`; Dấu.app đó thay bộ gõ đã cài (D37 (Cài bộ gõ)). `--ref main` cài bản dùng hằng ngày (bản Release của commit mới nhất trên `main`).
- `swift test --package-path Packages/DauEngine` — test engine; `--package-path Apps/Dau/Tests` cho app chủ.
- `scripts/check-l10n/check.sh` — kiểm String Catalog (D41).
