import Foundation
import SwiftUI

@MainActor
class StoryViewModel: ObservableObject {
    @Published var generatedStory: Story?
    @Published var isLoading = false
    @Published var isGeneratingImage = false
    @Published var errorMessage: String?
    
    // In a real app, inject this. For MVP, we'll switch based on key presence.
    private var generator: StoryGenerator
    
    init() {
        // Use Gemini Generator with the user provided key
        self.generator = GeminiStoryGenerator(apiKey: "AIzaSyBCZUd3XmYb1iRAL-D5UqF0X4iEB1qNly4")
    }
    
    func generateStory(params: StoryParams) {
        guard !params.topic.isEmpty else {
            self.errorMessage = "Please enter a topic."
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        self.generatedStory = nil
        
        Task {
            do {
                var story = try await generator.generateStory(params: params)
                self.generatedStory = story
                self.isLoading = false
                
                // Generate Image if prompt exists
                if let prompt = story.imagePrompt {
                    self.isGeneratingImage = true
                    let url = try await generator.generateImage(prompt: prompt)
                    story.imageURL = url
                    self.generatedStory = story // Update published property
                    self.isGeneratingImage = false
                }
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                self.isGeneratingImage = false
            }
        }
    }
}
