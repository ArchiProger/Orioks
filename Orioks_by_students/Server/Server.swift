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

class NewsInfo
{
    private var info: [String] = [] //date, time, header, news

    func getInfoArray() -> [String] {return info}

    func parsDoc(htmlDoc: XPathObject)
    {
        var arr: [String] = ["", "", "", ""]
        var flag = false

        for i in 0...(htmlDoc.count - 1)
        {
            if flag
            {
                arr[3] += htmlDoc[i].text!
            }

            if htmlDoc[i].text! == "Дата создания:"
            {
                let DateAndTime = htmlDoc[i + 1].text!
                var DTArray = DateAndTime.components(separatedBy: " ")
                DTArray = DTArray.filter(){$0 != ""}
                arr[0] = DTArray[0].replacingOccurrences(of: "-", with: ".")
                arr[1] = DTArray[1].replacingOccurrences(of: "\n", with: "")
            }

            else if htmlDoc[i].text! == "Заголовок:"
            {
                arr[2] = htmlDoc[i + 1].text!
            }

            else if htmlDoc[i].text! == "Тело новости:"
            {
                flag = true
            }
        }

        self.info.append(contentsOf: arr)
    }
}

class Server: ObservableObject
{
    @Published var loginStatus: Bool? = nil
    @Published var newsInfo: [[String]] = []
    @Published var marksData: Education = Education(dises: [])
    @Published var studentGroup: String = ""
    
    private func getHTML(value: String?) -> HTMLDocument
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
    
    func getGroupList(settings: SettingsData)
    {
        guard let myURL = URL(string: "https://miet.ru/schedule/groups") else
        {
            print("Error: https://www.miet.ru/schedule doesn't seem to be a valid URL")
            return
        }

        do
        {
            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            settings.groupsList = try JSONDecoder().decode([String].self, from: myHTMLString.data(using: .isoLatin1, allowLossyConversion: true)!)                  
        }
        catch let error
        {
            print("Error: \(error)")
        }            
    }

    func login(login: String, password: String, settings: SettingsData?)
    {
        var csrf = ""

        Alamofire.request("https://orioks.miet.ru/user/login")
            .responseString { response in

                for data in self.getHTML(value: response.result.value).xpath("//input[@name='_csrf']")
                {
                    csrf = data["value"]!
                }

                let param =
                [
                    "_csrf": csrf,
                    "LoginForm[login]": login,
                    "LoginForm[password]": password,
                    "LoginForm[rememberMe]": "0"
                ]

                Alamofire.request("https://orioks.miet.ru/user/login", method: .post, parameters: param, headers: nil).responseString { response in

                    for data in self.getHTML(value: response.result.value).xpath("//title")
                    {
                        self.loginStatus = !(data.text == "Авторизация")
                    }

                    if self.loginStatus != nil && self.loginStatus == true
                    {
                        if settings != nil && settings!.autoSignIn
                        {
                            settings!.userLogin = login
                            settings!.userPassword = password
                        }
                        
                        Alamofire.request("https://orioks.miet.ru") //News
                            .responseString { response in

                                let links = self.getHTML(value: response.result.value).xpath("//div[@id='news']//a")
                                
                                for i in 0..<20
                                {
                                    Alamofire.request("https://orioks.miet.ru/" + links[i]["href"]!).validate()
                                        .responseString { response in

                                            switch response.result
                                            {
                                            case .success(_):
                                                let info = NewsInfo()
                                                let html = self.getHTML(value: response.result.value).xpath("//div[@class='well']//text()")
                                                info.parsDoc(htmlDoc: html)
                                                self.newsInfo.append(info.getInfoArray())

                                            case .failure(let error):
                                                print(error)
                                            }
                                        }
                                }

                            }

                        Alamofire.request("https://orioks.miet.ru/student/student") // Marks
                            .responseString { response in

                                switch response.result
                                {
                                case .success(let value):

                                    let data = self.getHTML(value: value).xpath("//div[@id='forang']")[0].text!                                    

                                    do
                                    {                                        
                                        self.marksData = try JSONDecoder().decode(Education.self, from: Data(data.utf8))
                                    }

                                    catch
                                    {
                                        print(error)
                                    }

                                case .failure(let error):
                                    print(error)
                                }
                            }
                    }
                }
            }
    }
    
    func logout()
    {
        Alamofire.request("https://orioks.miet.ru/user/login")
            .responseString { response in
                
                switch response.result
                {
                case .success(_):
                    var csrf: String? = ""
                    
                    for data in self.getHTML(value: response.result.value).xpath("//meta[@name='csrf-token']")
                    {
                        csrf = data["content"]
                    }
                    
                    if csrf != nil
                    {
                        Alamofire.request("https://orioks.miet.ru/user/logout", method: .post, parameters: ["_csrf": csrf!], headers: nil)
                    }

                case .failure(let error):
                    print(error)
                }
            }
    }
}
