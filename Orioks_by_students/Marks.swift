//
//  Marks.swift
//  Orioks_by_students
//
//  Created by Артур Данилов on 10.12.2021.
//

import SwiftUI

func getCircleColor(maxBall: Float, currentBall: Float?) -> Color
{
    let performance = (currentBall ?? 0) / maxBall
    var returnColor = Color("Violet")
    
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
        
    @Binding var event: Event
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                Text("\(self.event.week)")
                    .font(.system(size: UIScreen.screenWidth * 0.04))
                
                Text(self.event.type)
                    .font(.system(size: UIScreen.screenWidth * 0.04))
                
                Text(self.event.alias ?? "")
                    .font(.system(size: UIScreen.screenWidth * 0.04))
                    .fontWeight(.heavy)
                
                
                Spacer()
                
                Text("\(self.event.max_grade.clean)")
                    .font(.system(size: UIScreen.screenWidth * 0.04))
                
                ZStack
                {
                    Text(self.event.current_grade == nil ? "-": (self.event.current_grade == -1 ? "Н" : "\(self.event.current_grade!.clean)"))
                        .font(.system(size: UIScreen.screenWidth * 0.04))
                    
                    Rectangle()
                        .stroke(((self.event.current_grade ?? 1) / self.event.max_grade) == 0 ? Color.red : Color("Violet"), style: StrokeStyle(lineWidth: 3))
                        .frame(width: 50, height: 30)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .trim(from: CGFloat(self.event.current_grade == nil ? 1 : 1 - (self.event.current_grade! / self.event.max_grade)), to: 1)
                        .stroke(getCircleColor(maxBall: self.event.current_grade == nil ? 0 : self.event.current_grade!, currentBall: self.event.max_grade), style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
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
    @Binding var discipline: Discipline
    
    var body: some View
    {
        ZStack
        {
            Color("Background").ignoresSafeArea(.all)
            
            ScrollView
            {
                Text(self.discipline.name)
                    .bold()
                    .font(.system(size: UIScreen.screenWidth * 0.06))
                    .multilineTextAlignment(.center)
                    .frame(width: UIScreen.screenWidth * 0.8)
                    .padding(.bottom, 40)
                
                HStack
                {
                    Spacer()
                    
                    VStack
                    {
                        ForEach(self.discipline.events!.indices, id: \.self) { i in
                            
                            Events(event: Binding(self.$discipline.events)![i])
                                .padding(10)
                            
                        }
                        
                        HStack
                        {
                            Text("Текущая оценка")
                                .font(.system(size: UIScreen.screenWidth * 0.04))
                            
                            Spacer()
                            
                            Text(self.discipline.getGrade())
                                .font(.system(size: UIScreen.screenWidth * 0.04))
                                .padding(5)
                                .background(getCircleColor(maxBall: self.discipline.max_grade, currentBall: self.discipline.current_grade))
                                .cornerRadius(4)
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
    @Binding var balls: Float?
    var color: LinearGradient
    var animation = true
    var size: Float = 1

    private let diameter = UIScreen.screenWidth * 0.47 * 0.6

    var body: some View
    {
        ZStack
        {
            Circle()
                .stroke(Color("Violet"), style: StrokeStyle(lineWidth: 3))

            Circle()
                .trim(from: self.isOpen ? CGFloat(1 - ((self.balls ?? 0) / self.maxBall)) : 1, to: 1)
                .stroke(self.color, style: StrokeStyle(lineWidth: 9 * CGFloat(self.size), lineCap: .round, lineJoin: .round))
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
                .animation(self.animation ? .easeIn(duration: self.isOpen ? 0.6 : 0) : .easeIn(duration: 0.3))

        }.frame(width: self.diameter * CGFloat(self.size), height: self.diameter * CGFloat(self.size))
    }
}

struct DisciplineCard: View
{
    @Binding var discipline: Discipline

    var body: some View
    {
        ZStack
        {
            HStack()
            {
                ZStack
                {
                    DynamicCircle(maxBall: self.$discipline.max_grade, balls: self.$discipline.current_grade, color:
                                    LinearGradient(gradient:
                                                    Gradient(
                                                        colors: [getCircleColor(maxBall: self.discipline.max_grade, currentBall: self.discipline.current_grade)]),
                                                        startPoint: .topTrailing,
                                                        endPoint: .bottomLeading))
                        .padding()

                    VStack(spacing: 0.2)
                    {
                        if self.discipline.current_grade == nil
                        {
                            Capsule()
                                .frame(width: UIScreen.screenWidth * 0.46 * 0.6 * 0.4, height: 1)
                        }
                        
                        else
                        {
                            Text("\(self.discipline.current_grade!.clean)")
                                .font(.system(size: UIScreen.screenWidth * 0.04))
                            
                            Capsule()
                                .frame(width: UIScreen.screenWidth * 0.46 * 0.6 * 0.4, height: 1)
                            
                            Text("\(self.discipline.max_grade.clean)")
                                .font(.system(size: UIScreen.screenWidth * 0.04))
                        }
                    }
                }
                
                Spacer()
                
                VStack
                {
                    Text(self.discipline.name)
                        .font(.system(size: UIScreen.screenWidth * 0.04))
                        .padding(10)
                        .multilineTextAlignment(.center)
                    
                    HStack
                    {
                        Text("Текущая оценка")
                            .font(.system(size: UIScreen.screenWidth * 0.03))
                        
                        Spacer()
                                                                    
                        Text(self.discipline.getGrade())
                            .font(.system(size: UIScreen.screenWidth * 0.04))
                            .padding(5)
                            .background(getCircleColor(maxBall: self.discipline.max_grade, currentBall: self.discipline.current_grade))
                            .cornerRadius(4)
                        
                    }.padding(10)
                }
            }
        }
        .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.2)
        .background(Color("MarksCard.Background"))
        .foregroundColor(Color(uiColor: .label))
        .shadow(radius: 5)
        .cornerRadius(20)
    }
}

struct Marks: View
{
    @Binding var menuOpen: Bool
    
    @EnvironmentObject var server: Server    
    
    var body: some View
    {
        NavigationView
        {
            ZStack
            {
                Color("Background").ignoresSafeArea(.all)
                
                ScrollView()
                {
                    VStack
                    {
                        ForEach(self.server.marksData.indices, id: \.self) { i in
                            
                            NavigationLink(destination: CardView(discipline: self.$server.marksData[i]))
                            {
                                DisciplineCard(discipline: self.$server.marksData[i])
                                    .shadow(radius: 10)
                                    .padding([.trailing, .leading], 20)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Оценки", displayMode: .automatic)
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

/* Marks_Previews: PreviewProvider
{
    static var previews: some View
    {
        Events()
            .preferredColorScheme(.dark)
    }
}*/
