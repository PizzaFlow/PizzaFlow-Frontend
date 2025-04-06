//
//  AppDelegate.swift
//  PizzaFlow
//
//  Created by 596 on 02.03.2025.
//

import UIKit
import YandexMapsMobile

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        YMKMapKit.setApiKey("190bff8a-6b60-4e52-9a85-7987fec3414b")
        YMKMapKit.setLocale("ru_RU")
        YMKMapKit.sharedInstance()
        return true
    }
}
