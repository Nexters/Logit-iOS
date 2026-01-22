//
//  ColorTestView.swift
//  Logit
//
//  Created by 임재현 on 1/22/26.
//

import SwiftUI

struct ColorTestView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // GrayScale Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("GrayScale")
                        .typo(.title1_bold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        ColorItemView(colorName: "Gray 20", color: .gray20)
                        ColorItemView(colorName: "Gray 50", color: .gray50)
                        ColorItemView(colorName: "Gray 70", color: .gray70)
                        ColorItemView(colorName: "Gray 100", color: .gray100)
                        ColorItemView(colorName: "Gray 200", color: .gray200)
                        ColorItemView(colorName: "Gray 300", color: .gray300)
                        ColorItemView(colorName: "Gray 400", color: .gray400)
                    }
                }
                
                Divider()
                    .padding(.vertical)
                
                // Icon Colors Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Icon Colors")
                        .typo(.title1_bold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        ColorItemView(colorName: "Icon 1", color: .icon1)
                        ColorItemView(colorName: "Icon 2", color: .icon2)
                        ColorItemView(colorName: "Icon 3", color: .icon3)
                        ColorItemView(colorName: "Icon 4", color: .icon4)
                        ColorItemView(colorName: "Icon 5", color: .icon5)
                        ColorItemView(colorName: "Icon 6", color: .icon6)
                        ColorItemView(colorName: "Icon 7", color: .icon7)
                        ColorItemView(colorName: "Icon 8", color: .icon8)
                        ColorItemView(colorName: "Alert", color: .alert)
                    }
                }
                
                Divider()
                    .padding(.vertical)
                
                // Primary Colors Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Primary Colors")
                        .typo(.title1_bold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        ColorItemView(colorName: "Primary 20", color: .primary20)
                        ColorItemView(colorName: "Primary 50", color: .primary50)
                        ColorItemView(colorName: "Primary 70", color: .primary70)
                        ColorItemView(colorName: "Primary 100", color: .primary100)
                        ColorItemView(colorName: "Primary 200", color: .primary200)
                        ColorItemView(colorName: "Primary 300", color: .primary300)
                        ColorItemView(colorName: "Primary 400", color: .primary400)
                        ColorItemView(colorName: "Primary 500", color: .primary500)
                        ColorItemView(colorName: "Primary 600", color: .primary600)
                    }
                }
                
                Divider()
                    .padding(.vertical)
                
                // Secondary Colors Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Secondary Colors")
                        .typo(.title1_bold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        ColorItemView(colorName: "Secondary 100", color: .secondary100)
                    }
                }
                
                Divider()
                    .padding(.vertical)
                
                // Gradients Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Gradients")
                        .typo(.title1_bold)
                    
                    VStack(spacing: 20) {
                        GradientItemView(
                            gradientName: "Logo Gradient",
                            gradient: GradientStyle.logo.gradient
                        )
                        
                        GradientItemView(
                            gradientName: "Empty 100",
                            gradient: GradientStyle.empty100.gradient
                        )
                        
                        GradientItemView(
                            gradientName: "Empty 200",
                            gradient: GradientStyle.empty200.gradient
                        )
                    }
                }
                
                Divider()
                    .padding(.vertical)
                
                // Combined Usage Example
                VStack(alignment: .leading, spacing: 16) {
                    Text("Usage Examples")
                        .typo(.title1_bold)
                    
                    VStack(spacing: 20) {
                        // Text with colors
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Primary Text")
                                .typo(.body3_bold)
                                .foregroundColor(.primary500)
                            
                            Text("Secondary Text")
                                .typo(.body5_regular_150)
                                .foregroundColor(.gray300)
                            
                            Text("Icon Color Example")
                                .typo(.body7_regular_140)
                                .foregroundColor(.icon5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.gray20)
                        .cornerRadius(12)
                        
                        // Circle with logo gradient
                        VStack(spacing: 8) {
                            Circle()
                                .fill(.gradient(.logo))
                                .frame(width: 100, height: 100)
                            
                            Text("Circle with Logo Gradient")
                                .typo(.body7_regular_140)
                                .foregroundColor(.gray400)
                        }
                        
                        // Card with gradient and colors
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.icon6)
                                
                                Text("Premium Feature")
                                    .typo(.body5_bold)
                                    .foregroundColor(.primary500)
                            }
                            
                            Text("This card combines gradient background with various text colors")
                                .typo(.body7_regular_140)
                                .foregroundColor(.gray400)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .gradientFill(.empty100)
                        .cornerRadius(16)
                        
                        // Alert Example
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.alert)
                            
                            Text("Alert message example")
                                .typo(.body7_semibold)
                                .foregroundColor(.gray400)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.primary20)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Color Test")
    }
}

// MARK: - Color Item View

struct ColorItemView: View {
    let colorName: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text(colorName)
                .typo(.body9_regular)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

// MARK: - Gradient Item View

struct GradientItemView: View {
    let gradientName: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(gradientName)
                .typo(.body5_semibold)
            
            RoundedRectangle(cornerRadius: 16)
                .fill(gradient)
                .frame(height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}
