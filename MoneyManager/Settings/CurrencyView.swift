//
//  CurrencyView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 04/03/2024.
//

import SwiftUI

struct CurrencyView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    let currencies = [
        ("AUD", "$"),
        ("BRL", "R$"),
        ("DKK", "kr"),
        ("HKD", "$"),
        ("JPY", "¥"),
        ("MAD", "Dhs"),
        ("INR", "₹"),
        ("CRC", "₡")
    ]
    @State private var selectedCurrencySymbol: String = ""
    
    // sorts the currency array with the selected one on top
    var sortedCurrencies: [(String, String)] {
        let selected = currencies.filter { $1 == selectedCurrencySymbol }
        let others = currencies.filter { $1 != selectedCurrencySymbol }
        return selected + others
    }
    
    var body: some View {
        VStack{
            Text("Select a currency")
                .font(.title)
                .bold()
            
            Spacer()
            // buttons with currency symbols that if pressed will update the currency symbol on the UI for the user
            Button(action: {
                selectedCurrencySymbol = "£"
                Task{
                    do{
                        try await viewModel.updateCurrencySymbol(currencySymbol: selectedCurrencySymbol)
                    }
                }
                
            }){
                VStack{
                    Text("£")
                    Text("GBP")
                    
                }
                .frame(width: 167, height: 91)
                .background(selectedCurrencySymbol == "£" ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0, green: 0.65, blue: 0.81))
                .cornerRadius(10)
                .foregroundColor(.black)
            }
            
            Spacer()
            
            Button(action: {
                selectedCurrencySymbol = "$"
                Task{
                    do{
                        try await viewModel.updateCurrencySymbol(currencySymbol: selectedCurrencySymbol)
                    }
                }
            }){
                VStack{
                    Text("$")
                    Text("USD")
                }
                .frame(width: 167, height: 91)
                .background(selectedCurrencySymbol == "$" ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0, green: 0.65, blue: 0.81))
                .cornerRadius(10)
                .foregroundColor(.black)
                
            }
            
            Spacer()
            
            Button(action: {
                selectedCurrencySymbol = "€"
                Task{
                    do{
                        try await viewModel.updateCurrencySymbol(currencySymbol: selectedCurrencySymbol)
                    }
                }
            }){
                VStack{
                    Text("€")
                    Text("EUR")
                }
                .frame(width: 167, height: 91)
                .background(selectedCurrencySymbol == "€" ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0, green: 0.65, blue: 0.81))
                .cornerRadius(10)
                .foregroundColor(.black)
                
            }
            
            Spacer()
            
            Text("Or select another currency:")
            // list of the currency array
            Picker("Currency", selection: $selectedCurrencySymbol) {
                ForEach(currencies, id: \.0) { currency in
                    Text("\(currency.0) (\(currency.1))").tag(currency.1)
                }
            }
            .pickerStyle(MenuPickerStyle())
            // if selected the currency symbol updates for the user
            .onChange(of: selectedCurrencySymbol) { newValue in
                Task {
                    do {
                        try await viewModel.updateCurrencySymbol(currencySymbol: newValue)
                    } catch {
                        print("Failed to update currency symbol: \(error)")
                    }
                }
            }
            Spacer()
            // when the view appears the selected currency symbol from the user's profile is shown
                .onAppear {
                    // Use a default value if none is set
                    self.selectedCurrencySymbol = viewModel.currentUser?.currency ?? "£"
                }
        }
    }
}


