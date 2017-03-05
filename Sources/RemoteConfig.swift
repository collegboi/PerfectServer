//
//  RemoteConfig.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 21/01/2017.
//
//

#if os(Linux)
    import LinuxBridge
#else
    import Darwin
#endif

import PerfectLib

private var _RemoteConfig: RemoteConfig?

class RemoteConfig {
    
    var requestNo: Int = 0
    
    public class var shared: RemoteConfig? {
        return _RemoteConfig
    }
    
    @discardableResult
    public class func setup() -> RemoteConfig? {
        
        let remoteConfig = RemoteConfig()
        remoteConfig.requestNo = 0
        return remoteConfig
    }
    
    public init() {
        
        if (_RemoteConfig == nil) {
            _RemoteConfig = self
        }
    }
    
    public func getConfigVerison(_ appKey: String , _ version: String) -> String {
        
        let abTestings = Storage.getCollectionStr(appKey,"ABTesting")
        
        let abTestingObject = JSONController.parseDatabaseAny(abTestings)
        
        var objectVal: [String:AnyObject]?
        
        for object in abTestingObject {
            
            guard let dict = object as? [String:Any] else {
                return ""
            }
            
            guard let versionVal = dict["version"] as? String  else {
                return ""
            }

            if  versionVal == version {
                #if os(Linux)
                    objectVal = (dict as? [String : AnyObject])!
                #else
                    objectVal = dict as [String : AnyObject]
                #endif
                
                break
            }
        }
        
        if objectVal != nil {
        
            switch requestNo {
            case 0:
                
                guard let version = objectVal?["versionA"] as? String else {
                    return ""
                }
                
                self.requestNo = (self.requestNo + 1) % 2
                
                return (FileController.sharedFileHandler?.getContentsOfFile("ConfigFiles", "config_"+version+".json"))!
                
                
            default:
                
                guard let version = objectVal?["versionB"] as? String else {
                    return ""
                }
                
                self.requestNo = (self.requestNo + 1) % 2
                
                return (FileController.sharedFileHandler?.getContentsOfFile("ConfigFiles", "config_"+version+".json"))!
            }
            
        } else {
            
            let config : [String:String] = ["version": version]
            
            let configJSON = JSONController.parseJSONToStr(dict: config)
            
            let colleciton = Storage.getCollectionStr(appKey, "RemoteConfig", query: configJSON)
            
            let collectionList = JSONController.parseDatabaseAny(colleciton)
            
            if collectionList.count > 0 {
             
                guard let collectionObj = collectionList[0] as? [String:String] else {
                    return ""
                }
                
                let filePath = collectionObj["path"]!
                
                return (FileController.sharedFileHandler?.getContentsOfFile("", filePath))!

            } else {
                return ""
            }
                
        }
    }

}
