//
//  Weather.swift
//  PerfectProject2
//
//  Created by Timothy Barnard on 19/01/2017.
//
//


import PerfectLib

class Weather {
    
    // Get the
    static func getCurrent(_ location: String = "Canada/Newmarket") -> String {
        
        //let data = getEndpoint(endpoint: "conditions/q/\(location).json", args: [], token: apiToken)
        //let current_observation = data["current_observation"] as! [String: Any]
        
        var trimmedData = [String:Any]()
        
        trimmedData["observation_time"]		= "12:00:00"//current_observation["observation_time"]
        trimmedData["weather"]				= "Cold"//current_observation["weather"]
        trimmedData["temperature_string"]	= "12.3"//current_observation["temperature_string"]
        
        do {
            return try trimmedData.jsonEncodedString()
        } catch {
            return "[\(error)]"
        }
    }
    
}
