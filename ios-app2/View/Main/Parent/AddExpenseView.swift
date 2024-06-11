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
    
    @State private var percent_amount: Int = 1
    
    @State var bankArray: Int
    @State var username: String
    
    @State var selectedExpenseType: String
    
    @Binding var bank: Bank
    
    @State var bank_names: [String] = []
    
    @State var loading_bank_names: Bool = true
    
    @Namespace var animation
    
    @State var selected_bank_to: String = "Savings"
    @State var selected_bank_from: String = "Savings"
    
    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                
                
                
                VStack {
                    
                    
                    HStack {
                        
                        VStack {
                            
                            Text("Expense")
                                .padding(.vertical, 5)
                            //.padding(.horizontal)
                                .onTapGesture {
                                    withAnimation {
                                        selectedExpenseType = "Expense"
                                    }
                                }
                                .font(.callout)
                            
                            if selectedExpenseType == "Expense" {
                                Rectangle()
                                    .frame(width: proxy.size.width / 4, height: 1)
                                    .foregroundStyle(.black)
                                    .padding(.horizontal)
                                    .matchedGeometryEffect(id: "UNDERLINE", in: animation)
                            }
                            
                        }
                        
                        Spacer()
                        
                        VStack {
                            
                            Text("Payment")
                                .padding(.vertical, 5)
                            //.padding(.horizontal)
                                .onTapGesture {
                                    withAnimation {
                                        selectedExpenseType = "Payment"
                                    }
                                }
                                .font(.callout)
                            
                            if selectedExpenseType == "Payment" {
                                Rectangle()
                                    .frame(width: proxy.size.width / 4, height: 1)
                                    .foregroundStyle(.black)
                                    .padding(.horizontal)
                                    .matchedGeometryEffect(id: "UNDERLINE", in: animation)
                            }
                            
                        }
                        
                        Spacer()
                        
                        VStack {
                            
                            Text("Transfer")
                                .padding(.vertical, 5)
                            //.padding(.horizontal)
                                .onTapGesture {
                                    withAnimation {
                                        selectedExpenseType = "Transfer"
                                    }
                                }
                                .font(.callout)
                            
                            if selectedExpenseType == "Transfer" {
                                Rectangle()
                                    .frame(width: proxy.size.width / 4, height: 1)
                                    .foregroundStyle(.black)
                                    .padding(.horizontal)
                                    .matchedGeometryEffect(id: "UNDERLINE", in: animation)
                            }
                            
                        }
                        
                        Spacer()
                        
                        VStack {
                            
                            Text("Interest")
                                .padding(.vertical, 5)
                            //.padding(.horizontal)
                                .onTapGesture {
                                    withAnimation {
                                        selectedExpenseType = "Interest"
                                    }
                                }
                                .font(.callout)
                            
                            if selectedExpenseType == "Interest" {
                                Rectangle()
                                    .frame(width: proxy.size.width / 4, height: 1)
                                    .foregroundStyle(.black)
                                    .padding(.horizontal)
                                    .matchedGeometryEffect(id: "UNDERLINE", in: animation)
                            }
                            
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .padding(.bottom)
                    
                    
                    
                    
                    Section("") {
                        TextField("Title", text: $title)
                            .listRowBackground(Color.clear)
                            .border(1, .black)
                            .listRowSeparator(.hidden)
                        
                        
                        TextField("Description", text: $subTitle)
                            .listRowBackground(Color.clear)
                            .border(1, .black)
                            .listRowSeparator(.hidden)
                    }
                    
                    Spacer()
                        .frame(height: 25)
                    
                    Divider()
                    
                    Spacer()
                        .frame(height: 25)
                    
                    if selectedExpenseType == "Expense" {
                        
                        
                        HStack(spacing: 4) {
                            Text("$")
                                .fontWeight(.semibold)
                            
                            TextField("0.00", value: $amount, formatter: formatter)
                                .keyboardType(.decimalPad)
                        }
                        .listRowBackground(Color.clear)
                        .border(1, .black)
                        
                        
                    } else if selectedExpenseType == "Payment" {
                        
                        HStack(spacing: 4) {
                            Text("$")
                                .fontWeight(.semibold)
                            
                            TextField("0.00", value: $amount, formatter: formatter)
                                .keyboardType(.decimalPad)
                        }
                        .listRowBackground(Color.clear)
                        .border(1, .black)
                        
                    } else if selectedExpenseType == "Interest" {
                        
                        
                        Stepper("\(percent_amount)%", value: $percent_amount, in: 1...100)
                            .listRowBackground(Color.clear)
                            .border(1, .black)
                        
                    } else {
                        
                        
                        HStack(spacing: 4) {
                            Text("$")
                                .fontWeight(.semibold)
                            
                            TextField("0.00", value: $amount, formatter: formatter)
                                .keyboardType(.decimalPad)
                        }
                        .listRowBackground(Color.clear)
                        .border(1, .black)
                        .listRowSeparator(.hidden)
                        
                        Spacer()
                            .frame(height: 25)
                        
                        Divider()
                        
                        Spacer()
                            .frame(height: 25)
                        
                        if !loading_bank_names {
                            
                            HStack {
                                
                                Picker("From", selection: $selected_bank_from) {
                                    ForEach(0..<bank_names.count) { i in
                                        Text(bank_names[i]).tag(bank_names[i])
                                    }
                                }
                                .pickerStyle(.menu)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                
                                Spacer()
                                
                                Text("to")
                                
                                Spacer()
                                
                                Picker("To", selection: $selected_bank_to) {
                                    ForEach(0..<bank_names.count) { i in
                                        Text(bank_names[i]).tag(bank_names[i])
                                    }
                                }
                                .pickerStyle(.menu)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                
                            }
                            .border(1, .black)
                            
                        } else {
                            ProgressView()
                                .listRowBackground(Color.clear)
                                .border(1, .black)
                                .listRowSeparator(.hidden)
                        }
                        
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Add \(selectedExpenseType)")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .tint(.black)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add") {
                            if selectedExpenseType == "Transfer" {
                                Task {
                                    await sendTransferFirebase(from: selected_bank_from, to: selected_bank_to)
                                }
                            } else if selectedExpenseType == "Interest" {
                                Task {
                                    await addInterest(amount: percent_amount)
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
        if selectedExpenseType == "Interest" {
            return title.isEmpty || subTitle.isEmpty
        } else {
            return title.isEmpty || subTitle.isEmpty || amount == .zero
        }
    }
    
    func addInterest(amount: Int) async {
        Task {
            var user = try await Firestore.firestore().collection("ChildUsers").document(username).getDocument(as: ChildUser.self)
            
            user.banks[bankArray].transactionHistoryName.append(title)
            
            user.banks[bankArray].transactionHistorySubTitle.append(subTitle)
            
            var amount_to_add = 0.00
            
            if amount < 10 {
                amount_to_add = (user.banks[bankArray].amount * Double("0.0\(amount)")!)
            } else if amount == 100 {
                amount_to_add = user.banks[bankArray].amount
            } else {
                amount_to_add = (user.banks[bankArray].amount * Double("0.\(amount)")!)
            }
            
            user.banks[bankArray].amountHistoryAmount.append((user.banks[bankArray].amount + amount_to_add))
            user.banks[bankArray].amountHistoryDate.append(Date.now)
            user.banks[bankArray].transactionHistoryAmount.append(Double(String(amount_to_add))!)
            user.banks[bankArray].transactionHistoryDate.append(Date.now)
            user.banks[bankArray].amount = (user.banks[bankArray].amount + amount_to_add)
            
            let _ = try Firestore.firestore().collection("ChildUsers").document(username).setData(from: user)
            
            await MainActor.run { [user] in
                self.bank = user.banks[bankArray]
            }
        }
        
        dismiss()
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

