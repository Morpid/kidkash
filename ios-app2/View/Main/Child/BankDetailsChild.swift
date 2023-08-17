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
    
    @State var bank: Bank
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    @State var bankHistoryAmount: [Double] = []
    
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
    
    
    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                ScrollView {
                    
                    Text("$\(bank.amount, specifier: "%.2f")")
                        .font(.title)
                    
                    
                    
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
                                        
                                        AreaMark(
                                            x: .value("Index", index),
                                            y: .value("Value", value)
                                        )
                                        .foregroundStyle(.mint.opacity(0.2).gradient)
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
                                        
                                        AreaMark(
                                            x: .value("Index", index),
                                            y: .value("Value", value)
                                        )
                                        .foregroundStyle(.mint.opacity(0.2).gradient)
                                    }
                                }
                                .frame(height: proxy.size.height / 3)
                            }
                            
                            
                            
                            
                        }
                        .padding()
                        .task {
                            if bank.transactionHistoryAmount != [] {
                                loadArrays()
                            }
                            
                        }
                    }
                    
                    if bank.transactionHistoryAmount.count > 0 {
                        
                        if bank.transactionHistoryAmount.count >= 6 {
                            
                            Divider()
                            
                            ForEach(0..<6) { i in
                                HStack {
                                    
                                    Text(String(bank.transactionHistoryName[(bank.transactionHistoryAmount.count - (i + 1))]))
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Text(bank.transactionHistoryDate[(bank.transactionHistoryAmount.count - (i + 1))], format: .dateTime.day().month().year())
                                        .opacity(0.5)
                                    
                                    Text(String(bank.transactionHistoryAmount[(bank.transactionHistoryAmount.count - (i + 1))]))
                                        .bold()
                                }
                                .padding()
                                
                                Divider()
                                
                            }
                        } else {
                            Divider()
                            
                            ForEach(0..<bank.transactionHistoryAmount.count) { i in
                                HStack {
                                    
                                    Text(String(bank.transactionHistoryName[(bank.transactionHistoryAmount.count - (i + 1))]))
                                    
                                    Spacer()
                                    
                                    Text(bank.transactionHistoryDate[(bank.transactionHistoryAmount.count - (i + 1))], format: .dateTime.day().month().year())
                                        .opacity(0.75)
                                    
                                    Spacer()
                                    
                                    Text(String(bank.transactionHistoryAmount[i]))
                                }
                                .padding()
                                
                                Divider()
                                
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
                                            LineMark(
                                                x: .value("Index", index),
                                                y: .value("Value", value)
                                            )
                                            .foregroundStyle(.green.gradient)
                                            .interpolationMethod(.catmullRom)
                                            
                                            AreaMark(
                                                x: .value("Index", index),
                                                y: .value("Value", value)
                                            )
                                            .foregroundStyle(.green.opacity(0.2).gradient)
                                            .interpolationMethod(.catmullRom)
                                        }
                                    }
                                    .frame(height: proxy.size.height / 4)
                                    
                                } else {
                                    Chart {
                                        ForEach(Array(posArray.enumerated()), id: \.offset) { index, value in
                                            LineMark(
                                                x: .value("Index", index),
                                                y: .value("Value", value)
                                            )
                                            .foregroundStyle(.green.gradient)
                                            .interpolationMethod(.catmullRom)
                                            
                                            AreaMark(
                                                x: .value("Index", index),
                                                y: .value("Value", value)
                                            )
                                            .foregroundStyle(.green.opacity(0.2).gradient)
                                            .interpolationMethod(.catmullRom)
                                        }
                                    }
                                    .frame(height: proxy.size.height / 4)
                                }
                                
                                
                            }
                            .padding()
                            .onReceive(timer) { input in
                                
                                if !bank.transactionHistoryAmount.isEmpty {
                                    
                                    loadArrays()
                                    
                                }
                            }
                            
                        }
                        
                        Divider()
                        
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
                                            LineMark(
                                                x: .value("Index", index),
                                                y: .value("Value", value)
                                            )
                                            .foregroundStyle(.red.gradient)
                                            
                                            AreaMark(
                                                x: .value("Index", index),
                                                y: .value("Value", value)
                                            )
                                            .foregroundStyle(.red.opacity(0.2).gradient)
                                        }
                                    }
                                    .frame(height: proxy.size.height / 4)
                                    
                                } else {
                                    Chart {
                                        ForEach(Array(negArray.enumerated()), id: \.offset) { index, value in
                                            LineMark(
                                                x: .value("Index", index),
                                                y: .value("Value", value)
                                            )
                                            .foregroundStyle(.red.gradient)
                                            
                                            AreaMark(
                                                x: .value("Index", index),
                                                y: .value("Value", value)
                                            )
                                            .foregroundStyle(.red.opacity(0.2).gradient)
                                        }
                                    }
                                    .frame(height: proxy.size.height / 4)
                                    
                                }
                                
                                
                            }
                            .padding()
                            .onReceive(timer) { input in
                                
                                if !bank.transactionHistoryAmount.isEmpty {
                                    
                                    loadArrays()
                                    
                                }
                            }
                        }
                        
                    }
                    
                    
                    
                    
                    
                    
                }
                .frame(maxWidth: .infinity)
                .navigationTitle(bank.name)
                .background(.black.opacity(0.05))
                .onReceive(timer) { input in
                    
                    Task {
                        await updateFirebaseBank()
                    }
                    
                    loadArrays()
                }
            }
            
        }
        .overlay {
            LoadingView(show: $isLoading)
        }
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
    

    
    func updateFirebaseBank() async {
        
        
        Task {
            var user = try await Firestore.firestore().collection("ChildUsers").document(usernameChild).getDocument(as: ChildUser.self)
            
            withAnimation {
                bank = user.banks[bankArray]
            }
              
        }
    }
}

#Preview {
    ContentView()
}
