# Phát hành

Tài liệu này tả cách một bản Dấu ra đời, từ tag git tới DMG, bản cập nhật Sparkle và Homebrew. Các quyết định liên quan là D6 (Phát hành), D7 (Cập nhật và loại bản dựng) và D25 (Nhận diện). Kế hoạch mốc nằm ở [`docs/Progress.md`](Progress.md), mục "Kế hoạch M7".

Bản phát hành có một danh tính ký tại mỗi thời điểm (D6). Hiện nay đó là chứng chỉ Apple Development của Personal Team `M58DANM3ZP`, và bản phát hành không notarize. Khi codefastlabs có tài khoản Apple Developer Program, bản phát hành chuyển sang ký Developer ID và notarize (mục "Chuyển sang Developer ID"). Cả hai đường dùng chung script và workflow; script chọn đường theo secret có mặt (mục "Chế độ ký").

```mermaid
flowchart TD
  tag["Tag v* đẩy lên"] --> wf["Workflow Release"]
  wf -- "vX.Y.Z-beta.N" --> build["build-release.sh:<br>archive, ký,<br>notarize nếu ký Developer ID,<br>DMG, SHA-256, appcast"]
  wf -- "vX.Y.Z" --> promote["promote-release.sh:<br>sao DMG của beta cuối,<br>bỏ thẻ beta ở appcast,<br>kiểm Checksums.json,<br>không dựng"]
  build --> draft["Bản nháp trên<br>GitHub Releases"]
  promote --> draft
  draft -- "Publish" --> pub["Bản đã công bố,<br>DMG trên GitHub"]
  pub -. "chép appcast.xml<br>và Checksums.json" .-> site["site/ trên main:<br>appcast.xml, Checksums.json"]
  site -- "Vercel dựng và xuất bản" --> feed["dau.codefastlabs.com<br>/appcast.xml"]
  feed -. "check-site-appcast.sh:<br>so byte với main" .-> site
  feed --> sparkle["Sparkle trong<br>Dấu đã cài"]
  sparkle -. "tải DMG" .-> pub
  pub -. "D6" .-> cask["Cask dau ở<br>codefastlabs/homebrew-tap"]
```

Phiên chính và subagent không cầm khoá. Chứng chỉ, khoá App Store Connect và khoá EdDSA chỉ nằm ở máy người dùng và trong secret của GitHub. Mọi thứ trong repo chỉ là mã, mẫu cấu hình và tên secret.

## Kịch bản phát hành

Dấu đi theo một vòng: phát nhiều bản beta để người dùng thử sớm và góp ý, rồi chốt beta cuối thành bản chính thức, rồi lại phát beta cho phiên bản sau. Vòng này không có nhịp cố định. Bản mới ra tuỳ theo khối lượng việc, độ hoàn thiện của tính năng, các app cần hỗ trợ thêm và các bản macOS mới. Kênh và từ ngữ theo D7 (Cập nhật và loại bản dựng) và [`docs/Glossary.md`](Glossary.md).

| Giai đoạn | Tag | Ai nhận |
|---|---|---|
| 1. Dùng thử sớm, chưa có bản chính thức | `v0.1.0-beta.1`, `beta.2`… | Mọi người đều nhận: kênh mặc định là Beta. Lựa chọn Chính thức hiện nhưng bị tắt. Cask và nút "Tải về" trỏ vào beta mới nhất (D6). |
| 2. Chốt bản chính thức | `v0.1.0` trên commit của beta cuối | Bỏ thẻ kênh `beta` khỏi mục của beta cuối để thành bản chính thức. Lựa chọn Chính thức bật lên. Người đã cài giữ kênh của mình. Người cài từ lúc này có kênh mặc định là Chính thức. Cask cùng nút "Tải về" trỏ vào bản chính thức. |
| 3. Phát triển tiếp, dùng thử sớm | `v0.2.0-beta.1`… | Chỉ kênh Beta nhận. Kênh Chính thức giữ `0.1.0`. |
| 4. Chốt bản kế tiếp | `v0.2.0` trên commit của beta cuối | Kênh Chính thức nhận bản này. Kênh Beta đã có đúng tệp đó nên không nhận gì. Vòng quay lại giai đoạn 3. |

Các kịch bản sau có thể chen vào vòng đó:

| Kịch bản | Cách làm |
|---|---|
| Beta bị lỗi | Phát ngay một beta sửa (mục "Khi một bản bị hỏng"). Chỉ kênh Beta bị ảnh hưởng. |
| Bản cập nhật không cài được | Gỡ mục của bản đó khỏi appcast trước, rồi mới đụng tới GitHub (mục "Thứ tự công bố và gỡ"). |
| Bản chính thức bị lỗi khi `main` đã có việc dở cho phiên bản sau | Sửa trên một nhánh tách từ commit của bản chính thức, phát beta `0.1.1-beta.1` trên nhánh đó, rồi quảng bá thành `0.1.1`. Số build lấy trong khoảng trống sau bản chính thức (đoạn "Số build"). Bản sửa cũng được đưa vào `main`. Hiện chưa làm được việc này, vì `check-release-gate.sh` chỉ nhận commit nằm trong `origin/main` và workflow Test chỉ chạy trên `main` (kế hoạch nằm ở [`docs/Roadmap.md`](Roadmap.md)). |
| Người dùng đổi kênh | Người chuyển sang Beta nhận beta mới nhất ở lần kiểm tra sau. Người chuyển sang Chính thức giữ bản đang chạy cho tới khi có bản chính thức có số build cao hơn (D7). |
| Bản macOS mới | Thử Dấu trên bản beta của macOS, phát beta sửa và chốt bản chính thức trước ngày macOS ra bản chính thức. Chỉ ghi đã kiểm trên bản macOS nào sau khi đã đo (D1 (Nền tảng)). |
| Nâng bản macOS tối thiểu | Mục appcast phải mang `sparkle:minimumSystemVersion`, để máy chạy macOS cũ dừng ở bản cuối còn chạy được. Chưa kiểm xem `generate_appcast` có tự ghi khoá này không ([`docs/Roadmap.md`](Roadmap.md)). |
| Thêm app vào danh sách tương thích | Danh sách đi kèm app (D7), nên thay đổi này đi qua beta rồi bản chính thức như mọi thay đổi khác. |
| Quay về bản trước | Việc này theo D19 (Quay về bản trước) và để sau beta đầu tiên. |
| Tên miền, chứng chỉ, khoá hết hạn | Xem mục "Hết hạn và gia hạn". |

