//
//  File.swift
//  
//
//  Created by Manel Montilla on 23/1/21.
//

import Foundation
import Sodium

struct Header {
    static var size: Int {
        let sodium = Sodium()
        // salt length + the  64 bit for the length of the SealedBoxDataSize
        return sodium.pwHash.SaltBytes + 8
    }
    
    let salt: Data
    let sealedBoxDataSize: UInt64
    
    init(_ salt:Data, _ sealedBoxDataSize: UInt64) {
        self.salt = salt
        self.sealedBoxDataSize = sealedBoxDataSize
    }
    
    init(contents:Data) throws {
        guard contents.count == Header.size else {
            throw AbemBoxErrors.InvalidBoxFile
        }
        let sodium = Sodium()
        let salt = contents[0..<sodium.pwHash.SaltBytes]
        let sizeData = contents[sodium.pwHash.SaltBytes..<contents.count]
        let size = sizeData.withUnsafeBytes{
            $0.load(as: UInt64.self)
        }
        self.salt = salt
        self.sealedBoxDataSize = size
    }
    
    func combined() -> Data {
        var res = Data()
        res.append(self.salt)
        var size = self.sealedBoxDataSize
        let sizeData = Data(bytes: &size, count: MemoryLayout<UInt64>.size)
        res.append(Data(sizeData))
        return res
    }
    
}
