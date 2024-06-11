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
    @Environment(\.dismiss) var dismiss
    
    @State var show_button: Bool = false
    
    var body: some View {
        if !register {
            ZStack {
                
                VStack {
                    
                    HStack {
                        
                        VStack(alignment: .leading) {
                            
                            Text("Sign In")
                                .foregroundStyle(.black)
                                .font(.title)
                                .bold()
                                .padding([.horizontal, .top])
                                .padding([.leading, .top], 15)
                            
                            
                            HStack {
                                
                                Text("or")
                                    .foregroundStyle(.black)
                                    .font(.callout)
                                
                                Button {
                                    withAnimation(.bouncy(duration: 0.25)) {
                                        register = true
                                    }
                                } label: {
                                    Text("Create Account")
                                        .foregroundStyle(.blue)
                                        .font(.callout)
                                }
                                
                            }
                            .padding(.leading)
                            .padding(.leading, 15)
                            
                        }
                        
                        Spacer()
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.title)
                                .foregroundStyle(.black)
                                
                        }
                        //.padding(.top)
                        .padding(.trailing, 20)
                        
                    }
                    
                    Spacer()
                    
                }
                
                
                VStack {
                    
                    HStack {
                        
                        Image(systemName: "at")
                            .foregroundStyle(.black)
                            .font(.title3)
                        
                        VStack {
                            
                            TextField("Email", text: $emailID)
                                .padding(.leading, 10)
                                //.border(1, .mint)
                                .padding(.top, 10)
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
                        
                        Button {
                            closeKeyboard()
                            showForgotPasswordAlert.toggle()
                        } label: {
                            Image(systemName: "questionmark")
                                .foregroundStyle(.black)
                                .font(.headline)
                        }
                        
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 15)
                    
                    if show_button {
                        
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
                        
                    }
                    
                    
                    
                }
                //.preferredColorScheme(.light)
                .onChange(of: keyboardHandler.keyboardHeight, { oldValue, newValue in
                    withAnimation(.spring(duration: 0.2)) {
                        keyboardHeight = newValue
                    }
                })
                .alert(forgotPasswordAlert, isPresented: $showForgotPasswordAlert) {
                    Button(role: .cancel, action: {}, label: { Text("Cancel") })
                    
                    Button {
                        ResetPassword()
                        
                    } label: {
                        Text("Send Email")
                    }
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
            .transition(.push(from: .leading))
            
        } else {
            ZStack {
                
                
                VStack {
                    
                    HStack {
                        
                        VStack(alignment: .leading) {
                            
                            Text("Sign Up")
                                .foregroundStyle(.black)
                                .font(.title)
                                .bold()
                                .padding([.horizontal, .top])
                                .padding([.leading, .top], 15)
                            
                            HStack {
                                
                                Text("or")
                                    .foregroundStyle(.black)
                                    .font(.callout)
                                
                                Button {
                                    withAnimation(.bouncy(duration: 0.25)) {
                                        register = false
                                    }
                                } label: {
                                    Text("Log in")
                                        .foregroundStyle(.blue)
                                        .font(.callout)
                                }
                                
                            }
                            .padding(.leading)
                            .padding(.leading, 15)
                            
                        }
                        
                        Spacer()
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.title)
                                .foregroundStyle(.black)
                                
                        }
                        //.padding(.top)
                        .padding(.trailing, 20)
                        
                    }
                    
                    Spacer()
                    
                }
                
                RegisterView()
            }
            .transition(.push(from: .trailing))
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
                showForgotPasswordSentAlert.toggle()
            } catch {
                await setError(error)
            }
        }
    }
}

#Preview {
    LoginView()
}
