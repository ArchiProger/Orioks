//
//  JSONSchedule.swift
//  Orioks_by_students
//
//  Created by Артур Данилов on 06.02.2022.
//

import Foundation

struct Timetable: Decodable
{
    var Data: [data]
    var Times: [times]
}

struct times: Decodable
{
    var Time: String
    var TimeFrom: String
    var TimeTo: String
}

struct data: Decodable
{
    var Day: Int // Пн, Вт..
    var DayNumber: Int // Числитель/знаменатель
    var Time: time
    var Class: cls
    var Room: room
}

struct time: Decodable
{
    var Time: String // Номер пары
    var TimeFrom: String // Начало пары
    var TimeTo: String // Конец пары
}

struct cls: Decodable
{
    var Name: String // Название дисциплины
    var TeacherFull: String // Имя препода
}

struct room: Decodable
{
    var Name: String // Номер аудитории
}
