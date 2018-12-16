//
//  TweetCellProperty.swift
//  Tweeeter
//
//  Created by eyebookpro on 16/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import UIKit
import Model

struct TweetCellProperty {

    let topMargin: CGFloat = 20
    let verticalMargin: CGFloat = 8
    let horizontalMargin: CGFloat = 16
    let userHeight: CGFloat = 21

    var textFont: UIFont { return UIFont.systemFont(ofSize: 22, weight: .regular) }

    func attributedText(from tweet: Tweet?) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: tweet?.text ?? "",
                                                       attributes: [.font: textFont])
        if let media = tweet?.entities?.media, media.isEmpty == false {
            let indices = media.map { $0.indices }
            for indice in indices where indice.count == 2 {
                let range = NSRange(location: indice[0], length: indice[1] - indice[0])
                attributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.blue], range: range)
            }
        }
        return attributedText
    }

    func calculateTextHeight(width: CGFloat, attributedText: NSAttributedString?) -> CGFloat {
        guard let text = attributedText else { return 42 }
        let size = CGSize(width: width - horizontalMargin * 2, height: .greatestFiniteMagnitude)
        return text.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).height + 42
    }

    func calculateMediaHeight(width: CGFloat, media: [Media]?) -> CGFloat {
        guard let media = media, media.isEmpty == false, media[0].type == "photo" else { return 0 }
        let size = media[0].sizes.thumb
        let mediaWidth = CGFloat(size.w)
        let mediaHeight = CGFloat(size.h)
        return width / mediaWidth * mediaHeight
    }

    func calculateCellHeight(width: CGFloat, tweet: Tweet?) -> CGFloat {
        guard let tweet = tweet else { return 0 }
        let commonAreaHeight = topMargin + verticalMargin
            + userHeight
            + verticalMargin
            + calculateTextHeight(width: width,
                                  attributedText: attributedText(from: tweet))

        return commonAreaHeight
            + verticalMargin
            + calculateMediaHeight(width: width, media: tweet.entities?.media)
            + verticalMargin
    }

}
