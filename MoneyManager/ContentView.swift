//
//  ContentView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 14/02/2024.
//

import SwiftUI

struct ContentView: View {
    // Accessing the shared instance of AuthViewModel via EnvironmentObject
    @EnvironmentObject  var viewModel: AuthViewModel
    @StateObject private var budgetViewModel: BudgetViewModel
    @StateObject private var billViewModel: BillViewModel
    
    //initialises the class
    init(authViewModel: AuthViewModel) {
        //initialises the property as an instance of the class
        _budgetViewModel = StateObject(wrappedValue: BudgetViewModel(authViewModel: authViewModel))
        _billViewModel = StateObject(wrappedValue: BillViewModel(authViewModel: authViewModel))
    }
    var body: some View {
        // produce different kinds of views from a conditional
        Group{
            // checks to see if user is logged in
            if viewModel.userSession != nil {
                navigationView()
                    .environmentObject(budgetViewModel)
                    .environmentObject(billViewModel)
            }
            else {
                // registration and login view
                landingView()
            }
        }
    }
}


