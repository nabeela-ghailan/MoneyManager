//
//  Income.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 21/02/2024.
//

import Foundation

struct Income: Identifiable, Codable {
    var id: String
    var name: String
    var amount: Double
    var month: String
    var year: Int
    var type: String
}


