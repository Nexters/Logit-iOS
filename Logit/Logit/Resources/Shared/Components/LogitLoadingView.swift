//
//  LogitLoadingView.swift
//  Logit
//

import SwiftUI

struct LogitLoadingView: View {
    var size: CGFloat = 64
    var lineWidth: CGFloat = 12
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.75)
            .stroke(
                AngularGradient(
                    colors: [
                        Color(hex: "CCD8FF"),
                        Color(hex: "BCE6FF"),
                        Color(hex: "B2FFF6"),
                        Color(hex: "CCD8FF")
                    ],
                    center: .center
                ),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(
                .linear(duration: 1).repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear { isAnimating = true }
    }
}
