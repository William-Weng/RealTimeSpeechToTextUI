//
//  ContentView.swift
//  LiveSTT
//
//  Created by William.Weng on 2026/7/7.
//
//  <key>NSMicrophoneUsageDescription</key>
//  <string>需要使用麥克風進行語音辨識</string>
//
//  <key>NSSpeechRecognitionUsageDescription</key>
//  <string>需要使用語音辨識將聲音轉換為文字</string>

import SwiftUI
import AVFoundation
import Speech
import Translation

/// Real-Time Speech-To-Text (STT)
struct ContentView: View {
    
    @State private var targetText = ""                                              // 翻譯後的目標語言文字
    @State private var targetLanguage: SupportedLanguage                            // 語音辨識使用的語言
    @State private var viewModel: SpeechViewModel                                   // 語音辨識的 ViewModel
    @State private var configuration: TranslationSession.Configuration              // 目前使用中的翻譯工作階段設定
    @State private var _configuration_ = TranslationSession.Configuration()         // 用來比較翻譯設定是否發生變化的設定值
    @State private var debounceTask: Task<Void, Never>?                             // 防抖任務：當使用者停止輸入一段時間後才執行翻譯
    
    var body: some View {

        NavigationStack {
            
            VStack(spacing: 20) {
                
                sourceTextView
                targetTextView
                if let errorMessage = viewModel.errorMessage { errorMessageView(errorMessage) }
                
                HStack(spacing: 20) {
                    startButton
                    languageButton
                }
            }
            .navigationTitle(viewModel.language.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                languageItem
            }
            .padding()
            .onChange(of: viewModel.language, { _, _ in
                viewModel.stop()
                updateSecondLanguageIfNeeded()
            })
            .onChange(of: targetLanguage) { _, _ in
                viewModel.stop()
            }
            .onChange(of: viewModel.text, { _, _ in
                transcriptionDebounce(milliseconds: 500)
            })
            .translationTask(configuration) { session in
                await translationTaskAction(session: session)
            }
        }
    }
        
    /// 建立 ContentView
    ///
    /// - Parameters:
    ///   - sourceLanguage: 原始語言，預設為台灣中文
    ///   - targetLanguage: 目標語言，預設為英文
    init(sourceLanguage: SupportedLanguage = .TW, targetLanguage: SupportedLanguage = .US) {
        viewModel = .init(language: sourceLanguage)
        self.targetLanguage = targetLanguage
        configuration = .build(for: sourceLanguage, target: targetLanguage)
    }
}

// MARK: - Private Subviews
private extension ContentView {
    
