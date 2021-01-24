import XCTest
@testable import AbemBox

final class AbemBoxTests: XCTestCase {
    
    var box: Box!
    var password: String!
    var tempFile: URL!
    
    override func setUpWithError() throws {
        self.password = "aB<z0aT!_Q"
        let data = try
            Box.create(named: "test", with: password)
        self.tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("sealed_box_test.sealed")
        try data.write(to: self.tempFile)
        self.box = try Box(from: self.tempFile, with: password)
    }
    
    override func tearDownWithError() throws {
        try! FileManager.default.removeItem(at: self.tempFile)
    }
    
    func testBoxAddFile() throws {
        let dir = try box.rootDir.get()
        let testContent = "test".data(using: .utf8)!
        _ = try! box.addFile(in: dir, named: "File1", containing: testContent)
        box = try Box(from: self.tempFile, with: password)!
        let root = try! box.rootDir.get()
        let infos = try! root.Stat()
        XCTAssertEqual(infos.count, 1)
        let info = infos[0]
        guard case .file(let file) = info else {
            XCTFail("invalid fileInfo")
            return
        }
        XCTAssertEqual(file.fullName.absoluteString,"/File1")
    }
    
    func testBoxDeleteFile() throws {
        let dir = try box.rootDir.get()
        let testContent = "test".data(using: .utf8)!
        let addedIn = try box.addFile(in: dir, named: "File1", containing: testContent)
        let stats = try addedIn.Stat()
        guard case let.file(file) = stats[0] else {
            XCTFail("unexpected FileItem type")
            return
        }
        _ =  try box.removeFile(file: file)
        box = try Box(from: self.tempFile, with: password)!
        let root = try! box.rootDir.get()
        let infos = try! root.Stat()
        XCTAssertEqual(infos.count, 0)
    }
    
    func testBoxAddDir() throws {
        let dirAdded = try self.box.addDir(in: try self.box.rootDir.get(), named: "a")
        XCTAssertEqual(dirAdded.fullName.absoluteString,"/a")
        let root = try! box.rootDir.get()
        let infos = try! root.Stat()
        XCTAssertEqual(infos.count, 1)
        let info = infos[0]
        guard case .directory(let dir) = info else {
            XCTFail("invalid fileInfo")
            return
        }
        XCTAssertEqual(dir.fullName,dirAdded.fullName)
    }
    
    func testBoxRemoveDir() throws {
        let dirAdded = try self.box.addDir(in: try self.box.rootDir.get(), named: "a")
        let removedFrom = try self.box.removeDir(dir: dirAdded)
        XCTAssertEqual(removedFrom.fullName.absoluteString,"/")
        let root = try! box.rootDir.get()
        let infos = try! root.Stat()
        XCTAssertEqual(infos.count, 0)
        _ = try Box(from: self.tempFile, with: self.password)
    }
    
    static var allTests = [
        ("testAbemBoxAddFile", testBoxAddFile),
        ("testAbemBoxDeleteFile", testBoxDeleteFile),
        ("testAbemBoxAddSubDir", testBoxAddDir),
        ("testAbemBoxAddSubDir", testBoxRemoveDir)
    ]
}
