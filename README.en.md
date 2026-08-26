[English](./README.en.md) | [正體中文](./README.md)

# [RealTimeSpeechToTextUI](https://swiftpackageindex.com/William-Weng)

[![Swift-5.10](https://img.shields.io/badge/Swift-5.10-orange.svg)](https://developer.apple.com/swift/)
[![iOS-17.0](https://img.shields.io/badge/iOS-17.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/RealTimeSpeechToTextUI)
![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

# Real Time Speech To Text

This project implements a real-time speech-to-text feature using **WWAudioStreamTranscription** and **WWMicrophoneInput**.

https://github.com/user-attachments/assets/d56d1c48-6809-4b19-89de-2138837081c2

## 📱 [Features](https://peterpanswift.github.io/iphone-bezels/)

- **Intuitive status prompts**: The UI initially displays “Press the button to start speaking.” Once recognition begins, it updates in real time with the transcribed text.
- **Automatically scrolling text area**: The text display is wrapped in a `ScrollView`, allowing users to browse smoothly even when the transcription becomes lengthy.
- **Dynamic button states**: The button at the bottom changes its appearance based on whether recording is in progress (`isRecording`):
  - **Not recording**: Displays a blue 🔵 microphone icon 🎤 and the label “Start Recognition.”
  - **Recording**: Displays a red 🔴 stop icon ⏹️ and the label “Stop Recognition.”
- **Error handling**: If speech-recognition or microphone-permission issues occur, a red error message (`errorMessage`) is displayed dynamically.

## 🏗️ Architecture

The UI is built with **SwiftUI** and follows the **MVVM** architecture:

- `ContentView`: The main SwiftUI view.
- `SpeechViewModel`: Manages the state and coordinates between the UI and the speech-recognition pipeline.

## 🔐 Permission Setup

Because this project uses Apple’s Speech framework and the microphone for speech recognition, add the following entries to your app’s `Info.plist`:

```xml
<!-- Speech recognition permission description -->
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition to convert audio into text.</string>

<!-- Microphone permission description -->
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone for recording.</string>
```

## 📦 [Dependencies](https://swiftpackageindex.com/William-Weng)

| Package | Description |
|------|------|
| [WWAudioStreamTranscription](https://github.com/William-Weng/WWAudioStreamTranscription) | A real-time audio-stream-to-text component based on Apple’s Speech framework. |
| [WWMicrophoneInput](https://github.com/William-Weng/WWMicrophoneInput) | A lightweight iOS microphone-input manager built with `AVAudioEngine`, providing a simple API for capturing PCM audio data from the microphone. |

> @Sendable is the compiler checking whether your closure is safe; actor is the compiler blocking unsafe access, plus the runtime using a queue to guarantee no concurrent modifications.