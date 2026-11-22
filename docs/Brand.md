# Nhận diện thương hiệu

Tài liệu này ghi biểu tượng, logo chữ, màu, phông và các file nhận diện cần xuất cho app, bộ gõ, website và ảnh chia sẻ. Quyết định gốc về tên là D24 (Tên và định danh), về nhận diện là D25 (Nhận diện); tài liệu này chỉ ghi chi tiết.

## Hiện trạng

- Biểu tượng app và biểu tượng bản phát triển là hai file Icon Composer: `Apps/Dau/Resources/AppIcon.icon` và `AppIconDev.icon`. Cả hai target dùng chung hai file này. Nguồn của chúng là `scripts/assets/make-app-icon.sh`, script dựng file từ hình học của artboard. Muốn sửa biểu tượng thì sửa script rồi chạy lại, không sửa tay các file `.icon`. Khi build, Xcode (`actool`) biên dịch file mà `DAU_APPICON` chọn (D25) thành `Assets.car`, gồm các kiểu Mặc định, Tối, Trong suốt và Phủ màu, cùng `AppIcon.icns` hoặc `AppIconDev.icns` làm bản dự phòng cho macOS 14–15 (`actool` tự sinh). Để xem kết quả mà không mở Icon Composer, chạy `scripts/assets/preview-app-icon.sh`.
- Mỗi file `.icon` có bốn lớp: nền, chữ "a", dấu mũ và dấu sắc. Màu nền là màu nền của file. Kiểu Tối dùng màu thứ hai. Bản phát triển có thêm lớp dải Hổ phách, kiểu Tối cũng dùng màu thứ hai. Hai kiểu Trong suốt và Phủ màu do macOS dẫn ra từ các lớp. Chữ "a" là đường nét chuyển từ Be Vietnam Pro Bold (700), theo ghi chú ở đầu script; logo chữ thì dùng ExtraBold (mục "Logo chữ").
- Bản sao phẳng cho README và web là `Resources/Brand/AppIcon.svg` và `AppIconDev.svg`, do cùng script sinh ra.
- Ảnh xem trước GitHub là `Resources/Brand/github-preview.png`, cỡ 1280 × 640, xuất từ artboard bằng `scripts/assets/export-github-preview.sh`. Script không dùng bản chụp trong `docs/canvas/`, vì canvas đặt `@import` phông sau các luật CSS khác nên bản chụp dùng phông thay thế chứ không phải Be Vietnam Pro. Ảnh tải lên ở Settings › Social preview của repo.
- Ảnh template thanh menu hiện là bản tạm `Apps/DauInputMethod/Resources/ModeVietnamese.tiff`, sinh bằng `scripts/assets/make-mode-icons.sh`.
- Nền cửa sổ DMG gồm `Resources/Brand/DmgBackground.png` (640 × 400) và `DmgBackground@2x.png` (1280 × 800). `scripts/assets/make-dmg-background.sh` vẽ hai ảnh này theo artboard "Cửa sổ ảnh đĩa DMG". Ảnh chỉ có màu Giấy và một mũi tên Mực mờ, không có biểu tượng và không có chữ, vì Finder tự vẽ những thứ đó. Cỡ cửa sổ, cỡ biểu tượng và toạ độ hai biểu tượng ghi ở đầu script. `scripts/release/build-release.sh` ghép hai ảnh thành một file TIFF nhiều độ phân giải bằng `tiffutil -cathidpicheck`, nên repo không giữ file TIFF.
- Favicon, `apple-touch-icon.png` và ảnh Open Graph chưa được xuất; chúng đi cùng website (M8).

## Mockup

Các artboard "Nhận diện – …", "Ảnh chia sẻ Open Graph" và "Ảnh xem trước GitHub" nằm trên canvas. Link canvas và bản chụp trong repo ghi ở [`docs/UI.md`](UI.md) và [`docs/canvas/README.md`](canvas/README.md):

