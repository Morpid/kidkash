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
//import VisibilityTrackingScrollView


struct BankDetailsChild: View {
    
    @State var plotWidth: CGFloat = 0
    
    @State var AnnotationPos: AnnotationPosition = .top
    
    @State var expense_amount: String = ""
    
    @Binding var selectedBank: String
    
    @State var bank: Bank?
    
    @State var usable_negative_array: [Double] = []
    
    @State var transaction_info: [BankTransactionInfo] = []
    
    @State var bankArray: Int = 0
    
    @AppStorage("user_name") var usernameChild: String = ""
    
    @State var negArray: [Double] = []
    @State var posArray: [Double] = []
    
    @State var currentActiveItem: (amount: Double, date: Date, index: Int)?
    
    @State var isLoading: Bool = true
    
    @State var profileImg: URL?
    
    @State var showLoading: Bool = false
    
    @State var show_title: Bool = true
    
    @Namespace var titleID
    
    @State private var scrollPosition: CGPoint = .zero
    
    var body: some View {
        
        GeometryReader {
            if !isLoading {
                let safeArea = $0.safeAreaInsets
                
                if bank!.transactionHistoryAmount.count > 0 {
                    
                    ScrollViewReader { proxy in
                        
                        ScrollView {
                            
                            VStack {
                                
                                TransparentBlurView(removeAllFilters: true)
                                    .frame(height: 75 + safeArea.top)
                                    .padding([.horizontal, .top], -30)
                                    .visualEffect { view, proxy in
                                        view
                                            .offset(y: (proxy.bounds(of: .scrollView)?.minY ?? 0))
                                    }
                                    .zIndex(1000)
                                    .blur(radius: 10)
                                
                                VStack {
                                    if show_title {
                                        GeometryReader { proxy in
                                            
                                            ZStack {
                                                
                                                HStack {
                                                    
                                                    Spacer()
                                                    
                                                    VStack {
                                                        
                                                        Text("\(bank!.name)")
                                                            .font(.title2)
                                                        
                                                        Text("$\(bank!.amount, specifier: "%.2f")")
                                                            .font(.title)
                                                            .bold()
                                                        
                                                    }
                                                    
                                                    
                                                    Spacer()
                                                }
                                                .padding([.bottom, .horizontal], 20)
                                                
                                                
                                            }
                                            .id(titleID)
                                            .onChange(of: scrollPosition) { old, new in
                                                if (-scrollPosition.y > proxy.size.height * 2.9) {
                                                    withAnimation {
                                                        show_title = false
                                                    }
                                                }
                                            }
                                            
                                        }
                                    } else {
                                        VStack {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .foregroundStyle(.white)
                                                    .shadow(radius: 3.5)
                                                    .frame(height: 75)
                                                
                                                HStack {
                                                    
                                                    VStack {
                                                        Text("--")
                                                            .font(.title3)
                                                            .bold()
                                                        
                                                        Text("$--.--")
                                                            .font(.title3)
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    Image(systemName: "chevron.down")
                                                        .foregroundStyle(.black)
                                                }
                                                .padding(.horizontal)
                                                
                                                
                                                
                                            }
                                            
                                            Spacer()
                                            
                                            
                                            
                                        }
                                        .padding(.horizontal)
                                    }
                                    
                                    AmountHistoryChart()
                                    
                                    
                                }
                                .padding(.horizontal)
                                
                                
                                HStack() {
                                    Text("Transactions")
                                        .font(.title3.bold())
                                        .foregroundStyle(.black)
                                    
                                    Spacer()
                                    
                                    Button {
                                        Task {
                                            
                                            showLoading = true
                                            
                                            await updateFirebaseBank()
                                            
                                            await loadArrays()
                                            
                                            if bank!.transactionHistoryAmount.count > 1 {
                                                
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
                                            
                                            sleep(2)
                                            
                                            showLoading = false
                                            
                                        }
                                    } label: {
                                        Text("REFRESH \(Image(systemName: "arrow.2.circlepath"))")
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                        
                                    }
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                
                                VStack {
                                    
                                    ForEach(transaction_info) { transaction in
                                        
                                        Divider()
                                        
                                        ExpenseCardView(title: transaction.name, sub_title: transaction.subtitle, date: transaction.date, amount: transaction.amount)
                                            .padding(5)
                                    }
                                    .padding(.horizontal)
                                }
                                
                            }
                            .background(GeometryReader { geometry in
                                Color.clear
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                            })
                            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                self.scrollPosition = value
                            }
                            
                        }
                        .coordinateSpace(name: "scroll")
                        .navigationTitle("Scroll offset: \(scrollPosition.y)")
                        .navigationBarTitleDisplayMode(.inline)
                        .overlay(content: {
                            LoadingView(show: $showLoading)
                        })
                        .frame(maxWidth: .infinity)
                        .navigationTitle(bank!.name)
                        .onAppear {
                            Task {
                                await updateFirebaseBank()
                                
                                await loadArrays()
                            }
                        }
                        .ignoresSafeArea(.container, edges: .top)
                        
                    }
                } else {
                    ContentUnavailableView {
                        Label("Nothing Here Yet...", systemImage: "tray")
                    }
                    .frame(maxWidth: .infinity)
                    .navigationTitle(bank!.name)
                    .onAppear {
                        Task {
                            await updateFirebaseBank()
                            
                            await loadArrays()
                        }
                        
                        
                        
                    }
                }
            }
        }
        .overlay {
            LoadingView(show: $isLoading)
        }
        .onAppear {
            Task {
                var user = try await Firestore.firestore().collection("ChildUsers").document(usernameChild).getDocument(as: ChildUser.self)
                
                for i in 0...(user.banks.count - 1) {
                    if user.banks[i].name == selectedBank {
                        bank = user.banks[i]
                    }
                }
                
                isLoading = false
            }
        }
        .onChange(of: selectedBank, { oldValue, newValue in
            Task {
                
                await updateFirebaseBank()
                
                if bank!.transactionHistoryAmount.count > 1 {
                    
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
        })
        //.preferredColorScheme(.light)
        .refreshable {
            
            Task {
                
                await updateFirebaseBank()
                
                await loadArrays()
                
                if bank!.transactionHistoryAmount.count > 1 {
                    
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
    
    func loadArrays() async {
        
        Task {
            
            var user = try await Firestore.firestore().collection("ChildUsers").document(usernameChild).getDocument(as: ChildUser.self)
            
            var tempNegArray: [Double] = []
            var tempPosArray: [Double] = []
            
            for i in 0...(user.banks.count - 1) {
                if user.banks[i].name == bank!.name {
                    bankArray = i
                }
            }
            
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
    
    func FindLast10Max() -> Double {
        var newtemparr: [Double] = []
        for i in 0...10 {                
            newtemparr.append(bank!.amountHistoryAmount[(bank!.amountHistoryAmount.count - 1) - i])
        }
        let max = newtemparr.max()
        return max!
    }
    
    func FindMax() -> Double {
        let max = bank!.amountHistoryAmount.max()
        return max!
    }
    
    @ViewBuilder
    func AmountHistoryChart() -> some View {
        
        
        
        if bank!.amountHistoryAmount.count >= 2 {
            VStack(alignment: .leading, spacing:0) {
                
                if bank!.amountHistoryAmount.count > 10 {
                    Chart {
                        ForEach(Array(bank!.amountHistoryAmount[(bank!.amountHistoryAmount.count - 11)...(bank!.amountHistoryAmount.count - 1)].enumerated()), id: \.offset) { index, value in
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
                            
                            if bank!.amountHistoryAmount[(bank!.amountHistoryAmount.count - 1)] > bank!.amountHistoryAmount[(bank!.amountHistoryAmount.count - 2)] {
                                
                                PointMark(
                                    x: .value("Index", 10),
                                    y: .value("Value", bank!.amountHistoryAmount[(bank!.amountHistoryAmount.count - 1)])
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
                                    y: .value("Value", bank!.amountHistoryAmount[(bank!.amountHistoryAmount.count - 1)])
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
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .chartXScale(domain: 0...10)
                    .chartYScale(domain: 0...FindLast10Max())
                    .chartOverlay { proxy in
                        GeometryReader { innerProxy in
                            Rectangle()
                                .fill(.clear).contentShape(Rectangle())
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let location = value.location
                                            
                                            var x = value.translation.width
                                            var y = value.translation.height
                                            
                                            var horizontal: Bool = true
                                            var vertical: Bool = true
                                                            
                                            if ((x < 0 && y < 0 && x < y) || (x < 0 && y > 0 && -x > y) || (x > 0 && y < 0 && x > -y) || (x > 0 && y > 0 && x > y)) && horizontal && vertical {
                                                horizontal = true
                                                vertical = false
                                            } else if vertical && horizontal {
                                                horizontal = false
                                                vertical = true
                                            }
                                            
                                            if horizontal {
                                                
                                                if let index_value: Int = proxy.value(atX: location.x) {
                                                    if index_value <= 10 && index_value >= 0 {
                                                        
                                                        if index_value == 0 {
                                                            AnnotationPos = .topTrailing
                                                        } else if index_value == 10 {
                                                            AnnotationPos = .topLeading
                                                        } else {
                                                            AnnotationPos = .top
                                                        }
                                                        
                                                        self.currentActiveItem = (amount: bank!.amountHistoryAmount[((bank!.amountHistoryAmount.count - 11) + index_value)], date: bank!.amountHistoryDate[((bank!.amountHistoryDate.count - 11) + index_value)], index: index_value)
                                                        
                                                        self.plotWidth = proxy.plotSize.width
                                                    }
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
                        ForEach(Array(bank!.amountHistoryAmount.enumerated()), id: \.offset) { index, value in
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
                            
                            if bank!.amountHistoryAmount[(bank!.amountHistoryAmount.count - 1)] > bank!.amountHistoryAmount[(bank!.amountHistoryAmount.count - 2)] {
                                
                                PointMark(
                                    x: .value("Index", (bank!.amountHistoryAmount.count - 1)),
                                    y: .value("Value", bank!.amountHistoryAmount[(bank!.amountHistoryAmount.count - 1)])
                                )
                                .foregroundStyle(.green)
                                .annotation(position: .top) {
                                    Text("now")
                                        .font(.caption2)
                                        .foregroundStyle(.gray)
                                }
                                
                            } else {
                                PointMark(
                                    x: .value("Index", (bank!.amountHistoryAmount.count - 1)),
                                    y: .value("Value", bank!.amountHistoryAmount[(bank!.amountHistoryAmount.count - 1)])
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
                    .chartYScale(domain: 0...FindMax())
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .chartXScale(domain: 0...(bank!.amountHistoryAmount.count - 1))
                    .chartOverlay { proxy in
                        GeometryReader { innerProxy in
                            Rectangle()
                                .fill(.clear).contentShape(Rectangle())
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let location = value.location
                                            
                                            var x = value.translation.width
                                            var y = value.translation.height
                                            
                                            var horizontal: Bool = true
                                            var vertical: Bool = true
                                                            
                                            if ((x < 0 && y < 0 && x < y) || (x < 0 && y > 0 && -x > y) || (x > 0 && y < 0 && x > -y) || (x > 0 && y > 0 && x > y)) && horizontal && vertical {
                                                horizontal = true
                                                vertical = false
                                            } else if vertical && horizontal {
                                                horizontal = false
                                                vertical = true
                                            }
                                            
                                            if horizontal {
                                                
                                                if let index_value: Int = proxy.value(atX: location.x) {
                                                    if index_value <= (bank!.amountHistoryAmount.count - 1) && index_value >= 0 {
                                                        
                                                        if index_value == 0 {
                                                            AnnotationPos = .topTrailing
                                                        } else if index_value == (bank!.amountHistoryAmount.count - 1) {
                                                            AnnotationPos = .topLeading
                                                        } else {
                                                            AnnotationPos = .top
                                                        }
                                                        
                                                        self.currentActiveItem = (amount: bank!.amountHistoryAmount[index_value], date: bank!.amountHistoryDate[index_value], index: index_value)
                                                        self.plotWidth = proxy.plotSize.width
                                                    }
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
                if bank!.transactionHistoryAmount != [] {
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
                
                if (user.banks[bankArray].transactionHistoryAmount.count) < 2 {
                    temp_transaction_info.append(BankTransactionInfo(amount: amountReverse[0], date: dateReverse[0], name: nameReverse[0], subtitle: subTitleReverse[0]))
                } else if (user.banks[bankArray].transactionHistoryAmount.count) == 2 {
                    temp_transaction_info.append(BankTransactionInfo(amount: amountReverse[0], date: dateReverse[0], name: nameReverse[0], subtitle: subTitleReverse[0]))
                    
                    temp_transaction_info.append(BankTransactionInfo(amount: amountReverse[1], date: dateReverse[1], name: nameReverse[1], subtitle: subTitleReverse[1]))
                } else {
                    
                    for i in 0...(nameReverse.count - 1) {
                        temp_transaction_info.append(BankTransactionInfo(amount: amountReverse[i], date: dateReverse[i], name: nameReverse[i], subtitle: subTitleReverse[i]))
                    }
                    
                }
                
            }

            await MainActor.run { [user, temp_transaction_info] in
                withAnimation {
                    self.bank = user.banks[bankArray]
                    
                    if temp_transaction_info != transaction_info {
                        self.transaction_info = temp_transaction_info
                    }
                    
                    
                }
            }
            
            await loadArrays()
              
        }
    }
    
    
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

#Preview {
    ContentView()
}
