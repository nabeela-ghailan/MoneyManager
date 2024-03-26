//
//  settingsView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 15/02/2024.
//

import SwiftUI

struct settingsView: View {
    // accessing the shared instance
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView{
            VStack{
                Text("Settings")
                    .font(.title)
                    .bold()
                    .padding(.top, 30)
                
                Spacer()
                // checks of the current user exists
                if let user = viewModel.currentUser {
                    // link to edit the users details
                    NavigationLink(destination: EditProfileView(viewModel: AuthViewModel(), user: user)){
                        VStack{
                            Image(systemName: "person")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                            Text("Profile")
                                .foregroundStyle(.black)
                                .font(.title2)
                        }
                        .frame(maxWidth: 167, maxHeight: 91)
                        .background(Color(red: 0, green: 0.65, blue: 0.81))
                        .cornerRadius(10)
                    }
                    .onAppear{
                        Task{
                            do{
                                // fetches the users data
                                await viewModel.fetchUser()
                            }
                        }
                    }
                    
                }
                Spacer()
                
                NavigationLink(destination: NotificationSettingView()){
                    VStack{
                        Image(systemName: "bell")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                        Text("Notification")
                            .foregroundStyle(.black)
                            .font(.title2)
                    }
                    .frame(maxWidth: 167, maxHeight: 91)
                    .background(Color(red: 0, green: 0.65, blue: 0.81))
                    .cornerRadius(10)
                }
                
                Spacer()
                
                NavigationLink(destination: CurrencyView(viewModel: AuthViewModel())){
                    VStack{
                        HStack{
                            Image(systemName: "sterlingsign")
                                .resizable()
                                .frame(width: 20, height: 24)
                            Image(systemName: "dollarsign")
                                .resizable()
                                .frame(width: 17, height: 27)
                            Image(systemName: "eurosign")
                                .resizable()
                                .frame(width: 20, height: 24)
                        }
                        .foregroundColor(.black)
                        Text("Currency")
                            .foregroundStyle(.black)
                            .font(.title2)
                    }
                    .frame(maxWidth: 167, maxHeight: 91)
                    .background(Color(red: 0, green: 0.65, blue: 0.81))
                    .cornerRadius(10)
                }
                
                Spacer()
                
                // button to sign out the user
                Button(action: {
                    viewModel.signOut()
                }, label: {
                    Text("Signout")
                        .foregroundStyle(.black)
                        .font(.title)
                        .bold()
                        .frame(maxWidth: 300, maxHeight: 60)
                        .background(Color(red: 0.97, green: 0.17, blue: 0.17))
                        .cornerRadius(10)
                })
                
                Spacer()
            }
        }
    }
}

struct settingsView_Previews: PreviewProvider {
    static var previews: some View {
        settingsView()
    }
    
}
