//
//  BottleScannerView.swift
//  CUNYCoin
//
//  Created by Amit Aharoni on 11/4/23.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#") // Skip the hash mark if present
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}


struct BottleScannerView: View {
    
    var studentName: String
    
    @EnvironmentObject var userBalance: UserBalance // Access the shared user balance (initiated in a separate file & delcared in the main app component)
    @State private var isShowingScanner = false
    @State private var hasScanned = false // New state to track if we've already scanned
    @State private var bottlesScanned = 0
    @State private var lastScannedBottleInfo = ""
    
    var totalBalance: Double {
        Double(bottlesScanned) * 0.5 // Each bottle is worth 50 cents
    }
    
    let recyclableMaterials: [String: Bool] = [
        "0096619756803": true, // True if recyclable
        "0076301000155": true,
        "0850039525001": true,
        "04965802": true,
        "04963406": true,
        "0075720000616": true,
        
    ]
    
    let bottleCompanies: [String: String] = [
        "0096619756803": "Kirkland", // Barcode values and their corresponding company
        "0076301000155": "Apple & Eve",
        "0850039525001": "Sun Berry Farms",
        "04965802": "Coca-Cola",
        "04963406": "Coca-Cola",
        "0075720000616": "Poland Spring",
    ]

    var body: some View {
        VStack(spacing: 16) {
            Spacer() // Push content towards center

            Text("Bottles Scanned: \(bottlesScanned)")
                .bold()
            
            if !lastScannedBottleInfo.isEmpty {
                let infoComponents = lastScannedBottleInfo.components(separatedBy: " - ")
                if infoComponents.count == 2 {
                    Text(infoComponents[0]) // Recyclable info
                    Text(infoComponents[1]) // Company info
                } else {
                    Text(lastScannedBottleInfo)
                }
            } else {
                Text("Scan the Bottle BarCode")
            }

            // Reducing the number of spacers here will bring the button a bit up
            Spacer(minLength: 20) // Use a minLength for the spacer to control the spacing

            Button("Scan Now") {
                isShowingScanner = true
                hasScanned = false // Reset the scanned state
            }
            .padding() // Add padding around the text
            .background(Color(hex: "#0051BB")) // Set background color using hex
            .foregroundColor(.white) // Set the text color to white
            .cornerRadius(8) // Adjust corner radius to make it more box-like
            .fixedSize(horizontal: true, vertical: false) // This will fix the button's width based on its content, while allowing vertical size to adjust based on padding


            Spacer(minLength: 100) // Another spacer to balance the layout
            
            // Finish Deposition Button
        NavigationLink(destination: SummaryView(studentName: studentName)) {
            Text("Finish Deposition")
        }
            
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Spacer(minLength: 20)
        }
        .frame(maxWidth: 600, maxHeight: 100)


        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView { result in
                if !hasScanned {
                    // This ensures we only process the first scan
                    hasScanned = true
                    
                    switch result {
                    case .success(let code):
                        bottlesScanned += 1 // Increment the bottle count here
                        
                        // Updates the user balance
                        userBalance.updateBalance(forBottles: 1) // Calls the update method from the update balance class
                        
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
