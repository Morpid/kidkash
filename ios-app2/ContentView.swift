//
//  ContentView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-12.
//

import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

struct ContentView: View {
    
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("parent_log_status") var parentLogStatus: Bool = false
    
    @Environment(\.scenePhase) var scenePhase

    
    var body: some View {
        if logStatus {
            MainView()
                .preferredColorScheme(.light)
        } else if parentLogStatus {
            ParentMain()
                .preferredColorScheme(.light)
        } else {
            StartView()
                .preferredColorScheme(.light)
        }
        
    }
    
    func sendLastToFirebase() async {
        Task {
            if logStatus {
                let db = Firestore.firestore()
            }
        }
    }
    
    func logoutUser() {
        try? Auth.auth().signOut()
        logStatus = false
    }
}

#Preview {
    ContentView()
}
