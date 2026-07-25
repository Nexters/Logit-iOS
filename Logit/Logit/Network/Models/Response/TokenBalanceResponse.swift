//
//  TokenBalanceResponse.swift
//  Logit
//

import Foundation

struct TokenBalanceResponse: Decodable {
    let balance: Int
    let plan: String
    let monthlyTokens: Int
    let monthlyGrantReceived: Bool
    let monthlyGrantAmount: Int
    let signupBonusReceived: Bool
    let signupBonusAmount: Int
    let attendanceReceived: Bool
    let attendanceAmount: Int
    let referralRewardReceived: Bool
    let referralRewardAmount: Int
    let referralRewardCount: Int

    enum CodingKeys: String, CodingKey {
        case balance
        case plan
        case monthlyTokens = "monthly_tokens"
        case monthlyGrantReceived = "monthly_grant_received"
        case monthlyGrantAmount = "monthly_grant_amount"
        case signupBonusReceived = "signup_bonus_received"
        case signupBonusAmount = "signup_bonus_amount"
        case attendanceReceived = "attendance_received"
        case attendanceAmount = "attendance_amount"
        case referralRewardReceived = "referral_reward_received"
        case referralRewardAmount = "referral_reward_amount"
        case referralRewardCount = "referral_reward_count"
    }
}
