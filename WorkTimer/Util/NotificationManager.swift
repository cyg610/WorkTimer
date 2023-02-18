//
//  NotificationManager.swift
//  WorkTimer
//
//  Created by taeyoung on 2023/02/16.
//

import Foundation
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    let userNotiCenter = UNUserNotificationCenter.current()
    
    // 사용자에게 알림 권한 요청
       func requestAuthNoti() {
           let notiAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
           userNotiCenter.requestAuthorization(options: notiAuthOptions) { (success, error) in
               if let error = error {
                   print(#function, error)
               }
           }
       }
    
    // 알림 전송
    func requestSendNoti(timer : String?) {
        if let stringDateTime = timer {
            let notiContent = UNMutableNotificationContent()
            notiContent.title = "WORK TIEMR"
            notiContent.body = "출근시간 : " + stringDateTime
            notiContent.userInfo = ["targetScene": "splash"] // 푸시 받을때 오는 데이터
            
            // 알림이 trigger되는 시간 설정
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: notiContent,
                trigger: trigger
            )
            
            userNotiCenter.add(request) { (error) in
                print(#function, error)
            }
        }

    }

}
