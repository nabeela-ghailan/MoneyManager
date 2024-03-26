//
//  Bill.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 25/02/2024.
//

import Foundation

struct Bill: Identifiable, Codable {
    var id: String
    var name: String
    var accountNumber: String
    var amount: Double
    var day: Int
    var month: String
    var year: Int
    var paymentLink: String
    var billRepeats: String
    var notification: Bool
}
// converts the string from of the month into integer. for example, 1 for January
extension Date {
    static func monthNumber(from monthName: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        guard let date = dateFormatter.date(from: monthName) else { return nil }
        let calendar = Calendar.current
        return calendar.component(.month, from: date)
    }
    
}
