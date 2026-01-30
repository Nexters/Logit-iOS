//
//  NetworkClient.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

protocol NetworkClient {
    func request<T:Decodable>(
        endpoint: APIEndpoint,
        body: Encodable?
    ) async throws -> T
    
    // 응답 body 없을때
    func request(
        endpoint: APIEndpoint,
        body: Encodable?
    ) async throws
}
