//
//  ConfigureNotification.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 05/02/2017.
//
//

import PerfectNotifications

private var _NotifcationSharedInstance: ConfigureNotfications?

public class ConfigureNotfications {
    
    private var configurationName: String?
    
    private class var sharedNotification: ConfigureNotfications? {
        return _NotifcationSharedInstance
    }
    
    public init() {
        
        if(_NotifcationSharedInstance == nil) {
            _NotifcationSharedInstance = self
        }
        self.configure()

    }
    
    private func configure() {
        
        let configurationName = "DITTimetable"
        
        self.configurationName = configurationName
        
        NotificationPusher.addConfigurationIOS(name: configurationName) { (net) in
            
            // This code will be called whenever a new connection to the APNS service is required.
            // Configure the SSL related settings.
            
            net.keyFilePassword = "Apple4ever"
            
//            if FileHandler.sharedFileHandler!.checkIfFileExits("Certs/cert.pem") {
//                print("cert.pem exits")
//            }
//            if FileHandler.sharedFileHandler!.checkIfFileExits("Certs/key.pem") {
//                print("key.pem Exits")
//            }
            
//            guard net.useCertificateChainFile(cert: "./webroot/aps_development.cer") else {
//                let code = Int32(net.errorCode())
//                print("Error validating private key file: \(net.errorStr(forCode: code))")
//                return
//            }
            
            guard net.useCertificateFile(cert: "cert.pem") &&
                net.usePrivateKeyFile(cert: "ck.pem") &&
                net.checkPrivateKey() else {
                    
                    let code = Int32(net.errorCode())
                    print("Error validating private key file: \(net.errorStr(forCode: code))")
                    return
            }
        }
        
        NotificationPusher.development = true // set to toggle to the APNS sandbox serer
        
        ///"e4d8fbbe085dfa93e5212a3759a774bed6264b17a437ad94b51359c92105ab3a"
        let deviceId = "e4d8fbbe085dfa93e5212a3759a774bed6264b17a437ad94b51359c92105ab3a"
        let ary = [IOSNotificationItem.alertBody("This is the message"), IOSNotificationItem.sound("default")]
        let n = NotificationPusher()
        
        n.apnsTopic = "barnard.com.DIT-Timetable"
        
        
        n.pushIOS(configurationName: configurationName, deviceToken: deviceId, expiration: 0, priority: 0, notificationItems: ary ) { (response) in
            print("NotificationResponse: \(response.body)")
        }

    }
    

}
