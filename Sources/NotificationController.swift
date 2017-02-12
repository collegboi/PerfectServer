//
//  ConfigureNotification.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 05/02/2017.
//
//

import PerfectNotifications


public class NotficationController {
    
    private class func setupNotificationPusher() -> String {
    
        let notificationSettings = LocalDatabaseHandler.getCollection("NotificationSetting", query: [:])
        
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
        
        NotificationPusher.development = true
        
        NotificationPusher.addConfigurationIOS(name: notificationsTestId,
                                               keyId: apnsKeyIdentifier,
                                               teamId: apnsTeamIdentifier,
                                               privateKeyPath: apnsPrivateKey)
        
        return notificationsTestId
    }
    
    
    private class func sendNotifcation( deviceId: String, messsage: String, silent: Bool = false ) {
        
        
        let apnsTopic = self.setupNotificationPusher()
        
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
                print("\(response)")
            }
        } else {
            print("notificaitons empty")
        }
        
    }
    
    private class func sendManyNotifcation( deviceId: [String], messsage: String, silent: Bool = false ) {
        
        
        let apnsTopic = self.setupNotificationPusher()
        
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
            }
        } else {
            print("notificaitons empty")
        }
        
    }

    
    public class func sendSilentNotification( deviceIDs: [String], message: String) {
        self.sendManyNotifcation(deviceId: deviceIDs, messsage: message)
    }
    
    public class func sendSingleNotfication( deviceID: String, message: String ) {
        self.sendNotifcation(deviceId: deviceID, messsage: message)
    }
    
    public class func sendMultipleNotifications( deviceIDs: [String], message: String ) {
        for deviceID in deviceIDs {
            self.sendNotifcation(deviceId: deviceID, messsage: message)
        }
    }
}
