//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Nikita Tsomuk on 20.06.2023.
//

import Foundation


struct MostPopularMovies : Codable {
    let errorMessage : String
    let items : [MostPopularMovie]
}


struct MostPopularMovie : Codable {
    let title    : String
    let rating   : String
    let imageURL : URL
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
    
    var resizedImageURL: URL {
        let urlString = imageURL.absoluteString
        let imageUrlString = urlString.components(separatedBy: "._")[0] + ".V0_UX600_.jpg"
        
        guard let newURL = URL(string: imageUrlString) else {
            return imageURL
        }
        return newURL
    }
    
    
}
