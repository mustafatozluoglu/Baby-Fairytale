import Foundation
import os

class StoryStore: ObservableObject {
    @Published var savedStories: [Story] = []
    
    private let fileName = "saved_stories.json"
    private let logger = Logger(subsystem: "BabyFairytale", category: "StoryStore")
    
    init() {
        loadStories()
    }
    
    private var fileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(fileName)
    }
    
    func saveStory(_ story: Story) {
        // Check if already saved
        if !savedStories.contains(where: { $0.id == story.id }) {
            savedStories.insert(story, at: 0)
            persist()
        }
    }
    
    func deleteStory(_ story: Story) {
        savedStories.removeAll { $0.id == story.id }
        persist()
    }
    
    private func persist() {
        do {
            let data = try JSONEncoder().encode(savedStories)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            logger.error("Failed to save stories: \(error.localizedDescription)")
        }
    }
    
    private func loadStories() {
        do {
            let data = try Data(contentsOf: fileURL)
            savedStories = try JSONDecoder().decode([Story].self, from: data)
        } catch {
            logger.info("Failed to load stories (might be first run): \(error.localizedDescription)")
            savedStories = []
        }
    }
}
