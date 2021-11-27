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

    var body: some View
    {
        if loginStatus == true && loginStatus != nil
        {
            Text("Home View")
        }

        else
        {
            LoginForm(login: self.$login, password: self.$password, loginStatus: self.$loginStatus)
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
