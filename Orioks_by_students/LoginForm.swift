//
//  SignIn.swift
//  test
//
//  Created by Артур Данилов on 26.11.2021.
//

import Foundation
import SwiftUI

struct LoginForm: View
{
    @State var login = ""
    @State var password = ""
    @State private var _isPasOpen = false
    
    @EnvironmentObject var server: Server
    @EnvironmentObject var settings: SettingsData

    var body: some View
    {
        VStack(spacing: 50)
        {
            Image("MIET_logo")
                .resizable()
                .frame(width: UIScreen.screenWidth * 0.2, height: UIScreen.screenWidth * 0.2)
                .padding(20)

            VStack(spacing: 10)
            {
                Text("Ориокс")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Capsule()
                    .fill(Color.cyan)
                    .frame(width: 140, height: 4)

                if self.server.loginStatus == false
                {
                    Text("Неправильный логин или пароль")
                        .foregroundColor(Color.red)
                }

                ZStack
                {
                    VStack()
                    {
                        HStack
                        {
                            Image(systemName: "mail.fill")
                                .foregroundColor(Color("Pink"))
                                

                            VStack(spacing: 2)
                            {
                                TextField("Номер студенческого билета", text: self.$login)
                                    .frame(width: UIScreen.screenWidth * 0.7, height: UIScreen.screenHeight * 0.05)

                                Capsule()
                                    .fill(Color.gray)
                                    .frame(width: UIScreen.screenWidth * 0.7, height: 2)
                            }

                        }

                        Spacer()
                        
                        HStack
                        {
                            Button(action:
                                    {
                                self._isPasOpen.toggle()
                            })
                            {
                                Image(systemName: self._isPasOpen ? "eye.fill" : "eye.slash.fill")
                                    .foregroundColor(Color("Pink"))
                            }

                            VStack(spacing: 2)
                            {
                                if self._isPasOpen
                                {
                                    TextField("Пароль", text: self.$password)
                                        .frame(width: UIScreen.screenWidth * 0.7, height: UIScreen.screenHeight * 0.05)
                                }

                                else
                                {
                                    SecureField("Пароль", text: self.$password)
                                        .frame(width: UIScreen.screenWidth * 0.7, height: UIScreen.screenHeight * 0.05)
                                }

                                Capsule()
                                    .fill(Color.gray)
                                    .frame(width: UIScreen.screenWidth * 0.7, height: 2)
                            }
                        }

                        Spacer()
                        
                        Button(action:
                        {
                            self.server.login(login: self.login, password: self.password, settings: self.settings)
                        })
                        {
                            ZStack
                            {
                                Capsule()
                                    .fill(Color("Pink"))
                                    .frame(width: UIScreen.screenWidth * 0.5, height: UIScreen.screenHeight * 0.05)

                                Text("Войти")
                                    .font(.title2)
                                    .foregroundColor(Color.white)
                            }
                        }
                    }.padding(20)
                }
                .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.22)
                .background(Color("Color_SignIn"))
                .shadow(color: Color("Color_SignIn"), radius: 10)
                .cornerRadius(25)
            }
            Spacer()
        }.preferredColorScheme(.dark)
    }
}

struct LoginFormPreviews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
            .previewInterfaceOrientation(.portrait)
    }
}
