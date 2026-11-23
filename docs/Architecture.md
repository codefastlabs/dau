# Kiến trúc

## Phạm vi

Tài liệu này tả cấu trúc của Dấu: thành phần nào làm gì, chúng gọi nhau ra sao và một phím đi qua những đâu. Luật và lý do nằm ở [`docs/Decisions.md`](Decisions.md); tài liệu này chỉ dẫn số D/N. Tài liệu này cũng không chứa số đo; hằng số có tên trong mã là giá trị cấu hình, không phải số đo. Số đo theo ngày nằm ở `docs/Progress.md` cho mốc đang làm và ở `docs/history/` cho mốc đã đóng; bảng "Số đo (M1–M3)" nằm ở `docs/history/LogM0ToM4.md`. Số đo giao diện nằm ở `docs/research/SystemSettingsReference.md`. Lịch sử các thay đổi của tài liệu nằm ở `docs/history/DocsLog.md`.

```
dau/
├─ .claude/agents/             # subagent: researcher, engine-dev, imk-dev, app-ui-dev, release-eng, web-dev, auditor
├─ .claude/commands/           # /milestone, /audit, /dogfood
├─ project.yml                 # XcodeGen → Dau.xcodeproj
├─ Packages/
│  ├─ DauEngine/               # Swift package thuần, không Foundation/AppKit
│  │  ├─ Sources/DauEngine/    # VietEngine, bảng nguyên âm/dấu, quy tắc chính tả
│  │  └─ Tests/                # Swift Testing: ca Telex/VNI, ca biên, fuzz, hiệu năng
│  └─ DauShared/               # model cài đặt chung, App Group + Darwin notification, xem trước bằng engine thật, danh sách tương thích
├─ Apps/
│  ├─ DauInputMethod/          # bộ gõ (IMK), sandbox, không quyền mạng (N2 (Bộ gõ không có quyền mạng))
│  └─ Dau/                     # app chủ SwiftUI, không sandbox (D37 (Cài bộ gõ)): Cài đặt, onboarding, cài/thay/gỡ bộ gõ, cập nhật (Sparkle), báo lỗi
├─ Config/                     # xcconfig ký mã (Signing.xcconfig, Local.xcconfig.example)
├─ Resources/Brand/            # file nhận diện gốc (docs/Brand.md)
├─ scripts/                    # script build, đo, phát hành: scripts/README.md
├─ site/                       # trang web; tới M8 chỉ có appcast.xml (docs/Releasing.md)
├─ .github/                    # GitHub Actions và mẫu issue (docs/Releasing.md)
└─ docs/                       # mục lục: docs/README.md
```

## Tổng quan

Dấu chạy thành hai tiến trình, nối với nhau chỉ qua App Group và thông báo Darwin.

```
┌──────────────────────── Dấu.app (app chủ, không sandbox) ───────────────────────┐
│ Cài đặt · onboarding · cài/bật/thay/gỡ bộ gõ                                    │
│ Contents/Library/Input Methods/DauInputMethod.app  (bản nhúng)                  │
└──────┬──────────────────────────────┬──────────────────────────────┬────────────┘
       │ ghi cài đặt                  │ phát <suite>.settingsDidChange │ chép, đổi chỗ, phát
       ▼                              ▼                              ▼ <bundle ID>.quitRequested
┌─────────────────────┐   ┌──────────────────────────┐   ┌──────────────────────────────────────┐
│ App Group (suite    │◀──│ thông báo Darwin         │──▶│ ~/Library/Input Methods/             │
│ UserDefaults, khoá  │   │ (không mang dữ liệu)     │   │ DauInputMethod.app (bộ gõ, sandbox)  │
│ settings)           │──▶│                          │   │ IMK ⇄ app đang gõ (insertText…)      │
└─────────────────────┘   └──────────────────────────┘   └──────────────────────────────────────┘
```

- **App chủ** (`Apps/Dau`) chứa giao diện Cài đặt và onboarding, giữ mọi kết nối mạng (N2), cài, bật, thay và gỡ bộ gõ.
- **Bộ gõ** (`Apps/DauInputMethod`) là một tiến trình nền do macOS chạy khi có app cần. Bộ gõ nhận phím qua InputMethodKit và ghi chữ vào app đang gõ. Bộ gõ không dùng mạng và không đọc danh sách tương thích.
- **App Group:** toàn bộ cài đặt là một JSON trong suite chung. App chủ ghi cài đặt rồi phát thông báo Darwin; bộ gõ nghe thông báo và đọc lại.
- **Thông báo Darwin** chỉ là gợi ý để đọc lại trạng thái thật (D18 (Phòng thủ với IMK)), vì tiến trình nào cũng phát được nó. Dấu dùng thông báo Darwin cho hai việc: báo đổi cài đặt và yêu cầu thoát.
- Engine (`DauEngine`) là thư viện thuần. Bộ gõ dùng nó. Phần xem trước của app chủ cũng dùng nó (qua `DauShared`).

## Luồng một phím

1. IMK gọi `handle(event, client)` trên main thread. Event nil hay bất thường bị bỏ qua (D18).
2. Với phím điều khiển (mũi tên, tổ hợp ⌘/⌃/⌥, Esc…), phím chết và sự kiện mang nhiều ký tự (`KeyRouter`), bộ gõ reset engine và trả `false` để hệ thống xử lý. Trường hợp này không khôi phục từ (D4 (Từ nước ngoài)).
3. Với Backspace, engine bỏ chữ cuối đang hiển thị và đặt lại dấu (D32 (Backspace)). Phím luôn đi tiếp tới app để app tự xoá chữ cuối. Khi dấu phải dời, bộ gõ thay phần chữ đứng trước trong cùng phím đó (mục "Backspace thay tại chỗ").
4. Với ký tự, bộ gõ gọi `engine.handle(scalar)`.
   - Nếu engine trả `passThrough`, bộ gõ tự chèn ký tự đó tại con trỏ bằng `client.insertText(ký tự, replacementRange: NSNotFound)` và trả `true`. Bộ gõ không hỏi `selectedRange`, trừ ngay sau một ⌫ đi thẳng (mục "App trả lời chậm", ý "Chờ ⌫ chưa áp"). Nhờ vậy mọi thao tác chữ tới app qua cùng một đường, theo đúng thứ tự bộ gõ gọi (N3, ý "Vì sao Dấu tự chèn ký tự"). Cách này áp cho mọi app và cho mọi nhánh mà phím cuối cùng để nguyên: D4, D20, D30, D33 và các nhánh dựng lại hay reset của D11.
   - Nếu engine trả `replace(n, s)`, bộ gõ gọi `client.insertText(s, replacementRange: vùng n ký tự trước con trỏ)` và trả `true`.
   - Khi engine rỗng mà bộ gõ chưa biết chữ trước con trỏ, bộ gõ có thể đọc chữ của app trước (D20 (Thêm dấu cho từ đã gõ), mục "Thêm dấu cho từ đã gõ").
5. Với ký tự kết thúc từ (Space, dấu câu, Enter, Tab), nếu từ không phải âm tiết tiếng Việt hợp lệ thì bộ gõ khôi phục phím gốc (D4). Sau đó bộ gõ chốt từ và reset.

Các phím còn đi thẳng tới app (trả `false`) chỉ gồm ⌫ (bước 3), Return, Tab, Enter bàn phím số (bước 5, với `endWord()`, sau lần khôi phục nếu có) và các phím ở bước 2. Phím đến trong lúc bộ gõ còn đang xử lý phím trước cũng đi thẳng (mục "Đầu vào từ IMK", ý "Gọi ngược trong lúc xử lý"; N3).

Ở chế độ gạch chân (D13 (Gạch chân là đường lui cuối cùng)), bước 3–5 ghi chữ bằng marked text thay cho thay chữ tại chỗ (mục "Chế độ gạch chân").

## DauEngine

- `struct VietEngine: Sendable` giữ từ đang gõ trong một bộ đệm có dung lượng cố định.
  - Bộ đệm là `TextBuffer`; dung lượng và cách lưu ghi trong comment của kiểu này.
  - Engine không cấp phát bộ nhớ ở mỗi phím (số đo nằm ở bảng "Số đo (M1–M3)" trong `docs/history/LogM0ToM4.md`, dòng cấp phát).
- Mọi hàm của API đều là `mutating` và trả `Action`.
  - `handle(_ key: Unicode.Scalar)` nối chữ cái và chữ số vào từ. Ký tự in ra khác (Space, Enter, Tab, dấu câu) kết thúc từ (D4) và nằm luôn trong `insert`. Ký tự điều khiển, 0x7F và phím chức năng 0xF700–0xF8FF chỉ gây `reset()`.
  - `backspace()` (D32) là hàm IMK gọi cho phím xoá; bộ gõ **không** đưa 0x7F vào `handle`.
  - `endWord()` kết thúc từ mà không chèn ký tự. Hàm này dùng cho Return, Tab và Enter bàn phím số (0x03) khi IMK để app tự xử lý phím.
  - `seed(displayed:) -> Bool` (D20) nạp từ đọc được từ ứng dụng, ở dạng NFC hoặc NFD.
  - `seedOverflow(shown:)` (D20 ngoại lệ (b), D33 (Độ dài từ)) dùng cho từ có sẵn mà `seed` không nhận: engine vào trạng thái của D33 cho phần còn lại của từ, trong đó nó để nguyên mọi phím.
  - Ngoài ra còn có `reset()` và `isComposing`.
- `Action` là `.passThrough` (engine để nguyên phím) hoặc `.replace(deleteCount:insert: TextBuffer)`. Với một ký tự, `.passThrough` không có nghĩa là phím đi thẳng: bộ gõ tự chèn ký tự đó (N3 (Ít lời gọi vào ứng dụng đích), mục "Luồng một phím").
  - `.replace` xoá `deleteCount` **scalar** trước con trỏ và chèn `insert` trong một lần `insertText` (N3 (Ít lời gọi vào ứng dụng đích)).
  - Mọi chữ Việt dựng sẵn đều nằm trong BMP, nên số scalar bằng độ dài UTF-16. Ngoại lệ là từ seed từ NFD; khi đó IMK tự đo chuỗi đã seed.
- `EngineOptions` gồm kiểu gõ (`telex`, `simpleTelex`, `vni`), vị trí dấu (`modern`/`classic`), đặt dấu tự do (D28 (Đặt dấu tự do)), tự khôi phục (D4, D30 (Kiểm tra chính tả), D33) và `advanced: .off | .consonantShortcuts | .allowZFWJ`. `advanced` là một enum, nên hai mục của nó loại trừ nhau (D22 (Gõ tắt loại trừ z, f, w, j)).
- Đường nóng không dùng `String`, `any Protocol` hay closure và không import Foundation. Engine dựng thẳng ký tự NFC từ bảng (D3 (Không macro, chỉ Unicode dựng sẵn)) và không chuẩn hoá lúc chạy.
- `FuzzTests` (D18) và `PerformanceTests` chạy trong mọi lần `swift test --package-path Packages/DauEngine`. Ngưỡng của test hiệu năng đặt lỏng để bản Debug cũng đạt; số của bản Release đo bằng `swift test -c release --filter Performance`.

## DauShared

- DauShared phụ thuộc DauEngine để đổi cài đặt sang `EngineOptions` và chạy engine thật cho phần xem trước. DauShared không nằm trong đường nóng của engine.
- `DauSettings` là kiểu Sendable, Codable, có giá trị mặc định theo D15 (Cài đặt mặc định). `advanced` là một enum, nên không thể bật cả hai mục của D22.
- `AppRule` (D5 (Quy tắc theo ứng dụng), D13) gồm bundle ID, tên hiển thị, lựa chọn gạch chân và nguồn của quy tắc ("Đề xuất" hay người dùng). Quy tắc không có chế độ Việt/Anh.
- Dấu giải mã `DauSettings` và `AppRule` dễ dãi (D18). Khoá lạ hoặc khoá cũ (`rememberModePerApp`, `mode` của quy tắc) bị bỏ qua, quy tắc cũ giữ lựa chọn gạch chân. Lần lưu sau không ghi lại các khoá đó. Hệ quả là quy tắc cũ chỉ có "Tiếng Anh" trở thành quy tắc không làm gì. Dấu gõ tiếng Việt ở app đó mà không báo người dùng. Dấu chấp nhận hệ quả này vì chưa có bản phát hành nào.
- Khi giải mã, Dấu đọc tối đa `DauSettings.maxAppRules` quy tắc. Các quy tắc trùng bundle ID gộp lại trong O(n) (`DauSettings.merged`): quy tắc sau thắng nhưng giữ chỗ của quy tắc trước.
- `SettingsStore`:
  - `SettingsStore` lưu toàn bộ cài đặt thành một JSON dưới khoá `settings` trong UserDefaults suite = App Group (`DauAppGroupIdentifier` trong Info.plist, giá trị `$(TeamIdentifierPrefix)$(BUNDLE_ID_PREFIX).shared`).
  - Sau mỗi lần lưu, nó phát thông báo Darwin `<suite>.settingsDidChange`. `synchronize()` của suite này trả false dù ghi thành công, nên Dấu không dùng giá trị đó làm dấu hiệu lỗi.
  - `observeChanges` giúp bộ gõ áp dụng thay đổi ngay. Ai cũng phát được thông báo này, nên bộ gõ gộp các thông báo đến dồn thành một lần đọc (`ChangeCoalescer`, sau `ChangeCoalescer.delay`).
