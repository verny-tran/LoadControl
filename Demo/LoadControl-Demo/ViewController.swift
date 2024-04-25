//
//  ViewController.swift
//  LoadControl-Demo
//
//  Created by Trần T. Dũng on 23/4/24.
//

import UIKit
import LoadControlKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        self.tableView.loadControl = LoadControl()
        self.tableView.loadControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refresh()
    }
    
    @objc
    private func refresh() {
        self.tableView.refreshControl?.beginRefreshing()
        
        self.viewModel.fetch(completion: { [weak self] in
            guard let `self` = self else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        })
    }
    
    @objc
    private func load() {
        self.viewModel.load(completion: { [weak self] in
            guard let `self` = self else { return }
            self.tableView.loadControl?.isHapticEnabled = self.viewModel.isEnded
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.loadControl?.endLoading()
            }
        })
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.viewModel.models[safe: indexPath.row]?.title?.capitalized
        
        return cell
    }
}
