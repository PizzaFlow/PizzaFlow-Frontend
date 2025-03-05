//
//  YandexMapView.swift
//  PizzaFlow
//
//  Created by 596 on 02.03.2025.
//

import SwiftUI
import YandexMapsMobile

struct YandexMapView: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme

    func makeUIView(context: Context) -> YMKMapView {
        let mapView = YMKMapView()

        let targetLocation = YMKPoint(latitude: 55.751244, longitude: 37.618423)
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(target: targetLocation, zoom: 12, azimuth: 0, tilt: 0),
            animation: YMKAnimation(type: .smooth, duration: 1),
            cameraCallback: nil
        )

        return mapView
    }

    func updateUIView(_ uiView: YMKMapView, context: Context) {
        applyDarkTheme(uiView, isDarkMode: colorScheme == .dark)
    }

    private func applyDarkTheme(_ mapView: YMKMapView, isDarkMode: Bool) {
        let darkStyle = """
        {
            "version": "1.0",
            "settings": {
                "landColor": "#1d1d1d",
                "waterColor": "#121212",
                "landmarkColor": "#242424"
            },
            "layers": []
        }
        """
        if isDarkMode {
            mapView.mapWindow.map.setMapStyleWithStyle(darkStyle)
        } else {
            mapView.mapWindow.map.setMapStyleWithStyle("")
        }
    }
}






