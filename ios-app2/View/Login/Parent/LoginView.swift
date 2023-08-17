//
//  LoginView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-12.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct LoginView: View {
    
    @StateObject private var keyboardHandler = KeyboardHandler()
    
    @State var keyboardHeight: CGFloat = 0
    
    @State var emailID: String = ""
    @State var password: String = ""
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMsg: String = ""
    
    @State var showForgotPasswordAlert: Bool = false
    @State var showForgotPasswordSentAlert: Bool = false
    @State var forgotPasswordAlert: String = "Forgot Password?"
    
    @State var register: Bool = false
   
    @AppStorage("parent_log_status") var parent_parentLogStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    @State var isLoading: Bool = false
    
    var body: some View {
        if !register {
            ZStack {
                
                VStack {
                    
                    HStack {
                        
                        Text("Sign In")
                            .foregroundStyle(.black)
                            .font(.title)
                            .bold()
                            .padding()
                            .padding([.leading, .top], 15)
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.easeIn(duration: 0.1)) {
                                register = true
                            }
                        } label: {
                            Text("Don't have an account?")
                                .foregroundStyle(.black)
                                .bold()
                        }
                        .padding()
                        .padding([.trailing, .top], 15)
                    }
                    
                    Spacer()
                    
                }
                
                
                VStack {
                    
//                    Button {
//                        withAnimation(.easeIn(duration: 0.1)) {
//                            register = true
//                        }
//                    } label: {
//                        Text("Don't have an account?")
//                            .foregroundStyle(.black)
//                            .bold()
//                    }
//                    .vAlign(.top)
//                    .hAlign(.trailing)
                    
//                    Text("Log In")
//                        .font(.title)
                    
                    HStack {
                        
                        Image(systemName: "envelope.open.fill")
                            .foregroundStyle(.black)
                            .font(.title3)
                        
                        
                        
                        TextField("Email", text: $emailID)
                            .padding(.all, 5)
                            .border(1, .black)
                            .padding(.all, 5)
                            .keyboardType(.emailAddress)
                        
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 5)
                    
                    HStack {
                        
                        Image(systemName: "key.fill")
                            .foregroundStyle(.black)
                            .font(.title3)
                            .padding(.leading, 5)
                        
                        
                        SecureField("Password", text: $password)
                            .padding(.all, 5)
                            .border(1, .black)
                            .padding(.all, 5)
                            .padding(.leading, 6)
                        
                        Button {
                            closeKeyboard()
                            showForgotPasswordAlert.toggle()
                        } label: {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundStyle(.black)
                                .font(.headline)
                        }
                        
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 5)
                    
                    
                    Button {
                        closeKeyboard()
                        loginUser()
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
                    .border(1, .black)
                    
                    
                    
                    
                    
                }
                .preferredColorScheme(.light)
                .onChange(of: keyboardHandler.keyboardHeight, { oldValue, newValue in
                    withAnimation(.spring(duration: 0.2)) {
                        keyboardHeight = newValue
                    }
                })
                .alert(forgotPasswordAlert, isPresented: $showForgotPasswordAlert) {
                    Button(role: .cancel, action: {}, label: { Text("Cancel") })
                    
                    Button(role: .none, action: {showForgotPasswordSentAlert.toggle()}, label: { Text("Send Email") })
                }
                .alert("Sent!", isPresented: $showForgotPasswordSentAlert) {
                    Button(role: .none, action: {}, label: { Text("OK") })
                }
                .alert("Error", isPresented: $showError) {
                    Button("OK", role: .none, action: {})
                } message: {
                    Text(errorMsg)
                }
            }
            
        } else {
            ZStack {
                
                VStack {
                    
                    HStack {
                        
                        Text("Sign Up")
                            .foregroundStyle(.black)
                            .font(.title)
                            .bold()
                            .padding()
                            .padding([.leading, .top], 15)
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.easeIn(duration: 0.1)) {
                                register = false
                            }
                        } label: {
                            Text("Already have an account?")
                                .foregroundStyle(.black)
                                .bold()
                        }
                        .padding()
                        .padding([.trailing, .top], 15)
                    }
                    
                    Spacer()
                    
                }
                
                RegisterView()
            }
        }
    }
    
    
    func loginUser() {
        isLoading = true
        closeKeyboard()
        Task {
            do {
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                try await fetchUser()
            } catch {
                await setError(error)
            }
        }
    }
    
    func fetchUser() async throws {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        
        await MainActor.run(body: {
            userUID = userID
            profileURL = user.userProfileURL
            parent_parentLogStatus = true
        })
    }
    
    func setError(_ error: Error) async {
        await MainActor.run(body: {
            isLoading = false
            errorMsg = error.localizedDescription
            showError.toggle()
        })
    }
    
    func ResetPassword() {
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
            } catch {
                await setError(error)
            }
        }
    }
}

#Preview {
    LoginView()
}
