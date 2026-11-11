# Tương thích: lỗi đã sửa và lượt chạy ma trận 30/10/2026

Chuyển từ [`docs/Compatibility.md`](../Compatibility.md) ngày 11/11/2026 (mục cũ 5.1, 6.4, 6.6, 6.7): các lỗi đã sửa kèm chẩn đoán, và nhật ký lượt chạy ma trận M3. Hiện trạng tương thích ở `docs/Compatibility.md`.

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
- Dọn dẹp: tab thử đã đóng; ghi chú thử trong Notes đã xoá trắng và Notes bỏ ghi chú trống; thư nháp đóng bằng "Don’t Save"; Notes, Mail, Firefox đã thoát, Edge còn chạy không cửa sổ; nguồn nhập liệu và clipboard được script khôi phục; khoá `DauDebugForceUnderline` đã xoá.

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
  - `CursorUIViewService` giữ ảnh cũ trong bộ nhớ đệm và bỏ qua SIGTERM: máy đã cài bản cũ thấy V sau khi đăng xuất, hoặc `killall -9 CursorUIViewService` (dịch vụ tự chạy lại).
- Không thử (không cần sau khi tìm ra nguyên nhân): ảnh PDF, `TISIconLabels` cấp bundle, nhãn bản địa hoá. Chuyển sang IMK extension (`.appex`) có lẽ cũng không cho nhãn chữ, vì bảng nhãn khoá theo ID của Apple (suy luận, chưa thử).
