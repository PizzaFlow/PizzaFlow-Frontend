//
//  CartMenuView.swift
//  PizzaFlow
//
//  Created by 596 on 03.03.2025.
//

import SwiftUI

struct CartMenuView: View {
    @Binding var selectedTab: Tab
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        ZStack(alignment: .bottom) { 
            Color("Dark").ignoresSafeArea(.all)

            VStack {
                Text("Корзина")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Orange"))
                    .padding(.top, 20)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach($cartManager.cartItems) { $cartItem in
                            PizzaCartItemView(cartItem: $cartItem)
                                .id(cartItem.quantity)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 80)
                }
            }

           
            VStack {
                Button(action: {
                    print("Перейти к оформлению")
                }) {
                    VStack {
                        Text("К оформлению")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        Text("\(cartManager.cartItems.count) шт, \(cartManager.cartItems.reduce(0) { $0 + Int($1.finalPrice) }) ₽")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color("Greenn"))
                    .cornerRadius(20)
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 10)
            }
            .background(Color("Dark").ignoresSafeArea(edges: .bottom))
        }
    }
}

struct PizzaCartItemView: View {
    @State private var isIngridientPresented = false
    @EnvironmentObject var cartManager: CartManager
    @Binding var cartItem: CartItem
    var body: some View {
        VStack{
            HStack{
                AsyncImage(url: URL(string: cartItem.pizza.photo)) { image in
                    image.resizable()
                        .scaledToFit()
                } placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack{
                        Image(systemName: "banknote")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 23, height: 23)
                            .foregroundColor(Color("Orange"))
                        Text("\(cartItem.finalPrice, specifier: "%.0f") ₽")
                            .font(.system(size: 23, weight: .bold))
                            .foregroundColor(Color("Orange"))
                    }
                    Text(cartItem.pizza.name)
                        .font(.system(size: 20, weight: .light))
                    
                }
                Spacer()
            }
            HStack(spacing: 12) {
                Button(action: {
                    cartManager.removeFromCart(cartItem)
                }){
                    Image(systemName: "trash.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.red)
                        .padding(10)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
                
                Button(action: {
                    isIngridientPresented.toggle()
                }) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.red)
                        .padding(10)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
                .sheet(isPresented: $isIngridientPresented) {
                    IngridientView(pizza: cartItem.pizza, selectedIngredients: cartItem.selectedIngredients)
            }
            HStack {
                Button(action: {
                    if cartItem.quantity > 1 {
                        cartManager.updateQuantity(for: cartItem, quantity: cartItem.quantity - 1)
                    }
                }) {
                    Image(systemName: "minus")
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .padding(10)
                }

                Text("\(cartItem.quantity)")
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 25)
                    .foregroundColor(.white)
                    
                Button(action: {
                    cartManager.updateQuantity(for: cartItem, quantity: cartItem.quantity + 1)
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .padding(10)
                }
            }
            .frame(width: 110, height: 40)
            .background(Color("Orange"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
                
            Spacer()
                

                
            Button(action: { print("Покупка \(cartItem.pizza.name)") }) {
                Text("Купить")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 100, height: 40)
                    .background(Color("Greenn"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    .padding()
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 15))
    .overlay(
        RoundedRectangle(cornerRadius: 15)
            .stroke(Color("Orange").opacity(0.5), lineWidth: 3)
    )
}
private func calculateTotalPrice() -> Double {
    let price = cartItem.pizza.price
    let extraIngredientsPrice = cartItem.selectedIngredients
        .reduce(0) { $0 + $1.price }
    return price + extraIngredientsPrice
}
}

#Preview {
    CartMenuView(selectedTab: .constant(.cart))
}
