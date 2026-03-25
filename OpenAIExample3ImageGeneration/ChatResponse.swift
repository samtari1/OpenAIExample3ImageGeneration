//
//  ChatResponse.swift
//  OpenAIExample
//
//  Created by Quanpeng Yang on 3/24/26.
//

import SwiftUI

struct ImageGenerationResponse: Codable {
    let created: Int
    let data: [GeneratedImage]

    struct GeneratedImage: Codable {
        let url: String?
        let revised_prompt: String?
    }
}
