//
//  File.swift
//  
//
//  Created by Manel Montilla on 24/1/21.
//

import Foundation

public enum AbemBoxErrors: Error {
    case LogicalError(_ Description: String)
    case FileAlreadyExists
    case InvalidFilePath
    case FileItemDoesNotExist
    case BoxClosed
    case DirectoryDoesNotExist
    case MaxNumberOfFilesLimitReached
    case InvalidBoxFile
    case CorrupedBox
    case OperationNotSupported
    case FileDoesNotExist
}
