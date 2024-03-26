//
//  forgotPassword.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 15/02/2024.
//

import SwiftUI

struct forgotPassword: View {
    @State private var email = ""
    @EnvironmentObject var viewModel: AuthViewModel // accesses the authentication view model
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView(){
            ScrollView{
                VStack(alignment: .leading){
                    Text("Forgotten Passowrd?")
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
                    
                    // button to send email to reset password link
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.forgetPassword(withEmail: email) // calls the method in authViewModel
                                self.alertMessage = "Password reset email has been sent."
                            } catch {
                                self.alertMessage = "Error: \(error.localizedDescription)"
                            }
                            // shows the alert after the task is completed
                            self.showAlert = true
                        }
                    }) {
                        Text("Send Email to Reset Password")
                            .multilineTextAlignment(.center)
                            .frame(width: 340, height: 60)
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .bold()
                            .background(Color(red: 122/255, green: 229/255, blue: 130/255))
                            .cornerRadius(10)
                            .padding(.leading, 10)
                            .padding(.bottom, 20)
                        
                    }
                    // alert to display message
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Forgotten Password"),
                              message: Text(alertMessage),
                              dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
            .padding()
        }
    }
}

struct forgotPasswordView: PreviewProvider {
    static var previews: some View {
        forgotPassword()
    }
}
