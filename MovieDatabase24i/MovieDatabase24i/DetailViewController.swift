//
//  DetailViewController.swift
//  MovieDatabase24i
//
//  Created by chytilek on 06/05/2020.
//  Copyright © 2020 lukaschytilek. All rights reserved.
//

import UIKit
import AFNetworking
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
    var sessionManager: AFHTTPSessionManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        updateMovieDetail()
        initOperationManager()
    }
    
    func initOperationManager() {
        sessionManager = AFHTTPSessionManager.init(baseURL: URL.init(string: "https://api.themoviedb.org"))
        sessionManager?.requestSerializer = AFJSONRequestSerializer.init()
        sessionManager?.responseSerializer = AFJSONResponseSerializer.init()
    }
    
    func updateMovieDetail() {
        posterImage?.image = movie?.posterImage
        titleLbl?.text = movie?.name
        genresLbl?.text = movie?.genres
        dateLbl?.text = movie?.returnDate()
        overviewTxt?.text = movie?.overview
    }
    
    func getTrailerURL(){
        sessionManager?.get(("/3/movie/\(movie?.id ?? 0)/videos" + appDelegate!.apiKey), parameters: nil, headers: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
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
        })
    }
    
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
    
    @IBAction func watchTrailer(_ sender: Any){
        getTrailerURL()
    }
}
