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
