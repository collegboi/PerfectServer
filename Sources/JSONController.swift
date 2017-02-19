//
//  JSONController.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 06/02/2017.
//
//


public class JSONController {
    
    public class func parseDatabaseAny(_ jsonStr: String) -> [Any] {
        var decodedJSOn = [Any]()
        
        do {
            guard let decoded  = try jsonStr.jsonDecode() as? [Any] else {
                return decodedJSOn
            }
            
            decodedJSOn = decoded
            
        } catch let error {
            print(error)
        }
        return decodedJSOn
    }
    
    
    public class func parseDatabase(_ jsonStr: String) -> [[String:Any]] {
        var decodedJSOn = [[String:Any]]()
        
        do {
            guard let decoded  = try jsonStr.jsonDecode() as? [String:Any] else {
                return decodedJSOn
            }
            decodedJSOn = decoded["data"] as! [[String:Any]]
            
        } catch let error {
            print(error)
        }
        return decodedJSOn
    }
    
    public class func parseJSONToArrDic(_ jsonStr: String) -> [[String:Any]] {
        
        var decodedJSOn = [[String:Any]]()
        
        do {
            guard let decoded  = try jsonStr.jsonDecode() as? [[String:Any]] else {
                return decodedJSOn
            }
            decodedJSOn = decoded
            
        } catch let error {
            print(error)
        }
        return decodedJSOn
    }
    
    public class func parseJSONToDict(_ jsonStr: String) -> [String:Any] {
        
        var decodedJSOn = [String:Any]()
        
        do {
            guard let decoded  = try jsonStr.jsonDecode() as? [String:Any] else {
                return decodedJSOn
            }
            decodedJSOn = decoded
            
        } catch let error {
            print(error)
        }
        return decodedJSOn
    }
    
    class func parseJSONStr( dict: [String:[String:String]] ) -> String {
        var result = ""
        
        do {
            result = try dict.jsonEncodedString()
            
        } catch let error {
            print(error)
        }
        
        return result
    }
    
    
    class func parseJSONToStr( dict: [String:Any] ) -> String  {
        
        var result = ""
        
        do {
            result = try dict.jsonEncodedString()
            
        } catch let error {
            print(error)
        }
        
        return result
    }

}
