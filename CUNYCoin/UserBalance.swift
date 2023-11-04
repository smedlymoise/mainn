//
//  UserBalance.swift
//  CUNYCoin
//
//  Created by Amit Aharoni on 11/4/23.
//

//import Foundation

import Combine

class UserBalance: ObservableObject {
    @Published var total: Double = 0.0
    
        // A method to update the total balance
        func updateBalance(forBottles bottles: Int) {
            let valuePerBottle = 0.5 // Assuming each bottle is worth 50 cents
            total += Double(bottles) * valuePerBottle
        }
    }


