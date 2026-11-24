# Công nghệ cho trang web (M8)

Tài liệu này ghi cách dựng trang web của Dấu bằng TanStack Start bản React: trang tĩnh, hai ngôn ngữ, triển khai trên Vercel. Nội dung trang nằm ở [`docs/Website.md`](../Website.md), nhận diện ở [`docs/Brand.md`](../Brand.md), mốc và tiêu chí xong ở [`docs/Roadmap.md`](../Roadmap.md) mục M8.

Mỗi khẳng định ghi rõ nguồn của nó: **đo** (điều kiện ở mục "Điều kiện đo"), **tài liệu** hay **mã nguồn** (URL ở mục "Nguồn") hoặc **suy luận** (ghi rõ tại chỗ).

## Hiện trạng (24/11/2026)

**Kết luận.**

- TanStack Start bản React dựng trang tải về thành HTML tĩnh. Trang thử đầy đủ có thẻ mô tả, favicon, màu đã sửa tương phản, nút tải nhận ra máy không phải Mac và chính sách CSP. Trang này đạt 100 ở cả bốn hạng mục Lighthouse, cả trên điện thoại lẫn máy tính (đo, mục 1).
- Phần JS tối thiểu của một trang React hydrate là phần chạy của React (66,6 KB gzip) cộng router của TanStack (30,2 KB gzip). Tuỳ chọn cấu hình của router và Vite không giảm được phần này (đo).
- Trang hydrate cả trang theo mặc định, không dùng Deferred Hydration (`Hydrate`). `Hydrate` chỉ bớt 6,1 KB JS khi hiệu năng đã là 100. API này còn thử nghiệm và có lỗi mở làm mất HTML dựng sẵn (mục 1).
- `site/dist/` phải nằm trong `.gitignore`. Tailwind tự dò nguồn và chỉ bỏ qua những gì git bỏ qua (mục 4).
- Nhánh `main` không có branch protection (`gh api repos/codefastlabs/dau/branches/main` trả `protected: false`). Bước "Công bố" của quy trình phát hành đẩy thẳng lên `main`. Vì vậy CI không chặn được một commit hỏng trước khi nó tới `main`. Lớp chặn thật là Vercel giữ bản triển khai cũ khi build hỏng (mục 3).

**Đề xuất.**

| # | Phần | Đề xuất |
|---|---|---|
| 1 | JS | Hydrate cả trang theo mặc định của TanStack Start, không dùng API thử nghiệm. |
| 2 | Hai ngôn ngữ | Bản tiếng Việt ở `/`, bản tiếng Anh ở `/en`. Route `/{-$locale}/` với `trailingSlash: 'never'` và `autoSubfolderIndex: false`. `x-default` trỏ về `/en`. Chuỗi lưu trong từ điển TypeScript có kiểu. Mã mục (`#features`, `#download`…) bằng tiếng Anh và giống nhau ở hai bản. |
| 3 | Vercel | `vercel.json` với `framework: null`, đầu ra `dist/client`, `cleanUrls`, `trailingSlash: false`, header bảo mật và header không cache lâu cho `appcast.xml`. Bảo vệ bằng bốn lớp: Vercel giữ bản cũ khi build hỏng, Deployment Checks nếu gói tài khoản có, hook `pre-push` build trang trên máy và bước so byte appcast sau mỗi lần triển khai. |
| 4 | Tailwind, phông | Khai báo mọi màu của artboard thành token trong `@theme`. Thêm `site/dist/` vào `.gitignore`. Tự phục vụ Be Vietnam Pro, giữ đủ năm độ đậm của artboard và cắt phông theo mọi chữ của trang trước khi build. |
| 5 | Công cụ, CI | Workflow `site.yml` trên `ubuntu-latest`: kiểm kiểu, oxlint, oxfmt, build, kiểm đầu ra, Lighthouse CI. Ghim Node và pnpm trong `package.json`. Cập nhật phụ thuộc bằng Dependabot. |
| 6 | Tương tác nhỏ | Viết bằng React. Nhận ra máy không phải Mac bằng `userAgentData` hoặc bằng chuỗi User-Agent kèm `maxTouchPoints`. Đổi ngôn ngữ bằng liên kết thường. |
| 7 | Rủi ro | Ghim phiên bản chính xác, gộp cập nhật hằng tuần, tự kiểm đầu ra build và so appcast trên tên miền với `origin/main`. |
| 8 | Repo, dữ liệu | Trang nằm trong repo của Dấu, ở `site/`. Mọi số và lời hứa trên trang đọc lúc build từ file dữ liệu trong repo. Ô chưa có nguồn giữ dạng `[…]`. |

**Việc cần tài khoản của người dùng.** Toàn bộ nằm trong bước nối project Vercel ([`docs/Releasing.md`](../Releasing.md) bước "Vercel"):

1. Đặt Root Directory là `site` và giữ bật "Include files outside the root directory in the Build Step" (mặc định bật).
2. Thêm biến môi trường `ENABLE_EXPERIMENTAL_COREPACK=1` để Vercel dùng đúng bản pnpm ghi trong `packageManager`.
3. Xem gói tài khoản có Deployment Checks không. Nếu có, chọn job của `site.yml` làm check bắt buộc.

**Việc của phiên chính trước khi viết mã.** Đây là thay đổi tài liệu và canvas, không cần quyết định của người dùng:

1. Theo [`Apps/Dau/CLAUDE.md`](../../Apps/Dau/CLAUDE.md), canvas làm trước, mã làm sau.
   - Sửa màu tiêu đề "Ghi chú" của cửa sổ minh hoạ trong hero. Chữ `#6e6e73` trên nền `#F3F1EC` chỉ đạt 4,49:1, dưới ngưỡng 4,5:1. Trang thử dùng `#5c5c63` và đạt Trợ năng 100.
   - Thêm vào artboard mục Quyền riêng tư dòng nói trang web không đo người đọc ([`docs/Website.md`](../Website.md) mục 6).
   - Vẽ artboard tiếng Anh cho trang tải về và cho ảnh Open Graph (`og-image-en.png`), rồi thêm file đó vào danh sách xuất của [`docs/Brand.md`](../Brand.md).
2. Trong commit đầu tiên có mã của `site/`, sửa [`docs/Releasing.md`](../Releasing.md):
   - Bước "Vercel" hiện ghi "không có bước build"; bước đó phải đổi theo mục 3 và nhóm việc cần tài khoản ở trên.
   - Bước chạy bài tải nặng hiện ghi số đo vào nhật ký [`docs/Progress.md`](../Progress.md) để trang lấy từ đó; bước này phải ghi vào file dữ liệu ở mục 8.
   - Bước "Công bố" commit thêm file checksum.
   - Thêm bước so byte appcast sau triển khai.
3. Trong cùng commit đó, sửa dòng `site/` trong [`docs/Architecture.md`](../Architecture.md).
4. Thêm `.githooks/pre-push` và bước kiểm `core.hooksPath` vào `scripts/dev/doctor.sh` khi dựng `site/` (mục 3).

## Điều kiện đo

Mọi số đo lấy trên máy M3 Max chạy macOS 27.2.1, ngày 24/11/2026.

