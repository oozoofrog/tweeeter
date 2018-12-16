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
import SDWebImage

///
/// https://github.com/twitter/twitter-text/blob/master/rb/lib/twitter-text/regex.rb
/// 위에 보고 텍스트쪽을 좀 더 만져볼까 하다가 굳이 ㅋㅋ
final class TweetCell: UICollectionViewCell, CellIdentificable {

    private(set) lazy var viewHolder = ViewHolder()
    var tweet: Tweet?

    override init(frame: CGRect) {
        super.init(frame: frame)
        viewHolder.install(self)

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewHolder.install(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        viewHolder.layout(contentView: contentView)
    }

    func set(tweet: Tweet) {
        self.tweet = tweet

        viewHolder.profileImageView.sd_setImage(with: tweet.user.profileImageUrlHttps)
        viewHolder.userNameLabel.text = tweet.user.name
        viewHolder.userNameLabel.flex.markDirty()
        viewHolder.textLabel.text = tweet.text
        viewHolder.textLabel.flex.markDirty()
        viewHolder.containerView.flex.markDirty()

        if let media = tweet.entities?.media, media.isEmpty == false {
            viewHolder.mediaView.isHidden = false
        } else {
            viewHolder.mediaView.isHidden = true
        }
    }

}

extension TweetCell {

    final class ViewHolder {

        var containerView: UIView
        let profileImageView: UIImageView
        let userNameLabel: UILabel
        let textLabel: UITextView
        let mediaView: UIView

        init() {
            self.containerView = UIView()
            self.profileImageView = UIImageView()
            self.userNameLabel = UILabel()
            self.textLabel = UITextView()
            self.mediaView = UIView()

            self.textLabel.isEditable = false
            self.textLabel.isScrollEnabled = false
        }

        func install(_ cell: TweetCell) {

            profileImageView.contentMode = .scaleAspectFit
            textLabel.font = UIFont.systemFont(ofSize: 22, weight: .regular)
            mediaView.backgroundColor = .red

            cell.contentView.addSubview(containerView)
            containerView.flex.direction(.column).define { column in
                column.addItem().direction(.row).define { row in
                    row.addItem(profileImageView).width(20).height(20).marginRight(8)
                    row.addItem(userNameLabel).grow(1.0).alignSelf(.center)
                }
                column.addItem(textLabel).grow(1.0).marginTop(8)
                column.addItem(mediaView).grow(1.0).marginTop(8).height(20)
            }.grow(1.0).justifyContent(.center).paddingHorizontal(16).paddingTop(24)

            textLabel.backgroundLayer = BackgroundLayer(layer: containerView.layer)
            textLabel.backgroundLayer?.cornerRadius = 5
            textLabel.backgroundLayer?.fillColor = UIColor(white: 0, alpha: 0.1).cgColor
            textLabel.backgroundLayer?.strokeColor = UIColor(white: 0, alpha: 0.3).cgColor
            textLabel.backgroundLayer?.lineWidth = 2.0
        }

        func layout(contentView: UIView) {
            contentView.flex.layout()
            containerView.pin.all()
        }
    }

}
