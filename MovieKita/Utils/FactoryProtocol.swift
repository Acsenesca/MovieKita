//
//  FactoryProtocol.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 02/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import UIKit

protocol SectionTypeable {
	associatedtype T:CellTypeable
	func factory() -> SectionFactoryProvider<T>
}

protocol CellTypeable {
	func factory() -> CellFactoryable
}

protocol SectionFactoryable {
	associatedtype T:CellTypeable
	func numberOfItem() -> Int
	func cellType(index:Int) -> T
}

protocol CellFactoryable {
	func identifier() -> String
	func cellClass() -> UITableViewCell.Type
	func viewModel() -> ViewModel
}

struct SectionFactoryProvider<T:CellTypeable>: SectionFactoryable {
	let _cellType: (Int) -> T
	let _numberOfRow: () -> Int
	
	init<S: SectionFactoryable>(_ factory: S) where S.T == T {
		_cellType = factory.cellType
		_numberOfRow = factory.numberOfItem
	}
	func cellType(index:Int) -> T {
		return _cellType(index)
	}
	
	func numberOfItem() -> Int {
		return _numberOfRow()
	}
}

protocol CollectionSectionTypable {
	associatedtype T:CollectionCellTypeable
	func factory() -> CollectionSectionFactoryProvider<T>
}

protocol CollectionCellTypeable {
	func factory() -> CollectionCellFactoryable
}

protocol CollectionSectionFactoryable {
	associatedtype T:CollectionCellTypeable
	func numberOfItem() -> Int
	func cellType(index:Int) -> T
}

protocol CollectionCellFactoryable {
	func identifier() -> String
	func cellClass() -> UICollectionViewCell.Type
	func viewModel() -> ViewModel
}

struct CollectionSectionFactoryProvider<T:CollectionCellTypeable>: CollectionSectionFactoryable {
	let _cellType: (Int) -> T
	let _numberOfRow: () -> Int
	
	init<S: CollectionSectionFactoryable>(_ factory: S) where S.T == T {
		_cellType = factory.cellType
		_numberOfRow = factory.numberOfItem
	}
	func cellType(index:Int) -> T {
		return _cellType(index)
	}
	
	func numberOfItem() -> Int {
		return _numberOfRow()
	}
}
