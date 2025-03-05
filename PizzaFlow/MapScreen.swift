//
//  MapScreen.swift
//  PizzaFlow
//
//  Created by 596 on 02.03.2025.
//

import SwiftUI
import YandexMapsMobile


struct MapScreen: View {
    @Binding var selectedTab: Tab
    @State private var userAddress: String = "Волокамское шоссе, 4"
    @State private var sheetOffset: CGFloat
    let minHeight: CGFloat = 360
    let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.9
    init(selectedTab: Binding<Tab>) {
        self._selectedTab = selectedTab
        self._sheetOffset = State(initialValue: UIScreen.main.bounds.height * 0.6)
    }
    var body: some View {
        ZStack {
            YandexMapView()
                .frame(maxWidth: .infinity, maxHeight:.infinity)
                .edgesIgnoringSafeArea(.all)
            addressSheet
        }
        .edgesIgnoringSafeArea(.all)
    }
    var addressSheet: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(Color.white.opacity(0.4))
                .frame(width: 50, height: 5)
                .padding(.top, 20)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let newOffset = sheetOffset - gesture.translation.height
                            if newOffset >= minHeight && newOffset <= maxHeight{
                                sheetOffset = newOffset
                            }
                        }
                        .onEnded{ _ in
                            withAnimation {
                                if sheetOffset > maxHeight * 0.7 {
                                    sheetOffset = maxHeight
                                } else {
                                    sheetOffset = minHeight
                                }
                            }
                        }
                )
            HStack {
                Text("Ваш адрес")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding()
            }

            HStack {
                TextField("Введите адрес", text: $userAddress)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .frame(height: 40)
                    
                Button(action: {
                        //
                }) {
                    Image(systemName: "questionmark")
                        .foregroundColor(Color("Orange"))
                        .padding()
                    }
                }
                .padding(.horizontal)

                // 3. Кнопка "Верно"
                Button(action: {
                    withAnimation {
                        sheetOffset = minHeight
                    }
                }) {
                    Text("Верно")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 180, height: 45)
                        .background(Color("Orange"))
                        .cornerRadius(12)
                }

                Spacer()
            }
            .frame(height: minHeight)
            .background(Color("Dark"))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .edgesIgnoringSafeArea(.bottom)
           // .padding(.bottom, 0)
            .offset(y: maxHeight - sheetOffset - 20)
            .animation(.easeInOut(duration: 0.3), value: sheetOffset)
    }
}


#Preview {
    MapScreen(selectedTab: .constant(.map))
}
