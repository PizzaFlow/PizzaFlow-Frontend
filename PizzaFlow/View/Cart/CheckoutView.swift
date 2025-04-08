//
//  MakeOrderSheet.swift
//  PizzaFlow
//
//  Created by 596 on 06.04.2025.
//

import SwiftUI

import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var apiClient: ApiClient
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showAddressPicker = false
    @State private var deliveryTimes: [DeliveryTime] = []
    @State private var showTimePicker = false
    @State private var selectedTime: DeliveryTime?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Binding var selectedTab: Tab
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Button(action: {
                    showAddressPicker.toggle()
                }) {
                    SectionView(title: "Адрес доставки") {
                        if let address = apiClient.selectedAddress {
                            HStack {
                                Text("\(address.city), \(address.street), \(address.house)")
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                        } else {
                            HStack {
                                Text("Выберите адрес")
                                    .foregroundColor(.gray)
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                        }
                    }
                }
                .sheet(isPresented: $showAddressPicker) {
                    AddressPickerView()
                        .environmentObject(apiClient)
                }
                .foregroundColor(.primary)
                
                SectionView(title: "Время доставки") {
                    Button(action: loadDeliveryTimes) {
                        HStack {
                            if let selectedTime = selectedTime {
                                Text(selectedTime.timeRange)
                            } else {
                                Text("Выберите время доставки")
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if isLoading {
                                ProgressView()
                            } else {
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .disabled(isLoading)
                SectionView(title: "Способ оплаты") {
                    VStack(spacing: 8) {
                        PaymentOption(
                            title: "Картой при получении",
                            isSelected: apiClient.paymentMethod == .card,
                            action: { apiClient.paymentMethod = .card }
                        )
                        
                        PaymentOption(
                            title: "Наличными при получении",
                            isSelected: apiClient.paymentMethod == .cash,
                            action: { apiClient.paymentMethod = .cash }
                        )
                    }
                }
                
                SectionView(title: "Ваш заказ") {
                    ForEach(cartManager.cartItems) { item in
                        CartItemRow(item: item)
                    }
                }
               
                VStack(spacing: 8) {
                    HStack {
                        Text("Товары")
                        Spacer()
                        Text("\(cartManager.totalPrice) ₽")
                    }
                    
                    HStack {
                        Text("Доставка")
                        Spacer()
                        Text("0 ₽")
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Итого")
                            .font(.headline)
                        Spacer()
                        Text("\(cartManager.totalPrice) ₽")
                            .font(.headline.bold())
                    }
                }
                .padding(.vertical, 8)
           
                Button(action: submitOrder) {
                    HStack {
                        Spacer()
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Оформить заказ")
                                .bold()
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isSubmitting)
            }
            .padding()
        }
        .navigationTitle("Оформление заказа")
        .sheet(isPresented: $showSuccess) {
            OrderSuccessView(selectedTab: $selectedTab)
        }
        .sheet(isPresented: $showTimePicker) {
            DeliveryTimePickerView(
                times: deliveryTimes,
                selectedTime: $selectedTime
            )
        }

    }
    
    private func loadDeliveryTimes() {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                deliveryTimes = try await apiClient.fetchDeliveryTimes()
                showTimePicker = true
            } catch {
                errorMessage = "Не удалось загрузить доступное время"
                print("Ошибка загрузки времени: \(error)")
            }
            
            isLoading = false
        }
    }
    
    private func submitOrder() {
        errorMessage = nil
        isSubmitting = true
        
        guard let address = apiClient.selectedAddress else {
            errorMessage = "Выберите адрес доставки"
            isSubmitting = false
            return
        }
        
        Task {
            do {
                let addresses = try await apiClient.fetchAddresses()
                
                guard apiClient.addresses.contains(where: { $0.id == address.id }) else {
                    await MainActor.run {
                        errorMessage = "Адрес недействителен. Выберите другой"
                        isSubmitting = false
                    }
                    return
                }

                let request = try prepareOrderRequest()
                let order = try await apiClient.createOrder(request: request)
                
                await MainActor.run {
                    cartManager.clearCart()
                    isSubmitting = false
                    showSuccess = true
                    // Сохраняем заказ если нужно
                    apiClient.currentOrder = order
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = handleOrderError(error)
                }
            }
        }
    }

    private func handleOrderError(_ error: Error) -> String {
        switch error {
        case NetworkError.unauthorized:
            return "Требуется авторизация"
        case NetworkError.serverError(let code):
            return "Ошибка сервера (код \(code))"
        case NetworkError.decodingError:
            return "Ошибка обработки данных"
        default:
            return "Ошибка оформления заказа"
        }
    }

    private func prepareOrderRequest() throws -> CreateOrderRequest {
        guard let addressId = apiClient.selectedAddress?.id else {
            throw ValidationError.addressNotSelected
        }
        
        guard let deliveryTimeRange = selectedTime?.timeRange else {
            throw ValidationError.timeNotSelected
        }
        
        let deliveryTime = deliveryTimeRange.components(separatedBy: "-").first ?? ""

        let paymentMethodString: String
        switch apiClient.paymentMethod {
        case .card:
            paymentMethodString = "Картой при получении"
        case .cash:
            paymentMethodString = "Наличными при получении"
        }
        
        return CreateOrderRequest(
            addressId: addressId,
            pizzas: cartManager.cartItems.map { item in
                OrderPizzaRequest(
                    pizzaId: item.pizza.id,
                    ingredients: item.selectedIngredients.map { ingredient in
                        OrderIngredientRequest(
                            ingredientId: ingredient.id,
                            isAdded: true,
                            count: 1
                        )
                    }
                )
            },
            deliveryTime: deliveryTime,
            paymentMethod: paymentMethodString
        )
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            
            content
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

struct DeliveryTimeOption: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .foregroundColor(.primary)
    }
}

struct PaymentOption: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .foregroundColor(.primary)
    }
}

