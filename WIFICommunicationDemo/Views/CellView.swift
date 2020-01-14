//
//  CellView.swift
//  WIFICommunicationDemo
//
//  Created by Jiwon Nam on 12/1/19.
//  Copyright © 2019 Jiwon Nam. All rights reserved.
//

import UIKit

class CellView: UITableViewCell {
    
    var clicked: Bool = false
    static let lock = NSLock()
    static var count = 0
    
    let incrment: Void = {
        CellView.lock.lock()
        defer { CellView.lock.unlock() }
        CellView.count += 1
    }()
    
    deinit {
        CellView.lock.lock()
        defer { CellView.lock.unlock() }
        CellView.count -= 1
    }
    
}
