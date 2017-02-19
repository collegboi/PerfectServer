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
    
    let versionID: String
    let versionDate: String
    var versionPath: String = ""
    var released: Int = 0
    
    init(versionID: String, versionDate: String) {
        self.versionID = versionID
        self.versionDate = versionDate
    }
 
    
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
    
    
    class func sendRemoteConfig( jsonString: String ) -> Bool {
        
        let versionData = parseJSONConfig(key: "version", dataStr: jsonString)
        
        let path = "ConfigFiles/config_"+versionData+".json"
        
        let configData: [String:String] = [
            "version" : versionData,
            "path" : path
        ]
        let configStr = JSONController.parseJSONToStr(dict: configData)
        
        
        DatabaseController.insertDocument("RemoteConfig", jsonStr: configStr)
        
        FileController.sharedFileHandler?.updateContentsOfFile(path,jsonString)
        
        return true
        
    }
}
