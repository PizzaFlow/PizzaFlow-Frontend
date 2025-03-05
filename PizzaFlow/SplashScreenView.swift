//
//  SplashScreenView.swift
//  PizzaFlow
//
//  Created by 596 on 04.03.2025.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var showSplash: Bool
    @State private var opacity = 0.0
    var body: some View {
        ZStack {
            Color("DarkBlue").ignoresSafeArea(.all)
            VStack {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1))
            }
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1.5)) {
                    opacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    print("SplashScreen завершён, загружаем ContentView")
                    showSplash = false
                }
            }
        }
    }
}
