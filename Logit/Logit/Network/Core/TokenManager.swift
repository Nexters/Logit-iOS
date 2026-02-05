//
//  TokenManager.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

class TokenManager {
    static let shared = TokenManager()
    private let keychain = KeychainManager.shared
    
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    // 메모리 캐시 (매번 Keychain 접근 방지)
    private var _accessToken: String? = Config.testAccessToken
    private var _refreshToken: String?
    
    var accessToken: String? {
        if let token = _accessToken {
            return token
        }
        _accessToken = try? keychain.get(key: accessTokenKey)
        return _accessToken
    }
    
    var refreshToken: String? {
        if let token = _refreshToken {
            return token
        }
        _refreshToken = try? keychain.get(key: refreshTokenKey)
        return _refreshToken
    }
    
    func saveTokens(access: String, refresh: String) {
        do {
            try keychain.save(key: accessTokenKey, value: access)
            try keychain.save(key: refreshTokenKey, value: refresh)
            _accessToken = access
            _refreshToken = refresh
            NetworkLogger.logTokenStatus(accessToken: access, refreshToken: refresh)
        } catch {
            print("Keychain save error: \(error)")
        }
    }
    
    func updateAccessToken(_ token: String) {
        do {
            try keychain.save(key: accessTokenKey, value: token)
            _accessToken = token
            
            NetworkLogger.logTokenStatus(accessToken: token, refreshToken: _refreshToken)
        } catch {
            print("Keychain update error: \(error)")
        }
    }
    
    func clearTokens() {
        do {
            try keychain.delete(key: accessTokenKey)
            try keychain.delete(key: refreshTokenKey)
            _accessToken = nil
            _refreshToken = nil
            NetworkLogger.logTokenStatus(accessToken: nil, refreshToken: nil)
        } catch {
            print("Keychain delete error: \(error)")
        }
    }
    
    var isLoggedIn: Bool {
        return accessToken != nil
    }
}
