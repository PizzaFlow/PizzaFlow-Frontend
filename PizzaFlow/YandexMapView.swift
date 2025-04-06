//
//  YandexMapView.swift
//  PizzaFlow
//
//  Created by 596 on 02.03.2025.
//

import SwiftUI
import YandexMapsMobile

struct YandexMapView: UIViewRepresentable {
    @EnvironmentObject var locationManager: LocationManager
    @Binding var cameraPosition: YMKCameraPosition?
    
    func makeUIView(context: Context) -> YMKMapView {
        let mapView = YMKMapView()
        
        // Устанавливаем начальную позицию камеры
        let targetLocation = YMKPoint(latitude: 55.751244, longitude: 37.618423)
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(target: targetLocation, zoom: 12, azimuth: 0, tilt: 0),
            animation: YMKAnimation(type: .smooth, duration: 1),
            cameraCallback: nil
        )
        
        // Добавляем слушателя изменений камеры
        mapView.mapWindow.map.addCameraListener(with: context.coordinator)
        

        
        return mapView
    }

    func updateUIView(_ uiView: YMKMapView, context: Context) {
        // Обновляем позицию камеры, если она изменилась
        if let cameraPosition = cameraPosition {
            uiView.mapWindow.map.move(
                with: cameraPosition,
                animation: YMKAnimation(type: .smooth, duration: 1),
                cameraCallback: nil
            )
        }
        
 
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }


    class Coordinator: NSObject, YMKMapCameraListener {
        var parent: YandexMapView
        private var lastUpdateTime = Date()
        private let updateInterval: TimeInterval = 1.0 // Задержка 1 сек между запросами
        private var lastPosition: YMKPoint?
        private let minDistance: Double = 50 // Минимальное расстояние для нового запроса (метры)

        init(_ parent: YandexMapView) {
            self.parent = parent
        }
        
        func onCameraPositionChanged(
            with map: YMKMap,
            cameraPosition: YMKCameraPosition,
            cameraUpdateReason: YMKCameraUpdateReason,
            finished: Bool
        ) {
            // 1. Пропускаем промежуточные обновления
            guard finished else { return }
            
            // 2. Проверяем временной интервал
            let now = Date()
            guard now.timeIntervalSince(lastUpdateTime) > updateInterval else { return }
            
            // 3. Проверяем расстояние от предыдущей точки
            if let lastPos = lastPosition {
                let distance = calculateDistance(from: lastPos, to: cameraPosition.target)
                guard distance > minDistance else { return }
            }
            
            // 4. Обновляем данные
            lastUpdateTime = now
            lastPosition = cameraPosition.target
            
            print("📍 Обновление: \(cameraPosition.target.latitude), \(cameraPosition.target.longitude)")
            parent.locationManager.fetchAddress(from: cameraPosition.target)
        }
        
        private func calculateDistance(from p1: YMKPoint, to p2: YMKPoint) -> Double {
            let latDiff = p1.latitude - p2.latitude
            let lonDiff = p1.longitude - p2.longitude
            return sqrt(latDiff * latDiff + lonDiff * lonDiff) * 111000 // Конвертация в метры
        }
    }
}
