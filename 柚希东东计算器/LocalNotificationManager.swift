//
//  LocalNotificationManager.swift
//  柚希胎动计数器
//
//  Created by 王哲夫 on 2023/1/16.
//

import Foundation
import UserNotifications

class LocalNotificationManager {
    static var shared: LocalNotificationManager = LocalNotificationManager()
    private var center: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }
    func notificationSettingChanged(completion:((Bool) -> Void)?) {
        center.removeAllPendingNotificationRequests()
        center.getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .authorized:
                self?.scheduleLocalNotification()
                completion?(true)
            case .notDetermined:
                self?.center.requestAuthorization(options: [.alert, .sound]) { [weak self] (granted, error) in
                    if granted {
                        self?.scheduleLocalNotification()
                        completion?(true)
                    } else {
                        completion?(false)
                    }
                }
            default:
                completion?(false)
            }
        }
    }
    func atLaunch() {
        center.getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .authorized:
                self?.scheduleLocalNotification()
            default: break
            }
        }
    }
    func scheduleLocalNotification() {
        center.removeAllPendingNotificationRequests()
        let message = "Time to measure your fetal movements!"
        let title = "Fetal Movements"
        let dates: [NotificationDataModel] = GlobalSettings.notificationDates
        for d in dates where d.isEnable {
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: message, arguments: nil)
            content.sound = UNNotificationSound.default
            let trigger = UNCalendarNotificationTrigger(dateMatching: d.date, repeats: true)
            let request = UNNotificationRequest(identifier: d.id.uuidString, content: content, trigger: trigger)
            center.add(request) { _ in }
        }
    }
}
