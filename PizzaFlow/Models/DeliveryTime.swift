//
//  DeliveryTime.swift
//  PizzaFlow
//
//  Created by 596 on 07.04.2025.
//

import Foundation

struct DeliveryTimesResponse: Decodable {
    let deliveryTimes: [String]
    
    enum CodingKeys: String, CodingKey {
        case deliveryTimes = "delivery_times"
    }
}

struct DeliveryTime: Identifiable {
    let id: String
    let timeRange: String
    let day: DeliveryDay
    
    init(id: String, timeRange: String, day: DeliveryDay) {
        self.id = id
        self.timeRange = timeRange
        self.day = day
    }
    
    init(timeRange: String, day: DeliveryDay) {
        self.init(id: "\(day.rawValue)-\(timeRange)", timeRange: timeRange, day: day)
    }
}

enum DeliveryDay: String, CaseIterable {
    case today = "Сегодня"
    case tomorrow = "Завтра"
}
