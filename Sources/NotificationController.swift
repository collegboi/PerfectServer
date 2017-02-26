//
//  ConfigureNotification.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 05/02/2017.
//
//

import PerfectNotifications
import Foundation


public class NotficationController {
    
    private class func setupNotificationPusher(_ appKey: String, development: Bool) -> String {
    
        let notificationSettings = LocalDatabaseHandler.getCollection(appKey, "NotificationSetting", query: [:])
        
        let notificationSetting = notificationSettings[0]

        guard let notificationsTestId = notificationSetting["appID"] as? String else {
            return ""// "barnard.com.DIT-Timetable"
        }
        
        guard let apnsTeamIdentifier = notificationSetting["teamID"] as? String else {
            return ""//"4EU4PGMLU9"
        }
        guard let apnsKeyIdentifier = notificationSetting["keyID"] as? String else {
            return ""//"BAKCFXE74R"
        }
        guard let apnsPrivateKey = notificationSetting["name"] as? String else {
            return ""//
        }
        //let test = "APNSAuthKey_\(apnsKeyIdentifier).p8"
        
        NotificationPusher.development = development
        
        NotificationPusher.addConfigurationIOS(name: notificationsTestId,
                                               keyId: apnsKeyIdentifier,
                                               teamId: apnsTeamIdentifier,
                                               privateKeyPath: apnsPrivateKey)
        
        return notificationsTestId
    }
    
    private class func sendNotificationCompletion(_ appKey:String, deviceId: String, messsage: String, development: Bool, silent: Bool = false, notificationCompleted : @escaping (_ succeeded: Bool, _ resultStr: String, _ resultBool: Bool) -> ()) {
        
        var result = [String:String]()
        result["result"] = "message not sent"
        result["reason"] = "nill"
        result["status"] = "404"
        var resultBool = false
        
        let apnsTopic = self.setupNotificationPusher(appKey, development: development)
        
        if apnsTopic != "" {
            
            print("Sending notification to all devices: \(deviceId)")
            
            var ary = [IOSNotificationItem]()
            ary.append(IOSNotificationItem.alertBody(messsage))
            
            if !silent {
                ary.append(IOSNotificationItem.sound("none"))
            } else {
                ary.append(IOSNotificationItem.sound("default"))
                ary.append(IOSNotificationItem.badge(1))
            }
            
            
            NotificationPusher(apnsTopic: apnsTopic ).pushIOS(
            configurationName: apnsTopic, deviceToken: deviceId, expiration: 0, priority: 10, notificationItems: ary) { (response) in
                //print("\(response)")
                print(response.status)
                print(response.jsonObjectBody)
                let responseStatus: Int = response.status.code
                
                if responseStatus == 202 {
                    result["result"] = "message sent"
                    result["reason"] = "nill"
                    result["status"] = "\(response.status)"
                    resultBool = true
                } else {
                    result["result"] = "message not sent"
                    result["reason"] = JSONController.parseJSONToStr(dict: response.jsonObjectBody)
                    result["status"] = "\(response.status)"
                    resultBool = false
                }
                
                let resultString = JSONController.parseJSONToStr(dict: result)
                
                notificationCompleted( true,resultString, resultBool )
            }
        } else {
            print("notificaitons empty")
            let resultString = JSONController.parseJSONToStr(dict: result)
            notificationCompleted( true, resultString, resultBool )
        }
    }
    
    private class func sendNotifcation(_ appKey:String, deviceId: String, messsage: String, development: Bool, silent: Bool = false ) -> ( Bool, String ) {
        
        var result = [String:String]()
        var resultBool = false
        
        let apnsTopic = self.setupNotificationPusher(appKey, development: development)
        
        if apnsTopic != "" {
        
            print("Sending notification to all devices: \(deviceId)")
            
            var ary = [IOSNotificationItem]()
            ary.append(IOSNotificationItem.alertBody(messsage))

            if !silent {
                ary.append(IOSNotificationItem.sound("none"))
            } else {
                ary.append(IOSNotificationItem.sound("default"))
                ary.append(IOSNotificationItem.badge(1))
            }

            
            NotificationPusher(apnsTopic: apnsTopic ).pushIOS(
            configurationName: apnsTopic, deviceToken: deviceId, expiration: 0, priority: 10, notificationItems: ary) { (response) in
                //print("\(response)")
                print(response.status)
                print(response.jsonObjectBody)
                let responseStatus: Int = response.status.code
                
                if responseStatus == 202 {
                    result["result"] = "message sent"
                    result["reason"] = "nill"
                    result["status"] = "\(response.status)"
                    resultBool = true
                } else {
                    result["result"] = "message not sent"
                    result["reason"] = JSONController.parseJSONToStr(dict: response.jsonObjectBody)
                    result["status"] = "\(response.status)"
                    resultBool = false
                }
            }
        } else {
            print("notificaitons empty")
        }
        return ( resultBool, JSONController.parseJSONToStr(dict: result) )
    }
    
    private class func sendManyNotifcation(_ appKey: String, deviceId: [String], messsage: String, development: Bool, silent: Bool = false ) -> String {
        
        var result = "{\"reason\":\"no repsonse\"}"
        
        let apnsTopic = self.setupNotificationPusher(appKey, development: development)
        
        if apnsTopic != "" {
            
            print("Sending notification to all devices: \(deviceId)")
            
            var ary = [IOSNotificationItem]()
            ary.append(IOSNotificationItem.alertBody(messsage))
            
            if !silent {
                ary.append(IOSNotificationItem.sound("none"))
            } else {
                ary.append(IOSNotificationItem.sound("default"))
                ary.append(IOSNotificationItem.badge(1))
            }
            
            
            NotificationPusher(apnsTopic: apnsTopic ).pushIOS(
            configurationName: apnsTopic, deviceTokens: deviceId, expiration: 0, priority: 10, notificationItems: ary) { (response) in
                print("\(response)")
                result =   "{\"reason\":\"\(response.description)\"}"
            }
        } else {
            print("notificaitons empty")
        }
        return result
    }
    
    private class func saveNotifcationToDatabase () {
        
        func nowDateTime() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
            
            return dateFormatter.string(from: Date())
        }
    }

    
    public class func sendSilentNotification(_ appKey: String, deviceIDs: [String], message: String, development: Bool = false) -> String {
        return self.sendManyNotifcation(appKey, deviceId: deviceIDs, messsage: message, development: development )
    }
    
    public class func sendSingleNotfication(_ appKey:String, deviceId: String, message: String, development: Bool, silent: Bool = false, notificationCompleted : @escaping (_ succeeded: Bool, _ resultStr: String, _ resultBool: Bool) -> ()) {
        //return self.sendNotifcation(appKey, deviceId: deviceID, messsage: message, development: development)
        
        self.sendNotificationCompletion(appKey, deviceId: deviceId, messsage: message, development: development) { (result, notifStr, notifResult) in
            notificationCompleted( true, notifStr, notifResult )
        }
        
        notificationCompleted( false, "", false)
        
    }
    
    public class func sendMultipleNotifications(_ appKey: String, deviceIDs: [String], message: String, development: Bool = false ) -> ( Bool, [String] ) {
        
        let results = [String]()
        let resultBool = false
        
//        for deviceID in deviceIDs {
//            let (result, resultBody ) = self.sendNotifcation(appKey, deviceId: deviceID, messsage: message, development: development)
//            results.append(resultBody)
//            resultBool = result
//        }
        
        return (resultBool, results)
    }
}
