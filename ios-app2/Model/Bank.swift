//
//  Bank.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-20.
//

import SwiftUI
import FirebaseFirestoreSwift

struct Bank: Identifiable, Codable {

    @DocumentID var id: String?
    var name: String
    var amount: Double
    var transactionHistoryName: [String]
    var transactionHistoryAmount: [Double]
    var transactionHistoryDate: [Date]
    var amountHistoryAmount: [Double]
    var amountHistoryDate: [Date]
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case amount
        case transactionHistoryName
        case transactionHistoryAmount
        case transactionHistoryDate
        case amountHistoryAmount
        case amountHistoryDate
    }
    
}

