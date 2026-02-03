import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var store: StoryStore
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.fallbackBackground
                    .ignoresSafeArea()
                
                if filteredStories.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "books.vertical")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text(searchText.isEmpty ? "Henüz kaydedilmiş masal yok." : "Aramanıza uygun masal bulunamadı.")
                            .font(Theme.Fonts.body())
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(filteredStories) { story in
                            NavigationLink(destination: StoryView(story: story)) {
                                StoryRowCard(story: story)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                let story = filteredStories[index]
                                store.deleteStory(story)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Kütüphanem")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Masal ara")
        }
    }
    
    private var filteredStories: [Story] {
        let base = store.savedStories.sorted(by: { $0.createdAt > $1.createdAt })
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return base
        }
        return base.filter { story in
            story.title.localizedCaseInsensitiveContains(searchText)
            || story.content.localizedCaseInsensitiveContains(searchText)
            || story.topic.localizedCaseInsensitiveContains(searchText)
        }
    }
}

struct StoryRowCard: View {
    let story: Story
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(story.title)
                .font(Theme.Fonts.body(size: 18))
                .foregroundColor(Theme.Colors.text)
            
            Text(story.content.prefix(80) + "...")
                .font(Theme.Fonts.caption())
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                StoryMetaChip(text: story.ageGroup.rawValue, systemImage: "figure.child")
                StoryMetaChip(text: story.tone.rawValue, systemImage: "sparkles")
            }
            
            Text(Self.dateFormatter.string(from: story.createdAt))
                .font(Theme.Fonts.caption(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
