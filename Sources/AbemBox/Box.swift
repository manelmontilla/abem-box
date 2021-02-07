//
//  Box.swift
//  
//
//  Created by Manel Montilla on 9/1/21.
//

import Foundation
import Sodium

public class Box {
    
    public let file: URL
    
    var header: Header?
    var filesTable: FilesTable?
    var fk: Bytes?
    var dk: Bytes?
    
    public var rootDir: Result<Directory,Error> {
        get {
            guard let table = self.filesTable else {
                return Result{
                    throw AbemBoxErrors.BoxClosed
                }
            }
            let r = table.basicData.rootDir
            let rootURL = URL(string:"/")
            let directoryInfo = Directory(directoryData: r,fullName: rootURL!)
            return Result{
                directoryInfo
            }
        }
    }
    
    deinit {
        let sodium = Sodium()
        if self.fk != nil {
            sodium.utils.zero(&self.fk!)
        }
        if self.dk != nil {
            sodium.utils.zero(&self.dk!)
        }
    }
    
    public init?(from file:URL, with password: String) throws {
        guard #available(OSX 10.15.4, *) else {throw  AbemBoxErrors.OperationNotSupported}
        guard #available(iOS 13.4, *) else {throw  AbemBoxErrors.OperationNotSupported}
        guard file.startAccessingSecurityScopedResource() else {throw
            AbemBoxErrors.LogicalError("can not access file: \(file.absoluteString)")
        }
        defer {file.stopAccessingSecurityScopedResource()}
        self.file = file
        // Open the handler for reading.
        let fileHandle = try FileHandle(forReadingFrom: file)
        defer {try? fileHandle.close()}
        
        // Read the header.
        let headerContents = try fileHandle.read(upToCount: Header.size)
        guard let contents = headerContents  else {
            throw AbemBoxErrors.InvalidBoxFile
        }
        self.header = try Header(contents: contents)
        
        // Derive the keys.
        let sodium = Sodium()
        var mk = masterKey(from: password, salt: header!.salt)
        self.dk = sodium.keyDerivation.derive(secretKey: mk, index: 1, length: sodium.secretBox.KeyBytes , context: "Data")!
        self.fk = sodium.keyDerivation.derive(secretKey: mk, index: 2, length: sodium.secretBox.KeyBytes , context: "Files")!
        sodium.utils.zero(&mk)
        
        // Read the files table.
        let ciphertext = try fileHandle.read(upToCount: Int(header!.sealedBoxDataSize))!
        let contentBytes  = sodium.secretBox.open(nonceAndAuthenticatedCipherText: [UInt8](ciphertext), secretKey: self.dk!)
        guard let content = contentBytes else {  throw AbemBoxErrors.LogicalError("invalid sealed file") }
        self.filesTable = try FilesTable(from: Data(content))
        
    }
    
    /**
     Adds a file to the box in the given path and with the given name and contents.
     If a file in the same path and with the same name already exists the it throws the error:
     AbemBoxError.FileAlreadyExists
     
     - Parameter in: The  directory to add the File.
     
     - Parameter named: the name of the file to add including the extension, e.g. : example.txt
     
     - Parameter containing: the contents of the file.
     
     */
    public func addFile(in dir: Directory, named name: String, containing data: Data)  throws -> Directory  {
        guard #available(OSX 10.15.4, *) else {throw  AbemBoxErrors.OperationNotSupported}
        guard #available(iOS 13.4, *) else {throw  AbemBoxErrors.OperationNotSupported}
        
        let file = self.file
        let sodium = Sodium()
        // Get the hash for the contents of the file.
        let hash = sodium.genericHash.hash(message: [UInt8](data))
        guard let h = hash else {
            throw AbemBoxErrors.LogicalError("unable to generate hash")
        }
        
        // Encrypt the data of the new file.
        let fileContentCiphertext: Bytes? = sodium.secretBox.seal(message: Bytes(data), secretKey: self.fk!)
        guard let fileCiphertext = fileContentCiphertext else {
            throw AbemBoxErrors.LogicalError("unable to encrypt data")
        }
        var fileOffset: UInt64?
        do {
            // Write the data to the file data area of the box.
            let fileHandle = try FileHandle(forUpdating: file)
            defer {
                try! fileHandle.close()
            }
            let last = try fileHandle.seekToEnd()
            fileOffset = last
            fileHandle.write(Data(fileCiphertext))
        }
        // Add the file to fileTable in the proper directory.
        let fileItem = AbemBox_FileListItem.with{
            item in
            item.hash = Data(h)
            item.offset = fileOffset!
            item.deleted = false
            item.size = UInt64(fileCiphertext.count)
        }
        let addedInDir = try self.filesTable!.addFile(file: fileItem, in: dir, named: name)
        try self.saveMetadata()
        // Return the directory info were the file was added.
        return addedInDir
    }
    
