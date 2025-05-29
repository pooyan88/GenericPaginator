//
//  ViewController.swift
//  PaginationTraining
//
//  Created by Pooyan J on 5/29/25.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        setupViews()
        bindState()
    }
    
    private var viewModel: ViewModel?
    private var cancellables: Set<AnyCancellable> = []
}

// MARK: - Setup Binding
extension ViewController {
    
    private func bindState() {
        viewModel?.$pageState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                guard let self, let state = state else { return }
                switch state {
                case .completed:
                    activityIndicator.stopAnimating()
                    tableView.reloadData()
                case .loading:
                    activityIndicator.startAnimating()
                case .error:
                    activityIndicator.stopAnimating()
                    tableView.isHidden = true
                }
            }).store(in: &cancellables)
    }
}

// MARK: - Setup Functions
private extension ViewController {
    
    func setupViewModel() {
        viewModel = ViewModel()
    }
    
    func setupViews() {
        setupTableView()
    }
    
    func setupTableView() {
        tableView.register(TableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - TableView Functions
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier, for: indexPath) as! TableViewCell
        let item = viewModel?.items[indexPath.row]
        let config = TableViewCell.Config(name: item?.name ?? "", url: item?.url ?? "")
        cell.setup(with: config)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        TableViewCell.getHeight()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
          guard let viewModel = viewModel else { return }
        if indexPath.row == viewModel.items.count - 1 && viewModel.hasMoreData {
            print("INDEX PATH ROW ==>", indexPath.row)
            print("ITEMS COUNT ===>", viewModel.items.count - 1)
              viewModel.getData(start: viewModel.start, size: viewModel.size)
          }
      }
}