## Thành phần

| Thành phần | Ở đâu |
|---|---|
| Script dựng một bản beta (archive, ký, DMG, appcast, ghi chú bản phát hành; với Developer ID thêm xuất, notarize, staple) | `scripts/release/build-release.sh` |
| Mẫu ghi chú của bản nháp, song ngữ Anh và Việt; phần Gatekeeper chỉ có khi bản không notarize | `scripts/release/release-notes-template.md` |
| Script quảng bá beta cuối thành bản chính thức (sao tài sản, bỏ thẻ kênh beta khỏi appcast, không dựng) | `scripts/release/promote-release.sh` |
| Kiểm một bản build (biểu tượng, ký hiệu, khoá Sparkle, bộ gõ, chữ ký của app, bộ gõ và mã Sparkle) | `scripts/release/check-build.sh` |
| Kiểm điều kiện của một tag: commit nằm trong `origin/main`, workflow Test đã đạt (dùng chung cho dựng và quảng bá) | `scripts/release/check-release-gate.sh` |
| Kiểm appcast: nền có mục của beta mới nhất đã công bố; mục beta mới mang thẻ `beta`; appcast quảng bá chỉ khác bản trước ở thẻ đó | `scripts/release/check-appcast.sh` |
| Tự kiểm offline phần đọc và sửa appcast cùng phần hợp nhất `Checksums.json` (không mạng, không khoá), dùng thư viện `scripts/lib/appcast.sh` và `scripts/lib/checksums.sh` | `scripts/release/test-appcast.sh` |
| Sắp xếp cửa sổ DMG bằng Finder (chỉ CI) | `scripts/release/layout-dmg.sh` |
| Test ở mỗi lần đẩy mã | `.github/workflows/test.yml` |
| Tag `v*`: beta dựng bản nháp, bản chính thức quảng bá beta cuối, trên GitHub Releases | `.github/workflows/release.yml` |
| Thư mục gốc của project Vercel: trang web, `appcast.xml` và `src/data/Checksums.json` (SHA-256 của từng DMG đã công bố) | `site/` |
| Hợp nhất SHA-256 của DMG vào `Checksums.json` (thư viện dùng chung của hai script phát hành) | `scripts/lib/checksums.sh` |
| So appcast trên `dau.codefastlabs.com` với `site/appcast.xml` của một commit rồi kiểm header `Cache-Control` (tác dụng phụ mạng) | `scripts/release/check-site-appcast.sh` |
| Build trang trước khi đẩy một commit có chạm `site/` | `.githooks/pre-push` |

Cách gọi và tuỳ chọn của từng script nằm ở đầu script đó.

## Việc của người dùng (làm một lần)

Các bước dưới đây dành cho đường ký Personal Team. Việc thêm khi chuyển sang Developer ID nằm ở mục "Chuyển sang Developer ID".

1. **Chứng chỉ Apple Development của Personal Team.** Xcode đã tạo chứng chỉ này trên máy người bảo trì khi ký bản phát triển (D24 (Tên và định danh)). Lệnh `security find-identity -v -p codesigning` in dòng "Apple Development: …"; trường Organizational Unit của chứng chỉ là Team ID `M58DANM3ZP`. Xuất chứng chỉ cùng khoá riêng ra `.p12` ngoài repo:

   ```sh
   security export -k ~/Library/Keychains/login.keychain-db -t identities -f pkcs12 -o ~/dau-signing.p12
   ```

   Lệnh này xuất mọi danh tính trong keychain đăng nhập, nên trước đó `security find-identity -v` phải chỉ in đúng một danh tính. macOS hỏi mật khẩu đặt cho file `.p12` và hỏi quyền dùng khoá riêng.
2. **Khoá EdDSA của Sparkle.** Công cụ tạo khoá nằm trong gói Sparkle mà Xcode đã tải. Chạy các lệnh sau từ gốc repo:

   ```sh
   xcodegen generate
   xcodebuild -resolvePackageDependencies -project Dau.xcodeproj -scheme Dau -derivedDataPath build/DerivedData-keys
   B=build/DerivedData-keys/SourcePackages/artifacts/sparkle/Sparkle/bin
   $B/generate_keys                      # tạo khoá, cất khoá riêng vào Keychain đăng nhập, in KHOÁ CÔNG KHAI
   $B/generate_keys -x ~/dau-sparkle.key # xuất khoá riêng ra file (ngoài repo)
   ```

   Khoá công khai được in ra (một chuỗi base64 ngắn) là `DAU_SPARKLE_PUBLIC_KEY`. Nội dung file xuất ra là `DAU_SPARKLE_PRIVATE_KEY`. Xong việc, hãy cất một bản sao ở nơi an toàn (trình quản lý mật khẩu), rồi xoá file xuất. Nếu mất khoá riêng, mọi bản đã cài sẽ không cập nhật được nữa, vì chúng chỉ tin chữ ký của đúng khoá này. Khoá này giữ nguyên khi chuyển sang Developer ID. Sau đó dọn `build/DerivedData-keys`.
3. **Nạp secret vào GitHub** bằng `gh secret set TÊN` (lệnh đọc giá trị từ stdin hoặc hỏi khi không có stdin). Bảng dưới ghi tên chính xác mà workflow dùng:

   | Secret | Giá trị | Lệnh |
   |---|---|---|
   | `DAU_TEAM_ID` | `M58DANM3ZP` | `gh secret set DAU_TEAM_ID --body M58DANM3ZP` |
   | `DAU_SIGNING_P12` | file `.p12` mã base64 | `base64 -i ~/dau-signing.p12 \| gh secret set DAU_SIGNING_P12` |
   | `DAU_SIGNING_P12_PASSWORD` | mật khẩu của `.p12` | `gh secret set DAU_SIGNING_P12_PASSWORD` |
   | `DAU_SPARKLE_PUBLIC_KEY` | khoá công khai (bước 2) | `gh secret set DAU_SPARKLE_PUBLIC_KEY` |
   | `DAU_SPARKLE_PRIVATE_KEY` | khoá riêng (bước 2) | `gh secret set DAU_SPARKLE_PRIVATE_KEY < ~/dau-sparkle.key` |

   Nạp xong thì xoá `~/dau-signing.p12` và `~/dau-sparkle.key` sau khi đã cất bản sao. Nếu cấu hình còn dở dang (chỉ có một phần), script dừng và báo tên các secret còn thiếu, thay vì âm thầm ra một bản không ký. Nếu chưa có secret nào, script chạy ở chế độ không ký (xem bên dưới).
