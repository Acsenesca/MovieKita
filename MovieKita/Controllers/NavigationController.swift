//
//  NavigationController.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 02/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import UIKit

class NavigationController: UINavigationController {
	
	override init(rootViewController: UIViewController) {
		super.init(rootViewController: rootViewController)
		showNavigation()
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.navigationBar.isTranslucent = false
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func hideNavigation() {
		self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		self.navigationBar.shadowImage = UIImage()
		self.navigationBar.isTranslucent = true
		self.navigationBar.isUserInteractionEnabled = false
	}
	
	func showNavigation(_ image:UIImage?, forBarMetrics barMetrics:UIBarMetrics) {
		self.navigationBar.setBackgroundImage(image, for: barMetrics)
		self.navigationBar.shadowImage = UIImage()
		self.navigationBar.isTranslucent = false
		self.navigationBar.isUserInteractionEnabled = true
	}
	
	func showNavigation() {
		self.navigationBar.shadowImage = nil
		self.navigationBar.isTranslucent = false
		self.navigationBar.isUserInteractionEnabled = true
	}
}
