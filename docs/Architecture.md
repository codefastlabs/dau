# Kiến trúc

## Phạm vi

Tài liệu này tả cấu trúc: thành phần nào làm gì, gọi nhau ra sao, luồng một phím đi qua đâu. Luật và lý do nằm ở [`docs/Decisions.md`](Decisions.md); ở đây chỉ dẫn số D/N. Số đo không nằm ở đây (hằng số kèm tên trong mã là giá trị cấu hình, không phải số đo): số đo theo ngày ở `docs/Progress.md` (mốc đang làm) và `docs/history/` (mốc đã đóng; bảng "Số đo (M1–M3)" ở `docs/history/LogM0ToM4.md`), số đo giao diện ở `docs/research/SystemSettingsReference.md`. Lịch sử các thay đổi của tài liệu: `docs/history/DocsLog.md`.

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
│  └─ Dau/                     # app chủ SwiftUI, không sandbox (D37 (Cài đặt bộ gõ)): Cài đặt, onboarding, cài/thay/gỡ bộ gõ
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

- **App chủ** (`Apps/Dau`): giao diện Cài đặt và onboarding; cài, bật, thay và gỡ bộ gõ; mọi kết nối mạng (N2).
- **Bộ gõ** (`Apps/DauInputMethod`): một tiến trình nền do macOS chạy khi có app cần; nhận phím qua InputMethodKit và ghi chữ vào app đang gõ. Không mạng, không đọc danh sách tương thích.
- **App Group:** cả cài đặt là một JSON trong suite chung. App chủ ghi rồi phát thông báo Darwin; bộ gõ nghe và đọc lại.
- **Thông báo Darwin:** chỉ là gợi ý để đọc lại trạng thái thật (D18 (Phòng thủ với IMK)), vì tiến trình nào cũng phát được: đổi cài đặt, yêu cầu thoát.
- Engine (`DauEngine`) là thư viện thuần dùng trong bộ gõ và trong phần xem trước của app chủ (qua `DauShared`).

## Luồng một phím

1. IMK gọi `handle(event, client)` trên main thread. Event nil hay bất thường bị bỏ qua (D18).
2. Phím điều khiển (mũi tên, tổ hợp ⌘/⌃/⌥, Esc…): reset engine, trả `false` cho hệ thống xử lý. Không khôi phục từ (D4 (Từ nước ngoài)).
3. Backspace: engine bỏ chữ cuối đang hiển thị và đặt lại dấu (D32 (Backspace)). Phím luôn đi tiếp tới app để app tự xoá chữ cuối; khi dấu phải dời, bộ gõ thay phần trước nó trong cùng phím (mục "Backspace thay tại chỗ").
4. Ký tự: `engine.handle(scalar)`.
   - `passThrough`: trả `false`.
   - `replace(n, s)`: `client.insertText(s, replacementRange: vùng n ký tự trước con trỏ)`, trả `true`.
   - Engine rỗng mà chưa biết chữ trước con trỏ: có thể đọc chữ của app trước (D20 (Thêm dấu cho từ đã gõ), mục "Thêm dấu cho từ đã gõ").
5. Ký tự kết thúc từ (Space, dấu câu, Enter, Tab): từ không phải âm tiết tiếng Việt hợp lệ thì khôi phục phím gốc (D4), rồi chốt và reset.

Ở chế độ gạch chân (D13 (Gạch chân là đường lui cuối cùng)), bước 3–5 ghi chữ bằng marked text thay cho thay chữ tại chỗ (mục "Chế độ gạch chân").

## DauEngine

- `struct VietEngine: Sendable` giữ từ đang gõ trong bộ đệm dung lượng cố định.
  - Bộ đệm là `TextBuffer`: tối đa 32 scalar, lưu trong `SIMD32<UInt32>` (`InlineArray` cần macOS 26).
  - Không cấp phát mỗi phím (số đo: bảng "Số đo (M1–M3)" ở `docs/history/LogM0ToM4.md`, dòng cấp phát).
- API: mọi hàm `mutating`, trả `Action`.
  - `handle(_ key: Unicode.Scalar)`: chữ cái và chữ số nối vào từ; ký tự in ra khác (Space, Enter, Tab, dấu câu) kết thúc từ (D4) và nằm luôn trong `insert`; ký tự điều khiển, 0x7F và phím chức năng 0xF700–0xF8FF chỉ `reset()`.
  - `backspace()` (D32): IMK gọi hàm này cho phím xoá, **không** đưa 0x7F vào `handle`.
  - `endWord()`: kết thúc từ không chèn ký tự, cho Return/Tab/Enter bàn phím số (0x03) khi IMK để app tự xử lý phím.
  - `seed(displayed:) -> Bool` (D20): nạp từ đọc được từ ứng dụng; nhận NFC hoặc NFD.
  - `seedOverflow(shown:)` (D20 ngoại lệ (b), D33 (Độ dài từ)): với từ có sẵn mà `seed` không nhận, vào trạng thái đi thẳng của D33 cho phần còn lại của từ.
  - `reset()`, `isComposing`.
- `Action` là `.passThrough` (IMK trả `false`) hoặc `.replace(deleteCount:insert: TextBuffer)`.
  - `.replace` xoá `deleteCount` **scalar** trước con trỏ và chèn `insert` trong một lần `insertText` (N3 (Ít lời gọi vào ứng dụng đích)).
  - Chữ Việt dựng sẵn đều nằm trong BMP nên số scalar bằng độ dài UTF-16. Ngoại lệ: từ được seed từ NFD, khi đó IMK tự đo chuỗi đã seed.
- `EngineOptions`: kiểu gõ (`telex`, `simpleTelex`, `vni`); vị trí dấu (`modern`/`classic`); bỏ dấu tự do (D28 (Bỏ dấu tự do)); tự khôi phục (D4, D30 (Kiểm tra chính tả), D33); `advanced: .off | .consonantShortcuts | .allowZFWJ`, một enum nên hai mục loại trừ nhau (D22 (Gõ tắt loại trừ z, f, w, j)).
- Đường nóng không dùng `String`, `any Protocol`, closure, không import Foundation. Engine dựng thẳng ký tự NFC từ bảng (D3 (Không macro, chỉ Unicode dựng sẵn)), không chuẩn hoá lúc chạy.
- Test: `FuzzTests` (D18) và `PerformanceTests` chạy trong mọi `swift test --package-path Packages/DauEngine`; ngưỡng của test hiệu năng lỏng để bản Debug cũng đạt, số của bản Release đo bằng `swift test -c release --filter Performance`.

## DauShared

- Phụ thuộc DauEngine để đổi cài đặt sang `EngineOptions` và chạy engine thật cho phần xem trước. Không dùng trong đường nóng của engine.
- `DauSettings`: Sendable, Codable, mặc định theo D15 (Cài đặt mặc định). `advanced` là một enum nên D22 không thể bật cả hai.
- `AppRule` (D5 (Quy tắc theo ứng dụng), D13): bundle ID, tên hiển thị, gạch chân, nguồn ("Đề xuất" hay người dùng). Không có chế độ Việt/Anh.
- Giải mã `DauSettings` và `AppRule` dễ dãi (D18): khoá lạ hoặc khoá cũ (`rememberModePerApp`, `mode` của quy tắc) bị bỏ qua, quy tắc cũ giữ lựa chọn gạch chân, lần lưu sau không ghi lại các khoá đó. Hệ quả: quy tắc cũ chỉ có "Tiếng Anh" thành quy tắc không làm gì, và Dấu gõ tiếng Việt ở app đó, không báo người dùng; chấp nhận vì chưa có bản phát hành nào.
- Giải mã đọc tối đa `DauSettings.maxAppRules` quy tắc; gộp quy tắc trùng bundle ID trong O(n) (`DauSettings.merged`): cái sau thắng, giữ chỗ của cái trước.
- `SettingsStore`:
  - lưu cả cài đặt thành một JSON dưới khoá `settings` trong UserDefaults suite = App Group (`DauAppGroupIdentifier` trong Info.plist, giá trị `$(TeamIdentifierPrefix)$(BUNDLE_ID_PREFIX).shared`);
  - sau mỗi lần lưu phát thông báo Darwin `<suite>.settingsDidChange`; `synchronize()` của suite này trả false dù ghi thành công, nên không dùng làm dấu hiệu lỗi;
  - `observeChanges` cho bộ gõ áp dụng ngay; ai cũng phát được thông báo này, nên bộ gõ gộp các thông báo đến dồn thành một lần đọc (`ChangeCoalescer`, sau `ChangeCoalescer.delay`).
