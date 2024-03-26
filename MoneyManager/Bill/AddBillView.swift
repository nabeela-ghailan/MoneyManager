//
//  AddBillView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 28/02/2024.
//

import SwiftUI

struct AddBillView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BillViewModel
    @EnvironmentObject var aViewModel: AuthViewModel
    @State private var name: String = ""
    @State private var accountNumber: String = ""
    @State private var amount: Double = 0
    @State private var date = Date()
    @State private var paymentLink: String = ""
    @State private var billRepeats = "Never"
    @State private var notificationEnabled = false
    
    let billRepeatOptions = ["Never", "Weekly", "Fortnightly", "Monthly", "Semi-Annually", "Annually"]
    
    var body: some View {
        // form to add a new bill
        Form {
            
            Section(header: Text("Bill Information")) {
                TextField("Name", text: $name)
                TextField("Account Number", text: $accountNumber)
                    .keyboardType(.numberPad)
                TextField("Amount", value: $amount, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                TextField("Payment Link", text: $paymentLink)
            }
            Section(header: Text("Bill Repeat")) {
                Picker("Repeats", selection: $billRepeats) {
                    ForEach(billRepeatOptions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            Section {
                Toggle("Enable Notification", isOn: $notificationEnabled)
            }
            // attemps to add the new bill record to the database
            Section {
                Button("Save Bill") {
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.day, .month, .year], from: date)
                    guard let day = components.day, let month = components.month, let year = components.year else { return }
                    // Getting month name from month number
                    let monthName = DateFormatter().monthSymbols[month - 1]
                    Task{
                        do{
                            await viewModel.addBill(name: name, accountNumber: accountNumber, amount: amount, day: day, month: monthName, year: year, paymentLink: paymentLink, billRepeats: billRepeats, notification: notificationEnabled)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle("Add A New Bill")
    }
}
struct AddBillView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthViewModel()
        let viewModel = BillViewModel(authViewModel: authViewModel)
        return AddBillView(viewModel: viewModel)
            .environmentObject(authViewModel)
    }
}
