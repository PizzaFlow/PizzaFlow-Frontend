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
        
        init(_ parent: YandexMapView) {
            self.parent = parent
        }
        
        func onCameraPositionChanged(
            with map: YMKMap,
            cameraPosition: YMKCameraPosition,
            cameraUpdateReason cameraUpdateSource: YMKCameraUpdateReason,
            finished: Bool
        ) {
            if finished {
                print("📍 Новая координата центра: \(cameraPosition.target.latitude), \(cameraPosition.target.longitude)")
                parent.locationManager.fetchAddress(from: cameraPosition.target)
            }
        }
    }
}
