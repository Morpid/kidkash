//
//  ChildLoginView.swift
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

struct ChildLoginView: View {
    
    @AppStorage("log_status") var logStatus: Bool = false
    
    
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var usernameStored: String = ""
    
    @State var profileURL_TEMP: URL?
    @State var usernameStored_TEMP: String = ""
    
    @State var showError: Bool = false
    @State var errorMsg: String = ""
    
    @State var showWrongCodeAlert: Bool = false
    @State var showParentHasNotCreatedCodeAlert: Bool = false
    
    @State var showProceedButton: Bool = false
    
    @State var documentExists: Bool = true
    
    @State var showVerificationCodeView: Bool = false
    
    @State var codeTextField: String = ""
    
    @State var verificationCode: Int = 0
    
    @State var username: String = ""
    
    @State var fetchedUsers: [ChildUser] = []
    @State var fetchedParentUsers: [User] = []
    
    @State var isLoading: Bool = false
    
    @State private var parentUID: String = ""
    
    @State var show_button: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    @State var showForgotPasswordAlert: Bool = false
    @State var showForgotPasswordSentAlert: Bool = false
    @State var forgotPasswordAlert: String = "Forgot Password?"
    
    var body: some View {
        if !showVerificationCodeView {
            VStack {
                
                HStack {
                    
                    VStack(alignment: .leading) {
                        
                        Text("Sign In")
                            .foregroundStyle(.black)
                            .font(.title)
                            .bold()
                            .padding([.horizontal, .top])
                            .padding([.leading, .top], 15)
                        
                        Text("to your child account")
                            .foregroundStyle(.black)
                            .font(.callout)
                            .padding([.horizontal])
                            .padding([.leading], 15)
                        
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
                
                HStack {
                    
                    Image(systemName: "person")
                        .foregroundStyle(.black)
                        .font(.title3)
                    
                    VStack {
                        
                        TextField("Username", text: $username)
                            .keyboardType(.emailAddress)
                            .onChange(of: username) { oldValue, newValue in
                                if !newValue.isEmpty {
                                    withAnimation {
                                        if !show_button {
                                            show_button = true
                                        }
                                    }
                                } else {
                                    if show_button {
                                        withAnimation {
                                            show_button = false
                                        }
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
                
                
                if show_button {
                    
                    Button {
                        closeKeyboard()
                        isLoading = true
                        checkUsername()
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
                
                Spacer()
                
            }
            //.preferredColorScheme(.light)
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

        } else {
            VStack {
                
                HStack {
                    
                    VStack(alignment: .leading) {
                        
                        Text("Verify it's you")
                            .foregroundStyle(.black)
                            .font(.title)
                            .bold()
                            .padding([.horizontal, .top])
                            .padding([.leading, .top], 15)
                        
                        Text("ask your parent to generate a login code for you")
                            .foregroundStyle(.black)
                            .font(.callout)
                            .padding([.horizontal])
                            .padding([.leading], 15)
                        
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
                
                HStack {
                    
                    Image(systemName: "key")
                        .foregroundStyle(.black)
                        .font(.title3)
                    
                    
                    VStack {
                        
                        TextField("Verification Code", text: $codeTextField)
                            .keyboardType(.emailAddress)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.black)
                    }
                    
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 15)
                .padding(.top, 30)
                
                if showProceedButton {
                    Button {
                        closeKeyboard()
                        Task {
                            await checkVerificationCode()
                        }
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
                    .disabled(codeTextField.isEmpty)
                }
                
                Spacer()
            }
            .onChange(of: codeTextField, { oldValue, newValue in
                if !newValue.isEmpty {
                    withAnimation {
                        showProceedButton = true
                    }
                } else {
                    withAnimation {
                        showProceedButton = false
                    }
                }
            })
            .alert("Incorrect Code", isPresented: $showWrongCodeAlert) {
                Button("OK", role: .none, action: {})
            }
            .alert("Verification Failed", isPresented: $showParentHasNotCreatedCodeAlert) {
                Button("OK", role: .none, action: {})
            } message: {
                Text("Your parent has not created a verification code yet")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .none, action: {})
            } message: {
                Text(errorMsg)
            }
        }
    }
    
    func checkVerificationCode() async {
        isLoading = true
        
        Task {
            do {
                
//                let db = Firestore.firestore()
//                
//                let docRef = db.collection("LoginCodes").document("\(username)")
//                
//                docRef.getDocument { (document, error) in
//                    if let document = document {
//                        if document.exists{
//                            documentExists = true
//                        } else {
//                            documentExists = false
//                        }
//                    }
//                }
                
                let doc = try await Firestore.firestore().collection("LoginCodes").document("\(username)").getDocument(as: LoginCode.self)
                
                if String(doc.code) == codeTextField {
                    isLoading = false
                    loginChildUser()
                } else {
                    isLoading = false
                    showWrongCodeAlert.toggle()
                }
                
//                if documentExists {
//                    let DocData = try await docRef.getDocument(as: LoginCode.self)
//                    let correctCode = DocData.code
//                        
//                    if codeTextField == String(correctCode) {
//                        loginChildUser()
//                    } else {
//                        isLoading = false
//                        showWrongCodeAlert.toggle()
//                    }
//                } else {
//                    isLoading = false
//                    showParentHasNotCreatedCodeAlert.toggle()
//                }
            } catch {
                isLoading = false
                errorMsg = "Your parent has not created a login code yet"
                showError.toggle()
            }
        }
    }
    
    func checkUsername() {
        isLoading = true
        Task {
            await searchChildUsers()
            
            if fetchedUsers.isEmpty {
                isLoading = false
                await setStringError("Username not found")
                return
            } else {
                for i in 0...(fetchedUsers.count - 1) {
                    if username == fetchedUsers[i].username {
                        profileURL_TEMP = fetchedUsers[i].userProfileURL
                        usernameStored_TEMP = fetchedUsers[i].username
                        await findParentUID(username, fetchedUserArrayNumber: i)
                        return
                    }
                }
                
                isLoading = false
                await setStringError("Username not found")
                return
            }
            
            
        }
        
        isLoading = false
        
    }
    
    func findParentUID(_ childUsername: String, fetchedUserArrayNumber: Int) async {
        do {
            let document = try await Firestore.firestore().collection("ChildUsers").document("\(username)").getDocument(as: ChildUser.self)
            
            let parentUID = document.parentUID
            
            withAnimation(.linear(duration: 0.2)) {
                showVerificationCodeView = true
            }
        } catch {
            print(error.localizedDescription)
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
    
    func random(digits: Int) -> String {
        var number = String()
        for _ in 1...digits {
           number += "\(Int.random(in: 1...9))"
        }
        return number
    }
    
    
    func loginChildUser() {
        isLoading = false
        
        usernameStored = usernameStored_TEMP
        profileURL = profileURL_TEMP
        
        logStatus = true
    }
    
    func searchChildUsers() async {
        do {
            
            let documents = try await Firestore.firestore().collection("ChildUsers").whereField("username", isGreaterThanOrEqualTo: username).whereField("username", isLessThanOrEqualTo: "\(username)\u{f8ff}").getDocuments()
            
            let users = try documents.documents.compactMap { doc -> ChildUser? in
                try doc.data(as: ChildUser.self)
            }
            
            await MainActor.run(body: {
                fetchedUsers = users
            })
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func searchParentUsers(UID: String) async {
        do {
            
            let documents = try await Firestore.firestore().collection("Users").whereField("userUID", isGreaterThanOrEqualTo: UID).whereField("userUID", isLessThanOrEqualTo: "\(UID)\u{f8ff}").getDocuments()
            
            let users = try documents.documents.compactMap { doc -> User? in
                try doc.data(as: User.self)
            }
            
            await MainActor.run(body: {
                fetchedParentUsers = users
            })
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    ChildLoginView()
}
