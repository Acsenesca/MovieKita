//
//  HomeViewController.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 02/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift

class HomeViewModel: ViewModel {
	var listMovie: MutableProperty<ListMovie?> = MutableProperty(nil)
	var reloadDataHandler: (() -> Void) = {}
	
	init() {}
	
	func requestListMovie() {
		ServiceAPI.requestListMovie(movieFilterType: .Popular)
			.on(started: { () -> () in
				//				PKHUD.sharedHUD.contentView = PKHUDProgressView()
				//				PKHUD.sharedHUD.show()
			}, failed: { (error) -> () in
				//				PKHUD.sharedHUD.contentView = PKHUDTextView(text: error.message())
				//				PKHUD.sharedHUD.hide(animated:true, completion: nil)
			},value: { (_) -> () in
				//				PKHUD.sharedHUD.contentView = PKHUDSuccessView()
				//				PKHUD.sharedHUD.hide(animated:true, completion: nil)
			}).startWithResult { [weak self] (result) in
				if let listMovie = result.value() {
					self?.listMovie.value = listMovie
				}
				self?.reloadDataHandler()
		}
	}
}

extension HomeViewModel: SectionedCollectionSource, SizeCollectionSource, SelectedCollectionSource {
	
	func numberOfCollectionCellAtSection(section: Int) -> Int {
		return self.listMovie.value?.results?.count ?? 0
	}
	func collectionCellIdentifierAtIndexPath(indexPath: IndexPath) -> String {
		return MainMovieCell.identifier()
	}
	func collectionCellModelAtIndexPath(indexPath: IndexPath) -> ViewModel {
		return MainMovieCellModel(movie: self.listMovie.value?.results?[indexPath.row])
	}
	func cellClassAtIndexPath(indexPath: IndexPath) -> UICollectionViewCell.Type {
		return MainMovieCell.self
	}
	func cellSizeAtIndexPath(indexPath: IndexPath, withCell cell: UICollectionViewCell) -> CGSize {
		return cell.viewSize()
	}
	func didSelectCellAtIndexPath(collectionView: UICollectionView, indexPath: IndexPath, withCell cell: UICollectionViewCell) {
		//        self.shouldSelectSelectedUserAtIndex(indexPath: indexPath)
	}
}


class HomeViewController: UIViewController {
	typealias VM = HomeViewModel
	var viewModel: VM
	
	lazy var collectionViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
	lazy var collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: self.collectionViewLayout)
	private var collectionViewBinding: CollectionViewBindingUtil<HomeViewModel>?
	
	init(viewModel: HomeViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemPurple
		
		// Do any additional setup after loading the view, typically from a nib.
		self.bindViewModel()
		self.configureCollectionView()
		self.configureNavigation()
		
		self.viewModel.requestListMovie()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.viewModel.reloadDataHandler()
	}
	
	fileprivate func bindViewModel() {
		collectionViewBinding = CollectionViewBindingUtil(source: self.viewModel)
		collectionViewBinding?.bindFlowDelegateWithCollectionView(collectionView: collectionView)
		collectionViewBinding?.bindDatasourceWithCollectionView(collectionView: collectionView)
		
		viewModel.reloadDataHandler = {[weak self] in
			self?.collectionView.reloadData()
		}
	}
	
	fileprivate func configureCollectionView() {
		view.addSubview(collectionView)
		
		collectionView.backgroundView?.backgroundColor = UIColor.white
		collectionView.backgroundColor = UIColor.primaryColor
		collectionViewLayout.scrollDirection = .vertical
		collectionView.register(MainMovieCell.nib(), forCellWithReuseIdentifier: MainMovieCell.identifier())
	}
	
	fileprivate func configureNavigation() {
		self.navigationItem.title = "Movie Kita"
	}
}
