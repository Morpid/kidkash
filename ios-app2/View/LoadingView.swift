//
//  LoadingView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-14.
//

import SwiftUI

struct LoadingView: View {
    
    @Binding var show: Bool
    
    var body: some View {
        ZStack {
            if show {
                Group {
                    Rectangle()
                        .fill(.black.opacity(0.2))
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .padding(15)
                        .background(.white, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .preferredColorScheme(.light)
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: show)
    }
}
