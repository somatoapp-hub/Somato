import SwiftUI

public enum AppColors {
    // Brand & Primary UI
    public static var brandPrimary: Color { Color(hex: "#0EA5E9") }    // Example: Cyan/Blue
    public static var brandSecondary: Color { Color(hex: "#7C3AED") }  // Example: Indigo/Purple

    // Backgrounds
    public static var background: Color { Color(hex: "#0B0B0B") }       // Example: near-black background
    public static var surface: Color { Color(hex: "#111214") }          // Example: elevated surface
    public static var surfaceAlt: Color { Color(hex: "#1A1B1E") }       // Example: alternate surface

    // Text
    public static var textPrimary: Color { Color(hex: "#FFFFFF") }      // White
    public static var textSecondary: Color { Color(hex: "#B3B8C2") }    // Muted gray-blue

    // Status
    public static var success: Color { Color(hex: "#22C55E") }
    public static var warning: Color { Color(hex: "#F59E0B") }
    public static var error: Color { Color(hex: "#EF4444") }

    // Accents (you can map your existing category colors progressively)
    public static var accentBlue: Color { Color(hex: "#3B82F6") }
    public static var accentCyan: Color { Color(hex: "#06B6D4") }
    public static var accentTeal: Color { Color(hex: "#14B8A6") }
    public static var accentIndigo: Color { Color(hex: "#6366F1") }
    public static var accentPurple: Color { Color(hex: "#A855F7") }
    public static var accentOrange: Color { Color(hex: "#F97316") }
    public static var accentRed: Color { Color(hex: "#EF4444") }
}

public extension Color {
    /// Initialize a Color from a HEX string like "#RRGGBB" or "RRGGBBAA".
    init(hex: String) {
        let r, g, b, a: Double

        // Remove non-hex characters (# or spaces)
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") { hexString.removeFirst() }

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        switch hexString.count {
        case 6: // RRGGBB
            r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            b = Double(rgbValue & 0x0000FF) / 255.0
            a = 1.0
        case 8: // RRGGBBAA
            r = Double((rgbValue & 0xFF000000) >> 24) / 255.0
            g = Double((rgbValue & 0x00FF0000) >> 16) / 255.0
            b = Double((rgbValue & 0x0000FF00) >> 8) / 255.0
            a = Double(rgbValue & 0x000000FF) / 255.0
        default:
            // Fallback to clear if invalid
            r = 0; g = 0; b = 0; a = 0
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

/*
How to customize step by step:
- Replace the HEX strings above with your desired colors.
- Use AppColors.* throughout the app instead of hard-coded Color values.
- You can also create Color Assets in the Asset Catalog and reference them with Color("AssetName"). If you prefer assets, mirror these names as color sets and switch the properties to return Color("AssetName").
*/
