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
    
    @State var AllBanksNames: [String] = []
    
    @State var DoubleDigit: String = ""
    
    @State var bank: Bank
    
    @State var showNeg: Bool = false
    
    @State var elapsed: Int = 0
    
    @State var positive_NEG_ARRAY: [Double] = []
    
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
    
    
    var body: some View {
        GeometryReader { proxy in
            
            ScrollView {
                
                Text("$\(bank.amount, specifier: "%.2f")")
                    .font(.title)
                
                
                if bank.amountHistoryAmount.count >= 2 {
                    VStack(alignment: .leading) {
                            
                        Text("Amount History")
                            .font(.title)
                            .fontWeight(.heavy)
                            .frame(alignment: .leading)
                            
                        ScrollViewReader { value in
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(Array(bank.amountHistoryAmount.enumerated()), id: \.offset) { i, val in
                                        BarView(colour: .mint, date: bank.amountHistoryDate[i], value: bank.amountHistoryAmount[i], proxy: proxy, highestVal: bank.amountHistoryAmount.max() ?? 0, total: bank.amountHistoryAmount.count)
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
                            .scrollIndicators(.hidden)
                            
                            
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
                
                
                
                if bank.transactionHistoryAmount.count > 0 {
                    
                    
                    VStack {
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
                                    
                                    //if posArray.count > 10 {
                                        
                                    ScrollViewReader { value in
                                        ScrollView(.horizontal) {
                                            HStack {
                                                ForEach(Array(posArray.enumerated()), id: \.offset) { i, val in
                                                    BarViewPos(colour: .green, value: posArray[i], proxy: (proxy.size.height / 1.5), highestVal: posArray.max() ?? 0, total: posArray.count)
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
                                        .scrollIndicators(.hidden)
                                        
                                        
                                    }
                                           
                                    
                                }
                                .padding()
                                .onAppear {
                                    
                                    if !bank.transactionHistoryAmount.isEmpty {
                                        
                                        Task {
                                            await loadArrays()
                                        }
                                        
                                    }
                                }
                                .task {
                                    if bank.transactionHistoryAmount != [] {
                                        Task {
                                            await loadArrays()
                                        }
                                    }
                                    
                                }
                                
                            }
                            
                            
                            if negArray.count >= 2 {
                                VStack(alignment: .leading) {
                                    
                                    if showNeg {
                                        Text("Subtract History")
                                            .font(.callout)
                                            .opacity(0.75)
                                            .frame(alignment: .leading)
                                        
                                        Text("Past 10")
                                            .font(.caption)
                                            .opacity(0.5)
                                            .frame(alignment: .leading)
                                        
                                        //                                        if negArray.count > 10 {
                                        
                                        
                                        ScrollViewReader { value in
                                            ScrollView(.horizontal) {
                                                HStack {
                                                    ForEach(Array(negArray.enumerated()), id: \.offset) { i, val in
                                                        //                                                        BarView(colour: .red, date: bank.transactionHistoryDate[i], value: -negArray[i], proxy: proxy, highestVal: 1000 , total: negArray.count)
                                                        //                                                            .frame(width: proxy.size.width / 5)
                                                        
                                                        BarViewNeg(colour: .red, value: negArray[i], proxy: (proxy.size.height / 1.5), highestVal: -positive_NEG_ARRAY.max()!, total: negArray.count)
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
                                            .scrollIndicators(.hidden)
                                            
                                            
                                        }
                                        
                                    }
                                    
                                }
                                .padding()
                                .task {
                                    var newarraytemp: [Double] = []
                                    
                                    for i in 0...(negArray.count - 1) {
                                        newarraytemp.append(-negArray[i])
                                    }
                                    
                                    await MainActor.run {
                                        positive_NEG_ARRAY = newarraytemp
                                    }
                                    
                                    showNeg = true
                                    
                                }
                                
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
                    
                    await loadArrays()
                }
                
            }
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
    ContentView()
}
