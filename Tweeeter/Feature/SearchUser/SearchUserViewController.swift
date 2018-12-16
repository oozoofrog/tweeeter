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

class SearchUserViewController: UICollectionViewController {

    lazy var disposeBag = DisposeBag()
    lazy var viewModel = ViewModel()
    weak var delegate: SearchUserViewDelegate?

    init() {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .white
        collectionView.register(SearchUserCell.self)

        bind()
    }

}

extension SearchUserViewController {

    func bind() {
        viewModel.searchScreenName
            .throttle(0.5, scheduler: MainScheduler.asyncInstance)
            .filter({ $0.isEmpty == false })
            .distinctUntilChanged()
            .flatMap { screenName in
                SearchUserProvider(screenName: screenName)
                    .request()
                    .catchError({ _ in
                        return .never()
                    })
            }
            .bind(to: viewModel.users)
            .disposed(by: disposeBag)

        viewModel
            .users
            .filter({ $0.isEmpty == false })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe { [weak collectionView] _ in
                collectionView?.reloadData()
            }
            .disposed(by: disposeBag)
    }

    func setScreenName(_ screenName: String) {
        viewModel.searchScreenName.accept(screenName)
    }

    final class ViewModel {
        let searchScreenName: PublishRelay<String> = PublishRelay()
        let users: BehaviorRelay<[User]> = BehaviorRelay(value: [])
    }
}

extension SearchUserViewController: UICollectionViewDelegateFlowLayout {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return viewModel.users.value.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: SearchUserCell.identifier,
                                                  for: indexPath)
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SearchUserCell else { return }
        let user = viewModel.users.value[indexPath.row]
        cell.set(user: user)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 80)
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        let user = viewModel.users.value[indexPath.row]
        self.delegate?.searchedUser(user)
    }
}

protocol SearchUserViewDelegate: class {

    func searchedUser(_ user: User)

}
