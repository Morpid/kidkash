//
//  BankDetails.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-28.
//

import SwiftUI
import Charts
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
import SDWebImageSwiftUI
import PhotosUI
import Algorithms
import SDWebImageSwiftUI

struct BankTransactionInfo: Identifiable, Equatable {
    var id = UUID()
    let amount: Double
    let date: Date
    let name: String
    let subtitle: String
}

struct BankDetails: View {
    
    @State var plotWidth: CGFloat = 0
    
    @State var AnnotationPos: AnnotationPosition = .top
    
    @State var expense_amount: String = ""
    
    @State var bank: Bank
    
    @State var usable_negative_array: [Double] = []
    
    @State var transaction_info: [BankTransactionInfo] = []
    
    @State var bankArray: Int
    @State var usernameChild: String
    
    @State var negArray: [Double] = []
    @State var posArray: [Double] = []
    
    @State var currentActiveItem: (amount: Double, date: Date, index: Int)?
    
    @State var isLoading: Bool = false
    
    @State var new_amount: Double = 0.00
    
    @State var show_expense_sheet: Bool = false
    @State var expense_type: String = "Expense"
    
    @State var showButton: Bool = false
    @State var Description: String = ""
    
    @State var profileImg: URL?
    
    @State var bankSelection1 = ""
    @State var bankSelection2 = ""
    
    @State var show_number_err_alert: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            
           
            
            if bank.transactionHistoryAmount.count > 0 {
                List {
                    
                    Section {
                            
                        VStack {
                            ZStack {
                                
                                HStack {
                                    
                                    Spacer()
                                    
                                    Text("$\(bank.amount, specifier: "%.2f")")
                                        .font(.title)
                                    
                                    
                                    Spacer()
                                }
                                .padding(.all, 20)
                                
                                
                            }
                            
                            
                            
                            AmountHistoryChart()
                            
                            HStack {
                                
                                VStack {
                                    
                                    Text("Amount History")
                                        .font(.caption)
                                        .bold()
                                        .foregroundStyle(.black)
                                    
                                    Text("Past 10 Changes")
                                        .font(.caption2)
                                        .foregroundStyle(.gray)
                                    
                                }
                                
                                
                                
                                Spacer()
                                
                                Divider()
                                    .padding(.vertical)
                                
                                Spacer()
                                
                                Text("Drag along chart to view amounts")
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                                
                                Image(systemName: "arrow.up")
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                            }
                        }
                        
                        
                    }
                    
//                    Section() {
//                        HStack {
//                            Text("Transactions")
//                                .font(.callout.bold())
//                                .foregroundStyle(.black)
//                            
//                            Text("Pull down to refresh \(Image(systemName: "arrow.down"))")
//                                .font(.caption2)
//                                .foregroundStyle(.gray)
//                        }
//                    }
                        
                        
                    
                        
                    Section() {
                        
                        HStack() {
                            Text("Transactions")
                                .font(.title3.bold())
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                            Text("Pull down to refresh \(Image(systemName: "arrow.down"))")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        .padding(.vertical, 10)
                            
                        ForEach(transaction_info) { transaction in
                            ExpenseCardView(title: transaction.name, sub_title: transaction.subtitle, date: transaction.date, amount: transaction.amount)
                        }
                            
                    }
                    
                        
                    
                }
                .frame(maxWidth: .infinity)
                .navigationTitle(bank.name)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            show_expense_sheet.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .onAppear {
                    Task {
                        await updateFirebaseBank()
                        
                        await loadArrays()
                    }
                    
                    
                    
                }
                .alert("Please enter a valid amount", isPresented: $show_number_err_alert) {
                    Button("OK", role: .none, action: {})
                }
                .sheet(isPresented: $show_expense_sheet) {
                    AddExpenseView(bankArray: bankArray, username: usernameChild, selectedExpenseType: expense_type, bank: $bank)
                }
                
            } else {
                ContentUnavailableView {
                    Label("Nothing Here Yet...", systemImage: "tray")
                }
                .frame(maxWidth: .infinity)
                .navigationTitle(bank.name)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            show_expense_sheet.toggle()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
                .onAppear {
                    Task {
                        await updateFirebaseBank()
                        
                        await loadArrays()
                    }
                    
                    
                    
                }
                .alert("Please enter a valid amount", isPresented: $show_number_err_alert) {
                    Button("OK", role: .none, action: {})
                }
                .sheet(isPresented: $show_expense_sheet) {
                    AddExpenseView(bankArray: bankArray, username: usernameChild, selectedExpenseType: expense_type, bank: $bank)
                }
            }
            
        }
        .overlay {
            LoadingView(show: $isLoading)
        }
        .preferredColorScheme(.light)
        .refreshable {
            
            Task {
                
                await updateFirebaseBank()
                
                await loadArrays()
                
                if bank.transactionHistoryAmount.count > 1 {
                    
                    var newarraytemp: [Double] = []
                    
                    if negArray.count >= 2 {
                        for i in 0...(negArray.count - 1) {
                            newarraytemp.append(-negArray[i])
                        }
                    }
                    
                    
                    await MainActor.run {
                        usable_negative_array = newarraytemp
                    }
                }
                
                
                
            }
            
        }
        
    }
    
