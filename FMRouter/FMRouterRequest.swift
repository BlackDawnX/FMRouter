//
//  FMRouterRequest.swift
//  FMRoute
//
//  Created by Aaron on 2018/7/10.
//  Copyright © 2018 Fitmao. All rights reserved.
//

import UIKit

class FMRouterRequest {
    
    private(set) var isMatched: Bool = false
    private let url: URL
    private let pattern: String
    
    public var matchedPatterns: [String: Any] = [:]
    
    public init(url: URL, pattern: String) {
        self.url = url
        self.pattern = pattern
        self.match()
    }
    
    private func match() {
        var components = url.pathComponents
        
        components[0] = url.host ?? ""
        
        let pattern2 = pattern.split(separator: "/")
        var arr1: [String] = []
        var dict: [String: Any] = [:]
        var index: Int = 0
        
        for str in pattern2 {
            if !str.hasPrefix(":") {
                index += 1
                arr1.append(String(str))
            }
        }
        
        if components.count >= index {
            var matched = true
            for i in 0..<index {
                if components[i] != arr1[i] {
                    matched = false
                    break
                }
            }
            
            if matched {
                let patternSubIndex = pattern2.count - index
                let componentsSubIndex = components.count - index
                
                if patternSubIndex == componentsSubIndex {
                    for i in index..<pattern2.count {
                        let pat = String(pattern2[i])
                        let key = String(pat.dropFirst())
                        dict[key] = components[i]
                    }
                    
                    self.isMatched = true
                    matchedPatterns = dict
                }
            }
        }
    }
}
