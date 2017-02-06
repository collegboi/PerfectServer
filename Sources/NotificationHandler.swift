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

/// Defines and returns the Web Authentication routes
public func makeNotificationRoutes() -> Routes {
    var routes = Routes()
    
    routes.add(method: .post, uri: "/notification/", handler: sendNotificaiton)
    //routes.add(method: .post, uri: "/tracker/{collection}/{objectid}", handler: sendTrackerIssuesObject)
    routes.add(method: .get, uri: "/notification/", handler: getAllNotificaitons)
    //routes.add(method: .get, uri: "/tracker/{collection}/{objectid}/", handler: getTrackerIssuesObject)
    
    // Check the console to see the logical structure of what was installed.
    print("\(routes.navigator.description)")
    
    return routes
}


func getAllNotificaitons(request: HTTPRequest, _ response: HTTPResponse) {
    
    let allNotifications = DatabaseController.retrieveCollection("Notifications")
    
    response.appendBody(string:allNotifications)
    response.completed()
}

func sendNotificaiton(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "postbody"))
        response.completed()
        return
    }
    
    let jsonArry = JSONController.parseJSONToDict(jsonStr)
    
    if jsonArry.count > 0 {
        let deviceid = jsonArry["deviceId"] as! String
        let message = jsonArry["message"] as! String
        
        NotficationController.sendSingleNotfication(deviceID: deviceid, message: message)
        
        let notificationObject: [String:String] = [
            "deviceID": deviceid,
            "timestamp": "12/02/2012 08:00:00",
            "message": message
        ]
        
        let objectStr = JSONController.parseJSONToStr(dict: notificationObject)
        
        DatabaseController.insertDocument("Notifications", jsonStr: objectStr)
        
    }
    
    let returnStr =  ResultBody.successBody(value: "sent")
    
    response.appendBody(string: returnStr)
    response.completed()
}
