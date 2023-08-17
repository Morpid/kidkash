//
//  BarViewPos.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-08-17.
//

import SwiftUI

struct BarViewPos: View {
    
    var colour: Color
    var value: Double
    var proxy: CGFloat
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
                    
                    Text("$\(value, specifier: "%.0f")")
                        .foregroundStyle(.black)
                        .font(.callout)
                        .bold()
                    
                    Rectangle()
                        .foregroundStyle(colour.gradient)
                        .frame(height: barHeight)
                        .cornerRadius(radius: 5, corners: [.topLeft, .topRight])
                }
                
            } else {
                ProgressView()
            }
        }
        .task {
            if value == highestVal {
                barHeight = (proxy / 3)
            } else {
                barHeightPercent = (value / highestVal)
                barHeight = (barHeightPercent * (proxy / 3))
            }
            
            show = true
        }
    }

}

#Preview {
    ContentView()
}
