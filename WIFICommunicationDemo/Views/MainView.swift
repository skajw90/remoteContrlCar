//
//  DemoView.swift
//  WIFICommunicationDemo
//
//  Created by Jiwon Nam on 4/4/19.
//  Copyright © 2019 Jiwon Nam. All rights reserved.
//

import UIKit

protocol DemoViewDataSource {
    func setLeftAccel(isLeft: Bool)
    func setLeftBrake(isLeft: Bool)
    func setRightAccel(isRight: Bool)
    func setRightBrake(isRight: Bool)
    func setLeft(isLeft: Bool)
    func setRight(isRight: Bool)
    func setAccel(isAccel: Bool)
    func setBrake(isBrake: Bool)
    func setReverse(isReverse: Bool)
    func getSpeed() -> Int
}

protocol DemoViewDelegate {
    func startStreaming()
    func startStopMapping(isStart: Bool)
    func openMapList()
}


class MainView: UIView {
    
    var datasource: DemoViewDataSource?
    var delegate: DemoViewDelegate?
    var isTouchable = true
    var isStart = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isMultipleTouchEnabled = true
    }
    
    lazy var leftView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    } ()
    
    lazy var leftArrowView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "L.png"))
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    } ()
    
    lazy var rightArrowView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "R.png"))
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    } ()
    
    
    lazy var gearFrameView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    } ()
    
    lazy var speedLabelFrameView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    } ()
    
    lazy var accelView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named:"speedup")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    } ()
    
    lazy var brakeView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named:"md")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    } ()
    
    lazy var reverseSwitch: UISwitch = {
        let reverseSwitch = UISwitch()
        reverseSwitch.onTintColor = .clear
        reverseSwitch.translatesAutoresizingMaskIntoConstraints = false
        reverseSwitch.addTarget(self, action: #selector(reverse), for: UIControl.Event.valueChanged)
        addSubview(reverseSwitch)
        return reverseSwitch
    } ()
    
    
    lazy var speedLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "0"
        label.textAlignment = .center
        label.textColor = .white
        label.makeOutLine(oulineColor: #colorLiteral(red: 0.03826803132, green: 0.4584812965, blue: 0.9686274529, alpha: 1), foregroundColor: .white)
        label.font = label.font.withSize(50)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        return label
    } ()
    
    lazy var leftMotorView: MotorSpeedView = {
        let view = MotorSpeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.nameLabel.text = "Left Motor"
        addSubview(view)
        return view
    } ()
    
    lazy var rightMotorView: MotorSpeedView = {
        let view = MotorSpeedView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.nameLabel.text = "Right Motor"
        addSubview(view)
        return view
    } ()
    
    lazy var gearLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "D"
        label.textAlignment = .center
        label.textColor = .white
        label.makeOutLine(oulineColor: #colorLiteral(red: 0.03826803132, green: 0.4584812965, blue: 0.9686274529, alpha: 1), foregroundColor: .white)
        label.font = label.font.withSize(50)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        return label
    } ()
    
    lazy var menuButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named:"map"),for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(menuButtonHandler), for: UIControl.Event.touchDown)
        addSubview(button)
        return button
    } ()
    
    lazy var startStopMappingButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named:"maps"),for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startStopMappingButtonHandler), for: UIControl.Event.touchDown)
        addSubview(button)
        return button
    } ()
    
    @objc func startStopMappingButtonHandler(sender: Any) {
        let button = sender as! UIButton
        delegate!.startStopMapping(isStart: isStart)
        if isStart == true {
            button.setBackgroundImage(UIImage(named:"maps"),for: UIControl.State.normal)
        }
        if isStart == false {
            button.setBackgroundImage(UIImage(named:"mapstop"),for: UIControl.State.normal)
        }
        isStart = !isStart
    }
    
    @objc func menuButtonHandler(sender: Any) {
        delegate!.openMapList()
    }
    
    @objc func reverse(sender: UISwitch) {
        if sender.isOn {
            if datasource!.getSpeed() != 0 {
                reverseSwitch.setOn(false, animated: true)
                reverseSwitch.onTintColor = .clear
                return
            }
            // make speed 0,
            // and make speed reverse 0
            gearLabel.text = "R"
            datasource!.setReverse(isReverse: true)
            gearLabel.makeOutLine(oulineColor: .red, foregroundColor: .white)
            
        } else {
            if datasource!.getSpeed() != 0 {
                reverseSwitch.setOn(true, animated: true)
                reverseSwitch.onTintColor = .clear
                return
            }
            // make speed 0,
            // and make speed forward 0
            gearLabel.text = "D"
            datasource!.setReverse(isReverse: false)
            gearLabel.makeOutLine(oulineColor: #colorLiteral(red: 0.03826803132, green: 0.4584812965, blue: 0.9686274529, alpha: 1), foregroundColor: .white)
        }
    }
    
    
    func touchInLeftArrow(location: CGPoint) -> Bool {
        let center = leftArrowView.center
        let width = leftArrowView.bounds.width
        let height = leftArrowView.bounds.height
        let bound = CGRect(x: center.x - 0.5 * width, y: center.y - 0.5 * height, width: width, height: height)
        if bound.minX > location.x || bound.maxX < location.x || bound.minY > location.y || bound.maxY < location.y {
            return false
        }
        return true
    }
    
    func touchInRightArrow(location: CGPoint) -> Bool {
        let center = rightArrowView.center
        let width = rightArrowView.bounds.width
        let height = rightArrowView.bounds.height
        let bound = CGRect(x: center.x - 0.5 * width, y: center.y - 0.5 * height, width: width, height: height)
        if bound.minX > location.x || bound.maxX < location.x || bound.minY > location.y || bound.maxY < location.y {
            return false
        }
        return true
    }
    
    func touchInAccel(location: CGPoint) -> Bool {
        let center = accelView.center
        let width = accelView.bounds.width
        let height = accelView.bounds.height
        let bound = CGRect(x: center.x - 0.5 * width, y: center.y - 0.5 * height, width: width, height: height)
        if bound.minX > location.x || bound.maxX < location.x || bound.minY > location.y || bound.maxY < location.y {
            return false
        }
        return true
    }
    
    func touchInBrake(location: CGPoint) -> Bool {
        let center = brakeView.center
        let width = brakeView.bounds.width
        let height = brakeView.bounds.height
        let bound = CGRect(x: center.x - 0.5 * width, y: center.y - 0.5 * height, width: width, height: height)
        if bound.minX > location.x || bound.maxX < location.x || bound.minY > location.y || bound.maxY < location.y {
            return false
        }
        return true
    }
    
    var leftTouch = UITouch()
    var rightTouch = UITouch()
    var accelTouch = UITouch()
    var brakeTouch = UITouch()
    var touchViews = [UITouch:TouchSpotView]()
    var isAccel = false
    var isbrake = false
    var isLeft = false
    var isRight = false
    
    var left_accel = false
    var right_accel = false
    var left_brake = false
    var right_brake = false
    
    var newStart = true
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isTouchable {
            return
        }
        for touch in touches {
            if touchInLeftArrow(location: touch.location(in: self)) {
                isLeft = true
                leftTouch = touch
                createViewForTouch(touch: touch)
            }
            else if touchInRightArrow(location: touch.location(in: self)) {
                isRight = true
                rightTouch = touch
                createViewForTouch(touch: touch)
            }
            else if touchInAccel(location: touch.location(in: self)) {
                isAccel = true
                accelTouch = touch
                createViewForTouch(touch: touch)
            }
            else if touchInBrake(location: touch.location(in: self)) {
                isbrake = true
                brakeTouch = touch
                createViewForTouch(touch: touch)
            }
        }
        if isAccel && newStart {
            newStart = false
            datasource!.setAccel(isAccel: isAccel)
        }
            
        if isLeft {
            datasource!.setLeftAccel(isLeft: isLeft)
        }
        if isRight {
            datasource!.setRightAccel(isRight: isRight)
        }
            
        if isLeft && newStart {
            datasource!.setLeft(isLeft: isLeft)
        }
        if isRight && newStart{
            datasource!.setRight(isRight: isRight)
        }
            
        if isbrake && newStart {
            newStart = false
            datasource!.setBrake(isBrake: isbrake)
            if isLeft {
                datasource!.setLeftAccel(isLeft: isLeft)
            }
            if isRight {
                datasource!.setRightAccel(isRight: isRight)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let view = viewForTouch(touch: touch)
            // Move the view to the new location.
            let newLocation = touch.location(in: self)
            view?.center = newLocation
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        var endleft = false
        var endright = false
        var endaccel = false
        var endbrake = false
        for touch in touches {
            if touch == leftTouch {
                endleft = true
                isLeft = false
                print("left touch end")
                leftTouch = UITouch()
            } else if touch == rightTouch {
                endright = true
                isRight = false
                print("right touch end")
                 rightTouch = UITouch()
            } else if touch == accelTouch {
                endaccel = true
                isAccel = false
                print("accel touch end")
                 accelTouch = UITouch()
            } else if touch == brakeTouch {
                endbrake = true
                isbrake = false
                print("brake touch end")
                 brakeTouch = UITouch()
            }
            removeViewForTouch(touch: touch)
        }
        if endaccel {
            datasource!.setAccel(isAccel: isAccel)
            newStart = true
        }
        if endleft {
            if isAccel || isbrake {
                datasource!.setLeftAccel(isLeft: isLeft)
            }
            else {
                datasource!.setLeft(isLeft: isLeft)
            }
        }
        if endright {
            if isAccel || isbrake {
                datasource!.setRightAccel(isRight: isRight)
            }
            else {
                datasource!.setRight(isRight: isRight)
            }
        }
        if endbrake {
            datasource!.setBrake(isBrake: isbrake)
            newStart = true
        }
    }
    
    func createViewForTouch( touch: UITouch) {
        let newView = TouchSpotView()
        newView.bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
        newView.center = touch.location(in: self)
        
        // Add the view and animate it to a new size.
        addSubview(newView)
        UIView.animate(withDuration: 0.2) {
            newView.bounds.size = CGSize(width: 100, height: 100)
        }
        
        // Save the views internally
        touchViews[touch] = newView
        
        
    }
    
    func viewForTouch (touch : UITouch) -> TouchSpotView? {
        return touchViews[touch]
    }
    
    func removeViewForTouch (touch : UITouch ) {
        if let view = touchViews[touch] {
            view.removeFromSuperview()
            touchViews.removeValue(forKey: touch)
        }
    }
}

extension UILabel{
    
    func makeOutLine(oulineColor: UIColor, foregroundColor: UIColor) {
        let strokeTextAttributes = [
            NSAttributedString.Key.strokeColor : oulineColor,
            NSAttributedString.Key.foregroundColor : foregroundColor,
            NSAttributedString.Key.strokeWidth : -4.0,
            NSAttributedString.Key.font : self.font ?? 10
            ] as [NSAttributedString.Key : Any]
        self.attributedText = NSMutableAttributedString(string: self.text ?? "", attributes: strokeTextAttributes)
    }
    
}

class TouchSpotView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Update the corner radius when the bounds change.
    override var bounds: CGRect {
        get { return super.bounds }
        set(newBounds) {
            super.bounds = newBounds
            layer.cornerRadius = newBounds.size.width / 2.0
        }
    }
}

class MotorSpeedView: UIView {
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.textColor = .white
        label.makeOutLine(oulineColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), foregroundColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))
        label.font = label.font.withSize(15)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        return label
    } ()
    
    lazy var WheelSpeedLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "0"
        label.textAlignment = .center
        label.textColor = .white
        label.makeOutLine(oulineColor: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), foregroundColor: .white)
        label.font = label.font.withSize(50)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        return label
    } ()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        (nameLabel.frame, WheelSpeedLabel.frame) = bounds.divided(atDistance: frame.height * 0.5, from: .minYEdge)
    }
}
