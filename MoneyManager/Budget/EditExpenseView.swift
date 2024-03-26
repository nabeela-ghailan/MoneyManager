//
//  EditExpenseView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 22/02/2024.
//

import SwiftUI

struct EditExpenseView: View {
    @ObservedObject var viewModel: BudgetViewModel
    var expense: Expense
    @State private var name: String
    @State private var amount: Double
    @State private var selectedCategory = ""
    @State private var newCategoryName = ""
    @Environment(\.presentationMode) var presentationMode
    
    // sets the initial state
    init(viewModel: BudgetViewModel, expense: Expense) {
        self.viewModel = viewModel
        self.expense = expense
        _name = State(initialValue: expense.name)
        _amount = State(initialValue: expense.amount)
        _selectedCategory = State(initialValue: expense.category)
    }
    
    var body: some View {
        Form {
            Section(){
                TextField("Name", text: $name)
                
                TextField("Amount", value: $amount, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                
                Picker("Category", selection: $selectedCategory) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        Text(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedCategory) { newCategory in
                    if let index = viewModel.categories.firstIndex(of: newCategory) {
                        selectedCategory = viewModel.categories[index]
                    }
                }
                TextField("New Category", text: $newCategoryName)
                if !newCategoryName.isEmpty {
                    Button("Add") {
                        Task {
                            await viewModel.addNewCategory(newCategoryName) { updatedCategory in
                                selectedCategory = updatedCategory
                            }
                            newCategoryName = "" // Clear the TextField after adding
                        }
                    }
                }
            }
            Section(){
                // updates the expense
                Button("Save") {
                    Task {
                        await viewModel.updateExpense(id: expense.id, name: name, amount: amount, month: expense.month, year: expense.year, category: selectedCategory)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            // deletes the expense
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteExpense(id: expense.id, month: expense.month, year: expense.year, category: selectedCategory)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Edit Expense")
    }
}

