//
//  TabButton.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-24.
//

import SwiftUI

struct TabButton: View {
    
    var image: String
    var title: String
    
    @Binding var selectedTab: String
    @Binding var showMenu: Bool
    @State var proxy: GeometryProxy
    
    @Binding var selectedBank: String
    
    @State var offset: CGFloat = 0.00
    @State var scale: CGFloat = 1
    
    var animation: Namespace.ID
    
    var body: some View {
        Button {
            withAnimation(.spring()) {
                selectedTab = title
                selectedBank = ""
                showMenu = false
            }
        } label: {
            HStack(spacing: 15) {
                if selectedTab == title {
                    Image(systemName: "\(image).fill")
                        .font(.title2)
                        .frame(width: 30)
                        .foregroundStyle(selectedBank == "" ? .black : .white)
                } else {
                    Image(systemName: image)
                        .font(.title2)
                        .frame(width: 30)
                        .foregroundStyle(selectedBank == "" ? .black : .white)
                }
                
                
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundStyle(selectedBank == "" ? .black : .white)
                            }
            .onChange(of: selectedTab, { oldValue, newValue in
                if newValue == title {
                    
                    
                    withAnimation {
                        showMenu = false
                    }
                }
            })
            .foregroundStyle(selectedTab == title ? Color.black.opacity(0.3) : Color.black.opacity(0.3))
            .padding(.vertical, 12)
            .padding(.horizontal, 10)
            .frame(maxWidth: proxy.size.width, alignment: .leading)
            .frame(alignment: .leading)
            .background(
                ZStack {
                    if selectedTab == title {
                        if selectedBank == "" {
                            Color.white
                                .opacity(selectedBank == "" ? 0.5 : 0)
                            //.clipShape(CustomCorners(corners: [.topRight, .bottomRight], radius: 12))
                                .matchedGeometryEffect(id: "TAB", in: animation)
                        }
                    }
                }
            )
        }
    }
}

#Preview {
    ContentView()
}
