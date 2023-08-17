//
//  ReuseableProfileContent.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-20.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReuseableProfileContent: View {
    
    var user: User
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            HStack {
                Spacer()
                    .frame(width: 15)
                
                LazyVStack {
                    
                    //HStack(spacing: 12) {
                        WebImage(url: user.userProfileURL).placeholder {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        
                        VStack() {
                            Text(user.userEmail)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .vAlign(.top)
                            
                            Text("Pax" + " • " + "Golden Retreiver")
                                .foregroundColor(.gray)
                        }
                    //}.hAlign(.leading)
                    
                    Text("Posts")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .hAlign(.leading)
                        .padding(.vertical, 15)
                }
            }
        }
    }
}
