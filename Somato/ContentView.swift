import SwiftUI

struct ContentView: View {
    // Kategorien mit Icons
    let categories: [(name: String, icon: String, color: Color)] = [
        ("Zellphysiologie", "circle.grid.3x3.fill", .teal),
        ("Organphysiologie", "heart.text.square.fill", .red),
        ("Neurophysiologie", "brain.head.profile", .indigo),
        ("Strukturbiologie", "cube.transparent.fill", .blue),
        ("Stoffwechsel und Endokrinologie", "pills.fill", .orange),
        ("Molekularbiologie", "link", .purple)
    ]

    // Sheet state
    @State private var sheetOffset: CGFloat = 0
    @State private var currentDetent: Detent = .collapsed

    // Heights for the bottom sheet
    enum Detent: CGFloat, CaseIterable {
        case collapsed = 120   // nur Griff + Titel
        case medium = 320      // halbe Höhe
        case expanded = 560    // fast voll

        static func next(after detent: Detent) -> Detent {
            let all = Detent.allCases
            if let idx = all.firstIndex(of: detent), idx < all.count - 1 {
                return all[idx + 1]
            }
            return detent
        }

        static func previous(before detent: Detent) -> Detent {
            let all = Detent.allCases
            if let idx = all.firstIndex(of: detent), idx > 0 {
                return all[idx - 1]
            }
            return detent
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Hintergrund
                Color(.systemBackground)
                    .ignoresSafeArea()

                // Quick Match Button zentriert
                VStack {
                    Spacer()
                    Button(action: {
                        quickMatch()
                    }) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .font(.title2)
                            Text("Quick Match")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 320)
                        .background(LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing))
                        .cornerRadius(18)
                        .shadow(color: .gray.opacity(0.35), radius: 8, x: 0, y: 8)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    Spacer()
                }
                .padding(.horizontal)

                // Swipe-up Bottom Sheet für Kategorien
                BottomCategoriesSheet(
                    categories: categories,
                    currentDetent: $currentDetent
                )
                .ignoresSafeArea(edges: .bottom)
            }
            .navigationTitle("Home")
        }
    }

    // MARK: - Funktionen
    func quickMatch() {
        print("Quick Match gestartet")
    }

    func selectCategory(_ category: String) {
        print("Kategorie ausgewählt: \(category)")
    }
}

// MARK: - Bottom Sheet für Kategorien mit Drag-Geste
private struct BottomCategoriesSheet: View {
    let categories: [(name: String, icon: String, color: Color)]

    @Binding var currentDetent: ContentView.Detent
    @State private var translation: CGFloat = 0

    private var cornerRadius: CGFloat { 24 }

    var body: some View {
        GeometryReader { proxy in
            let maxHeight = min(proxy.size.height * 0.9, ContentView.Detent.expanded.rawValue)
            let heights: [ContentView.Detent: CGFloat] = [
                .collapsed: ContentView.Detent.collapsed.rawValue,
                .medium: min(maxHeight, ContentView.Detent.medium.rawValue),
                .expanded: maxHeight
            ]
            let targetHeight = heights[currentDetent, default: ContentView.Detent.collapsed.rawValue]

            VStack(spacing: 0) {
                // Griff-Leiste
                Capsule()
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 44, height: 6)
                    .padding(.top, 8)
                    .padding(.bottom, 8)

                Text("Kategorien")
                    .font(.headline)
                    .padding(.bottom, 8)

                Divider()

                // Inhalt: Kategorien Grid
                ScrollView {
                    HStack(alignment: .top, spacing: 16) {
                        // Linke Spalte: Zellphysiologie, Organphysiologie, Neurophysiologie
                        VStack(spacing: 16) {
                            ForEach(categories.prefix(3), id: \.name) { category in
                                Button(action: {
                                    NotificationCenter.default.post(name: .categorySelected, object: category.name)
                                }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: category.icon)
                                            .font(.system(size: 28))
                                            .foregroundColor(.white)
                                        Text(category.name)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(category.color)
                                    .cornerRadius(15)
                                    .shadow(color: category.color.opacity(0.35), radius: 6, x: 0, y: 6)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                        // Rechte Spalte: Strukturbiologie, Stoffwechsel und Endokrinologie, Molekularbiologie
                        VStack(spacing: 16) {
                            ForEach(categories.suffix(3), id: \.name) { category in
                                Button(action: {
                                    NotificationCenter.default.post(name: .categorySelected, object: category.name)
                                }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: category.icon)
                                            .font(.system(size: 28))
                                            .foregroundColor(.white)
                                        Text(category.name)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(category.color)
                                    .cornerRadius(15)
                                    .shadow(color: category.color.opacity(0.35), radius: 6, x: 0, y: 6)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
            .frame(width: proxy.size.width, height: targetHeight + translation, alignment: .top)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThickMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.secondary.opacity(0.12))
            )
            .frame(maxHeight: .infinity, alignment: .bottom)
            .gesture(dragGesture(heights: heights))
            .onReceive(NotificationCenter.default.publisher(for: .categorySelected)) { output in
                if let name = output.object as? String {
                    print("Kategorie ausgewählt: \(name)")
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: currentDetent)
            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: translation)
        }
    }

    private func dragGesture(heights: [ContentView.Detent: CGFloat]) -> some Gesture {
        DragGesture(minimumDistance: 5)
            .onChanged { value in
                let dy = value.translation.height
                // Nach oben ziehen => negative height => sheet soll größer werden (also translation nach oben ist negativ)
                translation = -dy.clamped(to: -120...120)
            }
            .onEnded { value in
                let dy = value.translation.height
                let velocity = value.velocity.height

                // Heuristik: Richtung und Geschwindigkeit bestimmen neuen Zustand
                let isUp = dy < -40 || velocity < -800
                let isDown = dy > 40 || velocity > 800

                if isUp {
                    currentDetent = ContentView.Detent.next(after: currentDetent)
                } else if isDown {
                    currentDetent = ContentView.Detent.previous(before: currentDetent)
                }
                translation = 0
            }
    }
}

// MARK: - Utilities
private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

private extension Notification.Name {
    static let categorySelected = Notification.Name("categorySelected")
}

// MARK: - Button Style für kleine Animation beim Tippen
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