- [hướng biểu tượng](canvas/BrandConcepts.png)
- [hướng dẫn thương hiệu](canvas/BrandGuide.png)
- [biểu tượng ứng dụng](canvas/AppIcon.png)
- [nơi hình đại diện xuất hiện](canvas/BrandInUse.png)
- [biểu tượng trong hệ thống](canvas/MenuBarIcons.png)
- [biểu tượng bản phát triển](canvas/AppIconDev.png)
- [ảnh chia sẻ Open Graph](canvas/OgImage.png)
- [ảnh xem trước GitHub](canvas/GithubPreview.png)

## Biểu tượng
- Biểu tượng là chữ "ấ" màu Giấy trên nền Mực. Dấu mũ cùng màu với chữ, **riêng dấu sắc màu Son**, nên biểu tượng tự kể tên sản phẩm.
- Biểu tượng dựng bằng Icon Composer của Apple. Một file nguồn cho đủ các kiểu Mặc định, Tối, Trong suốt và Phủ màu trên macOS 26 trở lên. File `.icns` cho macOS 14–15 do `actool` sinh từ cùng file đó; file này chỉ có các cỡ 16, 32, 128 và 256 pt, cỡ lớn hơn do hệ thống phóng to.
- Chữ "a" trong biểu tượng là đường nét (outline) trong file nguồn, nên không phụ thuộc phông khi render.
- Nét dấu dùng một bộ nét cho mọi cỡ (chốt 17/11/2026). File `.icon` không có bản nét dày riêng cho cỡ 16–32 pt, còn làm dày nét chung thì đổi cả biểu tượng ở cỡ lớn. Khi xem bằng mắt (`scripts/assets/preview-app-icon.sh`), ở 32 pt biểu tượng đọc ra "ấ"; ở 16 pt dấu mũ và dấu sắc chỉ còn vài điểm ảnh, nhưng chữ vẫn đọc là chữ "a" có dấu.
- macOS tự vẽ viền mảnh quanh biểu tượng ở các kiểu Tối, Trong suốt và Phủ màu, nên file không thêm viền riêng.

## Biểu tượng bản phát triển
- Bản nào dùng biểu tượng này ghi ở D25; các loại bản ghi ở D7 (Cập nhật và loại bản dựng).
- Chữ "ấ" giữ nguyên như biểu tượng chuẩn (màu Giấy, dấu sắc màu Son), đặt trên nền **Chì**.
- Một dải chéo màu **Hổ phách** cắt góc dưới bên phải và nằm ngoài chữ "a".
- Ở kiểu Tối, nền và dải tối hơn một bậc.
- Ở kiểu Trong suốt và Phủ màu, macOS bỏ màu. Dải còn lại như một hình sáng hơn nền.
- Mockup nằm ở artboard [biểu tượng bản phát triển](canvas/AppIconDev.png).
- Khi xem bằng mắt ảnh xuất từ file `.icon` (`scripts/assets/preview-app-icon.sh`), dải vẫn nhận ra ở 16 pt và ở mọi kiểu; ở Trong suốt và Phủ màu, dải là một hình sáng hơn nền. Artboard chỉ mô phỏng hai kiểu Trong suốt và Phủ màu.

## Biểu tượng thanh menu (input mode)
- Biểu tượng là một ảnh template đơn sắc: một ô bo tròn tô đặc, chữ "V" khoét rỗng.
  - Ô có cùng kiểu và cùng cỡ với ô "A" của U.S.: ô 22 × 16 pt, góc bo 4 pt, chữ 9 × 8,5 pt căn giữa. Số đo lấy trên thanh menu Retina ngày 30/10/2026 (`scripts/assets/MakeModeIcons.swift`).
  - macOS tự tô màu ảnh theo nền.
- Cách khai ảnh template trong Info.plist ghi ở [`docs/Architecture.md`](Architecture.md), mục "Bundle: biểu tượng, ký, entitlements".
- Ô chỉ báo vẽ chính ảnh này bằng màu trắng.
  - Chỉ nguồn của Apple mới hiện chữ trần như chữ "A" của U.S., vì macOS dùng bảng nhãn dựng sẵn cho nguồn của Apple và không đọc `TISIconLabels` của bộ gõ ngoài.
