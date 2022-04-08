//
//  JSONTemplates.swift
//  Orioks_by_students
//
//  Created by Артур Данилов on 11.12.2021.
//

import Foundation

struct Discipline: Decodable
{
    var control_form: String?
    var id: Int
    var current_grade: Float?
    var max_grade: Float
    var name: String
    
    var events: [Event]?
    
    func getGrade() -> String
    {
        let performance = (current_grade ?? 0) / max_grade
        var result = ""
        
        if performance < 0.5
        {
            result =  "Неудовл"
        }

        else if performance < 0.7
        {
            result =  "Удовл"
        }

        else if performance < 0.9
        {
            result =  "Хорошо"
        }

        else if performance <= 1
        {
            result = "Отлично"
        }
        
        return result
    }
}

struct Event: Decodable
{
    var alias: String?
    var current_grade: Float?
    var max_grade: Float
    var type: String
    var week: Int
}
