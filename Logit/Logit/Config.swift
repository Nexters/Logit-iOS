//
//  Config.swift
//  Logit
//
//  Created by 임재현 on 2/5/26.
//

import Foundation

enum Config {
    // Info.plist에서 값 읽기
    private static func value(forKey key: String) -> String? {
        return Bundle.main.object(forInfoDictionaryKey: key) as? String
    }
    
    static var baseURL: String {
        return value(forKey: "BASE_URL") ?? "https://api.example.com"
    }
    
    static var testAccessToken: String? {
        let token = value(forKey: "TEST_ACCESS_TOKEN")
        return token?.isEmpty == false ? token : nil
    }
    
}
