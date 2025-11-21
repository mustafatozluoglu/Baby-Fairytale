import Foundation

class GeminiStoryGenerator: StoryGenerator {
    private let apiKey: String
    private let endpoint = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent")!
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func generateStory(params: StoryParams) async throws -> Story {
        // Construct the prompt
        let prompt = """
        Write a children's fairytale about \(params.topic).
        The main character is named \(params.heroName).
        The story should be suitable for a \(params.ageGroup.promptDescription).
        \(params.moral.isEmpty ? "" : "The moral of the story should be: \(params.moral).")
        
        IMPORTANT: The story MUST be written in \(params.language.rawValue).
        
        Return the response in JSON format with the following fields:
        - title: The title of the story
        - content: The full story text
        - imagePrompt: A description for an image generator to create an illustration for this story
        """
        
        var request = URLRequest(url: endpoint.appending(queryItems: [URLQueryItem(name: "key", value: apiKey)]))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "responseMimeType": "application/json"
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let errorText = String(data: data, encoding: .utf8) {
                print("Gemini Error: \(errorText)")
            }
            throw NSError(domain: "GeminiStoryGenerator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate story. Check API Key."])
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let contentString = geminiResponse.candidates.first?.content.parts.first?.text else {
            throw NSError(domain: "GeminiStoryGenerator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        // Parse the JSON content from the message
        struct StoryDTO: Decodable {
            let title: String
            let content: String
            let imagePrompt: String?
        }
        
        // Clean the response - remove markdown code blocks if present
        var cleanedContent = contentString.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedContent.hasPrefix("```json") {
            cleanedContent = cleanedContent.replacingOccurrences(of: "```json", with: "")
        }
        if cleanedContent.hasPrefix("```") {
            cleanedContent = cleanedContent.replacingOccurrences(of: "```", with: "")
        }
        if cleanedContent.hasSuffix("```") {
            cleanedContent = String(cleanedContent.dropLast(3))
        }
        cleanedContent = cleanedContent.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleanedContent.data(using: .utf8) else {
            throw NSError(domain: "GeminiStoryGenerator", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to convert response to data"])
        }
        
        // Try to decode as array first (Gemini sometimes returns an array)
        var storyDTO: StoryDTO?
        if let storyArray = try? JSONDecoder().decode([StoryDTO].self, from: data), let firstStory = storyArray.first {
            storyDTO = firstStory
        } else if let singleStory = try? JSONDecoder().decode(StoryDTO.self, from: data) {
            storyDTO = singleStory
        }
        
        guard let story = storyDTO else {
            print("Failed to parse Gemini response. Content was: \(cleanedContent)")
            throw NSError(domain: "GeminiStoryGenerator", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse story from AI response"])
        }
        
        // Manually set the language
        let newStory = Story(title: story.title, content: story.content, imagePrompt: story.imagePrompt, imageURL: nil, language: params.language == .turkish ? "tr-TR" : "en-US")
        
        return newStory
    }
    
    func generateImage(prompt: String) async throws -> URL? {
        // Gemini 1.5 Flash doesn't generate images directly in this endpoint usually, 
        // or requires a specific Imagen model. For this MVP, we will return nil 
        // as the user only asked for the API key integration for text mostly, 
        // and we don't have a separate Imagen key/endpoint setup in the plan.
        // We can stick to the placeholder logic or try to use DALL-E if we had a key, 
        // but we are switching to Gemini.
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        return nil
    }
}

// Helper structs for Gemini Response
struct GeminiResponse: Decodable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Decodable {
    let content: GeminiContent
}

struct GeminiContent: Decodable {
    let parts: [GeminiPart]
}

struct GeminiPart: Decodable {
    let text: String
}
