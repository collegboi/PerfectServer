//
//  SystemController.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 11/02/2017.
//
//

#if os(Linux)
    import LinuxBridge
#else
    import Darwin
#endif

import PerfectLib


extension String {
    func condenseWhitespace() -> String {
        return self.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

class SystemController {
    
    private class func runProc(cmd: String, args: [String], read: Bool = false) throws -> String? {
        let envs = [("PATH", "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin")]
        let proc = try SysProcess(cmd, args: args, env: envs)
        var ret: String?
        if read {
            var ary = [UInt8]()
            while true {
                do {
                    guard let s = try proc.stdout?.readSomeBytes(count: 1024), s.count > 0 else {
                        break
                    }
                    ary.append(contentsOf: s)
                } catch PerfectLib.PerfectError.fileError(let code, _) {
                    if code != EINTR {
                        break
                    }
                }
            }
            ret = UTF8Encoding.encode(bytes: ary)
        }
        let res = try proc.wait(hang: true)
        if res != 0 {
            let s = try proc.stderr?.readString()
            throw  PerfectError.systemError(Int32(res), s!)
        }
        return ret
    }
    // ---------------------------------------------------------------------------------------- //
    // --------------------------------LINUX COMMANDS----------------------------------------- //
    // ---------------------------------------------------------------------------------------- //
    
    class func restartDatabaseCMD() {
        
        do {
            guard let _ = try runProc(cmd: "systemctrl", args: ["restart", "mongodb"], read: true) else {
                return
            }
            
            //print(output)
        } catch let error  {
            print(error)
        }

    }
    
    class func getDatabaseStatus() -> [String:String] {
        
        var returnStr = [String:String]()
        
        returnStr["status"] = "1"
        
        do {
            guard let output = try runProc(cmd: "systemctrl", args: ["status", "mongodb"], read: true) else {
                return returnStr
            }
            
            if output.contains(string: "active (running)") {
                returnStr["status"] = "1"
            }
            
            //print(output)
        } catch let error  {
            print(error)
        }
        
        return returnStr
    }
    
    class func getLinuxStats() -> String {
        
        var data = [String:[String:String]]()
        
        data["memory"] = SystemController.getMemoryLinuxUsuage()
        data["storage"] = SystemController.getStorageLinuxUsuage()
        data["cpu"] = SystemController.getCPULinuxUsuage()
        data["database"] = SystemController.getDatabaseStatus()
        
        return  "{\"data\":\(JSONController.parseJSONToStr(dict: data))}"
    }
    
    
    @discardableResult
    class func getCPULinuxUsuage() -> [String:String] {
        
        var returnStr = [String:String]()
        
        do {
            guard let output = try runProc(cmd: "top", args: ["-bn1"], read: true) else {
                return returnStr
            }
            
            let list: [String] = output.components(separatedBy: "\n")
            
            if list.count > 0 {
                
                let condensedStr = list[2].condenseWhitespace()
                
                let cpuList: [String] = condensedStr.components(separatedBy: " ")
                
                if cpuList.count >= 8 {
                    let status : [String:String] = [
                        "user": cpuList[1],
                        "system": cpuList[3],
                        "idle": cpuList[7]
                    ]
                    
                    returnStr = status
                }
            }
            
            //print(output)
        } catch let error  {
            print(error)
        }
        return returnStr
    }
    
    
    @discardableResult
    class func getMemoryLinuxUsuage() -> [String:String] {
        
        var returnStr = [String:String]()
        
        do {
            guard let output = try runProc(cmd: "free", args: ["-m"], read: true) else {
                return returnStr
            }
            
            let list: [String] = output.components(separatedBy: "\n")
            
            if list.count > 0 {
                
                let condensedStr = list[1].condenseWhitespace()
                
                let memoryList: [String] = condensedStr.components(separatedBy: " ")
                
                if memoryList.count >= 5 {
                    let status : [String:String] = [
                        "total": memoryList[1],
                        "used": memoryList[2],
                        "free": memoryList[3],
                        "available": memoryList[6]
                    ]
                    
                    returnStr = status
                }
            }
            
            //print(output)
        } catch let error  {
            print(error)
        }
        return returnStr
    }
    
    @discardableResult
    class func getStorageLinuxUsuage() -> [String:String] {
        
        var returnStr = [String:String]()
        
        do {
            guard let output = try runProc(cmd: "df", args: ["-h"], read: true) else {
                return returnStr
            }
            
            let list: [String] = output.components(separatedBy: "\n")
            
            if list.count >= 3 {
                
                let condensedStr = list[3].condenseWhitespace()
                
                let memoryList: [String] = condensedStr.components(separatedBy: " ")
                
                if memoryList.count >= 3 {
                    let status : [String:String] = [
                        "size": memoryList[1].substring(to: memoryList[1].index(before: memoryList[1].endIndex)),
                        "used": memoryList[2].substring(to: memoryList[2].index(before: memoryList[2].endIndex)),
                        "avilable": memoryList[3].substring(to: memoryList[3].index(before: memoryList[3].endIndex))
                    ]
                    returnStr = status
                }
            }
            
            //print(output)
        } catch let error  {
            print(error)
        }
        return returnStr
    }
    
    
    // ---------------------------------------------------------------------------------------- //
    // -------------------------------MAC COMMANDS--------------------------------------------- //
    // ---------------------------------------------------------------------------------------- //
    class func getDirectorySize() -> String {
        
        var returnStr = "Error"
        
        do {
            let output = try runProc(cmd: "du", args: ["-sh *"], read: true)
            returnStr = output ?? "Error"
            //print(output)
        } catch let error  {
            print(error)
        }
        return returnStr
    }
    
    class func getListOfFiles() -> String {
        
        var returnStr = "Error"
        
        do {
            let output = try runProc(cmd: "ls", args: ["-la"], read: true)
            returnStr = output ?? "Error"
            //print(output)
        } catch let error  {
            print(error)
        }
        return returnStr
    }
    
    @discardableResult
    class func getMemoryMacUsuage() -> String {
        
        var returnStr = "Error"
        
        do {
            guard let output = try runProc(cmd: "top", args: ["-l 1"], read: true) else {
                return returnStr
            }
            
            let list: [String] = output.components(separatedBy: "\n")
            
            if list.count > 10 {
                
                let status : [String:String] = [
                    "date": list[1],
                    "Processes" : list[0],
                    "Load Avg" : list[2],
                    "CPU Usuage": list[3],
                    "MemRegions": list[5],
                    "PhysMem" : list[6],
                    "VM": list[7],
                    "Networks": list[8],
                    "Disks": list[9]
                ]
            
                returnStr = JSONController.parseJSONToStr(dict: status)
            }
            
            //print(output)
        } catch let error  {
            print(error)
        }
        return returnStr
    }

    // ---------------------------------------------------------------------------------------- //
    
}
