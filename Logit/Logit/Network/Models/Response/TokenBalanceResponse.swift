//
//  TokenBalanceResponse.swift
//  Logit
//

import Foundation

struct TokenBalanceResponse: Decodable {
    let balance: Int
    let plan: String
    let monthlyTokens: Int
    let monthlyUsed: Int
    let monthlyGrantAmount: Int
    let signupBonusAmount: Int
    let attendanceAmount: Int
    let referralRewardAmount: Int
    let referralRewardCount: Int

    enum CodingKeys: String, CodingKey {
        case balance
        case plan
        case monthlyTokens = "monthly_tokens"
        case monthlyUsed = "monthly_used"
        case monthlyGrantAmount = "monthly_grant_amount"
        case signupBonusAmount = "signup_bonus_amount"
        case attendanceAmount = "attendance_amount"
        case referralRewardAmount = "referral_reward_amount"
        case referralRewardCount = "referral_reward_count"
    }
}
