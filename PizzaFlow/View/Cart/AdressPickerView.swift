//
//  AdressPickerView.swift
//  PizzaFlow
//
//  Created by 596 on 07.04.2025.
//

import SwiftUI

struct AddressPickerView: View {
    @EnvironmentObject var apiClient: ApiClient
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(apiClient.addresses) { address in
                Button(action: {
                    apiClient.selectedAddress = address
                    dismiss()
                }) {
                    VStack(alignment: .leading) {
                        Text(address.city)
                            .font(.headline)
                        Text("\(address.street), \(address.house)")
                            .font(.subheadline)
                        if !address.apartment.isEmpty {
                            Text("Кв. \(address.apartment)")
                                .font(.subheadline)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Выберите адрес")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}
