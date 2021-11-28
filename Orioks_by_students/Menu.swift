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

struct Icon: View
{
    @Binding var transparencyOfCircle: Bool
    @Binding var diameter: CGFloat
    @State var angle: CGFloat
    let nameOfImage: String
    private let feedback = UIImpactFeedbackGenerator(style: .soft)
    @State private var focus = false
    @State private var scale: CGFloat = 1

    private func radianes(angle: CGFloat) -> CGFloat
    {
        return angle * CGFloat.pi / 180.0
    }

    var body: some View
    {
        Image(self.nameOfImage)
            .resizable()
            .frame(width: self.diameter / 12, height: self.diameter / 12)
            .scaleEffect(self.scale)
            .offset(x: -(self.diameter * 0.439) * cos(radianes(angle: self.angle)), y: -(self.diameter * 0.439) * sin(radianes(angle: self.angle)))
            .opacity(transparencyOfCircle ? 1 : 0)
            .gesture(
                LongPressGesture(minimumDuration: 0.3)
                    .onChanged { value in
                        if !self.focus
                        {
                            self.scale = 2
                            self.feedback.impactOccurred()
                            self.focus.toggle()
                        }
                    }
                    .onEnded { _ in
                        //Open the page
                        self.scale = 1
                        self.focus.toggle()
                    }
            )
    }
}

struct Menu: View
{
    @State private var viewState = CGSize.zero
    @State private var diameter = UIScreen.screenWidth * 0.5
    @State private var transparencyOfCircle = false
    @State private var focus = false
    private let diameterOfCircle = UIScreen.screenWidth * 0.5
    private let feedback = UIImpactFeedbackGenerator(style: .soft)

    private func radianes(angle: CGFloat) -> CGFloat
    {
        return angle * CGFloat.pi / 180.0
    }

    var body: some View
    {
        ZStack
        {
            Circle()
                .fill(Color.gray)
                .frame(width: diameter, height: diameter)
                .opacity(transparencyOfCircle ? 1 : 0.4)

            Icon(transparencyOfCircle: self.$transparencyOfCircle, diameter: self.$diameter, angle: 9, nameOfImage: "newspaper")
            Icon(transparencyOfCircle: self.$transparencyOfCircle, diameter: self.$diameter, angle: 27, nameOfImage: "checkmark.seal")
            Icon(transparencyOfCircle: self.$transparencyOfCircle, diameter: self.$diameter, angle: 45, nameOfImage: "graduationcap")
            Icon(transparencyOfCircle: self.$transparencyOfCircle, diameter: self.$diameter, angle: 63, nameOfImage: "bell.badge")
            Icon(transparencyOfCircle: self.$transparencyOfCircle, diameter: self.$diameter, angle: 81, nameOfImage: "gear")

            Image("arrow.down.right")
                .resizable()
                .frame(width: self.diameter / 12, height: self.diameter / 12)
                .offset(x: -(self.diameter * 0.12), y: -(self.diameter * 0.12))
                .opacity(transparencyOfCircle ? 1 : 0)
                .gesture(
                    LongPressGesture(minimumDuration: 0.3)
                        .onChanged { _ in
                            if !self.focus
                            {
                                self.feedback.impactOccurred()
                                self.focus.toggle()
                            }
                        }
                        .onEnded { _ in
                            self.diameter = diameterOfCircle
                            self.focus.toggle()
                            self.transparencyOfCircle.toggle()
                        }
                )

        }
        .position(x: UIScreen.screenWidth, y: UIScreen.screenHeight)
        .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0))
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !self.transparencyOfCircle
                    {
                        self.transparencyOfCircle.toggle()
                    }

                    let diag = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                    diameter = diameterOfCircle + diag
                }
                .onEnded { value in
                    if self.diameter >= UIScreen.screenWidth * 0.7
                    {
                        self.diameter = UIScreen.screenWidth
                    }

                    else
                    {
                        self.diameter = diameterOfCircle
                        self.transparencyOfCircle.toggle()
                    }
                }
        )
        .edgesIgnoringSafeArea(.all)
    }
}

struct Menu_Previews: PreviewProvider
{
    static var previews: some View
    {
        Menu()
    }
}
