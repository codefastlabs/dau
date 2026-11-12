# Nhận diện thương hiệu

Biểu tượng, logo chữ, màu, phông và các file nhận diện cần xuất cho app, bộ gõ, website và ảnh chia sẻ. Quyết định gốc: D24 (Tên và định danh) cho tên, D25 (Nhận diện) cho nhận diện; tài liệu này chỉ ghi chi tiết.

## Hiện trạng

- Biểu tượng app và biểu tượng bản phát triển hiện là bản tạm, sinh bằng `scripts/assets/make-app-icon.swift` (qua `scripts/assets/make-app-icon.sh`) từ hình học của artboard: SVG trong `Resources/Brand/`, PNG trong `Apps/Dau/Resources/Assets.xcassets`. Bản thật dựng bằng Icon Composer ở M7 (Phát hành).
- Chữ "a" của bản tạm dùng Be Vietnam Pro Bold (700), theo đầu script; logo chữ dùng ExtraBold (mục "Logo chữ").
- Ảnh template thanh menu: bản tạm `Apps/DauInputMethod/Resources/ModeVietnamese.tiff`, sinh bằng `scripts/assets/make-mode-icons.swift`.
- Chưa xuất: `.icns` và file Icon Composer, favicon, `apple-touch-icon.png`, ảnh Open Graph, ảnh xem trước GitHub, nền DMG (bảng "File cần xuất").

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
- Bản thật dựng bằng Icon Composer của Apple (một file nguồn, đủ các kiểu Mặc định / Tối / Trong suốt / Phủ màu trên macOS 26+); xuất thêm `.icns` cho macOS 14–15.
- Chữ "a" trong biểu tượng phải chuyển thành đường nét (outline) trong file nguồn, không phụ thuộc phông khi render.
- Ở 16–32 pt tăng độ dày nét dấu để vẫn đọc ra "ấ"; kiểm tra bằng mắt ở từng cỡ.
- Trên nền tối hoặc nền Mực: thêm viền mảnh màu Giấy ~35% để tách biểu tượng khỏi nền.

## Biểu tượng bản phát triển
- Bản nào dùng biểu tượng này: D25 (các loại bản ở D7 (Cập nhật và loại bản dựng)).
- Chữ "ấ" giữ nguyên như biểu tượng chuẩn (Giấy, dấu sắc Son), trên nền **Chì**.
- Một dải chéo màu **Hổ phách** cắt góc dưới phải, nằm ngoài chữ "a".
- Kiểu Tối: nền và dải tối hơn một bậc.
- Kiểu Trong suốt và Phủ màu: macOS bỏ màu, dải còn lại như một hình sáng hơn nền.
- Mockup: artboard [biểu tượng bản phát triển](canvas/AppIconDev.png).
- Kiểm bằng mắt ở 16–32 pt và ở kiểu Trong suốt, Phủ màu khi xuất từ Icon Composer (artboard chỉ mô phỏng hai kiểu này).

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
| Mực | `#10285A` | nền biểu tượng, nền ảnh chia sẻ, màu nhấn trên website |
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
| Biểu tượng app (Icon Composer + `.icns`) | 16–1024 pt | Finder, Dock, Launchpad, Spotlight, onboarding, hộp thoại |
| Biểu tượng bản phát triển (Icon Composer + `.icns`) | 16–1024 pt | như trên, ở mọi bản không phải bản chính thức (D25) |
| Ảnh template thanh menu V | 22×16 pt @1x/@2x (TIFF; PDF vector khi có bản chính thức) | menu nguồn đầu vào |
| `favicon.ico` + `favicon.svg` | 16, 32 | tab trình duyệt, kết quả tìm kiếm |
| `apple-touch-icon.png` | 180×180 | ghim trang trên iPhone/iPad |
| `og-image.png` | 1200×630 | `og:image`, `twitter:image` — link chia sẻ Zalo, Messenger, Slack, iMessage, X |
| GitHub social preview | 1280×640 | Settings › Social preview của repo |
| Ảnh nền DMG | theo cửa sổ cài đặt | file DMG phát hành |

## Thẻ cho website
`<title>Dấu – Bộ gõ tiếng Việt cho macOS</title>`, `meta description`, `og:title`, `og:description`, `og:image`, `og:locale=vi_VN`, `twitter:card=summary_large_image`. Mô tả và tiêu đề không chứa lời hứa chưa kiểm chứng (N5 (Chỉ hứa điều đã kiểm chứng)).
