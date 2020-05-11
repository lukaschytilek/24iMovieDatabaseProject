//
//  Movie.swift
//  MovieDatabase24i
//
//  Created by chytilek on 05/05/2020.
//  Copyright © 2020 lukaschytilek. All rights reserved.
//

import UIKit

/**Struct of Movie
*/
struct Movie {
    var id: Int
    var name: String
    var genres: String
    var date: String
    var overview: String
    var posterPath: String
    var posterImage: UIImage
    
    /**
        Returns transformed date from yyyy-MM-dd to dd.MM.yyyy
    */
    func returnDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date: Date = dateFormatter.date(from: self.date)!
        return fixDateFormatter(date: date)
    }
    
    /**
        Returns date in new format
    */
    func fixDateFormatter(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: date)
    }
}
