//
//  CollectionViewBindingUtil.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 02/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewBindingUtil<T:SectionedCollectionSource> {
	
	private var source:T
	private var dummyCell = [String:UICollectionViewCell]()
	
	private lazy var bridgedDataSource: BridgeableCollectionViewDataSource = self.bridgeableCollectionViewDataSource()
	private lazy var bridgedDelegate:BridgeableCollectionViewDelegate = self.bridgeableCollectionViewDelegate()
	private lazy var bridgedFlowDelegate:BridgeableCollectionViewFlowLayoutDelegate = self.bridgeableCollectionViewFlowDelegate()
	
	var didSelectRowAtIndexPathHandler:((IndexPath,UICollectionViewCell) -> ())?
	
	
	init(source:T) {
		self.source = source
	}
	
	private func bridgeableCollectionViewDataSource() -> BridgeableCollectionViewDataSource {
		
		let bridge = BridgeableCollectionViewDataSource (
			numberOfItemsInSectionHandler: { [weak self] in
				self?.source.numberOfCollectionCellAtSection(section: $0) ?? 0
			},
			cellConfiguration: { [weak self] in
				self?.collectionView($0, cellForRowAtIndexPath: $1) ?? UICollectionViewCell()
			},
			viewForSupplementaryElementOfKindAtIndexPathHandler: { [weak self] (collectionView, kind, indexPath) in
				return self?.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, indexPath: indexPath) ?? UICollectionReusableView()
			}
		)
		
		if let source = self.source as? CollectionMultipleSectionedSource {
			bridge.numberOfSectionsHandler = {
				return source.collectionCellNumberOfSections()
			}
		}
		
		return bridge
	}
	
	private func bridgeableCollectionViewDelegate() -> BridgeableCollectionViewDelegate {
		let bridge = BridgeableCollectionViewDelegate()
		
		if let source = self.source as? SelectedCollectionSource {
			bridge.didSelectItemAtIndexPathHandler = {
				return source.didSelectCellAtIndexPath(collectionView: $0, indexPath:$1, withCell: $2)
			}
		}
		if let source = self.source as? DeselectedCollectionSource {
			bridge.didDeselectItemAtIndexPathHandler = {
				return source.didDeselectCellAtIndexPath(collectionView: $0, indexPath:$1)
			}
		}
		if let source = self.source as? WillDisplayCollectionSource {
			bridge.willDisplayItemAtIndexPathHandler = {
				return source.willDisplayCell(collectionView: $0, atIndexPath: $1)
			}
		}
		
		
		return bridge
	}
	
	private func bridgeableCollectionViewFlowDelegate() -> BridgeableCollectionViewFlowLayoutDelegate {
		let bridge = BridgeableCollectionViewFlowLayoutDelegate()
		
		if let source = self.source as? SelectedCollectionSource {
			bridge.didSelectItemAtIndexPathHandler = {
				return source.didSelectCellAtIndexPath(collectionView: $0, indexPath:$1, withCell: $2)
			}
		}
		if let source = self.source as? DeselectedCollectionSource {
			bridge.didDeselectItemAtIndexPathHandler = {
				return source.didDeselectCellAtIndexPath(collectionView: $0, indexPath:$1)
			}
		}
		if let _ = self.source as? SizeCollectionSource {
			bridge.sizeForItemAtIndexPathHandler = { [weak self] in
				return self?.collectionView($0, sizeForRowAtIndexPath: $1) ?? CGSize.zero
			}
		}
		
		if let _ = self.source as? InsetCollectionSource {
			bridge.insetForItemAtIndexHandler = { [weak self] in
				return self?.collectionView($0, insetForItemInSection: $1) ?? UIEdgeInsets.zero
			}
		}
		
		if let _ = self.source as? ReferenceSizeForHeaderInSectionSource {
			bridge.referenceSizeForHeaderInSectionHandler = { [weak self] in
				return self?.collectionView($0, referenceSizeForHeaderInSection: $1) ?? CGSize.zero
			}
		}
		
		return bridge
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForRowAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
		let cellIdentifier = source.collectionCellIdentifierAtIndexPath(indexPath: indexPath)
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath as IndexPath)
		
		if let cellBind = cell as? _ViewBinding {
			cellBind.shouldBindViewModel(viewModel: source.collectionCellModelAtIndexPath(indexPath: indexPath))
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind:String,  indexPath: IndexPath) -> UICollectionReusableView {
		
		var viewIdentifier = "ViewIdentifier"
		if let source = self.source as? HeaderSupplementaryViewSource {
			let identifier = source.supplementaryIdentifierAtIndexPath(indexPath: indexPath)
			viewIdentifier = identifier
		}
		let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: viewIdentifier, for: indexPath as IndexPath)
		
		if let viewBind = supplementaryView as? _ViewBinding, let source = self.source as? HeaderSupplementaryViewSource {
			viewBind.shouldBindViewModel(viewModel: source.headerViewModelAtSection(section: indexPath.section))
		}
		
		return supplementaryView
	}
	
	func collectionView(_ collectionView:UICollectionView, sizeForRowAtIndexPath indexPath: IndexPath) -> CGSize {
		var cell:UICollectionViewCell
		
		if let dummyCell = dummyCell[source.collectionCellIdentifierAtIndexPath(indexPath: indexPath)] {
			cell = dummyCell
		} else {
			cell = source.cellClassAtIndexPath(indexPath: indexPath).viewFromXib()
			dummyCell[self.source.collectionCellIdentifierAtIndexPath(indexPath: indexPath)] = cell
		}
		
		if let cellBind = cell as? _ViewBinding {
			cellBind.shouldBindViewModel(viewModel: source.collectionCellModelAtIndexPath(indexPath: indexPath))
		}
		
		if let sizeSource = source as? SizeCollectionSource {
			return sizeSource.cellSizeAtIndexPath(indexPath: indexPath, withCell:cell)
		} else {
			return cell.viewSize()
		}
	}
	
	func collectionView(_ collectionView:UICollectionView, insetForItemInSection section: Int) -> UIEdgeInsets {
		if let insetSource = source as? InsetCollectionSource {
			return insetSource.cellInsetAtSection(section: section)
		} else {
			return UIEdgeInsets.zero
		}
	}
	
	func collectionView(_ collectionView:UICollectionView, referenceSizeForHeaderInSection section: Int) -> CGSize {
		if let referenceSizeSource = source as? ReferenceSizeForHeaderInSectionSource {
			return referenceSizeSource.referenceSizeForHeaderInSection(section: section)
		} else {
			return CGSize.zero
		}
		
	}
	
	func bindDelegateWithCollectionView(collectionView:UICollectionView) {
		collectionView.delegate = bridgedDelegate
	}
	func bindDatasourceWithCollectionView(collectionView:UICollectionView) {
		collectionView.dataSource = bridgedDataSource
	}
	func bindFlowDelegateWithCollectionView(collectionView:UICollectionView) {
		collectionView.delegate = bridgedFlowDelegate
	}
}


