import Foundation

class StoryStore: ObservableObject {
    @Published var savedStories: [Story] = []
    
    private let fileName = "saved_stories.json"
    
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
            try data.write(to: fileURL)
        } catch {
            print("Failed to save stories: \(error)")
        }
    }
    
    private func loadStories() {
        do {
            let data = try Data(contentsOf: fileURL)
            savedStories = try JSONDecoder().decode([Story].self, from: data)
        } catch {
            print("Failed to load stories (might be first run): \(error)")
            savedStories = []
        }
    }
}
