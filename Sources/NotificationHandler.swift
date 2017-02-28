//
//  NotificationHandler.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 06/02/2017.
//
//

import PerfectLib
import PerfectHTTP
import MongoDB
import Foundation

/// Defines and returns the Web Authentication routes
public func makeNotificationRoutes() -> Routes {
    var routes = Routes()
    
    routes.add(method: .post, uri: "/api/{appkey}/notification/", handler: sendNotificaiton)
    //routes.add(method: .post, uri: "/tracker/{collection}/{objectid}", handler: sendTrackerIssuesObject)
    routes.add(method: .get, uri: "/api/{appkey}/notification/", handler: getAllNotificaitons)
    //routes.add(method: .get, uri: "/tracker/{collection}/{objectid}/", handler: getTrackerIssuesObject)
    
    // Check the console to see the logical structure of what was installed.
    print("\(routes.navigator.description)")
    
    return routes
}


func getAllNotificaitons(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let appKey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing apID"))
        response.completed()
        return
    }

    
    let allNotifications = Storage.getCollectionStr(appKey, "TBNotification")
    
    response.appendBody(string:allNotifications)
    response.completed()
}

func sendNotificaiton(request: HTTPRequest, _ response: HTTPResponse) {
    
    func nowDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        
        return dateFormatter.string(from: Date())
    }
    
    guard let appKey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing apID"))
        response.completed()
        return
    }
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "postbody"))
        response.completed()
        return
    }
    
    response.isStreaming = true
    
    let jsonArry = JSONController.parseJSONToDict(jsonStr)
    
    let resultStr = ResultBody.errorBody(value: "missing data")
    
    if jsonArry.count > 0 {
        let deviceid = jsonArry["deviceId"] as! String
        let message = jsonArry["message"] as! String
        let development = jsonArry["development"] as! String
        let developmentBool: Bool = development == "1";
        
       NotficationController.sendSingleNotfication(appKey, deviceId: deviceid, message: message, development: developmentBool, notificationCompleted: { (complete, resultString, resultBool) in
        
            if complete {
            
                let notificationObject: [String:String] = [
                    "deviceID": deviceid,
                    "timestamp": nowDateTime(),
                    "message": message,
                    "status" : resultString,
                    "sent" : "\(resultBool)"
                ]
                
                let objectStr = JSONController.parseJSONToStr(dict: notificationObject)
                
                DatabaseController.insertDocument(appKey,"TBNotification", jsonStr: objectStr)
            }
        
            response.appendBody(string: resultString)
            response.completed()
        
       })
        
    } else {
        
        response.appendBody(string: resultStr)
        response.completed()
    }
}
