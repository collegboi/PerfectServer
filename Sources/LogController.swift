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

    static func getRequestLogs( name: String ) -> String {
        
        return (FileController.sharedFileHandler?.getContentsOfFile("", name + ".log"))!
    }
    
    static func getDatabaseLogs() -> String {
        
        return (FileController.sharedFileHandler?.getContentsOfFile("/var/log/mongodb/mongod.log"))!
    }
    
}
