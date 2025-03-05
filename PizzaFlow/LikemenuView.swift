//
//  LikemenuView.swift
//  PizzaFlow
//
//  Created by 596 on 03.03.2025.
//

import SwiftUI

struct LikemenuView: View {
    @Binding var selectedTab: Tab
    var body: some View {
        NavigationStack {
            Color("Dark").ignoresSafeArea(.all)
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

#Preview {
    LikemenuView(selectedTab: .constant(.favourites))
}
