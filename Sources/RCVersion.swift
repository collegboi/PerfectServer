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
                return "1.2"
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
        
        let versionData = parseJSONConfig(key: "version", dataStr: jsonString)
        let applicationID = parseJSONConfig(key: "applicationID", dataStr: jsonString)
        
        let path = "ConfigFiles/config_"+versionData+".json"
        
        let configData: [String:String] = [
            "version" : versionData,
            "applicationID": applicationID,
            "path" : path
        ]
        let configStr = JSONController.parseJSONToStr(dict: configData)
        
        
        DatabaseController.insertDocument(apid,"RemoteConfig", jsonStr: configStr)
        
        FileController.sharedFileHandler?.updateContentsOfFile(path,jsonString)
        
        return true
        
    }
}
