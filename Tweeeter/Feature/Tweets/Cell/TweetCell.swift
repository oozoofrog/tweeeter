//
//  TweetCell.swift
//  Tweeeter
//
//  Created by eyebookpro on 16/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import UIKit
import Model
import FlexLayout
import PinLayout

final class TweetCell: UICollectionViewCell, CellIdentificable {

    var tweet: Tweet?

    var containerView: UIView?
    let userNameLabel: UILabel
    let textLabel: UITextField

    override init(frame: CGRect) {
        self.userNameLabel = UILabel()
        self.textLabel = UITextField()
        super.init(frame: frame)

        containerView = contentView.flex.addItem().direction(.column).define { column in
            column.addItem(userNameLabel)
            column.addItem(textLabel).grow(1.0).shrink(1.0)
        }.justifyContent(.center).view

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.flex.layout()
        containerView?.pin.marginHorizontal(16).marginVertical(8)
    }

    func set(tweet: Tweet) {
        self.tweet = tweet

        userNameLabel.text = tweet.user.name
        userNameLabel.flex.markDirty()
        textLabel.text = tweet.text
        textLabel.flex.markDirty()
    }

}
