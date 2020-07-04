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

class Helper {
	static func changeDateFormat(dateString: String, fromFormat: String, toFormat: String) -> String {
		let inputDateFormatter = DateFormatter()
		inputDateFormatter.dateFormat = fromFormat
		let date = inputDateFormatter.date(from: dateString)

		let outputDateFormatter = DateFormatter()
		outputDateFormatter.dateFormat = toFormat
		return outputDateFormatter.string(from: date ?? Date())
	}}

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

//MARK:- UICollectionViewCell
extension UICollectionViewCell {
    override func viewSize() -> CGSize {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        return self.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

//MARK:- String
public extension String {
	func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
		let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
		
		return ceil(boundingBox.height)
	}

	func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
		let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
		
		return ceil(boundingBox.width)
	}
}

//MARK:- UIColor
extension UIColor {
	static let primaryColor = UIColor(red: 6.0/255.0, green: 173.0/255.0, blue: 239.0/255.0, alpha: 1)
	static let secondaryColor = UIColor(red: 0.976, green: 0.976, blue: 0.976, alpha: 1)
}

extension NSNotification.Name {
	static let filterTapped = NSNotification.Name("filterTapped")
}

//MARK:- UICollectionView
extension UICollectionView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel;
    }

    func restore() {
        self.backgroundView = nil
    }
}
