//
//  Marks.swift
//  Orioks_by_students
//
//  Created by Артур Данилов on 10.12.2021.
//

import SwiftUI

extension Float
{
    var clean: String
    {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

struct CardView: View
{
    var body: some View
    {
        ZStack
        {
            Color("Background").ignoresSafeArea(.all)
            VStack
            {
                Text("Работы")
                    .font(.title)
                    .fontWeight(.bold)
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

    func getCircleColor() -> Color
    {
        let performance = self.dise.grade.b / self.dise.mvb
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
                    DynamicCircle(maxBall: self.$dise.mvb, balls: self.$dise.grade.b, color: self.getCircleColor())

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

                                NavigationLink(destination: CardView())
                                {
                                    DisciplineCard(dise: self.$data.dises[i])
                                        .shadow(radius: 10)
                                }.foregroundColor(Color(uiColor: .label))

                                NavigationLink(destination: CardView())
                                {
                                    DisciplineCard(dise: self.$data.dises[i + 1])
                                        .shadow(radius: 10)
                                }.foregroundColor(Color(uiColor: .label))

                                Spacer()
                            }
                        }

                        if (data.dises.count % 2 != 0)
                        {
                            NavigationLink(destination: CardView())
                            {
                                DisciplineCard(dise: self.$data.dises.last!)
                                    .shadow(radius: 10)
                            }.foregroundColor(Color(uiColor: .label))
                        }
                    }
                }
            }
            .navigationTitle("Успеваемость")
            .navigationViewStyle(.automatic)
        }
    }
}

struct Marks_Previews: PreviewProvider {
    static var previews: some View {
        CardView()
            .preferredColorScheme(.dark)
    }
}
