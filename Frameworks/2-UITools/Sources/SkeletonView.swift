//
//  SkeletonView.swift
//  
//
//  Created by Paul VAYSSIER on 06/05/2024.
//

import SwiftUI

struct SkeletonView<Content: View>: View {
  let content: () -> Content

  var body: some View {
    content()
      .hidden()
      .overlay(gradient)
  }

  private let colors: [UIColor] = [
    .lightGray.withAlphaComponent(0.5),
    .gray.withAlphaComponent(0.5),
    .lightGray.withAlphaComponent(0.5)
  ]

  @State var gradientStartPoint = UnitPoint(x: -1, y: 0.5)
  @State var gradientEndPoint = UnitPoint.leading

  private var gradient: some View {
    LinearGradient(
      colors: colors.map(Color.init),
      startPoint: gradientStartPoint,
      endPoint: gradientEndPoint
    )
    .onAppear {
      withAnimation(.easeIn(duration: 1.5).repeatForever(autoreverses: false)) {
        gradientStartPoint = .trailing
        gradientEndPoint = UnitPoint(x: 2, y: 0.5)
      }
    }
  }
}

struct SkeletonModifier: ViewModifier {
  func body(content: Content) -> some View {
    SkeletonView { content }
  }
}

public extension View {
  @ViewBuilder
  func skeletoned(_ condition: Bool = true) -> some View {
    if condition {
      modifier(SkeletonModifier())
    } else {
      self
    }
  }
}
