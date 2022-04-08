//
//  JSONStudent.swift
//  Orioks_by_students
//
//  Created by Артур Данилов on 04.04.2022.
//

import Foundation

struct Student: Decodable
{
    var course: Int
    var full_name: String
    var group: String
    var study_direction: String
    var year: String
}
