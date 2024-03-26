//
//  AddIncomeView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 21/02/2024.
//

import SwiftUI

struct AddIncomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetViewModel
    @State private var amount: Double = 0
    @State private var name: String = ""
    @State private var type: String = ""
    @State private var selectedMonthIndex: Int = Calendar.current.component(.month, from: Date()) - 1
    @State private var selectedYearIndex: Int = Calendar.current.component(.year, from: Date()) - 2023
    @State private var showEditIncomeView: Bool = false
    
    
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let years = Array(2023...2030)
    
    var body: some View {
        
        Form{
            Section() {
                TextField("Name", text: $name)
                
                TextField("Amount", value: $amount, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                
                TextField("Type", text: $type)
                
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
            // sets the month and year from the picker
            let selectedMonth = months[selectedMonthIndex]
            let selectedYear = years[selectedYearIndex]
            
            // adds the income to the database
            Section() {
                Button(action:  {
                    Task{
                        do{
                            await viewModel.addIncome(name: name, amount: amount, month: selectedMonth, year: selectedYear, type: type)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                })
                {
                    Text("Add Income")
                        .disabled(amount <= 0)
                        .opacity(amount > 0 ? 1.0 : 0.2)
                        .frame(width: 350, height: 50)
                        .foregroundColor(.black)
                        .font(.title)
                        .bold()
                        .cornerRadius(10)
                    
                }
                .listRowBackground(Color(red: 122/255, green: 229/255, blue: 130/255))
            }
            
            // navigates to the select income view to select an income to edit
            NavigationLink(destination:  SelectIncomeView(viewModel: viewModel, selectedMonth: months[selectedMonthIndex], selectedYear: years[selectedYearIndex])){
                Text("Edit Existing Income")
                
            }
            .onAppear{
                Task{
                    do{
                        // fetches the incomes
                        await viewModel.fetchAllIncomesForSelectedMonthAndYear(month: months[selectedMonthIndex], year: years[selectedYearIndex])
                    }
                }
            }
        }
        .navigationTitle("Add A New Income")
    }
}

struct AddIncomeView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthViewModel()
        let viewModel = BudgetViewModel(authViewModel: authViewModel)
        
        return AddIncomeView(viewModel: viewModel)
            .environmentObject(authViewModel)
    }
}
