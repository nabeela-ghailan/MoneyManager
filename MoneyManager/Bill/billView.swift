//
//  billView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 28/02/2024.
//

import SwiftUI

struct billView: View {
    @StateObject private var viewModel: BillViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedMonthIndex = Calendar.current.component(.month, from: Date()) - 1
    @State private var selectedYearIndex = Calendar.current.component(.year, from: Date()) - 2023
    @State private var date = Date()
    @State private var selectedBill: Bill?
    @State private var showingDetail = false
    @State private var dateSelected: DateComponents?
    let years = Array(2023...2033)
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let daysOfWeek = Calendar.current.shortWeekdaySymbols
    
    init(viewModel: BillViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        NavigationView{
            VStack{
                
                Text("Your Bills")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                // month and year selector
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
                    .onChange(of: selectedMonthIndex) { _ in
                        fetchDataForSelectedDate()
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // calendar UI
                HStack {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(20)
                // displays the dates of the month in a grid
                VStack{
                    let selectedDate = Calendar.current.date(from: DateComponents(year: years[selectedYearIndex], month: selectedMonthIndex + 1))
                    let daysInMonth = selectedDate.map { Calendar.current.range(of: .day, in: .month, for: $0)?.count ?? 0 } ?? 0
                    let firstDayOfMonth = selectedDate.map { Calendar.current.component(.weekday, from: $0) } ?? 7
                    let offset = firstDayOfMonth - Calendar.current.firstWeekday
                    // makes sure this is possitive to align the first day of the month correctly
                    let adjustedOffset = offset < 0 ? (7 + offset) : offset
                    let totalDays = daysInMonth + adjustedOffset
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                        // for each day in the month
                        ForEach(0..<totalDays, id: \.self) { index in
                            if index >= adjustedOffset {
                                // Adjust day calculation to start from 1
                                let day = index - adjustedOffset + 1
                                // attempts to find a bill for this day and of there is allows the user to tap to view the bill detail
                                if let billForDay = getBillForDay(day) {
                                    DayView(day: day, bill: billForDay) { selectedBill in
                                        self.selectedBill = selectedBill
                                        self.showingDetail = true
                                    }
                                } else {
                                    // if no bill the day is viewed without a bill
                                    DayView(day: day, bill: nil) { _ in }
                                }
                            } else {
                                // Empty cells for days before the first of the month
                                Text("")
                            }
                        }
                    }
                    
                }
                .padding()
                Spacer()
                
                // list the next two upcoming bills
                Rectangle()
                    .fill(Color(red: 0, green: 0.65, blue: 0.81))
                    .frame(maxWidth: 350, maxHeight: 260, alignment: .leading)
                    .cornerRadius(10)
                    .overlay(
                        VStack(alignment: .leading) {
                            Text("Upcoming Bills")
                                .font(.title2)
                                .bold()
                                .padding(.bottom, 5)
                            LazyVStack {
                                ForEach(viewModel.upcomingBills) { bill in
                                    NavigationLink(destination: BillDetailView(viewModel: viewModel, bill: bill)) {
                                        HStack{
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
                                            Text("\(authViewModel.currentUser?.currency ?? "£") \(bill.amount, specifier: "%.2f")")
                                            
                                        }
                                        .padding(10)
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                    }
                                    .onTapGesture {
                                        Task {
                                            await viewModel.fetchSelectedBill(id: bill.id, year: bill.year, month: bill.month)
                                        }
                                    }
                                }
                            }
                            
                            .background(Color(red: 0, green: 0.65, blue: 0.81))
                            .cornerRadius(10)
                        }
                            .padding(20)
                            .frame(maxWidth: 350, maxHeight: 260, alignment: .leading)
                    )
                
                NavigationLink(destination: AddBillView(viewModel: viewModel)) {
                    HStack{
                        Text("Add a New Bill")
                            .padding(.leading)
                            .foregroundColor(.black)
                            .font(.title)
                            .bold()
                        
                        Spacer()
                        
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                            .padding(.trailing, 20)
                    }
                    .frame(width: 300, height: 60)
                    .background(Color(red: 122/255, green: 229/255, blue: 130/255))
                    .cornerRadius(10)
                    .padding()
                    .minimumScaleFactor(0.5)
                }
            }
        }
        // fetches the bill to update UI
        .onAppear {
            Task {
                await viewModel.fetchBillsForMonth(year: years[selectedYearIndex], month: months[selectedMonthIndex])
                await viewModel.fetchUpcomingBills()
            }
        }
        // if bill is selected, it navigates to bill detail view
        .sheet(isPresented: $showingDetail) {
            if let selectedBill = selectedBill {
                BillDetailView(viewModel: viewModel, bill: selectedBill)
            }
        }
    }
    
    private func getBillForDay(_ day: Int) -> Bill? {
        // convert the selected month index to the corresponding month name
        let selectedMonthName = months[selectedMonthIndex]
        // fetches the bill for the selected day, month, and year
        return viewModel.monthlyBills.first { bill in
            return bill.day == day && bill.month == selectedMonthName && bill.year == years[selectedYearIndex]
        }
    }
    
    // fetches the data
    private func fetchDataForSelectedDate() {
        let selectedMonth = months[selectedMonthIndex]
        let selectedYearValue = years[selectedYearIndex]
        Task {
            await viewModel.fetchBillsForMonth(year: selectedYearValue, month: selectedMonth)
        }
    }
    
    // calculates the days when when the bill is due
    private func daysUntilDue(for bill: Bill) -> Int? {
        let calendar = Calendar.current
        // Directly create dueDate from bill information
        guard let monthNumber = Date.monthNumber(from: bill.month),
              let dueDate = calendar.date(from: DateComponents(year: bill.year, month: monthNumber, day: bill.day)) else {
            return nil
        }
        
        // sets both today and dueDate to their start of the day to ignore time components
        let todayStart = calendar.startOfDay(for: Date())
        let dueDateStart = calendar.startOfDay(for: dueDate)
        
        // Calculate the difference in days
        let components = calendar.dateComponents([.day], from: todayStart, to: dueDateStart)
        return components.day
    }
}

// represents a single day in the calendar
struct DayView: View {
    var day: Int
    let bill: Bill?
    let action: (Bill) -> Void // gets called when a day with a bill is tapped
    
    var body: some View {
        Text("\(day)")
            .padding(5)
        // if there is a bill for that day then it is indicated as red
            .background(bill != nil ? Color.red : Color.clear) // Highlight if there's a bill
            .clipShape(Circle())
            .foregroundColor(.black)
            .onTapGesture {
                if let bill = bill {
                    action(bill)
                }
            }
    }
}


struct billView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthViewModel()
        let viewModel = BillViewModel(authViewModel: authViewModel)
        return billView(viewModel: viewModel)
            .environmentObject(authViewModel)
    }
}
