// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: Box.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

struct AbemBox_FilesData {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var name: String = String()

  var filesContentAreaOffset: UInt64 = 0

  var filesContentAreaSize: UInt64 = 0

  var fileList: [AbemBox_FileListItem] = []

  var rootDir: AbemBox_DirectoryData {
    get {return _rootDir ?? AbemBox_DirectoryData()}
    set {_rootDir = newValue}
  }
  /// Returns true if `rootDir` has been explicitly set.
  var hasRootDir: Bool {return self._rootDir != nil}
  /// Clears the value of `rootDir`. Subsequent reads from it will return its default value.
  mutating func clearRootDir() {self._rootDir = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _rootDir: AbemBox_DirectoryData? = nil
}

struct AbemBox_FileListItem {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var offset: UInt64 = 0

  var size: UInt64 = 0

  var deleted: Bool = false

  var hash: Data = Data()

  var references: UInt32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct AbemBox_DirectoryFile {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var name: String = String()

  var fileHash: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct AbemBox_DirectoryData {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var name: String = String()

  var files: [AbemBox_DirectoryFile] = []

  var subdirectories: [AbemBox_DirectoryData] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "abem_box"

extension AbemBox_FilesData: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".FilesData"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "name"),
    3: .standard(proto: "files_content_area_offset"),
    4: .standard(proto: "files_content_area_size"),
    5: .standard(proto: "file_list"),
    6: .standard(proto: "root_dir"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 3: try { try decoder.decodeSingularUInt64Field(value: &self.filesContentAreaOffset) }()
      case 4: try { try decoder.decodeSingularUInt64Field(value: &self.filesContentAreaSize) }()
      case 5: try { try decoder.decodeRepeatedMessageField(value: &self.fileList) }()
      case 6: try { try decoder.decodeSingularMessageField(value: &self._rootDir) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 1)
    }
    if self.filesContentAreaOffset != 0 {
      try visitor.visitSingularUInt64Field(value: self.filesContentAreaOffset, fieldNumber: 3)
    }
    if self.filesContentAreaSize != 0 {
      try visitor.visitSingularUInt64Field(value: self.filesContentAreaSize, fieldNumber: 4)
    }
    if !self.fileList.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.fileList, fieldNumber: 5)
    }
    if let v = self._rootDir {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: AbemBox_FilesData, rhs: AbemBox_FilesData) -> Bool {
    if lhs.name != rhs.name {return false}
    if lhs.filesContentAreaOffset != rhs.filesContentAreaOffset {return false}
    if lhs.filesContentAreaSize != rhs.filesContentAreaSize {return false}
    if lhs.fileList != rhs.fileList {return false}
    if lhs._rootDir != rhs._rootDir {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension AbemBox_FileListItem: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".FileListItem"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "offset"),
    2: .same(proto: "size"),
    3: .same(proto: "deleted"),
    4: .same(proto: "hash"),
    5: .same(proto: "references"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.offset) }()
      case 2: try { try decoder.decodeSingularUInt64Field(value: &self.size) }()
      case 3: try { try decoder.decodeSingularBoolField(value: &self.deleted) }()
      case 4: try { try decoder.decodeSingularBytesField(value: &self.hash) }()
      case 5: try { try decoder.decodeSingularUInt32Field(value: &self.references) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.offset != 0 {
      try visitor.visitSingularUInt64Field(value: self.offset, fieldNumber: 1)
    }
    if self.size != 0 {
      try visitor.visitSingularUInt64Field(value: self.size, fieldNumber: 2)
    }
    if self.deleted != false {
      try visitor.visitSingularBoolField(value: self.deleted, fieldNumber: 3)
    }
    if !self.hash.isEmpty {
      try visitor.visitSingularBytesField(value: self.hash, fieldNumber: 4)
    }
    if self.references != 0 {
      try visitor.visitSingularUInt32Field(value: self.references, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: AbemBox_FileListItem, rhs: AbemBox_FileListItem) -> Bool {
    if lhs.offset != rhs.offset {return false}
    if lhs.size != rhs.size {return false}
    if lhs.deleted != rhs.deleted {return false}
    if lhs.hash != rhs.hash {return false}
    if lhs.references != rhs.references {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension AbemBox_DirectoryFile: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".DirectoryFile"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "name"),
    2: .standard(proto: "file_hash"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self.fileHash) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 1)
    }
    if !self.fileHash.isEmpty {
      try visitor.visitSingularBytesField(value: self.fileHash, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: AbemBox_DirectoryFile, rhs: AbemBox_DirectoryFile) -> Bool {
    if lhs.name != rhs.name {return false}
    if lhs.fileHash != rhs.fileHash {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension AbemBox_DirectoryData: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".DirectoryData"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "name"),
    2: .same(proto: "files"),
    3: .same(proto: "subdirectories"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.files) }()
      case 3: try { try decoder.decodeRepeatedMessageField(value: &self.subdirectories) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 1)
    }
    if !self.files.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.files, fieldNumber: 2)
    }
    if !self.subdirectories.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.subdirectories, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: AbemBox_DirectoryData, rhs: AbemBox_DirectoryData) -> Bool {
    if lhs.name != rhs.name {return false}
    if lhs.files != rhs.files {return false}
    if lhs.subdirectories != rhs.subdirectories {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
