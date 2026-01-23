//
//  String+.swift
//  Logit
//
//  Created by 임재현 on 1/23/26.
//

import Foundation

extension String {
    /// 빈 문자열 체크
    var isNotEmpty: Bool {
        !self.isEmpty
    }
    
    /// 공백 제거
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 이메일 검증
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    /// 전화번호 포맷 (010-1234-5678)
    var formattedPhoneNumber: String {
        let numbers = self.filter { $0.isNumber }
        guard numbers.count == 11 else { return self }
        
        let index1 = numbers.index(numbers.startIndex, offsetBy: 3)
        let index2 = numbers.index(numbers.startIndex, offsetBy: 7)
        
        return "\(numbers[..<index1])-\(numbers[index1..<index2])-\(numbers[index2...])"
    }
    
    /// 숫자만 추출
    var onlyNumbers: String {
        self.filter { $0.isNumber }
    }
}
