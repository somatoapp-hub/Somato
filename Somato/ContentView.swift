import SwiftUI
// Uses AppColors for centralized theming

// MARK: - Splash View
struct SplashView: View {
    var onFinish: () -> Void
    @State private var glow: Bool = false
    @State private var isDone: Bool = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            Text("Somato")
                .font(.system(size: 58, weight: .bold, design: .rounded))
                .tracking(5)
                .foregroundStyle(AppColors.textPrimary)
                .shadow(color: AppColors.textPrimary.opacity(glow ? 0.95 : 0.0), radius: glow ? 28 : 0, x: 0, y: 0)
                .scaleEffect(glow ? 1.08 : 1.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
        ("Zellphysiologie", "circle.grid.3x3.fill", AppColors.categoryZellphysiologie),
        ("Organphysiologie", "heart.text.square.fill", AppColors.categoryOrganphysiologie),
        ("Neurophysiologie", "brain.head.profile", AppColors.categoryNeurophysiologie),
        ("Strukturbiologie", "cube.transparent.fill", AppColors.categoryStrukturbiologie),
        ("Stoffwechsel und Endokrinologie", "pills.fill", AppColors.categoryStoffwechselEndokrinologie),
        ("Molekularbiologie", "link", AppColors.categoryMolekularbiologie)
    ]

    let semesterOptions: [String] = (1...12).map { "\($0). Semester" } + ["Approbation"]
    
    @State private var showSplash: Bool = true
    @State private var showIntroImage: Bool = false
    @State private var loadingProgress: CGFloat = 0.0
    @State private var isLoading: Bool = false
    @State private var showRankings: Bool = false

    @State private var level: Int = 6
    @State private var xpProgress: CGFloat = 0.45
    @State private var coins: Int = 14847
    @AppStorage("selectedSemesterIndex") private var selectedSemesterIndex: Int = 0