- **Phần mềm.** Node 26.1.0, pnpm 12.21.0, `@tanstack/react-start` 1.169.7, `@tanstack/react-router` 1.170.46, React 19.3.1, Vite 8.3.8 (rolldown), Tailwind 4.3.5 (qua `@tailwindcss/vite`), TypeScript 7.0.2, `@fontsource/be-vietnam-pro` 5.3.0, oxlint 1.95.0 và oxfmt 0.80.0.
- **Trang đo.** Trang đo là phần thân của artboard [`docs/canvas/src/Landing.dc.html`](../canvas/src/Landing.dc.html) dựng lại bằng React (683 phần tử), kèm CSS của artboard. Suy luận: trang thật có lượng DOM và chữ gần như vậy, vì nó dựng theo cùng artboard.
- **Bản dựng.** `pnpm build` với `tanstackStart({ prerender: { enabled: true, crawlLinks: true, failOnError: true } })`, không dùng Nitro.
- **Lighthouse.** Một server tĩnh trên localhost phục vụ thư mục `dist/client` và nén brotli như một CDN. Lighthouse 13.6.0 chạy bằng CLI với Chrome 158 headless. Cấu hình mặc định giả lập điện thoại Android (mạng chậm, CPU chậm 4 lần); `--preset=desktop` giả lập máy tính với chuỗi User-Agent của Mac. Mỗi biến thể chạy 3 lần, bảng ghi trung vị. Cột "JS" là số byte JS tải về (brotli).
- **CPU chậm 10 lần.** `benchmarkIndex` của máy là 3900, gần gấp đôi máy để bàn mạnh trong bảng của Lighthouse. Theo bảng đó, muốn giả lập điện thoại tầm trung từ máy này thì nhân CPU chậm khoảng 10 lần. Các biến thể chính chạy thêm một lượt với `--throttling.cpuSlowdownMultiplier=10`.
- **Hành vi lúc chạy.** Một đoạn script chèn vào bản sao của HTML rồi mở bằng Chrome headless. Đoạn đó ghi các mục LCP, việc nút DOM của `<h1>` bị thay, lỗi console, vi phạm CSP, trạng thái nhận máy của nút tải và việc chữ còn đủ hay không.
- **Lighthouse CI trên `ubuntu-latest` chưa đo.** Máy chạy của GitHub chậm hơn máy đo. Ngưỡng ở mục 5 vì vậy kèm cả ngưỡng LCP, TBT và CLS ngoài điểm số.

## 1. JS và kết quả Lighthouse

### Trang thử đầy đủ

Trang thử gồm nội dung artboard, thẻ mô tả, thẻ Open Graph, favicon SVG, màu đã sửa tương phản và nút tải thật (mục 6). Server phục vụ trang với các header bảo mật và chính sách CSP của mục 3.

| Trạng thái | Hiệu năng | Trợ năng | Thực hành tốt | SEO | LCP | TBT | CLS | JS (KB, brotli) |
|---|---|---|---|---|---|---|---|---|
| Điện thoại, máy không phải Mac | 100 | 100 | 100 | 100 | 0,86 s | 0 ms | 0 | 103,5 |
| Máy tính, máy Mac | 100 | 100 | 100 | 100 | 0,31 s | 0 ms | 0,032 | 103,5 |

- **Trạng thái của nút tải (đo).** Lighthouse giả lập điện thoại với chuỗi User-Agent Android. Ảnh chụp cuối của Lighthouse cho thấy nút ở thanh điều hướng và hero là "Sao chép liên kết" (3/3 lượt). Với `--preset=desktop`, chuỗi User-Agent là Mac và nút giữ "Tải về".
- **CLS 0 ở trạng thái không phải Mac (đo).** Nút đổi chữ sau khi hydrate nhưng giữ cùng khung, nên không gây dịch chuyển. Câu cảnh báo trong mục tải về chèn thêm sau khi hydrate, nhưng mục đó nằm ngoài màn hình lúc tải.
- **CLS 0,032 ở máy tính (đo).** Lighthouse ghi dịch chuyển ở mục "Vì sao có Dấu" với nguyên nhân "Web font loaded" (3/3 lượt). Phông thay phông dự phòng (`font-display: swap`) làm khối chữ đổi chiều cao. Con số dưới ngưỡng 0,1 và không làm điểm hiệu năng giảm. Trên điện thoại, dịch chuyển này nằm ngoài màn hình lúc tải.
- **Phông** tải về 170,6 KB với bộ phông đầy đủ của Fontsource. Mục 4 giảm phần này.

### Thành phần gói

Bản dựng tải hai file JS. Chunk lõi `index-*.js` nặng 341,1 KB (110,2 KB gzip). Chunk route chứa nội dung trang nặng 78,5 KB (12,1 KB gzip). Chia theo gói bằng sourcemap:

| Gói | KB gzip |
|---|---|
| `react-dom` (bản production) | 62,1 |
| Nội dung trang | 12,0 |
| `@tanstack/router-core` | 20,1 |
| `seroval` và `seroval-plugins` | 8,8 |
| `@tanstack/react-router` | 6,2 |
| `react` | 3,0 |
| `@tanstack/start-client-core` | 2,4 |
| `@tanstack/history`, `@tanstack/store`, `use-sync-external-store` | 3,9 |
| `scheduler` | 1,5 |
| Mã của trang (`src/`) | 0,9 |

Mỗi gói nén riêng, nên tổng hơi lớn hơn số gzip của cả chunk.

- **React.** `react-dom`, `react` và `scheduler` cộng lại là 66,6 KB gzip. Mọi trang React hydrate đều cần phần này.
- **Router.** `router-core`, `react-router`, `history`, `store` và `use-sync-external-store` cộng lại là 30,2 KB gzip. `RouterProvider` cần phần này để hydrate trang của TanStack Start.
- **Start.** `seroval`, `seroval-plugins` và `start-client-core` cộng lại là 11,2 KB gzip. Mã `hydrateStart.ts` luôn gắn `ServerFunctionSerializationAdapter` vào router, kể cả khi trang không có server function. Không có tuỳ chọn tắt bước này.
- **Cấu hình.** Rolldown đã tree-shake phần router không dùng và đã minify. Tắt `scrollRestoration`, đổi `build.target` hay đổi trình minify không đổi kích thước (đo).

Trang hydrate cả trang (chưa có nút tải thật) đạt hiệu năng 100 với LCP 0,86 s khi CPU chậm 4 lần. Khi CPU chậm 10 lần, trang vẫn đạt 100 với TBT 61 ms (đo).

### Phương án không dùng

- **Deferred Hydration** (`<Hydrate when={never()}>` bọc các mục không tương tác). Trình biên dịch của Start tách mỗi vùng `Hydrate` thành một chunk mà trình duyệt không bao giờ tải. JS giảm còn 96,3 KB, LCP 0,78 s, hiệu năng vẫn 100 (đo). Phương án này không dùng vì phần được nhỏ, còn phần mất là độ đúng của trang:
  - Tài liệu ghi "Deferred hydration is experimental".
  - Mã `hydration/never.tsx` lấy bản chép `innerHTML` làm fallback của `Suspense`. Ngay sau khi hydrate, nút DOM của vùng bị thay bằng nút mới. Khi phần tử LCP nằm trong vùng đó, LCP giả lập lên 2,7–2,9 s (đo).
  - Issue #8778 (mở): vùng `Hydrate` mất HTML dựng sẵn khi một context phía trên đổi giá trị trước khi cổng mở.
  - Issue #8668 (mở): `<Hydrate when={never()}>` không hiện gì khi gắn sau một lần điều hướng phía client.
- **React Server Components** (`tanstackStart({ rsc: { enabled: true } })`, tài liệu ghi là thử nghiệm). JS chỉ bớt 1,9 KB (100,5 so với 102,4 KB). HTML tăng 14 KB gzip (từ 12,1 lên 26,1 KB) vì chứa payload Flight. LCP là 0,93 s (đo).

## 2. Hai ngôn ngữ

### Đường dẫn và ngôn ngữ mặc định

