//
//  DetailViewController.swift
//  MovieDatabase24i
//
//  Created by chytilek on 06/05/2020.
//  Copyright © 2020 lukaschytilek. All rights reserved.
//

import UIKit
import XCDYouTubeKit
import AVKit

class DetailViewController: UIViewController{
    
    @IBOutlet weak var posterImage: UIImageView?
    @IBOutlet weak var titleLbl: UILabel?
    @IBOutlet weak var genresLbl: UILabel?
    @IBOutlet weak var dateLbl: UILabel?
    @IBOutlet weak var overviewTxt: UITextView?
    
    var movie: Movie?
    var appDelegate: AppDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        updateMovieDetail()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getMovieDetail()
    }
    
    /**
        Update movie details
    */
    func updateMovieDetail() {
        posterImage?.image = movie?.posterImage
        titleLbl?.text = movie?.name
        genresLbl?.text = movie?.genres
        dateLbl?.text = movie?.returnDate()
        overviewTxt?.text = movie?.overview
        
        overviewTxt?.setContentOffset(.zero, animated: false)
    }
    
    /**
        Display error dialog with custom UIAlertAction title
        - Parameters:
            - title: Title of UIAlertAction button
    */
    func showErrorDialog(title: String){
        appDelegate?.showNetworkErrorDialog(view: self, alertAction: UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            if action.title == "Retry"{
                self.getMovieDetail()
            }
            self.dismiss(animated: true, completion: nil)
        }), secondAlertAction: UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
    }
    
    /**
        Getting details about actual movie
     
        If success, detail is parsed and after that is called updateMovieDetail() to update actual view
        If failure, error dialog is displayed but its possible to retry request
    */
    func getMovieDetail(){
        NetworkSessionManager.sharedNetworkInstance.getMovieDetail(movieId: (movie?.id ?? 0), success: { (task: URLSessionDataTask, response: Any?) in
            if(response != nil){
                let movieDict: NSDictionary = response as! NSDictionary
                print(movieDict)
                if movieDict.object(forKey: "title") != nil {
                    self.movie?.name = movieDict.object(forKey: "title") as! String
                    self.movie?.date = movieDict.object(forKey: "release_date") as! String
                    self.movie?.overview = movieDict.object(forKey: "overview") as! String
                    self.movie?.genres = self.returnGenresById(genreIds: movieDict.object(forKey: "genres") as! NSArray)
                    
                    self.updateMovieDetail()
                }
            }
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print(error)
            self.showErrorDialog(title: "Retry")
        })
    }
    
    /**
        Getting URL for movie trailer
     
        If success, response is parsed and used first value from dictionary to play video
        If failure, error dialog is displayed
    */
    func getTrailerURL(){
        NetworkSessionManager.sharedNetworkInstance.getMovieTrailerURL(movieId: (movie?.id ?? 0), success: { (task: URLSessionDataTask, response: Any?) in
            if(response != nil){
                let videosDict: NSDictionary = response as! NSDictionary
                if (videosDict.object(forKey: "results") != nil){
                    let resultsArray: NSArray = videosDict.object(forKey: "results") as! NSArray
                    if resultsArray.count > 0{
                        print(resultsArray[0])
                        self.playVideo(videoIdentifier: (resultsArray[0] as! NSDictionary).object(forKey: "key") as! String)
                    }
                }
            }
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print(error)
            self.showErrorDialog(title: "Ok")
        })
    }
    
    /**
        Return string of genres based on ID of genres
        - Parameters:
            - genreIds: Array of genres ID
        - Returns: Return string of genres
    */
    func returnGenresById(genreIds: NSArray) -> String {
        var returnedGenre: String = String()
        
        for genresResult in genreIds{
            let genreDict: NSDictionary = genresResult as! NSDictionary
            returnedGenre += (genreDict.object(forKey: "name") as? String)! + ", "
        }
        
        if returnedGenre.count > 0{
            returnedGenre.removeLast(2)
        }
        
        return returnedGenre
    }
    
    /**
        Playing video with XCDYoutubeClient
     
        If video identifier is valid and no error occured, video is played
        - Parameters:
            - videoIdentifier: String of video identifier
    */
    func playVideo(videoIdentifier: String){
        XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { (video: XCDYouTubeVideo?, error: Error?) in
            if error == nil {
                let videoPlayer = AVPlayerViewController()
                
                if video?.streamURL != nil {
                    NotificationCenter.default.addObserver(self, selector: #selector(self.videoPlayedToEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
                    
                    videoPlayer.player = AVPlayer(url: video!.streamURL)
                    videoPlayer.player?.play()
                    self.present(videoPlayer, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func videoPlayedToEnd(notification: Notification){
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
        Button to call getTrailerURL, if success, video is played
    */
    @IBAction func watchTrailer(_ sender: Any){
        getTrailerURL()
    }
}
