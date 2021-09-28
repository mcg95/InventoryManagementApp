//
//  StoreListViewController.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 27/09/2021.
//

import Foundation

import UIKit
import CoreData
import Combine

protocol StoreListViewControllerDelegate: NSObjectProtocol {
        
    func storeListViewControllerDidFinish(_ viewController: StoreListViewController)
    
    func storeListViewControllerPresentCart(_ viewController: StoreListViewController)
}

class StoreListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = StoreListViewModel()
        configureViews()
        startObserving()
    }
    
    private func startObserving() {
        viewModel.items.sink { products in
            self.applySnapshot(items: products)
        }.store(in: &cancellables)
        
        searchBar.searchTextField.textPublisher.sink { text in
            self.viewModel.searchText.send(text)
        }.store(in: &cancellables)
    }
    
    private func configureViews() {
        let addItemButton = UIBarButtonItem(image: UIImage(systemName: "cart"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(buyCartButtonDidTap))
        
        let logoutItemButton = UIBarButtonItem(title: "Logout",
                                            style: .plain,
                                            target: self,
                                            action: #selector(logOutButtonDidTap))
        
        addItemButton.tintColor = .systemIndigo
        navigationItem.rightBarButtonItem = addItemButton
        navigationItem.leftBarButtonItem = logoutItemButton

        collectionView.collectionViewLayout = generateLayout()
        
        // Collection view cells & supplementary views registration.
        collectionView.register(cellType: StoreListCell.self)
    }
    
    private func presentDeleteConfirmationAlert(forId: String) {
        let alert = UIAlertController(title: "Confirmation",
                                      message: "Are you sure you want to delete this product?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: .destructive,
                                      handler: { action in
            self.viewModel.deleteCart(withId: forId)
        }))
        
        alert.addAction(UIAlertAction(title: "No",
                                      style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func presentEditDialog(forCustomer product: Product) {
        let alert = UIAlertController(title: "Update Product",
                                      message: nil,
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = product.name
        }
        alert.addTextField { textField in
            textField.text = product.name
        }
        
        alert.addAction(UIAlertAction(title: "Update",
                                      style: .default,
                                      handler: { action in
            var updatedProduct = product
            updatedProduct.name = alert.textFields?.first?.text ?? ""
            self.viewModel.updateCart(product: updatedProduct)
        }))
        
        alert.addAction(UIAlertAction(title: "No",
                                      style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc func buyCartButtonDidTap(_ sender: UIBarButtonItem) {
        delegate?.storeListViewControllerPresentCart(self)
    }
    
    @objc func logOutButtonDidTap(_ sender: UIBarButtonItem) {
        delegate?.storeListViewControllerDidFinish(self)
    }
    
    //----------------------------------------
    // MARK:- UICollection view layout
    //----------------------------------------
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
                                                            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let sectionLayoutKind = Section.allCases[sectionIndex]
            switch sectionLayoutKind {
            case .main: return self.generateCoursesLayout()
            }
        }
        return layout
    }
    
    func generateCoursesLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
        
        let section = NSCollectionLayoutSection(group: group)
        
        
        return section
    }
    
    //----------------------------------------
    // MARK:- UI collection view data source
    //----------------------------------------
    
    private func applySnapshot(items: [AnyHashable], animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences) {
            self.collectionView.reloadData()
        }
    }
    
    private func createDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
                guard let section = Section(rawValue: indexPath.section) else { fatalError("unknown section") }
                switch section {
                case .main:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoreListCell.reuseIdentifier, for: indexPath) as? StoreListCell else {
                        fatalError("Invalid Cell Type")
                    }
                    
                    let item = (item as! Product)
                    print(item)
                    cell.bindViewModel(StoreListCellViewModel(
                        product: item
                    ))
                    
                    cell.addToCartButtonPublisher.sink(receiveValue: { [weak self] _ in
                        guard let quantity = Int64(cell.quantityTextPublisher.value) else { return }
                        
                        self?.viewModel.saveToCart(productId: item.id.uuidString,
                                                   name: item.name,
                                                   price: item.price,
                                                   quantity: quantity)
                        toast("Item added to cart", size: .normal, duration: .short)
                    }).store(in: &(cell.cancellables))
                    
                    return cell
                }
            })
        
        return dataSource
    }
    
    private lazy var dataSource = createDataSource()
    
    //----------------------------------------
    // MARK:- Delegate
    //----------------------------------------
    
    weak var delegate: StoreListViewControllerDelegate?
    
    //----------------------------------------
    // MARK:- View Model
    //----------------------------------------
    
    var viewModel: StoreListViewModel!
    
    //----------------------------------------
    // MARK:- Section
    //----------------------------------------
    
    enum Section: Int, Hashable, CaseIterable {
        case main
    }
    
    //----------------------------------------
    // MARK:- Type Aliases
    //----------------------------------------
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
    //----------------------------------------
    // MARK:- Internals
    //----------------------------------------
    
    private var cancellables = Set<AnyCancellable>()
    
    //----------------------------------------
    // MARK:- Outlets
    //----------------------------------------
    
    @IBOutlet private var searchBar: UISearchBar!
    
    @IBOutlet private var collectionView: UICollectionView!
}
