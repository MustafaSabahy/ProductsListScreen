//
//  AppDelegate.swift
//  ProductsListScreen
//
//  Created by mustafa sabahy on 17/12/2022.
//

import CoreData
import UIKit

class CoreDataManager {
    


    static let shared = CoreDataManager()
    private var appDelegate: AppDelegate!
    private var backgroundContext: NSManagedObjectContext!
    private let storageLimit = 20
    


    
    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
            
        }
        backgroundContext = appDelegate.persistentContainer.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
    }
    

  
    func add(product value: ProductsData.ProductViewModel, image data: Data) async {
        guard await getProducts().count < storageLimit else {
            print("No memory space")
            return
        }
        await backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            let fetchRequest = OfflineProduct.fetchRequest()
            let entity = OfflineProduct.entity()
            fetchRequest.predicate = NSPredicate.init(format:"productID == \(value.id)")
            if let result = try? self.backgroundContext.fetch(fetchRequest),
               result.isEmpty {
                let product = OfflineProduct(entity: entity, insertInto: self.backgroundContext)
                product.productID = Int32(value.id)
                product.productPrice = Int32(value.price)
                product.productDescription = value.description
                product.width = Int32(value.imageDetails.width)
                product.height = Int32(value.imageDetails.height)
                product.image = data
                self.saveChanges()
            } else {
                print("already exist")
            }
        }
    }
    
    func getProducts() async -> [OfflineProduct] {
        var products = [OfflineProduct]()
        await backgroundContext.perform { [weak self] in
            guard let self = self else {return}
            do {
                products = try self.backgroundContext.fetch(OfflineProduct.fetchRequest())
            } catch {
                print(error.localizedDescription)
            }
        }
        return products
    }
    
    func reset() {
        self.backgroundContext.perform { [weak self] in
            guard let self = self else {return}
            let request = NSBatchDeleteRequest(fetchRequest: OfflineProduct.fetchRequestResult())
            do {
                try self.backgroundContext.execute(request)
            } catch let error {
                print("error \(error.localizedDescription)")
            }
        }
    }
    
    func getProductBy(id: Int) async -> OfflineProduct? {
        await backgroundContext.perform { [weak self] in
            guard let self = self else {return nil}
            let fetchRequest = OfflineProduct.fetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "productID : \(id)")
            if let result = try? self.backgroundContext.fetch(fetchRequest), !result.isEmpty {
                return result[0]
            }
            return nil
        }
    }
    
    private func saveChanges() {
        if backgroundContext.hasChanges {
            backgroundContext.perform { [weak self] in
                guard let self = self else {return}
                do {
                    try self.backgroundContext.save()
                    print("saved successfully")
                } catch {
                    let nserror = error as NSError
                    fatalError("error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
}
