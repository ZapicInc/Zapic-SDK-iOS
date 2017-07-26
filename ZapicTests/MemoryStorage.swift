//
//  MemoryStorage.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/25/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

@testable import Zapic

class MemoryStorage : StorageProtocol{
    
    var values = [String: Any?]()
    
    func string(forKey key: String) -> String? {
        return values[key] as? String
    }
    
    func setValue(_ value: Any?, forKey key: String) {
        values[key] = value
    }
    
    func removeObject(forKey key: String) {
        values.removeValue(forKey: key)
    }
    
    public var count: Int {
        get{
            return values.count
        }
    }
}
