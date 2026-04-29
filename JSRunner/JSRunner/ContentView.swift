import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "curlybraces")
                    .font(.system(size: 64))
                    .foregroundColor(.orange)

                Text("JS Runner")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Adds a powerful \"Run JavaScript\" action to the Shortcuts app.\n\nOpen Shortcuts and search for \"Run JavaScript\" to use it.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)

                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "play.fill", text: "Run any JavaScript code")
                    FeatureRow(icon: "arrow.down.circle", text: "Pass input from Shortcuts")
                    FeatureRow(icon: "network", text: "Fetch URLs & call APIs")
                    FeatureRow(icon: "doc.text", text: "Parse & build JSON")
                    FeatureRow(icon: "arrow.up.circle", text: "Return result to Shortcuts")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding(.top, 48)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }
}
