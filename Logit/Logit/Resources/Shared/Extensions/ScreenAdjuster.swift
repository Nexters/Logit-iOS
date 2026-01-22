//
//  ScreenAdjuster.swift
//  Logit
//
//  Created by 임재현 on 1/22/26.
//

import SwiftUI

struct ScreenAdjuster {
    /// 기준 디바이스 (iPhone 13 mini)
    private static let baseWidth: CGFloat = 375
    private static let baseHeight: CGFloat = 812
    
    /// 현재 화면 크기
    private static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    private static var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    /// Width 기준 비율
    static var widthRatio: CGFloat {
        screenWidth / baseWidth
    }
    
    /// Height 기준 비율
    static var heightRatio: CGFloat {
        screenHeight / baseHeight
    }
    
    /// 타이포그래피용 스케일 비율
    static var fontScaleRatio: CGFloat {
        let ratio = max(widthRatio, heightRatio)
        return min(max(ratio, 0.9), 1.1)
    }
    
    /// 레이아웃용 스케일 비율
    static var layoutScaleRatio: CGFloat {
        let ratio = max(widthRatio, heightRatio)
        return min(max(ratio, 0.85), 1.15)
    }
}
