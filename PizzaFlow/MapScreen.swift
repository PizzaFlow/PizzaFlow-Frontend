//
//  MapScreen.swift
//  PizzaFlow
//
//  Created by 596 on 02.03.2025.
//

import SwiftUI
import YandexMapsMobile

struct MapScreen: View {
    @Binding var selectedTab: Tab
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var apiClient: ApiClient
    @State private var cameraPosition: YMKCameraPosition?
    @State private var addressInput: String = ""
    @State private var isLoading = false
    @State private var apartmentInput: String = ""
    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height * 0.6
    @State private var lastUpdateTime = Date()
    @State private var lastPosition: YMKPoint?
    @State private var isCameraMoving = false
    @State private var selectedCity: String = ""
    @State private var tempAddressInput: String = ""
    @State private var keyboardHeight: CGFloat = 0

    let minHeight: CGFloat = 400
    let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.9
    let middleHeight: CGFloat = UIScreen.main.bounds.height * 0.5

    init(selectedTab: Binding<Tab>) {
        self._selectedTab = selectedTab
    }

    var body: some View {
        ZStack {
            YandexMapView(cameraPosition: $cameraPosition)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)

            addressSheet
            Image(systemName: "mappin.and.ellipse")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(Color("Orange"))
                .offset(y: -20)
        }
        .edgesIgnoringSafeArea(.all)
        .onChange(of: cameraPosition) { oldValue, newValue in
            guard let newTarget = newValue?.target else { return }

            let now = Date()
            if now.timeIntervalSince(lastUpdateTime) > 30.0 {
                lastUpdateTime = now
                locationManager.fetchAddress(from: newTarget) { success in
                    if success {
                        DispatchQueue.main.async {
                            addressInput = "\(locationManager.street), \(locationManager.house)"
                        }
                    }
                }
            }
        }
        .onChange(of: addressInput) { newValue in
            tempAddressInput = newValue
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height
                }
            }

            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardHeight = 0
            }
        }
    }

    var addressSheet: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.white.opacity(0.4))
                .frame(width: 50, height: 5)
                .padding(.top, 12)

            Text("Адрес доставки")
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("Улица и дом")
                    .font(.footnote)
                    .foregroundColor(.gray)

                HStack {
                    TextField("Введите адрес", text: $tempAddressInput)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .frame(height: 44)
                        .keyboardType(.default)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .onChange(of: tempAddressInput) { newValue in
                            locationManager.street = newValue
                            locationManager.house = ""
                            addressInput = newValue
                        }

                    Button(action: {
                        guard !addressInput.isEmpty else { return }
                        locationManager.fetchCoordinates(from: addressInput) { point in
                            if let newPoint = point {
                                cameraPosition = YMKCameraPosition(target: newPoint, zoom: 16, azimuth: 0, tilt: 0)
                            }
                        }
                    }) {
                        Image(systemName: "location.magnifyingglass")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color("Orange"))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal)

            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Город:")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    CityPickerWithSearchView(selectedCity: $selectedCity)
                        .frame(height: 44)
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 14) {
                    Text("Квартира")
                        .font(.footnote)
                        .foregroundColor(.gray)

                    TextField("Введите номер квартиры", text: $locationManager.apartment)
                        .padding()
                        .frame(height: 44)
                        .keyboardType(.numberPad)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                        )
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)

            Button(action: {
                guard !locationManager.apartment.isEmpty else {
                    print("❌ Введите номер квартиры")
                    return
                }

                let city = selectedCity.isEmpty ? locationManager.city : selectedCity
                let fullAddress = locationManager.street

                let addressComponents = fullAddress.components(separatedBy: ", ")
                let street = addressComponents.first ?? ""
                let house = addressComponents.count > 1 ? addressComponents[1] : ""

                locationManager.street = street
                locationManager.house = house
                let apartment = locationManager.apartment

                apiClient.addAddress(
                    city: city,
                    street: street,
                    house: house,
                    apartment: apartment
                ) { success, errorMessage in
                    DispatchQueue.main.async {
                        if success {
                            print("✅ Адрес успешно сохранён!")
                            apiClient.fetchAddresses()

                            let newAddress = Address(
                                id: apiClient.addresses.count + 1,
                                city: city,
                                street: street,
                                house: house,
                                apartment: apartment,
                                user_id: 0
                            )
                            apiClient.selectedAddress = newAddress
                            selectedTab = .home
                        } else {
                            print("❌ Ошибка сохранения: \(errorMessage ?? "Неизвестная ошибка")")
                        }
                    }
                }
            }) {
                Text("Сохранить")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(locationManager.apartment.isEmpty ? Color.gray : Color("Orange"))
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
            .disabled(locationManager.apartment.isEmpty)
            .padding(.horizontal)

            Spacer()
        }
        .frame(height: minHeight)
        .background(
            Color("Dark")
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(radius: 5)
        )
        .edgesIgnoringSafeArea(.bottom)
        .offset(y: maxHeight - sheetOffset - 20 - keyboardHeight)
        .animation(.easeInOut(duration: 0.3), value: sheetOffset)
        .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
    }
}

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    MapScreen(selectedTab: .constant(.map))
        .environmentObject(LocationManager())
        .environmentObject(ApiClient())
}
