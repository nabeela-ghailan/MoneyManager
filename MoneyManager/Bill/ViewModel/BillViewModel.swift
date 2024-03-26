//
//  BillViewModel.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 28/02/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

@MainActor
class BillViewModel: ObservableObject{
    @MainActor private var userSession: User?
    private let authViewModel: AuthViewModel
    private let db = Firestore.firestore()
    @Published var selectedBill: Bill?
    @Published var upcomingBills: [Bill] = []
    @Published var monthlyBills: [Bill] = []
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }
    
    // converts the month name to its number form
    func monthNumber(from monthName: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM" // Month format as full month name
        guard let date = dateFormatter.date(from: monthName) else { return nil }
        return Calendar.current.component(.month, from: date)
    }
    
    // fetches the bills for the selected month and year
    func fetchBillsForMonth(year: Int, month: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let billPath = db.collection("users").document(uid).collection("bills").document(String(year)).collection(month)
        do {
            let snapshot = try await billPath.getDocuments()
            // manually maps the data from the fields to the array
            let fetchedMonthlyBills = snapshot.documents.compactMap { document -> Bill? in
                guard let name = document.data()["name"] as? String,
                      let amount = document.data()["amount"] as? Double,
                      let day = document.data()["day"] as? Int,
                      let month = document.data()["month"] as? String,
                      let year = document.data()["year"] as? Int,
                      let accountNumber = document.data()["accountNumber"] as? String,
                      let paymentLink = document.data()["paymentLink"] as? String,
                      let billRepeats = document.data()["billRepeats"] as? String,
                      let notification = document.data()["notification"] as? Bool else {
                    print("Document data does not match model: \(document.data())")
                    return nil
                }
                return Bill(id: document.documentID, name: name, accountNumber: accountNumber, amount: amount, day: day, month: month, year: year, paymentLink: paymentLink, billRepeats: billRepeats, notification: notification)
            }
            self.monthlyBills = fetchedMonthlyBills
            await fetchUpcomingBills()
            
        } catch {
            print("Error fetching bills for month: \(error.localizedDescription)")
        }
    }
    
    // adds the new bill record to the database
    func addBill(name: String, accountNumber: String, amount: Double, day: Int, month: String, year: Int,
                 paymentLink: String, billRepeats: String, notification: Bool) async {
        do {
            // ensures current user is logged in and with a valid unique ID
            guard let uid = Auth.auth().currentUser?.uid else {return}
            // generates a unique ID for the bill entry
            let newID = UUID().uuidString
            // stores the new bill data
            let newBill: [String: Any] = [
                "id": newID,
                "name": name,
                "accountNumber": accountNumber,
                "amount": amount,
                "day": day,
                "month": month,
                "year": year,
                "paymentLink": paymentLink,
                "billRepeats": billRepeats,
                "notification": notification
            ]
            // adds the new bill data to the users 'bills' collection organised by year and month
            try await db.collection("users").document(uid).collection("bills").document(String(year))
                .collection(month).addDocument(data: newBill)
            // updates view to reflect the new entry
            await fetchBillsForMonth(year: year, month: month)
            await fetchUpcomingBills()
        } catch {
            print("Error adding income: \(error.localizedDescription)")
        }
    }
    
    // fetches the next two upcoming bills
    func fetchUpcomingBills() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM" // Format for month names
        let currentMonthName = dateFormatter.string(from: today)
        let calendar = Calendar.current
        let year = calendar.component(.year, from: today)
        let billPath = db.collection("users").document(uid).collection("bills").document(String(year)).collection(currentMonthName)
        
        do {
            let snapshot = try await billPath.getDocuments()
            let upcomingBills = snapshot.documents.compactMap { document -> Bill? in
                guard let name = document.data()["name"] as? String,
                      let amount = document.data()["amount"] as? Double,
                      let day = document.data()["day"] as? Int,
                      let month = document.data()["month"] as? String,
                      let year = document.data()["year"] as? Int,
                      let accountNumber = document.data()["accountNumber"] as? String,
                      let paymentLink = document.data()["paymentLink"] as? String,
                      let billRepeats = document.data()["billRepeats"] as? String,
                      let notification = document.data()["notification"] as? Bool else {
                    print("Document data does not match model: \(document.data())")
                    return nil
                }
                return Bill(id: document.documentID, name: name, accountNumber: accountNumber, amount: amount, day: day, month: month, year: year, paymentLink: paymentLink, billRepeats: billRepeats, notification: notification)
            }
            
            // filters the bills for the those after or on the current day
            let filteredBills = upcomingBills.filter { bill -> Bool in
                guard let billDate = Calendar.current.date(from: DateComponents(year: bill.year, month: Int(bill.month), day: bill.day)) else { return false }
                let isUpcoming = billDate <= today
                return isUpcoming
            }
            // sorts based on ascending order
                .sorted {
                    guard let date1 = Calendar.current.date(from: DateComponents(year: $0.year, month: Int($0.month), day: $0.day)),
                          let date2 = Calendar.current.date(from: DateComponents(year: $1.year, month: Int($1.month), day: $1.day)) else { return false }
                    return date1 < date2
                }
            //only first two entries from the sorted list
                .prefix(2)
            
            DispatchQueue.main.async {
                self.upcomingBills = Array(filteredBills)
            }
        } catch {
            print("Error fetching bills: \(error)")
        }
    }
    
    func fetchSelectedBill(id: String, year: Int, month: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let billRef = db.collection("users").document(uid).collection("bills").document(String(year)).collection(month).document(id)
        do {
            let documentSnapshot = try await billRef.getDocument()
            if documentSnapshot.exists {
                // gets the bill data fromthe record
                let selectedBill = try documentSnapshot.data(as: Bill.self)
                DispatchQueue.main.async {
                    // updates the selected bill
                    self.selectedBill = selectedBill
                }
            } else {
                print("Document does not exist")
            }
        } catch {
            print("Error fetching selected bill: \(error)")
        }
    }
    
    // updates the bill record on the database
    func editBill(id: String, name: String, accountNumber: String, amount: Double, day: Int, month: String, year: Int, paymentLink: String, billRepeats: String, notification: Bool) async {
        do{
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let billRef = db.collection("users").document(uid).collection("bills").document(String(year)).collection(month).document(id)
            do{
                try await billRef.updateData(
                    [
                        "name": name,
                        "accountNumber": accountNumber,
                        "amount": amount,
                        "day": day,
                        "month": month,
                        "year": year,
                        "paymentLink": paymentLink,
                        "billRepeats": billRepeats,
                        "notification": notification
                    ])
                // updates the UI
                await fetchSelectedBill(id: id, year: year, month: month)
                await fetchBillsForMonth(year: year, month: month)
                await fetchUpcomingBills()
            }
        }
        catch let error {
            print("Error updating bill: \(error.localizedDescription)")
        }
    }
    
    // deletes the bill record from the database
    func deleteBill(id: String, year: Int, month: String) async{
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let billRef = db.collection("users").document(uid).collection("bills").document(String(year)).collection(month).document(id)
        
        do{
            try await billRef.delete()
            await fetchBillsForMonth(year: year, month: month)
            await fetchUpcomingBills()
        }  catch let error {
            print("Error deleting bill: \(error.localizedDescription)")
        }
        
    }
    
}
