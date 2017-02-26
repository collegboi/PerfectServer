//
//  LogController.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 22/02/2017.
//
//

import Foundation

#if os(Linux)
    import LinuxBridge
#else
    import Darwin
#endif

import PerfectLib

class LogController {

    static func getRequestLogs() -> String {
        
        return (FileController.sharedFileHandler?.getContentsOfFile("", "requests.log"))!
    }
    
    static func getDatabaseLogs() -> String {
        
        return (FileController.sharedFileHandler?.getContentsOfFile("/var/log/mongodb/mongod.log"))!
    }
    
}
