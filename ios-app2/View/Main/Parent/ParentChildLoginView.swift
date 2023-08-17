//
//  AlertView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-24.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
import SDWebImageSwiftUI

struct ParentChildLoginView: View {
    
    @State var showError: Bool = false
    @State var errorMsg: String = ""
    
    @State var fetchedUsers: [ChildUser] = []
    @State var DoneSearchingUsers: Bool = false
    
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    @State var loginCode: Int?
    
    @State var UsernameForCodeRemoval: String = ""
    
    @State var showAlert: Bool = false
    
    @State var isLoading: Bool = false
    
    var body: some View {
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
                            Section("Child Accounts") {
                                ForEach(0..<fetchedUsers.count) { i in
                                    NavigationLink {
                                        ScrollView {
                                            VStack {
                                                HStack {
                                                    WebImage(url: fetchedUsers[i].userProfileURL).placeholder {
                                                        ProgressView()
                                                    }
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 50, height: 50)
                                                    .clipShape(Circle())
                                                    
                                                    Text(fetchedUsers[i].username)
                                                        .font(.title)
                                                        .fontWeight(.heavy)
                                                    
                                                }
                                                
                                                Text("Login Code")
                                                    .font(.title2)
                                                    .padding(.top, 25)
                                                
                                                Button {
                                                    loginCode = Int(random(digits: 6)) ?? 0
                                                    UsernameForCodeRemoval = fetchedUsers[i].username
                                                    WriteCodeToFirebase(loginCode ?? 0, username: fetchedUsers[i].username)
                                                    showAlert.toggle()
                                                } label: {
                                                    HStack {
                                                        
                                                        Text("Generate")
                                                            .foregroundStyle(.black)
                                                        
                                                        Image(systemName: "lock")
                                                            .foregroundStyle(.orange)
                                                    }
                                                    .border(1, .black)
                                                    .padding(.all, 5)
                                                }
                                            }
                                            
                                        }
                                    } label: {
                                        
                                        HStack {
                                            
                                            WebImage(url: fetchedUsers[i].userProfileURL).placeholder {
                                                ProgressView()
                                            }
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            
                                            VStack {
                                                
                                                Text(fetchedUsers[i].username)
                                                
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.automatic)
                    }
                    .navigationTitle("Login Child Users")
                }
            }
        }
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .task {
            await searchChildUsers()
        }
        .alert("\(String(loginCode ?? 0))", isPresented: $showAlert) {
            Button("Done", role: .none, action: {
                deleteCode(UsernameForCodeRemoval)
            })
        } message: {
            Text("When this alert is dismised, this code will expire")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .none, action: {})
        } message: {
            Text(errorMsg)
        }

    }
    
    func deleteCode(_ username: String) {
        Task {
            do {
                try await Firestore.firestore().collection("LoginCodes").document(username).delete()
            } catch {
                isLoading = false
                await setError(error)
            }
        }
    }
    
    func random(digits: Int) -> String {
        var number = String()
        for _ in 1...digits {
           number += "\(Int.random(in: 1...9))"
        }
        return number
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
    
    func WriteCodeToFirebase(_ VerifyCode: Int, username: String) {
        Task {
            do {
                
                let code = LoginCode(code: VerifyCode)
                
                let _ = try Firestore.firestore().collection("LoginCodes").document(username).setData(from: code, completion: {
                    error in
                    if error == nil {
                        /// sheesh
                        isLoading = false
                    }
                })
            } catch {
                isLoading = false
                await setError(error)
            }
        }
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
        }
    }
}

#Preview {
    ParentChildLoginView()
}
