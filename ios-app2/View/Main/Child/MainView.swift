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
    
    @State var showMenu: Bool = false
    
    @State var selectedTab = "Home"
    
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    @State var myProfile: ChildUser?
    @AppStorage("log_status") var logStatus: Bool = false
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                
                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.25), .teal]), startPoint: .topTrailing, endPoint: .bottomLeading)
                    .ignoresSafeArea()
                
                SideMenu(selectedTab: $selectedTab, showMenu: $showMenu, proxy: proxy)
                    .frame(alignment: .leading)
                
                ZStack {
                    
                    Home(selectedTab: $selectedTab)
                        .clipShape(RoundedRectangle(cornerRadius: showMenu ? 15 : 0))
                        
                }
                .rotation3DEffect(showMenu ? Angle(degrees: -20) : Angle(degrees: 0), axis: (x: 0, y: 1, z: 0))
                .scaleEffect(showMenu ? 0.9 : 1)
                .offset(x: showMenu ? proxy.size.width / 1.5 : 0)
                .ignoresSafeArea()
                .overlay (
                    Button {
                        withAnimation(.spring()) {
                            showMenu.toggle()
                        }
                    } label: {
                        
                        Image(systemName: showMenu ? "xmark" : "line.horizontal.3")
                            .font(.title)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .contentTransition(.symbolEffect(.replace.downUp.byLayer))
                            .foregroundStyle(showMenu ? .white : .black)
                    }
                    .padding()
                    
                    ,alignment: .topLeading
                )
            }
            .gesture(DragGesture(minimumDistance: 45, coordinateSpace: .local)
                .onEnded({ value in
                    if value.translation.width > 0 {
                        if !showMenu {
                            withAnimation {
                                showMenu.toggle()
                            }
                        }
                    }
                    if value.translation.width < 0 {
                        if showMenu {
                            withAnimation {
                                showMenu.toggle()
                            }
                        }
                    }
                }))
        }
    }
}

#Preview {
    MainView()
}
