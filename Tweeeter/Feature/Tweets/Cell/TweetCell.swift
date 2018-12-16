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

    let property = TweetCellProperty()
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
        let textHeight = property.calculateTextHeight(width: bounds.width,
                                                      attributedText: viewHolder.textLabel.attributedText)
        viewHolder.textLabel.pin.height(textHeight)
        viewHolder.mediaView.pin.height(property.calculateMediaHeight(width: bounds.width,
                                                                      media: tweet?.entities?.media))
    }

    func set(tweet: Tweet) {
        self.tweet = tweet

        viewHolder.profileImageView.sd_setImage(with: tweet.user.profileImageUrlHttps)
        viewHolder.userNameLabel.text = tweet.user.name
        viewHolder.userNameLabel.flex.markDirty()
        viewHolder.containerView.flex.markDirty()

        viewHolder.textLabel.attributedText = property.attributedText(from: tweet)
        viewHolder.textLabel.flex.markDirty()

        if let media = tweet.entities?.media, media.isEmpty == false, media[0].type == "photo" {
            viewHolder.mediaView
                .sd_setImage(with: media[0].mediaUrlHttps,
                             placeholderImage: nil,
                             options: [.transformAnimatedImage, .continueInBackground, .scaleDownLargeImages])
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
        let mediaView: UIImageView

        init() {
            self.containerView = UIView()
            self.profileImageView = UIImageView()
            self.userNameLabel = UILabel()
            self.textLabel = UITextView()
            self.mediaView = UIImageView()

            self.textLabel.isEditable = false
            self.textLabel.isScrollEnabled = false
        }

        func install(_ cell: TweetCell) {
            let property = cell.property
            profileImageView.contentMode = .scaleAspectFit
            mediaView.contentMode = .scaleAspectFill
            mediaView.layer.cornerRadius = 10
            mediaView.clipsToBounds = true
            textLabel.font = property.textFont

            cell.contentView.addSubview(containerView)
            containerView.flex.direction(.column).define { column in
                column.addItem().direction(.row).define { row in
                    row.addItem(profileImageView).width(20).height(20).marginRight(8)
                    row.addItem(userNameLabel).grow(1.0).alignSelf(.center)
                }.height(property.userHeight)
                column.addItem(textLabel).marginTop(property.verticalMargin)
                column.addItem(mediaView).marginTop(property.verticalMargin)
            }
            .grow(1.0)
            .paddingHorizontal(property.horizontalMargin)
            .paddingVertical(property.verticalMargin + property.topMargin)

            containerView.backgroundLayer = BackgroundLayer(layer: containerView.layer)
            containerView.backgroundLayer?.cornerRadius = 5
            containerView.backgroundLayer?.fillColor = UIColor(red: 0.9, green: 0.9, blue: 0.8, alpha: 0.3).cgColor
            containerView.backgroundLayer?.strokeColor = UIColor(red: 0.9, green: 0.9, blue: 0.8, alpha: 0.4).cgColor
            containerView.backgroundLayer?.lineWidth = 1.0
        }

        func layout(contentView: UIView) {
            contentView.flex.layout()
            containerView.pin.all()
        }
    }

}
