//
//  ChatConversationInputView.swift
//  
//
//  Created by Paul VAYSSIER on 29/04/2024.
//

import SwiftUI

struct MessageInputView: View {
    @Binding var text: String
    var action: () -> Void

    var body: some View {
        HStack {
            TextField("", text: $text)
                .padding(6)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(.systemGray5), lineWidth: 1))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
            Button(action: {
                action()
            }, label: {
                Image(systemName: "paperplane.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(uiColor: UIColor.tintColor))
                    .background(.clear)
                    .padding(.trailing, 10)
                    .rotationEffect(.degrees(45))
                    .padding(.vertical, 6)
            })
        }
        .padding(0)
    }
}
