//
//  ExperienceTypeSection.swift
//  Logit
//
//  Created by 임재현 on 1/25/26.
//

import SwiftUI

struct ExperienceTypeSection: View {
    @State private var currentIndex: Int = 0
    private let totalCount = 8

    var body: some View {
        VStack(alignment: .leading, spacing: 12.adjustedLayout) {
            Text("경험 유형")
                .typo(.bold_18)
                .foregroundStyle(.black)

            ZStack(alignment: .bottomLeading) {
                TabView(selection: $currentIndex) {
                    ForEach(0..<totalCount, id: \.self) { index in
                        let imageIndex = index + 1
                        if let asset = NSDataAsset(name: "homeBanner_\(imageIndex)"),
                           let uiImage = UIImage(data: asset.data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Text("\(currentIndex + 1)/\(totalCount)")
                    .typo(.semibold_14)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10.adjustedLayout)
                    .padding(.vertical, 4.adjustedLayout)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(12)
                    .padding(.leading, 12.adjustedLayout)
                    .padding(.bottom, 12.adjustedLayout)
            }
            .frame(height: 155.adjustedHeight)
            .background(.white)
        }
        .padding(.horizontal, 20.adjustedLayout)
        .background(.white)
    }
}