    var body: some View {
        ZStack {
            if showSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        showSplash = false
                        showIntroImage = true
                    }
                }
                .transition(.opacity)
            } else if showIntroImage {
                // Intermediate intro image screen (full-screen)
                ZStack(alignment: .bottom) {
                    // Slightly shift the image to the left
                    Image("intro_fullscreen")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .offset(x: -18) // move a bit to the left

                    // Loading bar at the bottom
                    VStack(spacing: 10) {
                        // Optional label
                        Text("Lädt...")
                            .font(.footnote)
                            .foregroundStyle(AppColors.textPrimary.opacity(0.85))

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color.white.opacity(0.22))
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(LinearGradient(colors: [AppColors.accentCyan, AppColors.accentBlue], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: geo.size.width * loadingProgress)
                            }
                        }
                        .frame(height: 14)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                }
                .onAppear {
                    // Start loading animation over ~5 seconds
                    guard !isLoading else { return }
                    isLoading = true
                    loadingProgress = 0.0
                    withAnimation(.linear(duration: 5.0)) {
                        loadingProgress = 1.0
                    }
                    // After the animation completes, switch to main view
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            showIntroImage = false
                        }
                    }
                }
                .transition(.opacity)
            } else {
                NavigationView {
                    ZStack {
                        AppColors.mainBackgroundLight
                            .ignoresSafeArea()

                        VStack(spacing: 0) {
                            TopHUD(level: level, xpProgress: xpProgress, coins: coins, semesterOptions: semesterOptions, selectedSemesterIndex: $selectedSemesterIndex) {
                                // coin plus tapped
                            }
                            .padding(.top, 8)
                            .padding(.horizontal, 12)
                            .padding(.bottom, 4)
                            Spacer(minLength: 0)
                        }
                        .zIndex(1)

                        NavigationLink(destination: RankingsView(), isActive: $showRankings) { EmptyView() }

                        ScrollView {
                            VStack(spacing: 24) {
                                // Header / Intro section with emblem and Quick Match under it
                                ZStack {
                                    VStack(spacing: 12) {
                                        Spacer(minLength: 0)
                                            .frame(height: 180)
                                        // Emblem image centered on screen
                                        Group {
                                            #if canImport(UIKit)
                                            if UIImage(named: "player_emblem") != nil {
                                                Button {
                                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                                                        // trigger a tiny pulse by toggling a local state via scaleEffect animation handled below
                                                    }
                                                    showRankings = true
                                                } label: {
                                                    Image("player_emblem")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 200)
                                                        .padding(.horizontal)
                                                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                                                }
                                                .buttonStyle(ScaleButtonStyle())
                                            } else {
                                                Button { showRankings = true } label: {
                                                    Image(systemName: "photo")
                                                        .font(.system(size: 44, weight: .bold))
                                                        .foregroundStyle(.secondary)
                                                        .frame(height: 100)
                                                        .padding(.horizontal)
                                                }
                                                .buttonStyle(ScaleButtonStyle())
                                            }
                                            #else
                                            Button { showRankings = true } label: {
                                                Image("player_emblem")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 200)
                                                    .padding(.horizontal)
                                                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                                            }
                                            .buttonStyle(ScaleButtonStyle())
                                            #endif
                                        }

                                        // Quick Match directly below with small spacing
                                        Button(action: { quickMatch() }) {
                                            HStack(spacing: 10) {
                                                Image(systemName: "bolt.fill")
                                                    .font(.system(size: 24, weight: .bold))
                                                Text("Quick Match")
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                            }
                                            .foregroundColor(.white)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 20)
                                            .background(LinearGradient(colors: [AppColors.quickMatchStart, AppColors.quickMatchEnd], startPoint: .leading, endPoint: .trailing))
                                            .cornerRadius(16)
                                            .shadow(color: .gray.opacity(0.25), radius: 6, x: 0, y: 6)
                                        }
                                        .buttonStyle(ScaleButtonStyle())
                                        Spacer()
                                    }
                                }
                                //frame(height: UIScreen.main.bounds.height)

                                // Kategorien Grid (scrolls naturally)
                                // Push categories far below the fold so they are only reachable by scrolling
                                Spacer(minLength: 0)
                                    .frame(height: 120)

                                VStack(alignment: .leading, spacing: 12) {
                                    // Removed the "Kategorien" label as requested
                                    LazyVGrid(columns: [
                                        GridItem(.flexible(), spacing: 16),
                                        GridItem(.flexible(), spacing: 16)
                                    ], spacing: 16) {
                                        ForEach(categories, id: \.name) { item in
                                            NavigationLink(destination: destinationView(for: item)) {
                                                CategoryCard(name: item.name, icon: item.icon, color: item.color)
                                            }
                                        }
                                    }
                                    .padding(.top, 8)
                                    .padding(.horizontal)
                                    .padding(.bottom, 24)
                                }
                            }
                        }
                        .zIndex(0)
                    }
                    // Removed navigation title "Somato"
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

// MARK: - Top HUD
private struct TopHUD: View {
    let level: Int
    let xpProgress: CGFloat
    let coins: Int
    let semesterOptions: [String]
    @Binding var selectedSemesterIndex: Int
    var onAddCoins: () -> Void

    @State private var showConfetti: Bool = false
    @State private var confettiTrigger: Int = 0

    @State private var hasInitializedSelection: Bool = false
    @State private var initialIndex: Int? = nil

    var body: some View {
        HStack(spacing: 10) {
            // Left: Level badge with thin progress
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(.blue)
                        .frame(width: 28, height: 28)
                        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                    Text("\(level)")
                        .font(.caption).bold()
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.secondary.opacity(0.18))
                        Capsule().fill(LinearGradient(colors: [AppColors.success, AppColors.accentTeal], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 84 * xpProgress.clamped(to: 0...1), height: 4)
                    }
                    .frame(width: 84, height: 4)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())

            Spacer(minLength: 8)

            // Middle: Coins with plus
            HStack(spacing: 8) {
                Image(systemName: "creditcard.circle.fill")
                    .foregroundStyle(.yellow)
                    .font(.system(size: 18))
                Text("\(coins)")
                    .font(.subheadline).bold()
                Button(action: onAddCoins) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)

            Spacer(minLength: 8)

