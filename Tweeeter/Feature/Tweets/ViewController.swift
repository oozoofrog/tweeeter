//
//  ViewController.swift
//  Tweeeter
//
//  Created by eyebookpro on 15/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    lazy var viewHolder = ViewHolder()
    var viewModel: TweetsViewModel? {
        didSet {
            _ = viewModel.flatMap(bind)
        }
    }

    init(viewModel: TweetsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.viewModel = TweetsViewModel()
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        viewHolder.install(self)

        _ = viewModel.flatMap(bind)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

}

extension ViewController {

    final class ViewHolder {

        let searchController: UISearchController

        init() {
            searchController = UISearchController(searchResultsController: ViewController(viewModel: TweetsViewModel()))
        }

        func install(_ viewController: ViewController) {

        }

    }

}

extension ViewController {

    func bind(_ viewModel: TweetsViewModel) {

    }

}
