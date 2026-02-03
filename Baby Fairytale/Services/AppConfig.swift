import Foundation

enum AppConfig {
    static var geminiAPIKey: String? {
        let infoValue = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String
        if let infoValue, !infoValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return infoValue
        }
        
        let envValue = ProcessInfo.processInfo.environment["GEMINI_API_KEY"]
        if let envValue, !envValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return envValue
        }
        
        return nil
    }
}
