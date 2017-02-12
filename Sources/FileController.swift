//
//  FileHandler.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 04/02/2017.
//
//

#if os(Linux)
    import LinuxBridge
#else
    import Darwin
#endif

import PerfectLib

private var _FileControllerSharedInstance: FileController?

public class FileController {
    
    public class var sharedFileHandler: FileController? {
        return _FileControllerSharedInstance
    }
    
    func report_memory() {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            print("Memory used in MB: \(taskInfo.resident_size/1000000)")
        }
        else {
            print("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
        }
    }
    
    func mach_task_self() -> task_t {
        return mach_task_self_
    }
    
    func getMegabytesUsed() -> Float? {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)
        let kerr = withUnsafeMutablePointer(to: &info) { infoPtr in
            return infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { (machPtr: UnsafeMutablePointer<integer_t>) in
                return task_info(
                    mach_task_self(),
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    machPtr,
                    &count
                )
            }
        }
        guard kerr == KERN_SUCCESS else {
            return nil
        }  
        return Float(info.resident_size) / (1024 * 1024)   
    }
    
    
    public init() {
        
        if (_FileControllerSharedInstance == nil) {
            _FileControllerSharedInstance = self
        }
        
        setWorkingDirectory("./webroot")
        //report_memory()
        
        //print("Memory used in MB: \(getMegabytesUsed())")
    }
    
    private func createWorkingDirectory(_ filePath: String ) -> Dir {
        //// ~/Library/Developer/Xcode/DerivedData/
        let workingDir = Dir(filePath)
        
        if !workingDir.exists {
            
            do {
                try workingDir.create()
                print("Working Direcotry (\(workingDir)) created")
            } catch {
                print("Could not creat working directory")
            }
        }
        
        return workingDir
    }
    
    @discardableResult
    private func setWorkingDirectory(_ filePath: String) -> Dir {
        
        
        let workingDir = createWorkingDirectory(filePath)
        
        do {
            try workingDir.setAsWorkingDir()
            print("Working directory set")
        } catch {
            print("Could not set working directory")
        }
        
        return workingDir
    }
    
    
    private func createFile(_ filePath: String, _ fileContents: String ) -> Bool {
        
        var result: Bool = true
        
        //setWorkingDirectory("./ConfigFiles")
        
        let thisFile = File(filePath)
        
        do {
            try thisFile.open(.readWrite)
            
            defer {
                thisFile.close()
            }
        } catch let error {
            print(error)
            result = false
        }
        
        do {
            try thisFile.write(string: fileContents)
        } catch let error {
            print(error)
            result = false
        }
        
        return result
    }
    
    @discardableResult
    private func createFileToWrite(_ file: File ) -> Bool {
        
        var result: Bool = true
        
        do {
            try file.open(.readWrite)
            
        } catch {
            result = false
        }
        
        return result
    }
    
    
    @discardableResult
    private func openFileToWrite(_ file: File ) -> Bool {
        
        var result: Bool = true
        
        do {
            try file.open(.write)
    
        } catch let error {
            print(error)
            result = false
        }
        
        return result
    }
    
    public func checkIfFileExits(_ filePath:String) -> Bool {
        
        let thisFile = File(filePath)
        
        if !thisFile.exists {
            
             return false
            
        } else {
            print(thisFile.path)
             return true
        }
    }
    
    @discardableResult
    public func updateContentsOfFile(_ filePath: String, _ fileContents: String ) -> Bool {
        
        var result: Bool = true
                            // filePath - folder/file.filetype
        let thisFile = File(filePath)
        
        if !thisFile.exists {
            
            self.createFileToWrite(thisFile)
            
        } else {
            print(thisFile.path)
            self.openFileToWrite(thisFile)
        }

        do {
            
            try thisFile.write(string: fileContents )
            
            defer {
                thisFile.close()
            }
            
        } catch let error {
            print(error)
            result = false
        }
        
        return result
    }
    
    
    public func getContentsOfFile(_ filePath: String, _ name: String) -> String {
        
        var result: String = ""
        
        //setWorkingDirectory("./Languages/"+filePath)
        
        let thisFile = File("Languages/" + filePath+"/"+name)
        
        do {
            try thisFile.open(.readWrite)
            
            defer {
                thisFile.close()
            }
        } catch {
            print("Error Opening")
        }
        
        do {
            result = try thisFile.readString()
        } catch {
            print("Error reading file")
        }
        
        return result
    }
}
