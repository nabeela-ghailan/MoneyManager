//
//  loginView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 14/02/2024.
//

import SwiftUI

struct loginView: View {
    // declaring state variables to store user input for email and password
    @State private var email = ""
    @State private var password = ""
    // accessing the shared instance of AuthViewModel via EnvironmentObject
    @EnvironmentObject var viewModel: AuthViewModel
    // manages the presentation of alerts
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // login form
    var body: some View {
        // allows scrolling
        ScrollView{
            //arranging views vertically
            VStack(alignment: .leading){
                
                Text("Welcome Back!")
                    .bold()
                    .font(.system(size: 50))
                    .multilineTextAlignment(.center)
                    .padding()
                // aligns to the center
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)
                
                Text("Email")
                    .padding(.leading, 30)
                
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
                
                SecureField("Password", text: $password)
                    .padding()
                    .border(Color.black, width: 2)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                
                // pushes content up
                Spacer()
                
                // navigation link to forgot password page view
                NavigationLink(destination: forgotPassword()){
                    HStack{
                        Spacer()
                        Text("Forgot Password?")
                            .bold()
                            .padding(.trailing)
                            .padding(.bottom)
                    }
                }
                // error message if login failed
                if let errorMessage = viewModel.errorMessage, !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                //button to login
                Button(action: {
                    Task{
                        do{
                            // Calling the signIn method of AuthViewModel to authenticate user
                            try await viewModel.signIn(withEmail: email, password: password)
                        }
                        catch{
                            showAlert = true
                        }
                    }
                }) {
                    Text("Log in")
                        .disabled(!formIsValid) // button will be disabled if formIsValid is false
                        .opacity(formIsValid ? 1.0 : 0.2) // sets the opacity to 0.2 if formIsValid is false
                        .frame(width: 350, height: 60)
                        .foregroundColor(.black)
                        .font(.title)
                        .bold()
                        .background(Color(red: 122/255, green: 229/255, blue: 130/255))
                        .cornerRadius(10)
                        .padding(.leading, 10)
                        .padding(.bottom, 20)
                    Spacer()
                }
                // alert is displayed when login fails
                .alert("Error", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(viewModel.errorMessage ?? "An unknown error occurred.")
                }
                //navigation link to registration page
                NavigationLink(destination: RegistrationView()){
                    HStack{
                        Spacer()
                        Text("Don't have an account?")
                        Text("Register")
                            .bold()
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
        }
        
    }
}

// extends registrationView to conform to the protocol in authViewModel
extension loginView: AuthenticationFormProtocol {
    var formIsValid: Bool{ //returns true if these conditions are met
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

struct logView_Previews: PreviewProvider {
    static var previews: some View {
        loginView()
    }
}