            // Right: Semester badge as Menu opening a drop-down
            Menu {
                // Build list of semesters as selectable items
                ForEach(semesterOptions.indices, id: \.self) { idx in
                    Button(action: {
                        let previous = selectedSemesterIndex
                        selectedSemesterIndex = idx
                        if hasInitializedSelection && idx > previous {
                            confettiTrigger += 1
                        }
                    }) {
                        HStack {
                            Text(semesterOptions[idx])
                            if idx == selectedSemesterIndex {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.blue)
                    Text(semesterOptions[selectedSemesterIndex])
                        .font(.caption).bold()
                        .foregroundStyle(.white)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .frame(minHeight: 32)
                .contentShape(Rectangle())
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)
                .allowsHitTesting(true)
            }
            // Removed .buttonStyle(.plain) here as requested
        }
        .task {
            if initialIndex == nil {
                initialIndex = selectedSemesterIndex
                hasInitializedSelection = true
            }
        }
        .overlay(
            Group {
                if confettiTrigger > 0 {
                    ConfettiView(trigger: $confettiTrigger)
                }
            }
        )
    }
}

private struct ConfettiView: View {
    @Binding var trigger: Int
    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { i in
                ConfettiParticle()
                    .offset(x: CGFloat(Int.random(in: -80...80)), y: -120)
                    .animation(.interpolatingSpring(stiffness: 80, damping: 12).delay(Double(i) * 0.02), value: trigger)
            }
        }
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, _ in }
    }
}

private struct ConfettiParticle: View {
    @State private var y: CGFloat = -120
    @State private var rotation: Angle = .degrees(0)
    var body: some View {
        Rectangle()
            .fill([Color.red, .blue, .green, .orange, .pink, .purple, .yellow].randomElement()!)
            .frame(width: CGFloat(Int.random(in: 6...10)), height: CGFloat(Int.random(in: 8...16)))
            .rotationEffect(rotation)
            .onAppear {
                withAnimation(.easeIn(duration: Double.random(in: 0.9...1.4))) {
                    y = 160
                    rotation = .degrees(Double.random(in: 180...540))
                }
            }
            .offset(y: y)
            .opacity(y < 140 ? 1 : 0)
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
                .foregroundStyle(AppColors.textPrimary)
            Text(name)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.textPrimary)
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


// Replaced QuestionView:
private struct QuestionView: View {
    let categoryTitle: String
    let subcategory: String

    struct Question: Identifiable, Hashable {
        let id = UUID()
        let text: String
        let answers: [String]
        let correctIndex: Int
    }

    @Environment(\.dismiss) private var dismiss

    // Selected state per question replaced by single-question flow state:
    @State private var currentIndex: Int = 0
    @State private var selectedIndex: Int? = nil

    // Provide questions based on context
    private var questions: [Question] {
        // If the subcategory is our custom Endokrinologie inside Organphysiologie, return the requested set
        if categoryTitle == "Organphysiologie" && subcategory == "Endokrinologie" {
            return [
                Question(
                    text: "10. Welche Aussage über hCG ist korrekt?",
                    answers: [
                        "A) Es wird von der Adenohypophyse gebildet",
                        "B) Es stabilisiert das Corpus luteum",
                        "C) Es steigt erst nach der 20. SSW an",
                        "D) Es ist identisch mit FSH"
                    ],
                    correctIndex: 1
                ),
                Question(
                    text: "11. Welche Wirkung hat Glukagon auf die Leber?",
                    answers: [
                        "A) Aktiviert Glykogensynthese",
                        "B) Aktiviert Lipogenese",
                        "C) Aktiviert Glykogenolyse",
                        "D) Hemmt die Ketogenese"
                    ],
                    correctIndex: 2
                ),
                Question(
                    text: "12. Welcher Glukosetransporter ist insulinunabhängig und zentral für Gehirnzellen?",
                    answers: [
                        "A) GLUT-2",
                        "B) GLUT-3",
                        "C) GLUT-4",
                        "D) SGLT-1"
                    ],
                    correctIndex: 1
                ),
                Question(
                    text: "13. Welcher Faktor steigt in der Schwangerschaft an und verursacht Insulinresistenz?",
                    answers: [
                        "A) Inhibin",
                        "B) Relaxin",
                        "C) hPL (human placental lactogen)",
                        "D) Aldosteron"
                    ],
                    correctIndex: 2
                ),
                Question(
                    text: "14. Welche Aussage zum Menstruationszyklus ist richtig?",
                    answers: [
                        "A) FSH bleibt im gesamten Zyklus konstant",
                        "B) Der Östrogenanstieg vor dem Eisprung hemmt die GnRH-Sekretion",
                        "C) LH löst die Ovulation aus",
                        "D) Progesteron wird ausschließlich in der Follikelphase gebildet"
                    ],
                    correctIndex: 2
                ),
                Question(
                    text: "15. Welches der folgenden Hormone wirkt über einen Tyrosinkinase-Rezeptor?",
                    answers: [
                        "A) Insulin",
                        "B) Cortisol",
                        "C) Progesteron",
                        "D) Glukagon"
                    ],
                    correctIndex: 0
                )
            ]
        }
        // Default demo question set (fallback)
        return [
            Question(
                text: "Was denkst du über Testfrage 1?",
                answers: ["Wundervoll", "Top", "Sehr gut", "Hallo"],
                correctIndex: 0
            )
        ]
    }

