//
//  budgetView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 15/02/2024.
//

import SwiftUI

struct budgetView: View {
    @StateObject private var viewModel: BudgetViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var categories: [String] = []
    @State private var showingIncomeForm = false
    @State private var showingExpenseForm = false
    //  @State private var showingCategoryDetails = false
    @State private var selectedCategory: String? = nil
    @State private var showingDetail = false
    @State private var selectedMonthIndex = Calendar.current.component(.month, from: Date()) - 1
    @State private var selectedYearIndex = Calendar.current.component(.year, from: Date()) - 2023
    
    let years = Array(2023...2033)
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    init(viewModel: BudgetViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        NavigationView{
            VStack {
                HStack{
                    Picker("Month", selection: $selectedMonthIndex) {
                        ForEach(0..<months.count, id: \.self) { index in
                            Text(months[index]).tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedMonthIndex) { _ in
                        fetchDataForSelectedDate()
                    }
                    
                    Picker("Year", selection: $selectedYearIndex) {
                        ForEach(0..<years.count, id: \.self) { index in
                            Text(String(years[index])).tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedYearIndex) { _ in
                        fetchDataForSelectedDate()
                    }
                }
                .padding()
                
                // displays the budget for the selected month and year
                Rectangle()
                    .fill(Color(red: 0, green: 0.65, blue: 0.81))
                    .frame(width: 350, height: 150)
                    .cornerRadius(10)
                    .overlay(
                        VStack{
                            Text("Available Budget")
                            Spacer()
                            Text("\(authViewModel.currentUser?.currency ?? "£") " + String(format: "%.2f", viewModel.totalIncome - viewModel.totalExpense))
                            
                        }
                            .padding()
                            .font(.system(size: 36))
                            .font(.title2)
                            .bold()
                    )
                // displays the income total for the selected month and year and navigates to add income form
                HStack{
                    Spacer()
                    NavigationLink(destination: AddIncomeView(viewModel: viewModel)) {
                        ZStack(alignment: .bottomTrailing){
                            VStack(alignment: .leading){
                                
                                Text("Income:")
                                Text("\(authViewModel.currentUser?.currency ?? "£") \(String(format: "%.2f", viewModel.totalIncome))")
                                
                                Spacer()
                            }
                            .padding(.top, 10)
                            .padding(.trailing, 30)
                            .font(.system(size: 25))
                            
                            
                            Image(systemName: "plus.circle")
                                .resizable()
                                .padding(.bottom, 10)
                                .frame(width: 24, height: 35)
                        }
                    }
                    .onAppear{
                        fetchIncome(month: months[selectedMonthIndex], year: years[selectedYearIndex])
                    }
                    .frame(width: 160, height: 110)
                    .background(Color(red: 0.37, green: 0.93, blue: 0.5))
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    
                    
                    Spacer(minLength: 25)
                    
                    // displays the expense totals for the selected month and year and navigates to add expense form
                    NavigationLink(destination: AddExpenseView(viewModel: viewModel)) {
                        ZStack(alignment: .bottomTrailing){
                            VStack{
                                Text("Expense:")
                                Text("\(authViewModel.currentUser?.currency ?? "£") " + String(format: "%.2f", viewModel.totalExpense))
                                Spacer()
                            }
                            .padding(.top, 10)
                            .padding(.trailing, 30)
                            .font(.system(size: 25))
                            
                            
                            Image(systemName: "plus.circle")
                                .resizable()
                                .padding(.bottom, 10)
                                .frame(width: 24, height: 35)
                            
                        }
                        
                    }
                    .onAppear{
                        fetchCategories()
                        fetchExpense(month: months[selectedMonthIndex], year: years[selectedYearIndex])
                    }
                    .frame(width: 160, height: 110)
                    .background(Color(red: 0.92, green: 0.41, blue: 0.41))
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .bold()
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    
                    Spacer()
                }
                .padding()
                
                // displays the list of categories and their total. navigates to view records of expensed associated with the category
                List(viewModel.categoryTotals) { categoryTotal in
                    NavigationLink(destination: ExpenseDetailView(viewModel: viewModel, category: categoryTotal.name, selectedMonth: months[selectedMonthIndex], selectedYear: years[selectedYearIndex])) {
                        HStack{
                            Text(categoryTotal.name)
                            Spacer()
                            Text("\(authViewModel.currentUser?.currency ?? "£") \(categoryTotal.total, specifier: "%.2f")")
                        }
                        
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.fetchCategoryTotals(month: months[selectedMonthIndex], year: years[selectedYearIndex])
                    }
                }
            }
        }
        .onAppear {
            fetchDataForSelectedDate()
        }
    }
    
    private func fetchDataForSelectedDate() {
        let selectedMonth = months[selectedMonthIndex]
        let selectedYearValue = years[selectedYearIndex]
        Task {
            await viewModel.fetchData(month: selectedMonth, year: selectedYearValue)
        }
    }
    
    private func fetchIncome(month: String, year: Int)  {
        Task{
            await viewModel.fetchIncome(month: months[selectedMonthIndex], year: years[selectedYearIndex])
        }
    }
    
    private func fetchCategories()  {
        Task{
            if let fetchedCategories = await viewModel.fetchCategories() {
                DispatchQueue.main.async {
                    self.categories = fetchedCategories
                }
            }
        }
    }
    
    private func fetchExpense(month: String, year: Int)   {
        Task{
            await viewModel.fetchExpenses(month: month, year: year)
        }
    }
}

struct budgetView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthViewModel()
        let viewModel = BudgetViewModel(authViewModel: authViewModel)
        return budgetView(viewModel: viewModel)
            .environmentObject(authViewModel)
    }
}
