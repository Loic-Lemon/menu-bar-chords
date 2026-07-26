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
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(width: 320)
    }

    private var headerRow: some View {
        HStack {
            Image(systemName: "guitars")
                .foregroundStyle(Color.accentColor)
            Text("Menu Bar Chords")
                .font(.headline)
        }
    }

    private var modePicker: some View {
        Picker("Mode", selection: modeBinding) {
            ForEach(AppMode.allCases, id: \.self) { mode in
                Text(mode.label).tag(mode)
            }
        }
        .pickerStyle(.segmented)
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
