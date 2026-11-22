# Tương thích: lỗi đã sửa và lượt chạy ma trận 30/10/2026

Chuyển từ [`docs/Compatibility.md`](../Compatibility.md) ngày 11/11/2026 (mục cũ 5.1, 6.4, 6.6, 6.7): các lỗi đã sửa kèm chẩn đoán và nhật ký lượt chạy ma trận M3. Hiện trạng tương thích ở `docs/Compatibility.md`.

## Lượt chạy ma trận ngày 30/10/2026 (mục cũ 5.1)

- Máy: macOS 27.2, Apple M1 Pro; bộ gõ Debug đã cài ở HEAD 96a3e41.
- Tự gõ bằng `scripts/selftest/typing/run.sh` (thêm `edge`, `firefox`, `notes`, `mail` trong lượt này).
- Phím chỉ gửi khi app thử đứng trước; không nhấn Return ở đâu; không gửi thư hay tin nhắn.
- Mỗi app:
  - Chữ đúng: câu mẫu ở 30 ms và 0 ms; app sai ở 0 ms (hoặc trong danh sách đề xuất) thử thêm 0 ms với `--underline`, 5 và 10 ms.
  - Backspace: `--keys "hoaf⌫ " --expect "hò "` (30 ms).
  - Thêm dấu cho từ đã gõ: `--delay 120 --keys "hoc ⌫j " --expect "học "`.
  - Tự sửa chính tả: `--keys "tooi yeeu tieengs Vieetj, Sunrise carr " --expect "tôi yêu tiếng Việt, Sunrise car "` (30 ms).
  - Số µs lấy từ báo cáo `perf-report.sh` mà script in cho lượt 30 ms (p50 / p99).
- Trình duyệt thử trên trang cục bộ có `spellcheck="false"`, nên phép thử tự sửa chính tả ở đây không nói gì về tự sửa của trình duyệt khi gõ trên web thật.
- Người dùng dừng lượt thử sau Mail (kiểm chữ đúng ở 30 ms). Chưa thử trong lượt này: Mail (phần còn lại), Messages, Pages, Numbers, Zalo, Discord, Ghostty, Zed, Xcode, WebStorm; kiểm chứng lại Terminal không gửi ⌫ cho bộ gõ cũng chưa chạy.
- Dọn dẹp: tab thử đã đóng; ghi chú thử trong Notes đã xoá trắng và Notes bỏ ghi chú trống; thư nháp đóng bằng "Don’t Save"; Notes, Mail, Firefox đã thoát, Edge còn chạy không cửa sổ; script khôi phục nguồn nhập liệu và clipboard; khoá `DauDebugForceUnderline` đã xoá.

## Backspace thay chữ tại chỗ bị xoá hai lần trong Chromium/Electron (D32 (Backspace)), mục cũ 6.4

Ghi ngày 30/10/2026, đã sửa cùng ngày.

