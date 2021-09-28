//
//  EmployeeListViewController.swift
//  InventoryManagementApp
//
//  Created by Mewan - SnappyMob on 27/09/2021.
//

import Foundation
import UIKit
import Combine

protocol EmployeeListViewControllerDelegate: NSObjectProtocol {
        
    func employeeListViewControllerDidFinish(_ viewController: EmployeeListViewController)
}

class EmployeeListViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = EmployeeListViewModel()
        configureViews()
        startObserving()
    }
    
    private func startObserving() {
        viewModel.items.sink { employees in
            self.applySnapshot(items: employees)
        }.store(in: &cancellables)
        
        searchBar.searchTextField.textPublisher.sink { text in
            self.viewModel.searchText.send(text)
        }.store(in: &cancellables)
    }
    
    private func configureViews() {
        let addItemButton = UIBarButtonItem(systemItem: .add, primaryAction: UIAction(handler: { action in
            let addProductAlert = UIAlertController(title: "Add Employee",
                                                    message: "Leave password field empty for default password 12345678",
                                                    preferredStyle: .alert)
            addProductAlert.addTextField { textField in
                textField.placeholder = "Employee Name"
            }
            addProductAlert.addTextField { textField in
                textField.placeholder = "Employee Username"
            }
            addProductAlert.addTextField { textField in
                textField.placeholder = "Employee Password"
                textField.isSecureTextEntry = true
            }
            
            addProductAlert.addAction(UIAlertAction(title: "Add as Admin", style: .default, handler: { alertAction in
                guard let name = addProductAlert.textFields?.first?.text,
                      let username = addProductAlert.textFields?[1].text else { return }
                
                let password = addProductAlert.textFields?[2].text ?? "12345678"
                self.viewModel.saveEmployee(name: name, username: username, password: password, role: .admin)
            }))
            
            addProductAlert.addAction(UIAlertAction(title: "Add as Employee", style: .default, handler: { alertAction in
                guard let name = addProductAlert.textFields?.first?.text,
                      let username = addProductAlert.textFields?[1].text else { return }
                
                let password = addProductAlert.textFields?[2].text ?? "12345678"
                self.viewModel.saveEmployee(name: name, username: username, password: password, role: .employee)
            }))
            
            self.present(addProductAlert, animated: true)
        }))
        addItemButton.tintColor = .systemIndigo
        navigationItem.rightBarButtonItem = addItemButton

        collectionView.collectionViewLayout = generateLayout()
        
        // Collection view cells & supplementary views registration.
        collectionView.register(cellType: EmployeeCell.self)
    }
    
    private func presentDeleteConfirmationAlert(forId: String) {
        let alert = UIAlertController(title: "Confirmation",
                                      message: "Are you sure you want to delete this product?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: .destructive,
                                      handler: { action in
            self.viewModel.deleteEmployee(withId: forId)
        }))
        
        alert.addAction(UIAlertAction(title: "No",
                                      style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func presentEditDialog(forEmployee employee: Employee) {
        let alert = UIAlertController(title: "Update Product",
                                      message: nil,
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = employee.name
        }
        alert.addTextField { textField in
            textField.text = String(employee.password)
        }
        
        alert.addAction(UIAlertAction(title: "Update",
                                      style: .default,
                                      handler: { action in
            var updatedEmployee = employee
            updatedEmployee.name = alert.textFields?.first?.text ?? ""
            updatedEmployee.password = alert.textFields?[1].text ?? ""
            self.viewModel.updateEmployee(employee: updatedEmployee)
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
                        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmployeeCell.reuseIdentifier, for: indexPath) as? EmployeeCell else {
                            fatalError("Invalid Cell Type")
                        }
                        
                        let item = (item as! Employee)
                        print(item)
                        cell.bindViewModel(EmployeeCellViewModel(
                            employee: item
                        ))
                        
                        cell.editButtonPublisher.sink(receiveValue: { [weak self] _ in
                            self?.presentEditDialog(forEmployee: item)
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
    // MARK:- Delegate
    //----------------------------------------
    
    weak var delegate: EmployeeListViewControllerDelegate?
    
    //----------------------------------------
    // MARK:- View Model
    //----------------------------------------
    
    var viewModel: EmployeeListViewModel!

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
