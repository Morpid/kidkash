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
                
                ScrollView {
                    
                    Text("$\(bank.amount, specifier: "%.2f")")
                        .font(.title)
                    
                    HStack {
                        Button {
                            withAnimation(.linear(duration: 0.1)) {
                                showSheet2 = false
                                showSheet1 = false
                                showSheet0 = true
                            }
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
                            withAnimation(.linear(duration: 0.1)) {
                                showSheet2 = false
                                showSheet1 = true
                                showSheet0 = false
                            }
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
                            withAnimation(.linear(duration: 0.1)) {
                                showSheet2 = true
                                showSheet1 = false
                                showSheet0 = false
                            }
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
                    
                    if showSheet0 {
                        
                            
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
                                
                                Task {
                                    await MainActor.run {
                                        //loading = true
                                    }
                                }
                                
                                withAnimation { showSheet0 = false }
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
                                        await MainActor.run {
                                            //loading = true
                                        }
                                    }
                                    withAnimation { showSheet0 = false }
                                } label: {
                                    Image(systemName: "arrow.forward")
                                        .foregroundStyle(.green)
                                        .bold()
                                        .padding(.horizontal, 50)
                                        .border(1, .black)
                                }
                                
                            }
                        
                    } else if showSheet1 {
                        
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
                                Task {
                                    await MainActor.run {
                                        //loading = true
                                    }
                                }
                                withAnimation { showSheet1 = false }
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
                                        await MainActor.run {
                                            //loading = true
                                        }
                                    }
                                    withAnimation { showSheet1 = false }
                                } label: {
                                    Image(systemName: "arrow.forward")
                                        .foregroundStyle(.green)
                                        .bold()
                                        .padding(.horizontal, 50)
                                        .border(1, .black)
                                }
                                
                            }
                        
                    } else if showSheet2 {
                        
                            Text("Transfer")
                                .font(.title)
                                .bold()
                                .padding()
                                .task {
                                    AllBanksNames = []
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
                                Task {
                                    await MainActor.run {
                                        //loading = true
                                    }
                                }
                                withAnimation { showSheet2 = false }
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
                                        
                                        await MainActor.run {
                                            //loading = true
                                        }
                                    }
                                    
                                    
                                    withAnimation { showSheet2 = false }
                                } label: {
                                    Image(systemName: "arrow.forward")
                                        .foregroundStyle(.green)
                                        .bold()
                                        .padding(.horizontal, 50)
                                        .border(1, .black)
                                }
                                
                            }
                        
                    }
                    
                    
                    if bank.amountHistoryAmount.count >= 2 {
                        VStack(alignment: .leading) {
                                
                            Text("Amount History")
                                .font(.title)
                                .fontWeight(.heavy)
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
                            .onReceive(timer) { input in
                                
                                if !bank.transactionHistoryAmount.isEmpty {
                                    
                                    Task {
                                        await loadArrays()
                                    }
                                    
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
                            .onReceive(timer) { input in
                                
                                if !bank.transactionHistoryAmount.isEmpty {
                                    
                                    Task {
                                        await loadArrays()
                                    }
                                    
                                }
                            }
                        }
                        
                    }
                    
                    
//                    if bank.transactionHistoryAmount.count > 0 {
//                        
//                        
//                        VStack {
//                            if bank.transactionHistoryAmount.count >= 2 {
//                                
//                                if posArray.count >= 2 {
//                                    VStack(alignment: .leading) {
//                                        Text("Add History")
//                                            .font(.callout)
//                                            .opacity(0.75)
//                                            .frame(alignment: .leading)
//                                        
//                                        Text("Past 10")
//                                            .font(.caption)
//                                            .opacity(0.5)
//                                            .frame(alignment: .leading)
//                                        
//                                        //if posArray.count > 10 {
//                                            
//                                        ScrollViewReader { value in
//                                            ScrollView(.horizontal) {
//                                                HStack {
//                                                    ForEach(Array(posArray.enumerated()), id: \.offset) { i, val in
//                                                        BarViewPos(colour: .green, value: posArray[i], proxy: (proxy.size.height / 1.5), highestVal: posArray.max() ?? 0, total: posArray.count)
//                                                            .frame(width: proxy.size.width / 5)
//                                                        
//                                                    }
//                                                    
//                                                    
//                                                    Text("")
//                                                        .id(trailingID)
//                                                    
//                                                }
//                                                .task {
//                                                    withAnimation {
//                                                        value.scrollTo(trailingID)
//                                                    }
//                                                }
//                                            }
//                                            .scrollIndicators(.hidden)
//                                            
//                                            
//                                        }
//                                                
//                                                
////                                        } else {
////                                            ScrollViewReader { value in
////                                                ScrollView(.horizontal) {
////                                                    HStack {
////                                                        ForEach(Array(posArray.enumerated()), id: \.offset) { i, val in
////                                                            BarView(colour: .green, date: bank.transactionHistoryDate[i], value: posArray[i], proxy: proxy, highestVal: posArray.max() ?? 0, total: posArray.count)
////                                                                .frame(width: proxy.size.width / 5)
////                                                            
////                                                            
////                                                        }
////                                                        
////                                                        
////                                                        Text("")
////                                                            .id(trailingID)
////                                                        
////                                                    }
////                                                    .task {
////                                                        withAnimation {
////                                                            value.scrollTo(trailingID)
////                                                        }
////                                                    }
////                                                }
////                                                .frame(height: proxy.size.height / 2)
////                                                .scrollIndicators(.hidden)
////                                                
////                                                
////                                            }
////                                        }
//                                        
//                                        
//                                    }
//                                    .padding()
//                                    .onAppear {
//                                        
//                                        if !bank.transactionHistoryAmount.isEmpty {
//                                            
//                                            Task {
//                                                await loadArrays()
//                                            }
//                                            
//                                        }
//                                    }
//                                    .task {
//                                        if bank.transactionHistoryAmount != [] {
//                                            Task {
//                                                await loadArrays()
//                                            }
//                                        }
//                                        
//                                    }
//                                    
//                                }
//                                
//                                
//                                if negArray.count >= 2 {
//                                    VStack(alignment: .leading) {
//                                        
//                                        if showNeg {
//                                            Text("Subtract History")
//                                                .font(.callout)
//                                                .opacity(0.75)
//                                                .frame(alignment: .leading)
//                                            
//                                            Text("Past 10")
//                                                .font(.caption)
//                                                .opacity(0.5)
//                                                .frame(alignment: .leading)
//                                            
//                                            //                                        if negArray.count > 10 {
//                                            
//                                            
//                                            ScrollViewReader { value in
//                                                ScrollView(.horizontal) {
//                                                    HStack {
//                                                        ForEach(Array(negArray.enumerated()), id: \.offset) { i, val in
//                                                            //                                                        BarView(colour: .red, date: bank.transactionHistoryDate[i], value: -negArray[i], proxy: proxy, highestVal: 1000 , total: negArray.count)
//                                                            //                                                            .frame(width: proxy.size.width / 5)
//                                                            
//                                                            BarViewNeg(colour: .red, value: negArray[i], proxy: (proxy.size.height / 1.5), highestVal: -positive_NEG_ARRAY.max()!, total: negArray.count)
//                                                                .frame(width: proxy.size.width / 5)
//                                                            
//                                                        }
//                                                        
//                                                        
//                                                        Text("")
//                                                            .id(trailingID)
//                                                        
//                                                    }
//                                                    .task {
//                                                        withAnimation {
//                                                            value.scrollTo(trailingID)
//                                                        }
//                                                    }
//                                                }
//                                                .scrollIndicators(.hidden)
//                                                
//                                                
//                                            }
//                                            
//                                        }
//                                        
//                                    }
//                                    .padding()
//                                    .task {
//                                        var newarraytemp: [Double] = []
//                                        
//                                        for i in 0...(negArray.count - 1) {
//                                            newarraytemp.append(-negArray[i])
//                                        }
//                                        
//                                        await MainActor.run {
//                                            positive_NEG_ARRAY = newarraytemp
//                                        }
//                                        
//                                        showNeg = true
//                                        
//                                    }
//                                    
//                                }
//                                
//                            }
//                        }
//                        
//                        Divider()
//                        
//                        if !TransactionInfo.isEmpty {
//                            
//                            ForEach(TransactionInfo, id: \.self) { info in
//                                VStack {
//                                    HStack {
//                                        Text(info.name)
//                                            .bold()
//                                        
//                                        Spacer()
//                                        
//                                        Text(info.date, format: .dateTime.day().month().year().hour().minute())
//                                            .opacity(0.75)
//                                        
//                                        Text(String(info.amount))
//                                            .bold()
//                                    }
//                                    .padding()
//                                    
//                                    Divider()
//                                }
//                            }
//                            
//                        }
//                        
//                        
//                    }
                    
                }
                .frame(maxWidth: .infinity)
                .navigationTitle(bank.name)
                .background(.black.opacity(0.05))
                .refreshable {
                    
                    
                    loading = true
                    
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
        } else {
            ProgressView()
                .task {
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
                        
                        try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
                        
                        loading = false
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
    ParentMain()
}
