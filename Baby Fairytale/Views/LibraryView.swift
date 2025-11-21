import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var store: StoryStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.fallbackBackground
                    .ignoresSafeArea()
                
                if store.savedStories.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "books.vertical")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Henüz kaydedilmiş masal yok.")
                            .font(Theme.Fonts.body())
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(store.savedStories) { story in
                            NavigationLink(destination: StoryView(story: story)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(story.title)
                                            .font(Theme.Fonts.body(size: 18))
                                            .foregroundColor(Theme.Colors.text)
                                        
                                        Text(story.content.prefix(50) + "...")
                                            .font(Theme.Fonts.caption())
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                store.deleteStory(store.savedStories[index])
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
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
