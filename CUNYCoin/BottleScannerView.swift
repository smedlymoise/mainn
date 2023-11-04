//
//  BottleScannerView.swift
//  CUNYCoin
//
//  Created by Amit Aharoni on 11/4/23.
//

import Foundation
import SwiftUI

struct BottleScannerView: View {
    @State private var isShowingScanner = false
    @State private var hasScanned = false // New state to track if we've already scanned
    @State private var bottlesScanned = 0
    @State private var lastScannedBottleInfo = ""
    
    let recyclableMaterials: [String: Bool] = [
        "0096619756803": true, // True if recyclable
        "0076301000155": true,
        "0850039525001": true,
        "04965802": true,
        
    ]
    
    let bottleCompanies: [String: String] = [
        "0096619756803": "Kirkland", // Barcode values and their corresponding company
        "0076301000155": "Apple & Eve",
        "0850039525001": "Sun Berry Farms",
        "04965802": "Coca-Cola",
    ]

    var body: some View {
        VStack {
            Text("Bottles Scanned: \(bottlesScanned)")
            if !lastScannedBottleInfo.isEmpty {
                Text(lastScannedBottleInfo)
            } else {
                Text("Scan a Water Bottle Code")
            }
            Button("Scan Now") {
                isShowingScanner = true
                hasScanned = false // Reset the scanned state
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView { result in
                if !hasScanned {
                    // This ensures we only process the first scan
                    hasScanned = true
                    
                    switch result {
                    case .success(let code):
                        bottlesScanned += 1 // Increment the bottle count here
                        
                        // Check if the bottle is recyclable
                        let isRecyclable = recyclableMaterials[code.string] ?? false
                        let company = bottleCompanies[code.string] ?? "Unknown"
                        
                        // Update the last scanned bottle info without barcode
                        lastScannedBottleInfo = "Recyclable: \(isRecyclable ? "Yes" : "No") - Company: \(company)"
                        
                    case .failure(let error):
                        // Handle any errors
                        print(error.localizedDescription)
                    }
                    
                    // Delay the dismissal to ensure the scanner has time to close
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.isShowingScanner = false
                    }
                }
            }
        }
    }
}