    public func removeFile(file: File)  throws -> Directory  {
        guard #available(OSX 10.15.4, *) else {throw  AbemBoxErrors.OperationNotSupported}
        guard #available(iOS 13.0, *) else {throw  AbemBoxErrors.OperationNotSupported}
        let removedInDir = try self.filesTable!.removeFile(file.fullName)
        try self.saveMetadata()
        return removedInDir
    }
    
    public func addDir(in dir: Directory, named name: String)  throws -> Directory  {
        guard #available(OSX 10.15.4, *) else {throw  AbemBoxErrors.OperationNotSupported}
        guard #available(iOS 13.0, *) else {throw  AbemBoxErrors.OperationNotSupported}
        let fullName = dir.fullName.appendingPathComponent(name)
        let addedInDir = try self.filesTable!.addDirectory(fullName)
        try self.saveMetadata()
        // Return the directory info were the file was added.
        return addedInDir
    }
    
    public func removeDir(dir: Directory)  throws -> Directory  {
        guard #available(OSX 10.15.4, *) else {throw  AbemBoxErrors.OperationNotSupported}
        guard #available(iOS 13.0, *) else {throw  AbemBoxErrors.OperationNotSupported}
        let removedInDir = try self.filesTable!.removeDirectory(dir.fullName)
        try self.saveMetadata()
        return removedInDir
    }
    
    func saveMetadata() throws {
        guard #available(OSX 10.15.4, *) else {throw  AbemBoxErrors.OperationNotSupported}
        guard #available(iOS 13.0, *) else {throw  AbemBoxErrors.OperationNotSupported}
        let fileTableContents = try self.filesTable!.combined()
        guard fileTableContents.count < FilesTable.maxSize else {
            throw AbemBoxErrors.MaxNumberOfFilesLimitReached
        }
        let sodium = Sodium()
        let ciphertext: Bytes? = sodium.secretBox.seal(message: Bytes(fileTableContents), secretKey: self.dk!)
        guard let cipherT = ciphertext else {
            throw AbemBoxErrors.LogicalError("unable to encrypt data")
        }
        
        let fileHandle = try FileHandle(forUpdating: file)
        defer {
            try! fileHandle.close()
        }
        // Set the position of the file to just the size of the header,
        // which is the start of the area where FilesTable structure is written.
        try fileHandle.seek(toOffset: UInt64(Header.size))
        fileHandle.write(Data(cipherT))
        // Update the header.
        let fileTableSize = cipherT.count
        self.header = Header(self.header!.salt, UInt64(fileTableSize))
        let headerContents = self.header!.combined()
        // Write the header to the disk.
        try fileHandle.seek(toOffset: 0)
        fileHandle.write(headerContents)
        try fileHandle.synchronize()
    }
    
    static public func create(named name: String, with password: String) throws -> Data {
        let sodium = Sodium()
        // Generate random salt.
        let salt = sodium.randomBytes.buf(length:sodium.pwHash.SaltBytes)!
        // Derive the keys.
        var mk = masterKey(from: password, salt: Data(salt))
        guard var dk = sodium.keyDerivation.derive(secretKey: mk, index: 1, length: sodium.secretBox.KeyBytes , context: "Data") else {
            throw AbemBoxErrors.LogicalError("can not derive key")
        }
        sodium.utils.zero(&mk)
        let filesData = AbemBox_FilesData.with{
            data in
            data.name = name
            data.filesContentAreaOffset = UInt64(Header.size + FilesTable.maxSize)
            data.filesContentAreaSize = 0
            data.rootDir = AbemBox_DirectoryData.with{
                rootDir in
                // rootDir does not have name.
                rootDir.name = ""
                rootDir.files = [AbemBox_DirectoryFile]()
                rootDir.subdirectories = [AbemBox_DirectoryData]()
            }
            data.fileList = [AbemBox_FileListItem]()
        }
        
        let filesDataPayload = try filesData.serializedData()
        let filesDataCipherText: Bytes = sodium.secretBox.seal(message: [UInt8](filesDataPayload), secretKey: dk)!
        sodium.utils.zero(&dk)
        guard  filesDataCipherText.count < FilesTable.maxSize else {
            throw AbemBoxErrors.LogicalError("too many files in the box")
        }
        let dataPadCount = FilesTable.maxSize - filesDataCipherText.count
        let pad: [UInt8] = [UInt8].init(repeating: 0, count: dataPadCount)
        var filesDataBytes = Data()
        filesDataBytes.append(Data(filesDataCipherText))
        filesDataBytes.append(Data(pad))
        let header  = Header(Data(salt), UInt64(filesDataCipherText.count))
        var payload = Data()
        payload.append(header.combined())
        payload.append(filesDataBytes)
        return payload
    }
}

func masterKey(from password: String, salt: Data) -> [UInt8] {
    let sodium = Sodium()
    // Derive the encryption key from the password.
    let pwdBytes = password.bytes
    let keySize = sodium.secretBox.KeyBytes
    let key = sodium.pwHash.hash(outputLength: keySize, passwd: pwdBytes, salt: [UInt8](salt), opsLimit: sodium.pwHash.OpsLimitModerate, memLimit: sodium.pwHash.MemLimitModerate)!
    return key
}
