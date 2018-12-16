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

class ViewController: UIViewController {

    lazy var viewHolder = ViewHolder()
    var viewModel: TweetsViewModel?
    let cellProperty: TweetCellProperty = TweetCellProperty()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let printAccessToken = UIBarButtonItem(title: "?",
                                               style: .done,
                                               target: self,
                                               action: #selector(printAccessKeyForDebugging(_:)))
        navigationItem.leftBarButtonItem = printAccessToken

        let playButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(clickPlay(_:)))
        navigationItem.rightBarButtonItem = playButton

        viewHolder.install(self)

        let viewModel = TweetsViewModel(provider: TweetsProvider(screenName: "neko"))
        self.viewModel = viewModel
        bind(viewModel)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc func printAccessKeyForDebugging(_ sender: Any) {
        print(APIConfiguration.default.accessTokenProvider.accessToken ?? "")
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
        guard scrollToRow < viewHolder.collectionView.numberOfItems(inSection: 0) else { return }
        viewHolder.collectionView.scrollToItem(at: IndexPath(row: scrollToRow, section: 0),
                                               at: .top,
                                               animated: true)
    }
}

extension ViewController {

    final class ViewHolder {

        let collectionView: UICollectionView

        init() {
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 8
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        }

        func install(_ viewController: ViewController) {
            guard let view = viewController.view else { return }
            view.addSubview(collectionView)

            collectionView.backgroundColor = .white
            collectionView.delegate = viewController
            collectionView.dataSource = viewController
            collectionView.register(TweetCell.self)

            collectionView.snp.makeConstraints { maker in
                maker.edges.equalToSuperview()
            }
        }

    }

}

extension ViewController {

    func bind(_ viewModel: TweetsViewModel) {
        let disposeBag = viewModel.bind()

        title = viewModel.name

        viewModel.inputs.requestNextWithCount.accept(10)

        viewModel.outputs.tweets
            .distinctUntilChanged()
            .map { _ in }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe { [weak self] _ in
                self?.viewHolder.collectionView.reloadData()
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
    }

}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.outputs.tweets.value.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
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

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath.row + 1 == collectionView.numberOfItems(inSection: 0) {
            viewModel?.inputs.requestNextWithCount.accept(10)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToRow = viewHolder.collectionView.indexPathsForVisibleItems.first?.row ?? 0
        viewModel?.stopPlay()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate == false else { return }
        scrollToRow = viewHolder.collectionView.indexPathsForVisibleItems.first?.row ?? 0
        viewModel?.stopPlay()
    }
}
