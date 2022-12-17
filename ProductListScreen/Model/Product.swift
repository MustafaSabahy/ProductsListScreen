//
//  AppDelegate.swift
//  ProductsListScreen
//
//  Created by mustafa sabahy on 16/12/2022.
//


import Foundation

enum ProductsData {
    
    struct Request {}
    
    typealias Response = [Product]


    struct Product: Codable {
        let id: Int
        let productDescription: String
        let image: Image
        let price: Int

      
        struct Image: Codable {
            let width, height: Int
            let url: String
        }
    }
    
    
    struct ProductViewModel {
        let id: Int
        let description: String
        let price: Int
        let imageDetails: (url: String, width: Int, height: Int)
        var image: Data? = nil
        
        init(_ product: Product) {
            self.id = product.id
            self.description = product.productDescription
            self.price = product.price
            self.imageDetails = (product.image.url, product.image.width, product.image.height)
        }
        
        init(_ offlineProduct: OfflineProduct) {
            self.id = offlineProduct.id
            self.price = offlineProduct.price
            self.description = offlineProduct.pDescription
            self.image = offlineProduct.image
            self.imageDetails = ("",
                                 offlineProduct.imageWidth,
                                 offlineProduct.imageHeight)
        }
    }
}

