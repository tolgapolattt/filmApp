//
//  HomePageTableViewCell.swift
//
//
//  Created by Tolga Polat on 16.07.2023.
//

import UIKit

class HomePageTableViewCell: UITableViewCell {
    
    var titleLabel: UILabel!
    var yearLabel: UILabel!
    var posterImageView: UIImageView!
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //- MARK: UI ELEMENTS
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        
        yearLabel = UILabel()
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(yearLabel)
        
        posterImageView = UIImageView()
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.contentMode = .scaleAspectFit
        contentView.addSubview(posterImageView)
        

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.widthAnchor.constraint(equalToConstant: 300),
            
            yearLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            yearLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            yearLabel.widthAnchor.constraint(equalToConstant: 80),
            
            posterImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor), // Y ekseni ortalaması
            posterImageView.widthAnchor.constraint(equalToConstant: 30),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            posterImageView.heightAnchor.constraint(equalToConstant: 50),
            
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //- MARK: FUNCS
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        yearLabel.text = movie.year

        if let imageURL = URL(string: movie.poster) {
            downloadImage(from: imageURL)
        }
    }
    private func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
            guard let self = self, let data = data else { return }
            DispatchQueue.main.async {
                self.posterImageView.image = UIImage(data: data)
            }
        }.resume()
    }
    
}


