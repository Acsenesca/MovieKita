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
	var reloadDataHandler: (() -> Void) = {}
	var batchUpdateHandler: (([IndexPath]) -> Void) = { _ in }
	var emptyStateHandler: (() -> Void) = {}
	
	init(movie: Movie?) {
		self.movie = movie
	}
	
	func requestListMovieReview(completionHandler: (() -> Void)? = nil) {
		if let movie = self.movie {
			ServiceAPI.requestListMovieReview(movieId: movie.id)
				.startWithResult { [weak self] (result) in
					if let self = self, let listReview = result.value() {
						
						self.listReview.value = listReview
						self.reviews.value = listReview?.results
						
						self.reloadDataHandler()
						completionHandler?()
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
						
						self.batchUpdateHandler(indexPaths)
					}
			}
		}
	}
}

extension HomeDetailViewModel: SectionedCollectionSource, SizeCollectionSource {
	func numberOfCollectionCellAtSection(section: Int) -> Int {
		self.emptyStateHandler()
		
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
	
	lazy var separatorView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		
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
		view.backgroundColor = .primaryColor
		
		self.bindViewModel()
		
		self.configureCollectionView()
		self.configureSeparatorView()
		self.configureView()
		self.configureRefreshControl()
	}
	
	fileprivate func bindViewModel() {
		collectionViewBinding = CollectionViewBindingUtil(source: self.viewModel)
		collectionViewBinding?.bindFlowDelegateWithCollectionView(collectionView: collectionView)
		collectionViewBinding?.bindDatasourceWithCollectionView(collectionView: collectionView)
		
		viewModel.reloadDataHandler = { [weak self] in
			self?.collectionView.reloadData()
			self?.refreshControl.endRefreshing()
			self?.collectionView.es.stopLoadingMore()
		}
		
		viewModel.emptyStateHandler = { [weak self] in
			if (self?.viewModel.reviews.value?.count == 0) {
				self?.collectionView.setEmptyMessage("Not yet reviewed")
			} else {
				self?.collectionView.restore()
			}
		}
		
		viewModel.batchUpdateHandler = { [weak self] indexPaths in
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
		title = viewModel.movie?.originalTitle
		
		edgesForExtendedLayout = []
		
		view.addSubview(self.detailMovieView)
		
		self.setDetailMovieViewConstraints()
	}
	
	fileprivate func setDetailMovieViewConstraints() {
		detailMovieView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint(item: detailMovieView,
						   attribute: NSLayoutConstraint.Attribute.top,
						   relatedBy: NSLayoutConstraint.Relation.equal,
						   toItem: view,
						   attribute: NSLayoutConstraint.Attribute.top,
						   multiplier: 1,
						   constant: 16).isActive = true
		
		NSLayoutConstraint(item: detailMovieView,
						   attribute: NSLayoutConstraint.Attribute.left,
						   relatedBy: NSLayoutConstraint.Relation.equal,
						   toItem: view,
						   attribute: NSLayoutConstraint.Attribute.left,
						   multiplier: 1,
						   constant: 16).isActive = true
		
		NSLayoutConstraint(item: detailMovieView,
						   attribute: NSLayoutConstraint.Attribute.right,
						   relatedBy: NSLayoutConstraint.Relation.equal,
						   toItem: view,
						   attribute: NSLayoutConstraint.Attribute.right,
						   multiplier: 1,
						   constant: -16).isActive = true
		
		NSLayoutConstraint(item: detailMovieView,
						   attribute: NSLayoutConstraint.Attribute.bottom,
						   relatedBy: NSLayoutConstraint.Relation.equal,
						   toItem: separatorView,
						   attribute: NSLayoutConstraint.Attribute.top,
						   multiplier: 1,
						   constant: -16).isActive = true
		
		NSLayoutConstraint(item: detailMovieView,
						   attribute: NSLayoutConstraint.Attribute.height,
						   relatedBy: NSLayoutConstraint.Relation.equal,
						   toItem: nil,
						   attribute: NSLayoutConstraint.Attribute.notAnAttribute,
						   multiplier: 1,
						   constant: detailMovieView.viewSize().height).isActive = true
	}
	
	fileprivate func configureSeparatorView() {
		view.addSubview(self.separatorView)
		
		setSeparatorViewConstraints()
	}
	
	fileprivate func setSeparatorViewConstraints() {
		separatorView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint(item: separatorView,
						   attribute: NSLayoutConstraint.Attribute.bottom,
						   relatedBy: NSLayoutConstraint.Relation.equal,
						   toItem: collectionView,
						   attribute: NSLayoutConstraint.Attribute.top,
						   multiplier: 1,
						   constant: -16).isActive = true
		
		NSLayoutConstraint(item: separatorView,
						   attribute: NSLayoutConstraint.Attribute.left,
						   relatedBy: NSLayoutConstraint.Relation.equal,
						   toItem: view,
						   attribute: NSLayoutConstraint.Attribute.left,
						   multiplier: 1,
						   constant: 16).isActive = true
		
		NSLayoutConstraint(item: separatorView,
						   attribute: NSLayoutConstraint.Attribute.right,
						   relatedBy: NSLayoutConstraint.Relation.equal,
						   toItem: view,
						   attribute: NSLayoutConstraint.Attribute.right,
						   multiplier: 1,
						   constant: -16).isActive = true
		
		NSLayoutConstraint(item: separatorView,
						   attribute: NSLayoutConstraint.Attribute.height,
						   relatedBy: NSLayoutConstraint.Relation.equal,
						   toItem: nil,
						   attribute: NSLayoutConstraint.Attribute.notAnAttribute,
						   multiplier: 1,
						   constant: 1).isActive = true
	}
	
	fileprivate func configureCollectionView() {
		view.addSubview(self.collectionView)
		
		setCollectionViewConstraints()
		
		self.collectionView.backgroundColor = UIColor.clear
		self.collectionView.showsVerticalScrollIndicator = false
		self.collectionViewLayout.scrollDirection = .vertical
		
		self.collectionView.register(ReviewMovieCell.nib(), forCellWithReuseIdentifier: ReviewMovieCell.identifier())
	}
	
	fileprivate func setCollectionViewConstraints() {
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint(item: collectionView,
						   attribute: NSLayoutConstraint.Attribute.left,
						   relatedBy: NSLayoutConstraint.Relation.equal,
						   toItem: view,
						   attribute: NSLayoutConstraint.Attribute.left,
						   multiplier: 1,
						   constant: 16).isActive = true
		
		NSLayoutConstraint(item: collectionView,
						   attribute: NSLayoutConstraint.Attribute.right,
						   relatedBy: NSLayoutConstraint.Relation.equal,
						   toItem: view,
						   attribute: NSLayoutConstraint.Attribute.right,
						   multiplier: 1,
						   constant: -16).isActive = true
		
		NSLayoutConstraint(item: collectionView,
						   attribute: NSLayoutConstraint.Attribute.bottom,
						   relatedBy: NSLayoutConstraint.Relation.equal,
						   toItem: view,
						   attribute: NSLayoutConstraint.Attribute.bottom,
						   multiplier: 1,
						   constant: -16).isActive = true
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
