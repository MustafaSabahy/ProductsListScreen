//
//  AppDelegate.swift
//  ProductsListScreen
//
//  Created by mustafa sabahy on 15/12/2022.
//


import UIKit

fileprivate var imageCashe = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImage(url urlString: String) {
        
        if let image = imageCashe.object(forKey: urlString as NSString) {
            self.image = image
        } else {
            guard let url = URL(string: urlString) else {
                return
            }
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data ) {
                    imageCashe.setObject(image, forKey: urlString as NSString)
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
        }
    }
    
    func loadImage(data: Data) {
        let image = UIImage(data: data)
        self.image = image
    }
}
