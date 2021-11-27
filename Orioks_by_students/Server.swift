//
//  Server.swift
//  Orioks_by_students
//
//  Created by Артур Данилов on 27.11.2021.
//

import Foundation
import Alamofire
import Kanna
import SwiftUI

struct Request
{
    @State var login: String
    @State var password: String
    @Binding var loginStatus: Bool?

    func PostRequest()
    {
        var csrf = ""

        Alamofire.request("https://orioks.miet.ru/user/login")
            .responseString { response in
                //print("Response String: \(response.result.value)")

                if let html = response.result.value
                {
                    if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8)
                    {
                        for data in doc.xpath("//input[@name='_csrf']")
                        {
                            csrf = data["value"]!
                        }
                    }
                }

                let param =
                [
                    "_csrf": csrf,
                    "LoginForm[login]": self.login,
                    "LoginForm[password]": self.password,
                    "LoginForm[rememberMe]": "0"
                ]

                Alamofire.request("https://orioks.miet.ru/user/login", method: .post, parameters: param, headers: nil).responseString { response in
                    //print("\(response.result.isSuccess)")
                    print(response.result.value)

                    if let html = response.result.value
                    {
                        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8)
                        {
                            for data in doc.xpath("//title")
                            {
                                self.loginStatus = !(data.text == "Авторизация")
                            }
                        }
                    }

                    if self.loginStatus != nil && self.loginStatus == true
                    {
                        Alamofire.request("https://orioks.miet.ru/student/student")
                            .responseString { response in
                                print(response.result.value)

                            }
                    }
                }
            }
    }
}
