//
//  SideMenu.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-19.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift
import FirebaseFirestore
import SDWebImageSwiftUI

struct SideMenu: View {
    
    @Binding var selectedTab: String
    
    
    @Binding var showMenu: Bool
    
    @State var user: ChildUser?
    
    @State var LoadedUser: Bool = false
    
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    @AppStorage("log_status") var logStatus: Bool = false
    
    @Binding var SelectedBanks: String
    
    @State var showLogoutVerification: Bool = false
    
    @State var proxy: GeometryProxy
    @Namespace var animation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            WebImage(url: profileURL).placeholder {
                Image(systemName: "person.crop.circle")
                    .resizable()
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 70, height: 70)
            .clipShape(Circle())
            .padding(.top, 50)
            
            VStack(alignment: .leading, spacing: 6, content: {
                Text(usernameStored)
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
            })
            
            VStack(alignment: .leading, spacing: 10, content: {
                if LoadedUser {
                    
                    ScrollView {
                        
                        TabButton(image: "building.columns", title: "Bank Amounts", selectedTab: $selectedTab, showMenu: $showMenu, proxy: proxy, selectedBank: $SelectedBanks, animation: animation)
                        
                        ForEach(0..<user!.banks.count) { i in
                            BankTabButton(BankAmount: user!.banks[i].amount, BankTitle: user!.banks[i].name, title: "Bank", selectedTab: $selectedTab, SelectedBank: $SelectedBanks, showMenu: $showMenu, proxy: proxy, animation: animation)
                        }
                        
                    }
                    
                } else {
                    ProgressView()
                        .padding()
                        .font(.title)
                }
            })
            .padding(.leading, -15)
            .padding(.top, 50)
            
            Spacer()
             
            
            Button {
                withAnimation(.spring()) {
                    showLogoutVerification.toggle()
                }
            } label: {
                HStack(spacing: 15) {
                    Image(systemName: "iphone.and.arrow.forward")
                        .font(.title2)
                        .frame(width: 30)
                    
                    Text("Log Out")
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 10)
                .frame(maxWidth: proxy.size.width / 2, alignment: .leading)
            }
            .tint(.white)
            .padding(.leading, -15)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .alert(isPresented: $showLogoutVerification) {
            Alert(
                title: Text("Log Out?"),
                primaryButton: .destructive(Text("Log Out")) {
                    logStatus = false
                },
                secondaryButton: .cancel()
            )
        }
        .task {
            await FetchUser()
        }
    }
    
    func FetchUser() async {
        
        Task {
            do {
                    
                let user = try await Firestore.firestore().collection("ChildUsers").document(usernameStored).getDocument(as: ChildUser.self)
                
                
                await MainActor.run(body: {
                    self.user = user
                    LoadedUser = true
                })
                    
            } catch {
                
            }
        }
    }
    
}


#Preview {
    ContentView()
}
