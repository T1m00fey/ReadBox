//
//  ReadifyApp.swift
//  Readify
//
//  Created by Тимофей Юдин on 27.10.2024.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct YourApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @Environment(\.scenePhase) private var scenePhase
    
  var body: some Scene {
    WindowGroup {
      NavigationView {
        RootView()
          .onAppear {
              StorageManager.shared.setLanguage(to: Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "en")
              let db = Firestore.firestore()
              db.clearPersistence()
          }
          .onChange(of: scenePhase) { newValue in
              if scenePhase == .inactive || scenePhase == .background {
                  let db = Firestore.firestore()
                  db.clearPersistence()
              }
          }
      }
    }
  }
}
