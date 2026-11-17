# Nhận diện thương hiệu

Biểu tượng, logo chữ, màu, phông và các file nhận diện cần xuất cho app, bộ gõ, website và ảnh chia sẻ. Quyết định gốc: D24 (Tên và định danh) cho tên, D25 (Nhận diện) cho nhận diện; tài liệu này chỉ ghi chi tiết.

## Hiện trạng

- Biểu tượng app và biểu tượng bản phát triển là hai file Icon Composer: `Apps/Dau/Resources/AppIcon.icon` và `AppIconDev.icon` (cả hai target dùng chung). Nguồn của chúng là `scripts/assets/make-app-icon.sh`, dựng từ hình học của artboard; sửa biểu tượng thì sửa script rồi chạy lại, không sửa tay các file `.icon`. Xcode (`actool`) biên dịch file mà `DAU_APPICON` chọn (D25) thành `Assets.car` (các kiểu Mặc định, Tối, Trong suốt, Phủ màu) và `AppIcon.icns` hay `AppIconDev.icns` (dự phòng cho macOS 14–15, `actool` tự sinh). Xem kết quả không cần mở Icon Composer: `scripts/assets/preview-app-icon.sh`.
- Mỗi file `.icon` có bốn lớp: nền (màu nền của file; Tối là màu thứ hai), chữ "a", dấu mũ, dấu sắc; bản phát triển thêm lớp dải Hổ phách (Tối: màu thứ hai). Trong suốt và Phủ màu do macOS dẫn ra từ các lớp. Chữ "a" là đường nét đã chuyển từ Be Vietnam Pro Bold (700), theo đầu script; logo chữ dùng ExtraBold (mục "Logo chữ").
- Bản sao phẳng cho README và web: `Resources/Brand/AppIcon.svg`, `AppIconDev.svg` (cùng script).
- Ảnh xem trước GitHub: `Resources/Brand/github-preview.png`, 1280 × 640, xuất từ artboard bằng `scripts/assets/export-github-preview.sh` (không dùng bản chụp trong `docs/canvas/`: canvas đặt `@import` phông sau các luật CSS khác nên bản chụp dùng phông thay thế, không phải Be Vietnam Pro). Tải lên ở Settings › Social preview của repo.
- Ảnh template thanh menu: bản tạm `Apps/DauInputMethod/Resources/ModeVietnamese.tiff`, sinh bằng `scripts/assets/make-mode-icons.swift`.
- Nền cửa sổ DMG: `Resources/Brand/DmgBackground.png` (640 × 400) và `DmgBackground@2x.png` (1280 × 800), vẽ từ artboard "Cửa sổ ảnh đĩa DMG" bằng `scripts/assets/make-dmg-background.sh`: chỉ màu Giấy và mũi tên Mực mờ, không biểu tượng, không chữ (Finder vẽ). Cỡ cửa sổ, cỡ biểu tượng và toạ độ hai biểu tượng ghi ở đầu script; `scripts/release/build-release.sh` ghép hai ảnh thành một TIFF nhiều độ phân giải bằng `tiffutil -cathidpicheck` nên repo không giữ TIFF.
- Chưa xuất: favicon, `apple-touch-icon.png`, ảnh Open Graph (đi cùng website, M8).

## Mockup

Các artboard "Nhận diện – …", "Ảnh chia sẻ Open Graph" và "Ảnh xem trước GitHub" trên canvas (link và bản chụp trong repo: [`docs/UI.md`](UI.md), [`docs/canvas/README.md`](canvas/README.md)):

- [hướng biểu tượng](canvas/BrandConcepts.png)
- [hướng dẫn thương hiệu](canvas/BrandGuide.png)
- [biểu tượng ứng dụng](canvas/AppIcon.png)
- [nơi hình đại diện xuất hiện](canvas/BrandInUse.png)
- [biểu tượng trong hệ thống](canvas/MenuBarIcons.png)
- [biểu tượng bản phát triển](canvas/AppIconDev.png)
- [ảnh chia sẻ Open Graph](canvas/OgImage.png)
- [ảnh xem trước GitHub](canvas/GithubPreview.png)

## Biểu tượng
- Chữ "ấ" màu Giấy trên nền Mực; dấu mũ cùng màu chữ, **riêng dấu sắc màu Son** — biểu tượng tự kể tên sản phẩm.
- Dựng bằng Icon Composer của Apple (một file nguồn, đủ các kiểu Mặc định / Tối / Trong suốt / Phủ màu trên macOS 26+); `.icns` cho macOS 14–15 do `actool` sinh từ cùng file (chỉ có 16, 32, 128, 256 pt; cỡ lớn hơn do hệ thống phóng).
- Chữ "a" trong biểu tượng là đường nét (outline) trong file nguồn, không phụ thuộc phông khi render.
- Nét dấu: một bộ nét cho mọi cỡ (chốt 17/11/2026; file `.icon` không có bản nét dày riêng cho 16–32 pt, và làm dày nét chung thì đổi cả biểu tượng ở cỡ lớn). Xem bằng mắt (`scripts/assets/preview-app-icon.sh`): ở 32 pt đọc ra "ấ"; ở 16 pt dấu mũ và dấu sắc còn lại vài điểm ảnh, chữ vẫn đọc là "a" có dấu.
- Viền: macOS tự vẽ viền mảnh quanh biểu tượng ở kiểu Tối, Trong suốt, Phủ màu; file không thêm viền riêng.

