//
//  LogitFont.swift
//  Logit
//
//  Created by 임재현 on 1/17/26.
//

import SwiftUI

enum LogitFont {
    //HeadLine
    case headLine1_bold
    
    //Title
    case title1_bold
    case title2_bold
    case title2_semibold
    case title3_semibold
    
    // Body
    case body1_bold
    case body2_regular
    case body3_bold
    case body3_semibold
    case body3_regular
    case body4_semibold
    case body5_bold
    case body5_semibold
    case body5_medium
    case body5_regular_150
    case body5_regular_140
    case body6_regular
    case body6_meduim
    case body7_bold
    case body7_semibold
    case body7_regular_160
    case body7_regular_140
    case body8_medium
    case body8_regular
    case body9_bold
    case body9_semibold
    case body9_regular
    
    // Label
    case label1_medium
    
    private var baseFontSize: CGFloat {
        switch self {
        // Headline
        case .headLine1_bold:
            return 32
            
        // Title
        case .title1_bold:
            return 28
        case .title2_bold, .title2_semibold:
            return 24
        case .title3_semibold:
            return 22
            
        // Body
        case .body1_bold:
            return 20
        case .body2_regular:
            return 19
        case .body3_bold, .body3_semibold, .body3_regular:
            return 18
        case .body4_semibold:
            return 17
        case .body5_bold, .body5_semibold, .body5_medium, .body5_regular_150, .body5_regular_140:
            return 16
        case .body6_regular, .body6_meduim:
            return 15
        case .body7_bold, .body7_semibold, .body7_regular_160, .body7_regular_140:
            return 14
        case .body8_medium, .body8_regular, .label1_medium:
            return 13
        case .body9_bold, .body9_semibold, .body9_regular:
            return 12
        }
    }
}
