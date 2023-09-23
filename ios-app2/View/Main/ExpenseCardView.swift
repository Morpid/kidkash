//
//  ExpenseCardView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-09-16.
//

import SwiftUI

struct ExpenseCardView: View {
    @State var title: String
    @State var sub_title: String
    @State var date: Date
    @State var amount: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                
                Text(sub_title)
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Text(date, format: .dateTime.day().month().year().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .lineLimit(1)
            
            Spacer(minLength: 5)
            
            Text("\(amount, specifier: "%.2f")")
                .font(.title3.bold())
            
            
        }
    }
}