4. **Vercel.** Nối repo `codefastlabs/dau` với project của `dau.codefastlabs.com`. Thư mục `site/` là trang web TanStack Start dựng thành HTML tĩnh ([`docs/research/WebsiteStack.md`](research/WebsiteStack.md), mục 3), nên project cần build. Cấu hình build (`framework`, lệnh build, thư mục đầu ra, header) nằm trong `site/vercel.json`; trong bảng điều khiển cần năm việc sau:
   1. Đặt Root Directory là `site` và giữ bật "Include files outside the root directory in the Build Step" (mặc định bật).
   2. Không cần biến môi trường để chọn pnpm: `installCommand` trong `site/vercel.json` chạy đúng bản pnpm ghi trong `packageManager` của `site/package.json` bằng `npx`, không qua Corepack (lý do ở [`docs/research/WebsiteStack.md`](research/WebsiteStack.md), mục "Ghim Node và pnpm"). Project không đặt `ENABLE_EXPERIMENTAL_COREPACK`; nếu biến này còn trong Settings › Environment Variables thì xoá đi.
   3. Xem gói tài khoản có Deployment Checks không. Nếu có, chọn job của `site.yml` làm check bắt buộc.
   4. Bật Web Analytics cho project trong mục Analytics (D45). Script và điểm nhận số liệu chỉ có sau lần triển khai kế tiếp. Sự kiện tuỳ chỉnh chỉ ghi được ở gói Pro trở lên; ở gói Hobby chỉ có số lượt xem.
   5. Thêm tên miền `dau.codefastlabs.com` trong Settings › Domains của project, rồi tạo bản ghi DNS mà trang đó yêu cầu ở nhà cung cấp DNS của `codefastlabs.com` (nhãn và giá trị bản ghi do Vercel hiện cho từng project, chưa kiểm trên máy).

   Sau lần triển khai đầu, kiểm bằng `scripts/release/check-site-appcast.sh` rằng `https://dau.codefastlabs.com/appcast.xml` trả về đúng file `site/appcast.xml` của `origin/main` với header `Cache-Control` không cache lâu. Workflow `site.yml` cũng chạy script này sau mỗi lần triển khai production (bước 7 của đường beta nói thêm).

   Bật hook build trang ở mỗi bản clone bằng `git config core.hooksPath .githooks` (`scripts/dev/doctor.sh` kiểm). Hook `.githooks/pre-push` build `site/` trước khi đẩy một commit có chạm thư mục này và chặn lần đẩy khi build hỏng, vì `main` không có branch protection và bước "Công bố" đẩy thẳng lên `main`.
5. **Nền DMG.** Ảnh nền là `Resources/Brand/DmgBackground.png` (640×400 pt, theo artboard "Cửa sổ ảnh đĩa DMG" trong `docs/canvas/src/DmgWindow.dc.html`) và có thể thêm `DmgBackground@2x.png` (1280×800, cho màn hình Retina). Script ghép hai file thành một TIFF. Nếu thiếu `DmgBackground.png` thì DMG không có nền.

## Phát hành một tag

Có hai đường tuỳ theo tag. Mọi tag đều bắt đầu bằng `v` và theo một trong các dạng dưới đây; dạng khác bị từ chối.

| Tag | Số hiển thị (`CFBundleShortVersionString`) | Workflow làm gì |
|---|---|---|
| `v0.1.0-beta.1` | 0.1.0 | Dựng một bản beta (đường beta, bên dưới). |
| `v0.1.0-beta.2` | 0.1.0 | Dựng một bản beta, trên commit mới. |
| `v0.1.0` | 0.1.0 (cùng tệp với beta cuối) | Quảng bá beta cuối và không dựng (đường chính thức, bên dưới). |

Số hiển thị luôn là ba số nguyên `X.Y.Z`. Chữ "beta N" chỉ nằm ngoài tệp nhị phân, tức là ở tên tag và ở tiêu đề bản phát hành trên GitHub (D7). Bản phát triển dựng bằng `scripts/dev/install-app.sh` mang số `X.Y.Z` của tag `v*` gần nhất trên HEAD; nếu không có tag thì dùng số trong `project.yml`. Bản build bằng Xcode cũng giữ số trong `project.yml`.

Sơ đồ dưới tả vòng đời của một bản, từ tag tới lúc thôi phát:

```mermaid
stateDiagram-v2
  state "Bản nháp" as Nhap
  state "Beta đã công bố" as Beta
  state "Bản chính thức đã công bố, cùng tệp với beta cuối" as OnDinh
  state "Bị hỏng" as Hong
  state "Gỡ khỏi appcast, vẫn còn trên GitHub" as Go
  [*] --> Nhap: đẩy tag beta, CI dựng
  Nhap --> [*]: CI hỏng, xoá bản nháp và tag
  Nhap --> Beta: Publish, chép appcast
  Beta --> OnDinh: tag chính thức cùng commit, quảng bá, Publish
  Beta --> Hong: phát hiện lỗi
  OnDinh --> Hong: phát hiện lỗi
  Hong --> Go: không cài được
  note right of Hong
    Luôn phát ngay một beta sửa trên commit mới.
    Không xoá bản hỏng khỏi GitHub.
  end note
```

**Điều kiện chung** (`scripts/release/check-release-gate.sh`, chạy được trên máy): workflow chỉ dựng bản ký hay quảng bá khi commit có tag nằm trong `origin/main` và workflow Test đã đạt trên đúng commit đó. Nếu thiếu một trong hai điều kiện, workflow dừng và báo lý do. Nếu đã tag lên một commit chưa lên `main` hay chưa xanh, hãy xoá tag, sửa, rồi tag lại.

### Đường beta

