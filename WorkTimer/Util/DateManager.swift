//
//  DateManager.swift
//  WorkTimer
//
//  Created by taeyoung on 2023/02/16.
//

import Foundation

class DateManager {
    
    static let shared = DateManager()
    var formatter = DateFormatter()
    
    func getDataToString(_ date : Date) -> String {
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var current_date_string = formatter.string(from: date)
        return current_date_string
    }
    
    func comparedDateToReset() {
        formatter.dateFormat = "MMdd"
        let beforeDayString = UserDefaultsManager.workStartTime
        var before_day_array = beforeDayString?.components(separatedBy: [" ", "-"])
        var before_day = ""
        if before_day_array?.count ?? 0 > 3 {
            var before_day = (before_day_array?[1] ?? "")+(before_day_array?[2] ?? "")
        }
        var current_day = formatter.string(from: Date())
        
        if before_day != current_day {
            UserDefaultsManager.workStartTime = ""
        }
        
    }
    
}
