//
//  ViewController.swift
//  MovieDatabase24i
//
//  Created by chytilek on 04/05/2020.
//  Copyright © 2020 lukaschytilek. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var movieTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var verticalView: UIStackView!
    
    var appDelegate: AppDelegate?
    var movies: Array<Movie> = Array<Movie>()
    var moviesFiltered: Array<Movie> = Array<Movie>()
    var genres: Dictionary = Dictionary<Int, String>()
    
    var originalHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        movieTable.delegate = self
        movieTable.dataSource = self
        searchBar.delegate = self
        
        loadGenresAndPopularMovies()
        
        originalHeight = self.view.frame.height
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardState), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardState), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexForSelectedRow = movieTable.indexPathForSelectedRow{
            movieTable.deselectRow(at: indexForSelectedRow, animated: false)
        }
    }
    
    @objc func keyboardState(notification: Notification){
        if notification.name == UIResponder.keyboardDidShowNotification {
            if let sizeOfKeyboard = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                if self.view.frame.height == originalHeight {
                    self.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: originalHeight! - sizeOfKeyboard.height)
                }
            }
        }
        if notification.name == UIResponder.keyboardDidHideNotification {
            if self.view.frame.height != originalHeight {
                self.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: originalHeight!)
            }
        }
    }
    
    func showErrorDialog(){
        appDelegate?.showNetworkErrorDialog(view: self, alertAction: UIAlertAction(title: "Retry", style: .default, handler: { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
            
            self.loadGenresAndPopularMovies()
        }))
    }
    
    func loadPopularMoviesFromMovieDatabase() {
        NetworkSessionManager.sharedNetworkInstance.getPopularMoviesFromMovieDatabase(success: { (task: URLSessionDataTask, response: Any?) in
            if(response != nil){
                let popularDict: NSDictionary = response as! NSDictionary
                if (popularDict.object(forKey: "results") != nil){
                    let resultsArray: NSArray = popularDict.object(forKey: "results") as! NSArray
                    self.movies = Array<Movie>()
                    for movieResult in resultsArray{
                        let movieDict: NSDictionary = movieResult as! NSDictionary
                        let movie: Movie = Movie(id: movieDict.object(forKey: "id") as! Int,
                                                 name: movieDict.object(forKey: "title") as! String,
                                                 genres: self.returnGenresById(genreIds: movieDict.object(forKey: "genre_ids") as! Array<Int>),
                                                 date: movieDict.object(forKey: "release_date") as! String,
                                                 overview: movieDict.object(forKey: "overview") as! String,
                                                 posterPath: "https://image.tmdb.org/t/p/w342" + (movieDict.object(forKey: "poster_path") as! String),
                                                 posterImage: UIImage()
                        )
                        self.getImageFromURL(url: movie.posterPath, imageView: UIImageView())
                        self.movies.append(movie)
                    }
                    self.movieTable.reloadData()
                }
            }
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print(error)
            self.showErrorDialog()
        })
    }
    
    func loadGenresAndPopularMovies(){
        NetworkSessionManager.sharedNetworkInstance.getGenresAndPopularMovies(success: { (task: URLSessionDataTask, response: Any?) in
            if(response != nil){
                let genresDict: NSDictionary = response as! NSDictionary
                if (genresDict.object(forKey: "genres") != nil){
                    let resultsArray: NSArray = genresDict.object(forKey: "genres") as! NSArray
                    self.genres = Dictionary<Int, String>()
                    for genresResult in resultsArray{
                        let genreDict: NSDictionary = genresResult as! NSDictionary
                        self.genres[genreDict.object(forKey: "id") as! Int] = genreDict.object(forKey: "name") as? String
                    }
                    self.loadPopularMoviesFromMovieDatabase()
                }
            }
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print(error)
            self.showErrorDialog()
        })
    }
    
    func getImageFromURL(url: String, imageView: UIImageView){
        guard let imgURL = URL(string: url) else {
            print("Error when creating URL")
            return
        }
        DispatchQueue.global().async {
            guard let imgData = try? Data(contentsOf: imgURL) else {
                print("Error when getting Data")
                return
            }
            let image = UIImage(data: imgData)
            DispatchQueue.main.async {
                //imageView.image = image
                self.findMovieAndAssignImage(url: url, image: image!)
            }
        }
    }
    
    func findMovieAndAssignImage(url: String, image: UIImage){
        var moviePos: Int = 0
        for movie in movies {
            if movie.posterPath.elementsEqual(url) == true{
                movies[moviePos].posterImage = image
                break
            }
            moviePos += 1
        }
        movieTable.reloadData()
    }
    
    func returnGenresById(genreIds: Array<Int>) -> String {
        var returnedGenre: String = String()
        
        for genreId in genreIds{
            if genres[genreId] != nil {
                returnedGenre += genres[genreId]! + ", "
            }
        }
        
        if returnedGenre.count > 0{
            returnedGenre.removeLast(2)
        }
        
        return returnedGenre
    }
    
    func filterMovies(searchText: String){
        moviesFiltered = movies.filter({ (movie: Movie) -> Bool in
            return movie.name.lowercased().contains(searchText.lowercased())
        })
        
        movieTable.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterMovies(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text?.isEmpty ?? true {
            return movies.count
        } else {
            return moviesFiltered.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movieCell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        var movie = movies[indexPath.row]
        if searchBar.text!.count > 0 {
            movie = moviesFiltered[indexPath.row]
        }
        movieCell.movieTitle?.text = movie.name
        movieCell.movieImage.image = movie.posterImage
        
        return movieCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var movie = movies[indexPath.row]
        if searchBar.text!.count > 0 {
            movie = moviesFiltered[indexPath.row]
        }
        
        view.endEditing(true)
        performSegue(withIdentifier: "showDetail", sender: movie)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            if let destination = segue.destination as? DetailViewController {
                destination.movie = sender as? Movie
                destination.updateMovieDetail()
            }
        }
    }
}

