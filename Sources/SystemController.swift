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
    @discardableResult
    class func getMemoryLinuxUsuage() -> String {
        
        var returnStr = "Error"
        
        do {
            guard let output = try runProc(cmd: "free", args: ["-m"], read: true) else {
                return returnStr
            }
            
            let list: [String] = output.components(separatedBy: "\n")
            
            if list.count > 0 {
                
                let memoryList: [String] = list[1].components(separatedBy: " ")
                
                if memoryList.count >= 5 {
                    let status : [String:AnyObject] = [
                        "total": memoryList[1] as AnyObject,
                        "used": memoryList[2] as AnyObject,
                        "free": memoryList[3] as AnyObject,
                        "avilable": memoryList[6] as AnyObject,
                        "test": memoryList as AnyObject
                    ]
                    
                    returnStr = JSONController.parseJSONToStr(dict: status)
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
