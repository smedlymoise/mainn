//
//  WelcomeScreenView.swift
//  CUNYCoin
//
//  Created by Amit Aharoni on 11/4/23.
//

import Foundation
import SwiftUI


struct WelcomeScreenView: View {
    @EnvironmentObject var userBalance: UserBalance
    
    // A dictionary to hold the student IDs (as Strings) and their names
    let studentDirectory: [String: String] = [
        "24456981": "Amit Aharoni",
        "24004171": "Oluwafemi Olosunde",
        "24031540": "Rin Velez",
        "14163556": "Smedly Moise",
    ]
    
    // State to manage the display of the scanner and welcome message
    @State private var isShowingScanner = false
    @State private var welcomeMessage: String?
    @State private var isAuthenticated = false // Var to check if the user has authenticated into the system using a QR code.
    @State private var studentName: String = ""  // Add a state variable to hold the student name

    
    var body: some View {
        NavigationView {
            VStack {
                    if isAuthenticated{
                        NavigationLink(destination: BottleScannerView(studentName: studentName)) {
                            HomeView(studentName: studentName)
                        }
                        
                    } else {
                        Text("Welcome to CUNYCoin")
                            .font(.largeTitle)
                            .padding()
                        Button("Scan Student ID QR Code") {
                            // Present the barcode scanner
                            self.isShowingScanner = true
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
                
                    .sheet(isPresented: $isShowingScanner) {
                        // Present the CodeScannerView here
                        CodeScannerView { result in
                            // Dismiss the scanner when a result is obtained
                            self.isShowingScanner = false
                            switch result {
                            case .success(let scanResult):
                                // Use the scanned string to lookup the student name
                                let scannedID = scanResult.string
                                if let studentName = self.studentDirectory[scannedID] {
//                                  self.welcomeMessage = "Welcome, \(studentName)!"
                                    self.studentName = studentName
                                    self.isAuthenticated = true // Set to true when authenticated.
                                } else {
                                    self.welcomeMessage = "Unknown Student ID. Please try again."
                                }
                            case .failure(let error):
                                // Handle any errors, perhaps show an alert to the user
                                print(error.localizedDescription)
                            }
                        }
                    }
                    .onAppear {
                        if !studentName.isEmpty {
                            self.isAuthenticated = true
                        }
                    }
            }
        }
    }
