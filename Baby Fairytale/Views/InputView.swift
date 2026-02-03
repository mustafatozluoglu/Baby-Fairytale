import SwiftUI

struct InputView: View {
    @StateObject private var viewModel = StoryViewModel()
    @StateObject private var store = StoryStore()
    @State private var params = StoryParams()
    @State private var showLibrary = false
    @FocusState private var focusedField: Field?
    @State private var selectedSuggestion: String?
    
    private enum Field {
        case topic
        case heroName
        case moral
        case setting
    }
    
    private let suggestions = [
        "Uçan bir balon",
        "Renkli bir gökkuşağı",
        "Minik bir robot",
        "Deniz altı şehri",
        "Sihirli orman"
    ]
    
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
                            if let message = viewModel.generatorState.message {
                                NoticeCard(message: message, systemImage: "info.circle.fill")
                            }
                            
                            InputField(
                                title: "Masal ne hakkında olsun?",
                                placeholder: "örn. Cesur bir astronot",
                                text: $params.topic,
                                icon: "book.fill"
                            )
                            .focused($focusedField, equals: .topic)
                            
                            SuggestionRow(
                                title: "Hızlı Öneriler",
                                suggestions: suggestions,
                                selectedSuggestion: $selectedSuggestion
                            ) { suggestion in
                                params.topic = suggestion
                                focusedField = nil
                            }
                            
                            InputField(
                                title: "Kahramanın Adı",
                                placeholder: "örn. Ali",
                                text: $params.heroName,
                                icon: "person.fill"
                            )
                            .focused($focusedField, equals: .heroName)
                            
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
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Masal Tonu", systemImage: "sparkles")
                                    .font(Theme.Fonts.caption(size: 14))
                                    .foregroundColor(Theme.Colors.text)
                                
                                Picker("Masal Tonu", selection: $params.tone) {
                                    ForEach(StoryTone.allCases) { tone in
                                        Text(tone.rawValue).tag(tone)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(5)
                                .background(Theme.Colors.inputBackground)
                                .cornerRadius(12)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Masal Uzunluğu", systemImage: "text.alignleft")
                                    .font(Theme.Fonts.caption(size: 14))
                                    .foregroundColor(Theme.Colors.text)
                                
                                Picker("Masal Uzunluğu", selection: $params.length) {
                                    ForEach(StoryLength.allCases) { length in
                                        Text(length.rawValue).tag(length)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(5)
                                .background(Theme.Colors.inputBackground)
                                .cornerRadius(12)
                            }
                            
                            InputField(
                                title: "Ana Fikir (İsteğe Bağlı)",
                                placeholder: "örn. Her zaman doğruyu söyle",
                                text: $params.moral,
                                icon: "star.fill"
                            )
                            .focused($focusedField, equals: .moral)
                            
                            InputField(
                                title: "Mekân (İsteğe Bağlı)",
                                placeholder: "örn. Bulutlar şehri",
                                text: $params.setting,
                                icon: "map.fill"
                            )
                            .focused($focusedField, equals: .setting)
                        }
                        .padding(25)
                        .background(Theme.Colors.fallbackCard)
                        .cornerRadius(Theme.Styles.cardCornerRadius)
                        .shadow(color: Color.black.opacity(0.05), radius: Theme.Styles.shadowRadius, x: 0, y: Theme.Styles.shadowY)
                        .padding(.horizontal)
                        
                        // Action Button
                        Button(action: {
                            viewModel.generateStory(params: params)
                            focusedField = nil
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("✨ Sihirli Masal Oluştur")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(!params.isValid || viewModel.isLoading || !viewModel.generatorState.canGenerate)
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
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Tamam") {
                        focusedField = nil
                    }
                }
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
                .textInputAutocapitalization(.sentences)
                .disableAutocorrection(false)
                .foregroundColor(.black) // Ensure input text is visible
        }
    }
}

struct NoticeCard: View {
    let message: String
    let systemImage: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .foregroundColor(Theme.Colors.fallbackSecondary)
                .font(.title3)
            
            Text(message)
                .font(Theme.Fonts.caption(size: 14))
                .foregroundColor(Theme.Colors.text)
            
            Spacer(minLength: 0)
        }
        .padding()
        .background(Theme.Colors.inputBackground)
        .cornerRadius(16)
    }
}

struct SuggestionRow: View {
    let title: String
    let suggestions: [String]
    @Binding var selectedSuggestion: String?
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Theme.Fonts.caption(size: 13))
                .foregroundColor(Theme.Colors.text)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button(action: {
                            selectedSuggestion = suggestion
                            onSelect(suggestion)
                        }) {
                            Text(suggestion)
                                .font(Theme.Fonts.caption(size: 13))
                                .foregroundColor(selectedSuggestion == suggestion ? .white : Theme.Colors.fallbackAccent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedSuggestion == suggestion ? Theme.Colors.fallbackSecondary : Theme.Colors.inputBackground)
                                )
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}
