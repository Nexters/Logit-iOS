//
//  GradientStyle.swift
//  Logit
//
//  Created by 임재현 on 1/22/26.
//

import SwiftUI

enum GradientStyle {
    case logo
    case empty100
    case empty200
    
    var gradient: LinearGradient {
        switch self {
        case .logo:
            return LinearGradient(
                colors: [
                    Color(red: 0.35, green: 0.68, blue: 0.96),
                    Color(red: 0.4, green: 0.76, blue: 0.93)
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            
        case .empty100:
            return LinearGradient(
                colors: [
                    Color(red: 0.87, green: 0.9, blue: 1),
                    Color(red: 0.86, green: 0.96, blue: 0.96)
                ],
                startPoint: UnitPoint(x: 1, y: -0.08),
                endPoint: UnitPoint(x: 0.21, y: 0.71)
            )
            
        case .empty200:
            return LinearGradient(
                colors: [
                    Color(red: 0.83, green: 0.87, blue: 1),
                    Color(red: 0.85, green: 0.95, blue: 0.97)
                ],
                startPoint: UnitPoint(x: 1, y: -0.08),
                endPoint: UnitPoint(x: 0.21, y: 0.71)
            )
        }
    }
}


