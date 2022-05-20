//
//  DetailsView.swift
//  EbsTestViper
//
//  Created by Сережа Присяжнюк on 03.05.2022.
//

import Foundation
import UIKit
import SkeletonView
import RealmSwift

// MARK: Protocol

protocol DetailsViewProtocol {
    var presenter: DetailsPresenterProtocol? { get set }
    var products: Product? { get set }
    func getSingleProductSuccess(singleProduct: Product)
}

// MARK: Class
class DetailsView: BaseViewController, DetailsViewProtocol {
    
    // UIElements
    @IBOutlet weak var productDetails: UITableView!
    
    // Variables
    var cells: [CellType] = []
    var products: Product?
    var presenter: DetailsPresenterProtocol?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkFavoriteInRealm()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        presenter?.getSingleProduct()
        
        productDetails.register(ProductImageTableViewCell.nib(), forCellReuseIdentifier: ProductImageTableViewCell.identifier)
        productDetails.register(DetailsTableViewCell.nib(), forCellReuseIdentifier: DetailsTableViewCell.identifier)
        productDetails.register(InformationTableViewCell.nib(), forCellReuseIdentifier: InformationTableViewCell.identifier)
        productDetails.delegate = self
        productDetails.dataSource = self
    }
    
    private func setupNavigationBar() {
        setBackButton()
        setRightBarButtonHeart()
        setLogo()
        navigationItem.rightBarButtonItem?.action = #selector(markAsFavorite)
    }
    
    @objc func markAsFavorite() {
        if let products = products {
            presenter?.toggleFavorite(id: products.id)
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
        }
    }
    
    func checkFavoriteInRealm() {
        if let products = products {
            let contains = RealmService.shared.checkRealmElements(products: products)
            if contains {
                navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
            } else {
                navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart")
            }
        }
    }
    
    func getSingleProductSuccess(singleProduct: Product) {
        products = singleProduct
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let products = self.products else { return }
            self.cells = [.imageView(products.main_image, isSkeleton: false), .details(products, isSkeleton: false), .information(products, isSkeleton: false)]
            self.productDetails.reloadData()
        }
    }
}

// MARK: - Extension TableView
extension DetailsView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch cells[indexPath.row] {
        case .imageView(_, let isSkeleton):
            let cell = productDetails.dequeueReusableCell(withIdentifier: ProductImageTableViewCell.identifier, for: indexPath) as! ProductImageTableViewCell
            if isSkeleton {
                cell.productImageView.isSkeletonable = true
                cell.productImageView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .silver), animation: nil, transition: .crossDissolve(0.25))
                
            }
            if let products = products {
                cell.productImageView.stopSkeletonAnimation()
                cell.productImageView.sd_setImage(with: URL(string: products.main_image))
                cell.hideSkeleton()
            }
            return cell
        case .details(_, let isSkeleton):
            let cell = productDetails.dequeueReusableCell(withIdentifier: DetailsTableViewCell.identifier, for: indexPath) as! DetailsTableViewCell
            if isSkeleton {
                cell.presentSkeleton()
            }
            if let products = products {
                cell.configure(with: products)
            }
            
            return cell
        case .information(_, let isSkeleton):
            let cell = productDetails.dequeueReusableCell(withIdentifier: InformationTableViewCell.identifier, for: indexPath) as! InformationTableViewCell
            if isSkeleton {
                cell.presentSkeleton()
            }
            if let products = products {
                cell.configure(with: products)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch cells[indexPath.row] {
        case .imageView:
            return 300
        case .details:
            return UITableView.automaticDimension
        case .information:
            return UITableView.automaticDimension
        }
    }
}
