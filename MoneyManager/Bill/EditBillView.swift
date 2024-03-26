//
//  EditBillView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 03/03/2024.
//

import SwiftUI

struct EditBillView: View {
    @ObservedObject var viewModel: BillViewModel
    var bill: Bill
    @State private var name: String
    @State private var accountNumber: String
    @State private var amount: Double
    @State private var date: Date
    @State private var paymentLink: String
    @State private var billRepeats: String
    @State private var notification: Bool
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let billRepeatOptions = ["Never", "Weekly", "Fortnightly", "Monthly", "Semi-Annually", "Annually"]
    
    // sets the initial state
    init(viewModel: BillViewModel, bill: Bill) {
        self.viewModel = viewModel
        self.bill = bill
        _name = State(initialValue: bill.name)
        _accountNumber = State(initialValue: bill.accountNumber)
        _amount = State(initialValue: bill.amount)
        _paymentLink = State(initialValue: bill.paymentLink)
        _billRepeats = State(initialValue: bill.billRepeats)
        _notification = State(initialValue: bill.notification)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let dateString = "\(bill.day) \(bill.month) \(bill.year)"
        let billDate = dateFormatter.date(from: dateString) ?? Date()
        _date = State(initialValue: billDate)
    }
    
    var body: some View {
        // form to allow users to update their bill detail
        Form {
            Section(header: Text("Bill Information")){
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
                Toggle("Enable Notification", isOn: $notification)
            }
            Section {
                // attempts to update the bill record to the database
                Button("Save") {
                    print(bill)
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.day, .month, .year], from: date)
                    guard let day = components.day, let month = components.month, let year = components.year else { return }
                    // Getting month name from month number
                    let monthName = DateFormatter().monthSymbols[month - 1]
                    Task{
                        await viewModel.editBill(id: bill.id, name: name, accountNumber: accountNumber, amount: amount, day: day, month: monthName, year: year, paymentLink: paymentLink, billRepeats: billRepeats, notification: notification)
                        // updates the UI
                        await viewModel.fetchSelectedBill(id: bill.id, year: year, month: monthName)
                        await viewModel.fetchBillsForMonth(year: year, month: monthName)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            
            Button("Delete Bill") {
                self.alertMessage = "Are you sure you want to delete the bill?"
                self.showAlert = true
            }
        }
        // alerts the user if delete button is selected
        .alert(isPresented: $showAlert) {
            // Alert configuration
            Alert(title: Text("Delete bill?"),
                  message: Text(alertMessage),
                  primaryButton: .default(Text("Cancel") ),
                  secondaryButton: .destructive(Text("Delete")){
                Task {
                    do{
                        await viewModel.deleteBill(id: bill.id, year: bill.year, month: bill.month)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            })
        }
        
        .navigationBarTitle(Text("Edit Bill"), displayMode: .inline)
    }
}


