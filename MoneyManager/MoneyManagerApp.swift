//
//  MoneyManagerApp.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 14/02/2024.
//

import SwiftUI
import Firebase

@main
struct MoneyManagerApp: App {
    // appDelegates configures firebase when the app launches. this enables appDelegate to receive app states like (launch, termination)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // initialises as a state object to manage authentication. this creates an instance of the object so that its only used once.
    @StateObject var authViewModel = AuthViewModel() // Initialize AuthViewModel
    
    
    var body: some Scene {
        WindowGroup {
            ContentView(authViewModel: AuthViewModel())
                .environmentObject(authViewModel) //passes the viewModel as en environment object to contentView
            
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()  //configures firebase when the app finishes launching
        return true
    }
}
