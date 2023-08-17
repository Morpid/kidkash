//
//  RecurringTransaction.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-08-04.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import SDWebImageSwiftUI
import PhotosUI

enum Day: String, CaseIterable {
    case Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
}

struct DaysPicker: View {
    
    @Binding var selectedDays: [Day]
    
    var body: some View {
        HStack {
            ForEach(Day.allCases, id: \.self) { day in
                Text(String(day.rawValue.first!))
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(selectedDays.contains(day) ? Color.green.cornerRadius(10) : Color.gray.cornerRadius(10))
                    .onTapGesture {
                        if selectedDays.contains(day) {
                            selectedDays.removeAll(where: {$0 == day})
                        } else {
                            selectedDays.append(day)
                        }
                    }
            }
        }
    }
}



struct RecurringTransaction: View {
    
    @State var user: ChildUser
    
    @State var isLoading: Bool = false
    
    @State var AllBanksNames: [String] = []
    @State var bankSelection = "Select a Bank Account"
    
    @State var selectedDays: [Day] = []
    
    @State var selectedDaysCodable: [(name: String, isSelected: Bool)] = []
    @State var selectedDaysCodableTemp: [(name: String, isSelected: Bool)] = []
    
    @State var amount: String = ""
    @State var bankAccountName: String = ""
    @State var name: String = ""
    @State var days: [String] = []
    @State var startDay: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                ForEach(0..<user.RecurringTransactions.count) { i in
                    Text(user.RecurringTransactions[i].name)
                }
                
                Spacer()
                
                TextField("Name", text: $name)
                    .border(1, .black)
                
                TextField("Amount", text: $amount)
                    .border(1, .black)
                    .keyboardType(.decimalPad)
                
                DaysPicker(selectedDays: $selectedDays)
                
                Picker("Select a Bank Account", selection: $bankSelection) {
                    ForEach(AllBanksNames, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.navigationLink)
                
                Picker(selection: $bankSelection) {
                    ForEach(AllBanksNames, id: \.self) {
                        Text($0)
                    }
                } label: {
                    HStack {
                        Text("Select A Bank Account")
                            .foregroundStyle(.green)
                        
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.green)
                    }
                }
                .pickerStyle(.menu)

                
                Button("Add") {
                    Task {
                        await AddRecurringTransaction()
                    }
                }
            }
            .padding()
            .onChange(of: selectedDays) { oldValue, newValue in
                
                selectedDaysCodableTemp = []
                
                
                
                for i in 0...(selectedDays.count - 1) {
                    
                    selectedDaysCodableTemp.append((name: selectedDays[i].rawValue, isSelected: true))
                }
                
                selectedDaysCodable = selectedDaysCodableTemp
            }
        }
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .navigationTitle("Recurring Transactions")
        .task {
            await getAllBanks()
        }
    }
    
    func AddRecurringTransaction() async {
        
        
        isLoading = true
        
        do {
            var user = try await Firestore.firestore().collection("ChildUsers").document(user.username).getDocument(as: ChildUser.self)
            
            var tempArrayName: [String] = []
            var tempArrayIsSelected: [Bool] = []
            
            var dayModel: DayModel
            
            for i in 0...(selectedDaysCodable.count - 1) {
                if selectedDaysCodable[i].name == "Sunday" {
                    tempArrayName.append("Sunday")
                } else if selectedDaysCodable[i].name == "Monday" {
                    tempArrayName.append("Monday")
                } else if selectedDaysCodable[i].name == "Tuesday" {
                    tempArrayName.append("Tuesday")
                } else if selectedDaysCodable[i].name == "Wednesday" {
                    tempArrayName.append("Wednesday")
                } else if selectedDaysCodable[i].name == "Thurday" {
                    tempArrayName.append("Thurday")
                } else if selectedDaysCodable[i].name == "Friday" {
                    tempArrayName.append("Friday")
                } else if selectedDaysCodable[i].name == "Saturday" {
                    tempArrayName.append("Saturday")
                }
            }
            
            for i in 0...6 {
                switch i {
                case 0:
                    if tempArrayName.contains("Sunday") {
                        tempArrayIsSelected.append(true)
                    } else {
                        tempArrayIsSelected.append(false)
                    }
                case 1:
                    if tempArrayName.contains("Monday") {
                        tempArrayIsSelected.append(true)
                    } else {
                        tempArrayIsSelected.append(false)
                    }
                case 2:
                    if tempArrayName.contains("Tuesday") {
                        tempArrayIsSelected.append(true)
                    } else {
                        tempArrayIsSelected.append(false)
                    }
                case 3:
                    if tempArrayName.contains("Wednesday") {
                        tempArrayIsSelected.append(true)
                    } else {
                        tempArrayIsSelected.append(false)
                    }
                case 4:
                    if tempArrayName.contains("Thurday") {
                        tempArrayIsSelected.append(true)
                    } else {
                        tempArrayIsSelected.append(false)
                    }
                case 5:
                    if tempArrayName.contains("Friday") {
                        tempArrayIsSelected.append(true)
                    } else {
                        tempArrayIsSelected.append(false)
                    }
                case 6:
                    if tempArrayName.contains("Saturday") {
                        tempArrayIsSelected.append(true)
                    } else {
                        tempArrayIsSelected.append(false)
                    }
                default:
                    break
                }
            }
            
            dayModel = DayModel(Sunday: tempArrayIsSelected[0], Monday: tempArrayIsSelected[1], Tuesday: tempArrayIsSelected[2], Wednesday: tempArrayIsSelected[3], Thursday: tempArrayIsSelected[4], Friday: tempArrayIsSelected[5], Saturday: tempArrayIsSelected[6])
            
            
            user.RecurringTransactions.append(RecurringTransactionModel(bankAccountName: bankSelection, amount: Double(amount) ?? 0.00, days: dayModel, startDay: Date.now, name: name))
            
            let _ = try Firestore.firestore().collection("ChildUsers").document(user.username).setData(from: user)
            
            isLoading = false
            
        } catch {
            isLoading = false
        }
    }
    
    func getAllBanks() async {
        Task {
            var user = try await Firestore.firestore().collection("ChildUsers").document(user.username).getDocument(as: ChildUser.self)
            
            for i in 0...(user.banks.count - 1) {
                AllBanksNames.append(user.banks[i].name)
            }
        }
    }
}

#Preview {
    ParentMain()
}
