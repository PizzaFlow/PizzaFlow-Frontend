//
//  ProfileMenuVIew.swift
//  PizzaFlow
//
//  Created by 596 on 05.03.2025.
//

import SwiftUI

struct ProfileMenuView: View {
    @Binding var selectedTab: Tab
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ProfileMenuView(selectedTab: .constant(.profile))
}
