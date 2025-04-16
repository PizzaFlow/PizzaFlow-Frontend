//
//  LocationManager.swift
//  PizzaFlow
//
//  Created by 596 on 23.03.2025.
//

import Combine
import YandexMapsMobile
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var city: String = ""
    @Published var street: String = ""
    @Published var house: String = ""
    @Published var apartment: String = ""
    @Published var currentLocation: YMKPoint?
    @Published var locationError: String?

    private let searchManager: YMKSearchManager
    private var searchSession: YMKSearchSession?
    private let locationManager = CLLocationManager()

    override init() {
        searchManager = YMKSearchFactory.instance().createSearchManager(with: .combined)
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        print("📍 Запрос разрешения на геолокацию")
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let point = YMKPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        currentLocation = point
        locationError = nil
        print("📍 Текущая геолокация: \(point.latitude), \(point.longitude)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Ошибка получения геолокации: \(error)")
        currentLocation = nil
        locationError = "Не удалось получить геолокацию. Проверьте настройки."
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("📍 Геолокация разрешена")
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("❌ Доступ к геолокации запрещён")
            currentLocation = nil
            locationError = "Не удалось получить геолокацию. Проверьте настройки."
        case .notDetermined:
            print("📍 Ожидание разрешения на геолокацию")
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    // MARK: - Геокодирование (поиск адреса по координатам)

    func fetchAddress(from point: YMKPoint, completion: ((Bool) -> Void)? = nil) {
        print("📍 Вызван fetchAddress для точки: \(point.latitude), \(point.longitude)")
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

                self?.city = components.count > 1 ? components[1] : "" // "Москва"
                self?.street = components.count > 2 ? components[2] : "" // Улица
                self?.house = components.count > 3 ? components[3] : "" // Дом
                self?.apartment = ""

                print("✅ Определен адрес: Город: \(self?.city ?? "не найден"), Улица: \(self?.street ?? "не найден"), Дом: \(self?.house ?? "не найден")")

                completion?(true)
            }
        }
    }

    // MARK: - Прямое геокодирование (поиск координат по адресу)

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
