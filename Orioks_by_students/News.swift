//
//  News.swift
//  Orioks_by_students
//
//  Created by Артур Данилов on 29.11.2021.
//

import SwiftUI

struct NewsCard: View, Identifiable
{
    @State var date: String
    @State var time: String
    @State var header: String
    @State var news: String
    @State private var open = false
    
    var id = UUID()
    private let minHeight = UIScreen.screenHeight * 0.2
    private let maxHeight = UIScreen.screenHeight * 0.8
    
    var body: some View
    {
        HStack
        {
            Spacer()
            
            ZStack()
            {
                VStack()
                {
                    if self.open
                    {
                        ScrollView
                        {
                            HStack
                            {
                                Text("Дата: ")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text(self.date)
                                
                                Spacer()
                                
                                Text("Время:")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text(self.time)
                            }
                            
                            HStack
                            {
                                Text(self.header)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                            }.padding(.top, 10)
                            
                            Text(self.news)
                                .padding(.top, 2)
                            
                            Spacer()
                        }
                    }
                    
                    else
                    {
                        HStack
                        {
                            Text("Дата: ")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text(self.date)
                            
                            Spacer()
                            
                            Text("Время:")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text(self.time)
                        }
                        
                        Spacer()
                        Text(self.header)
                            .frame(width: UIScreen.screenWidth * 0.8, height: self.minHeight * 0.5)
                        Spacer()
                    }
                }
            }
            .padding()
            .frame(width: UIScreen.screenWidth * 0.9, height: self.open ? self.maxHeight : self.minHeight)
            .background(Color("NewsCard.Background"))
            .cornerRadius(25)
            .shadow(radius: 10)
            .onTapGesture
            {
                self.open.toggle()
            }
            .animation(.easeIn)
            
            Spacer()
        }
    }
}

struct News: View
{
    @Binding var newsInfo: [[String]]
    @Binding var menuOpen: Bool
    
    var body: some View
    {
        NavigationView
        {
            ZStack
            {
                Color("Background").ignoresSafeArea(.all)
                if self.newsInfo.count != 0
                {
                    ScrollView
                    {
                        VStack
                        {
                            ForEach(self.newsInfo.indices, id: \.self) { i in
                                
                                NewsCard(date: self.newsInfo[i][0], time: self.newsInfo[i][1], header: self.newsInfo[i][2], news: self.newsInfo[i][3])
                            }
                        }
                    }
                    .navigationBarTitle("Новости", displayMode: .automatic)
                    .navigationBarItems(trailing:
                        Image(self.menuOpen ? "Exit" : "Menu")
                            .resizable()
                            .frame(width: UIScreen.screenWidth * 0.05, height: UIScreen.screenWidth * 0.05)
                            .onTapGesture
                            {
                                self.menuOpen.toggle()
                            }
                    )
                }
                
                else
                {
                    Text("Новостей нет")
                        .navigationBarTitle("Новости", displayMode: .automatic)
                        .navigationBarItems(trailing:
                            Image(self.menuOpen ? "Exit" : "Menu")
                                .resizable()
                                .frame(width: UIScreen.screenWidth * 0.05, height: UIScreen.screenWidth * 0.05)
                                .onTapGesture
                                {
                                    self.menuOpen.toggle()
                                }
                        )
                }
            }
        }
    }
}

struct News_Previews: PreviewProvider
{
    static var previews: some View
    {
        NewsCard(date: "02.11.21", time: "13:56", header: "Группа ПИН-22. Перевод в дистанционный режим обучения в связи с возникшими случаями заболевания новой коронавирусной инфекцией (Covid-19)", news: "Вниманию преподавателей и студентов! В связи с возникшими случаями заболевания новой коронавирусной инфекцией (Covid-19) обучающиеся  группы ПИН-22 переводятся в дистанционный режим обучения с сохранением расписания занятий (преподаватели проводят занятия в дистанционном формате по расписанию). Всем студентам необходимо соблюдать режим самоизоляции по 13.11.2021 г. включительно.")
    }
}