- Hiện tượng (bản cbb8179): ở Chrome, Edge, VS Code, gõ `hoaf` ("hoà") rồi ⌫ ra "h" thay vì "hò", ở cả 30 và 120 ms/phím. Không gặp ở TextEdit, Safari, Firefox, Notes; chế độ gạch chân (D13 (Gạch chân là đường lui cuối cùng)) ở Edge đúng.
- **Nguyên nhân (đã kiểm chứng):** ứng dụng Chromium tự chạy lệnh xoá của mình cho phím ⌫ dù bộ gõ đã nuốt phím. Không phải `selectedRange` cũ, không phải đường đọc D20 (Thêm dấu cho từ đã gõ).
  - Log `diag`/`perf` của lượt chạy ma trận (Debug, 120 ms/phím, chỉ số):
    - Phím ⌫ ở Chrome là `key kind=replace … read_ns=-1` và `replace kind=replace del=2 sel=3,0 expected=3 rep=1,2 ins_len=1 after=3,0 after_expected=2`; VS Code (30 ms) và Edge giống hệt.
    - Vị trí hỏi được đúng bằng dự đoán (`sel=3` = `expected=3`), vùng thay đúng (`rep=1,2` = "oà" → "ò"), không có lần đọc D20 (`read_ns=-1`, không có kind `seed*`).
    - TextEdit, Safari, Notes cùng dòng đó trừ `after=2,0` (ứng dụng áp ngay).
    - Firefox `after=3,0` (bất đồng bộ) mà vẫn ra "hò", nên bất đồng bộ không phải nguyên nhân.
    - Kết quả "h" = "hò" mất thêm đúng một chữ.
  - Mã Chromium (`content/app_shim_remote_cocoa/render_widget_host_view_cocoa.mm`, `keyEvent:`, nhánh chính lúc đó):
    - Sau `interpretKeyEvents:`, nếu không có marked text và chữ chờ chèn không quá 1 ký tự, Chromium luôn gửi phím gốc (RawKeyDown) cho trang bằng `ForwardKeyboardEventWithCommands`, không xét bộ gõ có nuốt phím hay không.
    - `insertText` có `replacementRange` thì được gửi ngay (`ImeCommitText`), tức là trước phím gốc.
    - Với chữ cái, RawKeyDown không làm gì; với ⌫, trang xoá một chữ.
    - Khi có marked text, Chromium gửi phím giả VKEY_PROCESSKEY thay cho phím gốc, nên gạch chân không bị.
- **Cách sửa (M3, `InPlaceComposer`):** ⌫ cần đặt lại dấu thì không nuốt phím ở mọi ứng dụng.
  - Lệnh xoá của chính ứng dụng bỏ chữ cuối, còn bộ gõ thay phần còn lại và trả chữ cuối về đúng chỗ để lệnh xoá đó lấy đi ("hoà": thay "oà" bằng "òà" → ứng dụng xoá "à" → "hò").
  - Vẫn một `selectedRange` và một `insertText` như trước (N3 (Ít lời gọi vào ứng dụng đích)); D32 giữ nguyên.
  - Cần thứ tự: chữ của bộ gõ được áp trước lệnh xoá. Ứng dụng AppKit áp `insertText` trước khi `handle` trả về; Chromium gửi `ImeCommitText` trước phím gốc. Nếu thứ tự ngược ở một ứng dụng nào đó, phím có thay chữ kế tiếp thấy lệch (D11 (Kiểm tra ngữ cảnh)) và reset.
- Kết quả sau khi sửa (Debug, 30/10/2026, 82d9ecc):
  - `hoaf⌫ ` → "hò" ở 120 ms: TextEdit, Safari, Chrome, VS Code, Edge PASS (replace 2, mismatch 0).
  - Chạy lại ở 30 ms: `hoaf⌫ ` → "hò", `vieetj⌫⌫ ` → "vị", `tieengs⌫⌫ ` → "tiế" PASS ở cả 6 app (TextEdit, Safari, Chrome, VS Code, Edge, Firefox); câu mẫu ở 30 ms PASS ở cả 6 app.
  - `vieetj⌫s ` → "việs" ở 120 ms PASS (TextEdit, Chrome, Firefox).
- Test: `InPlaceComposerTests` có client giả kiểu Chromium (`deletesConsumedBackspace`: luôn xoá sau `insertText`) và kiểu AppKit, chạy cùng các chuỗi ⌫; thêm ca ảnh chụp cũ (phím cách 10 ms, ứng dụng trễ 50 ms): D11 bắt lệch, chỉ mất dấu, không mất chữ.

## Biểu tượng nguồn nhập liệu trên máy nhiều màn hình (mục cũ 6.6)

Ghi ngày 30/10/2026, đã sửa cùng ngày.

- Triệu chứng: trên máy hai màn hình, thanh menu tối ở màn hình phụ (biểu tượng hệ thống màu trắng) vẫn hiện ô V của Dấu màu đen.
- Nguyên nhân: lúc đầu tưởng là giới hạn của macOS với ảnh template của bộ gõ bên ngoài; thực ra cùng nguyên nhân với mục dưới: `TISIconIsTemplate` chỉ khai ở cấp bundle, cờ của input mode là false.
- Kết quả: sau b4f2cbe (cờ ở cấp mode), chụp cả hai màn hình: ô V xám trên thanh menu sáng, trắng trên thanh menu tối, giống các biểu tượng hệ thống bên cạnh.

