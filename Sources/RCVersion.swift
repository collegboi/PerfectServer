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
        
        FileController.sharedFileHandler?.updateContentsOfFile(filePath,jsonString)
        
        return true
        
    }
}
