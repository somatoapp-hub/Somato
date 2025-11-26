import SwiftUI

// MARK: - Splash View
struct SplashView: View {
    var onFinish: () -> Void
    @State private var glow: Bool = false
    @State private var isDone: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("Somato")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
                .shadow(color: Color.white.opacity(glow ? 0.95 : 0.0), radius: glow ? 28 : 0, x: 0, y: 0)
                .scaleEffect(glow ? 1.08 : 1.0)
        }
        .onAppear {
            Task {
                guard !isDone else { return }
                // Herzschlag 1 (insgesamt ~0.8s)
                withAnimation(.easeInOut(duration: 0.4)) { glow = true }
                try? await Task.sleep(nanoseconds: 400_000_000)
                withAnimation(.easeInOut(duration: 0.4)) { glow = false }

                // kurze Pause zwischen den Schlägen
                try? await Task.sleep(nanoseconds: 350_000_000)

                // Herzschlag 2 (insgesamt ~0.8s)
                withAnimation(.easeInOut(duration: 0.4)) { glow = true }
                try? await Task.sleep(nanoseconds: 400_000_000)
                withAnimation(.easeInOut(duration: 0.4)) { glow = false }

                // sanft ausklingen lassen
                try? await Task.sleep(nanoseconds: 600_000_000)
                if !isDone {
                    isDone = true
                    onFinish()
                }
            }
        }
    }
}

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

    @State private var showSplash: Bool = true

    // Heights for the bottom sheet
    enum Detent: CGFloat, CaseIterable {
        case collapsed = 120   // nur Griff + Titel
        case expanded = 560    // voll sichtbar

        static func next(after detent: Detent) -> Detent {
            switch detent {
            case .collapsed: return .expanded
            case .expanded: return .expanded
            }
        }

        static func previous(before detent: Detent) -> Detent {
            switch detent {
            case .collapsed: return .collapsed
            case .expanded: return .collapsed
            }
        }
    }

    var body: some View {
        ZStack {
            if showSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
            } else {
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
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
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
                    .navigationTitle("Somato")
                }
                .transition(.opacity)
            }
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
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        ForEach(categories, id: \.name) { item in
                            NavigationLink(destination: destinationView(for: item)) {
                                CategoryCard(name: item.name, icon: item.icon, color: item.color)
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

    @ViewBuilder
    private func destinationView(for item: (name: String, icon: String, color: Color)) -> some View {
        switch item.name {
        case "Zellphysiologie": ZellphysiologieView(bgColor: item.color)
        case "Organphysiologie": OrganphysiologieView(bgColor: item.color)
        case "Neurophysiologie": NeurophysiologieView(bgColor: item.color)
        case "Strukturbiologie": StrukturbiologieView(bgColor: item.color)
        case "Stoffwechsel und Endokrinologie": StoffwechselEndokrinologieView(bgColor: item.color)
        case "Molekularbiologie": MolekularbiologieView(bgColor: item.color)
        default:
            GenericCategoryView(title: item.name, bgColor: item.color)
        }
    }
}

// MARK: - Category Card
private struct CategoryCard: View {
    let name: String
    let icon: String
    let color: Color

    private let cardHeight: CGFloat = 110

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.white)
            Text(name)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .background(color)
        .cornerRadius(15)
        .shadow(color: color.opacity(0.35), radius: 6, x: 0, y: 6)
    }
}

// MARK: - Utilities
private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

// MARK: - Button Style für kleine Animation beim Tippen
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

// MARK: - Kategorie-Detail-Views
private struct CategoryBaseView: View {
    let title: String
    let bgColor: Color
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            VStack(spacing: 24) {
                Text(title)
                    .font(.largeTitle).bold()
                    .foregroundStyle(.white)
                HStack(spacing: 16) {
                    Button("Duell") {
                        print("Duell gestartet: \(title)")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.black.opacity(0.25))
                    .clipShape(Capsule())

                    Button("Einzelkampf") {
                        print("Einzelkampf gestartet: \(title)")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.black.opacity(0.25))
                    .clipShape(Capsule())
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ZellphysiologieView: View { let bgColor: Color; var body: some View { CategoryBaseView(title: "Zellphysiologie", bgColor: bgColor) } }
private struct OrganphysiologieView: View { let bgColor: Color; var body: some View { CategoryBaseView(title: "Organphysiologie", bgColor: bgColor) } }
private struct NeurophysiologieView: View { let bgColor: Color; var body: some View { CategoryBaseView(title: "Neurophysiologie", bgColor: bgColor) } }
private struct StrukturbiologieView: View { let bgColor: Color; var body: some View { CategoryBaseView(title: "Strukturbiologie", bgColor: bgColor) } }
private struct StoffwechselEndokrinologieView: View { let bgColor: Color; var body: some View { CategoryBaseView(title: "Stoffwechsel und Endokrinologie", bgColor: bgColor) } }
private struct MolekularbiologieView: View { let bgColor: Color; var body: some View { CategoryBaseView(title: "Molekularbiologie", bgColor: bgColor) } }

private struct GenericCategoryView: View { let title: String; let bgColor: Color; var body: some View { CategoryBaseView(title: title, bgColor: bgColor) } }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
