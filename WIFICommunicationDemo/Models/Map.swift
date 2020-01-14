//
//  Map.swift
//  WIFICommunicationDemo
//
//  Created by Jiwon Nam on 11/15/19.
//  Copyright © 2019 Jiwon Nam. All rights reserved.
//

import Foundation

struct Map: Codable {
    var wheels: Wheels
    var sensors: Sensors
    
    init(wheels: Wheels, sensors: Sensors) {
        self.wheels = wheels
        self.sensors = sensors
    }
    
    enum Error: Swift.Error {
        case encoding
        case writing
    }
    
    enum CodingKeys: String, CodingKey {
        case wheels = "wheels"
        case sensors = "sensors"
    }
}

struct Wheels: Codable {
    var leftWheelDistance: Float
    var rightWheelDistance: Float
}

struct Sensors: Codable {
    var leftSensor: Float
    var rightSensor: Float
}

extension Array where Element == Map {

    func save(to url: URL) throws {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            throw Map.Error.encoding
        }
        do {
            try jsonData.write(to: url)
        }
        catch {
            throw Map.Error.writing
        }
    }
    
    init(from url: URL) throws {
        let jsonData = try! Data(contentsOf: url)
        self = try JSONDecoder().decode([Map].self, from: jsonData)
    }
}
