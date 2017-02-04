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

private var _FileHandlerSharedInstance: FileHandler?

public class FileHandler {
    
    public class var sharedFileHandler: FileHandler? {
        return _FileHandlerSharedInstance
    }
    
    public init() {
        
        if (_FileHandlerSharedInstance == nil) {
            _FileHandlerSharedInstance = self
        }
        
        setWorkingDirectory("./Languages/")
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
    
    
    private func createFile(_ fileContents: String ) -> Bool {
        
        var result: Bool = true
        
        //setWorkingDirectory("./ConfigFiles")
        
        let thisFile = File("config.txt")
        
        do {
            try thisFile.open(.readWrite)
            
            defer {
                thisFile.close()
            }
        } catch {
            result = false
        }
        
        do {
            try thisFile.write(string: "Hello")
        } catch {
            result = false
        }
        
        return result
    }
    
    @discardableResult
    public func updateContentsOfFile(_ filePath: String, _ fileContents: String ) -> Bool {
        
        var result: Bool = true
        
        //setWorkingDirectory("./ConfigFiles")
        
        let thisFile = File(filePath)
        
        do {
            
            try thisFile.open(.readWrite)
        } catch {
            
        }
        
        do {
            try thisFile.write(string: fileContents )
        } catch {
            result = false
        }
        
        return result
    }
    
    
    public func getContentsOfFile(_ filePath: String, _ name: String) -> String {
        
        var result: String = ""
        
        //setWorkingDirectory("./Languages/"+filePath)
        
        let thisFile = File(filePath+"/"+name)
        
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
