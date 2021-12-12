//
//  JSONTemplates.swift
//  Orioks_by_students
//
//  Created by Артур Данилов on 11.12.2021.
//

import Foundation

struct Education: Decodable
{
    var dises: [Dises] //Массив дисциплин
}

struct Dises: Decodable
{
    var name: String //Название дисциплины
    var mvb: Float //Доступные баллы
    var segments: [Segments]
    var grade: Grade
}

struct Grade: Decodable
{
    var b: Float //Твои баллы
    var w: String // Удовл/зачет/незачет итд
}

struct Segments: Decodable
{
    var allKms: [AllKms]
}

struct AllKms: Decodable
{
    var name: String? //Кодировка работы
    var max_ball: Int //Максимальный балл за нее
    var type: TypeOf?
    var balls: [Balls]
}

struct TypeOf: Decodable
{
    var name: String// Название работы
}

struct Balls: Decodable
{
    var ball: Float//Баллы за работу
}
