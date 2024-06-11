//
//  BankTabButton.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-28.
//

import SwiftUI

struct BankTabButton: View {
    
    var BankAmount: Double
    var BankTitle: String
    var title: String
    
    @Binding var selectedTab: String
    @Binding var SelectedBank: String
    @Binding var showMenu: Bool
    @State var proxy: GeometryProxy
    
    @State var offset: CGFloat = 0.00
    @State var scale: CGFloat = 1
    
    var animation: Namespace.ID
    
    var body: some View {
        Button {
            withAnimation(.spring()) {
                selectedTab = "Bank Amounts"
                SelectedBank = BankTitle
                showMenu = false
            }
        } label: {
            HStack(spacing: 15) {
                
                
                
                Text(BankTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(SelectedBank == BankTitle ? .black : .white)
                
                Text(String(BankAmount))
                    .fontWeight(.regular)
                    .foregroundStyle(SelectedBank == BankTitle ? .black : .white)
                            }
            .onChange(of: selectedTab, { oldValue, newValue in
                if newValue == BankTitle {
                    
                    
                    withAnimation {
                        showMenu = false
                    }
                }
            })
            .foregroundStyle(SelectedBank == BankTitle ? Color.black : .white)
            .padding(.vertical, 12)
            .padding(.horizontal, 10)
            //.frame(maxWidth: (proxy.size.width / 2), alignment: .leading)
            .frame(maxWidth: proxy.size.width, alignment: .leading)
            .background(
                ZStack {
                    if SelectedBank == BankTitle {
                        Color.white
                            .opacity(SelectedBank == BankTitle ? 0.5 : 0)
                            //.clipShape(CustomCorners(corners: [.topRight, .bottomRight], radius: 12))
                            .matchedGeometryEffect(id: "TAB", in: animation)
                    }
                }
            )
        }
    }
}

#Preview {
    ContentView()
}
