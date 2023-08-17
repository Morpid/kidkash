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

struct BankTransactionInfo: Hashable {
    let amount: Double
    let date: Date
    let name: String
}

struct BankDetails: View {
    
    @Namespace var trailingID
    
    @State var bank: Bank
    
    @State var elapsed: Int = 0
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    @State var refreshChart: Bool = false
    
    @State var bankHistoryAmount: [Double] = []
    
    @State var TransactionInfo: [BankTransactionInfo] = []
    
    @State var bankArray: Int
    @State var usernameChild: String
    
    @State var negArray: [Double] = []
    @State var posArray: [Double] = []
    
    @State var negArrayDates: [Date] = []
    @State var posArrayDates: [Date] = []
    
    @State var isLoading: Bool = false
    
    @State var isDoneLoadingArrays: Bool = false
    
    @State var newAmount: Double = 0.00
    
    @State var AddTextFieldFirstDigit: String = ""
    @State var AddTextFieldSecondDigit: String = ""
    
    @State var SubtractTextFieldFirstDigit: String = ""
    @State var SubtractTextFieldSecondDigit: String = ""
    
    @State var showSheet0: Bool = false
    @State var showSheet1: Bool = false
    @State var showSheet2: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            
            ScrollView {
                
                Text("$\(bank.amount, specifier: "%.2f")")
                    .font(.title)
                
                HStack {
                    Button {
                        showSheet0.toggle()
                    } label: {
                        ZStack {
                            
                            Circle()
                                .foregroundStyle(.green.opacity(0.2).gradient)
                                .frame(width: 50)
                            
                            Image(systemName: "plus")
                                .foregroundStyle(.green)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    
                    Button {
                        showSheet1.toggle()
                    } label: {
                        ZStack {
                            
                            Circle()
                                .foregroundStyle(.red.opacity(0.2).gradient)
                                .frame(width: 50)
                            
                            Image(systemName: "minus")
                                .foregroundStyle(.red)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    
                    Button {
                        showSheet2.toggle()
                    } label: {
                        ZStack {
                            
                            Circle()
                                .foregroundStyle(.yellow.opacity(0.2).gradient)
                                .frame(width: 50)
                            
                            Image(systemName: "arrow.left.arrow.right")
                                .foregroundStyle(.yellow)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                }
                
                if bank.amountHistoryAmount.count >= 2 {
                    VStack(alignment: .leading) {
                        if !refreshChart {
                            
                            Text("Amount History")
                                .font(.title)
                                .fontWeight(.heavy)
                                .frame(alignment: .leading)
                            
                            ScrollViewReader { value in
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(0..<bank.amountHistoryAmount.count) { i in
                                            BarView(date: bank.amountHistoryDate[i], value: bank.amountHistoryAmount[i], proxy: proxy, highestVal: bank.amountHistoryAmount.max() ?? 0, total: bank.amountHistoryAmount.count)
                                                .frame(width: proxy.size.width / 5)
                                        }
                                        
                                        
                                        Text("")
                                            .id(trailingID)
                                            
                                    }
                                    .task {
                                        withAnimation {
                                            value.scrollTo(trailingID)
                                        }
                                    }
                                }
                                .frame(height: proxy.size.height / 2)
                                .scrollIndicators(.hidden)
                                
                                
                            }
                        }
                        
                    }
                    .padding()
                    .task {
                        if bank.transactionHistoryAmount != [] {
                            loadArrays()
                        }
                        
                    }
                    .onChange(of: bank.amountHistoryAmount) { oldValue, newValue in
                        refreshChart = true
                        refreshChart = false
                    }
                }
            
                
                
                if bank.transactionHistoryAmount.count > 0 {
                   
                    
                    HStack {
                        if bank.transactionHistoryAmount.count >= 2 {
                            
                            if posArray.count >= 2 {
                                VStack(alignment: .leading) {
                                    Text("Add History")
                                        .font(.callout)
                                        .opacity(0.75)
                                        .frame(alignment: .leading)
                                    
                                    Text("Past 10")
                                        .font(.caption)
                                        .opacity(0.5)
                                        .frame(alignment: .leading)
                                    
                                    if posArray.count > 10 {
                                        
                                        
                                        Chart {
                                            ForEach(Array(posArray[(posArray.count - 11)...(posArray.count - 1)].enumerated()), id: \.offset) { index, value in
                                                LineMark(
                                                    x: .value("Index", index),
                                                    y: .value("Value", value)
                                                )
                                                .foregroundStyle(.green.gradient)
                                                .lineStyle(.init(lineWidth: 3))
                                                
                                                AreaMark(
                                                    x: .value("Index", index),
                                                    y: .value("Value", value)
                                                )
                                                .foregroundStyle(.green.gradient)
                                            }
                                        }
                                        .chartXAxis(.hidden)
                                        
                                    } else {
                                        Chart {
                                            ForEach(Array(posArray.enumerated()), id: \.offset) { index, value in
                                                LineMark(
                                                    x: .value("Index", index),
                                                    y: .value("Value", value)
                                                )
                                                .foregroundStyle(.green.gradient)
                                                .lineStyle(.init(lineWidth: 3))
                                                
                                                AreaMark(
                                                    x: .value("Index", index),
                                                    y: .value("Value", value)
                                                )
                                                .foregroundStyle(.green.gradient)
                                            }
                                        }
                                        .chartXAxis(.hidden)
                                    }
                                    
                                    
                                }
                                .padding()
                                .onAppear {
                                    
                                    if !bank.transactionHistoryAmount.isEmpty {
                                        
                                        loadArrays()
                                        
                                    }
                                }
                                
                            }
                            
                            
                            if negArray.count >= 2 {
                                VStack(alignment: .leading) {
                                    Text("Subtract History")
                                        .font(.callout)
                                        .opacity(0.75)
                                        .frame(alignment: .leading)
                                    
                                    Text("Past 10")
                                        .font(.caption)
                                        .opacity(0.5)
                                        .frame(alignment: .leading)
                                    
                                    if negArray.count > 10 {
                                        
                                        
                                        Chart {
                                            ForEach(Array(negArray[(negArray.count - 11)...(negArray.count - 1)].enumerated()), id: \.offset) { index, value in
                                                LineMark(
                                                    x: .value("Index", index),
                                                    y: .value("Value", value)
                                                )
                                                .foregroundStyle(.red.gradient)
                                                .lineStyle(.init(lineWidth: 3))
                                                
                                                AreaMark(
                                                    x: .value("Index", index),
                                                    y: .value("Value", value)
                                                )
                                                .foregroundStyle(.red.gradient)
                                            }
                                        }
                                        .chartXAxis(.hidden)
                                        
                                    } else {
                                        Chart {
                                            ForEach(Array(negArray.enumerated()), id: \.offset) { index, value in
                                                LineMark(
                                                    x: .value("Index", index),
                                                    y: .value("Value", value)
                                                )
                                                .foregroundStyle(.red.gradient)
                                                .lineStyle(.init(lineWidth: 3))
                                                
                                                AreaMark(
                                                    x: .value("Index", index),
                                                    y: .value("Value", value)
                                                )
                                                .foregroundStyle(.red.gradient)
                                            }
                                        }
                                        .chartXAxis(.hidden)
                                        
                                    }
                                    
                                    
                                }
                                .padding()
                                
                            }
                            
                        }
                    }
                    
                    Divider()
                    
                    if !TransactionInfo.isEmpty {
                        
                        ForEach(TransactionInfo, id: \.self) { info in
                            VStack {
                                HStack {
                                    Text(info.name)
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Text(info.date, format: .dateTime.day().month().year().hour().minute())
                                        .opacity(0.75)
                                    
                                    Text(String(info.amount))
                                        .bold()
                                }
                                .padding()
                                
                                Divider()
                            }
                        }
                        
                    }
                    
                    
                }
                
            }
            .frame(maxWidth: .infinity)
            .navigationTitle(bank.name)
            .background(.black.opacity(0.05))
            .refreshable {
                Task {
                    await updateFirebaseBank()
                }
                
                loadArrays()
            }
            .onAppear {
                Task {
                    await updateFirebaseBank()
                }
                
                loadArrays()
            }
            .sheet(isPresented: $showSheet0) {
                BankAmountEditSheetView(editTypeSelection: 0, bankArray: bankArray, bank: $bank, usernameChild: usernameChild)
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showSheet1) {
                BankAmountEditSheetView(editTypeSelection: 1, bankArray: bankArray, bank: $bank, usernameChild: usernameChild)
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showSheet2) {
                BankAmountEditSheetView(editTypeSelection: 2, bankArray: bankArray, bank: $bank, usernameChild: usernameChild)
                    .interactiveDismissDisabled()
            }
            
        }
        .overlay {
            LoadingView(show: $isLoading)
        }
        .preferredColorScheme(.light)
    }
    
    func loadArrays() {
        
        Task {
            
            var tempNegArray: [Double] = []
            var tempPosArray: [Double] = []
            
            if bank.transactionHistoryAmount.count > 0 {
                for i in 0...(bank.transactionHistoryAmount.count - 1) {
                    if bank.transactionHistoryAmount[i].sign == .minus {
                        tempNegArray.append(bank.transactionHistoryAmount[i])
                    } else {
                        tempPosArray.append(bank.transactionHistoryAmount[i])
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
    
        
        isDoneLoadingArrays = true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        UserDefaults.standard.set(Date(), forKey: "LastOpened")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        guard let lastOpened = UserDefaults.standard.object(forKey: "LastOpened") as? Date else { return }
        
        let elapsed = Calendar.current.dateComponents([.second], from: lastOpened, to: Date())
        
        self.elapsed = elapsed.second!
    }
    
    func updateFirebaseBank() async {
        
        
        Task {
            var user = try await Firestore.firestore().collection("ChildUsers").document(usernameChild).getDocument(as: ChildUser.self)
            
            var tempTransactionInfo: [BankTransactionInfo] = []
            
            let count = user.banks[bankArray].transactionHistoryAmount.count
            
            if !user.banks[bankArray].transactionHistoryAmount.isEmpty {
                
                let nameReverse: [String] = user.banks[bankArray].transactionHistoryName.reversed()
                let amountReverse: [Double] = user.banks[bankArray].transactionHistoryAmount.reversed()
                let dateReverse: [Date] = user.banks[bankArray].transactionHistoryDate.reversed()
                
                for i in 0...(nameReverse.count - 1) {
                    tempTransactionInfo.append(BankTransactionInfo(amount: amountReverse[i], date: dateReverse[i], name: nameReverse[i]))
                }
                
            }

            await MainActor.run { [user, tempTransactionInfo] in
                withAnimation {
                    bank = user.banks[bankArray]
                    
                    if tempTransactionInfo != TransactionInfo {
                        TransactionInfo = tempTransactionInfo
                    }
                }
            }
              
        }
    }
}

#Preview {
    ParentMain()
}
