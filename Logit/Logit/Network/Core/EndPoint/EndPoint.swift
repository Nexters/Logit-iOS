//
//  EndPoint.swift
//  Logit
//
//  Created by 임재현 on 1/30/26.
//

import Foundation

protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
}
