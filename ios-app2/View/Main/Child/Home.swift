//
//  Home.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-20.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import SDWebImageSwiftUI
import PhotosUI

struct Home: View {
    
    @Binding var selectedTab: String
    
    @State var user: ChildUser?
    
    @State var LoadedUser: Bool = false
    
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    init(selectedTab: Binding<String>) {
        self._selectedTab = selectedTab
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            
            HomeViewThing()
                .tag("Home")
            
            if LoadedUser {
                
                ForEach(0..<user!.banks.count) { i in
                    BankView(BankName: user!.banks[i].name, bankArray: i, childUsername: user!.username)
                        .tag(user!.banks[i].name)
                }
                
            }
            
            ChildProfileView()
                .tag("Profile")
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

struct HomeViewThing: View {
    var body: some View {
        Text("Home")
    }
}

#Preview {
    ContentView()
}
