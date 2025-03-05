//
//  PizzaFlowApp.swift
//  PizzaFlow
//
//  Created by 596 on 01.03.2025.
//

import SwiftUI

@main
struct PizzaFlowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showSplash = true // Показываем сплэш при запуске

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView(showSplash: $showSplash) // Передаём `@Binding`
            } else {
                ContentView() // Загружаем `ContentView` после скрытия Splash
            }
        }
    }
}
