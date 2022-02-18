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
    @State private var menuOpen = false
    @State private var openViewID: Int = 0
    
    @ObservedObject var server = Server()
    
    var body: some View
    {
        if self.server.loginStatus == true && self.server.loginStatus != nil
        {                
            ZStack
            {
                Menu(openViewID: self.$openViewID, menuOpen: self.$menuOpen)
                    .environmentObject(self.server)
                
                switch self.openViewID
                {
                case 0:
                    News(menuOpen: self.$menuOpen)
                        .cornerRadius(self.menuOpen ? 10 : 0)
                        .rotationEffect(self.menuOpen ? Angle(degrees: -5) : Angle(degrees: 0))
                        .offset(x: self.menuOpen ? -UIScreen.screenWidth * 0.5 : 0)
                        .ignoresSafeArea(.all)
                        .environmentObject(self.server)
                    
                case 1:
                    Marks(menuOpen: self.$menuOpen)
                        .cornerRadius(self.menuOpen ? 10 : 0)
                        .rotationEffect(self.menuOpen ? Angle(degrees: -5) : Angle(degrees: 0))
                        .offset(x: self.menuOpen ? -UIScreen.screenWidth * 0.5 : 0)
                        .ignoresSafeArea(.all)
                        .environmentObject(self.server)
                    
                default:
                    Schedule(group: self.server.studentGroup, menuOpen: self.$menuOpen)
                        .cornerRadius(self.menuOpen ? 10 : 0)
                        .rotationEffect(self.menuOpen ? Angle(degrees: -5) : Angle(degrees: 0))
                        .offset(x: self.menuOpen ? -UIScreen.screenWidth * 0.5 : 0)
                        .ignoresSafeArea(.all)
                }
            }
            .shadow(radius: 10)
            .animation(.easeIn(duration: 0.3))
        }
        
        else
        {
            LoginForm()
                .environmentObject(self.server)
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
