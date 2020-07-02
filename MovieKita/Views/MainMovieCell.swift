//
//  MainMovieCell.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 02/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import UIKit
import Kingfisher

class MainMovieCellModel: ViewModel {
	let movie: Movie?
	
	init(movie: Movie?) {
		self.movie = movie
		bindModel()
	}
	
	func bindModel() {
		
	}
}

class MainMovieCell: UICollectionViewCell, ViewBinding {
	
	@IBOutlet weak var movieImageView: UIImageView!
	@IBOutlet weak var titleMovieLabel: UILabel!
	@IBOutlet weak var releaseDateLabel: UILabel!
	@IBOutlet weak var overviewLabel: UILabel!
	
	typealias VM = MainMovieCellModel
	var viewModel: VM?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
	}
	
	override func viewSize() -> CGSize {
		return CGSize(width: UIScreen.main.bounds.width - 32, height: 148)
	}
	
	func bindViewModel(viewModel: VM?) {
		self.viewModel = viewModel
		
		configureView()
	}
	
	func configureView() {
		self.layer.cornerRadius = 10
		
		if let movie = self.viewModel?.movie {
			self.titleMovieLabel.text = movie.title
			self.releaseDateLabel.text = movie.releaseDate
			self.overviewLabel.text = movie.overview
			
			if let posterPath = movie.posterPath, let posterURL = URL(string: imageBaseUrl + posterPath) {
				let processor = RoundCornerImageProcessor(cornerRadius: 20)
				self.movieImageView.kf.indicatorType = .activity
				self.movieImageView.kf.setImage(with: posterURL, options: [.processor(processor)])
			}
		}
	}
}
