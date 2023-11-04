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
    @State private var scannedCode: String?

    var body: some View {
        VStack {
            if let scannedCode = scannedCode {
                Text("Scanned: \(scannedCode)")
            } else {
                Text("Scan a Water Bottle Code")
            }
            Button("Scan Now") {
                isShowingScanner = true
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView { result in
                if case let .success(code) = result {
                    self.scannedCode = code.string
                    self.isShowingScanner = false
                }
            }
        }
    }
}
