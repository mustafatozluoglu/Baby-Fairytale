import Foundation
import os

protocol StoryGenerator {
    func generateStory(params: StoryParams) async throws -> Story
    func generateImage(prompt: String) async throws -> URL?
}

enum StoryGeneratorError: LocalizedError {
    case missingConfiguration
    
    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            return "GEMINI_API_KEY tanımlı değil. Lütfen Info.plist veya ortam değişkeninden anahtarınızı ekleyin."
        }
    }
}

class OpenAIStoryGenerator: StoryGenerator {
    private let apiKey: String
    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
    private let logger = Logger(subsystem: "BabyFairytale", category: "OpenAIStoryGenerator")
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func generateStory(params: StoryParams) async throws -> Story {
        let heroLine = params.heroName.isEmpty
        ? "Create a memorable main character suitable for the story."
        : "The main character is named \(params.heroName)."
        
        let settingLine = params.setting.isEmpty
        ? ""
        : "The story should take place in \(params.setting)."
        
        // Construct the prompt
        let prompt = """
        Write a children's fairytale about \(params.topic).
        \(heroLine)
        The story should be suitable for a \(params.ageGroup.promptDescription).
        The tone should be \(params.tone.promptDescription).
        The length should be \(params.length.promptDescription).
        \(settingLine)
        \(params.moral.isEmpty ? "" : "The moral of the story should be: \(params.moral).")
        
        IMPORTANT: The story MUST be written in \(params.language.rawValue).
        
        Return the response in JSON format with the following fields:
        - title: The title of the story
        - content: The full story text
        - imagePrompt: A description for an image generator to create an illustration for this story
        """
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo", // Or gpt-4 if available
            "messages": [
                ["role": "system", "content": "You are a creative storyteller for children. You output strictly valid JSON."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let errorText = String(data: data, encoding: .utf8) {
                logger.error("OpenAI error: \(errorText)")
            }
            throw NSError(domain: "OpenAIStoryGenerator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate story. Check API Key."])
        }
        
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let contentString = openAIResponse.choices.first?.message.content else {
            throw NSError(domain: "OpenAIStoryGenerator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        // Parse the JSON content from the message
        struct StoryDTO: Decodable {
            let title: String
            let content: String
            let imagePrompt: String?
        }
        
        guard let data = contentString.data(using: .utf8),
              let storyDTO = try? JSONDecoder().decode(StoryDTO.self, from: data) else {
             // Fallback if JSON parsing fails (sometimes LLMs add extra text)
            throw NSError(domain: "OpenAIStoryGenerator", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse story from AI response"])
        }
        
        // Manually set the language since the LLM might not return it in the JSON or we want to enforce what we asked for
        let newStory = Story(
            title: storyDTO.title,
            content: storyDTO.content,
            imagePrompt: storyDTO.imagePrompt,
            imageURL: nil,
            language: params.language == .turkish ? "tr-TR" : "en-US",
            topic: params.topic,
            heroName: params.heroName,
            ageGroup: params.ageGroup,
            tone: params.tone,
            length: params.length
        )
        
        return newStory
    }
    
    func generateImage(prompt: String) async throws -> URL? {
        let url = URL(string: "https://api.openai.com/v1/images/generations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "dall-e-3",
            "prompt": "Children's book illustration, cute, colorful, magical style: " + prompt,
            "n": 1,
            "size": "1024x1024"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let errorText = String(data: data, encoding: .utf8) {
                logger.error("DALL-E error: \(errorText)")
            }
            throw NSError(domain: "OpenAIStoryGenerator", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to generate image."])
        }
        
        let imageResponse = try JSONDecoder().decode(DALLEResponse.self, from: data)
        if let urlString = imageResponse.data.first?.url {
            return URL(string: urlString)
        }
        return nil
    }
}

struct DALLEResponse: Decodable {
    let data: [DALLEImage]
}

struct DALLEImage: Decodable {
    let url: String
}

// Helper structs for OpenAI Response
struct OpenAIResponse: Decodable {
    let choices: [Choice]
}

struct Choice: Decodable {
    let message: Message
}

struct Message: Decodable {
    let content: String
}

// Mock generator for testing without API key
class MockStoryGenerator: StoryGenerator {
    func generateStory(params: StoryParams) async throws -> Story {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Simulate delay
        
        let hero = params.heroName.isEmpty ? "Kahraman" : params.heroName
        
        let stories = [
            Story(
                title: "Cesur \(hero) ve Kayıp Yıldız",
                content: "Bir zamanlar, gökyüzünde parlayan yıldızları izlemeyi çok seven \(hero) adında cesur bir çocuk vardı. Bir gece, en parlak yıldızın kaybolduğunu fark etti. \(hero), yıldızı bulmak için sihirli ormana doğru yola çıktı. Yolda konuşan bir baykuşla karşılaştı. Baykuş ona yıldızın ayın arkasında saklandığını söyledi. \(hero) pes etmedi ve sonunda yıldızı bulup gökyüzüne geri koydu. O günden sonra tüm köy \(hero)'nun cesaretini konuştu.",
                imagePrompt: "A brave child looking at the starry night sky in a magical forest",
                language: "tr-TR",
                topic: params.topic,
                heroName: hero,
                ageGroup: params.ageGroup,
                tone: params.tone,
                length: params.length
            ),
            Story(
                title: "\(hero)'nun Sihirli Bahçesi",
                content: "\(hero), bahçesinde oynamayı çok severdi. Bir gün toprağı kazarken parlayan bir tohum buldu. Tohumu ekti ve ona su verdi. Ertesi sabah, bahçede devasa, rengarenk şekerlerden oluşan bir ağaç büyümüştü! \(hero), bu şekerleri tüm arkadaşlarıyla paylaştı. Paylaşmanın ne kadar güzel bir şey olduğunu o gün herkes öğrendi.",
                imagePrompt: "A magical garden with a giant tree made of colorful candies",
                language: "tr-TR",
                topic: params.topic,
                heroName: hero,
                ageGroup: params.ageGroup,
                tone: params.tone,
                length: params.length
            ),
            Story(
                title: "Uzay Gezgini \(hero)",
                content: "\(hero) her zaman uzayı merak ederdi. Bir karton kutudan kendine bir roket yaptı. '3, 2, 1, Ateş!' diye bağırdı ve hayal gücüyle uzaya fırladı. Ay'da zıpladı, Mars'taki kırmızı tozlarla oynadı. Dönüşte annesi ona sıcak bir süt hazırlamıştı. \(hero), en büyük maceraların bile evde bittiğini anladı.",
                imagePrompt: "A child pretending to be an astronaut in a cardboard rocket",
                language: "tr-TR",
                topic: params.topic,
                heroName: hero,
                ageGroup: params.ageGroup,
                tone: params.tone,
                length: params.length
            ),
            Story(
                title: "\(hero) ve Deniz Altı Macerası",
                content: "Deniz kenarında yaşayan \(hero), bir gün sahilde parlayan bir deniz kabuğu buldu. Kulağına dayadığında, kabuk ona denizin altındaki gizli bir şehirden bahsetti. \(hero) maskesini taktı ve suya daldı. Orada dans eden balıklar ve şarkı söyleyen yengeçlerle tanıştı. Deniz altı dünyası sandığından çok daha renkliydi.",
                imagePrompt: "Undersea world with colorful fish and a child swimming",
                language: "tr-TR",
                topic: params.topic,
                heroName: hero,
                ageGroup: params.ageGroup,
                tone: params.tone,
                length: params.length
            )
        ]
        
        // Select a random story or fallback
        var selectedStory = stories.randomElement()!
        
        // If user asked for English, return a generic English story (though UI defaults to Turkish now)
        if params.language == .english {
            selectedStory = Story(
                title: "The Brave Little Toaster",
                content: "Once upon a time, there was a toaster named \(hero). It loved to make toast for everyone in the village. One day...",
                imagePrompt: "A cute toaster with a smiling face in a cozy kitchen",
                language: "en-US",
                topic: params.topic,
                heroName: hero,
                ageGroup: params.ageGroup,
                tone: params.tone,
                length: params.length
            )
        }
        
        return selectedStory
    }
    
    func generateImage(prompt: String) async throws -> URL? {
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        // Return nil to show the placeholder art
        return nil
    }
}

class MissingConfigurationStoryGenerator: StoryGenerator {
    func generateStory(params: StoryParams) async throws -> Story {
        throw StoryGeneratorError.missingConfiguration
    }
    
    func generateImage(prompt: String) async throws -> URL? {
        throw StoryGeneratorError.missingConfiguration
    }
}
