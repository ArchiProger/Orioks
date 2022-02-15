//
//  ContentView.swift
//  Requests
//
//  Created by Артур Данилов on 25.11.2021.
//

import SwiftUI
import Alamofire
import Kanna

struct ContentView: View
{
    @State private var loginStatus: Bool? = nil //Должно быть nil
    @State private var login = ""
    @State private var password = ""
    @State private var newsInfo: [[String]] = []
    @State private var marksData = Education(dises: [])
    @State private var menuOpen = false
    @State private var openViewID: Int = 0
    @State private var studentGroup: String = ""
    
    var body: some View
    {
        if loginStatus == true && loginStatus != nil
        {                
            ZStack
            {
                Menu(menuOpen: self.$menuOpen, openViewID: self.$openViewID, studentGroup: self.$studentGroup)
                
                switch self.openViewID
                {
                case 0:
                    News(newsInfo: self.$newsInfo, menuOpen: self.$menuOpen)
                        .cornerRadius(self.menuOpen ? 10 : 0)
                        .rotationEffect(self.menuOpen ? Angle(degrees: -5) : Angle(degrees: 0))
                        .offset(x: self.menuOpen ? -UIScreen.screenWidth * 0.5 : 0)
                        .ignoresSafeArea(.all)
                    
                case 1:
                    Marks(data: self.$marksData, menuOpen: self.$menuOpen)
                        .cornerRadius(self.menuOpen ? 10 : 0)
                        .rotationEffect(self.menuOpen ? Angle(degrees: -5) : Angle(degrees: 0))
                        .offset(x: self.menuOpen ? -UIScreen.screenWidth * 0.5 : 0)
                        .ignoresSafeArea(.all)
                    
                default:
                    Schedule(group: self.$studentGroup, menuOpen: self.$menuOpen)
                        .cornerRadius(self.menuOpen ? 10 : 0)
                        .rotationEffect(self.menuOpen ? Angle(degrees: -5) : Angle(degrees: 0))
                        .offset(x: self.menuOpen ? -UIScreen.screenWidth * 0.5 : 0)
                        .ignoresSafeArea(.all)
                }
            }
            .animation(.easeIn(duration: 0.3))
        }
        
        else
        {
            LoginForm(login: self.$login, password: self.$password, loginStatus: self.$loginStatus, newsInfo: self.$newsInfo, marksData: self.$marksData, studentGroup: self.$studentGroup)
        }
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
