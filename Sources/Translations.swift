//
//  Translations.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 04/02/2017.
//
//
#if os(Linux)
    import LinuxBridge
#else
    import Darwin
#endif

class Translations {
    
    class func getTranslationFile(_ filePath: String, _ version: String ) -> String {
        
        return FileController.sharedFileHandler!.getContentsOfFile(filePath, version)
        
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

    
    class func parseJSONConfig( key:String, dataStr : String) -> String? {
        
        var returnData = ""
        
        let encoded = dataStr
        
        do {
            
            if let decoded = try encoded.jsonDecode() as? [String:Any] {
             
                if let  dict = decoded[key] as? [String:Any]  {
                 
                    returnData = parseJSONToStr(dict: dict)
                    
                } else if let str = decoded[key] as? String {
                    
                    returnData = str
                }
            
            } else if let strDecode = try encoded.jsonDecode() as? String {
                returnData = strDecode
            }
            
        } catch let error {
            print(error)
        }
        
        return returnData
    }

    
    @discardableResult
    class func postTranslationFile(_ appkey: String, _ jsonStr: String ) -> String {
        
        
        let translationList = "{\"translationList\":" + parseJSONConfig(key: "translationList", dataStr: jsonStr)! + "}"
        
        let language = parseJSONConfig(key: "language", dataStr: jsonStr)
        
        let newVersion = parseJSONConfig(key: "newVersion", dataStr: jsonStr)
        
        FileController.sharedFileHandler?.updateContentsOfFile(newVersion! ,translationList)
        
        DatabaseController.updateInsertDocument(appkey,"Languages", jsonStr: language!)
        
        return ""
    }
    
    
}

