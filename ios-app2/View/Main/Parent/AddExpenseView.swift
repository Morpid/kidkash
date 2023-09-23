//
//  AddExpenseView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-09-16.
//

import SwiftUI
import FirebaseFirestore

struct AddExpenseView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var subTitle: String = ""
    @State private var amount: Double = 0
    
    @State var bankArray: Int
    @State var username: String
    
    @State var selectedExpenseType: String
    
    @Binding var bank: Bank
    
    @State var bank_names: [String] = []
    
    @State var loading_bank_names: Bool = true
    
    @State var selected_bank_to: String = ""
    @State var selected_bank_from: String = ""
    
    var body: some View {
        NavigationStack {
            
            
            
            List {
                
                
                HStack {
                    
                    VStack {
                        
                        Text("Expense")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                            .onTapGesture {
                                withAnimation {
                                    selectedExpenseType = "Expense"
                                }
                            }
                        
                        if selectedExpenseType == "Expense" {
                            RoundedRectangle(cornerRadius: 3)
                                .frame(height: 5)
                                .foregroundStyle(Color.blue.opacity(0.7))
                                .padding(.horizontal)
                        } else {
                            RoundedRectangle(cornerRadius: 2)
                                .frame(height: 3)
                                .foregroundStyle(Color.gray.opacity(0.7))
                                .padding(.horizontal)
                        }
                        
                    }
                    
                    Spacer()
                    
                    VStack {
                        
                        Text("Payment")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                            .onTapGesture {
                                withAnimation {
                                    selectedExpenseType = "Payment"
                                }
                            }
                        
                        if selectedExpenseType == "Payment" {
                            RoundedRectangle(cornerRadius: 3)
                                .frame(height: 5)
                                .foregroundStyle(Color.blue.opacity(0.7))
                                .padding(.horizontal)
                        } else {
                            RoundedRectangle(cornerRadius: 2)
                                .frame(height: 3)
                                .foregroundStyle(Color.gray.opacity(0.7))
                                .padding(.horizontal)
                        }
                        
                    }
                    
                    Spacer()
                    
                    VStack {
                        
                        Text("Transfer")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                            .onTapGesture {
                                withAnimation {
                                    selectedExpenseType = "Transfer"
                                }
                            }
                        
                        if selectedExpenseType == "Transfer" {
                            RoundedRectangle(cornerRadius: 3)
                                .frame(height: 5)
                                .foregroundStyle(Color.blue.opacity(0.7))
                                .padding(.horizontal)
                        } else {
                            RoundedRectangle(cornerRadius: 2)
                                .frame(height: 3)
                                .foregroundStyle(Color.gray.opacity(0.7))
                                .padding(.horizontal)
                        }
                        
                    }
                }
                .listRowBackground(Color.clear)
                
                
                
                
                Section("") {
                    TextField("Title", text: $title)
                        .listRowBackground(Color.clear)
                        .border(1, .black)
                
                    TextField("Description", text: $subTitle)
                        .listRowBackground(Color.clear)
                        .border(1, .black)
                }
                
                if selectedExpenseType == "Expense" {
                    
                    Section("Amount") {
                        HStack(spacing: 4) {
                            Text("$")
                                .fontWeight(.semibold)
                            
                            TextField("0.00", value: $amount, formatter: formatter)
                                .keyboardType(.decimalPad)
                        }
                        .listRowBackground(Color.clear)
                        .border(1, .black)
                    }
                    
                } else if selectedExpenseType == "Payment" {
                    Section("Amount") {
                        HStack(spacing: 4) {
                            Text("$")
                                .fontWeight(.semibold)
                            
                            TextField("0.00", value: $amount, formatter: formatter)
                                .keyboardType(.decimalPad)
                        }
                        .listRowBackground(Color.clear)
                        .border(1, .black)
                    }
                } else {
                    
                    Section("Amount") {
                        HStack(spacing: 4) {
                            Text("$")
                                .fontWeight(.semibold)
                            
                            TextField("0.00", value: $amount, formatter: formatter)
                                .keyboardType(.decimalPad)
                        }
                        .listRowBackground(Color.clear)
                        .border(1, .black)
                        
                        if !loading_bank_names {
                            
                            Picker("From", selection: $selected_bank_from) {
                                ForEach(0..<bank_names.count) { i in
                                    Text(bank_names[i]).tag(bank_names[i])
                                }
                            }
                            .pickerStyle(.menu)
                            .listRowBackground(Color.clear)
                            .border(1, .black)
                            
                            Picker("To", selection: $selected_bank_to) {
                                ForEach(0..<bank_names.count) { i in
                                    Text(bank_names[i]).tag(bank_names[i])
                                }
                            }
                            .pickerStyle(.menu)
                            .listRowBackground(Color.clear)
                            .border(1, .black)
                            
                        } else {
                            ProgressView()
                                .listRowBackground(Color.clear)
                                .border(1, .black)
                        }
                    }
                }
                
                
            }
            .navigationTitle("Add \(selectedExpenseType)")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tint(.red)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        if selectedExpenseType == "Transfer" {
                            Task {
                                await sendTransferFirebase(from: selected_bank_from, to: selected_bank_to)
                            }
                        } else {
                            addExpense()
                        }
                    }
                    .disabled(isAddButtonDisabled)
                }
            }
            .onAppear {
                Task {
                    await getAllBanks()
                }
            }
        }
    }
    
    func getAllBanks() async {
        Task {
            var user = try await Firestore.firestore().collection("ChildUsers").document(username).getDocument(as: ChildUser.self)
            
            for i in 0...(user.banks.count - 1) {
                bank_names.append(user.banks[i].name)
                loading_bank_names = false
            }
        }
    }
    
    var isAddButtonDisabled: Bool {
        return title.isEmpty || subTitle.isEmpty || amount == .zero
    }
    
    func addExpense() {
        
        
        Task {
            var user = try await Firestore.firestore().collection("ChildUsers").document(username).getDocument(as: ChildUser.self)
            
            
             
            
            user.banks[bankArray].transactionHistoryName.append(title)
            
            user.banks[bankArray].transactionHistorySubTitle.append(subTitle)
            
            
            
            if selectedExpenseType == "Expense" {
                user.banks[bankArray].amountHistoryAmount.append((user.banks[bankArray].amount - amount))
                user.banks[bankArray].amountHistoryDate.append(Date.now)
                user.banks[bankArray].transactionHistoryAmount.append(Double("-" + String(amount))!)
                user.banks[bankArray].transactionHistoryDate.append(Date.now)
                user.banks[bankArray].amount = (user.banks[bankArray].amount - amount)
                
            } else {
                user.banks[bankArray].amountHistoryAmount.append((user.banks[bankArray].amount + amount))
                user.banks[bankArray].amountHistoryDate.append(Date.now)
                user.banks[bankArray].transactionHistoryAmount.append(amount)
                user.banks[bankArray].transactionHistoryDate.append(Date.now)
                user.banks[bankArray].amount = (user.banks[bankArray].amount + amount)
            }
            
            let _ = try Firestore.firestore().collection("ChildUsers").document(username).setData(from: user)
            
            await MainActor.run { [user] in
                self.bank = user.banks[bankArray]
            }
            
            
                
        }
    
        
        dismiss()
    }
    
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    func sendTransferFirebaseStep2(arrayforFrom: Int, arrayforTo: Int) async {
        
        
        Task {
            
            var new_amountToSendForFrom: Double
            var new_amountToSendForTo: Double
            
            var user = try await Firestore.firestore().collection("ChildUsers").document(username).getDocument(as: ChildUser.self)
            
            
            
            
            
            new_amountToSendForFrom = (user.banks[arrayforFrom].amount - amount)
            var amountForFrom = (user.banks[arrayforFrom].amount - amount)
            user.banks[arrayforFrom].amount = amountForFrom
            user.banks[arrayforFrom].amountHistoryAmount.append(new_amountToSendForFrom)
            user.banks[arrayforFrom].amountHistoryDate.append(Date.now)
            user.banks[arrayforFrom].transactionHistorySubTitle.append(subTitle)
            user.banks[arrayforFrom].transactionHistoryName.append(title)
            
            new_amountToSendForTo = (user.banks[arrayforTo].amount + amount)
            var amountForTo = (user.banks[arrayforTo].amount + amount)
            user.banks[arrayforTo].amount = amountForTo
            user.banks[arrayforTo].amountHistoryAmount.append(new_amountToSendForTo)
            user.banks[arrayforTo].amountHistoryDate.append(Date.now)
            user.banks[arrayforTo].transactionHistorySubTitle.append(subTitle)
            user.banks[arrayforTo].transactionHistoryName.append(title)
            
            
            
            user.banks[arrayforFrom].transactionHistoryAmount.append(Double("-" + String(amount))!)
            user.banks[arrayforFrom].transactionHistoryDate.append(Date.now)
            
            user.banks[arrayforTo].transactionHistoryAmount.append(amount)
            user.banks[arrayforTo].transactionHistoryDate.append(Date.now)
            
            
            let _ = try Firestore.firestore().collection("ChildUsers").document(username).setData(from: user)
            
            await MainActor.run { [user] in
                self.bank = user.banks[bankArray]
            }
        }
        
        dismiss()
    }
    
    func sendTransferFirebase(from: String, to: String) async {
        
        Task {
            let user = try await Firestore.firestore().collection("ChildUsers").document(username).getDocument(as: ChildUser.self)
            
            
            for i in 0...(user.banks.count - 1) {
                print(from)
                print(user.banks[i].name)
                if from == user.banks[i].name {
                    let arrayforFrom = i
                    for i in 0...(user.banks.count - 1) {
                        if to == user.banks[i].name {
                            let arrayforTo = i
                            await sendTransferFirebaseStep2(arrayforFrom: arrayforFrom, arrayforTo: arrayforTo)
                        }
                    }
                    
                }
            }
            
            
            
            
            
            
        }
    }
}

