//
//  NewChildAccountView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-25.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import SDWebImageSwiftUI
import PhotosUI

struct NewChildAccountView: View {
    
    @State var isLoading: Bool = false

    @State var fetchedUsers: [ChildUser] = []
    
    @State var myProfile: User?
    
    @State var ShouldProceedWithAccountCreation: Bool = true

    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    
    @State var showProceedButton: Bool = false

    @State var ChildUsername: String = ""
    @State var ChildPassword: String = ""
    @State var ChildProfileImageData: Data?
    
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""

    @State var showError: Bool = false
    @State var errorMsg: String = ""
    
    @State var showAccountCreated: Bool = false

    var body: some View {
        
        VStack(spacing: 0) {

            VStack {
                Text("Create Child User")
                    .font(.title)

                HStack {

                    ZStack {
                        if let ChildProfileImageData, let image = UIImage(data: ChildProfileImageData) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }


                    }
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .contentShape(Circle())
                    .padding(.trailing)


                    Button {
                        showImagePicker.toggle()
                    } label: {
                        HStack {
                            Text("Choose")
                                .foregroundStyle(.black)

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.green)
                        }
                        .border(1, .black)
                    }
                }
                .padding()
                
                HStack {
                    
                    Image(systemName: "person")
                        .foregroundStyle(.black)
                    
                    TextField("Username", text: $ChildUsername)
                        .border(1, .black)
                }
                .onChange(of: ChildUsername, { oldValue, newValue in
                    if !ChildUsername.isEmpty {
                        if let photoItemnew = photoItem {
                            withAnimation {
                                showProceedButton = true
                            }
                        } else {
                            withAnimation {
                                showProceedButton = false
                            }
                        }
                    } else {
                        withAnimation {
                            showProceedButton = false
                        }
                    }
                })
                .onChange(of: photoItem, { oldValue, newValue in
                    if let newPhotoItem = newValue {
                        if !ChildUsername.isEmpty {
                            withAnimation {
                                showProceedButton = true
                            }
                        } else {
                            withAnimation {
                                showProceedButton = false
                            }
                        }
                    } else {
                        withAnimation {
                            showProceedButton = false
                        }
                    }
                })
                
                if showProceedButton {
                    Button {
                        isLoading = true
                        Task {
                            await checkUsername()
                        }
                        isLoading = false
                    } label: {
                        Image(systemName: "arrow.forward")
                            .foregroundStyle(.green)
                            .bold()
                            .padding(.horizontal, 50)
                    }
                    .border(1, .black)
                    .padding()
                }
            }
            .padding()
        }
        .frame(maxHeight: .infinity)
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem, matching: .images)
        .onChange(of: photoItem) { oldValue, newValue in
            if let newValue {
                Task {
                    do {
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else {return}

                        await MainActor.run(body: {
                            ChildProfileImageData = imageData
                        })
                       } catch {

                    }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
                Button("OK", role: .none, action: {})
        } message: {
            Text(errorMsg)
        }
        .alert("Account Created", isPresented: $showAccountCreated) {
                Button("OK", role: .none, action: {})
        } message: {
            Text("Account created successfully. Login with the username \(ChildUsername) on your child's device")
        }
        .overlay(content: {
            LoadingView(show: $isLoading)
        })


        
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
    
    func searchChildUsers() async {
        do {
            
            let documents = try await Firestore.firestore().collection("ChildUsers").whereField("username", isGreaterThanOrEqualTo: ChildUsername).whereField("username", isLessThanOrEqualTo: "\(ChildUsername)\u{f8ff}").getDocuments()
            
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
    
    func checkUsername() async {
        isLoading = true
        Task {
            await searchChildUsers()
            
            if fetchedUsers.isEmpty {
                isLoading = false
                await MainActor.run {
                    CreatChildUser()
                }
                return
            } else {
                for i in 0...(fetchedUsers.count - 1) {
                    if ChildUsername == fetchedUsers[i].username {
                        await MainActor.run {
                            ShouldProceedWithAccountCreation = false
                        }
                        isLoading = false
                        await setStringError("The username '\(ChildUsername)' is already taken")
                        return
                    }
                }
                
                if ShouldProceedWithAccountCreation {
                    await MainActor.run {
                        CreatChildUser()
                    }
                }
                
                isLoading = false
                return
            }
            
        }
        
    }

    func CreatChildUser() {
        closeKeyboard()
        isLoading = true
        Task {
            do {

                guard let userUID = Auth.auth().currentUser?.uid else { return }
                guard let imageData = ChildProfileImageData else { return }

                let storageRef = Storage.storage().reference().child("Profile_Images").child(ChildUsername)
                let _ = try await storageRef.putDataAsync(imageData)

                let downloadURL = try await storageRef.downloadURL()

                let ChildUser = ChildUser(username: ChildUsername, userProfileURL: downloadURL, banks: [

                    Bank(name: "Savings", amount: 0.00, transactionHistoryName: [], transactionHistoryAmount: [], transactionHistoryDate: [], amountHistoryAmount: [0.00], amountHistoryDate: [Date.now]),
                    
                    Bank(name: "Spending", amount: 0.00, transactionHistoryName: [], transactionHistoryAmount: [], transactionHistoryDate: [], amountHistoryAmount: [0.00], amountHistoryDate: [Date.now]),
                    
                    Bank(name: "Charity", amount: 0.00, transactionHistoryName: [], transactionHistoryAmount: [], transactionHistoryDate: [], amountHistoryAmount: [0.00], amountHistoryDate: [Date.now]),
                    
                ], parentUID: userUID, lastUpdated: Date.now, RecurringTransactions: [])

                let _ = try Firestore.firestore().collection("ChildUsers").document(ChildUsername).setData(from: ChildUser, completion: {
                    error in
                    if error == nil {
                        print("user saved")
                        isLoading = false
                        showAccountCreated.toggle()
                    }
                })


            } catch {
                await setError(error)
            }
        }
    }
}

#Preview {
    NewChildAccountView()
}
