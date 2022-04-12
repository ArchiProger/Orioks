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
        ZStack
        {
            if self.settings.token != nil
            {
                ZStack
                {
                    Menu(openViewID: self.$openViewID, menuOpen: self.$menuOpen)
                        .environmentObject(self.server)
                    
                    switch self.openViewID
                    {
                    case 0:
                        Marks(menuOpen: self.$menuOpen)
                            .cornerRadius(self.menuOpen ? 10 : 0)
                            .rotationEffect(self.menuOpen ? Angle(degrees: -5) : Angle(degrees: 0))
                            .offset(x: self.menuOpen ? -UIScreen.screenWidth * 0.5 : 0)
                            .ignoresSafeArea(.all)
                            .environmentObject(self.server)
                            .environmentObject(self.settings)
                        
                    case 1:
                        Schedule(menuOpen: self.$menuOpen)
                            .cornerRadius(self.menuOpen ? 10 : 0)
                            .rotationEffect(self.menuOpen ? Angle(degrees: -5) : Angle(degrees: 0))
                            .offset(x: self.menuOpen ? -UIScreen.screenWidth * 0.5 : 0)
                            .ignoresSafeArea(.all)
                            .environmentObject(self.settings)
                        
                    case 2:
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
                    
                    LoadingScreen()
                        .environmentObject(self.settings)
                        .environmentObject(self.server)
                        .scaleEffect(self.server.loudDataInfo.dataExists() ? 3 : 1)
                        .opacity(self.server.loudDataInfo.dataExists() ? 0 : 1)
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
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification), perform: { output in            
            if self.settings.autoSignIn == false
            {
                self.server.logout(settings: self.settings)
            }
        })
    }
}

/// LoadingScreen - View экрана загрузки
/// Появляется в момент подгрузки данных с сервера, пропадает, когда все данные скачены
struct LoadingScreen: View
{
    @EnvironmentObject var server: Server
    @EnvironmentObject var settings: SettingsData
    
    var body: some View
    {
        ZStack
        {
            Color("Background").ignoresSafeArea(.all)
            
            Image("MIET_logo")
                .resizable()
                .frame(width: UIScreen.screenWidth * 0.3, height: UIScreen.screenWidth * 0.3)
                .padding(20)
        }
        .onAppear()
        {
            self.server.getGroupData(settings: self.settings)
            self.server.getMarksData(settings: self.settings)
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
