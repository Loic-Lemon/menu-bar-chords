import AVFoundation

public actor AudioEngine {
    public static let shared = AudioEngine()
    
    private let engine = AVAudioEngine()
    private let midiInstrument: AVAudioUnitMIDIInstrument
    private var activeNotes: Set<UInt8> = []
    
    private init() {
        let desc = AudioComponentDescription(
            componentType: kAudioUnitType_MusicDevice,
            componentSubType: kAudioUnitSubType_DLSSynth,
            componentManufacturer: kAudioUnitManufacturer_Apple,
            componentFlags: 0,
            componentFlagsMask: 0)
        
        self.midiInstrument = AVAudioUnitMIDIInstrument(audioComponentDescription: desc)
        
        engine.attach(midiInstrument)
        engine.connect(midiInstrument, to: engine.mainMixerNode, format: nil)
        
        do {
            try engine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    public func updateSound(_ sound: GuitarSound) {
        // MSB 0x79 (121) is the melodic bank in DLS Synth
        midiInstrument.sendProgramChange(sound.midiProgram, bankMSB: 0x79, bankLSB: 0, onChannel: 0)
    }
    
    public func play(frets: [Int?], sound: GuitarSound) async {
        let baseNotes: [UInt8] = [64, 59, 55, 50, 45, 40]
        var notesToPlay: [UInt8] = []
        
        for i in (0..<6).reversed() {
            if i < frets.count, let fret = frets[i] {
                notesToPlay.append(baseNotes[i] + UInt8(fret))
            }
        }
        
        guard !notesToPlay.isEmpty else { return }
        
        for note in activeNotes {
            midiInstrument.sendMIDIEvent(0x80, data1: note, data2: 0)
        }
        activeNotes.removeAll()
        
        for note in notesToPlay {
            midiInstrument.sendMIDIEvent(0x90, data1: note, data2: 100)
            activeNotes.insert(note)
            try? await Task.sleep(nanoseconds: 35_000_000)
        }
        
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            self.stop(notes: notesToPlay)
        }
    }
    
    private func stop(notes: [UInt8]) {
        for note in notes {
            if activeNotes.contains(note) {
                midiInstrument.sendMIDIEvent(0x80, data1: note, data2: 0)
                activeNotes.remove(note)
            }
        }
    }
}
