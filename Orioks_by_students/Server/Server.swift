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
    @Published var newsInfo: [[String]] = []
    @Published var marksData: [Discipline] = []
    @Published var studentInfo: Student = Student(course: 1, full_name: "", group: "", study_direction: "", year: "")
    @Published var authError: String = ""
    @Published var allCurrentMarks: Float? = 1
    @Published var maxCurrentMarks: Float = 1
    
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
    
    func login(login: String, password: String, settings: SettingsData)
    {
        let authHead =
        [
            "Authorization": "Basic " + Data("\(login):\(password)".utf8).base64EncodedString(),
            "Accept": "application/json",
            "User-Agent": "api_tester/0.1 venv python"
        ]
        
        Alamofire.request("https://orioks.miet.ru/api/v1/auth", method: .get, parameters: nil, headers: authHead)
            .responseString { response in
                switch response.result
                {
                case .success(let value):
                    do
                    {
                        let authJSON = try JSONDecoder().decode(Auth.self, from: Data(value.utf8))
                        
                        if authJSON.token == nil
                        {
                            self.authError = "\(authJSON.error!.code) " + authJSON.error!.text
                        }
                        
                        settings.token = authJSON.token
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
    
    func getMarksData(settings: SettingsData)
    {
        let head =
        [
            "Authorization": "Bearer " + settings.token!,
            "Accept": "application/json",
            "User-Agent": "api_tester/0.1 venv python"
        ]
        
        Alamofire.request("https://orioks.miet.ru/api/v1/student/disciplines", method: .get, parameters: nil, headers: head)
            .responseString { response in
                                
                switch response.result
                {
                case .success(let value):
                    do
                    {
                        self.marksData = try JSONDecoder().decode([Discipline].self, from: Data(value.utf8))
                        
                        for i in self.marksData.indices
                        {
                            if self.marksData[i].current_grade != nil
                            {
                                self.allCurrentMarks! += self.marksData[i].current_grade!
                                self.maxCurrentMarks += self.marksData[i].max_grade
                            }
                            
                            Alamofire.request("https://orioks.miet.ru/api/v1/student/disciplines/\(self.marksData[i].id)/events", method: .get, parameters: nil, headers: head).responseString {response in
                                
                                switch response.result
                                {
                                case .success(let value):
                                    
                                    do
                                    {
                                        self.marksData[i].events = try JSONDecoder().decode([Event].self, from: Data(value.utf8))
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
                    
                    catch
                    {
                        print(error)
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    func getGroupData(settings: SettingsData)
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
            
            let head =
            [
                "Authorization": "Bearer " + settings.token!,
                "Accept": "application/json",
                "User-Agent": "api_tester/0.1 venv python"
            ]
            
            Alamofire.request("https://orioks.miet.ru/api/v1/student", method: .get, parameters: nil, headers: head)
                .responseString { response in
                    
                    switch response.result
                    {
                    case .success(let value):
                        do
                        {
                            self.studentInfo = try JSONDecoder().decode(Student.self, from: Data(value.utf8))
                            settings.group = settings.groupsList.firstIndex(where: {$0 == self.studentInfo.group}) ?? 0
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
        catch let error
        {
            print("Error: \(error)")
        }
    }
    
    func logout(settings: SettingsData)
    {
        let head =
        [
            "Authorization": "Bearer " + settings.token!,
            "Accept": "application/json",
            "User-Agent": "api_tester/0.1 venv python"
        ]
        
        Alamofire.request("/api/v1/student/tokens/\(settings.token!)", method: .delete, parameters: nil, headers: head)
            .responseString { response in
                switch response.result
                {
                case .success(let value):
                    do
                    {
                        let deletionJSON = try JSONDecoder().decode(InfoTokenDeletion.self, from: Data(value.utf8))
                        
                        if deletionJSON.error != nil
                        {
                            print(deletionJSON.error!)
                        }
                    }
                    
                    catch
                    {
                        print(error)
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        
        settings.token = nil
    }
}
