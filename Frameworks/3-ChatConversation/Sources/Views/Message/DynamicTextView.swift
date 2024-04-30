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
        dynamicText = splitText(fullText: fullText, font: UIFont.systemFont(ofSize: 17), width: UIScreen.main.bounds.width - 60, endText: endText)
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
        
        let mainText = String(fullText[..<lastLineStartIndex]) + "-"
        let lastLineText = String(fullText[lastLineStartIndex...])

        return (main: mainText, last: lastLineText)
    }
}

fileprivate extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}
