//
//  AppDelegate.swift
//  ProductsListScreen
//
//  Created by mustafa sabahy on 16/12/2022.
//


import Foundation

enum Details {
    
    struct Request {}
    typealias Response = Product


    struct Product: Codable {
        let id: Int
        let productDescription: String
        let image: Image
        let price: Int
        
        // MARK: - Image
        struct Image: Codable {
            let width, height: Int
            let url: String
        }
    }
    
    struct ProductDetailsViewModel {
        var description: String
        var imageURL: String? 
        var imageData: Data?
        
        init() {
            description = "empty"
            imageURL = ""
            imageData = nil
        }
        
        init(product: Product) {
            self.description = product.productDescription
            self.imageURL = product.image.url
        }
        
        init(offlineProduct: OfflineProduct) {
            self.description = offlineProduct.pDescription
            self.imageData = offlineProduct.image
        }
    }
}