- **Bản tiếng Việt ở `/`, bản tiếng Anh ở `/en`.** Route đặt ở `src/routes/{-$locale}/index.tsx` theo hướng dẫn i18n của TanStack Router, khớp cả `/` lẫn `/en`. `beforeLoad` ném `notFound()` khi tham số khác `en`.
- **Prerender cả hai trang.** Trang `/` có liên kết tới `/en`, nên `crawlLinks` tự tìm ra trang tiếng Anh. Đầu ra gồm `dist/client/index.html` và `dist/client/en.html` (đo).
- **Không gạch chéo cuối.** `trailingSlash: 'never'` trong `createRouter` cho liên kết, đường dẫn prerender, `canonical` và sitemap cùng là `/en`. `prerender.autoSubfolderIndex: false` ghi trang thành `en.html` thay vì `en/index.html`. Prerender dò thẳng `/en`, không qua chuyển hướng nào (đo).
- **`<html lang>`.** `shellComponent` của route gốc đọc tham số bằng `useParams({ strict: false })`. Trang `/` có `lang="vi"`, trang `/en` có `lang="en"` (đo).
- **`x-default` trỏ về `/en`.** D41 (Ngôn ngữ giao diện) cho Dấu dùng tiếng Anh khi không có ngôn ngữ nào khớp. Google dùng `x-default` cho người đọc có ngôn ngữ không khớp bản nào.
- **Không tự chuyển theo ngôn ngữ trình duyệt.** Trang tĩnh không có server lúc chạy.
- **App mở trang theo ngôn ngữ của app.** Mọi liên kết từ app tới trang chọn `/` khi `Bundle.main.preferredLocalizations.first` là `vi` và chọn `/en` trong mọi trường hợp khác (D41). Ví dụ, nút "Ủng hộ…" của D39 (Ủng hộ dự án) mở `/#contribute` hoặc `/en#contribute`.

### Mã mục

Mã mục viết bằng tiếng Anh và giống nhau ở hai bản, để liên kết từ app và từ tài liệu dùng chung một mã: `#why`, `#features`, `#typing-table`, `#privacy`, `#measured`, `#faq`, `#download`, `#contribute`. Theo issue #8516 (mở), liên kết dạng `/#section` bị prerender dò như một trang riêng. Liên kết trong trang vì vậy viết `#section`, còn liên kết từ app viết đường dẫn đầy đủ và không đi qua prerender.

### Thẻ trong `<head>`

Một hàm dùng chung (`localizedHead(path, locale, messages)`, file `src/i18n/head.ts`) dựng mọi thẻ phụ thuộc đường dẫn. Bản tiếng Việt của `path` là chính `path`. Bản tiếng Anh là `/en` cộng `path`, trừ trang chủ là `/en`. Nhờ vậy, trang so sánh của M10 (`/compare` và `/en/compare`, đường dẫn tiếng Anh ở cả hai bản) dùng lại cùng hàm.

- `canonical` trỏ về chính trang. `alternate` có `hreflang` cho `vi`, `en` và `x-default`. Hai bản trỏ qua lại nhau, đúng yêu cầu của Google là mỗi bản liệt kê chính nó và mọi bản khác.
- Open Graph gồm `og:site_name` là "Dấu" (D24 (Tên và định danh)), `og:locale` (`vi_VN` hoặc `en_US`), `og:locale:alternate` (bản còn lại), `og:url` (bằng `canonical`), `og:title`, `og:description` và `og:image`.
- Ảnh Open Graph hiện có chữ tiếng Việt (artboard `docs/canvas/src/OgImage.dc.html`: "Bộ gõ tiếng Việt cho macOS"). Bản `/en` dùng ảnh riêng `og-image-en.png` vẽ từ một artboard tiếng Anh, bản `/` giữ `og-image.png`.

### Sitemap và `robots.txt`

- Tuỳ chọn `sitemap: { enabled: true, host: 'https://dau.codefastlabs.com' }` sinh `dist/client/sitemap.xml` gồm `/` và `/en` (đo). Google coi `hreflang` trong thẻ `<link>`, trong header HTTP và trong sitemap là ba cách tương đương, nên thẻ trong `<head>` là đủ.
- Bước kiểm đầu ra xoá `<lastmod>` khỏi sitemap. Start đặt `lastmod` bằng ngày build cho mọi trang (mã `build-sitemap.js`). Google chỉ dùng `lastmod` khi nó đúng và kiểm được, nên ngày build sai còn tệ hơn không có.
- Plugin còn ghi `pages.json` vào `dist/client`; bước kiểm đầu ra xoá file này.
- `public/robots.txt` cho phép mọi trang và có dòng `Sitemap: https://dau.codefastlabs.com/sitemap.xml`.

### Lưu chuỗi

Chuỗi lưu trong hai file `vi.ts` và `en.ts`. `vi.ts` xuất đối tượng `vi` và kiểu `Messages` dẫn từ khoá của nó. `en.ts` viết `export const en = { … } satisfies Messages`.

- Khi bản tiếng Anh thiếu một khoá, `tsc --noEmit` báo `TS2741`. Khi thừa một khoá, `tsc` báo `TS2353` (đo).
- Từ điển không bắt được chuỗi rỗng. Một test nhỏ kiểm mọi giá trị khác rỗng.
- Hai file đặt cạnh nhau và cùng thứ tự khoá, để người duyệt bản dịch đọc song song.

Paraglide JS 3.2.2, dựng theo ví dụ `start-i18n-paraglide` của TanStack, không dùng vì ba lý do đo được:

- JS nặng hơn 7,6 KB (brotli), trong đó `urlpattern-polyfill` chiếm 5,8 KB gzip.
- Khi bản tiếng Anh thiếu một câu, build vẫn đạt. Trang tiếng Anh hiện câu tiếng Việt mà không có cảnh báo nào.
- Lúc build, Paraglide tải module plugin từ `cdn.jsdelivr.net`.

### Liên kết đổi ngôn ngữ và trang 404

- Liên kết đổi ngôn ngữ là thẻ `<a>` thường. Thẻ có `hreflang` và `lang` của bản đích (ví dụ `<a href="/en" hreflang="en" lang="en">English</a>`). Trình đọc màn hình nhờ vậy đọc đúng giọng.
- Trang 404 hiện cả hai ngôn ngữ. Trang tĩnh không biết người đọc muốn bản nào. Mỗi khối có `lang` riêng và liên kết về trang chủ của ngôn ngữ đó. Route gốc dùng cùng thành phần `NotFound` làm `notFoundComponent`.
- Đo: HTML dựng sẵn của `404.html` và DOM sau khi hydrate ở `/abc/xyz` giống nhau từng ký tự (3/3 lượt).

## 3. Vercel với đầu ra tĩnh

Phần cấu hình đọc từ tài liệu Vercel. Content-Type của `.xml`, cách `cleanUrls` phục vụ `/en`, chuyển hướng 308 và các header bảo mật cần kiểm ở lần triển khai đầu, vì project chưa có bản triển khai nào.

### Cấu hình

