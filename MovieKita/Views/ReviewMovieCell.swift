//
//  ReviewMovieCell.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 03/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import UIKit

class ReviewMovieCellModel: ViewModel {
	let review: Review?
	
	init(review: Review?) {
		self.review = review

		bindModel()
	}
	
	func bindModel() {
		
	}
}

class ReviewMovieCell: UICollectionViewCell, ViewBinding {
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var contentLabel: UILabel!
	
	typealias VM = ReviewMovieCellModel
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
		if let review = self.viewModel?.review {
			self.authorLabel.text = review.author
			self.contentLabel.text = review.content
		}
	}
}
