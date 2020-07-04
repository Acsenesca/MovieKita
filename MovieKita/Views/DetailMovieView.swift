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
	let selectedLove: Bool = false
	
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
			self.icoLove.image = UIImage(named: "ico-love-selected")
			
			if let posterPath = movie.posterPath, let posterURL = URL(string: imageBaseUrl + posterPath) {
				let processor = RoundCornerImageProcessor(cornerRadius: 20)
				self.movieImageView.kf.indicatorType = .activity
				self.movieImageView.kf.setImage(with: posterURL, options: [.processor(processor)])
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
		print("Single Tap on imageview")
	}

}
