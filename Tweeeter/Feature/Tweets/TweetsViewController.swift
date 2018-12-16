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

class TweetsViewController: UIViewController {

    lazy var viewHolder = ViewHolder()
    lazy var viewModel = TweetsViewModel()
    let cellProperty: TweetCellProperty = TweetCellProperty()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        viewHolder.install(self)

        self.extendedLayoutIncludesOpaqueBars = self.navigationController?.navigationBar.isTranslucent == false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func setScreenName(_ screenName: String) {
        viewModel.inputs.screenName.accept(screenName)
    }

    func setTweets(_ tweets: [Tweet]) {
        viewModel.outputs.tweets.accept(tweets)
    }
}

extension TweetsViewController {

    final class ViewHolder {

        let collectionView: UICollectionView

        init() {
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 8
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        }

        func install(_ viewController: TweetsViewController) {
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

extension TweetsViewController {

    func rebind() {
        bind(viewModel)
    }
    func bind(_ viewModel: TweetsViewModel) {
        let disposeBag = viewModel.bind()
        viewModel.outputs.tweets
            .distinctUntilChanged()
            .map { _ in }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe { [weak self] _ in
                self?.viewHolder.collectionView.reloadData()
            }
            .disposed(by: disposeBag)

        viewModel.inputs
            .screenName
            .skip(1)
            .distinctUntilChanged()
            .filter({ $0.isEmpty == false })
            .map { _ in 10 }
            .bind(to: viewModel.inputs.requestNextWithCount)
            .disposed(by: disposeBag)
    }

}

extension TweetsViewController: UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource,
    UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.outputs.tweets.value.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TweetCell", for: indexPath)
        if let cell = cell as? TweetCell {
            let tweet = viewModel.outputs.tweets.value[indexPath.row]
            cell.set(tweet: tweet)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height = cellProperty.calculateCellHeight(width: collectionView.bounds.width - 16,
                                                      tweet: viewModel.outputs.tweets.value[indexPath.row])

        return CGSize(width: collectionView.bounds.width - 16, height: height)

    }

}
