
import SwiftUI

struct ErrorStateView: View {
    let message: String
    let isOffline: Bool
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: isOffline ? "wifi.slash" : "exclamationmark.triangle")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Button("Try again", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
