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
    @Binding var login: String
    @Binding var password: String
    @Binding var loginStatus: Bool?
    @Binding var newsInfo: [[String]]
    @Binding var marksData: Education
    @Binding var studentGroup: String
    @State private var _isPasOpen = false

    var body: some View
    {
        VStack(spacing: 50)
        {
            Image("MIET_logo")
                .resizable()
                .frame(width: 100, height: 100)
                .padding(20)

            VStack(spacing: 10)
            {
                Text("Ориокс")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Capsule()
                    .fill(Color.cyan)
                    .frame(width: 140, height: 4)

                if self.loginStatus != nil && self.loginStatus == false
                {
                    Text("Неправильный логин или пароль")
                        .foregroundColor(Color.red)
                }

                ZStack
                {
                    Rectangle()
                        .fill(Color("Color_SignIn"))
                        .frame(width: 360, height: 200)
                        .cornerRadius(40)
                        .shadow(color: Color("Color_SignIn"), radius: 10)

                    VStack(spacing: 30)
                    {
                        HStack
                        {
                            Image("mail")
                                .resizable()
                                .frame(width: 35, height: 25)

                            VStack(spacing: 2)
                            {
                                TextField("Номер студенческого билета", text: self.$login)

                                Capsule()
                                    .fill(Color.gray)
                                    .frame(width: 280, height: 2)
                            }

                        }

                        HStack
                        {
                            Button(action:
                                    {
                                self._isPasOpen.toggle()
                            })
                            {
                                Image(self._isPasOpen ? "eye" : "eye.slash.fill")
                                    .resizable()
                                    .frame(width: 35, height: 25)
                            }

                            VStack(spacing: 2)
                            {
                                if self._isPasOpen
                                {
                                    TextField("Пароль", text: self.$password)
                                }

                                else
                                {
                                    SecureField("Пароль", text: self.$password)
                                }

                                Capsule()
                                    .fill(Color.gray)
                                    .frame(width: 280, height: 2)
                            }
                        }

                        Button(action:
                        {
                            let req = Server(login: self.login, password: self.password, loginStatus: self.$loginStatus, newsInfo: self.$newsInfo, marksData: self.$marksData, studentGroup: self.$studentGroup)
                            req.PostRequest()
                        })
                        {
                            ZStack
                            {
                                Capsule()
                                    .fill(Color("Pink"))
                                    .frame(width: 250, height: 40)

                                Text("Войти")
                                    .font(.title2)
                                    .foregroundColor(Color.white)
                            }
                        }
                    }.padding(20)
                }.frame(width: 360, height: 200)
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
