//
//  MappingController.swift
//  WIFICommunicationDemo
//
//  Created by Jiwon Nam on 11/15/19.
//  Copyright © 2019 Jiwon Nam. All rights reserved.
//

import UIKit

protocol MapListViewControllerDelegate {
    func closeMapListView()
}

class MapListViewController: UIViewController, MapListViewDataSource, MapListViewDelegate, MapViewControllerDelegate {

    var map: [Map] = []
    var mapURLs: [URL] = []
    var delegate: MapListViewControllerDelegate?
    var numOfMaps: Int = 0
    var selectedRow: Int = 0
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        loadMapURLs()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    
    }
    
    func loadMapURLs() {
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            for i in 0 ..< contents.count {
                mapURLs.append(contents[i])
                print(mapURLs[i])
            }
            numOfMaps = contents.count
        } catch {
            print("no files")
        }
    }
    
    func saveNewMap() {
        let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let url = documentsDirectory.appendingPathComponent("mapName\(numOfMaps).json")
        do {
            try map.save(to: url)
            mapURLs.append(url)
        } catch {
            print("encoding error")
        }
    }
    
    func loadSelectedMap() {
        let url = mapURLs[selectedRow]
        do {
            let jsonData = try Data(contentsOf: url)
            let tempMap = try! JSONDecoder().decode([Map].self, from: jsonData)
            map = tempMap
        }
        catch {
            print("no file")
        }
    }
    
    var mapListView: MapListView {
        return view as! MapListView
    }
    
    override func loadView() {
        view = MapListView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = parent!.view.bounds
        NSLayoutConstraint.activate([
            mapListView.titleTextView.topAnchor.constraint(equalTo: view.topAnchor),
            mapListView.titleTextView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            mapListView.titleTextView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            mapListView.titleTextView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2),
            mapListView.tableView.topAnchor.constraint(equalTo: mapListView.titleTextView.bottomAnchor),
            mapListView.tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            mapListView.tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            mapListView.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapListView.labelView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapListView.labelView.widthAnchor.constraint(equalTo: view.widthAnchor),
            mapListView.labelView.heightAnchor.constraint(equalTo: mapListView.titleTextView.heightAnchor),
            mapListView.labelView.widthAnchor.constraint(equalTo: mapListView.titleTextView.widthAnchor, multiplier: 0.1),
            mapListView.closeBtn.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.07),
            mapListView.closeBtn.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            mapListView.closeBtn.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            mapListView.closeBtn.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        mapListView.dataSource = self
        mapListView.delegate = self
        startMapListView()
    }
    
    func startMapListView() {
        mapListView.setNeedsDisplay()
        mapListView.setUpTableView()
    }
    
    func closeMapListView() {
        delegate!.closeMapListView()
    }
    
    func getListNum() -> Int {
        
        return numOfMaps
    }
    
    func showMap(selected: Int) {
        selectedRow = selected
        let controller = MapViewController()
        controller.delegate = self
        add(controller)
    }
    
    func getMap() -> [Map] {
        loadSelectedMap()
        return map
    }
    
    func closeMapView(_ controller: MapViewController) {
        controller.remove()
    }
    
    
    func setDataMap(last: Int, data: Float, flag: Int, newLine: Int) {

        switch flag {
        case 0:
            let input: Map = Map(wheels: Wheels(leftWheelDistance: 0, rightWheelDistance: 0), sensors: Sensors(leftSensor: 0, rightSensor: 0))
            map.append(input)
            map[newLine].wheels.leftWheelDistance = data
        case 1:
            map[newLine].wheels.rightWheelDistance = data
        case 2:
            map[newLine].sensors.leftSensor = data
        case 3:
            map[newLine].sensors.rightSensor = data
        default:
            print("error")
        }
        if last == -1 {
            print(newLine)
            saveNewMap()
            numOfMaps += 1
        }
    }
}
