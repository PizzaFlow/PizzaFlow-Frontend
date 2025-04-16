import SwiftUI
import YandexMapsMobile

struct YandexMapView: UIViewRepresentable {
    @EnvironmentObject var locationManager: LocationManager
    @Binding var cameraPosition: YMKCameraPosition?
    
    func makeUIView(context: Context) -> YMKMapView {
        let mapView = YMKMapView()
        let targetLocation: YMKPoint
        let zoomLevel: Float
        
        if let location = locationManager.currentLocation {
            targetLocation = location
            zoomLevel = 16
        } else {
            targetLocation = YMKPoint(latitude: 55.751244, longitude: 37.618423)
            zoomLevel = 12
        }
        
        let initialCameraPosition = YMKCameraPosition(target: targetLocation, zoom: zoomLevel, azimuth: 0, tilt: 0)
        mapView.mapWindow.map.move(
            with: initialCameraPosition,
            animation: YMKAnimation(type: .smooth, duration: 1),
            cameraCallback: nil
        )

        cameraPosition = initialCameraPosition
        mapView.mapWindow.map.addCameraListener(with: context.coordinator)
        
        return mapView
    }

    func updateUIView(_ uiView: YMKMapView, context: Context) {
        guard let cameraPosition = cameraPosition else { return }
        let currentPosition = uiView.mapWindow.map.cameraPosition
        let isSamePosition = abs(currentPosition.target.latitude - cameraPosition.target.latitude) < 0.0001 &&
                            abs(currentPosition.target.longitude - cameraPosition.target.longitude) < 0.0001 &&
                            abs(currentPosition.zoom - cameraPosition.zoom) < 0.1
        
        if !isSamePosition {
            print("📍 updateUIView: Перемещение карты в \(cameraPosition.target.latitude), \(cameraPosition.target.longitude)")
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
        private let updateInterval: TimeInterval = 1.0
        private var lastPosition: YMKPoint?
        private let minDistance: Double = 50

        init(_ parent: YandexMapView) {
            self.parent = parent
        }
        
        func onCameraPositionChanged(
            with map: YMKMap,
            cameraPosition: YMKCameraPosition,
            cameraUpdateReason: YMKCameraUpdateReason,
            finished: Bool
        ) {
            guard finished else { return }

            let now = Date()
            guard now.timeIntervalSince(lastUpdateTime) > updateInterval else { return }

            if let lastPos = lastPosition {
                let distance = calculateDistance(from: lastPos, to: cameraPosition.target)
                guard distance > minDistance else { return }
            }

            lastUpdateTime = now
            lastPosition = cameraPosition.target
            parent.cameraPosition = cameraPosition // Синхронизируем cameraPosition
            
            print("📍 Обновление: \(cameraPosition.target.latitude), \(cameraPosition.target.longitude)")
            parent.locationManager.fetchAddress(from: cameraPosition.target) { [weak self] success in
                guard let self = self else { return }
                if success {
                    print("✅ Адрес обновлён: \(self.parent.locationManager.street), \(self.parent.locationManager.house)")
                }
            }
        }
        
        private func calculateDistance(from p1: YMKPoint, to p2: YMKPoint) -> Double {
            let latDiff = p1.latitude - p2.latitude
            let lonDiff = p1.longitude - p2.longitude
            return sqrt(latDiff * latDiff + lonDiff * lonDiff) * 111000
        }
    }
}
