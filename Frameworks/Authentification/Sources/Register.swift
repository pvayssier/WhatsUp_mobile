//
//  SwiftUIView.swift
//  
//
//  Created by Paul VAYSSIER on 08/04/2024.
//

import SwiftUI
import PhotosUI

public struct Register: View {
    public init() { }

    @State private var username = ""
    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImage: Image = Image(systemName: "person.circle.fill")

    public var body: some View {

        Image(systemName: "globe")
            .foregroundStyle(.blue)
        Text("Hello World !")


    }
}

#Preview {
    Register()
}
