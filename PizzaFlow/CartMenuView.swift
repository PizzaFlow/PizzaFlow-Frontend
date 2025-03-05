//
//  CartMenuView.swift
//  PizzaFlow
//
//  Created by 596 on 03.03.2025.
//

import SwiftUI

struct CartMenuView: View {
    @Binding var selectedTab: Tab
    var body: some View {
            Color("Dark").ignoresSafeArea(.all)
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .foregroundColor(.white)
    }
}

#Preview {
    CartMenuView(selectedTab: .constant(.cart))
}
