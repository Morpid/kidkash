//
//  MainView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-14.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift
import FirebaseFirestore
import SDWebImageSwiftUI


struct MainView: View {
    
    @State var isLoading = true
    
    @State var showMenu: Bool = false
    
    @State var selectedTab = "Bank Amounts"
    
    @State var selectedBanks = ""
    
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    @State var myProfile: ChildUser?
    @AppStorage("log_status") var logStatus: Bool = false
    
    @State var banks: [Bank]?
    
//    init() {
//        UITabBar.appearance().isHidden = true
//    }
    
    
    var body: some View {
        
        NavigationStack {
            
            if !isLoading {
                
                ScrollView {
                    
                    VStack {
                        
                        
                        HStack {
                            Text("Accounts")
                                .bold()
                                .font(.footnote)
                            
                            Spacer()
                        }
                        
                        HStack {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundStyle(.clear)
                                .border25(2, .gray)
                            
                            RoundedRectangle(cornerRadius: 35)
                                .foregroundStyle(.clear)
                                .border25(2, .gray)
                                .frame(width: 75)
                        }
                        .frame(height: 200)
                    }
                    .padding()
                }
                .scrollIndicators(.visible)
                .overlay (
                    HStack(spacing: 5) {
                        Button {
                            withAnimation(.spring()) {
                                showMenu.toggle()
                            }
                        } label: {
                            
                            Image(systemName: showMenu ? "chevron.up" : "line.horizontal.3")
                                .font(.title2)
                                .fontDesign(.rounded)
                                .contentTransition(.symbolEffect(.replace.downUp.byLayer))
                                .foregroundStyle(/*showMenu ? .white : */.black)
                        }
                        .padding(.horizontal)
                        
                        Text("Porkish")
                            .bold()
                            .font(.headline)
                            .padding(.leading, -10)
                        
                        Spacer()
                        
                        Image(systemName: "bell")
                            .foregroundStyle(.black)
                            .font(.title3)
                            .padding()
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(.capsule)
                    .padding()
                    
                    ,alignment: .top
                )
                
//                List {
//                    Section("Bank Accounts") {
//                        ForEach(0..<banks!.count) { i in
//                            NavigationLink {
//                                HStack {
//                                    Text("**\(banks![i].name)**")
//                                    
//                                    Spacer()
//                                    
//                                    Text("$\(banks![i].amount, specifier: "%.2f")")
//                                }
//                            } label: {
//                                HStack {
//                                    Text(banks![i].name)
//                                    
//                                    Spacer()
//                                    
//                                    Text("\(banks![i].amount, specifier: "%.2f")")
//                                }
//                            }
//                            
//                        }
//                    }
//                    
//                    Section("Goals") {
//                        HStack {
//                            Gauge(value: 0.71) {
//                                Text("")
//                            }
//                            .tint(.green)
//                            .gaugeStyle(.accessoryCircularCapacity)
//                            
//                            VStack(alignment: .leading) {
//                                Text("A Goal")
//                                    .bold()
//                                    .font(.title3)
//                                
//                                Text("**71** of **100**")
//                                    .foregroundStyle(.gray)
//                            }
//                            .padding(.leading, 10)
//                            .padding(.trailing, 20)
//                            
//                            
//                            Gauge(value: 0.32) {
//                                Text("")
//                            }
//                            .tint(.green)
//                            .gaugeStyle(.accessoryCircularCapacity)
//                            
//                            VStack(alignment: .leading) {
//                                Text("Another Goal")
//                                    .bold()
//                                    .font(.title3)
//                                
//                                Text("**32** of **100**")
//                                    .foregroundStyle(.gray)
//                            }
//                            .padding(.leading, 10)
//                        }
//                    }
//                    .listRowBackground(Color.clear)
//                    
//                    
//                }
//                .navigationTitle("Home")
            } else {
                ProgressView()
            }
        }
        .onAppear {
            Task {
                var user = try await Firestore.firestore().collection("ChildUsers").document(usernameStored).getDocument(as: ChildUser.self)
                
                banks = user.banks
                isLoading = false
            }
        }
        
//        GeometryReader { proxy in
//            let safeArea = proxy.safeAreaInsets
//            
//            ZStack {
//                
//                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.25), .teal]), startPoint: .topTrailing, endPoint: .bottomLeading)
//                    .ignoresSafeArea()
//                
//                SideMenu(selectedTab: $selectedTab, showMenu: $showMenu, SelectedBanks: $selectedBanks, proxy: proxy)
//                    .frame(alignment: .leading)
//                
//                ZStack {
//                    
//                    Home(selectedTab: $selectedTab, selectedBanks: $selectedBanks)
//                        .clipShape(RoundedRectangle(cornerRadius: showMenu ? 15 : 0))
//                    
//                    
//                        
//                }
//                .rotation3DEffect(showMenu ? Angle(degrees: -20) : Angle(degrees: 0), axis: (x: 0, y: 1, z: 0))
//                .scaleEffect(showMenu ? 0.9 : 1)
//                .offset(x: showMenu ? proxy.size.width / 1.5 : 0)
//                .ignoresSafeArea()
//                .overlay (
//                    Button {
//                        withAnimation(.spring()) {
//                            showMenu.toggle()
//                        }
//                    } label: {
//                        
//                        Image(systemName: showMenu ? "xmark" : "line.horizontal.3")
//                            .font(.title)
//                            .fontDesign(.rounded)
//                            .fontWeight(.semibold)
//                            .contentTransition(.symbolEffect(.replace.downUp.byLayer))
//                            .foregroundStyle(showMenu ? .white : .black)
//                    }
//                    .padding()
//                    
//                    ,alignment: .topLeading
//                )
//                .toolbar {
//                    ToolbarItem(placement: .topBarLeading) {
//                        Button {
//                            withAnimation(.spring()) {
//                                showMenu.toggle()
//                            }
//                        } label: {
//                            
//                            Image(systemName: showMenu ? "xmark" : "line.horizontal.3")
//                                .font(.title)
//                                .fontDesign(.rounded)
//                                .fontWeight(.semibold)
//                                .contentTransition(.symbolEffect(.replace.downUp.byLayer))
//                                .foregroundStyle(showMenu ? .white : .black)
//                        }
//                        .padding()
//                    }
//                }
//                
////                VStack {
////                    
////                    Spacer()
////                    
////                    TransparentBlurView(removeAllFilters: true)
////                        .frame(height: 75 + safeArea.bottom)
////                        .padding([.horizontal, .bottom], -55)
////                        .visualEffect { view, proxy in
////                            view
////                                .offset(y: (proxy.bounds(of: .scrollView)?.minY ?? 0))
////                        }
////                        .zIndex(1000)
////                        .blur(radius: 10)
////                }
//                
//                
//                
//            }
//            .gesture(DragGesture(minimumDistance: 45, coordinateSpace: .local)
//                .onEnded({ value in
//                    if value.translation.width > 0 {
//                        if !showMenu {
//                            withAnimation {
//                                showMenu.toggle()
//                            }
//                        }
//                    }
//                    if value.translation.width < 0 {
//                        if showMenu {
//                            withAnimation {
//                                showMenu.toggle()
//                            }
//                        }
//                    }
//                }))
//        }
    }
}

#Preview {
    MainView()
}
