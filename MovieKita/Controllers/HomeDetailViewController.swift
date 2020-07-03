//
//  HomeDetailViewController.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 03/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift

class HomeDetailViewModel: ViewModel {
	let movie: Movie?
	var listReview: MutableProperty<ListReview?> = MutableProperty(nil)
	var reviews: MutableProperty<[Review]?> = MutableProperty(nil)
	var page: Int = 2
	var reloadDataHandler: (([IndexPath]) -> Void) = { _ in }
	
	init(movie: Movie?) {
		self.movie = movie
	}
	
	func requestListMovieReview() {
		if let movie = self.movie {
			ServiceAPI.requestListMovieReview(movieId: movie.id)
				.startWithResult { [weak self] (result) in
					if let self = self, let listReview = result.value() {
						
						self.listReview.value = listReview
						self.reviews.value = listReview?.results
						
						var indexPaths: [IndexPath] = []
						let endIndex = self.reviews.value?.count ?? 0
						
						for index in 0 ..< endIndex {
							let indexPath = IndexPath(item: index, section: 0)
							indexPaths.append(indexPath)
						}
						
						self.reloadDataHandler(indexPaths)
					}
			}
		}
	}
	
	func requestLoadMoreListMovieReview() {
		if let movie = self.movie {
			ServiceAPI.requestListMovieReview(movieId: movie.id, page: page)
				.startWithResult { [weak self] (result) in
					if let self = self, let listReview = result.value() {
						
						var indexPaths: [IndexPath] = []
						let startIndex = self.reviews.value?.count ?? 0
						
						self.listReview.value = listReview
						self.reviews.value?.append(contentsOf: listReview?.results ?? [])
						self.page += 1
						
						let endIndex = self.reviews.value?.count ?? 0
						
						for index in startIndex ..< endIndex {
							let indexPath = IndexPath(item: index, section: 0)
							indexPaths.append(indexPath)
						}
						
						self.reloadDataHandler(indexPaths)
					}
			}
		}
	}
}

extension HomeDetailViewModel: SectionedCollectionSource, SizeCollectionSource {
	func numberOfCollectionCellAtSection(section: Int) -> Int {
		return self.reviews.value?.count ?? 0
	}
	func collectionCellIdentifierAtIndexPath(indexPath: IndexPath) -> String {
		return ReviewMovieCell.identifier()
	}
	func collectionCellModelAtIndexPath(indexPath: IndexPath) -> ViewModel {
		return ReviewMovieCellModel(review: self.reviews.value?[indexPath.row])
	}
	func cellClassAtIndexPath(indexPath: IndexPath) -> UICollectionViewCell.Type {
		return ReviewMovieCell.self
	}
	func cellSizeAtIndexPath(indexPath: IndexPath, withCell cell: UICollectionViewCell) -> CGSize {
		return cell.viewSize()
	}
}

class HomeDetailViewController: UIViewController {
	typealias VM = HomeDetailViewModel
	var viewModel: VM
	
	lazy var collectionViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
	lazy var collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: self.collectionViewLayout)
	private var collectionViewBinding: CollectionViewBindingUtil<HomeDetailViewModel>?
	private let refreshControl = UIRefreshControl()
	
	lazy var detailMovieView: DetailMovieView = {
		let viewModel = DetailMovieViewModel(movie: self.viewModel.movie)
		let view = DetailMovieView.viewFromXib()
		view.bindViewModel(viewModel: viewModel)
		
		return view
	}()
	
	init(viewModel: HomeDetailViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		
		self.bindViewModel()
		self.configureCollectionView()
		self.configureView()
		self.configureRefreshControl()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
	}
	
	fileprivate func bindViewModel() {
		collectionViewBinding = CollectionViewBindingUtil(source: self.viewModel)
		collectionViewBinding?.bindFlowDelegateWithCollectionView(collectionView: collectionView)
		collectionViewBinding?.bindDatasourceWithCollectionView(collectionView: collectionView)
		
		viewModel.reloadDataHandler = { [weak self] indexPaths in
			self?.collectionView.performBatchUpdates({
				self?.collectionView.insertItems(at: indexPaths)
			}) { [weak self] _ in
				self?.refreshControl.endRefreshing()
				self?.collectionView.es.stopLoadingMore()
				self?.collectionView.es.noticeNoMoreData()
			}
		}
		
		self.collectionView.es.addInfiniteScrolling {
			[unowned self] in
			self.viewModel.requestLoadMoreListMovieReview()
		}
		
		self.viewModel.requestListMovieReview()
	}
	
	fileprivate func configureView() {
		self.title = self.viewModel.movie?.originalTitle
		let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
		let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
		let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
		self.detailMovieView.backgroundColor = .blue
		
		self.detailMovieView.frame.size =  CGSize(width: UIScreen.main.bounds.width, height: detailMovieView.frame.height + statusBarHeight + navigationBarHeight)
		
		view.addSubview(self.detailMovieView)
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
			top: verticalPadding + detailMovieView.frame.height,
			left: 0,
			bottom: navigationBarHeight + statusBarHeight + verticalPadding,
			right: 0
		)
		
		self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
		self.collectionView.register(ReviewMovieCell.nib(), forCellWithReuseIdentifier: ReviewMovieCell.identifier())
	}
	
	private func configureRefreshControl() {
		self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
		
		self.collectionView.addSubview(refreshControl)
		self.collectionView.alwaysBounceVertical = true
		self.collectionView.refreshControl = refreshControl
	}
	
	@objc private func didPullToRefresh() {
		self.viewModel.requestListMovieReview()
	}
}
