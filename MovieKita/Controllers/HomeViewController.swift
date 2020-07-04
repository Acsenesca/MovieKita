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
import ESPullToRefresh

class HomeViewModel: ViewModel {
	var listMovie: MutableProperty<ListMovie?> = MutableProperty(nil)
	var movies: MutableProperty<[Movie]?> = MutableProperty(nil)
	var favMovies: MutableProperty<[Movie]?> = MutableProperty(nil)
	var selectedFilterType: MovieFilterType = .Popular
	var page: Int = 2
	
	var reloadDataHandler: (() -> Void) = {}
	var batchUpdateHandler: (([IndexPath]) -> Void) = { _ in }
	var didSelectHandler: ((Movie) -> Void) = {_ in }
	var emptyStateHandler: (() -> Void) = {}
	
	init() {}
	
	func requestListMovie(movieFilterType: MovieFilterType, completionHandler: (() -> Void)? = nil) {
		ServiceAPI.requestListMovie(movieFilterType: movieFilterType)
			.startWithResult { [weak self] (result) in
				if let self = self, let listMovie = result.value() {
					
					self.listMovie.value = listMovie
					self.movies.value = listMovie?.results
					
					self.reloadDataHandler()
					completionHandler?()
				}				
		}
	}
	
	func requestLoadMoreListMovie(movieFilterType: MovieFilterType) {
		ServiceAPI.requestListMovie(movieFilterType: movieFilterType, page: page)
			.startWithResult { [weak self] (result) in
				if let self = self, let listMovie = result.value() {
					
					var indexPaths: [IndexPath] = []
					let startIndex = self.movies.value?.count ?? 0
					
					self.listMovie.value = listMovie
					self.movies.value?.append(contentsOf: listMovie?.results ?? [])
					self.page += 1
					
					let endIndex = self.movies.value?.count ?? 0
					
					for index in startIndex ..< endIndex {
						let indexPath = IndexPath(item: index, section: 0)
						indexPaths.append(indexPath)
					}
					
					self.batchUpdateHandler(indexPaths)
				}
		}
	}
	
	fileprivate func shouldSelectCell(_ indexPath: IndexPath) {
		if self.selectedFilterType == .Favourite {
			let storage = MovieStorage()
			let fav = storage.value(key: MovieStorageKey.favoriteList.rawValue)
			
			guard let movie = fav?[indexPath.row] else { return }
			self.didSelectHandler(movie)
		} else {
			guard let movie = self.movies.value?[indexPath.row] else { return }
			self.didSelectHandler(movie)
		}
	}
}

extension HomeViewModel: SectionedCollectionSource, SizeCollectionSource, SelectedCollectionSource {
	func numberOfCollectionCellAtSection(section: Int) -> Int {
		if self.selectedFilterType == .Favourite {
			self.emptyStateHandler()
			
			let storage = MovieStorage()
			let fav = storage.value(key: MovieStorageKey.favoriteList.rawValue)
			
			return fav?.count ?? 0
		} else {
			return self.movies.value?.count ?? 0
		}
	}
	func collectionCellIdentifierAtIndexPath(indexPath: IndexPath) -> String {
		return MainMovieCell.identifier()
	}
	func collectionCellModelAtIndexPath(indexPath: IndexPath) -> ViewModel {
		if self.selectedFilterType == .Favourite {
			let storage = MovieStorage()
			let fav = storage.value(key: MovieStorageKey.favoriteList.rawValue)
			
			return MainMovieCellModel(movie: fav?[indexPath.row])
		} else {
			return MainMovieCellModel(movie: self.movies.value?[indexPath.row])
		}
	}
	func cellClassAtIndexPath(indexPath: IndexPath) -> UICollectionViewCell.Type {
		return MainMovieCell.self
	}
	func cellSizeAtIndexPath(indexPath: IndexPath, withCell cell: UICollectionViewCell) -> CGSize {
		return cell.viewSize()
	}
	func didSelectCellAtIndexPath(collectionView: UICollectionView, indexPath: IndexPath, withCell cell: UICollectionViewCell) {
		shouldSelectCell(indexPath)
	}
}

class HomeViewController: UIViewController {
	typealias VM = HomeViewModel
	var viewModel: VM
	
