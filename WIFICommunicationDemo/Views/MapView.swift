//
//  MapView.swift
//  WIFICommunicationDemo
//
//  Created by Jiwon Nam on 11/15/19.
//  Copyright © 2019 Jiwon Nam. All rights reserved.
//

import UIKit

protocol MapViewDelegate {
    func closeMap()
}

class MapView: UIView {
    var delegate: MapViewDelegate?
    
    lazy var wrap: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    } ()
    
    lazy var drawingView: DrawingView = {
        let view = DrawingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    } ()
    
    lazy var closeView: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setBackgroundImage(UIImage(named:"mapclose"),for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(closeMap), for: UIControl.Event.touchDown)
        addSubview(btn)
        return btn
    } ()
    
    @objc func closeMap(sender: Any) {
        print("Close Map")
        delegate!.closeMap()
    }
}
