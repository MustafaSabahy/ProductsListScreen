//
//  AppDelegate.swift
//  ProductsListScreen
//
//  Created by mustafa sabahy on 15/12/2022.
//


import UIKit

protocol Reusable {
    static var reuseIdentifier: String {get}
}

extension Reusable {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}

extension UICollectionViewCell: Reusable {}

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_ cellClass: T.Type)  {
        let nib = UINib(nibName: T.reuseIdentifier, bundle: nil)
        register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T? {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier,
                                             for: indexPath) as? T else { return nil }
        return cell
    }
}
