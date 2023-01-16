//
//  CollectionValue+Extension.swift
//  LivoCommon
//
//  Created by 王哲夫 on 2021/11/11.
//

import Foundation

public extension Array where Element: Equatable {
    
    /// 移动元素
    ///
    ///  如果数组中并不存在要移动的元素，则该方法不会做任何处理，例如
    ///
    ///      var s = [1, 2, 3, 3, 4]
    ///      s.move(object: 5, toIndex: 0) // [1, 2, 3, 3, 4]
    ///      s.move(object: 3, toIndex: 0) // [3, 1, 2, 3, 4]
    ///      s.move(object: 2, toIndex: 3) // [3, 1, 3, 2, 4]
    ///      s.move(object: 2, toIndex: 9) // [3, 1, 3, 4, 2]
    /// - Parameters:
    ///   - object: 移动的元素
    ///   - toIndex: 新 index，该参数做了安全处理，不会出现越界 crash
    mutating func move(object: Element, toIndex: Int) {
        move(where: { $0 == object }, toIndex: toIndex)
    }
    
    
    /// 插入或移动元素
    ///
    /// 与 move(object:toIndex:) 类似，但区别是如果 object 不存在原数组里，则插入进去
    ///
    ///     var s = [2,3]
    ///     s.update(object: 4, toIndex: 1) // [2, 4, 3]
    ///     s.update(object: 2, toIndex: 2) // [4, 3, 2]
    ///     s.update(object: 3, toIndex: 9) // [4, 2, 3]
    /// - Parameters:
    ///   - object: object
    ///   - toIndex: toIndex，该参数做了安全处理，不会出现越界 crash
    mutating func update(object: Element, toIndex: Int) {
        if firstIndex(of: object) == nil {
            safeInsert(object, toIndex: toIndex)
        } else {
            move(object: object, toIndex: toIndex)
        }
    }
}

public extension Array where Element: Hashable {
    
    /// 去重后的数组
    var unique: [Element] {
        var uniq: Set<Element> = Set<Element>()
        uniq.reserveCapacity(self.count)
        return self.filter {
            return uniq.insert($0).inserted
        }
    }
}


public extension Array {
    
    // 安全访问
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
    
    /// 移除第一个出现的元素
    /// - Parameter shouldBeRemoved: 是否需要移除的判断闭包
    /// - Returns: 是否移除，false 代表数组中不存在该元素
    @discardableResult mutating func removeFirst(where shouldBeRemoved: (Element) -> Bool) -> Bool {
        if let index: Int = firstIndex(where: shouldBeRemoved) {
            remove(at: index)
            return true
        }
        return false
    }
    
    /// 安全插入法
    ///
    ///     var s = [2,3]
    ///     s.safeInsert(4, toIndex: 1) // [2, 4, 3]
    ///     s.safeInsert(5, toIndex: -1) // [5, 2, 4, 3]
    ///     s.safeInsert(6, toIndex: 9) // [5, 2, 4, 3, 6]
    /// - Parameters:
    ///   - object: object
    ///   - toIndex: index, 会判断是否越界，如果越界，比如 -1，则插到头，大于等于 count 则插在尾部。负数并不会循环找尾部。
    mutating func safeInsert(_ object: Element, toIndex: Int) {
        let index: Int = Swift.max(0, toIndex)
        if count > toIndex {
            insert(object, at: index)
        } else {
            self += object
        }
    }
    
    /// 移动元素
    ///
    ///  如果数组中并不存在要移动的元素，则该方法不会做任何处理，例如
    ///
    ///      var s = [1,2,3,3,4]
    ///      s.move(where: { $0 == 5 }, toIndex: 0) // [1, 2, 3, 3, 4]
    ///      s.move(where: { $0 == 3 }, toIndex: 0) // [3, 1, 2, 3, 4]
    ///      s.move(where: { $0 == 2 }, toIndex: 3) // [3, 1, 3, 2, 4]
    ///      s.move(where: { $0 == 2 }, toIndex: 9) // [3, 1, 3, 4, 2]
    /// - Parameters:
    ///   - shouldBeMoved: 是否需要移动的判断闭包
    ///   - toIndex: 新 index，该参数做了安全处理，不会出现越界 crash
    mutating func move(where shouldBeMoved: (Element) -> Bool, toIndex: Int) {
        guard let objectIndex: Int = firstIndex(where: shouldBeMoved) else {
            return
        }
        let object: Element = remove(at: objectIndex)
        safeInsert(object, toIndex: toIndex)
    }
        
    /*
     一些有的没的 syntax suger
     Usage:
     
     var a: [Int] = [1,2]
     a += 3
     print(a) // [1,2,3]
     a += [4,5]
     print(a) // [1,2,3,4,5]
     let b: [Int] = a + 6
     print(b) // [1,2,3,4,5,6]
     let c: [Int] = a + [7,8]
     print(c) // [1,2,3,4,5,6,7,8]
     */
    static func +=(left: inout Array, right: Element?) {
        guard let right: Element = right else {
            return
        }
        left.append(right)
    }
    static func +=(left: inout Array, right: [Element]?) {
        guard let right: [Element] = right else {
            return
        }
        left.append(contentsOf: right)
    }
    static func +(left: Array, right: Element?) -> Array<Element> {
        guard let right: Element = right else {
            return left
        }
        var leftM: Array<Element> = left
        leftM += right
        return leftM
    }
    static func +(left: Array, right: [Element]?) -> Array<Element> {
        guard let right: [Element] = right else {
            return left
        }
        var leftM: Array<Element> = left
        leftM += right
        return leftM
    }
}

