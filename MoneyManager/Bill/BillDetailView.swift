//
//  BillDetailView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 28/02/2024.
//

import SwiftUI

struct BillDetailView: View {
    @ObservedObject var viewModel: BillViewModel
    @EnvironmentObject var aViewModel: AuthViewModel
    @State private var showingEditView = false
    var bill: Bill
    
    var body: some View {
        // shows details of the bill
        Form{
            Section(){
                
                VStack(alignment: .leading){
                    Text("Name: \(bill.name)")
                    Text("Account number: \(bill.accountNumber)")
                    Text("Amount: \(aViewModel.currentUser?.currency ?? "£") \(bill.amount, specifier: "%.2f")")
                    Text("Due Date: \(bill.day) \(bill.month) \(String(bill.year))")
                }
            }
            
            // button to allow users to edit the bill
            Button("Edit Bill") {
                showingEditView = true
                
            }
            .navigationTitle("Bill Details")
            .navigationBarItems(trailing: Button(action: {
                showingEditView = true
            }) {
                Text("Edit")
            })
        }
        .sheet(isPresented: $showingEditView) {
            EditBillView(viewModel: viewModel, bill: bill)
        }
    }
    
}




