//
//  ParentMain.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-21.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import SDWebImageSwiftUI
import PhotosUI

struct ParentMain: View {
    @State var showMenu: Bool = false
    
    @State var myProfile: User?
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    @State var DoneSearchingUsers: Bool = false
    
    @State var showError: Bool = false
    @State var errorMsg: String = ""
    
    @State var fetchedUsers: [ChildUser] = []
    
    @State var isLoading: Bool = false
    
    @State var showLogoutVerification: Bool = false
    
    @AppStorage("parent_log_status") var parentLogStatus: Bool = false
    
    @State var selectedTab = "Home"
    
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        
        NavigationStack {
            
            VStack(alignment: .center) {
                
                VStack {
                    if !DoneSearchingUsers {
                        ProgressView()
                    } else {
                        if fetchedUsers.isEmpty {
                            Text("Child accounts with show up here")
                                .padding()
                                .font(.callout)
                                .opacity(0.7)
                        } else {
                            NavigationStack {
                                List {
                                    Section() {
                                        ForEach(0..<fetchedUsers.count) { i in
                                            
                                            NavigationLink {
                                                ParentMainList(fetchedUsers: fetchedUsers, ArrayNumber: i)
                                            } label: {
                                                SimpleUserView(profileImg: fetchedUsers[i].userProfileURL, username: fetchedUsers[i].username)
                                            }
                                            
                                        }
                                    }
                                }
                                .listStyle(.automatic)
                            }
                            .navigationTitle("Home")
                            .onAppear {
                                if !fetchedUsers.isEmpty {
                                    Task {
                                        await updateChildUsers()
                                    }
                                }
                            }
                            .refreshable {
                                if !fetchedUsers.isEmpty {
                                    Task {
                                        await updateChildUsers()
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    
                    Button {
                        showLogoutVerification.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "iphone.and.arrow.forward")
                                .foregroundStyle(.black)
                                .font(.title2)
                            
                            Text("Sign Out")
                                .foregroundStyle(.black)
                                
                        }
                        .padding()
                        .background(.orange.opacity(0.6))
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    NavigationLink {
                        NewChildAccountView()
                    } label: {
                        HStack {
                            
                            Text("New User")
                                .foregroundStyle(.black)
                            
                            Image(systemName: "plus")
                                .foregroundStyle(.black)
                                .font(.title2)
                            
                            
                        }
                        .padding()
                        .background(.blue.opacity(0.6))
                        .clipShape(Capsule())
                    }

                    
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ParentChildLoginView()
                    } label: {
                        Image(systemName: "lock")
                            
                    }
                    .tint(.black)

                }
            }
            
        }
        .overlay {
            LoadingView(show: $isLoading)
        }
        .alert(isPresented: $showLogoutVerification) {
            Alert(
                title: Text("Log Out?"),
                primaryButton: .destructive(Text("Log Out")) {
                    logOutParent()
                },
                secondaryButton: .cancel()
            )
        }
        .task {
            await searchChildUsers()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .none, action: {})
        } message: {
            Text(errorMsg)
        }
        .preferredColorScheme(.light)
        
        
        
            
        
    }
    
    func updateChildUsers() async {
        do {
            for i in 0...(fetchedUsers.count - 1) {
                let documents = try await Firestore.firestore().collection("ChildUsers").whereField("username", isGreaterThanOrEqualTo: fetchedUsers[i].username).whereField("username", isLessThanOrEqualTo: fetchedUsers[i].username).getDocuments()
                
                let users = try documents.documents.compactMap { doc -> ChildUser? in
                    try doc.data(as: ChildUser.self)
                }
                
                if !(users.count > 1) {
                    if !(users.count < 1) {
                        let _ = try await Firestore.firestore().collection("ChildUsers").document(users[0].username).updateData(["lastUpdated": Date.now])
                    }
                }
            }
        } catch {}
    }
    
    func searchChildUsers() async {
        do {
            
            let documents = try await Firestore.firestore().collection("ChildUsers").whereField("parentUID", isGreaterThanOrEqualTo: String(Auth.auth().currentUser?.uid ?? "")).whereField("parentUID", isLessThanOrEqualTo: String(Auth.auth().currentUser?.uid ?? "")).getDocuments()
            
           
            
            let users = try documents.documents.compactMap { doc -> ChildUser? in
                try doc.data(as: ChildUser.self)
            }
            
            await MainActor.run(body: {
                fetchedUsers = users
                DoneSearchingUsers = true
            })
            
        } catch {
            print(error.localizedDescription)
            print("Sad........")
        }
    }
    
    func setError(_ error: Error) async {
        await MainActor.run(body: {
            isLoading = false
            errorMsg = error.localizedDescription
            showError.toggle()
        })
    }
    
    func setStringError(_ error: String) async {
        await MainActor.run(body: {
            isLoading = false
            errorMsg = error
            showError.toggle()
        })
    }
    
    func logOutParent() {
        isLoading = true
        Task {
            do {
                try Auth.auth().signOut()
                parentLogStatus = false
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }

    
    
    
}

#Preview {
    ParentMain()
}
