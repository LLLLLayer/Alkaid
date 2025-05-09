//
//  UserDefault.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/1.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    
    let key: String
    
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
