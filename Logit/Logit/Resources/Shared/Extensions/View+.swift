//
//  View+.swift
//  Logit
//
//  Created by 임재현 on 1/22/26.
//

import SwiftUI

extension View {
    func typo(_ font: LogitFont) -> some View {
        modifier(TypographyModifier(font: font))
    }
}

/// 그라디언트 배경색 지정
extension View {
    func gradientFill(_ style: GradientStyle) -> some View {
        self.background(style.gradient)
    }
}

extension ShapeStyle where Self == LinearGradient {
    static func gradient(_ style: GradientStyle) -> LinearGradient {
        style.gradient
    }
}
