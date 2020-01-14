//
//  MapListView.swift
//  WIFICommunicationDemo
//
//  Created by Jiwon Nam on 12/1/19.
//  Copyright © 2019 Jiwon Nam. All rights reserved.
//

import UIKit

protocol MapListViewDataSource {
    func getListNum() -> Int
}

protocol MapListViewDelegate {
    func closeMapListView()
    func showMap(selected: Int)
}

class MapListView: UIView {
    
    var dataSource: MapListViewDataSource?
    var delegate: MapListViewDelegate?
    var selectedHeaderNum = -1
    
    lazy var titleTextView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    } ()
    
    lazy var labelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "MAP LIST"
        label.textColor = .black
        label.textAlignment = .center
        addSubview(label)
        return label
    } ()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    } ()
    
    lazy var closeBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(named:"mapstop"),for: UIControl.State.normal)
        button.addTarget(self, action: #selector(closeMapList), for: UIControl.Event.touchDown)
        addSubview(button)
        return button
    } ()
    
    @objc func closeMapList(sender: Any) {
        delegate!.closeMapListView()
    }
    
    func setUpTableView() {
        selectedHeaderNum = -1
        //loadingLabel.text = ""
        tableView.register(CellView.self, forCellReuseIdentifier: String(describing: CellView.self))
        tableView.dataSource = self
        //tableView.delegate = self
        addSubview(tableView)
        tableView.reloadData()
    }
}

extension MapListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource!.getListNum()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CellView.self)) as? CellView else {
                   fatalError("Could not dequeue resuable cell of type: \(CellView.self)")
               }
        _ = cell.incrment
        cell.backgroundColor = .white
        let label = cell.textLabel!
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.text = "test \(indexPath.row)"
        label.textColor = .black
        cell.tag = indexPath.row
        // need to send selected row
        if indexPath.row < dataSource!.getListNum() {
            let cellTagGesture = UITapGestureRecognizer()
            cellTagGesture.addTarget(self, action: #selector(rowSelected))
            cell.addGestureRecognizer(cellTagGesture)
        }
        cell.selectionStyle = .none
           
        return cell
    }
    
    @objc func rowSelected(sender: UITapGestureRecognizer) {
        let cell = sender.view as! CellView
        let row = cell.tag
        delegate!.showMap(selected: row)
    }
    
    
}
