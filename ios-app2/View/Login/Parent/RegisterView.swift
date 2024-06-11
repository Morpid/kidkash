//
//  RegisterView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-12.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Firebase
import PhotosUI

struct RegisterView: View {
    
    @StateObject private var keyboardHandler = KeyboardHandler()
    
    @State var emailID: String = ""
    @State var password: String = ""
    
    @State var userProfileImageData: Data?
    
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    
    @State var showError: Bool = false
    @State var errorMsg: String = ""
    
    @State var isLoading: Bool = false
    
    @State var fetchedUsers: [User] = []
    
    @State var show_button: Bool = false
    
    
    @AppStorage("parent_log_status") var parentLogStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""

    @State var keyboardHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            HStack {
                    
                Image(systemName: "at")
                    .foregroundStyle(.black)
                    .font(.title3)
                    
                VStack {
                    
                    TextField("Email", text: $emailID)
                        .padding(.top, 10)
                        .padding(.leading, 10)
                        .keyboardType(.emailAddress)
                        .onChange(of: emailID) { oldValue, newValue in
                            if !newValue.isEmpty {
                                if !password.isEmpty {
                                    withAnimation {
                                        show_button = true
                                    }
                                } else {
                                    withAnimation {
                                        show_button = false
                                    }
                                }
                            } else {
                                withAnimation {
                                    show_button = false
                                }
                            }
                        }
                        .onChange(of: password) { oldValue, newValue in
                            if !newValue.isEmpty {
                                if !emailID.isEmpty {
                                    withAnimation {
                                        show_button = true
                                    }
                                } else {
                                    withAnimation {
                                        show_button = false
                                    }
                                }
                            } else {
                                withAnimation {
                                    show_button = false
                                }
                            }
                        }
                 
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.black)
                }
                
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 15)
            
            
            
            HStack {
                    
                Image(systemName: "lock")
                    .foregroundStyle(.black)
                    .font(.title3)
                
                
                VStack {
                    
                    SecureField("Password", text: $password)
                        .padding(.top, 10)
                        .padding(.leading, 10)
                 
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.black)
                }
                
                
                
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 15)
                
            if show_button {
                
                Button {
                    closeKeyboard()
                    registerUser()
                } label: {
                    if isLoading {
                        ProgressView()
                    } else {
                        
                        HStack {
                            Text("Next")
                                .foregroundStyle(.black)
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.black)
                        }
                        
                    }
                }
                
            }
            
            
        }
        //.preferredColorScheme(.light)
        .onChange(of: keyboardHandler.keyboardHeight, { oldValue, newValue in
            withAnimation(.spring(duration: 0.2)) {
                keyboardHeight = newValue
            }
        })
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem, matching: .images)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .none, action: {})
        } message: {
            Text(errorMsg)
        }
        .onChange(of: photoItem) { oldValue, newValue in
            if let newValue {
                Task {
                    do {
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else {return}
                        
                        await MainActor.run(body: {
                            userProfileImageData = imageData
                        })
                    } catch {
                        
                    }
                }
            }
        }

        
        
        
    }
    
    
    func registerUser() {
        isLoading = true
        closeKeyboard()
        Task {
            do {
                
//                if !self.fetchedUsers.isEmpty {
//                    for i in 0...(self.fetchedUsers.count - 1) {
//                        if self.username == fetchedUsers[i].username {
//                            await setStringError("Username already taken")
//                            return
//                        }
//                    }
//                }
                
                try await Auth.auth().createUser(withEmail: emailID, password: password)
                
                guard let userUID = Auth.auth().currentUser?.uid else { return }
                
                let user = User(userEmail: emailID, userUID: userUID)
                
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user, completion: {
                    error in
                    if error == nil {
                        self.userUID = userUID
                        parentLogStatus = true
                        
                    }
                })
                
                
            } catch {
                try await Auth.auth().currentUser?.delete()
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
    
    func setStringError(_ error: String) async {
        await MainActor.run(body: {
            isLoading = false
            errorMsg = error
            showError.toggle()
        })
    }
    
    func fetchUser() async throws {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let user = try await Firestore.firestore().collection("ChildUsers").document(userID).getDocument(as: ChildUser.self)
        
        await MainActor.run(body: {
            userUID = userID
            profileURL = user.userProfileURL
            parentLogStatus = true
        })
    }
}

#Preview {
    RegisterView()
} 
