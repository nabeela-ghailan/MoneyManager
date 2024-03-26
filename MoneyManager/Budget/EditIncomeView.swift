//
//  EditIncomeView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 22/02/2024.
//

import SwiftUI

struct EditIncomeView: View {
    @ObservedObject var viewModel: BudgetViewModel
    var income: Income
    @State private var amount: Double
    @State private var name: String
    @State private var type: String
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    
    // sets the initial values
    init(viewModel: BudgetViewModel, income: Income) {
        self.viewModel = viewModel
        self.income = income
        _amount = State(initialValue: income.amount)
        _name = State(initialValue: income.name)
        _type = State(initialValue: income.type)
    }
    var body: some View {
        Form {
            Section(){
                TextField("Name", text: $name)
                
                TextField("Amount", value: $amount, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                
                TextField("Type", text: $type)
                
                Button("Update Income") {
                    Task {
                        await viewModel.updateIncome(id: income.id, name: name, amount: amount, month: income.month, year: income.year, type: type)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            Button("Delete Income") {
                self.alertMessage = "Are you sure you want to delete the income?"
                self.showAlert = true
            }
        }
        // alerts the user if delete button is pressed
        .alert(isPresented: $showAlert) {
            // Alert configuration
            Alert(title: Text("Delete Income?"),
                  message: Text(alertMessage),
                  primaryButton: .default(Text("Cancel") ),
                  secondaryButton: .destructive(Text("Delete")){
                Task {
                    do{
                        await viewModel.deleteIncome(id: income.id, month: income.month, year: income.year)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            })
        }
        .navigationTitle("Edit Income")
    }
}

