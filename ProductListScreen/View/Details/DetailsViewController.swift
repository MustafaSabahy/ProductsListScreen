//
//  AppDelegate.swift
//  ProductsListScreen
//
//  Created by mustafa sabahy on 15/12/2022.
//



import UIKit
import Combine


class DetailsViewController: UIViewController {


    @IBOutlet weak private(set) var productDescription: UILabel!


    @IBOutlet weak private(set) var productImage: UIImageView!
    


    var productDetailsViewModel: DetailsViewModelBusiness?
    private var subscriptions = Set<AnyCancellable>()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        observeOnDetails()
        productDetailsViewModel?.getProductDetails()
    }


    private func observeOnDetails() {
        productDetailsViewModel?
            .product
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.showAlert(title: Strings.Messages.error.rawValue, message: error.rawValue)
                }
            } receiveValue: { [weak self] details in
                self?.renderUI(viewModel: details)
            }
            .store(in: &subscriptions)
    }

  
    func renderUI(viewModel details: Details.ProductDetailsViewModel) {
        productDescription.text = details.description
        if let data = details.imageData {
            productImage.loadImage(data: data)
        } else {
            productImage.loadImage(url: details.imageURL!)
        }
    }
}
