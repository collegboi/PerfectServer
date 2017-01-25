//
//  ResultBody.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 21/01/2017.
//
//

class ResultBody {
    
    class func errorBody( value: String) -> String {
        
        let resultBody: [String:String] = [
            "result" : "error",
            "message": value
        ]
        
        return RCVersion.parseJSONToStr(dict: resultBody)
    }
    
    class func successBody( value: String) -> String {
        
        let resultBody: [String:String] = [
            "result" : "success",
            "message": value
        ]
        
        return RCVersion.parseJSONToStr(dict: resultBody)
    }
    
}
