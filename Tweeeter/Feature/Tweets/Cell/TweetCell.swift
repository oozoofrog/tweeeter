//
//  TweetCell.swift
//  Tweeeter
//
//  Created by eyebookpro on 16/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import UIKit
import Model

final class TweetCell: UICollectionViewCell {

    var tweet: Tweet?

    let userName: UILabel
    let textLabel: UITextField

    override init(frame: CGRect) {
        self.userName = UILabel()
        self.textLabel = UITextField()
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func set(tweet: Tweet) {
        self.tweet = tweet

        userName.text = tweet.user.name
        textLabel.text = tweet.text
    }

}
