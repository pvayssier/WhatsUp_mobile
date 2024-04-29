//
//  ChatToolBarContent.swift
//  
//
//  Created by Paul VAYSSIER on 29/04/2024.
//

import SwiftUI

struct ChatToolbarContent: View {
    var groupPicture: Image?
    var groupName: String

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                if let groupPicture = groupPicture {
                    groupPicture
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.2.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .padding(10)
                        .frame(width: 35, height: 35)
                        .foregroundStyle(.white)
                        .background(Color(.systemGray3))
                        .clipShape(Circle())
                }
                VStack(alignment: .leading, spacing: 0.5) {
                    Text(groupName)
                        .font(.headline)
                    Text("tap here for conversation info")
                        .font(.footnote)
                        .fontWeight(.light)
                        .foregroundColor(.secondary)
                }

            }
        }

    }
}
