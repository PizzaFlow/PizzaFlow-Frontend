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
    @State private var tempAddressInput: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var isKeyboardVisible = false
    @State private var hasInitializedCamera = false

    let minHeight: CGFloat = 400
    let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.9
    let middleHeight: CGFloat = UIScreen.main.bounds.height * 0.5

    init(selectedTab: Binding<Tab>) {
        self._selectedTab = selectedTab
        let initialPoint = YMKPoint(latitude: 55.7558, longitude: 37.6173)
        self._cameraPosition = State(initialValue: YMKCameraPosition(target: initialPoint, zoom: 12, azimuth: 0, tilt: 0))
    }

    var body: some View {
        ZStack {
            YandexMapView(cameraPosition: $cameraPosition)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)

            Image(systemName: "mappin.and.ellipse")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(Color("Orange"))
                .position(x: UIScreen.main.bounds.width / 2, y: (UIScreen.main.bounds.height - minHeight) / 2)

            addressSheet
        }
        .edgesIgnoringSafeArea(.all)
        .onReceive(locationManager.$city.combineLatest(locationManager.$street, locationManager.$house)) { city, street, house in
            let newAddress = "\(city), \(street)\(house.isEmpty ? "" : ", \(house)")"
            addressInput = newAddress
            tempAddressInput = newAddress
            print("🔄 Обновление TextField через onReceive: \(newAddress)")
        }
        .onReceive(locationManager.$currentLocation) { newLocation in
            guard let location = newLocation else { return }
            if !hasInitializedCamera {
                print("📍 Обновление геолокации: \(location.latitude), \(location.longitude)")
                cameraPosition = YMKCameraPosition(target: location, zoom: 16, azimuth: 0, tilt: 0)
                hasInitializedCamera = true
            }
        }
        .onAppear {
            print("📍 Вызван onAppear, hasInitializedCamera: \(hasInitializedCamera)")
            // Настройка уведомлений клавиатуры
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    DispatchQueue.main.async {
                        keyboardHeight = keyboardFrame.height
                        isKeyboardVisible = true
                        print("⌨️ Клавиатура показана, isKeyboardVisible: \(isKeyboardVisible)")
                    }
                }
            }

            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                DispatchQueue.main.async {
                    keyboardHeight = 0
                    isKeyboardVisible = false
                    print("⌨️ Клавиатура скрыта, isKeyboardVisible: \(isKeyboardVisible)")
                }
            }
        }
    }

    var addressSheet: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.white.opacity(0.4))
                .frame(width: 50, height: 5)
                .padding(.top, 12)

            HStack {
                Text("Адрес доставки")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                Button(action: {
                    hideKeyboard()
                    isKeyboardVisible = false
                }) {
                    Image(systemName: "keyboard")
                        .foregroundColor(Color("Orange"))
                        .padding()
                        .background(Color("Dark"))
                        .clipShape(Circle())
                }
                .opacity(isKeyboardVisible ? 1 : 0)
                .padding(.horizontal)
            }

            

            VStack(alignment: .leading, spacing: 8) {
                Text("Адрес (город, улица, дом)")
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
                            let components = newValue.components(separatedBy: ", ")
                            locationManager.city = components.first ?? ""
                            locationManager.street = components.count > 1 ? components[1] : ""
                            locationManager.house = components.count > 2 ? components[2] : ""
                            addressInput = newValue
                        }
                        .onTapGesture {
                            print("🖱️ TextField получил фокус")
                        }

                    Button(action: {
                        guard !tempAddressInput.isEmpty else { return }
                        locationManager.fetchCoordinates(from: tempAddressInput) { point in
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
            .padding(.horizontal)

            Button(action: {
                guard !locationManager.apartment.isEmpty else {
                    print("❌ Введите номер квартиры")
                    return
                }

                let city = locationManager.city
                let street = locationManager.street
                let house = locationManager.house
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
