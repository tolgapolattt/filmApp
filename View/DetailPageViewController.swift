//
//  DetailPageViewController.swift
//
//
//  Created by Tolga Polat on 21.07.2023.
//

import Foundation
import UIKit
import FirebaseAnalytics

class DetailPageViewController: UIViewController {
    var movie: Movie?
    
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //- MARK: UI ELEMENTS
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actorsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    //- MARK: LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(posterImageView)
        view.addSubview(titleLabel)
        view.addSubview(yearLabel)
        view.addSubview(actorsLabel)
        
        
        NSLayoutConstraint.activate([
            
            posterImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            posterImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 90),
            posterImageView.widthAnchor.constraint(equalToConstant: 250),
            posterImageView.heightAnchor.constraint(equalToConstant: 250),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 150),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            yearLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
            actorsLabel.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 10),
            actorsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actorsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
        ])
        updateUI()
        logMovieDetailViewEvent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logMovieDetailViewEvent()
    }
    //- MARK: FUNCS
    
    func logMovieDetailViewEvent() {
        guard let movie = movie else {
            return // Eğer movie boşsa loglama yapma
        }
        
        Analytics.logEvent("movie_detail_view", parameters: [
            "movie_title": movie.title,
            "movie_year": movie.year,
        ])
    }
    
    func updateUI() {
        if let movie = movie {
            titleLabel.text = movie.title
            yearLabel.text = movie.year
            actorsLabel.text = "Actors: \(movie.actors)"
            if let posterURL = URL(string: movie.poster) {
                DispatchQueue.global().async {
                    if let posterData = try? Data(contentsOf: posterURL),
                       let posterImage = UIImage(data: posterData) {
                        DispatchQueue.main.async {
                            self.posterImageView.image = posterImage
                        }
                    }
                }
            }
        }
    }
}