- Biểu tượng không dùng màu thương hiệu (D9 (Giao diện)).
- Dấu chỉ có một input mode (D2 (Chuyển Việt/Anh)). Khi người dùng gõ tiếng Anh bằng ABC hay U.S., biểu tượng trên thanh menu là của hệ thống.

## Logo chữ
- Logo chữ viết "Dấu" bằng Be Vietnam Pro ExtraBold, **một màu**. Logo không tách dấu sắc ra tô màu riêng, vì chỉ lệch một chút là đọc thành "Dâu".
- Không bao giờ viết "Dau" hay "dau" trước người dùng (D24).

## Màu
| Tên | Mã | Dùng cho |
|---|---|---|
| Mực | `#10285A` (Tối: `#0B0F1A`) | Màu nền biểu tượng, nền ảnh chia sẻ và màu nhấn trên website. |
| Son | `#E0533D` | Màu này chỉ dùng cho dấu sắc trong biểu tượng, không dùng cho nút, chữ hay nền. |
| Giấy | `#F6F1E7` | Màu chữ trên nền Mực và màu nền website. |
| Than | `#1D1D1F` | Màu chữ chính. |
| Chì | `#2C2F35` (Tối: `#1A1B1F`) | Màu này chỉ dùng cho nền biểu tượng bản phát triển. |
| Hổ phách | `#F2B705` (Tối: `#D9A400`) | Màu này chỉ dùng cho dải góc của biểu tượng bản phát triển, không dùng cho nút, chữ hay nền. |

App dùng màu và phông của hệ thống (D9). Bảng màu này dành cho biểu tượng, website, ảnh chia sẻ và tài liệu.

## Chữ
- Logo, website và ảnh chia sẻ dùng phông Be Vietnam Pro (giấy phép OFL).
- Ngoài giao diện app, không dùng SF Pro. Giấy phép phông San Francisco của Apple chỉ cho dùng phông này để làm mockup giao diện cho phần mềm chạy trên hệ điều hành của Apple ([Apple Fonts](https://developer.apple.com/fonts/), phần giấy phép trên trang).

## File cần xuất
| File | Kích thước | Dùng ở |
|---|---|---|
| Biểu tượng app: `Apps/Dau/Resources/AppIcon.icon` (`.icns` do `actool` sinh khi build) | 16–1024 pt | Finder, Dock, Launchpad, Spotlight, onboarding, hộp thoại |
| Biểu tượng bản phát triển: `Apps/Dau/Resources/AppIconDev.icon` (cũng sinh `.icns`) | 16–1024 pt | Như dòng trên, ở mọi bản không phải bản phát hành (D25) |
| Ảnh template thanh menu V | 22×16 pt @1x/@2x (TIFF; PDF vector khi có bản phát hành) | Menu nguồn đầu vào |
| `favicon.ico` + `favicon.svg` | 16, 32 | Tab trình duyệt, kết quả tìm kiếm |
| `apple-touch-icon.png` | 180×180 | Ghim trang trên iPhone, iPad |
| `og-image.png` | 1200×630 | `og:image`, `twitter:image` cho link chia sẻ trên Zalo, Messenger, Slack, iMessage, X |
| GitHub social preview: `Resources/Brand/github-preview.png` | 1280×640 | Settings › Social preview của repo |
| Nền DMG: `Resources/Brand/DmgBackground.png`, `DmgBackground@2x.png` | 640×400 và 1280×800 | File DMG phát hành |

## Thẻ cho website
Website dùng các thẻ `<title>Dấu – Bộ gõ tiếng Việt cho macOS</title>`, `meta description`, `og:title`, `og:description`, `og:image`, `og:locale=vi_VN` và `twitter:card=summary_large_image`. Mô tả và tiêu đề không chứa lời hứa chưa kiểm chứng (N5 (Chỉ hứa điều đã kiểm chứng)).
