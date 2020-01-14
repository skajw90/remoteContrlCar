//
//  DrawingView.swift
//  WIFICommunicationDemo
//
//  Created by Jiwon Nam on 11/22/19.
//  Copyright © 2019 Jiwon Nam. All rights reserved.
//

import UIKit

protocol drawingViewDataSource {
    func getDataForMap() -> [Map]
}

class DrawingView: UIView {
    var dataSource: drawingViewDataSource?
    var origin: CGPoint = CGPoint(x: 0, y: 0)
    let WHEELRADIUS: Float = 9
    let WHEELSDISTANCE: Float = 27
    var carMoves: [(CGPoint, CGPoint?, CGPoint?)]?
    var maxX: CGFloat = 0
    var minX: CGFloat = CGFloat.infinity
    var maxY: CGFloat = 0
    var minY: CGFloat = CGFloat.infinity
    var scope: CGFloat = 1
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawMap()
    }
    
    func setMapCoordination() {
        origin = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        var map = dataSource!.getDataForMap()
        if scope != 1 {
            for i in 0 ..< map.count {
                map[i] = Map(wheels: Wheels(leftWheelDistance: map[i].wheels.leftWheelDistance * Float(scope), rightWheelDistance: map[i].wheels.rightWheelDistance * Float(scope)), sensors: Sensors(leftSensor: map[i].sensors.leftSensor * Float(scope), rightSensor: map[i].sensors.rightSensor * Float(scope)))
            }
        }
        print("draw map")
        var vehiclePrevCenter: CGPoint?
        var prevAngle: Float?
        for i in 0 ..< map.count {
            let leftWheelDistance = Float.pi * WHEELRADIUS * map[i].wheels.leftWheelDistance
            let rightWheelDistance = Float.pi * WHEELRADIUS * map[i].wheels.rightWheelDistance
            if let prev = vehiclePrevCenter {
                let movementData = getMovementData(prevCenter: prev, left: leftWheelDistance, right: rightWheelDistance, prevAngle: prevAngle!)
                let curAngle = movementData.1
                let vehicleCurCenter: CGPoint = movementData.0
                let sensorsCurDistance = Sensors(leftSensor: map[i].sensors.leftSensor, rightSensor: map[i].sensors.rightSensor)
                    
                let leftDistSensorCurCenter = getCenterPoint(prevCenter: vehicleCurCenter, distance: sensorsCurDistance.leftSensor, angle: curAngle - Float.pi / 2)
                let rightDistSensorCurCenter = getCenterPoint(prevCenter: vehicleCurCenter, distance: sensorsCurDistance.rightSensor, angle: curAngle + Float.pi / 2)
                
                carMoves!.append((vehicleCurCenter, (sensorsCurDistance.leftSensor > 0) ? leftDistSensorCurCenter : nil, (sensorsCurDistance.rightSensor > 0) ? rightDistSensorCurCenter : nil))
                
                setMinAndMax(x: vehicleCurCenter.x, y: vehicleCurCenter.y)
                // set prev center positions
                vehiclePrevCenter = vehicleCurCenter
                prevAngle = movementData.1
            }
            else {
                carMoves = []
                // initial center positions
                vehiclePrevCenter = origin
                let leftDistSensorCenter = map[i].sensors.leftSensor > 0 ? CGPoint(x: CGFloat(Float(origin.x) - map[i].sensors.leftSensor), y: origin.y) : nil
                let rightDistSensorCenter = map[i].sensors.rightSensor > 0 ? CGPoint(x: CGFloat(Float(origin.x) + map[i].sensors.rightSensor), y: origin.y) : nil
                prevAngle = 0
                carMoves!.append((vehiclePrevCenter!, leftDistSensorCenter, rightDistSensorCenter))
                setMinAndMax(x: vehiclePrevCenter!.x, y: vehiclePrevCenter!.y)
            }
        }
    }
    
    func setMinAndMax(x: CGFloat, y: CGFloat) {
        minX = CGFloat.minimum(x, minX)
        maxX = CGFloat.maximum(x, maxX)
        minY = CGFloat.minimum(y, minY)
        maxY = CGFloat.maximum(y, maxY)
    }
    
    func resize() {
        for i in 0 ..< carMoves!.count {
            carMoves![i].0 = carMoves![i].0.multi(factor: scope)
            if let left = carMoves![i].1 {
                carMoves![i].1 = left.multi(factor: scope)
            }
            if let right = carMoves![i].2 {
                carMoves![i].2 = right.multi(factor: scope)
            }
            setMinAndMax(x: carMoves![i].0.x, y: carMoves![i].0.y)
        }
    }
    
    func drawMap() {
        setMapCoordination()
        let context = UIGraphicsGetCurrentContext()!
        var shiftPoint: CGPoint = CGPoint(x: 0, y: 0)
       
        if maxX - minX > bounds.width {
            // shrink left right porpotion
            scope = bounds.width / (maxX - minX + 20)
        }
        if maxY - minY > bounds.height {
            // shrink height porpotion
            scope = CGFloat.minimum((bounds.height / (maxY - minY + 20)), scope)
        }
        
        if scope != 1 {
            minX = CGFloat.infinity
            minY = CGFloat.infinity
            maxX = 0
            maxY = 0
            resize()
        }
        print("X: \(minX), \(maxX) : \(bounds.minX), \(bounds.maxX)")
        print("Y: \(minY), \(maxY) : \(bounds.minY), \(bounds.maxY)")
        let middleX = (maxX + minX) / 2
        let middleY = (maxY + minY) / 2
        // shifting
        if minX < bounds.minX{ shiftPoint.x = origin.x - middleX + 2 }
        else if maxX > bounds.maxX { shiftPoint.x = middleX - origin.x + 2 }
        if minY < bounds.minY { shiftPoint.y = origin.y - middleY + 2 }
        else if maxY > bounds.maxY { shiftPoint.y = middleY - origin.y + 2 }
        
        for i in 1 ..< carMoves!.count {
            // get left right wheels center
            context.move(to: carMoves![i - 1].0.add(point: shiftPoint))
            context.addLine(to: carMoves![i].0.add(point: shiftPoint))
            if i == 1 { context.setStrokeColor(UIColor.red.cgColor) }
            else{ context.setStrokeColor(UIColor.white.cgColor) }
            context.drawPath(using: .stroke)
            // draw left sensor input
            if let prev = carMoves![i - 1].1, let cur = carMoves![i].1 {
                context.move(to: prev.add(point: shiftPoint))
                context.addLine(to: cur.add(point: shiftPoint))
                context.setStrokeColor(UIColor.green.cgColor)
                context.drawPath(using: .stroke)
            }
            // draw right sensor input
            if let prev = carMoves![i - 1].2, let cur = carMoves![i].2 {
                context.move(to: prev.add(point: shiftPoint))
                context.addLine(to: cur.add(point: shiftPoint))
                context.setStrokeColor(UIColor.green.cgColor)
                context.drawPath(using: .stroke)
            }
        }
    }
    
    // angle
    func getCenterPoint(prevCenter: CGPoint, distance: Float, angle: Float) -> CGPoint {
        return CGPoint(x: prevCenter.x + CGFloat(distance * sin(angle)), y: prevCenter.y - CGFloat(distance * cos(angle)))
    }
    
    // return current center position and angle
    func getMovementData(prevCenter: CGPoint, left: Float, right: Float, prevAngle: Float) -> (CGPoint, Float) {
        let relativeAngle = (left - right) / WHEELSDISTANCE
        let curAngle: Float = prevAngle + relativeAngle
        var distance = WHEELSDISTANCE / 2 + WHEELSDISTANCE * fminf(left, right) / fabsf(left - right)
        distance = ((left - right) < 0 ? -1 : 1) * distance
        var curCenterPoint: CGPoint

        if left == right {
            curCenterPoint = getCenterPoint(prevCenter: prevCenter, distance: left, angle: curAngle)
        }
        else {
            let angularCenter = CGPoint(x: prevCenter.x + CGFloat(distance * cos(prevAngle)), y: prevCenter.y + CGFloat(distance * sin(prevAngle)))
            curCenterPoint = CGPoint(x: angularCenter.x - CGFloat(distance * cos(curAngle)), y: angularCenter.y - CGFloat(distance * sin(curAngle)))
        }
        return (curCenterPoint, curAngle)
    }
}

extension CGPoint {
    func add (point: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + point.x, y: self.y + point.y)
    }
    
    func multi(factor: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * factor, y: self.y * factor)
    }
}
