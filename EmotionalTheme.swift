//
//  EmotionalTheme.swift
//  MoodGpt
//
//  Created by Test on 4/27/25.
//

// Create a new file: EmotionTheme.swift
import SwiftUI

struct EmotionTheme {
    // Primary gradient colors for each emotion
    static func gradientColors(for emotion: String) -> [Color] {
        switch emotion.lowercased() {
        case "happy", "joyful":
            return [Color.yellow.opacity(0.7), Color.orange.opacity(0.5), Color.white.opacity(0.3)]
        case "sad":
            return [Color.blue.opacity(0.7), Color.indigo.opacity(0.5), Color.white.opacity(0.3)]
        case "angry":
            return [Color.red.opacity(0.7), Color.pink.opacity(0.5), Color.white.opacity(0.3)]
        case "fear":
            return [Color.purple.opacity(0.7), Color.indigo.opacity(0.5), Color.white.opacity(0.3)]
        case "excited":
            return [Color.pink.opacity(0.7), Color.orange.opacity(0.5), Color.white.opacity(0.3)]
        case "calm":
            return [Color.mint.opacity(0.7), Color.cyan.opacity(0.5), Color.white.opacity(0.3)]
        case "tired":
            return [Color.gray.opacity(0.7), Color.blue.opacity(0.3), Color.white.opacity(0.3)]
        case "surprised":
            return [Color.yellow.opacity(0.7), Color.purple.opacity(0.5), Color.white.opacity(0.3)]
        case "confident":
            return [Color.indigo.opacity(0.7), Color.purple.opacity(0.5), Color.white.opacity(0.3)]
        case "neutral", "mixed":
            return [Color.blue.opacity(0.6), Color.purple.opacity(0.5), Color.white.opacity(0.3)]
        default:
            return [Color.blue.opacity(0.6), Color.purple.opacity(0.5), Color.white.opacity(0.3)]
        }
    }
    
    // Card background color based on emotion
    static func cardColor(for emotion: String) -> Color {
        switch emotion.lowercased() {
        case "happy", "joyful":
            return Color.yellow.opacity(0.2)
        case "sad":
            return Color.blue.opacity(0.2)
        case "angry":
            return Color.red.opacity(0.2)
        case "fear":
            return Color.purple.opacity(0.2)
        case "excited":
            return Color.pink.opacity(0.2)
        case "calm":
            return Color.mint.opacity(0.2)
        case "tired":
            return Color.gray.opacity(0.2)
        case "surprised":
            return Color.yellow.opacity(0.2)
        case "confident":
            return Color.indigo.opacity(0.2)
        case "neutral", "mixed":
            return Color.gray.opacity(0.2)
        default:
            return Color.gray.opacity(0.2)
        }
    }
    
    // Text color for each emotion to ensure readability
    static func textColor(for emotion: String) -> Color {
        switch emotion.lowercased() {
        case "happy", "joyful", "excited", "surprised":
            return Color.black.opacity(0.8)
        default:
            return Color.white
        }
    }
}
