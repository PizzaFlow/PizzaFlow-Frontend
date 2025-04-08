//
//  AdressListView.swift
//  PizzaFlow
//
//  Created by 596 on 06.04.2025.
//

import SwiftUI

struct AdressListView: View {
    @ObservedObject var apiClient: ApiClient
    private let accentColor = Color("Orange")
    private let backgroundColor = Color("Dark")
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            NavigationStack {
                VStack {
                    Text("Ваши адреса")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    if apiClient.addresses.isEmpty {
                        Text("У вас нет сохраненных адресов")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        List {
                            ForEach(apiClient.addresses, id: \.id) { address in
                                addressRow(for: address)
                                    .listRowBackground(Color("Dark"))
                            }
                            .onDelete { indices in
                                indices.forEach { index in
                                    let address = apiClient.addresses[index]
                                    apiClient.deleteAddress(addressID: address.id)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color("Dark"))
                        .scrollContentBackground(.hidden)
                    }
                }
                .background(Color("Dark"))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    private func addressRow(for address: Address) -> some View {
        HStack {
            
            VStack(alignment: .leading) {
                Text("\(address.city), \(address.street), \(address.house)")
                    .font(.headline)
                    .foregroundColor(.white)
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
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
}

