//
//  navigationView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 15/02/2024.
//

import SwiftUI

struct navigationView: View {
    @State private var selection = 0 // tracks tab selection
    // Accessing the shared instance of AuthViewModel via EnvironmentObject
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var bViewModel: BudgetViewModel
    @EnvironmentObject var billViewModel: BillViewModel
    let currentYear: Int
    let currentMonth: String
    
    // sets the initial state of the view
    init() {
        let currentDate = Date()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        
        // Extract year as integer
        currentYear = calendar.component(.year, from: currentDate)
        
        // Extract month as string
        dateFormatter.dateFormat = "MMMM" // Format for full month name
        currentMonth = dateFormatter.string(from: currentDate)
    }
    
    var body: some View {
        TabView(selection: $selection){ // displays multiple views with tabs
            // home tab
            homeView()
                .environmentObject(bViewModel)
                .environmentObject(billViewModel)
            // defines the tab item
                .tabItem { // defines the tab item
                    VStack{
                        Image(systemName: "house.fill")
                        Text("Home")}
                }
                .tag(0)
                .onAppear {
                    Task {
                        // fetches the data
                        await bViewModel.fetchData(month: currentMonth, year: currentYear)
                    }
                }
            // budget tab
            budgetView(viewModel: BudgetViewModel(authViewModel: viewModel))
                .tabItem {
                    VStack{
                        Image(systemName: "tag")
                        Text("Budget")}
                }
                .tag(1)
            // bill tab
            billView(viewModel: BillViewModel(authViewModel: viewModel))
                .tabItem {
                    VStack{
                        Image(systemName: "calendar")
                        Text("Bills")}
                }
                .onAppear {
                    Task {
                        await billViewModel.fetchUpcomingBills()                    }
                }
                .tag(2)
            // settings tab
            settingsView()
                .tabItem {
                    VStack{
                        Image(systemName: "gearshape")
                        Text("Settings")}
                }
                .tag(3)
        }
        
    }
}

struct navigationView_Previews: PreviewProvider{
    static var previews: some View {
        let authViewModel = AuthViewModel() // Initialize AuthViewModel
        let budgetViewModelInstance = BudgetViewModel(authViewModel: authViewModel)
        let billViewModelInstance = BillViewModel(authViewModel: authViewModel)// Create an instance of budgetViewModel
        return navigationView()
            .environmentObject(authViewModel) // Provide authViewModel as an environment object
            .environmentObject(budgetViewModelInstance)
            .environmentObject(billViewModelInstance)
    }
}
