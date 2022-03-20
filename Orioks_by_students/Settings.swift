//
//  Settings.swift
//  
//
//  Created by Артур Данилов on 18.02.2022.
//

import SwiftUI
import Alamofire

class SettingsData: ObservableObject
{
    @Published var themesSettings: Int
    {
        didSet
        {
            UserDefaults.standard.set(themesSettings, forKey: "ThemesSettings")
        }
    }
    
    @Published var autoSignIn: Bool
    {
        didSet
        {
            UserDefaults.standard.set(autoSignIn, forKey: "AutoSignIn")
        }
    }
    
    @Published var group: Int
    {
        didSet
        {
            UserDefaults.standard.set(group, forKey: "Group")
        }
    }
    
    @Published var userLogin: String?
    {
        didSet
        {
            UserDefaults.standard.set(userLogin, forKey: "UserLogin")
        }
    }
    
    @Published var userPassword: String?
    {
        didSet
        {
            UserDefaults.standard.set(userPassword, forKey: "UserPassword")
        }
    }
    
    @Published var groupsList: [String] = []
    
    init()
    {
        self.themesSettings = UserDefaults.standard.integer(forKey: "ThemesSettings")
        self.autoSignIn = UserDefaults.standard.object(forKey: "AutoSignIn") as? Bool ?? true
        self.group = UserDefaults.standard.integer(forKey: "Group")
        self.userLogin = UserDefaults.standard.object(forKey: "UserLogin") as? String ?? nil
        self.userPassword = UserDefaults.standard.object(forKey: "UserPassword") as? String ?? nil
        
        if !self.autoSignIn
        {
            self.group = 0
            self.userLogin = nil
            self.userPassword = nil
        }
    }
}

struct Settings: View
{
    @Binding var menuOpen: Bool
    
    @State private var showAlert = false
    
    @EnvironmentObject var settings: SettingsData
    @EnvironmentObject var server: Server
    
    private let themesSettings = ["Системная", "Темная", "Светлая"]
    
    init(menuOpen: Binding<Bool>)
    {
        self._menuOpen = menuOpen
        
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View
    {
        NavigationView
        {
            ZStack
            {
                Color("Background").ignoresSafeArea(.all)
                
                Form
                {
                    Group
                    {
                        Section("Тема")
                        {
                            Picker(selection: self.$settings.themesSettings, label: Text("Выберете тему оформления"))
                            {
                                ForEach(0..<self.themesSettings.count, id: \.self) { i in
                                    
                                    Text(self.themesSettings[i])
                                }
                            }.pickerStyle(SegmentedPickerStyle())
                        }
                        
                        Section("Аккаунт")
                        {
                            Picker(selection: self.$settings.group, label: Text("Группа: "))
                            {
                                ForEach(0..<self.settings.groupsList.count, id: \.self) { i in
                                    
                                    Text(self.settings.groupsList[i])
                                }
                            }
                            .font(.system(size: UIScreen.screenWidth * 0.04))
                            
                            Toggle("Автоматическая авторизация", isOn: self.$settings.autoSignIn)
                                .font(.system(size: UIScreen.screenWidth * 0.04))
                            Button("Выйти")
                            {
                                self.showAlert = true
                            }
                            .font(.system(size: UIScreen.screenWidth * 0.04))
                            .foregroundColor(Color.red)
                            .alert(isPresented: $showAlert) {
                                    Alert(
                                        title: Text("Вы точно хотите выйти?"),
                                        primaryButton: .default(
                                            Text("Отмена")
                                        ),
                                        secondaryButton: .destructive(
                                            Text("Выйти"),
                                            action:
                                                {
                                                    self.server.loginStatus = nil
                                                    self.settings.group = 0
                                                    self.settings.userLogin = nil
                                                    self.settings.userPassword = nil
                                                                                                                
                                                    self.server.logout()
                                                }
                                        )
                                    )
                                }
                        }
                    }.listRowBackground(Color("MarksCard.Background"))
                }
            }
            .navigationBarTitle("Настройки", displayMode: .automatic)
            .navigationBarItems(trailing:
                Image(systemName: self.menuOpen ? "xmark.app.fill" : "menucard.fill")
                    .resizable()
                    .foregroundColor(Color("ElementsColor"))
                    .frame(width: UIScreen.screenWidth * 0.06, height: UIScreen.screenWidth * 0.06)
                    .onTapGesture
                    {
                        self.menuOpen.toggle()
                    }
            )
        }
    }
}

struct Settings_Previews: PreviewProvider
{
    static var previews: some View
    {
        EmptyView()
            .preferredColorScheme(.dark)
    }
}
