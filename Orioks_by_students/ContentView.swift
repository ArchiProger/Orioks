//
//  ContentView.swift
//  Requests
//
//  Created by Артур Данилов on 25.11.2021.
//

import SwiftUI
import Alamofire
import Kanna

struct ContentView: View
{
    @State private var loginStatus: Bool? = nil
    @State private var login = ""
    @State private var password = ""
    @State private var newsInfo: [[String]] = []

    var body: some View
    {
        if loginStatus == true && loginStatus != nil
        {
            News(newsInfo: self.$newsInfo)
        }

        else
        {
            LoginForm(login: self.$login, password: self.$password, loginStatus: self.$loginStatus, newsInfo: self.$newsInfo)
        }
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
            .previewInterfaceOrientation(.portrait)
    }
}
