//
//  StartView.swift
//  ios-app2
//
//  Created by Luka Baylis on 2023-07-14.
//

import SwiftUI

struct StartView: View {
    
    @State var pageShowed: String = "Start"
    @State var ParentSelected: Bool = true
    
    @State var togglePageParent: Bool = false
    @State var togglePageChild: Bool = false
   
    @AppStorage("parent_log_status") var parent_parentLogStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var usernameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    var body: some View {
        //if pageShowed == "Start" {
            VStack {
                VStack {
                    
                    Image("Logo:black")
                        .resizable()
                        .frame(width: 300, height: 300)
                    
                    Spacer()
                    
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(.gray.opacity(0.2))
                                .frame(height: 100)
                                .borderWithoutPadding(2, ParentSelected == true ? .blue : .blue.opacity(0.0))
                                .onTapGesture {
                                    withAnimation {
                                        ParentSelected = true
                                    }
                                }
                            
                            
                            Text("I'm a **Parent**")
                        }
                        
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(.gray.opacity(0.2))
                                .frame(height: 100)
                                .borderWithoutPadding(2, ParentSelected == false ? .blue : .blue.opacity(0.0))
                                .onTapGesture {
                                    withAnimation {
                                        ParentSelected = false
                                    }
                                }
                            
                            
                            Text("I'm a **Child**")
                        }
                        
                        Spacer()
                            .frame(height: 25)
                        
                        Button {
                            Task {
                                await MainActor.run {
                                    if ParentSelected {
                                        withAnimation(.linear(duration: 0.1)) {
                                            pageShowed = "ParentLogin"
                                            togglePageParent.toggle()
                                        }
                                    } else {
                                        withAnimation(.linear(duration: 0.1)) {
                                            pageShowed = "ChildLogin"
                                            togglePageChild.toggle()
                                        }
                                    }
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.gray.opacity(0.2))
                                    .frame(height: 50)
                                
                                
                                HStack {
                                    Text("Next")
                                        .foregroundStyle(.black)
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.black)
                                }
                            }
                        }
                        
                    }
                    .padding()
                    
                    
//                    Button {
//                        withAnimation(.linear(duration: 0.1)) {
//                            pageShowed = "ParentLogin"
//                        }
//                    } label: {
//                        VStack(spacing: 0) {
//                            
//                            Image(systemName: "figure.and.child.holdinghands")
//                                .foregroundStyle(.black)
//                                .font(.title)
//                            
//                            HStack(spacing: 6) {
//                                
//                                Text("Parent")
//                                    .font(.title2)
//                                    .foregroundStyle(.black)
//                                    .bold()
//                                Text("Login")
//                                    .font(.title2)
//                                    .foregroundStyle(.black)
//                                
//                                
//                            }
//                        }
//                    }
//                    .padding(.bottom)
//                    .padding(.top)
//                    
//                    Button {
//                        withAnimation(.linear(duration: 0.1)) {
//                            pageShowed = "ChildLogin"
//                        }
//                    } label: {
//                        VStack(spacing: 0) {
//                            
//                            Image(systemName: "figure.child.and.lock.fill")
//                                .foregroundStyle(.black)
//                                .font(.title)
//                            
//                            HStack(spacing: 6) {
//                                
//                                Text("Child")
//                                    .font(.title2)
//                                    .bold()
//                                    .foregroundStyle(.black)
//                                Text("Login")
//                                    .font(.title2)
//                                    .foregroundStyle(.black)
//                                
//                                
//                            }
//                        }
//                    }
                }
                .padding(.bottom, 50)
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(gradient: Gradient(colors: [.mint, .white, .white]), startPoint: .topTrailing, endPoint: .bottomLeading)
            )
            .sheet(isPresented: $togglePageParent) {
                LoginView()
                    .presentationDetents([.medium])
                    .presentationCornerRadius(50)
                    .presentationBackground(.ultraThinMaterial)
            }
            .sheet(isPresented: $togglePageChild) {
                ChildLoginView()
                    .presentationDetents([.medium])
                    .presentationCornerRadius(50)
                    .presentationBackground(.ultraThinMaterial)
            }
            
//        } else {
//            if pageShowed == "ParentLogin" {
//                ZStack {
//                    LoginView()
//                    
//                    Button {
//                        withAnimation(.linear(duration: 0.1)) {
//                            pageShowed = "Start"
//                        }
//                    } label: {
//                        HStack {
//                            Image(systemName: "chevron.left")
//                                .foregroundStyle(.black)
//                            Text("Back")
//                                .foregroundStyle(.black)
//                        }
//                    }
//                    .padding()
//                    .hAlign(.leading)
//                    .vAlign(.top)
//                    
//                    Button {
//                        withAnimation(.linear(duration: 0.1)) {
//                            pageShowed = "ParentRegister"
//                        }
//                    } label: {
//                        HStack {
//                            
//                            Text("Don't Have an Account?")
//                                .foregroundStyle(.black)
//                        }
//                    }
//                    .padding()
//                    .hAlign(.trailing)
//                    .vAlign(.top)
//                }
//            } else if pageShowed == "ParentRegister" {
//                ZStack {
//                    RegisterView()
//                    
//                    Button {
//                        withAnimation(.linear(duration: 0.1)) {
//                            pageShowed = "ParentLogin"
//                        }
//                    } label: {
//                        HStack {
//                            Image(systemName: "chevron.left")
//                                .foregroundStyle(.black)
//                            Text("Back")
//                                .foregroundStyle(.black)
//                        }
//                    }
//                    .padding()
//                    .hAlign(.leading)
//                    .vAlign(.top)
//                }
//            } else if pageShowed == "ChildLogin" {
//                ZStack {
//                    ChildLoginView()
//                    
//                    Button {
//                        withAnimation(.linear(duration: 0.1)) {
//                            pageShowed = "Start"
//                        }
//                    } label: {
//                        HStack {
//                            Image(systemName: "chevron.left")
//                                .foregroundStyle(.black)
//                            Text("Back")
//                                .foregroundStyle(.black)
//                        }
//                    }
//                    .padding()
//                    .hAlign(.leading)
//                    .vAlign(.top)
//                }
//            }
//        }
    }
}

#Preview {
    StartView()
}
