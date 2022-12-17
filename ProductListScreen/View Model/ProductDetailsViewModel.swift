//
//  AppDelegate.swift
//  ProductsListScreen
//
//  Created by mustafa sabahy on 16/12/2022.
//


import Foundation
import Combine

protocol DetailsViewModelBusiness {
    var product: AnyPublisher<Details.ProductDetailsViewModel, ApiError> {get}
    func getProductDetails()
}

class DetailsViewModel: DetailsViewModelBusiness {


    var product: AnyPublisher<Details.ProductDetailsViewModel, ApiError> {
        productSubject.eraseToAnyPublisher()
    }
    private var productID: Int


    private var productSubject = CurrentValueSubject<Details.ProductDetailsViewModel, ApiError>(Details.ProductDetailsViewModel())
    private var subscriptions = Set<AnyCancellable>()
    private var webService: WebServiceLogic?
    private let coreDataManager = CoreDataManager.shared


    init(_ webService: WebServiceLogic?, productID: Int) {
        self.webService = webService
        self.productID = productID
    }

  
    func getProductDetails() {
        Reachability.shared.connectionStatus == true ?
        getOnlineProduct() : getOfflineProduct()
    }
    
    private func getOnlineProduct() {
        guard let webService = webService else {
            return
        }
        let publisher: AnyPublisher<Details.Response, ApiError> = webService.loadDataFrom(url: "\(Strings.URL.products.rawValue)/\(productID)")
        
        publisher.sink { [weak self ] completion in
            guard let self = self else { return }
            if case .failure(let error) = completion {
                self.productSubject.send(completion: .failure(error))
            }
        } receiveValue: { [weak self ] productDetails in
            guard let self = self else { return }
            self.productSubject.value =  Details.ProductDetailsViewModel(product: productDetails)
            self.productSubject.send(completion: .finished)
        }
        .store(in: &subscriptions)
    }
    
    private func getOfflineProduct() {
        Task {
            let offlineProduct = await coreDataManager.getProductBy(id: productID)
            guard let offlineProduct = offlineProduct else {
                productSubject.value = Details.ProductDetailsViewModel()
                productSubject.send(completion: .finished)
                return
            }
            let productDetailsVM = Details.ProductDetailsViewModel(offlineProduct: offlineProduct)
            productSubject.value = productDetailsVM
            productSubject.send(completion: .finished)
        }
    }
    
}
