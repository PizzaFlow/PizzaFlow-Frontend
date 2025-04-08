//
//  DeliveryTimePickerView.swift
//  PizzaFlow
//
//  Created by 596 on 07.04.2025.
//

import SwiftUI

struct DeliveryTimePickerView: View {
    let times: [DeliveryTime]
    @State private var selectedDay: DeliveryDay = .today
    @Binding var selectedTime: DeliveryTime?
    @Environment(\.dismiss) var dismiss

    private var availableTimes: [DeliveryTime] {
        generateTimeSlots(for: selectedDay)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("День доставки", selection: $selectedDay) {
                    ForEach(DeliveryDay.allCases, id: \.self) { day in
                        Text(day.rawValue).tag(day)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                List(availableTimes) { time in
                    Button(action: {
                        selectedTime = time
                        dismiss()
                    }) {
                        HStack {
                            Text(time.timeRange)
                                .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                            
                            if selectedTime?.id == time.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Выберите время")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
    private func generateTimeSlots(for day: DeliveryDay) -> [DeliveryTime] {
        let calendar = Calendar.current
        let now = Date()
        let startHour: Int
        let endHour = 23

        if day == .today {
            let currentHour = calendar.component(.hour, from: now)
            startHour = min(max(currentHour + 1, 10), 23)
        } else {
            startHour = 10
        }

        guard startHour <= endHour else {
            return []
        }
        
        var times = [DeliveryTime]()
        for hour in startHour...endHour {
            for minute in [0, 30] {
                if hour == endHour && minute == 30 {
                    continue
                }
                
                let timeString = String(format: "%02d:%02d", hour, minute)
                let nextHour = minute == 30 ? hour + 1 : hour
                let nextMinute = minute == 30 ? 0 : 30
                let nextTimeString = String(format: "%02d:%02d", nextHour, nextMinute)
                
                times.append(DeliveryTime(
                    timeRange: "\(timeString)-\(nextTimeString)",
                    day: day
                ))
            }
        }
        
        return times
    }
}
