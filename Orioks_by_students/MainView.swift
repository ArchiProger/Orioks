//
//  MainView.swift
//  Orioks_by_students
//
//  Created by Артур Данилов on 28.11.2021.
//

import SwiftUI

struct MainView: View
{
    @State var name: String

    @State var index = 0
    @State var show = false

    var body: some View
    {
        ZStack
        {
            HStack
            {
                VStack
                {
                    Image("MIET_logo")
                        .clipShape(Circle())

                    Text("Привет, \(name)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(name: "Артур")
    }
}
