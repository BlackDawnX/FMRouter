//
//  FMRouterUtilities.swift
//  FMRoute
//
//  Created by Aaron on 2018/7/10.
//  Copyright © 2018 Fitmao. All rights reserved.
//

import UIKit

extension Dictionary where Key == String {
    var allKeys: [String] {
        var keys: [String] = []
        
        for key in self.keys {
            keys.append(key)
        }
        
        return keys
    }
}

extension Dictionary where Value == Any {
    var allValues: [Any] {
        var values: [Any] = []
        
        for value in self.values {
            values.append(value)
        }
        
        return values
    }
}
