//
//  ViewModel.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 02/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import UIKit

protocol ViewModel:class { }

protocol _ViewBinding {
	func shouldBindViewModel(viewModel:ViewModel)
	func preferredHeight(viewModel:ViewModel) -> CGFloat
}

protocol ViewBinding :_ViewBinding {
	associatedtype VM = ViewModel
	var viewModel:VM? { get }
	func bindViewModel(viewModel:VM?)
}

extension ViewBinding {
	func shouldBindViewModel(viewModel: ViewModel) {
		self.bindViewModel(viewModel: viewModel as? VM)
	}
	
	func preferredHeight(viewModel:ViewModel) -> CGFloat {
		return 44
	}
}