Sơ đồ dưới liệt kê các điểm kiểm trước khi dựng, theo đúng thứ tự mà `scripts/release/build-release.sh` chạy chúng:

```mermaid
flowchart TD
  tag["Đẩy tag vX.Y.Z-beta.N"] --> fmt{"Tag đúng dạng,<br>commit chưa<br>có beta khác?"}
  fmt -- không --> stop1["Dừng"]
  fmt -- có --> sec{"Secret?"}
  sec -- "không có cái nào" --> uns["Bản không ký, là bản phát triển:<br>DMG chỉ là artifact của lần chạy, 7 ngày"]
  sec -- "thiếu một phần" --> stop2["Dừng, báo secret còn thiếu"]
  sec -- đủ --> gate{"check-release-gate.sh:<br>commit trên main,<br>Test đã đạt?"}
  gate -- không --> stopg["Dừng: xoá tag, sửa, tag lại"]
  gate -- có --> exist{"Tag đã có<br>bản phát hành?"}
  exist -- "đã công bố" --> stope["Dừng: phát một beta mới"]
  exist -- "bản nháp" --> stopd["Dừng: xoá bản nháp và tag,<br>tag lên commit mới"]
  exist -- chưa --> ac{"check-appcast.sh:<br>appcast có beta<br>mới nhất đã công bố?"}
  ac -- không --> stopa["Dừng: công bố xong bản trước"]
  ac -- có --> b["Archive, ký, DMG;<br>Developer ID: xuất,<br>notarize, staple"]
  b --> cb["check-build.sh trên archive và DMG"]
  cb --> appc["Appcast của origin/main<br>thêm mục bản mới, ký EdDSA"]
  appc --> sums["Checksums.json: của origin/main<br>cộng SHA-256 của DMG"]
  sums --> draft["Bản nháp pre-release:<br>DMG, dSYM, Checksums.json,<br>appcast.xml"]
```

1. Bảo đảm `main` đang xanh (workflow Test) và mọi thứ của bản này đã được commit.
2. Chạy bài tải nặng của D42 (Ngưỡng hiệu năng) trên commit sẽ được tag: `scripts/selftest/load/heavy.sh` với bộ gõ bản Debug. Đây là lượt chạy chiếm màn hình, nên phiên chính chạy nó (`CLAUDE.md`, mục "Điều phối"). Chữ gõ ra phải đúng ở mọi ô và p99 cùng bộ nhớ phải nằm trong ngưỡng. Nếu không đạt thì không tag cho tới khi rõ nguyên nhân. Ghi số đo vào `site/src/data/Measurements.json`, trường `heavyLoad` (p99 và RSS cùng ngưỡng, bản dựng, máy, phiên bản macOS, ngày, commit đã đo, tên ngắn của các ứng dụng đã gõ thử trong `apps`; D42). Số ca test engine (`swift test --package-path Packages/DauEngine`) ghi vào trường `engineTests`. Trường `heavyLoad.sparkleVersion` là số build của bản sắp phát, tức mười lần (số commit của HEAD cộng một) khi commit file này lên HEAD ("Số build" dưới đây). Commit file này lên `main`, đợi workflow Test đạt rồi tag đúng commit đó. Trang tải về chỉ hiện mục "Đo được" khi `sparkleVersion` khớp mục appcast mà trang đang cho tải, nên số đo của bản này không hiện cho bản khác. Hình dạng file: `docs/research/WebsiteStack.md`, mục "Dữ liệu lúc build".
3. Tag và đẩy tag. Việc này dẫn tới công bố, nên cần chủ dự án đồng ý; kế hoạch M7 đã có sự đồng ý đó cho hai bản thử 0.0.1 và beta đầu tiên.

   ```sh
   git tag v0.1.0-beta.1
   git push origin v0.1.0-beta.1
   ```

   Mỗi beta cần một commit mới. Script từ chối tag beta đặt lên commit đã có tag beta khác, vì cùng commit thì cùng số build.

   **Tag đã công bố không bao giờ được dựng lại:** bản ký từ chối một tag đã có bản phát hành không phải bản nháp. Nếu CI hỏng trước khi công bố, hãy xoá bản nháp (và tag) trên GitHub rồi tag lên một commit mới. Tag còn bản nháp cũng bị từ chối, để không dựng đè lên bản nháp đó.
4. Workflow Release dựng bản ký, rồi tạo một **bản nháp** pre-release trên GitHub Releases (tiêu đề "Dấu 0.1.0 beta 1") kèm DMG, dSYM, `Checksums.json` và `appcast.xml`, với ghi chú song ngữ từ mẫu `release-notes-template.md`. `Checksums.json` là file `site/src/data/Checksums.json` của `origin/main` cộng một dòng `"<sparkle:version>": "<SHA-256 của DMG>"` cho bản mới; trang web đọc file này để hiện SHA-256 của DMG, vì appcast chỉ có chữ ký EdDSA. Appcast là appcast của `origin/main` cộng mục của bản mới; nó không lấy file ở commit có tag, vì mục của bản trước chỉ đưa vào file trên `main` ở bước Công bố. Bản ký từ chối dựng nếu appcast đó thiếu beta mới nhất đã công bố trên GitHub (`check-appcast.sh`), nên phải công bố xong bản trước (bước 5) rồi mới tag bản sau. Ở bước này chưa công bố gì, nên người dùng chưa thấy gì. Nếu thiếu secret, workflow dựng bản không ký (xem bên dưới) và chỉ lưu DMG cùng `Checksums.json` thành artifact của lần chạy (7 ngày), không tạo bản nháp.
5. Kiểm bản nháp. Log của workflow in từng bước đã làm hay bị bỏ qua, kèm `summary.txt`. Hãy thử mở DMG đã tải về.
6. **Công bố.** Bấm Publish release trên GitHub, rồi chép `appcast.xml` từ tài sản của bản đó vào `site/appcast.xml` và `Checksums.json` vào `site/src/data/Checksums.json`, commit cả hai file cùng nhau và đẩy lên `main` để Vercel dựng và xuất bản. Hook `pre-push` build trang trước khi lần đẩy này đi. Phải làm theo đúng thứ tự này, vì nếu appcast lên trước thì Sparkle sẽ trỏ vào một địa chỉ DMG chưa có. Cask Homebrew nằm ở `codefastlabs/homebrew-tap` và theo D6 (Phát hành).
7. **Kiểm trang đã phát appcast.** Đợi Vercel báo triển khai production của commit vừa đẩy xong, rồi chạy `scripts/release/check-site-appcast.sh` (mặc định so với `origin/main`; `git fetch origin main` trước). Script tải `https://dau.codefastlabs.com/appcast.xml`, so từng byte với `site/appcast.xml` rồi kiểm header `Cache-Control` có `max-age=0` và `must-revalidate`. Script lỗi thì Sparkle chưa thấy bản mới hoặc bản dựng đã đổi appcast: xem log triển khai trên Vercel, đừng báo bản đã ra. Job `deployment_status` của `site.yml` chạy cùng script này sau mỗi lần triển khai production, kể cả những lần không do bước Công bố, nên một commit làm trang lệch appcast cũng bị báo.

