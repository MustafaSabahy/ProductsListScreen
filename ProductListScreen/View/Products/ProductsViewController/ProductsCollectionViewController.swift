//
//  AppDelegate.swift
//  ProductsListScreen
//
//  Created by mustafa sabahy on 15/12/2022.
//


import UIKit
import Combine

class ProductsViewController: UIViewController {

  
    
    @IBOutlet weak private var productsCollection: UICollectionView!


    private let webService: WebServiceLogic = WebService()
    private var productsViewModel: ProductsBusiness!
    private var products = [ProductsData.ProductViewModel]() {
        didSet {
            guard isViewLoaded else { return }
            productsCollection.reloadData()
            productsCollection.collectionViewLayout.invalidateLayout()
        }
    }
    private var subscriptions = Set<AnyCancellable>()
    private var indicator: UIActivityIndicatorView!
    private var refreshControl: UIRefreshControl!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        productsViewModel = ProductsViewModel(webService)
        observeOnProducts()
        productsViewModel.refreshProducts()
    }


    private func setupUI() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        setupCollection()
        setupIndicator()
        setupRefreshControll()
    }
    
    private func setupIndicator() {
        indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
    }
    
    private func setupRefreshControll() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: Strings.Messages.pull.rawValue,
                                                            attributes: [.foregroundColor: UIColor.gray])
        refreshControl.tintColor = .gray
        productsCollection.addSubview(refreshControl)
    }
    
    private func setupCollection() {
        if let layout = productsCollection?.collectionViewLayout as? ProductsLayout {
            layout.delegate = self
        }
        productsCollection.register(ProductsCollectionViewCell.self)
        productsCollection.contentInset = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    }

    private func observeOnProducts() {
        productsViewModel
            .products
            .receive(on: DispatchQueue.main)
            .sink {[weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.indicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.showAlert(title: Strings.Messages.error.rawValue, message: error.rawValue)
                }
            } receiveValue: { [weak self] in
                guard let self = self else { return }
                if !$0.isEmpty {
                    self.indicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                }
                self.products = $0
            }
            .store(in: &subscriptions)
    }
    
    @objc private func refresh() {
        productsViewModel.getProducts()
    }
}

extension ProductsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        products.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell: ProductsCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath) else {
            return UICollectionViewCell()
        }
        let product = products[indexPath.row]
        cell.configure(product)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let countOfProductsInRow = 2
        if indexPath.row == products.count -  countOfProductsInRow {
            productsViewModel.getNextPage()
        }
    }
}

extension ProductsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailsView = getController(DetailsViewController.self, fromBoard: "Main") else {return}
        detailsView.productDetailsViewModel =  DetailsViewModel(WebService(),
                                                                productID: products[indexPath.row].id)
        navigate(to: detailsView)
    }
}

extension ProductsViewController: ProductsLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let product = products[indexPath.row]
        let photoHeight = CGFloat(products[indexPath.row].imageDetails.height)
        let descriptionHeight = descriptionHeight(text: product.description, cellWidth: collectionView.bounds.size.width / 2)
        let priceHeight: CGFloat = 16
        let padding: CGFloat = 24
        
        return photoHeight + descriptionHeight + priceHeight + padding
    }
    
    private func descriptionHeight(text: String, cellWidth: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 16)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: cellWidth, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height + 32
    }
}
