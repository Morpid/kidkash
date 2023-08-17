//
//  ProfileView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-20.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct ProfileView: View {
    
    @State var myProfile: User?
    @State var showLogoutVerification: Bool = false
    @State var showDeleteVerification: Bool = false
    
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("parent_log_status") var parentLogStatus: Bool = false
    
    @State var errorMsg: String = ""
    @State var showError: Bool = false
    
    @State var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let myProfile {
                    ReuseableProfileContent(user: myProfile)
                        .refreshable {
                            self.myProfile = nil
                            await fetchUserData()
                        }
                } else {
                    ProgressView()
                }
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Log Out") {
                            showLogoutVerification.toggle()
                        }
                        
                        Button("Delete Account", role: .destructive) {
                            showDeleteVerification.toggle()
                        }
                        
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .tint(.black)
                    }.alert(errorMsg, isPresented: $showError) {
                        
                    }.tint(.black)
                }
            }
        }.overlay {
            LoadingView(show: $isLoading)
        }.alert(isPresented: $showDeleteVerification) {
            Alert(
                title: Text("Are you sure you want to delete your account?"),
                message: Text("This action cannot be undone"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteAccount()
                },
                secondaryButton: .cancel()
            )
        }.task {
            if myProfile != nil { return }
            
            await fetchUserData()
        }
        
    }
    
    
    func fetchUserData() async {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        guard let user = try? await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self) else { return }
        
        await MainActor.run(body: {
            myProfile = user
        })
    }
    
    
    func logoutUser() {
        try? Auth.auth().signOut()
        logStatus = false
        parentLogStatus = false
    }
    
    func deleteAccount() {
        isLoading = true
        Task {
            do {
                guard let userUID = Auth.auth().currentUser?.uid else { return }
                
                let reference = Storage.storage().reference().child("Profile_Images").child(userUID)
                try await reference.delete()
                
                try await Firestore.firestore().collection("Users").document(userUID).delete()
                
                try await Auth.auth().currentUser?.delete()
                logStatus = false
            } catch {
                await setError(error)
            }
        }
    }
    
    func setError(_ error: Error) async {
        await MainActor.run(body: {
            isLoading = false
            errorMsg = error.localizedDescription
            showError.toggle()
        })
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

