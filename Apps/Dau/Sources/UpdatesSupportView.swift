import AppKit
import SwiftUI

/// "Cập nhật & hỗ trợ" (mockup "SettingsAbout"). Updates (Sparkle, D7) and the report
/// and roll-back actions (D8, D19) arrive in M7, so their controls are disabled and
/// promise nothing yet (N5). No network access until then. "Gỡ cài đặt…" (D16) works:
/// `InputMethodActions.confirmUninstall`.
struct UpdatesSupportView: View {
    @Environment(\.inputMethodActions) private var actions

    var body: some View {
        SettingsPage {
            Section {
                HStack(spacing: 12) {
                    // System Settings' pane header card (Notifications, Siri: icon,
                    // title, description) shows its icon 26 pt; Dấu's app icon fills
                    // about 80% of its frame, so 32 draws it at that size.
                    Image(nsImage: NSApp.applicationIconImage)
                        .resizable()
                        .frame(width: AppIcon.twoLine, height: AppIcon.twoLine)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(verbatim: AppVersion.nameAndVersion)
                            .font(.headline)
                        // TODO(M7): one of the six update states from docs/UI.md.
                        Subtitle(Text("[Trạng thái kiểm tra cập nhật]"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .combine)
                    // TODO(M7): Sparkle check.
                    Button("Kiểm tra ngay") {}
                        .disabled(true)
                }
                .layoutProbe("firstRow")
            }

            // TODO(M7): bind to Sparkle (D7).
            Section(header: Text("Cập nhật")) {
                Toggle("Tự động kiểm tra bản mới", isOn: .constant(false))
                Toggle(isOn: .constant(false)) {
                    Text("Tự động tải và cài")
                    Text("[Cách cài bản mới — kiểm chứng ở M7]")
                }
                Picker("Kênh phát hành", selection: .constant(0)) {
                    Text("Ổn định").tag(0)
                    Text("Beta").tag(1)
                }
                .pickerStyle(.segmented)
            }
            .disabled(true)

            Section {
                LabeledContent {
                    // TODO(M7): report sheet with a pre-filled GitHub issue (D8).
                    Button("Báo lỗi…") {}
                } label: {
                    Text("Gặp ứng dụng gõ bị lỗi?")
                    Text("Gửi mô tả lỗi để chúng tôi kiểm tra")
                }
                .disabled(true)
                LabeledContent {
                    // TODO(M7): roll back with confirmation (D16, D19), with Sparkle.
                    Button("Quay về…") {}
                } label: {
                    Text("Quay về bản trước")
                    Text("Dùng khi bản mới gây lỗi")
                }
                .disabled(true)
                LabeledContent("Gỡ Dấu khỏi máy") {
                    // The system's destructive button, enabled and disabled look
                    // included (D9). macOS 27.2 draws it as a plain push button, text
                    // not red (measured 02/11/2026); docs/UI.md follows the system.
                    Button("Gỡ cài đặt…", role: .destructive) {
                        actions?.confirmUninstall(in: NSApp.keyWindow)
                    }
                    .disabled(actions == nil || actions?.isUninstalling == true)
                }
            } header: {
                Text("Hỗ trợ")
            } footer: {
                // Wording fixed by docs/UI.md (D8, N2). The page's closing note, after
                // the last card (a footer, not a section description).
                Subtitle(Text("Dấu không gửi chữ bạn gõ ra khỏi máy. Bộ gõ không có quyền truy cập mạng; chỉ phần cập nhật kết nối để tải bản mới và danh sách ứng dụng tương thích. Mã nguồn mở theo giấy phép GPLv3."))
            }
        }
    }
}
