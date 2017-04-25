//
//  RCVersion.swift
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

class RCVersion {
    
    class func parseJSONConfig( key:String, dataStr : String) -> String {
        
        let encoded = dataStr
        
        do {
        
            let decoded = try encoded.jsonDecode() as? [String:Any]
            
            
            guard let dict = decoded?[key] as? String else {
                return ""
            }
            
            return dict
            //returnData = parseJSONToStr(dict: dict)
            
        } catch let error {
            print(error)
        }
        
        return ""
    }
    
    
    class func parseJSONToStr( dict: [String:Any] ) -> String  {
        
        var result = ""
        
        do {
            
            //let scoreArray: [String:Any] = dict
            let dictStr = try dict.jsonEncodedString()
            result = dictStr
            
        } catch let error {
            print(error)
        }
        
        return result
    }
    
    
    class func sendRemoteConfig(_ apid: String, jsonString: String ) -> Bool {
        
//        let versionData = parseJSONConfig(key: "version", dataStr: jsonString)
//        let applicationID = parseJSONConfig(key: "applicationID", dataStr: jsonString)
        let filePath = parseJSONConfig(key: "filePath", dataStr: jsonString)
//        let configVersion = parseJSONConfig(key: "configVersion", dataStr: jsonString)
//        let appTheme = parseJSONConfig(key: "appTheme", dataStr: jsonString)
//        let appLive = parseJSONConfig(key: "appLive", dataStr: jsonString)
//        
//        let configData: [String:String] = [
//            "version" : versionData,
//            "applicationID": applicationID,
//            "path" : filePath,
//            "configVersion": configVersion,
//            "appTheme":appTheme,
//            "appLive":appLive
//        ]
//        let configStr = JSONController.parseJSONToStr(dict: configData)
//        
//        let storage = Storage()
//        storage.setAppKey(apid)
//        storage.setCollectionName("RemoteConfig")
//        
//        storage.insertDocument(jsonStr: configStr)
        
        FileController.sharedFileHandler?.updateContentsOfFile(filePath,jsonString)
        
        return true
        
    }
}
