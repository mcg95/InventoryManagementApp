//
//  OrderListViewController.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 26/09/2021.
//

import UIKit
import Combine

class OrderListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = OrderListViewModel()
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
            let storyboard = UIStoryboard(name: "OrderDetail", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "OrderDetail") as? OrderDetailViewController {
                vc.delegate = self
                vc.viewModel = OrderDetailViewModel(products: self.viewModel.products, order: nil)
                self.present(vc, animated: true)
            }
        }))
        addItemButton.tintColor = .systemIndigo
        navigationItem.rightBarButtonItem = addItemButton

        collectionView.collectionViewLayout = generateLayout()
        
        // Collection view cells & supplementary views registration.
        collectionView.register(cellType: OrderCell.self)
    }
    
    private func presentDeleteConfirmationAlert(forId: String) {
        let alert = UIAlertController(title: "Confirmation",
                                      message: "Are you sure you want to delete this order?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: .destructive,
                                      handler: { action in
            self.viewModel.deleteOrder(withId: forId)
        }))
        
        alert.addAction(UIAlertAction(title: "No",
                                      style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func presentEditDialog(forOrder order: Order) {
        let alert = UIAlertController(title: "Update Order",
                                      message: nil,
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.text = String(order.price)
        }
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.text = String(order.quantity)
        }
        
        alert.addAction(UIAlertAction(title: "Update",
                                      style: .default,
                                      handler: { action in
            var updatedOrder = order
            updatedOrder.price = Double(alert.textFields?.first?.text ?? "0") ?? 0
            updatedOrder.quantity = Int64(alert.textFields?[1].text ?? "0") ?? 0
            self.viewModel.updateOrder(order: updatedOrder)
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
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderCell.reuseIdentifier, for: indexPath) as? OrderCell else {
                        fatalError("Invalid Cell Type")
                    }
                    
                    let item = (item as! Order)

                    cell.bindViewModel(OrderCellViewModel(
                        order: item
                    ))
                    
                    cell.editButtonPublisher.sink(receiveValue: { [weak self] _ in
                        guard let self = self else { return }
                        
                        let storyboard = UIStoryboard(name: "OrderDetail", bundle: nil)
                        if let vc = storyboard.instantiateViewController(withIdentifier: "OrderDetail") as? OrderDetailViewController {
                            vc.delegate = self
                            vc.viewModel = OrderDetailViewModel(products: self.viewModel.products, order: item)
                            self.present(vc, animated: true)
                        }
                    }).store(in: &(cell.cancellables))
                    
                    cell.deleteButtonPublisher.sink(receiveValue: { [weak self] _ in
                        self?.presentDeleteConfirmationAlert(forId: item.id.uuidString)
                    }).store(in: &(cell.cancellables))
                    
                    return cell
                }
            })
        
        return dataSource
    }

    private lazy var dataSource = createDataSource()
    
    //----------------------------------------
    // MARK:- View Model
    //----------------------------------------
    
    var viewModel: OrderListViewModel!

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

extension OrderListViewController: OrderDetailViewControllerDelegate {
    func orderDetailViewControllerDidSubmit(_ viewController: OrderDetailViewController, order: Order?) {
        guard let order = order else { return }
        
        self.viewModel.saveOrder(order: order)
    }
}
