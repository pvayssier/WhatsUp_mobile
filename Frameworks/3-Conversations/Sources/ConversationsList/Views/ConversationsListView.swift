//
//  ConversationsListView.swift
//  
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import SwiftUI

public struct ConversationsListView<ViewModel: ConversationsListViewModelProtocol>: View {

    @ObservedObject private var viewModel: ViewModel

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                ForEach(viewModel.conversations) { conversation in
                    VStack {
                        SingleConversationView(viewModel: SingleConversationViewState(conversation: conversation))
                        if conversation != viewModel.conversations.last {
                            Divider()
                                .padding(.leading, 70)
                        }
                    }
                }
                .navigationTitle("Conversations")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            print("plus")
                        } label: {
                            Image(systemName: "plus")
                        }

                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            print("settings")
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
            .refreshable {
                Task {
                    await viewModel.didForceRefresh()
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.viewDidAppear()
            }
        }
    }

}

#if DEBUG
struct ConversationsListView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationsListView(viewModel: ConversationsListViewModel())
    }
}
#endif

