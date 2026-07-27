import SwiftUI
import ChordsLib

struct ContentView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 12) {
            headerRow
                .padding(.top, 16)

            modePicker

            Divider()

            modeContent

            if model.showHistory {
                Divider()
                SessionHistoryView()
                    .padding(.top, 4)
            }

            if model.showSettings {
                Divider()
                SettingsView()
                    .padding(.top, 4)
            }

            HStack(spacing: 12) {
                settingsButton
                historyButton
            }
            .padding(.bottom, (model.showSettings || model.showHistory) ? 0 : 16)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(width: model.popoverSize.width)
    }

    private var headerRow: some View {
        HStack {
            Image(systemName: model.menuBarIconName)
                .foregroundStyle(Color.accentColor)
            Text("Menu Bar Chords")
                .font(.headline)
        }
    }

    private var settingsButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "gearshape")
                .font(.caption)
            Text("Settings")
                .font(.caption)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            model.showSettings.toggle()
        }
    }

    private var historyButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.caption)
            Text("History")
                .font(.caption)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            model.showHistory.toggle()
        }
    }

    private var modePicker: some View {
        Picker("Mode", selection: modeBinding) {
            ForEach(AppMode.allCases, id: \.self) { mode in
                Text(mode.label).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }

    @ViewBuilder
    private var modeContent: some View {
        switch model.selectedMode {
        case .browse:
            BrowseView()
        case .quiz:
            ChordQuizView()
        case .notes:
            NoteRecognitionView()
        }
    }

    private var modeBinding: Binding<AppMode> {
        Binding(
            get: { model.selectedMode },
            set: {
                model.selectedMode = $0
                model.didChangeMode()
            }
        )
    }
}
