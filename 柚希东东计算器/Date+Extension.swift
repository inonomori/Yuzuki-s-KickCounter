//
//  Date+Extension.swift
//  柚希动动计数器
//
//  Created by 王哲夫 on 2023/1/16.
//

import Foundation

fileprivate var formater: DateFormatter = {
    let formate = DateFormatter()
    formate.dateFormat = "yyyy/MM/dd"
    formate.timeZone = TimeZone.current
    return formate
}()

fileprivate var formater2: DateFormatter = {
    let formate = DateFormatter()
    formate.dateFormat = "MM/dd"
    formate.timeZone = TimeZone.current
    return formate
}()
fileprivate var formater3: DateFormatter = {
    let formate = DateFormatter()
    formate.dateFormat = "HH:mm"
    formate.timeZone = TimeZone.current
    return formate
}()


extension Date {
    var toYYYYMMDD: String {
        formater.string(from: self)
    }
    var toMMDD: String {
        formater2.string(from: self)
    }
    var toHHMM: String {
        formater3.string(from: self)
    }
}

extension DateComponents {
    static func dateComponentFor(hour: Int, min: Int) -> DateComponents {
        var retV: DateComponents = DateComponents()
        retV.hour = hour
        retV.minute = min
        return retV
    }
}
