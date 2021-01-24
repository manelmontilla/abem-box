//
//  File.swift
//  
//
//  Created by Manel Montilla on 30/1/21.
//

import Foundation

extension AbemBox_DirectoryData {
    mutating func apply(at path: [String], action: (AbemBox_DirectoryData) throws -> AbemBox_DirectoryData) throws -> AbemBox_DirectoryData {
        if path.count == 0 || path[0] == "" {
            self = try action(self)
            return self
        }
        var names = path
        let nodeName = path[0]
        for i in 0..<self.subdirectories.count {
            if self.subdirectories[i].name == nodeName {
                names.remove(at: 0)
                return try self.subdirectories[i].apply(at: names, action: action)
            }
        }
        throw AbemBoxErrors.DirectoryDoesNotExist
    }
    
    func findFile(at path: [String], named name: String) throws -> AbemBox_DirectoryFile {
        if path.count == 0 || path[0] == "" {
             return try self.files.find(named: name)
        }
        var names = path
        let nodeName = path[0]
        for i in 0..<self.subdirectories.count {
            if self.subdirectories[i].name == nodeName {
                names.remove(at: 0)
                let subdir = self.subdirectories[i]
                return try subdir.findFile(at: path, named: name)
            }
        }
        throw AbemBoxErrors.DirectoryDoesNotExist
    }
    
    mutating func addFile(at path: [String], _ file: AbemBox_DirectoryFile ) throws -> AbemBox_DirectoryData {
        return try self.apply(at: path) {
            dir in
            var modified = dir
            modified.files.append(file)
            return modified
        }
    }
    
    mutating func removeFile(at path: [String], named name: String ) throws -> AbemBox_DirectoryData {
        return try self.apply(at: path){
            dir in
            var modified = dir
            try modified.files.remove(file: name)
            return modified
        }
    }
    
    mutating func addDirectory(at path: [String], named name: String) throws -> AbemBox_DirectoryData {
        var newDir:AbemBox_DirectoryData!
        _ = try self.apply(at: path) {
            dir in
            var modified = dir
            newDir = AbemBox_DirectoryData.with{
                dir in
                dir.files=[]
                dir.subdirectories = []
                dir.name = name
            }
            modified.subdirectories.append(newDir!)
            return modified
        }
        return newDir
    }
    
    mutating func removeDirectory(at path: [String], named name: String) throws -> AbemBox_DirectoryData {
        try self.apply(at: path) {
            dir in
            var modified = dir
            let index = modified.subdirectories.firstIndex(){
                item in
                item.name == name
            }
            guard index != nil else {throw AbemBoxErrors.DirectoryDoesNotExist}
            modified.subdirectories.remove(at: index!)
            return modified
        }
    }
}


extension Array where Element==AbemBox_DirectoryFile {
    mutating func remove(file name: String) throws {
        var index: Int?
        for (i, finfo) in self.enumerated() {
            if finfo.name == name {
                index = i
                break
            }
        }
        
        guard let filePos = index else {
            throw AbemBoxErrors.FileDoesNotExist
        }
        self.remove(at: filePos)
    }
    
    func find(named name:String) throws -> AbemBox_DirectoryFile {
        let file = self.first{
            f in
            f.name == name
        }
        guard file != nil else {throw AbemBoxErrors.FileDoesNotExist}
        return file!
    }
}