//    func transactionsByMonth() -> [[BankTransactionInfo]] {
//        guard !
//    }
    
    func checkNumeric(S: String) -> Bool {
       return Double(S) != nil
    }
    
    func loadArrays() async {
        
        Task {
            
            var user = try await Firestore.firestore().collection("ChildUsers").document(usernameChild).getDocument(as: ChildUser.self)
            
            var tempNegArray: [Double] = []
            var tempPosArray: [Double] = []
            
            if user.banks[bankArray].transactionHistoryAmount.count > 0 {
                for i in 0...(user.banks[bankArray].transactionHistoryAmount.count - 1) {
                    if user.banks[bankArray].transactionHistoryAmount[i].sign == .minus {
                        tempNegArray.append(user.banks[bankArray].transactionHistoryAmount[i])
                    } else {
                        tempPosArray.append(user.banks[bankArray].transactionHistoryAmount[i])
                    }
                }
                
                if negArray != tempNegArray {
                    withAnimation {
                        negArray = tempNegArray
                    }
                }
                
                if posArray != tempPosArray {
                    withAnimation {
                        posArray = tempPosArray
                    }
                }
                
                
                
            }
            
            
            
        }
    
    }
    
    @ViewBuilder
    func AmountHistoryChart() -> some View {
        let max = bank.amountHistoryAmount.max()
        
        if bank.amountHistoryAmount.count >= 2 {
            VStack(alignment: .leading) {
                
                if bank.amountHistoryAmount.count > 10 {
                    Chart {
                        ForEach(Array(bank.amountHistoryAmount[(bank.amountHistoryAmount.count - 11)...(bank.amountHistoryAmount.count - 1)].enumerated()), id: \.offset) { index, value in
                            LineMark(
                                x: .value("Index", index),
                                y: .value("Value", value)
                            )
                            .foregroundStyle(.mint.gradient)
                            
                            AreaMark(
                                x: .value("Index", index),
                                y: .value("Value", value)
                            )
                            .foregroundStyle(.mint.gradient.opacity(0.2))
                            
                            if bank.amountHistoryAmount[(bank.amountHistoryAmount.count - 1)] > bank.amountHistoryAmount[(bank.amountHistoryAmount.count - 2)] {
                                
                                PointMark(
                                    x: .value("Index", 10),
                                    y: .value("Value", bank.amountHistoryAmount[(bank.amountHistoryAmount.count - 1)])
                                )
                                .foregroundStyle(.green)
                                .annotation(position: .top) {
                                    Text("now")
                                        .font(.caption2)
                                        .foregroundStyle(.gray)
                                }
                            } else {
                                PointMark(
                                    x: .value("Index", 10),
                                    y: .value("Value", bank.amountHistoryAmount[(bank.amountHistoryAmount.count - 1)])
                                )
                                .foregroundStyle(.green)
                                .annotation(position: .bottom) {
                                    Text("now")
                                        .font(.caption2)
                                        .foregroundStyle(.gray)
                                }
                            }
                            
                            if let currentActiveItem, currentActiveItem.index == index {
                                RuleMark (
                                    x: .value("Index", currentActiveItem.index)
                                )
                                .foregroundStyle(.green)
                                .annotation(position: AnnotationPos) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("$\(currentActiveItem.amount, specifier: "%.2f")")
                                            .font(.callout.bold())
                                            .foregroundStyle(.black)
                                        
                                        
                                        Text("\(currentActiveItem.date, format: .dateTime.day().month().year())")
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                        
                                        Text("\(currentActiveItem.date, format: .dateTime.hour().minute())")
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                        
//                                                                Text("\(currentActiveItem.date, format: .dateTime.day().minute())")
//                                                                    .font(.title3)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background {
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(.white.shadow(.drop(radius: 2
                                                                        )))
                                    }
                                }
                            }
                            
                        }
                    }
                    .frame(height: 150)
                    .chartYScale(domain: 0...(max!))
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .chartXScale(domain: 0...10)
                    .chartOverlay { proxy in
                        GeometryReader { innerProxy in
                            Rectangle()
                                .fill(.clear).contentShape(Rectangle())
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let location = value.location
                                            
                                            if let index_value: Int = proxy.value(atX: location.x) {
                                                if index_value <= 10 && index_value >= 0 {
                                                    
                                                    if index_value == 0 {
                                                        AnnotationPos = .topTrailing
                                                    } else if index_value == 10 {
                                                        AnnotationPos = .topLeading
                                                    } else {
                                                        AnnotationPos = .top
                                                    }
                                                    
                                                    self.currentActiveItem = (amount: bank.amountHistoryAmount[((bank.amountHistoryAmount.count - 11) + index_value)], date: bank.amountHistoryDate[((bank.amountHistoryDate.count - 11) + index_value)], index: index_value)
                                                    
                                                    self.plotWidth = proxy.plotSize.width
                                                }
                                            }
                                        }.onEnded({ value in
                                            self.currentActiveItem = nil
                                        })
                                )
                        }
                    }
                    
                } else {
                    Chart {
                        ForEach(Array(bank.amountHistoryAmount.enumerated()), id: \.offset) { index, value in
                            LineMark(
                                x: .value("Index", index),
                                y: .value("Value", value)
                            )
                            .foregroundStyle(.mint.gradient)
                            
                            AreaMark(
                                x: .value("Index", index),
                                y: .value("Value", value)
                            )
                            .foregroundStyle(.mint.gradient.opacity(0.2))
                            
                            if bank.amountHistoryAmount[(bank.amountHistoryAmount.count - 1)] > bank.amountHistoryAmount[(bank.amountHistoryAmount.count - 2)] {
                                
                                PointMark(
                                    x: .value("Index", (bank.amountHistoryAmount.count - 1)),
                                    y: .value("Value", bank.amountHistoryAmount[(bank.amountHistoryAmount.count - 1)])
                                )
                                .foregroundStyle(.green)
                                .annotation(position: .top) {
                                    Text("now")
                                        .font(.caption2)
                                        .foregroundStyle(.gray)
                                }
                                
                            } else {
                                PointMark(
                                    x: .value("Index", (bank.amountHistoryAmount.count - 1)),
                                    y: .value("Value", bank.amountHistoryAmount[(bank.amountHistoryAmount.count - 1)])
                                )
                                .foregroundStyle(.green)
                                .annotation(position: .bottom) {
                                    Text("now")
                                        .font(.caption2)
                                        .foregroundStyle(.gray)
                                }
                            }
                            
                            if let currentActiveItem, currentActiveItem.index == index {
                                RuleMark (
                                    x: .value("Index", currentActiveItem.index)
                                )
                                .foregroundStyle(.green)
                                .annotation(position: AnnotationPos) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("$\(currentActiveItem.amount, specifier: "%.2f")")
                                            .font(.callout.bold())
                                            .foregroundStyle(.black)
                                        
                                        
                                        Text("\(currentActiveItem.date, format: .dateTime.day().month().year())")
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                        
                                        Text("\(currentActiveItem.date, format: .dateTime.hour().minute())")
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                        
//                                                                Text("\(currentActiveItem.date, format: .dateTime.day().minute())")
//                                                                    .font(.title3)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background {
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(.white.shadow(.drop(radius: 2
                                                                        )))
                                    }
                                }
                            }
                            
                        }
                    }
                    .frame(height: 150)
                    .chartYScale(domain: 0...(max!))
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .chartXScale(domain: 0...(bank.amountHistoryAmount.count - 1))
                    .chartOverlay { proxy in
                        GeometryReader { innerProxy in
                            Rectangle()
                                .fill(.clear).contentShape(Rectangle())
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let location = value.location
                                            
                                            if let index_value: Int = proxy.value(atX: location.x) {
                                                if index_value <= (bank.amountHistoryAmount.count - 1) && index_value >= 0 {
                                                    
                                                    if index_value == 0 {
                                                        AnnotationPos = .topTrailing
                                                    } else if index_value == (bank.amountHistoryAmount.count - 1) {
                                                        AnnotationPos = .topLeading
                                                    } else {
                                                        AnnotationPos = .top
                                                    }
                                                    
                                                    self.currentActiveItem = (amount: bank.amountHistoryAmount[index_value], date: bank.amountHistoryDate[index_value], index: index_value)
                                                    self.plotWidth = proxy.plotSize.width
                                                }
                                            }
                                        }.onEnded({ value in
                                            self.currentActiveItem = nil
                                        })
                                )
                        }
                    }
                }
                
                
            }
            .padding()
            .task {
                if bank.transactionHistoryAmount != [] {
                    Task {
                        await loadArrays()
                    }
                }
                                    
            }
                                
        }
    }
    
    
    func updateFirebaseBank() async {
        
        
        Task {
            var user = try await Firestore.firestore().collection("ChildUsers").document(usernameChild).getDocument(as: ChildUser.self)
            
            var temp_transaction_info: [BankTransactionInfo] = []
            
            let count = user.banks[bankArray].transactionHistoryAmount.count
            
            if !user.banks[bankArray].transactionHistoryAmount.isEmpty {
                
                let nameReverse: [String] = user.banks[bankArray].transactionHistoryName.reversed()
                let amountReverse: [Double] = user.banks[bankArray].transactionHistoryAmount.reversed()
                let dateReverse: [Date] = user.banks[bankArray].transactionHistoryDate.reversed()
                let subTitleReverse: [String] = user.banks[bankArray].transactionHistorySubTitle.reversed()
                
                for i in 0...(nameReverse.count - 1) {
                    temp_transaction_info.append(BankTransactionInfo(amount: amountReverse[i], date: dateReverse[i], name: nameReverse[i], subtitle: subTitleReverse[i]))
                }
                
            }

            await MainActor.run { [user, temp_transaction_info] in
                withAnimation {
                    bank = user.banks[bankArray]
                    
                    if temp_transaction_info != transaction_info {
                        transaction_info = temp_transaction_info
                    }
                }
            }
              
        }
    }
    
    
    
    
}

#Preview {
    ParentMain()
}