`site/vercel.json`, với Root Directory của project là `site`:

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "framework": null,
  "installCommand": "pnpm install --frozen-lockfile",
  "buildCommand": "pnpm build",
  "outputDirectory": "dist/client",
  "trailingSlash": false,
  "cleanUrls": true,
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" },
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "Content-Security-Policy", "value": "frame-ancestors 'none'; object-src 'none'; base-uri 'none'; form-action 'none'" }
      ]
    },
    {
      "source": "/appcast.xml",
      "headers": [{ "key": "Cache-Control", "value": "public, max-age=0, must-revalidate" }]
    },
    {
      "source": "/assets/(.*)",
      "headers": [{ "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }]
    }
  ]
}
```

- **`framework: null`** chọn preset "Other" (tài liệu `vercel.json`). Vercel chạy `buildCommand` rồi phục vụ thư mục đầu ra như file tĩnh.
- **Không dùng Nitro.** Trang "TanStack Start on Vercel" tả cách triển khai bằng Nitro. Preset `vercel` của Nitro dựng Vercel Functions để render khi có request, nhưng trang của Dấu không render lúc chạy.
  - Nitro 3 còn có preset `vercel-static`. Đo với `nitro@3.0.261103-rc`: bản dựng ra thẳng Build Output API của Vercel, `appcast.xml` giống từng byte.
  - Prerender của TanStack Start không chạy cùng preset này. Start dò trang qua server xem trước, mà preset tĩnh không có server đó, nên build dừng với lỗi `Failed to fetch` (đo). Prerender của Nitro phải làm thay. Khi đó trang mất sitemap của Start.
  - Trên npm, nhãn `latest` của Nitro là bản RC; Nitro 3 chưa có bản ổn định.
  - Preset `vercel` của Nitro còn hỏng khi prerender (issue #6562, mở).
- **`cleanUrls: true`** phục vụ `en.html` ở `/en` và chuyển `/en.html` sang `/en`. **`trailingSlash: false`** chuyển `/en/` sang `/en` bằng mã 308. Đường dẫn có phần mở rộng như `/appcast.xml` không bị đổi (tài liệu `vercel.json`).
- **Trang 404.** Vercel tự dùng file `404.html` trong đầu ra (tài liệu "Custom 404 pages"). TanStack Start không prerender được một đường dẫn trả về 404. Trang lỗi vì vậy là một route thường `/not-found` (file `src/routes/not-found.tsx`), khai trong `pages` với `prerender: { enabled: true, outputPath: '/404.html' }` và `sitemap: { exclude: true }`. Đo: đầu ra chỉ có `404.html`, không có `not-found.html`. Sitemap không có `/not-found`. Route này có `robots: noindex`.
- **Header của `appcast.xml`.** Phản hồi của Vercel ở tên miền hiện có `cache-control: public, max-age=0, must-revalidate` (đo trên phản hồi 404). Tài liệu CDN của Vercel ghi rằng mỗi bản triển khai mới có cache mới. Header vẫn khai rõ trong `vercel.json`, vì Sparkle cần luôn đọc bản mới. Ghi trong repo thì một thay đổi mặc định của Vercel không đổi được hành vi đó. Bước so byte sau triển khai cũng kiểm header này.
- **Appcast giống từng byte.** Appcast giữ ở `site/appcast.xml`, nơi ba script phát hành đọc. Script `build` chép nó vào `dist/client/` (đo bằng `cmp`).
- **Không có Vercel Web Analytics hay Speed Insights.** Trang không gọi bên thứ ba và không thu số liệu người đọc, theo tinh thần D8 (Không telemetry). Câu nói trang web không thu số liệu người đọc chưa có trong mục Quyền riêng tư của [`docs/Website.md`](../Website.md); thêm câu đó là việc của phiên chính (mục "Hiện trạng").

### Chính sách bảo mật nội dung (CSP)

HTML do TanStack Start dựng có ba thẻ `<script>` nội tuyến: khôi phục vị trí cuộn, dữ liệu hydrate `$_TSR` và lời gọi khởi động (đo). Nội dung của chúng đổi theo từng bản dựng vì có tên file đã băm. `vercel.json` là file tĩnh, nên không chứa được mã băm của từng bản dựng.

Chính sách chia làm hai phần:

- **Header trong `vercel.json`** chứa những gì không phụ thuộc bản dựng: `frame-ancestors 'none'; object-src 'none'; base-uri 'none'; form-action 'none'`. Header không chứa `default-src` hay `script-src`; nếu có, header sẽ chặn các script nội tuyến mà thẻ `<meta>` cho phép.
- **Thẻ `<meta http-equiv="Content-Security-Policy">`** do bước kiểm đầu ra chèn vào đầu `<head>` của mỗi file HTML, kèm mã băm `sha256` của từng script nội tuyến trong file đó: `default-src 'self'; script-src 'self' 'sha256-…'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self'; manifest-src 'self'`. `style-src` cần `'unsafe-inline'`, vì React viết thuộc tính `style` thành style nội tuyến.

Đo trên trang thử đầy đủ, phục vụ với header ở trên:

- Có mã băm: không có vi phạm CSP nào, trang hydrate xong, nút tải nhận đúng máy, chữ còn đủ (3/3 lượt). Lighthouse đạt 100 ở cả bốn hạng mục.
- Đối chứng, bỏ mã băm: trình duyệt chặn cả ba script (`script-src-elem`) và trang không hydrate.

### Khi build hỏng

- Theo tài liệu Vercel, chỉ build thành công mới thành bản triển khai và lên tên miền chính. Build hỏng thì tên miền giữ bản cũ, kể cả appcast cũ.
- Appcast đi chung đường build với trang. Khi build của trang hỏng, commit chép appcast mới lên `main` không xuất bản được. Việc gỡ một mục appcast khi bản cập nhật hỏng ([`docs/Releasing.md`](../Releasing.md), dòng "Bản cập nhật không cài được") cũng bị chặn.
- Một route ném lỗi trong `loader` làm `pnpm build` thoát mã 1, nhưng `dist/client` vẫn giữ các trang đã dựng trước lỗi (đo). Issue #8120 (mở) báo một đường mà trang lỗi bị bỏ qua và build vẫn thoát mã 0. Vì vậy trang không chỉ dựa vào mã thoát.

### Cách bảo vệ

`main` không có branch protection. Bước "Công bố" đẩy thẳng lên `main`. Workflow `site.yml` chạy sau khi commit đã ở `main`, nên nó báo lỗi chứ không chặn được lỗi. Bốn lớp dưới đây là những gì thật sự chặn hay phát hiện lỗi:

1. **Vercel giữ bản cũ khi build hỏng.** Đây là lớp chặn có sẵn. Script `build` kết thúc bằng bước kiểm đầu ra (`tools/verifyOutput.ts`). Bước này làm build hỏng khi đầu ra sai, nên Vercel không đưa bản sai lên. Bước này kiểm:
   - `dist/client/appcast.xml` giống từng byte `site/appcast.xml`.
   - Đầu ra có đủ `index.html`, `en.html`, `404.html`, `sitemap.xml` và `robots.txt`.
   - Mọi `href` và `src` nội bộ trong HTML trỏ tới file có thật.
   - Mọi ký tự hiện ra trong HTML nằm trong tập ký tự của phông đã cắt (mục 4).
   - Mỗi HTML có thẻ CSP với mã băm khớp mọi script nội tuyến của nó.
2. **Deployment Checks của Vercel**, nếu gói tài khoản có. Vercel giữ bản triển khai mới khỏi tên miền chính cho tới khi job của `site.yml` đạt (tài liệu "Deployment Checks"). Lớp này chặn được cả lỗi mà build không thấy, như Lighthouse dưới ngưỡng. Đây là việc cần tài khoản của người dùng (mục "Hiện trạng").
3. **Hook `pre-push` trên máy.** File `.githooks/pre-push` (zsh, đề xuất, chưa có) chạy `pnpm --dir site build` khi các commit sắp đẩy có chạm `site/`. Bước build đã gồm bước kiểm đầu ra. Hook bật một lần cho mỗi bản clone bằng `git config core.hooksPath .githooks`. `scripts/dev/doctor.sh` sẽ kiểm việc bật này (việc của phiên chính). Bước "Công bố" đẩy từ máy, nên hook chạy cả ở bước đó.
4. **So byte appcast sau mỗi lần triển khai**, không chỉ sau khi công bố. Một script (đề xuất, chưa có) tải `https://dau.codefastlabs.com/appcast.xml`, so byte với `site/appcast.xml` của đúng commit đã triển khai và kiểm header `Cache-Control`. Trong `site.yml`, job này chạy theo sự kiện `deployment_status` của GitHub, chỉ khi `github.event.deployment.environment == 'Production'` và `github.event.deployment_status.state == 'success'`. Job so với file tại `github.event.deployment.sha`. Như vậy bản xem trước của nhánh khác và khoảng thời gian commit mới chưa triển khai xong không làm job báo lỗi oan. Ở bước "Công bố", script chạy sau khi Vercel báo triển khai xong và so với `origin/main`. Script có tác dụng phụ mạng.

## 4. Tailwind v4, màu và phông

### Token màu

