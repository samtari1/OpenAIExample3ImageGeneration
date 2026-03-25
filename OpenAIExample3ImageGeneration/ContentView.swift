//
//  ContentView.swift
//  OpenAIExample
//
//  Created by Quanpeng Yang on 3/24/26.
//

import SwiftUI

struct ContentView: View {
    @State private var appData = ApplicationData.shared
    @State private var inProgress: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))

                if let imageURL = appData.generatedImageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        case .failure:
                            Text("Failed to load image.")
                                .foregroundStyle(.secondary)
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else if inProgress {
                    ProgressView("Generating image...")
                } else {
                    Text("Generated image will appear here.")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(minHeight: 300)

            if !appData.errorMessage.isEmpty {
                Text(appData.errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            TextField("Describe the image to generate", text: $appData.prompt)
                .textFieldStyle(.roundedBorder)
                .disabled(inProgress)

            Button("Generate Image") {
                inProgress = true
                Task {
                    await appData.generateImage()
                    inProgress = false
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .buttonStyle(.borderedProminent)
            .disabled(inProgress || appData.prompt.isEmpty)
        }
        .padding()
    }
}
