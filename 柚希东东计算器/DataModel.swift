//
//  DataModel.swift
//  柚希动动计数器
//
//  Created by 王哲夫 on 2023/1/14.
//

import Foundation

class DataModel: Codable {
    var id: UUID? = UUID()
    var dateStart: Date = Date()
    var count: Int = 0
    var tap: Int { rawRecords.count }
    var rawRecords: [TimeInterval] = []
    func addRecord() {
        rawRecords += Date().timeIntervalSince1970
    }
    func increaseCount() {
        count += 1
    }
    func save() {
        var data = GlobalSettings.data
        var collection: [DataModel] = data[dateStart.toYYYYMMDD] ?? []
        collection += self
        data[dateStart.toYYYYMMDD] = collection
        GlobalSettings.data = data
    }
    func delete() {
        var gdata: [String:[DataModel]] = GlobalSettings.data
        var allData: [DataModel]? = gdata[dateStart.toYYYYMMDD]
        guard (allData?.count ?? 0) > 0 else {
            return
        }
        allData?.removeAll { obj in
            if let idToBeDelete = id {
                return obj.id == idToBeDelete
            }
            // compatible for old data
            return obj.dateStart == dateStart
        }
        if (allData?.count ?? 0) == 0 {
            allData = nil
        }
        gdata[dateStart.toYYYYMMDD] = allData
        GlobalSettings.data = gdata
    }
}

@propertyWrapper
    struct UserDefault<T: Codable> {
        let key: String
        let defaultValue: T
        init(_ key: String, defaultValue: T) {
            self.key = key
            self.defaultValue = defaultValue
        }
        var wrappedValue: T {
            get {
                if let data = UserDefaults.standard.object(forKey: key) as? Data,
                    let user = try? JSONDecoder().decode(T.self, from: data) {
                    return user
                }
                return defaultValue
            }
            set {
                if let encoded = try? JSONEncoder().encode(newValue) {
                    UserDefaults.standard.set(encoded, forKey: key)
                }
            }
        }
    }


enum GlobalSettings {
    @UserDefault("com.my.datas_new", defaultValue:[:]) static var data: [String:[DataModel]]
    @UserDefault("com.my.datas", defaultValue:[]) static var oldData: [DataModel]
}