- `CompatibilityList` (D7 (Cập nhật và loại bản dựng), D13): danh sách app được gắn nhãn "Đề xuất".
  - Mỗi mục có các bundle ID của một app, tên, cờ `suggestUnderline`, ghi chú cho người bảo trì (không hiện lên giao diện, N5 (Chỉ hứa điều đã kiểm chứng)). Cả danh sách có `version`.
  - Giải mã dễ dãi (D18): khoá lạ bị bỏ qua; mục hỏng hoặc không có bundle ID bị bỏ mà không mất các mục khác; file hỏng thành danh sách rỗng.
  - Bản có sẵn là `Apps/Dau/Resources/CompatibilityList.json`; app nào có mặt, cờ và lý do nằm ở chính file đó (`about`, `note`). Test trong DauShared đọc chính file này. App chủ lấy danh sách ở `CompatibilityList.bundled()`.
  - `DauSettings.suggestions(from:isInstalled:)` dựng các hàng "Đề xuất": app đề xuất đã cài mà chưa có quy tắc đã lưu, theo thứ tự danh sách; **không lưu** gì. "Bật gạch chân" gọi `acceptSuggestion`, lưu quy tắc "Có gạch chân" nguồn `suggested` vào cuối "Quy tắc riêng".
  - "Quy tắc riêng" là đúng `appRules` đã lưu. `setUnderline(_:for:)` đổi popup mà giữ quy tắc và nguồn; đặt về "Không gạch chân" vẫn là quy tắc. Mọi quy tắc đã lưu đưa app ra khỏi "Đề xuất"; xoá quy tắc thì app trở lại.
  - Bộ gõ **không** đọc danh sách: gạch chân chỉ theo quy tắc đã lưu (D13).
- `TypingPreview`/`TypingExample`: chạy engine thật như bộ gõ. App chủ dùng chúng cho mọi ví dụ "phím → kết quả" trên giao diện (`SettingsSamples`, test ở `scripts/snapshot-settings`), nên mọi ví dụ do engine tính (N5).
- `InputMethodLifecycle`: tên và cách phát, nghe yêu cầu thoát của bộ gõ (mục "Thoát theo yêu cầu của app chủ").

## Bộ gõ (DauInputMethod)

### Điều khiển và hai chế độ ghi chữ

- Lớp con `IMKInputController`, mỗi client một instance và một `VietEngine` riêng. Không có trạng thái toàn cục (khác OpenKey).
- `handle(_:client:)` đưa phím vào engine qua `InPlaceComposer` (thay tại chỗ) hoặc `MarkedComposer` (gạch chân). Cả hai là kiểu giá trị thuần, test bằng client giả.
- Thay tại chỗ: nếu engine trả `replace`, hỏi `selectedRange` một lần để có vị trí tuyệt đối rồi gọi `insertText(_:replacementRange:)` đúng một lần (N3). Bản Debug có thêm một lần hỏi sau khi thay để chẩn đoán (`ReplaceDiag.swift`); số đo trên bản Debug có lời gọi thừa này.
- Engine reset khi: click chuột; `activateServer`/`deactivateServer`, `commitComposition`; phím di chuyển con trỏ; `selectedRange` khác dự đoán mà không phải app trả lời chậm (D11 (Kiểm tra ngữ cảnh)); nguồn nhập liệu đổi mà IMK không báo (mục "Đổi nguồn nhập liệu không qua `activateServer`").

### Vị trí thay chữ

Bảng dưới là toàn bộ lời gọi hỏi app trong thay tại chỗ. Mọi lần đọc chữ là một `attributedSubstring` trước con trỏ; client trả `NSNotFound` hay `nil` thì thôi đọc tới lần `activateServer` sau (D18).

| Phím | Hỏi `selectedRange` | Đọc chữ trước con trỏ | Quyết định |
|---|---|---|---|
| Đi thẳng, đang có từ | không | không | N3 |
| Có thay chữ, vị trí trùng vị trí Dấu theo dõi | một lần | không | N3, D11 |
| Có thay chữ, vị trí khác vị trí Dấu theo dõi | một lần | một lần: chứng minh app chậm; dựng lại từ chữ đó chỉ khi phím trước cách đủ `settleInterval` | D11 |
| Dấu/biến đổi đầu tiên trong từ đã hết hợp lệ, phím trước cách đủ `settleInterval` | một lần | tối đa một lần mỗi từ | D11 |
| Chữ cái hoặc dấu/biến đổi đầu tiên khi engine rỗng, chưa biết chữ trước con trỏ, phím trước cách đủ `settleInterval` | một lần, kể cả khi phím đi thẳng | một lần | D20 |
| Mọi phím ở chế độ gạch chân | không | không | D13 |

Ô bỏ qua vùng thay (Ghostty, terminal dựng bằng xterm.js) không được xử lý riêng: thay tại chỗ như mọi ô (D43 (Ô bỏ qua vùng thay chữ)).

`InPlaceComposer.settleInterval` là ngưỡng chung cho các lần đọc dùng chữ để dựng từ (D20 nói vì sao). Phép chứng minh app chậm không chờ: nó không dựng từ từ chữ đọc được, chỉ quyết định thay ở vị trí nào.

#### App trả lời chậm

`CursorTracker` theo dõi vị trí con trỏ của Dấu qua các từ, để thay đúng chỗ khi app trả vị trí và chữ cũ (D11, ý "App trả lời chậm").

- **Hiện tượng:**
  - Chrome khi trang bận: app áp phím theo thứ tự nhưng trả `selectedRange` và `attributedSubstring` từ chữ cũ, chưa có vài phím gần nhất. Lần thay đầu của một từ dùng vị trí cũ đó nên thay nhầm chữ đứng trước ("bạn" ra "ạnn"); vị trí dự đoán của composer (`expected`) chỉ có trong một từ nên không bắt được.
  - Phím dồn ở Chrome, VS Code, Firefox (`docs/Compatibility.md` mục 6.2): app chậm cả loạt phím vừa gõ.
  - Trình soạn thảo của Cursor: `selectedRange` và vùng thay tính từ đầu từ đang gõ, về 0 sau mỗi dấu cách, nên vị trí app trả luôn khác vị trí Dấu theo dõi dù app không chậm. Vùng thay bắt đầu ngoài chữ app đang giữ thì bị bỏ. Ô nhập Agents của Cursor và VS Code tính từ đầu văn bản.
- **Trạng thái của `CursorTracker`:**
  - `known`: vị trí con trỏ Dấu theo dõi qua ranh giới từ. Mất khi reset (click, mũi tên, phím tắt, Return/Tab, đổi client) và khi ⌫ đi thẳng mà không biết chữ bị xoá. `known` không thay cho `expected`: ở đầu từ, vị trí khác `known` vẫn có thể là app tự sửa chữ (tự sửa chính tả, gạch ngang thông minh).
  - `edits`: các thao tác gần nhất bộ gõ đã làm hoặc để đi thẳng; thao tác chèn tại con trỏ được đánh dấu `atCaret`.
  - `tail`: chữ chính bộ gõ đã gõ ngay trước con trỏ.
  - `burst`: số thao tác gần nhất do các phím đến liền nhau dưới `settleInterval` tạo ra; composer báo ở mỗi phím (`keyInBurst`).
- **Chứng minh app chậm** (`rebuild`), khi ở phím thay chữ `selectedRange` khác `known`:
  - Chữ đọc được, ở một trong hai dạng, cộng các thao tác app chưa áp ra đúng từ trong engine, mỗi thao tác xoá gặp đúng chữ nó xoá: (a) chữ như trước các thao tác đó (Firefox; Chrome khi không có thao tác chèn tại con trỏ); (b) chữ đó cộng thao tác chèn tại con trỏ mới nhất trong số đó (bộ đệm Chromium).
  - Số thao tác app được chậm: tối đa `lateLimit`, cộng `burst`. Vượt `lateLimit` thì chữ app trả trước các thao tác đó cũng phải là `tail`, so ít nhất hai đơn vị chữ của app (một, khi phần đọc bắt đầu từ đầu văn bản), và mọi thao tác xoá trong số đó phải biết chữ bị xoá. Lý do: thao tác thay làm ở vị trí app trả bắt đầu lại `tail` và không biết chữ nó xoá, nên dựng lại qua nó thì khớp với mọi chữ; ở Cursor, vị trí app trả trùng vị trí của lần thay trước trong từ nên app đúng giờ bị coi là chậm.
  - Trong `lateLimit`, chữ dựng lại và `tail` phải trùng ở phần cả hai cùng có (ở Cursor, sau một từ một chữ cái có thay chữ, chữ của từ mới cộng hai thao tác cuối có thể ra đúng từ trong engine dù bộ gõ đã gõ chữ khác: "ở đâu" ra "ở dâu").
  - Đầu văn bản (`typedHere`): khi các thao tác đó bắt đầu từ đầu văn bản và phím đang xử lý cũng thuộc loạt phím dồn, coi là app chậm mà không cần chữ của app. Sau một quãng nghỉ thì không, vì người dùng có thể đã bấm chuột mà IMK không báo.
  - Hoặc chữ đọc được là `tail` thiếu đúng số đơn vị app chậm (tối đa `lateLimit`), so ít nhất hai đơn vị; đơn vị thiếu phải đứng sau ít nhất một đơn vị đã so (bộ đệm Chromium thiếu phần trang chưa báo, nằm sau chữ nó đã có). `tail` mất các đơn vị đầu là app chỉ giữ từ đang gõ (Cursor: đọc được "co" ở chỗ đã gõ "ừ co").
