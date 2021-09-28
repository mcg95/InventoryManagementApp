//
//  BuyCartViewController.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 27/09/2021.
//

import Combine
import UIKit

protocol BuyCartViewControllerDelegate: NSObjectProtocol {
        
    func buyCartViewControllerDidFinish(_ viewController: BuyCartViewController)
}

class BuyCartViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = BuyCartViewModel()
        configureViews()
        startObserving()
    }
    
    private func startObserving() {
        viewModel.items.sink { products in
            self.totalPriceLabel.text = "RM \(String(products.reduce(0, { $0 + $1.totalPrice })))"
            self.totalQuantityLabel.text = String(products.reduce(0, { $0 + $1.quantity }))

            self.applySnapshot(items: products)
        }.store(in: &cancellables)
        
        searchBar.searchTextField.textPublisher.sink { text in
            self.viewModel.searchText.send(text)
        }.store(in: &cancellables)
        
        submitButton.publisher(for: .touchUpInside).sink { _ in
            self.viewModel.saveOrder()
            toast("Order Created", size: .normal, duration: .short)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6) {
                self.delegate?.buyCartViewControllerDidFinish(self)
            }
        }.store(in: &cancellables)
    }
    
    private func configureViews() {
        
        
        collectionView.collectionViewLayout = generateLayout()
        
        // Collection view cells & supplementary views registration.
        collectionView.register(cellType: BuyCartCell.self)
    }
    
    private func presentDeleteConfirmationAlert(forId: String) {
        let alert = UIAlertController(title: "Confirmation",
                                      message: "Are you sure you want to delete this product?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: .destructive,
                                      handler: { action in
            self.viewModel.deleteCartItem(withId: forId)
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
            heightDimension: .absolute(75))
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
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BuyCartCell.reuseIdentifier, for: indexPath) as? BuyCartCell else {
                        fatalError("Invalid Cell Type")
                    }
                    
                    let item = (item as! BuyCart)
                    print(item)
                    cell.bindViewModel(BuyCartCellViewModel(
                        cart: item
                    ))
                    
                    cell.deleteButtonPublisher.sink(receiveValue: { [weak self] _ in
                        self?.viewModel.deleteCartItem(withId: item.id.uuidString)
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
    
    weak var delegate: BuyCartViewControllerDelegate?
    
    //----------------------------------------
    // MARK:- View Model
    //----------------------------------------
    
    var viewModel: BuyCartViewModel!
    
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
    
    @IBOutlet private var totalQuantityLabel: UILabel!
    
    @IBOutlet private var totalPriceLabel: UILabel!
    
    @IBOutlet private var submitButton: UIButton!
}
