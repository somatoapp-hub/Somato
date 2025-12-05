import SwiftUI

struct RankingsView: View {
    enum Scope: String, CaseIterable, Identifiable {
        case germany = "Deutschland"
        case university = "Eigene Universität"
        var id: String { rawValue }
    }

    @State private var selectedScope: Scope = .germany

    // Placeholder data
    private var germanyRanks: [String] = ["1. Alex", "2. Sam", "3. Jamie", "4. Kim", "5. Taylor"]
    private var universityRanks: [String] = ["1. Du", "2. Chris", "3. Pat", "4. Robin", "5. Lee"]

    var body: some View {
        List {
            Section {
                Picker("Bereich", selection: $selectedScope) {
                    ForEach(Scope.allCases) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section(header: Text("Rangliste")) {
                ForEach(currentRanks, id: \.self) { name in
                    HStack {
                        Text(name)
                        Spacer()
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                    }
                }
            }
        }
        .navigationTitle("Rangliste")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var currentRanks: [String] {
        switch selectedScope {
        case .germany: return germanyRanks
        case .university: return universityRanks
        }
    }
}

#Preview {
    NavigationView { RankingsView() }
}
