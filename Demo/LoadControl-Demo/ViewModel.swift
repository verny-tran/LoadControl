//
//  ViewModel.swift
//  LoadControl-Demo
//
//  Created by Trần T. Dũng on 24/4/24.
//

import Foundation

final class ViewModel {
    private let api: String = "https://jsonplaceholder.typicode.com/posts?userId=%d"
    private var page: Int = 1
    
    private(set) var isEnded: Bool = false
    private(set) var models = [Model]()
    
    func fetch(completion: @escaping () -> Void) {
        self.models = []
        
        self.page = 1
        self.isEnded = false
        
        self.load(completion: { [weak self] in
            guard let `self` = self else { return }
            self.load(completion: { completion() })
        })
    }
    
    func load(completion: @escaping () -> Void) {
        guard !self.isEnded else { completion(); return }
        let path = String(format: self.api, self.page)
        
        guard let url = URL(string: path) else { return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let `self` = self, let data = data else { return }
            
            guard let decoded = try? JSONDecoder().decode(Array<Model>.self, from: data) else { return }
            self.models.append(contentsOf: decoded)
            
            self.page += 1
            self.isEnded = self.page > 10
            
            completion()
        }
        
        task.resume()
    }
}
