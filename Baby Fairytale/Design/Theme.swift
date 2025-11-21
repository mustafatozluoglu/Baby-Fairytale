import SwiftUI

struct Theme {
    struct Colors {
        static let background = Color("Background")
        static let primary = Color("Primary")
        static let secondary = Color("Secondary")
        static let accent = Color("Accent")
        static let text = Color(hex: "2C3E50") // Dark Blue-Gray for high contrast
        static let cardBackground = Color.white.opacity(0.95) // Higher opacity for readability
        static let inputBackground = Color(hex: "F0F2F5") // Light gray for inputs
        
        // Fallbacks if assets aren't created yet
        static let fallbackBackground = LinearGradient(gradient: Gradient(colors: [Color(hex: "F5F7FA"), Color(hex: "C3CFE2")]), startPoint: .top, endPoint: .bottom) // Very light grey/blue
        static let fallbackPrimary = Color(hex: "E74C3C") // Strong Red/Orange
        static let fallbackSecondary = Color(hex: "3498DB") // Strong Blue
        static let fallbackAccent = Color(hex: "2C3E50") // Dark Navy for text/icons
        static let fallbackCard = Color.white // Pure white for cards
    }
    
    struct Fonts {
        static func title(size: CGFloat = 34) -> Font {
            .system(size: size, weight: .heavy, design: .rounded)
        }
        
        static func body(size: CGFloat = 17) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }
        
        static func caption(size: CGFloat = 12) -> Font {
            .system(size: size, weight: .regular, design: .rounded)
        }
    }
    
    struct Styles {
        static let cardCornerRadius: CGFloat = 24
        static let shadowRadius: CGFloat = 10
        static let shadowY: CGFloat = 5
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Theme.Colors.fallbackPrimary)
            .foregroundColor(.white)
            .font(Theme.Fonts.body(size: 18))
            .cornerRadius(Theme.Styles.cardCornerRadius)
            .shadow(color: Theme.Colors.fallbackPrimary.opacity(0.4), radius: 10, x: 0, y: 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}
