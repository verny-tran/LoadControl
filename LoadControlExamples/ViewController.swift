//
//  ViewController.swift
//  LoadControlExamples
//
//  Created by Trần T. Dũng on 21/4/24.
//

import UIKit
import LoadControl

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.loadControl = LoadControl()
        self.tableView.loadControl?.addAction({ [weak self] in
            guard let `self` = self else { return }
            Haptic.light()
        })
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
