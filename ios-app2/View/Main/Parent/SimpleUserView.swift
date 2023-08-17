//
//  SimpleUserView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-28.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import SDWebImageSwiftUI
import PhotosUI

struct SimpleUserView: View {
    
    var profileImg: URL
    var username: String
    
    var body: some View {
        HStack {
            
            WebImage(url: profileImg).placeholder {
                ProgressView()
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack {
                
                Text(username)
                
            }
            
        }
    }
}

#Preview {
    ContentView()
}
