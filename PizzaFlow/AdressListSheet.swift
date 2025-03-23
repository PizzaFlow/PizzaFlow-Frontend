//
//  AdressListSheet.swift
//  PizzaFlow
//
//  Created by 596 on 16.03.2025.
//

import SwiftUI

struct AddressListSheet: View {
    @ObservedObject var apiClient: ApiClient
    @State private var showMapScreen = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Ваши адреса")
                    .font(.title2.bold())
                    .padding(.top, 20)
                if apiClient.addresses.isEmpty {
                    Text("У вас нет сохраненных адресов")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                } else {
                    
                    List(apiClient.addresses, id: \.id) { address in
                        HStack {
                            Image(systemName: apiClient.selectedAddress?.id == address.id ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(apiClient.selectedAddress?.id == address.id ? Color("Orange") : Color.gray)
                                .onTapGesture {
                                    apiClient.selectedAddress = address
                                }
                            
                            VStack(alignment: .leading) {
                                Text("\(address.city), \(address.street), \(address.house)")
                                    .font(.headline)
                                Text("Квартира: \(address.apartment)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                            Menu {
                                Button(role: .destructive) {
                                    apiClient.deleteAddress(addressID: address.id)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .rotationEffect(.degrees(90))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Button(action: {
                    showMapScreen = true
                }) {
                    Text("Добавить новый адрес")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Orange"))
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showMapScreen) {
                MapScreen(selectedTab: .constant(.map))
            }
        }
    }
}
