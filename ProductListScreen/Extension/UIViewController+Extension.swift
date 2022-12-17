//
//  AppDelegate.swift
//  ProductsListScreen
//
//  Created by mustafa sabahy on 15/12/2022.
//


import UIKit

extension UIViewController {
    
    func getController<T: UIViewController>(_ controller: T.Type, fromBoard boardName: String) -> T? {
        guard let controller = UIStoryboard(name: boardName, bundle: nil)
                   .instantiateViewController(withIdentifier: String(describing: T.self)) as? T
                   else { return nil }
        return controller
    }
    
    func navigate(to controller: UIViewController) {
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func showAlert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let closeButton = UIAlertAction(title: "Close", style: .cancel)
        alert.addAction(closeButton)
        self.present(alert, animated: true)
    }
}
