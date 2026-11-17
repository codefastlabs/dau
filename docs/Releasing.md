# Phát hành

Cách một bản Dấu ra đời: từ tag git tới DMG, bản cập nhật Sparkle và Homebrew. Quyết định: D6 (Phát hành), D7 (Cập nhật và loại bản dựng), D25 (Nhận diện). Kế hoạch mốc: [`docs/Progress.md`](Progress.md) mục "Kế hoạch M7".

Phiên chính và subagent không cầm khoá: chứng chỉ, khoá App Store Connect và khoá EdDSA chỉ nằm ở máy người dùng và trong secret của GitHub. Mọi thứ trong repo là mã, mẫu cấu hình và tên secret.

## Thành phần

| Thành phần | Ở đâu |
|---|---|
| Script dựng bản phát hành (archive, xuất Developer ID, notarize, staple, DMG, appcast) | `scripts/release/build-release.sh` |
| Kiểm một bản build (biểu tượng, ký hiệu, khoá Sparkle, bộ gõ, chữ ký) | `scripts/release/check-build.sh` |
| Sắp xếp cửa sổ DMG bằng Finder (chỉ CI) | `scripts/release/layout-dmg.sh` |
| Test ở mỗi lần đẩy mã | `.github/workflows/test.yml` |
| Tag `v*` dựng bản nháp trên GitHub Releases | `.github/workflows/release.yml` |
| Appcast, thư mục gốc của project Vercel | `site/appcast.xml` |

Cách gọi và tuỳ chọn của từng script nằm ở đầu script.

## Việc của người dùng (làm một lần)

1. **Apple Developer Program** (99 USD/năm). Đăng ký tổ chức nếu codefastlabs là pháp nhân (cần mã D-U-N-S), để Gatekeeper hiện tên tổ chức (D7). Ghi lại **Team ID** (developer.apple.com › Account › Membership details).
2. **Chứng chỉ Developer ID Application.** Xcode › Settings › Accounts › chọn Team › Manage Certificates › "+" › Developer ID Application. Rồi Keychain Access › login › My Certificates › chuột phải chứng chỉ vừa tạo › Export… › định dạng `.p12`, đặt mật khẩu. File `.p12` để ngoài repo.
3. **Khoá App Store Connect API cho notarize.** App Store Connect › Users and Access › Integrations › App Store Connect API › Team Keys › tạo khoá (vai trò Developer là đủ). Tải `.p8` (chỉ tải được một lần); ghi **Key ID** và **Issuer ID** (hiện đầu trang).
4. **Khoá EdDSA của Sparkle.** Công cụ nằm trong gói Sparkle mà Xcode đã tải. Từ gốc repo:

   ```sh
   xcodegen generate
   xcodebuild -resolvePackageDependencies -project Dau.xcodeproj -scheme Dau -derivedDataPath build/DerivedData-keys
   B=build/DerivedData-keys/SourcePackages/artifacts/sparkle/Sparkle/bin
   $B/generate_keys                      # tạo khoá, cất khoá riêng vào Keychain đăng nhập, in KHOÁ CÔNG KHAI
   $B/generate_keys -x ~/dau-sparkle.key # xuất khoá riêng ra file (ngoài repo)
   ```

   Khoá công khai in ra (chuỗi base64 ngắn) là `DAU_SPARKLE_PUBLIC_KEY`. Nội dung file xuất là `DAU_SPARKLE_PRIVATE_KEY`. Xong thì cất một bản sao ở nơi an toàn (trình quản lý mật khẩu), rồi xoá file xuất: mất khoá riêng thì mọi bản đã cài không cập nhật được nữa, vì chúng chỉ tin chữ ký của đúng khoá này. Dọn `build/DerivedData-keys` sau đó.
5. **Nạp secret vào GitHub** (repo › Settings › Secrets and variables › Actions, hoặc `gh secret set TÊN`). Tên chính xác mà workflow dùng:

   | Secret | Giá trị |
   |---|---|
   | `DAU_TEAM_ID` | Team ID (bước 1) |
   | `DAU_DEVELOPER_ID_P12` | file `.p12` mã base64: `base64 -i file.p12 \| pbcopy` |
   | `DAU_DEVELOPER_ID_P12_PASSWORD` | mật khẩu của `.p12` |
   | `DAU_NOTARY_KEY` | nội dung file `.p8` (cả dòng BEGIN/END) |
   | `DAU_NOTARY_KEY_ID` | Key ID |
   | `DAU_NOTARY_ISSUER_ID` | Issuer ID |
   | `DAU_SPARKLE_PUBLIC_KEY` | khoá công khai (bước 4) |
   | `DAU_SPARKLE_PRIVATE_KEY` | khoá riêng (bước 4) |

   Cấu hình dở dang (có một phần) làm script dừng với tên các secret còn thiếu, không âm thầm ra bản không ký. Chưa có secret nào thì chạy chế độ không ký (dưới).