### Đường chính thức (quảng bá beta cuối)

Bản chính thức là tệp nhị phân của bản beta cuối, giữ nguyên và không dựng lại (như bản ứng viên của Apple): cùng DMG, cùng chữ ký, cùng vé notarize và cùng `CFBundleVersion`. Nếu muốn sửa gì sau beta cuối, hãy phát thêm một beta, chứ không sửa rồi tag bản chính thức. Chỉ beta ký Developer ID và đã notarize mới quảng bá được (D6): `promote-release.sh` từ chối beta ký Apple Development, kể cả khi chạy `--dry-run`.

1. Beta cuối đã được công bố (bước 5 ở trên), nên item của nó đã nằm trong `site/appcast.xml` cho mọi người. Vì vậy bản chính thức **không thêm item** vào appcast (cùng `sparkle:version`), mà chỉ bỏ thẻ kênh `beta` khỏi item đó (D7). Mọi item beta mang `<sparkle:channel>beta</sparkle:channel>`; `build-release.sh` gắn thẻ này bằng tuỳ chọn `--channel beta` của `generate_appcast`. Item không có thẻ là bản chính thức. Kênh nào cũng thấy nó. Chữ ký EdDSA (`sparkle:edSignature` trên `<enclosure>`) phủ DMG chứ không phủ thẻ kênh, nên bỏ thẻ thì không cần ký lại.
2. Tag **đúng commit của tag beta cuối** rồi đẩy tag:

   ```sh
   git tag v0.1.0 v0.1.0-beta.2
   git push origin v0.1.0
   ```

   Workflow Release chạy `scripts/release/promote-release.sh`. Script làm các việc sau:
   - Script này tìm tag `v0.1.0-beta.N` cùng commit (lấy N lớn nhất), tải DMG và dSYM của bản phát hành đó và đổi tên chúng thành `Dau-0.1.0.dmg` và `Dau-0.1.0.dSYMs.zip`. Đổi tên không làm đổi chữ ký hay vé notarize, vì cả hai nằm trên nội dung DMG; script kiểm lại bằng `codesign`, `stapler validate`, `spctl` và số hiển thị của Dau.app trong DMG.
   - Script này lấy `site/appcast.xml` của `origin/main`, bỏ đúng thẻ `beta` khỏi item của beta cuối (không đổi byte nào khác và không thêm item), rồi kiểm bằng `check-appcast.sh --promoted`.
   - Script này kiểm `Checksums.json` của `origin/main` ghi đúng SHA-256 của DMG đã đổi tên cho `sparkle:version` của beta (thiếu dòng thì thêm từ DMG đã tải).
   - Script này tạo một **bản nháp** không pre-release kèm DMG, dSYM, `Checksums.json` và `appcast.xml` đã quảng bá, như đường beta.

   Script từ chối khi tag không trỏ vào commit của tag beta nào, khi beta chưa được công bố, khi item của beta không có trong appcast của `origin/main` hay đã không còn thẻ `beta` hoặc khi đã có bản phát hành cùng tag. Có thể chạy thử trên máy mà không tạo gì bằng `scripts/release/promote-release.sh --tag v0.1.0 --dry-run`.
3. **Công bố.** Bấm Publish release trên GitHub, rồi chép `appcast.xml` và `Checksums.json` từ tài sản của bản đó vào `site/appcast.xml` và `site/src/data/Checksums.json`, commit cả hai và đẩy lên `main` (cùng thứ tự và cách làm như bước 6 của đường beta). `Checksums.json` của bản chính thức là của `origin/main` với dòng của beta cuối đã có sẵn; `promote-release.sh` dừng nếu dòng đó khác SHA-256 của DMG đã đổi tên. Cask Homebrew nằm ở `codefastlabs/homebrew-tap` và theo D6 (Phát hành).
4. **Kiểm trang đã phát appcast.** Làm như bước 7 của đường beta.

**Số build.** `CFBundleVersion` mặc định bằng mười lần số commit của HEAD (`git rev-list --count`), nên nó tăng theo lịch sử. Mỗi bản dựng có một số. Số này, ghi trong ngoặc sau số hiển thị (D25), phân biệt các beta của cùng một phiên bản (vì chúng cùng số hiển thị). Bản chính thức không có số riêng mà mang số của beta cuối. `build-release.sh` (bản ký) từ chối một số build đã có ở `sparkle:version` của bất kỳ item nào trong appcast của `origin/main`, báo lỗi và bảo dùng `--build-number`. Cờ `--build-number` đặt một số khác khi cần. Bản sửa gấp trên nhánh phải dùng cờ này. Lý do là nhánh tách từ commit thứ N có số mặc định 10(N+1), trùng với beta có thể đã phát từ commit thứ N+1 trên `main`, mà Sparkle coi hai bản cùng số là một. Bản sửa gấp lấy số trong khoảng trống giữa hai mốc (10N+1…10N+9). Cũng vì vậy, `main` đã push không bao giờ bị viết lại (force push, rebase): lịch sử ngắn lại thì số build sẽ lùi.

### Thứ tự công bố và gỡ

Sơ đồ dưới tả luật thứ tự ở bước 6 của đường beta và ở bước 3 của mục "Khi một bản bị hỏng": appcast chỉ trỏ vào DMG đã có địa chỉ công khai trên GitHub.

