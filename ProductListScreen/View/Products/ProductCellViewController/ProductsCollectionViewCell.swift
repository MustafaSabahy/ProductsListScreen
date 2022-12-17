//
//  AppDelegate.swift
//  ProductsListScreen
//
//  Created by mustafa sabahy on 15/12/2022.
//


import UIKit

class ProductsCollectionViewCell: UICollectionViewCell {


    
    @IBOutlet weak private var productImage: UIImageView!
    @IBOutlet weak private var productPrice: UILabel!
    @IBOutlet weak private var peroductDescription: UILabel!
    @IBOutlet weak private var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var containerView: UIView!


    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = UIColor.gray.cgColor
    }
    
    override func prepareForReuse() {
        productPrice.text = "0$"
        peroductDescription.text = ""
        productImage.image = UIImage(named: "loading")
    }

  
    func configure(_ product: ProductsData.ProductViewModel) {
        let imageDetails = product.imageDetails
        setupUIImage(width: imageDetails.width, height: imageDetails.height)
        productPrice.text = "\(product.price)$"
        peroductDescription.text = product.description
        
        if let image = product.image {
            productImage.loadImage(data: image)
        } else {
            productImage.loadImage(url: imageDetails.url)
        }
    }
    
    private func setupUIImage(width: Int, height: Int) {
        imageWidthConstraint.constant = CGFloat(width)
        imageHeightConstraint.constant = CGFloat(height)
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
}