	lazy var collectionViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
	lazy var collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: self.collectionViewLayout)
	private var collectionViewBinding: CollectionViewBindingUtil<HomeViewModel>?
	private let refreshControl = UIRefreshControl()
	
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
		self.configureNotification()
		self.configureRefreshControl()
		
		self.viewModel.requestListMovie(movieFilterType: .Popular)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.viewModel.reloadDataHandler()
	}
	
	fileprivate func bindViewModel() {
		collectionViewBinding = CollectionViewBindingUtil(source: self.viewModel)
		collectionViewBinding?.bindFlowDelegateWithCollectionView(collectionView: collectionView)
		collectionViewBinding?.bindDatasourceWithCollectionView(collectionView: collectionView)
		
		viewModel.reloadDataHandler = { [weak self] in
			self?.navigationItem.titleView = self?.setTitle(title: "Movie Kita", subtitle: self?.viewModel.selectedFilterType.rawValue() ?? "")
			self?.collectionView.reloadData()
			self?.refreshControl.endRefreshing()
			self?.collectionView.es.stopLoadingMore()
		}
		
		viewModel.batchUpdateHandler = { [weak self] indexPaths in
			self?.collectionView.performBatchUpdates({
				self?.collectionView.insertItems(at: indexPaths)
			}) { [weak self] _ in
				self?.refreshControl.endRefreshing()
				self?.collectionView.es.stopLoadingMore()
			}
		}
		
		viewModel.emptyStateHandler = { [weak self] in
			if (self?.viewModel.favMovies.value?.count == 0) || (self?.viewModel.favMovies.value == nil) {
				self?.collectionView.setEmptyMessage("No data to display")
			} else {
				self?.collectionView.restore()
			}
		}
		
		self.collectionView.es.addInfiniteScrolling {
			[unowned self] in
			self.viewModel.requestLoadMoreListMovie(movieFilterType: self.viewModel.selectedFilterType)
		}
		
		viewModel.didSelectHandler = { [weak self] movie -> Void in
			let viewModel = HomeDetailViewModel(movie: movie)
			let controller = HomeDetailViewController(viewModel: viewModel)
			
			self?.navigationController?.pushViewController(controller, animated: true)
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
			top: verticalPadding,
			left: 0,
			bottom: navigationBarHeight + statusBarHeight + verticalPadding,
			right: 0
		)
		
		self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
		self.collectionView.register(MainMovieCell.nib(), forCellWithReuseIdentifier: MainMovieCell.identifier())
	}
	
	fileprivate func configureNavigation() {
		self.navigationItem.titleView = setTitle(title: "Movie Kita", subtitle: self.viewModel.selectedFilterType.rawValue())
		
		let image = UIImage(named: "ico-change-list")?.withTintColor(UIColor.primaryColor, renderingMode: .alwaysOriginal)
		let addBarButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(didChangeButton(_:)))
		
		self.navigationItem.rightBarButtonItem = addBarButton
		self.navigationItem.rightBarButtonItem?.isAccessibilityElement = true
		self.navigationItem.rightBarButtonItem?.accessibilityIdentifier = "add_favourite"
	}
	
	fileprivate func configureNotification() {
		NotificationCenter.default.addObserver(forName: .filterTapped, object: nil, queue: nil, using: {[weak self] (notification) -> Void in
			self?.configureSheetAction()
		})
	}
	
	fileprivate func configureSheetAction() {
		let alert = UIAlertController(title: nil, message: "Please Select an Option", preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: MovieFilterType.Popular.rawValue(), style: .default , handler:{ (UIAlertAction) in
			self.viewModel.selectedFilterType = .Popular
			self.viewModel.requestListMovie(movieFilterType: .Popular)
		}))
		
		alert.addAction(UIAlertAction(title: MovieFilterType.TopRated.rawValue(), style: .default , handler:{ (UIAlertAction) in
			self.viewModel.selectedFilterType = .TopRated
			self.viewModel.requestListMovie(movieFilterType: .TopRated)
		}))
		
		alert.addAction(UIAlertAction(title: MovieFilterType.NowPlaying.rawValue(), style: .default , handler:{ (UIAlertAction) in
			self.viewModel.selectedFilterType = .NowPlaying
			self.viewModel.requestListMovie(movieFilterType: .NowPlaying)
		}))
		
		alert.addAction(UIAlertAction(title: MovieFilterType.Favourite.rawValue(), style: .default , handler:{ (UIAlertAction) in
			self.viewModel.selectedFilterType = .Favourite
			self.viewModel.reloadDataHandler()
		}))
		alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
		
		self.present(alert, animated: true, completion: nil)
	}
	
	private func configureRefreshControl() {
		self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
		
		self.collectionView.addSubview(refreshControl)
		self.collectionView.alwaysBounceVertical = true
		self.collectionView.refreshControl = refreshControl
	}
	
	@objc private func didPullToRefresh() {
		self.viewModel.requestListMovie(movieFilterType: self.viewModel.selectedFilterType)
	}
	
	@objc func didChangeButton(_ sender: UIBarButtonItem) {
		self.configureSheetAction()
	}
	
	func setTitle(title:String, subtitle:String) -> UIView {
		let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))
		
		titleLabel.backgroundColor = UIColor.clear
		titleLabel.textColor = UIColor.black
		titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
		titleLabel.text = title
		titleLabel.sizeToFit()
		
		let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
		subtitleLabel.backgroundColor = UIColor.clear
		subtitleLabel.textColor = UIColor.gray
		subtitleLabel.font = UIFont.systemFont(ofSize: 12)
		subtitleLabel.text = subtitle
		subtitleLabel.sizeToFit()
		
		let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
		titleView.addSubview(titleLabel)
		titleView.addSubview(subtitleLabel)
		
		let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
		
		if widthDiff < 0 {
			let newX = widthDiff / 2
			subtitleLabel.frame.origin.x = abs(newX)
		} else {
			let newX = widthDiff / 2
			titleLabel.frame.origin.x = newX
		}
		
		return titleView
	}
}
