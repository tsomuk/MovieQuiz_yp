//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Nikita Tsomuk on 05.06.2023.
//

import Foundation

struct AlertModel {
    let title       : String
    let message     : String
    let buttonText  : String
    let buttonAction: () -> Void
}
