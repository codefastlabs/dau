import AppKit
import SwiftUI

/// The system segmented control (NSSegmentedControl).
///
/// - The onboarding window's (the default): segments of equal width filling the width it
///   is given, large size. SwiftUI's segmented `Picker` keeps its intrinsic width on
///   macOS 14–15; on macOS 26+ `buttonSizing(.flexible)` makes it fill (measured on 27.2:
///   "Kiểu gõ" in Settings spans the row, 528 pt), which the Settings window uses.
/// - A Settings row with a segment shown but not selectable ("Kênh phát hành", D7):
///   `fillsWidth: false`, regular size, as the row's SwiftUI segmented `Picker` would
///   draw. SwiftUI's segmented `Picker` cannot turn one segment off: `.disabled` on a
///   tagged option left the segment enabled on macOS 27.2 (a `Picker` laid out in a
///   window never shown, 18/11/2026), while `NSSegmentedControl.setEnabled(_:forSegment:)`
///   is the AppKit API for it.
///
/// Its look (selection color, height, separators) is the system's (D9).
struct SegmentedPicker<Value: Hashable>: NSViewRepresentable {
    let label: String
    let options: [(Value, String)]
    /// Options shown but not selectable.
    var disabled: [Value] = []
    var fillsWidth = true
    var controlSize: NSControl.ControlSize = .large
    @Binding var selection: Value

    init(_ label: String, selection: Binding<Value>, options: [(Value, String)], disabled: [Value] = [],
         fillsWidth: Bool = true, controlSize: NSControl.ControlSize = .large) {
        self.label = label
        self._selection = selection
        self.options = options
        self.disabled = disabled
        self.fillsWidth = fillsWidth
        self.controlSize = controlSize
    }

    func makeNSView(context: Context) -> NSSegmentedControl {
        let control = NSSegmentedControl(labels: options.map(\.1), trackingMode: .selectOne,
                                         target: context.coordinator,
                                         action: #selector(Coordinator.changed(_:)))
        control.segmentDistribution = fillsWidth ? .fillEqually : .fit
        control.controlSize = controlSize
        control.setAccessibilityLabel(label)
        if fillsWidth {
            control.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
        return control
    }

    func updateNSView(_ control: NSSegmentedControl, context: Context) {
        context.coordinator.parent = self
        control.isEnabled = context.environment.isEnabled
        let selected = options.firstIndex(where: { $0.0 == selection }) ?? -1
        if control.selectedSegment != selected { control.selectedSegment = selected }
        for (index, option) in options.enumerated() {
            control.setEnabled(!disabled.contains(option.0), forSegment: index)
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, nsView: NSSegmentedControl, context: Context) -> CGSize? {
        let intrinsic = nsView.intrinsicContentSize
        guard fillsWidth else { return intrinsic }
        return CGSize(width: proposal.width ?? intrinsic.width, height: intrinsic.height)
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    @MainActor
    final class Coordinator: NSObject {
        var parent: SegmentedPicker

        init(parent: SegmentedPicker) { self.parent = parent }

        @objc func changed(_ sender: NSSegmentedControl) {
            let index = sender.selectedSegment
            guard parent.options.indices.contains(index) else { return }
            parent.selection = parent.options[index].0
        }
    }
}
