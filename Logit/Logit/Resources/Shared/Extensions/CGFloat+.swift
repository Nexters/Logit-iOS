//
//  CGFloat+.swift
//  Logit
//
//  Created by 임재현 on 1/22/26.
//

import SwiftUI

extension CGFloat {
    /// 폰트 사이즈 조정
    var adjusted: CGFloat {
        return self * ScreenAdjuster.fontScaleRatio
    }
    
    /// 레이아웃 사이즈 조정
    var adjustedLayout: CGFloat {
        return self * ScreenAdjuster.layoutScaleRatio
    }
    
    /// Width 기준 조정
    var adjustedWidth: CGFloat {
        return self * ScreenAdjuster.widthRatio
    }
    
    /// Height 기준 조정
    var adjustedHeight: CGFloat {
        return self * ScreenAdjuster.heightRatio
    }
}
