//
//  File.swift
//  
//
//  Created by Manel Montilla on 23/1/21.
//

import Foundation
import Sodium

struct FilesTable {
    static let maxSize = 2 * (2 << 19) // 2 MB's.
    var basicData: AbemBox_FilesData
    var index: FilesIndex
    
    init(_ data: AbemBox_FilesData) {
        self.basicData = data
        self.index = data.buildIndex()
    }
    
    init?(from content: Data) throws {
        self.basicData = try AbemBox_FilesData(serializedData:content)
        self.index = self.basicData.buildIndex()
    }
    
    func combined() throws -> Data {
        let ret = try self.basicData.serializedData()
        return ret
    }
    
    mutating func addFile(file fileItem: AbemBox_FileListItem, in dir: Directory, named name: String) throws -> Directory {
        let hashBytes = [UInt8](fileItem.hash)
        var index = self.index[hashBytes]
        if  index == nil {
            index = self.basicData.fileList.count
            self.basicData.fileList.append(fileItem)
            self.basicData.fileList[index!].references = 1
            self.index[hashBytes] = index!
        } else {
            var references = self.basicData.fileList[index!].references
            references+=1
            self.basicData.fileList[index!].references = references
        }
        var (dirName, components) = try dir.fullName.treePath()
        if dirName != "/" {
            components.append(dirName)
        }
        let fDirData = AbemBox_DirectoryFile.with{
            f in
            f.name = name
            f.fileHash = fileItem.hash
        }
        // Add the file to the directory tree.
        let newDir = try self.basicData.rootDir.addFile(at: components, fDirData)
        let newDirInfo = Directory(directoryData: newDir, fullName: dir.fullName)
        return newDirInfo
    }
    
    mutating func removeFile(_ fullName: URL) throws -> Directory {
        let (name, components) = try fullName.treePath()
        let fileItem = try self.basicData.rootDir.findFile(at: components, named: name)
        let hashBytes = [UInt8](fileItem.fileHash)
        let index = self.index[hashBytes]
        if  index == nil {
            throw AbemBoxErrors.CorrupedBox
        }
        var references = self.basicData.fileList[index!].references
        references-=1
        self.basicData.fileList[index!].references = references
        if references == 0 {
            self.basicData.fileList[index!].deleted = true
        }
        let dirModified = try self.basicData.rootDir.removeFile(at: components, named: name)
        return Directory(directoryData: dirModified, fullName: fullName.deletingLastPathComponent())
    }
    
    mutating func addDirectory(_ fullName: URL) throws -> Directory {
        let (name, components) = try fullName.treePath()
        let dirModified = try self.basicData.rootDir.addDirectory(at: components, named: name)
        return Directory(directoryData: dirModified, fullName: fullName)
    }
    
    mutating func removeDirectory(_ fullName: URL) throws -> Directory {
        let (name, components) = try fullName.treePath()
        let dirModified = try self.basicData.rootDir.removeDirectory(at: components, named: name)
        return Directory(directoryData: dirModified, fullName: fullName.deletingLastPathComponent())
    }
    
}


extension URL {
    func treePath() throws -> (String,[String]) {
        var components = self.pathComponents
        guard components.count > 0 && components[0] == "/" else {
            throw AbemBoxErrors.LogicalError("invalid path \(self.absoluteString)")
        }
        let name = components[components.count-1]
        components.remove(at: components.count-1)
        if components.count > 0 {
            components.remove(at: 0)
        }
        return (name,components)
    }
}


extension AbemBox_FilesData {
    func buildIndex() ->  FilesIndex {
        var index = FilesIndex()
        for (i , file) in self.fileList.enumerated() {
            let h = [UInt8](file.hash)
            index[h] = i
        }
        return index
    }
    
}
