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
    let preparation: UninstallPreparation

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
                if let keyboard = preparation.switchedTo {
                    HStack(alignment: .top, spacing: 10) {
                        ListBadge(kind: .done)
                        Text("Đã chuyển sang **\(keyboard)**")
                            .font(.system(size: 13))
                            .padding(.top, 2)
                    }
                    .accessibilityElement(children: .combine)
                } else if preparation.needsOtherKeyboard {
                    NumberedLine(number: 1, text: Text("Chọn một bàn phím khác trong menu nhập liệu"))
                }
                NumberedLine(number: editNumber,
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
            Hint(Text("Nút – bị mờ? Bạn đang dùng Dấu: chọn bàn phím khác trong menu nhập liệu trước."))
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
    }

    /// The row with the steps in System Settings follows the keyboard row, when there is one.
    private var editNumber: Int {
        preparation.switchedTo != nil || preparation.needsOtherKeyboard ? 2 : 1
    }
}
