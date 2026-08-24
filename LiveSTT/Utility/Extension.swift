//
//  Extension.swift
//  LiveSTT
//
//  Created by William.Weng on 2026/8/13.
//

import Foundation
import AVFAudio
import Translation

// MARK: - String
private extension String {
    
    /// 🇦- A的差值（僅在首次存取時實際計算一次，隨後直接複用）
    static let flagBase: UInt32 = {
        let regionalIndicatorA = "🇦".unicodeScalars.first!.value   // 0x1F1E6
        let asciiA = "A".unicodeScalars.first!.value                // 0x41
        return regionalIndicatorA - asciiA                          // 0x1F1A5
    }()
}

// MARK: - String
extension String {
    
    /// 將二位字母國家代碼轉換為國旗 Emoji (ISO 3166-1)
    var flag: String {
        
        guard count == 2 else { return self }
        
        let base: UInt32 = String.flagBase
        
        var result = ""
        for char in uppercased() {
            if let scalar = Unicode.Scalar(UInt32(char.asciiValue!) + base) {
                result.append(String(scalar))
            }
        }
        return result
    }
}

// MARK: - TranslationSession.Configuration
extension TranslationSession.Configuration {

    /// 快速建立翻譯階段的組態設定 (Configuration)
    ///
    /// - Parameters:
    ///   - source: 來源語系（即原本文字的語言）
    ///   - target: 目標語系（即希望翻譯成的語言）
    /// - Returns: 回傳一個初始化完成的 `TranslationSession.Configuration` 實例
    static func build(for source: SupportedLanguage, target: SupportedLanguage) -> Self {
        .init(source: .init(identifier: source.identity), target: .init(identifier: target.identity))
    }
}
