//
//  TypographyModifier.swift
//  Logit
//
//  Created by 임재현 on 1/22/26.
//

import SwiftUI

struct TypographyModifier: ViewModifier {
    let font: LogitFont
    
    func body(content: Content) -> some View {
        let uiFont = font.uiFont
        let lineHeight = font.lineHeight
        let letterSpacing = font.letterSpacing
        
        content
            .font(Font(uiFont))
            .lineSpacing(lineHeight - uiFont.lineHeight)
            .tracking(letterSpacing)
            .padding(.vertical, (lineHeight - uiFont.lineHeight) / 2)
    }
}
