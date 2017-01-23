//
//  RemoteConfig.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 21/01/2017.
//
//

import Cocoa
import PerfectLib

class RemoteConfig {
    
    static func createWorkingDirectory(_ filePath: String ) -> Dir {
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
    static func setWorkingDirectory(_ filePath: String) -> Dir {
        
        
        let workingDir = createWorkingDirectory(filePath)
        
        do {
            try workingDir.setAsWorkingDir()
            print("Working directory set")
        } catch {
            print("Could not set working directory")
        }
        
        return workingDir
    }
    
    
    static func createFile(_ fileContents: String ) -> Bool {
        
        var result: Bool = true
        
        setWorkingDirectory("./ConfigFiles")
        
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
    
    
    static func updateContentsOfFile(_ fileContents: String ) -> Bool {
        
        var result: Bool = true
        
        setWorkingDirectory("./ConfigFiles")
        
        let thisFile = File("config.json")
        
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
    
    
    static func getContentsOfFile(_ fileName: String) -> String {
        
        var result: String = ""
        
        setWorkingDirectory("./ConfigFiles")
        
        let thisFile = File("config.json")
        
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