Khai báo trong `@theme` của `src/styles.css`, mở đầu bằng `--color-*: initial;` để chỉ còn token của trang. Mọi màu artboard dùng đều có token. Màu nào không thuộc bảng màu của [`docs/Brand.md`](../Brand.md) thì vẫn có tên, để một màu lạ trong mã là lỗi build chứ không là một mã hex rời.

| Token | Giá trị | Dùng ở artboard |
|---|---|---|
| `paper`, `ink`, `charcoal`, `vermilion` | Giá trị của Giấy, Mực, Than, Son trong `docs/Brand.md` | Nền, màu nhấn, chữ chính, dấu sắc của logo |
| `ink-soft` | `#1B3A78` | Nhãn nhỏ của mục |
| `ink-pale` | `#AFC2E8` | Chữ phụ trên nền Mực |
| `white` | `#FFFFFF` | Thẻ, cửa sổ minh hoạ |
| `black` | `#000000` | Viền và bóng (dùng với độ mờ, ví dụ `border-black/7`) |
| `mist` | `#F3F1EC` | Nền xen kẽ của mục |
| `linen` | `#F8F6F1` | Nền ô trong thẻ |
| `slate` | `#4A4A52` | Chữ phụ |
| `graphite`, `iron`, `smoke` | `#5A5A60`, `#3A3A40`, `#3A3A3C` | Chữ trong mô hình minh hoạ |
| `muted` | `#5C5C63` | Chữ phụ nhỏ (đã sửa từ `#6e6e73` để đạt 4,5:1 trên `mist`) |
| `switch-off` | `#C7C7CC` | Công tắc tắt trong mô hình |
| `window-close`, `window-minimize`, `window-zoom` | `#FF5F57`, `#FEBC2E`, `#28C840` | Ba chấm cửa sổ macOS trong mô hình |
| `error`, `accent-purple`, `accent-green`, `accent-blue` | `#B42318`, `#5B3FA8`, `#3C8A4A`, `#2F6FDE` | Chi tiết trong mô hình minh hoạ |

Màu `rgba` của artboard là các màu trên cộng độ mờ, viết bằng hậu tố của Tailwind (ví dụ `bg-ink/8`, `text-paper/85`). Biến `--color-*` sinh các tiện ích `bg-paper`, `text-ink`…; biến `--font-*` sinh `font-*` (tài liệu Tailwind "Theme variables").

### `.gitignore` và CSS

CSS nhập bằng `?url` như hướng dẫn Tailwind của TanStack Start, với `site/dist/` trong `.gitignore` ở gốc repo.

- Khi tự dò nguồn, Tailwind quét mọi file trong project, trừ những gì `.gitignore` bỏ qua (tài liệu Tailwind).
- TanStack Start build client (ghi `dist/client/`) trước rồi mới build server.
- Nếu `dist/` không bị bỏ qua, lần build server quét cả JS đã minify trong `dist/client/` và sinh ra CSS có băm khác. HTML khi đó trỏ tới một file CSS không có trong đầu ra (đo).
- Đối chứng: khi `.gitignore` ở gốc repo có `site/dist/` hoặc CSS có `@source not '../dist'` thì HTML trỏ đúng. `source('../')`, cách nêu trong issue #7658, không đủ (đo).

### Phông

Gói `@fontsource/be-vietnam-pro` có giấy phép OFL-1.1, khớp [`docs/Brand.md`](../Brand.md). Be Vietnam Pro không có bản phông biến thiên (metadata Fontsource ghi `"variable": false`). Mỗi độ đậm chia thành các tập con theo `unicode-range`. Tập `vietnamese` chỉ chứa chữ có dấu dựng sẵn, nên chữ tiếng Việt cần cả tập `latin` lẫn tập `vietnamese`. Artboard dùng đủ năm độ đậm (400 đến 800), nên trang giữ đủ năm.

| Phông | Tải về | LCP | CLS | Hiệu năng |
|---|---|---|---|---|
| Năm độ đậm, tập con đầy đủ của Fontsource | 168,5 KB | 0,86 s | 0 | 100 |
| Năm độ đậm, cắt theo ký tự của trang | 105,4 KB | 0,87 s | 0 | 100 |
| Năm độ đậm, cắt, preload hai file độ đậm 800 của `<h1>` | 105,4 KB | 0,87 s | 0 | 100 |
| Ba độ đậm (400, 700, 800), tập con đầy đủ | 101,0 KB | 0,86 s | 0 | 100 |

Số đo trong bảng dùng cấu hình điện thoại. CLS bằng 0 là số đo, không phải hệ quả tất yếu của `font-display: swap`: trên máy tính, phông thay vào vẫn gây CLS 0,032 (mục 1).

**Cắt phông.**

- Script `tools/subsetFonts.ts` chạy trước `vite build` trong script `build` (`"build": "node tools/subsetFonts.ts && vite build && node tools/verifyOutput.ts"`).
- Script dùng gói `subset-font` (giấy phép BSD-3-Clause, dùng HarfBuzz) cắt từng file woff2 của Fontsource, giữ `unicode-range`. File ra ghi vào `site/src/fonts/`, kèm `site/src/fonts/fonts.css` và danh sách ký tự đã giữ (`site/src/fonts/charset.txt`).
- Vite băm tên file theo nội dung, nên khi tập ký tự đổi thì tên file đổi và cache cũ không dùng nhầm.
- `site/src/fonts/` nằm trong `.gitignore`. File trong đó sinh lại ở mỗi lần build từ gói Fontsource đã ghim, nên không có bản commit nào để lệch với nội dung.
- Đầu vào gồm mọi nguồn chữ của trang: `src/i18n/vi.ts`, `src/i18n/en.ts`, các file dữ liệu ở mục 8, chữ trong `src/models/` và toàn bộ ASCII in được.
- Bước kiểm đầu ra so mọi ký tự trong phần chữ của HTML đầu ra với `charset.txt`. Một ký tự nằm ngoài tập là lỗi build, nên chữ thêm từ một nguồn mới không thể hiện bằng phông dự phòng mà không ai biết.

Preload không đổi LCP (đo), nên không thêm. Vite đặt file phông vào `dist/client/assets/` cùng tên miền, nên trang không gọi bên thứ ba.

## 5. Công cụ và CI

- **Workflow `site.yml`** chạy trên `ubuntu-latest` cho mọi pull request và mọi lần đẩy có chạm `site/**` hay chính file workflow. Action ghim bằng SHA và quyền chỉ là `contents: read`, như `test.yml`.
  1. `pnpm/action-setup` không đặt `version`, để dùng bản ghi ở `packageManager`. `actions/setup-node` dùng `node-version-file: site/package.json`, đọc `engines.node`.
  2. `pnpm install --frozen-lockfile`.
  3. `pnpm typecheck` (`tsc --noEmit`).
  4. `pnpm lint` (`oxlint --deny-warnings`) và `pnpm format:check` (`oxfmt --check`).
  5. `pnpm build`, gồm cắt phông và bước kiểm đầu ra.
  6. Lighthouse CI (`@lhci/cli`) với `collect.staticDistDir: './dist/client'` và `collect.url` gồm `/` và `/en.html` (server tĩnh của LHCI phục vụ theo tên file), `numberOfRuns: 3`.
     - Phần `assert` đặt bốn hạng mục ở mức `["error", {"minScore": 0.95}]` với `aggregationMethod: "median"`.
     - Phần `assert` thêm ngưỡng số liệu: `largest-contentful-paint` tối đa 2500 ms, `total-blocking-time` tối đa 200 ms, `cumulative-layout-shift` tối đa 0,1. Điểm số trên máy chạy chung có thể dao động, còn ngưỡng số liệu cho biết chỉ số nào hỏng.
     - `upload.target` là `filesystem`, rồi tải kết quả lên làm artifact. Đích `temporary-public-storage` đẩy báo cáo lên kho công khai, nên không dùng.
  7. Job so byte appcast sau triển khai (mục 3), chạy theo `deployment_status`.