```mermaid
sequenceDiagram
  participant R as Người phát hành
  participant GH as GitHub Releases
  participant M as main, site/appcast.xml
  participant V as Vercel
  participant S as Sparkle trong Dấu đã cài
  Note over R,S: Công bố một beta
  R->>GH: Publish release, DMG có địa chỉ công khai
  R->>M: Chép appcast.xml và Checksums.json của bản đó, commit, đẩy
  M->>V: Xuất bản appcast
  S->>V: Đọc appcast, thấy bản mới
  S->>GH: Tải DMG
  Note over R,S: Gỡ một bản không cài được
  R->>M: Gỡ mục của bản đó khỏi appcast, đẩy
  M->>V: Xuất bản appcast
  R->>GH: Rồi mới xoá hay đổi bản đó
```

## Khi một bản bị hỏng

Có hai kênh (D7): beta chỉ tới kênh Beta, còn bản chính thức tới cả hai kênh.

1. **Phát ngay một beta sửa** (theo đường beta, trên commit mới). Beta sửa có số build cao hơn, nên Sparkle đẩy nó tới kênh Beta, kể cả tới người đã cài bản hỏng. Nếu bản hỏng là bản chính thức thì quảng bá beta sửa đó thành bản chính thức mới. Nếu `main` đã có việc dở thì làm theo kịch bản "Bản chính thức bị lỗi" ở mục "Kịch bản phát hành".
2. **Không xoá bản hỏng khỏi GitHub**, vì mục appcast của nó trỏ vào DMG ở đó và máy đã tải appcast cũ vẫn cần địa chỉ ấy.
3. **Chỉ gỡ mục của bản hỏng khỏi appcast khi bản đó không cài được** (người dùng không cập nhật qua nó được). Hãy gỡ khỏi `site/appcast.xml` trước, đợi Vercel xuất bản (`scripts/release/check-site-appcast.sh` báo trang đã phục vụ file mới), rồi mới xoá hay đổi gì trên GitHub. Nếu làm ngược lại, appcast sẽ trỏ vào một địa chỉ không còn.
4. Quay về bản trước (D19) để sau beta đầu tiên.

## Chuyển sang Developer ID

Việc này làm sau beta đầu tiên và xong trước bản chính thức đầu tiên (D6 (Phát hành), [`docs/Roadmap.md`](Roadmap.md) mục "Chuyển sang Developer ID"). Khoá EdDSA của Sparkle giữ nguyên.

1. **Apple Developer Program** (99 USD/năm). codefastlabs đăng ký dưới dạng tổ chức nếu là pháp nhân (cần mã D-U-N-S), để chữ ký mang tên tổ chức. Sau đó ghi lại **Team ID** (developer.apple.com › Account › Membership details).
2. **Chứng chỉ Developer ID Application.** Trong Xcode, vào Settings › Accounts, chọn Team, chọn Manage Certificates, bấm "+" rồi chọn Developer ID Application. Xuất ra `.p12` như bước 1 của mục "Việc của người dùng".
3. **Khoá App Store Connect API cho notarize.** Trong App Store Connect, vào Users and Access › Integrations › App Store Connect API › Team Keys và tạo một khoá (vai trò Developer là đủ). Tải file `.p8` về. File này chỉ tải được một lần. Sau đó ghi lại **Key ID** và **Issuer ID** (hiện ở đầu trang).
4. **Secret:** thay `DAU_TEAM_ID`, `DAU_SIGNING_P12` và `DAU_SIGNING_P12_PASSWORD` bằng giá trị của Developer ID, rồi thêm `DAU_NOTARY_KEY` (nội dung file `.p8`, cả dòng BEGIN/END), `DAU_NOTARY_KEY_ID` và `DAU_NOTARY_ISSUER_ID`. Có đủ ba secret notarize thì script đi đường Developer ID; thiếu một phần thì script dừng.
5. **Beta chuyển đổi:** beta đầu tiên ký Developer ID phải cập nhật được qua Sparkle từ một bản ký Personal Team trên máy thật, giữ cài đặt và không hiện banner "Cài lại" (D7, ý "Chuyển danh tính ký"). Mục "Kiểm bản build" thêm `spctl` và `stapler validate` cho đường này.

## Hết hạn và gia hạn

Dấu đã cài chạy không cần mạng (N2, D8) và không có bản quyền hay tài khoản (D6), nên không có hạn nào làm bộ gõ ngừng chạy. Những thứ hết hạn chỉ chặn việc phát bản mới hay việc nhận cập nhật. Riêng một chứng chỉ bị **thu hồi** thì làm bản đã cài không mở được nữa.

