//
//  Marks.swift
//  Orioks_by_students
//
//  Created by Артур Данилов on 10.12.2021.
//

import SwiftUI

func getCircleColor(b: Float, mvd: Float) -> Color
{
    let performance = b / mvd
    var returnColor = Color.white

    if performance < 0.2
    {
        returnColor = Color.red
    }

    else if performance < 0.5
    {
        returnColor = Color("Red")
    }

    else if performance < 0.7
    {
        returnColor = Color("Orange")
    }

    else if performance < 0.9
    {
        returnColor = Color("Green")
    }

    else if performance <= 100
    {
        returnColor = Color.green
    }

    return returnColor
}

extension Float
{
    var clean: String
    {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

struct Events: View
{
    @State var isOpen = false
    
    @Binding var event: AllKms
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                Text("\(self.event.week)")
                Text(self.event.type == nil ? "Экзамен" : self.event.type!.name)
                
                Text("(\(self.event.sh))")
                    .fontWeight(.heavy)

                
                Spacer()
                
                Text("\(self.event.max_ball.clean)")
                
                ZStack
                {
                    Text(self.event.balls.count == 0 ? "-": "\(self.event.balls[0].ball.clean)")
                    
                    Rectangle()
                        .stroke(Color("Violet"), style: StrokeStyle(lineWidth: 3))
                        .frame(width: 50, height: 30)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .trim(from: CGFloat(self.event.balls.count == 0 ? 1 : 1 - (self.event.balls[0].ball / self.event.max_ball)), to: 1)
                        .stroke(getCircleColor(b: self.event.balls.count == 0 ? 0 : self.event.balls[0].ball, mvd: self.event.max_ball), style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
                        .rotationEffect(Angle(degrees: 180))
                        .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
                        .frame(width: 50, height: 30)
                        .cornerRadius(4)
                }
            }
            
            HStack
            {
                Capsule()
                    .fill(Color.gray)
                    .frame(width: UIScreen.screenWidth * 0.7, height: 2)
                
                Spacer()
            }
        }
    }
}

struct CardView: View
{
    @Binding var dise: Dises
    
    var body: some View
    {
        ZStack
        {
            Color("Background").ignoresSafeArea(.all)
            
            ScrollView
            {
                Text(dise.name)
                    .bold()
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .frame(width: UIScreen.screenWidth * 0.8)
                    .padding(.bottom, 40)
                
                HStack
                {
                    Spacer()
                    
                    VStack
                    {
                        ForEach(self.dise.segments[0].allKms.indices, id: \.self) { i in
                            
                            Events(event: self.$dise.segments[0].allKms[i])
                                .padding(10)
                            
                        }
                        
                        HStack
                        {
                            Text("Текущая оценка")
                            
                            Spacer()
                            
                            ZStack
                            {
                                Rectangle()
                                    .fill(getCircleColor(b: self.dise.grade.b, mvd: self.dise.mvb))
                                    .frame(width: 80, height: 30)
                                    .cornerRadius(4)
                                
                                Text(self.dise.grade.w)
                            }
                        }.padding(10)
                    }
                    .background(Color("MarksCard.Background"))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    
                    Spacer()
                }
            }
        }
    }
}

struct DynamicCircle: View
{
    @State var isOpen = false

    @Binding var maxBall: Float
    @Binding var balls: Float
    var color: Color

    private let diameter = UIScreen.screenWidth * 0.47 * 0.6

    var body: some View
    {
        ZStack
        {
            Circle()
                .stroke(Color("Violet"), style: StrokeStyle(lineWidth: 3))

            Circle()
                .trim(from: self.isOpen ? CGFloat(1 - (self.balls / self.maxBall)) : 1, to: 1)
                .stroke(self.color, style: StrokeStyle(lineWidth: 9, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: 90))
                .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .onAppear(perform:
                {
                    self.isOpen.toggle()
                })
                .onDisappear(perform:
                {
                    self.isOpen.toggle()
                })
                .animation(.easeIn(duration: self.isOpen ? 0.6 : 0))

        }.frame(width: self.diameter, height: self.diameter)
    }
}

struct DisciplineCard: View
{
    @Binding var dise: Dises

    private let side = UIScreen.screenWidth * 0.46

    var body: some View
    {
        ZStack
        {
            VStack(spacing: 0.2)
            {
                Text(self.dise.name)
                    .padding(10)
                    .multilineTextAlignment(.center)
                    .font(.caption)

                Spacer()

                ZStack
                {
                    DynamicCircle(maxBall: self.$dise.mvb, balls: self.$dise.grade.b, color: getCircleColor(b: self.dise.grade.b, mvd: self.dise.mvb))

                    VStack(spacing: 0.2)
                    {
                        Text("\(self.dise.grade.b.clean)")
                        Capsule()
                            .frame(width: self.side * 0.6 * 0.4, height: 1)
                        Text("\(self.dise.mvb.clean)")
                    }
                }

                Spacer()
            }
        }
        .frame(width: side, height: side)
        .background(Color("MarksCard.Background"))
        .shadow(radius: 20)
        .cornerRadius(20)
    }
}

struct Marks: View
{
    @Binding var data: Education
    @Binding var menuOpen: Bool

    var body: some View
    {
        NavigationView
        {
            ZStack
            {
                Color("Background").ignoresSafeArea(.all)

                ScrollView
                {
                    VStack
                    {
                        ForEach(data.dises.indices.filter {$0 % 2 == 0}, id: \.self) { i in

                            HStack(spacing: 7)
                            {
                                Spacer()
                                
                                NavigationLink(destination: CardView(dise: self.$data.dises[i]))
                                {
                                    DisciplineCard(dise: self.$data.dises[i])
                                        .shadow(radius: 10)
                                }.foregroundColor(Color(uiColor: .label))

                                NavigationLink(destination: CardView(dise: self.$data.dises[i + 1]))
                                {
                                    DisciplineCard(dise: self.$data.dises[i + 1])
                                        .shadow(radius: 10)
                                }.foregroundColor(Color(uiColor: .label))

                                Spacer()
                            }
                        }

                        if (data.dises.count % 2 != 0)
                        {
                            NavigationLink(destination: CardView(dise: self.$data.dises.last!))
                            {
                                DisciplineCard(dise: self.$data.dises.last!)
                                    .shadow(radius: 10)
                            }.foregroundColor(Color(uiColor: .label))
                        }
                    }
                }
            }
            .navigationBarTitle("Оценки", displayMode: .automatic)
            .navigationBarItems(trailing:
                Image(self.menuOpen ? "Exit" : "Menu")
                    .resizable()
                    .frame(width: UIScreen.screenWidth * 0.08, height: UIScreen.screenWidth * 0.08)
                    .onTapGesture
                    {
                        self.menuOpen.toggle()
                    }
            )
        }
    }
}

/* Marks_Previews: PreviewProvider
{
    static var previews: some View
    {
        Events()
            .preferredColorScheme(.dark)
    }
}*/
