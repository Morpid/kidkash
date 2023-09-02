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
    
    @State var NewChildUserSheet: Bool = false
    
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
            
            ZStack(alignment: .center) {
                
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
                                
                                ScrollView {
                                    
                                    VStack(alignment: .leading) {
                                        
                                        ForEach(0..<fetchedUsers.count) { i in
                                            
                                            NavigationLink {
                                                ParentMainList(fetchedUsers: fetchedUsers, ArrayNumber: i)
                                            } label: {
                                                ZStack {
                                                    
                                                    Capsule()
                                                        .foregroundStyle(.ultraThinMaterial)
                                                        .frame(maxWidth: .infinity)
                                                    
                                                    HStack {
                                                        
                                                        SimpleUserView(profileImg: fetchedUsers[i].userProfileURL, username: fetchedUsers[i].username)
                                                            .padding()
                                                        
                                                        Spacer()
                                                        
                                                        Image(systemName: "chevron.right")
                                                            .foregroundStyle(.black)
                                                            .padding()
                                                            .padding(.trailing)
                                                        
                                                    }
                                                    
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                        Spacer()
                                            .frame(height: 75)
                                        
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                }
                                .padding()
                                
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
                
                    
                HStack {
                    
                    
                    
                    Spacer()
                    
                    Button {
                        NewChildUserSheet.toggle()
                    } label: {
                        HStack {
                            
                            Image(systemName: "plus")
                                .foregroundStyle(.black)
                                .font(.title2)
                            
                            
                        }
                        .padding()
                        .background(.green)
                        .clipShape(Circle())
                    }
                    .padding()
                    
                    
                }
                .padding()
                .vAlign(.bottom)
                    
                
            }
            .ignoresSafeArea(edges: [.bottom])
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ParentChildLoginView()
                    } label: {
                        Image(systemName: "lock")
                            
                    }
                    .tint(.black)

                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showLogoutVerification.toggle()
                    } label: {
                        Image(systemName: "iphone.and.arrow.forward")
                            .foregroundStyle(.red)
                            
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
        .sheet(isPresented: $NewChildUserSheet, content: {
            NewChildAccountView()
                .presentationDetents([.medium])
                .presentationBackground(.ultraThinMaterial)
                .presentationCornerRadius(50)
        })
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
