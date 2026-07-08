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
                if let asset = NSDataAsset(name: "homebanner_\(currentIndex + 1)"),
                   let uiImage = UIImage(data: asset.data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .id(currentIndex)
                        .transition(.identity)
                }

                Text("\(currentIndex + 1)/\(totalCount)")
                    .typo(.semibold_14)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16.adjustedLayout)
                    .padding(.vertical, 2.5.adjustedLayout)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.leading, 12.adjustedLayout)
                    .padding(.bottom, 12.adjustedLayout)
            }
            .frame(height: 155.adjustedHeight)
            .background(.white)
            .animation(.none, value: currentIndex)
            .gesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        if value.translation.width < 0 {
                            currentIndex = (currentIndex + 1) % totalCount
                        } else {
                            currentIndex = (currentIndex - 1 + totalCount) % totalCount
                        }
                    }
            )
        }
        .padding(.horizontal, 20.adjustedLayout)
        .background(.white)
    }
}
