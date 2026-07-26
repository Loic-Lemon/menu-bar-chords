import SwiftUI
import AppKit

struct PopUpButtonPicker<Item: Hashable>: NSViewRepresentable {
    @Binding var selection: Item
    let items: [Item]
    let title: (Item) -> String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSPopUpButton {
        let button = NSPopUpButton(frame: .zero, pullsDown: false)
        button.target = context.coordinator
        button.action = #selector(Coordinator.selectionChanged(_:))
        button.controlSize = .small
        button.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small))
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }

    func updateNSView(_ button: NSPopUpButton, context: Context) {
        button.removeAllItems()
        for (index, item) in items.enumerated() {
            button.addItem(withTitle: title(item))
            button.item(at: index)?.representedObject = index
        }
        if let selectedIndex = items.firstIndex(of: selection) {
            button.selectItem(at: selectedIndex)
        }
        context.coordinator.parent = self
    }

    @MainActor
    final class Coordinator: NSObject {
        var parent: PopUpButtonPicker

        init(_ parent: PopUpButtonPicker) {
            self.parent = parent
        }

        @objc func selectionChanged(_ sender: NSPopUpButton) {
            let index = sender.selectedItem?.representedObject as? Int ?? -1
            guard index >= 0, index < parent.items.count else { return }
            parent.selection = parent.items[index]
        }
    }
}
