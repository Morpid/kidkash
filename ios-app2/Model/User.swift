//
//  User.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-14.
//

import SwiftUI
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var userEmail: String
    var userUID: String
    
    enum CodingKeys: CodingKey {
        case id
        case userUID
        case userEmail
    }
}
