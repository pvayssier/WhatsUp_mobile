//
//  DynamicTextView.swift
//  
//
//  Created by Paul VAYSSIER on 29/04/2024.
//

import SwiftUI

struct DynamicTextView: View {
    var fullText: String
    var endText: String

    @State private var dynamicText: (main: String, last: String) = ("", "")

    var body: some View {
        VStack(alignment: .leading) {
            if !dynamicText.main.isEmpty {
                Text(dynamicText.main)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.trailing, 10)
                HStack(alignment: .bottom) {
                    Text(dynamicText.last)
                    Text(endText)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .fontWeight(.light)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            } else {
                HStack(alignment: .bottom) {
                    Text(dynamicText.last)
                    Text(endText)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .fontWeight(.light)
                        .padding(.leading, 10)
                }
            }
        }
        .onAppear {
            calculateTexts()
        }
    }

    private func calculateTexts() {
        // Dummy logic for text measurement
        // In a real scenario, you would use UIKit to measure and adjust
        dynamicText = splitText(fullText: fullText,
                                font: UIFont.systemFont(ofSize: 17),
                                width: UIScreen.main.bounds.width,
                                endText: endText)
    }

    private func splitText(fullText: String, font: UIFont, width: CGFloat, endText: String) -> (main: String, last: String) {
        let endTextWidth = endText.widthOfString(usingFont: font)
        let spaceWidth = " ".widthOfString(usingFont: font)
        var currentLineWidth: CGFloat = 0
        var lastLineStartIndex: String.Index? = nil

        for (index, char) in fullText.enumerated() {
            let charWidth = String(char).widthOfString(usingFont: font)
            if currentLineWidth + charWidth > width - endTextWidth - spaceWidth {
                lastLineStartIndex = fullText.index(fullText.startIndex, offsetBy: index)
                currentLineWidth = charWidth
            } else {
                currentLineWidth += charWidth
            }
        }

        guard let lastLineStartIndex else {
            return  (main: "", last: fullText)
        }
        if let splitText = splitOnSpace(text: String(fullText[..<lastLineStartIndex])) {
            let mainText = splitText.main
            let lastLineText = splitText.spleeted + String(fullText[lastLineStartIndex...])
            return (main: mainText, last: lastLineText)
        }


        let mainText = String(fullText[..<lastLineStartIndex]) + "-"
        let lastLineText = String(fullText[lastLineStartIndex...])
        return (main: mainText, last: lastLineText)
    }

    private func splitOnSpace(text: String) -> (main: String, spleeted: String)? {
        var words = text.split(separator: " ")
        if let lastWord = words.last, lastWord.count <= 7 {
            words.removeLast()
            return (main: words.joined(separator: " "), spleeted: String(lastWord))
        }
        return nil
    }
}

fileprivate extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}
