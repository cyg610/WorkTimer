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
        let current_date_string = formatter.string(from: date)
        return current_date_string
    }
    
    func getTimeToString(_ date : Date) -> String {
        formatter.dateFormat = "HH:mm:ss"
        let time = formatter.string(from: date)
        return time
    }
    
    func comparedDateToReset() {
        formatter.dateFormat = "MMdd"
        let beforeDayString = UserDefaultsManager.workStartTime
        let before_day_array = beforeDayString?.components(separatedBy: [" ", "-"])
        let before_day = ""
        let current_day = formatter.string(from: Date())
        
        if before_day != current_day {
            UserDefaultsManager.workStartTime = ""
        }
        
    }
    
}
