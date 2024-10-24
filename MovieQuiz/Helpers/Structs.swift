//
//  Structs.swift
//  MovieQuiz
//
//  Created by Большаков Дмитрий on 24.10.2024.
//

import Foundation

struct QuizQuestion {
    let image: String
    let rating: Double
    let correctAnswer: Bool
}

struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

struct bestResultModel{
    var record: Int
    var timeWhenFinished: Date
}
