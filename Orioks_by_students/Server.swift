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

class getNewsInfo
{
    private var info: [String] = [] //data, time, header, news

    init(htmlDoc: HTMLDocument)
    {
        var arr: [String] = ["", "", "", ""]

        for data in htmlDoc.xpath("//div[@id='news']//td[1]")
        {
            var dataAndTime = data.text?.components(separatedBy: " ")
            arr[0] = dataAndTime![0]
            arr[1] = dataAndTime![1]
        }

        for data in htmlDoc.xpath("//div[@id='news']//td[2]")
        {
            arr[2] = data
        }

        self.info.append(contentsOf: arr)
    }
}

struct Server
{
    @State var login: String
    @State var password: String
    @Binding var loginStatus: Bool?

    func getHTML(value: String?) -> HTMLDocument
    {
        var doc: HTMLDocument!

        if let html = value
        {
            do
            {
                doc = try Kanna.HTML(html: html, encoding: String.Encoding.utf8)
            }
            catch
            {
                print("Failet to open HTML document")
            }
        }

        return doc
    }

    func PostRequest()
    {
        var csrf = ""

        Alamofire.request("https://orioks.miet.ru/user/login")
            .responseString { response in
                //print("Response String: \(response.result.value)")

                for data in getHTML(value: response.result.value).xpath("//input[@name='_csrf']")
                {
                    csrf = data["value"]!
                }

                let param =
                [
                    "_csrf": csrf,
                    "LoginForm[login]": self.login,
                    "LoginForm[password]": self.password,
                    "LoginForm[rememberMe]": "1"
                ]

                Alamofire.request("https://orioks.miet.ru/user/login", method: .post, parameters: param, headers: nil).responseString { response in
                    //print("\(response.result.isSuccess)")
                    //print(response.result.value)

                    for data in getHTML(value: response.result.value).xpath("//title")
                    {
                        self.loginStatus = !(data.text == "Авторизация")
                    }

                    if self.loginStatus != nil && self.loginStatus == true
                    {
                        Alamofire.request("https://orioks.miet.ru")
                            .responseString { response in
                                //print(response.result.value)

                                for data in getHTML(value: response.result.value).xpath("//div[@id='news']//td")
                                {
                                    print(data.text)
                                }

                            }
                    }
                }
            }
    }
}
