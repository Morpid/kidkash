//
//  BankDetailsChild.swift
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


struct BankDetailsChild: View {
    
    @Namespace var trailingID
    
    @Namespace var animation
    
    @State var AllBanksNames: [String] = []
    
    @State var DoubleDigit: String = ""
    
    @State var bank: Bank
    
    @State var showNeg: Bool = false
    
    @State var elapsed: Int = 0
    
    @State var positive_NEG_ARRAY: [Double] = []
    
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
    
    @State var loading: Bool = false
    
    @State var isDoneLoadingArrays: Bool = false
    
    @State var newAmount: Double = 0.00
    
    @State var AddTextFieldFirstDigit: String = ""
    @State var AddTextFieldSecondDigit: String = ""
    
    @State var SubtractTextFieldFirstDigit: String = ""
    @State var SubtractTextFieldSecondDigit: String = ""
    
    @State var showSheet0: Bool = false
    @State var showSheet1: Bool = false
    @State var showSheet2: Bool = false
    
    @State var showButton: Bool = false
    @State var EditReason: String = ""
    
    @State var bankSelection1 = "Savings"
    @State var bankSelection2 = "Savings"
    
    var body: some View {
        if !loading {
            GeometryReader { proxy in
                
                VStack {
                    
                    Spacer()
                        .frame(height: 100)
                    
                    HStack {
                        
                        Text("\(bank.name)")
                            .font(.title)
                            .bold()
                        
                        Text("$\(bank.amount, specifier: "%.2f")")
                            .font(.title)
                    }
                    
                    
                    
                    
                    
                    ZStack {
                        
                        Rectangle()
                            .cornerRadius(radius: 50, corners: [.topLeft, .topRight])
                            .foregroundStyle(.ultraThinMaterial)
                            .ignoresSafeArea(edges: [.bottom])
                        
                        VStack {
                            
                            
                            ScrollView {
                                
                                
                                
                                if bank.amountHistoryAmount.count >= 2 {
                                    VStack(alignment: .leading) {
                                        
                                        Text("Amount History")
                                            .font(.title)
                                            .fontWeight(.heavy)
                                            .frame(alignment: .leading)
                                        
                                        Text("Past 10 Changes")
                                            .font(.callout)
                                            .opacity(0.75)
                                            .frame(alignment: .leading)
                                        
                                        if bank.amountHistoryAmount.count > 10 {
                                            Chart {
                                                ForEach(Array(bank.amountHistoryAmount[(bank.amountHistoryAmount.count - 11)...(bank.amountHistoryAmount.count - 1)].enumerated()), id: \.offset) { index, value in
                                                    LineMark(
                                                        x: .value("Index", index),
                                                        y: .value("Value", value)
                                                    )
                                                    .foregroundStyle(.mint.gradient)
                                                    
                                                    
                                                }
                                            }
                                            .frame(height: proxy.size.height / 3)
                                            
                                        } else {
                                            Chart {
                                                ForEach(Array(bank.amountHistoryAmount.enumerated()), id: \.offset) { index, value in
                                                    LineMark(
                                                        x: .value("Index", index),
                                                        y: .value("Value", value)
                                                    )
                                                    .foregroundStyle(.mint.gradient)
                                                    
                                                }
                                            }
                                            .frame(height: proxy.size.height / 3)
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
                                
                                if bank.transactionHistoryAmount.count >= 2 {
                                    
                                    if posArray.count >= 2 {
                                        VStack(alignment: .leading) {
                                            
                                            Text("Add History")
                                                .font(.title)
                                                .fontWeight(.heavy)
                                                .frame(alignment: .leading)
                                            
                                            Text("Past 10 Changes")
                                                .font(.callout)
                                                .opacity(0.75)
                                                .frame(alignment: .leading)
                                            
                                            if posArray.count > 10 {
                                                
                                                
                                                Chart {
                                                    ForEach(Array(posArray[(posArray.count - 11)...(posArray.count - 1)].enumerated()), id: \.offset) { index, value in
                                                        BarMark(
                                                            x: .value("Index", index),
                                                            y: .value("Value", value)
                                                        )
                                                        .foregroundStyle(.green.gradient)
                                                        
                                                    }
                                                    
                                                }
                                                .frame(height: proxy.size.height / 4)
                                                .chartXAxis(.hidden)
                                                
                                            } else {
                                                Chart {
                                                    ForEach(Array(posArray.enumerated()), id: \.offset) { index, value in
                                                        BarMark(
                                                            x: .value("Index", index),
                                                            y: .value("Value", value)
                                                        )
                                                        .foregroundStyle(.green.gradient)
                                                        
                                                    }
                                                }
                                                .frame(height: proxy.size.height / 4)
                                                .chartXAxis(.hidden)
                                            }
                                            
                                            
                                        }
                                        .padding()
                                        
                                        
                                    }
                                    
                                    
                                    if negArray.count >= 2 {
                                        VStack(alignment: .leading) {
                                            
                                            Text("Subtract History")
                                                .font(.title)
                                                .fontWeight(.heavy)
                                                .frame(alignment: .leading)
                                            
                                            Text("Past 10 Changes")
                                                .font(.callout)
                                                .opacity(0.75)
                                                .frame(alignment: .leading)
                                            
                                            if negArray.count > 10 {
                                                
                                                
                                                Chart {
                                                    ForEach(Array(negArray[(negArray.count - 11)...(negArray.count - 1)].enumerated()), id: \.offset) { index, value in
                                                        BarMark(
                                                            x: .value("Index", index),
                                                            y: .value("Value", value)
                                                        )
                                                        .foregroundStyle(.red.gradient)
                                                        
                                                        //                                            AreaMark(
                                                        //                                                x: .value("Index", index),
                                                        //                                                y: .value("Value", value)
                                                        //                                            )
                                                        //                                            .foregroundStyle(.red.opacity(0.2).gradient)
                                                    }
                                                }
                                                .frame(height: proxy.size.height / 4)
                                                .chartXAxis(.hidden)
                                                
                                            } else {
                                                Chart {
                                                    ForEach(Array(negArray.enumerated()), id: \.offset) { index, value in
                                                        BarMark(
                                                            x: .value("Index", index),
                                                            y: .value("Value", value)
                                                        )
                                                        .foregroundStyle(.red.gradient)
                                                        
                                                        //                                            AreaMark(
                                                        //                                                x: .value("Index", index),
                                                        //                                                y: .value("Value", value)
                                                        //                                            )
                                                        //                                            .foregroundStyle(.red.opacity(0.2).gradient)
                                                    }
                                                }
                                                .frame(height: proxy.size.height / 4)
                                                .chartXAxis(.hidden)
                                                
                                            }
                                            
                                            
                                        }
                                        .padding()
                                        
                                    }
                                    
                                    
                                    
                                }
                                
                                if bank.transactionHistoryAmount.count > 0 {
                                    VStack(alignment: .leading) {
                                        Text("Transaction History")
                                            .font(.title)
                                            .fontWeight(.heavy)
                                            .frame(alignment: .leading)
                                        
                                        Divider()
                                        
                                        ForEach(0..<bank.transactionHistoryAmount.count) { i in
                                            
                                            HStack {
                                                Text("\(bank.transactionHistoryName[(bank.transactionHistoryAmount.count - (i + 1))])")
                                                    .bold()
                                                
                                                Spacer()
                                                
                                                Text(bank.transactionHistoryDate[(bank.transactionHistoryAmount.count - (i + 1))], format: .dateTime.day().month().year())
                                                
                                                Text("\(bank.transactionHistoryAmount[(bank.transactionHistoryAmount.count - (i + 1))], specifier: "%.2f")")
                                                    .bold()
                                                
                                            }
                                            .padding()
                                            
                                            Divider()
                                        }
                                    }
                                }
                                
                                
                                
                            }
                            .padding()
                            
                        }
                        
                        
                    }
                    
                }
                .frame(maxWidth: .infinity)
                .navigationTitle(bank.name)
                .background(LinearGradient(colors: [.mint.opacity(0.25), .gray], startPoint: .topTrailing, endPoint: .bottomLeading))
                .onAppear {
                    Task {
                        await updateFirebaseBank()
                        
                        await loadArrays()
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
                        
                        for i in 0...(negArray.count - 1) {
                            newarraytemp.append(-negArray[i])
                        }
                        
                        await MainActor.run {
                            positive_NEG_ARRAY = newarraytemp
                        }
                    }
                    
                    
                    
                }
                
            }
        }
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
    
        
        isDoneLoadingArrays = true
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
                let subTitleReverse: [String] = user.banks[bankArray].transactionHistorySubTitle.reversed()
                
                for i in 0...(nameReverse.count - 1) {
                    tempTransactionInfo.append(BankTransactionInfo(amount: amountReverse[i], date: dateReverse[i], name: nameReverse[i], subtitle: subTitleReverse[i]))
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
    ContentView()
}
