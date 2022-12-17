//
//  AppDelegate.swift
//  ProductsListScreen
//
//  Created by mustafa sabahy on 17/12/2022.
//


import Foundation
import CoreData


extension OfflineProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OfflineProduct> {
        return NSFetchRequest<OfflineProduct>(entityName: "OfflineProduct")
    }

    @NSManaged public var productID: Int32
    @NSManaged public var productPrice: Int32
    @NSManaged public var productDescription: String?
    @NSManaged public var image: Data?
    @NSManaged public var width: Int32
    @NSManaged public var height: Int32

}

extension OfflineProduct {
    
    class func fetchRequestResult() ->  NSFetchRequest<NSFetchRequestResult> {
        NSFetchRequest<NSFetchRequestResult>(entityName: "OfflineProduct")
    }
   
    
    var id: Int {
        Int(productID)
    }
    
    var price: Int {
        Int(productPrice)
    }
    
    var pDescription: String {
        productDescription ?? ""
    }
    
    var imageWidth: Int {
        Int(width)
    }
    
    var imageHeight: Int {
        Int(height)
    }
}