    var body: some View {
        let q = questions[safe: currentIndex]

        return VStack(alignment: .leading, spacing: 16) {
            if let q = q {
                // Question text
                Text(q.text)
                    .font(.title3).bold()
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .padding(.top)

                // Answers grid
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 12) {
                    ForEach(q.answers.indices, id: \.self) { idx in
                        let didSelect = selectedIndex != nil
                        let isSelected = selectedIndex == idx
                        let isCorrect = idx == q.correctIndex

                        Button(action: {
                            if selectedIndex == nil { selectedIndex = idx }
                        }) {
                            Text(q.answers[idx])
                                .font(.headline)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.primary)
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 72)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(backgroundColor(didSelect: didSelect, isSelected: isSelected, isCorrect: isCorrect))
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(didSelect)
                    }
                }
                .padding(.horizontal)

                // Weiter button appears after selection
                if selectedIndex != nil {
                    Button(action: {
                        // advance to next question or finish
                        if currentIndex + 1 < questions.count {
                            currentIndex += 1
                            selectedIndex = nil
                        } else {
                            // optional: pop view automatically
                            dismiss()
                        }
                    }) {
                        Text(currentIndex + 1 < questions.count ? "Weiter" : "Fertig")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            } else {
                // safety fallback
                Text("Keine Fragen verfügbar")
                    .foregroundStyle(.secondary)
                    .padding()
                Spacer()
            }
        }
        .navigationTitle(subcategory)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Zurück") { dismiss() }
            }
        }
    }

    private func backgroundColor(didSelect: Bool, isSelected: Bool, isCorrect: Bool) -> Color {
        guard didSelect else { return AppColors.surfaceAlt.opacity(0.5) }
        if isSelected {
            return isCorrect ? AppColors.success.opacity(0.35) : AppColors.error.opacity(0.35)
        }
        // After selection, also highlight the correct one in green
        return isCorrect ? AppColors.success.opacity(0.35) : AppColors.surfaceAlt.opacity(0.5)
    }
}

// MARK: - Kategorie-Detail-Views
private struct CategoryBaseView: View {
    let title: String
    let bgColor: Color
    
    @State private var showSubcategories: Bool = false
    
    private var subcategories: [String] {
        if title == "Organphysiologie" {
            var arr: [String] = ["Endokrinologie"]
            arr.append(contentsOf: (2...5).map { "Unterkategorie_\($0)_\(title)" })
            return arr
        }
        return (1...5).map { "Unterkategorie_\($0)_\(title)" }
    }
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            VStack(spacing: 24) {
                Text(title)
                    .font(.largeTitle).bold()
                    .foregroundStyle(AppColors.textPrimary)
                HStack(spacing: 16) {
                    Button("Duell") {
                        print("Duell gestartet: \(title)")
                    }
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.surfaceAlt.opacity(0.35))
                    .clipShape(Capsule())

                    Button("Einzelkampf") {
                        print("Einzelkampf gestartet: \(title)")
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            showSubcategories.toggle()
                        }
                    }
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.surfaceAlt.opacity(0.35))
                    .clipShape(Capsule())
                }
                
                if showSubcategories {
                    // Grid mit 5 Unterkategorien
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(subcategories, id: \.self) { name in
                            NavigationLink(destination: QuestionView(categoryTitle: title, subcategory: name)) {
                                VStack(spacing: 8) {
                                    Image(systemName: "square.grid.2x2.fill")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(.white)
                                    Text(name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.8)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 90)
                                .background(.black.opacity(0.25))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 3)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .move(edge: .top)))
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

// Safe subscript extension added here:
private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


#Preview("SplashView") {
    SplashView {
        // Preview completion
    }
}

