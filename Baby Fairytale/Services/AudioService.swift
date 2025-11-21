import AVFoundation

class AudioService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(text: String, language: String = "en-US") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.1 // Slightly higher pitch for "storyteller" vibe
        
        synthesizer.speak(utterance)
        isSpeaking = true
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
}
