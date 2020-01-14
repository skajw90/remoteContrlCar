//
//  ViewController.swift
//  WIFICommunicationDemo
//
//  Created by Jiwon Nam on 4/4/19.
//  Copyright © 2019 Jiwon Nam. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import WebKit
import CocoaMQTT

class MainViewController: UIViewController, DemoViewDataSource, DemoViewDelegate, WKNavigationDelegate, CocoaMQTTDelegate, MapListViewControllerDelegate {
   
    var mapListViewController = MapListViewController()
    // need to set right ip address depending on host
    let videoURL = URL(string: "http://\(Constants.ip):\(Constants.videoPort)")
    var mqttClient = CocoaMQTT(clientID: "iOS Device", host: Constants.ip, port: Constants.wifiPort)
    var car: Car = Car()
    var timer = Timer()
    var webView: WKWebView!
    var count = 0
    var isLeft = false
    var isRight = false
    var speed = 0
    var dispatch = DispatchGroup()
    
    var demoView: MainView {
        return view as! MainView
    }
    
    override func loadView() {
        view = MainView()
        startStreaming()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        demoView.frame = view.frame
        NSLayoutConstraint.activate([
            demoView.menuButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            demoView.menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            demoView.menuButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1 / 10),
            demoView.menuButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 1 / 5),
            
            demoView.leftView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            demoView.leftView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1 / 3),
            demoView.leftView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            demoView.leftView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1 / 3),
            
            demoView.leftArrowView.leftAnchor.constraint(equalTo: demoView.leftView.leftAnchor),
            demoView.leftArrowView.widthAnchor.constraint(equalTo: demoView.leftView.widthAnchor, multiplier: 0.5),
            demoView.leftArrowView.centerYAnchor.constraint(equalTo: demoView.leftView.centerYAnchor),
            demoView.leftArrowView.heightAnchor.constraint(equalTo: demoView.leftView.widthAnchor, multiplier: 0.5),
            
            demoView.rightArrowView.rightAnchor.constraint(equalTo: demoView.leftView.rightAnchor),
            demoView.rightArrowView.widthAnchor.constraint(equalTo: demoView.leftView.widthAnchor, multiplier: 0.5),
            demoView.rightArrowView.centerYAnchor.constraint(equalTo: demoView.leftView.centerYAnchor),
            demoView.rightArrowView.heightAnchor.constraint(equalTo: demoView.leftView.widthAnchor, multiplier: 0.5),
            
            demoView.speedLabelFrameView.leftAnchor.constraint(equalTo: demoView.leftView.rightAnchor),
            demoView.speedLabelFrameView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            demoView.speedLabelFrameView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            demoView.speedLabelFrameView.widthAnchor.constraint(equalTo: demoView.leftView.widthAnchor),
            
            demoView.gearFrameView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            demoView.gearFrameView.leftAnchor.constraint(equalTo: demoView.speedLabelFrameView.rightAnchor),
            demoView.gearFrameView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1 / 3),
            demoView.gearFrameView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1 / 3),
            
            demoView.reverseSwitch.topAnchor.constraint(equalTo: demoView.gearFrameView.topAnchor),
            demoView.reverseSwitch.centerXAnchor.constraint(equalTo: demoView.gearFrameView.centerXAnchor),
            demoView.reverseSwitch.widthAnchor.constraint(equalTo: demoView.gearFrameView.widthAnchor, multiplier: 0.2),
            demoView.reverseSwitch.heightAnchor.constraint(equalTo: demoView.gearFrameView.heightAnchor, multiplier: 0.4),
            
            demoView.accelView.topAnchor.constraint(equalTo: demoView.reverseSwitch.bottomAnchor),
            demoView.accelView.rightAnchor.constraint(equalTo: demoView.gearFrameView.rightAnchor),
            demoView.accelView.bottomAnchor.constraint(equalTo: demoView.gearFrameView.bottomAnchor),
            demoView.accelView.widthAnchor.constraint(equalTo: demoView.gearFrameView.widthAnchor, multiplier: 0.4),
            
            demoView.brakeView.topAnchor.constraint(equalTo: demoView.reverseSwitch.bottomAnchor),
            demoView.brakeView.leftAnchor.constraint(equalTo: demoView.gearFrameView.leftAnchor),
            demoView.brakeView.bottomAnchor.constraint(equalTo: demoView.gearFrameView.bottomAnchor),
            demoView.brakeView.widthAnchor.constraint(equalTo: demoView.gearFrameView.widthAnchor, multiplier: 0.4),
            
            demoView.speedLabel.leftAnchor.constraint(equalTo: demoView.speedLabelFrameView.leftAnchor),
            demoView.speedLabel.rightAnchor.constraint(equalTo: demoView.speedLabelFrameView.rightAnchor),
            demoView.speedLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            demoView.speedLabel.heightAnchor.constraint(equalTo: demoView.leftArrowView.heightAnchor),
            
            demoView.gearLabel.leftAnchor.constraint(equalTo: demoView.speedLabelFrameView.leftAnchor),
            demoView.gearLabel.rightAnchor.constraint(equalTo: demoView.speedLabelFrameView.rightAnchor),
            demoView.gearLabel.topAnchor.constraint(equalTo: demoView.speedLabelFrameView.topAnchor),
            demoView.gearLabel.bottomAnchor.constraint(equalTo: demoView.speedLabel.topAnchor),
            
            demoView.leftMotorView.leftAnchor.constraint(equalTo: demoView.speedLabel.leftAnchor),
            demoView.leftMotorView.topAnchor.constraint(equalTo: demoView.speedLabel.bottomAnchor),
            demoView.leftMotorView.widthAnchor.constraint(equalTo: demoView.speedLabel.widthAnchor, multiplier: 0.5),
            demoView.leftMotorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            demoView.rightMotorView.rightAnchor.constraint(equalTo: demoView.speedLabel.rightAnchor),
            demoView.rightMotorView.topAnchor.constraint(equalTo: demoView.speedLabel.bottomAnchor),
            demoView.rightMotorView.widthAnchor.constraint(equalTo: demoView.speedLabel.widthAnchor, multiplier: 0.5),
            demoView.rightMotorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            demoView.startStopMappingButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            demoView.startStopMappingButton.topAnchor.constraint(equalTo: view.topAnchor),
            demoView.startStopMappingButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            demoView.startStopMappingButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.07)
            ])
        
        demoView.datasource = self
        demoView.delegate = self
        mqttClient.delegate = self
    }
    
    func startStreaming() {
        let request = URLRequest(url: videoURL!)
        if mqttClient.connect() {
            print("connected")
        }
        else {
            print("wifi not connected")
        }
        // wait until connection is done
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            print("server start")
            self.webView = WKWebView(frame: self.view.frame)
            self.webView.navigationDelegate = self
            self.webView.scrollView.isScrollEnabled = false
            self.webView.scrollView.bounces = false
            self.webView.load(request)
            self.view.addSubview(self.webView)
            self.view.sendSubviewToBack(self.webView)
            self.mqttClient.subscribe("mapData", qos: CocoaMQTTQOS(rawValue: 0)!)
            self.mqttClient.publish("motorLeftForward", withString: "0")
            self.mqttClient.publish("motorRightForward", withString: "0")
            self.mqttClient.publish("motorLeftReverse", withString: "0")
            self.mqttClient.publish("motorRightReverse", withString: "0")
            self.mqttClient.publish("motorLeftForward", withString: "0")
            self.mqttClient.publish("motorRightForward", withString: "0")
        }
    }
    
    func startStopMapping(isStart: Bool) {
        if isStart {
            mqttClient.publish("mapStatus", withString: "stop")
            print("stop mapping")
        }
        else {
            mqttClient.publish("mapStatus", withString: "start")
            print("start mapping")
        }
    }
    
    func openMapList() {
        // disable all buttons
        mapListViewController = MapListViewController()
        demoView.isTouchable = false
        mapListViewController.delegate = self
        add(mapListViewController)
    }
    
    func closeMapListView() {
        mapListViewController.remove()
        demoView.isTouchable = true
    }
    
    func setLeftAccel(isLeft: Bool) { self.isLeft = isLeft }
    func setLeftBrake(isLeft: Bool) { self.isLeft = isLeft }
    func setRightAccel(isRight: Bool) { self.isRight = isRight }
    func setRightBrake(isRight: Bool) { self.isRight = isRight }
    
    // set left function
    func setLeft(isLeft: Bool) {
        self.isLeft = isLeft
        turnLeft(isLeft: isLeft)
    }
    
    // set right function
    func setRight(isRight: Bool) {
        self.isRight = isRight
        turnRight(isRight: isRight)
    }
    
    // set accelerating function
    func setAccel(isAccel: Bool) {
        
        if isAccel {
            if isLeft || isRight {
                timer.invalidate()
            }
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(accelerating), userInfo: nil, repeats: true)
        }
        else {
            car.aimingSpeed = speed
            car.leftWheelSpeed = speed
            car.rightWheelSpeed = speed
            timer.invalidate()
            setMotorSpeedLabel()
            updateToServer()
            if isLeft {
                turnLeft(isLeft: isLeft)
            }
            if isRight {
                turnRight(isRight: isRight)
            }
            print(car.aimingSpeed)
        }
    }
    
    // setbrake function
    func setBrake(isBrake: Bool) {
        if isBrake {
            if isLeft || isRight {
                timer.invalidate()
            }
            timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(deccelerating), userInfo: nil, repeats: true)
        }
        else {
            car.aimingSpeed = speed
            car.leftWheelSpeed = speed
            car.rightWheelSpeed = speed
            timer.invalidate()
            setMotorSpeedLabel()
            updateToServer()
            if isLeft {
                turnLeft(isLeft: isLeft)
            }
            if isRight {
                turnRight(isRight: isRight)
            }
        }
    }
    
    // set reverse function
    func setReverse(isReverse: Bool) {
        if car.aimingSpeed != 0 {
            return
        }
        car.isReverse = isReverse
        updateToServer()
    }
    
    // get speed function
    func getSpeed() -> Int {
        return car.aimingSpeed
    }
    
    // accelerating handler
    @objc func accelerating() {
        if speed < 100 { speed += 1; count += 1 }
        if car.aimingSpeed == 100 {
            if count % 10 == 0 {
                if isLeft {
                    if car.leftWheelSpeed == car.aimingSpeed / 2 {
                        return
                    }
                    // decrease left wheel accel rate speed
                    car.leftWheelSpeed = car.aimingSpeed / 2
                    car.rightWheelSpeed = car.aimingSpeed
                }
                else if isRight {
                    if car.rightWheelSpeed == car.aimingSpeed / 2 {
                        return
                    }
                    car.rightWheelSpeed = car.aimingSpeed / 2
                    car.leftWheelSpeed = car.aimingSpeed
                }
                else {
                    car.leftWheelSpeed = car.aimingSpeed
                    car.rightWheelSpeed = car.aimingSpeed
                }
                setMotorSpeedLabel()
                updateToServer()
            }
            return
        }
        demoView.speedLabel.text = "\(speed) rpm"
        if car.aimingSpeed % 10 != 0 {
            if count % 10 == 0 {
                if speed <= 100 {
                    car.aimingSpeed += 10 - car.aimingSpeed % 10
                }
                if isLeft {
                    if car.leftWheelSpeed == car.aimingSpeed / 2 {
                        return
                    }
                    // decrease left wheel accel rate speed
                    car.leftWheelSpeed = car.aimingSpeed / 2
                    car.rightWheelSpeed = car.aimingSpeed
                }
                else if isRight {
                    if car.rightWheelSpeed == car.aimingSpeed / 2 {
                        return
                    }
                    car.rightWheelSpeed = car.aimingSpeed / 2
                    car.leftWheelSpeed = car.aimingSpeed
                }
                else {
                    car.leftWheelSpeed = car.aimingSpeed
                    car.rightWheelSpeed = car.aimingSpeed
                }
                setMotorSpeedLabel()
                updateToServer()
            }
        }
        else if count % 10 == 0 {
            if speed <= 100 {
                car.aimingSpeed += 10
            }
            if isLeft {
                if car.leftWheelSpeed == car.aimingSpeed / 2 {
                    return
                }
                // decrease left wheel accel rate speed
                car.leftWheelSpeed = car.aimingSpeed / 2
                car.rightWheelSpeed = car.aimingSpeed
            }
            else if isRight {
                if car.rightWheelSpeed == car.aimingSpeed / 2 {
                    return
                }
                // decrease right wheel accel rate speed
                car.rightWheelSpeed = car.aimingSpeed / 2
                car.leftWheelSpeed = car.aimingSpeed
            }
            else {
                car.leftWheelSpeed = car.aimingSpeed
                car.rightWheelSpeed = car.aimingSpeed
            }
            setMotorSpeedLabel()
            updateToServer()
        }
    }
    
    // deccelerating handler
    @objc func deccelerating() {
        if speed > 0 { speed -= 1; count += 1 }
        demoView.speedLabel.text = "\(speed) rpm"
        if speed == 0 {
            if car.aimingSpeed == 0 {
                return
            }
            else {
                car.aimingSpeed = 0
                car.leftWheelSpeed = car.aimingSpeed
                car.rightWheelSpeed = car.aimingSpeed
                setMotorSpeedLabel()
                updateToServer()
                return
            }
        }
        if car.aimingSpeed % 10 != 0 {
            if count % 10 == 0 {
                if speed >= 0 {
                    car.aimingSpeed -= car.aimingSpeed % 10
                }
                if isLeft {
                    if car.leftWheelSpeed == car.aimingSpeed / 2 {
                        return
                    }
                    // decrease left wheel accel rate speed
                    car.leftWheelSpeed = car.aimingSpeed / 2
                    car.rightWheelSpeed = car.aimingSpeed
                }
                else if isRight {
                    if car.rightWheelSpeed == car.aimingSpeed / 2 {
                        return
                    }
                    car.rightWheelSpeed = car.aimingSpeed / 2
                    car.leftWheelSpeed = car.aimingSpeed
                    
                }
                else {
                    car.leftWheelSpeed = car.aimingSpeed
                    car.rightWheelSpeed = car.aimingSpeed
                }
                setMotorSpeedLabel()
                updateToServer()
            }
        }
        else if count % 10 == 0 {
            if speed >= 0 {
                car.aimingSpeed -= 10
            }
            if isLeft {
                if car.leftWheelSpeed == car.aimingSpeed / 2 {
                    return
                }
                // decrease left wheel accel rate speed
                car.leftWheelSpeed = car.aimingSpeed / 2
                car.rightWheelSpeed = car.aimingSpeed
            }
            else if isRight {
                if car.rightWheelSpeed == car.aimingSpeed / 2 {
                    return
                }
                // decrease right wheel accel rate speed
                car.rightWheelSpeed = car.aimingSpeed / 2
                car.leftWheelSpeed = car.aimingSpeed
            }
            else {
                car.leftWheelSpeed = car.aimingSpeed
                car.rightWheelSpeed = car.aimingSpeed
            }
            setMotorSpeedLabel()
            //  update to server
            updateToServer()
        }
    }
    
    //turn left handler
    func turnLeft(isLeft: Bool) {
      
        if !isLeft {
            if car.leftWheelSpeed == car.aimingSpeed {
                return
            }
            car.leftWheelSpeed = car.aimingSpeed
            car.rightWheelSpeed = car.aimingSpeed
            setMotorSpeedLabel()
            updateToServer()
            return
        }
        if car.leftWheelSpeed == car.aimingSpeed / 2 {
            return
        }
        // decrease left wheel accel rate speed
        car.leftWheelSpeed = car.aimingSpeed / 2
        car.rightWheelSpeed = car.aimingSpeed
        setMotorSpeedLabel()
        updateToServer()
    }
    
    // turn right hanlder
    func turnRight(isRight: Bool) {
        if !isRight {
            if car.rightWheelSpeed == car.aimingSpeed {
                return
            }
            car.leftWheelSpeed = car.aimingSpeed
            car.rightWheelSpeed = car.aimingSpeed
            setMotorSpeedLabel()
            updateToServer()
            return
        }
        if car.rightWheelSpeed == car.aimingSpeed / 2 {
            return
        }
        // decrease left wheel accel rate speed
        car.leftWheelSpeed = car.aimingSpeed
        car.rightWheelSpeed = car.aimingSpeed / 2
        setMotorSpeedLabel()
        updateToServer()
    }
    
    // function to call server connection
    func updateToServer() {
        
        print("update values:")
        print("aimingSpeed: \(car.aimingSpeed)")
        print("leftWheelSpeed: \(car.leftWheelSpeed)")
        print("rightWheelSpeed: \(car.rightWheelSpeed)")
        if car.isReverse {
            print("direction: Reverse")
        }
        else {
            print("direction: Forward")
        }
        self.requestToServer()
    }
    
    // request to server
    func requestToServer() {
        var dir = "Reverse"
        if !car.isReverse {
            dir = "Forward"
        }
        let leftmotor = "motorLeft" + dir
        let rightmotor = "motorRight" + dir
        mqttClient.publish(leftmotor, withString: String(car.leftWheelSpeed))
        print("send data left motor: \(car.leftWheelSpeed)")
        mqttClient.publish(rightmotor, withString: String(car.rightWheelSpeed))
        print("send data right motor: \(car.rightWheelSpeed)")
    }
    
    // set labels
    func setMotorSpeedLabel() {
        demoView.leftMotorView.WheelSpeedLabel.text = "\(car.leftWheelSpeed)"
        demoView.rightMotorView.WheelSpeedLabel.text = "\(car.rightWheelSpeed)"
    }
    
    // mqtt Delegate
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("publish")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print(message.topic)
        if (message.topic == "mapData") {
            let result = String(bytes: message.payload, encoding: .utf8)
            let splitByNextLine = result?.split(separator: "\r\n")
//            let splitByNextLine = result?.split(separator: "\n")
            var last = 1
            if let data = splitByNextLine {
                for i in 0 ..< data.count {
                    let splitByComma = data[i].split(separator: ",")
                    for j in 0 ..< splitByComma.count {
                        print(splitByComma[j])
                        let flag = j % 4
                        if i == data.count - 1 && j == splitByComma.count - 1 {
                            last = -1
                        }
                        mapListViewController.setDataMap(last: last, data: (splitByComma[j] as NSString).floatValue, flag: flag, newLine: i)
                    }
                }
            }
            print("end")
        }
        
        mqttClient.publish("mapStatus", withString: "received")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("Publish by \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        print("subscribe \(String(describing: topics.last))")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic: \(topic)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("ask still connecting?")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("still connected by server reply")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("Disconnect")
        if let error = err {
            print("error: \(error)")
        }
    }
}

// extension class for uiview controller to add and remove view controller
extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
