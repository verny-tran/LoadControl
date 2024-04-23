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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        self.tableView.loadControl = LoadControl()
        self.tableView.loadControl?.addAction({ [weak self] in
            guard let `self` = self else { return }
            Haptic.light()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: { [weak self] in
                guard let `self` = self else { return }
                self.tableView.loadControl?.endLoading()
            })
        })
    }
    
    @objc
    private func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: { [weak self] in
            guard let `self` = self else { return }
            self.tableView.refreshControl?.endRefreshing()
        })
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
