//
//  ContentView.swift
//  CUNYCoin
//
//  Created by Amit Aharoni on 11/4/23.
//

//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    ContentView()
//}

import SwiftUI

struct ContentView: View {
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
#Preview {
    ContentView()
}
