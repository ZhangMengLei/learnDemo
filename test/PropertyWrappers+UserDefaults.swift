//
//  PropertyWrappers + UserDefaults.swift
//  test_Example
//
//  Created by 张梦磊 on 2022/1/25.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let dafaultValue: T
    
    init(key: String, dafaultValue: T) {
        self.key = key
        self.dafaultValue = dafaultValue
    }
    
    var wrappedValue: T {
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
        
        get {
            return UserDefaults.standard.value(forKey: key) as? T ?? dafaultValue
        }
    }
}

struct UserDefaultConfig {
    
    @UserDefault(key: "userID", dafaultValue:"")
    static var userID: String
    
    @UserDefault(key: "age", dafaultValue:0)
    static var age: Int
    
    @UserDefault<Bool>(key: "isAgree", dafaultValue:false)
    static var isAgree: Bool
}


//UserDefaultConfig.userID = ""
//print(UserDefaultConfig.userID)