- **Kết quả:**
  - Chứng minh được: thay ở `known` (kind `late` trong log perf). Vùng thay luôn kết thúc ở `known`.
  - Lần thay đầu của từ, app chậm tối đa `lateLimit` mà không chứng minh được, và trước vị trí app trả không có đủ cả từ: vẫn thay ở `known` (kind `late_guess`). App sửa chữ trước từ (gạch ngang thông minh) thì trước vị trí nó trả có đủ cả từ, nên vị trí của app được tin.
  - Còn lại: trong từ là lệch (D11), đầu từ thì tin `selectedRange`.
  - Vị trí lấy từ một `selectedRange` có thể cũ không ghi đè `known` (ghi đè làm lần trả lời chậm sau trùng với `known` sai, ví dụ "kóo").
- Cùng cách chứng minh dùng ở phép kiểm từ đã hết hợp lệ (`checkLockedWord`) và ở lần đọc của D20 sau ⌫ (`addMarks`, thao tác chưa áp phải là xoá đã biết chữ).
- **Giới hạn:**
  - App chậm hơn số thao tác trên mà không chứng minh được thì như trước.
  - Ở đầu văn bản, app tự xoá hết chữ giữa hai phím của một loạt phím dồn trả lời giống hệt bộ đệm Chromium khi trang chưa báo gì, nên bị coi là app chậm: một `insertText` có vùng thay nằm ngoài chữ, phím thay chữ sau đó mới thấy lệch (`RapidKeysTests.clearedAtStartInBurst`).
  - App tính vị trí từ đầu từ (Cursor; mô hình `LateDocument.Origin.word`): app chậm thật qua ranh giới từ thì thay ở vị trí nào cũng sai (`staleAnswerAcrossWords`). App đúng giờ bị coi là chậm khi mọi phím từ lúc lấy vị trí ở đầu chữ app giữ tới phím đang xử lý thuộc một loạt phím dồn, và phím đó là phím thứ hai của một từ không phải từ đầu (`burstFromStartOfWord`): vị trí, chữ đọc được và `known` giống hệt tài liệu mới chưa áp phím nào của app dùng bộ đệm Chromium (`sameAnswerAsLateNewDocument`). Chỉ áp ca tài liệu mới cho từ đầu tiên thì sửa được Cursor nhưng mô hình VS Code và Firefox sai lại (`stalledStartTable`). Một ca chỉ có ở mô hình: `wordStartingAsTheText`. Chưa sửa.
- **Kiểm:** client giả trong `LateAnswerTests`, `RapidKeysTests` và `CursorEditorTests` (mô hình Chrome, VS Code, Firefox theo mã nguồn, mô hình Cursor theo log đo; thời gian của app là số chọn, không phải số đo).

**Chromium và Firefox theo mã nguồn** (chưa đo trên bản đã cài; cơ sở cho mô hình trong test):

- Chromium: thay với `replacementRange` trong ô thường giữ con trỏ và dời nó theo độ dài đổi (`ReplaceTextAndKeepSelection`); với EditContext (VS Code dùng mặc định) con trỏ về cuối vùng vừa thay. Lời gọi của bộ gõ và phím vào cùng hàng đợi của trang. `selectedRange` và `attributedSubstring` trả từ bộ đệm phía trình duyệt, không hỏi trang; mỗi `insertText` không vùng thay được ghi ngay vào bộ đệm đó ở vị trí con trỏ trang báo lần trước, `insertText` có vùng thay thì không.
- Firefox: vị trí và chữ trả từ bộ đệm của tiến trình cha, chỉ cập nhật khi tiến trình nội dung báo; thay với vùng thay là chọn vùng rồi chèn, con trỏ về cuối vùng vừa thay.

#### Thêm dấu cho từ đã gõ

`InPlaceComposer.addMarks` (D20). Điều kiện đọc ở bảng trên; thêm: công tắc `addMarksToTypedWords` bật (đọc lúc `activateServer` và khi cài đặt đổi, không theo phím); phím là phím dấu/biến đổi của kiểu gõ (`isMarkKey`: Telex `s f r x j z a e o w d` hoa hay thường, VNI chữ số) hoặc chữ cái ASCII khác (`isLetter`). "Chưa biết chữ trước con trỏ" là đầu phiên, sau reset, click, ⌫ hay Return/Tab; sau một ký tự kết thúc từ gõ ở đây thì đã biết, không đọc.

- **Đọc:** một `selectedRange` (phải là con trỏ, không vùng chọn); một `attributedSubstring` tối đa `InPlaceComposer.readLength` đơn vị UTF-16 ngay trước con trỏ, lấy dãy chữ cái/dấu kết hợp/chữ số cuối cùng; `seed(displayed:)`; rồi đưa phím vào engine.
- **Sau đó:** `replace` thì một `insertText` thay đúng vùng chữ đã đọc (đếm UTF-16; mọi ký tự engine nhận thuộc BMP, kể cả NFD); `passThrough` thì phím đi thẳng và engine giữ từ để gõ tiếp (mốc khôi phục D4 là chữ đã đọc).
- **Nối hay không** (`seedWord`), quyết định chỉ từ chữ đã đọc và trạng thái engine, trước khi gửi gì, nên phím không nối chỉ tốn đúng lần đọc:
  - Từ không phải tiếng Việt: phím được nhận nguyên văn tới hết từ. Từ đã khoá chính tả D30 thì giữ seed; từ toàn chữ cái mà `seed` không nhận thì `continueForeignWord` gọi `seedOverflow`.
  - Trên từ tiếng Việt, chữ hoa sau chữ thường (`startsNewWord`) bắt đầu từ mới, trừ phím dấu/biến đổi có thay chữ trong từ.
  - Từ tiếng Việt mà sau phím không còn là tiền tố hợp lệ (`isValidPrefix`): với chữ cái thường, và với phím dấu/biến đổi không áp dụng được (gõ đúp D26 (Gõ đúp phím dấu) là áp dụng), bỏ từ đã đọc, reset engine và xử lý phím như phím đầu của từ mới.
  - Từ seed đã khoá chính tả là chữ thật của app nên không kiểm lại theo D11 (`checkedLockedWord`). Lần đọc để đồng bộ của D11 dùng cùng `seedWord` nhưng không áp các luật này (`SeedRule.resync`).
- **Từ hệ thống vừa sửa** (`seedWord`, trước khi đưa phím vào engine):
  - Composer nhớ từ nó vừa trả (`InPlaceComposer.produced`), đặt khi một ký tự kết thúc từ gõ ở đây kết thúc từ; không đặt cho từ D4 đã khôi phục (`producedWord`; khác với mở rộng của D21 (Gõ tắt phụ âm), nhận ra bằng bản sao engine tắt gõ tắt) hay từ kết thúc khi còn hiện chữ của phím gõ đúp bỏ dấu (`undidMark`; ⌫ xoá chữ đó thì từ lại được nhớ như mọi từ).
  - Từ nhớ sống qua đúng một phím, cộng một ⌫ ở giữa; phím khác, ⌫ thứ hai, `reset` và `activate` xoá nó.
  - Phím dấu/biến đổi ngay sau ⌫ đó: nếu từ đọc được khác từ nhớ mà engine thử (`isSystemFix`) ra đúng từ đọc được, không phân biệt hoa thường, thì engine giữ từ đọc được, không gửi gì, phím bị nuốt (kind `seed_kept`). Không thêm lời gọi nào ngoài lần đọc của D20.
