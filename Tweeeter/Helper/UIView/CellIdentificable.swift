//
//  CellIdentificable.swift
//  Tweeeter
//
//  Created by eyebookpro on 16/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import Foundation
import UIKit

protocol CellIdentificable {
    static var identifier: String { get }
}

extension CellIdentificable where Self: UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UICollectionView {

    func register<CellType: CellIdentificable&UICollectionViewCell>(_ identificableCellType: CellType.Type) {
        self.register(CellType.self, forCellWithReuseIdentifier: CellType.identifier)
    }

}
