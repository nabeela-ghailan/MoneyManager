//
//  ExpenseDetailView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 22/02/2024.
//

import SwiftUI

struct ExpenseDetailView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @EnvironmentObject var aViewModel: AuthViewModel
    
    var category: String
    var selectedMonth: String
    var selectedYear: Int
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form{
            Section(){
                // lists the expenses for the selected cateogry
                List(viewModel.expenses, id: \.id) { expense in
                    NavigationLink(destination: EditExpenseView(viewModel: viewModel, expense: expense)){
                        VStack(alignment: .leading) {
                            Text(expense.name)
                            Text("Amount: \(aViewModel.currentUser?.currency ?? "£") \(expense.amount, specifier: "%.2f")")
                        }
                    }
                }
            }
            Button("Delete category", role: .destructive) {
                Task {
                    await viewModel.deleteCategory(month: selectedMonth, year: selectedYear, category: category)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Expenses for \(category)")
        .onAppear {
            
            Task{
                do{
                    await viewModel.fetchExpensesForCategory(month: selectedMonth, year: selectedYear, category: category)
                }
            }
            
        }
    }
}
