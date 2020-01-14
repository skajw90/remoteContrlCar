//
//  MapViewController.swift
//  WIFICommunicationDemo
//
//  Created by Jiwon Nam on 12/1/19.
//  Copyright © 2019 Jiwon Nam. All rights reserved.
//

import UIKit

protocol MapViewControllerDelegate {
    func getMap() -> [Map]
    func closeMapView(_ controller: MapViewController)
}

class MapViewController: UIViewController, MapViewDelegate, drawingViewDataSource {
    
    var delegate: MapViewControllerDelegate?
    
    var mapView: MapView {
        return view as! MapView
    }
        
    override func loadView() {
        view = MapView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = parent!.view.bounds
        NSLayoutConstraint.activate([
            mapView.wrap.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mapView.wrap.centerYAnchor.constraint(equalTo: mapView.centerYAnchor),
            mapView.wrap.widthAnchor.constraint(equalTo: mapView.widthAnchor),
            mapView.wrap.heightAnchor.constraint(equalTo: mapView.heightAnchor),
            mapView.drawingView.topAnchor.constraint(equalTo: mapView.wrap.topAnchor),
            mapView.drawingView.widthAnchor.constraint(equalTo: mapView.wrap.widthAnchor),
            mapView.drawingView.leftAnchor.constraint(equalTo: mapView.wrap.leftAnchor),
            mapView.drawingView.heightAnchor.constraint(equalTo: mapView.wrap.heightAnchor),
            mapView.closeView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.closeView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            mapView.closeView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.07),
            mapView.closeView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15)
                ])
        mapView.delegate = self
        mapView.drawingView.dataSource = self
    }
    
    func closeMap() {
        delegate!.closeMapView(self)
    }
    
    func getDataForMap() -> [Map] {
        return delegate!.getMap()
    }
}
