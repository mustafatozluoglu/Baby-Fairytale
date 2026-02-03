import Foundation

struct Story: Identifiable, Codable {
    var id: UUID
    let title: String
    let content: String
    let imagePrompt: String?
    var imageURL: URL?
    let language: String
    let createdAt: Date
    let topic: String
    let heroName: String
    let ageGroup: AgeGroup
    let tone: StoryTone
    let length: StoryLength
    
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        imagePrompt: String?,
        imageURL: URL? = nil,
        language: String,
        createdAt: Date = Date(),
        topic: String = "",
        heroName: String = "",
        ageGroup: AgeGroup = .toddler,
        tone: StoryTone = .gentle,
        length: StoryLength = .short
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.imagePrompt = imagePrompt
        self.imageURL = imageURL
        self.language = language
        self.createdAt = createdAt
        self.topic = topic
        self.heroName = heroName
        self.ageGroup = ageGroup
        self.tone = tone
        self.length = length
    }
    
    var shareText: String {
        "\(title)\n\n\(content)\n\n— Baby Fairytale"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case imagePrompt
        case imageURL
        case language
        case createdAt
        case topic
        case heroName
        case ageGroup
        case tone
        case length
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        imagePrompt = try container.decodeIfPresent(String.self, forKey: .imagePrompt)
        imageURL = try container.decodeIfPresent(URL.self, forKey: .imageURL)
        language = try container.decodeIfPresent(String.self, forKey: .language) ?? "tr-TR"
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        topic = try container.decodeIfPresent(String.self, forKey: .topic) ?? ""
        heroName = try container.decodeIfPresent(String.self, forKey: .heroName) ?? ""
        ageGroup = try container.decodeIfPresent(AgeGroup.self, forKey: .ageGroup) ?? .toddler
        tone = try container.decodeIfPresent(StoryTone.self, forKey: .tone) ?? .gentle
        length = try container.decodeIfPresent(StoryLength.self, forKey: .length) ?? .short
    }
}

struct StoryParams {
    var topic: String = ""
    var heroName: String = ""
    var ageGroup: AgeGroup = .toddler
    var moral: String = ""
    var language: StoryLanguage = .turkish
    var tone: StoryTone = .gentle
    var length: StoryLength = .short
    var setting: String = ""
}

extension StoryParams {
    var trimmedTopic: String {
        topic.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var trimmedHeroName: String {
        heroName.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var trimmedMoral: String {
        moral.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var trimmedSetting: String {
        setting.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isValid: Bool {
        !trimmedTopic.isEmpty
    }
}

enum StoryLanguage: String, CaseIterable, Identifiable, Codable {
    case turkish = "Türkçe"
    case english = "İngilizce"
    
    var id: String { self.rawValue }
}

enum AgeGroup: String, CaseIterable, Identifiable, Codable {
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

enum StoryTone: String, CaseIterable, Identifiable, Codable {
    case gentle = "Yumuşak"
    case adventurous = "Maceracı"
    case funny = "Eğlenceli"
    case soothing = "Rahatlatıcı"
    
    var id: String { self.rawValue }
    
    var promptDescription: String {
        switch self {
        case .gentle: return "gentle, warm, and comforting"
        case .adventurous: return "adventurous, exciting, and upbeat"
        case .funny: return "funny, playful, and lighthearted"
        case .soothing: return "calm, soothing, and bedtime-friendly"
        }
    }
}

enum StoryLength: String, CaseIterable, Identifiable, Codable {
    case short = "Kısa"
    case medium = "Orta"
    case long = "Uzun"
    
    var id: String { self.rawValue }
    
    var promptDescription: String {
        switch self {
        case .short: return "short (around 150-200 words)"
        case .medium: return "medium length (around 250-350 words)"
        case .long: return "longer (around 400-550 words)"
        }
    }
}
