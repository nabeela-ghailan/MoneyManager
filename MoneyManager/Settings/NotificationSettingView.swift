//
//  NotificationView.swift
//  MoneyManager
//
//  Created by Nabeela Ghailan on 06/03/2024.
//

import SwiftUI

// UI completed but not the backend to allow notifications

struct NotificationSettingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var notificationEnabled = true
    @State private var selectedMethod: String = "push"
    let notificationReminder = ["Never", "1 Day", "2 Days", "1 Week", "1 Month"]
    @State private var notificationRepeats = "Never"
    
    var body: some View {
        VStack{
            Spacer()
            Toggle("Enable Notification", isOn: $notificationEnabled)
                .padding()
                .frame(width: 350)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .cornerRadius(10)
            Spacer()
            
            VStack{
                Text("Preferred Method:")
                HStack{
                    Spacer()
                    Button(action: {
                        selectedMethod = "email"
                        
                    }){
                        Text("Email")
                            .frame(width: 136, height: 84)
                        
                            .foregroundColor(.black)
                            .background(selectedMethod == "email" ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0, green: 0.65, blue: 0.81))
                            .cornerRadius(10)
                    }
                    Spacer()
                    Button(action: {
                        selectedMethod = "push"
                        
                    }){
                        Text("Push Notifications")
                            .multilineTextAlignment(.center)
                            .frame(width: 136, height: 84)
                        
                            .foregroundColor(.black)
                            .background(selectedMethod == "push" ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0, green: 0.65, blue: 0.81))
                            .cornerRadius(10)
                    }
                    Spacer()
                }
            }
            .frame(width: 350)
            
            .padding(.top)
            .padding(.bottom)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
            Spacer()
            HStack{
                Text("Send reminder before bill due:")
                Picker("Remind before", selection: $notificationRepeats) {
                    ForEach(notificationReminder, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
            Spacer()
            
            Button(action: {
                
            }){
                Text("Save")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.black)
            }
            .frame(width: 350, height: 60, alignment: .center)
            .background(Color(red: 0, green: 0.65, blue: 0.81))
            .cornerRadius(10)
            Spacer()
        }
        
        .navigationTitle(Text("Notifications"))
    }
    
}
