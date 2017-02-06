//
//  ConfigureNotification.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 05/02/2017.
//
//

import PerfectNotifications


public class NotficationController {
    
    private class func sendNotifcation( deviceId: String, messsage: String, silent: Bool = false ) {
        
        let configurationName = "DITTimetable"
        
        NotificationPusher.addConfigurationIOS(name: configurationName) { (net) in
            
            net.keyFilePassword = ""
            
            guard net.useCertificateFile(cert: "./webroot/cert.pem") &&
                net.usePrivateKeyFile(cert: "./webroot/key.pem") &&
                net.checkPrivateKey() else {
                    
                    let code = Int32(net.errorCode())
                    print("Error validating private key file: \(net.errorStr(forCode: code))")
                    return
            }
        }
        
        NotificationPusher.development = true // set to toggle to the APNS sandbox serer
        
        ///"e4d8fbbe085dfa93e5212a3759a774bed6264b17a437ad94b51359c92105ab3a"
        
        var ary = [IOSNotificationItem]()
        ary.append(IOSNotificationItem.alertBody(messsage))
        
        if !silent {
            ary.append(IOSNotificationItem.sound("none"))
        } else {
            ary.append(IOSNotificationItem.sound("default"))
            ary.append(IOSNotificationItem.badge(1))
        }
        
        let n = NotificationPusher()
        
        n.apnsTopic = "barnard.com.DIT-Timetable"
        
        
        n.pushIOS(configurationName: configurationName, deviceToken: deviceId, expiration: 0, priority: 10, notificationItems: ary ) { (response) in
            print("NotificationResponse: \(response.body)")
        }
        
    }
    
    public class func sendSilentNotification( deviceIDs: [String], message: String) {
        for deviceid in deviceIDs {
            self.sendNotifcation(deviceId: deviceid, messsage: message, silent: true)
        }
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
