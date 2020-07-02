//
//  FilterView.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 02/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import UIKit

class FilterView: UIView {

	@IBOutlet weak var filterNameLabel: UILabel!
	@IBOutlet weak var actionButton: UIButton!
	@IBOutlet weak var contentView: UIView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.configureView()
		self.configureGesture()
	}
	
	func configureView() {
		self.filterNameLabel.text = MovieFilterType.Popular.rawValue()
		self.filterNameLabel.textColor = .white
		self.actionButton.tintColor = .white
		self.contentView.backgroundColor = .black
	}
	
	func configureGesture() {
		let filterTapGesture = UITapGestureRecognizer(target: self, action: #selector(filterTapped(_:)))
		self.actionButton.isUserInteractionEnabled = true
		self.actionButton.addGestureRecognizer(filterTapGesture)
	}
	
	@objc func filterTapped(_ sender: UITapGestureRecognizer) {
		NotificationCenter.default.post(name: .filterTapped, object: nil)
	}
}

