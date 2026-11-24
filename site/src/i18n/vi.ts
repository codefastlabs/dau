// Vietnamese strings, the source dictionary. en.ts mirrors every key in the same order.
// Text comes from the approved artboards (docs/canvas/src/Landing*.dc.html). Strings in
// square brackets are slots without verified data yet (N5).

export const vi = {
  head: {
    title: "Dấu – Bộ gõ tiếng Việt cho macOS",
    description:
      "Dấu thay chữ ngay tại chỗ bạn gõ: không gạch chân, không phím xoá giả. Gõ Telex hay VNI như bạn vẫn quen. Miễn phí, mã nguồn mở.",
    ogLocale: "vi_VN",
    ogImage: "/og-image.png",
    ogImageAlt: "Dấu – Bộ gõ tiếng Việt cho macOS",
  },
  nav: {
    label: "Chính",
    features: "Tính năng",
    typingTable: "Bảng gõ",
    faq: "Hỏi đáp",
    github: "GitHub",
    otherLanguage: "English",
    download: "Tải về",
  },
  copyLink: {
    label: "Sao chép liên kết",
    copied: "Đã sao chép liên kết",
    macOnly: "Dấu chỉ chạy trên Mac. Mở lại trang này trên máy Mac để tải về.",
  },
  hero: {
    eyebrow: "Bộ gõ tiếng Việt cho macOS",
    eyebrowSuffix: " · Mã nguồn mở",
    title: "Gõ tiếng Việt trên Mac, tự nhiên như vốn có.",
    subtitle:
      "Dấu thay chữ ngay tại chỗ bạn gõ: không gạch chân, không phím xoá giả. Gõ Telex hay VNI như bạn vẫn quen.",
    download: "Tải về",
    source: "Xem mã nguồn",
    requirements:
      "Miễn phí · macOS 14 trở lên, đã kiểm trên macOS 15 và macOS 27 · Apple silicon và Intel",
    windowTitle: "Ghi chú",
    lastKey: "Phím vừa gõ",
    illustration: "Minh hoạ: gõ {keys1} ra {text1}, rồi gõ {keys2} ra {text2}",
  },
  why: {
    eyebrow: "Vì sao có Dấu",
    title: "Ba cách gõ tiếng Việt trên Mac.",
    lead: "Cùng bốn phím h, o, a, f, ba loại bộ gõ đưa chữ vào ứng dụng theo ba cách khác nhau. Hình dưới chỉ tả cách làm của từng loại. Dấu chỉ đo chính mình, nên chỉ cột của Dấu có số đo khi máy bận.",
    builtInTitle: "Bộ gõ có sẵn của macOS: gạch chân",
    builtInCaption:
      "Bộ gõ gạch chân từ đang gõ cho tới khi bạn gõ dấu cách, rồi mới chốt chữ vào ứng dụng.",
    simulatedTitle: "Bộ gõ giả lập phím: xoá rồi gõ lại",
    simulatedFakeDelete: "⌫ giả",
    simulatedRetype: "gõ lại",
    simulatedCaption:
      "Bộ gõ chặn phím f, gửi phím ⌫ giả để xoá chữ cũ, rồi gõ lại chữ mới bằng phím giả. Ứng dụng nhận cả phím xoá lẫn phím gõ lại.",
    dauTitle: "Dấu: thay chữ tại chỗ",
    dauCaption:
      "Dấu thay đúng phần chữ cần đổi, trong một lần. Dấu không dùng phím giả và mặc định không gạch chân.",
    busyEyebrow: "Dấu khi máy đang bận",
    busyValue: "dưới {ms} ms",
    busyPlaceholder: "[Kết quả bài test tải nặng]",
    busyText:
      "là thời gian Dấu xử lý 99% số phím có đổi chữ, trong lúc máy chạy nặng. Một lần màn hình 60 Hz vẽ lại mất 16,7 ms. Chữ gõ ra đúng ở mọi lần thử trong {apps}.",
    busyConditions:
      "Đo ngày {date} trên {machine}, bản dùng để đo ({build}). Bản nào chậm quá {limit} ms thì không được phát hành.",
    verifiedTitle: "Đã thử và gõ đúng trong {count} ứng dụng (macOS {macOS})",
  },
  features: {
    eyebrow: "Tính năng",
    title: "Thông minh ở đúng chỗ, im lặng ở mọi chỗ khác.",
    foreignTitle: "Giữ nguyên từ nước ngoài",
    foreignText:
      "Gõ “windows” hay “Sunrise” rồi nhấn Space, chữ y nguyên. Từ trùng với tiếng Việt thì tiếng Việt được ưu tiên; gõ đúp phím dấu để giữ chữ gốc.",
    addMarksContext: "Hẹn gặp ở ",
    addMarksTitle: "Thêm dấu cho từ đã gõ",
    addMarksText:
      "Quên dấu? Đặt con trỏ ngay sau từ rồi gõ phím dấu, không cần xoá gõ lại. Không áp ở ứng dụng đang bật gạch chân.",
    perAppInPlace: "Thay tại chỗ",
    perAppUnderline: "Gạch chân",
    perAppSuggested: "Đề xuất",
    perAppSwitch: "Gạch chân khi gõ trong {app}",
    perAppTitle: "Gạch chân khi cần",
    perAppText:
      "Mặc định Dấu thay chữ ngay tại chỗ, không gạch chân. Ứng dụng nào gõ nhanh bị sai chữ thì bật gạch chân riêng cho ứng dụng đó.",
    menuClock: "Th 5 9:41",
    menuDau: "Dấu – Tiếng Việt",
    menuUS: "U.S.",
    menuSettings: "Cài đặt Dấu…",
    macOSTitle: "Như một phần của macOS",
    macOSText:
      "Chuyển Việt/Anh bằng phím tắt của hệ thống, chỉ báo ngay dưới con trỏ, cài đặt giống Cài đặt hệ thống. Trên thanh menu chỉ có biểu tượng nguồn đầu vào của macOS, không có biểu tượng riêng.",
  },
  typingTable: {
    eyebrow: "Bảng gõ",
    title: "Telex và VNI, gọn trong một bảng.",
    lead: "Gõ phím dấu ở bất kỳ đâu trong từ. Gõ đúp phím dấu để xoá dấu và giữ chữ gốc.",
    caption: "Bảng phím gõ Telex và VNI",
    result: "Kết quả",
    name: "Tên",
    telex: "Telex",
    vni: "VNI",
    rows: {
      sac: "Dấu sắc",
      huyen: "Dấu huyền",
      hoi: "Dấu hỏi",
      nga: "Dấu ngã",
      nang: "Dấu nặng",
      circumflex: "Dấu mũ",
      breve: "Dấu trăng",
      horn: "Dấu móc",
      wAlone: "Chữ ư (chỉ Telex)",
      dStroke: "Chữ đ",
      removeMark: "Xoá dấu",
    },
    vniTitle: "VNI: chữ số là dấu",
    vniCaption: "6 thêm mũ, 5 là dấu nặng.",
    doubleTitle: "Gõ đúp để giữ chữ số",
    doubleCaption: "Gõ đúp chữ số thì Dấu bỏ dấu và giữ chữ số.",
    standaloneTitle: "Số đứng riêng",
    standaloneCaption: "Chữ số gõ khi chưa có chữ nào thì giữ nguyên.",
  },
  privacy: {
    eyebrow: "Quyền riêng tư",
    title: "Những gì bạn gõ ở lại trên máy bạn",
    lead: "Dấu không gửi chữ bạn gõ đi đâu cả. Phần nhận phím của Dấu bị macOS chặn hẳn khỏi Internet.",
    inputMethodTitle: "Phần nhận phím",
    inputMethodSubtitle: "chạy mỗi khi bạn gõ",
    inputMethodNetwork:
      "macOS chặn phần này khỏi Internet, nên phần này không gửi được chữ bạn gõ ra ngoài.",
    inputMethodSandbox: "Phần này chạy trong vùng cách ly (sandbox) của macOS.",
    inputMethodLog: "Bản tải về không ghi lại bạn gõ gì, gõ ở ứng dụng nào hay vào lúc nào.",
    link: "Hai phần chỉ trao đổi cài đặt, như kiểu gõ Telex hay VNI, không bao giờ trao đổi chữ bạn gõ",
    appTitle: "Ứng dụng Dấu",
    appSubtitle: "cửa sổ cài đặt",
    appNetwork:
      "Chỉ kết nối Internet để kiểm tra và tải bản cập nhật. Danh sách ứng dụng tương thích có sẵn trong bản cài, không tải về riêng.",
    appReports: "Nút báo lỗi mở một trang GitHub điền sẵn. Bạn xem lại rồi tự bấm gửi.",
    appTelemetry: "Dấu không thu thập số liệu sử dụng.",
    sourceLead: "Mã nguồn công khai.",
    sourceText: " Ai cũng đọc được toàn bộ mã trên GitHub (giấy phép GPLv3) và tự build được.",
    countsLead: "Trang web này chỉ đếm lượt xem và lượt bấm nút.",
    countsText: " Không cookie, không nhận diện bạn. Số đếm lưu ở Vercel, nơi đặt trang.",
  },
  measured: {
    eyebrow: "Đo được",
    title: "Con số, không phải lời hứa.",
    lead: "Test engine chạy trên mỗi commit. Trước mỗi bản phát hành, Dấu chạy thêm một bài gõ dưới tải nặng ở Safari, Chrome và VS Code. Mỗi số dưới đây ghi kèm điều kiện đo.",
    appCountText: "ứng dụng đã đo, kể cả những chỗ Dấu còn gõ sai.",
    appCountLink: "Xem danh sách tương thích",
    otherLabel: "Số đo khác",
    casesPlaceholder: "[số ca]",
    casesText: "ca test engine, chạy lại trên mỗi commit.",
    casesNote: "Telex, VNI và Telex đơn giản.",
    p99Text:
      "là p99 thời gian bộ gõ xử lý một phím có thay chữ khi máy chạy tải nặng. Ngưỡng là {limit} ms.",
    p99Note: "Bản {build}, 20 phím mỗi giây, {machine}, {date}.",
    gate: "Bản nào vượt ngưỡng ở ô này hay ô bộ nhớ thì không được phát hành.",
    rssText: "là bộ nhớ của bộ gõ khi máy chạy tải nặng. Ngưỡng là {limit} MB.",
    rssNote: "Đo trong bài tải nặng, bản {build}, {machine}, {date}.",
    machine: "máy {chip}, macOS {macOS}",
  },
  faq: {
    eyebrow: "Hỏi đáp",
    title: "Câu hỏi thường gặp",
    free: {
      q: "Dấu có miễn phí không?",
      a: "Có, hoàn toàn miễn phí và mã nguồn mở theo giấy phép GPLv3. Không có bản trả phí, không quảng cáo.",
    },
    data: {
      q: "Dấu có thu thập những gì tôi gõ không?",
      a: "Không. Bộ gõ không được phép truy cập mạng nên không thể gửi gì ra ngoài. Dấu không gửi dữ liệu sử dụng nào; báo lỗi do chính bạn mở và gửi.",
    },
    permissions: {
      q: "Có cần cấp quyền gì không?",
      a: "Không cần quyền Trợ năng. Lần đầu bật Dấu, macOS có thể hỏi “Cho phép “Dấu” bật “Dấu”?” (Allow “Dấu” to enable “Dấu”?), vì bộ gõ nhận mọi phím bạn gõ. Bạn bấm Cho phép (Allow).",
    },
    builtIn: {
      q: "Khác gì bộ gõ tiếng Việt có sẵn của macOS?",
      aBefore: "Bộ gõ có sẵn gạch chân từ đang gõ, còn Dấu thay chữ ngay tại chỗ như mục ",
      aLink: "Ba cách gõ tiếng Việt trên Mac",
      aAfter: " cho thấy.",
      verified: "Dấu đã được kiểm chứng gõ đúng ở {apps} (macOS {macOS}).",
    },
    switching: {
      q: "Tôi đang dùng bộ gõ khác, chuyển sang thế nào?",
      a: "Lần đầu mở, Dấu tự phát hiện bộ gõ cũ đang chạy và hướng dẫn tắt, vì hai bộ gõ cùng chạy sẽ ra chữ lỗi.",
    },
    skipped: {
      q: "Vì sao Dấu không có gõ tắt, viết hoa đầu câu hay chuyển mã?",
      intro:
        "Dấu cố ý không làm những tính năng mà macOS đã có sẵn hoặc làm bộ gõ phức tạp thêm. Nếu bạn quen dùng ở bộ gõ khác:",
      items: [
        {
          term: "Gõ tắt (macro):",
          text: "dùng Thay thế văn bản… (Text Replacements…) trong Cài đặt hệ thống (System Settings) › Bàn phím.",
        },
        {
          term: "Viết hoa đầu câu:",
          text: "bật Tự động viết hoa chữ cái đầu từ (Capitalize words automatically) của macOS.",
        },
        {
          term: "Tự đổi Việt/Anh theo ứng dụng:",
          text: "bật Tự động chuyển sang nguồn đầu vào của tài liệu (Automatically switch to a document’s input source), mỗi cửa sổ sẽ nhớ nguồn đầu vào riêng.",
        },
        {
          term: "Bảng mã cũ, công cụ chuyển mã:",
          text: "Dấu chỉ gõ ra Unicode chuẩn, không chuyển mã.",
        },
        {
          term: "Phím chuyển riêng, biểu tượng riêng, âm thanh khi chuyển:",
          text: "Dấu dùng phím tắt và biểu tượng nguồn đầu vào của macOS.",
        },
        { term: "Thống kê gõ phím:", text: "Dấu không ghi lại những gì bạn gõ." },
      ],
    },
    vni: {
      q: "Gõ VNI, sao chữ số lại thành dấu?",
      a: "Với VNI, chữ số gõ ngay sau một âm tiết tiếng Việt là phím dấu: {markKeys} ra {mark}. Muốn giữ chữ số thì gõ nó hai lần: {digitKeys} ra {digit}. Chữ số đứng riêng, như {standalone}, giữ nguyên.",
    },
    cannotChoose: {
      q: "Một ứng dụng không chọn được Dấu?",
      a: "Ứng dụng đó có thể còn giữ danh sách nguồn đầu vào cũ, từ trước khi có Dấu. Đăng xuất (menu Apple › Đăng xuất, Log Out) rồi đăng nhập lại một lần: khi mở lại, mỗi ứng dụng đọc lại danh sách này. Chỉ thoát rồi mở lại ứng dụng thì chưa đủ.",
    },
    uninstall: {
      q: "Gỡ Dấu thế nào?",
      a: "Mở Dấu, vào Cập nhật & hỗ trợ và bấm Gỡ cài đặt…. Dấu mở sẵn danh sách Nguồn đầu vào (Input Sources) trong Cài đặt hệ thống: chọn “Dấu – Tiếng Việt” rồi bấm “–”. Khi Dấu không còn trong danh sách, Dấu tự chuyển bộ gõ rồi chính ứng dụng vào Thùng rác và thoát. Nếu bạn không bấm “–” thì không có gì bị gỡ.",
    },
  },
  download: {
    name: "Dấu {version}",
    versionPlaceholder: "[phiên bản]",
    datePlaceholder: "[ngày phát hành]",
    sizePlaceholder: "[dung lượng]",
    sizeValue: "{size} MB",
    requirements:
      "macOS 14 trở lên, đã kiểm trên macOS 27 (Apple silicon) và macOS 15 (Intel) · [ký số, notarize, cách cập nhật — điền ở M7]",
    dmg: "Tải về (.dmg)",
    history: "Lịch sử phiên bản",
    homebrewTitle: "Hoặc cài bằng Homebrew",
    homebrewCopy: "Sao chép",
    homebrewCopyLabel: "Sao chép lệnh Homebrew",
    homebrewCopied: "Đã sao chép lệnh Homebrew",
    checksum: "SHA-256: {checksum}",
    checksumPlaceholder: "[mã kiểm tra]",
    verifiableTitle: "Bản tải về kiểm chứng được",
    verifiableText:
      "[Build tự động từ mã công khai, ký số, notarize, chứng thực nguồn gốc — điền ở M7]",
    otherDeviceBefore: "Đang xem trên iPhone hay Windows? Dấu chỉ chạy trên Mac. ",
    otherDeviceLink: "Sao chép liên kết",
    otherDeviceAfter: " để mở lại trên máy Mac.",
  },
  contribute: {
    eyebrow: "Góp sức",
    title: "Cùng làm Dấu tốt hơn.",
    lead: "Dấu là dự án mã nguồn mở, miễn phí trọn vẹn. Nếu Dấu giúp ích cho bạn, bạn có thể góp một tay theo cách mình thấy hợp, không cách nào bắt buộc.",
    handTitle: "Góp công",
    reportTitle: "Báo lỗi",
    reportText:
      "Một ứng dụng gõ sai chữ hay một từ Dấu gõ ra không đúng: mở Dấu › Cập nhật & hỗ trợ › Báo lỗi…. Mỗi báo lỗi giúp Dấu đúng thêm cho mọi người.",
    betaTitle: "Dùng thử bản Beta",
    betaText:
      "Chọn kênh Beta trong Cập nhật & hỗ trợ để dùng bản mới sớm hơn và báo lại những gì bạn thấy.",
    codeTitle: "Góp mã nguồn",
    codeText:
      "Mã nguồn của Dấu ở trên GitHub theo giấy phép GPLv3. Bạn có thể đọc, góp ý và gửi thay đổi.",
    shareTitle: "Giới thiệu cho người quen",
    shareText: "Gửi trang này cho bạn bè và đồng nghiệp hoặc gắn sao cho Dấu trên GitHub.",
    donateEyebrow: "Ủng hộ",
    donateTitle: "Mời nhóm làm Dấu một ly cà phê",
    donateText:
      "Dấu vẫn miễn phí trọn vẹn dù bạn có ủng hộ hay không. Cuối mục này ghi tiền ủng hộ đã dùng vào việc gì.",
    vietQRAlt: "Mã VietQR để chuyển khoản",
    vietQRTitle: "Chuyển khoản trong nước",
    vietQRRecipient: "Người nhận",
    vietQRBank: "Ngân hàng",
    vietQRNote:
      "Quét mã bằng ứng dụng ngân hàng. Muốn có tên trong phần Cảm ơn, bạn ghi tên muốn hiện vào nội dung chuyển khoản.",
    vietQRDownload: "Tải ảnh mã QR",
    sponsorsButton: "Ủng hộ qua GitHub Sponsors",
    sponsorsNote: "GitHub Sponsors nhận thanh toán bằng thẻ quốc tế hoặc PayPal.",
    thanksTitle: "Cảm ơn",
    thanksText:
      "Cảm ơn những người đã báo lỗi, góp mã và ủng hộ Dấu. Tên người ủng hộ cũng hiện ở trang Cập nhật & hỗ trợ của ứng dụng Dấu và trong ghi chú của bản phát hành mà họ góp phần làm ra.",
    supportersLabel: "Người ủng hộ",
    consent:
      "Dấu chỉ nêu tên khi bạn đồng ý. Ủng hộ qua GitHub Sponsors ở chế độ công khai là đồng ý. Chuyển khoản VietQR thì ghi tên bạn muốn hiện vào nội dung chuyển khoản; Dấu không bao giờ nêu tên chủ tài khoản đã chuyển. Dấu không ghi số tiền và không xếp hạng.",
    expensesTitle: "Tiền ủng hộ đã dùng vào việc gì",
    expensesText: "Mục này chỉ ghi khoản đã chi thật.",
    expensesDate: "Ngày",
    expensesItem: "Khoản chi",
    expensesAmount: "Số tiền",
  },
  footer: {
    tagline: "Bộ gõ tiếng Việt cho macOS. Mã nguồn mở theo giấy phép GPLv3.",
    label: "Liên kết cuối trang",
    source: "Mã nguồn",
    issues: "Báo lỗi",
    history: "Lịch sử phiên bản",
    uninstall: "Hướng dẫn gỡ cài đặt",
    donate: "Ủng hộ dự án",
  },
  notFound: {
    title: "Không tìm thấy trang này",
    text: "Địa chỉ này không có trang nào.",
    home: "Về trang chủ Dấu",
  },
};

export type Messages = typeof vi;
