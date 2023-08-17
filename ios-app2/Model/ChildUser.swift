//
//  ChildUser.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-22.
//

import SwiftUI
import FirebaseFirestoreSwift

struct ChildUser: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var userProfileURL: URL
    var banks: [Bank]
    var parentUID: String
    var lastUpdated: Date
    var RecurringTransactions: [RecurringTransactionModel]
    
    enum CodingKeys: CodingKey {
        case id
        case username
        case userProfileURL
        case banks
        case parentUID
        case lastUpdated
        case RecurringTransactions
    }
}

struct RecurringTransactionModel: Identifiable, Codable {
    @DocumentID var id: String?
    var bankAccountName: String
    var amount: Double
    var days: DayModel
    var startDay: Date
    var name: String
    
    enum CodingKeys: CodingKey {
        case id
        case bankAccountName
        case amount
        case days
        case startDay
        case name
    }
}

struct DayModel: Identifiable, Codable {
    @DocumentID var id: String?
    var Sunday: Bool
    var Monday: Bool
    var Tuesday: Bool
    var Wednesday: Bool
    var Thursday: Bool
    var Friday: Bool
    var Saturday: Bool
    
    enum CodingKeys: CodingKey {
        case id
        case Sunday
        case Monday
        case Tuesday
        case Wednesday
        case Thursday
        case Friday
        case Saturday
    }
}

