//
//  RegistrationView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 14/02/2024.
//
import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    // Accessing the shared instance of AuthViewModel via EnvironmentObject
    @EnvironmentObject var viewModel: AuthViewModel
    
    // registration form
    var body: some View {
        // allows scrolling of content
        ScrollView{
            VStack(alignment: .leading, spacing: 20){
                
                Text("Welcome!")
                    .bold()
                    .font(.system(size: 50))
                    .padding()
                // aligns to the center
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("First Name")
                    .padding(.leading, 20)
                
                TextField("First Name", text: $firstName)
                    .padding()
                    .border(Color.black, width: 2)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                
                Text("Last Name")
                    .padding(.leading, 20)
                
                TextField("Last Name", text: $lastName)
                    .autocapitalization(.words)
                    .padding()
                    .border(Color.black, width: 2)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                
                Text("Email")
                    .padding(.leading, 20)
                
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .border(Color.black, width: 2)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                
                Text("Password")
                    .padding(.leading, 20)
                
                SecureField("Passowrd", text: $password)
                    .textContentType(.password)
                    .padding()
                    .border(Color.black, width: 2)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                
                Text("Confirm Password")
                    .padding(.leading, 20)
                
                // horizontal stack
                ZStack(alignment: .trailing){
                    SecureField("Confirm Passowrd", text: $confirmPassword)
                        .textContentType(.password)
                        .disableAutocorrection(true)
                        .padding()
                        .border(Color.black, width: 2)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    
                    // checks of the password and confirm password matches
                    if !password.isEmpty && !confirmPassword.isEmpty{
                        if password == confirmPassword{
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                        }
                        else{
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                                .padding(.horizontal, 10)
                                .padding(.bottom, 20)
                        }
                    }
                }
                // error message if registeration failed
                if let errorMessage = viewModel.errorMessage, !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                HStack{
                    Spacer()
                    
                    // register button
                    Button("Register"){
                        registerUser()
                    }
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.2)
                    .frame(width: 350, height: 60)
                    .foregroundColor(.black)
                    .font(.title)
                    .bold()
                    .background(Color(red: 122/255, green: 229/255, blue: 130/255))
                    .cornerRadius(10)
                    .padding()
                    // pop up alert with error message
                    .alert("Error", isPresented: $showAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(viewModel.errorMessage ?? "An unknown error occurred.")
                    }
                }
                
                Spacer()
                
            }
            
            HStack(){
                Spacer()
                NavigationLink(destination: loginView()){
                    Text("Already have an account?")
                    Text("Log in")
                        .bold()
                }
                .padding(.bottom, 30)
                Spacer()
            }
        }
    }
    
    func registerUser() {
        Task {
            do {
                // attempts to create a new user
                try await viewModel.createUser(withEmail: email, password: password, firstName: firstName, lastName: lastName)
                // fetches the user data
                await viewModel.fetchUser()
            } catch {
                // Update to show alert when there's an error
                showAlert = true
            }
        }
    }
}

// extends registrationView to conform to the protocol in authViewModel
extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool{
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && password == confirmPassword
        && !firstName.isEmpty
        && !lastName.isEmpty
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
