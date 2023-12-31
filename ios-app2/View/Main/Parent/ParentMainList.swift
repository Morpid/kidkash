//
//  ParentMainList.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-28.
//

import SwiftUI

struct ParentMainList: View {
    
    @State var fetchedUsers: [ChildUser]
    
    @State var ArrayNumber: Int
    
    var body: some View {
        List {
            
            Section("Banks Amounts") {
                ForEach(0..<fetchedUsers[ArrayNumber].banks.count) { j in
                    NavigationLink {
                        BankDetails(bank: fetchedUsers[ArrayNumber].banks[j], bankArray: j, usernameChild: fetchedUsers[ArrayNumber].username, profileImg: fetchedUsers[ArrayNumber].userProfileURL)
                    } label: {
                        HStack {
                            Image(systemName: "dollarsign")
                            
                            Text(fetchedUsers[ArrayNumber].banks[j].name)
                        }
                    }
                    
                }
            }
            
            Section("Reoccuring Transactions") {
                
                NavigationLink {
                    RecurringTransaction(user: fetchedUsers[ArrayNumber])
                } label: {
                    HStack {
                        Image(systemName: "arrow.left.arrow.right")
                        
                        Text("Reoccuring Transactions")
                    }
                }
                    
                
            }
            
            Section("Bank Accounts") {
                NavigationLink {
                    VStack {
                        AddBankView(username: fetchedUsers[ArrayNumber].username, currentArray: fetchedUsers[ArrayNumber].banks)
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        
                        Text("Add")
                    }
                }
            }
            
            Section("More") {
                
                NavigationLink {
                    Text("settings")
                } label: {
                    HStack {
                        Image(systemName: "gearshape")
                        
                        Text("Settings")
                    }
                }
                
                NavigationLink {
                    Text("delete")
                } label: {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                        
                        Text("Delete Account")
                            .foregroundStyle(.red)
                    }
                }
                    
                
            }
        }
        .navigationTitle(fetchedUsers[ArrayNumber].username)    }
}

#Preview {
    ParentMain()
}