- **Lỗi đọc** (D18): chuỗi sai độ dài, không có chữ, từ có chữ số mà `seed` không nhận, có vùng chọn thì không seed, phím xử lý như phím đầu của từ mới.
- **Log perf:** kind `seed` (đã thay), `seed_pass` (đọc, seed, phím đi thẳng), `seed_kept`, `seed_none` (đọc, không có từ, hoặc chữ cái không nối được), trường `read_ns`; bản Debug thêm `d20=mark|letter|none`, `seeded=0|1`, `diff=0|1|-`. `scripts/perf/perf-report.sh` đếm các trường này.
- Gõ liền qua dấu cách không đọc thêm lần nào; tối đa một lần ở phím đầu của phiên (test `sample`, `InPlaceComposerLetterTests.sentence`).
- Terminal không chuyển phím ⌫ cho bộ gõ (`docs/Compatibility.md` mục 6.5), nên ở Terminal D20 sau ⌫ không bao giờ chạy và ⌫ giữa từ không qua D32: "hoaf⌫␣" ra "ho " thay vì "hò "; "tooi⌫s" ra "tôs" (`CursorTracker` bắt lệch).

### Backspace thay tại chỗ

D32. `backspace()` trả `passThrough` thì ⌫ đi thẳng. Trả `replace` (dấu phải dời, "hoà" ⌫ → "hò") thì vẫn **không nuốt phím**: một `selectedRange`, một `insertText` thay phần chữ cần đổi **kèm lại chữ cuối** ("oà" → "òà"), rồi lệnh xoá của chính ứng dụng bỏ chữ cuối đó (`VietEngine.lastShown`).

- Lý do: Chromium/Electron luôn gửi phím ⌫ gốc cho trang sau chữ của bộ gõ, dù bộ gõ đã nuốt phím, nên nuốt phím làm mất thêm một chữ (`docs/history/CompatibilityFixed.md`).
- Cách này cần ứng dụng áp `insertText` trước lệnh xoá: AppKit làm trong lúc `handle`, Chromium theo mã nguồn. Thứ tự ngược thì phím thay chữ kế tiếp thấy lệch (D11) và reset.
- Chữ cuối là dấu kết hợp (NFD) thì không đoán: reset, ⌫ đi thẳng.

### Chế độ gạch chân

`MarkedComposer.swift` (D13), bật khi quy tắc của app có `underline`. Từ đang gõ hiện bằng `setMarkedText` (app tự vẽ gạch chân), chốt bằng `insertText` khi kết thúc từ. Mọi lời gọi dùng `replacementRange` = NSNotFound, nên **không bao giờ hỏi `selectedRange`**; vì vậy chế độ này đúng với app áp phím bất đồng bộ, và không có D20 (biến từ đã chốt thành marked text thì cần vị trí tuyệt đối).

Lời gọi mỗi phím (tối đa một, N3):

- chữ cái, chữ số, Backspace trong từ: một `setMarkedText` với cả từ (chuỗi rỗng xoá marked text khi xoá hết từ);
- ký tự kết thúc từ: một `insertText` gồm từ (đã khôi phục nếu D4 bảo vậy) và ký tự đó, phím được nuốt;
- Return, Tab, Enter bàn phím số: một `insertText` của từ rồi để app xử lý phím (ứng dụng chat vẫn gửi tin);
- mũi tên, Esc, tổ hợp ⌘/⌃/⌥ và các sự kiện reset (click, `deactivateServer`, `commitComposition`, đổi nguồn/mode, đổi client, đổi cài đặt): một `insertText` của **đúng chữ đang hiện**, không khôi phục, rồi phím đi tiếp tới app; chốt vào client đã nhận marked text nếu nó còn, không thì client của sự kiện; không còn client nào thì bỏ trạng thái (D18);
- không có từ đang gõ: không gọi gì, phím đi thẳng.

Gõ đúp, khôi phục, độ dài từ giống hệt thay tại chỗ: `MarkedComposer` giữ bản sao chữ engine đang hiển thị và áp nguyên `Action` lên đó (test so khớp ngẫu nhiên với thay tại chỗ). Chuỗi chữ dài hơn 32 ký tự không dấu cách (chỉ sau D33) được chốt sớm, phần còn lại của từ đi thẳng. Gõ thử bằng `scripts/selftest/typing/run.sh --underline`.

### Đầu vào từ IMK

D18. Mọi điểm vào và cách xử lý giá trị lạ:

- `handle(_:client:)`:
  - event nil hoặc kiểu khác keyDown/mouseDown: `false`;
  - client nil hoặc không phải `IMKTextInput`: reset, `false`;
  - `characters` nil, rỗng, nhiều scalar, ký tự điều khiển: chỉ reset (`KeyRouter`);
  - `selectedRange` đi qua `ClientRange.sanitized` ở một chỗ (`InPlaceComposer.selectedRange(of:)`): `NSNotFound`, âm, hoặc vị trí, độ dài, điểm cuối vượt `ClientRange.limit` (Int32.max) đều thành `NSNotFound`, tức không thay, không đọc; một lần như vậy tắt D20 và lần đọc của D11 tới `activateServer` sau. Có vùng chọn, ít chữ hơn số cần xoá: không thay. Các phép cộng còn lại trên vị trí dùng phép cộng bão hoà;
  - `attributedSubstring` nil, sai độ dài, ký tự ngoài BMP: không seed.
- `activateServer`/`deactivateServer`/`commitComposition` với client nil: reset (gạch chân: chốt vào client đã nhận marked text nếu còn, không thì bỏ); `activateServer(nil)` không giữ bundle ID của app trước.
- `setValue(_:forTag:client:)`: giá trị nil không chuyển cho `super`; giá trị lạ chỉ reset.
- `inputControllerWillClose`: reset, bỏ hai bộ nghe (cài đặt, nguồn nhập liệu).
- `menu()` và hành động menu: không chạy ngoài main thread (`onMain` trả nil thay vì dừng chương trình); tham số của hành động không được dùng.
- Thông báo cài đặt và nguồn nhập liệu: chỉ chạy trên main thread, tham chiếu yếu tới controller.
- Gọi ngược trong lúc xử lý (client gọi `commitComposition`, `deactivateServer`… ngay trong `insertText`, `selectedRange` hay `setMarkedText`): phím, reset và nạp lại cài đặt chạy lần lượt, không lồng (`KeyReentry`: `handle` qua `KeyReentry.key`, điểm vào khác qua `outsideKey`). Lời gọi đến lúc đang bận được giữ lại và chạy ngay sau, vì engine và composer đang bị mượn (`inout`). Phím đến lúc đang bận thì đi thẳng tới app và từ đang gõ reset sau đó. IMK có gọi ngược như vậy hay không: chưa đo.

### Input mode, quy tắc theo app, cài đặt

- Một input mode duy nhất "Dấu – Tiếng Việt" (`….Dau.vi`), khai trong Info.plist (`ComponentInputModeDict`), để ID nguồn đã bật không đổi và nguồn nằm trong nhóm Tiếng Việt (D2 (Chuyển Việt/Anh)).
  - Bộ gõ không giữ trạng thái chế độ: IMK báo mode nào (kể cả `….Dau.en` còn sót từ bản cũ) cũng xử lý như tiếng Việt. `setValue(_:forTag:client:)` chỉ reset từ đang gõ.
  - Không tự đổi nguồn theo app, không nhớ chế độ theo app (D5), không tự thông báo VoiceOver (D17 (Trợ năng)).
- Quy tắc theo app: lựa chọn gạch chân đọc lúc `activateServer` và khi cài đặt đổi, không theo phím; đổi chế độ giữa chừng một từ thì chốt từ trước. Bundle ID lấy từ client lúc `activateServer`; Chrome đôi khi đưa client có `bundleIdentifier()` nil, khi đó dùng app đang ở trước (`NSWorkspace.frontmostApplication`).
- Cài đặt đọc từ App Group, nghe thay đổi để áp dụng ngay. Không đọc danh sách tương thích (D13).

### Đổi nguồn nhập liệu không qua `activateServer`

- Hiện tượng: chọn U.S. rồi chọn lại Dấu bằng `TISSelectInputSource` từ tiến trình khác thì IMK không gọi `deactivateServer`/`activateServer`, từ đang gõ dở bị gõ tiếp.
- Mỗi controller nghe thông báo phân tán `kTISNotifySelectedKeyboardInputSourceChanged` (bộ gõ có sandbox vẫn nhận được). Khi nhận thì đọc nguồn đang chọn; chỉ reset từ đang gõ (gạch chân: chốt chữ đang hiện) khi nguồn đó không phải Dấu, không đọc được, hoặc khác nguồn đã thấy lần trước (`InputSourceChange`). Ai cũng phát được thông báo này, nên thông báo giả khi nguồn không đổi không cắt từ.
- Thông báo đến trong `DauInputController.activationEcho` sau `activateServer` của chính controller là tiếng vọng của lần chuyển bằng phím tắt/menu và bị bỏ qua, để phím gõ ngay sau khi chuyển không mất từ.
- Kiểm: `scripts/selftest/typing/run.sh --keys` với `⇄` (chọn U.S. rồi Dấu từ tiến trình script), xem dòng log `source-changed-reset`. Chuỗi `to` ⇄ `o` không phân biệt được có và không có bộ nghe, vì sau reset D20 đọc lại "to" và `o` cho "tô".

