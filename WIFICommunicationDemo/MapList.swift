//
//  MapList.swift
//  WIFICommunicationDemo
//
//  Created by Jiwon Nam on 12/1/19.
//  Copyright © 2019 Jiwon Nam. All rights reserved.
//

import Foundation

struct MapList: Codable {
    var fileName: String
}

extension Array where Element == MapList {

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
        self = try JSONDecoder().decode([MapList].self, from: jsonData)
    }
}
