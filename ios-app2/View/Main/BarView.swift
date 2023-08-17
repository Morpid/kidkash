//
//  BarView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-08-07.
//

import SwiftUI

struct BarView: View {
    var date: Date
    var value: Double
    var proxy: GeometryProxy
    var highestVal: Double
    var total: Int
    
    @State var barHeightPercent = 0.00
    @State var barHeight = 0.00
    
    @State var show: Bool = false

    var body: some View {
        
        
        
        VStack {
            if show {
                VStack {
                    Spacer()
                    
                    Text("\(value, specifier: "%.0f")")
                        .foregroundStyle(.black)
                        .font(.callout)
                    
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(.mint)
                        .frame(height: barHeight)
                    
                    Text(date, format: .dateTime.day().month().year())
                        .foregroundStyle(.black)
                        .font(.callout)
                        .fontWeight(.bold)
                }
                
            } else {
                ProgressView()
            }
        }
        .task {
            if value == highestVal {
                barHeight = (proxy.size.height / 3)
            } else {
                barHeightPercent = (value / highestVal)
                barHeight = (barHeightPercent * (proxy.size.height / 3))
            }
            
            show = true
        }
    }
}

#Preview {
    ContentView()
}