### Khởi chạy bộ gõ

`LaunchOrigin.swift`, `InputMethodAppDelegate.swift`. Bundle là `LSBackgroundOnly` nên người dùng mở nó (nháy đúp trong Finder) thì không thấy gì. Bộ gõ phân biệt bốn cách được chạy (theo log LaunchServices và Apple event ở `applicationDidFinishLaunching`, macOS 27.2):

- **Hệ thống** (imklaunchagent nhờ LaunchServices chạy khi một client cần bộ gõ): không có Apple event nào ngoài `aevt/oapp` do AppKit tự tạo, người gửi là chính tiến trình. `NSApplicationLaunchIsDefaultLaunchKey`, tiến trình cha và `XPC_SERVICE_NAME` giống nhau ở mọi đường nên không dùng được.
- **Finder** (Mở/nháy đúp): LaunchServices gửi `aevt/oapp` thật từ tiến trình khác. Bộ gõ mở app chủ (`HostApp`), rồi thoát nếu chưa client nào kích hoạt nó trong lúc đó (`DauClientActivated`).
- **Mở lại khi đang chạy** (Finder, `open`, `NSWorkspace`): tiến trình đang chạy nhận `aevt/rapp`. Bộ gõ mở app chủ, **không** thoát (có thể đang phục vụ gõ). `rapp` trong `LaunchPolicy.reopenSettleSeconds` đầu sau khởi chạy bị bỏ qua (phòng hờ hệ thống xin chạy hai lần).
- **`open` trong Terminal khi bộ gõ chưa chạy:** giống hệt hệ thống, nên coi là hệ thống, chạy tiếp, không mở gì. Không chắc thì luôn chạy tiếp.

**Tìm app chủ** (cùng cách với mục "Cài đặt Dấu…", `HostApp`): bản đang chạy, bản chứa bộ gõ, bản cùng phiên bản ưu tiên thư mục Applications, rồi tìm thẳng trong /Applications khi LaunchServices chưa biết bản chép vào, rồi bản trong `~/Applications` (luật bên dưới), và cuối cùng bản duy nhất LaunchServices biết nếu chữ ký đạt (`Reason.onlyKnown`).

- Mỗi bản phải qua kiểm chữ ký (`HostApp.accepts`, `HostAppSignature`; luật ở D37): chữ ký hợp lệ, gốc Apple, đúng bundle ID app chủ và Team ID của chính bộ gõ. Lời gọi Security này chạy được trong sandbox của bộ gõ.
- Sandbox của bộ gõ không đọc được Info.plist của bản nằm trong thư mục nhà (bị từ chối `file-read-data`). Bản như vậy, hoặc mọi bản khi bộ gõ không có Team ID, chỉ được mở khi là bản đang chạy, bản chứa bộ gõ, hoặc bản nằm trực tiếp trong `~/Applications` của thư mục nhà thật khi `/Applications` không có bản nào đạt (`HostApp.userApplicationsFolder`). Bản đọc được mà kiểm không đạt thì không bao giờ mở.
- Vì vậy bản build chưa chạy và không nằm ở /Applications không được chọn (log `host-app-not-found known=… readable=…`).

### Thoát theo yêu cầu của app chủ

Dùng khi thay bộ gõ (D37) và khi gỡ (D16 (Bảo trì và gỡ cài đặt)). Tên và cách phát ở `InputMethodLifecycle` (DauShared).

- App chủ phát thông báo Darwin `<bundle ID bộ gõ>.quitRequested` sau khi đã đổi chỗ bundle (thay) hoặc chuyển nó vào Thùng rác (gỡ).
- Bộ gõ (`main.swift`) ghi lúc khởi chạy file thực thi nó chạy từ đâu (`InputMethodLifecycle.BundleFile`: inode và giờ sửa). Khi nhận thông báo, nó chỉ thoát nếu file trên đĩa đã khác hoặc đã mất (`InputMethodLifecycle.shouldQuit`); không thì ghi `event=quit-ignored` và gõ tiếp, vì ai cũng phát được thông báo này.
- Khi thoát: phát `DauQuitRequested` trong tiến trình để mỗi controller chốt từ như một lần reset (gạch chân: chốt marked text vào client), rồi `exit(0)` ở vòng chạy kế tiếp. macOS chạy lại bundle trên đĩa ở phím kế tiếp.
- Phía app chủ: quá `SystemInputMethodInstaller.quitTimeout` mà còn chạy (bộ gõ bản cũ chưa nghe thông báo) thì `forceTerminate` đúng tiến trình bộ gõ của Dấu (`NSRunningApplication` theo bundle ID). Không dừng tiến trình hệ thống nào (`imklaunchagent`, `TextInputMenuAgent`…).

### Bundle: biểu tượng, ký, entitlements

- Biểu tượng của bundle (Finder) dùng chung `Apps/Dau/Resources/Assets.xcassets` với app chủ (AppIcon, AppIconDev, chọn theo cờ `DAU_OFFICIAL`, D25 (Nhận diện)), ra `CFBundleIconName`/`Assets.car` giống Dấu.app; tên hiển thị vẫn là "Dấu" (D24 (Tên và định danh)).
- Biểu tượng nguồn nhập liệu (ô V trên thanh menu, chỉ báo ⌃Space) là TIFF template khai trong Info.plist (`docs/history/CompatibilityFixed.md`); TIS báo `kTISPropertyIconImageURL` = `ModeVietnamese.tiff` và cờ template ở cả bundle và mode.
- Bản Release không có `get-task-allow` (`CODE_SIGN_INJECT_BASE_ENTITLEMENTS: NO`), nên không tiến trình nào gắn debugger vào bộ gõ để đọc từ đang gõ. Bản Debug có, chỉ dùng khi thử (`scripts/dev/install-app.sh --debug`). `dau_check_input_method` (`scripts/lib/build.sh`) kiểm điều này, cùng universal và không có quyền mạng, trên bộ gõ nhúng trước khi cài.
- Entitlements: App Sandbox, App Group, `temporary-exception.mach-register.global-name` cho tên kết nối IMK (theo mẫu IMK có sandbox; chưa thử bỏ). **Không** `com.apple.security.network.client`.
- Khoá Info.plist: `InputMethodConnectionName`, `InputMethodServerControllerClass`, `LSBackgroundOnly`, `TISInputSourceID`, `TISIntendedLanguage`; `ComponentInputModeDict` (một mode `.vi`, icon template V), `tsInputMethodIconFileKey`, `TISIconIsTemplate`; `CFBundleIconName` do actool thêm; `DauHostAppBundleIdentifier`, `DauAppGroupIdentifier` của riêng Dấu.

## App chủ (Dau)

Entitlement của app chủ chỉ có App Group, hardened runtime bật, không sandbox (D37). App chỉ **đọc** tuỳ chọn hệ thống (`com.apple.symbolichotkeys`, `com.apple.HIToolbox`: phím tắt chuyển nguồn nhập liệu và phím 🌐, N4 (Không tự đổi cài đặt hệ thống)). Kiểm App Group bằng `scripts/selftest/app-group.sh`. Điểm vào là `main.swift`.

### Cửa sổ Cài đặt

- Scene SwiftUI `Window` (không dùng scene `Settings`), cửa sổ chính của app; ⌘, mở lại cửa sổ. Cỡ và giới hạn cỡ theo System Settings, đặt trong `SettingsScene` (`SettingsWindow.swift`); chiều rộng tối đa giữ cột chi tiết dưới ngưỡng `Form(.grouped)` bắt đầu giới hạn thẻ và căn giữa.
- Ngôn ngữ giao diện theo danh sách ngôn ngữ của macOS (D41 (Ngôn ngữ giao diện)); tham số `-AppleLanguages` vẫn chọn được ngôn ngữ khi chạy kiểm.
- **Bố cục** (D9 (Giao diện), sidebar cố định):
  - nội dung của scene là `SettingsSplitViewController` (`NSSplitViewController` do app tạo, bọc bằng `NSViewControllerRepresentable`); mục sidebar có `canCollapse` và `canCollapseFromWindowResize` tắt, độ dày tối thiểu bằng tối đa, đường chia không có vùng kéo chuột;
  - trạng thái chung của hai cột (`SettingsWindowState`: mục đang hiện, chuỗi tìm) là một đối tượng `@Observable`;
  - sidebar và trang là view SwiftUI trong hai `NSHostingController`; môi trường của scene chuyển vào hai cột bằng `SettingsEnvironment` (kể cả `openWindow`).
