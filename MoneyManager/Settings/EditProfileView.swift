//
//  EditProfileView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 04/03/2024.
//

import SwiftUI

struct EditProfileView: View {
    // allows the view to react to changes
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String
    @State private var firstName: String
    @State private var lastName: String
    @State private var password: String = ""
    @State private var newPassword: String = ""
    @State private var currency: String
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // sets the initial state of the user properties
    init(viewModel: AuthViewModel, user: User) {
        self.viewModel = viewModel
        
        _firstName = State(initialValue: user.firstName)
        _lastName = State(initialValue: user.lastName)
        _email = State(initialValue: user.email)
        _currency = State(initialValue: user.currency)
    }
    
    var body: some View {
        
        Form {
            Section(header: Text("Personal Information")) {
                TextField("First name", text: $firstName)
                TextField("Last name", text: $lastName)
                TextField("Email", text: $email)
            }
            Section(header: Text("Please enter your current password to change password")){
                
                SecureField("Current Password", text: $password)
                // if password field not empty the user can enter a new password
                if !password.isEmpty {
                    SecureField("New Password", text: $newPassword)
                }
            }
            
            Button("Update Profile") {
                Task {
                    do{
                        // reauthenticates the user before updating details
                        try await viewModel.reauthenticateUser(currentPassword: password)
                        try await viewModel.updateUserProfile(firstName: firstName, lastName: lastName, email: email, currentPassword: password, newPassword: newPassword, currency: currency)
                        presentationMode.wrappedValue.dismiss()
                    }
                    catch {
                        // If reauthentication fails, show an alert
                        showAlert = true
                        alertMessage = "Current password does not match. Please try again."
                    }
                }
            }.disabled(!formIsValid)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
        }
        .navigationTitle(Text("Update your profile"))
    }
    var formIsValid: Bool {
        // checks if the fields are not empty
        let basicInfoIsValid = !email.isEmpty && !firstName.isEmpty && !lastName.isEmpty
        // if there's a new password, it must be 6 characters or more
        let newPasswordIsValid = newPassword.isEmpty || newPassword.count >= 6
        // returns true if all conditions are met
        return basicInfoIsValid || (newPasswordIsValid && password != newPassword)
    }
    
    
}

