//
//  SectionedSourceProtocol.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 02/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import UIKit

//MARK:- CollectionView

protocol CollectionSectionedSource {
	func numberOfCollectionCellAtSection(section:Int) -> Int
	func collectionCellIdentifierAtIndexPath(indexPath:IndexPath) -> String
	func collectionCellModelAtIndexPath(indexPath:IndexPath) -> ViewModel
}
protocol CollectionMultipleSectionedSource: CollectionSectionedSource {
	func collectionCellNumberOfSections() -> Int
}

protocol SectionedCollectionSource:CollectionSectionedSource {
	func cellClassAtIndexPath(indexPath:IndexPath) -> UICollectionViewCell.Type
}
protocol SizeCollectionSource:SectionedCollectionSource {
	func cellSizeAtIndexPath(indexPath:IndexPath, withCell cell:UICollectionViewCell) -> CGSize
}
protocol InsetCollectionSource:SectionedCollectionSource {
	func cellInsetAtSection(section:Int) -> UIEdgeInsets
}
protocol SelectedCollectionSource:SectionedCollectionSource {
	func didSelectCellAtIndexPath(collectionView:UICollectionView,indexPath:IndexPath, withCell cell:UICollectionViewCell)
}
protocol DeselectedCollectionSource:SectionedCollectionSource {
	func didDeselectCellAtIndexPath(collectionView:UICollectionView,indexPath:IndexPath)
}
protocol HeaderSupplementaryViewSource:SectionedCollectionSource {
	func supplementaryIdentifierAtIndexPath(indexPath: IndexPath) -> String
	func headerViewModelAtSection(section:Int) -> ViewModel
}
protocol WillDisplayCollectionSource:SectionedCollectionSource {
	func willDisplayCell(collectionView:UICollectionView, atIndexPath indexPath:IndexPath)
}

protocol ReferenceSizeForHeaderInSectionSource:SectionedCollectionSource {
	func referenceSizeForHeaderInSection(section: Int) -> CGSize
}
