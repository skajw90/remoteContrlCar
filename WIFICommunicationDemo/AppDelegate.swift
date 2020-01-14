//
//  AppDelegate.swift
//  WIFICommunicationDemo
//
//  Created by Jiwon Nam on 4/4/19.
//  Copyright © 2019 Jiwon Nam. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.rootViewController = InitialViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

