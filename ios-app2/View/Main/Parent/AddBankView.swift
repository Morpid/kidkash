//
//  AddBankView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-28.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
import SDWebImageSwiftUI
import PhotosUI

struct AddBankView: View {
    
    @State var username: String
    @State var currentArray: [Bank]
    
    
    @State var BankName: String = ""
    @State var BankAmount: String = ""
    
    @State var isLoading: Bool = false
    
    @State var showButton: Bool = false
    
    var body: some View {
        VStack {
            Text("Add Bank")
                .font(.title)
                .fontWeight(.heavy)
            
            TextField("Name", text: $BankName)
                .padding(.all, 5)
                .border(1, .black)
                .padding(.horizontal)
            
            TextField("Amount", text: $BankAmount)
                .keyboardType(.numberPad)
                .padding(.all, 5)
                .border(1, .black)
                .padding(.horizontal)
            
            if showButton {
                Button {
                    isLoading = true
                    
                    currentArray.append(Bank(name: BankName, amount: Double(BankAmount) ?? 0.00, transactionHistoryName: [], transactionHistorySubTitle: [], transactionHistoryAmount: [], transactionHistoryDate: [], amountHistoryAmount: [Double(BankAmount) ?? 0.00], amountHistoryDate: [Date.now]))
                    Task {
                        await sendArrayToFirebase()
                    }
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
        .frame(maxHeight: .infinity)
        .onChange(of: BankName) { oldValue, newValue in
            if !newValue.isEmpty {
                if !BankAmount.isEmpty {
                    withAnimation {
                        showButton = true
                    }
                } else {
                    withAnimation {
                        showButton = false
                    }
                }
            } else {
                withAnimation {
                    showButton = false
                }
            }
        }
        .onChange(of: BankAmount) { oldValue, newValue in
            if !newValue.isEmpty {
                if !BankName.isEmpty {
                    withAnimation {
                        showButton = true
                    }
                } else {
                    withAnimation {
                        showButton = false
                    }
                }
            } else {
                withAnimation {
                    showButton = false
                }
            }
        }
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
    }
    
    func sendArrayToFirebase() async {
        Task {
//                let _ = try Firestore.firestore().collection("ChildUsers").document(ChildUsername).setData(from: ChildUser, completion: {
//                    error in
//                    if error == nil {
//                        print("user saved")
//                        isLoading = false
//                        showAccountCreated.toggle()
//                    }
//                })
                
                
                    
            
            
            
            let user = try await Firestore.firestore().collection("ChildUsers").document(username).getDocument(as: ChildUser.self)
            
            let newUserData = ChildUser(username: user.username, userProfileURL: user.userProfileURL, banks: currentArray, parentUID: user.parentUID, lastUpdated: Date.now, RecurringTransactions: [])
            
            let _ = try Firestore.firestore().collection("ChildUsers").document(username).setData(from: newUserData)
            
            
            
            isLoading = false
                
            //db.collection("ChildUsers").document(username).setData(["banks":currentArray], merge: true)
                
            
        }
    }
}

#Preview {
    ContentView()
}
