////
////  BankView.swift
////  ios-app2
////
////  Created by Luka Baylis on 2023-07-28.
////
//
//import SwiftUI
//import Firebase
//import FirebaseStorage
//import FirebaseFirestoreSwift
//import FirebaseFirestore
//import SDWebImageSwiftUI
//
//struct BankView: View {
//    
//    @Binding var selectedBank: String
//    
//    @AppStorage("user_profile_url") var profileURL: URL?
//    @AppStorage("user_name") var usernameStored: String = ""
//    @AppStorage("user_UID") var userUID: String = ""
//    
//    var body: some View {
//        VStack {
//            
//            if DoneLoadingBanks {
//                BankDetailsChild(selectedBank: $selectedBank)
//            } else {
//                ProgressView()
//                Text("1")
//                Text("\(selectedBank)")
//            }
//        
//        }
//    }
//    
//}
//
//#Preview {
//    MainView()
//}
