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
		let author = viewModel?.review?.author ?? ""
		let content = viewModel?.review?.content ?? ""
		
		let inset: CGFloat = 32
		let width = UIScreen.main.bounds.width - inset
		
		let authorWidth = width - inset
		let authorHeight = author.height(withConstrainedWidth: authorWidth, font: UIFont.systemFont(ofSize: 14, weight: .semibold))
		
		let contentWidth = width - inset
		let contentHeight = content.height(withConstrainedWidth: contentWidth, font: UIFont.systemFont(ofSize: 12))
		
		let totalHeight = authorHeight + contentHeight + inset + 8
		let height = totalHeight >= 72 ? totalHeight : 72
		
		return CGSize(width: width, height: height)
	}
	
	func bindViewModel(viewModel: VM?) {
		self.viewModel = viewModel
		
		configureView()
	}
	
	func configureView() {
		self.layer.cornerRadius = 10
		
		if let review = self.viewModel?.review {
			self.authorLabel.text = review.author
			self.contentLabel.text = review.content
		}
	}
}
