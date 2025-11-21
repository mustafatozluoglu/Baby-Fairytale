import Foundation

struct Story: Identifiable, Codable {
    var id = UUID()
    let title: String
    let content: String
    let imagePrompt: String?
    var imageURL: URL?
    let language: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case content
        case imagePrompt
        case imageURL
        case language
    }
}

struct StoryParams {
    var topic: String = ""
    var heroName: String = ""
    var ageGroup: AgeGroup = .toddler
    var moral: String = ""
    var language: StoryLanguage = .turkish
}

enum StoryLanguage: String, CaseIterable, Identifiable {
    case turkish = "Türkçe"
    case english = "İngilizce"
    
    var id: String { self.rawValue }
}

enum AgeGroup: String, CaseIterable, Identifiable {
    case toddler = "Bebek (1-3)"
    case preschool = "Okul Öncesi (3-5)"
    case schoolAge = "Okul Çağı (6-9)"
    
    var id: String { self.rawValue }
    
    var promptDescription: String {
        switch self {
        case .toddler: return "simple, repetitive, and very short for a toddler"
        case .preschool: return "imaginative, engaging, and short for a preschooler"
        case .schoolAge: return "adventurous, slightly more complex, and medium length for a school-aged child"
        }
    }
}