## Biểu tượng bản phát triển
- Bản nào dùng biểu tượng này: D25 (các loại bản ở D7 (Cập nhật và loại bản dựng)).
- Chữ "ấ" giữ nguyên như biểu tượng chuẩn (Giấy, dấu sắc Son), trên nền **Chì**.
- Một dải chéo màu **Hổ phách** cắt góc dưới phải, nằm ngoài chữ "a".
- Kiểu Tối: nền và dải tối hơn một bậc.
- Kiểu Trong suốt và Phủ màu: macOS bỏ màu, dải còn lại như một hình sáng hơn nền.
- Mockup: artboard [biểu tượng bản phát triển](canvas/AppIconDev.png).
- Xem bằng mắt ảnh xuất từ file `.icon` (`scripts/assets/preview-app-icon.sh`; artboard chỉ mô phỏng hai kiểu Trong suốt, Phủ màu): dải còn nhận ra ở 16 pt và ở mọi kiểu; ở Trong suốt và Phủ màu dải là hình sáng hơn nền.

## Biểu tượng thanh menu (input mode)
- Một ảnh template đơn sắc: ô bo tròn tô đặc, chữ "V" khoét rỗng.
  - Cùng kiểu và cùng cỡ với ô "A" của U.S.: ô 22 × 16 pt, góc bo 4 pt; chữ 9 × 8,5 pt căn giữa (đo trên thanh menu Retina 30/10/2026, `scripts/assets/make-mode-icons.swift`).
  - Để macOS tự tô màu theo nền.
- Cách khai ảnh template trong Info.plist: [`docs/Architecture.md`](Architecture.md), mục "Bundle: biểu tượng, ký, entitlements".
- Ô chỉ báo vẽ chính ảnh này màu trắng.
  - Chữ trần như "A" của U.S. chỉ có cho nguồn của Apple (bảng nhãn dựng sẵn trong macOS, không đọc `TISIconLabels` của bộ gõ ngoài).
- Không dùng màu thương hiệu (D9 (Giao diện)).
- Dấu chỉ có một input mode (D2 (Chuyển Việt/Anh)); khi gõ tiếng Anh bằng ABC/U.S., biểu tượng là của hệ thống.

## Logo chữ
- "Dấu" viết bằng Be Vietnam Pro ExtraBold, **một màu**. Không tách dấu sắc ra tô màu riêng: lệch một chút là thành "Dâu".
- Không bao giờ viết "Dau"/"dau" trước người dùng (D24).

## Màu
| Tên | Mã | Dùng cho |
|---|---|---|
| Mực | `#10285A` (Tối: `#0B0F1A`) | nền biểu tượng, nền ảnh chia sẻ, màu nhấn trên website |
| Son | `#E0533D` | chỉ dấu sắc trong biểu tượng — không dùng cho nút, chữ, nền |
| Giấy | `#F6F1E7` | chữ trên nền Mực, nền website |
| Than | `#1D1D1F` | chữ chính |
| Chì | `#2C2F35` (Tối: `#1A1B1F`) | chỉ nền biểu tượng bản phát triển |
| Hổ phách | `#F2B705` (Tối: `#D9A400`) | chỉ dải góc của biểu tượng bản phát triển — không dùng cho nút, chữ, nền |

App dùng màu và phông của hệ thống (D9); bảng màu này dành cho biểu tượng, website, ảnh chia sẻ, tài liệu.

## Chữ
- Be Vietnam Pro (giấy phép OFL) cho logo, website, ảnh chia sẻ.
- Không dùng SF Pro ngoài giao diện app: giấy phép phông San Francisco của Apple chỉ cho dùng để làm mockup giao diện cho phần mềm chạy trên hệ điều hành của Apple ([Apple Fonts](https://developer.apple.com/fonts/), phần giấy phép trên trang).

## File cần xuất
| File | Kích thước | Dùng ở |
|---|---|---|
| Biểu tượng app: `Apps/Dau/Resources/AppIcon.icon` (`.icns` do `actool` sinh khi build) | 16–1024 pt | Finder, Dock, Launchpad, Spotlight, onboarding, hộp thoại |
| Biểu tượng bản phát triển: `Apps/Dau/Resources/AppIconDev.icon` (cũng sinh `.icns`) | 16–1024 pt | như trên, ở mọi bản không phải bản chính thức (D25) |
| Ảnh template thanh menu V | 22×16 pt @1x/@2x (TIFF; PDF vector khi có bản chính thức) | menu nguồn đầu vào |
| `favicon.ico` + `favicon.svg` | 16, 32 | tab trình duyệt, kết quả tìm kiếm |
| `apple-touch-icon.png` | 180×180 | ghim trang trên iPhone/iPad |
| `og-image.png` | 1200×630 | `og:image`, `twitter:image` — link chia sẻ Zalo, Messenger, Slack, iMessage, X |
| GitHub social preview: `Resources/Brand/github-preview.png` | 1280×640 | Settings › Social preview của repo |
| Nền DMG: `Resources/Brand/DmgBackground.png`, `DmgBackground@2x.png` | 640×400 và 1280×800 | file DMG phát hành |

## Thẻ cho website
`<title>Dấu – Bộ gõ tiếng Việt cho macOS</title>`, `meta description`, `og:title`, `og:description`, `og:image`, `og:locale=vi_VN`, `twitter:card=summary_large_image`. Mô tả và tiêu đề không chứa lời hứa chưa kiểm chứng (N5 (Chỉ hứa điều đã kiểm chứng)).
