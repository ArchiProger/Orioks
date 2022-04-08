//
//  JSONAuth.swift
//  Orioks_by_students
//
//  Created by Артур Данилов on 30.03.2022.
//

import Foundation

struct Auth: Decodable
{
    var error: Error?
    var token: String?
}

struct Error: Decodable
{
    var code: Int
    var text: String
}

struct InfoTokenDeletion: Decodable
{
    var error: String?
}
