//
//  homeView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 14/02/2024.
//

import SwiftUI



struct homeView: View {
    @State private var currentMonthAndYear: String = ""
    // access the shared data across the views
    @EnvironmentObject var bViewModel: BudgetViewModel
    @EnvironmentObject var aViewModel: AuthViewModel
    @EnvironmentObject var biViewModel: BillViewModel
    let currentYear: Int
    let currentMonth: String
    let yearString: String
    
    // sets up the initial state of the view
    init() {
        let currentDate = Date()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        
        // Extract year as integer
        currentYear = calendar.component(.year, from: currentDate)
        yearString = String(currentYear)
        // Extract month as string
        dateFormatter.dateFormat = "MMMM" // Format for full month name
        currentMonth = dateFormatter.string(from: currentDate)
    }
    
    var body: some View {
        
        VStack{
            
            Text("Hello")
                .font(.title)
                .bold()
            
            // checks if current user first name exists
            if let firstName = aViewModel.currentUser?.firstName {
                Text("\(firstName)!")
                    .font(.title)
                    .bold()
            } else {
                Text("User")
                    .font(.title2)
                    .bold()
            }
            Rectangle()
                .fill(Color(red: 0, green: 0.65, blue: 0.81))
                .frame(width: 350, height: 150)
                .cornerRadius(10)
                .overlay(
                    VStack{
                        Text("Available Budget")
                        Spacer()
                        // displays the user's chosen currency symbol and their total budget
                        Text("\(aViewModel.currentUser?.currency ?? "£") " + String(format: "%.2f", bViewModel.totalIncome - bViewModel.totalExpense))
                        HStack {
                            Spacer()
                            Text("\(currentMonth) \(yearString)")
                                .foregroundColor(.white) // Text color
                            
                                .padding(.trailing, 5) // Padding around the text
                                .font(.subheadline)
                        }
                        
                    }
                        .padding()
                        .font(.system(size: 36))
                        .font(.title2)
                        .bold()
                )
            
            
            HStack{
                Spacer()
                Rectangle()
                    .fill(Color(red: 0.37, green: 0.93, blue: 0.5))
                    .frame(width: 160, height: 100)
                    .cornerRadius(10)
                    .overlay(
                        VStack{
                            Text("Income:")
                            // displays the total amount of income
                            Text("\(aViewModel.currentUser?.currency ?? "£") " + (String(format: "%.2f", bViewModel.totalIncome)))
                        }
                    )
                
                Spacer(minLength: 25)
                Rectangle()
                    .fill(Color(red: 0.92, green: 0.41, blue: 0.41))
                    .cornerRadius(10)
                    .frame(width: 160, height: 100)
                    .cornerRadius(10)
                    .overlay(
                        VStack{
                            Text("Expense:")
                            // displays the total amount of expense
                            Text("\(aViewModel.currentUser?.currency ?? "£") " + String(format: "%.2f", bViewModel.totalExpense))
                        }
                        
                    )
                Spacer()
                
                    .font(.title)
                    .padding(.bottom)
                
            }
            .padding()
            
            Rectangle()
                .fill(Color(red: 0, green: 0.65, blue: 0.81))
                .frame(maxWidth: 350, maxHeight: 250, alignment: .leading)
                .cornerRadius(10)
                .overlay(
                    VStack (alignment: .leading){
                        Text("Upcoming Bills")
                            .font(.title2)
                            .bold()
                            .padding(.top, 10)
                            .padding(.bottom, 2)
                        
                        // displays a list of the next two upcoming bills
                        LazyVStack {
                            ForEach(biViewModel.upcomingBills) { bill in
                                HStack{
                                    // calculates how many days left until bill is due
                                    if let daysUntilDue = daysUntilDue(for: bill) {
                                        if daysUntilDue == 1{
                                            VStack{
                                                Text("\(daysUntilDue) day")
                                                Text("left")
                                            }
                                            .foregroundColor(.red)
                                        }else{
                                            VStack{
                                                Text("\(daysUntilDue) days")
                                                Text("left")
                                            }
                                            .foregroundColor(daysUntilDue <= 7 ? .red : .green)
                                        }
                                        
                                    }
                                    Spacer()
                                    Text(bill.name)
                                    Spacer()
                                    // displays the bill amount
                                    Text("\(aViewModel.currentUser?.currency ?? "£") \(bill.amount, specifier: "%.2f")")
                                    
                                }
                                .padding(15)
                                .cornerRadius(10)
                                .background(Color.white)
                            }
                            .listStyle(PlainListStyle()) // PlainListStyle for more control
                            .background(Color(red: 0, green: 0.65, blue: 0.81))
                            .cornerRadius(10)
                            .padding(7)
                            Spacer()
                        }
                        Spacer()
                    }
                        .frame(maxWidth: 350, maxHeight: 250, alignment: .leading)
                        .padding()
                    
                )
        }
        
        // fetches the data to appear on view
        .onAppear{
            Task{
                await bViewModel.fetchData(month: currentMonth,year:currentYear)
                await biViewModel.fetchUpcomingBills()
                await aViewModel.fetchUser()
            }
        }
    }
    
    // function calculates how many days until the bill is due
    private func daysUntilDue(for bill: Bill) -> Int? {
        let calendar = Calendar.current
        
        // Directly create dueDate from bill information
        guard let monthNumber = Date.monthNumber(from: bill.month),
              let dueDate = calendar.date(from: DateComponents(year: bill.year, month: monthNumber, day: bill.day)) else {
            return nil
        }
        
        // Normalize both today and dueDate to their start of the day to ignore time components
        let todayStart = calendar.startOfDay(for: Date())
        let dueDateStart = calendar.startOfDay(for: dueDate)
        
        // Calculate the difference in days
        let components = calendar.dateComponents([.day], from: todayStart, to: dueDateStart)
        return components.day
    }
}




// provides a preview before running the application
struct homeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = BudgetViewModel(authViewModel: AuthViewModel())
        let biViewModel = BillViewModel(authViewModel: AuthViewModel())
        homeView()
            .environmentObject(viewModel) // Add viewModel as an environment object
            .environmentObject(AuthViewModel())
            .environmentObject(biViewModel)
    }
}
