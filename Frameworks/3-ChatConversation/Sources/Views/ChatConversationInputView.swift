//
//  ChatConversationInputView.swift
//  
//
//  Created by Paul VAYSSIER on 29/04/2024.
//

import SwiftUI

struct MessageInputView: View {
    @State var text: String = ""
    var action: (String) -> Void

    init(_ action: @escaping (String) -> Void) {
        self.action = action
    }

    var body: some View {
        HStack {
            TextField("", text: $text, axis: .vertical)
                .padding(6)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(.systemGray5), lineWidth: 1))
                .padding(.leading, 10)
                .padding(.vertical, 4)
                .onSubmit {
                    action(text)
                }
            Button(action: {
                guard !text.isEmpty else { return }
                action(text)
                text = ""
            }, label: {
                Image(systemName: "paperplane.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(uiColor: UIColor.tintColor))
                    .background(.clear)
                    .rotationEffect(.degrees(45))
                    .padding(10)
            })
        }
    }
}
