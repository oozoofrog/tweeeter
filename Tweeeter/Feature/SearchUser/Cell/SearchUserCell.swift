//
//  SearchUserCell.swift
//  Tweeeter
//
//  Created by eyebookpro on 17/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import UIKit
import Model
import SnapKit
import SDWebImage

final class SearchUserCell: UICollectionViewCell, CellIdentificable {

    let profileImageView: UIImageView = UIImageView()
    let screenNameLabel: UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(screenNameLabel)

        profileImageView.contentMode = .scaleAspectFit
        profileImageView.snp.makeConstraints { maker in
            maker.leading.equalToSuperview().inset(16)
            maker.size.equalTo(CGSize(width: 20, height: 20))
            maker.centerY.equalToSuperview()
        }

        screenNameLabel.snp.makeConstraints { maker in
            maker.leading.equalTo(profileImageView.snp.trailing).offset(8)
            maker.trailing.equalToSuperview()
            maker.centerY.equalToSuperview()
        }
    }

    func set(user: User) {
        profileImageView.sd_setImage(with: user.profileImageUrlHttps)
        screenNameLabel.text = user.screenName
        setNeedsLayout()
    }
}
