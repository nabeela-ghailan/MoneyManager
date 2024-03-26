//
//  SelectIncomeToEditView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 22/02/2024.
//

import SwiftUI

struct SelectIncomeView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @EnvironmentObject var aViewModel: AuthViewModel
    var selectedMonth: String
    var selectedYear: Int
    
    var body: some View {
        // lists the income of the selected month and year
        List(viewModel.incomes) { income in
            NavigationLink(destination: EditIncomeView(viewModel: viewModel, income: income)) {
                
                VStack(alignment: .leading){
                    Text(income.name)
                    Text("Amount: \(aViewModel.currentUser?.currency ?? "£") \(income.amount, specifier: "%.2f")")
                        .font(.subheadline)
                    Text(income.type)
                }
            }
        }
        .navigationTitle("Select Income to Edit")
        .onAppear{
            Task{
                await viewModel.fetchAllIncomesForSelectedMonthAndYear(month: selectedMonth, year: selectedYear)
            }
        }
        
    }
}



