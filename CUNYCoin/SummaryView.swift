//
//  SummaryView.swift
//  CUNYCoin
//
//  Created by Amit Aharoni on 11/4/23.
//

import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var userBalance: UserBalance
    @State private var showSpendingView = false
    var studentName: String
    var body: some View {
        VStack {
            Text("Total Balance: $\(userBalance.total, specifier: "%.2f")")
            NavigationLink(destination: SpendingView(showSpendingView: $showSpendingView).environmentObject(userBalance)) {
                Text("Spend Tokens")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            NavigationLink(destination: HomeView(studentName: studentName)) {
                Text("Go Home")
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}


