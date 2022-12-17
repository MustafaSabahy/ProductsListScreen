//
//  AppDelegate.swift
//  ProductsListScreen
//
//  Created by mustafa sabahy on 16/12/2022.
//


import Network
import Combine

class Reachability {
    
    static let shared = Reachability()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "InternetConnectionMonitor")
    private let connection = CurrentValueSubject<Bool, Never>(true)
    var connectionMonitor: AnyPublisher<Bool, Never> {
        connection
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    var connectionStatus: Bool {
        monitor.currentPath.status == .satisfied
    }
    
    private init() {
        monitor.pathUpdateHandler = {[weak self] pathUpdateHandler in
            guard let self = self else { return }
            let lastUpdate = self.connection.value
            let isConnected = pathUpdateHandler.status == .satisfied
            if  lastUpdate != isConnected {
                self.connection.send(isConnected)
            }
        }
        monitor.start(queue: queue)
    }
}