- **Sidebar:** `List` kiểu `.sidebar` với 4 mục `Label`; ô tìm `NSSearchField` cỡ lớn ở đầu cột, lề chuẩn của sidebar (`searchable` của sidebar chỉ có trong `NavigationSplitView`); danh sách nhận tiêu điểm khi mở cửa sổ (`FocusState` đặt khi danh sách hiện; `defaultFocus` không có tác dụng trong hosting controller này); Edit › Find › Find… (⌘F, từ `TextEditingCommands` trong `DauApp`) đưa tiêu điểm vào ô tìm: split view controller xử lý `performFindPanelAction`; ô icon vẽ theo SVG của mockup, màu hệ thống.
- **Thanh công cụ và tiêu đề:** không có cụm Lùi/Tiến (D9); tiêu đề là `navigationTitle`. Tiêu đề và các nút của trang đến từ `NSHostingController` của cột trang, đưa lên cửa sổ bằng `sceneBridgingOptions`; cột sidebar không đưa gì. Ô tìm của sidebar nhảy tới mục khớp đầu tiên khi mục đang hiện không còn khớp (`SettingsWindowState.showFirstMatch`). Không có lệnh ẩn/hiện sidebar: không dùng `SidebarCommands`, hành động `toggleSidebar` của AppKit bị tắt. Mục Ứng dụng có nút "+" rồi ô tìm (`.searchable(placement: .toolbar)`), ngăn bằng `ToolbarSpacer(.flexible)`.
- **Trang:** `SettingsPage` = `Form(.grouped)` với `Section`, control hệ thống và thông số mặc định; mảnh nội dung riêng của mockup (thẻ xem trước, chip, nhãn "Mới", phím, ô banner) nằm trong các section. Form tự cuộn và lấp cột chi tiết; trên macOS 26+, nội dung cuộn dưới header được che bằng `scrollEdgeEffectStyle(.hard, for: .top)`. Thanh cuộn theo cài đặt hệ thống (`docs/UIChecks.md`).
- **Control bọc:** `SegmentedPicker` bọc `NSSegmentedControl`, chỉ còn ở cửa sổ onboarding (`Picker(.segmented)` trên macOS 14–15 giữ độ rộng nội tại, không trải theo khung). Cửa sổ Cài đặt dùng `Picker(.segmented)` (macOS 26+: `buttonSizing(.flexible)`).
- **Sheet thêm quy tắc** (`AddAppRuleSheet`), theo sheet của System Settings: hàng đầu gồm tiêu đề và ô tìm `NSSearchField`; danh sách ứng dụng là `List(selection:)` cao cố định trong `GroupBox` ngoài Form (`List` lồng trong `Form(.grouped)` không cuộn được), để "Khi đang gõ" (thẻ của một `Form(.grouped)`) luôn trong tầm nhìn; nút trên `toolbar` (`cancellationAction`, `confirmationAction`; "Chọn ứng dụng khác…" là `.automatic`).

### Onboarding

Ba bước (`OnboardingFlow`, `OnboardingWindow`; D14 (Onboarding)). Mọi trạng thái (bộ gõ cũ, nguồn khác, trạng thái bộ gõ, bản chủ, chữ ký) đọc lại lúc mở và mỗi lần cửa sổ được đưa lên trước (`readSystem`). Sheet báo lỗi chưa có (`docs/UI.md`).

- **Chuyển vào Applications:** `OnboardingFlow.needsMoveToApplications` thay cả ba bước bằng `MoveToApplicationsStep` khi bản đang chạy không phải bản chủ và bộ gõ chưa cài (D37). Hai nút đi qua `OwnerCopyGuide`: mở thư mục Applications trong Finder, thoát app.
- **Bước 1** chỉ hiện khi có xung đột (mục "Danh sách tương thích, bộ gõ cũ").
- Không bước nào có nút "Quay lại": các bước chỉ đi tới.
- **Bước 2:** nguồn tiếng Việt kiểu IMK khác đang bật hiện ở `OtherSourcesNote`, không chặn. `OnboardingFlow.installedTampered` đổi màn "Bật Dấu" thành màn lỗi cài "Chưa cài được Dấu" (`OnboardingFlow.EnableScreen.error`, view `EnableStep.installError`; "Chi tiết" là lỗi chữ ký): đúng khi bản đang chạy là bản chủ, bộ gõ đã cài nhưng chưa bật, và `InputMethodInstaller.installedIsGenuine` sai; phát hiện lúc đang chờ Allow thì huỷ lần chờ.
  - Nút "Cài lại" của màn lỗi gọi `OnboardingFlow.enable`: bản đã cài sai chữ ký thì `enable` chuyển sang `OnboardingFlow.reinstall`, chỉ gọi `install()`, không gọi `enable()` của bộ cài; xong thì đọc lại chữ ký: đúng thì về màn "Bật Dấu", còn sai hay lỗi thì ở lại màn lỗi. Lỗi cài khác (chưa chép được) thì `enable` cài rồi bật như lần đầu.
  - `OnboardingFlow.enable` nhận `EnableOutcome.needsReinstall` (bộ gõ bị thay sau lần đọc cuối) thì cũng sang màn này.

### Cài, bật, thay, gỡ bộ gõ

`InputMethodInstaller.swift`, theo `docs/research/InputMethodInstall.md` mục 1–6; luật ở D37 và D16.

`SystemInputMethodInstaller` đi qua sáu giao diện hẹp để test bằng đồ giả (`scripts/snapshot-settings/Tests/…/InputMethodInstallerTests.swift`): `InputMethodFiles` (bundle trong app và bản ở `~/Library/Input Methods`), `TextInputSources` (TIS), `InputMethodProcesses`, `SystemSettingsControl` (bộ đệm và tiến trình System Settings), `InputSourceCaches` (bộ đệm danh sách nguồn của từng app; bản thật `UserInputSourceCaches` nhận thư mục gốc làm tham số nên test chạy trên thư mục tạm), `OwnerCopyCheck` (bản chủ; bản thật `ApplicationsOwnerCopy`).

**Bản chủ:**

- `ApplicationsOwnerCopy` nhận bundle ID app chủ, danh sách thư mục theo thứ tự (`standardDirectories`) và hai hàm đọc mã băm làm tham số. Nó tìm bundle theo `CFBundleIdentifier` trong `Info.plist` của các mục `.app` nằm trực tiếp trong thư mục, không theo tên file; liên kết tượng trưng không tính. Thư mục đầu tiên có bundle như vậy quyết định.
- Mã băm đọc bằng `CodeSignature.codeHashes`, chỉ dùng API công khai của Security: `MachOSlices` đọc danh sách kiến trúc thẳng từ đĩa; mỗi kiến trúc một `SecStaticCodeCreateWithPathAndAttributes`, rồi lấy `kSecCodeInfoUnique` từ `SecCodeCopySigningInformation`. Một kiến trúc không đọc được thì cả bundle là "không biết": không trùng với gì. `CodeSignature.sameCode`: cùng tập kiến trúc và cùng mã băm ở từng kiến trúc.
- Mã băm của bản đang chạy đọc từ bundle của chính nó trên đĩa, để có mọi kiến trúc; bundle đó nằm ở đâu không tham gia kết luận. `InputMethodInstaller.isOwnerCopy` đọc lại mỗi lần hỏi, không lưu.
- Bản không phải bản chủ: `install()` ném `InputMethodInstallerError.notOwnerCopy` trước khi đụng tới file; `OnboardingFlow.enable` chỉ bật bộ gõ đã cài; `enable()` và `InputMethodActions.checkInstalled` không kiểm chữ ký; `reinstallInputMethod` không làm gì. Bật, cài đặt và gỡ đi các đường như bản chủ.

**Cài và thay** (chỉ bản chủ; onboarding bước 2, nút "Cài lại", và `reconcile`):

