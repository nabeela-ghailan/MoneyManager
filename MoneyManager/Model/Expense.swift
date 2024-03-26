//
//  Expense.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 22/02/2024.
//

import Foundation

struct Expense: Identifiable, Codable {
    var id: String
    var name: String
    var amount: Double
    var month: String
    var year: Int
    var category: String
}
