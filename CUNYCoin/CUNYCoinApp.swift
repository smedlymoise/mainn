//
//  CUNYCoinApp.swift
//  CUNYCoin
//
//  Created by Amit Aharoni on 11/4/23.
//

import SwiftUI

@main
struct CUNYCoinApp: App {
    @StateObject var userBalance = UserBalance() // Create a single instance of the total user's balance
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userBalance) // Inject into the environment
        }
    }
}