6. **Vercel.** Nối repo `codefastlabs/dau` với project của `dau.codefastlabs.com`, Root Directory là `site`, không có bước build. Tới M8 thư mục chỉ có `appcast.xml`; kiểm `https://dau.codefastlabs.com/appcast.xml` trả về file đó.
7. **Nền DMG.** Ảnh `Resources/Brand/DmgBackground.png` (640×400 pt, theo artboard "Cửa sổ ảnh đĩa DMG" trong `docs/canvas/src/DmgWindow.dc.html`) và tuỳ chọn `DmgBackground@2x.png` (1280×800, cho màn hình Retina). Script ghép hai file thành một TIFF. Thiếu `DmgBackground.png` thì DMG không có nền.

## Phát hành một tag

1. Chắc chắn `main` xanh (workflow Test) và đã commit mọi thứ của bản này.
2. Tag và đẩy tag: số hiển thị lấy từ tag (D7). Với hai bản thử của kế hoạch M7 bước 2, việc này công bố chúng lên appcast, nên cần người dùng đồng ý trước khi đẩy tag.

   ```sh
   git tag v0.1.0-beta.1
   git push origin v0.1.0-beta.1
   ```

   | Tag | Số hiển thị (`CFBundleShortVersionString`) |
   |---|---|
   | `v0.1.0-beta.1` | 0.1.0 beta 1 |
   | `v1.3.0` | 1.3.0 |

   Dạng khác bị từ chối.
3. Workflow Release dựng, rồi tạo **bản nháp** trên GitHub Releases (đánh dấu pre-release nếu tag có `-beta.`) kèm DMG, dSYM và (khi đã ký) `appcast.xml` đã thêm bản mới. Chưa có gì được công bố: người dùng chưa thấy gì.
4. Kiểm bản nháp: log của workflow in từng bước đã làm hay bỏ qua, và `summary.txt`. Thử mở DMG đã tải về.
5. **Công bố** (người dùng đồng ý một lần cho bản thử đầu, theo kế hoạch M7 bước 4): bấm Publish release trên GitHub; chép `appcast.xml` từ tài sản của bản đó vào `site/appcast.xml`, commit, đẩy lên `main` để Vercel xuất bản. Làm theo thứ tự này: nếu appcast lên trước, Sparkle trỏ vào địa chỉ DMG chưa có. Rồi cập nhật cask Homebrew ở `codefastlabs/homebrew-tap`.

**Số build.** `CFBundleVersion` mặc định là mười lần số commit của HEAD (`git rev-list --count`), cộng 1 với tag ổn định, nên tăng theo lịch sử, và bản ổn định dựng lại từ đúng commit của bản beta cuối (D7) vẫn lớn hơn số của beta đó. Cờ `--build-number` của script đặt số khác khi cần.

## Chế độ không ký

Khi không có secret nào (hoặc `--unsigned`), script vẫn chạy trọn từ archive tới DMG và báo bước nào bị bỏ qua: xuất Developer ID, notarize, staple, ký DMG, ký bản cập nhật, appcast. Bản này **không phải bản chính thức**:

- dựng với `DAU_OFFICIAL=YES` để đi đúng đường mã và qua đúng bước kiểm (biểu tượng chuẩn), nhưng khoá công khai là chuỗi giả và địa chỉ appcast nằm trên tên miền `.invalid`: một app như vậy không thể chạm hay cập nhật từ appcast thật;
- app ký tạm (ad hoc), DMG tên `*-unsigned.dmg`, không có appcast.

Chạy trên máy phát triển, không cần chứng chỉ (khoảng một phút, ghi vào `build/release/`):

```sh
scripts/release/build-release.sh --tag v0.1.0-beta.1 --unsigned
```

Không cờ `--layout` thì không mở Finder: DMG có Dau.app và liên kết Applications nhưng cửa sổ dùng bố cục mặc định, không nền.

## Bố cục cửa sổ DMG

Bố cục (kích thước cửa sổ, vị trí biểu tượng, nền) nằm trong `.DS_Store` của ảnh đĩa, do Finder ghi; macOS không có API công khai khác. `--layout` gọi `scripts/release/layout-dmg.sh`, dùng AppleScript điều khiển Finder vài giây và hiện một cửa sổ Finder, nên chỉ chạy trên CI (workflow Release đã bật) hoặc khi người dùng đồng ý giờ chạy. Nếu bước này lỗi, script cảnh báo và vẫn ra DMG không có bố cục: đọc dòng "Bố cục cửa sổ DMG" ở `summary.txt`.

## Kiểm bản build

`scripts/release/check-build.sh` chạy trong script phát hành trên cả bản trong archive lẫn bản trong DMG đã mở. Nó kiểm `CFBundleIconName` của Dấu.app và bộ gõ là `AppIcon` (D25), cả hai binary universal và đã lược ký hiệu cục bộ (`nm`), dSYM của cả hai có trong archive, `SUFeedURL` và `SUPublicEDKey` có ở app chủ và không có ở bộ gõ, `SUEnableSystemProfiling` là false (D8), bộ gõ không link Sparkle và không có quyền mạng (N2). Bản ký còn được kiểm bằng `codesign`, `spctl` và `stapler validate`.

## Còn phải thấy chạy thật

Phần ký, notarize, staple, `layout-dmg.sh` và `generate_appcast` ký thật cần tài khoản hoặc Finder nên chưa chạy ở máy phát triển; chế độ không ký đã chạy trọn tới DMG. Lần thấy chúng chạy đầu tiên là bước 2 của kế hoạch M7 (hai tag thử sau bước 0): sửa script theo log của lần đó.