- **`test.yml` không thêm `paths-ignore`.** `check-release-gate.sh` đòi workflow Test đạt trên đúng commit mang tag. Nếu Test bỏ qua commit chỉ đổi `site/`, một tag đặt lên commit đó không có kết quả Test nào và bản phát hành bị từ chối.
- **Ghim Node và pnpm.** `package.json` có `"engines": { "node": "26.x" }` và `"packageManager": "pnpm@12.21.0"`.
  - Vercel: theo tài liệu Vercel, `engines.node` ghi đè phiên bản Node của project; Node 26.x có sẵn. Vercel hỗ trợ pnpm 12. Muốn Vercel dùng đúng bản trong `packageManager` thì phải bật Corepack bằng biến `ENABLE_EXPERIMENTAL_COREPACK=1`; nếu không, Vercel chọn bản pnpm theo `lockfileVersion` (bản thử ghi `9.0`).
  - GitHub Actions: `actions/setup-node` đọc `engines.node` qua `node-version-file`, còn `pnpm/action-setup` đọc `packageManager` khi không có `version`.
- **Lint: oxlint 1.95.0.** Cấu hình `.oxlintrc.json` bật plugin `react`, `typescript` và `jsx-a11y`. File này có `ignorePatterns: ["src/routeTree.gen.ts"]`. `--deny-warnings` biến cảnh báo thành lỗi (đo: một `<img>` thiếu `alt` làm lệnh thoát mã 1).
- **Format: oxfmt 0.80.0.** Cấu hình `.oxfmtrc.json` có `ignorePatterns: ["src/routeTree.gen.ts"]` và `sortTailwindcss: { "stylesheet": "./src/styles.css" }`.
  - Đo: `stylesheet` cho oxfmt đọc token trong `@theme`, nên `text-ink zzz-unknown p-4 bg-paper flex mt-2` thành `zzz-unknown mt-2 flex bg-paper p-4 text-ink`. Khi không có `stylesheet`, oxfmt coi `bg-paper` và `text-ink` là class lạ và để chúng ở đầu.
  - oxfmt còn dưới 1.0, nên phiên bản ghim chính xác và cập nhật qua Dependabot như các gói khác.
- **Cập nhật phụ thuộc: Dependabot.** Theo tài liệu GitHub, Dependabot hỗ trợ pnpm từ bản 7 tới bản 12. File `.github/dependabot.yml` có hai mục:
  - `npm` cho `/site`, chạy hằng tuần, gộp `@tanstack/*` một nhóm và Vite với Tailwind một nhóm, vì các gói TanStack phụ thuộc lẫn nhau theo phiên bản chính xác.
  - `github-actions` cho `/`.
- **Phiên bản chính xác.** `package.json` ghim phiên bản chính xác, vì TanStack Start ra bản thường xuyên (mục 7) và các gói `@tanstack/start-*` đi theo cặp.
- **`.gitignore`.** Thêm `site/node_modules/`, `site/dist/`, `site/src/fonts/`, `site/.tanstack/`, `site/.lighthouseci/` và `site/.vercel/`. Commit `src/routeTree.gen.ts`, theo FAQ của TanStack Router.
- **Tên file.** Thành phần React đặt tên PascalCase, mỗi file một thành phần cùng tên (`DownloadButton.tsx`). Tài liệu TanStack không đặt luật riêng cho việc này. Route giữ quy ước file route của TanStack Router (`__root.tsx`, `{-$locale}/index.tsx`, `not-found.tsx`). Module không phải thành phần đặt tên camelCase (`head.ts`, `subsetFonts.ts`).

## 6. Tương tác nhỏ

Ba tương tác viết thành thành phần React.

- **Nhận ra máy không phải Mac.**
  - Theo dữ liệu tương thích của MDN, `navigator.userAgentData` có từ Chrome 90 (`platform` từ Chrome 93) và các trình duyệt nhân Chromium. Firefox và Safari không có API này.
  - Safari trên iPad mặc định ở chế độ máy tính. Khi đó chuỗi User-Agent giống Safari trên macOS (blog WebKit, Safari 13). Mã WebKit (`WebPageProxyIOS.mm`) đặt `navigator.platform` là `"MacIntel"`.
  - Mã WebKit (`Navigator::maxTouchPoints`) trả về 5 trên thiết bị cảm ứng iOS và 0 trên Mac, nên `maxTouchPoints > 1` tách được iPad ra.
  - Thứ tự kiểm: nếu có `userAgentData` thì dùng `platform === 'macOS'`. Nếu không có, máy là Mac khi chuỗi User-Agent có `Macintosh` và `maxTouchPoints < 2`.
  - HTML dựng sẵn luôn ở trạng thái "máy Mac", vì đó là trạng thái của người tải thật. Nút ở hai trạng thái giữ cùng khung (đo: CLS 0 ở trạng thái không phải Mac, mục 1).
  - Trang chỉ đọc các giá trị này trên máy người đọc, không gửi đi và không lưu lại.
- **Nút sao chép.** Dùng `navigator.clipboard.writeText` (MDN: "Baseline: Widely available" từ tháng 3/2020, chỉ chạy trong secure context). Nút bắt lỗi `NotAllowedError` để không hỏng. Một vùng `aria-live="polite"` báo "Đã sao chép liên kết" cho trình đọc màn hình.
- **Đổi ngôn ngữ.** Dùng liên kết thường (mục 2). Liên kết này cũng là cách `crawlLinks` tìm ra trang tiếng Anh lúc prerender.
- **`<details>`** là HTML thuần, không cần JS.

## 7. Rủi ro lâu dài

- **Nhịp phát hành.** `@tanstack/react-start` ra 20 bản trong 13 tuần tính tới 24/11/2026, khoảng 1,5 bản mỗi tuần. Nhịp này chậm hơn đầu năm 2026: tháng 1 có 69 bản, tháng 10 có 6 bản. Phiên bản chính vẫn là 1.x.
- **Thay đổi không tương thích gần đây.** Bản phát hành gộp ngày 12/10/2026 bỏ API `inputValidator` đã lỗi thời. Trang tĩnh không dùng server function nên không bị ảnh hưởng.
- **Mức chín.** Trang tài liệu Static Prerendering không có cảnh báo thử nghiệm. Deferred Hydration (`Hydrate`), `inlineCss` và Server Components ghi là thử nghiệm.
- **Issue còn mở ngày 24/11/2026 chạm tới trang của Dấu:**
  - #8120: có đường mà trang lỗi vẫn để build thoát mã 0.
  - #8516: liên kết dạng `/#section` bị dò như trang riêng và lọt vào sitemap. Trang của Dấu dùng `#section` (mục 2).
- **Chuỗi cung ứng.** Một gói npm chạy lúc build có thể sửa `dist/client/appcast.xml` (bảng ở mục 8).
- **Cách giảm rủi ro.**
  - Ghim phiên bản chính xác.
  - Gộp bản cập nhật hằng tuần qua Dependabot. Mỗi pull request chạy `site.yml` gồm Lighthouse CI và kiểm đầu ra.
  - Chỉ dùng tính năng không ghi là thử nghiệm.
  - So appcast trên tên miền với `origin/main` sau mỗi lần triển khai.

## 8. Repo, cấu trúc thư mục và dữ liệu

Trang nằm trong repo của Dấu, ở thư mục `site/`, không tách repo riêng. Thư mục `site/` làm gốc project Vercel đã chốt ngày 17/11/2026 cho appcast ([`docs/Roadmap.md`](../Roadmap.md) mục M8).

**Ràng buộc cố định.** App đọc feed ở `https://dau.codefastlabs.com/appcast.xml`. Địa chỉ này ghi trong `project.yml` (`DAU_SPARKLE_FEED_URL`) và đi vào `Info.plist` của mọi bản đã phát hành, nên không đổi được. Project Vercel nào giữ tên miền thì phải phục vụ appcast.

