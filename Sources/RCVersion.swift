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
    import Cocoa
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
 
    
    class func parseJSONConfig( key:String, dataStr : String) -> String? {
        
        var returnData = ""
        
        //do {
            
            //let data = dataStr.data(using: String.Encoding.utf8)!
            
            //let parsedData = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as! [String:Any]
            
            //let dict = parsedData[key] as! [String:Any]
            
            returnData = ""//parseJSONToStr(dict: dict)
            
        //} catch let error {
        //    print(error)
        //}
        
        return returnData
    }
    
    
    class func parseJSONToStr( dict: [String:Any] ) -> String  {
        
        var result = ""
        
        //do {
            //let jsonData: NSData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted ) as Data
            
            result = ""//NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            
       // } catch let error {
         //   print(error)
       // }
        
        return result
    }
    
    
    class func sendRemoteConfig( jsonString: String ) -> Bool {
        
        let versionData = parseJSONConfig(key: "version", dataStr: jsonString)
        
        DatabaseController.insertDocument("configVersion", jsonStr: versionData!)
        
        
        if RemoteConfig.updateContentsOfFile(jsonString) {
            return true
        } else {
            return false
        }
        
    }
}