| Thứ có hạn | Hết hạn hay mất thì | Bản đã cài | Cách tránh, cách cứu |
|---|---|---|---|
| Tên miền `codefastlabs.com` | Sparkle không đọc được appcast (`SUFeedURL` cố định trong app). | Bản đã cài vẫn chạy nhưng không nhận cập nhật. | Bật tự gia hạn ở nhà đăng ký. Nếu đã mất tên miền thì không có đường nào báo bản mới cho máy đã cài: phải phát bản mới với địa chỉ appcast mới qua GitHub Releases và Homebrew. Người dùng cài tay một lần. |
| Chứng chỉ HTTPS của `dau.codefastlabs.com` | Hậu quả như dòng trên. | Bản đã cài vẫn chạy nhưng không nhận cập nhật. | Vercel tự cấp và gia hạn chứng chỉ khi tên miền còn trỏ đúng. Kiểm bằng `curl -sI https://dau.codefastlabs.com/appcast.xml`. |
| Chứng chỉ Apple Development của Personal Team (hạn ghi trên chứng chỉ; chứng chỉ đang dùng hết hạn ngày 05/11/2027) | Không ký được bản mới. | Bản đã cài vẫn chạy nếu macOS xét chữ ký theo dấu thời gian lúc ký (`--timestamp` trong `build-release.sh`), như với Developer ID; với chứng chỉ Apple Development thì chưa đo. | Tạo chứng chỉ mới trong Xcode (Settings › Accounts › Manage Certificates), rồi thay `DAU_SIGNING_P12` và `DAU_SIGNING_P12_PASSWORD`. Team ID không đổi nên App Group không đổi. |
| Chứng chỉ Apple Development **bị thu hồi** (bấm Revoke trong Xcode, hay đồng ý khi Xcode đề nghị thu hồi chứng chỉ cũ để tạo chứng chỉ mới) | Không ký được bản mới bằng chứng chỉ đó. | Bản đã cài có thể không mở được nữa; chưa đo. | Không thu hồi chứng chỉ đang ký bản phát hành. Nếu đã bị thu hồi thì tạo chứng chỉ mới và phát ngay một bản mới. |
| Apple Developer Program (gia hạn hằng năm, sau khi chuyển sang Developer ID) | Không lấy được chứng chỉ Developer ID mới, nên không ký hay notarize được bản mới. | Theo Apple, bản đã cài vẫn chạy[^devid]. | Gia hạn trước hạn. Nếu đã quá hạn thì gia hạn lại, rồi ký bản sau như thường. |
| Chứng chỉ Developer ID Application (sau khi chuyển; hạn ghi trên chứng chỉ trong Keychain Access) | Không ký được bản mới. | Bản đã cài vẫn chạy, vì Gatekeeper xét chứng chỉ còn hạn vào lúc ký[^devid]. Bản ký có dấu thời gian (`--timestamp` trong `build-release.sh`) và không dùng provisioning profile (`project.yml`), nên không có profile nào hết hạn mỗi lần mở. | Tạo chứng chỉ mới, rồi thay secret `DAU_SIGNING_P12` và `DAU_SIGNING_P12_PASSWORD`. |
| Chứng chỉ Developer ID **bị thu hồi** (khoá lộ, Apple thu hồi) | Mọi bản ký bằng chứng chỉ đó không cài được và không mở được nữa[^devid]. | Bản đã cài **không mở được**. | Giữ `.p12` ngoài repo, chỉ trong secret của GitHub và trình quản lý mật khẩu. Nếu đã bị thu hồi thì tạo chứng chỉ mới và phát ngay một bản mới; người dùng tải lại DMG hay chạy `brew reinstall`, vì bản cũ không tự cập nhật được nữa. |
| Khoá EdDSA của Sparkle (không có hạn) | Nếu mất khoá riêng, bản đã cài vẫn chỉ tin chữ ký của đúng khoá này. | Bản đã cài vẫn chạy nhưng kẹt ở bản đó. | Cất bản sao trong trình quản lý mật khẩu ("Việc của người dùng", bước 2). Nếu đã mất thì xử lý như mất tên miền: người dùng cài tay bản mới một lần. |
| Khoá App Store Connect API (notarize, sau khi chuyển), bị thu hồi hay mất | Không notarize được. | Bản đã cài không bị ảnh hưởng. | Tạo khoá mới, rồi thay `DAU_NOTARY_KEY`, `DAU_NOTARY_KEY_ID`, `DAU_NOTARY_ISSUER_ID`. |

[^devid]: Apple, Developer ID: https://developer.apple.com/support/developer-id/

## Chế độ ký

`build-release.sh` chọn chế độ theo các biến môi trường (biến rỗng tính là không đặt):

| Chế độ | Biến cần có | Việc làm khác nhau |
|---|---|---|
| Không ký | không biến nào, hoặc `--unsigned` | Bản phát triển (mục dưới). |
| Ký Personal Team | `DAU_TEAM_ID`, `DAU_SPARKLE_PUBLIC_KEY`, `DAU_SPARKLE_PRIVATE_KEY` | Archive ký thủ công bằng chứng chỉ Apple Development của Team (tìm theo Organizational Unit của chứng chỉ, bỏ chứng chỉ đã thu hồi), hardened runtime, `--timestamp`. Dau.app lấy thẳng từ archive, không xuất. Xcode để mã lồng trong Sparkle với chữ ký ad hoc của Sparkle, nên script ký lại từ trong ra ngoài (mã lồng, framework, app) để mọi thành phần cùng Team ID; hardened runtime chỉ nạp Sparkle khi hai bên cùng Team. DMG ký cùng chứng chỉ. Không notarize, không staple. |
| Ký Developer ID | ba biến trên cùng `DAU_NOTARY_KEY`, `DAU_NOTARY_KEY_ID`, `DAU_NOTARY_ISSUER_ID` | Xuất archive bằng `-exportArchive` phương thức `developer-id`, notarize và staple app, ký, notarize và staple DMG, kiểm thêm `spctl` và `stapler validate`. |

Cả hai chế độ ký đặt `DAU_OFFICIAL=YES`, `SUFeedURL` và `SUPublicEDKey`, chạy các điều kiện trước khi dựng, ký appcast bằng EdDSA và ghi `Checksums.json`. Có một phần của bộ biến (ví dụ một biến notarize) thì script dừng. Bản nháp trên GitHub có ghi chú song ngữ làm từ `release-notes-template.md`; ghi chú của bản không notarize có thêm đoạn hướng dẫn mở qua Gatekeeper lần đầu, hiện còn ô trống `[Gatekeeper labels — measured at M7 step 4]` cho tới khi nhãn được đo (N5).

## Chế độ không ký

Khi không có secret nào (hoặc khi dùng `--unsigned`), script vẫn chạy trọn từ archive tới DMG và báo bước nào bị bỏ qua: ký app, xuất Developer ID, notarize, staple, ký DMG, ký bản cập nhật và appcast. Bản này dựng như bản phát triển (D7, D25) và dùng để kiểm quy trình, không phát cho người dùng:

- `DAU_OFFICIAL=NO`, nên bản này dùng biểu tượng bản phát triển và không có `SUFeedURL`, `SUPublicEDKey`; vì vậy Sparkle không khởi động.
- App ký tạm (ad hoc) và không có Team ID, nên App Group bị từ chối (D24).
- DMG có tên `Dau-<phiên bản>-dev-unsigned.dmg` (nếu không có tag thì là `Dau-dev-unsigned.dmg`) và không có appcast. Script vẫn ra `Checksums.json` (khoá là số build, giá trị là SHA-256 của DMG không ký) để kiểm phần hợp nhất; đừng chép file này vào `site/`.

Lệnh dưới chạy trên máy phát triển và không cần chứng chỉ; nó mất khoảng một phút và ghi vào `build/release/`:

```sh
scripts/release/build-release.sh --tag v0.1.0-beta.1 --unsigned
```

