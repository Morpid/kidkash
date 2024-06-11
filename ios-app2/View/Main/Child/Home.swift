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
    @Binding var selectedBanks: String
    
    @State var user: ChildUser?
    
    @State var LoadedUser: Bool = false
    
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    init(selectedTab: Binding<String>, selectedBanks: Binding<String>) {
        self._selectedTab = selectedTab
        self._selectedBanks = selectedBanks
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            if LoadedUser {
                
                AllBanksView(selectedBank: $selectedBanks)
                    .tag("Bank Amounts")
                
            }
        }
        
    }
    
}