| Tiêu chí | Chung repo, `site/` | Repo riêng cho trang |
|---|---|---|
| Appcast | Bước công bố commit `site/appcast.xml` lên `main`. `check-appcast.sh` và `promote-release.sh` đọc `origin/main:site/appcast.xml`. Không đổi gì. | Appcast phải nằm ở repo của trang. Mỗi bản phát hành commit vào hai repo. Ba script phát hành phải đọc repo kia. Cách khác là cho Vercel chuyển `/appcast.xml` sang file trên GitHub, nên feed phụ thuộc thêm một máy chủ. |
| Dữ liệu dùng chung | Trang đọc lúc build đúng file mà app và test dùng (mục "Dữ liệu lúc build"). Một commit sửa cả nguồn lẫn trang. Theo tài liệu Vercel, bản dựng mặc định đọc được file ngoài Root Directory. | Phải chép dữ liệu sang, dùng submodule hay tải từ repo kia lúc build. Hai bản có thể lệch mà không CI nào báo. |
| Canvas | Artboard (`docs/canvas/`), nội dung (`docs/Website.md`) và mã nằm trong cùng một diff, đúng luật "canvas trước, mã sau". | Artboard và mã ở hai repo. |
| Bản dựng thừa | Vercel có "Ignored Build Step" để chỉ dựng khi một thư mục đổi. `site.yml` lọc theo `site/**`. | Không có. |
| Khoá ký và bí mật | Phụ thuộc npm chỉ chạy trong `site.yml` (quyền `contents: read`, không dùng bí mật) và trên máy build của Vercel. `release.yml` dùng khoá ký nhưng không cài gì từ npm. Workflow do pull request của Dependabot kích hoạt không nhận Actions secrets (tài liệu GitHub). | Tách hẳn phụ thuộc npm khỏi repo giữ khoá ký. |
| Chuỗi cung ứng của appcast | Một gói npm chạy lúc build trên Vercel có thể sửa `dist/client/appcast.xml` và cả bước kiểm byte chạy cùng bản dựng đó. Feed không ký: `SURequireSignedFeed` không có trong `project.yml` hay `Info.plist`. `docs/Releasing.md` cũng ghi Dấu không đặt khoá này. Sparkle vẫn kiểm chữ ký EdDSA của từng DMG, nên feed bị sửa không cài được một DMG lạ. Feed bị sửa vẫn có thể bớt mục hay đổi thông tin của mục (suy luận từ tài liệu Sparkle về `SURequireSignedFeed`). Biện pháp: bước so byte sau triển khai (mục 3) chạy ngoài máy build của Vercel và so với `origin/main`. | Rủi ro như bên trái, vì appcast vẫn đi qua bản dựng có npm. |
| Nhịp thay đổi | Pull request cập nhật npm của Dependabot nằm chung danh sách với mã Swift. | Tách riêng. |
| CI macOS và số build | Mỗi lần đẩy lên `main` chạy workflow Test trên runner macOS, 3–6 phút (sáu lần chạy gần nhất ngày 24/11/2026), kể cả commit chỉ đổi `site/` hay tài liệu. `test.yml` không lọc được đường dẫn vì `check-release-gate.sh` đòi Test đạt trên commit mang tag. Số build bằng mười lần số commit ([`docs/Releasing.md`](../Releasing.md), đoạn "Số build"), nên commit của trang làm số build tăng; số build chỉ cần tăng dần nên điều này không hỏng gì. | Commit của trang không chạy Test macOS và không đổi số build. |

**Kết luận.** Repo riêng chỉ được hai điều. Thứ nhất, phụ thuộc npm không nằm cạnh khoá ký. Thứ hai, pull request cập nhật npm không lẫn với mã Swift. Điều thứ nhất đã có biện pháp: không job nào vừa cài npm vừa đọc bí mật. Đổi lại, repo riêng làm vỡ quy trình appcast đang chạy và tách dữ liệu mà D39 bắt dùng chung. Vì vậy trang nằm trong repo của Dấu. `release.yml` không cài phụ thuộc của `site/`. Mọi workflow chạm `site/` không dùng bí mật.

### Dữ liệu lúc build

Mọi ô số liệu và lời hứa trên trang ([`docs/Website.md`](../Website.md)) đọc lúc build từ một file trong repo. Ô nào chưa có dữ liệu thì giữ dạng `[…]`, theo N5 (Chỉ hứa điều đã kiểm chứng). Bước kiểm đầu ra liệt kê mọi ô còn `[…]` trong log build, để thấy trang đang chờ dữ liệu gì.

| Ô trên trang | Nguồn | Ai ghi, khi nào |
|---|---|---|
| Phiên bản, ngày phát hành, dung lượng, địa chỉ tải DMG | Mục đã chọn trong `site/appcast.xml`: `sparkle:shortVersionString` và tiêu đề, `pubDate`, `length` và `url` của `enclosure` | Bước "Công bố" (đã có) |
| SHA-256 của DMG | `site/src/data/checksums.json`, khoá là `sparkle:version` của mục | `build-release.sh` ghi file này thành tài sản của bản nháp. Bước "Công bố" commit nó cùng `appcast.xml`. Appcast không có SHA-256, chỉ có chữ ký EdDSA. |
| Lệnh Homebrew và nút "Sao chép" của nó | `site/src/data/distribution.json`, trường `homebrewCask` (mặc định `false`) | Commit đổi sang `true` khi cask có thật trong `codefastlabs/homebrew-tap` (D6 (Phát hành)) |
| Số ca test engine | `site/src/data/measurements.json`, trường `engineTests` (số ca, commit, ngày) | Bước chạy bài tải nặng của quy trình phát hành |
| p99 thời gian xử lý một phím có thay chữ, bộ nhớ RSS | `site/src/data/measurements.json`, trường `heavyLoad` (p99 ms, RSS MB, ngưỡng 20 ms và 96 MB, bản dựng, máy, phiên bản macOS, ngày, commit), theo D42 (Ngưỡng hiệu năng) | Bước chạy bài tải nặng ghi file này thay cho nhật ký `docs/Progress.md` |
| Số ứng dụng đã đo, danh sách ứng dụng đã kiểm chứng gõ đúng, ứng dụng mang nhãn "Đề xuất" | `Apps/Dau/Resources/CompatibilityList.json`, file app đọc qua `CompatibilityList.bundled()` | Phiên đo tương thích. Trang cần thêm các trường file chưa có: mọi ứng dụng đã đo (file hiện chỉ có 15 ứng dụng cần ghi chú), cờ gõ đúng tại chỗ và phiên bản macOS đã đo. `init(from:)` của `CompatibilityList` chỉ đọc theo các khoá nó khai báo, nên thêm trường không đổi hành vi của app (đọc mã). |
| Tên người ủng hộ | `Apps/Dau/Resources/Supporters.json` (đề xuất, chưa có; D39 chưa đặt tên file), một file cho app, trang và ghi chú phát hành theo D39 | Người duy trì, khi người ủng hộ đồng ý |
| Tiền ủng hộ đã dùng vào việc gì | `site/src/data/expenses.json` (ngày, khoản chi, số tiền), chỉ ghi khoản đã chi (D39) | Người duy trì, khi đã chi |
| Ví dụ chữ trong mô hình minh hoạ | `site/src/data/typing-examples.json` (chuỗi phím, kiểu gõ, chữ mong đợi) | Người viết trang. Một test engine mới (`WebsiteExamplesTests`) đọc cùng file này và kiểm engine gõ ra đúng chữ đó, như `ExternalCasesTests` đọc file trong `docs/research/`. Ví dụ trên trang và engine không thể lệch nhau. |

**Luật chọn mục appcast** (D6, D7 (Cập nhật và loại bản dựng)):

