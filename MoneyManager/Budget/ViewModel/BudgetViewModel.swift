//
//  budgetViewModel.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 21/02/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

// protocol for validating the expense form
protocol ExpenseFormProtocol{
    var formIsValid: Bool {get}
}

@MainActor
class BudgetViewModel: ObservableObject {
    // user session only accessible within the class
    @MainActor private var userSession: User?
    @Published var categories: [String] = []
    @Published var totalIncome: Double = 0
    @Published var totalExpense: Double = 0
    @Published var incomes: [Income] = []
    @Published var expenses: [Expense] = []
    private let authViewModel: AuthViewModel
    private let db = Firestore.firestore()
    private var userId: String = ""
    @Published var categoryTotals: [CategoryTotal] = []
    
    // initialising the instance of the object
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }
    
   
    func fetchData(month: String, year: Int) async {
        await fetchCategories()
        await fetchIncome(month: month, year: year)
        await fetchExpenses(month: month, year: year)
        await fetchCategoryTotals(month: month, year: year)
    }
    
    // for addExpenseView
    func fetchCategories() async -> [String]? {
        do {
            guard let uid = Auth.auth().currentUser?.uid else {
                return nil
            }
            
            let categoriesRef = db.collection("users").document(uid).collection("categories")
            let snapshot = try await categoriesRef.getDocuments()
            // stores the category names in alphabethical order
            let fetchedCategories = snapshot.documents.compactMap { document -> String? in
                return document.data()["name"] as? String
            }.sorted(by: <)
            // updates the UI view
            DispatchQueue.main.async {
                self.categories = fetchedCategories
            }
            return fetchedCategories
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            return nil
        }
    }
    
    // fetches the expense records that matches the category in the parameter
    func fetchExpensesForCategory(month: String, year: Int, category: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let expensesPath = db.collection("users").document(uid).collection("expense").document(String(year)).collection(month).whereField("category", isEqualTo: category)
        do {
            let snapshot = try await expensesPath.getDocuments()
            // adds the expense to the expense array
            let expenses = snapshot.documents.compactMap { document -> Expense? in
                guard let name = document.data()["name"] as? String,
                      let amount = document.data()["amount"] as? Double,
                      let category = document.data()["category"] as? String else {
                    print("Document data does not match model: \(document.data())")
                    return nil
                }
                return Expense(id: document.documentID, name: name, amount: amount, month: month, year: year, category: category)
            }
            // updates the UI
            DispatchQueue.main.async {
                self.expenses = expenses
            }
        } catch {
            print("Error fetching expenses for category: \(error)")
        }
    }
    
    // calculates the total for each category
    func fetchCategoryTotals(month: String, year: Int) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            var categoryTotalsDict = [String: Double]()
            let snapshot = try await db.collection("users").document(uid).collection("expense").document(String(year)).collection(month).getDocuments()
            
            for document in snapshot.documents {
                guard let category = document.data()["category"] as? String,
                      let amount = document.data()["amount"] as? Double
                else { continue }
                // for each record the ammount is added to the array for the category name
                categoryTotalsDict[category, default: 0] += amount
            }
            // sorts the category names in alphabitical order
            let categoryTotals = categoryTotalsDict.map { CategoryTotal(name: $0.key, total: $0.value) }
                .sorted { $0.name.lowercased() < $1.name.lowercased() }
            // updates the UI
            DispatchQueue.main.async {
                self.categoryTotals = categoryTotals
            }
        } catch {
            print("Error fetching category totals: \(error)")
        }
    }
    
    // fetches the income total
    func fetchIncome(month: String, year: Int) async -> Double?{
        do {
            guard let uid = Auth.auth().currentUser?.uid else {
                return nil
            }
            // fetches income data based on month and year
            let querySnapshot = try await db.collection("users").document(uid)
                .collection("income").document(String(year))
                .collection(month).getDocuments()
            
            // Calculate total income
            var totalIncome: Double = 0
            for document in querySnapshot.documents {
                if let amount = document.data()["amount"] as? Double {
                    totalIncome += amount
                }
            }
            self.totalIncome = totalIncome
            return totalIncome
        } catch {
            print("Error fetching income: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    func fetchAllIncomesForSelectedMonthAndYear(month: String, year: Int) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await db.collection("users").document(uid).collection("income").document(String(year)).collection(month).getDocuments()
            // fetches the income record
            self.incomes = snapshot.documents.compactMap { doc -> Income? in
                var income = try? doc.data(as: Income.self)
                income?.id = doc.documentID
                return income
            }
        } catch {
            print("Error fetching incomes for selected month and year: \(error)")
        }
    }
    // fetches the expense total
    func fetchExpenses(month: String, year: Int) async -> Double? {
        do {
            guard let uid = Auth.auth().currentUser?.uid else {
                return nil
            }
            let querySnapshot = try await db.collection("users").document(uid)
                .collection("expense").document(String(year))
                .collection(month).getDocuments()
            
            var totalExpenses: Double = 0
            for document in querySnapshot.documents {
                if let amount = document.data()["amount"] as? Double {
                    totalExpenses += amount
                }
            }
            self.totalExpense = totalExpenses
            return totalExpenses
        } catch {
            print("Error fetching expenses: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    func addIncome(name: String, amount: Double, month: String, year: Int, type: String) async {
        do {
            // ensures that the current user is authenticated and has a valid user ID
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            // generates a unique ID for the income entry
            let newID = UUID().uuidString
            // stores the new income data
            let newIncome: [String: Any] = [
                "id": newID,
                "name": name,
                "amount": amount,
                "month": month,
                "year": year,
                "type": type
            ]
            // adds the new income data to the users 'income' collection organised by year and month
            try await db.collection("users").document(uid).collection("income").document(String(year)).collection(month).addDocument(data: newIncome)
            // updates the view to reflect the new entry
            await fetchIncome(month: month, year: year)
        } catch {
            print("Error adding income: \(error.localizedDescription)")
        }
    }
    
    func addExpense(name: String, amount: Double, month: String, year: Int, category: String) async{
        do {
            // ensures that the current user is authenticated and has a valid user ID
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            // generates a unique ID for the expense entry
            let newID = UUID().uuidString
            // stores the new expense data
            let newExpense: [String: Any] = [
                "id": newID,
                "name": name,
                "amount": amount,
                "month": month,
                "year": year,
                "category": category,
            ]
            // adds the new expense data to the users 'expense' collection organised by year and month
            try await db.collection("users").document(uid).collection("expense").document(String(year)).collection(month).addDocument(data: newExpense)
            // updates the view to reflect the new entry
            await fetchExpenses(month: month, year: year)
            await fetchCategoryTotals(month: month, year: year)
        } catch {
            print("Error adding expense: \(error.localizedDescription)")
        }
    }
    
    func addNewCategory(_ category: String, updateSelectedCategory: @escaping (String) -> Void) async {
        guard !categories.contains(category) else { return }
        do {
            await saveCategory(category)
            // UI updates to the main thread
            DispatchQueue.main.async {
                // Ensure that the category is still not added to avoid duplicates
                if !self.categories.contains(category) {
                    self.categories.append(category)
                }
                updateSelectedCategory(category)
            }
        }
    }
    
    // saves the category to the categories collection in the database
    private func saveCategory(_ category: String) async {
        do {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let categoryData: [String: Any] = ["name": category]
            try await db.collection("users").document(uid).collection("categories").addDocument(data: categoryData)
        } catch {
            print("Error saving category to Firestore: \(error.localizedDescription)")
        }
    }
    
    // deletes the category and the records for the at category
    func deleteCategory (month: String, year: Int, category: String) async{
        do{
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let expensesPath = db.collection("users").document(uid).collection("expense").document(String(year)).collection(month).whereField("category", isEqualTo: category)
            let snapshot = try await expensesPath.getDocuments()
            for document in snapshot.documents {
                let docId = document.documentID
                await deleteExpense(id: docId, month: month, year: year, category: category)
            }
            let categoriesRef = db.collection("users").document(uid).collection("categories")
            let querySnapshot = try? await categoriesRef.whereField("name", isEqualTo: category).getDocuments()
            if let doc = querySnapshot?.documents.first {
                try await doc.reference.delete()
                DispatchQueue.main.async {
                    if let index = self.categories.firstIndex(of: category) {
                        self.categories.remove(at: index)
                    }
                }
            }
            
            await fetchCategories()
        }
        catch {
            print("Error")
        }
    }
    
    
    func updateIncome(id: String, name: String, amount: Double, month: String, year: Int, type: String) async {
        do {
            // ensures current user is logged in and with a valid unique ID
            guard let uid = Auth.auth().currentUser?.uid else { return }
            // fetches the specified income record
            let incomeRef = db.collection("users").document(uid).collection("income").document(String(year)).collection(month).document(id)
            // attempts to updated the specific fields of the income document with new values
            try await incomeRef.updateData(
                [
                    "name": name,
                    "amount": amount,
                    "type": type
                    
                ])
            // updates the view with the changes made
            await fetchIncome(month: month, year: year)
        } catch {
            print("Error updating income: \(error.localizedDescription)")
        }
    }
    
    // deletes the income record
    func deleteIncome(id: String, month: String, year: Int) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let incomeRef = db.collection("users").document(uid).collection("income").document(String(year)).collection(month).document(id)
        
        do {
            try await incomeRef.delete()
            print("Income successfully deleted")
            await fetchAllIncomesForSelectedMonthAndYear(month: month, year: year)
        } catch {
            print("Error deleting income: \(error.localizedDescription)")
        }
    }
    
    func updateExpense(id: String, name: String, amount: Double, month: String, year: Int, category: String) async {
        do {
            // ensures current user is logged in and with a valid unique ID
            guard let uid = Auth.auth().currentUser?.uid else { return }
            // fetches the specific expense record
            let expenseRef = db.collection("users").document(uid).collection("expense").document(String(year)).collection(month).document(id)
            // attempts to updated the specific fields of the expense document with new values
            try await expenseRef.updateData(
                [
                    "name": name,
                    "amount": amount,
                    "category": category
                ])
            // updates the total for each category
            await fetchExpensesForCategory(month: month, year: year, category: category)
        } catch let error {
            print("Error updating expense: \(error.localizedDescription)")
        }
    }
    
    // deletes the expese record
    func deleteExpense(id: String, month: String, year: Int, category: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let expenseRef = db.collection("users").document(uid).collection("expense").document(String(year)).collection(month).document(id)
        
        do {
            try await expenseRef.delete()
            await fetchExpensesForCategory(month: month, year: year, category: category)
        } catch let error {
            print("Error deleting expense: \(error.localizedDescription)")
        }
    }
    
}


