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
            Image(btnImg)
                .resizable()
                .frame(width: UIScreen.screenWidth * 0.08, height: UIScreen.screenWidth * 0.08)
            Text(btnText)
                .font(.title2)
                .foregroundColor(Color.black)
        }
        .padding(5)
    }
}

struct Menu: View
{
    @Binding var menuOpen: Bool
    @Binding var openViewID: Int
    
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
                    ZStack
                    {
                        Circle()
                            .fill(Color("Menu_circle"))
                            .padding()
                            .frame(width: UIScreen.screenWidth * 0.45, height: UIScreen.screenWidth * 0.45)
                        
                        VStack
                        {
                            Text("12 неделя")
                                .font(.title2)
                                .foregroundColor(Color.black)
                            Text("Числитель")
                                .font(.title2)
                                .foregroundColor(Color.black)
                        }
                    }
                    
                    VStack(alignment: .leading)
                    {
                        MenuListButton(btnImg: "Newspaper", btnText: "Новости")
                            .background(self.openViewID == 0 ? Color("Menu_exc") : Color.clear)
                            .cornerRadius(10)
                            .onTapGesture
                            {
                                self.openViewID = 0
                                self.menuOpen = false
                            }
                        
                        MenuListButton(btnImg: "Checkmark", btnText: "Оценки")
                            .background(self.openViewID == 1 ? Color("Menu_exc") : Color.clear)
                            .cornerRadius(10)
                            .onTapGesture
                            {
                                self.openViewID = 1
                                self.menuOpen = false
                            }
                        
                        MenuListButton(btnImg: "Graduationcap", btnText: "Расписание")
                            .background(self.openViewID == 2 ? Color("Menu_exc") : Color.clear)
                            .cornerRadius(10)
                            .onTapGesture
                            {
                                self.openViewID = 2
                                self.menuOpen = false
                            }
                    }
                    
                    Spacer()
                    
                    HStack
                    {
                        Spacer()
                        
                        Capsule()
                            .fill(Color.gray)
                            .frame(width: UIScreen.screenWidth * 0.22, height: 4)
                    }
                    
                    HStack(spacing: 15)
                    {
                        Image("Gear")
                            .resizable()
                            .frame(width: UIScreen.screenWidth * 0.08, height: UIScreen.screenWidth * 0.08)
                        
                        Image("Bell")
                            .resizable()
                            .frame(width: UIScreen.screenWidth * 0.08, height: UIScreen.screenWidth * 0.08)
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
