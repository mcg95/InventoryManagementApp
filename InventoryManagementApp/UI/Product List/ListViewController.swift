//
//  ListViewController.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 26/09/2021.
//

import UIKit
import Combine

enum ListType {
    case product
    case order
    case customer
}

protocol ListViewControllerDelegate: NSObjectProtocol {
    
    func listViewControllerDidFinish(_ viewController: ListViewController)
}

class ListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let addItemButton = UIBarButtonItem(systemItem: .add, primaryAction: UIAction(handler: { action in
            switch self.viewModel.listType {
            case .product:
                let addProductAlert = UIAlertController(title: "Add Product", message: nil, preferredStyle: .alert)
                addProductAlert.addTextField { textField in
                    textField.placeholder = "Product Name"
                }
                addProductAlert.addTextField { textField in
                    textField.keyboardType = .numberPad
                    textField.placeholder = "Product Price"
                }
                addProductAlert.addAction(UIAlertAction(title: "Add", style: .default, handler: { alertAction in
                    guard let name = addProductAlert.textFields?.first?.text,
                          let price = addProductAlert.textFields?[1].text,
                          let priceDouble = Double(price) else { return }
                    
                    self.viewModel.saveProduct(name: name, price: priceDouble)
                }))
                
                self.present(addProductAlert, animated: true)
                
            default: break
            }
        }))
        addItemButton.tintColor = .systemIndigo
        navigationItem.rightBarButtonItem = addItemButton

        collectionView.collectionViewLayout = generateLayout()

        // Collection view cells & supplementary views registration.
        collectionView.register(cellType: ProductCell.self)
    }
    
    private func presentDeleteConfirmationAlert(forId: String) {
        let alert = UIAlertController(title: "Confirmation",
                                      message: "Are you sure you want to delete this product?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: .destructive,
                                      handler: { action in
            self.viewModel.deleteProduct(withId: forId)
        }))
        
        alert.addAction(UIAlertAction(title: "No",
                                      style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func presentEditDialog(forProduct product: Product) {
        let alert = UIAlertController(title: "Update Product",
                                      message: nil,
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = product.name
        }
        alert.addTextField { textField in
            textField.text = String(product.price)
        }
        
        alert.addAction(UIAlertAction(title: "Update",
                                      style: .default,
                                      handler: { action in
            var updatedProduct = product
            updatedProduct.name = alert.textFields?.first?.text ?? ""
            updatedProduct.price = Double(alert.textFields?[1].text ?? "0") ?? 0
            self.viewModel.updateProduct(product: updatedProduct)
        }))
        
        alert.addAction(UIAlertAction(title: "No",
                                      style: .cancel))
        
        present(alert, animated: true)
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
            heightDimension: .absolute(90))
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
                    switch self.viewModel.listType {
                    case .product:
                        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.reuseIdentifier, for: indexPath) as? ProductCell else {
                            fatalError("Invalid Cell Type")
                        }
                        
                        let item = (item as! Product)
                        print(item)
                        cell.bindViewModel(ProductCellViewModel(
                            product: item
                        ))
                        
                        cell.editButtonPublisher.sink(receiveValue: { [weak self] _ in
                            self?.presentEditDialog(forProduct: item)
                        }).store(in: &(cell.cancellables))
                        
                        cell.deleteButtonPublisher.sink(receiveValue: { [weak self] _ in
                            self?.presentDeleteConfirmationAlert(forId: item.id.uuidString)
                        }).store(in: &(cell.cancellables))

                        return cell
                        
                    default:
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//                        let item = (item as! Product)
                        
//                        cell?.bindViewModel(CourseCollectionViewCourseCellViewModel(
//                            formatterService: self.viewModel.formatterService,
//                            course: item
//                        ))
                        
                        return cell
                        
                    }
                }
            })
        
        return dataSource
    }

    private lazy var dataSource = createDataSource()
    
    //----------------------------------------
    // MARK:- Delegate
    //----------------------------------------
    
    weak var delegate: ListViewControllerDelegate?
    
    //----------------------------------------
    // MARK:- View Model
    //----------------------------------------
    
    var viewModel: ListViewModel!

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
