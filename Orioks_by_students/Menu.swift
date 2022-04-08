//
//  Menu.swift
//  Orioks_by_students
//
//  Created by Артур Данилов on 28.11.2021.
//

import SwiftUI

extension UIScreen
{
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    static let screenSize = UIScreen.main.bounds.size
}

struct MenuListButton: View
{
    @State var btnImg: String
    @State var btnText: String
    
    var body: some View
    {
        HStack
        {
            Image(systemName: self.btnImg)
                .resizable()
                .frame(width: UIScreen.screenWidth * 0.08, height: UIScreen.screenWidth * 0.08)
                .foregroundColor(Color("ElementsColor"))
            Text(btnText)
                .font(.system(size: UIScreen.screenWidth * 0.05))
                .foregroundColor(Color.black)
        }
        .padding(5)
    }
}

struct Menu: View
{
    @Binding var openViewID: Int
    @Binding var menuOpen: Bool
    
    @State private var date = Date()
    @EnvironmentObject var server: Server
    
    func getWeekInfo() -> String
    {
        let calendar = Calendar.current
        let week = calendar.component(.weekOfYear, from: date) + 1
        
        return "\(week % 3 == 0 ? 2 : 1)-й " + (week % 2 == 0 ? "знаменатель" : "числитель")
    }
    
    var body: some View
    {
        ZStack
        {
            Color("Menu_backround").ignoresSafeArea(.all)
            
            HStack
            {
                Spacer()
                
                VStack(alignment: .trailing)
                {
                                                
                    Text(self.getWeekInfo())
                        .font(.system(size: UIScreen.screenWidth * 0.041))
                        .frame(width: UIScreen.screenWidth * 0.4, height: UIScreen.screenWidth * 0.4)
                        .background(Circle()
                                        .fill(Color("Menu_circle")))
                        .foregroundColor(Color.black)
                        .padding()
                        
                    
                    
                    VStack(alignment: .leading)
                    {
                        /*
                         MenuListButton(btnImg: "newspaper.fill", btnText: "Новости")
                            .background(self.openViewID == 0 ? Color("Menu_exc") : Color.clear)
                            .cornerRadius(10)
                            .onTapGesture
                            {
                                self.openViewID = 0
                                self.menuOpen = false
                            }
                         */
                        
                        MenuListButton(btnImg: "checkmark.seal.fill", btnText: "Оценки")
                            .background(self.openViewID == 1 ? Color("Menu_exc") : Color.clear)
                            .cornerRadius(10)
                            .onTapGesture
                            {
                                self.openViewID = 1
                                self.menuOpen = false
                            }
                        
                        MenuListButton(btnImg: "graduationcap.fill", btnText: "Расписание")
                            .background(self.openViewID == 2 ? Color("Menu_exc") : Color.clear)
                            .cornerRadius(10)
                            .onTapGesture
                            {
                                self.openViewID = 2
                                self.menuOpen = false
                            }
                        
                        MenuListButton(btnImg: "gear", btnText: "Настройки")
                            .background(self.openViewID == 3 ? Color("Menu_exc") : Color.clear)
                            .cornerRadius(10)
                            .onTapGesture
                            {
                                self.openViewID = 3
                                self.menuOpen = false
                            }
                        
                        Spacer()
                    }
                }.padding(20)
            }
        }
    }
}

struct Menu_Previews: PreviewProvider
{
    static var previews: some View
    {
        Text("Hello, World")
            .preferredColorScheme(.dark)
    }
}
