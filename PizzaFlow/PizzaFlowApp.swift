//
//  PizzaFlowApp.swift
//  PizzaFlow
//
//  Created by 596 on 01.03.2025.
//

import SwiftUI

@main
struct PizzaFlowApp: App {
    @StateObject var apiClient = ApiClient()
    @StateObject private var locationManager = LocationManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showSplash = true 
    @StateObject var cartManager = CartManager()

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView(showSplash: $showSplash)
            } else {
                ContentView()
                    .environmentObject(apiClient)
                    .environmentObject(cartManager)
                    .environmentObject(locationManager)
            }
        }
    }
}
