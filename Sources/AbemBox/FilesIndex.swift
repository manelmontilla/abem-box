//
//  File.swift
//  
//
//  Created by Manel Montilla on 24/1/21.
//

import Foundation

typealias  FilesIndex =  [[UInt8]:Int]

extension FilesIndex {
    func exists(_ hash: [UInt8]) -> Bool {
        let index = self.index(forKey: hash)
        if index == nil {
            return false
        }
        return true
    }
}
