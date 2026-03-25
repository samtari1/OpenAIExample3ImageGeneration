//
//  ApplicationData.swift
//  OpenAIExample
//
//  Created by Quanpeng Yang on 3/24/26.
//

import SwiftUI
import Observation

@Observable
class ApplicationData {
    var prompt: String = ""
    var generatedImageURL: URL?
    var errorMessage: String = ""

    static let shared: ApplicationData = ApplicationData()

    private init() {}

    func generateImage() async {
        guard !prompt.isEmpty else { return }

        let jsonbody: [String: Any] = [
            "model": "dall-e-3",
            "prompt": prompt,
            "n": 1,
            "size": "1024x1024"
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonbody) else { return }

        let apikey = "Your_API_Key" // Replace with your OpenAI API Key
        guard let url = URL(string: "https://api.openai.com/v1/images/generations") else { return }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonData
        urlRequest.addValue("Bearer \(apikey)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)

            if let httpResponse = urlResponse as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let imageResponse = try JSONDecoder().decode(ImageGenerationResponse.self, from: data)
                    if let urlString = imageResponse.data.first?.url,
                       let imageURL = URL(string: urlString) {
                        await MainActor.run {
                            generatedImageURL = imageURL
                            prompt = ""
                        }
                    }
                } else {
                    let errorText = String(data: data, encoding: .utf8) ?? "No additional information."
                    await MainActor.run {
                        errorMessage = "Error \(httpResponse.statusCode): \(errorText)"
                    }
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Error generating image: \(error)"
            }
        }
    }
}
