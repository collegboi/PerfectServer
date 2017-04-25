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
    
    public func getRemoteConfigVersion(_ appKey: String , _ configVersion: String, _ theme: String = "")-> String {
        
        var config : [String:String] = [:]
        
        if theme != "" {
            config = ["configVersion": configVersion, "appTheme": theme]
        } else {
            config = ["configVersion": configVersion]
        }
        
        let configJSON = JSONController.parseJSONToStr(dict: config)
        
        let storage = Storage()
        storage.setAppKey(appKey)
        storage.setCollectionName("RemoteConfig")
        
        let colleciton = storage.getCollectionStr(query: configJSON)
        
        let collectionList = JSONController.parseDatabaseAny(colleciton)
        
        if collectionList.count > 0 {
            
            guard let collectionObj = collectionList[0] as? [String:String] else {
                return "collectionObj  is empty: " + configVersion
            }
            
            let filePath = collectionObj["path"]!
            
            return (FileController.sharedFileHandler?.getContentsOfFile("", filePath))!
            
        } else {
            return "collectionList is empty: " + configVersion
        }

    }
    
    public func getConfigVerison(_ appKey: String , _ version: String, _ theme: String = "") -> String {
        
        let storage = Storage()
        storage.setAppKey(appKey)
        storage.setCollectionName("ABTesting")
        
        let abTestings = storage.getCollectionStr()
        
        let abTestingObject = JSONController.parseDatabaseAny(abTestings)
        
        var objectVal: [String:AnyObject]?
        
        for object in abTestingObject {
            
            guard let dict = object as? [String:Any] else {
                return "parsing dict error"
            }
            
            guard let versionVal = dict["version"] as? String  else {
                return "no version"
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
                    return "versionA is empty"
                }
                
                self.requestNo = (self.requestNo + 1) % 2
                
                return (FileController.sharedFileHandler?.getContentsOfFile("ConfigFiles", "config_"+version+".json"))!
                
                
            default:
                
                guard let version = objectVal?["versionB"] as? String else {
                    return "versionB is empty"
                }
                
                self.requestNo = (self.requestNo + 1) % 2
                
                return (FileController.sharedFileHandler?.getContentsOfFile("ConfigFiles", "config_"+version+".json"))!
            }
            
        } else {
            
            var config : [String:String] = [:]
            
            if theme != "" {
                config = ["version": version, "appTheme": theme]
            } else {
                config = ["version": version]
            }
            
            let configJSON = JSONController.parseJSONToStr(dict: config)
            
            let storage = Storage()
            storage.setAppKey(appKey)
            storage.setCollectionName("RemoteConfig")
            
            let colleciton = storage.getCollectionStr(query: configJSON)
            
            let collectionList = JSONController.parseDatabaseAny(colleciton)
            
            if collectionList.count > 0 {
                
                let languages = ["available": "1"] as [String : Any]
                
                let languagesJSON = JSONController.parseJSONToStr(dict: languages)
                
                storage.setCollectionName("Languages")
                
                let languagesStrings = storage.getCollectionStrFields(query: languagesJSON, fields: "name")
                
                let themes = ["version": version, "appLive": "1"] as [String : Any]
                
                let themesJSON = JSONController.parseJSONToStr(dict: themes)
                
                storage.setCollectionName("RemoteConfig")
                
                let themesStrings = storage.getCollectionStrFields(query: themesJSON, fields: "appTheme")
             
                guard let collectionObj = collectionList[0] as? [String:String] else {
                    return "collectionObj  is empty: " + version
                }
                
                let filePath = collectionObj["path"]!
                
                var configObjects = JSONController.parseJSONToDict((FileController.sharedFileHandler?.getContentsOfFile("", filePath))!)
                configObjects["themes"] = themesStrings
                configObjects["languagesList"] = languagesStrings
                
                return JSONController.parseJSONToStr(dict: configObjects)

            } else {
                return "collectionList is empty: " + version
            }
                
        }
    }

}
