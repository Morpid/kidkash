//
//  BankView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-28.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift
import FirebaseFirestore
import SDWebImageSwiftUI

struct BankView: View {
    
    @State var BankName: String
    
    @State var user: ChildUser?
    
    @State var bankArray: Int
    
    @State var childUsername: String
    
    @State var BankInfo: Bank?
    
    @State var foundBank: Bool = false
    
    @State var DoneLoadingBanks: Bool = false
    
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    var body: some View {
        VStack {
            if DoneLoadingBanks {
                BankDetailsChild(bank: BankInfo!, bankArray: bankArray, usernameChild: childUsername)
            } else{
                ProgressView()
            }
        }
        .task {
            await FetchUser()
        }
    }
    
    func FetchUser() async {
        Task {
                    
            let user = try await Firestore.firestore().collection("ChildUsers").document(usernameStored).getDocument(as: ChildUser.self)
                
            await MainActor.run { 
                self.user = user
            }
            
            await FetchBankInfo()
            
            DoneLoadingBanks = true
        }
    }
    
    func FetchBankInfo() async {
        for i in 0...(self.user!.banks.count - 1) {
            if self.user!.banks[i].name == BankName {
                BankInfo = user!.banks[i]
            }
        }
    }
    
}

#Preview {
    MainView()
}
