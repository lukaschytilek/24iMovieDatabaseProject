//
//  NetworkSessionManager.swift
//  MovieDatabase24i
//
//  Created by chytilek on 07/05/2020.
//  Copyright © 2020 lukaschytilek. All rights reserved.
//

import UIKit
import AFNetworking

class NetworkSessionManager {
    static let sharedNetworkInstance = NetworkSessionManager()
    
    let sessionManager: AFHTTPSessionManager
    private let appDelegate: AppDelegate
    
    /**
        Initialize of NetworkSessionManager for URL https://api.themoviedb.org
        Timeout set for 4 seconds
    */
    private init(){
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        sessionManager = AFHTTPSessionManager.init(baseURL: URL.init(string: "https://api.themoviedb.org"))
        sessionManager.requestSerializer = AFJSONRequestSerializer.init()
        sessionManager.responseSerializer = AFJSONResponseSerializer.init()
        sessionManager.requestSerializer.timeoutInterval = 4
    }
    
    /**
        Request for getting URL for trailer
        - Parameters:
            - movieID: ID of movie
            - success: Callback to handle successfull request
            - failure: Callback to handle failure request
    */
    func getMovieTrailerURL(movieId: Int,
                       success: ((_ task: URLSessionDataTask, _ response: Any?) -> Void)?,
                       failure: ((_ task: URLSessionDataTask?, _ error: Error) -> Void)?){
        sessionManager.get(("/3/movie/\(movieId)/videos\(appDelegate.apiKey)"), parameters: nil, headers: nil, progress: nil, success: success, failure: failure)
    }
    
    /**
        Request for getting popular movies from database
        - Parameters:
            - success: Callback to handle successfull request
            - failure: Callback to handle failure request
    */
    func getPopularMoviesFromMovieDatabase(success: ((_ task: URLSessionDataTask, _ response: Any?) -> Void)?,
                                            failure: ((_ task: URLSessionDataTask?, _ error: Error) -> Void)?){
        sessionManager.get(("/3/movie/popular\(appDelegate.apiKey)"), parameters: nil, headers: nil, progress: nil, success: success, failure: failure)
    }
    
    /**
        Request for getting list of genres from database
        - Parameters:
            - success: Callback to handle successfull request
            - failure: Callback to handle failure request
    */
    func getGenresFromDatabase(success: ((_ task: URLSessionDataTask, _ response: Any?) -> Void)?,
                                    failure: ((_ task: URLSessionDataTask?, _ error: Error) -> Void)?){
        sessionManager.get(("/3/genre/movie/list\(appDelegate.apiKey)"), parameters: nil, headers: nil, progress: nil, success: success, failure: failure)
    }
    
    /**
        Request for getting movie detail information
        - Parameters:
            - movieID: ID of movie
            - success: Callback to handle successfull request
            - failure: Callback to handle failure request
    */
    func getMovieDetail(movieId: Int,
                       success: ((_ task: URLSessionDataTask, _ response: Any?) -> Void)?,
                       failure: ((_ task: URLSessionDataTask?, _ error: Error) -> Void)?){
        sessionManager.get(("/3/movie/\(movieId)\(appDelegate.apiKey)"), parameters: nil, headers: nil, progress: nil, success: success, failure: failure)
    }
}
