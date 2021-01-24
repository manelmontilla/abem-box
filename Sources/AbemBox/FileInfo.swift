//
//  FileInfo.swift
//  
//
//  Created by Manel Montilla on 24/1/21.
//

import Foundation

public struct File {
    let hash: Data
    public let fullName: URL
}

public struct Directory {
    let directoryData: AbemBox_DirectoryData
    public let fullName: URL
    
    public func Stat() throws -> [FileInfo] {
        var infos = [FileInfo]()
        self.directoryData.files.forEach{
            file in
            let fileURL = self.fullName.appendingPathComponent(file.name, isDirectory: false)
            let file = File(hash: file.fileHash, fullName: fileURL)
            infos.append(.file(file))
        }
        
        self.directoryData.subdirectories.forEach{
            dir in
            let dirURL = self.fullName.appendingPathComponent(dir.name, isDirectory: false)
            let dirInfo = Directory(directoryData: dir, fullName: dirURL)
            infos.append(.directory(dirInfo))
        }
        return infos
    }
}

public enum FileInfo {
    case file(File)
    case directory(Directory)
}

