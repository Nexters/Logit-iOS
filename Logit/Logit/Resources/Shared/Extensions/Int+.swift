//
//  Int+.swift
//  Logit
//
//  Created by 임재현 on 1/22/26.
//

import SwiftUI

extension Int {
    var adjusted: CGFloat {
        return CGFloat(self).adjusted
    }
    
    var adjustedLayout: CGFloat {
        return CGFloat(self).adjustedLayout
    }
    
    var adjustedWidth: CGFloat {
        return CGFloat(self).adjustedWidth
    }
    
    var adjustedHeight: CGFloat {
        return CGFloat(self).adjustedHeight
    }
}
