//
//  ExperienceTypeSection.swift
//  Logit
//
//  Created by 임재현 on 1/25/26.
//

import SwiftUI

struct ExperienceTypeSection: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 12.adjustedLayout) {
            Text("경험 유형")
                .typo(.bold_18)
                .foregroundStyle(.black)
            
            TabView {
                ForEach(1...8, id: \.self) { index in
                    if let asset = NSDataAsset(name: "homeBanner_\(index)"),
                       let uiImage = UIImage(data: asset.data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .clipped()
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 155.adjustedHeight)
            .background(.white)
        }
        .padding(.horizontal, 20.adjustedLayout)
        .background(.white)
    }
}
