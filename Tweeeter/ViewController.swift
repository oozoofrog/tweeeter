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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        viewHolder.install(self)

        let viewModel = TweetsViewModel(provider: TweetsProvider(screenName: "swift"))
        self.viewModel = viewModel
        bind(viewModel)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

}

extension ViewController {

    final class ViewHolder {

        let collectionView: UICollectionView

        init() {
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        }

        func install(_ viewController: ViewController) {
            guard let view = viewController.view else { return }
            view.addSubview(collectionView)

            collectionView.backgroundColor = .white

            collectionView.snp.makeConstraints { maker in
                maker.edges.equalToSuperview()
            }
        }

    }

}

extension ViewController {

    func bind(_ viewModel: TweetsViewModel) {
        viewModel.bind()

        viewModel.inputs.requestNextWithCount.accept(10)

    }

}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.outputs.tweets.value.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }

}
