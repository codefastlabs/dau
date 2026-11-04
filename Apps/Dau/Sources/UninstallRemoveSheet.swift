import Carbon
import SwiftUI

/// "Bỏ Dấu khỏi Nguồn nhập liệu": the sheet over the Settings window after "Tiếp tục
/// gỡ" (D16). macOS lets only the user remove an input source, so it lists what is done
/// and what the user does, and waits until Dấu is gone from the list; then Dấu stops the
/// input method and moves it to the Trash (`InputMethodActions.performUninstall`). Built
/// like the add-rule sheet (D9): the sheet's own button bar from the toolbar's
/// cancellation and primary placements, no default button (Return must not cancel or
/// open anything by accident). The wording of macOS's own screens is English, as on the
/// user's Mac.
struct UninstallRemoveSheet: View {
    let actions: InputMethodActions
    @Environment(\.controlActiveState) private var activeState

    static let width: CGFloat = 470

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Bỏ Dấu khỏi Nguồn nhập liệu")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                Text("macOS chỉ cho bạn tự bỏ một nguồn nhập liệu. System Settings đã mở sẵn danh sách Input Sources.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            OnboardingCard(spacing: 10) {
                NumberedLine(number: 1,
                             text: Text("Chọn **Dấu – Tiếng Việt** ở danh sách bên trái, bấm **–**, rồi **Done**."),
                             isCurrent: true)
            }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                    .accessibilityHidden(true)
                Text("Đang chờ Dấu biến mất khỏi danh sách. Xong là Dấu tự chuyển vào Thùng rác.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.updatesFrequently)
            // Only while Dấu is the selected input source, which can dim "–": it goes away
            // when the user switches to another keyboard.
            if actions.dauIsSelected {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    Hint(Text("Bạn đang dùng Dấu. Nếu nút – bị mờ, chọn bàn phím khác trong menu nhập liệu trước."))
                }
                .accessibilityElement(children: .combine)
            }
        }
        .padding(20)
        .frame(width: Self.width, alignment: .leading)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Huỷ gỡ cài đặt", role: .cancel) { actions.cancelUninstall() }
                    .keyboardShortcut(.cancelAction)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Mở System Settings") { actions.showInputSources() }
            }
        }
        // Read again when the sheet appears, when its window becomes key again and whenever
        // the selected input source changes, so the hint follows the user's switch.
        .onAppear { actions.refreshDauIsSelected() }
        .onChange(of: activeState) { _, state in
            if state == .key { actions.refreshDauIsSelected() }
        }
        .onReceive(DistributedNotificationCenter.default().publisher(
            for: Notification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String))) { _ in
            // The notification can come before this process's input source state has
            // changed: read now and again shortly after; the wait's poll covers the rest.
            actions.refreshDauIsSelected()
            Task {
                try? await Task.sleep(for: .milliseconds(300))
                actions.refreshDauIsSelected()
            }
        }
    }
}
