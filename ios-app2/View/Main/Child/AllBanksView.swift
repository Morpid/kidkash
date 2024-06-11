//
//  AllBanksView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-10-27.
//

import SwiftUI
import Firebase

struct AllBanksView: View {
    
    @Binding var selectedBank: String
    
    var body: some View {
        VStack {
            if selectedBank == "" {
                ScrollView {
                    
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(height: 50)
                    
                    HStack {
                        Text("Welcome Back")
                            .foregroundStyle(.black)
                            .font(.title.bold())
                        
                        Spacer()
                    }
                    .padding()
                }
                
            } else {
                
                BankDetailsChild(selectedBank: $selectedBank)
                
            }
        }
    }
}
