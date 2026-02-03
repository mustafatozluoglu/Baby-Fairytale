import Foundation
import SwiftUI

enum StoryGeneratorState: Equatable {
    case configured
    case debugMock
    case missingConfiguration
    
    var message: String? {
        switch self {
        case .configured:
            return nil
        case .debugMock:
            return "GEMINI_API_KEY bulunamadı. Geliştirici modunda örnek masallar gösteriliyor."
        case .missingConfiguration:
            return "Uygulama yapılandırması eksik. GEMINI_API_KEY eklenmeden masal üretilemez."
        }
    }
    
    var canGenerate: Bool {
        switch self {
        case .configured, .debugMock:
            return true
        case .missingConfiguration:
            return false
        }
    }
}

@MainActor
class StoryViewModel: ObservableObject {
    @Published var generatedStory: Story?
    @Published var isLoading = false
    @Published var isGeneratingImage = false
    @Published var errorMessage: String?
    @Published var generatorState: StoryGeneratorState = .configured
    
    // In a real app, inject this. For MVP, we'll switch based on key presence.
    private var generator: StoryGenerator
    
    init(generator: StoryGenerator? = nil) {
        if let generator {
            self.generator = generator
            self.generatorState = .configured
            return
        }
        
        if let apiKey = AppConfig.geminiAPIKey {
            self.generator = GeminiStoryGenerator(apiKey: apiKey)
            self.generatorState = .configured
        } else {
            #if DEBUG
            self.generator = MockStoryGenerator()
            self.generatorState = .debugMock
            #else
            self.generator = MissingConfigurationStoryGenerator()
            self.generatorState = .missingConfiguration
            #endif
        }
    }
    
    func generateStory(params: StoryParams) {
        guard params.isValid else {
            self.errorMessage = "Lütfen bir konu girin."
            return
        }
        
        guard generatorState.canGenerate else {
            self.errorMessage = generatorState.message ?? "Uygulama yapılandırması eksik."
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        self.generatedStory = nil
        
        Task {
            do {
                var sanitizedParams = params
                sanitizedParams.topic = params.trimmedTopic
                sanitizedParams.heroName = params.trimmedHeroName
                sanitizedParams.moral = params.trimmedMoral
                sanitizedParams.setting = params.trimmedSetting
                
                var story = try await generator.generateStory(params: sanitizedParams)
                self.generatedStory = story
                
                // Generate Image if prompt exists
                if let prompt = story.imagePrompt {
                    self.isGeneratingImage = true
                    let url = try await generator.generateImage(prompt: prompt)
                    story.imageURL = url
                    self.generatedStory = story // Update published property
                    self.isGeneratingImage = false
                }
                
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                self.isGeneratingImage = false
            }
        }
    }
}
