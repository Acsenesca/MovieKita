//
//  DetailMovieView.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 03/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class DetailMovieViewModel: ViewModel {
	let movie: Movie?
	var selectedLove: Bool = false
	
	init(movie: Movie?) {
		self.movie = movie
	}
}

class DetailMovieView: UIView, ViewBinding {
	
	@IBOutlet weak var titleMovieLabel: UILabel!
	@IBOutlet weak var movieImageView: UIImageView!
	@IBOutlet weak var icoLove: UIImageView!
	@IBOutlet weak var releaseDateLabel: UILabel!
	@IBOutlet weak var overviewLabel: UILabel!
	
	typealias VM = DetailMovieViewModel
	var viewModel: VM?
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func viewSize() -> CGSize {
		let title = viewModel?.movie?.title ?? ""
		let overview = viewModel?.movie?.overview ?? ""
		
		let inset: CGFloat = 32
		let width = UIScreen.main.bounds.width - inset
		
		let titleWidth = width - inset - 88 - 8 - 40
		let titleHeight = title.height(withConstrainedWidth: titleWidth, font: UIFont.systemFont(ofSize: 18, weight: .semibold))
		
		let overviewWidth = width - inset - 88 - 8
		let overviewHeight = overview.height(withConstrainedWidth: overviewWidth, font: UIFont.systemFont(ofSize: 12, weight: .light))
		
		let totalHeight = titleHeight + overviewHeight + inset + 16 + 16
		let height = totalHeight >= 160 ? totalHeight : 160
		
		return CGSize(width: width, height: height)
	}
	
	func bindViewModel(viewModel: VM?) {
		self.viewModel = viewModel
		
		self.configureView()
		self.configureGesture()
	}
	
	func configureView() {
		self.layer.cornerRadius = 10
		
		if let movie = self.viewModel?.movie {
			self.titleMovieLabel.text = movie.title
			self.releaseDateLabel.text = Helper.changeDateFormat(dateString: movie.releaseDate ?? "", fromFormat: "yyyy-MM-dd", toFormat: "MMM dd, YYYY")
			self.overviewLabel.text = movie.overview
			
			if let posterPath = movie.posterPath, let posterURL = URL(string: imageBaseUrl + posterPath) {
				let processor = RoundCornerImageProcessor(cornerRadius: 20)
				self.movieImageView.kf.indicatorType = .activity
				self.movieImageView.kf.setImage(with: posterURL, options: [.processor(processor)])
			}
			
			let storage = MovieStorage()
			let movies = storage.load(key: MovieStorageKey.favoriteList.rawValue)
			
			if let films = movies {
				if let _ = films.first(where: { film in film.id == movie.id }) {
					self.viewModel?.selectedLove = true
					self.icoLove.image = UIImage(named: "ico-love-selected")
				} else {
					self.viewModel?.selectedLove = false
					self.icoLove.image = UIImage(named: "ico-love-unselected")
				}
			}
		}
	}
	
	func configureGesture() {
		let singleTap = UITapGestureRecognizer(target: self, action:  #selector(tapLoveDetected))
		singleTap.numberOfTapsRequired = 1
		
		self.icoLove.isUserInteractionEnabled = true
		self.icoLove.addGestureRecognizer(singleTap)
	}
	
	@objc func tapLoveDetected() {
		if let vm = self.viewModel, let movie = vm.movie {
			vm.selectedLove = !vm.selectedLove
			let storage = MovieStorage()
			
			self.icoLove.image = vm.selectedLove ? UIImage(named: "ico-love-selected") : UIImage(named: "ico-love-unselected")

			var movies = storage.load(key: MovieStorageKey.favoriteList.rawValue)
			
			if let films = movies {
				
				if let index = films.firstIndex(where: { film in film.id == movie.id }) {
					movies?.remove(at: index)
				} else {
					movies?.append(movie)
				}
			}
			
			storage.save(value: movies ?? [], key: MovieStorageKey.favoriteList.rawValue)
		}
	}
}
