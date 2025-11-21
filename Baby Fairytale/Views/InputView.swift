import SwiftUI

struct InputView: View {
    @StateObject private var viewModel = StoryViewModel()
    @StateObject private var store = StoryStore()
    @State private var params = StoryParams()
    @State private var showLibrary = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.fallbackBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 60))
                                .foregroundColor(Theme.Colors.fallbackAccent)
                                .padding(.bottom, 10)
                            
                            Text("Bebek Masalları")
                                .font(Theme.Fonts.title())
                                .foregroundColor(Theme.Colors.fallbackAccent)
                            
                            Text("Çocuğunuz için sihirli masallar oluşturun")
                                .font(Theme.Fonts.caption(size: 16))
                                .foregroundColor(Theme.Colors.text)
                        }
                        .padding(.top, 40)
                        
                        // Input Card
                        VStack(spacing: 20) {
                            InputField(title: "Masal ne hakkında olsun?", placeholder: "örn. Cesur bir astronot", text: $params.topic, icon: "book.fill")
                            
                            InputField(title: "Kahramanın Adı", placeholder: "örn. Ali", text: $params.heroName, icon: "person.fill")
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Yaş Grubu", systemImage: "figure.child")
                                    .font(Theme.Fonts.caption(size: 14))
                                    .foregroundColor(Theme.Colors.text)
                                
                                Picker("Yaş Grubu", selection: $params.ageGroup) {
                                    ForEach(AgeGroup.allCases) { age in
                                        Text(age.rawValue).tag(age)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(5)
                                .background(Theme.Colors.inputBackground)
                                .cornerRadius(12)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Dil", systemImage: "globe")
                                    .font(Theme.Fonts.caption(size: 14))
                                    .foregroundColor(Theme.Colors.text)
                                
                                Picker("Dil", selection: $params.language) {
                                    ForEach(StoryLanguage.allCases) { language in
                                        Text(language.rawValue).tag(language)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(5)
                                .background(Theme.Colors.inputBackground)
                                .cornerRadius(12)
                            }
                            
                            InputField(title: "Ana Fikir (İsteğe Bağlı)", placeholder: "örn. Her zaman doğruyu söyle", text: $params.moral, icon: "star.fill")
                        }
                        .padding(25)
                        .background(Theme.Colors.fallbackCard)
                        .cornerRadius(Theme.Styles.cardCornerRadius)
                        .shadow(color: Color.black.opacity(0.05), radius: Theme.Styles.shadowRadius, x: 0, y: Theme.Styles.shadowY)
                        .padding(.horizontal)
                        
                        // Action Button
                        Button(action: {
                            viewModel.generateStory(params: params)
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("✨ Sihirli Masal Oluştur")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(params.topic.isEmpty || viewModel.isLoading)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $viewModel.generatedStory) { story in
                StoryView(story: story)
                    .environmentObject(store)
            }
            .alert("Hata!", isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Bilinmeyen hata")
            }
            .overlay(
                HStack {
                    Button(action: { showLibrary.toggle() }) {
                        Image(systemName: "books.vertical.fill")
                            .font(.title2)
                            .foregroundColor(Theme.Colors.fallbackAccent)
                            .padding()
                            .background(Theme.Colors.fallbackCard)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    Spacer()
                }
                .padding()
                , alignment: .top
            )
            .sheet(isPresented: $showLibrary) {
                LibraryView()
                    .environmentObject(store)
            }
        }
    }
}

struct InputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(Theme.Fonts.caption(size: 14))
                .foregroundColor(Theme.Colors.text)
            
            TextField(placeholder, text: $text)
                .padding()
                .background(Theme.Colors.inputBackground)
                .cornerRadius(12)
                .font(Theme.Fonts.body())
                .foregroundColor(.black) // Ensure input text is visible
        }
    }
}
