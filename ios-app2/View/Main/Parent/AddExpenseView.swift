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
    @State private var date: Date = .init()
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
                
                Picker("Expense Type", selection: $selectedExpenseType) {
                    Text("Expense").tag("Expense")
                    Text("Payment").tag("Payment")
                    Text("Transfer").tag("Transfer")
                }
                .pickerStyle(.menu)
                
                
                
                Section("Title") {
                    TextField("Magic Keyboard", text: $title)
                }
                
                Section("Description") {
                    TextField("Bought a keyboard at the Apple Store", text: $subTitle)
                }
                
                if selectedExpenseType == "Expense" {
                    
                    Section("Amount Spent") {
                        HStack(spacing: 4) {
                            Text("$")
                                .fontWeight(.semibold)
                            
                            TextField("0.00", value: $amount, formatter: formatter)
                                .keyboardType(.decimalPad)
                        }
                    }
                    
                } else if selectedExpenseType == "Payment" {
                    Section("Amount Paid") {
                        HStack(spacing: 4) {
                            Text("$")
                                .fontWeight(.semibold)
                            
                            TextField("0.00", value: $amount, formatter: formatter)
                                .keyboardType(.decimalPad)
                        }
                    }
                } else {
                    
                    Section("Amount") {
                        HStack(spacing: 4) {
                            Text("$")
                                .fontWeight(.semibold)
                            
                            TextField("0.00", value: $amount, formatter: formatter)
                                .keyboardType(.decimalPad)
                        }
                        
                        if !loading_bank_names {
                            
                            Picker("From", selection: $selected_bank_from) {
                                ForEach(0..<bank_names.count) { i in
                                    Text(bank_names[i]).tag(bank_names[i])
                                }
                            }
                            .pickerStyle(.menu)
                            
                            Picker("To", selection: $selected_bank_to) {
                                ForEach(0..<bank_names.count) { i in
                                    Text(bank_names[i]).tag(bank_names[i])
                                }
                            }
                            .pickerStyle(.menu)
                            
                        } else {
                            ProgressView()
                        }
                    }
                }
                
                Section("Date") {
                    DatePicker("", selection: $date, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
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

