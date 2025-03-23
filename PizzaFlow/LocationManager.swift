//
//  LocationManager.swift
//  PizzaFlow
//
//  Created by 596 on 23.03.2025.
//

import Combine
import YandexMapsMobile

class LocationManager: ObservableObject {
    @Published var city: String = ""
    @Published var street: String = ""
    @Published var house: String = ""
    @Published var apartment: String = ""

    private let searchManager: YMKSearchManager
    private var searchSession: YMKSearchSession?

    init() {
        searchManager = YMKSearchFactory.instance().createSearchManager(with: .combined)
    }

    func fetchAddress(from point: YMKPoint, completion: ((Bool) -> Void)? = nil) {
        let searchOptions = YMKSearchOptions()

        searchSession = searchManager.submit(
            with: point,
            zoom: 16,
            searchOptions: searchOptions
        ) { [weak self] response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Ошибка поиска адреса: \(error.localizedDescription)")
                    completion?(false)
                    return
                }

                guard let response = response,
                      let firstResult = response.collection.children.first?.obj,
                      let toponymMetadata = firstResult.metadataContainer.getItemOf(YMKSearchToponymObjectMetadata.self) as? YMKSearchToponymObjectMetadata else {
                    print("❌ Адрес не найден")
                    completion?(false)
                    return
                }

                let fullAddress = toponymMetadata.address.formattedAddress
                print("❗ Получен адрес: \(fullAddress)")
                let components = fullAddress.components(separatedBy: ", ")

                self?.city = components.first ?? ""
                self?.street = components.count > 1 ? components[1] : ""
                self?.house = components.count > 2 ? components[2] : ""
                self?.apartment = "" // Квартиру можно вводить вручную

                print("✅ Определен адрес: \(self?.city ?? "не найден"), \(self?.street ?? "не найден"), \(self?.house ?? "не найден")")

                completion?(true)
            }
        }
    }

    func fetchCoordinates(from address: String, completion: @escaping (YMKPoint?) -> Void) {
        let searchOptions = YMKSearchOptions()

        searchSession = searchManager.submit(
            withText: address,
            geometry: YMKGeometry(point: YMKPoint(latitude: 0, longitude: 0)),
            searchOptions: searchOptions
        ) { response, error in
            if let error = error {
                print("❌ Ошибка поиска координат: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let response = response,
                  let firstResult = response.collection.children.first?.obj,
                  let point = firstResult.geometry.first?.point else {
                print("❌ Координаты не найдены")
                completion(nil)
                return
            }

            completion(point)
        }
    }
}

