//
//  StorageProtocol.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/25/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

protocol StorageProtocol {

    func string(forKey key: String) -> String?

    func setValue(_ value: Any?, forKey key: String)

    func removeObject(forKey key: String)
}

class UserDefaultsStorage: StorageProtocol {

    func setValue(_ value: Any?, forKey key: String) {
        UserDefaults.standard.setValue(value, forKey:key)
    }

    func string(forKey key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }

    func removeObject(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