## Chỉ báo ⌃Space dưới con trỏ trống (mục cũ 6.7)

Ghi ngày 30/10/2026, đã sửa cùng ngày.

- Hiện tượng (đến 7a6f087): chuyển nguồn bằng ⌃Space, bong bóng xanh dưới con trỏ hiện "A" cho U.S. nhưng trống cho Dấu.
- Nguyên nhân (đọc bằng lldb và gọi thử lớp riêng `KLInputSourceIconManager` của `KeyboardLayouts.framework`, macOS 27.2):
  - Bong bóng do `CursorUIViewService` (TextInputUIMacHelper) vẽ, lấy ảnh từ `indicatorImageForInputSource:`.
  - Nhãn chữ ("A", "VI", "VI TX") lấy từ bảng `KLDynamicInputSourceIconTable` dựng sẵn trong framework, khoá theo ID nguồn của Apple (291 mục); `TISIconLabels` trong Info.plist không được đọc cho bộ gõ bên ngoài.
  - Nguồn không có trong bảng thì dùng ảnh TIS `TSMInputSourcePropertyIconImage` và cờ `TSMInputSourcePropertyIconShouldBeTemplate`.
  - Cờ này của input mode `….Dau.vi` là `false` dù `TISIconIsTemplate` đặt ở cấp bundle (nguồn cấp bundle thì `true`); với ảnh không phải template, bong bóng trống.
- Cách sửa: thêm `TISIconIsTemplate = true` vào từ điển của input mode.
  - Cờ TIS đổi ngay khi cài lại, không cần đăng xuất.
  - Bong bóng hiện ô V trắng khoét chữ (cùng ảnh thanh menu), không phải chữ trần như "A": hệ thống không cho bộ gõ bên ngoài nhãn chữ.
- Kiểm chứng (TextEdit, ⌃Space Dấu → U.S. → Dấu, chụp 0,25 s sau phím):
  - Có khoá ở mode: hiện V. Bỏ khoá (đối chứng, cùng cách khởi động lại dịch vụ): trống. Thanh menu hai màn hình vẫn đúng.
  - `CursorUIViewService` giữ ảnh cũ trong bộ nhớ đệm và bỏ qua SIGTERM: máy đã cài bản cũ thấy V sau khi đăng xuất hoặc `killall -9 CursorUIViewService` (dịch vụ tự chạy lại).
- Không thử (không cần sau khi tìm ra nguyên nhân): ảnh PDF, `TISIconLabels` cấp bundle, nhãn bản địa hoá. Chuyển sang IMK extension (`.appex`) có lẽ cũng không cho nhãn chữ, vì bảng nhãn khoá theo ID của Apple (suy luận, chưa thử).

## Safari: ⌫ rồi phím dấu ngay sau khi trang bận (mục cũ 6.9)

Ghi ngày 22/11/2026, đã sửa cùng ngày.

- Triệu chứng: sau khi Dấu tự chèn mọi ký tự (N3), ở Safari khi trang bận, ⌫ (vẫn đi thẳng) có thể chờ trong hàng phím của WebKit và bị lời gọi kế của bộ gõ vượt, nên phím dấu gõ ngay sau ⌫ không được thêm cho từ trước (D20 không áp). Ví dụ: "Hoc ⌫j" ra "Hocj" (1/3 lượt ở nhịp người gõ nhanh), "khoong⌫g" ra "khôngg kó" hoặc "khôngg khó" (2/3 lượt ở trang bận 10 ms). Chữ không bị xáo.
- Nguyên nhân: mọi sự kiện phím vào hàng của WebKit, còn lời gọi của bộ gõ tới trang ngay (`docs/research/LateAnswerFixes.md` mục 5.1).
- Kết quả: ngoại lệ "Ngoại lệ sau ⌫ chưa áp" của N3 (chờ ⌫ áp xong, hạn 20 ms, cho mọi app) đúng 3/3 ở cả hai ô; số đo ở [`docs/Compatibility.md`](../Compatibility.md) mục 5.1.

