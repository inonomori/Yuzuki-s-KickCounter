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

extension Date {
    var toYYYYMMDD: String {
        formater.string(from: self)
    }
}
