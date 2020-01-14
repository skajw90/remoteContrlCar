//
//  InitialViewController.swift
//  WIFICommunicationDemo
//
//  Created by Jiwon Nam on 11/15/19.
//  Copyright © 2019 Jiwon Nam. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    var button: UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.frame = CGRect(x: view.center.x - 50, y: view.center.y - 25, width: 100, height: 50)
        button.addTarget(self, action: #selector(btnAction), for: UIControl.Event.touchDown)
        button.setBackgroundImage(UIImage(named:"st"),for: UIControl.State.normal)
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "bg2")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        
        view.addSubview(button)
    }
    
    @objc func btnAction(Sender: Any) {
        print("Action")
        button.removeFromSuperview()
        view.backgroundColor = .black
        let controller = MainViewController()
        present(controller, animated: true, completion: nil)
    }
}
