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
    
    @ObservedObject var settings = SettingsData()
    @ObservedObject var server = Server()
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View
    {
        return ZStack
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
                        
                    case 2:
                        Schedule(menuOpen: self.$menuOpen)
                            .cornerRadius(self.menuOpen ? 10 : 0)
                            .rotationEffect(self.menuOpen ? Angle(degrees: -5) : Angle(degrees: 0))
                            .offset(x: self.menuOpen ? -UIScreen.screenWidth * 0.5 : 0)
                            .ignoresSafeArea(.all)
                            .environmentObject(self.settings)
                        
                    case 3:
                        Settings(menuOpen: self.$menuOpen)
                            .cornerRadius(self.menuOpen ? 10 : 0)
                            .rotationEffect(self.menuOpen ? Angle(degrees: -5) : Angle(degrees: 0))
                            .offset(x: self.menuOpen ? -UIScreen.screenWidth * 0.5 : 0)
                            .ignoresSafeArea(.all)
                            .environmentObject(self.settings)
                            .environmentObject(self.server)
                        
                    default:
                        EmptyView()
                    }
                }
                .shadow(radius: 10)
                .animation(.easeIn(duration: 0.3))
            }
            
            else
            {
                LoginForm()
                    .environmentObject(self.server)
                    .environmentObject(self.settings)
            }
            
        }
        .environment(\.colorScheme, self.settings.themesSettings == 0 ? self.colorScheme : (self.settings.themesSettings == 1 ? .dark : .light))
        .onAppear()
        {
            self.server.getGroupList(settings: self.settings)
            
            if self.settings.autoSignIn && (self.settings.userLogin != nil || self.settings.userPassword != nil)
            {
                self.server.login(login: self.settings.userLogin!, password: self.settings.userPassword!, settings: nil)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification), perform: { output in            
            self.server.logout()
        })
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
