//
//  SpendingView.swift
//  CUNYCoin
//
//  Created by Amit Aharoni on 11/4/23.
//

import SwiftUI

struct SpendingView: View {
    @EnvironmentObject var userBalance: UserBalance
    @Binding var showSpendingView: Bool
    @State private var selectedStore: String = "Book Store"
    @State private var spendAmount: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    var studentName: String
    
    private let stores = ["Book Store", "Cafeteria"]
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Choose a store", selection: $selectedStore) {
                    ForEach(stores, id: \.self) { store in
                        Text(store)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                TextField("Enter amount to spend", text: $spendAmount)
                    .keyboardType(.decimalPad)

                Button("Spend") {
                    hideKeyboard()
                    if let amount = Double(spendAmount), amount > 0 {
                        spendAmountAtStore(amount, at: selectedStore)
                    }
                    spendAmount = ""
                }
                .disabled(!isValidAmountEntered)
            }
            .navigationBarTitle("Spend Your Tokens", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("Happy to recycle!")) {
                        showSpendingView = false // This will dismiss the SpendingView and return to HomeView
                    }
                )
            }

        }
        NavigationLink(destination: HomeView(studentName: studentName)) {
            Text("Go Home")
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        // Displays the total user balance.
            .navigationBarItems(trailing: HStack {
                Text("Balance: ")
                Text("$\(userBalance.total, specifier: "%.2f")")
                    .bold()
            })
    }
    
    private func spendAmountAtStore(_ amount: Double, at store: String) {
        if userBalance.total >= amount {
            userBalance.total -= amount
            // Here handle the logic of spending the amount
            alertMessage = "You've successfully spent $\(amount) at the \(store).\nYour new balance is $\(userBalance.total)."
            showAlert = true
        } else {
            // Handle the insufficient funds case
            alertMessage = "You do not have enough balance to spend this amount."
            showAlert = true
        }
    }
    
    private var isValidAmountEntered: Bool {
        if let amount = Double(spendAmount) {
            return amount > 0 && amount <= userBalance.total
        }
        return false
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif


