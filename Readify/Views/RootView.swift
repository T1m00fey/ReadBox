//
//  RootView.swift
//  Readify
//
//  Created by Тимофей Юдин on 27.10.2024.
//

import SwiftUI

struct RootView: View {
    @State private var isSignInViewPresented = false
    
    var body: some View {
        ZStack {
            TabView {
//                Tab("", systemImage: "house.fill") {
//                    if StorageManager.shared.getLanguage() == "ru" {
//                        RuFeedView()
//                    } else {
//                        EnFeedView()
//                    }
//                }
//                
//                Tab("", systemImage: "person.fill") {
//                    ProfileView(isSignInViewPresented: $isSignInViewPresented)
//                }
                
                if StorageManager.shared.getLanguage() == "ru" {
                    RuFeedView()
                        .tabItem {
                            Label("", systemImage: "house.fill")
                        }
                    
                    RuLikedPostsView()
                        .tabItem {
                            Label("", systemImage: "hand.thumbsup.fill")
                        }
                } else {
                    EnFeedView()
                        .tabItem {
                            Label("", systemImage: "house.fill")
                        }
                    
                    EnLikedPostsView()
                        .tabItem {
                            Label("", systemImage: "hand.thumbsup.fill")
                        }
                }
                
//                if StorageManager.shared.getLanguage() == "ru" {
//                    Text("Hello, World")
//                        .tabItem {
//                            Label("", systemImage: "arrow.down.circle")
//                        }
//                } else {
//                    Text("Hello, World")
//                        .tabItem {
//                            Label("", systemImage: "arrow.down.circle")
//                        }
//                }
                
                ProfileView(isSignInViewPresented: $isSignInViewPresented)
                    .tabItem {
                        Label("", systemImage: "person.fill")
                    }
            }
            .tint(Color(uiColor: .label))
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.isSignInViewPresented = authUser == nil
        }
        .fullScreenCover(isPresented: $isSignInViewPresented) {
            SignInView(isPresented: $isSignInViewPresented)
        }
    }
}

#Preview {
    RootView()
}
