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
    @State private var showCheckout = false
    @EnvironmentObject var apiClient: ApiClient

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
                            PizzaCartItemView(cartItem: $cartItem, selectedTab: $selectedTab)
                                .id(cartItem.quantity)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 80)
                }
            }

           
            VStack {
                Button(action: {
                    showCheckout.toggle()
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
                .sheet(isPresented: $showCheckout){
                    CheckoutView(selectedTab: $selectedTab)
                        .environmentObject(cartManager)
                        .environmentObject(apiClient)
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
    @State private var showCheckout = false
    @EnvironmentObject var apiClient: ApiClient
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: cartItem.pizza.photo)) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                }
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text(cartItem.pizza.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("\(cartItem.finalPrice, specifier: "%.0f") ₽")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("Orange"))

                    if !cartItem.selectedIngredients.isEmpty {
                        Text(cartItem.selectedIngredients.prefix(3).map { $0.name }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.black)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
            }

            HStack {
                Button(action: {
                    cartManager.removeFromCart(cartItem)
                }) {
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
  
                Button(action: {
                    isIngridientPresented.toggle()
                }) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color("Orange"))
                        .padding(8)
                }
                
                Spacer()

                HStack(spacing: 0) {
                    Button(action: {
                        if cartItem.quantity > 1 {
                            cartManager.updateQuantity(for: cartItem, quantity: cartItem.quantity - 1)
                        }
                    }) {
                        Image(systemName: "minus")
                            .foregroundColor(.white).opacity(cartItem.quantity > 1 ? 1 : 0.5)
                            .frame(width: 24, height: 24)
                            .padding(10)
                            .background(Color("Orange"))
                    }
                    .disabled(cartItem.quantity <= 1)
                    
                    Text("\(cartItem.quantity)")
                        .font(.system(size: 18, weight: .bold))
                        .frame(minWidth: 25)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .background(Color("Orange"))
                    
                    Button(action: {
                        cartManager.updateQuantity(for: cartItem, quantity: cartItem.quantity + 1)
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .padding(10)
                            .background(Color("Orange"))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("Orange"), lineWidth: 1)
                )
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color("Orange").opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $isIngridientPresented) {
            IngridientView(pizza: cartItem.pizza, selectedIngredients: cartItem.selectedIngredients, selectedTab: $selectedTab)
        }
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