Nếu không có cờ `--layout` thì script không mở Finder. Khi đó DMG có Dau.app và liên kết Applications, nhưng cửa sổ dùng bố cục mặc định và không có nền.

## Bố cục cửa sổ DMG

Bố cục (kích thước cửa sổ, vị trí biểu tượng, nền) nằm trong `.DS_Store` của ảnh đĩa và do Finder ghi; macOS không có API công khai nào khác để làm việc này. `--layout` gọi `scripts/release/layout-dmg.sh`, script này dùng AppleScript điều khiển Finder trong vài giây và hiện một cửa sổ Finder. Vì vậy nó chỉ chạy trên CI (workflow Release đã bật cờ này) hoặc trên máy như một lượt chạy chiếm màn hình, do phiên chính chạy theo chế độ quyền của Claude Code ([`CLAUDE.md`](../CLAUDE.md), mục "Điều phối"). Nếu bước này lỗi, script cảnh báo và vẫn ra DMG không có bố cục; hãy đọc dòng "Bố cục cửa sổ DMG" ở `summary.txt`.

## Kiểm bản build

`scripts/release/check-build.sh` chạy trong script phát hành, trên cả bản trong archive lẫn bản trong DMG đã mở.
- Với bản chính thức (`--signed`), `CFBundleIconName` của Dấu.app và của bộ gõ phải là `AppIcon` (D25). App chủ phải có `SUFeedURL` cùng `SUPublicEDKey`.
- Với bản không ký, biểu tượng phải là `AppIconDev`. App không có hai khoá đó.
- Ở cả hai loại, hai binary phải là universal và đã lược ký hiệu cục bộ (`nm`), dSYM của cả hai phải có trong archive, bộ gõ không có khoá `SU…`, `SUEnableSystemProfiling` là false (D8) và bộ gõ không link Sparkle và không có quyền mạng (N2).
- Bản ký (`--signed --team <Team ID>`) còn kiểm bằng `codesign` trên Dau.app, bộ gõ và mọi mã lồng trong Sparkle.framework (Updater.app, Downloader.xpc, Installer.xpc, Autoupdate): chữ ký hợp lệ ở từng kiến trúc (`--deep --strict`), chứng chỉ lá thuộc Team ID đã cho, hardened runtime bật, có dấu thời gian bảo mật và không có `get-task-allow` (D8). Chữ ký của app phải là Apple Development, hoặc Developer ID nếu có `--developer-id`.
- Chỉ bản Developer ID kiểm thêm bằng `spctl` và `stapler validate`; bản ký Personal Team không notarize nên không qua hai bước đó. Script quảng bá đọc chữ ký của DMG và từ chối beta ký Apple Development (mục "Đường chính thức").
- Xcode không đưa `get-task-allow` vào archive Release của Dấu khi ký bằng chứng chỉ Apple Development, nhờ `CODE_SIGN_INJECT_BASE_ENTITLEMENTS: NO` trong `project.yml` (đã đo trên archive của Dau.app và bộ gõ). Nếu có lần nào nó quay lại, `check-build.sh` báo lỗi.

## Còn phải thấy chạy thật

Đã chạy trên máy phát triển: chế độ không ký trọn tới DMG; archive ký Personal Team với các tham số ký mà script dùng, rồi ký lại mã Sparkle và app, rồi `check-build.sh --signed` đạt (chứng chỉ lá, hardened runtime, dấu thời gian, không `get-task-allow` ở app, bộ gõ và mã Sparkle); ký và kiểm một DMG thử bằng chứng chỉ đó. Archive thử dùng khoá công khai giả, nên chưa có gì về khoá EdDSA thật.

Chỉ thấy được trên CI, ở bước 4 của kế hoạch M7 (hai tag thử), rồi sửa script theo log của lần đó:
- Nhập chứng chỉ `.p12` Apple Development vào keychain tạm của runner và việc runner thấy nó là danh tính dùng được (cần chuỗi chứng chỉ tới Apple WWDR trong keychain).
- Toàn bộ `build-release.sh` ở chế độ ký Personal Team, kể cả các điều kiện (`check-release-gate.sh`, `check-appcast.sh`, việc từ chối tag đã có bản phát hành, cần quyền `actions: read` và `GH_TOKEN` của workflow).
- `layout-dmg.sh` (cần Finder) và `generate_appcast` ký bằng khoá thật. Chữ ký EdDSA nằm trên `<enclosure>`. Sparkle chỉ ký cả appcast khi app đặt `SURequireSignedFeed`; Dấu không đặt khoá này và hai script từ chối appcast có khối chữ ký đó.
- Bản nháp kèm ghi chú: `gh release create` ghép `--notes-file` với `--generate-notes` đúng như mong đợi.
- Sparkle trong Dấu đọc thẻ kênh (bước 1f mục 2, bước 2) và cập nhật qua bản ký Personal Team, mã Sparkle đã ký lại vẫn chạy được trên máy thật.
- `check-site-appcast.sh` với trang thật (hai nhánh của nó đã chạy với một máy chủ cục bộ).

Đường quảng bá (`promote-release.sh`) chưa chạy thật. Script này cần một bản beta đã công bố trên GitHub để `gh release download`, để kiểm chữ ký trên tệp đã đổi tên và để tạo bản nháp. Lần đầu thấy nó chạy sẽ là lúc quảng bá beta cuối của 0.1.0: khi đó chạy `--dry-run` trước, rồi sửa script hay tài liệu này theo log. Đổi tên DMG không làm hỏng chữ ký hay vé notarize mới chỉ là suy luận từ cách hai thứ này gắn vào nội dung tệp. Phần bỏ thẻ kênh khỏi appcast đã chạy offline (`scripts/release/test-appcast.sh` và `generate_appcast --channel beta` thử trên một archive giả).

Notarize và staple chạy lần đầu khi chuyển sang Developer ID.

Phần `Checksums.json` đã chạy trong chế độ không ký (file ra đúng một dòng khớp `shasum -a 256` của DMG) và phần hợp nhất đã kiểm offline bằng `test-appcast.sh`. Đường ký (tài sản của bản nháp) và đường quảng bá (kiểm SHA-256 của DMG đã đổi tên) chưa chạy thật.
