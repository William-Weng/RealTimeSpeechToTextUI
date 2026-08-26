[English](./README.en.md) | [正體中文](./README.md)

# [RealTimeSpeechToTextUI](https://swiftpackageindex.com/William-Weng)

[![Swift-5.10](https://img.shields.io/badge/Swift-5.10-orange.svg)](https://developer.apple.com/swift/)
[![iOS-17.0](https://img.shields.io/badge/iOS-17.0-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/RealTimeSpeechToTextUI)
![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

# 即時語音轉文字

本專案使用 **WWAudioStreamTranscription** 與 **WWMicrophoneInput** 實作即時語音轉文字功能。

https://github.com/user-attachments/assets/d56d1c48-6809-4b19-89de-2138837081c2

## 📱 [功能](https://peterpanswift.github.io/iphone-bezels/)

- **直覺的狀態提示**：介面初始會顯示「按下按鈕開始說話」。開始辨識後，會即時更新並顯示轉換後的文字。
- **自動捲動文字區域**：文字顯示區包裝在 `ScrollView` 中，即使辨識內容很長，使用者也能順暢瀏覽。
- **動態按鈕狀態**：底部按鈕會根據錄音是否進行中（`isRecording`）變更外觀：
  - **未錄音**：顯示藍色 🔵 麥克風圖示 🎤，以及「開始辨識」標籤。
  - **錄音中**：顯示紅色 🔴 停止圖示 ⏹️，以及「停止辨識」標籤。
- **錯誤處理**：若發生語音辨識或麥克風權限問題，介面會動態顯示紅色錯誤訊息（`errorMessage`）。

## 🏗️ 架構

介面使用 **SwiftUI** 建置，並採用 **MVVM** 架構：

- `ContentView`：主要的 SwiftUI 視圖。
- `SpeechViewModel`：管理狀態，並協調使用者介面與語音辨識流程之間的互動。

## 🔐 權限設定

由於本專案使用 Apple 的 Speech framework 與麥克風進行語音辨識，請在 App 的 `Info.plist` 中加入以下項目：

```xml
<!-- 語音辨識權限說明 -->
<key>NSSpeechRecognitionUsageDescription</key>
<string>此 App 需要使用語音辨識功能，將音訊轉換為文字。</string>

<!-- 麥克風權限說明 -->
<key>NSMicrophoneUsageDescription</key>
<string>此 App 需要使用麥克風進行錄音。</string>
```

## 📦 [相依套件](https://swiftpackageindex.com/William-Weng)

| 套件 | 說明 |
|------|------|
| [WWAudioStreamTranscription](https://github.com/William-Weng/WWAudioStreamTranscription) | 基於 Apple Speech framework 的即時音訊轉文字元件。 |
| [WWMicrophoneInput](https://github.com/William-Weng/WWMicrophoneInput) | 使用 `AVAudioEngine` 建置的輕量級 iOS 麥克風輸入管理器，提供簡單的 API 來擷取麥克風的 PCM 音訊資料。 |

> 「@Sendable 是編譯器幫你檢查閉包安不安全；actor 是編譯器幫你擋不安全存取，再加上執行期用 queue 保證不會同時改。」

