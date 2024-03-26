//
//  AuthViewModel.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 14/02/2024.
//
import Foundation
import Firebase // Import framework for Firebase authentication and Firestore database
import FirebaseFirestoreSwift // Import framework for Firestore encoding and decoding

// defines the properties of a protocol
protocol AuthenticationFormProtocol {
    // declares its of type bool
    var formIsValid: Bool {get}
}

// marks the following class as executing on the main thread
@MainActor
// conforms to the ObservableObject protocol. allows an object to change and updates its changes to any views
class AuthViewModel: ObservableObject{
    // Declares a published property that observe the current state and updates if any changes
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var errorMessage: String?
    
    // defines an initialiser for the AuthViewModel class
    init(){
        // Assign the current user session from Firebase authentication to userSession property
        self.userSession = Auth.auth().currentUser
        Task {
            // fetches the user data
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws{
        do{
            // sign in with provided email
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            // if successfull, set the userSession property to the signed-in user
            self.userSession = result.user
            // fetches the user data
            await fetchUser()
        }
        catch{
            // updates the UI
            DispatchQueue.main.async {
                // add the error to the property
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func forgetPassword(withEmail email: String) async throws{
        // sends password rest email with the provided email address
        try await Auth.auth().sendPasswordReset(withEmail: email)
        
    }
    
    // passing though the users inputted variables from the registration form
    func createUser(withEmail email: String, password: String, firstName: String, lastName: String) async throws{
        do{
            // creates a user with the inputted email and password using Firebase Authentication
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            // if successful, the result contains the created user and stores this in a local userSession variable
            self.userSession = result.user
            // creates a user object with the provided data
            let user = User(id: result.user.uid, firstName: firstName, lastName: lastName, email: email, currency: "£")
            // encodes the user object to firestore
            let encodedUser = try Firestore.Encoder().encode(user)
            // saves to firestore
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            // fetches the user data
            await fetchUser()
        }
        catch{
            // updates the UI
            DispatchQueue.main.async {
                // add the error to the property
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func updateUserProfile(firstName: String, lastName: String, email: String, currentPassword: String,
                           newPassword: String?, currency: String) async throws {
        // ensure the current user is logged in
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // if a new password is added and is not empty
        if let newPassword = newPassword, !newPassword.isEmpty {
            // password is updated here
            try await Auth.auth().currentUser?.updatePassword(to: newPassword)
        }
        // checks if email has been modified
        if self.currentUser?.email != email {
            // updates the user email
            try await Auth.auth().currentUser?.updateEmail(to: email)
        }
        // creates an updates user object with the new information
        let userUpdate = User(id: uid, firstName: firstName, lastName: lastName, email: email, currency: currency)
        // encode the user oject to store in the Firebase databse
        let encodedUser = try Firestore.Encoder().encode(userUpdate)
        // updated the user document with the new encode data
        try await Firestore.firestore().collection("users").document(uid).updateData(encodedUser)
        
        // updates local user model
        self.currentUser = userUpdate
        // fetches the user data to update the UI
        await fetchUser()
    }
    
    func reauthenticateUser(currentPassword: String) async throws {
        // attempts to get the currently logged in user and their email
        guard let user = Auth.auth().currentUser,
              let email = user.email
        else {
            return
        }
        // creates authentication credentials with the users email and password
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        
        do {
            // tries to reauthenticate the user with the provided credential
            try await user.reauthenticate(with: credential)
        } catch let error {return}
    }
    
    
    func signOut(){
        do{
            // signs out user on firestore
            try Auth.auth().signOut()
            // clears the user session and goes back to landing page
            self.userSession = nil
            // clears the current user data model
            self.currentUser = nil
        }
        catch {
            print("failed to sign out. error \(error.localizedDescription)")
        }
    }
    
    func fetchUser() async{
        // check if user is signed in
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        // fetch user document from firestore
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument()
        else {
            // exit if unable to fetch document
            return
        }
        // decode the fetched data into user object and assign to current user
        self.currentUser = try? snapshot.data(as: User.self)
    }
    
    // updates the currency symbol
    func updateCurrencySymbol(currencySymbol: String) async throws{
        guard let uid = self.userSession?.uid else { return }
        // updates the field in the users documnet
        await Firestore.firestore().collection("users").document(uid).updateData([
            "currency": currencySymbol
        ]) { error in
            if let error = error {
                print("Error updating currency symbol: \(error)")
                return
            }
            
        }
        // fetches the users data again to update UI
        await fetchUser()
    }
    
}
