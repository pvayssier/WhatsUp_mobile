//
//  MessageView.swift
//  
//
//  Created by Paul VAYSSIER on 29/04/2024.
//

import SwiftUI
import Models

struct MessageView: View {

    public init(senderName: String,
                message: Message,
                picture: Image?,
                isMyMessage: Bool,
                position: PositionInGroup,
                reportAction: @escaping (String) async -> Void) {
        self.message = message
        self.picture = picture
        self.isMyMessage = isMyMessage
        self.position = position
        self.senderName = senderName

        let formatter = DateFormatter()

        formatter.dateFormat = "HH:mm"
        self.formatDate = formatter.string(from: message.createdAt)
        self.reportAction = reportAction
    }

    let senderName: String
    let message: Message
    let isMyMessage: Bool
    let position: PositionInGroup
    let formatDate: String
    private var picture: Image? = nil
    private let reportAction: (String) async -> Void
    @State private var presentReportAlert = false

    var body: some View {
        HStack(alignment: .bottom) {
            if isMyMessage {
                Spacer(minLength: 30)
                VStack(alignment: .trailing) {
                    DynamicTextView(fullText: message.content,
                                    endText: formatDate)
                }
                .padding(4)
                .background(Color("sendedMessageColor", bundle: .main))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                if let picture, position == .idle || position == .last {
                    picture
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                } else if position == .idle || position == .last {
                    Image(systemName: "person.2.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .padding(6)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.white)
                        .background(Color(.systemGray3))
                        .clipShape(Circle())
                } else {
                    Spacer()
                        .frame(width: 30)
                }

                VStack(alignment: .leading) {
                    if position == .idle || position == .first {
                        Text(senderName.capitalized)
                            .foregroundStyle(Color(uiColor: .systemBrown))
                            .font(.system(size: 14))

                    }
                    DynamicTextView(fullText: message.content,
                                    endText: formatDate)
                }
                .padding(4)
                .background(Color("ReceivedMessageColor", bundle: .main))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .contextMenu {
                    Button("Report", systemImage: "exclamationmark.bubble", role: .destructive) {
                        presentReportAlert = true
                    }
                }
                Spacer(minLength: 30)
            }
        }
        .padding(.bottom, position.padding)
        .padding(.horizontal, 10)
        .alert("Do you want to report this message ?", isPresented: $presentReportAlert) {
            Button("Cancel", role: .cancel) {
                presentReportAlert = false
            }
            Button("Signal", role: .destructive) {
                Task {
                    await reportAction(message.id)
                }
            }
        } message: {
            Text("\(message.content) from \(senderName)")
                .foregroundColor(.primary)
        }

    }
}
