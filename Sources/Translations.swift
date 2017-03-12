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
    
    class func getTranslationVersionFile(_ appKey: String, _ version: String, _ language: String ) -> String {
        
        var config : [String:String] = [:]
        config = ["langVersion": version,  "languageName": language ]
        
        
        let configJSON = JSONController.parseJSONToStr(dict: config)
        
        let colleciton = Storage.getCollectionStr(appKey, "LanguageVersion", query: configJSON)
        
        let collectionList = JSONController.parseDatabaseAny(colleciton)
        
        if collectionList.count > 0 {
            
            
            guard let collectionObj = collectionList[0] as? [String:String] else {
                return "collectionObj  is empty: " + version
            }
            
            let filePath = collectionObj["filePath"]!
            
            return (FileController.sharedFileHandler?.getContentsOfFile("", filePath))!
            
        } else {
            return "collectionList is empty: " + version
        }

    }
    
    class func getTranslationFile(_ appKey: String, _ version: String, _ language: String ) -> String {
        
        var config : [String:String] = [:]
        config = ["appVersion": version, "published": "1", "languageName": language ]
        
        
        let configJSON = JSONController.parseJSONToStr(dict: config)
        
        let colleciton = Storage.getCollectionStr(appKey, "LanguageVersion", query: configJSON)
        
        let collectionList = JSONController.parseDatabaseAny(colleciton)
        
        if collectionList.count > 0 {
            
            
            guard let collectionObj = collectionList[0] as? [String:String] else {
                return "collectionObj  is empty: " + version
            }
            
            let filePath = collectionObj["filePath"]!
            
            return (FileController.sharedFileHandler?.getContentsOfFile("", filePath))!
            
        } else {
            return "collectionList is empty: " + version
        }
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
        
        
        let translationList = "{\"translationList\":" + jsonStr + "}"
        
        let filePath = parseJSONConfig(key: "filePath", dataStr: jsonStr)
        
//        let versionData = parseJSONConfig(key: "version", dataStr: jsonStr)
//        let languageID = parseJSONConfig(key: "languageID", dataStr: jsonStr)
//        let filePath = parseJSONConfig(key: "filePath", dataStr: jsonStr)
//        let langVersion = parseJSONConfig(key: "langVersion", dataStr: jsonStr)
//        let appLive = parseJSONConfig(key: "appLive", dataStr: jsonStr)
//        
//        let configData: [String:String] = [
//            "version" : versionData!,
//            "languageID": languageID!,
//            "path" : filePath!,
//            "langVersion": langVersion!,
//            "appLive":appLive!
//        ]
//        let configStr = JSONController.parseJSONToStr(dict: configData)
        
        FileController.sharedFileHandler?.updateContentsOfFile(filePath!,translationList)
        
        //DatabaseController.updateInsertDocument(appkey,"LanguageVersion", jsonStr: configStr)
        
        return ""
    }
    
    
}

