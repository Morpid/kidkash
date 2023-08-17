//
//  ChildReusableProfileContent.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChildReuseableProfileContent: View {
    
    var username: String
    var userProfileImageURL: URL?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            HStack {
                Spacer()
                    .frame(width: 15)
                
                LazyVStack {
                    
                        WebImage(url: userProfileImageURL).placeholder {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        
                        VStack() {
                            Text(username)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .vAlign(.top)
                        }
                }
            }
        }
    }
}
