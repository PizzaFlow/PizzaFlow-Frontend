//
//  IngredientRow.swift
//  PizzaFlow
//
//  Created by 596 on 06.03.2025.
//

import SwiftUI


struct IngredientRow: View {
    let ingredient: Ingredient
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: ingredient.photo ?? "")) { photo in
                photo.resizable()
                    .scaledToFit()
            } placeholder: {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading) {
                Text(ingredient.name)
                    .foregroundColor(.black)
                    .font(.system(size: 18, weight: .bold))
                Text("\(String(format: "%.2f", ingredient.price)) ₽")
                    .foregroundColor(Color("Orange"))
                    .font(.system(size: 16))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: {
                withAnimation{
                    onToggle()
                }
            }) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? .green : .gray)
            }
        }
        .padding()
    }
}
#Preview {
    IngredientRow(
        ingredient: Ingredient(id: 1, name: "Сыр", price: 50.0, photo: nil),
        isSelected: false,
        onToggle: {}
    )
}