- `CompatibilityList` (D7 (Cập nhật và loại bản dựng), D13) là danh sách app mang nhãn "Đề xuất".
  - Mỗi mục có các bundle ID của một app, tên, cờ `suggestUnderline` và ghi chú cho người bảo trì; ghi chú không hiện lên giao diện (N5 (Chỉ hứa điều đã kiểm chứng)). Cả danh sách có một `version`.
  - Giải mã dễ dãi (D18). Khoá lạ bị bỏ qua. Mục hỏng hoặc không có bundle ID bị bỏ mà không làm mất các mục khác. File hỏng thành danh sách rỗng.
  - Bản có sẵn là `Apps/Dau/Resources/CompatibilityList.json`. App nào có mặt, cờ của nó và lý do nằm ngay trong file đó (`about`, `note`). Test trong DauShared đọc chính file này. App chủ lấy danh sách qua `CompatibilityList.bundled()`.
  - `DauSettings.suggestions(from:isInstalled:)` dựng các hàng "Đề xuất" từ những app đề xuất đã cài mà chưa có quy tắc đã lưu, theo thứ tự của danh sách và **không lưu** gì. "Bật gạch chân" gọi `acceptSuggestion`, hàm này lưu quy tắc "Có gạch chân" với nguồn `suggested` vào cuối "Quy tắc riêng".
  - "Quy tắc riêng" đúng bằng `appRules` đã lưu. `setUnderline(_:for:)` đổi lựa chọn trong popup mà vẫn giữ quy tắc và nguồn của nó; đặt về "Không gạch chân" vẫn là một quy tắc. Mọi quy tắc đã lưu đưa app ra khỏi "Đề xuất". Xoá quy tắc thì app trở lại.
  - Bộ gõ **không** đọc danh sách này; gạch chân chỉ theo quy tắc đã lưu (D13).
- `TypingPreview` và `TypingExample` chạy engine thật như bộ gõ. App chủ dùng chúng cho mọi ví dụ "phím → kết quả" trên giao diện (`SettingsSamples`, test ở `Apps/Dau/Tests`), nên mọi ví dụ đều do engine tính (N5).
- `InputMethodLifecycle` giữ tên thông báo yêu cầu thoát của bộ gõ, cùng cách phát và cách nghe thông báo đó (mục "Thoát theo yêu cầu của app chủ").

## Bộ gõ (DauInputMethod)

### Điều khiển và hai chế độ ghi chữ

- Bộ gõ dùng một lớp con của `IMKInputController`; mỗi client có một instance và một `VietEngine` riêng. Bộ gõ không có trạng thái toàn cục (khác OpenKey).
- `handle(_:client:)` đưa phím vào engine qua `InPlaceComposer` (thay tại chỗ) hoặc `MarkedComposer` (gạch chân). Cả hai là kiểu giá trị thuần và test bằng client giả.
- Khi thay tại chỗ và engine trả `replace`, bộ gõ hỏi `selectedRange` một lần để có vị trí tuyệt đối, rồi gọi `insertText(_:replacementRange:)` đúng một lần (N3). Khi engine để nguyên một ký tự, bộ gõ gọi một `insertText` của ký tự đó tại con trỏ (`NSNotFound`) và không hỏi `selectedRange`, trừ ngay sau một ⌫ đi thẳng (ý "Chờ ⌫ chưa áp"). Ở bản Debug, khi khoá `DauPerfLog` bật, bộ gõ hỏi thêm một `selectedRange` sau khi thay để chẩn đoán (`ReplaceDiag.swift`). Lời gọi này chạy sau khi đã ghi thời gian của phím, nên nó không nằm trong số đo (D42 (Ngưỡng hiệu năng)).
- Engine reset trong các trường hợp sau: click chuột; `activateServer`/`deactivateServer` và `commitComposition`; phím di chuyển con trỏ; `selectedRange` khác dự đoán mà không phải do app trả lời chậm (D11 (Kiểm tra ngữ cảnh)); và nguồn đầu vào đổi mà IMK không báo, nếu có đường như vậy (mục "Đổi nguồn đầu vào không qua `activateServer`").

### Vị trí thay chữ

Bảng dưới đây liệt kê toàn bộ lời gọi hỏi app khi thay tại chỗ. Mọi ký tự (chữ, số, dấu câu, dấu cách, phím không kèm ⌘, ⌃, ⌥) tới app qua một `insertText` của bộ gõ, kể cả khi engine để nguyên nó. Chỉ ⌫, Return, Tab, Esc, mũi tên, phím chức năng và phím có ⌘, ⌃, ⌥ còn đi thẳng (N3).

Mọi lần đọc chữ là một lần gọi `attributedSubstring` cho phần trước con trỏ. Nếu client trả `NSNotFound` hay `nil`, phím đó xử lý như phím đầu của một từ mới. Nếu hai lần đọc liền nhau đều như vậy, bộ gõ thôi đọc cho tới lần `activateServer` sau; nếu có một lần đọc được ở giữa thì bộ gõ đếm lại (`InPlaceComposer.failedReadLimit`; D18, D20).

| Phím | Hỏi `selectedRange` | Đọc chữ trước con trỏ | Quyết định |
|---|---|---|---|
| Ký tự engine để nguyên, khi đang có từ hoặc sau ký tự kết thúc từ gõ ở đây: Dấu tự chèn tại con trỏ (một `insertText`, `NSNotFound`) | không | không | N3 |
| Ký tự Dấu tự chèn tại con trỏ (kể cả chữ chỉ thêm ở cuối từ) đến chưa tới `InPlaceComposer.backspaceWaitWindow` sau một ⌫ đi thẳng mà Dấu biết chữ bị xoá | một lần, rồi chờ như hàng dưới nếu câu trả lời là vị trí trước khi ⌫ áp | không | N3 (ý "Ngoại lệ sau ⌫ chưa áp") |
| Phím đi thẳng: ⌫ không phải dời dấu, Return và Tab không phải khôi phục, Esc, mũi tên, phím chức năng, phím có ⌘, ⌃, ⌥ | không | không | N3 |
| Phím đến chưa tới `InPlaceComposer.backspaceWaitWindow` sau một ⌫ đi thẳng mà Dấu biết chữ bị xoá, khi `selectedRange` đầu tiên của nó trả đúng vị trí Dấu theo dõi cộng số đơn vị ⌫ xoá | thêm một lần mỗi `InPlaceComposer.backspaceWaitStep`, tới khi app áp xong ⌫ hoặc hết `backspaceWaitLimit` | như đường của phím đó sau khi chờ | N3 (ý "Ngoại lệ sau ⌫ chưa áp") |
| Có thay chữ, vị trí trùng vị trí Dấu theo dõi | một lần | không | N3, D11 |
| Có thay chữ, vị trí khác vị trí Dấu theo dõi | một lần | một lần, để chứng minh app chậm; chỉ dựng lại từ chữ đó khi phím trước cách đủ `settleInterval` | D11 |
| Dấu/biến đổi đầu tiên trong một từ đã hết hợp lệ, khi phím trước cách đủ `settleInterval` | một lần | tối đa một lần mỗi từ | D11 |
| Chữ cái hoặc dấu thanh/biến đổi đầu tiên khi engine rỗng và chưa biết chữ trước con trỏ, ở mọi nhịp gõ | một lần, kể cả khi engine để nguyên phím | một lần | D20 |
| Mọi phím ở chế độ gạch chân | không | không | D13 |

Ô bỏ qua vùng thay (Ghostty, terminal dựng bằng xterm.js, terminal của WebStorm) không có cách xử lý riêng; Dấu thay tại chỗ ở đó như ở mọi ô khác (D43 (Ô bỏ qua vùng thay chữ)).

`InPlaceComposer.settleInterval` là ngưỡng cho hai lần đọc của D11 dùng chữ để dựng lại từ: dựng lại khi lệch và khi từ đã hết hợp lệ. Lần đọc của D20 và phép chứng minh app chậm không chờ ngưỡng này; chữ mà D20 đọc được đi qua chính phép chứng minh đó (D20, ý "Phạm vi").

#### App trả lời chậm

`CursorTracker` theo dõi vị trí con trỏ của Dấu qua các từ, để Dấu thay đúng chỗ khi app trả vị trí và chữ cũ (D11, ý "App trả lời chậm").

