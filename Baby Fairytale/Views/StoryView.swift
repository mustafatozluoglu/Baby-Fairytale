import SwiftUI

struct StoryView: View {
    let story: Story
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: StoryStore
    @StateObject private var audioService = AudioService()
    @State private var isSaved = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.fallbackBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Image Placeholder / Generated Image
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            
                            if let imageURL = story.imageURL {
                                AsyncImage(url: imageURL) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 250)
                                            .clipped()
                                            .cornerRadius(20)
                                    case .failure:
                                        Image(systemName: "photo.artframe")
                                            .font(.system(size: 50))
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else if let imagePrompt = story.imagePrompt {
                                VStack {
                                    Image(systemName: "photo.artframe")
                                        .font(.system(size: 50))
                                        .foregroundColor(Theme.Colors.fallbackAccent)
                                        .padding(.bottom, 5)
                                    
                                    Text("Resim hazırlanıyor...")
                                        .font(Theme.Fonts.caption())
                                        .foregroundColor(.secondary)
                                    
                                    Text(imagePrompt)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                        .lineLimit(2)
                                }
                                .padding()
                            }
                        }
                        .frame(height: 250)
                        .padding(.horizontal)
                        
                        // Story Content
                        VStack(alignment: .leading, spacing: 15) {
                            Text(story.title)
                                .font(Theme.Fonts.title(size: 28))
                                .foregroundColor(Theme.Colors.fallbackAccent)
                                .multilineTextAlignment(.leading)
                            
                            Text(story.content)
                                .font(Theme.Fonts.body(size: 18))
                                .foregroundColor(Theme.Colors.text)
                                .lineSpacing(8)
                        }
                        .padding(25)
                        .background(Theme.Colors.fallbackCard)
                        .cornerRadius(Theme.Styles.cardCornerRadius)
                        .shadow(color: Color.black.opacity(0.05), radius: Theme.Styles.shadowRadius, x: 0, y: Theme.Styles.shadowY)
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            if audioService.isSpeaking {
                                audioService.stop()
                            } else {
                                audioService.speak(text: story.content, language: story.language)
                            }
                        }) {
                            Image(systemName: audioService.isSpeaking ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.title2)
                                .foregroundColor(Theme.Colors.fallbackAccent)
                        }
                        
                        Button(action: {
                            store.saveStory(story)
                            isSaved = true
                        }) {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                .font(.title2)
                                .foregroundColor(Theme.Colors.fallbackAccent)
                        }
                        .disabled(isSaved)
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(Theme.Colors.fallbackAccent)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    StoryView(story: Story(title: "The Magic Bunny", content: "Once upon a time...", imagePrompt: "A bunny with a magic wand", language: "en-US"))
}
