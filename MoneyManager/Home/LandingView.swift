//
//  LandingView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 14/02/2024.
//

import SwiftUI

struct landingView: View {
    @State private var isRegistrationViewPresented = false
    
    var body: some View {
        // NavigationView to allow page to be navigated to
        NavigationView {
            VStack{
                Text("Money Manager")
                    .bold()
                    .font(.system(size: 50))
                    .padding()
                    .minimumScaleFactor(0.5)
                
                Text("Your Simple Money and Bill Manager")
                    .bold()
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
                    .minimumScaleFactor(0.5)
                
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .padding()
                    .minimumScaleFactor(0.5)
                
                Text("LETS GET STARTED!")
                    .bold()
                    .font(.largeTitle)
                    .padding()
                    .minimumScaleFactor(0.5)
                
                // navigation link to go to the registration form page
                NavigationLink(destination: RegistrationView()) {
                    Text("Register")
                        .frame(width: 300, height: 60)
                        .foregroundColor(.black)
                        .font(.title)
                        .bold()
                    // Set background color using RGB components
                        .background(Color(red: 122/255, green: 229/255, blue: 130/255))
                        .cornerRadius(10)
                        .padding()
                        .minimumScaleFactor(0.5)
                }
                
                Text("Already have an account?")
                    .bold()
                    .font(.system(size: 20))
                    .minimumScaleFactor(0.5)
                
                // navigation link to go to the login page
                NavigationLink(destination: loginView()) {
                    Text("Log In")
                        .frame(width: 300, height: 60)
                        .foregroundColor(.black)
                        .font(.title)
                        .bold()
                        .background(Color(red: 122/255, green: 229/255, blue: 130/255))
                        .cornerRadius(10)
                        .padding()
                        .minimumScaleFactor(0.5)
                }
                
            }
            
        }
    }
}

// provides a preview before running the application
struct landingView_Previews: PreviewProvider{
    static var previews: some View{
        landingView()
    }
}

