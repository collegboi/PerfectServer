//
//  ConfigSettingController.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 25/02/2017.
//
//

import Foundation

class ConfigSettingController {
    
    
    class func getConfigFile() -> String {
        
        return FileController.sharedFileHandler!.getContentsOfConfigFile()
        
    }
    
    class func sendConfigFile(_ jsonData: String) -> Bool {
        
        return FileController.sharedFileHandler!.sendContentsOfConfigFile(jsonData)
        
    }
    
    class func getConfigSettings() -> [String:Any] {
    
        let data = FileController.sharedFileHandler!.getContentsOfConfigFile()
        
        return JSONController.parseJSONToDict(data)
    }
    
}
