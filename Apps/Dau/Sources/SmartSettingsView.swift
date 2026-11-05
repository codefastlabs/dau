import SwiftUI
import DauShared

/// "Thông minh" (mockups "SettingsSmart", "SettingsSmartAdvanced"): automatic restore
/// of foreign words (D4), adding marks to a typed word (D20), and the collapsed
/// "Nâng cao" group (D21, D22, D23).
struct SmartSettingsView: View {
    @Environment(SettingsModel.self) private var model
    @Environment(\.smartAdvancedExpanded) private var expandedAtStart
    @State private var advancedExpanded = false

    var body: some View {
        @Bindable var model = model
        let method = model.settings.typingMethod
        SettingsPage {
            Section(header: Text("Gõ lẫn từ nước ngoài")) {
                Toggle(isOn: $model.settings.autoRestore) {
                    Text("Tự khôi phục từ không phải tiếng Việt")
                    Text("Khi gõ xong một từ (Space, dấu câu, Enter), từ không phải tiếng Việt được giữ nguyên như bạn gõ")
                }
                .layoutProbe("firstRow")
                VStack(alignment: .leading, spacing: 8) {
                    WrappingHStack {
                        ForEach(SettingsSamples.restore(method)) { ExampleChips(example: $0) }
                    }
                    let wins = SettingsSamples.vietnameseWins(method)
                    let keep = SettingsSamples.keepOriginal(method)
                    Subtitle(Text("Từ trùng với tiếng Việt thì tiếng Việt được ưu tiên: “\(wins.keys)” ra “\(wins.result)”. Muốn giữ chữ gốc, gõ đúp phím dấu: “\(keep.keys)” ra “\(keep.result)”."))
                }
            }

            Section(header: Text("Sửa từ đã gõ")) {
                Toggle(isOn: $model.settings.addMarksToTypedWords) {
                    HStack(spacing: 6) {
                        Text("Thêm dấu cho từ đã gõ")
                        NewBadge()
                    }
                    // D20 scope (30/10/2026): only the text right before the cursor,
                    // never in apps with a "Có gạch chân" rule. N5: stability on web
                    // editors is an open question in DECISIONS.md; the placeholder
                    // stays until it is measured.
                    Text("Đặt con trỏ ngay sau từ rồi gõ phím dấu. Không áp dụng ở ứng dụng có quy tắc “Có gạch chân”. [Kết quả kiểm chứng trên Google Docs, Notion…]")
                }
                WrappingHStack {
                    ExampleChips(example: SettingsSamples.addMarks(method))
                }
            }

            Section {
                // D9: a system button with a chevron, accepted for "Nâng cao" (the
                // disclosure group indents the options).
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { advancedExpanded.toggle() }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(advancedExpanded ? 90 : 0))
                        Text("Nâng cao")
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(advancedSummary(model.settings.advanced))
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Nâng cao"))
                .accessibilityValue(Text(advancedSummary(model.settings.advanced)))
                .accessibilityHint(advancedExpanded ? Text("Thu gọn") : Text("Mở rộng"))

                if advancedExpanded {
                    AdvancedOptions(settings: $model.settings)
                }
            }
        }
        .onAppear { if expandedAtStart { advancedExpanded = true } }
    }

    private func advancedSummary(_ advanced: DauSettings.Advanced) -> String {
        advanced == .off
            ? String(localized: "2 tuỳ chọn, đang tắt")
            : String(localized: "2 tuỳ chọn, 1 đang bật")
    }
}

/// The two mutually exclusive advanced switches (D22).
struct AdvancedOptions: View {
    @Binding var settings: DauSettings

    var body: some View {
        Toggle(isOn: $settings.consonantShortcuts) {
            Text("Gõ tắt phụ âm")
            Text(shortcutsHint)
        }
        Toggle(isOn: $settings.allowZFWJ) {
            Text("Cho phép phụ âm z, f, w, j")
            Text(zfwjHint)
        }
    }

    private var shortcutsHint: String {
        // D21; w → qu exists only in VNI (D23). D22: say that this turns the other off.
        String(localized: "Đầu từ: f → ph, j → gi (VNI thêm w → qu) · Cuối từ: g → ng, h → nh, k → ch. Áp dụng khi gõ xong từ, chỉ khi ra từ tiếng Việt hợp lệ. Bật mục này sẽ tắt Cho phép phụ âm z, f, w, j.")
    }

    private var zfwjHint: String {
        // D22, D23: in Telex a leading w is always ư, noted only while Telex is used.
        settings.typingMethod == .telex
            ? String(localized: "Dành cho từ mượn và tên riêng. Bật mục này sẽ tắt Gõ tắt phụ âm. Với Telex, w ở đầu từ luôn thành ư nên mục này chỉ có tác dụng với z, f, j.")
            : String(localized: "Dành cho từ mượn và tên riêng. Bật mục này sẽ tắt Gõ tắt phụ âm.")
    }
}

extension EnvironmentValues {
    /// Opens "Nâng cao" when the page appears (snapshots of the expanded state).
    @Entry var smartAdvancedExpanded = false
}