1. Chép `Contents/Library/Input Methods/DauInputMethod.app` vào thư mục tạm ẩn, không đuôi `.app`, cùng thư mục đích (`.DauInputMethod-staging-<uuid>`); gỡ `com.apple.quarantine`.
2. Kiểm chữ ký bản tạm (`CodeSignature.isValidAndSameTeam`).
3. Đổi chỗ vào `DauInputMethod.app` bằng một lần `renamex_np(RENAME_SWAP)`. Đích không có (`ENOENT`): `InputMethodFiles.installEmbedded` chuyển bản tạm vào bằng `RENAME_EXCL`, còn `InputMethodFiles.replaceInstalledWithEmbedded` (đường thay) không cài, xoá bản tạm và trả về sai.
4. Xoá bản cũ; dừng tiến trình cũ nếu đang chạy (mục "Thoát theo yêu cầu của app chủ"); `TISRegisterInputSource`. Không bật, không chọn nguồn nào.

**Bật** (chỉ khi người dùng bấm "Bật Dấu" hoặc "Bật lại"; `docs/research/InputMethodInstall.md` mục 1 và 3):

1. Bản chủ kiểm `InputMethodFiles.installedIsGenuine` trước mọi việc: sai thì trả `EnableOutcome.needsReinstall`, không làm gì thêm. `OnboardingFlow` hiện màn lỗi cài với nút "Cài lại", `InputMethodActions.enableFromBanner` hiện `TamperedBanner`.
2. Ngay trước `TISRegisterInputSource`, `InputSourceCaches.clearAll` xoá `com.apple.IntlDataCache.le*` trong mọi thư mục con trực tiếp của `DARWIN_USER_CACHE_DIR` (mỗi app có sandbox giữ bộ đệm riêng ở đó, extension Bàn phím của System Settings là một). File ở gốc thư mục là bộ đệm chung, tự làm mới, không đụng. Thư mục không liệt kê được hay file không xoá được thì bỏ qua, đếm là lỗi, ghi nhật ký; không bao giờ làm `enable()` thất bại.
3. Luôn `TISRegisterInputSource`: app đang chạy dựng lại bộ đệm ở lần đăng ký này. TIS không liệt kê Dấu sau đó thì `notListed`.
4. Mode `.vi` đã nằm trong mục lưu thì `enabled` ngay. Không thì yêu cầu System Settings thoát (`terminate()`, không ép; không thoát được thì đi tiếp), rồi `TISEnableInputSource` cho mục cha.
5. **Đọc lại** mục lưu theo chu kỳ tới khi có mode `.vi` (tối đa `SystemInputMethodInstaller.enableTimeout`, để người dùng đọc và bấm Allow): có thì `enabled`; hết hạn thì `notEnabled` (giao diện hiện "Chưa bật được"; macOS ghi mục sau đó thì cửa sổ nhận ra).
6. Mỗi lần ra `enabled` có đúng một lượt `InputSourceCaches.removeCaches(notMentioning:)`: thư mục con nào có `com.apple.IntlDataCache.le.kbdx` đọc được mà không chứa chuỗi UTF-8 `Input Methods/DauInputMethod.app` thì xoá bộ đệm đó; có ít nhất một thì `TISRegisterInputSource` thêm một lần. Đây là phỏng đoán trên định dạng không có tài liệu; lượt này không ném lỗi và không đổi kết quả.

Vòng chờ kiểm huỷ task mỗi lượt: `OnboardingFlow` giữ task của `enable()`, "Thử lại" huỷ nó. Mã trả về của TIS không bao giờ là bằng chứng. App không tắt được Dấu (`TISDisableInputSource` từ app bị macOS chặn, `docs/research/InputMethodInstall.md` mục 5.2); trạng thái "đã bật" (`status()`, `InputSourceStatus.query`) là mục lưu, không phải cờ enabled của TIS (D37).

**Kiểm bộ gõ đã cài:** mỗi lần mở app và mỗi lần app được đưa lên trước, `InputMethodActions.checkInstalled` hỏi `installedIsGenuine` (`CodeSignature.isValidAndSameTeam`, yêu cầu mã ở D37); chỉ bản chủ hỏi. Không đạt thì `TamperedBanner` hiện banner "Cài lại", bấm thì cài lại bản nhúng. Cờ Debug `--tampered` (`DebugCapture.tampered`) ghim banner để chụp: `InputMethodActions.forceTampered` làm `checkInstalled` không đọc bộ gõ thật, và lượt `reconcile` lúc mở app không chạy.

**Giữ bộ gõ đã cài trùng bản nhúng:** lúc app mở, `InputMethodActions.startLaunchReconcile` gọi `SystemInputMethodInstaller.reconcile`, xong thì `checkInstalled`. `reconcile` xét theo thứ tự và trả `ReconcileOutcome`:

1. không phải bản chủ: `notOwnerCopy`, không đọc gì thêm;
2. app không có bộ gõ nhúng: ném `InputMethodInstallerError.unavailable`;
3. chưa cài: `notInstalled`;
4. bản đã cài không đọc được `Info.plist` hoặc khác bundle ID: `skipped`;
5. `InputMethodFiles.installedIsGenuine` sai: `badSignature`, không thay;
6. `InputMethodFiles.installedMatchesEmbedded` (mã băm mọi kiến trúc): `alreadyCurrent`;
7. còn lại: chép tạm và chỉ đổi chỗ với bản đang có (`InputMethodFiles.replaceInstalledWithEmbedded`). Đổi được: `replaced`, dừng tiến trình cũ, đăng ký lại (mã trả về của lần đăng ký chỉ ghi nhật ký; `install()` thì ném lỗi, vì ở lần cài đầu bước bật cần lần đăng ký đó). Bản đã cài biến mất lúc đổi chỗ (vừa bị gỡ): `notInstalled`, không làm gì thêm.

`reconcile` không đụng trạng thái bật/chọn; `CFBundleVersion` chỉ dùng để ghi nhật ký.

**Lệnh `Dau --reconcile-input-method`** (`ReconcileCommand`, có ở cả bản Debug và Release; `main.swift` gọi trước khi dựng app): chạy đúng `reconcile` rồi thoát, không tạo `NSApplication` (vòng lặp `RunLoop.main` chạy các bước chờ); chạy thẳng file thực thi trong bundle để nhận kết quả; in một dòng `reconcile-input-method: <từ>: <giải thích>`. Mã thoát (`ReconcileCommand.Status`):

| Mã thoát | Từ | Nghĩa |
|---|---|---|
| 0 | `already-current` | bộ gõ đã cài trùng bản nhúng |
| 1 | `failed` | lỗi: app không có bộ gõ nhúng, chép hỏng, bản nhúng sai chữ ký |
| 3 | `replaced` | đã thay bằng bản nhúng |
| 4 | `not-installed` | bộ gõ chưa cài, hoặc vừa bị gỡ trong lúc lệnh chạy; không làm gì |
| 5 | `not-owner-copy` | bản đang chạy không phải bản chủ, không làm gì |
| 6 | `bad-signature` | bộ gõ đã cài sai chữ ký hoặc khác Team ID, không thay |
| 7 | `skipped` | bản đã cài khác bundle ID hoặc không đọc được, không thay |

Mã 2 để trống cho dòng lệnh sai, như các lệnh Debug. `scripts/dev/install-app.sh` gọi lệnh này từ bản vừa đặt vào `/Applications`, nên script không tự chép bộ gõ: mã 0 và 3 là đạt; mã 4 không phải lỗi (lần cài đầu là nút "Bật Dấu"); mã khác làm script thoát khác 0.

**Gỡ** ("Gỡ cài đặt…", D16): ba bước của `SystemInputMethodInstaller` do `InputMethodActions.performUninstall` điều phối.

1. `prepareUninstall`: mở thẳng danh sách Input Sources (`SystemSettings.openInputSources`, URL `…Keyboard-Settings.extension?InputSources`; trên macOS 27.2 mở sẵn sheet Edit…); không chọn bàn phím nào, không tắt gì. Sheet đọc lại `InputMethodStatus.selected` khi hiện, khi cửa sổ sheet thành key lại và khi nguồn đang chọn đổi, để hiện hoặc ẩn câu nhắc "–" có thể mờ.
2. `waitUntilRemovedFromInputSources`: thăm dò mục lưu của Dấu (`storedEnabledIDs`) tới khi rỗng, huỷ được; trong lúc đó `UninstallRemoveSheet` hiện trên cửa sổ Cài đặt.
3. `finishUninstall`: chỉ chạy khi mục lưu rỗng (không thì `stillListed`); chuyển `~/Library/Input Methods/DauInputMethod.app` vào Thùng rác rồi dừng bộ gõ; nếu tick ô thì xoá suite App Group (`removePersistentDomain`) và phát thông báo đổi cài đặt; xoá bộ đệm của System Settings (`SystemSettingsControl.clearKeyboardCache`), không đụng bộ đệm của các app; đọc lại để báo kết quả.

