//
//  HomePageViewController.swift
//
//
//  Created by Tolga Polat on 15.07.2023.
//

import UIKit
import UserNotifications

class HomePageViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    //- MARK: UI ELEMENTS
    
    let searchBar = UISearchBar()
    let tableView = UITableView()
    let loadingView = UIView()
    let viewModel = HomePageViewModel()
    let indicator = UIActivityIndicatorView(style: .gray)
    let backgroundImage = UIImageView(image: UIImage(named: "film"))
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //- MARK: FUNCS

    func setupUI() {
        view.backgroundColor = .white
        
        searchBar.delegate = self
        
        tableView.register(HomePageTableViewCell.self, forCellReuseIdentifier: "HomePageTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundView = backgroundImage
        backgroundImage.alpha = 0.9
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        loadingView.backgroundColor = .gray
        loadingView.alpha = 0
        view.addSubview(loadingView)
        
        loadingView.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor).isActive = true
        
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
}
//- MARK: EXTENSIONS

extension HomePageViewController: UISearchBarDelegate {
    
    //- MARK: SEARCHBAR FUNCS
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchMovies(with: searchText) { error in
            if let error = error {
                print("Arama hatası: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            showLoadingView()
            indicator.startAnimating()
            
            viewModel.searchMovies(with: searchText) { [weak self] error in
                DispatchQueue.main.async {
                    self?.hideLoadingView()
                    self?.indicator.stopAnimating()
                }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self?.showLoadingView()
                        self?.showErrorAlert(message: "Bağlantı hatası: \(error.localizedDescription)")
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                   }
                }
            }
        }
        searchBar.resignFirstResponder()
    }
    
    //- MARK: LOADINGS
    func  showLoadingView() {
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
    }
    
    func hideLoadingView() {
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 0
        }
    }
    
    //- MARK: NOTIFICATIONS
    
    func downloadImageAndShowNotification(movieTitle: String, year: String) {
        let imageURL = URL(string: "https://i.ibb.co/VLg3CyY/image.jpg")!

        URLSession.shared.downloadTask(with: imageURL) { (location, response, error) in
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }
            guard let location = location else {
                print("Error with downloaded image location.")
                return
            }

            do {
                let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let savedURL = documentsURL.appendingPathComponent("notificationImage.jpg")

                try FileManager.default.moveItem(at: location, to: savedURL)

                let content = UNMutableNotificationContent()
                content.title = movieTitle
                content.body = "Bu film \(year) tarihinde listelendi."
                content.sound = UNNotificationSound.default

                if let attachment = try? UNNotificationAttachment(identifier: "imageAttachment", url: savedURL, options: nil) {
                    content.attachments = [attachment]
                }

                let request = UNNotificationRequest(identifier: "SearchNotification", content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            } catch {
                print("Error saving downloaded image: \(error)")
            }
        }.resume()
    }

    //- MARK: ALERTS
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert(message: String) {
        showAlert(title: "Hata", message: message)
    }
}

//- MARK: EXTENSIONS

extension HomePageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = HomePageTableViewCell(style: .default, reuseIdentifier: "HomePageTableViewCell")
        let movie = viewModel.movies[indexPath.row]
        cell.configure(with: movie)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie = viewModel.movies[indexPath.row]
        let movieTitle = selectedMovie.title
        let yearTitle = selectedMovie.year
        downloadImageAndShowNotification(movieTitle: movieTitle, year: yearTitle)
        
        let detailVC = DetailPageViewController(movie: selectedMovie)
            self.present(detailVC, animated: true, completion: nil)
        }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}






