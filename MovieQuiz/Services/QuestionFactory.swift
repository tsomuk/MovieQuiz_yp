//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Nikita Tsomuk on 16.04.2023.
//

import Foundation

final class QuestionFactory : QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            
            guard
                let self = self,
                let index = (0..<self.movies.count).randomElement(),
                let movie = self.movies[safe: index]
            else {
                return
            }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async {
                    [weak self ] in guard let self = self else { return }
                    self.delegate?.didFailToLoadData(with: NetworkClient.NetworkError.codeError)
                }
            }
            
            let rating = Float(movie.rating) ?? 0
            print("Рейтинг фильма -",rating)
            
            let randomRating = Float.random(in: 5...9)
            let randomQuestion = Bool.random()
            
            var text = ""
            let correctAnswer : Bool
            
            if randomQuestion {
                 text = "Рейтинг этого фильма больше чем \(Int(randomRating))?"
                 correctAnswer = rating > randomRating
            } else {
                 text = "Рейтинг этого фильма меньше чем \(Int(randomRating))?"
                 correctAnswer = rating < randomRating
            }
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    
    func loadData() {
        moviesLoader.loadMovies {  result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
    
 
