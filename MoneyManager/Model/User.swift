//
//  User.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 14/02/2024.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let currency: String
    }