- Mục có `<sparkle:channel>beta</sparkle:channel>` là bản beta. Mục không có thẻ kênh là bản chính thức.
- Nếu appcast có ít nhất một bản chính thức, trang dùng bản chính thức có `sparkle:version` lớn nhất. Nếu chưa có, trang dùng bản beta có `sparkle:version` lớn nhất.
- Nếu appcast chưa có mục nào, mọi ô của mục tải về giữ `[…]`. Nút tải trỏ tới trang Releases của GitHub.

Cấu trúc thư mục:

```
site/
├─ appcast.xml              # feed Sparkle, bước công bố ghi; build chép nguyên byte vào dist/client/
├─ package.json             # engines.node, packageManager, phiên bản ghim chính xác; pnpm-lock.yaml đi kèm
├─ vite.config.ts           # tanstackStart (prerender, pages, sitemap), tailwindcss, viteReact
├─ vercel.json              # mục 3
├─ tsconfig.json
├─ .oxlintrc.json  .oxfmtrc.json
├─ lighthouserc.json        # mục 5
├─ public/                  # chép nguyên vào đầu ra: favicon, ảnh Open Graph, robots.txt
├─ tools/                   # bước build viết bằng TypeScript, chạy bằng Node
│  ├─ subsetFonts.ts        # cắt phông theo mọi nguồn chữ, chạy trước vite build (mục 4)
│  └─ verifyOutput.ts       # kiểm đầu ra, chèn CSP, xoá lastmod và pages.json (mục 3)
└─ src/
   ├─ router.tsx            # createRouter, trailingSlash: 'never'
   ├─ routeTree.gen.ts      # plugin sinh, có commit
   ├─ styles.css            # @import 'tailwindcss', @theme, nạp fonts/fonts.css
   ├─ fonts/                # phông đã cắt, sinh lúc build, nằm trong .gitignore
   ├─ data/                 # checksums.json, distribution.json, measurements.json, expenses.json, typing-examples.json
   ├─ i18n/
   │  ├─ vi.ts              # bản gốc, định nghĩa kiểu Messages
   │  ├─ en.ts              # satisfies Messages
   │  ├─ locale.ts          # 'vi' | 'en' từ tham số đường dẫn
   │  └─ head.ts            # localizedHead: canonical, alternate, Open Graph theo đường dẫn
   ├─ routes/
   │  ├─ __root.tsx         # <html lang>, head chung, nạp CSS, notFoundComponent
   │  ├─ {-$locale}/index.tsx   # trang tải về: / và /en
   │  └─ not-found.tsx      # dựng thành 404.html, hai ngôn ngữ
   ├─ sections/             # các mục của trang tải về, mỗi mục một file, theo thứ tự ở docs/Website.md
   ├─ models/               # mô hình minh hoạ, hoạt ảnh CSS (docs/Website.md)
   └─ components/           # DownloadButton.tsx, CopyButton.tsx, LanguageLink.tsx, NotFound.tsx
```

- Bước build bằng TypeScript nằm ở `site/tools/`, không ở `scripts/`. `scripts/` của repo là script zsh (`scripts/README.md`), còn các bước này chạy trong chuỗi `pnpm build`. Thư mục không đặt tên `build/`, vì `.gitignore` của repo bỏ qua mọi thư mục tên `build/`.
- Trang so sánh của M10 thêm một route `src/routes/{-$locale}/compare.tsx`, dùng lại `localizedHead`, `models/` và `i18n/`.

## Nguồn

- TanStack Start, Static Prerendering: https://tanstack.com/start/latest/docs/framework/react/guide/static-prerendering
- TanStack Start, Deferred Hydration: https://tanstack.com/start/latest/docs/framework/react/guide/deferred-hydration
- TanStack Start, Server Components: https://tanstack.com/start/latest/docs/framework/react/guide/server-components
- TanStack Start, Tailwind integration: https://tanstack.com/start/latest/docs/framework/react/guide/tailwind-integration
- TanStack Router, Internationalization (i18n): https://tanstack.com/router/latest/docs/guide/internationalization-i18n
- TanStack Router, FAQ: https://tanstack.com/router/latest/docs/framework/react/faq
- Ví dụ `start-i18n-paraglide`: https://github.com/TanStack/router/tree/main/examples/react/start-i18n-paraglide
- TanStack/router issue #6562: https://github.com/TanStack/router/issues/6562
- TanStack/router issue #7658: https://github.com/TanStack/router/issues/7658
- TanStack/router issue #8120: https://github.com/TanStack/router/issues/8120
- TanStack/router issue #8516: https://github.com/TanStack/router/issues/8516
- TanStack/router issue #8668: https://github.com/TanStack/router/issues/8668
- TanStack/router issue #8778: https://github.com/TanStack/router/issues/8778
- TanStack/router, bản phát hành 12/10/2026: https://github.com/TanStack/router/releases/tag/release-2026-10-12-2321
- Tailwind CSS, Detecting classes in source files: https://tailwindcss.com/docs/detecting-classes-in-source-files
- Tailwind CSS, Theme variables: https://tailwindcss.com/docs/theme
- Fontsource, metadata của Be Vietnam Pro: https://api.fontsource.org/v1/fonts/be-vietnam-pro
- `subset-font`: https://www.npmjs.com/package/subset-font
- Vercel, cấu hình `vercel.json`: https://vercel.com/docs/project-configuration/vercel-json
- Vercel, Configuring a Build (Root Directory, Corepack): https://vercel.com/docs/builds/configure-a-build
- Vercel, Package Managers: https://vercel.com/docs/package-managers
- Vercel, Supported Node.js versions: https://vercel.com/docs/functions/runtimes/node-js/node-js-versions
- Vercel, TanStack Start on Vercel: https://vercel.com/docs/frameworks/full-stack/tanstack-start
- Vercel, Deploying to Vercel: https://vercel.com/docs/deployments
- Vercel, Deployment Checks: https://vercel.com/docs/deployment-checks
- Vercel, CDN Cache: https://vercel.com/docs/caching/cdn-cache
- Vercel, Custom 404 pages: https://vercel.com/docs/routing/custom-404-pages
- Vercel, Project settings (Ignored Build Step): https://vercel.com/docs/project-configuration/project-settings
- Vercel, Monorepos: https://vercel.com/docs/monorepos
- Google Search Central, Localized versions of your pages: https://developers.google.com/search/docs/specialty/international/localized-versions
- Google Search Central, Build and submit a sitemap: https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap
- Sparkle, Customizing Sparkle (`SURequireSignedFeed`): https://sparkle-project.org/documentation/customization/
- Lighthouse, Throttling: https://github.com/GoogleChrome/lighthouse/blob/main/docs/throttling.md
- Lighthouse CI, Configuration: https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/configuration.md
- GitHub, Dependabot supported ecosystems: https://docs.github.com/en/code-security/dependabot/ecosystems-supported-by-dependabot/supported-ecosystems-and-repositories
- GitHub, Troubleshooting Dependabot on GitHub Actions: https://docs.github.com/en/code-security/dependabot/troubleshooting-dependabot/troubleshooting-dependabot-on-github-actions
- `actions/setup-node`, Advanced usage: https://github.com/actions/setup-node/blob/main/docs/advanced-usage.md
- `pnpm/action-setup`: https://github.com/pnpm/action-setup
- MDN browser-compat-data, `NavigatorUAData`: https://github.com/mdn/browser-compat-data/blob/main/api/NavigatorUAData.json
- MDN, `Clipboard.writeText()`: https://developer.mozilla.org/en-US/docs/Web/API/Clipboard/writeText
- WebKit, New WebKit Features in Safari 13: https://webkit.org/blog/9674/new-webkit-features-in-safari-13/
- WebKit, `WebPageProxyIOS.mm`: https://github.com/WebKit/WebKit/blob/main/Source/WebKit/UIProcess/ios/WebPageProxyIOS.mm
- WebKit, `Navigator.cpp`: https://github.com/WebKit/WebKit/blob/main/Source/WebCore/page/Navigator.cpp
