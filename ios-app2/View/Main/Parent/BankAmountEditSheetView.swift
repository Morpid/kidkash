//
//  BankAmountEditSheetView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-31.
//

import SwiftUI
import Charts
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
import SDWebImageSwiftUI
import PhotosUI

struct BankAmountEditSheetView: View {
    
    @State var editTypeSelection: Int
    
    @State var bankArray: Int
    
    @Binding var bank: Bank
    
    @State var AllBanksNames: [String] = []
    
    @State var usernameChild: String
    
    @State var EditReason: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    @State var newAmount: Double = 0.00
    
    @State var DoubleDigit: String = ""

    @State var bankSelection1 = "Savings"
    @State var bankSelection2 = "Savings"
    
    @State var isLoading: Bool = false
    
    @State var showButton: Bool = false
    
    var body: some View {
        
            
        VStack {
            if editTypeSelection == 0 {
                
                Text("Add")
                    .font(.title)
                    .bold()
                    .padding()
                
                HStack {
                    
                    Text("$")
                    
                    TextField("Amount", text: $DoubleDigit)
                        .border(1, .black)
                        .keyboardType(.decimalPad)
                    
                }
                .padding()
                .onChange(of: DoubleDigit) { oldValue, newValue in
                    if !newValue.isEmpty {
                        withAnimation {
                            showButton = true
                        }
                    } else {
                        withAnimation {
                            showButton = false
                        }
                    }
                }
                
                TextField("Reason", text: $EditReason)
                    .border(1, .black)
                    .padding()
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.black)
                        .bold()
                        .padding(.horizontal, 50)
                        .border(1, .black)
                }
                
                if showButton {
                    Button {
                        newAmount = (bank.amount + Double(DoubleDigit)!)
                        Task {
                            await sendToFirebase(newAmount, isSubtract: false)
                        }
                        
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.forward")
                            .foregroundStyle(.green)
                            .bold()
                            .padding(.horizontal, 50)
                            .border(1, .black)
                    }
                    
                }
            } else if editTypeSelection == 1 {
                Text("Subtract")
                    .font(.title)
                    .bold()
                    .padding()
                
                HStack {
                    
                    Text("$")
                    
                    TextField("Amount", text: $DoubleDigit)
                        .border(1, .black)
                        .keyboardType(.decimalPad)
                    
                }
                .padding()
                .onChange(of: DoubleDigit) { oldValue, newValue in
                    if !newValue.isEmpty {
                        
                        withAnimation {
                            showButton = true
                        }
                        
                    } else {
                        withAnimation {
                            showButton = false
                        }
                    }
                }
                
                TextField("Reason", text: $EditReason)
                    .border(1, .black)
                    .padding()
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.black)
                        .bold()
                        .padding(.horizontal, 50)
                        .border(1, .black)
                }
                
                if showButton {
                    Button {
                        newAmount = (bank.amount - Double(DoubleDigit)!)
                        Task {
                            await sendToFirebase(newAmount, isSubtract: true)
                        }
                        
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.forward")
                            .foregroundStyle(.green)
                            .bold()
                            .padding(.horizontal, 50)
                            .border(1, .black)
                    }
                    
                }
            } else {
                Text("Transfer")
                    .font(.title)
                    .bold()
                    .padding()
                    .task {
                        await getAllBanks()
                    }
                
                if !AllBanksNames.isEmpty {
                    HStack {
                        Picker("Select Bank Account", selection: $bankSelection1) {
                            ForEach(AllBanksNames, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        
                        Text("to")
                        
                        Picker("Select Bank Account", selection: $bankSelection2) {
                            ForEach(AllBanksNames, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                        
                    }
                }
                
                HStack {
                    
                    Text("$")
                    
                    TextField("Amount", text: $DoubleDigit)
                        .border(1, .black)
                        .keyboardType(.decimalPad)
                    
                }
                .padding()
                .onChange(of: DoubleDigit) { oldValue, newValue in
                    if !newValue.isEmpty {
                        
                        withAnimation {
                            showButton = true
                        }
                        
                    } else {
                        withAnimation {
                            showButton = false
                        }
                    }
                }
                
                TextField("Reason", text: $EditReason)
                    .border(1, .black)
                    .padding()
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.black)
                        .bold()
                        .padding(.horizontal, 50)
                        .border(1, .black)
                }
                
                if showButton {
                    Button {
                        newAmount = (bank.amount - Double(DoubleDigit)!)
                        Task {
                            await sendTransferFirebase(newAmount, from: bankSelection1, to: bankSelection2)
                        }
                        
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.forward")
                            .foregroundStyle(.green)
                            .bold()
                            .padding(.horizontal, 50)
                            .border(1, .black)
                    }
                    
                }
            }
        }
        .overlay {
            LoadingView(show: $isLoading)
        }
        
    }
    
    func getAllBanks() async {
        Task {
            var user = try await Firestore.firestore().collection("ChildUsers").document(usernameChild).getDocument(as: ChildUser.self)
            
            for i in 0...(user.banks.count - 1) {
                AllBanksNames.append(user.banks[i].name)
            }
        }
    }
    
    func sendTransferFirebaseStep2(arrayforFrom: Int, arrayforTo: Int) async {
        
        
        Task {
            
            var newAmountToSendForFrom: Double
            var newAmountToSendForTo: Double
            
            var user = try await Firestore.firestore().collection("ChildUsers").document(usernameChild).getDocument(as: ChildUser.self)
            
            newAmountToSendForFrom = (user.banks[arrayforFrom].amount - Double(DoubleDigit)!)
            var amountForFrom = (user.banks[arrayforFrom].amount - Double(DoubleDigit)!)
            user.banks[arrayforFrom].amount = amountForFrom
            
            newAmountToSendForTo = (user.banks[arrayforTo].amount + Double(DoubleDigit)!)
            var amountForTo = (user.banks[arrayforTo].amount + Double(DoubleDigit)!)
            user.banks[arrayforTo].amount = amountForTo
            
            user.banks[arrayforFrom].amountHistoryAmount.append(newAmountToSendForFrom)
            
            user.banks[arrayforTo].amountHistoryAmount.append(newAmountToSendForTo)
            
            user.banks[arrayforFrom].amountHistoryDate.append(Date.now)
            
            user.banks[arrayforTo].amountHistoryDate.append(Date.now)
            
            
            user.banks[arrayforFrom].transactionHistoryName.append(EditReason)
            
            user.banks[arrayforTo].transactionHistoryName.append(EditReason)
            
            
            
            user.banks[arrayforFrom].transactionHistoryAmount.append(Double("-" + DoubleDigit)!)
            user.banks[arrayforFrom].transactionHistoryDate.append(Date.now)
            
            user.banks[arrayforTo].transactionHistoryAmount.append(Double(DoubleDigit)!)
            user.banks[arrayforTo].transactionHistoryDate.append(Date.now)
            
            
            let _ = try Firestore.firestore().collection("ChildUsers").document(usernameChild).setData(from: user)
            
            
            isLoading = false
        }
    }
    
    func sendTransferFirebase(_ amountToTransfer: Double, from: String, to: String) async {
        
        isLoading = true
        
        Task {
            let user = try await Firestore.firestore().collection("ChildUsers").document(usernameChild).getDocument(as: ChildUser.self)
            
            
            for i in 0...(user.banks.count - 1) {
                print(from)
                print(user.banks[i].name)
                if from == user.banks[i].name {
                    let arrayforFrom = i
                    for i in 0...(user.banks.count - 1) {
                        if to == user.banks[i].name {
                            let arrayforTo = i
                            await sendTransferFirebaseStep2(arrayforFrom: arrayforFrom, arrayforTo: arrayforTo)
                            print("Hi There!!!!!! this is to debug")
                        }
                    }
                    
                }
            }
            
            
            
            
//            withAnimation {
//                bank = user.banks[bankArray]
//            }
            
        }
    }
    
    func sendToFirebase(_ newAmountToSend: Double, isSubtract: Bool) async {
        
        isLoading = true
        
        Task {
            var user = try await Firestore.firestore().collection("ChildUsers").document(usernameChild).getDocument(as: ChildUser.self)
            
            
            user.banks[bankArray].amount = newAmountToSend
            
            user.banks[bankArray].amountHistoryAmount.append(newAmountToSend)
            
            user.banks[bankArray].amountHistoryDate.append(Date.now)
            
            user.banks[bankArray].transactionHistoryName.append(EditReason)
            
            if isSubtract {
                user.banks[bankArray].transactionHistoryAmount.append(Double("-" + DoubleDigit)!)
                user.banks[bankArray].transactionHistoryDate.append(Date.now)
            } else {
                user.banks[bankArray].transactionHistoryAmount.append(Double(DoubleDigit)!)
                user.banks[bankArray].transactionHistoryDate.append(Date.now)
            }
            
            let _ = try Firestore.firestore().collection("ChildUsers").document(usernameChild).setData(from: user)
            
            await MainActor.run { [user] in
                bank = user.banks[bankArray]
            }
            
            
            isLoading = false
              
        }
    }
}

#Preview {
    ContentView()
}
