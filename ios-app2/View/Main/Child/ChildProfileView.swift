//
//  ChildProfileView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-25.
//

import SwiftUI

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ChildProfileView: View {
    
    @State var myProfile: ChildUser?
    @State var showLogoutVerification: Bool = false
    //@State var showDeleteVerification: Bool = false
    @AppStorage("log_status") var logStatus: Bool = false
    
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    @State var errorMsg: String = ""
    @State var showError: Bool = false
    
    @State var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ChildReuseableProfileContent(username: usernameStored, userProfileImageURL: profileURL)
                
            }
            .alert(isPresented: $showLogoutVerification) {
                Alert(
                    title: Text("Log Out?"),
                    primaryButton: .destructive(Text("Log Out")) {
                        logoutUser()
                    },
                    secondaryButton: .cancel()
                )
            }
            .navigationTitle("My Profile")
            
        }.overlay {
            LoadingView(show: $isLoading)
        }
        
    }
    
    
    func logoutUser() {
        logStatus = false
    }
    
//    func deleteAccount() {
//        isLoading = true
//        Task {
//            do {
//                guard let userUID = Auth.auth().currentUser?.uid else { return }
//                
//                let reference = Storage.storage().reference().child("Profile_Images").child(userUID)
//                try await reference.delete()
//                
//                try await Firestore.firestore().collection("Users").document(userUID).delete()
//                
//                try await Auth.auth().currentUser?.delete()
//                logStatus = false
//            } catch {
//                await setError(error)
//            }
//        }
//    }
    
    func setError(_ error: Error) async {
        await MainActor.run(body: {
            isLoading = false
            errorMsg = error.localizedDescription
            showError.toggle()
        })
    }
}



#Preview {
    ChildProfileView()
}