- **Hiện tượng:**
  - Ở Chrome khi trang bận, app áp phím theo đúng thứ tự nhưng trả `selectedRange` và `attributedSubstring` từ chữ cũ, chưa có vài phím gần nhất. Lần thay đầu của một từ dùng vị trí cũ đó nên thay nhầm chữ đứng trước ("bạn" ra "ạnn"). Vị trí dự đoán của composer (`predictedCaret`) chỉ có trong một từ, nên nó không bắt được lỗi này.
  - Khi phím dồn ở Chrome, VS Code và Firefox (`docs/Compatibility.md` mục 6.2), app chậm cả loạt phím vừa gõ.
  - Có app tính `selectedRange` và vùng thay từ đầu từ đang gõ và đưa về 0 sau mỗi dấu cách. Mô hình `LateDocument.Origin.word` trong test tả kiểu app này; mô hình dựng từ log của trình soạn thảo Cursor 3.29.15 đo ngày 10/11/2026. Chưa biết app nào hoạt động như vậy. Với app kiểu này, vị trí app trả luôn khác vị trí Dấu theo dõi dù app không chậm. Vùng thay bắt đầu ngoài phần chữ app đang giữ thì bị bỏ.
  - Ở Safari (WebKit), khi trang bận hay phím dồn, trang trả vị trí và chữ của chính nó. Tuy vậy, phím mà bộ gõ để đi thẳng phải chờ trong hàng phím của WebKit, còn lời gọi của bộ gõ tới trang ngay. Vì vậy Dấu tự chèn mọi ký tự (N3, ý "Vì sao Dấu tự chèn ký tự"). Phép chứng minh bên dưới chỉ đúng ở Safari nhờ điều đó (D11). ⌫ vẫn đi thẳng nên vẫn có thể phải chờ trong hàng ([`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md) mục 5.4); xem ý "Chờ ⌫ chưa áp" bên dưới.
- **Trạng thái của `CursorTracker`** gồm vị trí dự đoán trong từ (`predictedCaret`), phần theo dõi qua các từ (`FollowedText`, thuộc tính `followed`) và hạn mức chậm (`LatenessBudget`, thuộc tính `lateness`):
  - `followed.caret` là vị trí con trỏ mà Dấu theo dõi qua ranh giới từ. Giá trị này mất khi reset (click, mũi tên, phím tắt, Return/Tab, đổi client) và khi ⌫ đi thẳng mà Dấu không biết chữ bị xoá. `followed.caret` không thay cho `predictedCaret`: ở đầu từ, một vị trí khác `followed.caret` vẫn có thể là do app tự sửa chữ (tự sửa chính tả, gạch ngang thông minh).
  - `followed.edits` là các thao tác gần nhất mà bộ gõ đã làm, cùng thao tác xoá của các phím ⌫ mà nó để đi thẳng. Bộ gõ đánh dấu `atCaret` cho thao tác chèn tại con trỏ (ký tự bộ gõ tự chèn, chữ chỉ thêm ở cuối từ).
  - `followed.typedBeforeCaret` là phần chữ chính bộ gõ đã gõ ngay trước con trỏ.
  - `lateness.editsInBurst` là số thao tác gần nhất do các phím đến liền nhau dưới `settleInterval` tạo ra. Composer báo giá trị này ở mỗi phím (`keyInBurst`).
  - `lateness.editsSinceOnTimeAnswer` là số thao tác kể từ lần cuối app trả lời đúng `followed.caret` hay kể từ lần neo vị trí; nếu chưa có mốc nào thì giá trị này chưa biết. Composer báo mỗi lần app trả lời đúng (`answeredOnTime`). Câu trả lời đúng `followed.caret` không chứng minh app đã có các thao tác cuối không dời con trỏ (phép thay đặt dấu trên một chữ), cùng tối đa một chữ chèn tại con trỏ theo dạng bộ đệm Chromium, nên `editsSinceOnTimeAnswer` bắt đầu từ số thao tác đó thay vì từ 0. Lần neo vị trí mới (`anchor`: lần đọc của D20, phép kiểm từ đã hết hợp lệ khi chưa có `followed.caret`) cũng là một mốc: `editsSinceOnTimeAnswer` bắt đầu từ 0, vì app vừa cho biết vị trí đó và chưa có thao tác nào của bộ gõ sau nó.
- **Chứng minh app chậm** (`rebuild`, `prove`) chạy khi, ở một phím thay chữ, `selectedRange` khác `followed.caret` (ở lần đọc của D20 thì cả khi trùng, xem dưới):
  - Chữ đọc được, ở một trong hai dạng, cộng với các thao tác app chưa áp phải ra đúng từ trong engine. Mỗi thao tác xoá phải gặp đúng chữ nó xoá. Dạng (a) là chữ như trước các thao tác đó (Firefox; Chrome khi không có thao tác chèn tại con trỏ). Dạng (b) là chữ đó cộng với thao tác chèn tại con trỏ mới nhất trong số đó (bộ đệm Chromium).
  - Số thao tác mà app được phép chậm tối đa là `LatenessBudget.humanPaceEdits` cộng `editsInBurst`. Ở phím thay chữ trong từ, giới hạn này nâng lên `editsSinceOnTimeAnswer` nếu `editsSinceOnTimeAnswer` lớn hơn: app đã trả lời đúng lúc thì đã có mọi thao tác tới lúc đó, nên không thể thiếu xa hơn, còn trang bận thì chậm qua cả chỗ ngắt từ, nơi `editsInBurst` về 0. Lần đọc ở từ đã hết hợp lệ giữ giới hạn `humanPaceEdits` cộng `editsInBurst`, vì sau chỗ ngắt từ, chữ trông như chậm có thể là chữ mà hệ thống vừa sửa thành đúng một chữ bộ gõ từng có ("car" thành "cả"). Lần đọc của D20 giữ giới hạn đó cho dạng (a). Với dạng (b), giới hạn của lần đọc D20 nâng lên `editsSinceOnTimeAnswer` (`LatenessBudget.cacheReplayLimit`), vì chữ hệ thống sửa không kết thúc bằng chữ bộ gõ vừa chèn tại con trỏ đặt sau một trạng thái cũ của chữ; chỉ bộ đệm Chromium trả như vậy. Giới hạn phải nâng vì trang bận làm Chrome chậm qua cả chỗ ngắt từ và ⌫ đứng trước lần đọc này. Khi vượt `humanPaceEdits`, chữ app trả trước các thao tác đó cũng phải là `typedBeforeCaret`, và Dấu so ít nhất hai đơn vị chữ của app (một đơn vị, khi phần đọc bắt đầu từ đầu văn bản). Mọi thao tác xoá trong số đó phải biết chữ bị xoá. Lý do là một thao tác thay làm ở vị trí app trả sẽ bắt đầu lại `typedBeforeCaret` và không biết chữ nó xoá, nên dựng lại qua nó thì khớp với mọi chữ. Ngoài ra, ở app tính theo từ (Cursor 3.29.15), vị trí app trả trùng vị trí của lần thay trước trong từ, nên nếu không có luật này, một app đúng giờ sẽ bị coi là chậm.
  - Trong giới hạn `humanPaceEdits`, chữ dựng lại và `typedBeforeCaret` phải trùng nhau ở phần cả hai cùng có. Lý do: trên mô hình app tính vị trí theo từ, sau một từ một chữ cái có thay chữ, chữ của từ mới cộng hai thao tác cuối có thể ra đúng từ trong engine dù bộ gõ đã gõ chữ khác ("ở đâu" ra "ở dâu").
  - Ở đầu văn bản (`typedHere`), khi các thao tác đó bắt đầu từ đầu văn bản và phím đang xử lý cũng thuộc loạt phím dồn, Dấu coi là app chậm mà không cần chữ của app. Sau một quãng nghỉ thì Dấu không coi như vậy, vì người dùng có thể đã bấm chuột mà IMK không báo.
  - Cách chứng minh thứ hai là chữ đọc được bằng `typedBeforeCaret` thiếu đúng số đơn vị mà app chậm (tối đa `humanPaceEdits`) và Dấu so ít nhất hai đơn vị. Đơn vị bị thiếu phải đứng sau ít nhất một đơn vị đã so, vì bộ đệm Chromium thiếu phần trang chưa báo. Phần đó nằm sau chữ bộ đệm đã có. Nếu `typedBeforeCaret` mất các đơn vị ở đầu thì đó là app chỉ giữ từ đang gõ. Ví dụ, Cursor 3.29.15 cho đọc được "co" ở chỗ đã gõ "ừ co".
- **Kết quả:**
  - Nếu chứng minh được, Dấu thay ở `followed.caret` (kind `late` trong log perf). Vùng thay luôn kết thúc ở `followed.caret`.
  - Ở lần thay đầu của một từ, nếu app chậm tối đa `humanPaceEdits` mà không chứng minh được và trước vị trí app trả không có đủ cả từ, Dấu vẫn thay ở `followed.caret` (kind `late_guess`). Khi app sửa chữ đứng trước từ (gạch ngang thông minh), trước vị trí nó trả có đủ cả từ, nên Dấu tin vị trí của app.
  - Trong các trường hợp còn lại, ở giữa từ thì đó là lệch (D11), còn ở đầu từ thì Dấu tin `selectedRange`.
  - Vị trí lấy từ một `selectedRange` có thể đã cũ không ghi đè `followed.caret`, vì ghi đè sẽ làm lần trả lời chậm sau trùng với một `followed.caret` sai (ví dụ ra "kóo").
- Cùng cách chứng minh này dùng ở phép kiểm từ đã hết hợp lệ (`checkLockedWord`) và ở lần đọc của D20 sau ⌫ (`addMarks`, `answerForRead`; mọi thao tác xoá chưa áp phải biết chữ bị xoá). Ở lần đọc của D20, phép chứng minh chạy cả khi câu trả lời trùng `followed.caret`, chỉ với dạng (b): bộ đệm Chromium đặt vị trí sau chữ chèn tại con trỏ mới nhất (dấu cách mà ⌫ vừa xoá), nên app chậm ba thao tác trả đúng `followed.caret` với chữ kết thúc bằng dấu cách. Lần đọc này chính là lần đọc vốn có của D20, nên không thêm lời gọi nào. Khi chứng minh được, lần thay của phím đó dùng `followed.caret` và không tính là câu trả lời đúng lúc (`readProvedLate`); nếu tính thì `editsSinceOnTimeAnswer` về 0 trong khi app vẫn chậm. Ở lần đọc của D20, nếu không chứng minh được, câu trả lời lùi sau `followed.caret` và phím thuộc loạt phím dồn, Dấu giữ `followed.caret` và không gieo từ: phím bắt đầu từ mới. Sau một quãng nghỉ, Dấu neo vị trí vào câu trả lời như trước.
- **Chờ ⌫ chưa áp** (`InPlaceComposer.askSelection`; N3, ý "Ngoại lệ sau ⌫ chưa áp"): ngay sau một ⌫ đi thẳng, câu trả lời "vị trí Dấu theo dõi cộng số đơn vị ⌫ xoá, chữ trước khi xoá" giống hệt nhau ở hai trường hợp. Ở Chrome khi trang bận, bộ đệm đã cũ và ⌫ đã đứng trước trong hàng của trang, nên app sẽ áp nó trước lần thay. Ở Safari, ⌫ còn chờ trong hàng của WebKit, nên app sẽ áp nó sau lần thay và xoá nhầm chữ. Không vùng thay nào đúng cho cả hai, nên Dấu chờ app áp xong ⌫.
  - Dấu chỉ chờ khi đủ cả bốn điều kiện. Thứ nhất, phím trước trên client này là một ⌫ để app tự xoá và không có click giữa hai phím. Thứ hai, thao tác cuối của `CursorTracker` là thao tác xoá đó, ngay tại `followed.caret`, đồng thời Dấu biết chữ bị xoá (`unitsDeletedAtCaret`). Thứ ba, phím đến chưa tới `backspaceWaitWindow` sau ⌫. Thứ tư, `selectedRange` đầu tiên của phím trả đúng `followed.caret` cộng số đơn vị bị xoá và không có vùng chọn.
  - Khi đủ điều kiện, Dấu hỏi lại `selectedRange` sau mỗi `backspaceWaitStep`, cho tới khi câu trả lời đổi (bằng `followed.caret`, tức app đã áp ⌫) hoặc hết `backspaceWaitLimit`. Hạn này tính cả thời gian của các lần hỏi và theo ngưỡng p99 của D42. Sau đó Dấu xử lý phím như thường với câu trả lời mới nhất, kể cả lần đọc chữ mà đường đó vẫn làm. Nếu hết hạn, Dấu xử lý như khi không chờ.
  - Theo số đo ngày 22/11/2026, ở Safari lần hỏi đầu đã bị chặn tới khi trang rảnh. Cũng theo số đo đó, trang áp ⌫ trong 3 ms sau đó. Chrome không cập nhật bộ đệm mà nó dùng để trả lời trong lúc bộ gõ đang chặn, nên ở Chrome việc chờ chỉ tốn thời gian (mọi lần chờ đều hết hạn); phép chứng minh app chậm của D11 đã giữ đúng thứ tự ở Chrome. Mô hình trong test theo đúng hai điều đó (`LateDocument.pause`).
  - Dấu chỉ chờ ở lần hỏi đầu tiên của một phím. Phím vốn không hỏi vị trí (ký tự Dấu tự chèn, chữ chỉ thêm ở cuối từ) sẽ hỏi một lần khi đủ ba điều kiện đầu (`waitForBackspace`), vì ⌫ còn chờ trong hàng của WebKit sẽ xoá nhầm ký tự gõ sau nó. Ví dụ, "khoong⌫g" ra "khôngg kó" ở Safari khi trang bận, nhịp 10 ms, 2/3 lượt ([`docs/Compatibility.md`](Compatibility.md) mục 5.1).
  - Hạn chờ là một cách vá vòng có hẹn giờ, vì IMK không có API cho biết còn phím đang chờ trong app ([`docs/research/IMKCapabilities.md`](research/IMKCapabilities.md) mục 4.1). Log perf của bản Debug ghi `bksp`, `bksp_asks`, `bksp_wait_ns`; `scripts/perf/perf-report.sh` tách thời gian của phím khi có và khi không tính phần chờ (D42).
- **Khi không chứng minh được:** nếu app chậm hơn số thao tác nêu trên, Dấu xử lý như với một câu trả lời đúng giờ; nếu lệch thì Dấu dựng lại hoặc reset (D11). Các kịch bản app trả lời chậm mà chỉ mô hình cho ra, cùng hướng sửa dự phòng khi gặp chúng ở app thật, nằm ở [`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md).
- **Kiểm:** phần này kiểm bằng client giả trong `LateAnswerTests`, `RapidKeysTests`, `WordOriginTests` và `WebKitQueueTests`. Các test này dùng mô hình Chrome, VS Code, Firefox và hàng phím của WebKit theo mã nguồn, cùng mô hình tính vị trí theo từ dựng từ log Cursor 3.29.15. Thời gian của app và lịch trang xử lý phím trong các mô hình là số chọn, không phải số đo.

**Chromium, Firefox và WebKit theo mã nguồn.** Phần này chưa đo trên bản đã cài và là cơ sở cho mô hình trong test:

- Chromium: khi thay với `replacementRange` trong ô thường, Chromium giữ con trỏ và dời nó theo độ dài thay đổi (`ReplaceTextAndKeepSelection`); với EditContext (VS Code dùng mặc định), con trỏ về cuối vùng vừa thay. Lời gọi của bộ gõ và phím vào cùng hàng đợi của trang. `selectedRange` và `attributedSubstring` trả lời từ bộ đệm phía trình duyệt mà không hỏi trang. Mỗi `insertText` không có vùng thay ghi ngay vào bộ đệm đó, ở vị trí con trỏ mà trang báo lần trước; `insertText` có vùng thay thì không ghi như vậy.
- Firefox: vị trí và chữ lấy từ bộ đệm của tiến trình cha. Bộ đệm này chỉ cập nhật khi tiến trình nội dung báo. Thay với vùng thay là chọn vùng rồi chèn. Con trỏ về cuối vùng vừa thay.
- WebKit: mọi sự kiện phím (nhấn và nhả, bộ gõ đã xử lý hay chưa) vào `keyEventQueue` của tiến trình giao diện. Hàng này gửi cho trang từng sự kiện một. Sự kiện sau chỉ gửi khi trang xử lý xong sự kiện trước. Chỉ sự kiện mà bộ gõ để đi thẳng mới mang chữ tới trang. `insertText`, `selectedRange` và lần đọc chữ của bộ gõ tới trang ngay; trang trả lời từ chữ của chính nó, áp vùng thay lên chữ nó có lúc đó và đưa con trỏ về cuối vùng vừa thay (mô hình `LateDocument.keyQueue`; [`docs/research/LateAnswerFixes.md`](research/LateAnswerFixes.md) mục 5.1).

#### Thêm dấu cho từ đã gõ

Phần này nằm ở `InPlaceComposer.addMarks` (D20). Điều kiện đọc ghi ở bảng trên. Ngoài ra còn các điều kiện sau. Công tắc `addMarksToTypedWords` phải bật; công tắc này đọc lúc `activateServer` và khi cài đặt đổi, không đọc theo phím. Phím phải là phím dấu thanh/biến đổi của kiểu gõ (`isMarkKey`: với Telex là `s f r x j z a e o w d`, hoa hay thường; với VNI là chữ số) hoặc một chữ cái ASCII khác (`isLetter`). "Chưa biết chữ trước con trỏ" nghĩa là đang ở đầu phiên hoặc ngay sau reset, click, ⌫ hay Return/Tab. Sau một ký tự kết thúc từ gõ ở đây thì Dấu đã biết chữ trước con trỏ và không đọc.

- **Đọc:** Dấu gọi một `selectedRange`. Kết quả phải là con trỏ, không phải vùng chọn. Sau đó Dấu gọi một `attributedSubstring` lấy tối đa `InPlaceComposer.readLength` đơn vị UTF-16 ngay trước con trỏ và giữ dãy chữ cái, dấu kết hợp hay chữ số cuối cùng. Dấu gọi `seed(displayed:)` với dãy đó, rồi đưa phím vào engine.
- **Sau đó:** nếu engine trả `replace`, Dấu gọi một `insertText` thay đúng vùng chữ đã đọc. Vùng này đếm theo UTF-16. Mọi ký tự engine nhận đều thuộc BMP, kể cả NFD. Nếu engine trả `passThrough`, bộ gõ chèn nguyên phím tại con trỏ (một `insertText`, `NSNotFound`) và engine giữ từ để gõ tiếp; mốc khôi phục của D4 là chữ đã đọc.
- **Nối hay không** (`seedWord`): Dấu quyết định chỉ từ chữ đã đọc và trạng thái engine, trước khi gửi gì cho app, nên một phím không nối chỉ tốn đúng lần đọc.
  - Với từ không phải tiếng Việt, bộ gõ nhận phím nguyên văn cho tới hết từ. Từ đã khoá chính tả theo D30 thì giữ seed. Với từ toàn chữ cái mà `seed` không nhận, `continueForeignWord` gọi `seedOverflow`.
  - Trên một từ tiếng Việt, chữ hoa đứng sau chữ thường (`startsNewWord`) bắt đầu một từ mới, trừ phím dấu thanh/biến đổi có thay chữ trong từ.
  - Với từ tiếng Việt mà sau phím không còn là tiền tố hợp lệ (`isValidPrefix`), Dấu bỏ từ đã đọc, reset engine và xử lý phím như phím đầu của một từ mới. Luật này áp cho chữ cái thường và cho phím dấu thanh/biến đổi không áp dụng được; gõ đúp theo D26 (Gõ đúp phím dấu) tính là áp dụng được.
  - Từ seed đã khoá chính tả là chữ thật của app, nên Dấu không kiểm lại nó theo D11 (`checkedLockedWord`). Lần đọc để đồng bộ của D11 dùng cùng `seedWord` nhưng không áp các luật này (`SeedRule.resync`).
- **Từ hệ thống vừa sửa** (`seedWord`, trước khi đưa phím vào engine):
  - Composer nhớ từ mà nó vừa trả (`InPlaceComposer.produced`). Composer đặt từ này khi một ký tự kết thúc từ gõ ở đây kết thúc từ. Composer không đặt nó cho từ mà D4 đã khôi phục (`producedWord`; trường hợp này khác với phần mở rộng của D21 (Gõ tắt phụ âm) và nhận ra bằng một bản sao engine tắt gõ tắt). Composer cũng không đặt nó cho từ kết thúc khi còn hiện chữ của phím gõ đúp xoá dấu (`undidMark`); nếu ⌫ xoá chữ đó thì Composer lại nhớ từ như mọi từ khác.
  - Từ đã nhớ sống qua đúng một phím, cộng một ⌫ ở giữa. Phím khác, ⌫ thứ hai, `reset` và `activate` đều xoá nó.
  - Với phím dấu thanh/biến đổi gõ ngay sau ⌫ đó: nếu từ đọc được khác từ đã nhớ, mà engine thử (`isSystemFix`) ra đúng từ đọc được, không phân biệt hoa thường, thì engine giữ từ đọc được và không gửi gì. Phím đó bị nuốt (kind `seed_kept`). Nhánh này không thêm lời gọi nào ngoài lần đọc của D20.
- **Lỗi đọc** (D18): khi chuỗi đọc được sai độ dài, không có chữ, là từ có chữ số mà `seed` không nhận hoặc khi có vùng chọn, Dấu không seed và xử lý phím như phím đầu của một từ mới.
- **Log perf** có các kind `seed` (đã thay), `seed_pass` (đã đọc và seed, rồi chèn phím nguyên văn tại con trỏ), `seed_kept`, `seed_none` (đã đọc nhưng không có từ hoặc chữ cái không nối được) và trường `read_ns`. Bản Debug ghi thêm `typed_read=mark|letter|none`, `seeded=0|1`, `diff=0|1|-`. `scripts/perf/perf-report.sh` đếm các trường này.
  - Ở phím có lần đọc của D20, bản Debug còn ghi các con số của phép chứng minh app chậm (`InPlaceComposer.TypedWordReadProof`). `typed_read_sel` là câu trả lời của app, `typed_read_known` là `followed.caret`, `typed_read_since` là `editsSinceOnTimeAnswer`. `typed_read_burst` và `typed_read_inburst` cho biết `editsInBurst` và phím có thuộc loạt phím dồn không. `typed_read_after_bksp` cho biết phím có đến ngay sau một ⌫ mà Dấu biết chữ bị xoá không; nếu phím đã chờ ⌫ đó thì dòng có thêm trường `bksp`. `typed_read_limit` và `typed_read_limit_b` là giới hạn của dạng (a) và (b). `typed_read_lag` và `typed_read_form=a|b|m` là số thao tác app thiếu và dạng chữ, `typed_read_proved` là kết quả, `typed_read_reject=answer|limit|fit|deleted|typed|agrees|accept` là phép kiểm đã từ chối, còn `typed_read_stale` cho biết Dấu không neo vị trí. Khi phép kiểm từ chối vì giới hạn, `typed_read_lag` là số thao tác mà nếu dựng lại thì chứng minh được. Các trường chỉ có số và từ cố định (D8); `perf-report.sh` không đếm chúng.
- Khi gõ liền qua dấu cách, Dấu không đọc thêm lần nào; nó đọc tối đa một lần ở phím đầu của phiên (test `sample`, `InPlaceComposerLetterTests.sentence`).
- Terminal không chuyển phím ⌫ cho bộ gõ (`docs/Compatibility.md` mục 6.5). Vì vậy ở Terminal, D20 sau ⌫ không bao giờ chạy. ⌫ giữa từ không đi qua D32: "hoaf⌫␣" ra "ho " thay vì "hò ". Tương tự, "tooi⌫s" ra "tôs" (`CursorTracker` bắt được lệch).

### Backspace thay tại chỗ

Phần này theo D32. Khi `backspace()` trả `passThrough`, ⌫ đi thẳng. Khi nó trả `replace` (dấu phải dời, ví dụ "hoà" ⌫ → "hò"), bộ gõ vẫn **không nuốt phím**. Bộ gõ gọi một `selectedRange` và một `insertText` thay phần chữ cần đổi **kèm lại chữ cuối** ("oà" → "òà"), rồi lệnh xoá của chính ứng dụng bỏ chữ cuối đó (`VietEngine.lastShown`).

- Lý do là Chromium/Electron luôn gửi phím ⌫ gốc cho trang sau chữ của bộ gõ, dù bộ gõ đã nuốt phím, nên nuốt phím sẽ làm mất thêm một chữ (`docs/history/CompatibilityFixed.md`).
- Cách này cần ứng dụng áp `insertText` trước lệnh xoá. AppKit làm vậy trong lúc `handle`. Chromium cũng vậy theo mã nguồn. Nếu thứ tự ngược lại, phím thay chữ kế tiếp sẽ thấy lệch (D11) và reset.
- Nếu chữ cuối là dấu kết hợp (NFD), Dấu không đoán: nó reset và để ⌫ đi thẳng.

### Chế độ gạch chân

Chế độ này nằm ở `MarkedComposer.swift` (D13) và bật khi quy tắc của app có `underline`. Từ đang gõ hiện bằng `setMarkedText` (app tự vẽ gạch chân) và chốt bằng `insertText` khi kết thúc từ. Mọi lời gọi dùng `replacementRange` = NSNotFound, nên chế độ này **không bao giờ hỏi `selectedRange`**. Vì vậy chế độ này đúng với app áp phím bất đồng bộ, nhưng không có D20, vì muốn biến từ đã chốt thành marked text thì cần vị trí tuyệt đối.

Mỗi phím có tối đa một lời gọi (N3), như sau:

- Với chữ cái, chữ số và Backspace trong từ, bộ gõ gọi một `setMarkedText` với cả từ; chuỗi rỗng xoá marked text khi từ bị xoá hết.
- Với ký tự kết thúc từ, bộ gõ gọi một `insertText` gồm từ (đã khôi phục nếu D4 bảo vậy) và ký tự đó, rồi nuốt phím.
- Với Return, Tab và Enter bàn phím số, bộ gõ gọi một `insertText` của từ rồi để app xử lý phím, nên ứng dụng chat vẫn gửi tin.
- Với mũi tên, Esc, tổ hợp ⌘/⌃/⌥ và các sự kiện reset (click, `deactivateServer`, `commitComposition`, đổi nguồn hay mode, đổi client, đổi cài đặt), bộ gõ gọi một `insertText` của **đúng chữ đang hiện**, không khôi phục, rồi phím đi tiếp tới app. Chữ chốt vào client đã nhận marked text nếu client đó còn, nếu không thì vào client của sự kiện; nếu không còn client nào thì bộ gõ bỏ trạng thái (D18).
- Với ký tự gõ khi không có từ đang gạch chân (dấu câu, dấu cách giữa hai từ, phần còn lại của một chuỗi chữ đã chốt sớm), bộ gõ gọi một `insertText` của ký tự đó tại con trỏ, rồi nuốt phím (N3).
- Với Backspace, Return, Tab, Enter bàn phím số và các phím reset khi không có từ, bộ gõ không gọi gì và phím đi thẳng.

Ký tự kết thúc từ không bao giờ đi riêng sau chữ chốt. Ký tự này nằm trong cùng `insertText` với chữ chốt, kể cả khi D4 khôi phục từ (D13 (Gạch chân là đường lui cuối cùng)).

Gõ đúp, khôi phục và độ dài từ hoạt động giống hệt thay tại chỗ: `MarkedComposer` giữ bản sao phần chữ engine đang hiển thị và áp nguyên `Action` lên đó (một test so khớp ngẫu nhiên với thay tại chỗ). Chuỗi chữ dài hơn 32 ký tự không có dấu cách (chỉ sau D33) chốt sớm; phần còn lại của từ chèn từng ký tự bằng `insertText`, như ký tự ngoài từ. Có thể gõ thử chế độ này bằng `scripts/selftest/typing/run.sh --underline`.

### Đầu vào từ IMK

Phần này theo D18. Dưới đây là mọi điểm vào và cách bộ gõ xử lý giá trị lạ ở từng điểm.

- `handle(_:client:)`:
  - Khi event là nil hoặc không phải keyDown/mouseDown, hàm trả `false`.
  - Khi client là nil hoặc không phải `IMKTextInput`, bộ gõ reset và trả `false`.
  - Khi `characters` là nil, rỗng, có nhiều scalar hoặc là ký tự điều khiển, bộ gõ chỉ reset (`KeyRouter`).
  - Mọi giá trị `selectedRange` đều đi qua `ClientRange.sanitized` ở một chỗ (`InPlaceComposer.selectedRange(of:)`). Giá trị `NSNotFound`, giá trị âm hoặc vị trí, độ dài hay điểm cuối vượt `ClientRange.limit` (Int32.max) đều thành `NSNotFound`, nghĩa là không thay và không đọc. Ở lần đọc của D20 (`seedWord`), kết quả đó tính là một lần đọc hỏng: hai lần hỏng liền nhau thì bộ gõ thôi đọc (`InPlaceComposer.failedReadLimit`). Bộ đếm bắt đầu lại khi đổi client (`noteClient`) hay khi `activateServer`. Khi có vùng chọn, bộ gõ vẫn thay và gộp cả vùng chọn vào vùng thay (gợi ý tự hoàn thành, D11; `CursorTracker.plan`); chỉ lần đọc của D20 (`seedWord`, `allowSelection` false) bỏ qua khi có vùng chọn. Các phép cộng còn lại trên vị trí đều là phép cộng bão hoà.
  - Khi `attributedSubstring` trả nil, sai độ dài hoặc có ký tự ngoài BMP, bộ gõ không seed.
- Khi `activateServer`, `deactivateServer` hay `commitComposition` được gọi với client nil, bộ gõ reset. Ở chế độ gạch chân, nó chốt chữ vào client đã nhận marked text nếu client đó còn, nếu không thì bỏ. `activateServer(nil)` không giữ bundle ID của app trước.
- Với `setValue(_:forTag:client:)`, giá trị nil không chuyển cho `super`. Giá trị lạ chỉ gây reset.
- `inputControllerWillClose` reset và bỏ ba bộ nghe (cài đặt, nguồn đầu vào, yêu cầu thoát của app chủ).
- `menu()` và các hành động menu không chạy ngoài main thread (`onMain` trả nil thay vì dừng chương trình). Tham số của hành động menu không dùng tới.
- Thông báo cài đặt và thông báo nguồn đầu vào chỉ xử lý trên main thread và giữ tham chiếu yếu tới controller.
- **Gọi ngược trong lúc xử lý:** client có thể gọi `commitComposition`, `deactivateServer`… ngay trong `insertText`, `selectedRange` hay `setMarkedText`. Phím, reset và việc nạp lại cài đặt chạy lần lượt, không lồng nhau (`KeyReentry`: `handle` đi qua `KeyReentry.key`, các điểm vào khác đi qua `outsideKey`). Lời gọi đến lúc bộ gõ đang bận giữ lại và chạy ngay sau đó, vì engine và composer đang bị mượn (`inout`). Phím đến lúc bộ gõ đang bận thì đi thẳng tới app. Từ đang gõ reset sau đó. IMK có gọi ngược như vậy hay không thì chưa đo.

### Input mode, quy tắc theo app, cài đặt

- Bộ gõ có một input mode duy nhất là "Dấu – Tiếng Việt" (`….Dau.vi`), khai trong Info.plist (`ComponentInputModeDict`). Nhờ vậy ID của nguồn đã bật không đổi và nguồn nằm trong nhóm Tiếng Việt (D2 (Chuyển Việt/Anh)).
  - Bộ gõ không giữ trạng thái chế độ: IMK báo mode nào (kể cả `….Dau.en` còn sót từ bản cũ) thì bộ gõ cũng xử lý như tiếng Việt. `setValue(_:forTag:client:)` chỉ reset từ đang gõ.
  - Bộ gõ không tự đổi nguồn theo app, không nhớ chế độ theo app (D5) và không tự thông báo cho VoiceOver (D17 (Trợ năng)).
- Với quy tắc theo app, lựa chọn gạch chân đọc lúc `activateServer` và khi cài đặt đổi, không đọc theo phím. Nếu chế độ đổi giữa chừng một từ, bộ gõ chốt từ trước. Bundle ID lấy từ client lúc `activateServer`. Chrome đôi khi đưa client có `bundleIdentifier()` là nil; khi đó bộ gõ dùng app đang ở trước (`NSWorkspace.frontmostApplication`).
- Bộ gõ đọc cài đặt từ App Group và nghe thay đổi để áp dụng ngay. Bộ gõ không đọc danh sách tương thích (D13).

### Đổi nguồn đầu vào không qua `activateServer`

- Hiện tượng (đo ngày 10/11/2026, `0bf8d3f`): khi một tiến trình khác chọn nguồn bằng `TISSelectInputSource`, TIS báo nguồn đã đổi và thanh menu cũng đổi, nhưng ô gõ đang focus vẫn giữ bộ gõ cũ. Dấu không nhận `deactivateServer`/`activateServer`. Khi chuyển bằng phím tắt hệ thống thì IMK có gọi `activateServer`/`deactivateServer`.
- Bộ nghe (`InputSourceChange`) chỉ đáng giữ nếu có một đường chuyển nguồn thật mà IMK không báo, ví dụ "Automatically switch to a document's input source" hay một app khác gọi TIS. Các đường đó chưa được đo.
- Mỗi controller nghe thông báo phân tán `kTISNotifySelectedKeyboardInputSourceChanged`; bộ gõ có sandbox vẫn nhận được thông báo này. Khi nhận, controller đọc nguồn đang chọn. Controller chỉ reset từ đang gõ (ở chế độ gạch chân thì chốt chữ đang hiện) khi nguồn đó không phải Dấu, không đọc được hoặc khác nguồn đã thấy lần trước. Ai cũng phát được thông báo này, nên một thông báo giả khi nguồn không đổi không cắt ngang từ.
- Thông báo đến trong khoảng `DauInputController.activationEcho` sau `activateServer` của chính controller là tiếng vọng của lần chuyển bằng phím tắt hay menu và bị bỏ qua. Nhờ vậy phím gõ ngay sau khi chuyển không làm mất từ.
- Về cách kiểm, phím `⇄` của `scripts/selftest/typing/run.sh --keys` (chọn U.S. rồi Dấu từ tiến trình script) chỉ kiểm được việc bộ nghe phản ứng với thông báo (dòng log `source-changed-reset`). Script này không kiểm được một lần chuyển nguồn thật, vì ô gõ không đổi bộ gõ theo lệnh đó. Chuỗi `to` ⇄ `o` cũng không phân biệt được có hay không có bộ nghe, vì sau reset D20 đọc lại "to" và `o` cho ra "tô".

### Khởi chạy bộ gõ

Phần này nằm ở `LaunchOrigin.swift` và `InputMethodAppDelegate.swift`. Bundle là `LSBackgroundOnly`, nên khi người dùng mở nó (nháy đúp trong Finder) thì không thấy gì. Bộ gõ phân biệt bốn cách nó chạy, dựa theo log LaunchServices và Apple event ở `applicationDidFinishLaunching` trên macOS 27.2:

- **Hệ thống:** imklaunchagent nhờ LaunchServices chạy bộ gõ khi một client cần nó. Không có Apple event nào ngoài `aevt/oapp` do AppKit tự tạo. Người gửi là chính tiến trình. `NSApplicationLaunchIsDefaultLaunchKey`, tiến trình cha và `XPC_SERVICE_NAME` giống nhau ở mọi đường, nên không dùng được để phân biệt.
- **Finder** (Mở hoặc nháy đúp): LaunchServices gửi một `aevt/oapp` thật từ tiến trình khác. Bộ gõ mở app chủ (`HostApp`), rồi thoát nếu trong lúc đó chưa client nào kích hoạt nó (`DauClientActivated`).
- **Mở lại khi đang chạy** (Finder, `open`, `NSWorkspace`): tiến trình đang chạy nhận `aevt/rapp`. Bộ gõ mở app chủ và **không** thoát, vì nó có thể đang phục vụ việc gõ. `rapp` đến trong `LaunchPolicy.reopenSettleSeconds` đầu tiên sau khởi chạy bị bỏ qua, để phòng trường hợp hệ thống xin chạy hai lần.
- **`open` trong Terminal khi bộ gõ chưa chạy:** cách này giống hệt đường của hệ thống, nên bộ gõ coi đó là hệ thống, chạy tiếp và không mở gì. Khi không chắc, bộ gõ luôn chạy tiếp.

**Tìm app chủ** (cùng cách với mục "Cài đặt Dấu…", `HostApp`): bộ gõ tìm theo thứ tự sau. Trước hết là bản đang chạy, rồi bản chứa bộ gõ, rồi bản cùng phiên bản, ưu tiên bản trong thư mục Applications. Sau đó bộ gõ tìm thẳng trong /Applications khi LaunchServices chưa biết bản vừa chép vào, rồi tới bản trong `~/Applications` (luật bên dưới). Cuối cùng là bản duy nhất LaunchServices biết, nếu chữ ký đạt (`Reason.onlyKnown`).

- Mỗi bản phải qua bước kiểm chữ ký (`HostApp.accepts`, `HostAppSignature`; luật ở D37): chữ ký hợp lệ, gốc Apple, đúng bundle ID của app chủ và đúng Team ID của chính bộ gõ. Lời gọi Security này chạy được trong sandbox của bộ gõ.
- Sandbox của bộ gõ không đọc được Info.plist của bản nằm trong thư mục nhà (bị từ chối `file-read-data`). Bản như vậy, hoặc mọi bản khi bộ gõ không có Team ID, chỉ được mở khi nó là bản đang chạy, bản chứa bộ gõ hoặc bản nằm trực tiếp trong `~/Applications` của thư mục nhà thật trong lúc `/Applications` không có bản nào đạt (`HostApp.userApplicationsFolder`). Bản đọc được mà kiểm không đạt thì không bao giờ được mở.
- Vì vậy một bản build chưa chạy và không nằm ở /Applications sẽ không được chọn (log `host-app-not-found known=… readable=…`).

### Thoát theo yêu cầu của app chủ

Cơ chế này dùng khi thay bộ gõ (D37) và khi gỡ (D16 (Bảo trì và gỡ cài đặt)). Tên thông báo và cách phát nằm ở `InputMethodLifecycle` (DauShared).

- App chủ phát thông báo Darwin `<bundle ID bộ gõ>.quitRequested` sau khi đã đổi chỗ bundle (khi thay) hoặc đã chuyển bundle vào Thùng rác (khi gỡ).
- Lúc khởi chạy, bộ gõ (`main.swift`) ghi lại file thực thi mà nó chạy từ đó (`InputMethodLifecycle.BundleFile`: inode và giờ sửa). Khi nhận thông báo, nó chỉ thoát nếu file trên đĩa đã khác hoặc đã mất (`InputMethodLifecycle.shouldQuit`). Nếu không, nó ghi `event=quit-ignored` và gõ tiếp, vì ai cũng phát được thông báo này.
- Khi thoát, bộ gõ phát `DauQuitRequested` trong tiến trình để mỗi controller chốt từ như một lần reset, rồi gọi `exit(0)` ở vòng chạy kế tiếp. Ở chế độ gạch chân, controller chốt marked text vào client. macOS chạy lại bundle trên đĩa ở phím kế tiếp.
- Về phía app chủ, nếu quá `SystemInputMethodInstaller.quitTimeout` mà bộ gõ vẫn chạy (bộ gõ bản cũ chưa nghe thông báo này), app gọi `forceTerminate` cho đúng tiến trình bộ gõ của Dấu (`NSRunningApplication` theo bundle ID). App không dừng tiến trình hệ thống nào (`imklaunchagent`, `TextInputMenuAgent`…).

### Bundle: biểu tượng, ký, entitlements

- Biểu tượng của bundle (hiện trong Finder) dùng chung hai file Icon Composer `Apps/Dau/Resources/AppIcon.icon` và `AppIconDev.icon` với app chủ, chọn theo cờ `DAU_OFFICIAL` (D25 (Nhận diện)). Kết quả là `CFBundleIconName`, `Assets.car` và `.icns` giống Dấu.app. Tên hiển thị vẫn là "Dấu" (D24 (Tên và định danh)).
- Biểu tượng nguồn đầu vào (ô V trên thanh menu, chỉ báo ⌃Space) là một TIFF template khai trong Info.plist (`docs/history/CompatibilityFixed.md`). TIS báo `kTISPropertyIconImageURL` = `ModeVietnamese.tiff`. Cờ template có ở cả bundle lẫn mode.
- Bản Release không có `get-task-allow` (`CODE_SIGN_INJECT_BASE_ENTITLEMENTS: NO`), nên không tiến trình nào gắn được debugger vào bộ gõ để đọc từ đang gõ. Bản Debug có quyền này và chỉ dùng khi thử (`scripts/dev/install-app.sh --debug`). `dau_check_input_method` (`scripts/lib/build.sh`) kiểm điều này trên bộ gõ nhúng trước khi cài, cùng với việc bộ gõ là universal và không có quyền mạng.
- Entitlements gồm App Sandbox, App Group và `temporary-exception.mach-register.global-name` cho tên kết nối IMK. Bộ gõ **không** có `com.apple.security.network.client`. Dấu giữ ngoại lệ dù trên macOS 27.2 app nối vào bộ gõ qua endpoint XPC mà `IMKServer` gửi cho `imklaunchagent`, vì bỏ nó không giúp notarize và việc bỏ chưa kiểm được trên macOS 14–26 ([`docs/research/IMKAPINotes.md`](research/IMKAPINotes.md) mục "Kết nối của IMKServer và sandbox").
- Các khoá Info.plist gồm `InputMethodConnectionName`, `InputMethodServerControllerClass`, `LSBackgroundOnly`, `TISInputSourceID`, `TISIntendedLanguage`; `ComponentInputModeDict` (một mode `.vi`, icon template V), `tsInputMethodIconFileKey`, `TISIconIsTemplate`; `CFBundleIconName` do actool thêm; và `DauHostAppBundleIdentifier`, `DauAppGroupIdentifier` là khoá riêng của Dấu.

## App chủ (Dau)

Entitlement của app chủ chỉ có App Group; hardened runtime bật và app không có sandbox (D37). App chỉ **đọc** tuỳ chọn hệ thống (`com.apple.symbolichotkeys`, `com.apple.HIToolbox`) để biết phím tắt chuyển nguồn đầu vào và phím 🌐 (N4 (Không tự đổi cài đặt hệ thống)). `scripts/selftest/app-group.sh` kiểm App Group. Điểm vào của app là `main.swift`.

### Cửa sổ Cài đặt

- Cửa sổ chính của app là một scene SwiftUI `Window` (app không dùng scene `Settings`). ⌘, mở lại cửa sổ này. Cỡ cửa sổ và giới hạn cỡ theo System Settings, đặt trong `SettingsScene` (`SettingsWindow.swift`). Chiều rộng tối đa giữ cột chi tiết dưới ngưỡng mà ở đó `Form(.grouped)` bắt đầu giới hạn độ rộng thẻ và căn giữa.
- Ngôn ngữ giao diện theo danh sách ngôn ngữ của macOS (D41 (Ngôn ngữ giao diện)). Tham số `-AppleLanguages` vẫn chọn được ngôn ngữ khi chạy kiểm.
- **Bố cục** (D9 (Giao diện), sidebar cố định):
  - Nội dung của scene là `SettingsSplitViewController`, một `NSSplitViewController` do app tạo và bọc bằng `NSViewControllerRepresentable`. Mục sidebar có `canCollapse` và `canCollapseFromWindowResize` tắt, độ dày tối thiểu bằng độ dày tối đa và đường chia không có vùng kéo chuột.
  - Trạng thái chung của hai cột (`SettingsWindowState`: mục đang hiện, chuỗi tìm) là một đối tượng `@Observable`.
  - Sidebar và trang là view SwiftUI trong hai `NSHostingController`. Môi trường của scene chuyển vào hai cột bằng `SettingsEnvironment`, kể cả `openWindow`.
- **Sidebar** là một `List` kiểu `.sidebar` với 4 mục `Label`.
  - Ô tìm là một `NSSearchField` cỡ lớn ở đầu cột, theo lề chuẩn của sidebar, vì `searchable` cho sidebar chỉ có trong `NavigationSplitView`.
  - Danh sách nhận tiêu điểm khi mở cửa sổ (`FocusState` đặt khi danh sách hiện, vì `defaultFocus` không có tác dụng trong hosting controller này).
  - Edit › Find › Find… (⌘F, từ `TextEditingCommands` trong `DauApp`) đưa tiêu điểm vào ô tìm; split view controller xử lý `performFindPanelAction`.
  - Ô icon vẽ theo SVG của mockup, bằng màu hệ thống.
- **Thanh công cụ và tiêu đề:** cửa sổ không có cụm Lùi/Tiến (D9). Tiêu đề là `navigationTitle`. Tiêu đề và các nút của trang lấy từ `NSHostingController` của cột trang và đưa lên cửa sổ bằng `sceneBridgingOptions`; cột sidebar không đưa gì lên. Ô tìm của sidebar nhảy tới mục khớp đầu tiên khi mục đang hiện không còn khớp (`SettingsWindowState.showFirstMatch`). Cửa sổ không có lệnh ẩn hay hiện sidebar: app không dùng `SidebarCommands` và hành động `toggleSidebar` của AppKit bị tắt. Mục Ứng dụng có nút "+" rồi tới ô tìm (`.searchable(placement: .toolbar)`), ngăn cách bằng `ToolbarSpacer(.flexible)`. Các mục khác không có nút nào trên thanh; chúng đặt một `ToolbarSpacer(.flexible)` để SwiftUI không bỏ thanh công cụ (`PageSearch`, macOS 26+; lý do và số đo nằm ở [`docs/research/SwiftUIWindowAPI.md`](research/SwiftUIWindowAPI.md) mục 3).
- **Trang:** `SettingsPage` = `Form(.grouped)` với các `Section`, control hệ thống và thông số mặc định. Những mảnh nội dung riêng của mockup (thẻ xem trước, chip, nhãn "Mới", phím, ô banner) nằm trong các section. Form tự cuộn và lấp đầy cột chi tiết. Trên macOS 26+, `scrollEdgeEffectStyle(.hard, for: .top)` che nội dung cuộn dưới header. Thanh cuộn theo cài đặt hệ thống (`docs/UIChecks.md`).
- **Control bọc:** `SegmentedPicker` bọc `NSSegmentedControl`. Control này dùng ở cửa sổ onboarding, vì `Picker(.segmented)` trên macOS 14–15 giữ độ rộng nội tại mà không trải theo khung. Control này cũng dùng ở hàng "Kênh phát hành", vì `.disabled` của SwiftUI không tắt được một đoạn, còn AppKit có `setEnabled(_:forSegment:)`. Các hàng khác của cửa sổ Cài đặt dùng `Picker(.segmented)` (trên macOS 26+ kèm `buttonSizing(.flexible)`).
- **Sheet thêm quy tắc** (`AddAppRuleSheet`) theo sheet của System Settings. Hàng đầu gồm tiêu đề và ô tìm `NSSearchField`. Danh sách ứng dụng là một `List(selection:)` có chiều cao cố định, nằm trong `GroupBox` ngoài Form, vì `List` lồng trong `Form(.grouped)` không cuộn được; nhờ vậy phần "Khi đang gõ" (thẻ của một `Form(.grouped)`) luôn nằm trong tầm nhìn. Các nút nằm trên `toolbar` (`cancellationAction`, `confirmationAction`; "Chọn ứng dụng khác…" là `.automatic`).

### Onboarding

Onboarding có ba bước (`OnboardingFlow`, `OnboardingWindow`; D14 (Onboarding)). Mọi trạng thái (bộ gõ cũ, nguồn khác, trạng thái bộ gõ, bản chủ, chữ ký) đọc lại lúc mở và mỗi lần cửa sổ lên trước (`readSystem`).

- **Chuyển vào Applications:** `OnboardingFlow.needsMoveToApplications` thay cả ba bước bằng `MoveToApplicationsStep` khi bản đang chạy không phải bản chủ và bộ gõ chưa được cài (D37). Hai nút của màn này đi qua `OwnerCopyGuide`: một nút mở thư mục Applications trong Finder, một nút thoát app.
- **Bước 1** chỉ hiện khi có xung đột (mục "Danh sách tương thích, bộ gõ cũ").
- Không bước nào có nút "Quay lại", vì các bước chỉ đi tới.
- **Bước 2:** nguồn tiếng Việt kiểu IMK khác đang bật nêu ở `OtherSourcesNote` và không chặn người dùng. `OnboardingFlow.installedTampered` đổi màn "Bật Dấu" thành màn lỗi cài "Chưa cài được Dấu" (`OnboardingFlow.EnableScreen.error`, view `EnableStep.installError`; "Chi tiết" là lỗi chữ ký). Cờ này đúng khi bản đang chạy là bản chủ, bộ gõ đã cài nhưng chưa bật và `InputMethodInstaller.installedIsGenuine` sai. Nếu phát hiện điều này trong lúc đang chờ Allow, onboarding huỷ lần chờ.
  - Màn lỗi cài cũng hiện khi việc chép, kiểm chữ ký bản tạm hay đăng ký bị lỗi (`problem == .failed`). Nút "Cài lại" gọi `OnboardingFlow.reinstall`, với cùng một luật cho mọi nguyên nhân. Bản chủ chép lại bản nhúng (`install()`, trong đó có bước đăng ký) và không gọi `enable()` của bộ cài. Xong việc, onboarding đọc lại chữ ký: nếu đúng thì quay về màn "Bật Dấu" ("Trước khi bấm") và chỉ cú bấm ở màn đó mới bật Dấu; nếu vẫn sai hay lỗi thì ở lại màn lỗi với "Chi tiết" mới.
  - Khi bộ gõ đã cài có chữ ký sai, `OnboardingFlow.enable` không làm gì, không thay và không bật (D37); chỉ "Cài lại" mới thay bộ gõ.
  - Khi `OnboardingFlow.enable` nhận `EnableOutcome.needsReinstall` (bộ gõ bị thay sau lần đọc cuối), onboarding cũng chuyển sang màn này.

### Cài, bật, thay, gỡ bộ gõ

Phần này nằm ở `InputMethodInstaller.swift` và làm theo `docs/research/InputMethodInstall.md` mục 1–6; luật nằm ở D37 và D16.

`SystemInputMethodInstaller` đi qua sáu giao diện hẹp để có thể test bằng đồ giả (`Apps/Dau/Tests/DauAppTests/InputMethodInstallerTests.swift`):
- `InputMethodFiles` lo bundle trong app và bản ở `~/Library/Input Methods`.
- `TextInputSources` lo TIS.
- `InputMethodProcesses` lo tiến trình bộ gõ.
- `SystemSettingsControl` lo bộ đệm và tiến trình System Settings.
- `InputSourceCaches` lo bộ đệm danh sách nguồn của từng app. Bản thật là `UserInputSourceCaches`; nó nhận thư mục gốc làm tham số, nên test chạy được trên thư mục tạm.
- `OwnerCopyCheck` lo việc xác định bản chủ; bản thật là `ApplicationsOwnerCopy`.

**Bản chủ:**

- `ApplicationsOwnerCopy` nhận bundle ID của app chủ, danh sách thư mục theo thứ tự (`standardDirectories`) và hai hàm đọc mã băm làm tham số. `ApplicationsOwnerCopy` tìm bundle theo `CFBundleIdentifier` trong `Info.plist` của các mục `.app` nằm trực tiếp trong thư mục, không theo tên file; liên kết tượng trưng không tính. Thư mục đầu tiên có bundle như vậy là thư mục quyết định.
- Mã băm đọc bằng `CodeSignature.codeHashes`, chỉ dùng API công khai của Security. `MachOSlices` đọc danh sách kiến trúc thẳng từ đĩa; mỗi kiến trúc mở bằng một `SecStaticCodeCreateWithPathAndAttributes`, rồi lấy `kSecCodeInfoUnique` từ `SecCodeCopySigningInformation`. Nếu một kiến trúc không đọc được thì cả bundle coi là "không biết" và không trùng với gì. `CodeSignature.sameCode` đòi cùng tập kiến trúc và cùng mã băm ở từng kiến trúc.
- Mã băm của bản đang chạy đọc từ bundle của chính nó trên đĩa, để có đủ mọi kiến trúc; vị trí của bundle đó không tham gia vào kết luận. `InputMethodInstaller.isOwnerCopy` đọc lại mỗi lần được hỏi và không lưu kết quả.
- Với bản không phải bản chủ, `install()` ném `InputMethodInstallerError.notOwnerCopy` trước khi đụng tới file. `OnboardingFlow.enable` chỉ bật bộ gõ đã cài. "Cài lại" của màn lỗi (`OnboardingFlow.reinstall`) không chép gì mà chỉ đăng ký và bật lại bộ gõ đã cài. `enable()` và `InputMethodActions.checkInstalled` không kiểm chữ ký. `reinstallInputMethod` không làm gì. Bật, cài và gỡ đi các đường như ở bản chủ.

**Cài và thay** chỉ chạy ở bản chủ, từ bước 2 của onboarding, từ nút "Cài lại" và từ `reconcile`:

1. App chép `Contents/Library/Input Methods/DauInputMethod.app` vào một thư mục tạm ẩn, không có đuôi `.app`, nằm cùng thư mục đích (`.DauInputMethod-staging-<uuid>`), rồi gỡ `com.apple.quarantine`.
2. App kiểm chữ ký của bản tạm (`CodeSignature.isValidAndSameTeam`).
3. App đổi chỗ bản tạm vào `DauInputMethod.app` bằng một lần `renamex_np(RENAME_SWAP)`. Nếu đích không có (`ENOENT`), `InputMethodFiles.installEmbedded` chuyển bản tạm vào bằng `RENAME_EXCL`, còn `InputMethodFiles.replaceInstalledWithEmbedded` (đường thay) không cài, xoá bản tạm và trả về sai.
4. App xoá bản cũ, dừng tiến trình cũ nếu nó đang chạy (mục "Thoát theo yêu cầu của app chủ"), rồi gọi `TISRegisterInputSource`. App không bật và không chọn nguồn nào.

**Bật** chỉ chạy khi người dùng bấm "Bật Dấu" hoặc "Bật lại" (`docs/research/InputMethodInstall.md` mục 1 và 3):

1. Bản chủ kiểm `InputMethodFiles.installedIsGenuine` trước mọi việc. Nếu sai, nó trả `EnableOutcome.needsReinstall` và không làm gì thêm; khi đó `OnboardingFlow` hiện màn lỗi cài với nút "Cài lại", còn `InputMethodActions.enableFromBanner` hiện `TamperedBanner`.
2. Ngay trước `TISRegisterInputSource`, `InputSourceCaches.clearAll` xoá `com.apple.IntlDataCache.le*` trong mọi thư mục con trực tiếp của `DARWIN_USER_CACHE_DIR`. Mỗi app có sandbox giữ bộ đệm riêng ở đó. Extension Bàn phím của System Settings là một trong số đó. File ở gốc thư mục là bộ đệm chung, tự làm mới, nên app không đụng tới. Thư mục không liệt kê được hay file không xoá được thì bị bỏ qua, đếm là lỗi và ghi nhật ký; bước này không bao giờ làm `enable()` thất bại.
3. App luôn gọi `TISRegisterInputSource`, vì các app đang chạy dựng lại bộ đệm ở lần đăng ký này. Nếu sau đó TIS không liệt kê Dấu thì kết quả là `notListed`.
4. Nếu mode `.vi` đã nằm trong mục lưu thì kết quả là `enabled` ngay. Nếu chưa, app yêu cầu System Settings thoát (`terminate()`, không ép; không thoát được thì đi tiếp), rồi gọi `TISEnableInputSource` cho mục cha.
5. App **đọc lại** mục lưu theo chu kỳ cho tới khi có mode `.vi`, tối đa `SystemInputMethodInstaller.enableTimeout`, để người dùng có thời gian đọc và bấm Allow. Nếu có mode `.vi` thì kết quả là `enabled`. Nếu hết hạn thì kết quả là `notEnabled`; giao diện hiện "Chưa bật được". Nếu macOS ghi mục lưu sau đó thì cửa sổ nhận ra.
6. Mỗi lần kết quả là `enabled`, app chạy đúng một lượt `InputSourceCaches.removeCaches(notMentioning:)`. Thư mục con nào có `com.apple.IntlDataCache.le.kbdx` đọc được mà không chứa chuỗi UTF-8 `Input Methods/DauInputMethod.app` thì bộ đệm đó bị xoá. Nếu có ít nhất một bộ đệm bị xoá, app gọi `TISRegisterInputSource` thêm một lần. Đây là phỏng đoán dựa trên một định dạng không có tài liệu; lượt này không ném lỗi và không đổi kết quả.

Vòng chờ kiểm việc huỷ task ở mỗi lượt: `OnboardingFlow` giữ task của `enable()`. "Thử lại" huỷ task đó. Mã trả về của TIS không bao giờ coi là bằng chứng. App không tắt được Dấu, vì `TISDisableInputSource` gọi từ app bị macOS chặn (`docs/research/InputMethodInstall.md` mục 5.2). Trạng thái "đã bật" (`status()`, `InputSourceStatus.query`) là mục lưu, không phải cờ enabled của TIS (D37).

**Kiểm bộ gõ đã cài:** mỗi lần mở app và mỗi lần app lên trước, `InputMethodActions.checkInstalled` hỏi `installedIsGenuine` (`CodeSignature.isValidAndSameTeam`, yêu cầu mã ở D37); chỉ bản chủ mới hỏi. Nếu không đạt, `TamperedBanner` hiện banner "Cài lại". Bấm nút đó thì app cài lại bản nhúng. Cờ Debug `--tampered` (`DebugCapture.tampered`) ghim banner để chụp màn hình: `InputMethodActions.forceTampered` làm `checkInstalled` không đọc bộ gõ thật. Lượt `reconcile` lúc mở app không chạy.

**Giữ bộ gõ đã cài trùng bản nhúng:** lúc app mở, `InputMethodActions.startLaunchReconcile` gọi `SystemInputMethodInstaller.reconcile` và gọi `checkInstalled` khi xong. `reconcile` xét các trường hợp theo thứ tự sau và trả `ReconcileOutcome`:

1. Nếu bản đang chạy không phải bản chủ, kết quả là `notOwnerCopy` và app không đọc gì thêm.
2. Nếu app không có bộ gõ nhúng, `reconcile` ném `InputMethodInstallerError.unavailable`.
3. Nếu bộ gõ chưa được cài, kết quả là `notInstalled`.
4. Nếu bản đã cài không đọc được `Info.plist` hoặc có bundle ID khác, kết quả là `skipped`.
5. Nếu `InputMethodFiles.installedIsGenuine` sai, kết quả là `badSignature` và app không thay.
6. Nếu `InputMethodFiles.installedMatchesEmbedded` đúng (so mã băm mọi kiến trúc), kết quả là `alreadyCurrent`.
7. Trong các trường hợp còn lại, app chép ra bản tạm và chỉ đổi chỗ với bản đang có (`InputMethodFiles.replaceInstalledWithEmbedded`). Nếu đổi được, kết quả là `replaced`; app dừng tiến trình cũ và đăng ký lại. Mã trả về của lần đăng ký này chỉ ghi nhật ký, còn `install()` thì ném lỗi, vì ở lần cài đầu bước bật cần lần đăng ký đó. Nếu bản đã cài biến mất lúc đổi chỗ (vì vừa bị gỡ), kết quả là `notInstalled` và app không làm gì thêm.

`reconcile` không đụng tới trạng thái bật hay chọn; `CFBundleVersion` chỉ dùng để ghi nhật ký.

**Lệnh `Dau --reconcile-input-method`** (`ReconcileCommand`) có ở cả bản Debug và Release; `main.swift` gọi nó trước khi dựng app. Lệnh chạy đúng `reconcile` rồi thoát, không tạo `NSApplication`; vòng lặp `RunLoop.main` chạy các bước chờ. Muốn nhận kết quả thì chạy thẳng file thực thi trong bundle. Lệnh in một dòng `reconcile-input-method: <từ>: <giải thích>`. Mã thoát (`ReconcileCommand.Status`) như sau:

| Mã thoát | Từ | Nghĩa |
|---|---|---|
| 0 | `already-current` | Bộ gõ đã cài trùng bản nhúng. |
| 1 | `failed` | Có lỗi: app không có bộ gõ nhúng, chép hỏng hoặc bản nhúng sai chữ ký. |
| 3 | `replaced` | Bộ gõ đã thay bằng bản nhúng. |
| 4 | `not-installed` | Bộ gõ chưa được cài hoặc vừa bị gỡ trong lúc lệnh chạy; lệnh không làm gì. |
| 5 | `not-owner-copy` | Bản đang chạy không phải bản chủ; lệnh không làm gì. |
| 6 | `bad-signature` | Bộ gõ đã cài sai chữ ký hoặc khác Team ID; lệnh không thay. |
| 7 | `skipped` | Bản đã cài khác bundle ID hoặc không đọc được; lệnh không thay. |

Mã 2 để trống cho dòng lệnh sai, như các lệnh Debug. `scripts/dev/install-app.sh` gọi lệnh này từ bản vừa đặt vào `/Applications`, nên script không tự chép bộ gõ. Với script, mã 0 và 3 là đạt; mã 4 không phải lỗi, vì lần cài đầu đi qua nút "Bật Dấu"; mã khác làm script thoát với mã khác 0.

**Gỡ** ("Gỡ cài đặt…", D16) gồm ba bước của `SystemInputMethodInstaller`, do `InputMethodActions.performUninstall` điều phối.

1. `prepareUninstall` mở thẳng danh sách Input Sources (`SystemSettings.openInputSources`, URL `…Keyboard-Settings.extension?InputSources`; trên macOS 27.2 sheet Edit… đã mở sẵn). Bước này không chọn bàn phím nào và không tắt gì. Sheet đọc lại `InputMethodStatus.selected` khi hiện, khi cửa sổ sheet thành key lại và khi nguồn đang chọn đổi, để hiện hoặc ẩn câu nhắc rằng nút "–" có thể bị mờ.
2. `waitUntilRemovedFromInputSources` thăm dò mục lưu của Dấu (`storedEnabledIDs`) cho tới khi nó rỗng và có thể huỷ được. Trong lúc đó `UninstallRemoveSheet` hiện trên cửa sổ Cài đặt.
3. `finishUninstall` chỉ chạy khi mục lưu đã rỗng; nếu không, kết quả là `stillListed`. Bước này chuyển `~/Library/Input Methods/DauInputMethod.app` vào Thùng rác rồi dừng bộ gõ. Nếu người dùng đã tick ô, nó xoá suite App Group (`removePersistentDomain`) và phát thông báo đổi cài đặt. Bước này xoá bộ đệm của System Settings (`SystemSettingsControl.clearKeyboardCache`) nhưng không đụng tới bộ đệm của các app khác, rồi đọc lại hệ thống để báo kết quả.

### Cập nhật và báo lỗi

Phần này là trang Cập nhật & hỗ trợ (`UpdatesSupportView`); hành vi của trang tả ở `docs/UI.md`.

- **Có updater hay không:** `UpdaterConfiguration.isConfigured` đọc Info.plist của app. App chỉ tạo updater khi có cả `SUFeedURL` (https) lẫn `SUPublicEDKey`, mà hai khoá này chỉ có ở bản phát hành (mục "Build"). `DauApp.init` luôn gọi `SparkleUpdater.startIfConfigured` lúc khởi động; hàm này tự kiểm `UpdaterConfiguration.isConfiguredForThisApp` và trả nil khi thiếu khoá. Mọi bản khác không tạo gì của Sparkle (D7).
- **Sparkle:** `SparkleUpdaterBackend` giữ một `SPUStandardUpdaterController`, tức cửa sổ chuẩn của Sparkle, không có user driver riêng. Lịch kiểm tra và việc hỏi trước khi cài lấy từ các khoá `SU…` trong Info.plist (mục "Build"). Chỉ file `SparkleUpdater.swift` import Sparkle. Gói test của app chủ bỏ file này ra.
- **Trang:** `UpdatesModel` (`@Observable`, môi trường `\.updates`, chuyển vào hai cột qua `SettingsEnvironment`) theo dõi `canCheckForUpdates`, `lastUpdateCheckDate` và `automaticallyChecksForUpdates` của `SPUUpdater` bằng KVO, qua giao thức `UpdaterBackend`; test dùng một bản giả của giao thức này. Công tắc ghi thẳng vào Sparkle.
- **Sau khi cài bản mới:** Sparkle mở lại Dấu.app ở chỗ nó vừa cài. Lần mở đó là bản chủ, vì mã băm chữ ký trùng với bản trong Applications, nên `reconcileAtLaunch` → `SystemInputMethodInstaller.reconcile` thay bộ gõ đã cài bằng bản nhúng mới (D37, mục "Cài, bật, thay, gỡ bộ gõ"). Không có bước mở lại riêng.
- **Báo lỗi:** `ReportSheet` dựng `ProblemReport` từ các trường và mục "Gửi kèm". `ProblemReport.issueURL` tạo URL issue mới của `codefastlabs/dau` theo issue form `.github/ISSUE_TEMPLATE/typing-problem.yml`; tham số query theo `id` của từng trường. Test `IssueFormTests` giữ hai danh sách này khớp nhau. `NSWorkspace.open` mở URL đó trong trình duyệt (D8). `PreviousAppTracker` (bắt đầu trong `DauApp`) nhớ ứng dụng thường gần nhất trước Dấu qua `NSWorkspace.didActivateApplicationNotification` và chỉ giữ trong bộ nhớ.

### Tên hệ thống và chuỗi

#### Tên bàn phím (`LayoutNames`)

- Tên bàn phím phải hiện đúng như trên thanh menu của macOS ("U.S." trên máy tiếng Anh), không phải tên mà TIS trả cho tiến trình của app. `kTISPropertyLocalizedName` theo ngôn ngữ của tiến trình. Ngôn ngữ này có thể khác ngôn ngữ hệ thống (ngôn ngữ riêng của app hoặc `-AppleLanguages`, D41); khi đó máy tiếng Anh vẫn ra "Mỹ".
- `LayoutNames` đọc ngôn ngữ ưu tiên thật của hệ thống (`AppleLanguages` ở miền toàn cục) và tra bảng `InfoPlist.loctable` của `AppleKeyboardLayouts.bundle`; khoá của bảng là ID nguồn bỏ tiền tố `com.apple.keylayout.`. `LayoutNames` thử ngôn ngữ cụ thể trước, rồi bỏ dần phần vùng, rồi sang ngôn ngữ ưu tiên kế tiếp. Nếu không khớp thì nó dùng tên TIS.
- `LayoutNames` dùng ở `englishLayoutName` (dòng phím tắt) và ở `InputSourceEntry.name` của bàn phím (sheet gỡ, alert gỡ xong). `LayoutNames` chỉ đọc (N4). Bảng đọc một lần, còn danh sách ngôn ngữ đọc ở mỗi lần gọi.

#### Tên giao diện của macOS trong chữ của Dấu

Phần này là `SystemUINames` (D38 (Chữ trên giao diện)).

- Danh sách đủ là các case của enum `SystemUIName`. Đây là nơi duy nhất giữ danh sách. `docs/Glossary.md` dẫn sang đây. Mỗi case có một dòng trong `SystemUINames.location(of:)`. Danh sách gồm các tên của System Settings, thư mục Applications (`applications`), Trash của Finder (`trash`), tên ngôn ngữ "Vietnamese", hộp thoại "Allow … to enable …?" (`allowDialogTitle`, `allowDialogBody`) và tên nguồn của chính Dấu (`dauInputSource`). Tên nguồn của Dấu đọc từ `InfoPlist.strings` của bộ gõ đã cài hoặc của bản trong app nếu bộ gõ chưa được cài, với khoá là ID input mode.
- Ngôn ngữ lấy như `LayoutNames`. Chữ lấy từ bảng của chính hệ thống (`SystemUITable`; đường dẫn ở `SystemUINames.tableURLs` và `loadTables`). "Applications" lấy từ `SystemFolderLocalizations` qua `folderNames`, "Trash" lấy từ `Localizable.strings` của Finder qua `finderNames`. Tên ngôn ngữ lấy từ `Locale`. Khoá tìm bằng cách khớp giá trị tiếng Anh. Nếu ngôn ngữ đầu là tiếng Anh hoặc không khớp ở mọi ngôn ngữ ưu tiên, thì Dấu dùng tiếng Anh.
- Câu chữ của Dấu dùng `%@` cho các tên này; khái niệm chung thì dùng thuật ngữ Apple của từng ngôn ngữ (`docs/Glossary.md`). Bộ gõ không dùng hai file này.

#### Chuỗi giao diện

- Mỗi target có `Localizable.xcstrings` và `InfoPlist.xcstrings`. Ngôn ngữ gốc là tiếng Anh, khoá là câu tiếng Anh viết thẳng trong mã (`Text("…")`, `String(localized:)`) và tiếng Việt là bản dịch (D41).
- `scripts/check-l10n/check.sh` kiểm mọi khoá có đủ bản `en` và `vi` đã dịch, cùng các `%@`/`%lld`.
- Ô tìm của sidebar so với chữ đang hiện (`SettingsSection.matches`), nên người dùng tìm được bằng ngôn ngữ đang dùng.

### Danh sách tương thích, bộ gõ cũ

- Danh sách tương thích có sẵn trong app (`Apps/Dau/Resources/CompatibilityList.json`, xem mục DauShared).
- Phần phát hiện bộ gõ cũ (D14) nằm ở `Apps/Dau/Sources/OnboardingServices.swift`:
  - `KnownInputMethods` liệt kê các bộ gõ chặn phím, với bundle ID và các bước tắt đã kiểm, hoặc các bước chung không nhắc chữ trên menu (N5). `detect()` so bundle ID với `NSWorkspace.shared.runningApplications` và với các app đã cài. `OnboardingFlow` chỉ coi bản **đang chạy** là xung đột (`conflicts`) và chỉ hiện bước 1 khi có xung đột.
  - `InputSourceStatus.otherVietnameseSourceNames` đọc TIS để tìm các nguồn chọn được, có ngôn ngữ đầu là `vi`, khác Dấu và thuộc kiểu bàn phím (Telex/VNI của Apple, XKeyIM). Các nguồn này chỉ nêu ở bước 2 (`OtherSourcesNote`).

## Build

- `Dau.xcodeproj` sinh từ `project.yml` bằng XcodeGen; không sửa tay và không commit file này. Scheme `Dau` build cả bộ gõ và nhúng nó vào `Dau.app/Contents/Library/Input Methods/DauInputMethod.app`.
- Định danh và Team ID theo D24. Chúng đặt ở `project.yml` (`BUNDLE_ID_PREFIX`), `Config/Signing.xcconfig` (`DEVELOPMENT_TEAM`) và `Config/Local.xcconfig`; git bỏ qua file cuối. Mỗi máy đặt team khác ở đó nếu cần. Bước ký dùng chế độ tự động với "Apple Development".
- ID input mode viết cứng ở ba nơi: `Apps/DauInputMethod/Info.plist`, `Apps/DauInputMethod/Resources/InfoPlist.xcstrings` (vì Xcode không thay biến trong khoá plist) và `SystemUINames.location` (tên nguồn của Dấu). Đổi bundle ID thì phải sửa cả ba nơi (D37: bundle ID không đổi giữa các bản).
- Về kiến trúc, bản Release luôn là universal. Bản Debug build bằng `xcodebuild` không kèm `-destination` chỉ ra kiến trúc của máy đang build, vì Xcode build package cục bộ theo kiến trúc máy. Muốn bản Debug universal thì thêm `-destination 'generic/platform=macOS'`; `scripts/lib/build.sh` dùng destination này cho `dau_build`.
- Mã commit của bản build: `scripts/build/stamp-build-commit.sh` ghi `build/generated/BuildCommit.txt` (thêm "+" khi còn thay đổi chưa commit). Script chạy lúc `xcodegen generate` (preGenCommand) và ở mỗi lần build bộ gõ. Dấu.app và bộ gõ chép file này vào Resources, nên bản build ký lại khi mã đổi. App hiện "Dấu x.y.z (mã)" ở đáy sidebar và ở thẻ đầu trang Cập nhật & hỗ trợ. `scripts/dev/dau-version.sh` so mã của bộ gõ đã cài, của Dấu.app và của repo. Script này cũng cho biết bộ gõ đã cài có phải bản mới nhất của `main` không (theo đầu vào build và Xcode).
- Sparkle 2 là Swift Package, ghim bản chính xác trong `project.yml`. Chỉ target `Dau` link Sparkle; bộ gõ không link Sparkle (N2). `SUFeedURL` và `SUPublicEDKey` không nằm trong `Apps/Dau/Info.plist`. Phase "Sparkle keys" của target `Dau` ghi hai khoá này vào Info.plist đã build khi `DAU_OFFICIAL=YES` và xoá chúng ở mọi bản khác (D7). Khoá công khai lấy từ build setting `DAU_SPARKLE_PUBLIC_KEY`; thiếu thì build lỗi. `SUEnableSystemProfiling` là `false` (D8). `SUEnableAutomaticChecks`, `SUScheduledCheckInterval` (86400) và `SUAllowsAutomaticUpdates` (`false`) có trong `Apps/Dau/Info.plist` ở mọi bản (D7). Bản phát triển không có `SUFeedURL`, nên app không được khởi động Sparkle ở bản đó. Lúc chạy, app chỉ khởi động Sparkle khi Info.plist có cả hai khoá (`UpdaterConfiguration`, mục "Cập nhật và báo lỗi").

## Log, signpost, cờ Debug

- `os_signpost` có một interval `handle` bao quanh `DauInputController.handle(_:client:)` và một interval quanh mỗi lời gọi client (`selectedRange`, `attributedSubstring`, `setMarkedText`, `insertText`); các interval này xem bằng Instruments. Ở bản Debug, signpost luôn bật, không phụ thuộc khoá `DauPerfLog`.
- Nhật ký từng phím (category `perf`, `diag`) và signpost chỉ có ở bản Debug; chúng bị loại khỏi bản Release lúc build (D8). Nhật ký từng phím chỉ ghi khi khoá `DauPerfLog` đã đặt trong global domain.
  - `scripts/selftest/typing/run.sh` tự bật khoá này lúc chạy và trả khoá về như cũ khi xong. Khi đo tay thì bật khoá, đo, rồi xoá khoá (`scripts/perf/perf-report.sh`).
  - Mỗi dòng phím có `t_ns` (lúc `handle` bắt đầu, theo `CLOCK_UPTIME_RAW`) và `ev_ns` (thời điểm của chính sự kiện phím). Từ hai giá trị này, `perf-report.sh` dựng khoảng cách giữa các phím và độ trễ từ lúc tạo phím tới bộ gõ, cho bài test tải nặng (`scripts/selftest/load/heavy.sh`, D42 (Ngưỡng hiệu năng)) và bài một app bận (`scripts/selftest/load/run.sh`).
- Bộ gõ bản Debug đọc thêm khoá `DauDebugForceUnderline` (mảng bundle ID, miền global) để ép gạch chân khi thử mà không đụng tới cài đặt của người dùng; bản Release không đọc khoá này.
- **Cờ chạy của app chủ bản Debug** nằm trong `#if DEBUG`; danh sách đủ nằm ở nơi định nghĩa từng cờ.
  - Các cờ chạy không mở cửa sổ, in một giá trị rồi thoát là các cờ `--print-…` ở đầu `main.swift` và `--set-typing-method` ở `DebugSettingsCommand`. (`--reconcile-input-method` có ở cả bản Release, xem mục "Cài, bật, thay, gỡ bộ gõ".)
  - Các cờ chụp màn hình với dịch vụ giả và chọn màn hình hay trạng thái (`--capture-…`, `--onboarding`, `--shortcut`, `--active`, `--tampered`) nằm ở `DebugCapture.swift` và `DauApp.swift`.
  - Các cờ mở app thật để đo từ bên ngoài (`--settings-window`, `--appearance`) nằm ở `DebugCapture.swift`.
  - `scripts/selftest/settings-window` dùng các cờ này để kiểm giao diện (`docs/UIChecks.md`).
