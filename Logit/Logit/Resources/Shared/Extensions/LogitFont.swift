//
//  LogitFont.swift
//  Logit
//
//  Created by 임재현 on 1/17/26.
//

import SwiftUI

enum LogitFont {
    //HeadLine
    case bold_32
    
    //Title
    case bold_28
    case bold_24
    case semibold_24
    case semibold_22
    
    // Body
    case bold_20
    case regular_19
    case bold_18
    case semibold_18
    case regular_18
    case semibold_17
    case bold_16
    case semibold_16
    case medium_16
    case regular_16_150
    case regular_16_140
    case regular_15
    case medium_15
    case bold_14
    case semibold_14
    case regular_14_160
    case regular_14_140
    case medium_13
    case regular_13
    case bold_12
    case semibold_12
    case regular_12
    
    // Label
    case medium_10
    
    private var baseFontSize: CGFloat {
        switch self {
        // Headline
        case .bold_32:
            return 32
            
        // Title
        case .bold_28:
            return 28
        case .bold_24, .semibold_24:
            return 24
        case .semibold_22:
            return 22
            
        // Body
        case .bold_20:
            return 20
        case .regular_19:
            return 19
        case .bold_18, .semibold_18, .regular_18:
            return 18
        case .semibold_17:
            return 17
        case .bold_16, .semibold_16, .medium_16, .regular_16_150, .regular_16_140:
            return 16
        case .regular_15, .medium_15:
            return 15
        case .bold_14, .semibold_14, .regular_14_160, .regular_14_140:
            return 14
        case .medium_13, .regular_13:
            return 13
        case .bold_12, .semibold_12, .regular_12:
            return 12
        case .medium_10:
            return 10
        }
    }
    
    private var fontWeight: PretendardWeight {
        switch self {
        // Bold
        case .bold_32, .bold_28, .bold_24,
             .bold_20, .bold_18, .bold_16, .bold_14, .bold_12:
            return .bold
            
        // SemiBold
        case .semibold_24, .semibold_22,
             .semibold_18, .semibold_17, .semibold_16, .semibold_14, .semibold_12:
            return .semiBold
            
        // Medium
        case .medium_16, .medium_15, .medium_13, .medium_10:
            return .medium
            
        // Regular
        case .regular_19, .regular_18, .regular_16_150, .regular_16_140,
             .regular_15, .regular_14_160, .regular_14_140, .regular_13, .regular_12:
            return .regular
        }
    }
    
    private var lineHeightPercent: CGFloat {
        switch self {
        // Headline
        case .bold_32:
            return 140
            
        // Title
        case .bold_28, .bold_24, .semibold_22:
            return 140
        case .semibold_24:
            return 120
            
        // Body
        case .bold_20:
            return 140
        case .regular_19:
            return 150
        case .bold_18, .semibold_18, .regular_18:
            return 140
        case .semibold_17:
            return 100
        case .bold_16, .semibold_16:
            return 140
        case .medium_16:
            return 120
        case .regular_16_150:
            return 150
        case .regular_16_140:
            return 140
        case .regular_15:
            return 180
        case .medium_15:
            return 140
        case .bold_14, .semibold_14:
            return 140
        case .regular_14_160:
            return 160
        case .regular_14_140:
            return 140
        case .medium_13:
            return 150
        case .regular_13:
            return 120
        case .bold_12, .semibold_12, .regular_12:
            return 140
            
        // Label
        case .medium_10:
            return 100
        }
    }
    
    var fontSize: CGFloat {
            return baseFontSize.adjusted
        }

    // 실제 lineHeight 계산
    var lineHeight: CGFloat {
        return (baseFontSize * lineHeightPercent / 100).adjusted
    }
    
    var letterSpacing: CGFloat {
        return 0
    }
    
    var font: Font {
          return .custom(fontWeight.fontName, size: fontSize)
      }
      
      var uiFont: UIFont {
          return UIFont(name: fontWeight.fontName, size: fontSize)
              ?? .systemFont(ofSize: fontSize, weight: fontWeight.uiFontWeight)
      }
}

//MARK: - PretendardWeight
enum PretendardWeight {
    case bold
    case semiBold
    case medium
    case regular

    var fontName: String {
        switch self {
        case .bold: return "Pretendard-Bold"
        case .semiBold: return "Pretendard-SemiBold"
        case .medium: return "Pretendard-Medium"
        case .regular: return "Pretendard-Regular"
        }
    }
    
    var uiFontWeight: UIFont.Weight {
        switch self {
        case .bold: return .bold
        case .semiBold: return .semibold
        case .medium: return .medium
        case .regular: return .regular
        }
    }
}