## Safari và Chrome khi phím dồn hay trang bận, trước khi Dấu tự chèn ký tự (mục cũ 5.1, 5.2)

Chuyển từ `docs/Compatibility.md` ngày 22/11/2026. Các lỗi dưới đây hết khi Dấu tự chèn mọi ký tự engine để nguyên (N3, 22/11/2026); hiện trạng ở `docs/Compatibility.md` mục 5.1, 5.2.

### Safari (mục cũ 5.1)

- Safari 27.2 (17/11/2026, bản Debug của `8d3e93a`, máy M1, chuyển nguồn bằng phím tắt hệ thống, có xác nhận trong ô): chuỗi `std` ở 5 ms đúng 2/3; Telex của Apple cùng điều kiện đúng (hợp lệ). Lượt sai hỏng đúng từ đầu ("Chiều" ra "hieCeuf"). Log: ở lần thay đầu của tài liệu mới, Safari trả vị trí chậm (`selectedRange` 2, Dấu theo dõi 4, `kind=late`). Cùng dấu hiệu với ý "Nguyên nhân" dưới đây (chữ C dời chỗ, Safari chậm 2 thao tác); chưa đo riêng. Mô hình test: `stalledStartTable`, `typedHere`.
- Safari 27.2 (18/11/2026, máy M3 Max, bản Debug của `f0a9102`, chuỗi `edit`, nhịp 5, 10, 20 ms, 3 lượt mỗi nhịp, hai bản có và không có ngưỡng 50 ms của D11): trang rảnh đúng 18/18; trang bận (`--busy 300:1000`) sai 9/9 với bản đang dùng, Telex của Apple cùng điều kiện ra đúng chữ của chính nó.
- Tốc độ cao nhất khi máy và trang rảnh, trước khi Dấu tự chèn ký tự (18/11/2026, máy M1 Pro, macOS 27.2.1, CPU rảnh khoảng 75%; bản Debug của `3aad4e2`; Safari 27.2, Chrome 157.0.8103.79, VS Code 1.146.0; 3 lượt mỗi ô, mỗi lượt gõ cả ba app). Khoảng cách thật giữa hai phím tới bộ gõ đọc từ `t_ns` trong log Debug:

  | Chuỗi, nhịp đặt | Khoảng cách thật p10 / p50 (ms) | Safari | Chrome | VS Code |
  |---|---|---|---|---|
  | `edit`, 20 ms | 25–26 / 29–32 | 3/3 | 3/3 | 3/3 |
  | `edit`, 10 ms | 8–14 / 17 | 3/3 | 3/3 | 3/3 |
  | `edit`, 5 ms | 6–7 / 9–10 | 3/3 | 3/3 | 3/3 |
  | `edit`, 0 ms (từng phím, không nghỉ; chuỗi có ⌫) | 6–7 / 8,5–8,7 | 3/3 | 3/3 | 3/3 |
  | `std`, 0 ms (cả chuỗi một lần) | Safari 0,06 / 0,11; Chrome, VS Code 0,9 / 1,4 | sai 3/3 | 3/3 | 3/3 |
  | `std`, 0 ms, gạch chân (`--underline`) | Safari 0,48 / 0,72 | chữ đúng 3/3, dấu cách dời chỗ 2/3 | — | — |

  - Gửi từng phím, System Events không nhanh hơn khoảng 8,5 ms một phím (p50), tức khoảng 118 phím mỗi giây, nhiều lần nhanh hơn người gõ nhanh nhất; ở mọi nhịp đó Dấu đúng ở cả ba app và không có lần `mismatch` nào.
  - Gửi cả chuỗi một lần (không là tiêu chí, D13): Safari đưa phím tới bộ gõ dồn cả loạt, dưới 0,2 ms một phím. Dấu sai nhiều từ mỗi lượt (`count_mismatch` 9, 9, 4). Telex của Apple cùng điều kiện ra đúng các chữ của chính nó ("mêting", D4) ở 3/3 lượt, lượt đầu mất một dấu cách ("uốngcà"), nên ô hợp lệ và lỗi là của Dấu. Chrome và VS Code đưa phím cách nhau khoảng 1,4 ms và Dấu đúng. Cùng kiểu dồn phím như lúc trang bận ở trên (dưới 2 ms, cùng dấu thời gian): ca này tái hiện được ở trang rảnh, không cần `--busy`.
  - Cùng ô ở chế độ gạch chân (bản Debug của `555ee2f`, 3 lượt, phím cách nhau khoảng 0,7 ms): mọi chữ đúng; 2/3 lượt có dấu cách dời sang sau chữ kế ("không,mình đi  uống"), cùng loại với dấu cách Telex của Apple làm mất. Dấu cách là phím duy nhất đi thẳng ở chế độ này; nguyên nhân ở ý "Nguyên nhân" dưới đây.
  - Lệnh: `typing/run.sh --delay 20|10|5|0 --keys "$(scripts/selftest/load/run.sh --text edit --print keys)" --expect "$(… --print expect)" safari chrome vscode`; dòng cuối với `--text std`, đối chứng thêm `--source com.apple.inputmethod.VietnameseIM.VietnameseTelex`.
  - Chẩn đoán (18/11/2026, 3 lượt 10 ms): khác Chrome. Safari dồn phím: mỗi lượt khoảng 59 phím tới bộ gõ cách nhau dưới 2 ms, cùng dấu thời gian, sau những quãng trang bị chặn. Chỉ 1 lần mỗi lượt Dấu tin vị trí cũ chậm từ 3 ký tự, nhưng mỗi lượt có 3–4 lần Safari báo vị trí **vượt** vị trí Dấu theo dõi, điều mà một app chỉ trả lời chậm không làm ra. Nguyên nhân ở ý dưới. Nhịp người gõ nhanh (cùng điều kiện như Chrome ở mục 5.2): sai 2/3, mỗi lượt vài từ.
  - Nguyên nhân của lỗi trước đây (18/11/2026, máy M1 Pro, macOS 27.2.1, Safari 27.2, bản Debug của `6e7d83d`, 16:32–16:35): Safari không áp các thao tác theo thứ tự phím. Theo mã WebKit (nhánh main, `WebViewImpl::keyDown/keyUp` và `WebPageProxy::handleKeyboardEvent`, đọc 18 và 22/11/2026; [`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md) mục 5), mọi sự kiện phím (nhấn và nhả, bộ gõ đã xử lý hay chưa) vào một hàng đợi ở tiến trình giao diện; hàng này gửi trang mỗi lần một sự kiện và chỉ gửi sự kiện sau khi trang xử lý xong sự kiện trước. Chỉ phím bộ gõ trả `false` mới mang chữ tới trang. Còn `insertText`, `selectedRange` và lần đọc chữ của bộ gõ đi tới trang ngay, vượt các sự kiện đang chờ. Khi trang chưa nhận kịp (phím dồn hay trang bận), phím để đi thẳng phải chờ; lần thay của Dấu tới trang trước chúng, nên các chữ đó rơi ra sau chữ vừa thay, và vì mỗi lần thay sau đặt con trỏ ở cuối vùng thay, chúng bị đẩy dần về cuối văn bản. Giả thuyết này giải thích mọi quan sát:
    - Chữ hỏng là chữ của phím đi thẳng bị dời chỗ, không thừa không mất: trang bận, "phải viết" ra "phảiết" và "vie" ở cuối văn bản; "meeting chiều" ra "meeting gchiều"; gửi cả chuỗi một lần, cuối văn bản là một dãy chữ cái của các từ đầu câu.
    - Log: mỗi từ hỏng ở trang bận đúng là chỗ một lần thay `late` (Safari chậm 4 thao tác, phép chứng minh của D11 qua) có vị trí đọc ngay sau khi thay (`after`, chỉ bản Debug hỏi) **vượt** vị trí Dấu theo dõi: 1 lần ở mỗi lượt có chữ dời, 0 lần ở lượt không có. Gửi cả chuỗi một lần: 13–16 lần mỗi lượt.
    - Chrome áp phím và lời gọi của bộ gõ theo cùng một hàng (theo mã Chromium, ghi ở `LateDocument` trong test). Cùng ô ở Chrome đúng.
    - Chế độ gạch chân: chữ cái nằm trong chữ gạch chân (lời gọi của bộ gõ, theo thứ tự) nên đúng; dấu cách đi thẳng nên dời chỗ. Telex của Apple cũng gạch chân và cũng có lúc mất dấu cách.
    - Hai giả thuyết bị loại: (a) Safari tự chèn thêm một phím: chữ không thừa và gạch chân đúng mọi chữ cái; (b) Safari áp vùng thay `late` lên chữ đã đổi: đúng là điều xảy ra, nhưng là hệ quả, vì chữ đổi do phím đi thẳng tới sau.

### Chrome (mục cũ 5.2)

- Phím dồn khi trang bận (18/11/2026, máy M3 Max, Chrome 157.0.8103.79, bản Debug của `f0a9102`, chuỗi `edit`, nhịp 5, 10, 20 ms, `--busy 300:1000`, 3 lượt mỗi nhịp): Chrome sai 9/9, chữ hỏng nhiều chỗ ("bạửigui", "projecả"); Telex của Apple cùng điều kiện ra đúng chữ của chính nó lúc trang rảnh ở cả 3 nhịp, nên trang không làm rơi phím. Cùng lượt, lúc trang rảnh: đúng 18/18. Edge, Firefox chưa đo.
  - Chẩn đoán (18/11/2026, bản Debug của `f0a9102`, 10 ms, 3 lượt trang bận và 1 lượt 100 ± 30 ms trang bận làm đối chứng): phím tới bộ gõ đều, khoảng 17 ms một phím (không dồn). Trang bận làm Chrome trả vị trí chậm tới 12 ký tự. Phép chứng minh app chậm của D11 nhận ra phần lớn các lần chậm (`late`). Lỗi nằm ở các lần phép chứng minh không qua, ở lần thay đầu của một từ, khi vị trí chậm từ 3 ký tự trở lên: quá `CursorTracker.lateLimit` (2) nên Dấu không đoán là app chậm, mà tin vị trí cũ và thay chữ lùi về đó (`kind=replace`, vị trí app báo nhỏ hơn vị trí Dấu theo dõi). Ví dụ "bạn gửi" ra "bạửigui": Dấu ở 26, Chrome báo 23, Dấu thay ở 21–23. Số lần như vậy đi cùng mức hỏng: 3, 4, 6 lần cho khoảng cách chỉnh sửa 11, 10, 21; lượt 100 ms không có lần nào và đúng. Sau mỗi lần thay sai, vị trí Dấu theo dõi lệch theo nên các lần sau cũng lệch. Nguyên nhân gốc (log Debug có các con số của phép chứng minh): độ chậm chấp nhận được là `lateLimit` cộng số phím dồn liền nhau, mà số đó về 0 ở mỗi chỗ ngắt từ (50–60 ms) trong khi Chrome vẫn chậm; hướng sửa đã thử ở [`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md) mục 3.
  - Sửa ở commit `d171ab9` (18/11/2026): ở phím thay chữ trong từ, app được chậm mọi thao tác kể từ lần cuối nó trả lời đúng lúc. Chrome trang bận, nhịp người gõ nhanh: sai 2/6 lượt, tổng khoảng cách chỉnh sửa 7 (bản trước 4/6, 14); 10 ms: khoảng 1,7 mỗi lượt (bản trước khoảng 10); trang rảnh đúng. Số và các ca còn lại: [`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md) mục 3.3.
  - Nhịp người gõ nhanh (18/11/2026, Dấu Release `0b1a42d`, `--delay 40 --jitter 20 --word-pause 150`, trang bận, 3 lượt): Chrome sai 2/3, mỗi lượt một từ ("ngùii", "mêting"); Telex của Apple cùng điều kiện ra cùng chữ ở Chrome và Safari.
