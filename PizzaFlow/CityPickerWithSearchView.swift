//
//  CityPickerWithSearchView.swift
//  PizzaFlow
//
//  Created by 596 on 19.03.2025.
//

import SwiftUI

struct CityPickerWithSearchView: View {
    @Binding var selectedCity: String
    @State private var searchQuery: String = ""

    let cities = ["Москва", "Санкт-Петербург", "Новосибирск", "Екатеринбург", "Нижний Новгород", "Казань", "Самара"]

    var filteredCities: [String] {
        cities.filter { city in
            searchQuery.isEmpty || city.lowercased().contains(searchQuery.lowercased())
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Menu {
                VStack {
                    TextField("Поиск города", text: $searchQuery)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        .font(.system(size: 14))
                        .frame(height: 44)
                    
                    ForEach(filteredCities, id: \.self) { city in
                        Button(action: {
                            selectedCity = city
                        }) {
                            Text(city)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                .font(.system(size: 14))
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedCity.isEmpty ? "Выберите город" : selectedCity)
                        .font(.system(size: 16))
                        .foregroundColor(Color("Dark"))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color("Orange"))
                }
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color.white)
                .cornerRadius(12)
                .frame(height: 44)
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
}
