//
//  LoginCode.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-25.
//

import SwiftUI
import FirebaseFirestoreSwift

struct LoginCode: Identifiable, Codable {
    @DocumentID var id: String?
    var code: Int
    
    enum CodingKeys: CodingKey {
        case id
        case code
    }
}
