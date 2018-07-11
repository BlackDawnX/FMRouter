//
//  DataManager.swift
//  FTNotebook
//
//  Created by Fitmao on 2018/5/2.
//  Copyright © 2018年 Fitmao. All rights reserved.
//

import UIKit

/// 要让 Swift 类属性获得 Runtime 的动态性，要在声明的时候指定动态类型
/// 例如：@objc dynamic var property: String
extension NSObject {
    func getPropertyList() -> [String] {
        var count: UInt32 = 0
        var listArr: [String] = []
        let list_t = class_copyPropertyList(object_getClass(self), &count)
        
        if let list = list_t {
            for i in 0..<count {
                let p = property_getName(list[Int(i)])
                if let name = String(utf8String: p) {
                    listArr.append(name)
                }
            }
        }
        
        return listArr
    }
    
    func getPropertyDict() -> NSDictionary {
        var dict: [String: Any?] = [:]
        let pList = self.getPropertyList()
        for p in pList {
            dict[p] = getPropertyValue(p)
        }
        
        return dict as NSDictionary
    }
    
    func getPropertyValue(_ name: String) -> Any? {
        return self.value(forKey: name)
    }
}

/// 遵循该协议的类会自动获得模型转 JSON 以及 JSON 转模型的功能
///
/// 请保证模型类中需要参与模型字典转换的属性为动态属性，否则运行时系统无法检测到属性的存在
///  - 使用 `saveDataWithJSON()` 方法来完成模型转 JSON
///  - 使用 `setValues(keys:values:)` 方法来完成 JSON 转模型
protocol ModelManager {
    func saveDataWithJSON() -> String
    func setValues(keys: [String], values: [Any])
//    static func convertModel(filePath: String) -> Self
}

extension ModelManager where Self: NSObject {
    func saveDataWithJSON() -> String {
        let pDict = self.getPropertyDict()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: pDict, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8) ??
            "你没有得到任何 JSON 数据，可能导致此情况的原因有：\n\t1)JSON 序列化出现错误\n\t2)Model 类没有动态属性或非可选属性"
        } catch {
            print("Error occured. ", error)
            return "你没有得到任何 JSON 数据，可能导致此情况的原因有：\n\t1)JSON 序列化出现错误\n\t2)Model 类没有动态属性或非可选属性"
        }
    }
    
    func setValues(keys: [String], values: [Any]) {
        let allProperties = self.getPropertyList()
        for i in 0..<keys.count {
            if allProperties.contains(keys[i]) {
                self.setValue(values[i], forKey: keys[i])
//                if values[i] is NSNull {
//                    self.setValue("", forKey: keys[i])
//                } else {
//                    self.setValue(values[i], forKey: keys[i])
//                }
            }
        }
    }
}