    /// 顯示原始語言文字的 View
    ///
    /// 使用 ScrollView 包圍 Text，支援多行顯示與捲動
    var sourceTextView: some View {
        
        ScrollView {
            Text(viewModel.text.isEmpty ? viewModel.language.message : viewModel.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .frame(maxWidth: .infinity)
        .background(.blue.opacity(0.1))
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
    
    /// 顯示目標語言文字的 View
    ///
    /// 使用 ScrollView 包圍 Text，支援多行顯示與捲動
    var targetTextView: some View {
        
        ScrollView {
            Text(targetText.isEmpty ? targetLanguage.message : targetText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(.black)
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
    
    /// 開始/停止辨識的按鈕
    /// 
    /// 根據當前是否正在錄音，切換按鈕文字與圖示
    @ViewBuilder
    var startButton: some View {
        
        let color: Color = viewModel.isRecording ? .red: .blue
        
        Button {
            viewModel.toggle()
        } label: {
            Label(
                viewModel.isRecording ? viewModel.language.stopMessage : viewModel.language.startMessage,
                systemImage: viewModel.isRecording ? "stop.circle.fill": "mic.circle.fill"
            )
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(12)
        }
    }
    
    /// 目標語言選擇按鈕
    ///
    /// 點擊後顯示支援的語言清單，並將選取結果綁定至 `targetLanguage`
    var languageButton: some View {
        
        Menu {
            Picker("第二語系", selection: $targetLanguage) {
                
                ForEach(SupportedLanguage.allCases, id: \.self) { language in
                    
                    if (language != viewModel.language) {
                        ZStack {
                            Text("\(language.flag) \(language.name)")
                        }
                        .tag(language.identity)
                    } else {
                        EmptyView()
                    }
                }
            }
        } label: {
            
            Text("\(targetLanguage.flag) \(targetLanguage.name)")
                .font(.headline)
                .padding()
                .frame(height: 64)
                .frame(minWidth: 128)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}

// MARK: - Private Subviews
private extension ContentView {
    
    /// 錯誤訊息的顯示視圖
    ///
    /// 以紅色小字顯示，並佔滿水平寬度
    /// - Parameter errorMessage: 要顯示的錯誤訊息文字。
    func errorMessageView(_ errorMessage: String) -> some View {
        
        Text(errorMessage)
            .font(.footnote)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - @ToolbarContentBuilder
private extension ContentView {
    
    /// 語言選擇工具列項目
    ///
    /// 點選後，可以選擇支援的語系
    @ToolbarContentBuilder
    var languageItem: some ToolbarContent {
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Picker("主要語系", selection: $viewModel.language) {
                    ForEach(SupportedLanguage.allCases, id: \.self) { language in
                        ZStack {
                            Text("\(language.flag) \(language.name)")
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(viewModel.language.flag)
                        .font(.headline)
                        .padding()
                }
            }
        }
    }
}

// MARK: - 翻譯邏輯擴充 (Private Extension)
private extension ContentView {
    
    /// 使用翻譯工作階段將原始文字翻譯成目標語言
    ///
    /// - Parameter session: 目前使用中的翻譯工作階段
    ///
    /// 這個方法會非同步執行翻譯工作，翻譯成功後更新 `targetText`，翻譯失敗時則顯示錯誤訊息
    @MainActor
    func translationTaskAction(session: TranslationSession) async {
        
        do {
            let response = try await session.translate(viewModel.text)
            targetText = response.targetText
        } catch {
            targetText = error.localizedDescription
        }
    }
    
    /// 確保第二個語系不會與第一個語系重複
    func updateSecondLanguageIfNeeded() {
        
        let availableLanguages = SupportedLanguage.allCases.filter { $0 != viewModel.language }
        
        guard !availableLanguages.isEmpty else { return }
        
        if targetLanguage == viewModel.language || !availableLanguages.contains(targetLanguage) {
            targetLanguage = availableLanguages.last ?? .TW
        }
        
        configuration = .build(for: viewModel.language, target: targetLanguage)
    }
    
    /// 當文字改變時呼叫，帶有 500ms 防抖（debounce）效果
    func transcriptionDebounce(milliseconds: any BinaryInteger) {
        
        debounceTask?.cancel()
        
        debounceTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(milliseconds))
            guard !Task.isCancelled else { return }
            resetConfiguration()
        }
    }
    
    /// 重設並更新翻譯的組態設定
    ///
    /// 此方法會檢查當前的翻譯組態是否需要更新：
    /// 1. 如果「目前畫面的組態」與「暫存的基準組態（`_configuration_`）」**不一致**（代表使用者切換了語系），則會依據 `viewModel` 的最新語系與 `targetLanguage` 重新構建組態，並同步更新暫存
    /// 2. 如果組態**沒有改變**，則直接將當前的組態使之失效（`invalidate()`），以重新觸發或整理現有的翻譯工作階段
    ///
    /// ### 呼叫情境：
    /// 當使用者切換語系、或是點擊「重新整理翻譯」按鈕時呼叫此方法。
    func resetConfiguration() {
        
        if configuration != _configuration_ {
            _configuration_ = .build(for: viewModel.language, target: targetLanguage)
            configuration = _configuration_
        } else {
            configuration.invalidate()
        }
    }
}

#Preview {
    ContentView()
}