class BridgeableCollectionViewDelegate: NSObject, UICollectionViewDelegate {
	
	var didSelectItemAtIndexPathHandler:((UICollectionView,IndexPath,UICollectionViewCell) -> ())?
	var didDeselectItemAtIndexPathHandler:((UICollectionView,IndexPath) -> ())?
	var willDisplayItemAtIndexPathHandler:((UICollectionView,IndexPath) -> ())?
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let cell = collectionView.cellForItem(at: indexPath as IndexPath) {
			didSelectItemAtIndexPathHandler?(collectionView, indexPath, cell)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		didDeselectItemAtIndexPathHandler?(collectionView, indexPath)
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		willDisplayItemAtIndexPathHandler?(collectionView, indexPath)
	}
}

class BridgeableCollectionViewFlowLayoutDelegate: BridgeableCollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	var sizeForItemAtIndexPathHandler:((UICollectionView,IndexPath) -> CGSize)?
	var insetForItemAtIndexHandler:((UICollectionView,Int) -> UIEdgeInsets)?
	var referenceSizeForHeaderInSectionHandler:((UICollectionView,Int) -> CGSize)?
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return sizeForItemAtIndexPathHandler?(collectionView,indexPath) ?? CGSize.zero
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return insetForItemAtIndexHandler?(collectionView, section) ?? UIEdgeInsets.zero
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return referenceSizeForHeaderInSectionHandler?(collectionView, section) ?? CGSize.zero
	}
}

class BridgeableCollectionViewDataSource: NSObject, UICollectionViewDataSource {
	
	//MARK:- Property
	var numberOfSectionsHandler:(() -> Int)?
	let numberOfItemsInSectionHandler:(Int) -> Int
	let cellForItemAtIndexPathHandler:(UICollectionView, IndexPath) -> UICollectionViewCell
	var viewForSupplementaryElementOfKindAtIndexPathHandler:((UICollectionView, String, IndexPath) -> UICollectionReusableView)
	
	init(numberOfItemsInSectionHandler:@escaping (Int) -> Int, cellConfiguration cellForItemAtIndexPathHandler:@escaping(UICollectionView, IndexPath) -> UICollectionViewCell, viewForSupplementaryElementOfKindAtIndexPathHandler:@escaping((UICollectionView, String, IndexPath) -> UICollectionReusableView)) {
		self.numberOfItemsInSectionHandler = numberOfItemsInSectionHandler
		self.cellForItemAtIndexPathHandler = cellForItemAtIndexPathHandler
		self.viewForSupplementaryElementOfKindAtIndexPathHandler = viewForSupplementaryElementOfKindAtIndexPathHandler
		super.init()
	}
	
	//MARK : UICollectionViewDataSource
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return numberOfSectionsHandler?() ?? 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return numberOfItemsInSectionHandler(section)
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		return cellForItemAtIndexPathHandler(collectionView,indexPath)
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		return viewForSupplementaryElementOfKindAtIndexPathHandler(collectionView, kind, indexPath)
	}
}
