//
//  UserDefault.swift
//  WorkTimer
//
//  Created by taeyoung on 2023/02/16.
//

import Foundation

class UserDefaultsManager {
    
    @UserDefault(key: "workStartTime", defaultValue: "")
    static var workStartTime :  String?
    
    @UserDefault(key: "destinationLocation", defaultValue: "")
    static var destinationLocation :  String?
    
    
}


// MARK: - UserDefault Property Wrapper

@propertyWrapper
struct UserDefault<T> {
    private let ud = UserDefaults.standard
    private let key : String
    
    private var defaultValue : T
    
    var wrappedValue : T {
        get {
            return ud.value(forKey: key) as? T ?? defaultValue
        }
        set {
            ud.setValue(newValue, forKey: key)
        }
    }
    
    init(key : String, defaultValue : T){
        self.key = key
        self.defaultValue = defaultValue
    }
}


@propertyWrapper
struct UserDefaultCodable<T: Codable> {
    private let ud = UserDefaults.standard
    private let key : String
    
    private var defaultValue : T
    
    var wrappedValue : T {
        get {
            guard let data = UserDefaults.standard.data(forKey: key) else { return defaultValue }
            return (try? PropertyListDecoder().decode(T.self, from: data)) ?? defaultValue
        }
        set {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: key)
        }
    }
    
    init(key : String, defaultValue : T){
        self.key = key
        self.defaultValue = defaultValue
    }
}
