//
//  DaySpeparatorView.swift
//  
//
//  Created by Paul VAYSSIER on 05/05/2024.
//

import SwiftUI

struct DaySeparatorView: View {

    init(messageDate: Date, prevMessageDate: Date?) {
        if let prevMessageDate, Calendar.current.isDate(messageDate, inSameDayAs: prevMessageDate) {
            self.showDate = false
        } else {
            self.showDate = true
        }

        if Calendar.current.isDate(messageDate, inSameDayAs: Date()) {
            self.formatDate = "Aujourd'hui"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Calendar.current.locale
            formatter.dateFormat = "EEEE d MMMM" + (Calendar.current.isDate(messageDate,
                                                                            equalTo: Date(),
                                                                            toGranularity: .year) ? "" : " yyyy")
            self.formatDate = formatter.string(from: messageDate)
        }
    }

    private let showDate: Bool
    private let formatDate: String

    var body: some View {
        if showDate {
            VStack {
                Text(formatDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(10)
            }
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(20)
        }
    }
}
