//
//  AppDelegate.swift
//  ProductsListScreen
//
//  Created by mustafa sabahy on 16/12/2022.
//


import Foundation
import Combine

protocol WebServiceLogic {
    func loadDataFrom<T: Codable>(url: String) -> AnyPublisher<T, ApiError>
}

class WebService: WebServiceLogic {


    private let decoder = JSONDecoder()
    private let serviceQueue = DispatchQueue(label: "ApiContext",
                                             qos: .utility,
                                             attributes: .concurrent)
    private var subscribtion = Set<AnyCancellable>()


    
    func loadDataFrom<T: Codable>(url: String) -> AnyPublisher<T, ApiError> {
        return Future { [weak self ] promise in
            guard let url = URL(string: url),
                  let self = self else {
                      return promise(.failure(ApiError.inValidURL))
                  }
            
            URLSession
                .shared
                .dataTaskPublisher(for: url)
                .receive(on: self.serviceQueue)
                .map(\.data)
                .decode(type: T.self, decoder: self.decoder)
                .catch { _ in
                    Empty<T, Error>()
                }
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(error)
                        promise(.failure(ApiError.serverError))
                    }
                } receiveValue: { result in
                    promise(.success(result))
                }
                .store(in: &self.subscribtion)
        }
        .eraseToAnyPublisher()
    }
    
}


enum ApiError: String, Error {
    case serverError = "Internal Server Error"
    case inValidURL = "Invalid URL"
}
