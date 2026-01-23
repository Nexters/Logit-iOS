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

extension View {
    
    /// 정사각형 frame
    func frame(size: CGFloat) -> some View {
        self.frame(width: size, height: size)
    }
    
    /// 전체 너비
    func fillWidth(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    /// 전체 높이
    func fillHeight(alignment: Alignment = .center) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
    
    /// 전체 화면
    func fillScreen(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
    
    /// 조건부 modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Optional 조건부
    @ViewBuilder
    func ifLet<Value, Content: View>(_ value: Value?, transform: (Self, Value) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
    
    
    // MARK: - Keyboard
    /// 키보드 숨기기
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// 탭해서 키보드 숨기기
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            hideKeyboard()
        }
    }
    
    // MARK: - Corner Radius
    
    /// 특정 코너만 radius
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    // MARK: - Debug (릴리즈에서 자동 제거)
    func debugBorder(_ color: Color = .red, width: CGFloat = 1) -> some View {
        #if DEBUG
        self.border(color, width: width)
        #else
        self
        #endif
    }
    
    func debugBackground(_ color: Color = .red.opacity(0.3)) -> some View {
        #if DEBUG
        self.background(color)
        #else
        self
        #endif
    }
}

// MARK: - RoundedCorner Shape

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
