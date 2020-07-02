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
	
	func requestListMovie(movieFilterType: MovieFilterType) {
		ServiceAPI.requestListMovie(movieFilterType: movieFilterType)
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
	
	lazy var filterView: FilterView = {
		let view = FilterView.viewFromXib()
		
		return view
	}()
	
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
		self.configureFilterView()
		self.configureNotification()
		
		self.viewModel.requestListMovie(movieFilterType: .Popular)
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
		view.addSubview(self.collectionView)
		
		let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
		let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
		let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
		let verticalPadding: CGFloat = 16
		
		self.collectionView.backgroundView?.backgroundColor = UIColor.white
		self.collectionView.backgroundColor = UIColor.primaryColor
		self.collectionViewLayout.scrollDirection = .vertical
		self.collectionView.contentInset = UIEdgeInsets(
			top: verticalPadding + filterView.frame.height,
			left: 0,
			bottom: navigationBarHeight + statusBarHeight + verticalPadding,
			right: 0
		)
		
		self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
		self.collectionView.register(MainMovieCell.nib(), forCellWithReuseIdentifier: MainMovieCell.identifier())
	}
	
	fileprivate func configureNavigation() {
		self.navigationItem.title = "Movie Kita"
	}
	
	fileprivate func configureFilterView() {
		let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
		let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
		let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
		
		self.filterView.frame.size =  CGSize(width: filterView.frame.width, height: filterView.frame.height + statusBarHeight + navigationBarHeight)
		view.addSubview(filterView)
	}
	
	fileprivate func configureNotification() {
		NotificationCenter.default.addObserver(forName: .filterTapped, object: nil, queue: nil, using: {[weak self] (notification) -> Void in
			self?.configureSheetAction()
		})
	}
	
	fileprivate func configureSheetAction() {
		let alert = UIAlertController(title: nil, message: "Please Select an Option", preferredStyle: .actionSheet)
		
		alert.addAction(UIAlertAction(title: MovieFilterType.Popular.rawValue(), style: .default , handler:{ (UIAlertAction)in
			self.viewModel.requestListMovie(movieFilterType: .Popular)
			NotificationCenter.default.post(name: .filterNameChanged, object: MovieFilterType.Popular.rawValue())
		}))
		
		alert.addAction(UIAlertAction(title: MovieFilterType.TopRated.rawValue(), style: .default , handler:{ (UIAlertAction)in
			self.viewModel.requestListMovie(movieFilterType: .TopRated)
			NotificationCenter.default.post(name: .filterNameChanged, object: MovieFilterType.TopRated.rawValue())
		}))
		
		alert.addAction(UIAlertAction(title: MovieFilterType.NowPlaying.rawValue(), style: .default , handler:{ (UIAlertAction)in
			self.viewModel.requestListMovie(movieFilterType: .NowPlaying)
			NotificationCenter.default.post(name: .filterNameChanged, object: MovieFilterType.NowPlaying.rawValue())
		}))
		
		alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
		
		self.present(alert, animated: true, completion: nil)
	}
}
