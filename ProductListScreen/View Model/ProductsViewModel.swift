//
//  AppDelegate.swift
//  ProductsListScreen
//
//  Created by mustafa sabahy on 16/12/2022.
//


import Foundation
import Combine

protocol ProductsBusiness {
    var products: AnyPublisher<[ProductsData.ProductViewModel], ApiError> {get}
    func getProducts()
    func refreshProducts()
    func getNextPage()
}

class ProductsViewModel: ProductsBusiness {
        var products: AnyPublisher<[ProductsData.ProductViewModel], ApiError> {
        productsSubject.eraseToAnyPublisher()
    }

  private var productsSubject = CurrentValueSubject<[ProductsData.ProductViewModel], ApiError>([])
    private var subscriptions = Set<AnyCancellable>()
    private let webService: WebServiceLogic
    private let coreDataManager = CoreDataManager.shared

  
    init(_ webService: WebServiceLogic) {
        self.webService = webService
    }


    func getProducts() {
        Reachability.shared.connectionStatus == true ? getOnlineProducts() : getOfflineProducts()
    }
    
    func refreshProducts() {
        Reachability
            .shared
            .connectionMonitor
            .sink { [weak self] status in
                guard let self = self else { return }
                status == true ? self.getOnlineProducts() : self.getOfflineProducts()
            }
            .store(in: &subscriptions)
    }
    
    func getNextPage() {
        let isConnectedToNetwork =  Reachability.shared.connectionStatus
        if isConnectedToNetwork {
            let publisher: AnyPublisher<ProductsData.Response, ApiError> = webService.loadDataFrom(url: Strings.URL.products.rawValue)
            
            publisher.sink { [weak self ] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.productsSubject.send(completion: .failure(error))
                }
            } receiveValue: { [weak self ] products in
                guard let self = self else { return }
                let products =  products.map { ProductsData.ProductViewModel($0)}
                self.update(local: products)
                self.productsSubject.send(self.productsSubject.value + products)
            }
            .store(in: &subscriptions)
        }
    }
    
    private func getOnlineProducts() {
        print("online")
        let publisher: AnyPublisher<ProductsData.Response, ApiError> = webService.loadDataFrom(url: Strings.URL.products.rawValue)
        
        publisher.sink { [weak self ] completion in
            guard let self = self else { return }
            if case .failure(let error) = completion {
                self.productsSubject.send(completion: .failure(error))
            }
        } receiveValue: { [weak self ] products in
            guard let self = self else { return }
            let products =  products.map { ProductsData.ProductViewModel($0)}
            self.clearLoacalData()
            self.update(local: products)
            self.productsSubject.value = products
        }
        .store(in: &subscriptions)
    }
    
    private func getOfflineProducts() {
        print("offline")
        Task {
            let offlineProducts =  await coreDataManager.getProducts()
            let products = offlineProducts.map {
                ProductsData.ProductViewModel($0)
            }
            self.productsSubject.value = products
        }
    }
    
    private func clearLoacalData() {
        coreDataManager.reset()
    }
    private func update(local products: [ProductsData.ProductViewModel]) {
        Task { [weak self] in
            for product in products {
                guard let self = self,
                      let url = URL(string: product.imageDetails.url),
                      let imageData = try? Data(contentsOf: url)  else { return }
                await self.coreDataManager.add(product: product, image: imageData)
            }
        }
    }
    
    deinit {
        self.productsSubject.send(completion: .finished)
    }
}
