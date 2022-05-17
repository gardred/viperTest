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
  var products: Products! { get set }
  var id: Int! { get set }
  
  func getSingleProductSuccess(singleProduct: Products)
}
// MARK: Class
class DetailsView: BaseViewController, DetailsViewProtocol {
  var id: Int!
  var products: Products!
  var presenter: DetailsPresenterProtocol?
  let realm = try? Realm()
  var favoriteList: Results<FavoriteList>!
  var cell: ProductsTableViewCell?
  // UIElements
  @IBOutlet weak var productDetails: UITableView!
  var cells: [CellType] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    presenter?.getSingleProduct()
    
    favoriteList = self.realm?.objects(FavoriteList.self)
    
    let contains = realm?.objects(FavoriteList.self).contains { favoriteObject in
      if favoriteObject.id == presenter?.id {
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
        navigationItem.rightBarButtonItem?.action = #selector(removed)
      }
      return false
    }
    
    productDetails.register(ProductImageTableViewCell.nib(), forCellReuseIdentifier: ProductImageTableViewCell.identifier)
    productDetails.register(DetailsTableViewCell.nib(), forCellReuseIdentifier: DetailsTableViewCell.identifier)
    productDetails.register(InformationTableViewCell.nib(), forCellReuseIdentifier: InformationTableViewCell.identifier)
    productDetails.delegate = self
    productDetails.dataSource = self
  }
  
  func setupNavigationBar() {
    setBackButton()
    setRightBarButtonHeart()
    setLogo()
    navigationItem.rightBarButtonItem?.action = #selector(added)
  }
  @objc func added() {
    navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
    RealmService.shared.addProduct(name: products.name, icon: products.main_image, details: products.details, price: products.price, id: products.id)
  }
  
  @objc func removed() {
    navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart")
    let contains = realm?.objects(FavoriteList.self).contains { favoriteObject in
      if favoriteObject.id == presenter?.id {
        RealmService.shared.removeProduct(productToDelete: favoriteObject)
      }
      return false
    }
  }
  
  func getSingleProductSuccess(singleProduct: Products) {
    products = singleProduct
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.cells = [.imageView(self.products.main_image), .details(self.products), .information(self.products)]
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
    case .imageView:
      let cell = productDetails.dequeueReusableCell(withIdentifier: ProductImageTableViewCell.identifier, for: indexPath) as! ProductImageTableViewCell
      cell.productImageView.sd_setImage(with: URL(string: products.main_image))
      cell.productImageView.hideSkeleton()
      cell.productImageView.stopSkeletonAnimation()
      cell.selectionStyle = .none
      return cell
    case .details:
      let cell = productDetails.dequeueReusableCell(withIdentifier: DetailsTableViewCell.identifier, for: indexPath) as! DetailsTableViewCell
      cell.configure(with: products)
      cell.selectionStyle = .none
      return cell
    case .information:
      let cell = productDetails.dequeueReusableCell(withIdentifier: InformationTableViewCell.identifier, for: indexPath) as! InformationTableViewCell
      cell.configure(with: products)
      
      cell.selectionStyle = .none
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
