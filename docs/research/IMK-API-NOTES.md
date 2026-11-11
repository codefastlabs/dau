# Ghi chú API InputMethodKit

Những gì tài liệu và header chính thức của Apple nói về các API mà bộ gõ của Dấu dùng (`Apps/DauInputMethod`), và hệ quả cho các quyết định. Chỉ ghi điều có nguồn; chỗ suy luận ghi rõ.

## Hiện trạng (11/11/2026)

- Header đọc trong Xcode 27.1, SDK `MacOSX27.0.sdk`, lúc làm M2 (Bộ gõ tối thiểu) và M3 (Độ tin cậy); chưa đọc lại trên SDK mới hơn. Chuyển nguyên từ `docs/research/OPENKEY-NOTES.md` ngày 11/11/2026 vì không thuộc OpenKey.
- Hệ quả chính:
  - Tham số của IMK có thể nil, và `NSEvent.characters` ném ngoại lệ trên sự kiện không phải phím: cơ sở của D18 (Phòng thủ với IMK).
  - Ứng dụng không hỗ trợ TSMDocumentAccess bỏ qua `replacementRange` và trả `NSNotFound` cho `selectedRange()`: ở đó thay chữ tại chỗ không thể đúng, cần marked text (D13 (Gạch chân là đường lui cuối cùng)).
  - Phạm vi tính theo UTF-16; chữ đọc từ ứng dụng ở dạng NFD được tính đúng khi thay.
- Chưa đo: `overrideKeyboard(withKeyboardNamed:)` và bố cục không phải QWERTY.

## API

- `IMKServerInput.handle(_:client:)`: tham số `NSEvent!` và `Any!` (kiểu tự mở có thể nil).
  - Trả `true` nếu đã xử lý sự kiện, `false` để hệ thống xử lý.
  - Phương thức nhận cả sự kiện phím xuống lẫn chuột, nên chuột là tín hiệu reset (D11 (Kiểm tra ngữ cảnh)).
  - Tham số có thể nil cũng là cơ sở cho D18 (Phòng thủ với IMK).
  - https://developer.apple.com/documentation/objectivec/nsobject-swift.class/handle(_:client:) và https://developer.apple.com/documentation/inputmethodkit/imkserverinput
- `NSEvent.characters` **ném `NSInternalInconsistencyException`** nếu đọc trên sự kiện không phải phím.
  - Với phím chết (dead key, ví dụ ⌥e) nó là chuỗi rỗng.
  - Phải kiểm tra loại sự kiện trước khi đọc (D18).
  - https://developer.apple.com/documentation/appkit/nsevent/characters
- `NSEvent.keyCode` là mã phím ảo, không phụ thuộc phần cứng. Còn `characters` được suy ra từ bảng ánh xạ bàn phím. Dấu dùng ký tự thay cho mã phím để tránh lỗi B17 của OpenKey ([`docs/research/OPENKEY-NOTES.md`](OPENKEY-NOTES.md) mục 3). https://developer.apple.com/documentation/appkit/nsevent/keycode
- `IMKTextInput` (header `HIToolbox.framework/Headers/IMKInputSession.h`; trang tài liệu web của protocol này trả 404 khi tra):
  - `insertText(_:replacementRange:)`: `replacementRange` tính từ đầu tài liệu của client. Truyền `NSNotFound` thì chèn tại vùng chọn hiện tại.
    - **Nếu client không hỗ trợ TSMDocumentAccess thì `replacementRange` bị bỏ qua.**
    - Đây là dữ kiện trực tiếp cho câu hỏi vị trí thay chữ (hỏi con trỏ ở mỗi phím hay tự cộng dồn vị trí; đã chốt hỏi ở mỗi phím, D11) và cho D13: ở các ứng dụng như vậy, thay chữ tại chỗ không thể đúng, cần marked text.
  - `selectedRange()` trả `{NSNotFound, NSNotFound}` nếu client không hỗ trợ TSMDocumentAccess.
  - `attributedSubstring(from:)` có thể trả chuỗi dài hơn hoặc ngắn hơn phạm vi yêu cầu khi phạm vi cắt ngang một cặp surrogate. "Thêm dấu cho từ đã gõ" (D20 (Thêm dấu cho từ đã gõ)) phải kiểm tra độ dài.
  - `setMarkedText(_:selectionRange:replacementRange:)`: chuỗi thường sẽ có gạch chân mặc định (D13).
  - `overrideKeyboard(withKeyboardNamed:)`: input method có thể chỉ định bố cục bàn phím dùng để dịch phím, và "nên gọi mỗi lần được kích hoạt".
    - Chưa đo: nếu không gọi thì ký tự Dấu nhận được theo bố cục nào, và người dùng Dvorak gõ Telex ra sao.
- `IMKStateSetting.recognizedEvents(_:)` quyết định loại sự kiện bộ gõ nhận được. Nếu cần biết Shift/Caps riêng thì phải xét mask này (suy luận). https://developer.apple.com/documentation/inputmethodkit/imkstatesetting
- `NSTextInputClient.insertText(_:replacementRange:)` (phía ứng dụng): "chỉ phù hợp cho văn bản do người dùng gõ" và yêu cầu view cho phép sửa. https://developer.apple.com/documentation/appkit/nstextinputclient/inserttext(_:replacementrange:)
- Phạm vi `NSRange` tính theo đơn vị UTF-16.
  - Chữ Việt dựng sẵn (NFC) đều nằm trong BMP nên một chữ = một đơn vị.
  - Nhưng nếu ứng dụng lưu chữ ở dạng tổ hợp (NFD) thì số đơn vị khác số chữ, và `deleteCount` của engine phải đổi cho đúng. Đã xử lý: chữ đọc từ ứng dụng ở dạng NFD được tính đúng khi thay (test `SeedTests`).
