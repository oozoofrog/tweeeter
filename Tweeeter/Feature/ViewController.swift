//
//  ViewController.swift
//  Tweeeter
//
//  Created by eyebookpro on 15/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import UIKit
import SnapKit
import API
import Model
import RxSwift
import RxCocoa

class ViewController: UICollectionViewController {

    lazy var viewHolder = ViewHolder()
    lazy var searchViewHolder = SearchViewHolder()

    var viewModel: TweetsViewModel?
    let cellProperty: TweetCellProperty = TweetCellProperty()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let playButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(clickPlay(_:)))
        navigationItem.rightBarButtonItem = playButton

        viewHolder.install(self)
        searchViewHolder.install(self)

        let viewModel = TweetsViewModel()
        self.viewModel = viewModel
        bind(viewModel)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc func clickPlay(_ sender: Any) {
        if viewModel?.isPlaying == true {
            viewModel?.stopPlay()
        } else {
            viewModel?.startPlay()
        }
    }

    var scrollToRow: Int = 0
    func showNext() {
        scrollToRow += 1
        guard scrollToRow < collectionView.numberOfItems(inSection: 0) else { return }
        collectionView.scrollToItem(at: IndexPath(row: scrollToRow, section: 0),
                                    at: .top,
                                    animated: true)
    }
}

extension ViewController {

    final class ViewHolder {
        func install(_ viewController: ViewController) {
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 8
            viewController.collectionView.collectionViewLayout = layout
            viewController.collectionView.register(TweetCell.self)
        }
    }

}

extension ViewController {

    func bind(_ viewModel: TweetsViewModel) {
        let disposeBag = viewModel.bind()

        viewModel.inputs.screenName.bind(to: rx.title).disposed(by: disposeBag)

        viewModel.inputs.requestNextWithCount.accept(10)

        viewModel.outputs.tweets
            .distinctUntilChanged()
            .map { _ in }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .disposed(by: disposeBag)

        viewModel.outputs.showNext
            .subscribe(onNext: { [weak self] _ in
                self?.showNext()
            })
            .disposed(by: disposeBag)
        viewModel.inputs.startPlay
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] start in
                guard let self = self else { return }
                let button: UIBarButtonItem
                if start {
                    button = UIBarButtonItem(barButtonSystemItem: .pause,
                                             target: self,
                                             action: #selector(self.clickPlay(_:)))
                } else {
                    button = UIBarButtonItem(barButtonSystemItem: .play,
                                             target: self,
                                             action: #selector(self.clickPlay(_:)))
                }
                self.navigationItem.setRightBarButton(button, animated: true)
            })
            .disposed(by: disposeBag)

        guard let resultController = searchViewHolder.resultController else { return }
        guard let searchController = navigationItem.searchController else { return }

        let resultViewModel = resultController.viewModel
        searchController.searchBar.rx.text
            .filter({ _ in searchController.isActive })
            .map { $0 ?? "" }
            .distinctUntilChanged()
            .throttle(0.5, scheduler: MainScheduler.asyncInstance)
            .bind(to: resultViewModel.inputs.screenName)
            .disposed(by: disposeBag)

        searchController.rx.willPresent
            .subscribe(onNext: { [weak resultController, weak self] _ in
                resultController?.rebind()
                resultController?.setScreenName(searchController.searchBar.text ?? "neko")
                resultController?.setTweets(self?.viewModel?.outputs.tweets.value ?? [])
            })
            .disposed(by: disposeBag)
    }

}

extension ViewController: UICollectionViewDelegateFlowLayout {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.outputs.tweets.value.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TweetCell", for: indexPath)
        if let cell = cell as? TweetCell, let tweet = viewModel?.outputs.tweets.value[indexPath.row] {
            cell.set(tweet: tweet)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height = cellProperty.calculateCellHeight(width: collectionView.bounds.width - 16,
                                                      tweet: viewModel?.outputs.tweets.value[indexPath.row])

        return CGSize(width: collectionView.bounds.width - 16, height: height)

    }

    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        if indexPath.row + 1 == collectionView.numberOfItems(inSection: 0) {
            viewModel?.inputs.requestNextWithCount.accept(10)
        }
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToRow = collectionView.indexPathsForVisibleItems.first?.row ?? 0
        viewModel?.stopPlay()
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate == false else { return }
        scrollToRow = collectionView.indexPathsForVisibleItems.first?.row ?? 0
        viewModel?.stopPlay()
    }
}

extension ViewController {

    final class SearchViewHolder {

        var resultController: TweetsViewController?

        func install(_ viewController: ViewController) {
            let resultController = TweetsViewController()
            let searchController = UISearchController(searchResultsController: resultController)
            searchController.searchBar.placeholder = "트위터 사용자 이름 입력"
            viewController.navigationItem.searchController = searchController

            searchController.definesPresentationContext = false
            viewController.definesPresentationContext = true

            self.resultController = resultController
        }

    }

}
