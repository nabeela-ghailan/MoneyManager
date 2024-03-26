//
//  AddExpenseView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 22/02/2024.
//
import SwiftUI

struct AddExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetViewModel
    @State private var name = ""
    @State private var amount: Double = 0
    @State private var selectedCategory = ""
    @State private var showingCategoryInput = false
    @State private var newCategoryName = ""
    @FocusState private var isPickerFocused: Bool
    @State private var selectedMonthIndex = Calendar.current.component(.month, from: Date()) - 1
    @State private var selectedYearIndex = Calendar.current.component(.year, from: Date()) - 2023
    
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let years = Array(2023...2030)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Name", text: $name)
                    TextField("Amount", value: $amount, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                    
                    Picker("Month", selection: $selectedMonthIndex) {
                        ForEach(0..<months.count, id: \.self) { index in
                            Text(months[index]).tag(index)
                        }
                    }
                    Picker("Year", selection: $selectedYearIndex) {
                        ForEach(0..<years.count, id: \.self) { index in
                            Text(String(years[index])).tag(index)
                        }
                    }
                }
                
                Section(header: Text("Category")) {
                    // user can select a catefory from a list
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
                    // user can add a new category
                    TextField("New Category", text: $newCategoryName)
                    if !newCategoryName.isEmpty {
                        Button("Add") {
                            Task {
                                await viewModel.addNewCategory(newCategoryName) { updatedCategory in
                                    selectedCategory = updatedCategory
                                }
                                // Clear the TextField after adding
                                newCategoryName = ""
                            }
                        }
                    }
                }
                .onAppear {
                    Task {
                        // fetches the category list
                        await viewModel.fetchCategories()
                    }
                }
                // sets the moth and year from the picker
                let selectedMonth = months[selectedMonthIndex]
                let selectedYear = years[selectedYearIndex]
                
                Button(action:  {
                    Task {
                        do {
                            // determins the category to be assgned to the new expense
                            let category = showingCategoryInput ? newCategoryName : selectedCategory
                            // adds the expense record to the database
                            await viewModel.addExpense(name: name, amount: amount, month: selectedMonth, year: selectedYear, category: category)
                            // fetched the updated category totals
                            await viewModel.fetchCategoryTotals(month: selectedMonth, year: selectedYear)
                            
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }) {
                    Text("Add Expense")
                        .disabled(!formIsValid)
                        .opacity(formIsValid ? 1.0 : 0.2)
                        .frame(width: 350, height: 50)
                        .foregroundColor(.black)
                        .font(.title)
                        .bold()
                        .cornerRadius(10)
                    
                }
                .listRowBackground(Color(red: 122/255, green: 229/255, blue: 130/255))
            }
            
        }
        .navigationTitle("Add Expense")
    }
    
}

// used to validate the expense form
extension AddExpenseView: ExpenseFormProtocol {
    var formIsValid: Bool{
        return !name.isEmpty
        && amount > 0
    }
}

struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthViewModel() 
        let viewModel = BudgetViewModel(authViewModel: authViewModel)
        
        return AddExpenseView(viewModel: viewModel)
            .environmentObject(authViewModel)
    }
}
