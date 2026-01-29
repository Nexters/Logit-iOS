//
//  ContentView.swift
//  Logit
//
//  Created by 임재현 on 1/17/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Headline
                Group {
                    Text("Headline")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text("헤드라인 텍스트 Headline Text 123")
                        .typo(.bold_32)
                }
                
                Divider()
                
                // Title
                Group {
                    Text("Title")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text("타이틀1 볼드 Title1 Bold")
                        .typo(.bold_28)
                    
                    Text("타이틀2 볼드 Title2 Bold")
                        .typo(.bold_24)
                    
                    Text("타이틀2 세미볼드 Title2 SemiBold")
                        .typo(.semibold_24)
                    
                    Text("타이틀3 세미볼드 Title3 SemiBold")
                        .typo(.semibold_22)
                }
                
                Divider()
                
                // Body
                Group {
                    Text("Body")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text("바디1 볼드 Body1 Bold")
                        .typo(.bold_20)
                    
                    Text("바디2 레귤러 Body2 Regular")
                        .typo(.regular_19)
                    
                    Text("바디3 볼드 Body3 Bold")
                        .typo(.bold_18)
                    
                    Text("바디3 세미볼드 Body3 SemiBold")
                        .typo(.semibold_18)
                    
                    Text("바디3 레귤러 Body3 Regular")
                        .typo(.regular_18)
                    
                    Text("바디5 볼드 Body5 Bold")
                        .typo(.bold_16)
                    
                    Text("바디5 레귤러 150% Body5 Regular 150%")
                        .typo(.regular_16_150)
                    
                    Text("바디5 레귤러 140% Body5 Regular 140%")
                        .typo(.regular_16_140)
                    
                    Text("바디7 볼드 Body7 Bold")
                        .typo(.bold_14)
                    
                    Text("바디9 레귤러 Body9 Regular")
                        .typo(.regular_12)
                }
                
                Divider()
                
                // Label
                Group {
                    Text("Label")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text("라벨1 미디엄 Label1 Medium")
                        .typo(.medium_10)
                }
                
                Divider()
                
                // Multi-line Test
                Group {
                    Text("Multi-line Text")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text("여러 줄로 된 긴 텍스트입니다. Line Height가 제대로 적용되는지 확인하기 위한 텍스트입니다. This is a long text to test multi-line rendering with proper line height.")
                        .typo(.regular_16_150)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(20)
        }
    }
}

