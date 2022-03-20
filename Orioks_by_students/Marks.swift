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
        
    @Binding var event: AllKms
    @Binding var formControl: String
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                Text("\(self.event.week)")
                    .font(.system(size: UIScreen.screenWidth * 0.04))
                
                Text(self.event.type == nil ? formControl : self.event.type!.name)
                    .font(.system(size: UIScreen.screenWidth * 0.04))
                
                Text("(\(self.event.sh))")
                    .font(.system(size: UIScreen.screenWidth * 0.04))
                    .fontWeight(.heavy)
                
                
                Spacer()
                
                Text("\(self.event.max_ball.clean)")
                    .font(.system(size: UIScreen.screenWidth * 0.04))
                
                ZStack
                {
                    Text(self.event.balls.count == 0 ? "-": (self.event.balls[0].ball == -1 ? "Н" : "\(self.event.balls[0].ball.clean)"))
                        .font(.system(size: UIScreen.screenWidth * 0.04))
                    
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
                    .font(.system(size: UIScreen.screenWidth * 0.06))
                    .multilineTextAlignment(.center)
                    .frame(width: UIScreen.screenWidth * 0.8)
                    .padding(.bottom, 40)
                
                HStack
                {
                    Spacer()
                    
                    VStack
                    {
                        ForEach(self.dise.segments[0].allKms.indices, id: \.self) { i in
                            
                            Events(event: self.$dise.segments[0].allKms[i], formControl: self.$dise.formControl.name)
                                .padding(10)
                            
                        }
                        
                        HStack
                        {
                            Text("Текущая оценка")
                                .font(.system(size: UIScreen.screenWidth * 0.04))
                            
                            Spacer()
                            
                            Text(self.dise.grade.w)
                                .font(.system(size: UIScreen.screenWidth * 0.04))
                                .padding(5)
                                .background(getCircleColor(b: self.dise.grade.b, mvd: self.dise.mvb))
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

    var body: some View
    {
        ZStack
        {
            HStack()
            {
                ZStack
                {
                    DynamicCircle(maxBall: self.$dise.mvb, balls: self.$dise.grade.b, color: getCircleColor(b: self.dise.grade.b, mvd: self.dise.mvb))
                        .padding()

                    VStack(spacing: 0.2)
                    {
                        Text("\(self.dise.grade.b.clean)")
                            .font(.system(size: UIScreen.screenWidth * 0.04))
                        
                        Capsule()
                            .frame(width: UIScreen.screenWidth * 0.46 * 0.6 * 0.4, height: 1)
                        
                        Text("\(self.dise.mvb.clean)")
                            .font(.system(size: UIScreen.screenWidth * 0.04))
                    }
                }
                
                Spacer()
                
                VStack
                {
                    Text(self.dise.name)
                        .font(.system(size: UIScreen.screenWidth * 0.04))
                        .padding(10)
                        .multilineTextAlignment(.center)
                    
                    HStack
                    {
                        Text("Текущая оценка")
                            .font(.system(size: UIScreen.screenWidth * 0.03))
                        
                        Spacer()
                                                                    
                        Text(self.dise.grade.w)
                            .font(.system(size: UIScreen.screenWidth * 0.04))
                            .padding(5)
                            .background(getCircleColor(b: self.dise.grade.b, mvd: self.dise.mvb))
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
                        ForEach(self.server.marksData.dises.indices, id: \.self) { i in
                            
                            NavigationLink(destination: CardView(dise: self.$server.marksData.dises[i]))
                            {
                                DisciplineCard(dise: self.$server.marksData.dises[i])
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
