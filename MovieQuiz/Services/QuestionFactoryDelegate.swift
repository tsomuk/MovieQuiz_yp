//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Nikita Tsomuk on 05.06.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