### Tên hệ thống và chuỗi

#### Tên bàn phím (`LayoutNames`)

- Tên bàn phím hiện đúng như thanh menu của macOS ("U.S." trên máy tiếng Anh), không phải tên TIS trả cho tiến trình của app: `kTISPropertyLocalizedName` theo ngôn ngữ của tiến trình, có thể khác ngôn ngữ hệ thống (ngôn ngữ riêng của app hoặc `-AppleLanguages`, D41), khi đó máy tiếng Anh vẫn ra "Mỹ".
- `LayoutNames` đọc ngôn ngữ ưu tiên thật của hệ thống (`AppleLanguages` ở miền toàn cục), tra bảng `InfoPlist.loctable` của `AppleKeyboardLayouts.bundle` (khoá là ID nguồn bỏ tiền tố `com.apple.keylayout.`), thử ngôn ngữ cụ thể trước rồi bỏ dần phần vùng, rồi sang ngôn ngữ ưu tiên kế; không khớp thì dùng tên TIS.
- Dùng ở `englishLayoutName` (dòng phím tắt) và `InputSourceEntry.name` của bàn phím (sheet gỡ, alert gỡ xong). Chỉ đọc (N4); bảng đọc một lần, danh sách ngôn ngữ đọc mỗi lần gọi.

#### Tên giao diện của macOS trong chữ của Dấu

`SystemUINames` (D38 (Chữ trên giao diện)).

- Danh sách đủ là các case của enum `SystemUIName` (nơi duy nhất giữ danh sách; `docs/Glossary.md` dẫn sang đây), mỗi case có một dòng trong `SystemUINames.location(of:)`: các tên của System Settings, thư mục Applications (`applications`), Trash của Finder (`trash`), tên ngôn ngữ "Vietnamese", hộp thoại "Allow … to enable …?" (`allowDialogTitle`, `allowDialogBody`), và tên nguồn của chính Dấu (`dauInputSource`: đọc `InfoPlist.strings` của bộ gõ đã cài, chưa cài thì bản trong app, khoá là ID input mode).
- Ngôn ngữ lấy như `LayoutNames`. Chữ lấy từ bảng của chính hệ thống (`SystemUITable`; đường dẫn ở `SystemUINames.tableURLs` và `loadTables`; "Applications" từ `SystemFolderLocalizations` qua `folderNames`, "Trash" từ `Localizable.strings` của Finder qua `finderNames`; tên ngôn ngữ từ `Locale`), tìm khoá bằng cách khớp giá trị tiếng Anh; ngôn ngữ đầu là tiếng Anh, hoặc không khớp ở mọi ngôn ngữ ưu tiên, thì tiếng Anh.
- Câu chữ của Dấu dùng `%@` cho các tên này; khái niệm chung dùng thuật ngữ Apple của từng ngôn ngữ (`docs/Glossary.md`). Bộ gõ không dùng hai file này.

#### Chuỗi giao diện

- Mỗi target có `Localizable.xcstrings` và `InfoPlist.xcstrings`; ngôn ngữ gốc tiếng Anh, khoá là câu tiếng Anh viết thẳng trong mã (`Text("…")`, `String(localized:)`), tiếng Việt là bản dịch (D41).
- `scripts/check-l10n/check.sh` kiểm mọi khoá có đủ `en` và `vi` đã dịch, cùng các `%@`/`%lld`.
- Ô tìm của sidebar so với chữ đang hiện (`SettingsSection.matches`), nên tìm được bằng ngôn ngữ đang dùng.

### Danh sách tương thích, bộ gõ cũ

- Danh sách tương thích có sẵn trong app (`Apps/Dau/Resources/CompatibilityList.json`, mục DauShared).
- Phát hiện bộ gõ cũ (D14), `Apps/Dau/Sources/OnboardingServices.swift`:
  - `KnownInputMethods` liệt kê các bộ gõ chặn phím (bundle ID, các bước tắt đã kiểm hoặc bước chung không nhắc chữ trên menu, N5). `detect()` so bundle ID với `NSWorkspace.shared.runningApplications` và với app đã cài; `OnboardingFlow` chỉ coi bản **đang chạy** là xung đột (`conflicts`) và chỉ hiện bước 1 khi có xung đột.
  - `InputSourceStatus.otherVietnameseSourceNames` đọc TIS: nguồn chọn được, ngôn ngữ đầu là `vi`, khác Dấu, kiểu bàn phím (Telex/VNI của Apple, XKeyIM). Chỉ hiện ở bước 2 (`OtherSourcesNote`).

## Build

- `Dau.xcodeproj` sinh từ `project.yml` bằng XcodeGen, không sửa tay và không commit. Scheme `Dau` build cả bộ gõ và nhúng nó vào `Dau.app/Contents/Library/Input Methods/DauInputMethod.app`.
- Định danh và Team ID: D24. Chúng được đặt ở `project.yml` (`BUNDLE_ID_PREFIX`), `Config/Signing.xcconfig` (`DEVELOPMENT_TEAM`) và `Config/Local.xcconfig` (git bỏ qua, mỗi máy đặt team khác nếu cần); ký tự động "Apple Development".
- ID input mode viết cứng ở ba nơi: `Apps/DauInputMethod/Info.plist`, `Apps/DauInputMethod/Resources/InfoPlist.xcstrings` (Xcode không thay biến trong khoá plist) và `SystemUINames.location` (tên nguồn của Dấu). Đổi bundle ID phải sửa cả ba (D37: không đổi giữa các bản).
- Kiến trúc: bản Release luôn universal. Bản Debug build bằng `xcodebuild` không kèm `-destination` chỉ ra kiến trúc của máy đang build (Xcode build package cục bộ theo kiến trúc máy); muốn Debug universal thì thêm `-destination 'generic/platform=macOS'`. `scripts/lib/build.sh` dùng destination này cho `dau_build`.
- Mã commit của bản build: `scripts/build/stamp-build-commit.sh` ghi `build/generated/BuildCommit.txt` (thêm "+" khi còn thay đổi chưa commit), chạy lúc `xcodegen generate` (preGenCommand) và ở mỗi lần build bộ gõ. Dấu.app và bộ gõ chép file này vào Resources nên bản build được ký lại khi mã đổi. App hiện "Dấu x.y.z (mã)" ở đáy sidebar và thẻ đầu Cập nhật & hỗ trợ; `scripts/dev/dau-version.sh` so mã của bộ gõ đã cài, Dấu.app và repo.

## Log, signpost, cờ Debug

- `os_signpost` quanh `engine.handle` và quanh lệnh gọi client; xem bằng Instruments.
- Nhật ký từng phím (category `perf`, `diag`) và signpost chỉ có ở bản Debug, bị loại khỏi bản Release lúc build (D8). Ở bản Debug chỉ ghi khi khoá `DauPerfLog` được đặt trong global domain.
  - `scripts/selftest/typing/run.sh` tự bật lúc chạy và khi xong trả khoá về như cũ; đo tay thì bật, đo, rồi xoá (`scripts/perf/perf-report.sh`).
  - Mỗi dòng phím có `t_ns` (lúc `handle` bắt đầu, `CLOCK_UPTIME_RAW`) và `ev_ns` (thời điểm của chính sự kiện phím); `perf-report.sh` dựng từ đó khoảng cách giữa các phím và độ trễ từ lúc tạo phím tới bộ gõ, cho bài test tải nặng (`scripts/selftest/load/run.sh`, D42 (Ngưỡng hiệu năng)).
- Bộ gõ bản Debug đọc thêm khoá `DauDebugForceUnderline` (mảng bundle ID, miền global) để ép gạch chân khi thử mà không đụng cài đặt người dùng; bản Release không đọc.
- **Cờ chạy của app chủ bản Debug** (trong `#if DEBUG`; danh sách đủ ở nơi định nghĩa):
  - chạy không mở cửa sổ, in một giá trị rồi thoát: các cờ `--print-…` ở đầu `main.swift`, và `--set-typing-method` ở `DebugSettingsCommand` (`--reconcile-input-method` có ở cả bản Release, mục "Cài, bật, thay, gỡ bộ gõ");
  - chụp với dịch vụ giả và chọn màn hình, trạng thái (`--capture-…`, `--onboarding`, `--shortcut`, `--active`, `--tampered`): `DebugCapture.swift`, `DauApp.swift`;
  - mở app thật để đo từ ngoài (`--settings-window`, `--appearance`): `DebugCapture.swift`.
  - `scripts/selftest/settings-window` dùng các cờ này để kiểm giao diện (`docs/UIChecks.md`).
