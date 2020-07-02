//
//  Helper.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 02/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import UIKit

struct Screen {
	static let width: Float = Float(UIScreen.main.bounds.size.width)
	static let height: Float = Float(UIScreen.main.bounds.size.height)
}

extension UIView {
	fileprivate class func typeSafeFromXib<T: UIView>() -> T {
		if let view: AnyObject = Bundle.main.loadNibNamed(self.nibName(), owner: nil, options: nil)?.first as AnyObject? {
			if let viewT = view as? T {
				return viewT
			} else {
				return T()
			}
		} else {
			return T()
		}
	}
	
	class func nibName() -> String {
		return "\(self)".components(separatedBy: ".").last ?? ""
	}
	
	class func viewFromXib() -> Self {
		return typeSafeFromXib()
	}
	
	class func nib() -> UINib {
		let nib = UINib(nibName:self.nibName(), bundle: Bundle.main)
		return nib
	}
	
	class func identifier() -> String {
		return "\(self)"
	}
	
	@objc func viewSize() -> CGSize {
		self.setNeedsLayout()
		self.layoutIfNeeded()
		return self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
	}
}

//MARK:- UITableView
extension UITableViewCell {
	override func viewSize() -> CGSize {
		self.setNeedsLayout()
		self.layoutIfNeeded()
		return self.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
	}
}

//MARK:- UIColor
extension UIColor {
	static let primaryColor = UIColor(red: 249.0/255.0, green: 188.0/255.0, blue: 80.0/255.0, alpha: 1)
	static let secondaryColor = UIColor(red: 0.976, green: 0.976, blue: 0.976, alpha: 1)
}

extension NSNotification.Name {
	static let filterTapped = NSNotification.Name("filterTapped")
	static let filterNameChanged = NSNotification.Name("filterNameChanged")
}
